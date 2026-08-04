import Observation

/// The state of one puzzle in progress: the fences built so far, and what the pig
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
    private(set) var fences: Set<Fence> = []
    private(set) var phase: Phase = .building
    /// The largest pen managed so far, so a second attempt can be compared to the first.
    private(set) var bestArea = 0

    init(level: PuzzleLevel) {
        self.level = level
    }

    var isBuilding: Bool { phase == .building }
    var fencesRemaining: Int { level.fenceBudget - fences.count }

    /// The mud tiles of the finished pen, or an empty set while the pen is unproven.
    var penTiles: Set<GridPoint> {
        if case .penned(let pen) = phase { pen } else { [] }
    }

    var starRating: Int? {
        if case .penned(let pen) = phase { level.starRating(forArea: pen.count) } else { nil }
    }

    /// Puts a fence piece on a line, or takes it back off. Returns whether anything changed,
    /// so the caller can tell a refused tap from an accepted one.
    @discardableResult
    func toggleFence(_ fence: Fence) -> Bool {
        guard isBuilding else { return false }

        if fences.contains(fence) {
            fences.remove(fence)
            return true
        }
        guard level.canBuildFence(fence), fencesRemaining > 0 else { return false }
        fences.insert(fence)
        return true
    }

    /// Opens the gate and sees what the pig makes of the fences.
    func releasePig() {
        guard isBuilding else { return }

        switch level.releasePig(fences: fences) {
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
        phase = .building
    }
}
