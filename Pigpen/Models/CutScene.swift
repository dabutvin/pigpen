import Foundation

/// A film the game stops to play, as a clock.
///
/// Three per world: the one before a player's first walk into it, the one that says what makes
/// its last puzzle the boss, and the one that sees them off it. They are all the same machine —
/// a list of shots, each held for a moment and captioned — so a world's three are a list and a
/// few pictures rather than another screen.
///
/// Like the pasture behind the title and the lap of honour on a pen that holds, a scene is
/// written as a clock rather than as a queue of steps: the screen asks what is on it at a
/// given moment and draws that. So a film cannot fall out of step with itself, a still of
/// any moment of it can be taken for a preview or a screenshot, and skipping it is a matter
/// of walking away from the clock rather than unwinding a pile of half-finished animation.
struct CutScene: Equatable, Sendable, Identifiable {
    /// Which film this is.
    ///
    /// Named rather than left anonymous because the game has to remember which ones a
    /// player has already sat through — none of them is worth showing twice.
    ///
    /// Between them they are the whole of the pig's story, told in an estate agent's voice: a
    /// pig who outgrew a poky farm pen and went looking for property, every market he toured
    /// and every resident he had to share it with, and the pig — housed at last on each of
    /// them, and already reading the next listing.
    ///
    /// The first of them carries the rules as well as the story, since a player who has
    /// watched it should know what a good pen is before they are handed a rack of fencing:
    /// build the biggest pen the fencing will reach round, more space is a better score,
    /// apples improve the property and skulls hurt its resale value — and close the fence,
    /// because the pig is keeping his options open.
    enum Name: String, Sendable, CaseIterable {
        /// Before the first walk up the meadow: a pig who has outgrown his farm pen, the
        /// open gate he leaves through, and the rules the whole game is scored on — biggest
        /// pen wins, apples help, skulls hurt, and it only counts if the fence is shut.
        case opening
        /// Before the meadow's last puzzle, which is the first with two animals on it: the
        /// promising piece of land already has a resident, so the pig and the deer both have
        /// to be fenced — one pen or two, whatever makes the floor plan work.
        case stagMere
        /// After it, once every pen in the meadow is held: the pig housed and comfortable,
        /// and the dark forest at the meadow's edge that he has already started eyeing.
        case theMeadowHeld

        // MARK: Thornwood Thicket

        /// Before the first walk into the thicket: the tree line the meadow pointed at, and a
        /// listing that is secluded, wooded and very private, whichever way you read those.
        case thornwoodOpening = "thornwood-opening"
        /// Before the thicket's last puzzle: the neighbour, and the one thing he and the pig
        /// agree on, which is that they are not sharing a fence.
        case boarHollow = "boar-hollow-briefing"
        /// After it, once every pen in the thicket is held: a private, peaceful, almost
        /// perfect wood, and a mountain showing over the top of it.
        case thornwoodHeld = "thornwood-held"

        // MARK: Emberpeak

        /// Before the first walk up the mountain: dramatic views, naturally heated, and a
        /// maintenance concern the listing calls an open flame.
        case emberpeakOpening = "emberpeak-opening"
        /// Before the mountain's last puzzle: the seller disclosed some local wildlife and
        /// undersold it, and this neighbour is not to be fenced in but kept out.
        case wyrmCaldera = "wyrm-caldera-briefing"
        /// After it: an unbeatable heating bill, and a city lighting up a long way below.
        case emberpeakHeld = "emberpeak-held"

        // MARK: Cogsworth City

        /// Before the first walk into the city: walkable, vibrant, close to everything, with a
        /// trash pickup that appears to be irregular.
        case cogsworthOpening = "cogsworth-opening"
        /// Before the city's last puzzle: the apartment came with a roommate who has never once
        /// considered leaving, so this is the boss the pig is fenced in *with*.
        case ratKingWharf = "rat-king-wharf-briefing"
        /// After it: great food, a minor rodent situation, and a star overhead.
        case cogsworthHeld = "cogsworth-held"

        // MARK: Starfall Reaches

        /// Before the first walk out into the reaches: no traffic, no crowds, unbelievable lot
        /// sizes, and no cover for meteor damage.
        case starfallOpening = "starfall-opening"
        /// Before the reaches' last puzzle: there were neighbours after all, and both parties
        /// value fairness enough to want two pens of exactly the same size.
        case visitorCrater = "visitor-crater-briefing"
        /// After it: remote, spacious, mostly peaceful, and something listed very far below
        /// market.
        case starfallHeld = "starfall-held"

        // MARK: Gloamdeep Caverns

        /// Before the first walk down into the caverns: solid construction, no street noise, no
        /// street, and admittedly limited natural light.
        case gloamdeepOpening = "gloamdeep-opening"
        /// Before the caverns' last puzzle: the property is occupied twice over, and the pig is
        /// absolutely not accepting roommates.
        case theRoost = "the-roost-briefing"
        /// After it: affordable, quiet, extremely dark, and a carnival glow promising much
        /// better lighting.
        case gloamdeepHeld = "gloamdeep-held"

        // MARK: Lantern Carnival

        /// Before the first walk into the carnival: bright, bustling, and no shortage of
        /// entertainment, if you can live with the noise.
        case lanternOpening = "lantern-opening"
        /// Before the carnival's last puzzle: management runs a tight ship, and wants its ring
        /// fenced in but not touched.
        case theCenterRing = "the-centre-ring-briefing"
        /// After it: constant nightlife, and a desert where quiet hours enforce themselves.
        case lanternHeld = "lantern-held"

        // MARK: Sunbaked Dunes

        /// Before the first walk into the dunes: warm, secluded, extremely low-maintenance
        /// landscaping, and snakes.
        case duneOpening = "dune-opening"
        /// Before the dunes' last puzzle: the nearest neighbour would like a little distance,
        /// and adjoining properties were not approved.
        case scorpionFlats = "scorpion-flats-briefing"
        /// After it: tons of space, very low humidity, and blue water on the horizon.
        case duneHeld = "dune-held"

        // MARK: Tidepool Cove

        /// Before the first walk down onto the cove: ocean views, fresh air, prime waterfront,
        /// and a certain amount of coastal hazard.
        case tidepoolOpening = "tidepool-opening"
        /// Before the cove's last puzzle: the property came with a guest house, and everyone
        /// likes a little privacy.
        case theCrabPool = "the-crab-pool-briefing"
        /// After it: beautiful views, one too many uninvited guests, and a cold gust off
        /// somewhere cooler.
        case tidepoolHeld = "tidepool-held"

        // MARK: Frostwhisker Tundra

        /// Before the first walk out onto the tundra: charming, scenic, excellent natural
        /// refrigeration, and black ice.
        case frostwhiskerOpening = "frostwhisker-opening"
        /// Before the tundra's last puzzle: the waterfront came with a resident, and its water
        /// access is non-negotiable.
        case theHaulout = "the-haulout-briefing"
        /// After it: quiet, beautiful, very cool — far too cool — and somewhere green beyond.
        case frostwhiskerHeld = "frostwhisker-held"

        // MARK: Mirebog Fen

        /// Before the first walk into the fen: waterfront property in every direction, described
        /// in the listing as lush.
        case mirebogOpening = "mirebog-opening"
        /// Before the fen's last puzzle: the crocodile has one requirement, and it is the whole
        /// waterway.
        case theWallow = "the-wallow-briefing"
        /// After it: very green, very wet, and only one direction left to go.
        case mirebogHeld = "mirebog-held"

        // MARK: Cloudspire Heights

        /// Before the first walk onto the heights: fresh air, endless views, absolutely no flood
        /// risk, and severe weather.
        case cloudspireOpening = "cloudspire-opening"
        /// Before the last puzzle in the game: the neighbourhood has very strict oversight, and
        /// the eagle sees everything above, below and beside it.
        case theEyrie = "the-eyrie-briefing"
        /// The last film in the game. Every market toured, every neighbour met, and the best pen
        /// turning out to have been the first one — right up until the open house.
        case cloudspireHeld = "cloudspire-held"
    }

    let name: Name
    /// What the world remembers this film by, so it plays once and is never shown twice — and
    /// what tells one on screen apart from another, so presenting a new film swaps the screen
    /// rather than leaving the old one up.
    ///
    /// It is the name's raw value rather than the name because a device that has already seen a
    /// film has the string on it: a case can be renamed freely, and what it spells cannot.
    var key: String { name.rawValue }
    var id: String { key }
    /// The film, in order.
    let shots: [Shot]
    /// The moment the curtain went up.
    let start: Date

    init(name: Name, shots: [Shot], start: Date = .now) {
        self.name = name
        self.shots = shots
        self.start = start
    }

    /// One shot of a film: what it shows, and what it says over it. How long it holds is not a
    /// property of the shot alone — the film's first and last lines read slower — so a shot's
    /// length is figured by the film, in `frame(secondsIn:)` and `runtime`.
    struct Shot: Equatable, Sendable, Identifiable {
        let picture: Picture
        let caption: String

        var id: Picture { picture }
    }

    /// What a shot shows. A script only says which picture is up and for how long; how each
    /// one is painted is the screen's business.
    ///
    /// A world at a time rather than one flat list. Every film in the game is painted with the
    /// same brushes — a sky, a ridge, a band of ground, an animal stood on it — but a thicket's
    /// shots are no more the meadow's than its boar is its deer, and one list of every shot in
    /// the game would carry a `finishedPen` per world with nothing but a longer name to tell
    /// them apart. So each world names its own shots inside its own case, in its own file
    /// beside the films that use them, and the switch that paints one is only ever as long as
    /// the world it belongs to.
    enum Picture: Hashable, Sendable {
        case meadow(Meadow)
        case thornwood(Thornwood)
        case emberpeak(Emberpeak)
        case cogsworth(Cogsworth)
        case starfall(Starfall)
        case gloamdeep(Gloamdeep)
        case lantern(Lantern)
        case dunes(Dunes)
        case tidepool(Tidepool)
        case frostwhisker(Frostwhisker)
        case mirebog(Mirebog)
        case cloudspire(Cloudspire)

        /// Whether the line over this shot is the point of the whole film rather than a note
        /// under the picture, and so is set big in the middle of the frame as a card. The shot
        /// a film hands the game over on is the one that gets it.
        var isCard: Bool {
            switch self {
            case .meadow(let shot): shot.isCard
            case .thornwood(let shot): shot.isCard
            case .emberpeak(let shot): shot.isCard
            case .cogsworth(let shot): shot.isCard
            case .starfall(let shot): shot.isCard
            case .gloamdeep(let shot): shot.isCard
            case .lantern(let shot): shot.isCard
            case .dunes(let shot): shot.isCard
            case .tidepool(let shot): shot.isCard
            case .frostwhisker(let shot): shot.isCard
            case .mirebog(let shot): shot.isCard
            case .cloudspire(let shot): shot.isCard
            }
        }
    }

    // MARK: - Timing

    /// How long the whole film runs, with the first and last shots carrying the film's slower
    /// framing sentences.
    var runtime: TimeInterval {
        shots.indices.reduce(0) { total, index in
            total + CutScene.shotSeconds(
                of: shots[index].caption,
                slowFirst: index == 0,
                slowLast: index == shots.count - 1
            )
        }
    }

    /// How long a film takes to come up out of black at the start and to go back into it at
    /// the end. The same beat does for both, so every one opens and closes evenly.
    static let fade: TimeInterval = 0.55
    /// How long after a cut the caption waits before it fades up, and how long that fade
    /// takes. The picture is worth seeing for a moment before there are words over it.
    static let captionDelay: TimeInterval = 0.5
    static let captionFade: TimeInterval = 0.35
    /// A lick of light on the cut itself, which is what makes a new shot read as a cut
    /// rather than as one picture quietly replacing another.
    static let flash: TimeInterval = 0.16

    // MARK: - Reading pace

    /// The pace the lines in the body of a film are read out at, a sentence at a time under the
    /// held picture — the quick middle of a scene, between the two lines it lingers on.
    ///
    /// This is the main knob for how fast the words go by; turn it down and every film reads
    /// quicker. Roughly sixteen characters a second.
    static let secondsPerCaptionCharacter: TimeInterval = 0.063
    /// The least a body sentence is ever held fully up, however short. Without it "Cozy." is gone
    /// before it lands: a one-word line paced only by its length never gets a beat to be read in.
    static let minSentenceHold: TimeInterval = 1.5

    /// The slower pace the two lines a film frames on are read out at — the very first line it
    /// opens on and the last line it hands the game over on. They are held a little longer than
    /// the ones between, so a scene eases in and out rather than rattling by at one speed.
    static let secondsPerFramingCharacter: TimeInterval = 0.084
    /// The least a framing line is held fully up — a longer beat than a body line gets, so the
    /// opening line and the closing card land with a little more weight.
    static let minFramingHold: TimeInterval = 2.0

    /// A caption split into the sentences it is read out one at a time as. A line of a single
    /// sentence is a reel of one, and behaves exactly as a whole caption used to.
    ///
    /// A sentence ends on a full stop, question mark or exclamation — carrying any closing quote
    /// with it, so *… as "lush." That was generous.* reads as two lines and not three — and a
    /// stop with no space after it (there are none in the scripts, but a decimal would be one)
    /// is left inside its sentence rather than splitting it.
    static func sentences(of caption: String) -> [String] {
        let terminators: Set<Character> = [".", "!", "?"]
        let closers: Set<Character> = ["\"", "'", ")", "”", "’"]
        let chars = Array(caption)
        var lines: [String] = []
        var current = ""
        var i = 0
        while i < chars.count {
            let c = chars[i]
            current.append(c)
            i += 1
            guard terminators.contains(c) else { continue }
            while i < chars.count, closers.contains(chars[i]) {
                current.append(chars[i])
                i += 1
            }
            // A stop ends a sentence only when the next thing is a space or the end of the line.
            if i >= chars.count || chars[i] == " " {
                let line = current.trimmingCharacters(in: .whitespaces)
                if !line.isEmpty { lines.append(line) }
                current = ""
                while i < chars.count, chars[i] == " " { i += 1 }
            }
        }
        let tail = current.trimmingCharacters(in: .whitespaces)
        if !tail.isEmpty { lines.append(tail) }
        return lines.isEmpty ? [caption] : lines
    }

    /// How long a sentence is held fully up, before the fades either side of it: its length at
    /// the reading pace, floored so even a one-word line gets a beat. `framing` is the slower,
    /// longer beat the film's opening line and closing card get.
    static func sentenceHold(of sentence: String, framing: Bool) -> TimeInterval {
        let pace = framing ? secondsPerFramingCharacter : secondsPerCaptionCharacter
        let floor = framing ? minFramingHold : minSentenceHold
        return max(floor, Double(sentence.count) * pace)
    }

    /// How long a sentence owns the caption area for, all told: a fade up, its hold, and a fade
    /// down before the next one takes its place. Summed over a line's sentences (after the
    /// opening beat) this is how long a shot runs.
    static func sentenceWindow(_ sentence: String, framing: Bool) -> TimeInterval {
        captionFade + sentenceHold(of: sentence, framing: framing) + captionFade
    }

    /// Whether the sentence at `index` of a `count`-sentence line is one the film frames on and
    /// so reads slower: the very first sentence of the film (when this is its first shot) or the
    /// very last (its last shot's last sentence). The lines in between are the quick middle.
    static func isFraming(index: Int, of count: Int, slowFirst: Bool, slowLast: Bool) -> Bool {
        (index == 0 && slowFirst) || (index == count - 1 && slowLast)
    }

    /// How long a shot runs: the opening beat, then each of its sentences' windows, with the
    /// film's very first and very last sentence held at the slower framing pace. `slowFirst` and
    /// `slowLast` say whether this shot is the film's first and last, since only those two carry
    /// a framing sentence.
    static func shotSeconds(of caption: String, slowFirst: Bool, slowLast: Bool) -> TimeInterval {
        let reel = sentences(of: caption)
        return captionDelay + reel.indices.reduce(0) { total, index in
            let framing = isFraming(index: index, of: reel.count, slowFirst: slowFirst, slowLast: slowLast)
            return total + sentenceWindow(reel[index], framing: framing)
        }
    }

    /// Which sentence of a line is showing `seconds` into a shot, and how far up it is: the
    /// shared caption clock a painted shot and a storybook still both read off. After the
    /// opening beat each sentence waits its turn, fades up over `captionFade`, holds, and fades
    /// down before the next — so only one sentence is ever up, and the last fades out with the
    /// shot rather than being left over the cut. `slowFirst`/`slowLast` hold the film's opening
    /// and closing sentence a little longer.
    static func caption(
        of line: String,
        secondsIn seconds: TimeInterval,
        slowFirst: Bool,
        slowLast: Bool
    ) -> (sentence: String, opacity: Double) {
        let reel = sentences(of: line)
        guard !reel.isEmpty else { return ("", 0) }
        var t = seconds - captionDelay
        for (index, sentence) in reel.enumerated() {
            let framing = isFraming(index: index, of: reel.count, slowFirst: slowFirst, slowLast: slowLast)
            let window = sentenceWindow(sentence, framing: framing)
            if t < window || index == reel.count - 1 {
                let arriving = t / captionFade
                let leaving = (window - t) / captionFade
                return (sentence, min(max(min(arriving, leaving), 0), 1))
            }
            t -= window
        }
        return (reel[0], 0)
    }

    /// What is on screen at one moment: which shot it is, where it comes in the film, and
    /// how long it has been up — which is what the caption and the cut flash are timed off.
    struct Frame: Equatable, Sendable {
        let index: Int
        let shot: Shot
        /// How long this shot has been on screen.
        let seconds: TimeInterval
        /// Whether this shot is the film's first and its last, which is what makes its opening or
        /// closing sentence a slower framing line.
        let slowFirst: Bool
        let slowLast: Bool

        /// The framing-aware length of this frame's shot.
        var shotSeconds: TimeInterval {
            CutScene.shotSeconds(of: shot.caption, slowFirst: slowFirst, slowLast: slowLast)
        }

        /// 0 at the cut to this shot, 1 as it cuts away. What the camera move is drawn from.
        var progress: Double {
            let length = shotSeconds
            guard length > 0 else { return 1 }
            return min(max(seconds / length, 0), 1)
        }

        /// The sentence of the shot's line showing right now, and how far up it is. The line is
        /// read out a sentence at a time: after the opening beat each one waits its turn, fades
        /// up, holds long enough to read, and fades down before the next — so a picture never
        /// carries more than one sentence at once, and none is left over the cut. Before the
        /// beat is up it is the first sentence at nothing.
        var caption: (sentence: String, opacity: Double) {
            CutScene.caption(of: shot.caption, secondsIn: seconds, slowFirst: slowFirst, slowLast: slowLast)
        }

        /// How much light is still on the cut.
        var flash: Double {
            max(0, 1 - seconds / CutScene.flash)
        }
    }

    /// The shot on screen `elapsed` seconds in, or nothing once the film has run out —
    /// which is the same moment the curtain is fully black, so there is nothing to draw.
    func frame(secondsIn elapsed: TimeInterval) -> Frame? {
        let lastIndex = shots.count - 1
        // A clock that has not started yet sits on the first frame rather than on nothing.
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

    /// How much black is over the picture: all of it on the first frame, gone by the time
    /// the film is up, and back over everything as it hands the player on.
    func curtain(secondsIn elapsed: TimeInterval) -> Double {
        let opening = 1 - elapsed / Self.fade
        let closing = 1 - (runtime - elapsed) / Self.fade
        return min(max(max(opening, closing), 0), 1)
    }

    /// How far the bars are in, 0 to 1. They slide in over the top of a film and stay: the
    /// curtain has the screen by the time it ends, so there is nothing to pull them off.
    func letterbox(secondsIn elapsed: TimeInterval) -> Double {
        min(max(elapsed / Self.fade, 0), 1)
    }
}

// MARK: - The meadow's shots

extension CutScene.Picture {
    /// Every shot of the meadow's three films: the world the game has always shipped, and the
    /// one that was painted before there was anywhere else to go.
    enum Meadow: Hashable, Sendable {
        // MARK: The opening

        /// The pig in a poky farm pen by the barn, stepping up to the fence and looking
        /// thoroughly unimpressed with the square footage.
        case homePen
        /// The barn, and the one gap in the fence that nobody shut — the pig already through
        /// it and off to explore the market.
        case theOpenGate
        /// The meadow, with fence pieces popping up around the pig: the property, and the
        /// rack of fencing a player is handed to build on it.
        case welcomeMeadow
        /// A shut pen round the pig with an apple inside it and a skull outside: the scoring
        /// rule drawn rather than written — space scores, apples improve it, skulls hurt it.
        case applesAndSkulls
        /// One panel gone from the pen and the pig walking straight out through the gap: the
        /// other half of the rule, and the pig keeping his options open.
        case closeTheFence

        // MARK: Stag Mere

        /// The meadow, with a deer walking into frame behind the pig: a promising piece of
        /// land, and the one complication on it.
        case promisingLand
        /// The pig and the deer looking at each other across the grass: the current
        /// resident, and the discovery that this was not a vacant lot.
        case theResident
        /// Both animals with a single pen outline round them that splits into two: fence in
        /// both of them, one pen or two, whatever makes the floor plan work.
        case oneOrTwo

        // MARK: The meadow held

        /// The pig stood comfortable in the finished meadow pen: space, good views, plenty
        /// of apples.
        case finishedPen
        /// The pig turned toward a dark forest at the edge of the meadow — the thing he
        /// should have been satisfied without.
        case forestEdge
        /// The pig walking off toward the forest: he has started checking other listings.
        case intoTheForest

        var isCard: Bool {
            switch self {
            case .closeTheFence, .intoTheForest: true
            default: false
            }
        }
    }
}

// MARK: - The films

extension CutScene {
    /// Before the first walk up the meadow.
    ///
    /// Five shots, and between them the reason the pig left home and the rule every puzzle
    /// in the game is scored on, all told in an estate agent's patter: the poky farm pen the
    /// pig outgrew, the gate somebody left open, the meadow with a rack of fencing to build
    /// on, the shut pen with an apple improving it and a skull hurting it, and the pig
    /// walking straight back out through a gap in the fence.
    ///
    /// The last three shots are the briefing the game never otherwise gives. A player who
    /// watches the film knows the property is theirs to build on, that space scores and
    /// apples help and skulls hurt — and, before a single piece is in the ground, that a pen
    /// is worth nothing at all with a gap left in it, because the pig is keeping his
    /// options open.
    static func opening(start: Date = .now) -> Self {
        Self(
            name: .opening,
            shots: [
                Shot(
                    picture: .meadow(.homePen),
                    caption: "Pig had a home. Cozy. Rustic. Extremely limited square footage."
                ),
                Shot(
                    picture: .meadow(.theOpenGate),
                    caption: "Then someone left the gate open. Pig decided it was time to explore the market for some new real estate."
                ),
                Shot(
                    picture: .meadow(.welcomeMeadow),
                    caption: "Welcome to Mudlark Meadow. Use the fence you're given to build Pig the biggest pen you can."
                ),
                Shot(
                    picture: .meadow(.applesAndSkulls),
                    caption: "More space means a better score. Apples improve the property. Skulls hurt the resale value."
                ),
                Shot(
                    picture: .meadow(.closeTheFence),
                    caption: "And make sure to close the fence. Pig is keeping his options open."
                )
            ],
            start: start
        )
    }

    /// Before the meadow's last puzzle.
    ///
    /// Short on purpose. A player who has fenced eight fields does not need teaching how to
    /// fence a ninth — they need telling the one thing about this map that is different,
    /// which is that there are two animals on it. Three shots: the promising piece of land,
    /// the resident already on it, and the rule that follows.
    ///
    /// The rule is still the estate agent's: this was not a vacant lot, so fence in both the
    /// pig and the deer — one pen or two, whatever makes the floor plan work.
    static func stagMere(start: Date = .now) -> Self {
        Self(
            name: .stagMere,
            shots: [
                Shot(
                    picture: .meadow(.promisingLand),
                    caption: "Pig had found a promising piece of land. There was just one complication."
                ),
                Shot(
                    picture: .meadow(.theResident),
                    caption: "The current resident. Apparently this was not a vacant lot."
                ),
                Shot(
                    picture: .meadow(.oneOrTwo),
                    caption: "Fence in both Pig and the deer. One pen or two. Whatever makes the floor plan work."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the meadow holds.
    ///
    /// The one that closes the world out. The pig is housed at last — space, good views,
    /// plenty of apples — and by every account should have been satisfied. He is already
    /// turned toward the dark forest at the meadow's edge, because he has started checking
    /// other listings, which is what makes the next world a reason to go on.
    static func theMeadowHeld(start: Date = .now) -> Self {
        Self(
            name: .theMeadowHeld,
            shots: [
                Shot(
                    picture: .meadow(.finishedPen),
                    caption: "Mudlark Meadow had space. Good views. Plenty of apples."
                ),
                Shot(
                    picture: .meadow(.forestEdge),
                    caption: "By all accounts, Pig should have been satisfied."
                ),
                Shot(
                    picture: .meadow(.intoTheForest),
                    caption: "Unfortunately, he'd started checking other listings."
                )
            ],
            start: start
        )
    }

    /// Every film the game has, which is what the tests walk. In the order the journey meets
    /// them, so a world's three stand together.
    static var all: [CutScene] {
        [
            .opening(), .stagMere(), .theMeadowHeld(),
            .thornwoodOpening(), .boarHollow(), .thornwoodHeld(),
            .emberpeakOpening(), .wyrmCaldera(), .emberpeakHeld(),
            .cogsworthOpening(), .ratKingWharf(), .cogsworthHeld(),
            .starfallOpening(), .visitorCrater(), .starfallHeld(),
            .gloamdeepOpening(), .theRoost(), .gloamdeepHeld(),
            .lanternOpening(), .theCenterRing(), .lanternHeld(),
            .duneOpening(), .scorpionFlats(), .duneHeld(),
            .tidepoolOpening(), .theCrabPool(), .tidepoolHeld(),
            .frostwhiskerOpening(), .theHaulout(), .frostwhiskerHeld(),
            .mirebogOpening(), .theWallow(), .mirebogHeld(),
            .cloudspireOpening(), .theEyrie(), .cloudspireHeld()
        ]
    }

    /// The film a name stands for, so a screen that has been handed a name can play it
    /// without knowing which one it is.
    static func named(_ name: Name, start: Date = .now) -> CutScene {
        switch name {
        case .opening: .opening(start: start)
        case .stagMere: .stagMere(start: start)
        case .theMeadowHeld: .theMeadowHeld(start: start)
        case .thornwoodOpening: .thornwoodOpening(start: start)
        case .boarHollow: .boarHollow(start: start)
        case .thornwoodHeld: .thornwoodHeld(start: start)
        case .emberpeakOpening: .emberpeakOpening(start: start)
        case .wyrmCaldera: .wyrmCaldera(start: start)
        case .emberpeakHeld: .emberpeakHeld(start: start)
        case .cogsworthOpening: .cogsworthOpening(start: start)
        case .ratKingWharf: .ratKingWharf(start: start)
        case .cogsworthHeld: .cogsworthHeld(start: start)
        case .starfallOpening: .starfallOpening(start: start)
        case .visitorCrater: .visitorCrater(start: start)
        case .starfallHeld: .starfallHeld(start: start)
        case .gloamdeepOpening: .gloamdeepOpening(start: start)
        case .theRoost: .theRoost(start: start)
        case .gloamdeepHeld: .gloamdeepHeld(start: start)
        case .lanternOpening: .lanternOpening(start: start)
        case .theCenterRing: .theCenterRing(start: start)
        case .lanternHeld: .lanternHeld(start: start)
        case .duneOpening: .duneOpening(start: start)
        case .scorpionFlats: .scorpionFlats(start: start)
        case .duneHeld: .duneHeld(start: start)
        case .tidepoolOpening: .tidepoolOpening(start: start)
        case .theCrabPool: .theCrabPool(start: start)
        case .tidepoolHeld: .tidepoolHeld(start: start)
        case .frostwhiskerOpening: .frostwhiskerOpening(start: start)
        case .theHaulout: .theHaulout(start: start)
        case .frostwhiskerHeld: .frostwhiskerHeld(start: start)
        case .mirebogOpening: .mirebogOpening(start: start)
        case .theWallow: .theWallow(start: start)
        case .mirebogHeld: .mirebogHeld(start: start)
        case .cloudspireOpening: .cloudspireOpening(start: start)
        case .theEyrie: .theEyrie(start: start)
        case .cloudspireHeld: .cloudspireHeld(start: start)
        }
    }
}

extension CutScene {
    /// Waits out the film.
    ///
    /// Returns whether it ran to the end. A player who skips it takes the screen away,
    /// which cancels the wait — and nothing should be handed on twice.
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
