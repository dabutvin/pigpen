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

/// What a tap on a treat just said, rising off that tile: five more for an apple, five
/// fewer for a skull. A skull takes no fencing, so this is how a finger finds out the cost
/// without planting a post.
struct WorthCallout: Equatable, Identifiable {
    let id: UUID
    let tile: GridPoint
    let treat: Treat

    init(tile: GridPoint, treat: Treat) {
        self.id = UUID()
        self.tile = tile
        self.treat = treat
    }
}

/// An animal as the field draws it: what it is, the tile it is standing on this instant,
/// and how solid it is — one that has walked off the map fades out where it left.
struct AnimalMark: Equatable, Identifiable {
    let kind: Animal
    var tile: GridPoint
    var opacity: Double

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
    /// The lap of honour under way, if a pen has just held. While one is on, it says where
    /// the animals are rather than the marks doing so, and it throws the confetti.
    var celebration: Celebration?
    /// What a tap on a treat just said, if anything — drawn rising off that tile.
    var worthCallout: WorthCallout? = nil
    /// Told when a callout has finished rising, so the field can put it away.
    var onWorthCalloutFinished: ((WorthCallout.ID) -> Void)? = nil
    /// Tiles the coach is pointing at — drawn with a soft pulse so a tutorial can say
    /// "this one" without covering the board in labels. Empty during ordinary play.
    var highlightedTiles: Set<GridPoint> = []
    /// How this world dresses the windfall and the hazard: an apple and a skull in the meadow,
    /// a truffle and a bramble in the woods. Only the glyph changes — a truffle is scored, tapped
    /// and fenced exactly as an apple is, because it is one under the picture.
    var treatSkin: TreatSkin = WorldTheme.meadow.treats
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
    /// How far the callout has risen and faded, 0 on the tile and 1 up and gone.
    @State private var calloutFlight: CGFloat = 0

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

                confetti(board: board)
                herd(board: board)
                worthSaid(board: board)
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
            .onChange(of: worthCallout?.id) { _, id in
                guard id != nil else {
                    calloutFlight = 0
                    return
                }
                calloutFlight = 0
                let duration = reduceMotion ? 0.01 : 0.95
                withAnimation(.easeOut(duration: duration)) { calloutFlight = 1 }
            }
            .task(id: worthCallout?.id) {
                guard let callout = worthCallout else { return }
                let hold = reduceMotion ? 700 : 1_100
                try? await Task.sleep(for: .milliseconds(hold))
                onWorthCalloutFinished?(callout.id)
            }
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

    /// The animals, wherever they are this instant. A lap of honour is drawn off its own
    /// clock — thirty frames a second is enough for a pulse but not for a gallop — while
    /// everything else about an animal, its walk off the map included, comes out of the
    /// marks the field was handed.
    private func herd(board: BoardGeometry) -> some View {
        // Every mark puts itself where it belongs by hand, so each one has to be handed
        // the whole board to put itself on. Stacked one on top of another for that reason,
        // rather than left as a list: two animals listed inside a timeline are laid out one
        // under the other, half a board each, and the second of them runs its lap that far
        // below the pen it is meant to be shut into — off the field and onto the grass.
        ZStack(alignment: .topLeading) {
            if let celebration, !reduceMotion {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    let elapsed = timeline.date.timeIntervalSince(celebration.start)

                    ZStack(alignment: .topLeading) {
                        ForEach(animals) { animal in
                            mark(
                                animal,
                                board: board,
                                pose: celebration.pose(of: animal.kind, secondsIn: elapsed)
                            )
                        }
                    }
                }
            } else {
                ForEach(animals) { animal in
                    mark(animal, board: board, pose: nil)
                }
            }
        }
    }

    /// One animal, standing on its own tile or held in the pose a celebration puts it in.
    private func mark(_ animal: AnimalMark, board: BoardGeometry, pose: AnimalPose?) -> some View {
        let pose = pose ?? AnimalPose(
            row: Double(animal.tile.row),
            column: Double(animal.tile.column)
        )

        return Text(animal.kind.glyph)
            .font(.system(size: board.cell * 0.78))
            .scaleEffect(x: CGFloat(pose.stretch), y: CGFloat(pose.squash), anchor: .bottom)
            .rotationEffect(.degrees(pose.lean))
            // Standing on the ground rather than floating over it, and further off it the
            // higher the celebration lifts it.
            .shadow(
                color: .black.opacity(0.3),
                radius: board.cell * (0.04 + 0.15 * pose.lift),
                y: board.cell * (0.03 + 0.26 * pose.lift)
            )
            .opacity(animal.opacity)
            .position(board.center(atRow: pose.row, column: pose.column, lift: pose.lift))
            .allowsHitTesting(false)
    }

    /// What a tap on a treat just said, rising off that tile and fading out. Written onto
    /// the grass the way the best-pen tally is — cream with a shadow — so it is painted
    /// rather than printed on a plaque of its own.
    @ViewBuilder
    private func worthSaid(board: BoardGeometry) -> some View {
        if let callout = worthCallout {
            let center = board.center(of: callout.tile)
            Text(callout.treat.pointsSaid)
                .font(.system(size: max(14, board.cell * 0.36), weight: .heavy))
                .foregroundStyle(GamePalette.cream)
                .shadow(color: .black.opacity(0.55), radius: 3, y: 1)
                .position(
                    x: center.x,
                    y: center.y - board.cell * (0.15 + 0.7 * calloutFlight)
                )
                .opacity(Double(1 - calloutFlight))
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    /// The confetti thrown over a pen that holds.
    @ViewBuilder
    private func confetti(board: BoardGeometry) -> some View {
        if let celebration, !reduceMotion {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                Canvas { context, _ in
                    drawConfetti(
                        in: &context,
                        board: board,
                        celebration: celebration,
                        elapsed: timeline.date.timeIntervalSince(celebration.start)
                    )
                }
            }
            .allowsHitTesting(false)
        }
    }

    /// A handful of scraps out of the ground each animal is standing on, thrown up as the
    /// gate opens and tumbling back down over the pen. Every scrap's flight is drawn from a
    /// seeded scatter and the time on the clock, so a win throws the same confetti twice
    /// and none of it has to be kept anywhere.
    private func drawConfetti(
        in context: inout GraphicsContext,
        board: BoardGeometry,
        celebration: Celebration,
        elapsed: Double
    ) {
        // Tiles a second, and tiles a second a second: a scrap goes up fast and comes down
        // the way anything else on the field would.
        let gravity = 5.4

        for lap in celebration.laps {
            let source = board.center(of: lap.animal.tile)
            var scatter = Scatter(
                seed: UInt64(truncatingIfNeeded: lap.animal.tile.row * 31 + lap.animal.tile.column + 1)
            )

            for _ in 0..<22 {
                let delay = scatter.next(in: 0...0.22)
                let life = scatter.next(in: 1.0...1.6)
                // Anywhere from up and out to the left to up and out to the right, but
                // never downwards: it is thrown, not dropped.
                let heading = scatter.next(in: -0.82 ... -0.18) * .pi
                let speed = scatter.next(in: 1.9...3.5)
                let size = board.cell * CGFloat(scatter.next(in: 0.10...0.17))
                let spin = scatter.next(in: 0...6.3)
                let tumble = scatter.next(in: 5...13)
                let color = scrapColor(&scatter)

                let age = elapsed - delay
                guard age > 0, age < life else { continue }

                let center = CGPoint(
                    x: source.x + board.cell * CGFloat(cos(heading) * speed * age),
                    y: source.y + board.cell * CGFloat(sin(heading) * speed * age + gravity * age * age / 2)
                )
                // Turning end over end: a scrap edge-on is a sliver, face-on the full width.
                let width = size * CGFloat(0.2 + 0.8 * abs(cos(spin + tumble * age)))
                let fade = min(1, age * 8) * min(1, (life - age) / 0.35)

                context.fill(
                    Path(
                        roundedRect: CGRect(
                            x: center.x - width / 2,
                            y: center.y - size * 0.34,
                            width: width,
                            height: size * 0.68
                        ),
                        cornerRadius: size * 0.16
                    ),
                    with: .color(color.opacity(0.92 * fade))
                )
            }
        }
    }

    /// What one scrap is cut from: the colours of the field for an ordinary pen, and the
    /// whole spectrum for one there is nothing above.
    private func scrapColor(_ scatter: inout Scatter) -> Color {
        guard !isAsGoodAsItGets else {
            return Color(hue: scatter.next(), saturation: 0.78, brightness: 0.96)
        }

        let colors = [GamePalette.pen, GamePalette.cream, GamePalette.barn, GamePalette.beyond]
        return colors[min(Int(scatter.next() * Double(colors.count)), colors.count - 1)]
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
    /// coordinates so the field is mottled the same way every time it is drawn. Two tiles in
    /// five get one, faintly: any more and any stronger and the field is a chessboard.
    private func patch(on tile: GridPoint) -> Color? {
        switch (tile.row * 7 + tile.column * 11) % 5 {
        case 0: Color.white.opacity(0.03)
        case 3: Color.black.opacity(0.03)
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
        drawRipples(in: &surface, board: board)
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

    /// The light breaking on the surface. Scattered from the tiles' own coordinates rather
    /// than drawn one to a tile: a lake is a single body of water, and a ripple squared up in
    /// the middle of every tile of it reads as tiles.
    private func drawRipples(in context: inout GraphicsContext, board: BoardGeometry) {
        var ripples = Path()
        for tile in waterTiles {
            let rect = board.rect(for: tile)
            var noise = UInt64(truncatingIfNeeded: tile.row * 131 + tile.column * 57 + 3)
            for _ in 0..<2 {
                noise = noise &* 6364136223846793005 &+ 1442695040888963407
                guard (noise >> 12) % 100 < 38 else { continue }

                let span = board.cell * (0.32 + 0.3 * CGFloat((noise >> 20) % 100) / 100)
                let across = CGFloat((noise >> 32) % 100) / 100
                let down = CGFloat((noise >> 44) % 100) / 100
                let start = CGPoint(
                    x: rect.minX + board.cell * 0.08 + across * (board.cell * 0.84 - span),
                    y: rect.minY + board.cell * (0.14 + down * 0.72)
                )
                ripples.move(to: start)
                ripples.addQuadCurve(
                    to: CGPoint(x: start.x + span, y: start.y),
                    control: CGPoint(x: start.x + span / 2, y: start.y - board.cell * 0.13)
                )
            }
        }
        context.stroke(
            ripples,
            with: .color(GamePalette.waterRipple.opacity(0.42)),
            style: StrokeStyle(lineWidth: max(1, board.cell * 0.05), lineCap: .round)
        )
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
        // one, which is what makes a furrow of a line at this size. They have to be clear
        // enough to count tiles along, since counting tiles is the game.
        ground.translateBy(x: 0, y: 1)
        ground.stroke(lines, with: .color(GamePalette.mudLit.opacity(0.5)), lineWidth: 1)
        ground.translateBy(x: 0, y: -1)
        ground.stroke(lines, with: .color(GamePalette.mudShade.opacity(0.65)), lineWidth: 1)
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
    /// which is how an apple gets wasted. A skull is never covered over: it takes no
    /// fencing, so it is on the board for as long as the board is, and a tap on one says
    /// what it costs rather than planting a post.
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

    /// A treat as it is drawn on a tile `cell` across, in whatever the world dresses it as.
    /// Emoji fill the box they are given differently, so each glyph carries its own scale.
    private func mark(for treat: Treat, cell: CGFloat) -> Text {
        Text(treatSkin.glyph(for: treat))
            .font(.system(size: cell * treatSkin.scale(for: treat)))
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

/// A pen that holds, mid-celebration: the pig part way round the little circle it runs when
/// the gate opens and there is nowhere to go, under the confetti thrown for it. The clock
/// starts as the preview opens, so it plays the lap once and then stands still.
#Preview("A lap of honour") {
    let game = PuzzleGame(level: .riverBend)
    for row in 3...9 {
        game.buildFence(on: GridPoint(row: row, column: 0))
    }
    for column in 1...5 {
        game.buildFence(on: GridPoint(row: 10, column: column))
    }
    game.openTheGate()

    return FieldView(
        level: game.level,
        fences: game.fences,
        penTiles: game.penTiles,
        penGlow: 1,
        isAsGoodAsItGets: game.isPenAsGoodAsItGets,
        animals: .standing(on: game.level),
        celebration: Celebration(laps: game.victoryLaps, start: .now),
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

/// Both of Stag Mere's animals celebrating at once: the pig round its own circle on the
/// north shore and the stag round its own on the south, each inside the pen holding it and
/// neither of them anywhere near the grass off the board.
#Preview("Two laps at once") {
    let game = PuzzleGame.theStagMeresBestPen()
    game.openTheGate()

    return FieldView(
        level: game.level,
        fences: game.fences,
        penTiles: game.penTiles,
        penGlow: 1,
        isAsGoodAsItGets: game.isPenAsGoodAsItGets,
        animals: .standing(on: game.level),
        celebration: Celebration(laps: game.victoryLaps, start: .now),
        onStroke: { _ in },
        onStrokeEnd: {}
    )
    .padding()
}
