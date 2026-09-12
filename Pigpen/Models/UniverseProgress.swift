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
    /// Whether the full game has been bought. The map reads it to tell a world shut for want
    /// of stars from one shut for want of the purchase: the meadow is free, the world the
    /// trail has reached is walked a level a day, and everything past that stands behind the
    /// wall until this opens.
    let fullGame: FullGame
    /// Every best star rating in every world, by level id. Held here so the map redraws the
    /// instant it changes and re-read from the store each time the map comes back.
    private(set) var stars: [String: Int]

    init(
        universe: Universe = .all,
        store: any ProgressStore = StoredProgress(),
        fullGame: FullGame = .shared
    ) {
        self.universe = universe
        self.store = store
        self.fullGame = fullGame
        self.stars = store.loadStars()
    }

    var count: Int { universe.count }

    func world(at index: Int) -> UniverseWorld { universe[index] }

    func state(of index: Int) -> WorldState { universe.state(of: index, stars: stars) }

    func isUnlocked(_ index: Int) -> Bool { universe.isUnlocked(index, stars: stars) }

    func isCleared(_ index: Int) -> Bool { universe.isCleared(index, stars: stars) }

    /// Whether a world is shown for sale rather than played: a world past the free meadow that
    /// the trail has not yet reached, while the full game is not yet bought. Every one of those,
    /// not only the next — so the universe ahead is a shop window before a player pays, each
    /// world in colour and each tap on one an offer, rather than silhouettes.
    ///
    /// The world the chain has reached is not for sale, because it is not shut: a player who
    /// has not paid walks it a level a day — see `LevelRation` — and the wall they meet is on
    /// its trail, not on the map. The meadow is never for sale at all.
    ///
    /// It is kept apart from `WorldState`, which stays a reading of stars alone: a world can be
    /// `.locked` by progress and for sale at the same time, and the map draws the second over
    /// the first. Once the full game is bought, this is false everywhere and the map is nothing
    /// but the star chain again — the worlds ahead going back to silhouettes the player earns
    /// their way to.
    func isForSale(_ index: Int) -> Bool {
        guard !fullGame.isUnlocked, universe.worlds.indices.contains(index) else { return false }
        guard !(universe.game(at: index)?.isFree ?? false) else { return false }
        return !universe.isUnlocked(index, stars: stars)
    }

    /// Whether entering a world means being shown the offer rather than dropping into its
    /// trail. The map asks this on a tap: a world for sale opens the wall, everything else
    /// opens the world.
    func isBehindTheWall(_ index: Int) -> Bool { isForSale(index) }

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
    ///
    /// The full game is bought by default, so the map shows its worlds as the star chain the
    /// screenshots have always shown rather than as a run of price tags. `forSale` stands the
    /// same progress up unbought, so the wall — the thicket open on its ration, the rest for
    /// sale — can be drawn and photographed too.
    static func partWayThrough(
        universe: Universe = .all,
        forSale: Bool = false
    ) -> UniverseProgress {
        var stars: [String: Int] = [:]
        for node in universe.game(at: 0)?.map.nodes ?? [] {
            stars[node.id] = 3
        }
        return UniverseProgress(
            universe: universe,
            store: RememberedProgress(stars: stars),
            fullGame: forSale ? .locked() : .unlocked()
        )
    }
}
