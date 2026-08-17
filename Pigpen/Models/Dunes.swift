import Foundation

/// The eighth world's levels and the trail that strings them together.
///
/// Sunbaked Dunes is the meadow's game on sand: fence in the pig, the biggest pen the pieces will
/// reach round, shut or it is no pen at all. The windfall here is a **melon** lying where it fell in
/// the sand and the hazard a **cactus** rooted in it, and each is worth exactly what its meadow twin
/// was — a melon five tiles to shut in, a cactus five to shut in with and no fencing at all, since
/// there is no room beside a cactus for a post of yours — so the same solver that authored the seven
/// worlds below these authored them, with `a` standing in for the melon and `x` for the cactus.
///
/// What the water is here is **a dune**: sand too steep to climb and too loose to hold a post, so it
/// stops a pig and a fence exactly as a river does. And the world's own idea is the shape of it —
/// **every dune is a crescent.** A barchan: a straight back with a horn trailing off each end, one
/// tile thick, so the sand comes back on itself. A meadow has meres, a thicket pools, a mountain
/// tarns, a city canals in straight runs, the reaches a scatter of single drops, the caverns one
/// stepped river and the carnival filled blocks with never a bend in them; here there is nothing but
/// bends. `DunesTests` pins it, and pins the other half of it too — every crescent on a board opens
/// the same way, because barchans are made by a wind and a wind blows one way across a field.
///
/// Which is new in what it **offers** rather than in what it forbids. Every world below hands a pen
/// one wall to follow, or two meeting at a corner, and the player draws the rest. A crescent hands
/// over a finished pen: three sides free, and a mouth to plug that is shorter than the back it hangs
/// off. It is the cheapest pen in the game.
///
/// And it is a trap, which is the whole world. The belly of a dune is rectangle-shaped, so it is
/// exactly what squaring a board off finds — and it is small, and it cannot be made bigger, because
/// the sand is where it is. So the question every field here asks is *is the free pen worth having*,
/// and the answer is almost always no. The shade under the dune is free, and it is not enough.
/// Slipface Hollow says it on the first board by standing a cactus in each end of the shade.
///
/// One field has no dune on it anywhere, the way The Blind Grike has no river: The Hardpan, the
/// ground the sand never reached, where every tile of the pen is bought.
///
/// The dunes floor at 38% against the carnival's 37 — the highest floor in the game — on boards
/// where the free pen has to be turned down before anything else can be worked out.
extension PuzzleLevel {
    /// One wide, shallow barchan across the north of the hollow with a cactus standing in each end
    /// of its shade, and the pig out on the sand below its mouth.
    ///
    /// The basin question, asked on the only kind of bank this world has — and asked as a refusal,
    /// which is how the dunes introduce themselves. The shade under the back is a finished pen: six
    /// tiles with sand on three sides of them and a six-tile mouth to plug. It is also where both
    /// cacti are, so six pieces buy six tiles and minus ten points — and the pig is out on the sand
    /// below in any case. A player who takes the gift the sand is holding out has been given nothing.
    ///
    /// So the answer is the shade *and* everything under it. The best rectangle fourteen pieces can
    /// square off is the belly plus three rows below it — thirty tiles with the pair of cacti in
    /// them, which is 20. The same fourteen hung as a lozenge from the horns and tapered to a point
    /// in the south hold 43 tiles and the same pair, which is 33.
    ///
    /// Both melons lie where fourteen pieces do not go: one on the far side of the back, and one a
    /// tile past the tip of the lozenge. Not everything in a desert is worth walking to.
    ///
    /// It opens the world the way Coconut Shy opened the carnival, and asks more than that did —
    /// 39 against 37 — because a player standing here has held seven worlds of pens, and the first
    /// thing this one does is offer a free one and mean it as a question.
    static let slipfaceHollow = dunes(
        id: "slipface-hollow",
        name: "Slipface Hollow",
        fenceBudget: 14,
        twoStarScore: 19,
        threeStarScore: 31,
        maximumScore: 33,
        question: .basin,
        map: """
            ....a......
            .~~~~~~~~..
            .~x....x~..
            ...........
            ....P......
            ...........
            ...........
            ...........
            ...........
            .......a...
            ...........
            """
    )

    /// Three barchans marching away south-east down the slack with their backs turned, and a
    /// gangway on the diagonal between every pair of them.
    ///
    /// Which is the shore question asked on a bank that is not one bank but three, set on the slant
    /// — Sideshow Row's lesson with horns on it. Fourteen pieces squared off beside the rank can get
    /// one side against one dune and hold 19. The same fourteen laid as a staircase that mirrors the
    /// rank back at itself, cutting each gangway on the diagonal, shut 28 tiles and the melon in the
    /// south with them, which is 33 — because a diagonal wall closes two tiles a piece where a
    /// straight one closes one, and a rank of dunes set out on the slant is how the sand says so.
    ///
    /// The pair of cacti is pegged against the western rim right where the pig stands, and the
    /// answer walls in beside them rather than swallowing them: the staircase comes down between her
    /// and the pair, and their ten points stay outside. The second melon is a row further south
    /// again, outside everything.
    static let theLongSlack = dunes(
        id: "the-long-slack",
        name: "The Long Slack",
        fenceBudget: 14,
        twoStarScore: 19,
        threeStarScore: 31,
        maximumScore: 33,
        question: .shore,
        map: """
            ~.~........
            ~~~........
            ...........
            ....~.~....
            ....~~~....
            ...........
            x.P.....~.~
            x.......~~~
            ...........
            .......a...
            ....a......
            """
    )

    /// One ridge of sand the whole width of the board — two barchans back to back, horns standing up
    /// out of it — with a single dry tile blown through the middle where the wind got round.
    ///
    /// So this is Otter Ford's lesson and Lock Gate's and The Turnstile's, taught on fifteen tiles of
    /// sand: put a piece in the blowout and the whole ridge is the north wall of one pen. Everybody
    /// finds that piece, and the block this field is measured against spends it too — it hangs a four
    /// by four under the gap, which with the two tiles of the blowout itself comes to 18. What the
    /// rectangle cannot then do is use the rest of the ridge, because a rectangle only has one north
    /// side. The same thirteen pieces run out under the whole length of the sand and closed as a
    /// lozenge hold 32 tiles.
    ///
    /// The melon north of the ridge is on the far side of the sand, and like every far bank in the
    /// game nothing reaches it. The one in the south-east is three tiles outside the lozenge, in the
    /// corner the taper leaves behind, which is the cheaper lesson of the two: a melon is five points
    /// and the wall that fetches it is four pieces of shape.
    static let theBlowout = dunes(
        id: "the-blowout",
        name: "The Blowout",
        fenceBudget: 13,
        twoStarScore: 18,
        threeStarScore: 30,
        maximumScore: 32,
        question: .gap,
        map: """
            ............
            .....a......
            ............
            ~...~.~....~
            ~~~~~.~~~~~~
            ............
            ............
            ............
            .....P......
            ............
            .........a..
            ............
            """
    )

    /// The ground the sand never reached: bare hardpan eleven tiles in every direction, no dune
    /// anywhere on it, and the biggest budget of any field in the world laid out across it.
    ///
    /// It is The Blind Grike again, and Basalt Flats and Cobble Yard and Swept Flat before it, and
    /// the answer is the answer it always was: the best block twenty-one pieces can square off is a
    /// five by five holding 25, and the same twenty-one run round as a diamond hold 45. A diagonal
    /// wall shuts two tiles per piece where a straight one shuts one, and on ground with nothing on
    /// it there is nothing else to know — which is why the hardpan is the one field here that a
    /// player has met before, and why it stands in the middle of the trail rather than at the start
    /// of it.
    ///
    /// A melon lies at each end of the southern edge, and twenty-one pieces will not reach either.
    /// On ground with no free wall on it five points is four pieces of fence, and four pieces of
    /// diamond are eight tiles.
    static let theHardpan = dunes(
        id: "the-hardpan",
        name: "The Hardpan",
        fenceBudget: 21,
        twoStarScore: 25,
        threeStarScore: 42,
        maximumScore: 45,
        question: .bare,
        map: """
            ...........
            ...........
            ...........
            ...........
            ...........
            .....P.....
            ...........
            ...........
            ...........
            ...........
            .a.......a.
            """
    )

    /// Two barchans set on the diagonal from one another — one in the north-west, one in the
    /// south-east, both with their mouths open to the south — and the pig on the open sand between
    /// them.
    ///
    /// The span question: neither dune is any use on its own, and no rectangle on this board reaches
    /// round both, so squaring off gets one corner against each of them across the middle and holds
    /// 29 — 29 tiles with both melons and both cacti in them, paying each other back exactly.
    /// Eighteen pieces run out as a great lozenge from one to the other hold 50 tiles and that same
    /// pair of each, so the pen is worth its ground and no more. It takes the northern dune's shade inside and leaves the southern one's out, which is the
    /// board's own answer to the question it asks.
    ///
    /// The run of cactus is pegged directly north of the pig, which is the one thing that stops the
    /// lozenge being tidier than it is: no piece will stand on a cactus and no pen may lean on one,
    /// so the wall that comes down between the two horns has to come round the pair.
    static let twoHorns = dunes(
        id: "two-horns",
        name: "Two Horns",
        fenceBudget: 18,
        twoStarScore: 28,
        threeStarScore: 47,
        maximumScore: 50,
        question: .span,
        map: """
            ...........
            .~~~.......
            .~.~.......
            ...........
            ....xx.....
            .....P.....
            ....a......
            .......~~~.
            .......~.~.
            .....a.....
            ...........
            """
    )

    /// One barchan with its back to the east and its mouth open west, three melons lying out past
    /// where the tidy wall goes, and a run of cactus pegged along the line the tidy wall would take.
    ///
    /// The best block seventeen pieces can square off against that back holds 24 tiles, the melon in
    /// the south and both cacti, which is 19. So the whole field is which melons to go out for, and
    /// the answer is the other two: seventeen pieces run out as a lozenge that reaches the one in the
    /// north and the one out east hold 35 tiles and the same pair of cacti, which is 35.
    ///
    /// It gives up the melon the tidy block was already holding, and leaves it standing outside the
    /// wall rather than under it — no piece will lie on a melon — which is the plainest way any board
    /// in the game has said that five points is worth less than a tile of shape.
    ///
    /// The run of cactus lies square in the middle of the ground the crescent encloses, so there is no
    /// drawing this pen without swallowing the pair and paying their ten. The tiles the detour fetches
    /// cover it twice over.
    ///
    /// It is the hardest of the seven ordinary fields but one, and the hardest detour in the game.
    static let melonGround = dunes(
        id: "melon-ground",
        name: "Melon Ground",
        fenceBudget: 17,
        twoStarScore: 19,
        threeStarScore: 33,
        maximumScore: 35,
        question: .detour,
        map: """
            ...........
            ...........
            .......a...
            .~~~.....a.
            ...~.......
            .~~~.......
            ....P......
            ...xx......
            ...........
            ......a....
            ...........
            """
    )

    /// The scarp: one great barchan hooked into the north-west of the board so its back runs nearly
    /// the whole width of the north and its western horn stands on the rim. Two sides of a pen handed
    /// over, and eleven pieces — the smallest budget in the world — to draw the rest.
    ///
    /// Which is the corner question with two free sides, the way Rimstone Corner and The Big Top
    /// asked it, and the hardest corner in the game. The right-angled answer is a rectangle hung
    /// under the back with its own east wall paid for: 20 tiles, stopping three columns short of the
    /// eastern horn, because eleven pieces will not reach it and turn the corner as well. The eleven
    /// run instead as one long chevron — out from the western rim, down across the whole mouth of the
    /// crescent and back up to a point in the south — and hold 41 tiles. That is nearly four tiles a
    /// piece, the best rate anywhere in the world, and it is what two free sides and a diagonal are
    /// worth together. It is the top of the world's climb.
    ///
    /// The two melons lie in the south, well outside the chevron on either side of its tip. Eleven
    /// pieces will not stretch to either, and on a board where two of the walls came free five points
    /// is still four pieces of fence.
    static let scarpCorner = dunes(
        id: "scarp-corner",
        name: "Scarp Corner",
        fenceBudget: 11,
        twoStarScore: 20,
        threeStarScore: 39,
        maximumScore: 41,
        question: .corner,
        map: """
            ............
            ~~~~~~~~~~..
            ~........~..
            ~........~..
            ............
            ...P........
            ............
            ............
            ............
            ..a......a..
            ............
            ............
            """
    )

    /// The sand sea: twelve tiles by twelve, two barchans with their backs to the west standing at
    /// opposite ends of it, a run of three cacti across the waist and three melons down the length.
    ///
    /// The erg stands outside the climb the way Smoulder Ridge and Clocktower Square and Wide Reaches
    /// and the Great Gallery and The Midway do. A broad board leaves a wide gap against a squared-off
    /// pen because it is broad, which says more about its size than about how hard it is to hold —
    /// and this one asks 41, less than four of the seven above it, while holding the biggest pen in
    /// the world and the third biggest in the game, behind Wide Reaches and the Great Gallery.
    ///
    /// Nineteen pieces squared off down the middle of the sea from the northern dune's back hold 38
    /// tiles, two of the melons and all three cacti, which comes to 33. The same nineteen run out to
    /// both dunes and closed round the south hold 56 tiles, the third melon as well and the same three
    /// cacti, which is 56. The two melons lying together at the foot of the sea are the reason the
    /// block stops where it does: neither takes a piece, so a wall that wants that row has to come
    /// round the pair of them or take them both in.
    static let theGreatErg = dunes(
        id: "the-great-erg",
        name: "The Great Erg",
        fenceBudget: 19,
        twoStarScore: 32,
        threeStarScore: 53,
        maximumScore: 56,
        question: .detour,
        map: """
            ............
            ..~~~.......
            ..~.....a...
            ..~~~.......
            ...P........
            ............
            ....xxx.....
            .......~~~..
            .......~....
            .......~~~..
            .....aa.....
            ............
            """
    )

    /// The dunes' boss, and the eighth rule the game has: **a scorpion stings through a fence, so
    /// the two pens may not share one.**
    ///
    /// It is the direct inversion of the game's oldest boss lesson. Stag Mere taught that two pens
    /// can share a wall — one boundary doing two jobs — and the search has priced a shared wall at
    /// half ever since; every boss from Boar Hollow to The Center Ring is built on that discount.
    /// This one takes it away. The pig may not be standing in with him, and no piece of fence may
    /// have her ground on one side of it and his on the other, so the ground between the two pens
    /// has to be given up unclaimed and one budget has to pay for two whole walls.
    ///
    /// He is standing in the shade of a barchan three tiles wide, which is what makes the board
    /// answerable and what makes it hard at the same time. Three of his walls are free and one piece
    /// shuts him in — the cheapest pen in the game — and that one piece is a piece she may not use,
    /// so the three tiles of sand round it are ground she may not have either. Her wall has to come
    /// past the notch and close behind it, giving it a berth, which is a thing no rectangle can do.
    ///
    /// So the answer five worlds have taught is turned down twice over. One pen round the pair of
    /// them wins Stag Mere and Rat King Wharf, and nine pieces do it here with seven of the budget
    /// unspent; the board sends it back. And so does the answer below with a single piece moved a
    /// single tile — run the wall straight up to his own south wall instead of stopping short and
    /// closing behind it, and every piece still holds, nothing is loose, the pig has one tile *more*
    /// than she has in the answer, and it would score 51. One piece of fence then has her ground on
    /// one side of it and his on the other, which is a wall the sting goes straight through.
    ///
    /// Sixteen pieces is the smallest budget any boss in the game hands out. The cheapest legal pair
    /// it buys is the tidy pair of pens side by side: four pieces box the pig where she stands on one
    /// tile, and the rest wall the open sand east of the notch as the scorpion's own yard with the
    /// melon inside it — 14 tiles and that melon, which is 19. A fair answer, and one nobody has to
    /// be taught. The same sixteen run out from the pig up the west of the flats, along under the
    /// great back in the north and down round the far side of the notch hold 45 tiles and the melon
    /// in the north-east, which is 50 — the biggest pen any boss holds, and at 62% the widest gap
    /// any board in the game leaves.
    ///
    /// The melon left lying in the lane is the board saying what the rule costs. In the answer it
    /// sits in the clear ground between the two pens, so this is the only pen in the game that walks
    /// past five points it can see and leaves them where they are.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since the thicket
    /// has.
    static let scorpionFlats = dunes(
        id: "scorpion-flats",
        name: "Scorpion Flats",
        fenceBudget: 16,
        twoStarScore: 19,
        threeStarScore: 47,
        maximumScore: 50,
        question: .berth,
        map: """
            ...........
            .~~~~~~~~~.
            .~.......~.
            .........a.
            ...........
            ...........
            ....~~~....
            ....~S~....
            ...........
            ..P..a.....
            ...........
            """
    )
}

/// Builds a dunes level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall`, the
/// caverns' `gloamdeep` and the carnival's `carnival` do — a malformed map here is a mistake in the
/// source, not anything a player could bring about, and its `maximumScore` comes from
/// `Tools/level_search.py` like every other in the game.
private func dunes(
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
    /// Sunbaked Dunes: nine fields with nothing but crescents of sand on them, ending on a scorpion
    /// who will not have a wall of his shared with anybody and a toll of most of the stars below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the pen a
    /// player gets by squaring the map off — and it climbs the whole way from Slipface Hollow to
    /// Scarp Corner, the way Emberpeak climbs to Crater Pools, the city to Foundry Corner, the
    /// reaches to Starwell Ring, the caverns to Boulder Chamber and the carnival to The Rigging.
    ///
    /// The Hardpan stands fourth rather than third because of that order and not in spite of it: it
    /// is the one field here with no sand on it, so it is the one field a player has met before, and
    /// a diamond on bare ground turns out to ask more than a ridge with a hole blown through it.
    ///
    /// The last two stops step out of the order for the same reason every world's do: the Great Erg is
    /// the broadest board out here and holds the second biggest pen in the game, and Scorpion Flats is
    /// a boss, and neither is measured by the same yardstick as a field with one animal and one wall
    /// to shape.
    static let sunbakedDunes = WorldMap(
        name: "Sunbaked Dunes",
        nodes: [
            WorldNode(level: .slipfaceHollow, across: 0.26, up: 0.00),
            WorldNode(level: .theLongSlack, across: 0.74, up: 1.06),
            WorldNode(level: .twoHorns, across: 0.28, up: 2.02),
            WorldNode(level: .theBlowout, across: 0.72, up: 3.04),
            WorldNode(level: .theHardpan, across: 0.22, up: 4.00),
            WorldNode(level: .melonGround, across: 0.70, up: 5.06),
            WorldNode(level: .scarpCorner, across: 0.30, up: 6.02),
            WorldNode(level: .theGreatErg, across: 0.76, up: 7.04),
            WorldNode(level: .scorpionFlats, across: 0.24, up: 8.02, starToll: 21)
        ]
    )
}
