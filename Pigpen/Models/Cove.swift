import Foundation

/// The ninth world's levels and the trail that strings them together.
///
/// Tidepool Cove is the meadow's game on the flats: fence in the pig, the biggest pen the pieces
/// will reach round, shut or it is no pen at all. The windfall here is a **clam** lying open where
/// the tide left it and the hazard a **sea urchin**, and each is worth exactly what its meadow twin
/// was — a clam five tiles to shut in, an urchin five to shut in with and no fencing at all, since
/// there is nowhere on an urchin to stand a post — so the same solver that authored the eight
/// worlds below these authored them, with `a` standing in for the clam and `x` for the urchin.
///
/// What the water is here is **the sea**, which is the plainest thing water has been in nine
/// worlds. The world's own idea is not what the water is but where it has got to: every world under
/// this one is a field with water in it, and **the cove is water with fields in it.** The tide has
/// come up through the ground and cut it into lands that do not touch, so the first question every
/// board asks is not what shape of pen but *which of this ground can she reach at all* — and the
/// answer is always less than it looks.
///
/// `CoveTests` pins the four promises that make that a world rather than a coincidence. Every board
/// is two lands or more. No land is smaller than four tiles, so the far shore is always big enough
/// to want. The pig stands on one land and never on all of it, so there is always ground she cannot
/// have. And every urchin lies at the waterline, on a tile with water beside it — because a coast
/// is a great deal of free wall, and the hazard is pegged along exactly the walls a pen wants to
/// lean on.
///
/// Which is new in what it **withholds**. Eight worlds have handed the pig water for nothing and
/// called it a wall; the cove hands her a coast on every board and fences ground off with the same
/// stroke — every field here has land on it she can see and will never stand on. And the two halves
/// of that pull in opposite directions, which is what makes the boards. A squared-off pen has to
/// fit inside one land, and the lands out here are cut on the diagonal as often as not. A pen that
/// follows a coast can have most of one. That is where the gap comes from, and it is why the cove
/// opens above every world below it without any of its boards having to be mean.
///
/// The cove floors at 40% against the dunes' 38 — the highest floor in the game.
extension PuzzleLevel {
    /// One channel, cut at the ebb: it comes in off the north rim, turns at the fourth row and runs
    /// the whole diagonal down to the south-east corner, with a wedge of water left standing in the
    /// south-west. Sixty-four tiles of cockle bank on her side of it, thirty-three on the other.
    ///
    /// The shore question, asked on the longest bank this world has and asked on the slant. Thirteen
    /// pieces laid against the cut get their western side free where the steps happen to line up with
    /// it, and buy a north wall and an east wall: 21 tiles. But a rectangle has one north side and
    /// this coast has eight steps in it, so squaring off can only ever meet the water at a corner.
    /// The whole budget run down the length of the cut and closed along the eastern rim holds 30
    /// tiles instead, and the clam in the north with them, which is 35.
    ///
    /// The top of that wall is a tongue two rows deep, drawn round a clam standing on its own above
    /// the bank: five pieces to fetch four tiles and five points, and the one place on the board where
    /// the wall leaves the line of the cut for something lying on the ground.
    ///
    /// The second clam is up on the north rim, which is ground no pen may hold on any board in the
    /// game. The cove will spend the rest of the trail putting clams where she cannot walk; this one
    /// is only out of reach.
    ///
    /// It opens the world the way Slipface Hollow opened the dunes, and asks more than that did —
    /// 40 against 39 — because a player standing here has held eight worlds of pens, and the first
    /// thing this one does is draw them a bank with a bend in it and take a third of the field away.
    static let cockleBank = cove(
        id: "cockle-bank",
        name: "Cockle Bank",
        fenceBudget: 14,
        twoStarScore: 21,
        threeStarScore: 33,
        maximumScore: 35,
        question: .shore,
        map: """
            .~.......a.
            .~.....a...
            .~.........
            .~~........
            ..~~.......
            ...~~......
            ....~~.....
            .....~~....
            ~.....~~...
            ~~.....~~P.
            ~~~.....~..
            """
    )

    /// Three runs of water that all meet: a channel down from the north rim, a bar across the
    /// north-west and a longer bar across the middle and out to the eastern rim. It leaves three
    /// lands — seventy-three tiles in the south, eighteen in the north-east, ten in the north-west —
    /// and stands the pig on the neck between the two bars, walled north, east and south by the sea.
    ///
    /// The basin question, and the water has done three sides of it. What is left is the mouth,
    /// which is the whole south and west. Thirteen pieces hung down off the neck as a rectangle hold
    /// 20 tiles and the clam in the south, which is 25, and it is a fair answer — the north wall
    /// comes free, and so do the three tiles of channel that bite into the eastern side of it.
    ///
    /// What a rectangle cannot do is go under the middle bar. The same thirteen run as a lozenge —
    /// four pieces down the western rim and the rest stepped round the south — hold 35 tiles, and
    /// four of those tiles are the strip in the lee of the bar out to the east, with the second clam
    /// lying on it. Both clams inside, which is 45.
    ///
    /// Both lands across the water are left empty on purpose. This is the one board in the cove
    /// whose best pen comes back with every clam on the map, and it is the second field of nine: the
    /// world says what it is going to do before it starts doing it.
    static let ebbNeck = cove(
        id: "ebb-neck",
        name: "Ebb Neck",
        fenceBudget: 13,
        twoStarScore: 25,
        threeStarScore: 42,
        maximumScore: 45,
        question: .basin,
        map: """
            .....~~....
            .....~~....
            ~~~~~~.....
            ....P~.....
            ....~~~~~~~
            .....~a...~
            ...........
            ...........
            .....a.....
            ...........
            ...........
            """
    )

    /// The gut: one tile of water running the whole height of the board, rim to rim, with the flats
    /// on the west of it and an island of thirty-three tiles on the east. And a pool two tiles by
    /// two, left inland in the north-west of her side.
    ///
    /// The span question. The gut is a wall down one whole side and nothing else; the pool is four
    /// tiles of water in a corner and nothing else. Fourteen pieces squared off against the gut hold
    /// 24 tiles and one clam, which is 29 — and that is every rectangle on this board, because there
    /// is no rectangle that touches both.
    ///
    /// The same fourteen thrown from the pool's shoulder across to the gut, run down the western rim
    /// and closed on the diagonal in the south hold 44 tiles and two clams, which is 54. Four pieces
    /// of that wall are the span itself, laid across the north between the two pieces of water; what
    /// they buy is the two rows behind the pool, which no rectangle can have without paying for a
    /// west wall as well.
    ///
    /// Two clams lie on the island across the gut, five points apiece and in plain sight on ground
    /// she cannot walk to. Every board in the cove has ground like that on it. This is the first one
    /// that puts anything worth having on it.
    static let barnacleGut = cove(
        id: "barnacle-gut",
        name: "Barnacle Gut",
        fenceBudget: 14,
        twoStarScore: 29,
        threeStarScore: 51,
        maximumScore: 54,
        question: .span,
        map: """
            .......~...
            .~~....~.a.
            .~~....~...
            .......~...
            .......~...
            .......~...
            .a.....~...
            .......~...
            ....a..~...
            .....P.~.a.
            .......~...
            """
    )

    /// Open sea two tiles deep down the whole of the north-east, and an inlet in the west that turns
    /// south and runs out to the rim, cutting six tiles off the south-west corner. Between them,
    /// eighty-seven tiles of strand with two clams lying on it.
    ///
    /// Which is the shore question again, three fields on and asked the hard way round. Squaring off
    /// is not the problem here — a rectangle in the middle of the strand can get its east side
    /// against the sea and its west side against the inlet at the same time, and thirteen pieces
    /// make 16 tiles and the clam of it, which is 21. The problem is that both coasts keep going and
    /// the rectangle stops.
    ///
    /// So the answer is a band on the slant: a staircase down the north-west from the sea's edge to
    /// the mouth of the inlet, and another back up the south-east from the inlet to the sea. Thirteen
    /// pieces, 35 tiles and the same clam, which is 40 — and every tile of both coasts between the
    /// two staircases is wall the board gave away. It is the hardest shore in the game at 47%, five
    /// points past The Long Slack out in the dunes.
    ///
    /// The second clam is pegged on the western rim two rows above the inlet: on her own ground, and
    /// outside every pen that can be drawn on the board.
    static let theLongStrand = cove(
        id: "the-long-strand",
        name: "The Long Strand",
        fenceBudget: 13,
        twoStarScore: 21,
        threeStarScore: 38,
        maximumScore: 40,
        question: .shore,
        map: """
            .........~~
            .........~~
            .........~~
            .........~~
            a........~~
            ......a..~~
            ~~~~.....~~
            ~~~~.....P.
            ..~~.......
            ..~~.......
            ..~~.......
            """
    )

    /// The beds: a strand down the western rim for eight of its eleven rows, and a channel down the
    /// north-east that turns
    /// and runs out to the eastern rim, cutting eight tiles off that corner. Four clams on the mussel
    /// beds between them, three in the open and the fourth right on the line the closing wall takes.
    ///
    /// The detour question, and the hardest in the game. A rectangle against the western strand holds
    /// 28 tiles and the clam standing in the middle of them, which is 33 — the strand pays for its
    /// west wall and it pays for nothing else, because a rectangle that reached east for the other
    /// clams would have to buy the whole of its own north side.
    ///
    /// Fifteen pieces run instead round the north of the beds and back down the east on the diagonal:
    /// 50 tiles, three clams, which is 65 — twenty-two tiles and two clams more than the tidy answer
    /// gets, off the same budget.
    ///
    /// Two of those clams lie side by side at the eastern edge of the beds, right where the wall has
    /// to turn for home. The answer reaches out for the first of them and closes on top of the
    /// second: a clam takes a post perfectly well, and the five points go under it. Melon Ground said
    /// that first, out in the sand, and this is the same sentence with the choice made twice in one
    /// step.
    static let theMusselBeds = cove(
        id: "the-mussel-beds",
        name: "The Mussel Beds",
        fenceBudget: 15,
        twoStarScore: 33,
        threeStarScore: 61,
        maximumScore: 65,
        question: .detour,
        map: """
            ........~..
            ........~..
            .....a..~..
            ~.......~..
            ~.......~~~
            ~...a..aa..
            ~..........
            ~..........
            ~P.........
            ~..........
            ~..........
            """
    )

    /// One bent coast down the west — the rim for four rows, then a diagonal away to the south — and
    /// the open sea filling the whole south-east corner, three columns of it by four rows. The two
    /// nearly meet in the south, and eleven pieces, the smallest budget in the world, are handed over
    /// to do the rest.
    ///
    /// The corner question with two free sides, the way Rimstone Corner and The Big Top and Scarp
    /// Corner asked it, and the hardest corner in the game at 52%. The right-angled answer runs a
    /// straight wall across the flats and drops one piece down to the sea: 19 tiles, and it reaches
    /// no clam.
    ///
    /// The eleven run instead as one long chevron. It goes up into the north-west first, four rows
    /// north of where the tidy wall stopped, to take the nearer of the two clams lying in the north; then out
    /// across the open flats on the diagonal, where a wall shuts two tiles a piece where a straight
    /// one shuts one; then closes on the sea's edge in the south. 35 tiles and the clam, which is 40
    /// — more than twice the block, off a budget of eleven.
    ///
    /// The second clam is two tiles east of the chevron's line, and there is no version of this pen
    /// that reaches it. On a board where two of the walls came free, five points is still four pieces
    /// of fence.
    static let limpetCorner = cove(
        id: "limpet-corner",
        name: "Limpet Corner",
        fenceBudget: 11,
        twoStarScore: 19,
        threeStarScore: 38,
        maximumScore: 40,
        question: .corner,
        map: """
            ...........
            ...........
            ...........
            ~..a...a...
            ~..........
            ~..........
            ~~.........
            .~~.....~~~
            ..~~....~~~
            ...~~P..~~~
            ....~...~~~
            """
    )

    /// The ledge, with a coast on both sides of it: the sea across the whole north but for a corner,
    /// the sound across the whole south, and thirty-five tiles of waterline between them — more than
    /// any other board in the cove has. And a run of five urchins standing in the north-west, four in
    /// a line down a column and one turned out of it.
    ///
    /// The obstruction question, and the widest gap any field in the game leaves at 58%, two points
    /// past Starwell Ring and The Rigging. An urchin takes no fencing and no pen may lean on one, so
    /// the run is a length of ground no wall may cross — and it is pegged exactly where the two
    /// coasts come closest, which is where a wall would have gone. Twelve pieces squared off between
    /// the two seas get their north wall and their south wall for nothing and hold 18 tiles: two
    /// paid sides, standing clear of the urchins in the west and stopping short of the dry corner in
    /// the north-east, because a rectangle that took the corner would have to buy a north wall too.
    ///
    /// The same twelve run round the whole ledge instead. Three of them cut the north-west corner on
    /// the diagonal, skirting the run of urchins tile by tile; the other nine take the western rim
    /// below it, the north-east corner and the eastern rim. 43 tiles, and nothing lying on any of
    /// them.
    ///
    /// What those three pieces are really doing is plugging a hole, and it is the one thing on the
    /// board a player has to see. A wall may not stand on an urchin, but nothing stops the pig
    /// *walking* over one — and this run climbs a column from the middle of the ledge to the northern
    /// rim, so it is four urchins and a step off the map. The diagonal seals that ladder at its foot
    /// and at its shoulder, and the tile it picks up west of the seal comes free with the sealing:
    /// one square of ledge with the sea above it and a post either side.
    ///
    /// Two clams lie across the sound, on the strip the tide cut off in the south. The second board
    /// in the world to put five points where she cannot walk.
    static let urchinLedge = cove(
        id: "urchin-ledge",
        name: "Urchin Ledge",
        fenceBudget: 12,
        twoStarScore: 18,
        threeStarScore: 40,
        maximumScore: 43,
        question: .obstruction,
        map: """
            ~~x~~~~~...
            ~~x~~~~~...
            ~~xx..P....
            ~~x........
            ...........
            ...........
            ...........
            ~..........
            ~~~~~~~~~~~
            .a......a..
            ...........
            """
    )

    /// The sound: twelve tiles by twelve, the open water across the whole southern side of it and a
    /// wedge of it in the north-west corner. A hundred and two tiles of kelp bed on her side, and
    /// twenty-four on the far shore.
    ///
    /// The broad board stands outside the climb the way Smoulder Ridge and Clocktower Square and
    /// Wide Reaches and the Great Gallery and The Midway and the Great Erg do. A broad board leaves
    /// a wide gap against a squared-off pen because it is broad, which says more about its size than
    /// about how hard it is to hold — and this one asks 42, less than six of the seven fields above
    /// it, while holding the biggest pen in the cove at 51 tiles.
    ///
    /// Fifteen pieces squared off against the sound hold 28 tiles and the two clams lying down at the
    /// water's edge, which is 38. The same fifteen run out as one great wedge — up the western rim,
    /// along the water in the north-west corner and away on the diagonal to the eastern rim — hold
    /// 51 tiles, the same two clams and the one in the north, which is 66.
    ///
    /// And two more clams lie on the far shore, ten points on ground no wall on this board reaches,
    /// which is where the cove says its own idea loudest: the biggest field in the world looks half
    /// again as big as it is.
    static let kelpSound = cove(
        id: "kelp-sound",
        name: "Kelp Sound",
        fenceBudget: 15,
        twoStarScore: 38,
        threeStarScore: 62,
        maximumScore: 66,
        question: .detour,
        map: """
            ~~~.........
            ~~..........
            ~...a.......
            ............
            ............
            ............
            .....P......
            ............
            ..a.....a...
            ~~~~~~~~~~~~
            .....a..a...
            ............
            """
    )

    /// The cove's boss, and the ninth rule the game has: **a crab is at home in the water, so water
    /// will not hold him.**
    ///
    /// Every rule below this one is a refusal. They may not share a pen, they may not be parted, they
    /// may not be housed unequally, one has to be left outside, one has to be ringed, they may not
    /// share a wall — eight worlds of things a board says no to once everything on it is already
    /// stuck. The ninth says no to nothing. It changes what stuck means: the crab is walked over the
    /// board rather than over the mud on it, so every drop of water he can reach is a road, and the
    /// far side of it is the way out.
    ///
    /// Which turns the whole world against itself. Nine fields of coastline have taught that water is
    /// a wall handed over for nothing, and the sound across the south of this board is eleven tiles
    /// of it — every one of them a hole. Cork him in a bay and he is gone, and the field draws him
    /// going: the escape route runs out over the water, so the board says why without a word.
    ///
    /// He stands beside the other half of it. The tide left a pool of four tiles inland, stepped on
    /// the diagonal, and any wall that holds him has to go round the outside of it — dead ground the
    /// budget buys and the score does not count. It is the exact inverse of every other piece of
    /// water in the game.
    ///
    /// So the answer is one closed ring with every piece of it bought, and it is the only pen in the
    /// cove that leans on nothing at all. Twenty-two pieces run as a lozenge round the middle of the
    /// flats hold the pig, the crab, his pool and 41 tiles of ground, with the clam south-west of him
    /// inside it and the one at her own shoulder under a post: 46. Twenty-two is the biggest budget
    /// in the game, and only The Centre Ring has handed one out before — it has to be, because on
    /// this board a budget is all there is.
    ///
    /// Squaring the map off means something new here as well. The cheapest legal pair is four pieces
    /// round the pig where she stands, holding her one tile, and the other eighteen laid *over* the
    /// pool as a rectangle for the crab: 16 tiles of mud, four of water that pay nothing, 17 between
    /// the pair of them. Every other block in the game leans on water. This is the one that has to
    /// cover it, because a block on the coast holds nothing that swims.
    ///
    /// At 63% it is the widest gap any board in the game leaves, a point past Scorpion Flats.
    ///
    /// The two clams across the sound are the cove's joke told for the last time and to the wrong
    /// animal. Four boards in the world peg a clam on ground she cannot reach, and on the other three
    /// it is out of everything's reach as well. Here it is not: the crab walks to them, so a player
    /// who sees him get there has already lost.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since the thicket
    /// has.
    static let hermitPool = cove(
        id: "hermit-pool",
        name: "Hermit Pool",
        fenceBudget: 22,
        twoStarScore: 17,
        threeStarScore: 43,
        maximumScore: 46,
        question: .swim,
        map: """
            ...........
            ..a........
            ..P........
            ...........
            ......~~...
            ......C~~..
            ...........
            ...a.......
            ...........
            ~~~~~~~~~~~
            ....a..a...
            ...........
            """
    )
}

/// Builds a cove level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall`, the
/// caverns' `gloamdeep`, the carnival's `carnival` and the dunes' `dunes` do — a malformed map here
/// is a mistake in the source, not anything a player could bring about, and its `maximumScore` comes
/// from `Tools/level_search.py` like every other in the game.
private func cove(
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
    /// Tidepool Cove: nine fields the tide has cut into pieces, ending on a crab who treats the sea
    /// as a road and a toll of most of the stars below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the pen a
    /// player gets by squaring the map off — and it climbs the whole way from Cockle Bank to Urchin
    /// Ledge, the way Emberpeak climbs to Crater Pools, the city to Foundry Corner, the reaches to
    /// Starwell Ring, the caverns to Boulder Chamber, the carnival to The Rigging and the dunes to
    /// Scarp Corner.
    ///
    /// The Long Strand stands fourth rather than second because of that order and not in spite of it.
    /// It is the plainest board in the world — a straight sea down one side, an inlet down the other and open ground between — and
    /// the coasts out here are long enough that choosing which stretch of one to take turns out to
    /// ask more than either the basin or the span, both of which come down to a handful of pieces in
    /// the right place.
    ///
    /// The last two stops step out of the order the way every world's do: Kelp Sound is the broadest
    /// board in the cove and holds the biggest pen in it, and Hermit Pool is a boss, and neither is
    /// measured by the same yardstick as a field with one animal and one wall to shape.
    static let tidepoolCove = WorldMap(
        name: "Tidepool Cove",
        nodes: [
            WorldNode(level: .cockleBank, across: 0.28, up: 0.00),
            WorldNode(level: .ebbNeck, across: 0.72, up: 1.04),
            WorldNode(level: .barnacleGut, across: 0.24, up: 2.00),
            WorldNode(level: .theLongStrand, across: 0.70, up: 3.06),
            WorldNode(level: .theMusselBeds, across: 0.26, up: 4.02),
            WorldNode(level: .limpetCorner, across: 0.74, up: 5.00),
            WorldNode(level: .urchinLedge, across: 0.30, up: 6.04),
            WorldNode(level: .kelpSound, across: 0.76, up: 7.02),
            WorldNode(level: .hermitPool, across: 0.22, up: 8.04, starToll: 21)
        ]
    )
}
