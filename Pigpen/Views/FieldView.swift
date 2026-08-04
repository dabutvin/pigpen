import SwiftUI

/// Draws the field — terrain, fences, pen and pig — and turns taps into the fence
/// line nearest the finger.
struct FieldView: View {
    let level: PuzzleLevel
    let fences: Set<Fence>
    /// Mud tiles to wash in gold once the pen is proven closed.
    let penTiles: Set<GridPoint>
    /// How far along the pen's celebration wash is, 0 to 1.
    let penGlow: Double
    let pigTile: GridPoint
    let pigOpacity: Double
    let onTapLine: (Fence) -> Void

    var body: some View {
        GeometryReader { proxy in
            let board = BoardGeometry(size: proxy.size, level: level)

            ZStack(alignment: .topLeading) {
                Canvas { context, _ in
                    drawTerrain(in: &context, board: board)
                    drawGridLines(in: &context, board: board)
                    drawBorder(in: &context, board: board)
                    drawFences(in: &context, board: board)
                }

                Text("🐷")
                    .font(.system(size: board.cell * 0.72))
                    .opacity(pigOpacity)
                    .position(board.center(of: pigTile))
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture().onEnded { tap in
                    if let fence = board.line(nearest: tap.location) {
                        onTapLine(fence)
                    }
                }
            )
        }
        .aspectRatio(CGFloat(level.columnCount) / CGFloat(level.rowCount), contentMode: .fit)
    }

    private func drawTerrain(in context: inout GraphicsContext, board: BoardGeometry) {
        for row in 0..<level.rowCount {
            for column in 0..<level.columnCount {
                let tile = GridPoint(row: row, column: column)
                let rect = board.rect(for: tile)

                switch level.terrain[row][column] {
                case .mud:
                    context.fill(Path(rect), with: .color(GamePalette.mud))
                    drawSpeckles(in: &context, rect: rect, tile: tile)
                case .water:
                    context.fill(Path(rect), with: .color(GamePalette.water))
                    drawRipples(in: &context, rect: rect, tile: tile)
                }

                if penTiles.contains(tile) {
                    context.fill(
                        Path(rect),
                        with: .color(GamePalette.pen.opacity(0.55 * penGlow))
                    )
                }
            }
        }
    }

    /// A couple of stones per tile, placed from the tile's own coordinates so the
    /// field looks the same every time it is drawn.
    private func drawSpeckles(in context: inout GraphicsContext, rect: CGRect, tile: GridPoint) {
        var noise = UInt64(truncatingIfNeeded: tile.row * 73 + tile.column * 19 + 7)
        let size = rect.width * 0.08
        let margin = rect.width * 0.16
        for _ in 0..<3 {
            noise = noise &* 6364136223846793005 &+ 1442695040888963407
            let across = CGFloat((noise >> 16) % 100) / 100
            let down = CGFloat((noise >> 32) % 100) / 100
            let dot = CGRect(
                x: rect.minX + margin + across * (rect.width - 2 * margin - size),
                y: rect.minY + margin + down * (rect.height - 2 * margin - size),
                width: size,
                height: size
            )
            context.fill(Path(ellipseIn: dot), with: .color(GamePalette.mudSpeckle.opacity(0.35)))
        }
    }

    private func drawRipples(in context: inout GraphicsContext, rect: CGRect, tile: GridPoint) {
        let offset = (tile.row + tile.column).isMultiple(of: 2) ? 0.18 : -0.12
        for band in [0.34, 0.66] {
            var ripple = Path()
            let y = rect.minY + rect.height * (band + offset * 0.2)
            ripple.move(to: CGPoint(x: rect.minX + rect.width * 0.14, y: y))
            ripple.addQuadCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.14, y: y),
                control: CGPoint(x: rect.midX, y: y - rect.height * 0.16)
            )
            context.stroke(
                ripple,
                with: .color(GamePalette.waterRipple.opacity(0.5)),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.05), lineCap: .round)
            )
        }
    }

    private func drawGridLines(in context: inout GraphicsContext, board: BoardGeometry) {
        var lines = Path()
        for row in 0...level.rowCount {
            let y = board.origin.y + CGFloat(row) * board.cell
            lines.move(to: CGPoint(x: board.origin.x, y: y))
            lines.addLine(to: CGPoint(x: board.origin.x + board.width, y: y))
        }
        for column in 0...level.columnCount {
            let x = board.origin.x + CGFloat(column) * board.cell
            lines.move(to: CGPoint(x: x, y: board.origin.y))
            lines.addLine(to: CGPoint(x: x, y: board.origin.y + board.height))
        }
        context.stroke(lines, with: .color(.black.opacity(0.10)), lineWidth: 1)
    }

    /// The rim of the map. Everything past it is open country, which is exactly where
    /// the pig is trying to get to.
    private func drawBorder(in context: inout GraphicsContext, board: BoardGeometry) {
        let rim = CGRect(
            origin: board.origin,
            size: CGSize(width: board.width, height: board.height)
        )
        context.stroke(Path(rim), with: .color(GamePalette.post.opacity(0.5)), lineWidth: 3)
    }

    private func drawFences(in context: inout GraphicsContext, board: BoardGeometry) {
        guard !fences.isEmpty else { return }

        var rails = Path()
        var posts = Path()
        let postRadius = board.cell * 0.09

        for fence in fences {
            let (start, end) = board.endpoints(of: fence)
            rails.move(to: start)
            rails.addLine(to: end)
            for endpoint in [start, end] {
                posts.addEllipse(in: CGRect(
                    x: endpoint.x - postRadius,
                    y: endpoint.y - postRadius,
                    width: postRadius * 2,
                    height: postRadius * 2
                ))
            }
        }

        context.stroke(
            rails,
            with: .color(GamePalette.post),
            style: StrokeStyle(lineWidth: board.cell * 0.20, lineCap: .round)
        )
        context.stroke(
            rails,
            with: .color(GamePalette.rail),
            style: StrokeStyle(lineWidth: board.cell * 0.09, lineCap: .round)
        )
        context.fill(posts, with: .color(GamePalette.post))
    }
}

/// Maps between tiles, fence lines and points on screen.
private struct BoardGeometry {
    let cell: CGFloat
    let origin: CGPoint
    let level: PuzzleLevel

    init(size: CGSize, level: PuzzleLevel) {
        let cell = min(
            size.width / CGFloat(max(level.columnCount, 1)),
            size.height / CGFloat(max(level.rowCount, 1))
        )
        self.cell = cell
        self.level = level
        self.origin = CGPoint(
            x: (size.width - cell * CGFloat(level.columnCount)) / 2,
            y: (size.height - cell * CGFloat(level.rowCount)) / 2
        )
    }

    var width: CGFloat { cell * CGFloat(level.columnCount) }
    var height: CGFloat { cell * CGFloat(level.rowCount) }

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

    /// The fence line closest to a touch: the tile under the finger decides which four
    /// lines are in play, and whichever of its sides the finger sits nearest wins.
    func line(nearest location: CGPoint) -> Fence? {
        guard cell > 0 else { return nil }

        let x = (location.x - origin.x) / cell
        let y = (location.y - origin.y) / cell
        let column = min(max(Int(x.rounded(.down)), 0), level.columnCount - 1)
        let row = min(max(Int(y.rounded(.down)), 0), level.rowCount - 1)
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

#Preview {
    FieldView(
        level: .riverBend,
        fences: [
            Fence(side: .up, of: GridPoint(row: 6, column: 2)),
            Fence(side: .left, of: GridPoint(row: 6, column: 2))
        ],
        penTiles: [],
        penGlow: 0,
        pigTile: PuzzleLevel.riverBend.pigStart,
        pigOpacity: 1,
        onTapLine: { _ in }
    )
    .padding()
}
