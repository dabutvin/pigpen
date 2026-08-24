import Foundation

/// The tenth world's levels and the trail that strings them together.
///
/// Frostwhisker Tundra is the meadow's game on snow over sea ice: fence in the pig, the biggest
/// pen the pieces will reach round, shut or it is no pen at all. The windfall here is a **ski**
/// dropped on the way up to the slopes and the hazard an **ice slick** sheeted black across
/// the snow, and each is worth exactly what its meadow twin was — a ski five tiles to
/// shut in, an ice slick five to shut in with and no fencing at all, since nothing drives a post
/// through black ice — so the same solver that authored the nine worlds below these authored
/// them, with `a` standing in for the ski and `x` for the ice slick.
///
/// What the water is here is **a pressure ridge**: ice crushed upward where two floes met, too
/// sheer to climb and no ground to build on, so it stops a pig and a fence exactly as a river
/// does. And the world's own idea is the shape of it — **every ridge runs on the slant.** A
/// straight chain of single tiles on the diagonal, corner to corner, never two abreast and
/// never bending: the meadow has meres, the cove broken rings, and here every body of "water"
/// on every board is a diagonal line at least three tiles long. `FrostwhiskerTests` pins it —
/// one direction per chain, each tile touching the next at its corner and nothing anywhere
/// orthogonally beside it.
///
/// Which is a new kind of gift. A crescent handed over walls and a mouth; a ridge hands over a
/// wall that is already the best shape a wall can be. Tiles that touch only at corners still
/// seal the ground between them — nothing walks between two blades of ice — so a ridge is a
/// diagonal wall laid for free, and a diagonal wall is what every world since the meadow has
/// been teaching a player to build. The question each field here asks is not whether to lean on
/// the ridge but *how*: which end, which side, and what shape of bought wall finishes what the
/// ice began.
///
/// One field has no ice on it anywhere, the way The High Strand has no pool: The Whiteout,
/// where the weather has come down and every tile of the pen is bought.
///
/// The tundra floors at 41 against the cove's 40 — the highest floor in the game — on boards
/// where the free wall is always the right shape and the whole question is what to do with it.
extension PuzzleLevel {
    /// Two ridges leaning together like a roof — a corrie of ice with a one-tile gap at its
    /// apex, two ice slicks calved into the bowl, and the pig on the open snow below.
    ///
    /// The basin question, asked by the world's own wall: the ridges nearly close a bowl, one
    /// piece at the apex finishes it, and everything else follows from what the bowl turns out
    /// to be worth. Both answers here buy the plug — it is the cheapest wall on the board —
    /// and both take the two ice slicks with it, because a bowl is where ice slicks calve and going round
    /// them costs more ground than their ten points. The block squares the bowl off at the
    /// ridges' feet and holds 32 tiles and the two ice slicks, which is 22. The same thirteen pieces
    /// flare on south past the feet instead, lean the outside of both ridges the whole way
    /// down, and hold 43 tiles, one ski and the same two ice slicks, which is 38 — the ski lying
    /// out on the open snow is what the wider wall is for.
    ///
    /// Two more skis lie frozen in along the south rim, and nothing reaches them: no pen may
    /// stand on the edge of the map, so a ski on the rim is the ice's to keep.
    static let theCorrie = frostwhisker(
        id: "the-corrie",
        name: "The Corrie",
        fenceBudget: 13,
        twoStarScore: 22,
        threeStarScore: 36,
        maximumScore: 38,
        question: .basin,
        map: """
            ...........
            ....~.~....
            ...~...~...
            ..~.....~..
            .~..x.x..~.
            ...........
            .....P.....
            ...........
            ..a........
            ...........
            ..a.....a..
            """
    )

    /// Two short ridges thrown into opposite quarters of the board — spurs off floes that met
    /// somewhere else — with the pig on the flat between them and a ski on the line of both.
    ///
    /// The span question, on walls that are already diagonal: each spur is three tiles of free
    /// wall and each is useless alone, so the whole field is the wall thrown between them. The
    /// block gets a corner against each across the middle and holds 18 tiles and the ski,
    /// which is 23. The same thirteen pieces run out as one great lozenge that leans on every
    /// tile of both spurs — down the outside of one, back up the outside of the other — and
    /// hold 36 tiles and the same ski, which is 41. A second ski rides the north rim where
    /// the ice keeps it.
    static let twinSpurs = frostwhisker(
        id: "twin-spurs",
        name: "Twin Spurs",
        fenceBudget: 13,
        twoStarScore: 23,
        threeStarScore: 39,
        maximumScore: 41,
        question: .span,
        map: """
            .........a.
            .....~.....
            ......~....
            .......~...
            ...........
            ....P......
            .~...a.....
            ..~........
            ...~.......
            ...........
            ...........
            """
    )

    /// The weather down on the ground: snow to every horizon, no ridge anywhere in it, and the
    /// biggest budget in the world laid out across it.
    ///
    /// It is The High Strand again, and The Hardpan before it, and the answer is the answer it
    /// always was: the best block nineteen pieces can square off is a four by five holding 20,
    /// and the same nineteen run round as a diamond hold 36. A diagonal wall shuts nearly two
    /// tiles a piece where a straight one shuts one — which on this world is the lesson every
    /// ridge has been drawing on the ice for free, asked once with nothing drawing it. Two skis
    /// lie along the rims where the whiteout dropped them and two ice slicks sit off in the corners,
    /// and the diamond that wins touches none of them.
    static let theWhiteout = frostwhisker(
        id: "the-whiteout",
        name: "The Whiteout",
        fenceBudget: 19,
        twoStarScore: 20,
        threeStarScore: 34,
        maximumScore: 36,
        question: .bare,
        map: """
            ......a....
            ...........
            ...........
            ...........
            ...........
            ...........
            .....P..x..
            ..........a
            .....x.....
            ..a..x.....
            ...........
            .....x.....
            """
    )

    /// Two ridges on the same slant with a one-tile seam between them, where the floes did not
    /// quite finish meeting — and one piece finishes it.
    ///
    /// The gap question, asked in the world's own grammar: the two chains lie corner to corner
    /// on one line, so a single piece laid in the seam joins them into a seven-tile diagonal
    /// wall, the longest free wall the budget could never buy. The block refuses the seam and
    /// huddles east of the lower ridge for 19, one ski included. The same twelve pieces spend
    /// exactly one on the seam and the rest on a lozenge slung from end to end of the joined
    /// wall, and hold 26 tiles and both skis — one at each far end of what the seam made one —
    /// which is 36.
    static let theSeam = frostwhisker(
        id: "the-seam",
        name: "The Seam",
        fenceBudget: 12,
        twoStarScore: 19,
        threeStarScore: 34,
        maximumScore: 36,
        question: .gap,
        map: """
            ...........
            ....a......
            ..~........
            ...~.......
            ....~..P...
            ...........
            ......~..a.
            .......~...
            ........~..
            ...........
            ...........
            """
    )

    /// One ridge seven tiles long, whale-backed across the whole board, and a scatter of skis
    /// dropped out on the ice off its lower flank.
    ///
    /// The shore question, on the longest bank the tundra has: the ridge is the dominant free
    /// wall and the whole field is which stretch of it to use. The scatter says the lower
    /// stretch — three skis in a line, one stride apart — and the block believes it,
    /// scoops the scatter in a skinny box that wastes the ridge, and holds 7 tiles and all
    /// three skis, which is 22. The same eleven pieces flare from the ridge's high end instead,
    /// lean its whole lower run, and hold 27 tiles and the same scatter, which is 42 — the skis
    /// were never the question, the ridge was.
    static let whalebackRidge = frostwhisker(
        id: "whaleback-ridge",
        name: "Whaleback Ridge",
        fenceBudget: 11,
        twoStarScore: 22,
        threeStarScore: 39,
        maximumScore: 42,
        question: .shore,
        map: """
            ...........
            ...........
            ..~........
            ...~.......
            ....~......
            .....~.....
            ......~....
            .aaa...~...
            ....P...~..
            ...........
            ...........
            ...........
            """
    )

    /// Somebody's winter store, scattered: one ridge four tiles long, and three skis hung wide
    /// of the tidy line it suggests — one high, one far east, one tucked in behind the ice.
    ///
    /// The detour question: the ridge offers a neat rectangle and the skis refuse it. The block
    /// takes the offer, leans the ridge, and manages only the ski tucked inside its own lines
    /// — 15 tiles and one ski, which is 20. The same twelve pieces bow out of the tidy line
    /// three times over, once for each ski, and hold 24 tiles and all three, which is 39.
    /// Ground given up for ground, which is what a detour is, and this one is worth it three
    /// times.
    static let fishCache = frostwhisker(
        id: "fish-cache",
        name: "Fish Cache",
        fenceBudget: 12,
        twoStarScore: 20,
        threeStarScore: 37,
        maximumScore: 39,
        question: .detour,
        map: """
            ...........
            .......a...
            ...........
            ..~...P..a.
            ...~.a.....
            ....~......
            .....~.....
            ...........
            ...........
            ...........
            ...........
            """
    )

    /// Three ridges scattered to three quarters of the compass — the whiskers the world is
    /// named for — and every one of them a stretch of the same circle nobody has drawn.
    ///
    /// The constellation question, and the hardest field in the world. The ten tiles of ice
    /// are all arcs of one diamond ring drawn at five paces round the pig, and the budget is
    /// exactly the ten mud tiles of that ring the ice did not build: see the whole shape and
    /// the whole shape is affordable, see anything less and it is not. The block is the
    /// bottom half-diamond between the south ridges, 21. The full ring holds 41 tiles and the
    /// two skis lying in its top half, which is 51 — the Dew Ponds' lesson, spaced out to the
    /// width of a world that has been teaching diagonals for nine fields.
    static let theWhiskers = frostwhisker(
        id: "the-whiskers",
        name: "The Whiskers",
        fenceBudget: 10,
        twoStarScore: 21,
        threeStarScore: 48,
        maximumScore: 51,
        question: .constellation,
        map: """
            ...........
            ...........
            .......~...
            ....a.a.~..
            .........~.
            .....P.....
            .~.........
            ..~.....~..
            ...~...~...
            ....~.~....
            ...........
            """
    )

    /// The great floe: the broadest board in the tundra, two long ridges lying as opposite
    /// sides of a pen nobody has drawn, and a ski in each half of it.
    ///
    /// The Great Floe stands outside the climb the way Low Water and The Great Erg do. A broad
    /// board leaves a wide gap against a squared-off pen because it is broad — this one asks
    /// 43, less than The Whiskers above it — while holding 50 tiles, the biggest pen in the
    /// world. The block squares off between the ridges and nudges out over one ski for 34.
    /// The same fourteen pieces close the lozenge the two ridges already imply — each ridge a
    /// finished side, the bought wall only joining their ends — and hold 50 tiles and both
    /// ski, which is 60.
    static let theGreatFloe = frostwhisker(
        id: "the-great-floe",
        name: "The Great Floe",
        fenceBudget: 14,
        twoStarScore: 34,
        threeStarScore: 56,
        maximumScore: 60,
        question: .span,
        map: """
            ............
            .......~....
            ........~...
            ....a....~..
            ..........~.
            .....P......
            .~..........
            ..~....a....
            ...~........
            ....~.......
            ............
            ............
            """
    )

    /// The tundra's boss, and the tenth rule the game has: **the bull seal will not share a
    /// pen with the pig, and the pen he is given has to lie against the ice — he keeps a
    /// breathing hole.**
    ///
    /// Every two-pen boss so far has asked who goes where. This one is the first to be
    /// particular about *where the second pen is*: two pens, never one, and the seal's ground
    /// must touch a ridge, because a ridge is where the ice broke and the sea shows through,
    /// and a seal hauls out beside his breathing hole or nowhere. The board hands the seal a
    /// corner with no ice anywhere near it, which is the whole trap. Box him tidily where he
    /// lies and the board sends it back — held, and held dry, which for a seal is no holding
    /// at all. His pen has to be walked up the board to the tail of the great ridge, and every
    /// piece it takes is a piece the pig's pen does not get.
    ///
    /// The tidy answer that satisfies it is mean with the pig on purpose: box her on her own
    /// tile, spend the rest walling the seal a yard of ice against the ridge's tail, and that
    /// is 13. The same seventeen pieces spent the other way round run the pig's wall down the
    /// whole west flank of the great ridge — the longest free wall in the world doing the
    /// holding — with a two-piece yard for the seal tucked against the same tail, and that is
    /// 42 tiles, one ski and one ice slick, which is 42: the widest gap any boss in the game
    /// left, at 69, until the fen's croc asked 72. And the one answer nine worlds have
    /// drilled — one great pen round the pair — holds 51 tiles and is sent back whole,
    /// because the seal will not share.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since the
    /// thicket has.
    static let theHaulout = frostwhisker(
        id: "the-haulout",
        name: "The Haulout",
        fenceBudget: 17,
        twoStarScore: 13,
        threeStarScore: 39,
        maximumScore: 42,
        question: .hole,
        map: """
            .........~..
            ..~.......~.
            ...~.......~
            ....~.......
            .a...~......
            ......~.....
            ..P....~....
            ........~...
            ....x.......
            .~........L.
            ..~.........
            ...~........
            """
    )
}

/// Builds a tundra level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall`, the
/// caverns' `gloamdeep`, the carnival's `carnival`, the dunes' `dunes` and the cove's `tidepool`
/// do — a malformed map here is a mistake in the source, not anything a player could bring
/// about, and its `maximumScore` comes from `Tools/level_search.py` like every other in the
/// game.
private func frostwhisker(
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
    /// Frostwhisker Tundra: nine fields with nothing but diagonal ridges of ice on them,
    /// ending on a bull seal who must be penned against the water and a toll of most of the
    /// stars below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the
    /// pen a player gets by squaring the map off — and it climbs the whole way from The Corrie
    /// to The Whiskers, the way the cove climbs to Barnacle Corner and the dunes to Scarp
    /// Corner.
    ///
    /// The Whiteout stands third because of that order and not in spite of it: it is the one
    /// field here with no ice on it, so it is the one field a player has met before, and a
    /// diamond on bare snow turns out to ask more than a corrie with its apex handed over.
    ///
    /// The last two stops step out of the order for the same reason every world's do: The
    /// Great Floe is the broadest board in the tundra and holds the biggest pen in it, and The
    /// Haulout is a boss, and neither is measured by the same yardstick as a field with one
    /// animal and one wall to shape.
    static let frostwhiskerTundra = WorldMap(
        name: "Frostwhisker Tundra",
        nodes: [
            WorldNode(level: .theCorrie, across: 0.24, up: 0.00),
            WorldNode(level: .twinSpurs, across: 0.72, up: 1.04),
            WorldNode(level: .theWhiteout, across: 0.26, up: 2.02),
            WorldNode(level: .theSeam, across: 0.74, up: 3.06),
            WorldNode(level: .whalebackRidge, across: 0.28, up: 4.00),
            WorldNode(level: .fishCache, across: 0.70, up: 5.04),
            WorldNode(level: .theWhiskers, across: 0.24, up: 6.02),
            WorldNode(level: .theGreatFloe, across: 0.76, up: 7.06),
            WorldNode(level: .theHaulout, across: 0.28, up: 8.02, starToll: 21)
        ]
    )
}
