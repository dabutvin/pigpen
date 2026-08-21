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
    /// Before the first walk into Thornwood Thicket: a secluded, wooded, very private listing, its
    /// mushrooms a charming amenity and its wilted flowers a blow to the curb appeal.
    static func thornwoodOpening(start: Date = .now) -> Self {
        Self(
            key: "thornwood-opening",
            title: "Thornwood Thicket",
            light: .forestDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌲", "🍂"],
                    caption: "Thornwood Thicket. Secluded. Wooded. Very private.",
                    seconds: 3.4
                ),
                Shot(
                    motif: "🍄",
                    strewn: ["🥀", "🌿"],
                    caption: "Mushrooms are a charming local amenity. Wilted flowers do nothing for curb appeal.",
                    seconds: 5.0
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌲", "🍄"],
                    caption: "Pig was beginning to see himself as a country-estate sort of pig.",
                    isCard: true,
                    seconds: 4.2
                )
            ],
            start: start
        )
    }

    /// The thicket's boss briefing: Pig meets the neighbour, and both agree on separate units.
    static func boarHollow(start: Date = .now) -> Self {
        Self(
            key: "boar-hollow-briefing",
            title: "Boar Hollow",
            light: .forestDay,
            shots: [
                Shot(
                    motif: "🐗",
                    strewn: ["🌲", "🍄"],
                    caption: "Then Pig met the neighbor.",
                    seconds: 2.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐗", "🌲"],
                    caption: "They agreed immediately on one thing: separate units.",
                    seconds: 3.6
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐗", "🍄"],
                    caption: "Fence in Pig and the boar separately. Shared walls are not permitted.",
                    isCard: true,
                    seconds: 4.4
                )
            ],
            start: start
        )
    }

    /// After the last pen in the thicket holds: private and almost perfect, until a listing with
    /// spectacular mountain views tempts the pig on.
    static func thornwoodHeld(start: Date = .now) -> Self {
        Self(
            key: "thornwood-held",
            title: "Thornwood Thicket held",
            light: .forestDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🐗", "🌲"],
                    caption: "Private. Peaceful. Spacious. Almost perfect.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["🌲", "✨"],
                    caption: "Then Pig spotted a listing with spectacular mountain views.",
                    seconds: 3.9
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["🌲", "🔥"],
                    caption: "The description did not mention the volcano.",
                    isCard: true,
                    seconds: 3.1
                )
            ],
            start: start
        )
    }
}

// MARK: - The mountain's films

extension StorybookScene {
    /// Before the first walk up Emberpeak: dramatic views and natural heating, its chestnuts a perk
    /// and its open flames a maintenance concern.
    static func emberpeakOpening(start: Date = .now) -> Self {
        Self(
            key: "emberpeak-opening",
            title: "Emberpeak",
            light: .emberDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌋", "🪨"],
                    caption: "Welcome to Emberpeak. Dramatic views. Naturally heated.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🌰",
                    strewn: ["🔥", "🪨"],
                    caption: "Chestnuts are a nice perk. Open flames are a maintenance concern.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌋", "🌫️"],
                    caption: "Pig was willing to overlook a few issues for the right property.",
                    isCard: true,
                    seconds: 4.2
                )
            ],
            start: start
        )
    }

    /// The mountain's boss briefing: the seller undersold the local wildlife, and the wyrm stays out.
    static func wyrmCaldera(start: Date = .now) -> Self {
        Self(
            key: "wyrm-caldera-briefing",
            title: "Wyrm Caldera",
            light: .emberDay,
            shots: [
                Shot(
                    motif: "🐉",
                    strewn: ["🌋", "🔥"],
                    caption: "The seller had disclosed some local wildlife. They had undersold it.",
                    seconds: 4.3
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐉", "🪨"],
                    caption: "This neighbor will not be joining the homeowners association.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐉", "🌋"],
                    caption: "Fence in Pig. Keep the wyrm out. Very, very out.",
                    isCard: true,
                    seconds: 3.3
                )
            ],
            start: start
        )
    }

    /// After the last pen on the mountain holds: unbeatable heating, and a city lighting up below.
    static func emberpeakHeld(start: Date = .now) -> Self {
        Self(
            key: "emberpeak-held",
            title: "Emberpeak held",
            light: .emberDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌋", "🔥"],
                    caption: "The views were excellent. The heating bill was unbeatable.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["🌋", "✨"],
                    caption: "Still, Pig wondered if city living might be more fun.",
                    seconds: 3.6
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["✨", "🌫️"],
                    caption: "At least cities had building codes. Probably.",
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
    /// Before the first walk into Cogsworth City: walkable, vibrant, close to everything, with fresh
    /// pie nearby and mystery drains underfoot.
    static func cogsworthOpening(start: Date = .now) -> Self {
        Self(
            key: "cogsworth-opening",
            title: "Cogsworth City",
            light: .cityDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🏙️", "🧱"],
                    caption: "Cogsworth City. Walkable. Vibrant. Close to everything.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🥧",
                    strewn: ["🕳️", "🧱"],
                    caption: "Fresh pie nearby adds value. Mystery drains do not.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🏙️", "🪟"],
                    caption: "Pig could get used to city living.",
                    isCard: true,
                    seconds: 2.6
                )
            ],
            start: start
        )
    }

    /// The city's boss briefing: the apartment came with a roommate who was never leaving.
    static func ratKingWharf(start: Date = .now) -> Self {
        Self(
            key: "rat-king-wharf-briefing",
            title: "Rat King Wharf",
            light: .cityDay,
            shots: [
                Shot(
                    motif: "🐀",
                    strewn: ["🏙️", "🕳️"],
                    caption: "The apartment came with a roommate.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐀", "🧱"],
                    caption: "The rat was not leaving. The rat had never considered leaving.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐀", "🏙️"],
                    caption: "Fence them in together. Sometimes real estate is about compromise.",
                    isCard: true,
                    seconds: 4.2
                )
            ],
            start: start
        )
    }

    /// After the last pen in the city holds: great food, a minor rodent situation, and a star overhead.
    static func cogsworthHeld(start: Date = .now) -> Self {
        Self(
            key: "cogsworth-held",
            title: "Cogsworth City held",
            light: .cityDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🐀", "🏙️"],
                    caption: "Great food. Excellent location. Minor rodent situation.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🌟",
                    strewn: ["🏙️", "✨"],
                    caption: "Pig began wondering how far he'd have to go for truly quiet neighbors.",
                    seconds: 4.4
                ),
                Shot(
                    motif: "🌌",
                    strewn: ["✨", "🌟"],
                    caption: "Quite far, apparently.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The reaches' films

extension StorybookScene {
    /// Before the first walk out into Starfall Reaches: no traffic, no crowds, unbelievable lot sizes,
    /// with a little sparkle from the stars and no cover for meteor damage.
    static func starfallOpening(start: Date = .now) -> Self {
        Self(
            key: "starfall-opening",
            title: "Starfall Reaches",
            light: .starDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌌", "✨"],
                    caption: "Starfall Reaches. No traffic. No crowds. Unbelievable lot sizes.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🌟",
                    strewn: ["☄️", "🌑"],
                    caption: "Stars add a little sparkle. Meteor damage is not covered.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌌", "✨"],
                    caption: "Finally. No neighbors.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }

    /// The reaches' boss briefing: there were neighbours after all, and both sides valued fairness.
    static func visitorCrater(start: Date = .now) -> Self {
        Self(
            key: "visitor-crater-briefing",
            title: "Visitor Crater",
            light: .starDay,
            shots: [
                Shot(
                    motif: "🛸",
                    strewn: ["🌌", "🌟"],
                    caption: "There were neighbors.",
                    seconds: 2.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🛸", "✨"],
                    caption: "Fortunately, both parties valued personal space. And fairness.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🛸", "🌌"],
                    caption: "Build two separate pens. They must be exactly the same size. Equal square footage. No exceptions.",
                    isCard: true,
                    seconds: 5.8
                )
            ],
            start: start
        )
    }

    /// After the last pen in the reaches holds: remote and mostly peaceful, and something listed well
    /// below market.
    static func starfallHeld(start: Date = .now) -> Self {
        Self(
            key: "starfall-held",
            title: "Starfall Reaches held",
            light: .starDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🛸", "🌟"],
                    caption: "Remote. Spacious. Peaceful. Mostly.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["🌌", "✨"],
                    caption: "Then Pig found something listed below market.",
                    seconds: 3.2
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["🌑", "✨"],
                    caption: "Very far below market.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The caverns' films

extension StorybookScene {
    /// Before the first walk down into Gloamdeep Caverns: quiet, private, no upstairs neighbours, with
    /// excellent mineral rights and some structural concerns.
    static func gloamdeepOpening(start: Date = .now) -> Self {
        Self(
            key: "gloamdeep-opening",
            title: "Gloamdeep Caverns",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🕳️", "💎"],
                    caption: "Gloamdeep Caverns. Quiet. Private. No upstairs neighbors.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "💎",
                    strewn: ["🪨", "💧"],
                    caption: "Excellent mineral rights. Some structural concerns.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🕳️", "🪨"],
                    caption: "Natural light was admittedly limited.",
                    isCard: true,
                    seconds: 2.8
                )
            ],
            start: start
        )
    }

    /// The caverns' boss briefing: the property was occupied twice over, and everyone gets their due.
    static func theRoost(start: Date = .now) -> Self {
        Self(
            key: "the-roost-briefing",
            title: "The Roost",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🦇",
                    strewn: ["🕳️", "💎"],
                    caption: "The property was already occupied. Twice.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦇", "🪨"],
                    caption: "The bats were happy to share. Pig was not.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦇", "💎"],
                    caption: "Pig gets his own pen. Both bats share the other. Everyone gets the arrangement they deserve.",
                    isCard: true,
                    seconds: 5.5
                )
            ],
            start: start
        )
    }

    /// After the last pen in the caverns holds: affordable, quiet, extremely dark, and a carnival glow
    /// promising much better lighting.
    static func gloamdeepHeld(start: Date = .now) -> Self {
        Self(
            key: "gloamdeep-held",
            title: "Gloamdeep Caverns held",
            light: .gloamDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🦇", "💎"],
                    caption: "Affordable. Quiet. Extremely dark.",
                    seconds: 2.6
                ),
                Shot(
                    motif: "🎪",
                    strewn: ["💎", "✨"],
                    caption: "Then Pig saw somewhere with better lighting.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🎪",
                    strewn: ["🍭", "✨"],
                    caption: "Much, much better lighting.",
                    isCard: true,
                    seconds: 2.3
                )
            ],
            start: start
        )
    }
}

// MARK: - The carnival's films

extension StorybookScene {
    /// Before the first walk into the Lantern Carnival: colourful, exciting, amenities everywhere, its
    /// lollipops a sweetener and its knots a sign of strings attached.
    static func lanternOpening(start: Date = .now) -> Self {
        Self(
            key: "lantern-opening",
            title: "Lantern Carnival",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🎪", "🍭"],
                    caption: "Lantern Carnival. Colorful. Exciting. Amenities everywhere.",
                    seconds: 3.9
                ),
                Shot(
                    motif: "🍭",
                    strewn: ["🪢", "🎡"],
                    caption: "Lollipops sweeten the deal. Knots mean there are strings attached.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🎪", "🎡"],
                    caption: "It was certainly more lively than the cave.",
                    isCard: true,
                    seconds: 3.1
                )
            ],
            start: start
        )
    }

    /// The carnival's boss briefing: Pig meets management, who requires a generous setback.
    static func theCenterRing(start: Date = .now) -> Self {
        Self(
            key: "the-centre-ring-briefing",
            title: "The Center Ring",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "👥"],
                    caption: "Then Pig met management.",
                    seconds: 2.2
                ),
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "🍭"],
                    caption: "The ringmaster stays in the center ring. He also requires a generous setback.",
                    seconds: 4.8
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🤹", "🎪"],
                    caption: "Fence in Pig, the ringmaster, and his ring. But don't let your fence touch the ring. Apparently it's in the lease.",
                    isCard: true,
                    seconds: 6.6
                )
            ],
            start: start
        )
    }

    /// After the last pen in the carnival holds: constant nightlife, and a quiet desert beyond.
    static func lanternHeld(start: Date = .now) -> Self {
        Self(
            key: "lantern-held",
            title: "Lantern Carnival held",
            light: .lanternDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🎪", "🍭"],
                    caption: "Food. Entertainment. Nightlife. Constant nightlife.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🏜️",
                    strewn: ["🎪", "✨"],
                    caption: "Pig decided he wanted somewhere peaceful.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🏜️",
                    strewn: ["🌵", "☀️"],
                    caption: "He may have overcorrected.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The dunes' films

extension StorybookScene {
    /// Before the first walk into the dunes: quiet, open, miles from the nearest neighbour, its melons
    /// a welcome amenity and its cacti a hit to the walkability score.
    static func duneOpening(start: Date = .now) -> Self {
        Self(
            key: "dune-opening",
            title: "Sunbaked Dunes",
            light: .duneDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🏜️", "☀️"],
                    caption: "Sunbaked Dunes. Quiet. Open. Miles from the nearest neighbor.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🍈",
                    strewn: ["🌵", "🏜️"],
                    caption: "Melons are a welcome amenity. Cacti lower the walkability score.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🏜️", "🦴"],
                    caption: "The lot was enormous. Shade was sold separately.",
                    isCard: true,
                    seconds: 3.3
                )
            ],
            start: start
        )
    }

    /// The dunes' boss briefing: the nearest neighbour, and a request for a little distance.
    static func theScorpionPit(start: Date = .now) -> Self {
        Self(
            key: "scorpion-flats-briefing",
            title: "Scorpion Flats",
            light: .duneDay,
            shots: [
                Shot(
                    motif: "🦂",
                    strewn: ["🏜️", "🌵"],
                    caption: "Pig finally met the nearest neighbor.",
                    seconds: 2.8
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦂", "🏜️"],
                    caption: "Both parties requested a little distance.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦂", "🌵"],
                    caption: "Build separate pens. And don't let them share a fence. Good fences make good neighbors. Better gaps make better ones.",
                    isCard: true,
                    seconds: 6.8
                )
            ],
            start: start
        )
    }

    /// After the last pen in the dunes holds: tons of space, low humidity, and blue water on the horizon.
    static func duneHeld(start: Date = .now) -> Self {
        Self(
            key: "dune-held",
            title: "Sunbaked Dunes held",
            light: .duneDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🦂", "🏜️"],
                    caption: "Tons of space. Very low humidity.",
                    seconds: 2.6
                ),
                Shot(
                    motif: "🌊",
                    strewn: ["🏜️", "☀️"],
                    caption: "Pig suddenly understood the appeal of waterfront property.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "🌊",
                    strewn: ["🐚", "🌊"],
                    caption: "What could go wrong?",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The cove's films

extension StorybookScene {
    /// Before the first walk down onto the cove: ocean views, fresh air, prime waterfront, its
    /// seashells coastal charm and its jellyfish a complication for the inspection.
    static func tidepoolOpening(start: Date = .now) -> Self {
        Self(
            key: "tidepool-opening",
            title: "Tidepool Cove",
            light: .coveDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌊", "🐚"],
                    caption: "Tidepool Cove. Ocean views. Fresh air. Prime waterfront.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🐚",
                    strewn: ["🪼", "🌊"],
                    caption: "Seashells add coastal charm. Jellyfish complicate the inspection.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌊", "🐚"],
                    caption: "Pig was ready to put in an offer.",
                    isCard: true,
                    seconds: 2.6
                )
            ],
            start: start
        )
    }

    /// The cove's boss briefing: a small easement issue, and property inside the property.
    static func theCrabPool(start: Date = .now) -> Self {
        Self(
            key: "the-crab-pool-briefing",
            title: "The Crab Pool",
            light: .coveDay,
            shots: [
                Shot(
                    motif: "🦀",
                    strewn: ["🌊", "🐚"],
                    caption: "Then Pig discovered a small easement issue.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦀", "🌊"],
                    caption: "The crab already had property inside the property. Naturally.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦀", "🐚"],
                    caption: "Put the crab in its own pen. Then put that pen inside Pig's. And keep the fences apart. It's less a floor plan and more a legal arrangement.",
                    isCard: true,
                    seconds: 7.9
                )
            ],
            start: start
        )
    }

    /// After the last pen in the cove holds: beautiful views, a complicated title history, and a
    /// cold gust off somewhere cooler.
    static func tidepoolHeld(start: Date = .now) -> Self {
        Self(
            key: "tidepool-held",
            title: "Tidepool Cove held",
            light: .coveDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🦀", "🐚"],
                    caption: "Beautiful views. Excellent beach access. Complicated title history.",
                    seconds: 4.3
                ),
                Shot(
                    motif: "❄️",
                    strewn: ["🌊", "🐚"],
                    caption: "Pig wondered if somewhere cooler might be nice.",
                    seconds: 3.3
                ),
                Shot(
                    motif: "❄️",
                    strewn: ["🧊", "❄️"],
                    caption: "Again, he overcorrected.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The tundra's films

extension StorybookScene {
    /// Before the first walk out onto the tundra: quiet, scenic, excellent natural refrigeration, its
    /// fish highly desirable and its extra ice distinctly not.
    static func frostwhiskerOpening(start: Date = .now) -> Self {
        Self(
            key: "frostwhisker-opening",
            title: "Frostwhisker Tundra",
            light: .frostDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["❄️", "🌨️"],
                    caption: "Frostwhisker Tundra. Quiet. Scenic. Excellent natural refrigeration.",
                    seconds: 4.3
                ),
                Shot(
                    motif: "🐟",
                    strewn: ["🧊", "❄️"],
                    caption: "Fish are highly desirable. More ice is not.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["❄️", "🧊"],
                    caption: "Pig had wanted cooler. Technically, he'd succeeded.",
                    isCard: true,
                    seconds: 3.5
                )
            ],
            start: start
        )
    }

    /// The tundra's boss briefing: the waterfront came with a resident who needs water access.
    static func theHaulout(start: Date = .now) -> Self {
        Self(
            key: "the-haulout-briefing",
            title: "The Haulout",
            light: .frostDay,
            shots: [
                Shot(
                    motif: "🦭",
                    strewn: ["❄️", "🌊"],
                    caption: "The waterfront came with a resident.",
                    seconds: 2.7
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦭", "❄️"],
                    caption: "The seal wanted its own place. With water access. Non-negotiable.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦭", "🌊"],
                    caption: "Build separate pens. The seal's pen must border the water. Location, location, location.",
                    isCard: true,
                    seconds: 5.4
                )
            ],
            start: start
        )
    }

    /// After the last pen on the tundra holds: beautiful and far too cool, and a green wetland beyond.
    static func frostwhiskerHeld(start: Date = .now) -> Self {
        Self(
            key: "frostwhisker-held",
            title: "Frostwhisker Tundra held",
            light: .frostDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🦭", "❄️"],
                    caption: "Quiet. Beautiful. Very cool. Far too cool.",
                    seconds: 3.0
                ),
                Shot(
                    motif: "🌿",
                    strewn: ["❄️", "🌫️"],
                    caption: "Pig decided to try somewhere with less ice.",
                    seconds: 3.1
                ),
                Shot(
                    motif: "🌿",
                    strewn: ["🐊", "🌿"],
                    caption: "Much less.",
                    isCard: true,
                    seconds: 2.2
                )
            ],
            start: start
        )
    }
}

// MARK: - The fen's films

extension StorybookScene {
    /// Before the first walk into the fen: waterfront property in every direction, its blueberries a
    /// pleasant surprise and its logs a tripping hazard.
    static func mirebogOpening(start: Date = .now) -> Self {
        Self(
            key: "mirebog-opening",
            title: "Mirebog Fen",
            light: .fenDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌿", "🌫️"],
                    caption: "Mirebog Fen. Waterfront property in every direction.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🫐",
                    strewn: ["🪵", "🌿"],
                    caption: "Blueberries are a pleasant surprise. Logs are a tripping hazard.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌿", "🌫️"],
                    caption: "The listing described it as \"lush.\" That was generous.",
                    isCard: true,
                    seconds: 3.6
                )
            ],
            start: start
        )
    }

    /// The fen's boss briefing: a pool and a pool owner, who wants the whole thing.
    static func theWallow(start: Date = .now) -> Self {
        Self(
            key: "the-wallow-briefing",
            title: "The Wallow",
            light: .fenDay,
            shots: [
                Shot(
                    motif: "🐊",
                    strewn: ["🌿", "🌊"],
                    caption: "There was also a pool. And a pool owner.",
                    seconds: 2.9
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐊", "🌿"],
                    caption: "The crocodile wanted the entire thing. Pig had no objections.",
                    seconds: 4.0
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐊", "🌿"],
                    caption: "Build separate pens. The crocodile's pen must surround the whole body of water. And don't put the fence right on the shoreline. Even crocodiles have setback requirements.",
                    isCard: true,
                    seconds: 9.4
                )
            ],
            start: start
        )
    }

    /// After the last pen in the fen holds: very green, very wet, and only one direction left to go.
    static func mirebogHeld(start: Date = .now) -> Self {
        Self(
            key: "mirebog-held",
            title: "Mirebog Fen held",
            light: .fenDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🐊", "🌿"],
                    caption: "Very green. Very wet.",
                    seconds: 2.2
                ),
                Shot(
                    motif: "☁️",
                    strewn: ["🌿", "🌫️"],
                    caption: "Pig decided his next home should be as far from water as possible.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "☁️",
                    strewn: ["🦅", "☁️"],
                    caption: "There was really only one direction left.",
                    isCard: true,
                    seconds: 3.0
                )
            ],
            start: start
        )
    }
}

// MARK: - The heights' films

extension StorybookScene {
    /// Before the first walk onto the heights: fresh air, endless views, absolutely no flood risk,
    /// its balloons a charm and its twisters a hit to the insurance premium.
    static func cloudspireOpening(start: Date = .now) -> Self {
        Self(
            key: "cloudspire-opening",
            title: "Cloudspire Heights",
            light: .spireDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "💨"],
                    caption: "Cloudspire Heights. Fresh air. Endless views. Absolutely no flood risk.",
                    seconds: 4.5
                ),
                Shot(
                    motif: "🎈",
                    strewn: ["🌪️", "☁️"],
                    caption: "Balloons add charm. Twisters affect the insurance premium.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "🎈"],
                    caption: "Pig's property search had officially left the ground.",
                    isCard: true,
                    seconds: 3.6
                )
            ],
            start: start
        )
    }

    /// The heights' boss briefing: very strict oversight, and an eye that reaches every straight line.
    static func theEyrie(start: Date = .now) -> Self {
        Self(
            key: "the-eyrie-briefing",
            title: "The Eyrie",
            light: .spireDay,
            shots: [
                Shot(
                    motif: "🦅",
                    strewn: ["☁️", "💨"],
                    caption: "Unfortunately, the neighborhood had very strict oversight.",
                    seconds: 3.8
                ),
                Shot(
                    motif: "🦅",
                    strewn: ["☁️", "🐷"],
                    caption: "The eagle sees everything directly above, below, and beside it. Everything.",
                    seconds: 4.7
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦅", "☁️"],
                    caption: "Fence in Pig. Keep every piece of fence out of the eagle's line of sight. The homeowners association is watching.",
                    isCard: true,
                    seconds: 6.6
                )
            ],
            start: start
        )
    }

    /// The last film in the game. Pig has toured every market, meets every neighbour again, and comes
    /// home to build the one perfect pen — right before the open house goes very wrong.
    static func cloudspireHeld(start: Date = .now) -> Self {
        Self(
            key: "cloudspire-held",
            title: "Cloudspire Heights held",
            light: .spireDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "🌈"],
                    caption: "And that was it. Pig had toured every market imaginable.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🦌",
                    strewn: ["🐗", "🐉", "🛸"],
                    caption: "He'd met some interesting neighbors. Very interesting neighbors.",
                    seconds: 4.2
                ),
                Shot(
                    motif: "🏡",
                    strewn: ["🚧", "🐷"],
                    caption: "After all that, Pig finally knew exactly what he wanted.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🌈",
                    strewn: ["🐷", "🍎"],
                    caption: "More space. Good snacks. No surprises. The perfect pen.",
                    seconds: 3.7
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌈", "🦌"],
                    caption: "There was just one problem.",
                    seconds: 2.3
                ),
                Shot(
                    motif: "🦅",
                    strewn: ["🐊", "🦂", "🦀"],
                    caption: "Apparently the listing had excellent word of mouth.",
                    seconds: 3.5
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌈", "🦌", "🐗"],
                    caption: "Open house was a mistake.",
                    isCard: true,
                    seconds: 2.2
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
            .lanternOpening(), .theCenterRing(), .lanternHeld(),
            .duneOpening(), .theScorpionPit(), .duneHeld(),
            .tidepoolOpening(), .theCrabPool(), .tidepoolHeld(),
            .frostwhiskerOpening(), .theHaulout(), .frostwhiskerHeld(),
            .mirebogOpening(), .theWallow(), .mirebogHeld(),
            .cloudspireOpening(), .theEyrie(), .cloudspireHeld()
        ]
    }
}
