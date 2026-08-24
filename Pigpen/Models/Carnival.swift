import Foundation

/// The seventh world's levels and the trail that strings them together.
///
/// Lantern Carnival is the meadow's game with a fair put on it: fence in the pig, the biggest pen
/// the pieces will reach round, shut or it is no pen at all. The windfall here is **popcorn**
/// dropped at the concession stand into the sawdust and the hazard a **megaphone** set down
/// where it blares, and each is worth exactly what its meadow twin was — a popcorn five tiles to
/// shut in, a megaphone five to shut in with and no fencing at all, since nobody builds a wall
/// where the noise is worst — so the same solver that authored the six worlds below these
/// authored them, with `a` standing in for the popcorn and `x` for the megaphone.
///
/// What the water is here is **the crowd**, and what the carnival does that no world above it did
/// is stand that crowd in **solid blocks**. A meadow has meres, a thicket pools, a mountain tarns,
/// a city canals, the reaches a scatter of single drops and the caverns one long staircase of a
/// river; on every field here each body of crowd is a filled rectangle of two tiles or more — a
/// stall, a queue, the wall of a tent — and on all but one field there is more than one of them.
/// `CarnivalTests` pins it: no bend on any field, and no single drop either.
///
/// The boss is the one board that steps outside that, and steps outside it deliberately: its crowd
/// is a three by three with the ringmaster standing in the middle of it, so the body that closes
/// round him is a ring of eight rather than a filled block of nine. Eight fields of solid blocks
/// are what make that one shape read as a ring at all.
///
/// Which changes what a wall is for. A river hands a pen one long edge to follow; a block of
/// crowd hands it a short one and then stops, and the ground between two blocks is a **gangway** a
/// single piece closes. So a pen out here is assembled rather than followed — pick which blocks to
/// string together, pay a piece for each gap between them, and the shape that comes out is
/// whatever those blocks happened to leave. It is why the carnival's answers are lopsided where
/// the caverns' were wedges and the reaches' were diamonds.
///
/// The other thing it keeps is **the megaphone row**. Emberpeak staked a flame in all nine of its
/// fields and the caverns hung a diamond in all nine of theirs; there is a row of megaphones on
/// every board here, and a *row* is the point — never one megaphone on its own, always two or more
/// in a straight line. A single hazard is a tile to build around, which every world since the
/// meadow has had. A row of them is a **length of ground no wall may cross**, because a megaphone
/// takes no fence and a pen may not lean on one either. The crowd is a wall the board gives you; a
/// megaphone is a wall the board forbids you, and reading the difference is the world.
///
/// The carnival floors at 37% against the caverns' 34 — the highest floor in the game — on ground
/// where a plain block has to keep a clear tile off every megaphone on the field.
extension PuzzleLevel {
    /// A ring of stalls in a shallow vee, with the gangways between them wide open and the whole
    /// southern side of the board missing. Two popcorns lie out past the arms of it.
    ///
    /// The basin question asked on the only kind of bank the carnival has: not one long shore but
    /// four short ones with gaps between, so following it means paying a piece at each gap and
    /// deciding which of them are worth the piece. Fourteen pieces hung under the vee as a
    /// rectangle hold 18 tiles and neither popcorn, since both are dropped a row below where any
    /// rectangle stops; the same fourteen fitted to the stalls — one in
    /// the gangway at the bottom of the vee, then out east under the arm and tapering back — hold
    /// 24 tiles and the eastern popcorn, which is 29.
    ///
    /// It opens the world the way Sinter Basin opened the caverns, and asks less than that did —
    /// 27 against 34 — because a bank in four pieces has to be read before it can be followed, and
    /// a player standing here has held six worlds of pens.
    static let coconutShy = carnival(
        id: "coconut-shy",
        name: "Coconut Shy",
        fenceBudget: 14,
        twoStarScore: 17,
        threeStarScore: 27,
        maximumScore: 29,
        question: .basin,
        map: """
            ...........
            .~~.....~~.
            ...........
            ...~~.~~...
            ...........
            .....P.....
            ...........
            ...........
            ..a.xx..a..
            ...........
            ...........
            """
    )

    /// A row of sideshows stepping away south-east across the ground, each one its own block of
    /// crowd, with a gangway on the diagonal between every pair of them.
    ///
    /// Which is the shore question asked on a bank that is not a bank at all but four of them in
    /// a line. Fourteen pieces squared off beside the row can only get one of their four sides
    /// against it and hold 24, reaching neither popcorn; the same fourteen laid as a staircase of
    /// their own, mirroring the
    /// row back at itself and cutting each gangway on the diagonal, shut 39 tiles with both popcorns
    /// and both megaphones inside them, which comes back to 39. A diagonal wall closes two tiles a
    /// piece where a straight one closes one, and a row of stalls set out on the slant is how the
    /// carnival says so.
    static let sideshowRow = carnival(
        id: "sideshow-row",
        name: "Sideshow Row",
        fenceBudget: 14,
        twoStarScore: 22,
        threeStarScore: 37,
        maximumScore: 39,
        question: .shore,
        map: """
            ..~~.......
            ..~~.......
            ....~~.....
            ....~~.....
            ......~~...
            ...P..~~...
            ........~~.
            ........~~.
            .a.xx......
            .....a.....
            ...........
            """
    )

    /// The queue for the gate runs the whole width of the fair, and there is one turnstile in it.
    /// Two blocks of crowd, rim to rim, with a single tile of ground between them.
    ///
    /// So this is Otter Ford's lesson and Lock Gate's and Stillwater Neck's, taught on eleven tiles
    /// of free wall that cost nothing: one piece in the turnstile and the whole queue is wall.
    /// Everybody finds that piece — the block this field is measured against spends it too, and
    /// hangs a plain rectangle off it for 21. What the block cannot then do is spread, because the
    /// row of megaphones is set just south-west of the gate and no wall may lie along it — and the
    /// popcorn dropped south-east of the gate is a tile no wall will lie along either, so the
    /// rectangle stops short of it rather than collecting it. The same fourteen pieces opened out
    /// east as a lozenge instead hold 30 tiles and that popcorn, which is 35.
    ///
    /// The popcorn north of the queue is on the far side of the crowd, and like every far bank in
    /// the game nothing reaches it.
    static let theTurnstile = carnival(
        id: "the-turnstile",
        name: "The Turnstile",
        fenceBudget: 14,
        twoStarScore: 20,
        threeStarScore: 33,
        maximumScore: 35,
        question: .gap,
        map: """
            ............
            .....a......
            ............
            ~~~~~.~~~~~~
            ............
            ..xx........
            .....P......
            ............
            ............
            .......a....
            ..a.........
            ............
            """
    )

    /// Two queues standing well apart — one north-west, one south-east — and a row of megaphones set
    /// between them, right where a wall from one to the other would want to lie.
    ///
    /// The span question: neither queue is any use on its own, and no rectangle on this board
    /// reaches both, so squaring off leans on one of them and holds 20. Fifteen pieces run
    /// diagonally from the corner of the near queue to the corner of the far one hold 34 tiles
    /// with both popcorns and both megaphones inside them, which comes back to 34.
    ///
    /// The megaphones are not a choice here, which makes this the only board at the fair where they are
    /// not: the pig stands directly under the pair of them and no piece will stand on a megaphone, so
    /// nothing can be walled between her and them and every pen on this board has them in it. What
    /// the diagonal buys is the second queue — a rectangle leans on one, and only a slanted wall
    /// leans on both — and the two popcorns it collects on the way pay the megaphones back.
    static let ticketLine = carnival(
        id: "ticket-line",
        name: "Ticket Line",
        fenceBudget: 15,
        twoStarScore: 19,
        threeStarScore: 32,
        maximumScore: 34,
        question: .span,
        map: """
            ...........
            ...........
            ..~~.......
            ..~~.......
            ....xx.....
            .....P.....
            ....a......
            ...a...~~..
            .......~~..
            ...........
            ...........
            """
    )

    /// Three popcorns dropped where the tidy pen does not go, and one block of crowd off to
    /// the west doing a third of a wall's work. The best block seventeen pieces can square off
    /// against that crowd holds 17 tiles and the popcorn up in the north, or 22.
    ///
    /// So the whole field is which of the other two to go out for. The one hanging in the south is
    /// three tiles of wall below where the pen would otherwise stop, and three tiles of wall cost
    /// more than five points pay — the row of megaphones is set directly between it and the pig, so
    /// the wall that fetches it has to go round the pair of them as well. The one up in the north
    /// is reached by running the pen up the eastern side of the crowd and closing over the top of
    /// it, which is 28 tiles and two popcorns, or 38.
    static let toffeeStand = carnival(
        id: "toffee-stand",
        name: "The Toffee Stand",
        fenceBudget: 17,
        twoStarScore: 21,
        threeStarScore: 36,
        maximumScore: 38,
        question: .detour,
        map: """
            ...........
            .a.........
            ...........
            .~~~.......
            .~~~.......
            ....P......
            ...........
            ...xx......
            .......a...
            .....a.....
            ...........
            """
    )

    /// The big top takes the length of the west of the fair and the length of its foot — the
    /// crowd runs down the side of it, turns at the corner and goes along the far end — and both
    /// of those are free wall for anybody standing in the sawdust inside them. Two sides handed
    /// over, and eleven pieces to draw the other two.
    ///
    /// Which is the corner question with two free sides, the way Rimstone Corner asked it, and the
    /// hardest corner in the game. What is different is the pair of megaphones set out in the
    /// middle of the ground, and where they are set: a right-angled block in this corner is a
    /// rectangle hung under the crowd, and the megaphones are lying inside every rectangle worth
    /// drawing. So the tidy pen has to swallow the pair and pay their ten, and comes to 25 where
    /// the same block on clear ground would be 35 — the popcorns are dropped clear of it, and no
    /// wall will lie on one to sweep it up. The eleven pieces laid corner to corner
    /// instead — one long diagonal from the north side down to the south-east, cutting the whole
    /// bend off in a single line — hold 51 tiles, both popcorns and the same pair of megaphones, which
    /// comes back to 51. The biggest pen in the world for the smallest budget in it, which is what
    /// two free sides are worth.
    static let theBigTop = carnival(
        id: "the-big-top",
        name: "The Big Top",
        fenceBudget: 11,
        twoStarScore: 25,
        threeStarScore: 48,
        maximumScore: 51,
        question: .corner,
        map: """
            .~.........
            .~.........
            .~.........
            .~.........
            .~...P.....
            .~..a......
            .~.........
            .~....x.a..
            .~....x....
            .~.........
            ..~~~~~~~~~
            ...........
            """
    )

    /// The guying behind the tents: three rows of megaphones set out across the only ground worth
    /// having, and the hardest field in the world. A fence will not go through any of them, and a
    /// pen may not lean on one either — so a wall has to stand a clear tile off a run it does not
    /// shut in, which makes every run of two a strip of dead ground three wide.
    ///
    /// Every board above this one lays its hazards down one at a time and never two of them
    /// touching — two on Sour Ground, two on Gutter Lane, three on Boulder Chamber. Here there are
    /// seven megaphones in three runs, which is more noise than any other field at the fair carries and
    /// includes the only line of three anywhere in the game. Every rectangle worth having runs
    /// into one of them, so squaring off means retreating down the west and swallowing the pair
    /// of megaphones nearest the pig on the way: 31 tiles less their ten, which is 21. The same
    /// eighteen pieces fitted round the rigging instead keep clear of every megaphone on the board and
    /// hold 34 tiles with two of the three popcorns inside them, which comes to 44.
    ///
    /// The popcorns are the other half of the field. No piece will lie on one any more than on a
    /// megaphone, so a wall cannot run through one and cannot pretend it is not there: it comes
    /// inside and pays for itself, or the pen stops short of it. The widest pen the rigging
    /// leaves holds 37 tiles and reaches only the popcorn in the south, which is 42; the pen that
    /// wins gives three of those tiles back to come round the popcorn out east as well, and two
    /// popcorns for three tiles is the two points in it. The run of three and the pair beside it
    /// are left standing out in the north with the third popcorn behind them, because the ground
    /// back there is not worth the twenty-five points the megaphones would cost to shut in.
    static let theRigging = carnival(
        id: "the-rigging",
        name: "The Rigging",
        fenceBudget: 18,
        twoStarScore: 18,
        threeStarScore: 41,
        maximumScore: 44,
        question: .obstruction,
        map: """
            ............
            .~~~...x.x..
            .~~~...x.x..
            .~~~.x.x.a..
            .....x......
            ....P.......
            ............
            ..........a.
            ..~~~.......
            ..~~~....a..
            ............
            ............
            """
    )

    /// The longest walk at the carnival: twelve tiles by twelve with the biggest budget of any
    /// field at the fair laid out along it, a stall at the top of the walk, a crowd round the
    /// waltzer at the bottom of it and three popcorns down the length.
    ///
    /// The midway stands outside the climb the way Smoulder Ridge and Clocktower Square and Wide
    /// Reaches and the Great Gallery do. A broad board leaves a wide gap against a squared-off pen
    /// because it is broad, which says more about its size than about how hard it is to hold — and
    /// this one asks 38, less than three of the fields below it, while holding the second biggest
    /// pen at the fair.
    /// Nineteen pieces squared off down the middle of the walk hold 30 tiles with two popcorns in
    /// them and the pair of megaphones lying across them, which comes to 30. The same nineteen run out to
    /// both blocks of crowd and closed round the south hold 49 tiles, two popcorns and that same
    /// row of megaphones, which comes back to 49. The third popcorn hangs up in the north-east past the stall,
    /// where nothing these nineteen pieces can draw will reach it.
    static let theMidway = carnival(
        id: "the-midway",
        name: "The Midway",
        fenceBudget: 19,
        twoStarScore: 28,
        threeStarScore: 46,
        maximumScore: 49,
        question: .detour,
        map: """
            ............
            ..~~........
            ..~~....a...
            ............
            .....xx.....
            ...P........
            ............
            .......~~~..
            ..a....~~~..
            ............
            .....a......
            ............
            """
    )

    /// The carnival's boss, and the seventh rule the game has: **the ringmaster keeps the middle
    /// and the pig has to close all the way round him.** Every rule before this one is about which
    /// animal is in which pen. This one is about where one pen stands in relation to the other,
    /// which nothing in the game has ever asked — the pig may not be in with him, and her ground
    /// has to leave him no way off the board that does not cross it.
    ///
    /// So the answer five worlds have taught is refused. The tidy pair of pens side by side —
    /// which wins Boar Hollow, and which is what two animals on a board have meant since the
    /// thicket — is turned down here, because a pen beside his is a pen and not a ring. Four
    /// pieces round the pig where she stands hold her perfectly well and leave eighteen of the
    /// budget unspent, and the board sends it back. So is the wall that comes three quarters of
    /// the way round and closes on itself: every piece of it holds, and he walks out the side
    /// that was left open.
    ///
    /// He is standing in the middle of a three by three of crowd, which is the one thing on the
    /// board that makes squaring off possible at all: a rectangle laid over that crowd comes out
    /// with a hole in it, and the hole has the ringmaster in it. Twenty-two pieces boxed round the
    /// crowd that way hold 16 tiles of walkway, and the single tile he is standing on makes 17 —
    /// a fair answer, and one nobody has to be taught. The same twenty-two run out as an octagon —
    /// out from the pig's corner, round the crowd on all four diagonals and back to where they
    /// started — hold 35 tiles and the popcorn hanging over the ring, which is 40.
    ///
    /// The four rows of megaphones are set at the corners, one to each quarter, and they are what
    /// stops the octagon being a bigger octagon: the wall has to come inside them on every
    /// diagonal, and a ring that has to be inside four corners at once is a ring with very little
    /// slack in it. Without them the same budget reaches 46. It asks for most of the stars the
    /// eight fields below it hold before it will open at all.
    ///
    /// Its id keeps the older spelling of the name. Stars and best pens are stored by level id,
    /// so changing it would hand a player who has already held this ring a fresh, empty board.
    static let theCenterRing = carnival(
        id: "the-centre-ring",
        name: "The Center Ring",
        fenceBudget: 22,
        twoStarScore: 17,
        threeStarScore: 38,
        maximumScore: 40,
        question: .ring,
        map: """
            ...........
            .....a.....
            .xx.....xx.
            ...........
            ....~~~....
            ....~M~....
            ....~~~....
            ...P.......
            .xx.....xx.
            ...........
            ...........
            """
    )
}

/// Builds a carnival level from an ASCII map, the same way the meadow's `authored`, the thicket's
/// `woodland`, the mountain's `emberpeak`, the city's `cogsworth`, the reaches' `starfall` and the
/// caverns' `gloamdeep` do — a malformed map here is a mistake in the source, not anything a
/// player could bring about, and its `maximumScore` comes from `Tools/level_search.py` like every
/// other in the game.
private func carnival(
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
    /// Lantern Carnival: nine fields with the crowd standing in blocks on every one of them,
    /// ending on a ringmaster who will not move off his own ring and a toll of most of the stars
    /// below him.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the pen
    /// a player gets by squaring the map off — and it climbs the whole way from Coconut Shy to The
    /// Rigging, the way Emberpeak climbs to Crater Pools, the city to Foundry Corner, the reaches
    /// to Starwell Ring and the caverns to Boulder Chamber. The last two stops step out of that
    /// order for the same reason every world's do: the Midway holds the second biggest pen at the
    /// fair, and the Center Ring is a boss, and neither is measured by the same yardstick as a
    /// field with one animal and one wall to shape.
    static let lanternCarnival = WorldMap(
        name: "Lantern Carnival",
        nodes: [
            WorldNode(level: .coconutShy, across: 0.24, up: 0.00),
            WorldNode(level: .sideshowRow, across: 0.72, up: 1.04),
            WorldNode(level: .theTurnstile, across: 0.26, up: 2.02),
            WorldNode(level: .ticketLine, across: 0.74, up: 3.06),
            WorldNode(level: .toffeeStand, across: 0.20, up: 4.00),
            WorldNode(level: .theBigTop, across: 0.70, up: 5.04),
            WorldNode(level: .theRigging, across: 0.28, up: 6.02),
            WorldNode(level: .theMidway, across: 0.76, up: 7.06),
            WorldNode(level: .theCenterRing, across: 0.30, up: 8.02, starToll: 21)
        ]
    )
}
