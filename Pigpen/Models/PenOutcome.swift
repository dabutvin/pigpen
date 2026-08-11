/// One animal's walk off the map: what got out, and the way it went.
struct Escape: Equatable, Sendable {
    let animal: AnimalStart
    /// The shortest walk out, starting on the animal's home tile and ending one step past
    /// the edge of the map.
    let route: [GridPoint]
}

/// What happens when the animals are let loose on a field fenced a particular way.
enum PenOutcome: Equatable, Sendable {
    /// Something found a way out — one escape for each animal that did. A field holding
    /// the pig but not the deer — or the boar — is a field that has not been won.
    case escaped(escapes: [Escape])
    /// Everything on the map is stuck. `pen` is every mud tile the animals can still
    /// reach between them: one enclosure when they are held together, two when apart.
    case penned(pen: Set<GridPoint>)
}

extension PuzzleLevel {
    /// Walks every animal outwards from its home tile, one step at a time, to see whether
    /// the fenced tiles and the water together close every way off the map.
    ///
    /// A single missing piece is enough to lose: each animal tries every route, so the
    /// ring around it has to be unbroken — and one animal loose in the open loses the
    /// field however well the other one is held.
    func release(fences: Set<GridPoint>) -> PenOutcome {
        var escapes: [Escape] = []
        var held: Set<GridPoint> = []

        for animal in animals {
            switch walk(from: animal.tile, fences: fences) {
            case .out(let route):
                escapes.append(Escape(animal: animal, route: route))
            case .stuck(let ground):
                held.formUnion(ground)
            }
        }

        return escapes.isEmpty ? .penned(pen: held) : .escaped(escapes: escapes)
    }

    /// How one animal's walk ends: off the map, or on the ground it is shut into.
    private enum Walk {
        case out(route: [GridPoint])
        case stuck(ground: Set<GridPoint>)
    }

    private func walk(from home: GridPoint, fences: Set<GridPoint>) -> Walk {
        var reached: Set<GridPoint> = [home]
        var cameFrom: [GridPoint: GridPoint] = [:]
        var queue: [GridPoint] = [home]
        var next = 0

        // Breadth first, so the first way out found is also the shortest.
        while next < queue.count {
            let tile = queue[next]
            next += 1

            for direction in Direction.allCases {
                let step = tile.stepped(direction)

                guard contains(step) else {
                    return .out(route: route(to: tile, cameFrom: cameFrom) + [step])
                }
                guard isWalkable(step), !fences.contains(step), !reached.contains(step)
                else { continue }

                reached.insert(step)
                cameFrom[step] = tile
                queue.append(step)
            }
        }

        return .stuck(ground: reached)
    }

    private func route(to tile: GridPoint, cameFrom: [GridPoint: GridPoint]) -> [GridPoint] {
        var route = [tile]
        while let previous = cameFrom[route[0]] {
            route.insert(previous, at: 0)
        }
        return route
    }
}
