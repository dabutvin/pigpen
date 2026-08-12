import Foundation

/// The fourth world's levels and the trail that strings them together.
///
/// Cogsworth City is the meadow's game played on paving: fence in the pig, the biggest pen
/// the pieces will reach round, shut or it is no pen at all. The windfall here is a pie
/// dropped outside a shop and the hazard a drain sunk into the road, but each is worth what
/// its meadow twin was — a pie five tiles to shut in, a drain five to shut in with and no
/// fencing at all, since nothing will drive a post through cast iron — so the same solver
/// that authored the meadow and the woods and the mountain authored these, with `a` standing
/// in for the pie and `x` for the drain.
///
/// What the city does that none of the three worlds below it did is **cut its water**. A
/// meadow has meres, a thicket has pools and a mountain has tarns, and every one of them lies
/// in a body two or three tiles thick; every drop of water in this world is canal, dug one
/// tile wide and turned at right angles like everything else somebody built here. A canal
/// walls a pen without taking any ground away from it, which sounds like a gift and is not:
/// there is no broad bank to square a rectangle off against, only a line to follow.
/// `CogsworthTests` pins it — no two tiles of water in this world lie side by side and one
/// above the other.
///
/// The other thing it does is take the room away. Every board here is smaller than the
/// smallest shelf on Emberpeak, so the rim is always close, and a pen that wants to be big has
/// to be the shape of the yard it stands in rather than the shape a player would draw. It is
/// why the city floors at 30% where the mountain floors at 28: on ground this tight, squaring
/// off wastes more than it ever did in open country.
extension PuzzleLevel {
    /// The cut runs the whole width of the world along the top of the gasworks and turns
    /// down the far end of it, which hands over the north wall and most of the east one for
    /// nothing. Nine pieces squared off under it hold 18 tiles; the same nine run down the
    /// west and then stepped away south-east hold 26, which is every tile the yard has in it.
    ///
    /// It opens the world the way Cinder Slope opened the mountain, and asks a little more
    /// than that did — 30 against 28 — because a player standing here has held three worlds
    /// of pens and a canal, unlike a melt channel, leaves nothing to lean on but its own line.
    static let gasworksCut = cogsworth(
        id: "gasworks-cut",
        name: "Gasworks Cut",
        fenceBudget: 9,
        twoStarScore: 15,
        threeStarScore: 24,
        maximumScore: 26,
        question: .shore,
        map: """
            .........
            ~~~~~~~~~
            ........~
            ..P.....~
            ........~
            .........
            .........
            .........
            """
    )

    /// The city's first pie, and the first field to ask what one is worth. Two of them lie
    /// out on the row — one halfway down the paving, one at the far end past where any tidy
    /// wall would stop — and the cut down the west is the only free wall there is.
    ///
    /// Eleven pieces squared off against the cut hold twelve tiles and the near pie, which is
    /// 17. The pen that wins gives up the tidy shape altogether and runs out on the diagonal
    /// to take that same pie with twenty tiles round it instead of twelve: 25. The far one
    /// stays where it fell, because the ground a wall gives up bending out to it costs more
    /// than the five it pays — which is the whole of what a pie is for.
    static let piemansRow = cogsworth(
        id: "piemans-row",
        name: "Pieman's Row",
        fenceBudget: 11,
        twoStarScore: 14,
        threeStarScore: 24,
        maximumScore: 25,
        question: .detour,
        map: """
            ~........
            ~........
            ~.P....a.
            ~........
            ~...a....
            ~........
            .........
            .........
            """
    )

    /// Paving, and nothing else: no canal anywhere near it, two drains sunk in the middle of
    /// it and fourteen pieces. Every tile of this pen is bought.
    ///
    /// It is the city's answer to Basalt Flats, and a tighter one. The best block those
    /// fourteen pieces can square off in a yard this size holds 12; the same fourteen run out
    /// as a ring that steps round both drains hold 18. Half the answer is knowing a ring beats
    /// a box, and the other half is where to put the ring so neither drain is on its wall.
    static let cobbleYard = cogsworth(
        id: "cobble-yard",
        name: "Cobble Yard",
        fenceBudget: 14,
        twoStarScore: 10,
        threeStarScore: 17,
        maximumScore: 18,
        question: .bare,
        map: """
            .........
            .........
            ..x......
            .........
            ....P....
            .........
            ......x..
            .........
            """
    )

    /// A canal across the whole world with the lock standing open in the middle of it. One
    /// piece laid in the gate shuts the only way north and buys the entire canal as a free
    /// wall, which is Otter Ford's lesson taught on a board a third the size — and with a
    /// drain staked directly under the gate, so the ground the plug buys is sour.
    ///
    /// Twelve pieces are then left for three sides. Squaring them off holds 19 tiles, less the
    /// drain, which is 14; the same twelve stepped away south on the diagonal hold 27, less the
    /// drain, which is 22. Walling round the drain costs more ground than the drain does, so
    /// this is a field where the answer is to swallow it and pay.
    static let lockGate = cogsworth(
        id: "lock-gate",
        name: "Lock Gate",
        fenceBudget: 13,
        twoStarScore: 13,
        threeStarScore: 21,
        maximumScore: 22,
        question: .gap,
        map: """
            .........
            ~~~~.~~~~
            .........
            ...x.....
            ....P....
            .........
            .........
            .........
            """
    )

    /// Two culverts reaching in from opposite sides of the street, one along the top and one
    /// along the bottom, with six rows of paving between them. Neither is any use on its own
    /// and no single wall reaches both: the meadow's Narrows put its two banks a stride apart,
    /// and this one puts them at either end of the world.
    ///
    /// So the pen has to lean on one culvert, run the length of the street on the diagonal and
    /// come down on the other — thirteen pieces, 27 tiles — where the best block that can
    /// reach both at once holds 16. It is the widest gap the city leaves outside its last two
    /// fields.
    static let culvertRow = cogsworth(
        id: "culvert-row",
        name: "Culvert Row",
        fenceBudget: 13,
        twoStarScore: 15,
        threeStarScore: 25,
        maximumScore: 27,
        question: .span,
        map: """
            ........
            ~~~~....
            ........
            ........
            ...P....
            ........
            ........
            ....~~~~
            ........
            """
    )

    /// The canal runs the whole east side of the lane and two drains are sunk out in the
    /// middle of the paving, exactly where a wall would want to stand. Neither is worth paying
    /// for here: the wall comes off the canal and runs down the diagonal tight past the upper
    /// drain, then pinches in round the lower one, which is a wall built round a tile rather
    /// than over it.
    ///
    /// Sour Ground made that choice once and Sulphur Rill made it twice; this makes it twice
    /// on a board with nowhere to put the mistake. Fourteen pieces, 26 tiles, and a block
    /// worth 15.
    static let gutterLane = cogsworth(
        id: "gutter-lane",
        name: "Gutter Lane",
        fenceBudget: 14,
        twoStarScore: 15,
        threeStarScore: 24,
        maximumScore: 26,
        question: .obstruction,
        map: """
            ........~
            ........~
            ...P....~
            ........~
            ..x.....~
            ........~
            ....x...~
            .........
            """
    )

    /// Two canals meeting at the corner of the foundry, and the hardest field in the city.
    ///
    /// Puddle Corner and Willow Corner both handed out eight pieces and asked the same
    /// question — how much does a diagonal buy over a right angle — and both were worth 26 off
    /// clean ground. This one hands out nine and stakes two drains on the diagonal itself, so
    /// the staircase cannot simply be drawn: it has to be drawn round one drain and over the
    /// other. Nine pieces cut the corner off and hold 32 tiles, less the drain the wall
    /// swallows on the way, which is 27; the best right-angled block those same nine can wall
    /// is worth 15. No corner in the game gives a diagonal this much to buy.
    static let foundryCorner = cogsworth(
        id: "foundry-corner",
        name: "Foundry Corner",
        fenceBudget: 9,
        twoStarScore: 15,
        threeStarScore: 25,
        maximumScore: 27,
        question: .corner,
        map: """
            ~~~~~~~~~
            ~........
            ~........
            ~..P.....
            ~...x....
            ~........
            ~.....x..
            .........
            """
    )

    /// The widest board in the city and the last field before the wharf: the canal comes in
    /// under the clocktower, three pies are dropped across the square and two drains are sunk
    /// in it. Seventeen pieces cut the pen to the shape of the canal and gather two of the
    /// pies on the way, taking one drain in and paying for it and leaving the far pie and the
    /// other drain outside — thirty-five tiles and two pies, less the one drain, which is
    /// forty, and the biggest pen in the world.
    ///
    /// It stands outside the climb the way Smoulder Ridge does: a broad board leaves a wide
    /// gap against a squared-off pen because it is broad, which says more about its size than
    /// about how hard it is to hold.
    static let clocktowerSquare = cogsworth(
        id: "clocktower-square",
        name: "Clocktower Square",
        fenceBudget: 17,
        twoStarScore: 23,
        threeStarScore: 38,
        maximumScore: 40,
        question: .detour,
        map: """
            ~~~~~....
            ....~....
            .........
            ..P....a.
            .........
            ....x....
            ..a......
            .......a.
            ....x....
            """
    )

    /// The city's boss: the canal itself, cut straight across the wharf with the pig on the
    /// near quay and the rat king on the far one, and the same rule the last field of every
    /// world has taught — one budget has to hold both of them. The water walls one side of
    /// each enclosure the way Stag Mere's mere and Wyrm Caldera's lake do, so the twenty
    /// pieces go out as two pens rather than one.
    ///
    /// What the wharf adds is that both quays are worth having. The mountain's rim was narrow
    /// ground hardly worth a piece; here there is a pie on each side of the canal and a drain
    /// on each side too, so the split is a real question rather than a formality — and the
    /// pen that wins takes every pie in the world and pays for both drains. 34 tiles and
    /// three pies, less the two drains, come to 39. It asks for most of the stars the fields
    /// below it hold before it will open.
    static let ratKingWharf = cogsworth(
        id: "rat-king-wharf",
        name: "Rat King Wharf",
        fenceBudget: 20,
        twoStarScore: 22,
        threeStarScore: 37,
        maximumScore: 39,
        question: .herd,
        map: """
            .........
            ..P.a....
            .........
            ...x.....
            ~~~~~~~~~
            .........
            ..a...R..
            ....a.x..
            .........
            """
    )
}

/// Builds a city level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland` and the mountain's `emberpeak` do — a malformed map here is a mistake in the
/// source, not anything a player could bring about, and its `maximumScore` comes from
/// `Tools/level_search.py` like every other in the game.
private func cogsworth(
    id: String,
    name: String,
    fenceBudget: Int,
    twoStarScore: Int,
    threeStarScore: Int,
    maximumScore: Int,
    question: Question? = nil,
    map: String
) -> PuzzleLevel {
    guard let level = PuzzleLevel(
        id: id,
        name: name,
        fenceBudget: fenceBudget,
        twoStarScore: twoStarScore,
        threeStarScore: threeStarScore,
        maximumScore: maximumScore,
        question: question,
        map: map
    ) else {
        preconditionFailure("The built-in \(name) map is malformed")
    }
    return level
}

extension WorldMap {
    /// Cogsworth City: nine yards, lanes and wharves, ending at a canal with a second animal
    /// across it and a toll of most of the stars below it.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the
    /// pen a player gets by squaring the map off — and it climbs the whole way from Gasworks
    /// Cut to Foundry Corner, the way Emberpeak climbs to Crater Pools. The last two stops
    /// step out of that order for the same reason every world's do: Clocktower Square is the
    /// widest board in the city and the wharf is a boss, and neither is measured by the same
    /// yardstick as a field with one animal and one wall to shape.
    static let cogsworthCity = WorldMap(
        name: "Cogsworth City",
        nodes: [
            WorldNode(level: .gasworksCut, across: 0.26, up: 0.00),
            WorldNode(level: .piemansRow, across: 0.74, up: 1.04),
            WorldNode(level: .cobbleYard, across: 0.24, up: 2.02),
            WorldNode(level: .lockGate, across: 0.70, up: 3.06),
            WorldNode(level: .culvertRow, across: 0.28, up: 4.02),
            WorldNode(level: .gutterLane, across: 0.76, up: 5.04),
            WorldNode(level: .foundryCorner, across: 0.22, up: 6.06),
            WorldNode(level: .clocktowerSquare, across: 0.72, up: 7.02),
            WorldNode(level: .ratKingWharf, across: 0.30, up: 8.06, starToll: 21)
        ]
    )
}
