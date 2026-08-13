import Foundation

/// The sixth world's levels and the trail that strings them together.
///
/// Gloamdeep Caverns is the meadow's game played underground: fence in the pig, the biggest pen
/// the pieces will reach round, shut or it is no pen at all. The windfall down here is a crystal
/// growing out of the flowstone and the hazard a boulder come off the roof, and each is worth what
/// its meadow twin was — a crystal five tiles to shut in, a boulder five to shut in with and no
/// fencing at all, since nothing will drive a post through a block of limestone the size of a cow
/// — so the same solver that authored the five worlds above these authored them, with `a` standing
/// in for the crystal and `x` for the boulder.
///
/// What the caverns do that no world above them did is **put all the water in one river**. A
/// meadow has meres, a thicket has pools, a mountain has tarns, a city has canals and the reaches
/// have wells, and every one of those worlds scatters its water in bodies — ten ponds, seven pools,
/// twelve drops. There is at most one body of water on a board down here and it comes in off the
/// rim of the cave, because it is the same river the whole way and a cave has no second river in
/// it. `GloamdeepTests` pins both halves: every drop of water on a board belongs to one run, and
/// that run touches the edge.
///
/// Which sounds like less water to lean on and is in fact a great deal more of it in one place.
/// A river that runs in off the rim and stops short of the far wall has done nine tenths of a
/// wall's work and left a **neck** — the strip of dry floor where the two halves of the cave still
/// run into one another — and a single piece laid in the neck buys the whole length of the river.
/// A river that runs the whole way across has cut the cave in two for nothing. And because the
/// only way to make a river long enough to matter on a board this size is to step it, the banks
/// down here are staircases rather than straight lines, so the pen that follows one is a wedge or
/// a lozenge and never a box.
///
/// The other thing the caverns keep is the light. Emberpeak staked an ember in all nine of its
/// fields; this is that idea turned the other way up — there is a crystal on every board in the
/// world, because a crystal is the only light in the Gloamdeep and a field with none would be a
/// field nobody could see. The caverns floor at 34% against the reaches' 32, on ground where a
/// plain block can lean on a river and still lose a third of what is there.
extension PuzzleLevel {
    /// The river comes in off the roof of the cave in the north-west, runs down to the floor and
    /// climbs back out to the east: a shallow V of free wall with the whole floor of the chamber
    /// underneath it. Every tile along the belly of that V is walled for nothing, which is most of
    /// a pen already — and it is why this is the gentlest field in the world.
    ///
    /// What it leaves is the mouth, and the mouth here is the entire southern side. Twelve pieces
    /// hung straight down off the belly as a rectangle hold 16 tiles and one crystal, which is 21
    /// and a fair answer. The same twelve hung under the belly as a lozenge — stepping out west and
    /// east and closing again on the diagonal — hold 22 tiles and both crystals, which is 32.
    ///
    /// It opens the world the way Dust Shore opened the reaches, and asks a little more than that
    /// did — 34 against 32 — because a bent bank is a bank that has to be read before it can be
    /// followed, and a player standing here has held five worlds of pens.
    static let sinterBasin = gloamdeep(
        id: "sinter-basin",
        name: "Sinter Basin",
        fenceBudget: 12,
        twoStarScore: 18,
        threeStarScore: 30,
        maximumScore: 32,
        question: .basin,
        map: """
            .~.........
            .~~....~~..
            ..~~..~~...
            ...~~~~....
            .....a.....
            ...........
            ......P....
            ...........
            ...a.......
            ...........
            ...........
            """
    )

    /// A shelf of dripstone with the river running the length of it. It comes in off the roof at
    /// the north and steps south-east the whole way down the board, so the bank is one long
    /// staircase and the ground either side of it is a wedge.
    ///
    /// Which is the shore question asked on the only kind of bank the caverns have. Eleven pieces
    /// squared off beside the staircase can only get one of their four sides against it and hold
    /// 22; the same eleven laid as a staircase of their own, mirroring the river back at itself,
    /// shut 26 tiles and both crystals, which is 36. A diagonal wall closes two tiles a piece
    /// where a straight one closes one, and following a river that is already diagonal is how the
    /// caverns say so.
    static let dripstoneShelf = gloamdeep(
        id: "dripstone-shelf",
        name: "Dripstone Shelf",
        fenceBudget: 11,
        twoStarScore: 21,
        threeStarScore: 34,
        maximumScore: 36,
        question: .shore,
        map: """
            ..~.......
            ..~.......
            ..~..a....
            ..~~......
            ...~......
            ...~..P...
            ...~~.....
            ....~.....
            ....~.a...
            ....~~....
            ..........
            """
    )

    /// The river runs in off the west wall, steps away south-east across the middle of the cave,
    /// and stops two columns short of the east. What it leaves behind is the neck the whole world
    /// is built on: a corridor of dry floor round the tip of the water, and the only way from one
    /// half of the cave to the other.
    ///
    /// So this is Otter Ford's lesson and Lock Gate's and Broken Chain's, taught on a bank eight
    /// tiles long that cost nothing: shut the corridor and the whole of it is wall. Twelve pieces
    /// squared off north of the water hold 21, because a wall that stops short of the east rim has
    /// to pay for its own eastern side. The same twelve run right out along the bank and closed
    /// with a single piece in the corridor hold 29 tiles and both the crystals over the river.
    ///
    /// And the corridor is not clear ground, which is the rest of the field. A boulder stands in
    /// it, just behind the tip of the water, so the pen that comes round the river swallows it and
    /// pays its five — 29 and two crystals less one boulder, or 34. The eight tiles of free bank
    /// that piece bought are worth that twice over, which is a sum a player has to do rather than
    /// see.
    static let stillwaterNeck = gloamdeep(
        id: "stillwater-neck",
        name: "Stillwater Neck",
        fenceBudget: 12,
        twoStarScore: 19,
        threeStarScore: 32,
        maximumScore: 34,
        question: .gap,
        map: """
            ...........
            ......a....
            ...........
            ......a....
            ~~.........
            .~~~~P.x...
            ....~~~~...
            ..a....~~..
            ...........
            ...........
            ...........
            """
    )

    /// The one cave the river never found: a grike in the limestone with no water in it anywhere,
    /// eleven tiles of dry floor in every direction, two crystals, a boulder and nineteen pieces.
    /// Every tile of this pen is bought.
    ///
    /// It is Basalt Flats and Cobble Yard and Swept Flat again, and the answer is the answer it
    /// always was: the best block nineteen pieces can square off holds 25, and the same nineteen
    /// run round as a diamond hold 36 tiles, both crystals and the boulder they cannot avoid
    /// swallowing, which is 41. A diagonal wall shuts two tiles per piece where a straight one
    /// shuts one, and in a cave with no river in it there is nothing else to know.
    static let blindGrike = gloamdeep(
        id: "blind-grike",
        name: "The Blind Grike",
        fenceBudget: 19,
        twoStarScore: 23,
        threeStarScore: 39,
        maximumScore: 41,
        question: .bare,
        map: """
            ...........
            .....a.....
            ...........
            ...x.......
            ...........
            .a...P.....
            ...........
            ...........
            ...........
            ...........
            ...........
            """
    )

    /// Three crystals in a reach the glowworms have got into, and not one of them on the line the
    /// tidy pen wants. The river steps in off the roof at the north-west and away south-east, and
    /// the best block thirteen pieces can hang under it holds 20 tiles and no crystal at all —
    /// there is no rectangle on this board that reaches any of the three.
    ///
    /// So the whole field is which one to go out for. The crystal above the river's arm is on the
    /// far side of the water: a pen that wants it has to come round the tip of the river and climb
    /// back up, and there is no thirteen-piece wall that does. The one out east is four tiles of
    /// wall from the nearest ground worth holding, and four tiles of wall costs more than five
    /// points pay. The one hanging in the south is two rows below where the wall would otherwise
    /// stop, and the tongue that fetches it pinches down to a single tile — which is 28 tiles and
    /// that one crystal, or 33.
    static let glowwormReach = gloamdeep(
        id: "glowworm-reach",
        name: "Glowworm Reach",
        fenceBudget: 13,
        twoStarScore: 19,
        threeStarScore: 31,
        maximumScore: 33,
        question: .detour,
        map: """
            ..~........
            ..~~.......
            ...~~.a....
            ....~~.....
            .....~~....
            ....P.~~...
            ...........
            ...........
            .........a.
            .....a.....
            ...........
            """
    )

    /// The river takes the length of the roof of the cave and the length of the east wall — it
    /// comes in along the north, turns at the corner and runs down the far side, and both of those
    /// are free wall for anybody standing in the rimstone under them. Two sides handed over, and
    /// nine pieces to draw the other two. It runs a tile inside the rim rather than along it, so
    /// there is a far bank beyond it, and like every far bank in the game nothing can reach it.
    ///
    /// Which is the corner question with nothing else in the way of it, and the hardest corner in
    /// the game. Nine pieces laid as a right angle in the corner hold 25. The same nine laid corner
    /// to corner — one long diagonal from the west wall down to the south-east, cutting the whole
    /// bend off in a single line — hold 36 tiles and both crystals, which is 46. Foundry Corner
    /// asked this on a canal bend with the same nine pieces and could only reach round 27; two free
    /// sides instead of one is what takes those nine to 46, and every one of them has to be on the
    /// diagonal or the pen falls apart.
    static let rimstoneCorner = gloamdeep(
        id: "rimstone-corner",
        name: "Rimstone Corner",
        fenceBudget: 9,
        twoStarScore: 25,
        threeStarScore: 43,
        maximumScore: 46,
        question: .corner,
        map: """
            ............
            ~~~~~~~~~~~.
            .....a....~.
            ..........~.
            .......P..~.
            ..........~.
            ......a...~.
            ..........~.
            ..........~.
            ..........~.
            ..........~.
            """
    )

    /// Three boulders down off the roof into the middle of the only ground worth having, and the
    /// hardest field in the world. A fence will not go through any of them: the pen swallows one
    /// and pays its five, or it steps the wall in beside it and gives up the ground behind it too.
    ///
    /// Sour Ground made that choice once, Sulphur Rill and Gutter Lane and Meteor Field made it
    /// twice; this makes it three times, on a board where the river down the west side is worth
    /// having and the boulders are strung across the way to it. Fifteen pieces squared off in the
    /// long chamber beside the water hold 23. The same fifteen run round as a diamond hold 44
    /// tiles, both crystals and two of the three boulders, which comes back to 44 — the third is
    /// left out in the east where the wall goes round it, because it is the one boulder on the
    /// board that costs less to abandon than to shut in.
    static let boulderChamber = gloamdeep(
        id: "boulder-chamber",
        name: "Boulder Chamber",
        fenceBudget: 15,
        twoStarScore: 23,
        threeStarScore: 41,
        maximumScore: 44,
        question: .obstruction,
        map: """
            .~.........
            .~.........
            .~.........
            .~~........
            ..~.....a..
            ..~..x.....
            ..~~..P....
            ...~x......
            ...~....x..
            ...~~a.....
            ...........
            """
    )

    /// The widest floor in the caverns with a river running the length of it: twelve tiles by
    /// twelve, a staircase of water in off the roof at the north-west and stepping south-east to
    /// within a column of the east wall, three crystals, one boulder and nineteen pieces.
    ///
    /// The gallery stands outside the climb the way Smoulder Ridge and Clocktower Square and Wide
    /// Reaches do. A broad board leaves a wide gap against a squared-off pen because it is broad,
    /// which says more about its size than about how hard it is to hold — and this one asks 34,
    /// as little as the field that opens the world, while holding the second biggest pen in the
    /// game at 58 tiles.
    /// Nineteen pieces squared off down the west of it hold 41 tiles with a crystal and a boulder
    /// in them cancelling each other out. The same nineteen laid along the river and closed round
    /// the south as a staircase hold 58 tiles, two crystals and that same boulder, which is 63.
    /// The third crystal lies out east past the tip of the water, where nothing these nineteen
    /// pieces can draw will reach it.
    static let greatGallery = gloamdeep(
        id: "great-gallery",
        name: "Great Gallery",
        fenceBudget: 19,
        twoStarScore: 36,
        threeStarScore: 59,
        maximumScore: 63,
        question: .detour,
        map: """
            ....~.......
            ....~~......
            .....~~.....
            ..a...~~....
            .......~~a..
            ........~~..
            ...P.....~~.
            .......x....
            ............
            .....a......
            ............
            ............
            """
    )

    /// The caverns' boss, and the sixth rule the game has: **the roost hangs together and the pig
    /// hangs apart**. Three animals on one board for the first time anywhere — a bat, its pup and
    /// the pig — and two things asked at once that pull opposite ways. The bat and the pup have to
    /// be in the same pen, because a roost is not split; the pig has to be in another, because a
    /// pig underfoot is not what a roost wants over it. One budget for both pens, and either half
    /// of the rule broken is the field lost.
    ///
    /// Which is every other multi-animal board's answer forbidden at once, and two of them
    /// forbidden by the same wall. Stag Mere lets the budget fall wherever it scores best; Boar
    /// Hollow insists on two pens and does not care which animals are in them; Rat King Wharf
    /// demands one pen round the pair; Wyrm Caldera throws the second animal out; Visitor Crater
    /// wants two pens holding the same ground. Here the pens are two and which animal is in which
    /// is the whole of it — and the cheap answer, three little boxes so that nothing can possibly
    /// be sharing, is turned down flat, because a pup boxed on its own is a roost split.
    ///
    /// The river comes in off the west wall low down and climbs north-east across the cave, and
    /// the bat and its pup are hung either side of the tip of it: the water runs between them.
    /// Joining them means reaching round that tip, and reaching round the tip is what hands the
    /// pig the whole staircase as the wall of its own pen — so the one wall the budget cannot
    /// afford to leave out does both jobs, and finding it is finding the field.
    ///
    /// Twenty pieces. The best pair of blocks holds 22 between them. The answer hangs the roost in
    /// a pocket of 14 tiles off the east end of the river with two crystals in it, and gives the
    /// pig 21 tiles of the wide floor south-west of the water with the third crystal and a boulder
    /// it cannot get out of swallowing, which comes to 45. It asks for most of the stars the eight
    /// fields below it hold before it will open at all.
    static let theRoost = gloamdeep(
        id: "the-roost",
        name: "The Roost",
        fenceBudget: 20,
        twoStarScore: 22,
        threeStarScore: 42,
        maximumScore: 45,
        question: .roost,
        map: """
            ...........
            ......T.a..
            ...~~~~....
            ..~~..U....
            .~~.....a..
            ~~.........
            ......P....
            ....a.x....
            ...........
            ...........
            """
    )
}

/// Builds a Gloamdeep level from an ASCII map, the same way the meadow's `authored`, the
/// thicket's `woodland`, the mountain's `emberpeak`, the city's `cogsworth` and the reaches'
/// `starfall` do — a malformed map here is a mistake in the source, not anything a player could
/// bring about, and its `maximumScore` comes from `Tools/level_search.py` like every other in the
/// game.
private func gloamdeep(
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
    /// Gloamdeep Caverns: nine chambers with one river apiece, ending on a roost with a bat and
    /// its pup hung either side of the water and a toll of most of the stars below it.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and the pen
    /// a player gets by squaring the map off — and it climbs the whole way from Sinter Basin to
    /// Boulder Chamber, the way Emberpeak climbs to Crater Pools, the city to Foundry Corner and
    /// the reaches to Starwell Ring. The last two stops step out of that order for the same reason
    /// every world's do: the Great Gallery is the widest floor in the caverns and the roost is a
    /// boss, and neither is measured by the same yardstick as a field with one animal and one wall
    /// to shape.
    static let gloamdeepCaverns = WorldMap(
        name: "Gloamdeep Caverns",
        nodes: [
            WorldNode(level: .sinterBasin, across: 0.26, up: 0.00),
            WorldNode(level: .dripstoneShelf, across: 0.74, up: 1.02),
            WorldNode(level: .stillwaterNeck, across: 0.22, up: 2.04),
            WorldNode(level: .blindGrike, across: 0.72, up: 3.00),
            WorldNode(level: .glowwormReach, across: 0.24, up: 4.06),
            WorldNode(level: .rimstoneCorner, across: 0.76, up: 5.02),
            WorldNode(level: .boulderChamber, across: 0.20, up: 6.04),
            WorldNode(level: .greatGallery, across: 0.70, up: 7.00),
            WorldNode(level: .theRoost, across: 0.30, up: 8.06, starToll: 21)
        ]
    )
}
