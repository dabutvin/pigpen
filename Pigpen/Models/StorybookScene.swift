import Foundation

/// A film for a themed world, told in storybook stills rather than the meadow's hand-painted
/// shots.
///
/// The meadow's three films are drawn frame by frame in a canvas — a whole sky and ridge and
/// run of grass per shot — which is glorious and a great deal of code, and every world cannot
/// have one before it can be played at all. A `StorybookScene` is the lighter machine that
/// lets a new world still open and close on a film: a themed backdrop, a motif held over it,
/// and a line of type, timed exactly the way a `CutScene` is so it opens out of black, letters
/// its picture, and hands the player on when the last still has gone. A world can graduate to a
/// painted `CutScene` later; until then this is what wraps it.
///
/// Like every other clock in the game — the pasture, the lap of honour, the meadow's own films
/// — it is written as a function of time rather than a queue of steps, so a still of any moment
/// of it can be taken and skipping it is walking away from the clock rather than unwinding
/// half-finished animation.
struct StorybookScene: Sendable {
    /// What the world remembers this film by, so a scene watched or skipped is not shown twice.
    let key: String
    /// The world and film this is, for a screen read aloud rather than watched.
    let title: String
    /// The light this film is shot in, its own business rather than the phone's — the same
    /// reason the meadow's opening is at sunrise on a screen set to dark.
    let light: GamePalette.Pasture
    let shots: [Shot]
    /// The moment the curtain went up.
    let start: Date

    init(key: String, title: String, light: GamePalette.Pasture, shots: [Shot], start: Date = .now) {
        self.key = key
        self.title = title
        self.light = light
        self.shots = shots
        self.start = start
    }

    /// One still: the motif held over the backdrop, the line over it, and how long it holds.
    struct Shot: Equatable, Sendable, Identifiable {
        /// The big glyph the still is built around.
        let motif: String
        /// A few smaller glyphs strewn behind it, for the world it is set in.
        let strewn: [String]
        let caption: String
        /// Whether the line is the point of the still and set big in the middle, the way the
        /// meadow's hand-off shots are, rather than tucked along the bottom.
        let isCard: Bool
        let seconds: TimeInterval

        var id: String { motif + caption }

        init(
            motif: String,
            strewn: [String] = [],
            caption: String,
            isCard: Bool = false,
            seconds: TimeInterval
        ) {
            self.motif = motif
            self.strewn = strewn
            self.caption = caption
            self.isCard = isCard
            self.seconds = seconds
        }
    }

    // MARK: - Timing

    /// How long the whole film runs.
    var runtime: TimeInterval { shots.reduce(0) { $0 + $1.seconds } }

    /// What is on screen one moment in: which still, where it comes, and how long it has held —
    /// which is what the caption and the cut flash are timed off. The same shape as a
    /// `CutScene.Frame`, so one view can play either.
    struct Frame: Equatable, Sendable {
        let index: Int
        let shot: Shot
        let seconds: TimeInterval

        var progress: Double {
            guard shot.seconds > 0 else { return 1 }
            return min(max(seconds / shot.seconds, 0), 1)
        }

        var captionOpacity: Double {
            let arriving = (seconds - CutScene.captionDelay) / CutScene.captionFade
            let leaving = (shot.seconds - seconds) / CutScene.captionFade
            return min(max(min(arriving, leaving), 0), 1)
        }

        var flash: Double {
            max(0, 1 - seconds / CutScene.flash)
        }
    }

    /// The still on screen `elapsed` seconds in, or nothing once the film has run out.
    func frame(secondsIn elapsed: TimeInterval) -> Frame? {
        guard elapsed > 0 else {
            return shots.first.map { Frame(index: 0, shot: $0, seconds: 0) }
        }

        var left = elapsed
        for (index, shot) in shots.enumerated() {
            if left < shot.seconds {
                return Frame(index: index, shot: shot, seconds: left)
            }
            left -= shot.seconds
        }
        return nil
    }

    /// How much black is over the picture: all of it at the start, gone in the middle, back
    /// over everything as it hands the player on.
    func curtain(secondsIn elapsed: TimeInterval) -> Double {
        let opening = 1 - elapsed / CutScene.fade
        let closing = 1 - (runtime - elapsed) / CutScene.fade
        return min(max(max(opening, closing), 0), 1)
    }

    /// How far the letterbox bars are in, 0 to 1. They slide in and stay.
    func letterbox(secondsIn elapsed: TimeInterval) -> Double {
        min(max(elapsed / CutScene.fade, 0), 1)
    }

    /// Waits out the film, returning whether it ran to the end. A skip takes the screen away
    /// and cancels the wait, so nobody is handed on twice.
    @MainActor
    @discardableResult
    func waitOut() async -> Bool {
        do {
            try await Task.sleep(for: .seconds(runtime))
            return true
        } catch {
            return false
        }
    }
}

// MARK: - The thicket's films

extension StorybookScene {
    /// Before the first walk into Thornwood Thicket. It carries the one thing the woods
    /// change — a truffle to shut in, a bramble to keep out — and then says the rule is the
    /// meadow's rule: the biggest pen you can, shut.
    static func thornwoodOpening(start: Date = .now) -> Self {
        Self(
            key: "thornwood-opening",
            title: "Thornwood Thicket",
            light: .forestDay,
            shots: [
                Shot(
                    motif: "🌲",
                    strewn: ["🌲", "🌲", "🍂"],
                    caption: "Thornwood Thicket. The trees close right over.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌿", "🍂"],
                    caption: "Your pig made the tree line before you did.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🍄",
                    strewn: ["🌿", "🍂", "🌿"],
                    caption: "Truffles in the leaf mould. Shut them in — five apiece.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🥀",
                    strewn: ["🌿", "🍂"],
                    caption: "Brambles in the dark. Leave those on the outside.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌲", "🌲"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen in the thicket holds. It says what became of the boar, that every
    /// clearing is fenced, and — like the meadow's send-off — points past the trees to the
    /// next world coming alight.
    static func thornwoodHeld(start: Date = .now) -> Self {
        Self(
            key: "thornwood-held",
            title: "Thornwood Thicket held",
            light: .forestDusk,
            shots: [
                Shot(
                    motif: "🐗",
                    strewn: ["🌲", "🍄"],
                    caption: "The boar kept to its hollow. You kept the pig to its pens.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🌲",
                    strewn: ["🍄", "✨", "🍄"],
                    caption: "Every clearing in the Thornwood, fenced and held.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🌍",
                    strewn: ["✨", "⭐️"],
                    caption: "Nothing gets out of the Thornwood now.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["✨", "⭐️", "✨"],
                    caption: "Past the trees, a mountain is smoking.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// Before the thicket's last clearing, the way `CutScene.stagMere` goes before the meadow's.
    ///
    /// Short on purpose, and for the same reason: a player standing at this signpost has fenced
    /// eight fields of woods and does not need teaching how to fence a ninth. What they are owed
    /// is the one thing this board does that no other board in the thicket does — there is a
    /// second animal on it and a single budget for the pair — and that is three stills and under
    /// nine seconds. The middle one is the story half, the same as the mere's: the far bank is
    /// not empty ground, so the pen there is making room for what already lives in the hollow
    /// rather than walling it out.
    ///
    /// It is lit for daylight where the thicket's send-off is lit after dark, because a briefing
    /// wants reading rather than admiring.
    static func boarHollow(start: Date = .now) -> Self {
        Self(
            key: "boar-hollow-briefing",
            title: "Boar Hollow",
            light: .forestDay,
            shots: [
                Shot(
                    motif: "🌊",
                    strewn: ["🌲", "🍂", "🌿"],
                    caption: "Boar Hollow. A pool across the wood.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐗",
                    strewn: ["🌲", "🍄"],
                    caption: "The boar had this hollow before you did.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌲", "🌲", "🍄"],
                    caption: "Twenty pieces. Both of them held, or neither counts.",
                    isCard: true,
                    seconds: 3.3
                )
            ],
            start: start
        )
    }
}

// MARK: - The mountain's films

extension StorybookScene {
    /// Before the first walk up Emberpeak. It carries the two things the mountain changes —
    /// a chestnut to shut in, an ember to keep out — says out loud that the ember takes no
    /// fencing, since every field up here has one on it, and then hands the game back on the
    /// rule it has always been.
    static func emberpeakOpening(start: Date = .now) -> Self {
        Self(
            key: "emberpeak-opening",
            title: "Emberpeak",
            light: .emberDay,
            shots: [
                Shot(
                    motif: "🌋",
                    strewn: ["🪨", "🌫️", "🪨"],
                    caption: "Emberpeak. It has been smoking since the barn was built.",
                    seconds: 3.6
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🪨", "🌫️"],
                    caption: "Your pig went up past the last of the trees.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🌰",
                    strewn: ["🪨", "🌫️", "🪨"],
                    caption: "Chestnuts roasting where they fell. Five apiece, shut in.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🔥",
                    strewn: ["🪨", "🌫️"],
                    caption: "Embers take no fence. Build around them, or pay the five.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌋", "🪨"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen on the mountain holds. It says what became of the wyrm, that the
    /// whole peak is fenced, and — like the meadow's send-off and the thicket's — points on
    /// past this world to the next one waiting.
    static func emberpeakHeld(start: Date = .now) -> Self {
        Self(
            key: "emberpeak-held",
            title: "Emberpeak held",
            light: .emberDusk,
            shots: [
                Shot(
                    motif: "🐉",
                    strewn: ["🌋", "🌰"],
                    caption: "The wyrm kept to its crater. You kept the pig to its pens.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["🔥", "✨", "🔥"],
                    caption: "Every shelf on Emberpeak, fenced and held.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🌍",
                    strewn: ["✨", "⭐️"],
                    caption: "Nothing gets off this mountain now.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["✨", "⭐️", "✨"],
                    caption: "Below the ash, a city is lighting its lamps.",
                    isCard: true,
                    seconds: 3.2
                )
            ],
            start: start
        )
    }

    /// Before the mountain's last field, the way `boarHollow` goes before the thicket's and
    /// `CutScene.stagMere` before the meadow's.
    ///
    /// Short, and for the same reason: a player standing at this signpost has fenced eight
    /// fields of scree and is owed the one thing this board does that no other board up here
    /// does — a second animal on it and a single budget for the pair. The middle still is the
    /// story half: the crater floor is not spare ground, it is somewhere something already
    /// lives, and the pen down there is making room for it rather than shutting it out.
    ///
    /// It is lit for daylight where the send-off is lit after dark, because a briefing wants
    /// reading rather than admiring.
    static func wyrmCaldera(start: Date = .now) -> Self {
        Self(
            key: "wyrm-caldera-briefing",
            title: "Wyrm Caldera",
            light: .emberDay,
            shots: [
                Shot(
                    motif: "🌊",
                    strewn: ["🌋", "🪨", "🌫️"],
                    caption: "Wyrm Caldera. A lake in the summit.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐉",
                    strewn: ["🌋", "🔥"],
                    caption: "The wyrm had this crater long before you did.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌋", "🪨", "🌰"],
                    caption: "Twenty pieces. Both of them held, or neither counts.",
                    isCard: true,
                    seconds: 3.3
                )
            ],
            start: start
        )
    }
}

// MARK: - The city's films

extension StorybookScene {
    /// Before the first walk into Cogsworth City. It carries the two things the city changes
    /// — a pie to shut in, a drain to build around — says out loud that the water down here
    /// is cut one tile wide rather than lying about in ponds, and then hands the game back on
    /// the rule it has always been.
    static func cogsworthOpening(start: Date = .now) -> Self {
        Self(
            key: "cogsworth-opening",
            title: "Cogsworth City",
            light: .cityDay,
            shots: [
                Shot(
                    motif: "🏙️",
                    strewn: ["🧱", "💨", "🧱"],
                    caption: "Cogsworth City. Everything in it was built by somebody.",
                    seconds: 3.6
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🧱", "💨"],
                    caption: "Your pig came in under the gate and kept going.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🥧",
                    strewn: ["🧱", "🪟", "🧱"],
                    caption: "Pies dropped outside the shops. Five apiece, shut in.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["🧱", "💨"],
                    caption: "Drains take no fence. Build around them, or pay the five.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🏙️", "🧱"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen in the city holds. It says what became of the rat king, that every
    /// yard is fenced, and — like the three send-offs before it — points on past this world
    /// to the next one waiting.
    static func cogsworthHeld(start: Date = .now) -> Self {
        Self(
            key: "cogsworth-held",
            title: "Cogsworth City held",
            light: .cityDusk,
            shots: [
                Shot(
                    motif: "🐀",
                    strewn: ["🏙️", "🥧"],
                    caption: "The rat king kept its wharf. You kept the pig to its pens.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["🪔", "✨", "🪔"],
                    caption: "Every yard in Cogsworth, fenced and held.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🌍",
                    strewn: ["✨", "⭐️"],
                    caption: "Nothing gets out of this city now.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🛸",
                    strewn: ["✨", "⭐️", "✨"],
                    caption: "Above the rooftops, something came down out of the stars.",
                    isCard: true,
                    seconds: 3.4
                )
            ],
            start: start
        )
    }

    /// Before the city's last field, the way `wyrmCaldera` goes before the mountain's.
    ///
    /// Short, and for the same reason: a player standing at this signpost has fenced eight
    /// yards of paving and is owed the one thing this board does that no other board down
    /// here does — a second animal on it and a single budget for the pair. The middle still
    /// is the story half: the far quay is not spare ground, it is somewhere something already
    /// lives, and the pen over there is making room for it rather than shutting it out.
    ///
    /// It is lit for daylight where the send-off is lit after dark, because a briefing wants
    /// reading rather than admiring.
    static func ratKingWharf(start: Date = .now) -> Self {
        Self(
            key: "rat-king-wharf-briefing",
            title: "Rat King Wharf",
            light: .cityDay,
            shots: [
                Shot(
                    motif: "🌊",
                    strewn: ["🏙️", "🧱", "💨"],
                    caption: "Rat King Wharf. A canal through the middle.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐀",
                    strewn: ["🏙️", "🕳️"],
                    caption: "The rat king had this wharf before you did.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🏙️", "🧱", "🥧"],
                    caption: "Twenty pieces. Both of them held, or neither counts.",
                    isCard: true,
                    seconds: 3.3
                )
            ],
            start: start
        )
    }
}

extension StorybookScene {
    /// Every storybook film the game has, for the tests to walk the way `CutScene.all` is.
    static var all: [StorybookScene] {
        [
            .thornwoodOpening(), .boarHollow(), .thornwoodHeld(),
            .emberpeakOpening(), .wyrmCaldera(), .emberpeakHeld(),
            .cogsworthOpening(), .ratKingWharf(), .cogsworthHeld()
        ]
    }
}
