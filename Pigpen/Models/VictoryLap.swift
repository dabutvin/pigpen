/// What one animal does when the gate opens and there is nowhere to go: a little circle
/// round its own pen, ending back on the tile it started from.
struct VictoryLap: Equatable, Sendable {
    let animal: AnimalStart
    /// The tiles it trots through in order, beginning and ending on its home tile. A route
    /// of one tile is an animal penned too tight to run, which celebrates on the spot.
    let route: [GridPoint]

    /// Whether the pen leaves any room to run at all.
    var hasRoomToRun: Bool { route.count > 1 }

    /// Tiles of ground one time round covers: four for a circle, two out and back along a
    /// pen too narrow for one, and none for an animal penned onto its own tile.
    var strides: Int { route.count - 1 }
}

extension PuzzleLevel {
    /// The lap every animal runs when the fencing holds, inside the ground `pen` shuts
    /// them into. One lap each, whether the pen holds them together or apart — and each
    /// animal only runs the ground it can itself reach, so a stag on the far shore of a
    /// mere never trots a circle that belongs to the pig.
    func victoryLaps(inside pen: Set<GridPoint>) -> [VictoryLap] {
        animals.map { animal in
            let own = enclosure(containing: animal.tile, inside: pen)
            return VictoryLap(animal: animal, route: lap(from: animal.tile, inside: own))
        }
    }

    /// The piece of `pen` an animal standing on `home` is shut into: every tile it can
    /// walk to without crossing fencing or water. Empty when `home` is not in the pen at
    /// all, which a held field never asks for.
    private func enclosure(containing home: GridPoint, inside pen: Set<GridPoint>) -> Set<GridPoint> {
        guard pen.contains(home) else { return [] }

        var reached: Set<GridPoint> = [home]
        var queue: [GridPoint] = [home]
        var next = 0

        while next < queue.count {
            let tile = queue[next]
            next += 1
            for direction in Direction.allCases {
                let step = tile.stepped(direction)
                guard pen.contains(step), !reached.contains(step) else { continue }
                reached.insert(step)
                queue.append(step)
            }
        }
        return reached
    }

    /// The ring an animal standing on `home` can run. Every tile of it has to be ground
    /// the pen holds, which is already ground that is mud, unfenced and reachable.
    private func lap(from home: GridPoint, inside pen: Set<GridPoint>) -> [GridPoint] {
        // Four tiles in a square with the animal on one corner is the smallest circle
        // there is: every step is a step onwards, and the fourth is back home. The squares
        // are tried in a fixed order, so a given pen is always run the same way round.
        let squares = [
            (down: 1, across: 1),
            (down: 1, across: -1),
            (down: -1, across: -1),
            (down: -1, across: 1)
        ]

        for square in squares {
            let ring = [
                GridPoint(row: home.row, column: home.column + square.across),
                GridPoint(row: home.row + square.down, column: home.column + square.across),
                GridPoint(row: home.row + square.down, column: home.column)
            ]
            guard ring.allSatisfy({ pen.contains($0) }) else { continue }
            return [home] + ring + [home]
        }

        // A pen a single tile wide has no circle in it, so a skip to the next tile and
        // back is the nearest thing to one.
        let neighbours = Direction.allCases.map { home.stepped($0) }
        if let neighbour = neighbours.first(where: { pen.contains($0) }) {
            return [home, neighbour, home]
        }

        return [home]
    }
}
