/// What happens when the pig is let loose on a field fenced a particular way.
enum PenOutcome: Equatable, Sendable {
    /// The pig found a way out. `route` is the shortest walk it takes, starting on its
    /// home tile and ending one step past the edge of the map.
    case escaped(route: [GridPoint])
    /// The pig is stuck. `pen` is every mud tile it can still reach, and its size is the score.
    case penned(pen: Set<GridPoint>)
}

extension PuzzleLevel {
    /// Walks the pig outwards from its home tile, one step at a time, to see whether the
    /// fenced tiles and the water together close every way off the map.
    ///
    /// A single missing piece is enough to lose: the pig tries every route, so the ring
    /// around the pen has to be unbroken.
    func releasePig(fences: Set<GridPoint>) -> PenOutcome {
        var reached: Set<GridPoint> = [pigStart]
        var cameFrom: [GridPoint: GridPoint] = [:]
        var queue: [GridPoint] = [pigStart]
        var next = 0

        // Breadth first, so the first way out found is also the shortest.
        while next < queue.count {
            let tile = queue[next]
            next += 1

            for direction in Direction.allCases {
                let step = tile.stepped(direction)

                guard contains(step) else {
                    return .escaped(route: route(to: tile, cameFrom: cameFrom) + [step])
                }
                guard isWalkable(step), !fences.contains(step), !reached.contains(step)
                else { continue }

                reached.insert(step)
                cameFrom[step] = tile
                queue.append(step)
            }
        }

        return .penned(pen: reached)
    }

    private func route(to tile: GridPoint, cameFrom: [GridPoint: GridPoint]) -> [GridPoint] {
        var route = [tile]
        while let previous = cameFrom[route[0]] {
            route.insert(previous, at: 0)
        }
        return route
    }
}
