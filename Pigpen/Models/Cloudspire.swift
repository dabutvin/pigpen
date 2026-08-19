import Foundation

/// The twelfth world's levels and the trail that strings them together — the last trail
/// there is.
///
/// Cloudspire Heights is the meadow's game played above the weather: fence in the pig, the
/// biggest pen the pieces will reach round, shut or it is no pen at all. The windfall here is
/// a **balloon** that slipped a child's fist at the carnival five worlds below and has been
/// climbing ever since, and the hazard a **whirlwind** worrying at the turf — and each is
/// worth exactly what its meadow twin was, a balloon five tiles to shut in, a whirlwind five
/// to shut in with and no fencing at all, since a balloon is tethered by nothing but its
/// string and no post stands in a wind that never stops turning. So the same solver that
/// authored the eleven worlds below these authored them, with `a` standing in for the balloon
/// and `x` for the whirlwind.
///
/// What the water is here is **not water at all**: it is open sky between the fields, and a
/// long way down. It stops a pig and a fence exactly as a river does, which is all the board
/// ever asks of it. And the world's own idea is the shape of it — **one sky.** Every board's
/// sky is a single body, it laps all four rims of the map, and somewhere it is open enough to
/// hold a two-by-two of nothing but air: the meadow has meres, the fen closed braids that
/// never ran two tiles deep, and up here the water is the one sky everything hangs in, which
/// `CloudspireTests` pins — one body, all four rims, a two-by-two of open air, on every wet
/// board in the world.
///
/// Which hands over walls the way every wet world has — a field's sky-hung banks are free
/// fencing — and keeps something back the way the fen did: **the far fields.** An island the
/// pig's ground never touches is ground nothing can ever walk to, so a balloon adrift on one
/// is the fen's bar-berries said in this world's grammar: in plain sight, five points, and
/// nobody's. Seven of the nine boards float at least one.
///
/// One field has no sky on it anywhere, the way The Turbary has no channel: The Long Way
/// Down, the one field back on the ground, where every tile of the pen is bought.
///
/// The heights floor at 43 against the fen's 42 — the highest floor in the game — on boards
/// where the free wall is everywhere and the whirlwinds are staked exactly where the tidy
/// answers want to stand.
extension PuzzleLevel {
    /// A crown of open sky rings the top of the board — a one-balloon islet adrift in it,
    /// the crown's jewel and nobody's — and the hollow sits inside the crown with the pig at
    /// its heart, opening south into a broad field hung on the west and south rims.
    ///
    /// The basin question, asked at altitude: the hollow's flanks are free sky wall, and
    /// everything turns on where the south line is drawn. A whirlwind tower staked at the
    /// rim kills every tidy rectangle that wants a south wall through its column, and a
    /// third whirlwind sits exactly on the straight row the block wants, so the block
    /// swallows it and stops at 24. The best pen takes the hollow, the field's top rows, and
    /// pockets down both sides of the dead column to swallow both balloons: 38 tiles and the
    /// pair, less the swallowed whirlwind, which is 43.
    static let theHollowCrown = cloudspire(
        id: "the-hollow-crown",
        name: "The Hollow Crown",
        fenceBudget: 11,
        twoStarScore: 24,
        threeStarScore: 40,
        maximumScore: 43,
        question: .basin,
        map: """
            ~~~~~~~~~~~
            ~~~~a~~~~~~
            ~~~~~~~~~~~
            ~~~~...~~~~
            ~~~.....~~~
            ~~..P...~~~
            ........~..
            ........~..
            ....x...~..
            .a.x..a.~..
            ...x....~..
            """
    )

    /// An L of ground hangs on the north and east rims, and the sky bites into it twice — a
    /// west bay holding a bare pinnacle, and a moated inner pocket holding the second, a
    /// balloon staked on it where nothing will ever walk.
    ///
    /// The span question: each sky bank is useless alone, and the one pen worth having is
    /// thrown between them — a diamond leaning the bay's east bank, the pocket's north bank
    /// and the shelf below all at once, its northwest wall one long staircase that swallows
    /// both live balloons on the way down: 20 tiles and the pair, which is 30. A whirlwind
    /// pair staked one above the other kills every rectangle that wants a north wall through
    /// their column, so the tidy block huddles east, swallows the third, and comes to 16.
    static let theTwoPinnacles = cloudspire(
        id: "the-two-pinnacles",
        name: "The Two Pinnacles",
        fenceBudget: 10,
        twoStarScore: 16,
        threeStarScore: 28,
        maximumScore: 30,
        question: .span,
        map: """
            ~~..x......
            ~~..x...a..
            ~~.......a.
            ~~.x.......
            ~~....P....
            ~~~~~......
            ~~~.~.~~~..
            ~~~~~.~a~..
            ~~~~~.~~~..
            ~~~~~~~~~~~
            ~~~~~~~~~~~
            """
    )

    /// No sky at all: the one field down on the ground, under the spires rather than on
    /// them, and the biggest budget in the world laid out across it.
    ///
    /// It is The Turbary again, and The Whiteout and The High Strand before it, and the
    /// answer is the answer it always was — with two balloons to bend it and two whirlwinds
    /// staked exactly on the natural diamond's rim. The best pen is a long diamond bent to
    /// keep both whirlwinds out and both balloons in, 41 tiles and the pair for 51; the
    /// block nudges out over one balloon, must swallow a whirlwind doing it, and comes to
    /// 27. The long way down to the west balloon is the whole game.
    static let theLongWayDown = cloudspire(
        id: "the-long-way-down",
        name: "The Long Way Down",
        fenceBudget: 21,
        twoStarScore: 27,
        threeStarScore: 48,
        maximumScore: 51,
        question: .bare,
        map: """
            ............
            ............
            ............
            ..x.........
            ............
            .a......P...
            ............
            ............
            .....a..x...
            ............
            ............
            """
    )

    /// The rope bridge itself: the pig's island floats in open sky, and one two-tile
    /// causeway is the only way down to the delta hung on the west and south rims. Across
    /// the last gap, a balloon glitters on a dead strip nothing will ever walk to.
    ///
    /// The gap question: one piece at the causeway's neck seals the island for almost
    /// nothing, and that is the cheap answer — the block is exactly that, island and neck
    /// and one field row, 24. The best pen crosses the bridge and fans over the whole
    /// delta, notching around the whirlwind tower that kills every rectangle's deep south
    /// wall, and swallows both live balloons: 37 tiles and the pair, which is 47.
    static let theRopeBridge = cloudspire(
        id: "the-rope-bridge",
        name: "The Rope Bridge",
        fenceBudget: 12,
        twoStarScore: 24,
        threeStarScore: 44,
        maximumScore: 47,
        question: .gap,
        map: """
            ~~~~~~~~~~~~
            ~~~...~~~~~~
            ~~~....~~~~~
            ~~~.P..~~~~~
            ~~~....~~~~~
            ~~~~.~~~~~~~
            ~~~~.~~~~~~~
            .x........~.
            ..........~a
            ..a..x..a.~.
            .....x....~.
            """
    )

    /// One long cloudbank and nothing else: two rows of sky across the whole north, its
    /// underside broken by two mud bumps — free tiles for any pen that leans the bank, and
    /// the tell for which stretch of it to take. Across the fjord, a balloon rides a dead
    /// limb the size of a small field.
    ///
    /// The shore question, on the longest bank the heights have: whirlwind pairs staked at
    /// the west and south pin every tidy rectangle to the middle of the field, so the block
    /// stops at 26 and reaches no balloon at all. The best pen takes the whole bank
    /// frontage, both bumps, and runs deep down both sides of the dead notch for the pair
    /// of live balloons: 41 tiles and the pair, which is 51.
    static let theCloudbank = cloudspire(
        id: "the-cloudbank",
        name: "The Cloudbank",
        fenceBudget: 13,
        twoStarScore: 26,
        threeStarScore: 48,
        maximumScore: 51,
        question: .shore,
        map: """
            ~~~~~~~~~~~
            ~~~.~.~~~~~
            .......~...
            .......~...
            ....P..~...
            xx.....~.a.
            .......~...
            .......~...
            .......~...
            ..a.x.a~...
            ....x..~...
            """
    )

    /// Balloons hung wide of every tidy line — and two of them hung where no line will ever
    /// reach, adrift on dead islets in the great southwest sky: the lost balloons the board
    /// is named for.
    ///
    /// The detour question, teased four ways: a whirlwind pair kills every rectangle whose
    /// north wall crosses their column, so the tidy box keeps west at 20. The best pen bows —
    /// it takes the whole west and centre, notches around the dead column, and stretches its
    /// east wall down the rim to swallow the high balloon, 36 tiles and the one, which is 41 —
    /// while the deep balloon hangs one detour too far and is refused. One bowed for, one
    /// refused, two lost for good.
    static let theLostBalloons = cloudspire(
        id: "the-lost-balloons",
        name: "The Lost Balloons",
        fenceBudget: 11,
        twoStarScore: 20,
        threeStarScore: 39,
        maximumScore: 41,
        question: .detour,
        map: """
            ~~~....x...
            ~~~....x.a.
            ~~~..P.....
            ~~~........
            ~~~........
            ~~~........
            ~~~.....a..
            ~~~~~~~~~~~
            ~a~~~~~~~~~
            ~~~~~a~~~~~
            ~~~~~~~~~~~
            """
    )

    /// The windward corner: sky two deep along the whole north and west — a balloon riding
    /// the very corner of the world, nobody's — and the field hung on the east and south
    /// rims, a right angle of free bank meeting high in the quadrant.
    ///
    /// Which is the corner question the way Scarp Corner, Barnacle Corner and Heron Corner
    /// asked it, at full stretch: the right angle boxes a strip, swallows both whirlwinds and
    /// reaches one balloon for 20, where one grand diagonal — ten fences corner to corner, the
    /// largest single wall on any ordinary field in the game — leans both banks at once,
    /// swallows the same two whirlwinds and takes BOTH live balloons, holding 45 tiles for 45.
    /// At 55 it is the hardest ordinary field in the heights, and in the game the Whiskers
    /// alone ask more.
    ///
    /// The two live balloons are set one straight out along the pig's row and one straight down
    /// her column, each with a whirlwind between her and it, so neither is had for nothing —
    /// and the corner balloon stays exactly where it was, riding the tile no pen will ever
    /// hold. A tease is worth having when the board also pays out; it is only scenery when
    /// nothing on the board can be won.
    static let windwardCorner = cloudspire(
        id: "windward-corner",
        name: "Windward Corner",
        fenceBudget: 10,
        twoStarScore: 20,
        threeStarScore: 42,
        maximumScore: 45,
        question: .corner,
        map: """
            a~~~~~~~~~~
            ~~~~~~~~~.~
            ~~~........
            ~~.........
            ~~..P.x.a..
            ~~.........
            ~~..x......
            ~~.........
            ~~..a......
            ~..........
            ~~.........
            ~~.........
            """
    )

    /// The airiest, widest board in the world, and the biggest pen in it: a three-row bank
    /// of open sky over a ten-wide field, the sky returning down a two-wide east channel, a
    /// balloon adrift on a dead islet mid-bank.
    ///
    /// The Open Sky stands outside the climb the way The Great Slough and The Great Floe do.
    /// Two gust-lines of whirlwinds rake the field — a triple across the west, a triple up
    /// the south — each one killing every straight wall through its line, so the tidy block
    /// retreats east of both and squares off 30. The best pen leans the whole bank and the
    /// east channel, wraps around the dead column, and swallows the far balloon: 51 tiles —
    /// the biggest pen in the world, six over the boss's — and the one balloon, which is 56.
    static let theOpenSky = cloudspire(
        id: "the-open-sky",
        name: "The Open Sky",
        fenceBudget: 14,
        twoStarScore: 30,
        threeStarScore: 53,
        maximumScore: 56,
        question: .shore,
        map: """
            ~~~~~~~~~~~~
            ~~~~~a~~~~~~
            ~~~~~~~~~~~~
            ..........~~
            ..........~~
            ....P.....~~
            xxx.......~~
            ..........~~
            ..........~~
            ....x.....~~
            ....x...a.~~
            ....x.....~~
            """
    )

    /// The heights' boss, the twelfth rule the game has, and the last: **only the pig is
    /// held and the eagle is left outside, his perch a hole in the wall's way — and no tile
    /// of her pen may stand in his line of sight, which runs four ways from his perch,
    /// straight along his row and his column, over mud and sky alike. Only a fence breaks
    /// it.**
    ///
    /// Every boss before him cared where the pens were; the eagle cares what he can see,
    /// which turns a fence into a second tool. His perch is a pinnacle ringed by sky, so no
    /// wall can ever stand beside him — but two stepping-stone islets sit in his west and
    /// south rays, and a piece planted on either stands alone in the open sky, no pen
    /// anywhere near it, doing nothing but putting out an eye. No other board in the game
    /// has a use for such a piece.
    ///
    /// The answers eleven worlds have taught are turned down one after the other. Lean the
    /// neck of the north approach on its free sky wall and the board sends it back: those
    /// tiles stand in his west ray, spotted. Take the east fields without blinding his south
    /// ray and the causeway is spotted the same way. The tidy answer that satisfies the rule
    /// hides in the pocket below the neck, out of both rays, and squares off 15. The same
    /// ten pieces put out three eyes instead — one wall fenced across his north ray, lone
    /// pieces on both stepping stones — and take every tile the pig can walk to: 45 tiles,
    /// five balloons, and the whirlwind on the causeway swallowed on the way east, which is
    /// 65. At 76 it is the widest gap any board in the game leaves, past even The Wallow's
    /// 72. The balloon adrift by the crown of the map stays where it is: up here even the
    /// eagle keeps a tease.
    ///
    /// It asks for 21 of the 24 stars below it before it opens, the way every boss since
    /// the thicket has.
    static let theEyrie = cloudspire(
        id: "the-eyrie",
        name: "The Eyrie",
        fenceBudget: 10,
        twoStarScore: 15,
        threeStarScore: 61,
        maximumScore: 65,
        question: .stoop,
        map: """
            ~~~~~~~~~~~~
            ~a.....~~~a~
            ~.a....~~~~~
            ~.~~~~~~~~~~
            ~..~~~~~~~~~
            ~..~.~E~~~~~
            ~..~~~~~~~~~
            ~....~.~..a.
            ~.P..~~~.a..
            ~......x.a..
            ~~~~~~~~....
            ~~~~~~~~....
            """
    )
}

/// Builds a heights level from an ASCII map, the same way the meadow's `authored`, the
/// thicket's `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches'
/// `starfall`, the caverns' `gloamdeep`, the carnival's `carnival`, the dunes' `dunes`, the
/// cove's `tidepool`, the tundra's `frostwhisker` and the fen's `mirebog` do — a malformed
/// map here is a mistake in the source, not anything a player could bring about, and its
/// `maximumScore` comes from `Tools/level_search.py` like every other in the game.
private func cloudspire(
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
    /// Cloudspire Heights: nine fields hanging in one sky, ending on an eagle whose gaze has
    /// to be fenced out of and a toll of most of the stars below him — the last trail in the
    /// game.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and
    /// the pen a player gets by squaring the map off — and it climbs the whole way from The
    /// Hollow Crown to Windward Corner, the way the fen climbs to Heron Corner and the
    /// tundra to The Whiskers.
    ///
    /// The Long Way Down stands third because of that order and not in spite of it: it is
    /// the one field up here with no sky on it, so it is the one field a player has met
    /// before, and a diamond on bare ground turns out to ask more than two pinnacles a span
    /// apart.
    ///
    /// The last two stops step out of the order for the same reason every world's do: The
    /// Open Sky is the broadest board in the heights and holds the biggest pen in it, and
    /// The Eyrie is a boss, and neither is measured by the same yardstick as a field with
    /// one animal and one wall to shape.
    static let cloudspireHeights = WorldMap(
        name: "Cloudspire Heights",
        nodes: [
            WorldNode(level: .theHollowCrown, across: 0.26, up: 0.00),
            WorldNode(level: .theTwoPinnacles, across: 0.74, up: 1.02),
            WorldNode(level: .theLongWayDown, across: 0.24, up: 2.04),
            WorldNode(level: .theRopeBridge, across: 0.72, up: 3.00),
            WorldNode(level: .theCloudbank, across: 0.30, up: 4.04),
            WorldNode(level: .theLostBalloons, across: 0.68, up: 5.02),
            WorldNode(level: .windwardCorner, across: 0.26, up: 6.00),
            WorldNode(level: .theOpenSky, across: 0.74, up: 7.04),
            WorldNode(level: .theEyrie, across: 0.30, up: 8.02, starToll: 21)
        ]
    )
}
