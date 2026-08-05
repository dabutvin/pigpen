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
        /// Point out that water is a free wall.
        case water
        /// Fence the remaining gaps until the pen washes gold.
        case close
        /// Release the pig to prove the pen holds.
        case release
        /// Score, stars, and the way out to the meadow.
        case finished
    }

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
        [firstPost].union(eastRun).union(closingRun)
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
        case .welcome, .water, .release, .finished:
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
        case .welcome, .water, .release, .finished: []
        }
    }

    var allowsBuilding: Bool { !buildableTiles.isEmpty }

    /// The Release button only lights once the pen is shut and the coach asks for it.
    var allowsRelease: Bool { step == .release }

    /// Whether the coach card advances on Continue rather than on something done to the field.
    var showsContinue: Bool {
        switch step {
        case .welcome, .water, .finished: true
        case .tap, .drag, .close, .release: false
        }
    }

    var headline: String {
        switch step {
        case .welcome: "A practice field"
        case .tap: "Plant a post"
        case .drag: "Lay a run"
        case .water: "Water walls for free"
        case .close: "Shut the gaps"
        case .release: "Let it try"
        case .finished: "Penned in"
        }
    }

    var detail: String {
        switch step {
        case .welcome:
            "Fence in the pig. You get a fixed number of pieces — tap Continue and we will walk through how to spend them."
        case .tap:
            "Tap the glowing mud tile to lay a fence piece. The pig cannot walk through fencing."
        case .drag:
            "Press on a glowing tile and drag to the next. A whole run of fencing goes down in one stroke."
        case .water:
            "Rivers and lakes are a boundary the pig cannot cross. You cannot build on them, and you never need to — build against them instead."
        case .close:
            "Fence the glowing tiles. When every way off the map is closed, the ground inside washes gold."
        case .release:
            "The wash says the pen holds. Release the pig to prove it — and to see what the pen is worth."
        case .finished:
            finishedDetail
        }
    }

    /// What the closed pen held, and why the meadow will ask for more of it.
    private var finishedDetail: String {
        let held = game.penTally?.area ?? game.bestScore
        let tiles = held == 1 ? "1 mud tile" : "\(held) mud tiles"
        return "You held \(tiles). Every tile inside a pen that holds scores a point, and bigger pens earn more stars. Ready for the meadow?"
    }

    // MARK: - Advancing

    /// Moves on from a step that only needs reading. Returns whether the step changed.
    @discardableResult
    func continueTapped() -> Bool {
        switch step {
        case .welcome:
            step = .tap
            return true
        case .water:
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
        game.releasePig()
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
                step = .water
            }
        case .close:
            if game.isPenClosed {
                step = .release
            }
        case .release:
            if case .penned = game.phase {
                step = .finished
            }
        case .welcome, .water, .finished:
            break
        }
    }
}
