import Foundation

/// A film the game stops to play, as a clock.
///
/// Three of them so far: the one before a player's first walk up the meadow, the one that
/// says what makes the meadow's last puzzle the boss, and the one that sees them off it.
/// They are all the same machine — a list of shots, each held for a moment and captioned —
/// so a fourth is a list and a few pictures rather than another screen.
///
/// Like the pasture behind the title and the lap of honour on a pen that holds, a scene is
/// written as a clock rather than as a queue of steps: the screen asks what is on it at a
/// given moment and draws that. So a film cannot fall out of step with itself, a still of
/// any moment of it can be taken for a preview or a screenshot, and skipping it is a matter
/// of walking away from the clock rather than unwinding a pile of half-finished animation.
struct CutScene: Equatable, Sendable {
    /// Which film this is.
    ///
    /// Named rather than left anonymous because the game has to remember which ones a
    /// player has already sat through — none of them is worth showing twice.
    enum Name: String, Sendable, CaseIterable {
        /// Before the first walk up the meadow: a pig, and the ground it is loose in.
        case opening
        /// Before the meadow's last puzzle, which is the only one with two animals on it.
        case stagMere
        /// After it, once every pen in the meadow is held.
        case theMeadowHeld
    }

    let name: Name
    /// The film, in order.
    let shots: [Shot]
    /// The moment the curtain went up.
    let start: Date

    init(name: Name, shots: [Shot], start: Date = .now) {
        self.name = name
        self.shots = shots
        self.start = start
    }

    /// One shot of a film: what it shows, what it says over it, and how long it is held.
    struct Shot: Equatable, Sendable, Identifiable {
        let picture: Picture
        let caption: String
        /// How long the shot is on screen.
        let seconds: TimeInterval

        var id: Picture { picture }
    }

    /// What a shot shows. A script only says which picture is up and for how long; how each
    /// one is painted is the screen's business.
    enum Picture: Hashable, Sendable {
        // MARK: The opening

        /// The meadow, wide, with the sun coming up over the far hills.
        case firstLight
        /// The barn, and the one gap in the fence that nobody shut.
        case theOpenGate
        /// The pig, head on and filling the frame — the one the whole game is about.
        case thePig
        /// Gone, at a gallop, with the field streaking past it.
        case away
        /// The meadow again, with a run of fencing laid out along the front of it.
        case fenceItIn

        // MARK: Stag Mere

        /// The mere, with an animal on either side of it.
        case theMere
        /// The stag, head on: the second thing the game ever asks anybody to hold.
        case theStag
        /// Both of them, with the pen each would take drawn round them in dashes.
        case bothOrNeither

        // MARK: The meadow held

        /// Both animals shut in, on ground washed gold.
        case bothPenned
        /// The stag alone in the meadow, and the trail out of it.
        case theStagStays
        /// The whole meadow at once: the trail, its stops, the barn and the mere.
        case theWholeMeadow
        /// The meadow from further out than that — a world, with a stag stood on it.
        case theMeadowFromOut
        /// And another one out past it, coming alight.
        case somewhereElse
    }

    // MARK: - Timing

    /// How long the whole film runs.
    var runtime: TimeInterval { shots.reduce(0) { $0 + $1.seconds } }

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

    /// What is on screen at one moment: which shot it is, where it comes in the film, and
    /// how long it has been up — which is what the caption and the cut flash are timed off.
    struct Frame: Equatable, Sendable {
        let index: Int
        let shot: Shot
        /// How long this shot has been on screen.
        let seconds: TimeInterval

        /// 0 at the cut to this shot, 1 as it cuts away. What the camera move is drawn from.
        var progress: Double {
            guard shot.seconds > 0 else { return 1 }
            return min(max(seconds / shot.seconds, 0), 1)
        }

        /// The caption comes up a beat after the cut, holds, and goes back out with the
        /// shot, so no line of type is ever left over a picture it does not belong to.
        var captionOpacity: Double {
            let arriving = (seconds - CutScene.captionDelay) / CutScene.captionFade
            let leaving = (shot.seconds - seconds) / CutScene.captionFade
            return min(max(min(arriving, leaving), 0), 1)
        }

        /// How much light is still on the cut.
        var flash: Double {
            max(0, 1 - seconds / CutScene.flash)
        }
    }

    /// The shot on screen `elapsed` seconds in, or nothing once the film has run out —
    /// which is the same moment the curtain is fully black, so there is nothing to draw.
    func frame(secondsIn elapsed: TimeInterval) -> Frame? {
        // A clock that has not started yet sits on the first frame rather than on nothing.
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

// MARK: - The films

extension CutScene {
    /// Before the first walk up the meadow.
    ///
    /// Five shots: the meadow at first light, the barn with the gate nobody shut, the pig
    /// itself, the pig leaving, and the fencing the player is given to answer it with. It
    /// introduces the two things every puzzle is made of and then gets out of the way.
    static func opening(start: Date = .now) -> Self {
        Self(
            name: .opening,
            shots: [
                Shot(picture: .firstLight, caption: "Mudlark Meadow, first light.", seconds: 2.8),
                Shot(picture: .theOpenGate, caption: "Somebody left the gate open.", seconds: 2.6),
                Shot(picture: .thePig, caption: "One pig, and nine fields to lose it in.", seconds: 3.0),
                Shot(picture: .away, caption: "It is already going.", seconds: 2.4),
                Shot(picture: .fenceItIn, caption: "Fence it in.", seconds: 2.6)
            ],
            start: start
        )
    }

    /// Before the meadow's last puzzle.
    ///
    /// Short on purpose. A player who has fenced eight fields does not need teaching how to
    /// fence a ninth — they need telling the one thing about this map that is different,
    /// which is that there are two animals on it and one budget for the pair. Three shots
    /// and eight seconds: the water, the stag, and the rule.
    static func stagMere(start: Date = .now) -> Self {
        Self(
            name: .stagMere,
            shots: [
                Shot(picture: .theMere, caption: "Stag Mere. Water straight down the middle.", seconds: 2.6),
                Shot(picture: .theStag, caption: "There is a stag on the far shore.", seconds: 2.6),
                Shot(
                    picture: .bothOrNeither,
                    caption: "Twenty pieces. Both of them held, or neither counts.",
                    seconds: 2.9
                )
            ],
            start: start
        )
    }

    /// After the last pen in the meadow holds.
    ///
    /// The one that closes the world out: both animals held, the stag left where it lives,
    /// the whole meadow seen at once, and then the meadow seen from far enough out to be a
    /// world with more country past it.
    static func theMeadowHeld(start: Date = .now) -> Self {
        Self(
            name: .theMeadowHeld,
            shots: [
                Shot(picture: .bothPenned, caption: "Both of them held.", seconds: 2.5),
                Shot(picture: .theStagStays, caption: "The stag keeps the meadow.", seconds: 2.8),
                Shot(picture: .theWholeMeadow, caption: "Nine fields, every one of them fenced.", seconds: 2.8),
                Shot(picture: .theMeadowFromOut, caption: "Mudlark Meadow is yours.", seconds: 3.0),
                Shot(picture: .somewhereElse, caption: "And there is more country than this.", seconds: 3.0)
            ],
            start: start
        )
    }

    /// Every film the game has, which is what the tests walk.
    static var all: [CutScene] { [.opening(), .stagMere(), .theMeadowHeld()] }

    /// The film a name stands for, so a screen that has been handed a name can play it
    /// without knowing which one it is.
    static func named(_ name: Name, start: Date = .now) -> CutScene {
        switch name {
        case .opening: .opening(start: start)
        case .stagMere: .stagMere(start: start)
        case .theMeadowHeld: .theMeadowHeld(start: start)
        }
    }
}

extension CutScene.Name {
    /// The film that sets a level up before it opens, if it has one.
    ///
    /// Only the boss does. Every other map in the meadow is the same game on new ground —
    /// there is nothing to say about it that the ground does not say itself — where Stag
    /// Mere is the one that changes the rules, and a rule is worth eight seconds.
    init?(briefingFor levelID: String) {
        guard levelID == PuzzleLevel.stagMere.id else { return nil }
        self = .stagMere
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
