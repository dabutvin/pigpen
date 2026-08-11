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
/// its pig everywhere at once, so a truffle turns up in the second field and a bramble in the
/// seventh, and there are fields between them with nothing lying about at all. It reads as woods
/// a pig has been rooting through rather than a syllabus — which is the whole difference the
/// theme is there to make.
///
/// The other thing the thicket does is start higher up. The meadow opened on two fields whose
/// best pen *was* the plain block, because the game had itself to explain; the woods are walked
/// by somebody who has already held every pen in the meadow, so not one field here gives its
/// third star to a squared-off pen. `DifficultyTests` measures that as the world's floor and
/// holds it above the meadow's.
extension PuzzleLevel {
    /// Where the meadow put a river bend, the woods put a brook that gives less away. It bars
    /// the north and turns south down the east, and the ground it leaves opens to the west and
    /// the south with nothing on those two sides but the rim. Nine pieces squared off round the
    /// pig hold 20 tiles; the same nine cut as a staircase down the south-west corner hold 27,
    /// which is every tile the brook can be made to keep.
    ///
    /// It opens the thicket the way River Bend opened the meadow — familiar water, a gentle
    /// budget, nothing lying on the ground to weigh — with the one difference the world is
    /// built on: the meadow's opener handed its third star to the obvious block and this one
    /// keeps it back. A player who has walked a whole world already knows what a corner is
    /// worth.
    static let brambleBrook = woodland(
        id: "bramble-brook",
        name: "Bramble Brook",
        fenceBudget: 9,
        twoStarScore: 15,
        threeStarScore: 25,
        maximumScore: 27,
        map: """
            ..........
            ..........
            ~~~~~~~~..
            .......~..
            ...P...~..
            .......~..
            .......~..
            .......~..
            ..........
            """
    )

    /// A pool the pig sits in the middle of, walled on every side by water bar the mouth at the
    /// bottom, with a truffle lying out beyond either corner of that mouth. Four pieces plug the
    /// mouth and hold the pool's 16 tiles; squaring off below it with all seven holds 21 and
    /// reaches neither truffle, where seven spent leaning the wall out to the east gather the
    /// truffle on that side and come to 29.
    ///
    /// The choice is which truffle rather than whether — the two lie too far apart for one
    /// budget to reach both, and a wall that goes after the second gives up more ground on the
    /// way than the truffle is worth. It is the thicket's first treat, and it is out here in
    /// the second field where the meadow kept its first apple back until the seventh.
    static let foxgloveDell = woodland(
        id: "foxglove-dell",
        name: "Foxglove Dell",
        fenceBudget: 7,
        twoStarScore: 17,
        threeStarScore: 27,
        maximumScore: 29,
        map: """
            ..........
            ..~~~~~~..
            .~~~~~~~~.
            .~~....~~.
            .~~....~~.
            .~~.P..~~.
            .~~....~~.
            .a......a.
            ..........
            ..........
            """
    )

    /// A truffle that costs nothing to take, after a dell where taking one was the whole
    /// question: a brook bars the north, so the ground under it is cheap to wall, and the
    /// truffle sits on the pig's own tile-line where the pen was going to close anyway. What
    /// this one asks for is the shape — twelve pieces cut a lozenge, and the corners a plain
    /// block pays for are the seven tiles between 23 and 30.
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

    /// The thicket's boss: a hollow pool across the middle of the wood, the pig grazing
    /// north of it and a boar south, with the same rule the meadow's last field taught —
    /// one budget has to hold both of them. The pool walls one side of each enclosure the
    /// way Stag Mere's water does, so the twenty pieces go out as two pens rather than one.
    /// Truffles on both shores are worth going out of the way for, and there is a bramble
    /// on each: neither wall can pass over one, and on this board walling round either of
    /// them costs more ground than the bramble does, so each pen takes its own in and pays
    /// for it. 29 tiles and three truffles, less the two brambles, come to 34. It asks for
    /// most of the stars the fields below it hold before it will open.
    static let boarHollow = woodland(
        id: "boar-hollow",
        name: "Boar Hollow",
        fenceBudget: 20,
        twoStarScore: 19,
        threeStarScore: 32,
        maximumScore: 34,
        map: """
            ..........
            .....a....
            ..P.......
            ...x......
            ...~~~~...
            ..~~~~~~..
            ...~~~~...
            .......x..
            ..a....B..
            ....a.....
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
    /// Thornwood Thicket: nine fields up a winding trail through the trees, climbing to a boss
    /// that stands a second animal and asks for most of the stars below it. The truffles and
    /// brambles are scattered rather than saved for the end, so the woods read as country a
    /// pig has been through rather than a lesson laid out in order.
    ///
    /// It is also the same trail walked from higher up. The meadow could open on two fields
    /// that gave their third star to the plain block, since it had a game to teach; the woods
    /// have nowhere that generous on them, and the least any field here asks is well above the
    /// meadow's floor. `DifficultyTests` measures every stop in both worlds and fails if a
    /// world ever opens softer, or floors lower, than the one below it.
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
