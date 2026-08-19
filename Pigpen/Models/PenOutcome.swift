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
    /// An animal that has to be penned against the water is standing in a pen that touches
    /// none: held, and held dry, which for a seal is no holding at all.
    case landlocked(Animal)
    /// An animal that has to be given a whole channel is standing in a pen that holds a bank
    /// or two of one and not the rest: held, and short a wallow, which for a croc is no
    /// holding at all.
    case parched(Animal)
    /// The pen is shut, and some of its ground stands in the eagle's line of sight: held,
    /// and held where he can see her, which is one stoop away from not being held at all.
    case spotted(Animal)
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

    /// The spire's field: the crater's question first — only the pig is held, and the eagle
    /// is never walked, his perch a hole in the wall's way — and then the spire's own. The
    /// eagle sees four ways from his perch, straight along his row and his column, over mud
    /// and open sky alike, and a pen with any of its ground in his eye is refused. Only a
    /// fence breaks his line of sight — the pen's own wall where the wall faces him, or a
    /// piece standing on its own with no pen anywhere near it, which is a thing no other
    /// board in the game has a use for.
    private func releaseStooping(fences: Set<GridPoint>) -> PenOutcome {
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
            if let watcher = animals.first(where: { $0.kind != .pig }),
               sees(from: watcher.tile, into: ground, fences: fences) {
                return .refused(pen: ground, refusal: .spotted(watcher.kind))
            }
            return .penned(pen: ground)
        }
    }

    /// Whether any tile of `ground` lies in the line of sight out of `perch`: four straight
    /// rays, one per direction, walked until they leave the map or land on a fence. Sight
    /// crosses water and mud alike — the sky between the spires hides nothing.
    private func sees(from perch: GridPoint, into ground: Set<GridPoint>, fences: Set<GridPoint>) -> Bool {
        for direction in Direction.allCases {
            var tile = perch.stepped(direction)
            while contains(tile), !fences.contains(tile) {
                if ground.contains(tile) { return true }
                tile = tile.stepped(direction)
            }
        }
        return false
    }

    func release(fences: Set<GridPoint>) -> PenOutcome {
        if question == .exclude {
            return releaseExcluding(fences: fences)
        }
        if question == .stoop {
            return releaseStooping(fences: fences)
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

        // The carnival asks for two pens with one of them inside the other, which is two things
        // at once as well: the pig may not be standing in with the ringmaster, and her ground
        // has to close the whole way round him. A pen beside his is a pen, not a ring.
        //
        // The cove asks the same of the crab, and the difference is what he is standing in: a
        // broken ring of tidewater walls him on every side but its break, so the ground that has
        // to close round him is really closing round the whole pool — the flood walked below
        // crosses water as freely as it crosses mud, which is exactly what makes surrounding the
        // crab and surrounding his pool the same question.
        if question == .ring || question == .moat, let pigGround = ground[.pig] {
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

        // The tundra asks for two pens and is particular about one of them: the bull seal will
        // not stand in with the pig, and the ground he is given has to lie against the water,
        // because a seal hauls out beside his breathing hole and nowhere else. The pressure
        // ridges he lives among are ice rather than water as far as he is concerned — what the
        // rule wants is one tile of his run beside one tile of open water, which on his own
        // board means beside a ridge, since a ridge is where the ice broke and the sea shows
        // through.
        if question == .hole, let pigGround = ground[.pig] {
            for animal in animals where animal.kind != .pig {
                if pigGround.contains(animal.tile) {
                    return .refused(pen: held, refusal: .together(animal.kind))
                }
                guard let theirs = ground[animal.kind] else { continue }
                if !touchesWater(theirs) {
                    return .refused(pen: held, refusal: .landlocked(animal.kind))
                }
            }
        }

        // The fen asks for two pens and is greedier about one of them than any board before
        // it: the old croc will not stand in with the pig, and the pen he is given has to
        // hold every bank of one whole body of water — a croc keeps a wallow rather than
        // visits one, so a run of ground that laps a channel here and there has not given
        // him anything he would call his.
        if question == .wallow, let pigGround = ground[.pig] {
            for animal in animals where animal.kind != .pig {
                if pigGround.contains(animal.tile) {
                    return .refused(pen: held, refusal: .together(animal.kind))
                }
                guard let theirs = ground[animal.kind] else { continue }
                if !ownsAWallow(theirs) {
                    return .refused(pen: held, refusal: .parched(animal.kind))
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

    /// Whether any tile of a run of ground lies orthogonally beside water — which is what a
    /// breathing hole is: one step from where the seal lies to where the sea shows through.
    private func touchesWater(_ ground: Set<GridPoint>) -> Bool {
        ground.contains { tile in
            Direction.allCases.contains { terrain(at: tile.stepped($0)) == .water }
        }
    }

    /// Whether one whole body of water lies against a run of ground — every wet tile of it
    /// orthogonally beside a tile of the run — which is what owning a wallow is. A body is
    /// gathered the way the ground itself is: tile by orthogonal tile.
    private func ownsAWallow(_ ground: Set<GridPoint>) -> Bool {
        var banks: Set<GridPoint> = []
        for tile in ground {
            for direction in Direction.allCases {
                banks.insert(tile.stepped(direction))
            }
        }

        var left: Set<GridPoint> = []
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                let tile = GridPoint(row: row, column: column)
                if terrain(at: tile) == .water { left.insert(tile) }
            }
        }

        while let seed = left.first {
            var body: Set<GridPoint> = [seed]
            var queue = [seed]
            left.remove(seed)
            while let tile = queue.popLast() {
                for direction in Direction.allCases where left.contains(tile.stepped(direction)) {
                    left.remove(tile.stepped(direction))
                    body.insert(tile.stepped(direction))
                    queue.append(tile.stepped(direction))
                }
            }
            if body.isSubset(of: banks) { return true }
        }
        return false
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
