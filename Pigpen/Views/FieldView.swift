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

/// An animal as the field draws it: what it is, the tile it is standing on this instant,
/// and how solid it is — one that has walked off the map fades out where it left.
struct AnimalMark: Equatable, Identifiable {
    let kind: Animal
    var tile: GridPoint
    var opacity: Double
    /// How far off the ground it is, 0 standing on its tile and 1 at the top of a hop.
    /// What a pen that holds gets celebrated with.
    var hop: Double = 0

    var id: Animal { kind }
}

extension Array where Element == AnimalMark {
    /// Every animal a level stands on its ground, on the tile the map puts it.
    static func standing(on level: PuzzleLevel) -> [AnimalMark] {
        level.animals.map { AnimalMark(kind: $0.kind, tile: $0.tile, opacity: 1) }
    }
}

/// Draws the field — terrain, fences, pen and animals — and turns a tap or a drag into
/// the tiles under the finger.
struct FieldView: View {
    let level: PuzzleLevel
    /// The tiles filled in with fencing.
    let fences: Set<GridPoint>
    /// The mud tiles the fencing shuts the animals into, washed in as soon as the pen closes.
    let penTiles: Set<GridPoint>
    /// How deep that wash goes, 0 to 1.
    let penGlow: Double
    /// Whether the pen is the best the map has in it, which turns the wash from gold
    /// to a drifting rainbow.
    let isAsGoodAsItGets: Bool
    /// Everything standing on the field, wherever it is standing this instant.
    let animals: [AnimalMark]
    /// Tiles the coach is pointing at — drawn with a soft pulse so a tutorial can say
    /// "this one" without covering the board in labels. Empty during ordinary play.
    var highlightedTiles: Set<GridPoint> = []
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
                    draw(in: &context, board: board)
                }

                penWash(board: board)

                // Above the wash, like the pig: an apple shut into a finished pen has to
                // still read as an apple and not as a patch of the colour laid over it.
                Canvas { context, _ in
                    var field = context
                    field.clip(to: rim(board))
                    drawTreats(in: &field, board: board)
                }
                .allowsHitTesting(false)

                highlights(board: board)

                ForEach(animals) { animal in
                    Text(animal.kind.glyph)
                        .font(.system(size: board.cell * 0.78))
                        // Standing on the ground rather than floating over it, and further
                        // off it the higher a lap of honour throws it.
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: board.cell * (0.04 + 0.05 * animal.hop),
                            y: board.cell * (0.03 + 0.09 * animal.hop)
                        )
                        .opacity(animal.opacity)
                        .position(board.center(of: animal.tile))
                        .offset(y: -board.cell * 0.3 * animal.hop)
                        .allowsHitTesting(false)
                }
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

    /// Soft rings on the tiles a tutorial is asking for, pulsing so they read as a target
    /// rather than as fencing already down.
    @ViewBuilder
    private func highlights(board: BoardGeometry) -> some View {
        if !highlightedTiles.isEmpty {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
                let pulse = reduceMotion
                    ? 0.55
                    : 0.35 + 0.35 * (sin(timeline.date.timeIntervalSinceReferenceDate * 3) + 1) / 2

                Canvas { context, _ in
                    for tile in highlightedTiles {
                        let rect = board.rect(for: tile).insetBy(dx: board.cell * 0.08, dy: board.cell * 0.08)
                        context.fill(
                            Path(roundedRect: rect, cornerRadius: board.cell * 0.18),
                            with: .color(GamePalette.pen.opacity(0.22 + pulse * 0.25))
                        )
                        context.stroke(
                            Path(roundedRect: rect, cornerRadius: board.cell * 0.18),
                            with: .color(GamePalette.cream.opacity(0.55 + pulse * 0.35)),
                            lineWidth: max(2, board.cell * 0.08)
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
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
        let pen = run(of: penTiles, board: board, radius: board.cell * 0.3)

        return ZStack(alignment: .topLeading) {
            pen.fill(GamePalette.pen.opacity(0.5))

            // Brighter just inside the walls, so the pen reads as a pool of light the
            // fencing is holding in rather than a stain spilt on the ground.
            pen.stroke(GamePalette.pen.opacity(0.8), lineWidth: board.cell * 0.18)
                .clipShape(pen)

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

    // MARK: - Drawing the field

    /// The field, in the order the ground was made: mud, the water lying in it, the lines
    /// between the tiles, and whatever fencing has been laid. All of it is kept inside the
    /// board's rim, so the corners of the map are rounded off rather than cut square.
    private func draw(in context: inout GraphicsContext, board: BoardGeometry) {
        let lake = run(of: waterTiles, board: board, radius: board.cell * 0.42)

        var field = context
        field.clip(to: rim(board))

        drawGround(in: &field, board: board)
        drawWater(in: &field, board: board, lake: lake)
        drawGridLines(in: &field, board: board, lake: lake)
        drawFences(in: &field, board: board)

        drawRim(in: &context, board: board)
    }

    /// The mud the whole board is cut out of: lit from above like everything else in the
    /// game, mottled tile by tile so it does not read as one flat slab, and with a scatter
    /// of stones over it.
    private func drawGround(in context: inout GraphicsContext, board: BoardGeometry) {
        context.fill(
            Path(board.frame),
            with: .linearGradient(
                Gradient(colors: [GamePalette.mudLit, GamePalette.mud, GamePalette.mudShade]),
                startPoint: CGPoint(x: board.frame.midX, y: board.frame.minY),
                endPoint: CGPoint(x: board.frame.midX, y: board.frame.maxY)
            )
        )

        for row in 0..<level.rowCount {
            for column in 0..<level.columnCount where level.terrain[row][column] == .mud {
                let tile = GridPoint(row: row, column: column)
                let rect = board.rect(for: tile)
                if let patch = patch(on: tile) {
                    context.fill(Path(rect), with: .color(patch))
                }
                drawSpeckles(in: &context, rect: rect, tile: tile)
            }
        }
    }

    /// A touch of light or shade on one tile of ground, worked out from the tile's own
    /// coordinates so the field is mottled the same way every time it is drawn.
    private func patch(on tile: GridPoint) -> Color? {
        switch (tile.row * 5 + tile.column * 3) % 4 {
        case 0: Color.white.opacity(0.04)
        case 2: Color.black.opacity(0.04)
        default: nil
        }
    }

    /// The water, drawn as one body of it rather than tile by tile: a lake with its
    /// outside corners taken off, silt along the bank, and the light on the surface. Water
    /// is a wall the pen never pays for, so it is worth its looking like one.
    private func drawWater(in context: inout GraphicsContext, board: BoardGeometry, lake: Path) {
        guard !lake.isEmpty else { return }

        // Laid on the mud first and then covered over by the water itself, which leaves
        // the silt showing only on the bank.
        context.stroke(
            lake,
            with: .color(GamePalette.shore.opacity(0.5)),
            lineWidth: board.cell * 0.18
        )

        context.fill(
            lake,
            with: .linearGradient(
                Gradient(colors: [GamePalette.water, GamePalette.waterDeep]),
                startPoint: CGPoint(x: board.frame.midX, y: board.frame.minY),
                endPoint: CGPoint(x: board.frame.midX, y: board.frame.maxY)
            )
        )

        // Everything from here on belongs in the water, so it is stopped at the shore.
        var surface = context
        surface.clip(to: lake)

        surface.stroke(
            lake,
            with: .color(GamePalette.waterRipple.opacity(0.4)),
            lineWidth: board.cell * 0.16
        )
        for tile in waterTiles {
            drawRipples(in: &surface, rect: board.rect(for: tile), tile: tile)
        }
    }

    /// Every tile the map has water on. They are drawn as one lake, so the shape of the
    /// shore matters more than the tiles it is made of.
    private var waterTiles: Set<GridPoint> {
        var tiles: Set<GridPoint> = []
        for row in 0..<level.rowCount {
            for column in 0..<level.columnCount where level.terrain[row][column] == .water {
                tiles.insert(GridPoint(row: row, column: column))
            }
        }
        return tiles
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

    /// The lines between the tiles, ruled over the ground and stopped at the water. A lake
    /// is one sheet of it; squaring it off would only make the map look like a spreadsheet.
    private func drawGridLines(in context: inout GraphicsContext, board: BoardGeometry, lake: Path) {
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

        var ground = context
        ground.clip(to: lake, options: .inverse)
        // Scratched into the mud rather than drawn on top of it: a light line under a dark
        // one, which is what makes a furrow of a line at this size.
        ground.translateBy(x: 0, y: 1)
        ground.stroke(lines, with: .color(GamePalette.mudLit.opacity(0.35)), lineWidth: 1)
        ground.translateBy(x: 0, y: -1)
        ground.stroke(lines, with: .color(GamePalette.mudShade.opacity(0.5)), lineWidth: 1)
    }

    /// The rim of the map: a lip of turned earth all the way round, with the light catching
    /// the inside of it. Everything past it is open country, which is exactly where the pig
    /// is trying to get to.
    private func drawRim(in context: inout GraphicsContext, board: BoardGeometry) {
        let timber = max(2, board.cell * 0.1)
        context.stroke(
            rim(board, inset: timber / 2),
            with: .color(GamePalette.post.opacity(0.85)),
            lineWidth: timber
        )
        context.stroke(
            rim(board, inset: timber * 1.5),
            with: .color(GamePalette.cream.opacity(0.14)),
            lineWidth: max(1, board.cell * 0.03)
        )
    }

    /// The board's own outline, and the shape everything drawn on the field is kept inside.
    /// The corners are taken off only lightly: enough that the map reads as a plot of ground
    /// somebody staked out, not so much that a fence laid in the corner of it looks bitten.
    private func rim(_ board: BoardGeometry, inset: CGFloat = 0) -> Path {
        Path(
            roundedRect: board.frame.insetBy(dx: inset, dy: inset),
            cornerRadius: max(board.cell * 0.3 - inset, 0),
            style: .continuous
        )
    }

    /// A run of tiles as a single shape, with its outside corners taken off.
    ///
    /// Tiles inside the run meet square, so the whole run fills in one pass with no seams
    /// between them, and a corner is only rounded where the run actually turns. Ground off
    /// the edge of the map counts as part of the run, so a river that reaches the rim of
    /// the board is not rounded away from it.
    private func run(of tiles: Set<GridPoint>, board: BoardGeometry, radius: CGFloat) -> Path {
        func belongs(_ row: Int, _ column: Int) -> Bool {
            let tile = GridPoint(row: row, column: column)
            return tiles.contains(tile) || !level.contains(tile)
        }

        var path = Path()
        for tile in tiles {
            let rect = board.rect(for: tile)
            let up = belongs(tile.row - 1, tile.column)
            let down = belongs(tile.row + 1, tile.column)
            let left = belongs(tile.row, tile.column - 1)
            let right = belongs(tile.row, tile.column + 1)

            let topLeft = up || left ? 0 : radius
            let topRight = up || right ? 0 : radius
            let bottomRight = down || right ? 0 : radius
            let bottomLeft = down || left ? 0 : radius

            path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
            if topRight > 0 {
                path.addQuadCurve(
                    to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
                    control: CGPoint(x: rect.maxX, y: rect.minY)
                )
            }
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
            if bottomRight > 0 {
                path.addQuadCurve(
                    to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
                    control: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            }
            path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
            if bottomLeft > 0 {
                path.addQuadCurve(
                    to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
                    control: CGPoint(x: rect.minX, y: rect.maxY)
                )
            }
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
            if topLeft > 0 {
                path.addQuadCurve(
                    to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
                    control: CGPoint(x: rect.minX, y: rect.minY)
                )
            }
            path.closeSubpath()
        }
        return path
    }

    /// What is lying about on the mud: an apple worth five tiles of ground to shut in with
    /// the pig, a skull worth five fewer. Each sits on a pale scuff of ground so it reads
    /// against the mud, and a tile with fencing on it is covered over, treat and all —
    /// which is how a skull gets buried and how an apple gets wasted.
    private func drawTreats(in context: inout GraphicsContext, board: BoardGeometry) {
        for (tile, treat) in level.treats where !fences.contains(tile) {
            let rect = board.rect(for: tile)
            context.fill(
                Path(ellipseIn: rect.insetBy(dx: board.cell * 0.15, dy: board.cell * 0.15)),
                with: .color(.white.opacity(0.2))
            )
            // A shadow on the ground under it, so it lies on the mud rather than in it.
            context.fill(
                Path(ellipseIn: CGRect(
                    x: rect.minX + board.cell * 0.24,
                    y: rect.maxY - board.cell * 0.28,
                    width: board.cell * 0.52,
                    height: board.cell * 0.14
                )),
                with: .color(.black.opacity(0.16))
            )
            context.draw(mark(for: treat, cell: board.cell), at: board.center(of: tile))
        }
    }

    /// A treat as it is drawn on a tile `cell` across. Emoji fill the box they are given
    /// differently, so the skull is set larger than the apple to carry the same weight.
    private func mark(for treat: Treat, cell: CGFloat) -> Text {
        switch treat {
        case .apple: Text("🍎").font(.system(size: cell * 0.58))
        case .skull: Text("☠️").font(.system(size: cell * 0.68))
        }
    }

    /// A fenced tile is a whole square given over to fencing: three pointed pickets with
    /// two rails across them, on ground churned dark and throwing a shadow onto the mud.
    /// Drawn head-on rather than from above, which is the only way it still reads at the
    /// size a tile gets on a phone, and lit down one side of every piece of timber, which
    /// is what keeps it from looking like a sticker.
    private func drawFences(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in fences {
            let plot = board.rect(for: tile).insetBy(dx: board.cell * 0.05, dy: board.cell * 0.05)
            let corner = board.cell * 0.15

            context.fill(
                Path(
                    roundedRect: plot.offsetBy(dx: 0, dy: board.cell * 0.06),
                    cornerRadius: corner
                ),
                with: .color(.black.opacity(0.22))
            )
            context.fill(
                Path(roundedRect: plot, cornerRadius: corner),
                with: .color(GamePalette.post)
            )

            var pickets = Path()
            var lit = Path()
            let width = plot.width * 0.17
            let top = plot.minY + plot.height * 0.11
            let foot = plot.minY + plot.height * 0.93
            for picket in [0.2, 0.5, 0.8] {
                let x = plot.minX + plot.width * picket
                pickets.move(to: CGPoint(x: x - width / 2, y: foot))
                pickets.addLine(to: CGPoint(x: x - width / 2, y: top))
                pickets.addLine(to: CGPoint(x: x, y: top - plot.height * 0.07))
                pickets.addLine(to: CGPoint(x: x + width / 2, y: top))
                pickets.addLine(to: CGPoint(x: x + width / 2, y: foot))
                pickets.closeSubpath()

                lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.36, height: foot - top))
            }
            context.fill(pickets, with: .color(GamePalette.picket))
            context.fill(lit, with: .color(.white.opacity(0.2)))

            var rails = Path()
            var under = Path()
            for rail in [0.40, 0.72] {
                let y = plot.minY + plot.height * rail
                let from = CGPoint(x: plot.minX + plot.width * 0.06, y: y)
                let to = CGPoint(x: plot.maxX - plot.width * 0.06, y: y)
                rails.move(to: from)
                rails.addLine(to: to)
                under.move(to: CGPoint(x: from.x, y: y + plot.height * 0.06))
                under.addLine(to: CGPoint(x: to.x, y: y + plot.height * 0.06))
            }
            context.stroke(
                under,
                with: .color(.black.opacity(0.2)),
                style: StrokeStyle(lineWidth: plot.width * 0.1, lineCap: .round)
            )
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
        animals: .standing(on: .riverBend),
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
        animals: .standing(on: level),
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
    if case .penned(let held) = level.release(fences: fences) {
        pen = held
    }

    return FieldView(
        level: level,
        fences: fences,
        penTiles: pen,
        penGlow: 0.8,
        isAsGoodAsItGets: true,
        animals: .standing(on: level),
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}

/// The best pen Stag Mere has in it: the mere walls one side of each enclosure, so the
/// twenty pieces hold the pig on the north shore and the stag on the south for less than
/// one pen round the pair of them would cost.
#Preview("Two to hold") {
    let game = PuzzleGame.theStagMeresBestPen()

    return FieldView(
        level: game.level,
        fences: game.fences,
        penTiles: game.penTiles,
        penGlow: 0.8,
        isAsGoodAsItGets: game.isPenAsGoodAsItGets,
        animals: .standing(on: game.level),
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}
