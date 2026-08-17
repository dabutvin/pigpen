import Foundation

/// The ninth world's levels and the trail that strings them together.
///
/// Tidepool Cove is the meadow's game on wet sand: fence in the pig, the biggest pen the pieces
/// will reach round, shut or it is no pen at all. The windfall here is a **pearl** the tide left
/// lying in its shell and the hazard a **jellyfish** stranded where it washed up, and each is
/// worth exactly what its meadow twin was — a pearl five tiles to shut in, a jellyfish five to
/// shut in with and no fencing at all, since nothing drives a post through a sting — so the same
/// solver that authored the eight worlds below these authored them, with `a` standing in for the
/// pearl and `x` for the jellyfish.
///
/// What the water is here is **a tidepool**: seawater the tide left behind, too deep to wade and
/// no ground to build on, so it stops a pig and a fence exactly as a river does. And the world's
/// own idea is the shape of it — **every pool is a broken ring.** A ring of tidewater round a
/// heart of dry sand, with one break in its lip where the tide got out. A meadow has meres, a
/// thicket pools, a city canals in straight runs, the reaches a scatter of single drops, the
/// caverns one stepped river, the carnival filled blocks and the dunes nothing but crescents;
/// here every body of water on every board is a ring with a bite out of it. `TidepoolTests` pins
/// it — a box of water one tile thick, a dry heart inside, and exactly one lip tile missing,
/// never a corner.
///
/// Which out-offers even the dunes. A crescent handed over three walls and a mouth; a broken
/// ring hands over a pen that is *finished* but for its break, and one piece on the break shuts
/// the heart. It is the cheapest pen the game has ever offered — and it is a trap, because a
/// heart is small and the ring is where the tide put it. So the question every field here asks
/// is what the tide's gift is actually worth, and the answer is almost never what it looks like:
/// the heart is walked past, teased through a break that faces the rim, poisoned with a
/// jellyfish, or bought and found wanting. The wall that wins leans on the *outside* of the
/// ring instead, which is the same lesson every world teaches, told through the keyhole of a
/// shape that keeps promising otherwise.
///
/// One field has no pool on it anywhere, the way The Hardpan has no sand: The High Strand, the
/// ground above the tideline, where every tile of the pen is bought.
///
/// The cove floors at 40 against the dunes' 39 — the highest floor in the game — on boards where
/// the tide's gift has to be priced before anything else can be worked out.
extension PuzzleLevel {
    /// One pool mid-board with its break facing the rim, a pearl lying in its heart, and two
    /// jellyfish stranded in its lee — the tide's whole repertoire on the first field.
    ///
    /// The basin question, asked backwards, which is how the cove introduces itself. The pool's
    /// heart is a finished pen with a pearl in it, and there is no having it: the break faces
    /// the top of the map, so the only way in runs over the rim, where nothing can be penned.
    /// The gift is a picture of a gift. What the pool actually hands over is its south wall —
    /// and the ground under that wall is where the tide dumped its jellyfish, so the block a
    /// player squares off in the pool's lee spends thirteen pieces holding twenty tiles and
    /// minus ten points, which is 10.
    ///
    /// The same thirteen drawn as a diamond on the open sand below hold 27 tiles — and the pair
    /// of jellyfish with them, because a diamond wide enough to be worth drawing cannot come
    /// down between them, and ten points is cheaper than the ground a detour round them gives
    /// up. 17 is the best this board has, the smallest opening maximum in the game, and the
    /// first lesson of the cove: price what the tide leaves lying about, and take the sting
    /// when the sting is cheaper than the swerve.
    ///
    /// Two pearls lie on the south rim where the water went out, and nothing reaches them: no
    /// pen may stand on the edge of the map, so a treat on the rim is the tide's to keep.
    static let ebbtidePool = tidepool(
        id: "ebbtide-pool",
        name: "Ebbtide Pool",
        fenceBudget: 13,
        twoStarScore: 10,
        threeStarScore: 16,
        maximumScore: 17,
        question: .basin,
        map: """
            ...........
            ..~~.~~....
            ..~.a.~....
            ..~...~....
            ..~~~~~....
            ...x.x.....
            ...........
            ....P......
            ...........
            ...........
            .a.......a.
            """
    )

    /// Two small pools set corner to corner across the middle of the strand, each with its break
    /// turned in towards the other, and the pig on the open sand between them.
    ///
    /// The span question: neither pool is any use on its own — a ring three tiles wide walls
    /// almost nothing — and no rectangle on this board reaches round both. Squaring off gets one
    /// corner against each across the middle and holds 17. Twelve pieces run out as one long
    /// diagonal band from the top of the board down between the two rings hold 30
    /// tiles, leaning on the outside of one pool going down and the other coming back — because
    /// two walls that face each other across open ground are a pen already drawn, if the wall
    /// thrown between them steps on the diagonal.
    ///
    /// The hearts go unbought on purpose: a tile apiece behind their breaks, they are the
    /// cheapest ground on the board and the least of it, which is the world's lesson told twice
    /// in miniature. The pools' pearls are already gone — the tide carried both down the strand
    /// and dropped them on the line of the map, where nothing can be penned.
    static let twinPools = tidepool(
        id: "twin-pools",
        name: "Twin Pools",
        fenceBudget: 12,
        twoStarScore: 17,
        threeStarScore: 28,
        maximumScore: 30,
        question: .span,
        map: """
            ...........
            ..~~~......
            ..~.~......
            ..~.~......
            ...........
            ....P......
            ......~.~..
            ......~.~..
            ......~~~..
            ...........
            ...a.....a.
            """
    )

    /// The ground above the tideline: dry strand twelve tiles across, no pool anywhere on it,
    /// and the biggest budget in the world laid out across it.
    ///
    /// It is The Hardpan again, and The Blind Grike and Swept Flat before it, and the answer is
    /// the answer it always was: the best block nineteen pieces can square off is a four by five
    /// holding 20, and the same nineteen run round as a diamond hold 36. A diagonal wall shuts
    /// nearly two tiles a piece where a straight one shuts one, and on ground with nothing on it
    /// there is nothing else to know — which is why the strand is the one field here a player
    /// has met before, and why it stands mid-trail rather than at the start of it.
    ///
    /// A pearl lies at each end of the last wave's reach, on the very rim of the map, and
    /// nothing reaches either: the tide keeps what it leaves on the line.
    static let theHighStrand = tidepool(
        id: "the-high-strand",
        name: "The High Strand",
        fenceBudget: 19,
        twoStarScore: 20,
        threeStarScore: 34,
        maximumScore: 36,
        question: .bare,
        map: """
            ............
            ............
            ............
            ............
            ............
            ......P.....
            ............
            ............
            ............
            ............
            .a........a.
            """
    )

    /// One pool with its break turned east and two pearls seeded in its heart, a third pearl out
    /// on the open sand, and the pig in the far south-west corner.
    ///
    /// The detour question, asked through the break: the heart holds ten points and its only
    /// door faces away from everything, so the pen that wants the pearls has to come the whole
    /// way round the pool and in at the east side — ground given up for ground, which is what a
    /// detour is. The best block fourteen pieces make leans the west rim and takes the field
    /// pearl for 23. The same fourteen run out and round hold 27 tiles, both seeded pearls and
    /// the field pearl too, which is 42 — the pen bends in at the break, swallows the heart,
    /// and still reaches the loose pearl on its way back south.
    ///
    /// It is the first heart in the world worth buying, and the board makes buying it cost
    /// exactly the shape a rectangle cannot make.
    static let theOysterBed = tidepool(
        id: "the-oyster-bed",
        name: "The Oyster Bed",
        fenceBudget: 14,
        twoStarScore: 23,
        threeStarScore: 39,
        maximumScore: 42,
        question: .detour,
        map: """
            ...........
            ...........
            ...........
            ..~~~~.....
            ..~aa......
            ..~..~.....
            ..~~~~.....
            ...........
            .P....a....
            ...........
            ...........
            """
    )

    /// Two pools reaching in from either side of the board with their breaks facing each other,
    /// a dry channel one tile wide between them, and the channel's head standing on the rim.
    ///
    /// The gap question, asked at the top of the map: the channel joins both hearts to the open
    /// field, and every way into all of it funnels through the single tile where the channel
    /// meets the rim. One piece there buys the channel, the western heart and the pearl lying in
    /// it — the whole north of the board walled by two rings and a single post. Thirteen pieces
    /// squared off below reach 23; the same thirteen spent as that one plug and a lozenge slung
    /// under both pools hold 38 tiles and the pearl, which is 43.
    ///
    /// The eastern heart lost its pearl to the tide, which is the board saying the two rings are
    /// not the same offer: one break leads to treasure and one to swept sand, and the wall is
    /// the same wall either way.
    static let theRunnel = tidepool(
        id: "the-runnel",
        name: "The Runnel",
        fenceBudget: 13,
        twoStarScore: 23,
        threeStarScore: 40,
        maximumScore: 43,
        question: .gap,
        map: """
            ...........
            .~~~~.~~~~.
            .~a......~.
            .~~~~.~~~~.
            ...........
            ...........
            ...........
            .....P.....
            ...........
            ........a..
            ...........
            """
    )

    /// One long pool the width of the strand, its break mid-lip on the south side, two jellyfish
    /// stranded under its wall and two pearls further down the sand.
    ///
    /// The shore question, on the longest bank the cove has: the pool's south lip is eight tiles
    /// of free wall, and the whole field is how much of it to use and what using it costs. The
    /// block squared off under the lip holds 31 tiles and both jellyfish, which is 21. The same
    /// fourteen pieces flared out as a lozenge from the lip's two ends hold 44 tiles, one pearl
    /// and the same two jellyfish, which is 39 — the stings are the price of the bank either
    /// way, so the pen that wins is the one that buys the most sand with them.
    static let theLongPool = tidepool(
        id: "the-long-pool",
        name: "The Long Pool",
        fenceBudget: 14,
        twoStarScore: 21,
        threeStarScore: 37,
        maximumScore: 39,
        question: .shore,
        map: """
            ...........
            .~~~~~~~~..
            .~......~..
            .~~~~.~~~..
            ..x....x...
            ...........
            .....P.....
            ...........
            ...........
            ....a...a..
            ...........
            """
    )

    /// The corner of the cove: one great pool along the whole north of the board with pearls
    /// teasing behind a rim-facing break, and a second pool down the east side with its break
    /// turned in and a pearl behind it.
    ///
    /// Which is the corner question with two free sides, the way Rimstone Corner and The Big Top
    /// and Scarp Corner asked it, and the hardest corner anywhere in the game. The
    /// right-angled answer tucks a rectangle under the north pool and pays its own east and
    /// south walls: 22. The ten pieces run instead as one long chevron from under the north lip
    /// down to the east pool's flank — every piece on the diagonal — and hold 42 tiles, and the
    /// pen lets itself in at the east pool's break for the pearl on its way, which is 47.
    ///
    /// The north pool's two pearls sit behind a break that opens onto the rim, and stay there:
    /// the loudest tease in the world, nine tiles of heart and treasure with no door anybody
    /// can use.
    static let barnacleCorner = tidepool(
        id: "barnacle-corner",
        name: "Barnacle Corner",
        fenceBudget: 10,
        twoStarScore: 22,
        threeStarScore: 44,
        maximumScore: 47,
        question: .corner,
        map: """
            ~~~~~.~~~~~
            ~.a.....a.~
            ~~~~~~~~~~~
            ...........
            ...P....~~~
            ........~.~
            ........~.~
            ........~a~
            ..........~
            ........~.~
            ........~~~
            """
    )

    /// The flats at low water: the broadest board in the cove, two pools far apart with their
    /// breaks turned in to the middle, a pearl in each heart, a third loose on the sand, and
    /// a jellyfish on the straight line between everything.
    ///
    /// Low Water stands outside the climb the way Smoulder Ridge and The Midway and The Great
    /// Erg do. A broad board leaves a wide gap against a squared-off pen because it is broad —
    /// this one asks 46, less than Barnacle Corner above it — while holding 48 tiles, the
    /// biggest pen in the world. Sixteen pieces squared off between the pools hold 26 tiles, two
    /// pearls and the jellyfish, which is 31. The same sixteen swung corner to corner as one
    /// great lozenge hold 48 tiles, all three pearls and the same sting, which is 58 — a detour
    /// on the scale of the whole board, each heart bought through its break in passing.
    static let lowWater = tidepool(
        id: "low-water",
        name: "Low Water",
        fenceBudget: 16,
        twoStarScore: 31,
        threeStarScore: 55,
        maximumScore: 58,
        question: .detour,
        map: """
            ............
            ..~~~.......
            ..~a~.......
            ..~.~.......
            ............
            .....P......
            ....x....a..
            ............
            .......~.~..
            .......~a~..
            .......~~~..
            ............
            """
    )

    /// The cove's boss, and the ninth rule the game has: **the crab keeps his pool, and the
    /// pig's ground has to close the whole way round it — break, crab and all.**
    ///
    /// It is the carnival's ring asked of a pool rather than a man. The Center Ring taught that
    /// a pen can stand inside another pen; this one hands the inner pen over already built — the
    /// crab sits in the heart of a broken ring of tidewater, walled by the pool on every side
    /// but its break — and asks for the ring round the outside of it. One piece on the break
    /// shuts the crab in, the cheapest boss pen the game has ever handed out. Every other piece
    /// goes on the moat, and the moat is the whole board: the pig may not stand in with him, and
    /// her ground has to close round the pool so that no way off the map misses it.
    ///
    /// The answers eight worlds have taught are turned down one after the other. Shut the pool's
    /// break and box the pig beside it and both are held, in two tidy pens — and the board sends
    /// it back, because a pen alongside is no ring. Run the ring and forget the break, and the
    /// crab strolls out of his pool into the pig's own ground — held, and held together, which
    /// is no answer either. The ring *and* the plug, both, from one budget of twenty-two.
    ///
    /// The tidy answer that satisfies it is the square moat: a box of wall round the pool with
    /// the one piece on the break, 17 tiles of ground and nothing on any of them. The same
    /// twenty-two drawn as a great diamond hold 37 tiles and all three pearls — one off each
    /// side of the square's reach, which is exactly where a diamond's points go — and that is
    /// 52, the widest gap any boss in the game left at 67, until the tundra's seal asked 69.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since the
    /// thicket has.
    static let theCrabPool = tidepool(
        id: "the-crab-pool",
        name: "The Crab Pool",
        fenceBudget: 22,
        twoStarScore: 17,
        threeStarScore: 49,
        maximumScore: 52,
        question: .moat,
        map: """
            ...........
            ...........
            ...........
            ...........
            ....~.~....
            .a..~C~..a.
            ....~~~....
            ...P.......
            ...........
            .....a.....
            ...........
            """
    )
}

/// Builds a cove level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall`, the
/// caverns' `gloamdeep`, the carnival's `carnival` and the dunes' `dunes` do — a malformed map
/// here is a mistake in the source, not anything a player could bring about, and its
/// `maximumScore` comes from `Tools/level_search.py` like every other in the game.
private func tidepool(
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
    /// Tidepool Cove: nine fields with nothing but broken rings of tidewater on them, ending on
    /// a crab who will not leave his pool and a toll of most of the stars below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the
    /// pen a player gets by squaring the map off — and it climbs the whole way from Ebbtide Pool
    /// to Barnacle Corner, the way the dunes climb to Scarp Corner and the carnival to The
    /// Rigging.
    ///
    /// The High Strand stands third because of that order and not in spite of it: it is the one
    /// field here with no pool on it, so it is the one field a player has met before, and a
    /// diamond on bare sand turns out to ask more than two rings thrown a span apart.
    ///
    /// The last two stops step out of the order for the same reason every world's do: Low Water
    /// is the broadest board in the cove and holds the biggest pen in it, and The Crab Pool is a
    /// boss, and neither is measured by the same yardstick as a field with one animal and one
    /// wall to shape.
    static let tidepoolCove = WorldMap(
        name: "Tidepool Cove",
        nodes: [
            WorldNode(level: .ebbtidePool, across: 0.24, up: 0.00),
            WorldNode(level: .twinPools, across: 0.72, up: 1.04),
            WorldNode(level: .theHighStrand, across: 0.26, up: 2.02),
            WorldNode(level: .theOysterBed, across: 0.74, up: 3.06),
            WorldNode(level: .theRunnel, across: 0.28, up: 4.00),
            WorldNode(level: .theLongPool, across: 0.70, up: 5.04),
            WorldNode(level: .barnacleCorner, across: 0.24, up: 6.02),
            WorldNode(level: .lowWater, across: 0.76, up: 7.06),
            WorldNode(level: .theCrabPool, across: 0.28, up: 8.02, starToll: 21)
        ]
    )
}
