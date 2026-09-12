import Foundation

/// Hamish: a pig from the next farm over, sweet on her, and the one soul in the game who will
/// say where a piece goes.
///
/// Every level is authored around the best pen its budget can hold — see `PuzzleLevel.bestPen`
/// — and a hint is one piece of that pen, shown rather than said. He trots onto the board from
/// the nearest edge and stands on the tile the next piece belongs on, rose in hand, until the
/// piece is laid there; then he blows a kiss and goes. Which piece is *next* is worked out from
/// the fencing already down, so a wall half built is extended rather than started again
/// somewhere else, and asking twice on the same board gets the same tile until it is filled.
///
/// He is a suitor rather than a coach because a coach would explain. Hamish does not: he says
/// one fond line in a bubble over the square he is standing on, and the rest of the pen is
/// still hers to find. What keeps him from giving the whole board away is `HintAllowance` —
/// three roses a day, and the day rolls.
enum Suitor {
    static let name = "Hamish"
    /// Drawn side-on, so he is never mistaken for her.
    static let glyph = "🐖"
    /// What he brings. One rose is one hint.
    static let rose = "🌹"
    /// What rises off the tile when the piece is laid where he stood.
    static let kiss = "💕"

    /// The tile the next piece of the best pen goes on, or nothing when every piece of that
    /// pen is already in the ground — or the level has no best pen authored, which is only
    /// the practice pen: every trail stop carries one beside its map and every daily in its
    /// line of the almanac.
    ///
    /// A piece that extends the wall already down is preferred to one that starts a new run,
    /// and among those the one nearest the pig, then the first in reading order, so the same
    /// board always gets the same answer. Fencing that is not part of the best pen is neither
    /// pointed at nor taken into account: he says where to build, never what to tear out.
    static func nextPiece(of level: PuzzleLevel, given fences: Set<GridPoint>) -> GridPoint? {
        guard let best = level.bestPen else { return nil }
        let missing = best.subtracting(fences)
        guard !missing.isEmpty else { return nil }

        let laid = best.intersection(fences)
        let extending = missing.filter { tile in
            Direction.allCases.contains { laid.contains(tile.stepped($0)) }
        }
        let pool = extending.isEmpty ? missing : extending

        func rank(_ tile: GridPoint) -> (Int, Int, Int) {
            let toPig = abs(tile.row - level.pigStart.row) + abs(tile.column - level.pigStart.column)
            return (toPig, tile.row, tile.column)
        }
        return pool.min { rank($0) < rank($1) }
    }

    /// The way onto the board: from a tile just off the nearest edge, over the ground, to
    /// `tile`. The first tile is off the map, the last is `tile`, and each is one step from
    /// the one before, so he can be walked along it the way an escaping animal is walked off.
    ///
    /// He comes in over mud — fences and animals do not stop a visitor — by the shortest way
    /// from the rim. Ground the rim cannot reach over mud, which no shipped map has, gets a
    /// straight line in from the nearest edge instead, water and all.
    static func approach(to tile: GridPoint, on level: PuzzleLevel) -> [GridPoint] {
        var cameFrom: [GridPoint: GridPoint] = [:]
        var queue = [tile]
        var seen: Set<GridPoint> = [tile]
        var gate: GridPoint? = isOnRim(tile, of: level) ? tile : nil

        search: while gate == nil, !queue.isEmpty {
            let here = queue.removeFirst()
            for direction in Direction.allCases {
                let next = here.stepped(direction)
                guard level.isWalkable(next), seen.insert(next).inserted else { continue }
                cameFrom[next] = here
                if isOnRim(next, of: level) {
                    gate = next
                    break search
                }
                queue.append(next)
            }
        }

        guard let gate else { return straightIn(to: tile, on: level) }
        var route = [gate]
        var here = gate
        while here != tile, let back = cameFrom[here] {
            route.append(back)
            here = back
        }
        return [outside(gate, of: level)] + route
    }

    private static func isOnRim(_ tile: GridPoint, of level: PuzzleLevel) -> Bool {
        tile.row == 0 || tile.column == 0
            || tile.row == level.rowCount - 1 || tile.column == level.columnCount - 1
    }

    /// The tile one step off the map from a rim tile.
    private static func outside(_ gate: GridPoint, of level: PuzzleLevel) -> GridPoint {
        for direction in Direction.allCases {
            let out = gate.stepped(direction)
            if !level.contains(out) { return out }
        }
        return gate.stepped(.up)
    }

    private static func straightIn(to tile: GridPoint, on level: PuzzleLevel) -> [GridPoint] {
        let ways: [(outward: Direction, steps: Int)] = [
            (.up, tile.row + 1),
            (.down, level.rowCount - tile.row),
            (.left, tile.column + 1),
            (.right, level.columnCount - tile.column)
        ]
        let way = ways.min { $0.steps < $1.steps } ?? ways[0]
        var route: [GridPoint] = []
        var here = tile
        for _ in 0..<way.steps {
            here = here.stepped(way.outward)
            route.append(here)
        }
        return route.reversed() + [tile]
    }

    // MARK: - What he says

    /// The hint itself, in the bubble over the square he is standing on.
    ///
    /// Short, and in his own voice: it is read at a glance off a tooltip the width of a few
    /// tiles rather than off a board at the top of the screen, and the tail underneath it has
    /// already said the only thing that matters, which is *where*.
    static let hint = "Place a fence here, my love."

    /// Asked again while he is still standing on a square nothing has been laid on.
    static let alreadyShowing = "Still right here, my love."

    /// Asked on a board that already has every piece of the best pen in it.
    static let nothingToAdd = "Nothing left to add, my love. That is the best pen this map has."

    /// Tacked onto the hint when the rack is empty: the piece cannot go down until one comes up.
    static let rackIsEmpty = " Take a piece back first — the rack is empty."

    /// Asked with no roses left, and when the next one comes.
    static func outOfRoses(until next: Date, from now: Date) -> String {
        "No roses left today, my love. I will be back "
            + "\(HintAllowance.said(until: next, from: now))."
    }
}
