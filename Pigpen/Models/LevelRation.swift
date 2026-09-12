import Foundation
import Observation

/// How long there is to wait for the next free level, in the two characters a signpost has
/// room for and the words a sentence reads.
///
/// Never less than a minute: a wait is only ever spoken of while there is one. Hours are
/// rounded to the nearest once the wait is an hour or more — a sign reading `14h` at
/// thirteen and a half hours misleads nobody, and one reading `13h 31m` is a clock, not a
/// signpost.
struct LevelWait: Equatable, Sendable {
    /// Whole minutes still to wait, rounded up.
    let minutes: Int

    init(minutes: Int) {
        self.minutes = max(minutes, 1)
    }

    init(until due: Date, now: Date = .now) {
        let seconds = max(due.timeIntervalSince(now), 0)
        self.init(minutes: Int((seconds / 60).rounded(.up)))
    }

    /// The wait in hours once it is an hour or more, to the nearest, and nothing under an hour.
    var hours: Int? {
        guard minutes >= 60 else { return nil }
        return max((minutes + 30) / 60, 1)
    }

    /// The wait as the signpost writes it: `14h`, `40m`.
    var short: String {
        if let hours { return "\(hours)h" }
        return "\(minutes)m"
    }

    /// The wait as a sentence says it: `14 hours`, `1 hour`, `40 minutes`, `a minute`.
    var spoken: String {
        if let hours { return "\(hours) hour\(hours == 1 ? "" : "s")" }
        return minutes == 1 ? "a minute" : "\(minutes) minutes"
    }
}

/// Where the ration's standing is kept on the device: which levels it has handed out, and
/// when it last handed one out.
///
/// A protocol rather than `UserDefaults` outright, for the reason every store in the game is
/// one: the tests and the previews can stand a trail up the morning after a free level, or
/// with the next one due, without a day passing on the machine they run on.
protocol RationStore {
    func loadReleased() -> Set<String>
    func loadLastRelease() -> Date?
    func save(released: Set<String>, lastRelease: Date)
}

/// The real thing: a level handed out survives the app being closed, and so does the clock
/// that started when it was.
struct StoredRation: RationStore {
    private static let releasedKey = "pigpen.ration.released"
    private static let lastReleaseKey = "pigpen.ration.last-release"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadReleased() -> Set<String> {
        Set(defaults.stringArray(forKey: Self.releasedKey) ?? [])
    }

    func loadLastRelease() -> Date? {
        defaults.object(forKey: Self.lastReleaseKey) as? Date
    }

    func save(released: Set<String>, lastRelease: Date) {
        defaults.set(Array(released).sorted(), forKey: Self.releasedKey)
        defaults.set(lastRelease, forKey: Self.lastReleaseKey)
    }
}

/// A ration that forgets the moment it is put down, for previews and tests.
final class RememberedRation: RationStore {
    private var released: Set<String>
    private var lastRelease: Date?

    init(released: Set<String> = [], lastRelease: Date? = nil) {
        self.released = released
        self.lastRelease = lastRelease
    }

    func loadReleased() -> Set<String> { released }
    func loadLastRelease() -> Date? { lastRelease }

    func save(released: Set<String>, lastRelease: Date) {
        self.released = released
        self.lastRelease = lastRelease
    }
}

/// The free game's ration of levels past the meadow: one every twenty-four hours.
///
/// Pigpen ships as the meadow and the day, and used to stop there — every world past the
/// meadow stood behind the one purchase. Now the free game walks the same chain a bought one
/// does, only slower: a player who has not paid may open one new level past the meadow, and
/// then the next is theirs a day later. The purchase is what it always was, the whole map at
/// once; this is what the map is worth without it.
///
/// It is a clock and a list. The list is every level the ration has handed out, by id, so a
/// level opened is a level the player keeps — they can walk back down to it and take it apart
/// as often as they like without spending anything. The clock starts when a level is handed
/// out and runs a day; while it runs nothing new is handed out, and the moment it stops the
/// next level on the trail is theirs for the asking. Nothing banks up: a player away for a
/// week comes back to one free level, not seven, because *one every twenty-four hours* is
/// the whole rule.
///
/// The ration decides nothing about which level. The trail does that already — a stop opens
/// once the one below it is penned and any toll on it is paid — and the ration only asks,
/// of a stop the trail has opened, whether the free game has handed it over yet. A level
/// already cleared is never asked about at all: it has been played, and playing it again
/// costs nothing, whatever the list says.
///
/// Held apart from `FullGame`, which is the purchase and only the purchase. The map asks
/// that switch first and this one second, and a bought game never reaches the second.
@MainActor
@Observable
final class LevelRation {
    /// The one the whole game asks through, so the clock reads the same on every trail.
    static let shared = LevelRation()

    /// How long the clock runs after a level is handed out.
    static let interval: TimeInterval = 24 * 60 * 60

    /// What the ration has to say about a level the trail has opened.
    enum Standing: Equatable {
        /// Already handed out, or already cleared: the player's to play.
        case free
        /// Not handed out yet, and the clock has stopped: the next tap hands it over.
        case ready
        /// Not handed out yet, and the clock still running — until the moment given.
        case waiting(until: Date)
    }

    /// Every level the ration has handed out, by id.
    private(set) var released: Set<String>
    /// When the last one was handed out, or nothing for a ration that has handed out nothing.
    private(set) var lastRelease: Date?
    @ObservationIgnored private let store: any RationStore

    init(store: any RationStore = StoredRation()) {
        self.store = store
        self.released = store.loadReleased()
        self.lastRelease = store.loadLastRelease()
    }

    /// Where the ration stands on a level, read against a given moment.
    ///
    /// - Parameter isCleared: Whether the level has been penned already. A cleared level is
    ///   free whatever the list says, so a level played before this ration existed — or one
    ///   played under a purchase the store has since taken back — stays the player's.
    func standing(of levelID: String, isCleared: Bool, now: Date = .now) -> Standing {
        if isCleared || released.contains(levelID) { return .free }
        if let due = nextRelease(now: now) { return .waiting(until: due) }
        return .ready
    }

    /// When the clock stops and the next level is due, or nothing when it is due already.
    ///
    /// A phone whose clock has been wound back would otherwise be told to wait for longer
    /// than a day, so the answer is never further off than one: the worst a wrong clock does
    /// is start the day over.
    func nextRelease(now: Date = .now) -> Date? {
        guard let lastRelease else { return nil }
        let due = min(lastRelease.addingTimeInterval(Self.interval), now.addingTimeInterval(Self.interval))
        return due > now ? due : nil
    }

    /// Whether the clock has stopped, so the next level on the trail is there for the asking.
    func isReady(now: Date = .now) -> Bool {
        nextRelease(now: now) == nil
    }

    /// Hands a level over and starts the clock. Refused, with nothing written, while the
    /// clock is still running — the trail should never have asked — and a level already
    /// handed out is left as it was, so asking twice costs no second day.
    ///
    /// Returns whether a level was handed over just now.
    @discardableResult
    func release(_ levelID: String, now: Date = .now) -> Bool {
        guard !released.contains(levelID), isReady(now: now) else { return false }
        released.insert(levelID)
        lastRelease = now
        store.save(released: released, lastRelease: now)
        return true
    }
}

extension LevelRation {
    /// A ration that has handed out nothing yet, held in memory: the free game on the morning
    /// it first reaches the thicket, with the first level there for the asking.
    static func fresh() -> LevelRation {
        LevelRation(store: RememberedRation())
    }

    /// A ration part-way up a world, held in memory: the first few stops of the trail handed
    /// out, the last of them some hours ago, and the clock still running on the next. The
    /// standing a preview or a screenshot of the wait wants — a trail with a lock on it and a
    /// countdown over the lock.
    static func partWayThrough(
        world: WorldMap,
        released count: Int = 2,
        hoursAgo: Double = 10
    ) -> LevelRation {
        LevelRation(
            store: RememberedRation(
                released: Set(world.nodes.prefix(count).map(\.id)),
                lastRelease: Date().addingTimeInterval(-hoursAgo * 60 * 60)
            )
        )
    }
}
