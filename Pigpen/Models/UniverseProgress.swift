import Observation

/// How far a player has got across the whole universe: which worlds are cleared, which are open,
/// and which are still silhouettes waiting past the frontier.
///
/// It reads the same star store every world writes to — level ids are unique across worlds, so
/// one store holds all of them — and works out the state of each world from those stars. Opening
/// a world hands its own `WorldProgress` out of the same store, so a star won up a trail shows on
/// the map the moment the player comes back to it.
@MainActor
@Observable
final class UniverseProgress {
    let universe: Universe
    @ObservationIgnored private let store: any ProgressStore
    /// Every best star rating in every world, by level id. Held here so the map redraws the
    /// instant it changes and re-read from the store each time the map comes back.
    private(set) var stars: [String: Int]

    init(universe: Universe = .all, store: any ProgressStore = StoredProgress()) {
        self.universe = universe
        self.store = store
        self.stars = store.loadStars()
    }

    var count: Int { universe.count }

    func world(at index: Int) -> UniverseWorld { universe[index] }

    func state(of index: Int) -> WorldState { universe.state(of: index, stars: stars) }

    func isUnlocked(_ index: Int) -> Bool { universe.isUnlocked(index, stars: stars) }

    func isCleared(_ index: Int) -> Bool { universe.isCleared(index, stars: stars) }

    /// The furthest world open to the player, which is where the map settles when it opens.
    var frontier: Int { universe.frontier(stars: stars) }

    /// A world's own progress, sharing this store, or nothing for a silhouette. Handed to the
    /// world map when a world is entered.
    func progress(for index: Int) -> WorldProgress? {
        guard let game = universe.game(at: index) else { return nil }
        return WorldProgress(world: game.map, store: store)
    }

    /// Remembers a world's film has played, so its opening or send-off is not shown twice —
    /// tracked in the same store the worlds use.
    func markPlayed(sceneKey key: String) {
        var scenes = store.loadPlayedScenes()
        guard !scenes.contains(key) else { return }
        scenes.insert(key)
        store.markScenePlayed(key)
    }

    func hasPlayed(sceneKey key: String) -> Bool {
        store.loadPlayedScenes().contains(key)
    }

    /// Whether Play on the title should open this map. The universe stays hidden until every
    /// pen in the meadow is held — until then Play walks straight into Mudlark Meadow.
    var isRevealed: Bool { isCleared(0) }

    /// Reads the store again, for the map coming back from a world with new stars won in it.
    func reload() { stars = store.loadStars() }
}

extension UniverseProgress {
    /// A universe with the first world held, so previews and screenshots show the map with the
    /// meadow cleared and its rainbow, the thicket open and beckoning, and the worlds past it
    /// still dark silhouettes waiting their turn.
    static func partWayThrough(universe: Universe = .all) -> UniverseProgress {
        var stars: [String: Int] = [:]
        for node in universe.game(at: 0)?.map.nodes ?? [] {
            stars[node.id] = 3
        }
        return UniverseProgress(universe: universe, store: RememberedProgress(stars: stars))
    }
}
