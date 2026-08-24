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

    /// One still: the motif held over the backdrop, and the line over it.
    struct Shot: Equatable, Sendable, Identifiable {
        /// The big glyph the still is built around.
        let motif: String
        /// A few smaller glyphs strewn behind it, for the world it is set in.
        let strewn: [String]
        let caption: String
        /// Whether the line is the point of the still and set big in the middle, the way the
        /// meadow's hand-off shots are, rather than tucked along the bottom.
        let isCard: Bool
        /// Glyphs ringed around the motif rather than strewn behind it, popping in one at a time
        /// as the shot runs. The game's last film gathers every world's boss round the pig this
        /// way, so the whole cast is on screen at once rather than a few scattered behind it.
        let crowd: [String]
        /// A painted meadow picture to draw in place of the emoji motif, for a still that wants
        /// the hand-drawn art rather than a glyph. The finale reaches back to `.homePen` with it.
        let painting: CutScene.Picture?

        var id: String { motif + caption }

        init(
            motif: String,
            strewn: [String] = [],
            caption: String,
            isCard: Bool = false,
            crowd: [String] = [],
            painting: CutScene.Picture? = nil
        ) {
            self.motif = motif
            self.strewn = strewn
            self.caption = caption
            self.isCard = isCard
            self.crowd = crowd
            self.painting = painting
        }
    }

    // MARK: - Timing

    /// How long the whole film runs, with the first and last stills carrying the film's slower
    /// framing sentences, the same as a painted film.
    var runtime: TimeInterval {
        shots.indices.reduce(0) { total, index in
            total + CutScene.shotSeconds(
                of: shots[index].caption,
                slowFirst: index == 0,
                slowLast: index == shots.count - 1
            )
        }
    }

    /// What is on screen one moment in: which still, where it comes, and how long it has held —
    /// which is what the caption and the cut flash are timed off. The same shape as a
    /// `CutScene.Frame`, so one view can play either.
    struct Frame: Equatable, Sendable {
        let index: Int
        let shot: Shot
        let seconds: TimeInterval
        let slowFirst: Bool
        let slowLast: Bool

        var shotSeconds: TimeInterval {
            CutScene.shotSeconds(of: shot.caption, slowFirst: slowFirst, slowLast: slowLast)
        }

        var progress: Double {
            let length = shotSeconds
            guard length > 0 else { return 1 }
            return min(max(seconds / length, 0), 1)
        }

        var caption: (sentence: String, opacity: Double) {
            CutScene.caption(of: shot.caption, secondsIn: seconds, slowFirst: slowFirst, slowLast: slowLast)
        }

        var flash: Double {
            max(0, 1 - seconds / CutScene.flash)
        }
    }

    /// The still on screen `elapsed` seconds in, or nothing once the film has run out.
    func frame(secondsIn elapsed: TimeInterval) -> Frame? {
        let lastIndex = shots.count - 1
        guard elapsed > 0 else {
            return shots.first.map {
                Frame(index: 0, shot: $0, seconds: 0, slowFirst: true, slowLast: lastIndex == 0)
            }
        }

        var left = elapsed
        for (index, shot) in shots.enumerated() {
            let slowFirst = index == 0
            let slowLast = index == lastIndex
            let length = CutScene.shotSeconds(of: shot.caption, slowFirst: slowFirst, slowLast: slowLast)
            if left < length {
                return Frame(index: index, shot: shot, seconds: left, slowFirst: slowFirst, slowLast: slowLast)
            }
            left -= length
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
                    caption: "Thornwood Thicket. Secluded. Wooded. Very private."
                ),
                Shot(
                    motif: "🍄",
                    strewn: ["🥀", "🌿"],
                    caption: "Mushrooms are a charming local amenity. Wilted flowers do nothing for curb appeal."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌲", "🍄"],
                    caption: "Pig was warming to the idea of living off the beaten path.",
                    isCard: true
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
                    caption: "Then Pig met the neighbor."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐗", "🌲"],
                    caption: "They agreed immediately on one thing: separate units."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐗", "🍄"],
                    caption: "Fence in Pig and the boar separately.",
                    isCard: true
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
                    caption: "Private. Peaceful. Spacious. Almost perfect."
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["🌲", "✨"],
                    caption: "Then Pig spotted a listing with spectacular mountain views."
                ),
                Shot(
                    motif: "🌋",
                    strewn: ["🌲", "🔥"],
                    caption: "The description did not mention the volcano.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The mountain's films

extension StorybookScene {
    /// Before the first walk up Emberpeak: dramatic views and natural heating, its mineral
    /// rights a perk and its open flames a maintenance concern.
    static func emberpeakOpening(start: Date = .now) -> Self {
        Self(
            key: "emberpeak-opening",
            title: "Emberpeak",
            light: .emberDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌋", "🪨"],
                    caption: "Welcome to Emberpeak. Dramatic views. Naturally heated."
                ),
                Shot(
                    motif: "🪙",
                    strewn: ["🔥", "🪨"],
                    caption: "Turns out the mineral rights have their perks. Open flames are a maintenance concern."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌋", "🌫️"],
                    caption: "Pig was willing to overlook a few issues for the right property.",
                    isCard: true
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
                    caption: "The seller had disclosed some local wildlife. They had undersold it."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐉", "🪨"],
                    caption: "This neighbor will not be joining the homeowners association."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐉", "🌋"],
                    caption: "Fence in Pig. Keep the wyrm out. Very, very out.",
                    isCard: true
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
                    caption: "The views were excellent. The heating bill was unbeatable."
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["🌋", "✨"],
                    caption: "Still, Pig wondered if maybe a city had more to offer."
                ),
                Shot(
                    motif: "🏙️",
                    strewn: ["✨", "🌫️"],
                    caption: "At least cities had building codes. Probably.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The city's films

extension StorybookScene {
    /// Before the first walk into Cogsworth City: walkable, vibrant, close to everything, with
    /// pizza in walking distance and a trash pickup that appears to be irregular.
    static func cogsworthOpening(start: Date = .now) -> Self {
        Self(
            key: "cogsworth-opening",
            title: "Cogsworth City",
            light: .cityDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🏙️", "🧱"],
                    caption: "Cogsworth City. Walkable. Vibrant. Close to everything."
                ),
                Shot(
                    motif: "🍕",
                    strewn: ["🗑️", "🧱"],
                    caption: "Pizza within walking distance is a strong selling point. Trash pickup appears to be… irregular."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🏙️", "🪟"],
                    caption: "Pig could get used to city living.",
                    isCard: true
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
                    caption: "The apartment came with a roommate."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐀", "🧱"],
                    caption: "The rat was not leaving. The rat had never considered leaving."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐀", "🏙️"],
                    caption: "Fence them in together. Sometimes real estate is about compromise.",
                    isCard: true
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
                    caption: "Great food. Excellent location. Minor rodent situation."
                ),
                Shot(
                    motif: "🌟",
                    strewn: ["🏙️", "✨"],
                    caption: "Pig began wondering how far he'd have to go to get away from rats."
                ),
                Shot(
                    motif: "🌌",
                    strewn: ["✨", "🌟"],
                    caption: "Quite far, apparently.",
                    isCard: true
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
                    caption: "Starfall Reaches. No traffic. No crowds. Unbelievable lot sizes."
                ),
                Shot(
                    motif: "🌟",
                    strewn: ["☄️", "🌑"],
                    caption: "Stars add a little sparkle. Meteor damage is not covered."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌌", "✨"],
                    caption: "Finally. No neighbors.",
                    isCard: true
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
                    caption: "Turns out, there were neighbors."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🛸", "✨"],
                    caption: "Fortunately, both parties valued personal space. And fairness."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🛸", "🌌"],
                    caption: "Build two separate pens. They must be exactly the same size. Equal square footage. No exceptions.",
                    isCard: true
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
                    caption: "Remote. Spacious. Peaceful. Mostly."
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["🌌", "✨"],
                    caption: "Then Pig found something listed below market."
                ),
                Shot(
                    motif: "🕳️",
                    strewn: ["🌑", "✨"],
                    caption: "Very far below market.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The caverns' films

extension StorybookScene {
    /// Before the first walk down into Gloamdeep Caverns: solid construction and no street noise
    /// (no street, either), with excellent mineral rights and boulders in the way of expansion.
    static func gloamdeepOpening(start: Date = .now) -> Self {
        Self(
            key: "gloamdeep-opening",
            title: "Gloamdeep Caverns",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🕳️", "💎"],
                    caption: "Gloamdeep Caverns. Solid construction. No street noise. No street, either."
                ),
                Shot(
                    motif: "💎",
                    strewn: ["🪨", "💧"],
                    caption: "Excellent mineral rights. Boulders make expansion difficult."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🕳️", "🪨"],
                    caption: "Natural light was admittedly limited.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// The caverns' boss briefing: the property was occupied twice over, and Pig is absolutely
    /// not accepting roommates.
    static func theRoost(start: Date = .now) -> Self {
        Self(
            key: "the-roost-briefing",
            title: "The Roost",
            light: .gloamDay,
            shots: [
                Shot(
                    motif: "🦇",
                    strewn: ["🕳️", "💎"],
                    caption: "The property was already occupied. Twice."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦇", "🪨"],
                    caption: "The bats were happy to share. Pig was not."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦇", "💎"],
                    caption: "Pig gets his own pen. Both bats share the other. Pig was absolutely not accepting roommates.",
                    isCard: true
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
                    caption: "Affordable. Quiet. Extremely dark."
                ),
                Shot(
                    motif: "🎪",
                    strewn: ["💎", "✨"],
                    caption: "Then Pig saw somewhere with better lighting."
                ),
                Shot(
                    motif: "🎪",
                    strewn: ["🍭", "✨"],
                    caption: "Much, much better lighting.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The carnival's films

extension StorybookScene {
    /// Before the first walk into the Lantern Carnival: bright, bustling, no shortage of
    /// entertainment, its concessions a perk and its noise enough to sink the deal.
    static func lanternOpening(start: Date = .now) -> Self {
        Self(
            key: "lantern-opening",
            title: "Lantern Carnival",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🎪", "🍭"],
                    caption: "Lantern Carnival. Bright. Bustling. Absolutely no shortage of entertainment."
                ),
                Shot(
                    motif: "🍿",
                    strewn: ["📣", "🎡"],
                    caption: "On-site concessions are a definite perk. The noise alone could sink the deal."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🎪", "🎡"],
                    caption: "It was certainly more lively than the cave.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// The carnival's boss briefing: Pig meets management, who runs a tight ship.
    static func theCenterRing(start: Date = .now) -> Self {
        Self(
            key: "the-centre-ring-briefing",
            title: "The Center Ring",
            light: .lanternDay,
            shots: [
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "👥"],
                    caption: "Then Pig met management."
                ),
                Shot(
                    motif: "🤹",
                    strewn: ["🎪", "🍭"],
                    caption: "The ringmaster runs a tight ship. Keep your construction out of his personal space."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🤹", "🎪"],
                    caption: "Fence in Pig, the ringmaster, and his ring. But don't let your fence touch the ring. Apparently it's in the lease.",
                    isCard: true
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
                    caption: "Food. Entertainment. Nightlife. Constant nightlife."
                ),
                Shot(
                    motif: "🏜️",
                    strewn: ["🎪", "✨"],
                    caption: "Pig decided he wanted somewhere more peaceful."
                ),
                Shot(
                    motif: "🏜️",
                    strewn: ["🌵", "☀️"],
                    caption: "Somewhere quiet hours practically enforce themselves.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The dunes' films

extension StorybookScene {
    /// Before the first walk into the dunes: warm, secluded, extremely low-maintenance
    /// landscaping, its water access worth a premium and its snakes a hit to buyer confidence.
    static func duneOpening(start: Date = .now) -> Self {
        Self(
            key: "dune-opening",
            title: "Sunbaked Dunes",
            light: .duneDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🏜️", "☀️"],
                    caption: "Sunbaked Dunes. Warm. Secluded. Extremely low-maintenance landscaping."
                ),
                Shot(
                    motif: "🍈",
                    strewn: ["🌵", "🏜️"],
                    caption: "Water access is worth a premium. Snakes tend to hurt buyer confidence."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🏜️", "🦴"],
                    caption: "The lot was enormous. Shade was sold separately.",
                    isCard: true
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
                    caption: "Pig finally met the nearest neighbor."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦂", "🏜️"],
                    caption: "Both parties requested a little distance."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦂", "🌵"],
                    caption: "Build separate pens. And don't let them share a fence. Adjoining properties were not approved.",
                    isCard: true
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
                    caption: "Tons of space. Very low humidity."
                ),
                Shot(
                    motif: "🌊",
                    strewn: ["🏜️", "☀️"],
                    caption: "Pig thought the sand would be more appealing with water attached."
                ),
                Shot(
                    motif: "🌊",
                    strewn: ["🐚", "🌊"],
                    caption: "What could go wrong?",
                    isCard: true
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
                    caption: "Tidepool Cove. Ocean views. Fresh air. Prime waterfront."
                ),
                Shot(
                    motif: "🐚",
                    strewn: ["🪼", "🌊"],
                    caption: "Seashells add coastal charm. Jellyfish complicate the inspection."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌊", "🐚"],
                    caption: "Pig was ready to put in an offer.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// The cove's boss briefing: the property came with a guest house, and everyone likes a
    /// little privacy.
    static func theCrabPool(start: Date = .now) -> Self {
        Self(
            key: "the-crab-pool-briefing",
            title: "The Crab Pool",
            light: .coveDay,
            shots: [
                Shot(
                    motif: "🦀",
                    strewn: ["🌊", "🐚"],
                    caption: "Then Pig discovered the property came with a guest house."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦀", "🌊"],
                    caption: "Give the crab its own pen. Then build Pig's around it."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦀", "🐚"],
                    caption: "No shared fences. Everyone likes a little privacy.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// After the last pen in the cove holds: beautiful views, one too many uninvited guests, and
    /// a cold gust off somewhere cooler.
    static func tidepoolHeld(start: Date = .now) -> Self {
        Self(
            key: "tidepool-held",
            title: "Tidepool Cove held",
            light: .coveDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🦀", "🐚"],
                    caption: "Beautiful views. Excellent beach access. One too many uninvited guests."
                ),
                Shot(
                    motif: "❄️",
                    strewn: ["🌊", "🐚"],
                    caption: "Pig decided he'd had enough of sand, surf, and surprise crustaceans."
                ),
                Shot(
                    motif: "❄️",
                    strewn: ["🧊", "❄️"],
                    caption: "A cozy place near the slopes sounded hard to beat.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The tundra's films

extension StorybookScene {
    /// Before the first walk out onto the tundra: charming, scenic, excellent natural
    /// refrigeration, its slope access a major amenity and its black ice a hit to walkability.
    static func frostwhiskerOpening(start: Date = .now) -> Self {
        Self(
            key: "frostwhisker-opening",
            title: "Frostwhisker Tundra",
            light: .frostDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["❄️", "🌨️"],
                    caption: "Frostwhisker Tundra. Charming. Scenic. Excellent natural refrigeration."
                ),
                Shot(
                    motif: "🎿",
                    strewn: ["🧊", "❄️"],
                    caption: "Slope access is a major amenity. Black ice hurts the walkability score."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["❄️", "🧊"],
                    caption: "Pig was beginning to understand the ski-town premium.",
                    isCard: true
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
                    caption: "The waterfront came with a resident."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🦭", "❄️"],
                    caption: "The seal wanted its own place. With water access. Non-negotiable."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦭", "🌊"],
                    caption: "Build separate pens. The seal's pen must border the water.",
                    isCard: true
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
                    caption: "Quiet. Beautiful. Very cool. Far too cool."
                ),
                Shot(
                    motif: "🌿",
                    strewn: ["❄️", "🌫️"],
                    caption: "Pig decided to try somewhere with less ice."
                ),
                Shot(
                    motif: "🌿",
                    strewn: ["🐊", "🌿"],
                    caption: "Much less.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The fen's films

extension StorybookScene {
    /// Before the first walk into the fen: waterfront property in every direction, its lotus
    /// flowers a lovely pop of color and its mosquito situation difficult to overlook.
    static func mirebogOpening(start: Date = .now) -> Self {
        Self(
            key: "mirebog-opening",
            title: "Mirebog Fen",
            light: .fenDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["🌿", "🌫️"],
                    caption: "Mirebog Fen. Waterfront property in every direction."
                ),
                Shot(
                    motif: "🪷",
                    strewn: ["🦟", "🌿"],
                    caption: "Lotus flowers add a lovely pop of color. The mosquito situation is difficult to overlook."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌿", "🌫️"],
                    caption: "The listing described it as \"lush.\" That was generous.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// The fen's boss briefing: the crocodile has one requirement, and it is the whole waterway.
    static func theWallow(start: Date = .now) -> Self {
        Self(
            key: "the-wallow-briefing",
            title: "The Wallow",
            light: .fenDay,
            shots: [
                Shot(
                    motif: "🐊",
                    strewn: ["🌿", "🌊"],
                    caption: "The crocodile had one requirement: waterfront."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🐊", "🌿"],
                    caption: "One waterway is enough. But he wants the whole thing."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🐊", "🌿"],
                    caption: "Build separate pens. Fence the crocodile in with one entire waterway.",
                    isCard: true
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
                    caption: "Very green. Very wet."
                ),
                Shot(
                    motif: "☁️",
                    strewn: ["🌿", "🌫️"],
                    caption: "Pig still wasn't quite satisfied."
                ),
                Shot(
                    motif: "☁️",
                    strewn: ["🦅", "☁️"],
                    caption: "There was really only one direction left.",
                    isCard: true
                )
            ],
            start: start
        )
    }
}

// MARK: - The heights' films

extension StorybookScene {
    /// Before the first walk onto the heights: fresh air, endless views, absolutely no flood risk,
    /// its rainbows instant appeal and its severe weather a notable drawback.
    static func cloudspireOpening(start: Date = .now) -> Self {
        Self(
            key: "cloudspire-opening",
            title: "Cloudspire Heights",
            light: .spireDay,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "💨"],
                    caption: "Cloudspire Heights. Fresh air. Endless views. Absolutely no flood risk."
                ),
                Shot(
                    motif: "🌈",
                    strewn: ["🌩️", "☁️"],
                    caption: "A rainbow adds instant appeal. Severe weather is a notable drawback."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "🎈"],
                    caption: "Pig's property search had officially left the ground.",
                    isCard: true
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
                    caption: "Unfortunately, the neighborhood had very strict oversight."
                ),
                Shot(
                    motif: "🦅",
                    strewn: ["☁️", "🐷"],
                    caption: "The eagle sees everything directly above, below, and beside it. Everything."
                ),
                Shot(
                    motif: "🚧",
                    strewn: ["🦅", "☁️"],
                    caption: "Fence in Pig. Keep every piece of fence out of the eagle's line of sight. The homeowners association is watching.",
                    isCard: true
                )
            ],
            start: start
        )
    }

    /// The last film in the game. Pig has toured every market, meets every neighbour again, and comes
    /// home to build the one perfect pen — right before the open house goes very wrong.
    static func cloudspireHeld(start: Date = .now) -> Self {
        // Every world's boss, in the order the pig met them, gathered round him at the end.
        let bosses = ["🦌", "🐗", "🐉", "🐀", "🛸", "🦇", "🤹", "🦂", "🦀", "🦭", "🐊", "🦅"]
        return Self(
            key: "cloudspire-held",
            title: "Cloudspire Heights held",
            light: .spireDusk,
            shots: [
                Shot(
                    motif: "🐷",
                    strewn: ["☁️", "🌈"],
                    caption: "And that was it. Pig had toured every market imaginable."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["☁️"],
                    caption: "He'd met some interesting neighbors. Very interesting neighbors.",
                    crowd: bosses
                ),
                // Back to the very first shot of the very first film: the poky farm pen, painted
                // exactly as the opening painted it, so the ending returns to where it began.
                Shot(
                    motif: "🐷",
                    caption: "After all that, Pig finally knew exactly what he wanted.",
                    painting: .homePen
                ),
                Shot(
                    motif: "🌈",
                    strewn: ["🐷", "🍎"],
                    caption: "The best pen was already his. Plenty of space. Apples nearby. No fine print."
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["🌈"],
                    caption: "There was just one problem.",
                    crowd: bosses
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["☁️"],
                    caption: "Apparently the listing had excellent word of mouth.",
                    crowd: bosses
                ),
                Shot(
                    motif: "🐷",
                    strewn: ["☁️"],
                    caption: "Open house was a mistake.",
                    isCard: true,
                    crowd: bosses
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
