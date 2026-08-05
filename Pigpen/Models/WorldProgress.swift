import Foundation
import Observation

/// Where a player's best star rating for each level is kept.
///
/// A protocol rather than `UserDefaults` outright, so the tests, the previews and the
/// screenshot runs can hand the map a world part-way through without touching what is
/// on the device.
protocol ProgressStore {
    func loadStars() -> [String: Int]
    func save(_ stars: [String: Int])
    /// Throws the lot away, for the player who wants the game back as they found it.
    func erase()
}

/// The real thing: stars survive the app being closed.
struct StoredProgress: ProgressStore {
    private static let key = "pigpen.best-stars"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStars() -> [String: Int] {
        defaults.dictionary(forKey: Self.key) as? [String: Int] ?? [:]
    }

    func save(_ stars: [String: Int]) {
        defaults.set(stars, forKey: Self.key)
    }

    func erase() {
        defaults.removeObject(forKey: Self.key)
    }
}

/// A world that forgets everything the moment it is put down.
final class RememberedProgress: ProgressStore {
    private var stars: [String: Int]

    init(stars: [String: Int] = [:]) {
        self.stars = stars
    }

    func loadStars() -> [String: Int] { stars }

    func save(_ stars: [String: Int]) { self.stars = stars }

    func erase() { stars = [:] }
}

/// How far a player has got through a world: the best rating earned on every level, and
/// therefore which levels are open.
///
/// A level opens as soon as the one before it has been penned at all, so the trail can
/// only ever be blocked by a puzzle you have not solved — never by one you solved badly.
/// Going back to an old level and doing worse than last time changes nothing: the map
/// keeps the best you have ever done.
///
/// The one exception is a stop with a star toll on it. The meadow's boss wants most of the
/// stars the trail below it holds, so beating the level before it is not enough — the
/// player has to go back and better their pens, and the stars they win doing it open it
/// wherever on the trail they happen to be standing.
@MainActor
@Observable
final class WorldProgress {
    let world: WorldMap
    private(set) var bestStars: [String: Int]
    @ObservationIgnored private let store: any ProgressStore

    init(world: WorldMap = .mudlarkMeadow, store: any ProgressStore = StoredProgress()) {
        self.world = world
        self.store = store
        self.bestStars = store.loadStars()
    }

    /// The best rating earned on a level, or 0 for one nobody has held a pig in yet.
    func stars(for levelID: String) -> Int {
        bestStars[levelID] ?? 0
    }

    func stars(at index: Int) -> Int {
        world.nodes.indices.contains(index) ? stars(for: world[index].id) : 0
    }

    func isCleared(_ index: Int) -> Bool { stars(at: index) > 0 }

    /// How far along the trail play has got: the first level still to be cleared, or the
    /// last stop on the map once the whole world is done. A stop with a star toll on it
    /// can still be shut inside that.
    private var reached: Int {
        for index in world.nodes.indices where !isCleared(index) {
            return index
        }
        return max(world.count - 1, 0)
    }

    /// The stop the pig stands at when nothing else has moved it: the furthest one open
    /// to it. A boss whose toll has not been paid is not a stop to stand at, so the pig
    /// waits below it until the stars for it are in.
    var frontier: Int {
        var stop = reached
        while stop > 0, !isTollPaid(stop) {
            stop -= 1
        }
        return stop
    }

    /// Whether a level can be played: the trail has to have reached it and any stars it
    /// asks for have to be won already. Everything behind the frontier stays open, which
    /// is what lets a player walk back down the trail to a level they have already beaten
    /// — and what lets them go back for the stars a boss is waiting on.
    func isUnlocked(_ index: Int) -> Bool {
        index >= 0 && index <= reached && isTollPaid(index)
    }

    /// Whether the world holds the stars a stop asks for. Every level but the boss asks
    /// for none, so this is true of all of them.
    func isTollPaid(_ index: Int) -> Bool {
        guard world.nodes.indices.contains(index) else { return false }
        return totalStars >= world[index].starToll
    }

    /// How many more stars a stop wants before it will open, and 0 for one that is only
    /// waiting on the trail.
    func starsOwed(_ index: Int) -> Int {
        guard world.nodes.indices.contains(index) else { return 0 }
        return max(world[index].starToll - totalStars, 0)
    }

    var clearedCount: Int {
        world.nodes.indices.filter { isCleared($0) }.count
    }

    var totalStars: Int {
        world.nodes.reduce(0) { $0 + stars(for: $1.id) }
    }

    /// Records how a level went, keeping the best rating it has ever been given.
    ///
    /// Returns whether this opened the next level up — the pig's cue to walk on.
    @discardableResult
    func record(stars rating: Int, for levelID: String) -> Bool {
        guard rating > 0, world.index(of: levelID) != nil else { return false }

        let before = frontier
        if rating > stars(for: levelID) {
            bestStars[levelID] = rating
            store.save(bestStars)
        }
        return frontier > before
    }

    /// Reads the store again, for a screen that has been sitting behind another one while
    /// the stars were being won. The title screen does this every time it comes back.
    func reload() {
        bestStars = store.loadStars()
    }

    /// Forgets every star ever earned, on the device as well as on the screen, which shuts
    /// the world back to its first level. There is no undoing it, so nothing calls this
    /// without asking first.
    func eraseEverything() {
        bestStars = [:]
        store.erase()
    }
}

extension WorldProgress {
    /// A world a couple of levels in, so previews and the screenshots CI takes show a
    /// trail with stars on it, a level waiting to be played, and some still shut.
    static func partWayThrough(world: WorldMap = .mudlarkMeadow) -> WorldProgress {
        var seeded: [String: Int] = [:]
        for (index, rating) in [3, 2].enumerated() where index < world.count {
            seeded[world[index].id] = rating
        }
        return WorldProgress(world: world, store: RememberedProgress(stars: seeded))
    }
}
