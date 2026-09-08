import Foundation

/// A film a world owns but has not started yet: the key it is tracked by, and how to raise the
/// curtain on it at a given moment. Held apart from the film itself so asking whether a film is
/// owed does not build one, and presenting it starts its clock fresh.
struct WorldFilmSpec: Sendable {
    let key: String
    let make: @Sendable (Date) -> CutScene

    /// The film, its clock started now.
    func raise(at start: Date = .now) -> CutScene { make(start) }
}

/// A whole world: the puzzles up its trail, the look that dresses them, and the films that open
/// and close it.
///
/// The map and the theme are the two halves the rest of the game reads — one for what a pen is
/// worth, the other for what it looks like — and every world is the same game underneath. The
/// films are what wrap it: an opening before the first field, a send-off once every pen is held,
/// and a briefing before any field that changes the rules rather than only the ground.
struct GameWorld: Sendable {
    let theme: WorldTheme
    let map: WorldMap
    /// The film before the first walk into the world, if it has one. Played on entering the
    /// world with nothing yet won on it.
    let opening: WorldFilmSpec?
    /// The film that sees the world out once every pen in it is held.
    let farewell: WorldFilmSpec?
    /// The films that set a particular level up before it opens, by level id.
    ///
    /// Only a boss has one, in every world built so far. Every other field is the same game on
    /// new ground — there is nothing to say about it that the ground does not say itself — where
    /// a boss stands a second animal on the board and puts one budget on the pair, and a rule is
    /// worth stopping nine seconds for.
    let briefings: [String: WorldFilmSpec]

    init(
        theme: WorldTheme,
        map: WorldMap,
        opening: WorldFilmSpec? = nil,
        farewell: WorldFilmSpec? = nil,
        briefings: [String: WorldFilmSpec] = [:]
    ) {
        self.theme = theme
        self.map = map
        self.opening = opening
        self.farewell = farewell
        self.briefings = briefings
    }

    var name: String { theme.name }

    /// The film this world plays before a level opens, if it keeps one for it.
    func briefing(before levelID: String) -> WorldFilmSpec? { briefings[levelID] }
}

extension GameWorld {
    /// Mudlark Meadow: the world the game has always shipped, now the first stop of many. Its
    /// films stay the meadow's own painted ones, and keyed exactly as before — the boss briefing
    /// included — so a player who has already seen one is not sat back down in front of it.
    static let mudlarkMeadow = GameWorld(
        theme: .meadow,
        map: .mudlarkMeadow,
        opening: WorldFilmSpec(key: CutScene.Name.opening.rawValue) { .opening(start: $0) },
        farewell: WorldFilmSpec(key: CutScene.Name.theMeadowHeld.rawValue) {
            .theMeadowHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.stagMere.id: WorldFilmSpec(key: CutScene.Name.stagMere.rawValue) {
                .stagMere(start: $0)
            }
        ]
    )

    /// Thornwood Thicket: the second world, and the first after the meadow to be painted. Every
    /// world's films are keyed exactly as its storybook stills were, so nobody who sat through
    /// one before it was painted is sat back down in front of it.
    ///
    /// The send-off points on past the trees, the way the meadow's points past the hills, and
    /// Boar Hollow stops for a briefing the way Stag Mere does — it is the same board with the
    /// same twist on it, and the woods should no more spring a second animal on a player than
    /// the meadow did.
    static let thornwoodThicket = GameWorld(
        theme: .thornwood,
        map: .thornwoodThicket,
        opening: WorldFilmSpec(key: CutScene.Name.thornwoodOpening.rawValue) {
            .thornwoodOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.thornwoodHeld.rawValue) {
            .thornwoodHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.boarHollow.id: WorldFilmSpec(key: CutScene.Name.boarHollow.rawValue) {
                .boarHollow(start: $0)
            }
        ]
    )

    /// Emberpeak: the third world, painted the way the meadow is. The
    /// send-off points on down the far side of the mountain to the city, the way the
    /// thicket's points past the trees to the mountain, and Wyrm Caldera stops for a briefing
    /// because it stands a second animal on the board — the same courtesy Stag Mere and Boar
    /// Hollow pay.
    static let emberpeak = GameWorld(
        theme: .emberpeak,
        map: .emberpeak,
        opening: WorldFilmSpec(key: CutScene.Name.emberpeakOpening.rawValue) {
            .emberpeakOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.emberpeakHeld.rawValue) {
            .emberpeakHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.wyrmCaldera.id: WorldFilmSpec(key: CutScene.Name.wyrmCaldera.rawValue) {
                .wyrmCaldera(start: $0)
            }
        ]
    )

    /// Cogsworth City: the fourth world, painted the way the worlds below it are. The send-off points on up past the rooftops to something coming down
    /// out of the stars, the way the mountain's points down off the peak to the city, and
    /// Rat King Wharf stops for a briefing because it stands a second animal on the board —
    /// the same courtesy every boss before it pays.
    static let cogsworthCity = GameWorld(
        theme: .cogsworth,
        map: .cogsworthCity,
        opening: WorldFilmSpec(key: CutScene.Name.cogsworthOpening.rawValue) {
            .cogsworthOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.cogsworthHeld.rawValue) {
            .cogsworthHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.ratKingWharf.id: WorldFilmSpec(key: CutScene.Name.ratKingWharf.rawValue) {
                .ratKingWharf(start: $0)
            }
        ]
    )

    /// Starfall Reaches: the fifth world, painted the way the worlds below it are. The send-off points on down into the dark under the dust, the way the city's
    /// points up off the rooftops to the reaches, and Visitor Crater stops for a briefing
    /// because it stands a second animal on the board — the same courtesy every boss pays.
    static let starfallReaches = GameWorld(
        theme: .starfall,
        map: .starfallReaches,
        opening: WorldFilmSpec(key: CutScene.Name.starfallOpening.rawValue) {
            .starfallOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.starfallHeld.rawValue) {
            .starfallHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.visitorCrater.id: WorldFilmSpec(key: CutScene.Name.visitorCrater.rawValue) {
                .visitorCrater(start: $0)
            }
        ]
    )

    /// Gloamdeep Caverns: the sixth world, painted the way the worlds below it are. The send-off points on out of the dark towards lights and a crowd, the way the
    /// reaches' points down under the dust to the caverns, and The Roost stops for a briefing
    /// because it stands two more animals on the board and asks two things of them at once — the
    /// same courtesy every boss pays, and the one that has most to explain.
    static let gloamdeepCaverns = GameWorld(
        theme: .gloamdeep,
        map: .gloamdeepCaverns,
        opening: WorldFilmSpec(key: CutScene.Name.gloamdeepOpening.rawValue) {
            .gloamdeepOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.gloamdeepHeld.rawValue) {
            .gloamdeepHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theRoost.id: WorldFilmSpec(key: CutScene.Name.theRoost.rawValue) {
                .theRoost(start: $0)
            }
        ]
    )

    /// Lantern Carnival: the seventh world, painted the way the worlds below it are. The send-off points on past the last stall to sand, the way the caverns' points up out
    /// of the dark towards the lights, and The Center Ring stops for a briefing because it stands
    /// a second animal on the board and asks the one thing no board has asked before — not who is
    /// in which pen, but where one pen stands in relation to the other.
    static let lanternCarnival = GameWorld(
        theme: .lanternCarnival,
        map: .lanternCarnival,
        opening: WorldFilmSpec(key: CutScene.Name.lanternOpening.rawValue) {
            .lanternOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.lanternHeld.rawValue) {
            .lanternHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theCenterRing.id: WorldFilmSpec(key: CutScene.Name.theCenterRing.rawValue) {
                .theCenterRing(start: $0)
            }
        ]
    )

    /// Sunbaked Dunes: the eighth world, painted the way the worlds below it are.
    /// The send-off points on past the last dune to a sea coming in, the way the carnival's points
    /// past the last stall to sand, and Scorpion Flats stops for a briefing because it stands a
    /// second animal on the board and takes away the discount every boss since the meadow has been
    /// allowed — one wall doing for two pens.
    static let sunbakedDunes = GameWorld(
        theme: .sunbakedDunes,
        map: .sunbakedDunes,
        opening: WorldFilmSpec(key: CutScene.Name.duneOpening.rawValue) {
            .duneOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.duneHeld.rawValue) {
            .duneHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.scorpionFlats.id: WorldFilmSpec(key: CutScene.Name.scorpionFlats.rawValue) {
                .scorpionFlats(start: $0)
            }
        ]
    )

    /// Tidepool Cove: the ninth world, painted the way the worlds below it are. The send-off points on out across the ice the tide is starting to carry in, the way
    /// the dunes' points past the last dune to the sea, and The Crab Pool stops for a briefing
    /// because it stands a second animal on the board and asks for a ring round the pool he
    /// lives in — the same courtesy every boss pays.
    static let tidepoolCove = GameWorld(
        theme: .tidepoolCove,
        map: .tidepoolCove,
        opening: WorldFilmSpec(key: CutScene.Name.tidepoolOpening.rawValue) {
            .tidepoolOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.tidepoolHeld.rawValue) {
            .tidepoolHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theCrabPool.id: WorldFilmSpec(key: CutScene.Name.theCrabPool.rawValue) {
                .theCrabPool(start: $0)
            }
        ]
    )

    /// Frostwhisker Tundra: the tenth world, painted the way the worlds below it are. The send-off points on south along the shore to where the ice gives out into mud
    /// and reeds, the way the cove's points north along the water to the ice, and The Haulout
    /// stops for a briefing because it stands a second animal on the board and is particular
    /// about the pen he gets — the same courtesy every boss pays.
    static let frostwhiskerTundra = GameWorld(
        theme: .frostwhiskerTundra,
        map: .frostwhiskerTundra,
        opening: WorldFilmSpec(key: CutScene.Name.frostwhiskerOpening.rawValue) {
            .frostwhiskerOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.frostwhiskerHeld.rawValue) {
            .frostwhiskerHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theHaulout.id: WorldFilmSpec(key: CutScene.Name.theHaulout.rawValue) {
                .theHaulout(start: $0)
            }
        ]
    )

    /// Mirebog Fen: the eleventh world, painted the way the worlds below it are. The send-off points up out of the reeds to fields hanging in the sky, the way the
    /// tundra's points south along the shore to the mud, and The Wallow stops for a briefing
    /// because it stands a second animal on the board and owes him a whole channel — the same
    /// courtesy every boss pays.
    static let mirebogFen = GameWorld(
        theme: .mirebogFen,
        map: .mirebogFen,
        opening: WorldFilmSpec(key: CutScene.Name.mirebogOpening.rawValue) {
            .mirebogOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.mirebogHeld.rawValue) {
            .mirebogHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theWallow.id: WorldFilmSpec(key: CutScene.Name.theWallow.rawValue) {
                .theWallow(start: $0)
            }
        ]
    )

    /// Cloudspire Heights: the twelfth world and the last, painted the way the eleven below it
    /// are. The send-off points nowhere, because there is nowhere left —
    /// it puts the game to bed with the pig in it — and The Eyrie stops for a briefing
    /// because it stands a second animal on the board and cares what he can see, which no
    /// board before it has cared about: the same courtesy every boss pays.
    static let cloudspireHeights = GameWorld(
        theme: .cloudspireHeights,
        map: .cloudspireHeights,
        opening: WorldFilmSpec(key: CutScene.Name.cloudspireOpening.rawValue) {
            .cloudspireOpening(start: $0)
        },
        farewell: WorldFilmSpec(key: CutScene.Name.cloudspireHeld.rawValue) {
            .cloudspireHeld(start: $0)
        },
        briefings: [
            PuzzleLevel.theEyrie.id: WorldFilmSpec(key: CutScene.Name.theEyrie.rawValue) {
                .theEyrie(start: $0)
            }
        ]
    )
}
