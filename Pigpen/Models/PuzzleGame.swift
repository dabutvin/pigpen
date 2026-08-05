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

    let level: PuzzleLevel
    /// The tiles filled in with fencing. The pig cannot walk onto any of them.
    private(set) var fences: Set<GridPoint> = []
    private(set) var phase: Phase = .building
    /// The largest pen managed so far, so a second attempt can be compared to the first.
    private(set) var bestArea = 0
    /// What the pig would do if it were let out this instant, kept up to date as the
    /// fencing changes so a closed pen can be shown as closed the moment it closes.
    private var outcome: PenOutcome

    init(level: PuzzleLevel) {
        self.level = level
        self.outcome = level.releasePig(fences: [])
    }

    var isBuilding: Bool { phase == .building }
    var fencesRemaining: Int { level.fenceBudget - fences.count }

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
            bestArea = max(bestArea, pen.count)
        }
    }

    /// Fetches the pig back, leaving the fences up so a gap can be patched or a pen widened.
    func resumeBuilding() {
        phase = .building
    }

    /// Tears every fence back out and starts the field over.
    func startOver() {
        fences.removeAll()
        reconsider()
        phase = .building
    }

    /// Walks the pig out again on paper, after the fencing has changed.
    private func reconsider() {
        outcome = level.releasePig(fences: fences)
    }
}
