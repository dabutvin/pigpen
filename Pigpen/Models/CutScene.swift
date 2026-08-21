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
    ///
    /// Between them they are the whole of the meadow's story, told in an estate agent's
    /// voice: a pig who outgrew a poky farm pen and went looking for property, the meadow
    /// he found and the resident he had to share it with, and the pig — housed at last, and
    /// already reading other listings.
    ///
    /// The first of them carries the rules as well as the story, since a player who has
    /// watched it should know what a good pen is before they are handed a rack of fencing:
    /// build the biggest pen the fencing will reach round, more space is a better score,
    /// apples improve the property and skulls hurt its resale value — and close the fence,
    /// because the pig has no respect for property lines.
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
        /// other half of the rule, and the pig's contempt for property lines.
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
    /// Five shots, and between them the reason the pig left home and the rule every puzzle
    /// in the game is scored on, all told in an estate agent's patter: the poky farm pen the
    /// pig outgrew, the gate somebody left open, the meadow with a rack of fencing to build
    /// on, the shut pen with an apple improving it and a skull hurting it, and the pig
    /// walking straight back out through a gap in the fence.
    ///
    /// The last three shots are the briefing the game never otherwise gives. A player who
    /// watches the film knows the property is theirs to build on, that space scores and
    /// apples help and skulls hurt — and, before a single piece is in the ground, that a pen
    /// is worth nothing at all with a gap left in it, because the pig has no respect for
    /// property lines.
    static func opening(start: Date = .now) -> Self {
        Self(
            name: .opening,
            shots: [
                Shot(
                    picture: .homePen,
                    caption: "Pig had a home. Cozy. Rustic. Extremely limited square footage.",
                    seconds: 4.0
                ),
                Shot(
                    picture: .theOpenGate,
                    caption: "Then someone left the gate open. Pig decided to explore the market.",
                    seconds: 4.0
                ),
                Shot(
                    picture: .welcomeMeadow,
                    caption: "Welcome to Mudlark Meadow. Use the fence you're given to build Pig the biggest pen you can.",
                    seconds: 5.4
                ),
                Shot(
                    picture: .applesAndSkulls,
                    caption: "More space means a better score. Apples improve the property. Skulls hurt the resale value.",
                    seconds: 5.4
                ),
                Shot(
                    picture: .closeTheFence,
                    caption: "And close the fence. Pig has no respect for property lines.",
                    seconds: 3.8
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
                    picture: .promisingLand,
                    caption: "Pig found a promising piece of land. There was just one complication.",
                    seconds: 4.2
                ),
                Shot(
                    picture: .theResident,
                    caption: "The current resident. Apparently this was not a vacant lot.",
                    seconds: 3.8
                ),
                Shot(
                    picture: .oneOrTwo,
                    caption: "Fence in both Pig and the deer. One pen or two, whatever makes the floor plan work.",
                    seconds: 5.0
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
                    picture: .finishedPen,
                    caption: "Mudlark Meadow had space. Good views. Plenty of apples.",
                    seconds: 3.6
                ),
                Shot(
                    picture: .forestEdge,
                    caption: "By all accounts, Pig should have been satisfied.",
                    seconds: 3.2
                ),
                Shot(
                    picture: .intoTheForest,
                    caption: "Unfortunately, he'd started checking other listings.",
                    seconds: 3.6
                )
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
