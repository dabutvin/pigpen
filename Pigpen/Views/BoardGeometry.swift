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

    /// The middle of a tile given in fractions — whole numbers are tile centres and the
    /// fractions between them the ground in between — raised `lift` tiles off it. Which is
    /// where an animal part way through a stride, or off its feet altogether, is standing.
    func center(atRow row: Double, column: Double, lift: Double = 0) -> CGPoint {
        CGPoint(
            x: origin.x + CGFloat(column + 0.5) * cell,
            y: origin.y + CGFloat(row + 0.5 - lift) * cell
        )
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

    /// The tiles a finger crosses travelling in a straight line from one point to the
    /// next, in the order it meets them. Touches only arrive every so often, so a quick
    /// drag lands several tiles away from where it was last seen, and the tiles in
    /// between have to be walked rather than jumped over.
    ///
    /// Only tiles the line actually passes through are returned: a slanted drag comes
    /// back as a run with diagonal steps in it, not as a staircase of tiles the finger
    /// never touched.
    func tiles(from start: CGPoint, to end: CGPoint) -> [GridPoint] {
        guard cell > 0 else { return [] }

        // Half a tile between samples would be enough to never skip one; a quarter also
        // keeps the order right where the line clips a corner.
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(Int((distance / (cell / 4)).rounded(.up)), 1)

        var crossed: [GridPoint] = []
        for step in 0...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            let point = CGPoint(
                x: start.x + (end.x - start.x) * progress,
                y: start.y + (end.y - start.y) * progress
            )
            if let tile = tile(at: point), tile != crossed.last {
                crossed.append(tile)
            }
        }
        return crossed
    }
}
