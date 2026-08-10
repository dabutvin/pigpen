/// A tile coordinate on a puzzle grid. Row 0 is the top row, column 0 the left one.
struct GridPoint: Hashable, Codable, Sendable {
    var row: Int
    var column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    /// How a tile is written down when a daily's submitted wall is filed away.
    var stored: String { "\(row),\(column)" }

    /// The tile written as `stored`, and nothing if the string is not a tile.
    init?(stored: String) {
        let parts = stored.split(separator: ",")
        guard parts.count == 2,
              let row = Int(parts[0]),
              let column = Int(parts[1])
        else { return nil }
        self.init(row: row, column: column)
    }

    /// The neighbouring tile one step away. The result may lie off the grid.
    func stepped(_ direction: Direction) -> GridPoint {
        GridPoint(row: row + direction.rowOffset, column: column + direction.columnOffset)
    }
}

/// The four ways a pig can walk. Pigs never move diagonally.
enum Direction: CaseIterable, Hashable, Sendable {
    case up, down, left, right

    var rowOffset: Int {
        switch self {
        case .up: -1
        case .down: 1
        case .left, .right: 0
        }
    }

    var columnOffset: Int {
        switch self {
        case .left: -1
        case .right: 1
        case .up, .down: 0
        }
    }
}
