import Observation

/// The state of one puzzle in progress: the tiles fenced off so far, and what the pig
/// did the last time it was let out.
@MainActor
@Observable
final class PuzzleGame {
    enum Phase: Equatable {
        /// Fences can be added and removed.
        case building
        /// The pig walked `route` and is gone.
        case escaped(route: [GridPoint])
        /// The pig is penned in `pen`.
        case penned(pen: Set<GridPoint>)
    }

    /// A pen that held, kept whole: the ground it held and the fencing that held it.
    struct Pen: Equatable {
        let fences: Set<GridPoint>
        let area: Int
    }

    let level: PuzzleLevel
    /// The tiles filled in with fencing. The pig cannot walk onto any of them.
    private(set) var fences: Set<GridPoint> = []
    private(set) var phase: Phase = .building
    /// The biggest pen closed so far this session, fencing and all, so a rearrangement
    /// that turns out worse can be measured against it and put back.
    private(set) var bestPen: Pen?
    /// What the pig would do if it were let out this instant, kept up to date as the
    /// fencing changes so a closed pen can be shown as closed the moment it closes.
    private var outcome: PenOutcome

    init(level: PuzzleLevel) {
        self.level = level
        self.outcome = level.releasePig(fences: [])
    }

    var isBuilding: Bool { phase == .building }
    var fencesRemaining: Int { level.fenceBudget - fences.count }
    /// The most ground any pen has held this session, and 0 before one has closed.
    var bestArea: Int { bestPen?.area ?? 0 }

    /// Whether the fencing and the water together already shut the pig in — true as soon as
    /// the last gap is filled, without waiting for the pig to be let out and prove it.
    var isPenClosed: Bool {
        if case .penned = outcome { true } else { false }
    }

    /// The mud tiles the fencing shuts the pig into, and an empty set while a way off the
    /// map remains.
    var penTiles: Set<GridPoint> {
        if case .penned(let pen) = outcome { pen } else { [] }
    }

    /// Whether the pen is the biggest the map has in it — true as soon as the fencing that
    /// holds it is down, so the field can say so, and there is no wider pen left to send
    /// the player back out after.
    var isPenAsBigAsItGets: Bool {
        isPenClosed && level.isMaximumArea(penTiles.count)
    }

    /// The stars for the pen the pig has actually been let loose in. Nothing is scored
    /// until the pig has been released.
    var starRating: Int? {
        if case .penned(let pen) = phase { level.starRating(forArea: pen.count) } else { nil }
    }

    /// Whether the field stands somewhere other than on its best pen, so putting it back
    /// is worth offering. False while the pig is out, and until a pen has closed at all.
    var canRestoreBestPen: Bool {
        guard isBuilding, let bestPen else { return false }
        return bestPen.fences != fences
    }

    /// Puts the fencing back the way it stood when it held the best pen of the session,
    /// so a rearrangement that turned out worse costs nothing. Returns whether anything
    /// changed.
    @discardableResult
    func restoreBestPen() -> Bool {
        guard canRestoreBestPen, let bestPen else { return false }

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

        fences.insert(tile)
        reconsider()
        return true
    }

    /// Takes the fencing back out of a tile, giving the piece back. Returns whether
    /// anything changed.
    @discardableResult
    func clearFence(on tile: GridPoint) -> Bool {
        guard isBuilding, fences.remove(tile) != nil else { return false }
        reconsider()
        return true
    }

    /// Opens the gate and sees what the pig makes of the fences.
    func releasePig() {
        guard isBuilding else { return }

        switch outcome {
        case .escaped(let route):
            phase = .escaped(route: route)
        case .penned(let pen):
            phase = .penned(pen: pen)
        }
    }

    /// Fetches the pig back, leaving the fences up so a gap can be patched or a pen widened.
    func resumeBuilding() {
        phase = .building
    }

    /// Tears every fence back out and starts the field over. The best pen of the session
    /// outlives it, so a field cleared by mistake can still be put back.
    func startOver() {
        fences.removeAll()
        reconsider()
        phase = .building
    }

    /// Walks the pig out again on paper, after the fencing has changed, and remembers the
    /// fencing if it holds more ground than anything before it. A pen counts from the
    /// moment it closes: the pig does not have to be let out for the score to stand.
    private func reconsider() {
        outcome = level.releasePig(fences: fences)

        guard case .penned(let pen) = outcome, isWorthRemembering(pen) else { return }
        bestPen = Pen(fences: fences, area: pen.count)
    }

    /// Whether a pen beats the one being kept: more ground, or the same ground held with
    /// pieces to spare, which is the same score with more budget left to widen it.
    private func isWorthRemembering(_ pen: Set<GridPoint>) -> Bool {
        guard let bestPen else { return true }
        return pen.count == bestPen.area
            ? fences.count < bestPen.fences.count
            : pen.count > bestPen.area
    }
}
