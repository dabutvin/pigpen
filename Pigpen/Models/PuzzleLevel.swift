/// What a single tile is made of.
enum Terrain: Character, CaseIterable, Sendable {
    /// Open ground. The pig walks on it, you may fence it, and it is what scores.
    case mud = "."
    /// A river or lake. Impassable to the pig and to fences alike, and free of charge.
    case water = "~"
}

/// Something lying on a tile of mud, worth having inside the pen or worth keeping out of it.
///
/// A treat does not change what the ground underneath it is: either one can be walked over,
/// and either one can be shut into a pen. What they do not share is whether they take a
/// fence. An apple is windfall, and a piece laid on top of one wastes it. A skull is staked
/// into the ground and refuses the piece altogether, so a wall that wants that tile has to
/// go round it — which is what makes sour ground something to plan a pen around rather than
/// something to pave over.
enum Treat: Character, CaseIterable, Sendable {
    /// A windfall apple. Ground with an apple on it is worth five ordinary tiles.
    case apple = "a"
    /// A skull staked in the mud. Sour ground: it costs five tiles to shut a pig in with,
    /// and it takes no fencing, so it can be neither built on nor buried.
    case skull = "x"

    /// Whether a piece of fencing can be laid on the tile this is lying on.
    var takesFencing: Bool {
        switch self {
        case .apple: true
        case .skull: false
        }
    }

    /// What shutting the tile into the pen is worth, over and above the ground itself,
    /// counted in mud tiles.
    var worth: Int {
        switch self {
        case .apple: 5
        case .skull: -5
        }
    }

    /// What tapping this treat says: five more for an apple, five fewer for a skull. A
    /// skull takes no fencing, so a tap that would have planted a post lands on the
    /// cost instead — which is how a player finds out what sour ground is worth without
    /// reading the README.
    var pointsSaid: String {
        switch self {
        case .apple: "+\(worth) points"
        case .skull: "\(worth) points"
        }
    }
}

/// What a pen is worth: the ground it holds, what was lying on that ground, and the score
/// the two come to together.
struct PenTally: Equatable, Sendable {
    /// The mud tiles the pen holds, treats and all.
    let area: Int
    let apples: Int
    let skulls: Int

    init(area: Int, apples: Int = 0, skulls: Int = 0) {
        self.area = area
        self.apples = apples
        self.skulls = skulls
    }

    /// A point for every tile of ground, five more for an apple shut in with the pig and
    /// five fewer for a skull. A pen that closes is never worth nothing, however sour the
    /// ground inside it; a field with no pen on it is worth nothing at all.
    var score: Int {
        guard area > 0 else { return 0 }
        return max(1, area + apples * Treat.apple.worth + skulls * Treat.skull.worth)
    }
}

/// What a level makes of a pen that held: the stars it earns, and whether it is the best
/// pen the map has in it.
///
/// The two travel together because everything downstream of a pen wants both — the field
/// washes rainbow rather than gold for the best there is, and the signpost on the world
/// map keeps that rainbow on its stars long after the board has gone.
struct PenVerdict: Equatable, Sendable {
    /// One star for any pen at all, three for one worth the level's `threeStarScore`.
    let stars: Int
    /// True for a pen worth the level's `maximumScore` — nothing on this map beats it.
    let isAsGoodAsItGets: Bool
}

/// One puzzle: a map, the animals on it, and a fence budget.
struct PuzzleLevel: Identifiable, Sendable {
    let id: String
    let name: String
    /// Row-major, every row the same width.
    let terrain: [[Terrain]]
    /// What is lying about on the mud, by tile. Treats are scattered rather than everywhere,
    /// so they are held apart from the terrain instead of as a second grid.
    let treats: [GridPoint: Treat]
    /// Everything on the map that has to be shut in, in the order the map writes it down.
    /// Every level stands a pig on its ground; the meadow's last one stands a deer there too.
    let animals: [AnimalStart]
    /// The pig's own tile. Kept beside `animals` because every map has exactly one pig and
    /// most of the game only ever has the one animal to think about.
    let pigStart: GridPoint
    let fenceBudget: Int
    /// The score needed for the second and third star. Any pen at all earns one.
    let twoStarScore: Int
    let threeStarScore: Int
    /// The best pen this map and budget allow. Finding it is a search rather than a
    /// sum, so it is authored alongside the star thresholds: a player who matches it has
    /// nothing left to beat, and the game stops asking them to go bigger.
    let maximumScore: Int

    var rowCount: Int { terrain.count }
    var columnCount: Int { terrain.first?.count ?? 0 }

    func contains(_ point: GridPoint) -> Bool {
        point.row >= 0 && point.row < rowCount && point.column >= 0 && point.column < columnCount
    }

    /// The terrain at a tile, or `nil` for a tile off the edge of the map.
    func terrain(at point: GridPoint) -> Terrain? {
        guard contains(point) else { return nil }
        return terrain[point.row][point.column]
    }

    /// What is lying on a tile, if anything is.
    func treat(at point: GridPoint) -> Treat? { treats[point] }

    /// Whether this map has anything lying about on it, which is what makes a score
    /// something other than a count of ground.
    var holdsTreats: Bool { !treats.isEmpty }

    /// Whether there is more than the pig to hold, which is what turns one enclosure into
    /// a budget split between two.
    var holdsAHerd: Bool { animals.count > 1 }

    /// Whether an animal can stand on a tile. Off-map tiles are not walkable — they are
    /// freedom.
    func isWalkable(_ point: GridPoint) -> Bool {
        terrain(at: point) == .mud
    }

    /// A fence takes up a whole tile, so it can only be built on open mud: never in the
    /// water, which is already a boundary and free, never on a tile an animal is standing
    /// on, and never on a skull, which is staked into the ground and leaves no room for a
    /// post. Tiles along the outer edge of the map are fair game, and usually where the
    /// fencing has to go, since that is the ground the animals run off from.
    func canBuildFence(on tile: GridPoint) -> Bool {
        terrain(at: tile) == .mud
            && !animals.contains { $0.tile == tile }
            && (treats[tile]?.takesFencing ?? true)
    }

    var mudTileCount: Int {
        terrain.reduce(0) { $0 + $1.filter { $0 == .mud }.count }
    }

    /// What a pen is worth: the ground it holds and whatever was lying on that ground.
    func tally(for pen: Set<GridPoint>) -> PenTally {
        let caught = pen.compactMap { treats[$0] }
        return PenTally(
            area: pen.count,
            apples: caught.filter { $0 == .apple }.count,
            skulls: caught.filter { $0 == .skull }.count
        )
    }

    /// Stars earned for a pen worth `score`.
    func starRating(forScore score: Int) -> Int {
        if score >= threeStarScore { 3 } else if score >= twoStarScore { 2 } else { 1 }
    }

    /// Whether a pen worth `score` is the best this map has in it.
    func isMaximumScore(_ score: Int) -> Bool {
        score >= maximumScore
    }

    /// Everything the map has to say about a pen worth `score`, in one piece so that the
    /// stars and the rainbow are never carried about apart from one another.
    func verdict(forScore score: Int) -> PenVerdict {
        PenVerdict(stars: starRating(forScore: score), isAsGoodAsItGets: isMaximumScore(score))
    }

    /// Builds a level from an ASCII map, one line per row: `.` mud, `~` water, `a` an
    /// apple and `x` a skull — both of which lie on mud — a single `P` for the mud tile
    /// the pig starts on, and an optional `D` for a deer's.
    ///
    /// Returns `nil` if the map is empty, ragged, holds an unknown character, stands the
    /// same animal on it twice, or has no pig on it at all.
    init?(
        id: String,
        name: String,
        fenceBudget: Int,
        twoStarScore: Int,
        threeStarScore: Int,
        maximumScore: Int,
        map: String
    ) {
        let lines = map.split(whereSeparator: \.isNewline)
        guard let width = lines.first?.count, width > 0, lines.allSatisfy({ $0.count == width })
        else { return nil }

        var terrain: [[Terrain]] = []
        var treats: [GridPoint: Treat] = [:]
        var animals: [AnimalStart] = []
        for (row, line) in lines.enumerated() {
            var tiles: [Terrain] = []
            for (column, character) in line.enumerated() {
                if let animal = Animal(rawValue: character) {
                    guard !animals.contains(where: { $0.kind == animal }) else { return nil }
                    animals.append(AnimalStart(kind: animal, tile: GridPoint(row: row, column: column)))
                    tiles.append(.mud)
                } else if let treat = Treat(rawValue: character) {
                    treats[GridPoint(row: row, column: column)] = treat
                    tiles.append(.mud)
                } else if let tile = Terrain(rawValue: character) {
                    tiles.append(tile)
                } else {
                    return nil
                }
            }
            terrain.append(tiles)
        }

        guard let pigStart = animals.first(where: { $0.kind == .pig })?.tile else { return nil }

        self.id = id
        self.name = name
        self.terrain = terrain
        self.treats = treats
        self.animals = animals
        self.pigStart = pigStart
        self.fenceBudget = fenceBudget
        self.twoStarScore = twoStarScore
        self.threeStarScore = threeStarScore
        self.maximumScore = maximumScore
    }
}

extension PuzzleLevel {
    /// The practice field the title screen walks a new player through. Water takes the
    /// north and west for free; six pieces close the other two sides and hold 11 tiles.
    /// It is not on the world map — it is only ever opened from Tutorial.
    static let practicePen = authored(
        id: "practice-pen",
        name: "Practice Pen",
        fenceBudget: 6,
        twoStarScore: 6,
        threeStarScore: 10,
        maximumScore: 11,
        map: """
            ~~~~~
            ~....
            ~.P..
            ~....
            ~....
            .....
            """
    )

    /// The first puzzle, and the one that teaches the whole game.
    ///
    /// A river runs in from the west, turns south and pools into a pond, which hands
    /// the player two free sides of a large pen. Walling the remaining two sides with
    /// all 12 pieces pens 35 of the map's 83 mud tiles, which is the provable maximum —
    /// every tile the pig can be shut into without standing on the rim of the map.
    /// The same budget spent on a free-standing box would only hold 9.
    static let riverBend = authored(
        id: "river-bend",
        name: "River Bend",
        fenceBudget: 12,
        twoStarScore: 20,
        threeStarScore: 33,
        maximumScore: 35,
        map: """
            .........
            .........
            ~~~~~~~..
            ......~..
            ......~..
            ......~..
            ..P...~..
            ......~..
            ......~~.
            ......~~.
            .........
            """
    )

    /// The last of the water levels and the one that asks the most: two whole sides are
    /// water, so the pen only ever needs two walls of its own, and the whole puzzle is the
    /// shape of them. Eight pieces cut the corner off diagonally and hold 26 tiles, where
    /// the best right-angled block those eight can wall holds 16 and the same eight spent
    /// out in the open hold 9. Nothing else in the meadow rewards the staircase this
    /// heavily, which is why it stands at the top of the fencing-and-water stretch rather
    /// than near the bottom where its small board would suggest.
    static let puddleCorner = authored(
        id: "puddle-corner",
        name: "Puddle Corner",
        fenceBudget: 8,
        twoStarScore: 15,
        threeStarScore: 24,
        maximumScore: 26,
        map: """
            ~~~~~~~~
            ~.......
            ~.......
            ~..P....
            ~.......
            ~.......
            ~.......
            ........
            """
    )

    /// A lake bent right round the pig, leaving a mouth four tiles wide at the bottom.
    /// Plugging the mouth costs four pieces and holds 20 tiles, which is the whole point
    /// — but the two pieces left over buy four more tiles out past the arms of the lake.
    ///
    /// The second stop, and the second and last one whose best pen is a plain block of
    /// ground: everything here is reachable by squaring the map off, so the three stars
    /// are there for a player still learning what a fence is for. Every stop past this
    /// one asks for something the shape of the wall has to earn.
    static let horseshoeLake = authored(
        id: "horseshoe-lake",
        name: "Horseshoe Lake",
        fenceBudget: 6,
        twoStarScore: 14,
        threeStarScore: 23,
        maximumScore: 24,
        map: """
            ..........
            ..~~~~~~..
            .~~~~~~~~.
            .~~....~~.
            .~~....~~.
            .~~....~~.
            .~~.P..~~.
            .~~....~~.
            ..........
            ..........
            """
    )

    /// Two lakes almost meeting, with the pig in the gap between them. Neither lake is
    /// any use on its own; a pen thrown across the neck leans on both at once and holds
    /// 22 tiles for ten pieces.
    static let theNarrows = authored(
        id: "the-narrows",
        name: "The Narrows",
        fenceBudget: 10,
        twoStarScore: 13,
        threeStarScore: 21,
        maximumScore: 22,
        map: """
            ..........
            ..~~~.....
            .~~~~~....
            ..~~~.....
            ..........
            ....P.....
            ..~~~~....
            .~~~~~~...
            ..~~~~....
            ..........
            """
    )

    /// A river across the whole map, broken by a single dry tile. That one tile is the
    /// only way north and costs one piece to shut, which buys the entire far bank as a
    /// free wall — the other eleven pieces then have only three sides left to close.
    static let otterFord = authored(
        id: "otter-ford",
        name: "Otter Ford",
        fenceBudget: 12,
        twoStarScore: 14,
        threeStarScore: 23,
        maximumScore: 24,
        map: """
            ..........
            ..........
            ..........
            ~~~~~.~~~~
            ..........
            ....P.....
            ..........
            ..........
            ..........
            """
    )

    /// The widest board in the meadow, with a lake down one side and open ground
    /// everywhere else. Sixteen pieces and no corner to hide in: the pen has to be cut
    /// to the shape of the shore, and only then does it reach 33 tiles.
    static let bigMeadow = authored(
        id: "big-meadow",
        name: "The Big Meadow",
        fenceBudget: 16,
        twoStarScore: 19,
        threeStarScore: 31,
        maximumScore: 33,
        map: """
            ..........
            .~~~~~....
            .~~~~~~...
            ..~~~~~~..
            ...~~~~~..
            ....~~~...
            ..P.......
            ..........
            ..........
            ..........
            ..........
            """
    )

    /// The first orchard: a river bars the whole north of the map, so the ground under it
    /// is cheap to wall, and four windfall apples lie in rows further south where the
    /// walling is dear. An apple is worth five tiles, which is more than the ground the
    /// pen gives up narrowing itself to reach one — so the best pen is not the roundest.
    /// The 12 pieces hold 27 tiles and two of the apples, and 37 is what that comes to.
    static let windfallOrchard = authored(
        id: "windfall-orchard",
        name: "Windfall Orchard",
        fenceBudget: 12,
        twoStarScore: 21,
        threeStarScore: 35,
        maximumScore: 37,
        map: """
            ..........
            .~~~~~~~~.
            .~~~~~~~~.
            ..........
            ...P......
            ..........
            ..a..a....
            ..........
            ..a..a....
            ..........
            """
    )

    /// Sour ground: two skulls staked in the mud, each costing five tiles to shut a pig
    /// in with, and three apples worth five apiece. A skull takes no fencing, so a wall
    /// that wants its tile has to step around it — and stepping around one is not the same
    /// as shutting it out, since any ground the wall leaves open is ground the pig walks
    /// onto. The best pen here does one of each: it bends its south wall in beside the
    /// skull by the lake to leave it outside, and takes the skull north of the pig in and
    /// pays the five, which costs less than the ground a detour round it would give up.
    /// 24 tiles and two apples, less the one skull, come to 29.
    ///
    /// The second star is set by what squaring the map off is worth rather than by the
    /// proportion of the maximum the rest of the meadow uses: with both skulls off limits
    /// to fencing, the best plain block here is only worth 15, and no level withholds its
    /// second star from the obvious pen.
    static let sourGround = authored(
        id: "sour-ground",
        name: "Sour Ground",
        fenceBudget: 14,
        twoStarScore: 15,
        threeStarScore: 27,
        maximumScore: 29,
        map: """
            ..........
            ....a.....
            ..........
            ...x..a...
            ..........
            ...~P.....
            ..~~~.x...
            .~~~~.....
            ....a.....
            ..........
            """
    )

    /// The meadow's boss, and the only map with a second animal on it: a mere lies across
    /// the middle, the pig grazes north of it and a stag south, and one budget has to hold
    /// them both. Neither shore is worth walling alone, and the water is the one wall both
    /// pens can lean on, so the twenty pieces go out as two enclosures rather than one —
    /// which is the whole puzzle, since every piece spent on the pig is a piece the stag
    /// does not get. Apples on both shores are worth going out of the way for, and there is
    /// a skull on each: neither wall can pass over one, the way Sour Ground taught, and on
    /// this board walling round either of them costs more ground than the skull does, so
    /// each pen takes its own in and pays for it. 33 tiles and three apples, less the two
    /// skulls, come to 38.
    static let stagMere = authored(
        id: "stag-mere",
        name: "Stag Mere",
        fenceBudget: 20,
        twoStarScore: 22,
        threeStarScore: 36,
        maximumScore: 38,
        map: """
            ..........
            .....a....
            ..P.......
            ...x......
            .~~~~~~...
            .~~~~~~...
            .......x..
            ..a....D..
            ..........
            ....a.....
            ..........
            """
    )

    /// A level written into the game itself, where a malformed map is a mistake in the
    /// source rather than anything a player could bring about.
    ///
    /// `maximumScore` is the one number here that cannot be worked out by eye. It comes
    /// from `Tools/level_search.py`, which searches a map for the best pen its budget
    /// can hold, and `PuzzleLevelTests` pins each one to a pen that actually holds it.
    private static func authored(
        id: String,
        name: String,
        fenceBudget: Int,
        twoStarScore: Int,
        threeStarScore: Int,
        maximumScore: Int,
        map: String
    ) -> PuzzleLevel {
        guard let level = PuzzleLevel(
            id: id,
            name: name,
            fenceBudget: fenceBudget,
            twoStarScore: twoStarScore,
            threeStarScore: threeStarScore,
            maximumScore: maximumScore,
            map: map
        ) else {
            preconditionFailure("The built-in \(name) map is malformed")
        }
        return level
    }
}
