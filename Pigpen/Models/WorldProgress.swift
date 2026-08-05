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
}

/// A world that forgets everything the moment it is put down.
final class RememberedProgress: ProgressStore {
    private var stars: [String: Int]

    init(stars: [String: Int] = [:]) {
        self.stars = stars
    }

    func loadStars() -> [String: Int] { stars }

    func save(_ stars: [String: Int]) { self.stars = stars }
}

/// How far a player has got through a world: the best rating earned on every level, and
/// therefore which levels are open.
///
/// A level opens as soon as the one before it has been penned at all, so the trail can
/// only ever be blocked by a puzzle you have not solved — never by one you solved badly.
/// Going back to an old level and doing worse than last time changes nothing: the map
/// keeps the best you have ever done.
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

    /// The stop the pig stands at when nothing else has moved it: the first level still
    /// to be cleared, or the last stop on the map once the whole world is done.
    var frontier: Int {
        for index in world.nodes.indices where !isCleared(index) {
            return index
        }
        return max(world.count - 1, 0)
    }

    /// Whether a level can be played. Everything up to and including the frontier is
    /// open, which is what lets a player walk back down the trail to a level they have
    /// already beaten.
    func isUnlocked(_ index: Int) -> Bool {
        index >= 0 && index <= frontier
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
