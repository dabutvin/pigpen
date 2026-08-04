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
    /// A one-line nudge shown under the board.
    let hint: String
    /// Row-major, every row the same width.
    let terrain: [[Terrain]]
    let pigStart: GridPoint
    let fenceBudget: Int
    /// Penned mud tiles needed for the second and third star. Any pen at all earns one.
    let twoStarArea: Int
    let threeStarArea: Int

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

    /// A fence can only be driven into mud, so any line that already has water on
    /// either side is refused: the water is doing that job for free. Lines along the
    /// outer edge of the map are fair game, since that is where the pig runs off.
    func canBuildFence(_ fence: Fence) -> Bool {
        let (first, second) = fence.separatedTiles
        let sides = [terrain(at: first), terrain(at: second)]
        guard sides.contains(.mud) else { return false }
        return !sides.contains(.water)
    }

    var mudTileCount: Int {
        terrain.reduce(0) { $0 + $1.filter { $0 == .mud }.count }
    }

    /// Stars earned for penning `area` mud tiles.
    func starRating(forArea area: Int) -> Int {
        if area >= threeStarArea { 3 } else if area >= twoStarArea { 2 } else { 1 }
    }

    /// Builds a level from an ASCII map, one line per row: `.` mud, `~` water,
    /// and a single `P` for the mud tile the pig starts on.
    ///
    /// Returns `nil` if the map is empty, ragged, holds an unknown character, or
    /// does not name exactly one starting tile.
    init?(
        id: String,
        name: String,
        hint: String,
        fenceBudget: Int,
        twoStarArea: Int,
        threeStarArea: Int,
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
        self.hint = hint
        self.terrain = terrain
        self.pigStart = pigStart
        self.fenceBudget = fenceBudget
        self.twoStarArea = twoStarArea
        self.threeStarArea = threeStarArea
    }
}

extension PuzzleLevel {
    /// The one puzzle the game ships with so far.
    ///
    /// A river runs in from the west, turns south and pools into a pond, which hands
    /// the player two free sides of a large pen. Fencing the remaining two sides with
    /// all 16 pieces pens 49 of the map's 83 mud tiles, which is the provable maximum;
    /// the same budget spent on a free-standing box would only hold 16.
    static let riverBend: PuzzleLevel = {
        guard let level = PuzzleLevel(
            id: "river-bend",
            name: "River Bend",
            hint: "Water costs nothing. Build the pen against it.",
            fenceBudget: 16,
            twoStarArea: 30,
            threeStarArea: 46,
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
        ) else {
            preconditionFailure("The built-in River Bend map is malformed")
        }
        return level
    }()
}
