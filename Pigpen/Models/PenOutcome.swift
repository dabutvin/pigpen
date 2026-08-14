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
    /// Two pens that should have been one inside the other are standing side by side: the pig
    /// is held and so is the other one, but the ring does not go round him.
    case beside(Animal)
    /// Two pens that should have had clear ground between them are sharing a wall: both are
    /// held, and one fence piece has the pig on one side of it and something that stings on
    /// the other.
    case tooClose(Animal)
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
            switch walk(from: animal.tile, fences: fences, swimming: animal.kind.swims) {
            case .out(let route):
                escapes.append(Escape(animal: animal, route: route))
            case .stuck(let run):
                held.formUnion(run)
                ground[animal.kind] = run
            }
        }

        // Which is where the cove's rule has already been applied, and the whole of it. Eight boss
        // rules below this one are refusals laid on top of a board where everything is stuck; the
        // ninth changes what stuck means, so it is decided in the walk and there is nothing left
        // to check down here. A crab who was not held is a crab who swam off the map, and the
        // escape carries the route he took through the water.
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

        // The carnival asks for two pens with one of them inside the other, which is two things
        // at once as well: the pig may not be standing in with the ringmaster, and her ground
        // has to close the whole way round him. A pen beside his is a pen, not a ring.
        if question == .ring, let pigGround = ground[.pig] {
            for animal in animals where animal.kind != .pig {
                if pigGround.contains(animal.tile) {
                    return .refused(pen: held, refusal: .together(animal.kind))
                }
                if !isSurrounded(animal.tile, by: pigGround) {
                    return .refused(pen: held, refusal: .beside(animal.kind))
                }
            }
        }

        // The dunes ask for two pens with clear ground between them, which is the one rule that
        // is about the wall rather than the ground: everywhere else a piece with the pig on one
        // side and something else on the other is one wall doing two jobs, and a sting goes
        // straight through it.
        if question == .berth, let pigGround = ground[.pig] {
            for animal in animals where animal.kind != .pig {
                if pigGround.contains(animal.tile) {
                    return .refused(pen: held, refusal: .together(animal.kind))
                }
                guard let theirs = ground[animal.kind] else { continue }
                if sharesAWall(pigGround, theirs, fences: fences) {
                    return .refused(pen: held, refusal: .tooClose(animal.kind))
                }
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

    /// Whether one fence piece is doing for both pens: whether any wall the player laid has one
    /// run of ground on one side of it and the other run on the other.
    ///
    /// Only the fencing is asked about, because the fencing is the whole of what the rule is
    /// against. Sand between two pens is another matter — a dune is yards of it, and nothing
    /// reaches across one — and the two runs cannot be touching without a wall between them in
    /// any case, since ground the pig could walk into would be her own ground and not a second
    /// pen at all.
    private func sharesAWall(
        _ mine: Set<GridPoint>,
        _ theirs: Set<GridPoint>,
        fences: Set<GridPoint>
    ) -> Bool {
        fences.contains { piece in
            let beside = Direction.allCases.map(piece.stepped)
            return beside.contains(where: mine.contains) && beside.contains(where: theirs.contains)
        }
    }

    /// Whether every way off the board from a tile crosses the given ground.
    ///
    /// Walked over the whole board rather than over the mud it is made of, because the crowd
    /// is no help with this question: a ringmaster standing on an island in the middle of one
    /// would be surrounded before a single piece was laid, and what the ring asks is that the
    /// pig herself go round him. Fenced tiles are walked over for the same reason — it is the
    /// ground she holds that has to close the circle, not the wall she holds it with.
    private func isSurrounded(_ tile: GridPoint, by ground: Set<GridPoint>) -> Bool {
        var reached: Set<GridPoint> = [tile]
        var queue: [GridPoint] = [tile]
        var next = 0

        while next < queue.count {
            let here = queue[next]
            next += 1

            for direction in Direction.allCases {
                let step = here.stepped(direction)
                guard contains(step) else { return false }
                guard !ground.contains(step), !reached.contains(step) else { continue }
                reached.insert(step)
                queue.append(step)
            }
        }

        return true
    }

    /// How one animal's walk ends: off the map, or on the ground it is shut into.
    private enum Walk {
        case out(route: [GridPoint])
        case stuck(ground: Set<GridPoint>)
    }

    /// - Parameter swimming: whether water is ground to this animal rather than a wall. True for
    ///   the cove's crab and nothing else, and the whole of the ninth world's rule: he is walked
    ///   over the board rather than over the mud on it, so the only thing that stops him is a
    ///   fence piece. What comes back is still the ground he holds — water is not ground and
    ///   scores nothing, however freely he paddles across it.
    private func walk(
        from home: GridPoint,
        fences: Set<GridPoint>,
        swimming: Bool = false
    ) -> Walk {
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
                guard isWalkable(step) || swimming, !fences.contains(step), !reached.contains(step)
                else { continue }

                reached.insert(step)
                cameFrom[step] = tile
                queue.append(step)
            }
        }

        return .stuck(ground: swimming ? reached.filter(isWalkable) : reached)
    }

    private func route(to tile: GridPoint, cameFrom: [GridPoint: GridPoint]) -> [GridPoint] {
        var route = [tile]
        while let previous = cameFrom[route[0]] {
            route.insert(previous, at: 0)
        }
        return route
    }
}
