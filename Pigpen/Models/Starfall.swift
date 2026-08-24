import Foundation

/// The fifth world's levels and the trail that strings them together.
///
/// Starfall Reaches is the meadow's game played on ground the sky keeps landing on: fence in the
/// pig, the biggest pen the pieces will reach round, shut or it is no pen at all. The windfall
/// here is a star still cooling where it fell and the hazard a meteor sunk into the dust, but
/// each is worth what its meadow twin was — a star five tiles to shut in, a meteor five to
/// shut in with and no fencing at all, since nothing will drive a post through a stone that came
/// in from that far out — so the same solver that authored the meadow and the woods and the
/// mountain and the city authored these, with `a` standing in for the star and `x` for the
/// meteor.
///
/// What the reaches do that no world below them did is **break the water up altogether**. A
/// meadow has meres, a thicket has pools, a mountain has tarns and a city has canals, and every
/// one of those lies in a line or a body you can put a wall along. Every drop of water out here
/// is one tile: a well where a star went in, and no two wells touching. `StarfallTests` pins it —
/// no drop of water in this world shares an edge with another.
///
/// Which sounds like the end of free walls and is not, because of the one arrangement the law
/// still allows: wells laid corner to corner. A chain of them on the diagonal is a wall a pig
/// cannot walk through — every step out of the pen behind it runs into a well or into the one
/// piece bridging two of them — and it is a wall no rectangle can ever use. So this world's
/// water hands over staircases rather than banks, and squaring a board off against a staircase
/// wastes more than squaring off against anything the four worlds below had. It is why the
/// reaches floor at 32% where the city floors at 30, on boards half again as big: there is more
/// room out here than anywhere in the game, and less of it that a plain block can reach.
extension PuzzleLevel {
    /// The chain runs from the north-west corner down across the middle of the reaches, seven
    /// wells laid corner to corner, and the whole south-west side of the pen is therefore free:
    /// every tile behind it has a well beside it or a well above it. What the field is asking is
    /// how far along the chain to keep going, since the pen has to pay for its own north and
    /// east however long it runs.
    ///
    /// Twelve pieces squared off in the open beside the chain hold 21 tiles. The same twelve run
    /// along it as a staircase — one long diagonal wall bought for nothing — hold 31, which is
    /// every tile between the chain and the rim it can afford to close.
    ///
    /// It opens the world the way Gasworks Cut opened the city, and asks a little more than that
    /// did — 32 against 30 — because a player standing here has held four worlds of pens, and a
    /// bank of wells with gaps in it is the first bank in the game that has to be read rather
    /// than followed.
    static let dustShore = starfall(
        id: "dust-shore",
        name: "Dust Shore",
        fenceBudget: 12,
        twoStarScore: 18,
        threeStarScore: 29,
        maximumScore: 31,
        question: .shore,
        map: """
            ...........
            ...........
            .~.........
            ..~..P.....
            ...~.......
            ....~......
            .....~.....
            ......~....
            .......~...
            ...........
            ...........
            """
    )

    /// A whole shower of them landed here: wells along the top of the reaches, wells down the
    /// west, and a third line falling away south-west through the middle. Twelve drops, and
    /// every one of them every other tile — which is the question Horseshoe Lake and Foxglove
    /// Dell asked with one body of water apiece, asked here with a basin that is dotted rather
    /// than drawn.
    ///
    /// So the wall of the answer is half water: almost every one of the thirteen pieces goes in
    /// the gap between two drops, and the drops do the rest. Squared off between the north bank
    /// and the west those thirteen hold 24 tiles; laid in the gaps instead they hold 36.
    static let fallwaterBasin = starfall(
        id: "fallwater-basin",
        name: "Fallwater Basin",
        fenceBudget: 13,
        twoStarScore: 21,
        threeStarScore: 34,
        maximumScore: 36,
        question: .basin,
        map: """
            .~.~.~.~...
            ~........~.
            ...........
            ~..P...~...
            ...........
            ~....~.....
            ...........
            ~..~.......
            ...........
            ...........
            ...........
            """
    )

    /// One chain again, longer, and with a well missing out of the middle of it. Everything the
    /// chain seals is free and the hole is a way out, so the whole bank — eight tiles of
    /// diagonal, seven of them wells — costs exactly one piece, laid in the hole.
    ///
    /// Which is Otter Ford's lesson and Lock Gate's, taught on the only board in the game where
    /// the bank is diagonal: fifteen pieces squared off hold 24 tiles, and the same fifteen with
    /// one of them spent plugging the chain hold 38. Finding the hole is most of it; what is
    /// left is that the fourteen pieces still in hand have to close a staircase rather than a
    /// box, and a staircase wants them in a different order.
    static let brokenChain = starfall(
        id: "broken-chain",
        name: "Broken Chain",
        fenceBudget: 15,
        twoStarScore: 22,
        threeStarScore: 36,
        maximumScore: 38,
        question: .gap,
        map: """
            ...........
            ...........
            .........~.
            ........~..
            .......~...
            ...P.......
            .....~.....
            ....~......
            ...~.......
            ..~........
            ...........
            """
    )

    /// A stretch of the reaches the water never found: not one well on it, eleven tiles of dust
    /// in every direction and eighteen pieces. Every tile of this pen is bought, and there is no
    /// half measure available on a board this size — a well left in the far corner is a well
    /// eighteen pieces can walk out and lean on, so the sky has to have missed this field with
    /// its water for the question to be the one it is asking.
    ///
    /// What it did not miss it with is stone. Three meteors are sunk in the dust out here, and
    /// not one of them hands over so much as a tile of wall: a stone that came in from that far
    /// out takes no fencing and shuts nothing in. All a meteor does on this field is stand where
    /// a wall might otherwise have gone.
    ///
    /// So it is Basalt Flats and Cobble Yard with more room and more pieces than either of them
    /// had, and the answer is the same answer it always was, worth more here than it has ever
    /// been worth: the best block eighteen pieces can square off holds 20 tiles, and the same
    /// eighteen run round as a diamond hold 32. A diagonal wall shuts two tiles per piece where
    /// a straight one shuts one.
    ///
    /// What the stones add is Cobble Yard's other half — not what shape to run, but where to put
    /// it. The diamond a player draws first is the one centred on the pig, and this board refuses
    /// it twice over: the northern meteor lies on the line its wall wants, where no piece can be
    /// laid, and the eastern one lies inside it, worth five against. Carried two columns west and
    /// a row north the same diamond holds the same 32 tiles with all three stones outside it —
    /// and the one out in the south-west is what stops it being carried a row south instead.
    static let sweptFlat = starfall(
        id: "swept-flat",
        name: "Swept Flat",
        fenceBudget: 18,
        twoStarScore: 18,
        threeStarScore: 30,
        maximumScore: 32,
        question: .bare,
        map: """
            ...........
            ......x....
            ...........
            ...........
            ...........
            ......P..x.
            ...........
            ...........
            ..x........
            ...........
            ...........
            """
    )

    /// Two stars cooling on the north rim of a hollow with a single tile of dust between
    /// them, and thirteen pieces with seven wells scattered round the ground to lean on. The
    /// near one is worth the ground the wall gives up bending out to it and the far one is not,
    /// which is the whole of what a star is for — and here the two are close enough that
    /// the line between worth it and not runs between neighbours.
    ///
    /// Thirteen pieces squared off under the wells hold 13 tiles and, since no piece goes on a
    /// star, both of the drops as well — which is 23. The same thirteen, bent out over the
    /// near drop and cut back on the diagonal to pay for it, hold 34 tiles and that drop, which
    /// is 39. The far one stays where it fell: reaching it costs more tiles than its five ever
    /// pays for, and the reaches are wide enough that the difference is obvious once it has been
    /// worked out and invisible until then.
    static let stardropHollow = starfall(
        id: "stardrop-hollow",
        name: "Stardrop Hollow",
        fenceBudget: 13,
        twoStarScore: 22,
        threeStarScore: 37,
        maximumScore: 39,
        question: .detour,
        map: """
            ..~..~.....
            ......a.a..
            ~.......~..
            ....P......
            ...........
            .~.....~...
            ....~......
            ...........
            ...........
            ...........
            ...........
            """
    )

    /// Two meteors staked in the dust three tiles apart, dead in the middle of the only ground
    /// worth having, with the pig standing between them. A fence will not go through either of
    /// them: the pen swallows both and pays their ten, or it steps round them and loses the
    /// tiles behind them as well.
    ///
    /// Sour Ground made that choice once, Sulphur Rill and Gutter Lane made it twice on tight
    /// boards; this makes it twice in the open, where stepping round looks affordable and is
    /// not. Fifteen pieces squared off hold 17 once the stone in the way is counted. The same
    /// fifteen, run round as a ring that takes both meteors in, hold 42 tiles less their ten,
    /// which is 32 — the widest gap any ordinary field in the world leaves except the ring.
    static let meteorField = starfall(
        id: "meteor-field",
        name: "Meteor Field",
        fenceBudget: 15,
        twoStarScore: 17,
        threeStarScore: 30,
        maximumScore: 32,
        question: .obstruction,
        map: """
            .....~.....
            ...........
            .~.........
            ....x..~...
            ...........
            .~..P......
            ....x..~...
            ...........
            ..~........
            .....~.....
            ...........
            """
    )

    /// Six wells and nothing else: two on the north, two on the south, one out west and one out
    /// east, none of them touching anything. They are six corners of a shape nobody has drawn,
    /// and the budget is exactly the rest of that shape's wall — twelve pieces, which is what
    /// the octagon they imply needs and not one to spare.
    ///
    /// So this is Dew Ponds and Fairy Ring and Crater Pools again, and the hardest field in the
    /// world: twelve pieces squared off between two of the drops hold 14 tiles, and the same
    /// twelve laid where the drops are pointing hold 32. Nothing about the board says where the
    /// wall goes. The water only rules out every shape but one, and every well is on the answer,
    /// which is what `Constellation.idleWater` is checked for in the tests.
    static let starwellRing = starfall(
        id: "starwell-ring",
        name: "Starwell Ring",
        fenceBudget: 12,
        twoStarScore: 14,
        threeStarScore: 30,
        maximumScore: 32,
        question: .constellation,
        map: """
            ...........
            ...~..~....
            ...........
            ...........
            ~....P...~.
            ...........
            ...........
            ...~..~....
            ...........
            ...........
            ...........
            """
    )

    /// The widest board in the game, and the biggest pen anywhere in it. Twelve tiles by twelve,
    /// six wells thrown across it, one star lying down in the south-west, and twenty pieces.
    ///
    /// The wells are a constellation the way the ring's are — the budget is the rest of the wall
    /// they imply — but out here that wall is a diamond ten tiles across, and the diamond is
    /// the point: twenty pieces laid as a staircase all the way round shut 64 tiles and take the
    /// star in on the way, which is 69, where the best block those same twenty can square
    /// off holds 40 tiles and the same star, or 45. Nothing else in the game holds sixty
    /// tiles.
    ///
    /// It stands outside the climb the way Smoulder Ridge and Clocktower Square do: a broad
    /// board leaves a wide gap against a squared-off pen because it is broad, which says more
    /// about its size than about how hard it is to hold.
    static let wideReaches = starfall(
        id: "wide-reaches",
        name: "Wide Reaches",
        fenceBudget: 20,
        twoStarScore: 39,
        threeStarScore: 65,
        maximumScore: 69,
        question: .constellation,
        map: """
            ............
            ...~....~...
            ..~.........
            ............
            ............
            ......P.....
            ..........~.
            .~..........
            ...a........
            ......~.....
            ............
            ............
            """
    )

    /// The reaches' boss, and the fifth rule the game has: **the visitor will not be housed
    /// worse than the pig**. Both of them held, in two pens rather than one, and the same ground
    /// in each — a pen apiece that comes out even, or the field is not won.
    ///
    /// Which is every other two-animal board's answer forbidden at once. Stag Mere lets the
    /// budget fall wherever it scores best; Boar Hollow insists on two pens and does not care
    /// what is in them; Wyrm Caldera throws the second animal out; Rat King Wharf demands the
    /// single pen this one refuses. Here the two pens have to be weighed against each other,
    /// and the cheap answer every one of those four rewards — spend the budget on the animal
    /// standing in the better country and box the other one in four pieces — is exactly what
    /// the board sends back.
    ///
    /// A line of wells falls down the middle of the crater, north-east rim to south-west, and it
    /// is dividing wall the sky laid and nobody pays for — except that two tiles of it are
    /// missing, a neck of plain dust where the two halves of the crater still run into one
    /// another. Plugging the neck for two pieces is what turns one pen into two. What is left
    /// after that is the rule itself, because the halves the line leaves are not the same size:
    /// a player who plugs the neck and fences the rim has a pen that holds every tile in the
    /// crater and a board that will not have it, and the last thing to work out is which tiles
    /// of the wider half to hand back.
    ///
    /// Twenty pieces. The best pair of blocks holds 27 between them; the answer holds 22 tiles
    /// apiece with a star in each half and a meteor swallowed by the visitor's, which comes
    /// to 49. A third star hangs out past the west rim where no wall on this board can reach
    /// it, and the other meteor stands out on the rim where the tidy wall would want to go. It asks for most of the stars the eight fields below it hold before it will open at
    /// all.
    static let visitorCrater = starfall(
        id: "visitor-crater",
        name: "Visitor Crater",
        fenceBudget: 20,
        twoStarScore: 27,
        threeStarScore: 46,
        maximumScore: 49,
        question: .even,
        map: """
            ...........
            ...........
            ...........
            ..a....~...
            ....P......
            ~.....x....
            ....~....a.
            ..x~.V...~.
            .a~........
            .....~.....
            ....~......
            ...........
            """
    )
}

/// Builds a Starfall level from an ASCII map, the same way the meadow's `authored`, the
/// thicket's `woodland`, the mountain's `emberpeak` and the city's `cogsworth` do — a malformed
/// map here is a mistake in the source, not anything a player could bring about, and its
/// `maximumScore` comes from `Tools/level_search.py` like every other in the game.
private func starfall(
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
    /// Starfall Reaches: nine stretches of dust with the sky in them, ending on a crater with a
    /// visitor standing in it and a toll of most of the stars below it.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the
    /// pen a player gets by squaring the map off — and it climbs the whole way from Dust Shore
    /// to Starwell Ring, the way Emberpeak climbs to Crater Pools and the city to Foundry
    /// Corner. The last two stops step out of that order for the same reason every world's do:
    /// Wide Reaches is the widest board in the game and the crater is a boss, and neither is
    /// measured by the same yardstick as a field with one animal and one wall to shape.
    static let starfallReaches = WorldMap(
        name: "Starfall Reaches",
        nodes: [
            WorldNode(level: .dustShore, across: 0.24, up: 0.00),
            WorldNode(level: .fallwaterBasin, across: 0.72, up: 1.02),
            WorldNode(level: .brokenChain, across: 0.22, up: 2.06),
            WorldNode(level: .sweptFlat, across: 0.74, up: 3.00),
            WorldNode(level: .stardropHollow, across: 0.26, up: 4.04),
            WorldNode(level: .meteorField, across: 0.78, up: 5.02),
            WorldNode(level: .starwellRing, across: 0.20, up: 6.06),
            WorldNode(level: .wideReaches, across: 0.70, up: 7.02),
            WorldNode(level: .visitorCrater, across: 0.28, up: 8.06, starToll: 21)
        ]
    )
}
