import SwiftUI

/// Draws the field — terrain, fences, pen and pig — and turns taps into the tile
/// under the finger.
struct FieldView: View {
    let level: PuzzleLevel
    /// The tiles filled in with fencing.
    let fences: Set<GridPoint>
    /// Mud tiles to wash in gold once the pen is proven closed.
    let penTiles: Set<GridPoint>
    /// How far along the pen's celebration wash is, 0 to 1.
    let penGlow: Double
    let pigTile: GridPoint
    let pigOpacity: Double
    let onTapTile: (GridPoint) -> Void

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
                    .font(.system(size: board.cell * 0.78))
                    .opacity(pigOpacity)
                    .position(board.center(of: pigTile))
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture().onEnded { tap in
                    if let tile = board.tile(at: tap.location) {
                        onTapTile(tile)
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

    /// A fenced tile is a square of timber: two rails with three posts across them, which
    /// still reads as a fence at the size a tile gets on a phone.
    private func drawFences(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in fences {
            let plot = board.rect(for: tile).insetBy(dx: board.cell * 0.06, dy: board.cell * 0.06)
            let timber = Path(roundedRect: plot, cornerRadius: board.cell * 0.14)
            context.fill(timber, with: .color(GamePalette.rail))

            var slats = Path()
            for rail in [0.32, 0.68] {
                let y = plot.minY + plot.height * rail
                slats.move(to: CGPoint(x: plot.minX, y: y))
                slats.addLine(to: CGPoint(x: plot.maxX, y: y))
            }
            for post in [0.24, 0.5, 0.76] {
                let x = plot.minX + plot.width * post
                slats.move(to: CGPoint(x: x, y: plot.minY))
                slats.addLine(to: CGPoint(x: x, y: plot.maxY))
            }
            context.stroke(slats, with: .color(GamePalette.post), lineWidth: max(1, board.cell * 0.09))
            context.stroke(timber, with: .color(GamePalette.post), lineWidth: max(1, board.cell * 0.05))
        }
    }
}

#Preview {
    FieldView(
        level: .riverBend,
        fences: [
            GridPoint(row: 5, column: 2),
            GridPoint(row: 6, column: 1)
        ],
        penTiles: [],
        penGlow: 0,
        pigTile: PuzzleLevel.riverBend.pigStart,
        pigOpacity: 1,
        onTapTile: { _ in }
    )
    .padding()
}
