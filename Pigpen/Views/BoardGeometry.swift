import Foundation

/// Maps between tiles and points on screen. Tiles are square, and the board is centred
/// in whatever space it is handed.
struct BoardGeometry {
    /// The side of one tile.
    let cell: CGFloat
    /// The top-left corner of the board within the space it was given.
    let origin: CGPoint
    private let rowCount: Int
    private let columnCount: Int

    init(size: CGSize, level: PuzzleLevel) {
        self.rowCount = level.rowCount
        self.columnCount = level.columnCount

        let cell = min(
            size.width / CGFloat(max(columnCount, 1)),
            size.height / CGFloat(max(rowCount, 1))
        )
        self.cell = max(cell, 0)
        self.origin = CGPoint(
            x: (size.width - self.cell * CGFloat(columnCount)) / 2,
            y: (size.height - self.cell * CGFloat(rowCount)) / 2
        )
    }

    var width: CGFloat { cell * CGFloat(columnCount) }
    var height: CGFloat { cell * CGFloat(rowCount) }

    func rect(for tile: GridPoint) -> CGRect {
        CGRect(
            x: origin.x + CGFloat(tile.column) * cell,
            y: origin.y + CGFloat(tile.row) * cell,
            width: cell,
            height: cell
        )
    }

    func center(of tile: GridPoint) -> CGPoint {
        CGPoint(x: rect(for: tile).midX, y: rect(for: tile).midY)
    }

    /// The tile under a touch. A touch that strays just off the board is pulled back to
    /// the nearest tile, so the rim of the map — where the fencing usually has to go — is
    /// as easy to hit as the middle.
    func tile(at location: CGPoint) -> GridPoint? {
        guard cell > 0, rowCount > 0, columnCount > 0 else { return nil }

        let x = (location.x - origin.x) / cell
        let y = (location.y - origin.y) / cell
        return GridPoint(
            row: min(max(Int(y.rounded(.down)), 0), rowCount - 1),
            column: min(max(Int(x.rounded(.down)), 0), columnCount - 1)
        )
    }
}
