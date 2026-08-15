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
                    caption: "Truffles take no fence. Shut them in — five apiece.",
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
                    caption: "The boar was here first. It shares with nobody.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌲", "🌲", "🍄"],
                    caption: "Twenty pieces. Both held, in two pens — never one.",
                    isCard: true,
                    seconds: 3.2
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
                    caption: "Chestnuts take no fence. Five apiece, shut in.",
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
                    caption: "Do not fence the wyrm. Nobody is holding that.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌋", "🪨", "🌰"],
                    caption: "Twenty pieces for the pig. Leave the wyrm outside.",
                    isCard: true,
                    seconds: 3.2
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
                    caption: "Pies take no fence. Five apiece, shut in.",
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
                    caption: "You fenced the rat king in with your own pig.",
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
    /// here does — the city's own rule, which is the woods' rule turned round. The middle
    /// still is the story half: the rat king is not something to shut out or to pen off on
    /// its own, since a yard of its own is exactly what it is after.
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
                    motif: "🏙️",
                    strewn: ["🧱", "💨", "🕳️"],
                    caption: "Rat King Wharf. The last yard in the city.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐀",
                    strewn: ["🏙️", "🕳️"],
                    caption: "Pen the rat king apart and it keeps that yard.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🏙️", "🧱", "🥧"],
                    caption: "Nineteen pieces. Both held, in one pen — never two.",
                    isCard: true,
                    seconds: 3.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The reaches' films

extension StorybookScene {
    /// Before the first walk out into Starfall Reaches. It carries the two things the reaches
    /// change — a stardrop to shut in, a meteor to build around — and then hands the game back
    /// on the rule it has always been.
    ///
    /// It is the one opening with six stills in it rather than five, and the extra one is the
    /// water: every drop out here stands on its own, a single well where a star went in, and
    /// that is a thing about the ground a player cannot be left to work out from the ground.
    /// The woods, the mountain and the city all changed their water too and each of them let
    /// the board say so, because a pool and a tarn and a canal all still read as water lying
    /// about. Water broken into single tiles reads as decoration until somebody says it is a
    /// wall.
    static func starfallOpening(start: Date = .now) -> Self {
        Self(
            key: "starfall-opening",
            title: "Starfall Reaches",
            light: .starDay,
            shots: [
                Shot(
                    motif: "🌌",
                    strewn: ["✨", "🌑", "✨"],
                    caption: "Starfall Reaches. The sky keeps landing in it.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["✨", "🌑"],
                    caption: "Your pig went up off the rooftops.",
                    seconds: 2.5
                ),
                Shot(
                    motif: "💧",
                    strewn: ["✨", "🌑", "✨"],
                    caption: "Every star that lands leaves one well.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🌟",
                    strewn: ["✨", "🌑"],
                    caption: "Stardrops take no fence. Five each.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "☄️",
                    strewn: ["✨", "🌑"],
                    caption: "Meteors take no fence. Build round them.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌌", "✨"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen in the reaches holds. It says what became of the visitor, that the
    /// whole of the reaches is fenced, and — like the four send-offs before it — points on
    /// past this world to the next one waiting.
    static func starfallHeld(start: Date = .now) -> Self {
        Self(
            key: "starfall-held",
            title: "Starfall Reaches held",
            light: .starDusk,
            shots: [
                Shot(
                    motif: "🛸",
                    strewn: ["🌟", "☄️"],
                    caption: "The visitor got a pen to match your own.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🌌",
                    strewn: ["✨", "🌟", "✨"],
                    caption: "Every well in the reaches, fenced and held.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🌍",
                    strewn: ["✨", "⭐️"],
                    caption: "Nothing gets off these reaches now.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🦇",
                    strewn: ["✨", "⭐️", "✨"],
                    caption: "Under the dust, a cavern is breathing out.",
                    isCard: true,
                    seconds: 3.4
                )
            ],
            start: start
        )
    }

    /// Before the reaches' last field, the way `ratKingWharf` goes before the city's.
    ///
    /// Short, and for the same reason: a player standing at this signpost has fenced eight
    /// stretches of dust and is owed the one thing this board does that no other board up here
    /// does — the reaches' own rule, which is the first one that asks for two pens *and* says
    /// how much ground each of them holds. The middle still is the story half: the visitor is
    /// not something to shut out and not something to share with either.
    ///
    /// It is lit for daylight where the send-off is lit after dark, because a briefing wants
    /// reading rather than admiring.
    static func visitorCrater(start: Date = .now) -> Self {
        Self(
            key: "visitor-crater-briefing",
            title: "Visitor Crater",
            light: .starDay,
            shots: [
                Shot(
                    motif: "🌠",
                    strewn: ["✨", "🌑", "☄️"],
                    caption: "Visitor Crater. The newest ground there is.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🛸",
                    strewn: ["🌌", "🌟"],
                    caption: "The visitor wants as much ground as the pig.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🌌", "✨", "🌟"],
                    caption: "Twenty pieces. Two pens, and neither one bigger.",
                    isCard: true,
                    seconds: 3.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The caverns' films

extension StorybookScene {
    /// Before the first walk down into Gloamdeep Caverns. It carries the two things the caverns
    /// change — a crystal to shut in, a boulder to build around — and hands the game back on the
    /// rule it has always been.
    ///
    /// It has six stills, the way the reaches' opening does, and the extra one is the water
    /// again: down here every board has exactly one river on it and that river always comes in
    /// off the edge of the cave. The reaches had to say their water was single drops because
    /// drops read as decoration. The caverns have to say the opposite — that there is only ever
    /// one of it — because a player who has just come off boards scattered with wells will look
    /// for a second body of water on every board of this world and never find one.
    static func gloamdeepOpening(start: Date = .now) -> Self {
        Self(
            key: "gloamdeep-opening",
            title: "Gloamdeep Caverns",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🕳️",
                    strewn: ["💎", "🪨", "💧"],
                    caption: "Gloamdeep Caverns. Under it all, in the dark.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["💎", "🪨"],
                    caption: "Your pig went down a hole in the dust.",
                    seconds: 2.5
                ),
                Shot(
                    motif: "💧",
                    strewn: ["💎", "🪨", "💧"],
                    caption: "One river to a cave, and never two.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "💎",
                    strewn: ["💧", "🪨"],
                    caption: "Crystals take no fence. Five each.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🪨",
                    strewn: ["💎", "💧"],
                    caption: "Boulders take no fence. Build round them.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🕳️", "💎"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen in the caverns holds. It says what became of the roost, that the whole
    /// of the Gloamdeep is fenced, and — like the five send-offs before it — points on past this
    /// world to the next one waiting.
    static func gloamdeepHeld(start: Date = .now) -> Self {
        Self(
            key: "gloamdeep-held",
            title: "Gloamdeep Caverns held",
            light: .gloamDusk,
            shots: [
                Shot(
                    motif: "🦇",
                    strewn: ["💎", "🪨"],
                    caption: "The roost hangs together. The pig sleeps apart.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "💎",
                    strewn: ["💧", "🦇", "💧"],
                    caption: "Every crystal in the Gloamdeep, fenced and held.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["💎", "🪨"],
                    caption: "Nothing comes up out of these caves now.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🤹",
                    strewn: ["💎", "🎪", "💎"],
                    caption: "Up ahead there is music, and far too many lights.",
                    isCard: true,
                    seconds: 3.4
                )
            ],
            start: start
        )
    }

    /// Before the caverns' last field, the way `visitorCrater` goes before the reaches'.
    ///
    /// Short, and for the same reason: a player standing at this signpost has fenced eight caves
    /// and is owed the one thing this board does that no other board down here does. It is the
    /// only rule in the game that asks two things at once *and* stands three animals on the
    /// ground — the bat and its pup in one pen, the pig in another — so the middle still is the
    /// story half and the card is the arithmetic.
    ///
    /// It is lit for the caverns' own light where the send-off is lit with it out, because a
    /// briefing wants reading rather than admiring.
    static func theRoost(start: Date = .now) -> Self {
        Self(
            key: "the-roost-briefing",
            title: "The Roost",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🦇",
                    strewn: ["💎", "🪨", "💧"],
                    caption: "The Roost. Two bats hanging over one river.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦇", "💎"],
                    caption: "A pup hangs where its mother does. Not by a pig.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦇", "💧", "💎"],
                    caption: "Twenty pieces. Both bats in one pen, pig in another.",
                    isCard: true,
                    seconds: 3.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The carnival's films

extension StorybookScene {
    /// Before the first walk in through the gate of the Lantern Carnival. It carries the two
    /// things the carnival changes — a toffee apple to shut in, a guy rope to build around — and
    /// hands the game back on the rule it has always been.
    ///
    /// Six stills, the way the reaches' and the caverns' openings have, and the extra one is the
    /// world's own idea rather than its water. Every world so far has staked its hazard about the
    /// board one tile at a time; here they come pegged out in straight runs, and a run of them is
    /// a line no wall crosses. A player who reads a rope as one more thing to step round will
    /// build square pens all the way through this world and never understand why they will not
    /// close, so the film says it before the first board does.
    static func lanternOpening(start: Date = .now) -> Self {
        Self(
            key: "lantern-opening",
            title: "Lantern Carnival",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🎪",
                    strewn: ["🍭", "🪢", "🎡"],
                    caption: "Lantern Carnival. Music, lights, and a crowd.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🍭", "🪢"],
                    caption: "Your pig went in under the tent flap.",
                    seconds: 2.4
                ),
                Shot(
                    motif: "👥",
                    strewn: ["🎪", "🍭", "👥"],
                    caption: "The crowd will not move. Lean on it for free.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🍭",
                    strewn: ["👥", "🪢"],
                    caption: "Toffee apples take no fence. Five each.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🪢",
                    strewn: ["🍭", "👥"],
                    caption: "Guy ropes take no fence, and they run in lines.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🎪", "🍭"],
                    caption: "Same as the meadow. Fence it in, big and shut.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }

    /// After the last pen in the carnival holds. It says what became of the ringmaster, that the
    /// whole fairground is fenced, and — like the six send-offs before it — points on past this
    /// world to the next one waiting.
    static func lanternHeld(start: Date = .now) -> Self {
        Self(
            key: "lantern-held",
            title: "Lantern Carnival held",
            light: .lanternDusk,
            shots: [
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "👥"],
                    caption: "The ringmaster has his ring. The pig has the rest.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🍭",
                    strewn: ["🪢", "🎪", "🪢"],
                    caption: "Every toffee apple on the field, fenced and held.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🎡",
                    strewn: ["🍭", "👥"],
                    caption: "The lights go out one string at a time.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🦂",
                    strewn: ["🏜️", "🍭", "🏜️"],
                    caption: "Past the last stall, sand as far as it goes.",
                    isCard: true,
                    seconds: 3.2
                )
            ],
            start: start
        )
    }

    /// Before the carnival's last field, the way `theRoost` goes before the caverns'.
    ///
    /// Short, and for the same reason: a player standing at this signpost has fenced eight
    /// fairgrounds and is owed the one thing this board does that no other board here does. It is
    /// the only rule in the game about where one pen stands in relation to another rather than
    /// about who is in which, so the middle still is the whole of it said in a line.
    static func theCentreRing(start: Date = .now) -> Self {
        Self(
            key: "the-centre-ring-briefing",
            title: "The Centre Ring",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "👥", "🍭"],
                    caption: "The Centre Ring. He will not step aside.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🤹", "👥"],
                    caption: "He keeps the middle. Take the ring round him.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🤹", "👥", "🍭"],
                    caption: "Twenty-two pieces, and they meet where they started.",
                    isCard: true,
                    seconds: 3.4
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
            .cogsworthOpening(), .ratKingWharf(), .cogsworthHeld(),
            .starfallOpening(), .visitorCrater(), .starfallHeld(),
            .gloamdeepOpening(), .theRoost(), .gloamdeepHeld(),
            .lanternOpening(), .theCentreRing(), .lanternHeld()
        ]
    }
}
