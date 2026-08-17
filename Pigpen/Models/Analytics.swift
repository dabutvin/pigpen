import CryptoKit
import Foundation
import Observation

/// One thing worth knowing about, on its way off the phone.
///
/// A name, a handful of words about it, and at most one number — which is as much as any
/// question about how the game is played needs answering. Nothing here is about a person:
/// the fields are level ids, star counts and seconds on a clock, and there is no room in
/// the shape for anything else.
struct AnalyticsSignal: Equatable, Sendable {
    /// What happened, in the dotted form the dashboards group by: `Level.held`, `Daily.opened`.
    let name: String
    /// The circumstances, as plain strings. Small on purpose — a signal carrying half the
    /// board is a signal nobody can ask a question of.
    let parameters: [String: String]
    /// The one number the signal is about, if it is about a number: the score a pen was
    /// worth, the seconds a daily took. Charted directly, so it is worth choosing.
    let value: Double?

    init(_ name: String, _ parameters: [String: String] = [:], value: Double? = nil) {
        self.name = name
        self.parameters = parameters
        self.value = value
    }
}

/// Who a batch of signals is from — which is to say, not who at all.
///
/// The install is a random number minted on the device the first time the game is opened
/// and hashed before it ever leaves; the session is minted fresh every launch. Together
/// they say *these signals came from one phone, in one sitting*, and nothing else. No
/// advertising identifier, no vendor identifier, no account, nothing Apple asks a
/// tracking permission for.
struct AnalyticsIdentity: Equatable, Sendable {
    /// The hashed install. Hashed again and salted at the far end.
    let install: String
    /// This launch. Gone when the app is.
    let session: String
}

/// Where signals go once the game has finished with them.
///
/// A protocol rather than the uploader outright, for the same reason the buzzing goes
/// through one: the tests can watch what the game asks to send without anything leaving
/// the machine they run on.
@MainActor
protocol AnalyticsSink {
    /// Takes a batch and is done with it. Nothing waits on this — a game is not held up
    /// by a dashboard, and a batch that never arrives is a batch nobody misses.
    func send(_ signals: [AnalyticsSignal], from identity: AnalyticsIdentity)
}

/// A sink that sends nothing. What the game runs on when no dashboard is configured, and
/// on the runs that take the screenshots — a photograph of the board is not a player.
struct SilentAnalytics: AnalyticsSink {
    func send(_ signals: [AnalyticsSignal], from identity: AnalyticsIdentity) {}
}

/// A sink that sends nothing and keeps a list of what it was handed.
@MainActor
final class RecordedAnalytics: AnalyticsSink {
    private(set) var batches: [[AnalyticsSignal]] = []
    private(set) var identities: [AnalyticsIdentity] = []

    /// Every signal handed over, in order, with the batching flattened out — which is
    /// what most questions about what the game sent are actually asking.
    var sent: [AnalyticsSignal] { batches.flatMap { $0 } }

    func send(_ signals: [AnalyticsSignal], from identity: AnalyticsIdentity) {
        batches.append(signals)
        identities.append(identity)
    }
}

/// Where the player's answer to *may we count this* is kept, along with the random number
/// that stands in for the install.
protocol AnalyticsStore {
    func loadIsOn() -> Bool
    func save(isOn: Bool)
    /// The install's own number, or nothing at all on a phone that has never minted one.
    func loadInstall() -> String?
    func save(install: String)
    /// Throws the install's number away, so the player is somebody nobody has counted
    /// before. Wired to the same button that throws the stars away, since a player asking
    /// for the game back as they found it means all of it.
    ///
    /// The switch is deliberately left alone. It is a setting, not game data — the same
    /// way the buzzing is — and a clear-everything that quietly turned counting back on
    /// for somebody who had turned it off would be the worst thing in this file.
    func eraseInstall()
}

/// The real thing: the switch and the number survive the app being closed.
struct StoredAnalytics: AnalyticsStore {
    private static let key = "pigpen.analytics-on"
    private static let installKey = "pigpen.analytics-install"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsOn() -> Bool {
        // Nothing written means on, the same way the buzzing is on as the game comes.
        // What is counted is anonymous and the switch is one screen away, so the game
        // ships counting rather than shipping deaf and asking.
        defaults.object(forKey: Self.key) as? Bool ?? true
    }

    func save(isOn: Bool) {
        defaults.set(isOn, forKey: Self.key)
    }

    func loadInstall() -> String? {
        defaults.string(forKey: Self.installKey)
    }

    func save(install: String) {
        defaults.set(install, forKey: Self.installKey)
    }

    func eraseInstall() {
        defaults.removeObject(forKey: Self.installKey)
    }
}

/// A switch and a number that forget the moment they are put down.
final class RememberedAnalytics: AnalyticsStore {
    private var isOn: Bool
    private var install: String?

    init(isOn: Bool = true, install: String? = nil) {
        self.isOn = isOn
        self.install = install
    }

    func loadIsOn() -> Bool { isOn }

    func save(isOn: Bool) { self.isOn = isOn }

    func loadInstall() -> String? { install }

    func save(install: String) { self.install = install }

    func eraseInstall() { install = nil }
}

/// Everything the game counts, and the one switch that stops it.
///
/// The whole game goes through `Analytics.record` rather than reaching for an uploader
/// where it stands, so that the switch in settings is the only place the question is ever
/// asked — and with it off, nothing is recorded, nothing is held and nothing is sent. Not
/// queued for later, not written down quietly: the signal is dropped at the door.
///
/// Signals are gathered into batches rather than going one at a time, because a puzzle
/// game is played in bursts on a phone that is often on a train. A batch goes when it
/// fills up or when the player puts the game down, whichever comes first, and whatever is
/// still in hand when the app is killed outright is simply lost. That is the trade the
/// low overhead buys: no background task, no disk queue, no retry ladder — a dropped
/// batch costs a few rows on a chart and nothing at all to the player.
@MainActor
@Observable
final class Analytics {
    /// The one the game counts through, and the one the settings toggle holds.
    static let shared = Analytics()

    /// How many signals gather before a batch goes on its own. Small enough that a player
    /// who plays one level and leaves is counted, large enough that a busy screen is one
    /// request rather than twenty.
    static let batchSize = 20

    /// Whether the game is allowed to count. Written the moment it changes, since a player
    /// who turns it off and puts the game down means it.
    ///
    /// Turning it off says so on the way out — that one last signal is sent before the
    /// gate shuts, because a dashboard that cannot tell *switched off* from *stopped
    /// playing* will read every opt-out as a player lost.
    var isOn: Bool {
        didSet {
            guard isOn != oldValue else { return }
            store.save(isOn: isOn)
            if isOn {
                record(.analyticsSwitched(on: true))
            } else {
                pending.append(.analyticsSwitched(on: false))
                flush()
            }
        }
    }

    /// Whether this launch is the first the game has ever been counted on. What tells a run
    /// of sessions apart from a run of installs, and the denominator under every funnel
    /// below it.
    @ObservationIgnored private(set) var isFirstRun: Bool

    @ObservationIgnored private let store: any AnalyticsStore
    @ObservationIgnored private let sink: any AnalyticsSink
    /// This launch. A sitting rather than a person: minted here and never written down.
    @ObservationIgnored private let session = UUID().uuidString
    /// Signals gathered since the last batch went.
    @ObservationIgnored private(set) var pending: [AnalyticsSignal] = []
    /// The hashed install, worked out once and kept, since hashing it on every signal is
    /// work for nothing.
    @ObservationIgnored private var install: String?

    /// What this build counts through: the uploader when there is a dashboard to send to,
    /// and silence when there is not.
    static func defaultSink() -> any AnalyticsSink {
        if let sink = TelemetryDeckSink.configured() { return sink }
        return SilentAnalytics()
    }

    init(
        store: any AnalyticsStore = StoredAnalytics(),
        sink: any AnalyticsSink = Analytics.defaultSink()
    ) {
        self.store = store
        self.sink = sink
        self.isFirstRun = store.loadInstall() == nil
        self.isOn = store.loadIsOn()
        // Minted at launch rather than at the first batch, so that a session killed before
        // it could send anything is still not counted as a fresh install the next morning.
        if isOn { _ = installID() }
    }

    /// Counts one thing, if counting is allowed. Everything the game counts comes through
    /// here, and with the switch off nothing beyond it is even built.
    func record(_ signal: AnalyticsSignal) {
        guard isOn else { return }
        pending.append(signal)
        if pending.count >= Self.batchSize {
            flush()
        }
    }

    /// Hands whatever has gathered to the sink. Called when a batch fills up and when the
    /// player puts the game down, and safe to call on an empty hand.
    func flush() {
        guard !pending.isEmpty else { return }
        let batch = pending
        pending = []
        sink.send(batch, from: AnalyticsIdentity(install: installID(), session: session))
    }

    /// Throws the install's number away, for the player who wants the game back as they
    /// found it. Anything still in hand goes with it rather than being sent under a number
    /// that no longer exists.
    ///
    /// The switch survives, on purpose: a player who turned counting off and then cleared
    /// their stars has not asked to be counted again.
    func eraseEverything() {
        pending = []
        install = nil
        store.eraseInstall()
        isFirstRun = true
    }

    /// The number that stands in for this install, minted on first use and hashed before
    /// it goes anywhere. Random rather than anything the phone already knows about itself,
    /// so there is nothing on the far end to join it up to.
    private func installID() -> String {
        if let install { return install }
        let raw = store.loadInstall() ?? {
            let minted = UUID().uuidString
            store.save(install: minted)
            return minted
        }()
        let hashed = Self.hashed(raw)
        install = hashed
        return hashed
    }

    static func hashed(_ raw: String) -> String {
        let digest = SHA256.hash(data: Data((raw + "pigpen").utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func record(_ signal: AnalyticsSignal) { shared.record(signal) }

    static func flush() { shared.flush() }
}

// MARK: - What the game counts

/// Every signal the game sends, written out in one place.
///
/// One file rather than a name typed out wherever it is sent from, so that the list of
/// what this game knows about its players can be read end to end — by whoever is reading
/// the dashboards, and by whoever is filling in the App Store's privacy questionnaire.
///
/// The rule every one of these keeps: nothing that identifies a player, nothing they typed,
/// nothing about the phone beyond what the platform attaches anyway. Level ids, star
/// counts, seconds on a clock.
extension AnalyticsSignal {
    // MARK: Opening the game

    /// A launch. The count of these against the count of installs is the first thing worth
    /// knowing: whether anybody comes back.
    static func sessionStarted(isFirstRun: Bool) -> AnalyticsSignal {
        AnalyticsSignal("Session.started", ["firstRun": String(isFirstRun)])
    }

    // MARK: The walkthrough

    static let tutorialOpened = AnalyticsSignal("Tutorial.opened")

    /// The walkthrough seen through to the end.
    static let tutorialFinished = AnalyticsSignal("Tutorial.finished")

    /// Backed out of part-way. `lesson` is how far they got, which is where the
    /// walkthrough is losing people.
    static func tutorialLeftEarly(lesson: Int, of total: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "Tutorial.leftEarly",
            ["lesson": String(lesson), "of": String(total)],
            value: Double(lesson)
        )
    }

    // MARK: A level, start to finish

    /// A board opened. Against `Level.held` below, this is the drop-off: which puzzle is
    /// the one players open and never beat.
    static func levelOpened(_ level: PuzzleLevel, world: String, stop: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "Level.opened",
            ["level": level.id, "world": world, "stop": String(stop)],
            value: Double(stop)
        )
    }

    /// A pen that held. The score is the number worth charting: how close players get to
    /// the best pen a map has in it says more about a level than its star count does.
    static func levelHeld(
        _ level: PuzzleLevel,
        verdict: PenVerdict,
        score: Int,
        pieces: Int,
        attempts: Int,
        seconds: TimeInterval?
    ) -> AnalyticsSignal {
        var parameters = [
            "level": level.id,
            "stars": String(verdict.stars),
            "score": String(score),
            "maximumScore": String(level.maximumScore),
            "bestPen": String(verdict.isAsGoodAsItGets),
            "pieces": String(pieces),
            "budget": String(level.fenceBudget),
            "attempts": String(attempts)
        ]
        if let seconds {
            parameters["seconds"] = String(Int(seconds.rounded()))
        }
        return AnalyticsSignal("Level.held", parameters, value: Double(score))
    }

    /// The gate opened on a pen with a gap in it. How many of these a level takes before
    /// it gives is the closest thing the game has to a difficulty reading.
    static func levelEscaped(_ level: PuzzleLevel, attempt: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "Level.escaped",
            ["level": level.id, "attempt": String(attempt)],
            value: Double(attempt)
        )
    }

    /// Nothing got out and the board still said no — a boss rule broken. Which rule is the
    /// point: a briefing nobody understands shows up here as one refusal over and over.
    static func levelRefused(
        _ level: PuzzleLevel,
        refusal: Refusal,
        attempt: Int
    ) -> AnalyticsSignal {
        AnalyticsSignal(
            "Level.refused",
            ["level": level.id, "refusal": refusal.reason, "attempt": String(attempt)],
            value: Double(attempt)
        )
    }

    /// Walked away from a board without ever holding it, and how many goes they had first.
    /// A high count here is a player who tried; a zero is a level whose look put them off.
    static func levelLeftUnheld(_ level: PuzzleLevel, attempts: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "Level.leftUnheld",
            ["level": level.id, "attempts": String(attempts)],
            value: Double(attempts)
        )
    }

    /// Every pen in a world held. The end of the funnel, and the rarest signal the game has.
    static func worldHeld(_ world: String, stars: Int, of total: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "World.held",
            ["world": world, "stars": String(stars), "of": String(total)],
            value: Double(stars)
        )
    }

    // MARK: The book of days

    /// A day's board opened. Whether it was today or one out of the archive is the
    /// difference between a habit and a browse.
    static func dailyOpened(isToday: Bool) -> AnalyticsSignal {
        AnalyticsSignal("Daily.opened", ["today": String(isToday)])
    }

    /// A day held, and the run of days behind it. The streak is what says whether the
    /// dailies are bringing anybody back.
    static func dailyHeld(stars: Int, score: Int, seconds: TimeInterval, streak: Int) -> AnalyticsSignal {
        AnalyticsSignal(
            "Daily.held",
            [
                "stars": String(stars),
                "score": String(score),
                "seconds": String(Int(seconds.rounded())),
                "streak": String(streak)
            ],
            value: Double(streak)
        )
    }

    static let dailyArchiveOpened = AnalyticsSignal("Daily.archiveOpened")

    // MARK: The morning reminder

    /// The game's own offer of a reminder, put up once to somebody who has held a day and so
    /// has a run to lose. The denominator under everything below it.
    static let reminderOffered = AnalyticsSignal("Reminder.offered")

    /// What the offer got back.
    ///
    /// `allowed` is the phone's answer rather than the player's, and it is the whole reason
    /// this is one signal with two fields instead of two signals. A game gets one go at the
    /// system prompt, and the question worth answering is not *how many said yes* but *how
    /// many said yes and were let through* — the two coming apart is the failure this sheet
    /// exists to prevent, and nothing else on the phone will report it.
    static func reminderAnswered(taken: Bool, allowed: Bool? = nil) -> AnalyticsSignal {
        var parameters = ["taken": String(taken)]
        if let allowed {
            parameters["allowed"] = String(allowed)
        }
        return AnalyticsSignal("Reminder.answered", parameters, value: taken ? 1 : 0)
    }

    /// The switch behind the gear, moved after the fact — which is a different question from
    /// the offer, and the one that says whether a reminder somebody accepted is one they
    /// went on wanting.
    static func reminderSwitched(on: Bool, allowed: Bool? = nil) -> AnalyticsSignal {
        var parameters = ["on": String(on)]
        if let allowed {
            parameters["allowed"] = String(allowed)
        }
        return AnalyticsSignal("Reminder.switched", parameters, value: on ? 1 : 0)
    }

    /// The hour moved off the one the game picked. Charted as the hour alone, since what is
    /// worth knowing is whether nine in the morning was the right guess — and the hour a
    /// stranger wants their puzzle at says nothing about who they are.
    static func reminderHourChanged(to time: ReminderTime) -> AnalyticsSignal {
        AnalyticsSignal(
            "Reminder.hourChanged",
            ["hour": String(time.hour)],
            value: Double(time.hour)
        )
    }

    // MARK: The films

    /// A cut scene, watched through or tapped past. Which of the two is the whole question:
    /// a film everybody skips is a film that should be shorter.
    static func filmPlayed(_ name: String, watched: Bool) -> AnalyticsSignal {
        AnalyticsSignal("Film.played", ["film": name, "watched": String(watched)])
    }

    // MARK: Settings

    static let settingsOpened = AnalyticsSignal("Settings.opened")

    /// The button that hands everything back. Rare, and worth knowing when it is not.
    static let dataCleared = AnalyticsSignal("Settings.dataCleared")

    static func hapticsSwitched(on: Bool) -> AnalyticsSignal {
        AnalyticsSignal("Settings.hapticsSwitched", ["on": String(on)])
    }

    static func analyticsSwitched(on: Bool) -> AnalyticsSignal {
        AnalyticsSignal("Settings.analyticsSwitched", ["on": String(on)])
    }
}

extension Refusal {
    /// The name a refusal goes under on a chart. The animal it is about is left off: which
    /// rule was broken is the useful half, and the animal is a property of the level, which
    /// travels beside it anyway.
    var reason: String {
        switch self {
        case .together: "together"
        case .apart: "apart"
        case .uneven: "uneven"
        case .split: "split"
        case .shutIn: "shutIn"
        case .beside: "beside"
        case .tooClose: "tooClose"
        }
    }
}
