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

/// Somewhere off the side of a trail that is not a puzzle: a door the trail passes.
///
/// A stop is the way on — beat it and the next one opens — which is why the trail is a line and
/// why the nine of them are ordered by what they ask. A door is none of that. It stands beside
/// a stop, it leads nowhere, nothing behind it is waiting on it, and a player who never turns
/// aside finishes the world without opening it.
///
/// It is not a level either. It has no board, no budget, no stars and no rainbow: it opens when
/// the stop it stands beside has been penned, and tapping it takes you straight through. A world
/// counts itself in the nine pens of its trail, and a door changes none of that arithmetic —
/// not the tally across the top of the map, not what a boss's toll costs, not what *the world
/// held* means.
///
/// There is one in the game: the dressing barn beside the meadow's orchard.
struct WorldSpur: Identifiable, Hashable, Sendable {
    /// What the sign says, which is the whole of what is behind it.
    let name: String
    /// The stop it stands beside, as an index into the trail's own stops. Penning that stop is
    /// what opens the door, and nothing else bears on it.
    let junction: Int
    /// Where the sign stands, on the same fractions the stops are placed by.
    let across: Double
    let up: Double
    /// The glyph painted on that sign, where a stop carries its number. A door has no number —
    /// it is not one of the nine — so it shows what it is instead.
    let glyph: String

    var id: String { name }
}

/// The levels of one world: the stops in the order the pig walks them, and any doors standing
/// off the side of that trail.
struct WorldMap: Sendable {
    let name: String
    let nodes: [WorldNode]
    /// The doors standing off the trail, which are not levels. Empty for every world but the
    /// meadow, which keeps the dressing barn beside its orchard.
    let spurs: [WorldSpur]

    init(name: String, nodes: [WorldNode], spurs: [WorldSpur] = []) {
        self.name = name
        self.nodes = nodes
        self.spurs = spurs
    }

    /// How many stops the trail has. A door is not a stop, so it is not counted here, nor
    /// anywhere else the world counts itself.
    var count: Int { nodes.count }

    subscript(index: Int) -> WorldNode { nodes[index] }

    /// How far up the meadow the furthest thing in the world stands, which is how tall the
    /// map has to be drawn. The last stop, usually — but a door standing higher than the stop
    /// it keeps beside still has to fit on the hillside.
    var reach: Double { (nodes.map(\.up) + spurs.map(\.up)).max() ?? 0 }

    func index(of levelID: String) -> Int? {
        nodes.firstIndex { $0.id == levelID }
    }

    func spur(withID id: String) -> WorldSpur? {
        spurs.first { $0.id == id }
    }

    /// Every star the world has in it, for a player who takes all of them. The trail's, and
    /// only the trail's — a door has none to give: see `WorldSpur`.
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
    /// harder thing about them: apples, then skulls to build around as well, then a second
    /// animal and one budget to split between the two.
    ///
    /// There is one thing in the meadow that is not one of the nine, and not a puzzle at all:
    /// the dressing barn, standing off the trail beside the seventh stop. Penning the orchard
    /// opens its doors and tapping it walks you in — it is not on the way anywhere, and the
    /// arithmetic of the world does not know it exists. See `WorldSpur`.
    static let mudlarkMeadow = WorldMap(
        name: "Mudlark Meadow",
        nodes: [
            WorldNode(level: .riverBend, across: 0.20, up: 0.00),
            WorldNode(level: .horseshoeLake, across: 0.76, up: 1.00),
            WorldNode(level: .theNarrows, across: 0.26, up: 2.06),
            WorldNode(level: .dewPonds, across: 0.78, up: 3.02),
            WorldNode(level: .otterFord, across: 0.22, up: 4.08),
            WorldNode(level: .puddleCorner, across: 0.62, up: 5.02),
            WorldNode(level: .windfallOrchard, across: 0.24, up: 6.06),
            WorldNode(level: .sourGround, across: 0.74, up: 7.00),
            WorldNode(level: .stagMere, across: 0.28, up: 8.06, starToll: 21)
        ],
        spurs: [
            // The dressing barn, standing in the corner of the field the orchard backs onto.
            // It keeps beside the seventh stop and stands away west of it, far enough off the
            // path that the two signs never crowd one another and low enough that the mist over
            // the unearned meadow still covers it until the orchard has been penned. It is not
            // a puzzle and never was: pen the orchard and the doors are open.
            WorldSpur(name: "Dressing Barn", junction: 6, across: 0.04, up: 6.70, glyph: "🧺")
        ]
    )
}
