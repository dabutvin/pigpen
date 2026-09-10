import Foundation
import Observation

/// The hour of the day a reminder reminders at. Two plain numbers rather than a `Date`, for
/// the same reason `DailyDate` is three: half past eight is half past eight wherever the
/// phone is standing and whichever day it happens to be.
struct ReminderTime: Hashable, Comparable, Sendable {
    let hour: Int
    let minute: Int

    /// Anything outside a day is pulled back into one, so a stored number that has been
    /// meddled with cannot ask to be reminded at the twenty-ninth hour.
    init(hour: Int, minute: Int) {
        let held = min(max(hour * 60 + minute, 0), 24 * 60 - 1)
        self.hour = held / 60
        self.minute = held % 60
    }

    init(minutesFromMidnight: Int) {
        self.init(hour: 0, minute: minutesFromMidnight)
    }

    /// What o'clock it is now, for deciding whether today's reminder has already been missed.
    init(of moment: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: moment)
        self.init(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
    }

    /// How the hour is filed: one number, so a stored preference cannot come back half read.
    var minutesFromMidnight: Int { hour * 60 + minute }

    static func < (left: Self, right: Self) -> Bool {
        left.minutesFromMidnight < right.minutesFromMidnight
    }

    /// Nine in the morning: a new board goes up at midnight, and the reminder that says so is
    /// worth more over breakfast than it is in the small hours.
    static let morning = ReminderTime(hour: 9, minute: 0)

    /// The same o'clock on a given day, which is what a picker showing an hour and a minute
    /// wants to be bound to.
    func on(_ day: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// The hour as the player's own phone would write it — noon or 12:00 depending on where
    /// they are, which is the one part of a daily puzzle that is allowed to be local.
    var face: String {
        on(Date()).formatted(date: .omitted, time: .shortened)
    }
}

/// One reminder: the day it is about, the o'clock it goes off at, and what it says when it
/// does.
///
/// Worked out ahead of time rather than at the moment it fires, because nothing of this
/// game runs while the phone is in a pocket. Every reminder for the fortnight ahead is laid
/// down at once and laid down again each time the player comes back, which is what keeps a
/// day already held from being reminded about.
struct ScheduledReminder: Hashable, Sendable, Identifiable {
    /// What every reminder this game posts is filed under, so clearing them takes ours and
    /// leaves anything else on the phone alone.
    static let idPrefix = "pigpen.daily-reminder."

    let date: DailyDate
    let time: ReminderTime
    /// The headline: the game's own name on every reminder it posts.
    let title: String
    /// The morning's hook, under the name.
    let subtitle: String
    /// The rest of the morning's line, under that.
    let body: String

    var id: String { Self.idPrefix + date.id }
}

/// Where the player's mind on being reminded is kept: whether they want reminding, what hour
/// they want it at, and whether the game has already asked them once.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the book of days is
/// one: a preview, a test or a screenshot run wants a setting in a known state and nothing
/// on the device to show for it afterwards.
protocol ReminderStore {
    func loadIsOn() -> Bool
    func save(isOn: Bool)
    /// The hour, as minutes from midnight.
    func loadTime() -> ReminderTime
    func save(time: ReminderTime)
    /// Whether the game has put the offer up already. Kept so that a player who said no is
    /// not asked again every time they finish a puzzle — the settings sheet is where they
    /// change their mind, not a sheet that keeps coming back.
    func loadHasBeenOffered() -> Bool
    func save(hasBeenOffered: Bool)
}

/// The real thing: an hour chosen on Tuesday is still the hour on Wednesday.
struct StoredReminderSettings: ReminderStore {
    private static let isOnKey = "pigpen.reminder-on"
    private static let timeKey = "pigpen.reminder-time"
    private static let offeredKey = "pigpen.reminder-offered"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsOn() -> Bool { defaults.bool(forKey: Self.isOnKey) }

    func save(isOn: Bool) { defaults.set(isOn, forKey: Self.isOnKey) }

    func loadTime() -> ReminderTime {
        guard defaults.object(forKey: Self.timeKey) != nil else { return .morning }
        return ReminderTime(minutesFromMidnight: defaults.integer(forKey: Self.timeKey))
    }

    func save(time: ReminderTime) {
        defaults.set(time.minutesFromMidnight, forKey: Self.timeKey)
    }

    func loadHasBeenOffered() -> Bool { defaults.bool(forKey: Self.offeredKey) }

    func save(hasBeenOffered: Bool) { defaults.set(hasBeenOffered, forKey: Self.offeredKey) }
}

/// A setting that forgets itself the moment it is put down.
final class RememberedReminderSettings: ReminderStore {
    private var isOn: Bool
    private var time: ReminderTime
    private var hasBeenOffered: Bool

    init(isOn: Bool = false, time: ReminderTime = .morning, hasBeenOffered: Bool = false) {
        self.isOn = isOn
        self.time = time
        self.hasBeenOffered = hasBeenOffered
    }

    func loadIsOn() -> Bool { isOn }
    func save(isOn: Bool) { self.isOn = isOn }
    func loadTime() -> ReminderTime { time }
    func save(time: ReminderTime) { self.time = time }
    func loadHasBeenOffered() -> Bool { hasBeenOffered }
    func save(hasBeenOffered: Bool) { self.hasBeenOffered = hasBeenOffered }
}

/// The daily reminder: whether the game says anything when a new board goes up, at what
/// hour, and what it says.
///
/// Everything a daily puzzle is worth playing for — the run of days, the clock, the square
/// on the calendar that goes gold — depends on the player being there on the day, and a run
/// of days is broken by forgetting far more often than by a board somebody could not hold.
/// So the game is allowed to say so once a morning, and it is allowed to say it only because
/// the player said it could.
///
/// Nothing here is fetched and nothing here runs in the background. The almanac is already
/// in the player's pocket, so the game knows what every morning of the fortnight ahead is
/// going to be and simply lays one down for each of them; coming back to the title
/// screen lays the lot down again, which is how a day held before the hour comes round has
/// its reminder taken back off.
@MainActor
@Observable
final class DailyReminder {
    /// How far ahead the reminders are laid. Long enough that a player who does not open the
    /// game for a week is still reminded every morning of it, short enough to sit well
    /// inside the sixty-four pending notifications a phone will hold for one app.
    static let fortnight = 14

    /// What every reminder calls itself. The phone prints the app's name in small letters
    /// along the top of a notification either way, but the headline is the line somebody
    /// actually reads off a locked screen, and a morning that says whose it is is worth
    /// more than one that only says something is ready.
    static let name = "Pigpen"

    /// Whether the player has asked to be reminded. Their wish rather than the phone's
    /// permission — those come apart the moment somebody turns notifications off in the
    /// system settings, and the card behind the gear has to be able to say so.
    private(set) var isOn: Bool
    private(set) var time: ReminderTime
    /// Where the phone stands on letting this game post anything at all.
    private(set) var standing: ReminderStanding
    /// Whether the offer has been put up once already.
    private(set) var hasBeenOffered: Bool

    @ObservationIgnored private let store: any ReminderStore
    @ObservationIgnored private let scheduler: any ReminderScheduler

    /// - Parameter standing: Where the phone is to be taken as standing until it is asked
    ///   properly. Nothing on the device can be read without waiting, and a screen cannot
    ///   wait before it draws, so the honest opening answer is that nobody has asked yet —
    ///   `readTheStanding()` puts it right a moment later. Handed in by the previews, which
    ///   want a card that is already refusing or already reminding.
    init(
        store: any ReminderStore = StoredReminderSettings(),
        scheduler: any ReminderScheduler = SystemReminderScheduler(),
        standing: ReminderStanding = .notAsked
    ) {
        self.store = store
        self.scheduler = scheduler
        self.isOn = store.loadIsOn()
        self.time = store.loadTime()
        self.hasBeenOffered = store.loadHasBeenOffered()
        self.standing = standing
    }

    // MARK: - Where things stand

    /// Whether the game should put its own offer up: the player has never been asked, and
    /// the phone has never been asked either. A player who has said no once — to either of
    /// them — is left alone, and finds the switch behind the gear when they want it.
    var isDueAnOffer: Bool {
        !hasBeenOffered && standing == .notAsked
    }

    /// Whether the player wants reminding and the phone is refusing to pass it on. The one
    /// state the settings card has to explain rather than simply show, since nothing this
    /// game can do will fix it.
    var isBeingRefused: Bool {
        isOn && standing == .refused
    }

    /// Asks the phone where it stands. Worth doing every time the title screen comes back:
    /// permission is granted and taken away in the system settings, well out of sight of
    /// anything here.
    func readTheStanding() async {
        standing = await scheduler.standing()
    }

    // MARK: - Turning it on and off

    /// The player has said yes. Raises the phone's own prompt if it has never been raised,
    /// and lays the fortnight down if it is allowed to.
    ///
    /// A refusal leaves the switch off rather than on-and-silent: a game that says it will
    /// remind and then cannot is worse than one that admits the phone has the last word.
    @discardableResult
    func turnOn(today: DailyDate = .today(), progress: DailyProgress) async -> Bool {
        standing = await scheduler.standing()
        if standing == .notAsked {
            let granted = await scheduler.ask()
            standing = granted ? .allowed : .refused
            markOffered()
        }

        guard standing == .allowed else {
            set(isOn: false)
            return false
        }

        set(isOn: true)
        await replan(today: today, progress: progress)
        return true
    }

    /// The player has said no, or has changed their mind later. Every reminder this game has
    /// standing is taken back.
    func turnOff() async {
        set(isOn: false)
        await scheduler.clear()
    }

    /// A new hour. The fortnight is laid down again at once rather than at the next
    /// opportunity, so a player who moves the reminder to the evening does not get one
    /// more in the morning first.
    func change(to newTime: ReminderTime, today: DailyDate = .today(), progress: DailyProgress) async {
        guard newTime != time else { return }
        time = newTime
        store.save(time: newTime)
        await replan(today: today, progress: progress)
    }

    /// Notes that the offer has been put up, so it is never put up twice. Called whether
    /// the player took it or waved it away — this records the asking, not the answer.
    func markOffered() {
        guard !hasBeenOffered else { return }
        hasBeenOffered = true
        store.save(hasBeenOffered: true)
    }

    // MARK: - Laying the reminders down

    /// Works out every reminder due over the fortnight ahead and hands the lot to the phone,
    /// replacing whatever was standing before.
    ///
    /// Called on every return to the title screen, and after any day is held, because what
    /// is worth reminding about changes underneath: a day finished at ten past eight should
    /// not be reminded about at nine.
    func replan(
        today: DailyDate = .today(),
        progress: DailyProgress,
        now: Date = Date()
    ) async {
        guard isOn, standing == .allowed else {
            await scheduler.clear()
            return
        }

        await scheduler.replace(
            with: Self.reminders(
                from: today,
                now: ReminderTime(of: now),
                at: time,
                streak: progress.streak(upTo: today),
                isComplete: { progress.isComplete($0) }
            )
        )
    }

    private func set(isOn newValue: Bool) {
        isOn = newValue
        store.save(isOn: newValue)
    }

    // MARK: - What gets said

    /// The reminders due over a run of days: one for every morning the almanac has a board
    /// for and the player has not already held.
    ///
    /// - Parameters:
    ///   - now: What o'clock it is, so an hour already gone today is not asked of the phone
    ///     — one scheduled for a moment in the past is one that never arrives.
    ///   - streak: The run of days as it stands. It is written onto the first reminder alone,
    ///     and only when that reminder is today's or tomorrow's, because that is as far ahead
    ///     as the number can be promised: the run either survives to the next board or it
    ///     does not, and a reminder four days out cannot know which.
    static func reminders(
        from today: DailyDate,
        now: ReminderTime,
        at time: ReminderTime,
        over days: Int = DailyReminder.fortnight,
        streak: Int = 0,
        holdsAPuzzle: (DailyDate) -> Bool = DailyAlmanac.holdsAPuzzle(on:),
        isComplete: (DailyDate) -> Bool
    ) -> [ScheduledReminder] {
        var due: [ScheduledReminder] = []
        var day = today

        for step in 0..<max(0, days) {
            defer { day = day.dayAfter }
            // Today's hour, once it has gone, has gone.
            if step == 0, time <= now { continue }
            guard holdsAPuzzle(day), !isComplete(day) else { continue }

            // As far ahead as the run of days can be promised: the reminder the player is
            // going to see next, and only while it is today's board or tomorrow's.
            let promised = due.isEmpty && step <= 1 ? streak : 0
            let said = line(on: day, streak: promised)
            due.append(
                ScheduledReminder(
                    date: day,
                    time: time,
                    title: name,
                    subtitle: said.title,
                    body: said.body
                )
            )
        }

        return due
    }

    /// What a reminder says under its name: the first half of its morning's line, which is
    /// the half somebody reads at a glance.
    static func subtitle(for date: DailyDate, streak: Int = 0) -> String {
        line(on: date, streak: streak).title
    }

    /// What a reminder says under that: the rest of its morning's line, which is empty for
    /// the lines that are one sentence long and say all they have to say in the first half.
    static func body(for date: DailyDate, streak: Int = 0) -> String {
        line(on: date, streak: streak).body
    }

    /// What a morning says: a line out of the streak pool when there is a run to keep, and
    /// one out of the generic pool when there is not.
    ///
    /// A run of one is not a run — it is the single day the player has just had — so it is
    /// left unmentioned and the morning speaks generically. Everything above that has a
    /// number worth putting in front of somebody.
    ///
    /// Which line of the pool is picked by the day rather than in the moment, because the
    /// fortnight is laid down again on every return to the title screen: a true roll of the
    /// dice would rewrite every pending reminder each time, and a screenshot run would never
    /// photograph the same morning twice. Seeded off the date instead, so any one morning
    /// always says the same thing and the mornings around it say something else — random on
    /// any day, settled for that day.
    static func line(on date: DailyDate, streak: Int = 0) -> (title: String, body: String) {
        guard streak > 1 else {
            return genericLines[pick(on: date, outOf: genericLines.count)]
        }
        return streakLine(streak, at: pick(on: date, outOf: streakLineCount))
    }

    /// The date scrambled down to an index: a stamp of the calendar day pushed through
    /// SplitMix64's finalizer, so consecutive mornings land all over the pool rather than
    /// walking through it in order — and the same morning lands on the same line on every
    /// launch, which `hashValue` (salted per process) could not promise.
    static func pick(on date: DailyDate, outOf count: Int) -> Int {
        var mixed = UInt64(date.year * 10_000 + date.month * 100 + date.day)
        mixed = (mixed ^ (mixed >> 30)) &* 0xbf58_476d_1ce4_e5b9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94d0_49bb_1331_11eb
        mixed ^= mixed >> 31
        return Int(mixed % UInt64(max(1, count)))
    }

    /// The ten things a morning says when there is no run to keep: today's puzzle is up,
    /// and Pig needs a pen built.
    ///
    /// Each is one line of copy split at its first full stop. The game's name is the
    /// headline, so these sit underneath it: the phone sets the first half in bold over the
    /// rest in plain, and a notification is read at a glance, so the hook goes on top and
    /// the rest underneath that. A line that is one sentence long is all hook and no body,
    /// which is a notification the phone draws perfectly well.
    static let genericLines: [(title: String, body: String)] = [
        ("Today's puzzle is ready", "Help Pig build his pen."),
        ("A new puzzle is waiting for you", ""),
        ("Today's pen won't build itself", ""),
        ("Pig needs your help", "Today's puzzle is ready."),
        ("Your daily puzzle is here", "See how big you can build."),
        ("New day, new puzzle", "Let's build."),
        ("Think you can beat today's puzzle?", ""),
        ("Today's challenge is ready when you are", ""),
        ("Pig has a fresh puzzle for you", ""),
        ("Got a minute?", "Today's puzzle is waiting.")
    ]

    /// How many things a morning has to say to somebody with a run going. A count rather
    /// than an array, because half of these are written round the number and so cannot be
    /// stood up until there is one.
    static let streakLineCount = 10

    /// The ten things a morning says when there is a run to keep, written round the run as
    /// it stands.
    ///
    /// - Parameters:
    ///   - streak: Days in a row so far, counting back from the last board held. Today's is
    ///     still to be played, which is why these ask for it rather than congratulate it.
    ///   - index: Which of the ten, picked off the date by `line(on:streak:)`.
    static func streakLine(_ streak: Int, at index: Int) -> (title: String, body: String) {
        switch index % streakLineCount {
        case 0: ("Don't lose your \(streak)-day streak", "Today's puzzle is ready.")
        case 1: ("Your \(streak)-day streak is on the line", "")
        case 2: ("Keep your \(streak)-day streak going", "Play today's puzzle.")
        case 3: ("One puzzle keeps your \(streak)-day streak alive", "")
        case 4: ("You've played \(streak) days in a row", "Make it \(streak + 1).")
        case 5: ("Your streak needs you", "Today's puzzle is waiting.")
        case 6: ("So close to another streak day", "Don't stop now.")
        case 7: ("\(streak) days and counting", "Keep it going.")
        case 8: ("Pig remembers your streak", "Do you?")
        default: ("Your streak won't save itself", "Play today's puzzle.")
        }
    }
}

extension DailyReminder {
    /// A reminder that has never been mentioned to anybody: the state a game is in the day
    /// it is installed, and the one state the offer sheet is allowed to appear in.
    static func neverAsked() -> DailyReminder {
        DailyReminder(store: RememberedReminderSettings(), scheduler: RememberedReminders())
    }

    /// Switched on and reminding, for the settings card in a preview or a screenshot run —
    /// held in memory, so nothing is left standing on the machine that photographed it.
    static func reminding(at time: ReminderTime = .morning) -> DailyReminder {
        DailyReminder(
            store: RememberedReminderSettings(isOn: true, time: time, hasBeenOffered: true),
            scheduler: RememberedReminders(standing: .allowed),
            standing: .allowed
        )
    }

    /// Wanted by the player and refused by the phone, which is the one state the settings
    /// card has to apologise for and so the one worth being able to photograph.
    static func refused() -> DailyReminder {
        DailyReminder(
            store: RememberedReminderSettings(isOn: true, hasBeenOffered: true),
            scheduler: RememberedReminders(standing: .refused),
            standing: .refused
        )
    }
}

/// Where the phone stands on letting this game post a reminder.
///
/// Three states rather than a flag, because the middle one is the whole of why there is an
/// offer sheet at all: a game gets one chance at the system prompt, and spending it on
/// somebody who has not yet played a daily puzzle spends it for nothing.
enum ReminderStanding: Equatable, Sendable {
    /// The phone has never been asked. The one state in which asking is still possible.
    case notAsked
    /// Reminders will be passed on.
    case allowed
    /// The player has turned this game's notifications off, here or in the system settings.
    /// Nothing in the game can undo it; only the system settings can.
    case refused
}
