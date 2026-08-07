/// One stop on the world map: a puzzle, and where its signpost stands in the meadow.
///
/// Positions are held as fractions rather than points so the same world lays itself out
/// on any screen. `across` runs left to right; `up` counts stops from the start of the
/// trail, and a stop is free to stand a little short of or past its own number so the
/// trail does not climb like a staircase.
struct WorldNode: Identifiable, Sendable {
    let level: PuzzleLevel
    /// Where the signpost stands across the meadow: 0 at the left edge, 1 at the right.
    let across: Double
    /// How far up the trail the signpost stands, counted in stops from the first one.
    let up: Double
    /// Stars the world wants before this stop opens, on top of the trail having reached it.
    /// Nothing for an ordinary level; the meadow's boss asks for most of the stars the
    /// levels below it hold, so it is played by a player who has gone back and bettered
    /// their pens rather than one who has simply got this far.
    let starToll: Int

    var id: String { level.id }

    init(level: PuzzleLevel, across: Double, up: Double, starToll: Int = 0) {
        self.level = level
        self.across = across
        self.up = up
        self.starToll = starToll
    }
}

/// The levels of one world, in the order the pig walks them.
struct WorldMap: Sendable {
    let name: String
    let nodes: [WorldNode]

    var count: Int { nodes.count }

    subscript(index: Int) -> WorldNode { nodes[index] }

    /// How far up the trail the last stop stands, which is the length of the world.
    var reach: Double { nodes.map(\.up).max() ?? 0 }

    func index(of levelID: String) -> Int? {
        nodes.firstIndex { $0.id == levelID }
    }

    /// Every star the world has in it, for a player who takes all of them.
    var starTotal: Int { count * 3 }
}

extension WorldMap {
    /// The world the game ships with: nine puzzles up a winding trail, starting at the
    /// bottom of the meadow and climbing towards the hills. The first six are fencing and
    /// water alone, the next two put apples and skulls on the ground as well, and the
    /// last one stands a stag on it beside the pig and asks for 21 of the 24 stars below
    /// it before it will open at all.
    ///
    /// The first six are ordered by how much they ask of the player rather than by how big
    /// the board is or how long the budget. What a level asks is the gap between the pen it
    /// has in it and the pen a player gets by squaring the map off — a plain block of
    /// ground, no staircase and no detour — which `Tools/level_search.py --demand` measures
    /// and `DifficultyTests` pins. The trail opens on two maps whose best pen *is* the
    /// obvious pen, so the first three stars are free and the game gets to explain itself,
    /// and the gap then widens the whole way to Puddle Corner, which is eight pieces and
    /// nothing to lean on but the shape of the wall.
    ///
    /// The last three are ordered by what they put on the ground instead, since that is the
    /// harder thing about them: apples, then skulls to bury as well, then a second animal
    /// and one budget to split between the two.
    static let mudlarkMeadow = WorldMap(
        name: "Mudlark Meadow",
        nodes: [
            WorldNode(level: .riverBend, across: 0.20, up: 0.00),
            WorldNode(level: .horseshoeLake, across: 0.76, up: 1.00),
            WorldNode(level: .theNarrows, across: 0.26, up: 2.06),
            WorldNode(level: .bigMeadow, across: 0.78, up: 3.02),
            WorldNode(level: .otterFord, across: 0.22, up: 4.08),
            WorldNode(level: .puddleCorner, across: 0.62, up: 5.02),
            WorldNode(level: .windfallOrchard, across: 0.24, up: 6.06),
            WorldNode(level: .sourGround, across: 0.74, up: 7.00),
            WorldNode(level: .stagMere, across: 0.28, up: 8.06, starToll: 21)
        ]
    )
}
