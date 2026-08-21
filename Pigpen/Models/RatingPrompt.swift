import Foundation

/// Where a player stands, in the three marks a rating prompt watches — and nothing else. Not
/// who they are, not how long they have had the game, not what they have paid: three numbers
/// the game already keeps for its own reasons, read off the same stores the title screen draws
/// itself from.
struct RatingStanding: Equatable, Sendable {
    /// Worlds held: every pen in every level of them taken at least once.
    let worldsHeld: Int
    /// The best pen a map has in it, taken — the rainbows, across every world there is.
    let bestPens: Int
    /// The run of daily boards, as it stands this morning.
    let streak: Int

    /// A player with nothing to show yet, which is what a game is the day it is installed.
    static let nothing = RatingStanding(worldsHeld: 0, bestPens: 0, streak: 0)
}

extension RatingStanding {
    /// The three marks, read off the two stores the title screen already has in its hands.
    ///
    /// Level ids are unique across worlds and both stores are game-wide, so one `WorldProgress`
    /// answers for every world on the map rather than only the one whose trail is up.
    ///
    /// On the main actor because both of those stores are: the standing is read where the title
    /// screen stands, rather than being handed off somewhere the stars could be moving
    /// underneath it.
    @MainActor
    static func read(
        from progress: WorldProgress,
        daily: DailyProgress,
        today: DailyDate,
        universe: Universe = .all
    ) -> RatingStanding {
        let stars = progress.bestStars
        return RatingStanding(
            worldsHeld: universe.worlds.indices.filter { universe.isCleared($0, stars: stars) }.count,
            bestPens: progress.bestPens.count,
            streak: daily.streak(upTo: today)
        )
    }
}

/// The handful of moments worth asking a player what they think of the game.
///
/// Each of them is something a player would recognise as having just done — a world held, a
/// rainbow taken, a week of mornings kept — rather than a count of launches or an hour on a
/// clock. A game that asks somebody who is losing what they think of it gets the answer it
/// asked for.
enum RatingMoment: String, CaseIterable, Sendable {
    /// Every pen in a world held. The biggest thing a player does in this game, and the end of
    /// the free half of it.
    case worldHeld
    /// The best pen a map has in it, taken — with a few already behind it, since the first
    /// rainbow can come three minutes in on a map that gives one up easily.
    case bestPen
    /// A week of daily boards in a row: somebody who has come back seven mornings running has
    /// an opinion about the game and it is not an idle one.
    case runOfDays

    /// How much of the mark has to be in before a rise in it counts as a moment.
    var bar: Int {
        switch self {
        case .worldHeld: 1
        case .bestPen: 3
        case .runOfDays: 7
        }
    }

    /// This moment's own mark, out of a standing.
    func mark(in standing: RatingStanding) -> Int {
        switch self {
        case .worldHeld: standing.worldsHeld
        case .bestPen: standing.bestPens
        case .runOfDays: standing.streak
        }
    }
}

/// Where what the game has already asked, and what it last saw, are kept.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the reminder's settings
/// are one: a test wants to stand a player up four months and two versions along without
/// leaving anything on the machine it runs on, and a screenshot runner must never be able to
/// raise Apple's prompt at all.
protocol RatingStore {
    /// The marks as they stood the last time the game looked, or nothing at all on a phone it
    /// has never looked at. The absent answer is the whole of why a fresh install is never
    /// asked on the way in — see `RatingPrompt.look(at:now:)`.
    func loadSeen() -> RatingStanding?
    func save(seen: RatingStanding)
    /// The version the player was last asked on, and the day it happened.
    func loadAskedOnVersion() -> String?
    func loadAskedOn() -> Date?
    func save(askedOnVersion: String, on day: Date)
}

/// The real thing: what the game has asked survives the app being closed, and survives a new
/// version of it being installed over the top.
struct StoredRatingRecord: RatingStore {
    private static let lookedKey = "pigpen.rating-looked"
    private static let worldsKey = "pigpen.rating-worlds-held"
    private static let pensKey = "pigpen.rating-best-pens"
    private static let streakKey = "pigpen.rating-streak"
    private static let versionKey = "pigpen.rating-asked-version"
    private static let askedKey = "pigpen.rating-asked-on"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSeen() -> RatingStanding? {
        // A flag of its own rather than reading three zeros as *never looked*, because three
        // zeros is also exactly what a real player looks like on the morning they install it.
        guard defaults.bool(forKey: Self.lookedKey) else { return nil }
        return RatingStanding(
            worldsHeld: defaults.integer(forKey: Self.worldsKey),
            bestPens: defaults.integer(forKey: Self.pensKey),
            streak: defaults.integer(forKey: Self.streakKey)
        )
    }

    func save(seen: RatingStanding) {
        defaults.set(seen.worldsHeld, forKey: Self.worldsKey)
        defaults.set(seen.bestPens, forKey: Self.pensKey)
        defaults.set(seen.streak, forKey: Self.streakKey)
        defaults.set(true, forKey: Self.lookedKey)
    }

    func loadAskedOnVersion() -> String? { defaults.string(forKey: Self.versionKey) }

    func loadAskedOn() -> Date? { defaults.object(forKey: Self.askedKey) as? Date }

    func save(askedOnVersion: String, on day: Date) {
        defaults.set(askedOnVersion, forKey: Self.versionKey)
        defaults.set(day, forKey: Self.askedKey)
    }
}

/// A record that forgets itself the moment it is put down.
final class RememberedRatingRecord: RatingStore {
    private var seen: RatingStanding?
    private var version: String?
    private var asked: Date?

    init(seen: RatingStanding? = nil, askedOnVersion: String? = nil, askedOn: Date? = nil) {
        self.seen = seen
        self.version = askedOnVersion
        self.asked = askedOn
    }

    func loadSeen() -> RatingStanding? { seen }
    func save(seen: RatingStanding) { self.seen = seen }
    func loadAskedOnVersion() -> String? { version }
    func loadAskedOn() -> Date? { asked }

    func save(askedOnVersion: String, on day: Date) {
        version = askedOnVersion
        asked = day
    }
}

/// Whatever it is that actually raises Apple's own rating prompt.
///
/// A protocol for the same reason the notification centre is behind one: nothing in a test, a
/// preview or a screenshot run may put a real prompt up on the machine it is running on — and
/// unlike a notification, a rating prompt cannot be taken back down or counted afterwards.
@MainActor
protocol ReviewRequester {
    /// Asks for the prompt. Whether anything appears is Apple's to decide and nothing here can
    /// find out: the phone shows it three times a year at the very most, and says nothing
    /// either way. So this returns nothing, and the game treats having asked as the outcome.
    func request()
}

/// A requester that writes the asking down in a ledger instead of raising anything.
@MainActor
final class RememberedReviews: ReviewRequester {
    private(set) var timesAsked = 0

    func request() { timesAsked += 1 }
}

/// When the game asks a player what they think of it, and how rarely.
///
/// Apple's prompt is the only way an app is allowed to ask. *Guideline 5.6.1* says to use the
/// provided API and that custom review prompts are disallowed, which is why there is no
/// `RatingPromptView` beside `ReminderPromptView`. That is the opposite of the reminder's shape
/// and for a good reason: the reminder asks in its own words first because the phone's
/// permission sheet is one-shot forever, while the rating prompt may not be dressed up at all
/// and is shown three times a year at most whatever the game does.
///
/// So the only decision left to the game is *when*, and it is made here:
///
/// - **On a high point.** A world held, a rainbow taken, a week of daily boards in a row —
///   `RatingMoment` has the three of them and what each one has to reach.
/// - **On the moment, not on the standing.** The marks the game saw last time are written down,
///   so a rise is a rise once. Somebody who held the meadow a month ago is not asked every time
///   they come back to the title screen; somebody who held it on the way to this screen is.
/// - **Never on the way in.** A phone the game has never looked at has no marks written down,
///   so the first look writes them and asks nothing — which is what keeps a reinstall on a
///   phone that already has a world held from being asked before the game has drawn twice.
/// - **Never twice on one version, and never inside four months.** Apple allows three a year
///   and counts them itself; this is the game keeping well inside that rather than spending
///   the allowance on somebody who has already said their piece.
/// - **Never over anything.** The title screen at rest is where it happens, with the puzzle
///   finished and the map behind them — never over a board, a film, or the one sheet that
///   offers the morning reminder.
///
/// Nothing draws this, so unlike the reminder it is not observable: it is asked a question on
/// the way through the title screen and answers it. And nothing here is game data — clearing
/// every star leaves it standing, the same way clearing them leaves the reminder's hour and the
/// counting switch alone. A player who has been asked has been asked.
@MainActor
final class RatingPrompt {
    /// The one the title screen looks through, so the game's whole record of having asked is
    /// one record.
    static let shared = RatingPrompt()

    /// How long the game leaves between one ask and the next, whatever has happened in between.
    /// Four months: comfortably inside Apple's three a year, and long enough that a player who
    /// waved the prompt away has forgotten it before it can come round again.
    static let quietDays = 120

    /// The marks as they stood the last time the game looked, or nothing on a phone it has
    /// never looked at.
    private(set) var seen: RatingStanding?
    /// The version the player was last asked on, if they have been asked at all.
    private(set) var askedOnVersion: String?
    private(set) var askedOn: Date?

    private let store: any RatingStore
    private let reviews: any ReviewRequester
    /// The version this build calls itself. Handed in so a test can walk a player from one
    /// release to the next without a bundle to rebuild.
    private let version: String

    init(
        store: any RatingStore = StoredRatingRecord(),
        reviews: any ReviewRequester = SystemReviews(),
        version: String = AppRelease.marketing
    ) {
        self.store = store
        self.reviews = reviews
        self.version = version
        self.seen = store.loadSeen()
        self.askedOnVersion = store.loadAskedOnVersion()
        self.askedOn = store.loadAskedOn()
    }

    // MARK: - Where things stand

    /// Whether the game is allowed to ask at all, before any question of whether this is a
    /// moment worth asking on: not twice on one version, and not inside the quiet spell.
    ///
    /// A clock wound backwards leaves it quiet rather than opening the gate, which is the safe
    /// way round: the cost of a prompt withheld is nothing, and the cost of one too many is a
    /// player who came back to be asked again.
    func isDue(now: Date = Date()) -> Bool {
        guard askedOnVersion != version else { return false }
        guard let askedOn else { return true }
        return now.timeIntervalSince(askedOn) >= TimeInterval(Self.quietDays) * 24 * 60 * 60
    }

    /// The moment two standings have between them: a mark that has risen since the game last
    /// looked and has reached what that moment asks of it. Nothing at all when none has.
    ///
    /// The order is the order of `RatingMoment`'s own cases, so when two rise at once — a world
    /// held on a board that also gave up its best pen — the bigger of them is what the ask is
    /// counted under.
    static func moment(from seen: RatingStanding, to standing: RatingStanding) -> RatingMoment? {
        RatingMoment.allCases.first { moment in
            let before = moment.mark(in: seen)
            let now = moment.mark(in: standing)
            return now > before && now >= moment.bar
        }
    }

    // MARK: - Looking

    /// Looks at where a player stands, writes it down, and raises Apple's prompt if this is a
    /// moment worth raising it on. Answers with the moment it asked on, so the caller can count
    /// it — and with nothing at all when it kept quiet, which is nearly always.
    ///
    /// The standing is written down whichever way it goes, and that is the point: a rise the
    /// game has looked at is a rise it has had its chance at. Anything else would leave a
    /// player who held a world during a quiet spell standing on a moment that never goes stale,
    /// to be asked the instant the spell was up.
    @discardableResult
    func look(at standing: RatingStanding, now: Date = Date()) -> RatingMoment? {
        defer { remember(standing) }

        // Nothing written down means nobody has looked yet. Whatever the player has to show
        // for themselves arrived before the game was watching — a reinstall, a restore, or an
        // update from a version that did not keep this — and none of that is a moment.
        guard let seen else { return nil }
        guard let moment = Self.moment(from: seen, to: standing), isDue(now: now) else { return nil }

        ask(at: moment, now: now)
        return moment
    }

    /// Raises the prompt, and writes the asking down before raising it rather than after.
    ///
    /// That order is deliberate. The phone may well show nothing — the allowance is spent, or
    /// Apple simply decides not to — and there is no way to find out which. A game that waited
    /// to hear back before writing anything down would ask again on the next high point, and
    /// again on the one after that, on the strength of never having seen a thing.
    private func ask(at moment: RatingMoment, now: Date) {
        askedOnVersion = version
        askedOn = now
        store.save(askedOnVersion: version, on: now)
        reviews.request()
    }

    private func remember(_ standing: RatingStanding) {
        guard standing != seen else { return }
        seen = standing
        store.save(seen: standing)
    }
}

extension RatingPrompt {
    /// A prompt that has never looked at anybody and cannot raise anything: what a preview, a
    /// test or the screenshot runner is handed, so that photographing the title screen of a
    /// player with a world held can never put Apple's prompt in the picture.
    static func neverAsked(version: String = "0.0.0") -> RatingPrompt {
        RatingPrompt(
            store: RememberedRatingRecord(),
            reviews: RememberedReviews(),
            version: version
        )
    }
}
