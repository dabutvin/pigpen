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

    var id: String { level.id }
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
    /// The world the game ships with: eight puzzles up a winding trail, starting at the
    /// bottom of the meadow and climbing towards the hills. The first six are fencing and
    /// water alone; the last two put apples and skulls on the ground as well.
    static let mudlarkMeadow = WorldMap(
        name: "Mudlark Meadow",
        nodes: [
            WorldNode(level: .riverBend, across: 0.20, up: 0.00),
            WorldNode(level: .puddleCorner, across: 0.76, up: 1.00),
            WorldNode(level: .horseshoeLake, across: 0.26, up: 2.06),
            WorldNode(level: .theNarrows, across: 0.78, up: 3.02),
            WorldNode(level: .otterFord, across: 0.22, up: 4.08),
            WorldNode(level: .bigMeadow, across: 0.62, up: 5.02),
            WorldNode(level: .windfallOrchard, across: 0.24, up: 6.06),
            WorldNode(level: .sourGround, across: 0.74, up: 7.00)
        ]
    )
}
