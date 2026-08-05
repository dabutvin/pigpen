import Foundation
import SwiftUI

/// One tile touched during a single unbroken press: a tap, or one of the tiles a finger
/// crossed on its way across the field.
struct FenceStroke {
    /// Which way the press is working. Settled by the tile it starts on and held for the
    /// rest of the drag, so a press that begins on open ground builds a run of fencing and
    /// one that begins on a fence tears a run of it out — a finger never undoes its own work.
    enum Mode {
        case building
        case clearing
    }

    let mode: Mode
    let tile: GridPoint
    /// True for the tile the press started on, before the finger moved.
    let isFirst: Bool
}

/// Draws the field — terrain, fences, pen and pig — and turns a tap or a drag into the
/// tiles under the finger.
struct FieldView: View {
    let level: PuzzleLevel
    /// The tiles filled in with fencing.
    let fences: Set<GridPoint>
    /// The mud tiles the fencing shuts the pig into, washed in as soon as the pen closes.
    let penTiles: Set<GridPoint>
    /// How deep that wash goes, 0 to 1.
    let penGlow: Double
    /// Whether the pen is the best the map has in it, which turns the wash from gold
    /// to a drifting rainbow.
    let isAsGoodAsItGets: Bool
    let pigTile: GridPoint
    let pigOpacity: Double
    let onStroke: (FenceStroke) -> Void
    /// Told when the finger comes up, so everything one press laid or tore out can be
    /// taken back together.
    let onStrokeEnd: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The press in progress, if a finger is down: which way it is working, where it was
    /// last seen, and the tiles it has already handed over. A finger wandering about
    /// inside one tile must not toggle it over and over.
    @State private var press: Press?
    /// When the board came up, so the rainbow drifts from a fixed point rather than from
    /// whenever it happened to be switched on.
    @State private var opened = Date()

    private struct Press {
        var mode: FenceStroke.Mode
        var location: CGPoint
        var touched: Set<GridPoint>
    }

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

                penWash(board: board)

                // Above the wash, like the pig: an apple shut into a finished pen has to
                // still read as an apple and not as a patch of the colour laid over it.
                Canvas { context, _ in
                    drawTreats(in: &context, board: board)
                }
                .allowsHitTesting(false)

                Text("🐷")
                    .font(.system(size: board.cell * 0.78))
                    .opacity(pigOpacity)
                    .position(board.center(of: pigTile))
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(
                // Zero minimum distance so the touch counts the moment it lands: a press
                // that never moves is a tap on one tile, and one that moves paints a run.
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in touch(at: drag.location, on: board) }
                    .onEnded { _ in
                        press = nil
                        onStrokeEnd()
                    }
            )
        }
        .aspectRatio(CGFloat(level.columnCount) / CGFloat(level.rowCount), contentMode: .fit)
    }

    /// Follows the finger, handing over each new tile it reaches once.
    private func touch(at location: CGPoint, on board: BoardGeometry) {
        guard var current = press else {
            guard let tile = board.tile(at: location) else { return }
            let mode: FenceStroke.Mode = fences.contains(tile) ? .clearing : .building
            onStroke(FenceStroke(mode: mode, tile: tile, isFirst: true))
            press = Press(mode: mode, location: location, touched: [tile])
            return
        }

        for tile in board.tiles(from: current.location, to: location) {
            guard current.touched.insert(tile).inserted else { continue }
            onStroke(FenceStroke(mode: current.mode, tile: tile, isFirst: false))
        }
        current.location = location
        press = current
    }

    /// The pen's wash, laid over the board rather than drawn into it so that it can fade
    /// in the moment the fencing closes and bloom into a rainbow when the pen is the biggest
    /// the map has in it. The rainbow sits on top of the gold rather than replacing it, so
    /// the piece that finishes the best pen there is colours over the wash already there.
    private func penWash(board: BoardGeometry) -> some View {
        let pen = penPath(board: board)

        return ZStack(alignment: .topLeading) {
            pen.fill(GamePalette.pen.opacity(0.55))

            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion || !isAsGoodAsItGets)) { timeline in
                // One turn round the colour wheel every twelve seconds.
                let phase = reduceMotion ? 0 : timeline.date.timeIntervalSince(opened) / 12

                Canvas { context, _ in
                    let bounds = pen.boundingRect
                    guard !bounds.isNull else { return }

                    // Corner to corner of the pen itself, so a pen of any size and shape
                    // holds the whole spectrum rather than a slice of the board's.
                    context.fill(
                        pen,
                        with: .linearGradient(
                            GamePalette.rainbow(phase: phase),
                            startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                            endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                        )
                    )
                }
            }
            .opacity(isAsGoodAsItGets ? 0.8 : 0)
        }
        .opacity(penGlow)
        .allowsHitTesting(false)
        .animation(.easeOut(duration: 0.28), value: penGlow)
        .animation(.easeInOut(duration: 0.5), value: isAsGoodAsItGets)
    }

    /// The pen as one shape, so it washes in a single pass with no seams between tiles.
    private func penPath(board: BoardGeometry) -> Path {
        Path { path in
            for tile in penTiles {
                path.addRect(board.rect(for: tile))
            }
        }
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

    /// What is lying about on the mud: an apple worth five tiles of ground to shut in with
    /// the pig, a skull worth five fewer. Each sits on a pale scuff of ground so it reads
    /// against the mud, and a tile with fencing on it is covered over, treat and all —
    /// which is how a skull gets buried and how an apple gets wasted.
    private func drawTreats(in context: inout GraphicsContext, board: BoardGeometry) {
        for (tile, treat) in level.treats where !fences.contains(tile) {
            let rect = board.rect(for: tile)
            context.fill(
                Path(ellipseIn: rect.insetBy(dx: board.cell * 0.16, dy: board.cell * 0.16)),
                with: .color(.white.opacity(0.18))
            )
            context.draw(
                Text(glyph(for: treat)).font(.system(size: board.cell * 0.58)),
                at: board.center(of: tile)
            )
        }
    }

    private func glyph(for treat: Treat) -> String {
        switch treat {
        case .apple: "🍎"
        case .skull: "☠️"
        }
    }

    /// A fenced tile is a whole square given over to fencing: three pointed pickets with
    /// two rails across them, on ground churned dark. Drawn head-on rather than from
    /// above, which is the only way it still reads at the size a tile gets on a phone.
    private func drawFences(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in fences {
            let plot = board.rect(for: tile).insetBy(dx: board.cell * 0.06, dy: board.cell * 0.06)
            context.fill(
                Path(roundedRect: plot, cornerRadius: board.cell * 0.14),
                with: .color(GamePalette.post)
            )

            var pickets = Path()
            let width = plot.width * 0.16
            let top = plot.minY + plot.height * 0.10
            let foot = plot.minY + plot.height * 0.92
            for picket in [0.2, 0.5, 0.8] {
                let x = plot.minX + plot.width * picket
                pickets.move(to: CGPoint(x: x - width / 2, y: foot))
                pickets.addLine(to: CGPoint(x: x - width / 2, y: top))
                pickets.addLine(to: CGPoint(x: x, y: top - plot.height * 0.06))
                pickets.addLine(to: CGPoint(x: x + width / 2, y: top))
                pickets.addLine(to: CGPoint(x: x + width / 2, y: foot))
                pickets.closeSubpath()
            }
            context.fill(pickets, with: .color(GamePalette.picket))

            var rails = Path()
            for rail in [0.40, 0.72] {
                let y = plot.minY + plot.height * rail
                rails.move(to: CGPoint(x: plot.minX + plot.width * 0.06, y: y))
                rails.addLine(to: CGPoint(x: plot.maxX - plot.width * 0.06, y: y))
            }
            context.stroke(
                rails,
                with: .color(GamePalette.rail),
                style: StrokeStyle(lineWidth: plot.width * 0.13, lineCap: .round)
            )
        }
    }
}

#Preview("Building") {
    FieldView(
        level: .riverBend,
        fences: [
            GridPoint(row: 5, column: 2),
            GridPoint(row: 6, column: 1)
        ],
        penTiles: [],
        penGlow: 0,
        isAsGoodAsItGets: false,
        pigTile: PuzzleLevel.riverBend.pigStart,
        pigOpacity: 1,
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}

/// The par solution to River Bend: the river and the pond wall two sides of the pen and the
/// whole budget walls the other two, which holds every tile the map can shut a pig into —
/// so the wash is a rainbow.
#Preview("The best pen there is") {
    let level = PuzzleLevel.riverBend
    let fences = Set((1...5).map { GridPoint(row: 10, column: $0) })
        .union((3...9).map { GridPoint(row: $0, column: 0) })
    let pen = Set((3...9).flatMap { row in (1...5).map { GridPoint(row: row, column: $0) } })

    return FieldView(
        level: level,
        fences: fences,
        penTiles: pen,
        penGlow: 0.8,
        isAsGoodAsItGets: true,
        pigTile: level.pigStart,
        pigOpacity: 1,
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}

/// The best pen Windfall Orchard has in it: the fencing narrows as it goes south so that
/// two of the four apples end up inside, which is worth more than the ground given up to
/// reach them. The two apples left out sit under fencing, spent for nothing.
#Preview("Fruit worth reaching for") {
    let level = PuzzleLevel.windfallOrchard
    let fences = Set((3...8).flatMap { row in
        [GridPoint(row: row, column: max(0, row - 5)), GridPoint(row: row, column: 12 - row)]
    })
    var pen: Set<GridPoint> = []
    if case .penned(let held) = level.releasePig(fences: fences) {
        pen = held
    }

    return FieldView(
        level: level,
        fences: fences,
        penTiles: pen,
        penGlow: 0.8,
        isAsGoodAsItGets: true,
        pigTile: level.pigStart,
        pigOpacity: 1,
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}
