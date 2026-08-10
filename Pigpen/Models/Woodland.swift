import Foundation

/// The second world's levels and the trail that strings them together.
///
/// Thornwood Thicket is the meadow's game moved into the trees: fence in the pig, the biggest
/// pen the pieces will reach round, shut or it is no pen at all. What is different is the
/// ground it is played on. The windfall here is a truffle rather than an apple and the hazard
/// a bramble rather than a skull, but each is worth what its meadow twin was — a truffle five
/// tiles to shut in, a bramble five to shut in with and no fencing at all — so the same solver
/// that authored the meadow authored these, with `a` standing in for the truffle and `x` for
/// the bramble.
///
/// The one thing the thicket does that the meadow did not is scatter its treats. The meadow
/// held them all back for its last three fields, teaching water and fencing clean first and
/// only then handing the player an orchard and a patch of sour ground. The thicket has walked
/// its pig everywhere at once, so a truffle turns up in the third field and a bramble in the
/// sixth, and there are fields between them with nothing lying about at all. It reads as woods
/// a pig has been rooting through rather than a syllabus — which is the whole difference the
/// theme is there to make.
extension PuzzleLevel {
    /// A truffle in the leaf mould where the first world put a river bend: two free sides
    /// from the brook, two walls of the player's own, and one windfall it costs nothing to
    /// take in. The obvious block already holds all of it, so the three stars are free while
    /// the thicket introduces itself.
    static let brambleBrook = woodland(
        id: "bramble-brook",
        name: "Bramble Brook",
        fenceBudget: 10,
        twoStarScore: 11,
        threeStarScore: 19,
        maximumScore: 20,
        map: """
            .........
            .........
            ~~~~~~~..
            ......~..
            ...P..~..
            ......~..
            .........
            .........
            """
    )

    /// A pool the pig sits in the middle of, walled on all four sides by water bar the corners.
    /// Six pieces close the two open corners and hold twenty tiles — the second field whose
    /// best pen is the plain one, so a player still finding their feet in the trees keeps their
    /// footing.
    static let foxgloveDell = woodland(
        id: "foxglove-dell",
        name: "Foxglove Dell",
        fenceBudget: 6,
        twoStarScore: 11,
        threeStarScore: 19,
        maximumScore: 20,
        map: """
            ..........
            ..~~~~~~..
            .~~~~~~~~.
            .~~....~~.
            .~~....~~.
            .~~.P..~~.
            .~~....~~.
            ..........
            ..........
            """
    )

    /// The first truffle worth going a little out of the way for: a brook bars the north, so
    /// the ground under it is cheap to wall, and a truffle sits on the pig's own tile-line
    /// where the pen was going to close anyway. Twelve pieces cut a lozenge that holds it.
    static let hazelCopse = woodland(
        id: "hazel-copse",
        name: "Hazel Copse",
        fenceBudget: 12,
        twoStarScore: 17,
        threeStarScore: 28,
        maximumScore: 30,
        map: """
            ..........
            ..........
            ~~~~~~~~..
            ..........
            ...aP.....
            ..........
            ..........
            ..........
            """
    )

    /// A stream across the whole thicket, broken by one dry stone. That stone is the only way
    /// across and costs a single piece to shut, which buys the entire far bank as a free wall.
    /// Nothing lies on this one — the woods do not put a truffle in every clearing.
    static let gnarlFord = woodland(
        id: "gnarl-ford",
        name: "Gnarl Ford",
        fenceBudget: 12,
        twoStarScore: 14,
        threeStarScore: 23,
        maximumScore: 24,
        map: """
            ..........
            ..........
            ..........
            ~~~~~.~~~~
            ..........
            ....P.....
            ..........
            ..........
            ..........
            """
    )

    /// A gully with a pool along its head and truffles down its length, strung out south of
    /// the pig where the walling is dear. A truffle is worth more than the ground a pen gives
    /// up to bend down and reach it, so the best pen is a long tongue rather than a tidy box:
    /// twenty-four tiles and both of its truffles, which comes to thirty-four.
    static let fernGully = woodland(
        id: "fern-gully",
        name: "Fern Gully",
        fenceBudget: 12,
        twoStarScore: 19,
        threeStarScore: 32,
        maximumScore: 34,
        map: """
            ..........
            .~~~~~~~~.
            .~~~~~~~~.
            ..........
            ...P......
            ..a.......
            ..........
            ..a.......
            ..........
            ..........
            """
    )

    /// The first bramble: one staked in the mud north of the pig, and a truffle either side of
    /// the puzzle. A bramble takes no fencing, so a wall that wants its tile has to step round
    /// it — and the best pen here takes the near bramble in and pays its five, since walling
    /// round it would cost more ground than that, while leaving the far truffle out.
    static let nettleBank = woodland(
        id: "nettle-bank",
        name: "Nettle Bank",
        fenceBudget: 13,
        twoStarScore: 15,
        threeStarScore: 24,
        maximumScore: 26,
        map: """
            ..........
            ....a.....
            ..........
            ...x......
            ....P.....
            ..~~~.....
            .~~~~~.a..
            ..~~~.....
            ..........
            ..........
            """
    )

    /// A pool bent into one corner of a small clearing, leaving the pig two water walls and two
    /// of its own. Eight pieces cut the far corner off on the diagonal and hold twenty-six
    /// tiles, where the best right-angled block those eight can wall holds far fewer. The
    /// thicket's staircase, and nothing lying on it to soften the ask.
    static let willowCorner = woodland(
        id: "willow-corner",
        name: "Willow Corner",
        fenceBudget: 8,
        twoStarScore: 15,
        threeStarScore: 24,
        maximumScore: 26,
        map: """
            ~~~~~~~~
            ~.......
            ~.......
            ~..P....
            ~.......
            ~.......
            ~.......
            ........
            """
    )

    /// The widest board in the woods: a mere down one side, a bramble staked off to the west,
    /// and truffles scattered through the open ground. Fifteen pieces cut the pen to the shape
    /// of the shore and gather three truffles on the way, leaving the bramble out — forty-one.
    static let elderwood = woodland(
        id: "elderwood",
        name: "Elderwood",
        fenceBudget: 15,
        twoStarScore: 23,
        threeStarScore: 39,
        maximumScore: 41,
        map: """
            ..........
            .~~~~~....
            .~~~~~~...
            ..~~~~~~..
            ...~~~~~..
            ....~~~.a.
            ..P.......
            ....a.....
            ..x.......
            ....a.....
            ..........
            """
    )

    /// The thicket's boss: the deepest hollow in the wood, thick with truffles and staked with
    /// bramble, with a pool in the middle of it. Eighteen pieces — the biggest budget in the
    /// woods — gather four truffles and take one bramble in, for fifty-four. It asks for most of
    /// the stars the fields below it hold before it will open, so it is played by somebody who
    /// has gone back and bettered their pens rather than one who has merely reached it.
    static let boarHollow = woodland(
        id: "boar-hollow",
        name: "Boar Hollow",
        fenceBudget: 18,
        twoStarScore: 31,
        threeStarScore: 51,
        maximumScore: 54,
        map: """
            ..........
            ...a...a..
            ..........
            ....x.....
            .a..P..a..
            ..........
            ...~~~....
            ..~~~~~.x.
            ...~~~....
            ..a...a...
            ..........
            """
    )
}

/// Builds a thicket level from an ASCII map, the same way the meadow's `authored` does — a
/// malformed map here is a mistake in the source, not anything a player could bring about, and
/// its `maximumScore` comes from `Tools/level_search.py` like every other in the game.
private func woodland(
    id: String,
    name: String,
    fenceBudget: Int,
    twoStarScore: Int,
    threeStarScore: Int,
    maximumScore: Int,
    map: String
) -> PuzzleLevel {
    guard let level = PuzzleLevel(
        id: id,
        name: name,
        fenceBudget: fenceBudget,
        twoStarScore: twoStarScore,
        threeStarScore: threeStarScore,
        maximumScore: maximumScore,
        map: map
    ) else {
        preconditionFailure("The built-in \(name) map is malformed")
    }
    return level
}

extension WorldMap {
    /// Thornwood Thicket: nine fields up a winding trail through the trees, the same shape as
    /// the meadow — water and fencing first, treats coming and going after — climbing to a boss
    /// that asks for most of the stars below it. The truffles and brambles are scattered rather
    /// than saved for the end, so the woods read as country a pig has been through rather than
    /// a lesson laid out in order.
    static let thornwoodThicket = WorldMap(
        name: "Thornwood Thicket",
        nodes: [
            WorldNode(level: .brambleBrook, across: 0.22, up: 0.00),
            WorldNode(level: .foxgloveDell, across: 0.74, up: 1.00),
            WorldNode(level: .hazelCopse, across: 0.24, up: 2.06),
            WorldNode(level: .gnarlFord, across: 0.78, up: 3.02),
            WorldNode(level: .fernGully, across: 0.22, up: 4.08),
            WorldNode(level: .willowCorner, across: 0.64, up: 5.02),
            WorldNode(level: .nettleBank, across: 0.26, up: 6.06),
            WorldNode(level: .elderwood, across: 0.76, up: 7.00),
            WorldNode(level: .boarHollow, across: 0.30, up: 8.06, starToll: 21)
        ]
    )
}
