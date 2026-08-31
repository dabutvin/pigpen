import Observation

/// The scripted walkthrough that teaches the game on the practice pen.
///
/// Each step waits on one thing the player does — a tap, a drag, a continue, a closed
/// pen, or releasing the pig — and then hands them the next. The field is the same
/// puzzle engine the meadow uses; only which tiles are fair game and which controls
/// light up change from step to step.
@MainActor
@Observable
final class TutorialLesson {
    enum Step: Int, CaseIterable, Equatable {
        /// The goal, before any fencing is down.
        case welcome
        /// Tap one glowing tile to plant a post.
        case tap
        /// Drag a short run of fencing.
        case drag
        /// Point out the bonus and the penalty, each with its little price tag.
        case treats
        /// Fence the remaining gaps until the pen washes gold.
        case close
        /// Release the pig to prove the pen holds.
        case release
        /// The send-off, and the way out to the meadow.
        case finished
    }

    /// What the walkthrough is remembered under, beside the films. It is written down the
    /// same way one is because it is owed the same way one is: once, to somebody who has
    /// never played, whether they sit through it or walk out of it.
    static let seenKey = "tutorial"

    private(set) var step: Step = .welcome
    let game: PuzzleGame

    init(game: PuzzleGame = PuzzleGame(level: .practicePen)) {
        self.game = game
    }

    // MARK: - Scripted fencing

    /// The first post, at the top of the open east side.
    static let firstPost = GridPoint(row: 1, column: 4)

    /// The rest of the east wall, laid as a short drag south from the first post.
    static let eastRun: Set<GridPoint> = [
        GridPoint(row: 2, column: 4),
        GridPoint(row: 3, column: 4)
    ]

    /// The south-west closing run that shuts the pen against the water.
    static let closingRun: Set<GridPoint> = [
        GridPoint(row: 4, column: 3),
        GridPoint(row: 5, column: 1),
        GridPoint(row: 5, column: 2)
    ]

    /// Every tile the walkthrough asks the player to fence, in order.
    static var scriptedFences: Set<GridPoint> {
        Set([firstPost]).union(eastRun).union(closingRun)
    }

    // MARK: - What the step allows

    /// Tiles the coach is pointing at right now. Empty while the card is talking and
    /// there is nothing to tap.
    var highlightedTiles: Set<GridPoint> {
        switch step {
        case .tap:
            game.fences.contains(Self.firstPost) ? [] : [Self.firstPost]
        case .drag:
            Self.eastRun.subtracting(game.fences)
        case .close:
            Self.closingRun.subtracting(game.fences)
        case .welcome, .treats, .release, .finished:
            []
        }
    }

    /// Tiles a press may fence during this step. Anything else is refused, so the
    /// walkthrough cannot be derailed by a post planted in the wrong place.
    var buildableTiles: Set<GridPoint> {
        switch step {
        case .tap: [Self.firstPost]
        case .drag: Self.eastRun
        case .close: Self.closingRun
        case .welcome, .treats, .release, .finished: []
        }
    }

    /// Treats the coach is pricing up. The treats step is the one that has to say what an
    /// apple and a skull are worth, so it puts the number on both where they lie; every
    /// other step lets the board alone and prices a treat only once a pen has shut on it.
    var pricedTiles: Set<GridPoint> {
        step == .treats ? Set(game.level.treats.keys) : []
    }

    var allowsBuilding: Bool { !buildableTiles.isEmpty }

    /// The Release button only lights once the pen is shut and the coach asks for it.
    var allowsRelease: Bool { step == .release }

    /// Whether the coach card advances on Continue rather than on something done to the field.
    var showsContinue: Bool {
        switch step {
        case .welcome, .treats, .finished: true
        case .tap, .drag, .close, .release: false
        }
    }

    var headline: String {
        switch step {
        case .welcome: "Welcome to Pigpen"
        case .tap: "Place a fence"
        case .drag: "Build faster"
        case .treats: "Choose what's inside"
        case .close: "Keep Pig in"
        case .release: "See how you did"
        case .finished: "You're ready"
        }
    }

    var detail: String {
        switch step {
        case .welcome:
            "Pig needs a little more room. Your job is to build him the biggest pen you can. Let's try one."
        case .tap:
            "Tap a tile to place a fence piece. Try it now."
        case .drag:
            "Tap and drag across tiles to place several pieces at once. Give it a try."
        case .treats:
            "Bonus tiles add points. Penalty tiles take points away. Try to fence in the bonus and leave the penalty out."
        case .close:
            "Make sure your fence is completely closed. Leave a gap and Pig will wander off."
        case .release:
            "Release the pig. Earn up to 3 stars. More space + bonuses = a better score."
        case .finished:
            "That's it. Go give Pig some room to roam."
        }
    }

    // MARK: - Advancing

    /// Moves on from a step that only needs reading. Returns whether the step changed.
    @discardableResult
    func continueTapped() -> Bool {
        switch step {
        case .welcome:
            step = .tap
            return true
        case .treats:
            step = .close
            return true
        case .finished:
            return false
        case .tap, .drag, .close, .release:
            return false
        }
    }

    /// Opens a press so a drag across several glowing tiles undoes as one stroke.
    func beginStroke() {
        game.beginStroke()
    }

    func endStroke() {
        game.endStroke()
    }

    /// Tries to fence a tile the coach is pointing at. Returns whether the field changed.
    @discardableResult
    func buildFence(on tile: GridPoint) -> Bool {
        guard allowsBuilding, buildableTiles.contains(tile) else { return false }
        guard game.buildFence(on: tile) else { return false }
        reconsider()
        return true
    }

    /// Lets the pig go when the coach asks for it.
    func releasePig() {
        guard allowsRelease else { return }
        game.openTheGate()
        reconsider()
    }

    /// Reads the field and moves the lesson on when the step's work is done.
    func reconsider() {
        switch step {
        case .tap:
            if game.fences.contains(Self.firstPost) {
                step = .drag
            }
        case .drag:
            // The coach asks for a drag, but two taps that fill the same tiles count —
            // the lesson is the run of fencing, not the gesture that got it there.
            if Self.eastRun.isSubset(of: game.fences) {
                step = .treats
            }
        case .close:
            if game.isPenClosed {
                step = .release
            }
        case .release:
            if case .penned = game.phase {
                step = .finished
            }
        case .welcome, .treats, .finished:
            break
        }
    }
}
