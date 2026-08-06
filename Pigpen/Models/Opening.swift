import Foundation

/// The film that plays before a player's first walk up the meadow, as a clock.
///
/// Five shots and a little over thirteen seconds: the meadow at first light, the barn with
/// the one gate nobody shut, the pig itself, the pig leaving, and the fencing you are given
/// to answer it with. It introduces the two things every puzzle is made of — a pig, and the
/// ground it is loose in — and then gets out of the way.
///
/// Like the pasture behind the title and the lap of honour on a pen that holds, it is
/// written as a clock rather than as a queue of steps: the screen asks what is on it at a
/// given moment and draws that. So the film cannot fall out of step with itself, a still of
/// any moment of it can be taken for a preview or a screenshot, and skipping it is a matter
/// of walking away from the clock rather than unwinding a pile of half-finished animation.
struct Opening: Equatable, Sendable {
    /// The moment the curtain went up.
    let start: Date

    init(start: Date = .now) {
        self.start = start
    }

    /// One shot of the film: what it shows, what it says over it, and how long it is held.
    struct Shot: Equatable, Sendable, Identifiable {
        let picture: Picture
        let caption: String
        /// How long the shot is on screen.
        let seconds: TimeInterval

        var id: Picture { picture }
    }

    /// What a shot shows. The script only says which picture is up and for how long; how
    /// each one is painted is the screen's business.
    enum Picture: Hashable, Sendable {
        /// The meadow, wide, with the sun coming up over the far hills.
        case firstLight
        /// The barn, and the one gap in the fence that nobody shut.
        case theOpenGate
        /// The pig, head on and filling the frame — the one the whole game is about.
        case thePig
        /// Gone, at a gallop, with the field streaking past it.
        case away
        /// The meadow again, with a run of fencing laid out along the front of it: the
        /// answer to everything the four shots before it just showed.
        case fenceItIn
    }

    /// The film, in order. Every caption is a line rather than a speech: a player pressing
    /// Play wants to be playing, and five short shots is as much introduction as a pig
    /// getting out of a field warrants.
    static let shots: [Shot] = [
        Shot(picture: .firstLight, caption: "Mudlark Meadow, first light.", seconds: 2.8),
        Shot(picture: .theOpenGate, caption: "Somebody left the gate open.", seconds: 2.6),
        Shot(picture: .thePig, caption: "One pig, and nine fields to lose it in.", seconds: 3.0),
        Shot(picture: .away, caption: "It is already going.", seconds: 2.4),
        Shot(picture: .fenceItIn, caption: "Fence it in.", seconds: 2.6)
    ]

    /// How long the whole film runs.
    static let runtime: TimeInterval = shots.reduce(0) { $0 + $1.seconds }

    /// How long the screen takes to come up out of black at the start, and to go back into
    /// it at the end. The same beat does for both, so the film opens and closes evenly.
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
            let arriving = (seconds - Opening.captionDelay) / Opening.captionFade
            let leaving = (shot.seconds - seconds) / Opening.captionFade
            return min(max(min(arriving, leaving), 0), 1)
        }

        /// How much light is still on the cut.
        var flash: Double {
            max(0, 1 - seconds / Opening.flash)
        }
    }

    /// The shot on screen `elapsed` seconds in, or nothing once the film has run out —
    /// which is the same moment the curtain is fully black, so there is nothing to draw.
    func frame(secondsIn elapsed: TimeInterval) -> Frame? {
        // A clock that has not started yet sits on the first frame rather than on nothing.
        guard elapsed > 0 else {
            return Self.shots.first.map { Frame(index: 0, shot: $0, seconds: 0) }
        }

        var left = elapsed
        for (index, shot) in Self.shots.enumerated() {
            if left < shot.seconds {
                return Frame(index: index, shot: shot, seconds: left)
            }
            left -= shot.seconds
        }
        return nil
    }

    /// How much black is over the picture: all of it on the first frame, gone by the time
    /// the meadow is up, and back over everything as the film hands the player to the map.
    func curtain(secondsIn elapsed: TimeInterval) -> Double {
        let opening = 1 - elapsed / Self.fade
        let closing = 1 - (Self.runtime - elapsed) / Self.fade
        return min(max(max(opening, closing), 0), 1)
    }

    /// How far the bars are in, 0 to 1. They slide in over the top of the film and stay:
    /// the curtain has the screen by the time it ends, so there is nothing to pull them
    /// back off.
    func letterbox(secondsIn elapsed: TimeInterval) -> Double {
        min(max(elapsed / Self.fade, 0), 1)
    }
}

extension Opening {
    /// Waits out the film.
    ///
    /// Returns whether it ran to the end. A player who skips it takes the screen away,
    /// which cancels the wait — and nothing should be handed on twice.
    @MainActor
    @discardableResult
    func waitOut() async -> Bool {
        do {
            try await Task.sleep(for: .seconds(Self.runtime))
            return true
        } catch {
            return false
        }
    }
}
