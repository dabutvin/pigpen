/// One animal's walk off the map: what got out, and the way it went.
struct Escape: Equatable, Sendable {
    let animal: AnimalStart
    /// The shortest walk out, starting on the animal's home tile and ending one step past
    /// the edge of the map.
    let route: [GridPoint]
}

/// Why a field that holds everything is still not won: the ground is shut, but the board
/// asked for something the fencing did not give it.
enum Refusal: Equatable, Sendable {
    /// Two animals that will not share are standing in the same pen.
    case together(Animal)
    /// Two animals that will not be parted are standing in pens of their own.
    case apart(Animal)
    /// Two animals that will not be housed unequally are standing in pens of different sizes.
    case uneven(Animal)
    /// One of a roost that hangs together is standing in a pen of its own.
    case split(Animal)
    /// The animal that had to be left outside has been fenced in.
    case shutIn(Animal)
}

/// What happens when the animals are let loose on a field fenced a particular way.
enum PenOutcome: Equatable, Sendable {
    /// Something found a way out — one escape for each animal that did. A field holding
    /// the pig but not the deer — or the boar — is a field that has not been won.
    case escaped(escapes: [Escape])
    /// Everything on the map is stuck. `pen` is every mud tile the animals can still
    /// reach between them: one enclosure when they are held together, two when apart.
    case penned(pen: Set<GridPoint>)
    /// Everything is stuck and nothing got out, but the field's own rule is broken — so the
    /// ground is shown the way a pen is, and the field is not won. Only a boss can refuse.
    case refused(pen: Set<GridPoint>, refusal: Refusal)
}

extension PuzzleLevel {
    /// Walks every animal outwards from its home tile, one step at a time, to see whether
    /// the fenced tiles and the water together close every way off the map.
    ///
    /// A single missing piece is enough to lose: each animal tries every route, so the
    /// ring around it has to be unbroken — and one animal loose in the open loses the
    /// field however well the other one is held.
    /// A field where the pig is what has to be held, and the other animal what has to be
    /// left outside it. The other one is never walked: it may wander off the map for all the
    /// board cares, so long as the wall keeps it out of the pig's ground.
    private func releaseExcluding(fences: Set<GridPoint>) -> PenOutcome {
        guard let pig = animals.first(where: { $0.kind == .pig }) else {
            return .penned(pen: [])
        }
        switch walk(from: pig.tile, fences: fences) {
        case .out(let route):
            return .escaped(escapes: [Escape(animal: pig, route: route)])
        case .stuck(let ground):
            if let shut = animals.first(where: { $0.kind != .pig && ground.contains($0.tile) }) {
                return .refused(pen: ground, refusal: .shutIn(shut.kind))
            }
            return .penned(pen: ground)
        }
    }

    func release(fences: Set<GridPoint>) -> PenOutcome {
        if question == .exclude {
            return releaseExcluding(fences: fences)
        }

        var escapes: [Escape] = []
        var held: Set<GridPoint> = []
        var ground: [Animal: Set<GridPoint>] = [:]

        for animal in animals {
            switch walk(from: animal.tile, fences: fences) {
            case .out(let route):
                escapes.append(Escape(animal: animal, route: route))
            case .stuck(let run):
                held.formUnion(run)
                ground[animal.kind] = run
            }
        }

        guard escapes.isEmpty else { return .escaped(escapes: escapes) }

        // A board that keeps two animals apart is not won by the pen that holds them both:
        // the ground the pig is standing in must not be the ground the other one is in.
        if question == .apart, let pigGround = ground[.pig],
           let sharing = animals.first(where: { $0.kind != .pig && pigGround.contains($0.tile) }) {
            return .refused(pen: held, refusal: .together(sharing.kind))
        }

        // And a board that will not have them parted asks the same question the other way
        // round: the ground the pig is standing in has to be the ground the other one is in,
        // however well two pens either side of them hold.
        if question == .together, let pigGround = ground[.pig],
           let alone = animals.first(where: { $0.kind != .pig && !pigGround.contains($0.tile) }) {
            return .refused(pen: held, refusal: .apart(alone.kind))
        }

        // A roost asks two things at once as well, and they pull opposite ways: the bat and its
        // pup have to be in the same pen, and the pig has to be somewhere else. So the pen that
        // holds all three is refused, and so is the one that hangs the pup on its own.
        if question == .roost, let pigGround = ground[.pig] {
            if let sharing = animals.first(where: { $0.kind != .pig && pigGround.contains($0.tile) }) {
                return .refused(pen: held, refusal: .together(sharing.kind))
            }
            if let bat = animals.first(where: { $0.kind == .bat }),
               let batGround = ground[.bat],
               let strays = animals.first(where: {
                   $0.kind != .pig && $0.kind != bat.kind && !batGround.contains($0.tile)
               }) {
                return .refused(pen: held, refusal: .split(strays.kind))
            }
        }

        // And a board that will not have one animal better housed than the other asks two
        // things at once: two pens rather than one, and the same ground in each of them.
        if question == .even, let pigGround = ground[.pig] {
            for animal in animals where animal.kind != .pig {
                guard let theirs = ground[animal.kind] else { continue }
                if pigGround.contains(animal.tile) {
                    return .refused(pen: held, refusal: .together(animal.kind))
                }
                if theirs.count != pigGround.count {
                    return .refused(pen: held, refusal: .uneven(animal.kind))
                }
            }
        }

        return .penned(pen: held)
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
