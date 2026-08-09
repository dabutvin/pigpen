import Observation

/// The state of one puzzle in progress: the tiles fenced off so far, and what the animals
/// did the last time the gate was opened.
@MainActor
@Observable
final class PuzzleGame {
    enum Phase: Equatable {
        /// Fences can be added and removed.
        case building
        /// Something walked out, and `escapes` is the walk each one that did took.
        case escaped(escapes: [Escape])
        /// Everything is penned in `pen`.
        case penned(pen: Set<GridPoint>)
    }

    /// A pen that held, kept whole: what it was worth and the fencing that held it.
    struct Pen: Equatable {
        let fences: Set<GridPoint>
        let tally: PenTally

        var score: Int { tally.score }
    }

    let level: PuzzleLevel
    /// The tiles filled in with fencing. The pig cannot walk onto any of them.
    private(set) var fences: Set<GridPoint> = []
    private(set) var phase: Phase = .building
    /// The best pen closed so far this session, fencing and all, so a rearrangement
    /// that turns out worse can be measured against it and put back.
    private(set) var bestPen: Pen?
    /// What the animals would do if the gate were opened this instant, kept up to date as
    /// the fencing changes so a closed pen can be shown as closed the moment it closes.
    private var outcome: PenOutcome
    /// The field as it stood before each change made to it, oldest first, and the fields
    /// undone waiting to be laid back down. One press is one step, so a drag that lays a
    /// run of fencing comes back out in a single undo.
    private var past: [Set<GridPoint>] = []
    private var future: [Set<GridPoint>] = []
    /// Whether a press is underway, and whether it has already put the field it started
    /// from away. Only the first tile a press changes does that; the rest join it.
    private var pressIsOpen = false
    private var pressIsRemembered = false

    init(level: PuzzleLevel) {
        self.level = level
        self.outcome = level.release(fences: [])
    }

    var isBuilding: Bool { phase == .building }
    var fencesRemaining: Int { level.fenceBudget - fences.count }
    /// The most any pen has been worth this session, and 0 before one has closed.
    var bestScore: Int { bestPen?.score ?? 0 }

    /// Whether the fencing and the water together already shut every animal in — true as
    /// soon as the last gap is filled, without waiting for the gate to be opened and prove it.
    var isPenClosed: Bool {
        if case .penned = outcome { true } else { false }
    }

    /// The mud tiles the fencing shuts the animals into, and an empty set while a way off
    /// the map remains.
    var penTiles: Set<GridPoint> {
        if case .penned(let pen) = outcome { pen } else { [] }
    }

    /// What the fencing is holding — ground, apples and skulls — and nothing while a way
    /// off the map remains.
    var penTally: PenTally? {
        if case .penned(let pen) = outcome { level.tally(for: pen) } else { nil }
    }

    /// Whether the pen is the best the map has in it — true as soon as the fencing that
    /// holds it is down, so the field can say so, and there is no better pen left to send
    /// the player back out after.
    var isPenAsGoodAsItGets: Bool {
        guard let penTally else { return false }
        return level.isMaximumScore(penTally.score)
    }

    /// The little circle each animal runs once the gate has been opened on a pen that
    /// holds, and nothing while the field is still being built or something has got out.
    var victoryLaps: [VictoryLap] {
        guard case .penned(let pen) = phase else { return [] }
        return level.victoryLaps(inside: pen)
    }

    /// What the map makes of the pen the animals have actually been let loose in: its
    /// stars, and whether it is the best pen there is. Nothing is scored until the gate
    /// has been opened.
    var verdict: PenVerdict? {
        guard case .penned(let pen) = phase else { return nil }
        return level.verdict(forScore: level.tally(for: pen).score)
    }

    /// The stars for the pen the animals have actually been let loose in. Nothing is
    /// scored until the gate has been opened.
    var starRating: Int? { verdict?.stars }

    /// Whether there is a change to the field to take back. Nothing can be undone while
    /// the animals are out; fetch them back first.
    var canUndo: Bool { isBuilding && !past.isEmpty }

    /// Whether a change that was taken back can be laid down again.
    var canRedo: Bool { isBuilding && !future.isEmpty }

    /// Whether the field stands somewhere other than on its best pen, so putting it back
    /// is worth offering. False while the animals are out, and until a pen has closed at all.
    var canRestoreBestPen: Bool {
        guard isBuilding, let bestPen else { return false }
        return bestPen.fences != fences
    }

    /// Puts the fencing back the way it stood when it held the best pen of the session,
    /// however many presses ago that was, so a rearrangement that turned out worse costs
    /// nothing. It is one step of its own, so `undo` takes the field off the best pen
    /// again. Returns whether anything changed.
    @discardableResult
    func restoreBestPen() -> Bool {
        endStroke()
        guard canRestoreBestPen, let bestPen else { return false }

        remember()
        fences = bestPen.fences
        reconsider()
        return true
    }

    /// Fills a tile in with fencing, or clears it again. Returns whether anything changed,
    /// so the caller can tell a refused tap from an accepted one.
    @discardableResult
    func toggleFence(on tile: GridPoint) -> Bool {
        fences.contains(tile) ? clearFence(on: tile) : buildFence(on: tile)
    }

    /// Fills a tile in with fencing. Returns whether anything changed: a tile that is
    /// already fenced, or that the map or the budget refuses, leaves the field as it was.
    @discardableResult
    func buildFence(on tile: GridPoint) -> Bool {
        guard isBuilding, !fences.contains(tile) else { return false }
        guard level.canBuildFence(on: tile), fencesRemaining > 0 else { return false }

        remember()
        fences.insert(tile)
        reconsider()
        return true
    }

    /// Takes the fencing back out of a tile, giving the piece back. Returns whether
    /// anything changed.
    @discardableResult
    func clearFence(on tile: GridPoint) -> Bool {
        guard isBuilding, fences.contains(tile) else { return false }

        remember()
        fences.remove(tile)
        reconsider()
        return true
    }

    /// Opens a press, so everything it goes on to change is undone in one step. A tap
    /// works one tile and a drag a whole run of them; either way the finger's whole
    /// journey is one thing the player did, and one thing they can take back.
    func beginStroke() {
        pressIsOpen = true
        pressIsRemembered = false
    }

    /// Closes the press, so the next change starts a step of its own.
    func endStroke() {
        pressIsOpen = false
        pressIsRemembered = false
    }

    /// Puts the field back as it was before the last thing the player did to it. Returns
    /// whether there was anything to take back.
    @discardableResult
    func undo() -> Bool {
        endStroke()
        guard isBuilding, let previous = past.popLast() else { return false }

        future.append(fences)
        fences = previous
        reconsider()
        return true
    }

    /// Lays back down what `undo` took away. Returns whether there was anything to put back.
    @discardableResult
    func redo() -> Bool {
        endStroke()
        guard isBuilding, let next = future.popLast() else { return false }

        past.append(fences)
        fences = next
        reconsider()
        return true
    }

    /// Opens the gate and sees what the animals make of the fences.
    func openTheGate() {
        guard isBuilding else { return }
        endStroke()

        switch outcome {
        case .escaped(let escapes):
            phase = .escaped(escapes: escapes)
        case .penned(let pen):
            phase = .penned(pen: pen)
        }
    }

    /// Fetches the animals back, leaving the fences up so a gap can be patched or a pen
    /// widened.
    func resumeBuilding() {
        phase = .building
    }

    /// Tears every fence back out and starts the field over. A field cleared by accident
    /// is one `undo` away from coming back, and the best pen of the session outlives the
    /// clearing either way.
    func startOver() {
        endStroke()
        if !fences.isEmpty {
            remember()
            fences.removeAll()
            reconsider()
        }
        phase = .building
    }

    /// Walks the animals out again on paper, after the fencing has changed, and remembers
    /// the fencing if it is worth more than anything before it. A pen counts from the
    /// moment it closes: nothing has to be let out for the score to stand.
    private func reconsider() {
        outcome = level.release(fences: fences)

        guard case .penned(let pen) = outcome else { return }
        let tally = level.tally(for: pen)
        guard isWorthRemembering(tally) else { return }
        bestPen = Pen(fences: fences, tally: tally)
    }

    /// Whether a pen beats the one being kept: a better score, or the same score held with
    /// pieces to spare, which is the same score with more budget left to widen it.
    private func isWorthRemembering(_ tally: PenTally) -> Bool {
        guard let bestPen else { return true }
        return tally.score == bestPen.score
            ? fences.count < bestPen.fences.count
            : tally.score > bestPen.score
    }

    /// Files the field away, so whatever is about to change about it can be undone. A press
    /// files it once however many tiles it goes on to work, and whatever was undone before
    /// is given up: a new fence is a new course, not a way back onto the old one.
    private func remember() {
        if pressIsOpen {
            guard !pressIsRemembered else { return }
            pressIsRemembered = true
        }

        past.append(fences)
        future.removeAll()
    }
}

extension PuzzleGame {
    /// River Bend with its west wall part way down, so previews and the screenshots CI
    /// takes show a board with fencing on it and something for undo to take back. Each
    /// piece is laid as a press of its own, the way a player lays them one tap at a time.
    static func partWayThrough() -> PuzzleGame {
        let game = PuzzleGame(level: .riverBend)
        for row in 5...9 {
            game.beginStroke()
            game.buildFence(on: GridPoint(row: row, column: 0))
            game.endStroke()
        }
        return game
    }

    /// Windfall Orchard with the best pen the map has in it standing, which is the board to
    /// look at when the question is what an apple does: two of them are inside the pen and
    /// worth five tiles apiece, and the other two are under the fencing that got there.
    static func theOrchardsBestPen() -> PuzzleGame {
        let game = PuzzleGame(level: .windfallOrchard)
        for row in 3...8 {
            game.beginStroke()
            game.buildFence(on: GridPoint(row: row, column: max(0, row - 5)))
            game.buildFence(on: GridPoint(row: row, column: 12 - row))
            game.endStroke()
        }
        return game
    }

    /// Sour Ground with the ground east of the little lake boxed off, which is the board
    /// that has an apple and a skull on it at once. One of each is inside the pen, where
    /// they cancel out and leave it worth exactly the ten tiles it holds. The other skull
    /// is left outside, and the wall takes the step in beside it that it has to: nothing
    /// can be built on a skull, so a wall that wants its tile goes round.
    static func applesAndSkulls() -> PuzzleGame {
        let game = PuzzleGame(level: .sourGround)
        game.build("""
            ..........
            ..........
            .....##...
            ....#..#..
            ...#...#..
            .......#..
            .......#..
            .....##...
            ..........
            ..........
            """)
        return game
    }

    /// Stag Mere with the best pen the meadow has in it standing, which is the board to
    /// look at when the question is what a second animal does: two enclosures leaning on
    /// the same water, one round the pig and one round the stag, three apples shut in
    /// between them and a skull shut in on either shore, since neither wall can be laid
    /// over the one in its way and going round it costs more ground than it is worth.
    static func theStagMeresBestPen() -> PuzzleGame {
        let game = PuzzleGame(level: .stagMere)
        game.build("""
            ...###....
            ..#...#...
            .#.....#..
            #......#..
            ..........
            .......#..
            #.......#.
            .#......#.
            ..#....#..
            ...#..#...
            ....##....
            """)
        return game
    }

    /// A daily puzzle with the south-west of its wall laid and the pen still open.
    ///
    /// The screenshots are taken on one fixed day of the almanac, and an untouched field
    /// has no fencing on it and not a control lit — the same reason the meadow's plain
    /// board is photographed part way through. These six pieces are the bottom half of the
    /// best pen that day has in it, which is a wall a player could plausibly be half way
    /// through building.
    static func aDayPartWayThrough(_ level: PuzzleLevel) -> PuzzleGame {
        let game = PuzzleGame(level: level)
        game.build("""
            .........
            .........
            .........
            .........
            #........
            #........
            #........
            .#.......
            ..##.....
            """)
        return game
    }

    /// Lays a plan of fencing out on the board, `#` by `#`. Each piece goes down as a press
    /// of its own, the way a player lays them one tap at a time.
    private func build(_ plan: String) {
        for (row, line) in plan.split(whereSeparator: \.isNewline).enumerated() {
            for (column, character) in line.enumerated() where character == "#" {
                beginStroke()
                buildFence(on: GridPoint(row: row, column: column))
                endStroke()
            }
        }
    }
}
