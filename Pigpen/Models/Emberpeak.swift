import Foundation

/// The third world's levels and the trail that strings them together.
///
/// Emberpeak is the meadow's game taken up a mountain: fence in the pig, the biggest pen
/// the pieces will reach round, shut or it is no pen at all. The windfall here is a chestnut
/// roasting where it fell and the hazard an ember burning in the ash, but each is worth what
/// its meadow twin was — a chestnut five tiles to shut in, an ember five to shut in with and
/// no fencing at all — so the same solver that authored the meadow and the woods authored
/// these, with `a` standing in for the chestnut and `x` for the ember.
///
/// What the mountain does that neither world below it did is refuse to hand out clean
/// ground. The meadow saved its treats for the last three fields and the thicket scattered
/// them, but both of them had fields with nothing lying about at all; every field on
/// Emberpeak has at least one ember staked in it, so there is nowhere up here a wall can run
/// straight without something in the way of it. `EmberpeakTests` pins that, and it is the
/// whole reason a world that is mostly bare rock still asks more than a wood full of pools.
///
/// The other thing it does is take the water away. Basalt Flats is the first field in the
/// game with no water on it whatsoever — seventeen pieces, a bare shelf and nothing to lean
/// on but the shape of the wall — and the fields that do have water get a tarn rather than
/// the lakes and brooks the low country runs on.
extension PuzzleLevel {
    /// Where the meadow put a river bend and the woods a brook, the mountain puts a melt
    /// channel: it comes down the west and turns east along the top, so the ground it leaves
    /// opens south and east with nothing on those two sides but the rim. Nine pieces squared
    /// off hold 18 tiles; the same nine cut down the south-east and stepped round the ember
    /// hold 25, which is every tile the channel can be made to keep.
    ///
    /// It opens the world the way Bramble Brook opened the thicket, and asks a little more
    /// than that did — 28 against 25 — because a player standing here has held two worlds
    /// of pens and the ember is one more thing to build round.
    static let cinderSlope = emberpeak(
        id: "cinder-slope",
        name: "Cinder Slope",
        fenceBudget: 9,
        twoStarScore: 14,
        threeStarScore: 24,
        maximumScore: 25,
        question: .shore,
        map: """
            .........
            .........
            ..~~~~~~.
            ..~......
            ..~.P....
            ..~......
            ..~......
            ..~....x.
            ..~......
            ..~......
            """
    )

    /// The first field in the game with no water on it at all. Every pen in both worlds
    /// below this one leant on a lake, a brook or a mere somewhere; here there is bare rock,
    /// two embers staked in it, seventeen pieces and nothing else.
    ///
    /// Which makes it the plainest statement the game has of what a wall is worth: the best
    /// block those seventeen pieces can square off holds 16 tiles, and the same seventeen
    /// run out as a ring that steps round both embers hold 23. Nothing is free on this one —
    /// every tile of it is bought.
    static let basaltFlats = emberpeak(
        id: "basalt-flats",
        name: "Basalt Flats",
        fenceBudget: 17,
        twoStarScore: 13,
        threeStarScore: 22,
        maximumScore: 23,
        question: .bare,
        map: """
            ..........
            ..........
            ..........
            ....x.....
            ..........
            ....P.....
            ..........
            ......x...
            ..........
            ..........
            ..........
            """
    )

    /// The mountain's first chestnut, lying out south where a tidy pen would never go, with an
    /// ember staked just south-east of the pig, on the line the wall wants to turn along. The
    /// tarn down the west is the only free wall on the board.
    ///
    /// The pen that wins is neither tidy nor cheap: it runs out south far enough to take the
    /// chestnut, then tapers away east past the ember and pays the five rather than walling
    /// round it, since walling round it costs more ground than it saves. Thirty-one tiles and
    /// a chestnut, less the ember, come to thirty-one.
    static let ashfallTerrace = emberpeak(
        id: "ashfall-terrace",
        name: "Ashfall Terrace",
        fenceBudget: 13,
        twoStarScore: 18,
        threeStarScore: 29,
        maximumScore: 31,
        question: .detour,
        map: """
            .........
            .~.......
            .~.P.....
            .~.......
            .~..x....
            .~.......
            .~.......
            .~.a.....
            .........
            .........
            """
    )

    /// A meltwater tarn bars the whole west of the scree, so the ground beside it is cheap to
    /// wall, and the chestnuts are strung out where the walling is dear: one east of the pig
    /// and one well down the slope. A chestnut is worth more than the ground a pen gives up
    /// bending to reach it, so the best pen is a long tongue rather than a box — twenty-seven
    /// tiles and both chestnuts, less the ember it swallows on the way, which comes to
    /// thirty-two.
    static let chestnutScree = emberpeak(
        id: "chestnut-scree",
        name: "Chestnut Scree",
        fenceBudget: 12,
        twoStarScore: 18,
        threeStarScore: 30,
        maximumScore: 32,
        question: .detour,
        map: """
            .~.......
            .~.......
            .~.......
            .~.P..a..
            .~...x...
            .~.......
            .~.......
            .~.a.....
            .~.......
            .~.......
            """
    )

    /// A scalding rill runs the whole foot of the shelf, and two embers are staked out
    /// on the open ground north of it. Neither ember is worth paying for here — the wall runs
    /// down the diagonal tight past the upper one and pinches right in round the lower one,
    /// which is a wall built round a tile rather than over it — so this is the field
    /// where the mountain teaches that an ember is something to shape a wall against rather
    /// than something to swallow. Thirteen pieces, 24 tiles, and a block worth 15.
    static let sulphurRill = emberpeak(
        id: "sulphur-rill",
        name: "Sulphur Rill",
        fenceBudget: 13,
        twoStarScore: 14,
        threeStarScore: 23,
        maximumScore: 24,
        question: .obstruction,
        map: """
            .........
            .........
            ....x....
            .........
            ..P......
            .........
            ......x..
            .........
            .........
            ~~~~~~~~~
            """
    )

    /// Two embers venting either side of the pig, both chestnuts dropped out east beyond them
    /// and a small tarn at the head of the field. There is no block on this map worth having:
    /// a rectangle that reaches the near chestnut has to swallow an ember to get there, and
    /// the far one is past where any rectangle stops.
    ///
    /// So the pen goes out as a lozenge threaded between the two vents and runs on east for the
    /// second chestnut: eighteen tiles and both of them, twenty-eight, against a block that
    /// takes one chestnut, pays for an ember and comes to sixteen.
    static let fumaroleField = emberpeak(
        id: "fumarole-field",
        name: "Fumarole Field",
        fenceBudget: 14,
        twoStarScore: 16,
        threeStarScore: 26,
        maximumScore: 28,
        question: .obstruction,
        map: """
            ..........
            ..........
            ..~~~.....
            ...x......
            ....P.....
            .......a..
            ..x.......
            .......a..
            ..........
            ..........
            """
    )

    /// The hardest field in the three worlds up to here, and the third turn of the idea the
    /// meadow's dew ponds opened. Tarns caught in the rock at three-tile intervals, an ember
    /// staked out beyond them and a chestnut lying inside: the pools are the wall of a pen
    /// nobody has drawn, and at this spacing they give away almost nothing — five hints of a
    /// ring, and the other two thirds of it to work out.
    ///
    /// Which is why squaring off is worth 17 here and the ring is worth 34. The meadow spaced
    /// its ponds one tile apart and asked 27%; the thicket two, and asked 44%; the mountain
    /// three, and asks 50% — more than Sour Ground and more than anything the city has, and
    /// beaten in the end only by the reaches, which ask the same three tiles on a wider board.
    static let craterPools = emberpeak(
        id: "crater-pools",
        name: "Crater Pools",
        fenceBudget: 12,
        twoStarScore: 16,
        threeStarScore: 32,
        maximumScore: 34,
        question: .constellation,
        map: """
            ..........
            ....~.....
            .......x..
            ..~.......
            .......~..
            ....P.....
            .~........
            ......~...
            ..a.......
            ....~.....
            """
    )

    /// The widest board on the mountain and the last field before the caldera: a tarn in the
    /// north-west, three chestnuts scattered down the slope and two embers burning in it.
    /// Sixteen pieces cut the pen to the shape of the shore and gather every chestnut on the
    /// way, taking the upper ember in and paying for it and leaving the lower one outside —
    /// thirty-two tiles and three chestnuts, less the one ember, which is forty-two — the
    /// biggest pen on any world's trail.
    static let smoulderRidge = emberpeak(
        id: "smoulder-ridge",
        name: "Smoulder Ridge",
        fenceBudget: 16,
        twoStarScore: 24,
        threeStarScore: 39,
        maximumScore: 42,
        question: .detour,
        map: """
            ..........
            .~~~~.....
            .~~~~~....
            ..~~~~....
            ..........
            ..P....a..
            ....x.....
            ..a.......
            .......a..
            ....x.....
            ..........
            """
    )

    /// The mountain's boss, and the only field in the game you are not asked to hold
    /// everything on.
    ///
    /// The wyrm is not livestock. It is what the mountain has instead of weather, and the
    /// board does not want it fenced — it wants it left where it is, on the outside of
    /// whatever you build. So its tile is a hole you can neither cover nor stand a post on,
    /// like an ember that walks, and the only ground that counts is the pig's.
    ///
    /// Which turns the boss inside out. Stag Mere and Boar Hollow are a budget split two
    /// ways; here every one of the twenty pieces goes to the pig, and the question is how
    /// much of the mountain you can take before the wall has to bend round the thing sitting
    /// in the middle of it. Thirty-eight tiles and three chestnuts, less two embers, come to 43,
    /// where
    /// squaring off well clear of the wyrm is worth 27.
    static let wyrmCaldera = emberpeak(
        id: "wyrm-caldera",
        name: "Wyrm Caldera",
        fenceBudget: 20,
        twoStarScore: 25,
        threeStarScore: 40,
        maximumScore: 43,
        question: .exclude,
        map: """
            ..........
            ..P.......
            ....a.....
            ..x.......
            .......~..
            .......~..
            ....x.....
            ..a...W...
            ..........
            ....a..x..
            ..........
            """
    )
}

/// Builds a mountain level from an ASCII map, the same way the meadow's `authored` and the
/// thicket's `woodland` do — a malformed map here is a mistake in the source, not anything a
/// player could bring about, and its `maximumScore` comes from `Tools/level_search.py` like
/// every other in the game.
private func emberpeak(
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
    /// Emberpeak: nine fields up a mountain, climbing to a caldera with a second animal in it
    /// and a toll of most of the stars below it.
    ///
    /// The trail is ordered by what each field asks — the gap between the pen it holds and
    /// the pen a player gets by squaring the map off — the way the meadow's opening stretch
    /// is, and it climbs the whole way from Cinder Slope to Crater Pools. The last two
    /// stops step out of that order for the same reason the meadow's do: Smoulder Ridge is
    /// the widest board in the world and the caldera is a boss, and neither is measured by
    /// the same yardstick as a field with one animal and one wall to shape.
    static let emberpeak = WorldMap(
        name: "Emberpeak",
        nodes: [
            WorldNode(level: .cinderSlope, across: 0.24, up: 0.00),
            WorldNode(level: .basaltFlats, across: 0.76, up: 1.02),
            WorldNode(level: .ashfallTerrace, across: 0.22, up: 2.04),
            WorldNode(level: .chestnutScree, across: 0.72, up: 3.06),
            WorldNode(level: .sulphurRill, across: 0.26, up: 4.02),
            WorldNode(level: .fumaroleField, across: 0.74, up: 5.06),
            WorldNode(level: .craterPools, across: 0.28, up: 6.02),
            WorldNode(level: .smoulderRidge, across: 0.70, up: 7.04),
            WorldNode(level: .wyrmCaldera, across: 0.32, up: 8.06, starToll: 21)
        ]
    )
}
