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
        question: .shore,
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
    /// mouth and hold the pool's 16 tiles; squaring off below it holds 20 and reaches neither
    /// truffle — the block that used to hold 21 stood a piece on one of them, and no piece goes
    /// on a truffle — where seven spent leaning the wall out to the east gather the truffle on
    /// that side and come to 29.
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
        question: .basin,
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
        question: .shore,
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

    /// A ring of pools set round a clearing, and the thicket's turn of the idea the meadow's
    /// dew ponds opened. Seven pools, no two of them touching, laid on the wall of a pen that
    /// is not drawn anywhere: each is a tile of wall nobody pays for, and the thirteen pieces
    /// are exactly the rest of that wall — no more, no less.
    ///
    /// Which is the whole of the field. A rectangle cannot use a single pool, so squaring off
    /// is worth 19; the ring the pools imply holds 36. The truffle out past the north-east is
    /// the decoy, since reaching it means breaking the ring and giving up more ground than
    /// five points. The meadow spaced its ponds a tile apart; these are two, and the shape is
    /// that much less obvious for it.
    static let fairyRing = woodland(
        id: "fairy-ring",
        name: "Fairy Ring",
        fenceBudget: 13,
        twoStarScore: 19,
        threeStarScore: 34,
        maximumScore: 36,
        question: .constellation,
        map: """
            ..........
            ..........
            ..~..~.a..
            .......~..
            ..........
            ~...P.....
            ........~.
            ..........
            ..~..~....
            ..........
            """
    )

    /// A gully with a pool along its head and a truffle at either end of the walling that is
    /// dear: one out east on the pig's own line, one well down the gully to the south-west. A
    /// truffle is worth more than the ground a pen gives up bending to reach it, and no piece
    /// will lie on one, so the best pen is a long tongue that goes out for both rather than a
    /// tidy box that takes the near one and stops: twenty-four tiles and both truffles, which
    /// comes to thirty-four, against a block worth twenty-three.
    static let fernGully = woodland(
        id: "fern-gully",
        name: "Fern Gully",
        fenceBudget: 12,
        twoStarScore: 19,
        threeStarScore: 32,
        maximumScore: 34,
        question: .detour,
        map: """
            ..........
            .~~~~~~~~.
            .~~~~~~~~.
            ..........
            ...P..a...
            ..........
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
        question: .obstruction,
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
        question: .corner,
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
        question: .detour,
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

    /// The thicket's boss, and the field where the woods stop copying the meadow.
    ///
    /// Stag Mere taught that two pens sharing a stretch of water beat one pen dragged round
    /// both animals. Here the pool is pulled back into the middle of the wood and touches
    /// neither animal, so that lesson does not apply — and for a while the board looks as
    /// though one big pen round the pair is the answer, because with twenty pieces it very
    /// nearly is.
    ///
    /// It is not, because the boar will not have it. This is the first field in the game that
    /// refuses a pen for a reason other than something walking out of it: hold them both, but
    /// never in the same ground. So the twenty pieces go out as two enclosures that lean on
    /// the pool from opposite sides and share not one tile — 28 tiles and three truffles, 43,
    /// against a squared-off 36, since a pair of blocks nudged out over the truffles their walls
    /// wanted collect all three of those as well. It asks for most of the stars the fields below
    /// it hold.
    static let boarHollow = woodland(
        id: "boar-hollow",
        name: "Boar Hollow",
        fenceBudget: 20,
        twoStarScore: 25,
        threeStarScore: 40,
        maximumScore: 43,
        question: .apart,
        map: """
            ..........
            ..a....x..
            ...P......
            ..........
            ....~~~...
            ...~~~~...
            ....~~....
            ..a....B..
            .......a..
            ..x.......
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
            WorldNode(level: .fairyRing, across: 0.78, up: 3.02),
            WorldNode(level: .fernGully, across: 0.22, up: 4.08),
            WorldNode(level: .willowCorner, across: 0.64, up: 5.02),
            WorldNode(level: .nettleBank, across: 0.26, up: 6.06),
            WorldNode(level: .elderwood, across: 0.76, up: 7.00),
            WorldNode(level: .boarHollow, across: 0.30, up: 8.06, starToll: 21)
        ]
    )
}
