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
    let title: String
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
            due.append(
                ScheduledReminder(
                    date: day,
                    time: time,
                    title: title(for: day),
                    body: body(for: day, streak: promised)
                )
            )
        }

        return due
    }

    /// What a reminder calls itself: its morning's own line from the hundred, and never
    /// the game's name — the phone writes that over the top of it anyway.
    static func title(for date: DailyDate) -> String {
        line(on: date).title
    }

    /// What a reminder says under that: the rest of its morning's line, with the run of
    /// days glued onto the end when there is one to keep. The run rides in the body rather
    /// than the title, because a title and its body are written as a couplet — *Pig would
    /// like a word* / *The word is "bigger."* — and neither half stands alone.
    static func body(for date: DailyDate, streak: Int = 0) -> String {
        let said = line(on: date).body
        guard streak > 1 else { return said }
        return said + " \(streak) days in a row so far."
    }

    /// Which of the hundred lines a morning says.
    ///
    /// Picked by the day rather than in the moment, because the fortnight is laid down
    /// again on every return to the title screen: a true roll of the dice would rewrite
    /// every pending reminder each time, and a screenshot run would never photograph the
    /// same morning twice. Seeded off the date instead, so any one morning always says the
    /// same thing and the mornings around it say something else — random on any day,
    /// settled for that day.
    static func line(on date: DailyDate) -> (title: String, body: String) {
        lines[pick(on: date, outOf: lines.count)]
    }

    /// The date scrambled down to an index: a stamp of the calendar day pushed through
    /// SplitMix64's finalizer, so consecutive mornings land all over the hundred rather
    /// than walking through them in order — and the same morning lands on the same line on
    /// every launch, which `hashValue` (salted per process) could not promise.
    static func pick(on date: DailyDate, outOf count: Int) -> Int {
        var mixed = UInt64(date.year * 10_000 + date.month * 100 + date.day)
        mixed = (mixed ^ (mixed >> 30)) &* 0xbf58_476d_1ce4_e5b9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94d0_49bb_1331_11eb
        mixed ^= mixed >> 31
        return Int(mixed % UInt64(max(1, count)))
    }

    /// The hundred things a morning can say, each a couplet: the estate agent's patter the
    /// cut scenes talk in, carried on into the notification shade. One is picked per day in
    /// `line(on:)`; none of them gives a board away, and every body reads on from its title
    /// rather than standing alone — so the pair travels together, streak clause and all.
    static let lines: [(title: String, body: String)] = [
        ("Pig's waiting", "Come build him a yard he can brag about."),
        ("Today's listing is in", "Cozy lot. Limited fence. Pig has high hopes."),
        ("New lot, who dis?", "Pig found another place. Help him fence it in."),
        ("A fresh pen awaits", "Come see how much yard you can squeeze out of it."),
        ("It's giving acreage", "Come give Pig the spacious-yard lifestyle he deserves."),
        ("Pig needs a yard", "Preferably one with an unreasonable amount of square footage."),
        ("Open house", "Pig is already wandering around the property."),
        ("Fresh pasture", "Come turn today's little lot into prime pig real estate."),
        ("Today's property", "It has potential. Pig would like you to find it."),
        ("A little yard work?", "The kind that involves geometry instead of weeds."),
        ("Pig found a place", "Come see if you can improve the floor plan."),
        ("New listing", "One pig. One fence budget. Plenty of ambition."),
        ("Pig's ready to move in", "Small issue: there is currently no pen."),
        ("Today's lot is ready", "Come make it look expensive."),
        ("Room to roam", "Pig would like as much of it as you can manage."),
        ("Vibe check: spacious", "Open today's puzzle and see how much yard you can find."),
        ("A fresh little plot", "Pig has already mentally moved in."),
        ("Pig has plans", "They mostly involve making the yard bigger."),
        ("Today's floor plan", "Come give Pig something spacious and tastefully fenced."),
        ("Home sweet pen", "Today's version still needs some work."),
        ("Another showing", "Pig has never met a property he wouldn't tour."),
        ("Pig found some acreage", "\"Acreage\" may be generous. Come help."),
        ("Fresh property", "Come see what a few strategically placed fences can do."),
        ("Pig's house hunt", "Today's candidate is ready for your inspection."),
        ("A promising little lot", "Pig can already picture himself standing in it."),
        ("Today's pen is up to you", "No pressure. Pig is very easy to impress with square footage."),
        ("Big yard energy", "Come see how roomy you can make today's pen."),
        ("Pig wants more space", "A timeless request. See what you can do."),
        ("Fresh fence, fresh possibilities", "Come make Pig's tiny real-estate dreams come true."),
        ("Today's listing", "Great bones. Mostly because there are no walls yet."),
        ("A new place for Pig", "Come add the one feature it's missing: boundaries."),
        ("Fence time", "Pig has once again outsourced the entire floor plan to you."),
        ("Pig's got a new project", "By \"project,\" he means \"you build it.\""),
        ("A little geometry", "Come draw a shape Pig would be proud to live in."),
        ("Pig understood the assignment", "He showed up. You handle the geometry."),
        ("Fresh listing alert", "Pig is ready to see what you do with the place."),
        ("Pig has feedback", "Before you even start: more yard."),
        ("Today's puzzle is ready", "Come make Pig's fence budget look generous."),
        ("A blank lot awaits", "Pig sees a future here. Mostly a fenced one."),
        ("New day, new pen", "Help Pig achieve his pen dreams."),
        ("Pig found another contender", "Come see if this one earns a spot on the shortlist."),
        ("A cozy little challenge", "See how much yard you can make."),
        ("Today's viewing", "Pig is ready. The property is… unfinished."),
        ("More square footage, please", "Pig's daily request has arrived."),
        ("The client is here", "He is pink, round, and very interested in the yard."),
        ("Today's property tour", "Come help Pig find the best use of space."),
        ("Pig has arrived", "The fence contractor has not. That's you."),
        ("It's giving open concept", "Maybe a little too open. Come add some fence."),
        ("Pig's daily showing", "He likes the location. Now about that fence…"),
        ("Another day, another listing", "Pig is nothing if not thorough."),
        ("Fence budget approved", "It is exactly as small as yesterday's ambitions were large."),
        ("Pig would like an upgrade", "Come see what today's lot can become."),
        ("A fresh patch of real estate", "Pig has already claimed the best spot to stand."),
        ("Today's project", "Build a pen. Make it roomy. Impress one pig."),
        ("Pig is browsing again", "Come help him make today's listing work."),
        ("A little home improvement", "The home is mostly imaginary. The fence is up to you."),
        ("Today's lot has charm", "Pig thinks it could use more yard."),
        ("Pig's wish list", "Spacious. Cozy. Closed on all sides."),
        ("New property, same priorities", "Pig would like the biggest yard possible, please."),
        ("A fresh floor plan", "Come make every fence piece earn its keep."),
        ("Three-star potential", "Pig is ready to see what you've got."),
        ("Today's appraisal", "Build the pen first. Pig will handle the judging."),
        ("Pig brought his standards", "Fortunately, they're mostly about square footage."),
        ("A perfect pen?", "Come see if today's puzzle has one hiding in it."),
        ("Rainbow potential", "Build big enough and today's pen might show off a little."),
        ("Pig smells a three-star property", "Come see if he's right."),
        ("Today could be the one", "The one with an unnecessarily excellent pen."),
        ("Pig is optimistic", "Come justify his confidence."),
        ("A fresh puzzle awaits", "Find the roomy little solution hiding inside."),
        ("Today's lot is looking good", "Pig would like you to make it look even better."),
        ("Mind the gap", "Pig considers openings a strong suggestion to leave."),
        ("Close the fence", "Unless you'd like to watch Pig immediately wander off."),
        ("Pig's feeling adventurous", "A closed pen may help with that."),
        ("Tiny escape artist", "Come build Pig somewhere nice enough to stay."),
        ("Pig spotted an opening", "Better get to today's puzzle before he does."),
        ("Please contain your pig", "Spaciously, of course."),
        ("Pig is on the loose", "In a very calm, cozy sort of way."),
        ("Fence check", "Come make sure Pig's new place has all four-ish sides."),
        ("Plot twist: more plot", "Come find Pig a little extra land today."),
        ("A nice closed pen", "Pig asks for so little. Except square footage."),
        ("Your daily pig break", "Come spend a few minutes rearranging fences."),
        ("Pig o'clock", "Today's little puzzle is ready when you are."),
        ("A cozy puzzle is waiting", "Come make Pig somewhere nice to stand."),
        ("Daily Pigpen", "A fresh board, a small pig, and a few quiet minutes."),
        ("Take a little Pigpen break", "Today's lot is ready for you."),
        ("A new puzzle for today", "Come see what kind of pen takes shape."),
        ("Pig has cleared his calendar", "He's available for today's puzzle whenever you are."),
        ("A few minutes with Pig?", "There's a fresh pen waiting to be figured out."),
        ("Today's tiny project", "Give Pig a surprisingly large backyard."),
        ("A quiet little challenge", "Come make the most of today's fence."),
        ("Pig's got nowhere to be", "Take your time with today's puzzle."),
        ("A small favor for Pig", "Could you optimize his entire living situation?"),
        ("Pig would like a word", "The word is \"bigger.\""),
        ("Client feedback is in", "Pig says the yard could use more yard."),
        ("Pig's in his homeowner era", "Come help him make the most of today's lot."),
        ("Very important pig business", "Today's property isn't going to fence itself."),
        ("Pig did some house hunting", "Now you get to do the hard part."),
        ("Today in real estate", "Local pig seeks roomy pen. Fence budget firm."),
        ("Pig found \"the one\"", "Or at least today's one. Come take a look."),
        ("New Daily Puzzle", "Come give Pig the kind of yard he'll immediately take for granted.")
    ]
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
