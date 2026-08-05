/// What a single tile is made of.
enum Terrain: Character, CaseIterable, Sendable {
    /// Open ground. The pig walks on it, you may fence it, and it is what scores.
    case mud = "."
    /// A river or lake. Impassable to the pig and to fences alike, and free of charge.
    case water = "~"
}

/// One puzzle: a map, a pig, and a fence budget.
struct PuzzleLevel: Identifiable, Sendable {
    let id: String
    let name: String
    /// Row-major, every row the same width.
    let terrain: [[Terrain]]
    let pigStart: GridPoint
    let fenceBudget: Int
    /// Penned mud tiles needed for the second and third star. Any pen at all earns one.
    let twoStarArea: Int
    let threeStarArea: Int
    /// The biggest pen this map and budget allow. Finding it is a search rather than a
    /// sum, so it is authored alongside the star thresholds: a player who matches it has
    /// nothing left to beat, and the game stops asking them to go bigger.
    let maximumArea: Int

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

    /// Whether the pig can stand on a tile. Off-map tiles are not walkable — they are freedom.
    func isWalkable(_ point: GridPoint) -> Bool {
        terrain(at: point) == .mud
    }

    /// A fence takes up a whole tile, so it can only be built on open mud: never in the
    /// water, which is already a boundary and free, and never on the tile the pig is
    /// standing on. Tiles along the outer edge of the map are fair game, and usually where
    /// the fencing has to go, since that is the ground the pig runs off from.
    func canBuildFence(on tile: GridPoint) -> Bool {
        terrain(at: tile) == .mud && tile != pigStart
    }

    var mudTileCount: Int {
        terrain.reduce(0) { $0 + $1.filter { $0 == .mud }.count }
    }

    /// Stars earned for penning `area` mud tiles.
    func starRating(forArea area: Int) -> Int {
        if area >= threeStarArea { 3 } else if area >= twoStarArea { 2 } else { 1 }
    }

    /// Whether a pen of `area` tiles is the biggest this map has in it.
    func isMaximumArea(_ area: Int) -> Bool {
        area >= maximumArea
    }

    /// Builds a level from an ASCII map, one line per row: `.` mud, `~` water,
    /// and a single `P` for the mud tile the pig starts on.
    ///
    /// Returns `nil` if the map is empty, ragged, holds an unknown character, or
    /// does not name exactly one starting tile.
    init?(
        id: String,
        name: String,
        fenceBudget: Int,
        twoStarArea: Int,
        threeStarArea: Int,
        maximumArea: Int,
        map: String
    ) {
        let lines = map.split(whereSeparator: \.isNewline)
        guard let width = lines.first?.count, width > 0, lines.allSatisfy({ $0.count == width })
        else { return nil }

        var terrain: [[Terrain]] = []
        var pigStart: GridPoint?
        for (row, line) in lines.enumerated() {
            var tiles: [Terrain] = []
            for (column, character) in line.enumerated() {
                if character == "P" {
                    guard pigStart == nil else { return nil }
                    pigStart = GridPoint(row: row, column: column)
                    tiles.append(.mud)
                } else if let tile = Terrain(rawValue: character) {
                    tiles.append(tile)
                } else {
                    return nil
                }
            }
            terrain.append(tiles)
        }

        guard let pigStart else { return nil }

        self.id = id
        self.name = name
        self.terrain = terrain
        self.pigStart = pigStart
        self.fenceBudget = fenceBudget
        self.twoStarArea = twoStarArea
        self.threeStarArea = threeStarArea
        self.maximumArea = maximumArea
    }
}

extension PuzzleLevel {
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
        twoStarArea: 20,
        threeStarArea: 33,
        maximumArea: 35,
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

    /// The same lesson on a smaller board: two whole sides are water, so the pen only
    /// ever needs two walls of its own. Eight pieces cut the corner off at its widest
    /// and hold 26 tiles; the same eight spent anywhere out in the open hold 9.
    static let puddleCorner = authored(
        id: "puddle-corner",
        name: "Puddle Corner",
        fenceBudget: 8,
        twoStarArea: 15,
        threeStarArea: 24,
        maximumArea: 26,
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
    static let horseshoeLake = authored(
        id: "horseshoe-lake",
        name: "Horseshoe Lake",
        fenceBudget: 6,
        twoStarArea: 16,
        threeStarArea: 23,
        maximumArea: 24,
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
        twoStarArea: 13,
        threeStarArea: 21,
        maximumArea: 22,
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
        twoStarArea: 14,
        threeStarArea: 23,
        maximumArea: 24,
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
        twoStarArea: 19,
        threeStarArea: 31,
        maximumArea: 33,
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

    /// A level written into the game itself, where a malformed map is a mistake in the
    /// source rather than anything a player could bring about.
    ///
    /// `maximumArea` is the one number here that cannot be worked out by eye. It comes
    /// from `Tools/level_search.py`, which searches a map for the biggest pen its budget
    /// can hold, and `PuzzleLevelTests` pins each one to a pen that actually holds it.
    private static func authored(
        id: String,
        name: String,
        fenceBudget: Int,
        twoStarArea: Int,
        threeStarArea: Int,
        maximumArea: Int,
        map: String
    ) -> PuzzleLevel {
        guard let level = PuzzleLevel(
            id: id,
            name: name,
            fenceBudget: fenceBudget,
            twoStarArea: twoStarArea,
            threeStarArea: threeStarArea,
            maximumArea: maximumArea,
            map: map
        ) else {
            preconditionFailure("The built-in \(name) map is malformed")
        }
        return level
    }
}
