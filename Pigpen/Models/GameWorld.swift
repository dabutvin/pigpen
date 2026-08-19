import Foundation

/// A film a world plays, whichever kind it is: the meadow's hand-painted `CutScene`, or a
/// themed world's lighter `StorybookScene`. One type so a single screen can present either and
/// a world can be wrapped in whichever it has.
enum WorldFilm: Sendable, Identifiable {
    case painted(CutScene)
    case storybook(StorybookScene)

    /// A film on screen is told apart by its key, so presenting a new one swaps the screen.
    var id: String { key }

    /// What the world remembers the film by, so it plays once and is never shown twice.
    var key: String {
        switch self {
        case .painted(let scene): scene.name.rawValue
        case .storybook(let scene): scene.key
        }
    }

    var runtime: TimeInterval {
        switch self {
        case .painted(let scene): scene.runtime
        case .storybook(let scene): scene.runtime
        }
    }
}

/// A film a world owns but has not started yet: the key it is tracked by, and how to raise the
/// curtain on it at a given moment. Held apart from the film itself so asking whether a film is
/// owed does not build one, and presenting it starts its clock fresh.
struct WorldFilmSpec: Sendable {
    let key: String
    let make: @Sendable (Date) -> WorldFilm

    /// The film, its clock started now.
    func raise(at start: Date = .now) -> WorldFilm { make(start) }
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
        opening: WorldFilmSpec(key: CutScene.Name.opening.rawValue) { .painted(.opening(start: $0)) },
        farewell: WorldFilmSpec(key: CutScene.Name.theMeadowHeld.rawValue) {
            .painted(.theMeadowHeld(start: $0))
        },
        briefings: [
            PuzzleLevel.stagMere.id: WorldFilmSpec(key: CutScene.Name.stagMere.rawValue) {
                .painted(.stagMere(start: $0))
            }
        ]
    )

    /// Thornwood Thicket: the second world, wrapped in storybook films until it earns painted
    /// ones. The send-off points on past the trees, the way the meadow's points past the hills,
    /// and Boar Hollow stops for a briefing the way Stag Mere does — it is the same board with
    /// the same twist on it, and the woods should no more spring a second animal on a player
    /// than the meadow did.
    static let thornwoodThicket = GameWorld(
        theme: .thornwood,
        map: .thornwoodThicket,
        opening: WorldFilmSpec(key: "thornwood-opening") { .storybook(.thornwoodOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "thornwood-held") { .storybook(.thornwoodHeld(start: $0)) },
        briefings: [
            PuzzleLevel.boarHollow.id: WorldFilmSpec(key: "boar-hollow-briefing") {
                .storybook(.boarHollow(start: $0))
            }
        ]
    )

    /// Emberpeak: the third world, wrapped in storybook films the way the thicket is. The
    /// send-off points on down the far side of the mountain to the city, the way the
    /// thicket's points past the trees to the mountain, and Wyrm Caldera stops for a briefing
    /// because it stands a second animal on the board — the same courtesy Stag Mere and Boar
    /// Hollow pay.
    static let emberpeak = GameWorld(
        theme: .emberpeak,
        map: .emberpeak,
        opening: WorldFilmSpec(key: "emberpeak-opening") { .storybook(.emberpeakOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "emberpeak-held") { .storybook(.emberpeakHeld(start: $0)) },
        briefings: [
            PuzzleLevel.wyrmCaldera.id: WorldFilmSpec(key: "wyrm-caldera-briefing") {
                .storybook(.wyrmCaldera(start: $0))
            }
        ]
    )

    /// Cogsworth City: the fourth world, wrapped in storybook films the way the two worlds
    /// below it are. The send-off points on up past the rooftops to something coming down
    /// out of the stars, the way the mountain's points down off the peak to the city, and
    /// Rat King Wharf stops for a briefing because it stands a second animal on the board —
    /// the same courtesy every boss before it pays.
    static let cogsworthCity = GameWorld(
        theme: .cogsworth,
        map: .cogsworthCity,
        opening: WorldFilmSpec(key: "cogsworth-opening") { .storybook(.cogsworthOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "cogsworth-held") { .storybook(.cogsworthHeld(start: $0)) },
        briefings: [
            PuzzleLevel.ratKingWharf.id: WorldFilmSpec(key: "rat-king-wharf-briefing") {
                .storybook(.ratKingWharf(start: $0))
            }
        ]
    )

    /// Starfall Reaches: the fifth world, wrapped in storybook films the way the three below
    /// it are. The send-off points on down into the dark under the dust, the way the city's
    /// points up off the rooftops to the reaches, and Visitor Crater stops for a briefing
    /// because it stands a second animal on the board — the same courtesy every boss pays.
    static let starfallReaches = GameWorld(
        theme: .starfall,
        map: .starfallReaches,
        opening: WorldFilmSpec(key: "starfall-opening") { .storybook(.starfallOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "starfall-held") { .storybook(.starfallHeld(start: $0)) },
        briefings: [
            PuzzleLevel.visitorCrater.id: WorldFilmSpec(key: "visitor-crater-briefing") {
                .storybook(.visitorCrater(start: $0))
            }
        ]
    )

    /// Gloamdeep Caverns: the sixth world, wrapped in storybook films the way the four below it
    /// are. The send-off points on out of the dark towards lights and a crowd, the way the
    /// reaches' points down under the dust to the caverns, and The Roost stops for a briefing
    /// because it stands two more animals on the board and asks two things of them at once — the
    /// same courtesy every boss pays, and the one that has most to explain.
    static let gloamdeepCaverns = GameWorld(
        theme: .gloamdeep,
        map: .gloamdeepCaverns,
        opening: WorldFilmSpec(key: "gloamdeep-opening") { .storybook(.gloamdeepOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "gloamdeep-held") { .storybook(.gloamdeepHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theRoost.id: WorldFilmSpec(key: "the-roost-briefing") {
                .storybook(.theRoost(start: $0))
            }
        ]
    )

    /// Lantern Carnival: the seventh world, wrapped in storybook films the way the five below it
    /// are. The send-off points on past the last stall to sand, the way the caverns' points up out
    /// of the dark towards the lights, and The Center Ring stops for a briefing because it stands
    /// a second animal on the board and asks the one thing no board has asked before — not who is
    /// in which pen, but where one pen stands in relation to the other.
    static let lanternCarnival = GameWorld(
        theme: .lanternCarnival,
        map: .lanternCarnival,
        opening: WorldFilmSpec(key: "lantern-opening") { .storybook(.lanternOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "lantern-held") { .storybook(.lanternHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theCenterRing.id: WorldFilmSpec(key: "the-centre-ring-briefing") {
                .storybook(.theCenterRing(start: $0))
            }
        ]
    )

    /// Sunbaked Dunes: the eighth world, wrapped in storybook films the way the six below it are.
    /// The send-off points on past the last dune to a sea coming in, the way the carnival's points
    /// past the last stall to sand, and Scorpion Flats stops for a briefing because it stands a
    /// second animal on the board and takes away the discount every boss since the meadow has been
    /// allowed — one wall doing for two pens.
    static let sunbakedDunes = GameWorld(
        theme: .sunbakedDunes,
        map: .sunbakedDunes,
        opening: WorldFilmSpec(key: "dune-opening") { .storybook(.duneOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "dune-held") { .storybook(.duneHeld(start: $0)) },
        briefings: [
            PuzzleLevel.scorpionFlats.id: WorldFilmSpec(key: "scorpion-flats-briefing") {
                .storybook(.theScorpionPit(start: $0))
            }
        ]
    )

    /// Tidepool Cove: the ninth world, wrapped in storybook films the way the eight below it
    /// are. The send-off points on out across the ice the tide is starting to carry in, the way
    /// the dunes' points past the last dune to the sea, and The Crab Pool stops for a briefing
    /// because it stands a second animal on the board and asks for a ring round the pool he
    /// lives in — the same courtesy every boss pays.
    static let tidepoolCove = GameWorld(
        theme: .tidepoolCove,
        map: .tidepoolCove,
        opening: WorldFilmSpec(key: "tidepool-opening") { .storybook(.tidepoolOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "tidepool-held") { .storybook(.tidepoolHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theCrabPool.id: WorldFilmSpec(key: "the-crab-pool-briefing") {
                .storybook(.theCrabPool(start: $0))
            }
        ]
    )

    /// Frostwhisker Tundra: the tenth world, wrapped in storybook films the way the nine below
    /// it are. The send-off points on south along the shore to where the ice gives out into mud
    /// and reeds, the way the cove's points north along the water to the ice, and The Haulout
    /// stops for a briefing because it stands a second animal on the board and is particular
    /// about the pen he gets — the same courtesy every boss pays.
    static let frostwhiskerTundra = GameWorld(
        theme: .frostwhiskerTundra,
        map: .frostwhiskerTundra,
        opening: WorldFilmSpec(key: "frostwhisker-opening") { .storybook(.frostwhiskerOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "frostwhisker-held") { .storybook(.frostwhiskerHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theHaulout.id: WorldFilmSpec(key: "the-haulout-briefing") {
                .storybook(.theHaulout(start: $0))
            }
        ]
    )

    /// Mirebog Fen: the eleventh world, wrapped in storybook films the way the ten below it
    /// are. The send-off points up out of the reeds to fields hanging in the sky, the way the
    /// tundra's points south along the shore to the mud, and The Wallow stops for a briefing
    /// because it stands a second animal on the board and owes him a whole channel — the same
    /// courtesy every boss pays.
    static let mirebogFen = GameWorld(
        theme: .mirebogFen,
        map: .mirebogFen,
        opening: WorldFilmSpec(key: "mirebog-opening") { .storybook(.mirebogOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "mirebog-held") { .storybook(.mirebogHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theWallow.id: WorldFilmSpec(key: "the-wallow-briefing") {
                .storybook(.theWallow(start: $0))
            }
        ]
    )

    /// Cloudspire Heights: the twelfth world and the last, wrapped in storybook films the way
    /// the eleven below it are. The send-off points nowhere, because there is nowhere left —
    /// it puts the game to bed with the pig in it — and The Eyrie stops for a briefing
    /// because it stands a second animal on the board and cares what he can see, which no
    /// board before it has cared about: the same courtesy every boss pays.
    static let cloudspireHeights = GameWorld(
        theme: .cloudspireHeights,
        map: .cloudspireHeights,
        opening: WorldFilmSpec(key: "cloudspire-opening") { .storybook(.cloudspireOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "cloudspire-held") { .storybook(.cloudspireHeld(start: $0)) },
        briefings: [
            PuzzleLevel.theEyrie.id: WorldFilmSpec(key: "the-eyrie-briefing") {
                .storybook(.theEyrie(start: $0))
            }
        ]
    )
}
