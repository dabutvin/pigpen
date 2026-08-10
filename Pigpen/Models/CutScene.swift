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
    /// Between them they are the whole of the meadow's story: a gate left open on unfenced
    /// country, the one field of that country which already belongs to something, and the
    /// meadow made to hold — with another gate standing open somewhere else by the last
    /// frame, which is what there is to go on for.
    ///
    /// The first of them carries the rules as well as the story, since a player who has
    /// watched it should know what a good pen is before they are handed a rack of fencing:
    /// the pig is out, it would rather stay out, open country is no place for a pig, and the
    /// answer is the biggest pen the fencing will reach round — shut, or it is no pen at all.
    /// Big because the pig wants running about, not because big scores well; the score is
    /// how the game keeps count of a pig with room to stretch its legs.
    enum Name: String, Sendable, CaseIterable {
        /// Before the first walk up the meadow: a pig, the open gate it came through, nine
        /// fields of country with nothing in them to stop it, and the rule the whole game is
        /// scored on — the biggest pen you can lay, so long as it is shut.
        case opening
        /// Before the meadow's last puzzle, which is the only one with two animals on it —
        /// because the last field of the meadow is the stag's, and fencing it has to leave
        /// the stag its water rather than wall it off.
        case stagMere
        /// After it, once every pen in the meadow is held: what all that fencing was for,
        /// and the open gate somewhere else that is the reason to go on.
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
        /// Gone, at a gallop, with the field streaking past it: what chasing it looks like,
        /// and why the game is a fence rather than a chase.
        case away
        /// The pen a player is being asked for, marked out round the pig in dashes and
        /// pushing out as far as the meadow will give it: the scoring rule, drawn rather
        /// than written, since every tile a pen holds is a point — and every tile is
        /// somewhere a shut-in pig can still run.
        case theBiggestPen
        /// The meadow again, with a run of fencing laid out along the front of it — shut,
        /// which is the other half of the rule.
        case fenceItIn

        // MARK: Stag Mere

        /// The mere, with an animal on either side of it.
        case theMere
        /// The stag, head on: the second thing the game ever asks anybody to hold, and the
        /// one animal in the meadow that was there before the farm was.
        case theStag
        /// Both of them, with the pen each would take drawn round them in dashes.
        case bothOrNeither

        // MARK: The meadow held

        /// Both animals shut in, on ground washed gold.
        case bothPenned
        /// The stag alone in the meadow, and the trail out of it: it was let go, and it is
        /// staying on the water it always had.
        case theStagStays
        /// The whole meadow at once: the trail, its stops, the barn and the mere.
        case theWholeMeadow
        /// The meadow from further out than that — a world, with a stag stood on it.
        case theMeadowFromOut
        /// And another one out past it, coming alight: the next gate standing open.
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
    /// Six shots, and between them the reason the game is nine puzzles rather than one and
    /// the rule every one of them is scored on: the meadow with no fence anywhere in it,
    /// the gate somebody left open, the pig and what it wants, the pig at a gallop with the
    /// line that says chasing it is not going to work, the pen a player is being asked for
    /// pushing out as far as it will go, and the fencing that shuts it.
    ///
    /// The last two shots are the briefing the game never otherwise gives. A player who
    /// watches the film knows what got out, why the job is the meadow rather than the
    /// animal, and — before a single piece is in the ground — that a pen is worth what it
    /// holds and worth nothing at all with a gap left in it.
    ///
    /// *Room to run* is why, and it is the half a scoring rule cannot say on its own. The
    /// pig wants to be free and open country is not safe for it, so the biggest pen there
    /// is becomes the kindest answer available rather than a high score with an animal in
    /// it: as close to loose as a pig can safely get, and what the meadow's last film hands
    /// back, nine fields wide and shut.
    static func opening(start: Date = .now) -> Self {
        Self(
            name: .opening,
            shots: [
                Shot(
                    picture: .firstLight,
                    caption: "Mudlark Meadow, first light. Not a fence in it.",
                    seconds: 3.0
                ),
                Shot(picture: .theOpenGate, caption: "Somebody left the gate open.", seconds: 2.3),
                Shot(picture: .thePig, caption: "One pig, out, and it wants to be free.", seconds: 2.6),
                Shot(
                    picture: .away,
                    caption: "Open country is not safe, and you will not catch it.",
                    seconds: 3.3
                ),
                Shot(
                    picture: .theBiggestPen,
                    caption: "Give it the biggest pen you can. Room to run.",
                    seconds: 2.9
                ),
                Shot(picture: .fenceItIn, caption: "Fence it in. One gap, and it is gone.", seconds: 2.6)
            ],
            start: start
        )
    }

    /// Before the meadow's last puzzle.
    ///
    /// Short on purpose. A player who has fenced eight fields does not need teaching how to
    /// fence a ninth — they need telling the one thing about this map that is different,
    /// which is that there are two animals on it and one budget for the pair. Three shots
    /// and under nine seconds: the water, whose water it is, and the rule that follows.
    ///
    /// The middle shot is the story half of the briefing. The rule reads as arithmetic on
    /// its own — two animals, one budget — and as something worth doing once the far shore
    /// belongs to somebody: the last field of the meadow is not empty ground, so fencing it
    /// means making room for what already lives there rather than walling it out.
    static func stagMere(start: Date = .now) -> Self {
        Self(
            name: .stagMere,
            shots: [
                Shot(picture: .theMere, caption: "Stag Mere. Water straight down the middle.", seconds: 2.7),
                Shot(
                    picture: .theStag,
                    caption: "The stag had that shore before the barn did.",
                    seconds: 2.9
                ),
                Shot(
                    picture: .bothOrNeither,
                    caption: "Twenty pieces. Both of them held, or neither counts.",
                    seconds: 3.3
                )
            ],
            start: start
        )
    }

    /// After the last pen in the meadow holds.
    ///
    /// The one that closes the world out, and the one that has to pay off the opening: both
    /// animals held a shore apiece, the stag left on the water that was always its own, the
    /// nine fields fenced and the pig free to be loose in all of them, a meadow nothing gets
    /// out of any more — and then, out past it, another gate standing open somewhere else.
    ///
    /// That last line is the opening's second shot said again from further away, which is
    /// what makes the next world a reason to go on rather than simply more country.
    static func theMeadowHeld(start: Date = .now) -> Self {
        Self(
            name: .theMeadowHeld,
            shots: [
                Shot(picture: .bothPenned, caption: "Both of them held, a shore apiece.", seconds: 2.5),
                Shot(
                    picture: .theStagStays,
                    caption: "The stag stays. It had this meadow before you did.",
                    seconds: 3.1
                ),
                Shot(
                    picture: .theWholeMeadow,
                    caption: "Nine fields fenced, and the pig loose in all of them.",
                    seconds: 3.2
                ),
                Shot(
                    picture: .theMeadowFromOut,
                    caption: "Nothing gets out of Mudlark Meadow now.",
                    seconds: 3.0
                ),
                Shot(
                    picture: .somewhereElse,
                    caption: "Somewhere else, a gate is standing open.",
                    seconds: 3.0
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
