import Foundation

/// Maps between tiles, fence lines and points on screen. Tiles are square, and the board
/// is centred in whatever space it is handed.
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

    /// Where to draw a fence: along the top of its anchor tile if horizontal, down the
    /// left of it if vertical.
    func endpoints(of fence: Fence) -> (CGPoint, CGPoint) {
        let corner = CGPoint(
            x: origin.x + CGFloat(fence.anchor.column) * cell,
            y: origin.y + CGFloat(fence.anchor.row) * cell
        )
        switch fence.orientation {
        case .horizontal:
            return (corner, CGPoint(x: corner.x + cell, y: corner.y))
        case .vertical:
            return (corner, CGPoint(x: corner.x, y: corner.y + cell))
        }
    }

    /// The fence line closest to a touch. The tile under the finger decides which four
    /// lines are in play and the nearest of its sides wins, so every tap lands on a line
    /// rather than on a dead spot. A touch that strays just off the board is pulled back
    /// to the nearest edge tile, which is how the outer rim gets fenced.
    func line(nearest location: CGPoint) -> Fence? {
        guard cell > 0, rowCount > 0, columnCount > 0 else { return nil }

        let x = (location.x - origin.x) / cell
        let y = (location.y - origin.y) / cell
        let column = min(max(Int(x.rounded(.down)), 0), columnCount - 1)
        let row = min(max(Int(y.rounded(.down)), 0), rowCount - 1)
        let sides: [(distance: CGFloat, side: Direction)] = [
            (y - CGFloat(row), .up),
            (CGFloat(row + 1) - y, .down),
            (x - CGFloat(column), .left),
            (CGFloat(column + 1) - x, .right)
        ]

        guard let nearest = sides.min(by: { $0.distance < $1.distance }) else { return nil }
        return Fence(side: nearest.side, of: GridPoint(row: row, column: column))
    }
}
