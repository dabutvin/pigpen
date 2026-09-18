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
/// rainbow taken, a run of mornings kept — rather than a count of launches or an hour on a
/// clock. A game that asks somebody who is losing what they think of it gets the answer it
/// asked for.
///
/// The three of them are meant to catch three different players, and the bars are what keep
/// them from all catching the same one. Only one ask is ever spent — the first moment to
/// arrive takes it and the rest are shut out for four months — so a bar set where every
/// player passes it in their first sitting is a bar that answers for everybody.
enum RatingMoment: String, CaseIterable, Sendable {
    /// Every pen in a world held. The biggest thing a player does in this game, and the end of
    /// the free half of it.
    case worldHeld
    /// The best pen a map has in it, taken — with a few already behind it, since the first
    /// rainbow can come three minutes in on a map that gives one up easily.
    case bestPen
    /// A run of daily boards: somebody who has come back three mornings running has an opinion
    /// about the game and it is not an idle one.
    case runOfDays

    /// How much of the mark has to be in before a rise in it counts as a moment.
    ///
    /// The numbers are not guesses any more; they are what the counting said. Two in five pens
    /// held are the best pen their map has in it, so a bar of three rainbows was reached around
    /// the eighth board — inside the free meadow, often on the first day. And a bar of seven
    /// mornings never once fired in a year of asking: players reach a week and go far past it,
    /// but the other two always got there first and spent the ask. Three mornings arrives while
    /// the run is still the thing the player is thinking about, which is the whole point of
    /// asking on it.
    var bar: Int {
        switch self {
        case .worldHeld: 1
        case .bestPen: 5
        case .runOfDays: 3
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

extension RatingMoment: Identifiable {
    /// Its own word, so the moment can be what a sheet is raised on rather than a flag beside
    /// one — the title screen holds the moment for as long as the asking lasts, since what a
    /// chart wants to know about an answer is which high point it was given on.
    var id: String { rawValue }
}

/// What the game's own question got back.
///
/// Three answers rather than two, because the cross is not a no. Somebody who shuts the sheet
/// has said they did not want to be asked; somebody who presses *Not really* has said the game
/// is letting them down, which is a different thing and the one worth acting on.
enum RatingAnswer: String, CaseIterable, Sendable {
    /// Yes — and so on to Apple's prompt, which is the whole reason for asking.
    case enjoying
    /// No — and so on to the door that reaches a person, which is what they were asking for.
    case disappointed
    /// Neither, and the sheet gone: the cross, or a swipe down.
    case closed
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
/// The asking is in two steps. First the game asks in its own words, on its own boards, whether
/// the player is enjoying Pigpen — that is `RatingPromptView`. Only a player who says yes is
/// handed on to Apple's prompt; a player who says no is handed the door that reaches a person,
/// which is what somebody who is not enjoying the game was actually asking for.
///
/// The rating itself stays Apple's and only Apple's. *Guideline 5.6.1* says to use the provided
/// API, so nothing in the game draws a star, takes a review, or dresses the prompt up as
/// something of its own: the question in front of it decides only whether it is raised at all,
/// and raising it is `AppStore`'s own call made from `SystemReviews` and nowhere else.
///
/// That is the same shape the reminder has, for a related reason. The phone shows the prompt
/// three times a year at the very outside, says nothing either way, and cannot be asked again
/// once it has decided — so an allowance spent on somebody who was about to complain is spent
/// twice over: the rating that does not come, and the complaint that goes nowhere.
///
/// What is left to the game, then, is *when* to ask, and it is decided here:
///
/// - **On a high point.** A world held, a handful of rainbows taken, a run of daily boards —
///   `RatingMoment` has the three of them, what each one has to reach, and why those numbers
///   and not others.
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
/// This is not observable, even though a sheet now draws the first step: nothing here moves
/// while that sheet is up. The title screen asks a question on the way through, gets back the
/// moment worth asking on, and hands the answer back down.
///
/// And nothing here is game data — clearing every star leaves it standing, the same way
/// clearing them leaves the reminder's hour and the counting switch alone. A player who has
/// been asked has been asked.
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

    /// Looks at where a player stands, writes it down, and answers with the moment worth asking
    /// on if this is one — and with nothing at all when it is not, which is nearly always.
    ///
    /// Putting the question up is the caller's to do, since the caller is the screen that knows
    /// what else is on it. What is settled by the time this answers is that the asking is
    /// allowed and has now been spent: see `markAsked(now:)` for why it is spent here rather
    /// than when an answer comes back.
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

        markAsked(now: now)
        return moment
    }

    /// Writes the asking down, when the question goes up rather than when an answer comes back.
    ///
    /// Marked whichever way it is answered, the way the reminder's offer is. A player who says
    /// they are not enjoying the game has been asked and has said their piece; coming back at
    /// them on the next world they hold is asking somebody to change their mind about a game
    /// they have already told the truth about.
    ///
    /// And marked before anything is raised rather than after, for the step that follows a yes.
    /// The phone may well show nothing — the allowance is spent, or Apple simply decides not to
    /// — and there is no way to find out which. A game that waited to hear back before writing
    /// anything down would ask again on the next high point, and again on the one after that,
    /// on the strength of never having seen a thing.
    private func markAsked(now: Date) {
        askedOnVersion = version
        askedOn = now
        store.save(askedOnVersion: version, on: now)
    }

    // MARK: - The second step

    /// Apple's own prompt, for a player who has just said they are enjoying it — and the only
    /// place in the whole game it is ever raised.
    ///
    /// Nothing is written down here. The asking was written down when the question went up,
    /// which is what holds the two steps to one ask however the player answers, and whether
    /// anything appears at all is Apple's to decide and nothing here can find out.
    func askForAReview() {
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
