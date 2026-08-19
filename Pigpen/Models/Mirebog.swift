import Foundation

/// The eleventh world's levels and the trail that strings them together.
///
/// Mirebog Fen is the meadow's game on ground that never chose between land and water: fence
/// in the pig, the biggest pen the pieces will reach round, shut or it is no pen at all. The
/// windfall here is a **bilberry** ripened over the peat and the hazard a **snag** — bog oak
/// drowned black and hard as iron — and each is worth exactly what its meadow twin was, a
/// bilberry five tiles to shut in, a snag five to shut in with and no fencing at all, since
/// nothing drives a post into wood the bog already ate. So the same solver that authored the
/// ten worlds below these authored them, with `a` standing in for the bilberry and `x` for
/// the snag.
///
/// What the water is here is **a channel**: fen water moving too slowly to see, too deep to
/// wade and no ground to build on, so it stops a pig and a fence exactly as a river does. And
/// the world's own idea is the shape of it — **every channel closes on itself.** The water
/// splits, rejoins, and rings its own ground: every body on every board holds a loop, and none
/// of it ever runs two tiles deep. A meadow has meres, the cove broken rings, the tundra
/// chains on the slant; here the water is braided, and `MirebogTests` pins it — a cycle in
/// every body, never a two-by-two of water anywhere.
///
/// Which hands over walls the way every wet world has — a braid's outer bank is free fencing,
/// jogged so a rectangle cannot follow it — and keeps something back that no world has kept
/// before: **the bars.** The ground a loop rings is ground nothing can ever walk to, so a
/// bilberry parked on a bar is the loudest tease since the cove's rim pearls: in plain sight,
/// five points, and nobody's. The fen keeps what it rings, and the trail says so from the
/// second field on.
///
/// One field has no channel on it anywhere, the way The Whiteout has no ice: The Turbary, the
/// cut-over peat ground, where every tile of the pen is bought.
///
/// The fen floors at 42 against the tundra's 41 — the highest floor in the game — on boards
/// where the free wall is real but never straight, and half of what the water offers it keeps.
extension PuzzleLevel {
    /// Two staircase braids leaning together into a broad arch over the pig's hollow, a snag
    /// in the hollow's lee, and two bilberries out on the open peat below.
    ///
    /// The basin question, asked in the fen's grammar: the water has nearly done it — the bowl
    /// under the arch is walled on both flanks for free, and one piece at the apex shuts the
    /// mouth. The rest of the budget is the whole field. The block plugs the apex and squares
    /// the bowl off with a straight row, but the snag sits exactly where its second row wants
    /// to be, so it stops short at 21. The same eleven pieces run the south wall out as a deep
    /// V instead, scoop the west bilberry on the way, and hold 32 tiles and the berry, which
    /// is 37 — the east bilberry is the gift not worth taking, since reaching both costs more
    /// ground than one is worth.
    static let theEelTrap = mirebog(
        id: "the-eel-trap",
        name: "The Eel Trap",
        fenceBudget: 11,
        twoStarScore: 21,
        threeStarScore: 35,
        maximumScore: 37,
        question: .basin,
        map: """
            ...........
            ..~~~.~~~..
            ..~.~.~.~..
            ~~~~~.~~~~~
            ~.~..P..~.~
            ~~~.....~~~
            ...........
            ...........
            .......x...
            ...a...a...
            ...........
            ...........
            """
    )

    /// Two braids each useless alone — a pool trailing a staircase channel in the north-west,
    /// and its mirror in the south-east — with the pig on the open peat between them.
    ///
    /// The span question: neither bank pens anything by itself, and the best answer throws one
    /// wall of ten pieces between and around both, a great lozenge whose far faces are the two
    /// channels' banks. The bilberries hang at the lozenge's west and east waist, exactly
    /// where the wall bows widest, and the pen takes both: 37 tiles and the pair, which is 47.
    /// The block nests against the north-west braid and nudges out over one berry for 26 —
    /// barely more than half. The third bilberry rides the north-west pool's bar, ringed and
    /// unreachable, which is the fen's first word on what it keeps.
    static let theTwoCarrs = mirebog(
        id: "the-two-carrs",
        name: "The Two Carrs",
        fenceBudget: 10,
        twoStarScore: 26,
        threeStarScore: 44,
        maximumScore: 47,
        question: .span,
        map: """
            .~~~.......
            .~a~~~.....
            .~~~.~~....
            ......~~...
            .a.........
            .....P.....
            .........a.
            ...~~......
            ....~~.~~~.
            .....~~~.~.
            .......~~~.
            """
    )

    /// The cut-over ground: peat stripped to the bench, no channel anywhere on it, and the
    /// biggest budget in the world laid out across it.
    ///
    /// It is The Whiteout again, and The High Strand and The Hardpan before it, and the answer
    /// is the answer it always was — with one bilberry to bend it. The best block twenty-one
    /// pieces can square off is a strip nudged out over the berry for 27; the same twenty-one
    /// run round as a diamond slung off-centre hold 45 tiles and the berry, which is 50. Two
    /// more bilberries sit on the very corners of the map, where nothing can ever be penned:
    /// cut peat or no, the fen keeps its corners.
    static let theTurbary = mirebog(
        id: "the-turbary",
        name: "The Turbary",
        fenceBudget: 21,
        twoStarScore: 27,
        threeStarScore: 47,
        maximumScore: 50,
        question: .bare,
        map: """
            ..........a
            ...........
            ...........
            ...........
            ...........
            ..P......a.
            ...........
            ...........
            ...........
            ...........
            a..........
            """
    )

    /// Two braids nearly meeting — a north-west pool stepping its channel down toward the
    /// middle, a south-east channel rising to meet it — and one mud tile between their ends.
    ///
    /// The gap question, asked as a sluice: one piece on that tile fuses the two braids into a
    /// single barrier from the north rim to the south-east pool, and the best pen is the long
    /// diagonal strip behind it, capped with a staircase and holding both live bilberries at
    /// its two ends — 28 tiles and the pair, which is 38. The snag is staked exactly where the
    /// squared-off answer wants its south fence, so the block huddles mid-strip at 20. A third
    /// bilberry sits in the south-east pool's eye, ringed, teasing, and nobody's.
    static let theSluice = mirebog(
        id: "the-sluice",
        name: "The Sluice",
        fenceBudget: 11,
        twoStarScore: 20,
        threeStarScore: 36,
        maximumScore: 38,
        question: .gap,
        map: """
            ~~~........
            ~.~........
            ~.~........
            ~~~~.......
            .a.~~......
            ....~.~....
            ......~~...
            ....P..~~..
            ........~..
            ......a.~~~
            ...x....~a~
            ........~~~
            """
    )

    /// One long braid and nothing else: a single loop-chain snaking clear across the upper
    /// third of the board, five linked eyes rising and dipping, its ends curling down to the
    /// rims.
    ///
    /// The shore question, on the longest bank the fen has: the braid's south bank is the
    /// dominant free wall, and the whole field is which stretch of it to use. The bilberries
    /// hang deep to the south-west and south-east, and the best pen leans on the bank and
    /// funnels its V south-west to swallow the west berry — 28 tiles and the berry, which is
    /// 33. The block leans the same bank, but the snag stands where its east wall wants to,
    /// so it squares off at 17 and reaches no berry at all.
    static let bitternBank = mirebog(
        id: "bittern-bank",
        name: "Bittern Bank",
        fenceBudget: 11,
        twoStarScore: 17,
        threeStarScore: 31,
        maximumScore: 33,
        question: .shore,
        map: """
            ....~~~....
            ..~~~.~~~..
            ~~~.~~~.~~~
            ~.~~~.~~~.~
            ~~~.....~~~
            ...........
            ....P...x..
            ...........
            ...........
            ...a...a...
            ...........
            ...........
            """
    )

    /// Berries hung wide of every tidy line — east, west, and high — with two pool-braids
    /// walling the bottom corners and a one-tile gap in the bottom channel.
    ///
    /// The detour question, teased three ways: the tidy answer is a straight-walled box over
    /// the pig with a plug in the gap, and the snag is staked exactly where that box's
    /// north-west fence wants to be, so the block swallows it and pays the five — 22 tiles
    /// less the snag is 17. The best pen bows out east instead, a skewed dome leaning both
    /// pools, and stretches its wall to the east bilberry: 29 tiles and the berry, which is
    /// 34. The high berry hangs one tile past its tip and the west one stays wide — the pen
    /// bows for one, and is teased by two.
    static let bilberryHags = mirebog(
        id: "bilberry-hags",
        name: "Bilberry Hags",
        fenceBudget: 11,
        twoStarScore: 17,
        threeStarScore: 32,
        maximumScore: 34,
        question: .detour,
        map: """
            ...........
            ...........
            ......a....
            ...........
            ...x.......
            .a...P...a.
            ...........
            ~~~.....~~~
            ~.~.....~.~
            ~~~~~.~~~~~
            ...........
            """
    )

    /// The corner of the fen: a tall loop-braid stacked up the whole west side, the bottom
    /// channel running east to the south-east pool, and their banks meeting at the south-west
    /// — two whole sides of the field walled for free. The same scatter of berries as
    /// Bilberry Hags, asked a harder question.
    ///
    /// Which is the corner question the way Rimstone Corner, Scarp Corner and Barnacle Corner
    /// asked it. The right-angled answer ignores the gift, boxes the pig high on the peat and
    /// nudges over the west bilberry: 16. The best pen takes the corner and beats the box with
    /// one long diagonal thrown from the high ground down to the east pool, plus a short
    /// staircase to scoop the same west berry — 30 tiles and the berry, which is 35 against
    /// 16, and at 54 the hardest field in the fen. The high berry hangs one tile past the
    /// funnel's tip, and the east one is stranded behind the snag.
    static let heronCorner = mirebog(
        id: "heron-corner",
        name: "Heron Corner",
        fenceBudget: 11,
        twoStarScore: 16,
        threeStarScore: 33,
        maximumScore: 35,
        question: .corner,
        map: """
            ...........
            ...........
            ....a......
            ...........
            .......x...
            .a...P...a.
            ~~~........
            ~.~........
            ~.~.....~~~
            ~.~.....~.~
            ~~~~~..~~~~
            ...........
            """
    )

    /// The great slough: the broadest board in the fen, the north-west pool-and-channel braid
    /// and its south-east mirror thrown as far apart as the board allows, a bilberry off each,
    /// and a snag dead in the middle of everything.
    ///
    /// The Great Slough stands outside the climb the way Low Water and The Great Floe do. The
    /// span question at full stretch: thirteen pieces close the lozenge the two braids imply
    /// and hold 49 tiles — the biggest pen in the world — both live bilberries, and the fen's
    /// one bitter mouthful: the snag sits mid-lozenge where no wall can exclude it, and the
    /// pen swallows it and pays, 49 and 10 less 5 for 54. The block leans the north-west braid
    /// and pays the same snag for 30. The third bilberry rides the south-east pool's eye,
    /// ringed and untouchable.
    static let theGreatSlough = mirebog(
        id: "the-great-slough",
        name: "The Great Slough",
        fenceBudget: 13,
        twoStarScore: 30,
        threeStarScore: 51,
        maximumScore: 54,
        question: .span,
        map: """
            .~~~........
            .~.~~~......
            .~~~.~~.....
            ......~~....
            .a..x.......
            .....P......
            ............
            ..........a.
            ....~~......
            .....~~.~~~.
            ......~~~a~.
            ........~~~.
            """
    )

    /// The fen's boss, and the eleventh rule the game has: **the old croc will not share a pen
    /// with the pig, and the pen he is given has to hold every bank of one whole channel — a
    /// croc keeps a wallow rather than visits one, and half a wallow is nobody's.**
    ///
    /// The tundra's seal wanted a pen that touched the water; the croc wants a pen that owns
    /// it. His channel sits ringed by three others — two of them backed against the rims,
    /// their far banks unwalkable, so his is the only wallow on the board that can ever be
    /// whole — and he lies in the one-tile causeway between his channel and its neighbour.
    /// Box him there with two pieces and both animals are held, and the board sends it back:
    /// his pen laps one bank of the wallow and not the rest, which is no wallow at all. Pen
    /// the pair together in one great sweep of the east fen — more ground than the winning
    /// answer holds — and the board sends that back whole, because the croc is not company.
    ///
    /// The tidy answer that satisfies it is mean with everybody: box the pig on her own tile
    /// and run a tight ring of causeways round the croc's channel, leaning the sister braids
    /// for walls — and the snag on the ring's south line is staked so the ring must swallow
    /// it, 18 tiles less the snag and the pig's one, which is 13. The same nineteen pieces
    /// swing the ring wide instead, take the whole east fen into the croc's ground with both
    /// live bilberries and both snags, and that is 48 — at 72 the widest gap any board in the
    /// game left until the heights' Eyrie asked 76. His channel's own bar keeps a bilberry no
    /// pen will ever hold, which on this board is the croc's pantry.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since the
    /// thicket has.
    static let theWallow = mirebog(
        id: "the-wallow",
        name: "The Wallow",
        fenceBudget: 19,
        twoStarScore: 13,
        threeStarScore: 45,
        maximumScore: 48,
        question: .wallow,
        map: """
            ....~~~.....
            ....~.~.....
            ....~~~.....
            ............
            ~~~.~~~.....
            ~.~G~a~.....
            ~~~.~~~..a..
            ............
            ....x...a~~~
            ......x..~.~
            .P.......~~~
            ............
            """
    )
}

/// Builds a fen level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall`,
/// the caverns' `gloamdeep`, the carnival's `carnival`, the dunes' `dunes`, the cove's
/// `tidepool` and the tundra's `frostwhisker` do — a malformed map here is a mistake in the
/// source, not anything a player could bring about, and its `maximumScore` comes from
/// `Tools/level_search.py` like every other in the game.
private func mirebog(
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
    /// Mirebog Fen: nine fields with nothing but closed braids of channel water on them,
    /// ending on an old croc who must be given a whole wallow and a toll of most of the stars
    /// below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and
    /// the pen a player gets by squaring the map off — and it climbs the whole way from The
    /// Eel Trap to Heron Corner, the way the tundra climbs to The Whiskers and the cove to
    /// Barnacle Corner.
    ///
    /// The Turbary stands third because of that order and not in spite of it: it is the one
    /// field here with no channel on it, so it is the one field a player has met before, and
    /// a diamond on cut peat turns out to ask more than two carrs a span apart.
    ///
    /// The last two stops step out of the order for the same reason every world's do: The
    /// Great Slough is the broadest board in the fen and holds the biggest pen in it, and The
    /// Wallow is a boss, and neither is measured by the same yardstick as a field with one
    /// animal and one wall to shape.
    static let mirebogFen = WorldMap(
        name: "Mirebog Fen",
        nodes: [
            WorldNode(level: .theEelTrap, across: 0.24, up: 0.00),
            WorldNode(level: .theTwoCarrs, across: 0.72, up: 1.04),
            WorldNode(level: .theTurbary, across: 0.26, up: 2.02),
            WorldNode(level: .theSluice, across: 0.74, up: 3.06),
            WorldNode(level: .bitternBank, across: 0.28, up: 4.00),
            WorldNode(level: .bilberryHags, across: 0.70, up: 5.04),
            WorldNode(level: .heronCorner, across: 0.24, up: 6.02),
            WorldNode(level: .theGreatSlough, across: 0.76, up: 7.06),
            WorldNode(level: .theWallow, across: 0.28, up: 8.02, starToll: 21)
        ]
    )
}
