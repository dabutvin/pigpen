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
    /// How this world paints the board itself: the ground it is cut out of, the water lying in
    /// it, and the fencing built on top. Mud is mud and water is water whatever the skin — the
    /// game underneath cannot tell ash from leaf mould — but the meadow's field is mud with
    /// stones in it and the mountain's is ash with cinder still going in it.
    var skin: FieldSkin = .meadow
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

    /// The ground the whole board is cut out of: lit from above like everything else in the
    /// game, mottled tile by tile so it does not read as one flat slab, and strewn with
    /// whatever this world's ground is strewn with.
    private func drawGround(in context: inout GraphicsContext, board: BoardGeometry) {
        context.fill(
            Path(board.frame),
            with: .linearGradient(
                Gradient(colors: [skin.groundLit, skin.ground, skin.groundShade]),
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
                drawGrain(in: &context, rect: rect, tile: tile)
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

        // Laid on the ground first and then covered over by the water itself, which leaves
        // the silt showing only on the bank.
        context.stroke(
            lake,
            with: .color(skin.shore.opacity(0.5)),
            lineWidth: board.cell * 0.18
        )

        context.fill(
            lake,
            with: .linearGradient(
                Gradient(colors: [skin.water, skin.waterDeep]),
                startPoint: CGPoint(x: board.frame.midX, y: board.frame.minY),
                endPoint: CGPoint(x: board.frame.midX, y: board.frame.maxY)
            )
        )

        // Everything from here on belongs in the water, so it is stopped at the shore.
        var surface = context
        surface.clip(to: lake)

        surface.stroke(
            lake,
            with: .color(skin.waterLight.opacity(0.4)),
            lineWidth: board.cell * 0.16
        )
        drawSurface(in: &surface, board: board)
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

    /// The mark one tile of ground carries, laid out from that tile's own coordinates so the
    /// field is strewn the same way every time it is drawn. What the mark is comes from the
    /// world the board is standing in: stones turned up in meadow mud, leaves lying in the
    /// wood, cinder still going on the mountain, setts somebody laid in the city.
    private func drawGrain(in context: inout GraphicsContext, rect: CGRect, tile: GridPoint) {
        var scatter = Scatter(seed: UInt64(truncatingIfNeeded: tile.row * 73 + tile.column * 19 + 7))
        switch skin.grain {
        case .stones: drawStones(in: &context, rect: rect, scatter: &scatter)
        case .leafMould: drawLeaves(in: &context, rect: rect, scatter: &scatter)
        case .cinder: drawCinder(in: &context, rect: rect, scatter: &scatter)
        case .setts: drawSetts(in: &context, rect: rect, scatter: &scatter)
        case .pits: drawPits(in: &context, rect: rect, scatter: &scatter)
        case .ribs: drawRibs(in: &context, rect: rect, scatter: &scatter)
        case .sawdust: drawSawdust(in: &context, rect: rect, scatter: &scatter)
        case .hardpan: drawHardpan(in: &context, rect: rect, scatter: &scatter)
        }
    }

    /// A couple of stones per tile, turned up out of the mud.
    private func drawStones(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        let size = rect.width * 0.08
        let margin = rect.width * 0.16
        for _ in 0..<3 {
            let across = CGFloat(scatter.next())
            let down = CGFloat(scatter.next())
            let dot = CGRect(
                x: rect.minX + margin + across * (rect.width - 2 * margin - size),
                y: rect.minY + margin + down * (rect.height - 2 * margin - size),
                width: size,
                height: size
            )
            context.fill(Path(ellipseIn: dot), with: .color(skin.grit.opacity(0.35)))
        }
    }

    /// Leaves lying where they fell: flat, at whatever angle they landed at, and dark against
    /// the mould rather than the bright thing they were on the way down.
    private func drawLeaves(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        for _ in 0..<3 {
            let centre = CGPoint(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.18...0.82)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.18...0.82))
            )
            let span = rect.width * CGFloat(scatter.next(in: 0.20...0.34))
            let leaf = Path(
                ellipseIn: CGRect(x: -span / 2, y: -span * 0.15, width: span, height: span * 0.3)
            )
            .applying(
                CGAffineTransform(rotationAngle: CGFloat(scatter.next(in: -1.4...1.4)))
                    .concatenating(CGAffineTransform(translationX: centre.x, y: centre.y))
            )
            context.fill(leaf, with: .color(skin.grit.opacity(scatter.next(in: 0.24...0.46))))
        }
    }

    /// Ash with cinder through it, and on some tiles an ember that has not gone out yet — the
    /// whole of what the mountain is, which is nothing growing and the ground still working.
    private func drawCinder(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        for _ in 0..<4 {
            let size = rect.width * CGFloat(scatter.next(in: 0.05...0.11))
            let fleck = CGRect(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.12...0.82)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.12...0.82)),
                width: size,
                height: size * 0.8
            )
            context.fill(
                Path(ellipseIn: fleck),
                with: .color(.black.opacity(scatter.next(in: 0.10...0.24)))
            )
        }

        guard scatter.next() < 0.3 else { return }
        let centre = CGPoint(
            x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.25...0.75)),
            y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.25...0.75))
        )
        // The ground warmed round it, then the ember itself in the middle of that.
        let reach = rect.width * 0.26
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - reach, y: centre.y - reach, width: reach * 2, height: reach * 2
            )),
            with: .radialGradient(
                Gradient(colors: [skin.grit.opacity(0.45), skin.grit.opacity(0)]),
                center: centre,
                startRadius: 0,
                endRadius: reach
            )
        )
        let eye = rect.width * 0.07
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - eye / 2, y: centre.y - eye / 2, width: eye, height: eye
            )),
            with: .color(skin.grit.opacity(0.85))
        )
    }

    /// Courses of setts, every other course offset by half a stone and stopped at the edges of
    /// the tile. It is the joints that read at this size, so the stones themselves are only
    /// lightened and darkened a shade either side of the paving and the mortar does the drawing.
    private func drawSetts(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        var paved = context
        paved.clip(to: Path(rect))

        let joint = max(1, rect.width * 0.045)
        let sett = rect.width / 2
        let course = rect.height / 2
        for down in 0..<2 {
            let offset = down.isMultiple(of: 2) ? 0 : sett / 2
            // One stone either side of the tile as well as the two in it, since an offset
            // course starts half a stone out and has to finish half a stone past the far edge.
            for across in -1...2 {
                let stone = CGRect(
                    x: rect.minX + CGFloat(across) * sett + offset + joint / 2,
                    y: rect.minY + CGFloat(down) * course + joint / 2,
                    width: sett - joint,
                    height: course - joint
                )
                let cut = Path(roundedRect: stone, cornerRadius: joint)
                paved.fill(
                    cut,
                    with: .color(
                        scatter.next() < 0.5
                            ? Color.white.opacity(0.05)
                            : Color.black.opacity(0.06)
                    )
                )
                // The mortar, drawn round the stone rather than under it, so the light still
                // falls down the board the way it does everywhere else.
                paved.stroke(
                    cut,
                    with: .color(skin.grit.opacity(0.35)),
                    lineWidth: joint * 0.6
                )
            }
        }
    }

    /// Dust with things having landed in it: a shallow pit ringed pale where the ground was
    /// thrown up, on the tiles that have one, and grains of the dust itself on all of them.
    private func drawPits(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        if scatter.next() < 0.55 {
            let centre = CGPoint(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.3...0.7)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.3...0.7))
            )
            let spread = rect.width * CGFloat(scatter.next(in: 0.28...0.48))
            let pit = CGRect(
                x: centre.x - spread / 2,
                y: centre.y - spread * 0.2,
                width: spread,
                height: spread * 0.4
            )
            context.fill(Path(ellipseIn: pit), with: .color(.black.opacity(0.16)))
            context.stroke(
                Path(ellipseIn: pit.insetBy(dx: -spread * 0.06, dy: -spread * 0.03)),
                with: .color(GamePalette.cream.opacity(0.16)),
                lineWidth: max(1, spread * 0.05)
            )
        }

        for _ in 0..<2 {
            let size = rect.width * 0.05
            let grain = CGRect(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.1...0.85)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.1...0.85)),
                width: size,
                height: size
            )
            context.fill(Path(ellipseIn: grain), with: .color(skin.grit.opacity(0.3)))
        }
    }

    /// Flowstone: rock that has had water running over it long enough to lay it down in
    /// ledges, so the ground is banded — a black step with the wet lip of the next rib
    /// catching the crystal light over the top of it.
    private func drawRibs(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        for _ in 0..<2 {
            let down = rect.minY + rect.height * CGFloat(scatter.next(in: 0.22...0.8))
            var rib = Path()
            rib.move(to: CGPoint(x: rect.minX, y: down))
            rib.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: down + rect.height * CGFloat(scatter.next(in: -0.05...0.05))),
                control: CGPoint(x: rect.midX, y: down - rect.height * CGFloat(scatter.next(in: 0.04...0.12)))
            )
            context.stroke(
                rib,
                with: .color(.black.opacity(scatter.next(in: 0.12...0.20))),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.08), lineCap: .round)
            )
            context.stroke(
                rib.applying(CGAffineTransform(translationX: 0, y: -max(1, rect.width * 0.05))),
                with: .color(skin.grit.opacity(0.20)),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.03), lineCap: .round)
            )
        }
    }

    /// Sawdust, thrown down over ground a week of boots has already been over: pale flecks of
    /// it, heavier in some places than others, which is how it lands.
    private func drawSawdust(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        for _ in 0..<7 {
            let size = rect.width * CGFloat(scatter.next(in: 0.05...0.10))
            let fleck = CGRect(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.08...0.86)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.08...0.86)),
                width: size,
                height: size * 0.5
            )
            context.fill(
                Path(roundedRect: fleck, cornerRadius: size * 0.25),
                with: .color(skin.grit.opacity(scatter.next(in: 0.18...0.42)))
            )
        }
    }

    /// Hardpan: clay that dried out and went on drying until it cracked into plates. The crack
    /// does the drawing — a dark line with a pale lip along the top of it, since a plate that
    /// has curled at the edge catches the sun on the way up and hides it on the way down.
    private func drawHardpan(in context: inout GraphicsContext, rect: CGRect, scatter: inout Scatter) {
        for _ in 0..<2 {
            let down = rect.minY + rect.height * CGFloat(scatter.next(in: 0.18...0.82))
            let kink = rect.midX + rect.width * CGFloat(scatter.next(in: -0.25...0.25))
            var crack = Path()
            crack.move(to: CGPoint(x: rect.minX, y: down))
            crack.addLine(to: CGPoint(
                x: kink,
                y: down + rect.height * CGFloat(scatter.next(in: -0.12...0.12))
            ))
            crack.addLine(to: CGPoint(
                x: rect.maxX,
                y: down + rect.height * CGFloat(scatter.next(in: -0.10...0.10))
            ))
            context.stroke(
                crack.applying(CGAffineTransform(translationX: 0, y: -max(1, rect.width * 0.03))),
                with: .color(GamePalette.cream.opacity(0.18)),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.03), lineJoin: .round)
            )
            context.stroke(
                crack,
                with: .color(skin.grit.opacity(scatter.next(in: 0.22...0.38))),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.035), lineJoin: .round)
            )
        }

        // And the odd branch off one, because a crack in a pan never runs alone for long.
        if scatter.next() < 0.5 {
            let foot = CGPoint(
                x: rect.minX + rect.width * CGFloat(scatter.next(in: 0.25...0.75)),
                y: rect.minY + rect.height * CGFloat(scatter.next(in: 0.2...0.8))
            )
            var branch = Path()
            branch.move(to: foot)
            branch.addLine(to: CGPoint(
                x: foot.x + rect.width * CGFloat(scatter.next(in: -0.3...0.3)),
                y: foot.y + rect.height * CGFloat(scatter.next(in: 0.18...0.34))
            ))
            context.stroke(
                branch,
                with: .color(skin.grit.opacity(0.24)),
                style: StrokeStyle(lineWidth: max(1, rect.width * 0.028), lineCap: .round)
            )
        }
    }

    /// What is going on on the surface, which is not the same thing twice: light breaking on
    /// open water in the meadow, rings on a standing pool in the wood, steam off a mountain
    /// tarn, a slick on a canal, the light still in the well a star made, one river running,
    /// a crowd stood at the carnival where every other world has water — and, in the dunes,
    /// sand doing the same job standing still.
    private func drawSurface(in context: inout GraphicsContext, board: BoardGeometry) {
        switch skin.surface {
        case .ripples: drawRipples(in: &context, board: board)
        case .peat: drawRings(in: &context, board: board)
        case .steam: drawSteam(in: &context, board: board)
        case .sheen: drawSlick(in: &context, board: board)
        case .starlight: drawGlints(in: &context, board: board)
        case .flow: drawFlow(in: &context, board: board)
        case .crowd: drawCrowd(in: &context, board: board)
        case .dune: drawDune(in: &context, board: board)
        }
    }

    /// A tile's own generator, so everything scattered on the water lands in the same place
    /// every time the board is drawn.
    private func scatter(on tile: GridPoint) -> Scatter {
        Scatter(seed: UInt64(truncatingIfNeeded: tile.row * 131 + tile.column * 57 + 3))
    }

    /// The light breaking on the surface. Scattered from the tiles' own coordinates rather
    /// than drawn one to a tile: a lake is a single body of water, and a ripple squared up in
    /// the middle of every tile of it reads as tiles.
    private func drawRipples(in context: inout GraphicsContext, board: BoardGeometry) {
        var ripples = Path()
        for tile in waterTiles {
            let rect = board.rect(for: tile)
            var noise = scatter(on: tile)
            for _ in 0..<2 {
                guard noise.next() < 0.38 else { continue }

                let span = board.cell * CGFloat(noise.next(in: 0.32...0.62))
                let across = CGFloat(noise.next())
                let down = CGFloat(noise.next())
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
            with: .color(skin.waterLight.opacity(0.42)),
            style: StrokeStyle(lineWidth: max(1, board.cell * 0.05), lineCap: .round)
        )
    }

    /// Rings on a standing pool, spreading from wherever something went in and nothing since.
    /// A pool in the leaf litter does not break the way open water does; it only remembers.
    private func drawRings(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in waterTiles {
            var noise = scatter(on: tile)
            guard noise.next() < 0.45 else { continue }

            let centre = board.center(of: tile)
            let reach = board.cell * CGFloat(noise.next(in: 0.16...0.3))
            for ring in 1...2 {
                let spread = reach * CGFloat(ring)
                context.stroke(
                    Path(ellipseIn: CGRect(
                        x: centre.x - spread,
                        y: centre.y - spread * 0.6,
                        width: spread * 2,
                        height: spread * 1.2
                    )),
                    with: .color(skin.waterLight.opacity(0.32 / Double(ring))),
                    lineWidth: max(1, board.cell * 0.035)
                )
            }
        }
    }

    /// Steam off a tarn: wisps that lean as they rise, since everything on this mountain is
    /// giving something off and standing water most of all.
    private func drawSteam(in context: inout GraphicsContext, board: BoardGeometry) {
        var wisps = Path()
        for tile in waterTiles {
            let rect = board.rect(for: tile)
            var noise = scatter(on: tile)
            for _ in 0..<2 {
                guard noise.next() < 0.5 else { continue }

                let foot = CGPoint(
                    x: rect.minX + board.cell * CGFloat(noise.next(in: 0.2...0.8)),
                    y: rect.maxY - board.cell * CGFloat(noise.next(in: 0.12...0.3))
                )
                let rise = board.cell * CGFloat(noise.next(in: 0.3...0.55))
                let lean = board.cell * CGFloat(noise.next(in: -0.16...0.16))
                wisps.move(to: foot)
                wisps.addCurve(
                    to: CGPoint(x: foot.x + lean, y: foot.y - rise),
                    control1: CGPoint(x: foot.x - lean, y: foot.y - rise * 0.4),
                    control2: CGPoint(x: foot.x + lean * 1.6, y: foot.y - rise * 0.7)
                )
            }
        }
        context.stroke(
            wisps,
            with: .color(skin.waterLight.opacity(0.38)),
            style: StrokeStyle(lineWidth: max(1, board.cell * 0.055), lineCap: .round)
        )
    }

    /// The slick on a canal, which lies still and runs the way the cut runs: along it where
    /// the water carries on north or south, across it where the cut is going the other way.
    private func drawSlick(in context: inout GraphicsContext, board: BoardGeometry) {
        let cut = waterTiles
        var bands = Path()
        for tile in cut {
            let rect = board.rect(for: tile)
            let alongTheCut = cut.contains(GridPoint(row: tile.row - 1, column: tile.column))
                || cut.contains(GridPoint(row: tile.row + 1, column: tile.column))
            var noise = scatter(on: tile)
            for band in [0.32, 0.66] {
                guard noise.next() < 0.75 else { continue }

                let drift = CGFloat(noise.next(in: -0.05...0.05))
                if alongTheCut {
                    let x = rect.minX + board.cell * (CGFloat(band) + drift)
                    bands.move(to: CGPoint(x: x, y: rect.minY + board.cell * 0.06))
                    bands.addLine(to: CGPoint(x: x, y: rect.maxY - board.cell * 0.06))
                } else {
                    let y = rect.minY + board.cell * (CGFloat(band) + drift)
                    bands.move(to: CGPoint(x: rect.minX + board.cell * 0.06, y: y))
                    bands.addLine(to: CGPoint(x: rect.maxX - board.cell * 0.06, y: y))
                }
            }
        }
        context.stroke(
            bands,
            with: .color(skin.waterLight.opacity(0.28)),
            style: StrokeStyle(lineWidth: max(1, board.cell * 0.06), lineCap: .round)
        )
    }

    /// The light still in a well where a star went in: a bloom off the middle of it and a
    /// glint across that. Every drop of water out here is one tile, so this is the one surface
    /// in the game that is drawn tile by tile on purpose.
    private func drawGlints(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in waterTiles {
            let centre = board.center(of: tile)
            var noise = scatter(on: tile)
            let reach = board.cell * CGFloat(noise.next(in: 0.2...0.32))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - reach, y: centre.y - reach, width: reach * 2, height: reach * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [skin.waterLight.opacity(0.7), skin.waterLight.opacity(0)]),
                    center: centre,
                    startRadius: 0,
                    endRadius: reach
                )
            )

            let arm = board.cell * CGFloat(noise.next(in: 0.16...0.24))
            var glint = Path()
            glint.move(to: CGPoint(x: centre.x - arm, y: centre.y))
            glint.addLine(to: CGPoint(x: centre.x + arm, y: centre.y))
            glint.move(to: CGPoint(x: centre.x, y: centre.y - arm))
            glint.addLine(to: CGPoint(x: centre.x, y: centre.y + arm))
            context.stroke(
                glint,
                with: .color(skin.waterLight.opacity(0.65)),
                style: StrokeStyle(lineWidth: max(1, board.cell * 0.035), lineCap: .round)
            )
        }
    }

    /// One river, running: every line drawn straight through a tile and out the other side, so
    /// a run of water reads as a length of something moving rather than as tiles of it.
    private func drawFlow(in context: inout GraphicsContext, board: BoardGeometry) {
        let river = waterTiles
        var lines = Path()
        for tile in river {
            let rect = board.rect(for: tile)
            let downstream = river.contains(GridPoint(row: tile.row - 1, column: tile.column))
                || river.contains(GridPoint(row: tile.row + 1, column: tile.column))
            for lane in [0.34, 0.66] {
                if downstream {
                    let x = rect.minX + board.cell * CGFloat(lane)
                    lines.move(to: CGPoint(x: x, y: rect.minY))
                    lines.addQuadCurve(
                        to: CGPoint(x: x, y: rect.maxY),
                        control: CGPoint(x: x + board.cell * 0.07, y: rect.midY)
                    )
                } else {
                    let y = rect.minY + board.cell * CGFloat(lane)
                    lines.move(to: CGPoint(x: rect.minX, y: y))
                    lines.addQuadCurve(
                        to: CGPoint(x: rect.maxX, y: y),
                        control: CGPoint(x: rect.midX, y: y + board.cell * 0.07)
                    )
                }
            }
        }
        context.stroke(
            lines,
            with: .color(skin.waterLight.opacity(0.3)),
            style: StrokeStyle(lineWidth: max(1, board.cell * 0.04), lineCap: .round)
        )
    }

    /// The crowd: heads, shoulder to shoulder, with the lanterns catching the top of every one
    /// of them. It walls a pen exactly as a mere does — a pig will not walk through a queue
    /// any more than it will swim a river — and it is the one body of water in the game that
    /// somebody could ask to move.
    private func drawCrowd(in context: inout GraphicsContext, board: BoardGeometry) {
        for tile in waterTiles {
            let rect = board.rect(for: tile)
            var noise = scatter(on: tile)
            for _ in 0..<3 {
                let size = board.cell * CGFloat(noise.next(in: 0.22...0.32))
                let head = CGRect(
                    x: rect.minX + board.cell * CGFloat(noise.next(in: 0.12...0.88)) - size / 2,
                    y: rect.minY + board.cell * CGFloat(noise.next(in: 0.15...0.85)) - size / 2,
                    width: size,
                    height: size
                )
                context.fill(Path(ellipseIn: head), with: .color(.black.opacity(0.22)))
                // The lantern on the top of it, which is what a crowd looks like from above
                // after dark: not faces, only the light landing on however many heads.
                context.fill(
                    Path(ellipseIn: head.insetBy(dx: size * 0.18, dy: size * 0.18)
                        .offsetBy(dx: 0, dy: -size * 0.08)),
                    with: .color(skin.waterLight.opacity(0.5))
                )
            }
        }
    }

    /// The dune: sand where every other world has water, and it walls a pen for the same
    /// reason a mere does — a pig will no more climb a slipface than it will swim. What makes
    /// a bank of tiles read as a ridge rather than a pool is the two edges of it: the crest
    /// along the top, where the sand runs out into the light, and the slipface under the
    /// bottom, dropping away into its own shadow. The wind's combing goes over both.
    private func drawDune(in context: inout GraphicsContext, board: BoardGeometry) {
        let sand = waterTiles
        for tile in sand {
            let rect = board.rect(for: tile)
            var noise = scatter(on: tile)

            // The combing the wind leaves up the back of a dune: parallel, and running the
            // same way on every tile, since it is one dune rather than a tile's worth each.
            var ripples = Path()
            for lane in [0.3, 0.55, 0.8] {
                let y = rect.minY + board.cell * CGFloat(lane)
                ripples.move(to: CGPoint(x: rect.minX, y: y))
                ripples.addQuadCurve(
                    to: CGPoint(x: rect.maxX, y: y),
                    control: CGPoint(
                        x: rect.midX,
                        y: y - board.cell * CGFloat(noise.next(in: 0.04...0.09))
                    )
                )
            }
            context.stroke(
                ripples,
                with: .color(skin.waterLight.opacity(0.28)),
                style: StrokeStyle(lineWidth: max(1, board.cell * 0.03), lineCap: .round)
            )

            // The crest, on the tiles that have nothing above them.
            if !sand.contains(GridPoint(row: tile.row - 1, column: tile.column)) {
                var crest = Path()
                let top = rect.minY + board.cell * 0.09
                crest.move(to: CGPoint(x: rect.minX, y: top))
                crest.addQuadCurve(
                    to: CGPoint(x: rect.maxX, y: top),
                    control: CGPoint(x: rect.midX, y: top - board.cell * 0.06)
                )
                context.stroke(
                    crest,
                    with: .color(skin.waterLight.opacity(0.7)),
                    style: StrokeStyle(lineWidth: max(1, board.cell * 0.05), lineCap: .round)
                )
            }

            // And the slipface, on the tiles that have nothing below them: the steep side,
            // which is the side a pig would have to come up and the reason it does not.
            if !sand.contains(GridPoint(row: tile.row + 1, column: tile.column)) {
                context.fill(
                    Path(CGRect(
                        x: rect.minX,
                        y: rect.maxY - board.cell * 0.34,
                        width: rect.width,
                        height: board.cell * 0.34
                    )),
                    with: .linearGradient(
                        Gradient(colors: [skin.waterDeep.opacity(0), skin.waterDeep.opacity(0.75)]),
                        startPoint: CGPoint(x: rect.midX, y: rect.maxY - board.cell * 0.34),
                        endPoint: CGPoint(x: rect.midX, y: rect.maxY)
                    )
                )
            }
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
        // one, which is what makes a furrow of a line at this size. They have to be clear
        // enough to count tiles along, since counting tiles is the game.
        ground.translateBy(x: 0, y: 1)
        ground.stroke(lines, with: .color(skin.groundLit.opacity(0.5)), lineWidth: 1)
        ground.translateBy(x: 0, y: -1)
        ground.stroke(lines, with: .color(skin.groundShade.opacity(0.65)), lineWidth: 1)
    }

    /// The rim of the map: a lip of turned earth all the way round, with the light catching
    /// the inside of it. Everything past it is open country, which is exactly where the pig
    /// is trying to get to.
    private func drawRim(in context: inout GraphicsContext, board: BoardGeometry) {
        let timber = max(2, board.cell * 0.1)
        context.stroke(
            rim(board, inset: timber / 2),
            with: .color(skin.post.opacity(0.85)),
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
    /// against the mud, and neither is ever covered over: no treat takes fencing, so every
    /// one of them is on the board for as long as the board is, and a tap on one says what
    /// it is worth rather than planting a post.
    private func drawTreats(in context: inout GraphicsContext, board: BoardGeometry) {
        for (tile, treat) in level.treats {
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

    /// A fenced tile is a whole square given over to fencing, on ground churned dark and
    /// throwing a shadow onto the field. What stands in that square is whatever this world
    /// fences with — pickets and rails in the meadow, a woven hurdle in the wood, iron in the
    /// city, bunting at the fair — but the square, the shadow and the churned ground under it
    /// are the same everywhere, because a piece of fencing costs one piece of the budget
    /// wherever it is laid and has to read as the same thing.
    ///
    /// All of it is drawn head-on rather than from above, which is the only way it still reads
    /// at the size a tile gets on a phone, and lit down one side of every upright, which is
    /// what keeps it from looking like a sticker.
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
                with: .color(skin.post)
            )

            switch skin.fencing {
            case .pickets: drawPickets(in: &context, plot: plot)
            case .hurdle: drawHurdle(in: &context, plot: plot)
            case .charredStakes: drawCharredStakes(in: &context, plot: plot)
            case .railings: drawRailings(in: &context, plot: plot)
            case .beacons: drawBeacons(in: &context, plot: plot)
            case .props: drawProps(in: &context, plot: plot)
            case .bunting: drawBunting(in: &context, plot: plot)
            case .driftFence: drawDriftFence(in: &context, plot: plot)
            }
        }
    }

    /// The meadow's fence: three pointed pickets with two rails across them.
    private func drawPickets(in context: inout GraphicsContext, plot: CGRect) {
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
        context.fill(pickets, with: .color(skin.picket))
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
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: plot.width * 0.13, lineCap: .round)
        )
    }

    /// The thicket's: a hurdle, which is what a wood fences itself with. Three stakes with
    /// withies woven through them, and the weave is the whole of it — every rod passes behind
    /// the stake in the middle and comes back out in front of the two either side, which is
    /// the one thing that tells a hurdle from a fence with three rails nailed on.
    private func drawHurdle(in context: inout GraphicsContext, plot: CGRect) {
        var stakes = Path()
        var lit = Path()
        let width = plot.width * 0.13
        let top = plot.minY + plot.height * 0.14
        let foot = plot.minY + plot.height * 0.93
        for stake in [0.18, 0.5, 0.82] {
            let x = plot.minX + plot.width * stake
            stakes.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.36, height: foot - top))
        }
        context.fill(stakes, with: .color(skin.picket))
        context.fill(lit, with: .color(.white.opacity(0.18)))

        var weave = Path()
        for (index, rod) in [0.3, 0.52, 0.74].enumerated() {
            let y = plot.minY + plot.height * CGFloat(rod)
            // Every other rod bows the other way, which is what makes the weave alternate.
            let bow = plot.height * (index.isMultiple(of: 2) ? 0.06 : -0.06)
            weave.move(to: CGPoint(x: plot.minX + plot.width * 0.04, y: y))
            weave.addQuadCurve(
                to: CGPoint(x: plot.midX, y: y),
                control: CGPoint(x: plot.minX + plot.width * 0.27, y: y + bow)
            )
            weave.addQuadCurve(
                to: CGPoint(x: plot.maxX - plot.width * 0.04, y: y),
                control: CGPoint(x: plot.maxX - plot.width * 0.27, y: y - bow)
            )
        }
        context.stroke(
            weave,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: plot.width * 0.09, lineCap: .round)
        )
    }

    /// The mountain's: stakes burnt black, no two of them the same height, with one rail
    /// lashed across and the ground still warm where they went in. There is nothing growing up
    /// here to cut a picket from, so what a fence is made of is what the mountain left.
    private func drawCharredStakes(in context: inout GraphicsContext, plot: CGRect) {
        let width = plot.width * 0.16
        let foot = plot.minY + plot.height * 0.93

        // The heat still in the ground under them, laid down before the timber so the stakes
        // stand in the glow rather than on top of it.
        context.fill(
            Path(ellipseIn: CGRect(
                x: plot.minX + plot.width * 0.1,
                y: foot - plot.height * 0.14,
                width: plot.width * 0.8,
                height: plot.height * 0.24
            )),
            with: .radialGradient(
                Gradient(colors: [skin.grit.opacity(0.4), skin.grit.opacity(0)]),
                center: CGPoint(x: plot.midX, y: foot - plot.height * 0.02),
                startRadius: 0,
                endRadius: plot.width * 0.42
            )
        )

        var stakes = Path()
        var lit = Path()
        var char = Path()
        // No two of them burnt down to the same height, which is what says these were not cut.
        let tops: [CGFloat] = [0.10, 0.24, 0.16]
        for (index, stake) in [0.2, 0.5, 0.8].enumerated() {
            let x = plot.minX + plot.width * CGFloat(stake)
            let top = plot.minY + plot.height * tops[index]
            stakes.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.3, height: foot - top))
            // Burnt off rather than cut: the top of every stake is blacker than the rest of it.
            char.addRect(CGRect(x: x - width / 2, y: top, width: width, height: plot.height * 0.1))
        }
        context.fill(stakes, with: .color(skin.picket))
        context.fill(lit, with: .color(.white.opacity(0.12)))
        context.fill(char, with: .color(.black.opacity(0.45)))

        var rail = Path()
        let y = plot.minY + plot.height * 0.56
        rail.move(to: CGPoint(x: plot.minX + plot.width * 0.06, y: y + plot.height * 0.03))
        rail.addLine(to: CGPoint(x: plot.maxX - plot.width * 0.06, y: y - plot.height * 0.02))
        context.stroke(
            rail,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: plot.width * 0.11, lineCap: .round)
        )
    }

    /// The city's: wrought iron, four bars under a spear head. Nothing here was made out of
    /// what was to hand, so the fencing is the one thing on the board that is exactly straight.
    private func drawRailings(in context: inout GraphicsContext, plot: CGRect) {
        var bars = Path()
        var heads = Path()
        var lit = Path()
        let width = plot.width * 0.08
        let top = plot.minY + plot.height * 0.18
        let foot = plot.minY + plot.height * 0.9
        for bar in [0.17, 0.39, 0.61, 0.83] {
            let x = plot.minX + plot.width * CGFloat(bar)
            bars.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.4, height: foot - top))

            let point = plot.height * 0.12
            heads.move(to: CGPoint(x: x, y: top - point))
            heads.addLine(to: CGPoint(x: x + width * 0.85, y: top - point * 0.35))
            heads.addLine(to: CGPoint(x: x, y: top + point * 0.2))
            heads.addLine(to: CGPoint(x: x - width * 0.85, y: top - point * 0.35))
            heads.closeSubpath()
        }

        var rails = Path()
        for rail in [0.34, 0.82] {
            let y = plot.minY + plot.height * CGFloat(rail)
            rails.move(to: CGPoint(x: plot.minX + plot.width * 0.05, y: y))
            rails.addLine(to: CGPoint(x: plot.maxX - plot.width * 0.05, y: y))
        }
        context.stroke(
            rails,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: plot.width * 0.09, lineCap: .square)
        )
        context.fill(bars, with: .color(skin.picket))
        context.fill(heads, with: .color(skin.picket))
        context.fill(lit, with: .color(.white.opacity(0.22)))
    }

    /// The reaches': two posts with a light strung between them. On ground this pale a timber
    /// fence would hardly show, and out here nothing has to keep a pig in that a line of light
    /// across the dust will not.
    private func drawBeacons(in context: inout GraphicsContext, plot: CGRect) {
        var posts = Path()
        var lit = Path()
        let width = plot.width * 0.12
        let top = plot.minY + plot.height * 0.22
        let foot = plot.minY + plot.height * 0.92
        for post in [0.26, 0.74] {
            let x = plot.minX + plot.width * CGFloat(post)
            posts.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.36, height: foot - top))
        }
        context.fill(posts, with: .color(skin.picket))
        context.fill(lit, with: .color(.white.opacity(0.24)))

        // The line itself, drawn twice: wide and faint for the bloom coming off it, then thin
        // and bright for the light.
        var line = Path()
        line.move(to: CGPoint(x: plot.minX + plot.width * 0.26, y: top))
        line.addQuadCurve(
            to: CGPoint(x: plot.minX + plot.width * 0.74, y: top),
            control: CGPoint(x: plot.midX, y: top + plot.height * 0.16)
        )
        context.stroke(
            line,
            with: .color(skin.rail.opacity(0.35)),
            style: StrokeStyle(lineWidth: plot.width * 0.22, lineCap: .round)
        )
        context.stroke(
            line,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: plot.width * 0.07, lineCap: .round)
        )

        // And a bead burning on the top of each post.
        for post in [0.26, 0.74] {
            let centre = CGPoint(x: plot.minX + plot.width * CGFloat(post), y: top)
            let bead = plot.width * 0.13
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - bead, y: centre.y - bead, width: bead * 2, height: bead * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [skin.rail, skin.rail.opacity(0)]),
                    center: centre,
                    startRadius: 0,
                    endRadius: bead * 2
                )
            )
        }
    }

    /// The caverns': pit props. Two uprights and a lintel, wedged at the corners the way any
    /// gallery is held up — the only fence in the game built to hold something off you rather
    /// than to keep something in.
    private func drawProps(in context: inout GraphicsContext, plot: CGRect) {
        let width = plot.width * 0.19
        let head = plot.minY + plot.height * 0.3
        let foot = plot.minY + plot.height * 0.93

        var lintel = Path()
        lintel.addRect(CGRect(
            x: plot.minX + plot.width * 0.06,
            y: plot.minY + plot.height * 0.14,
            width: plot.width * 0.88,
            height: plot.height * 0.16
        ))
        context.fill(lintel, with: .color(skin.rail))

        var props = Path()
        var lit = Path()
        var wedges = Path()
        for prop in [0.24, 0.76] {
            let x = plot.minX + plot.width * CGFloat(prop)
            props.addRect(CGRect(x: x - width / 2, y: head, width: width, height: foot - head))
            lit.addRect(CGRect(x: x - width / 2, y: head, width: width * 0.32, height: foot - head))

            // The wedge driven in under the lintel, which is what takes the weight.
            let span = plot.width * 0.16
            wedges.move(to: CGPoint(x: x - span, y: head))
            wedges.addLine(to: CGPoint(x: x + span, y: head))
            wedges.addLine(to: CGPoint(x: x, y: head + plot.height * 0.12))
            wedges.closeSubpath()
        }
        context.fill(props, with: .color(skin.picket))
        context.fill(wedges, with: .color(skin.rail))
        context.fill(lit, with: .color(.white.opacity(0.16)))
        context.fill(
            Path(CGRect(
                x: plot.minX + plot.width * 0.06,
                y: plot.minY + plot.height * 0.14,
                width: plot.width * 0.88,
                height: plot.height * 0.05
            )),
            with: .color(.white.opacity(0.16))
        )
    }

    /// The carnival's: two painted poles with a swag of bunting between them. A fairground
    /// fences a thing off to be looked at rather than to be kept, so this is the one fence in
    /// the game with nothing solid across the middle of it — and it holds a pig exactly as
    /// well as any of the others, because the board cannot tell the difference.
    private func drawBunting(in context: inout GraphicsContext, plot: CGRect) {
        var poles = Path()
        var lit = Path()
        let width = plot.width * 0.11
        let top = plot.minY + plot.height * 0.16
        let foot = plot.minY + plot.height * 0.93
        for pole in [0.16, 0.84] {
            let x = plot.minX + plot.width * CGFloat(pole)
            poles.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.34, height: foot - top))
        }
        context.fill(poles, with: .color(skin.picket))

        // The barber's stripe up each pole, which is what makes a pole a fairground pole.
        var stripes = Path()
        for pole in [0.16, 0.84] {
            let x = plot.minX + plot.width * CGFloat(pole)
            for band in [0.28, 0.52, 0.76] {
                let y = plot.minY + plot.height * CGFloat(band)
                stripes.addRect(CGRect(
                    x: x - width / 2, y: y, width: width, height: plot.height * 0.07
                ))
            }
        }
        context.fill(stripes, with: .color(skin.post.opacity(0.75)))
        context.fill(lit, with: .color(.white.opacity(0.2)))

        // The string, hanging between the two poles, and the flags off it.
        let left = CGPoint(x: plot.minX + plot.width * 0.16, y: top + plot.height * 0.06)
        let right = CGPoint(x: plot.minX + plot.width * 0.84, y: top + plot.height * 0.06)
        let sag = plot.height * 0.22
        func hanging(_ along: CGFloat) -> CGPoint {
            CGPoint(
                x: left.x + (right.x - left.x) * along,
                y: left.y + sag * sin(.pi * along)
            )
        }

        var string = Path()
        string.move(to: left)
        for step in 1...12 {
            string.addLine(to: hanging(CGFloat(step) / 12))
        }
        context.stroke(
            string,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: max(1, plot.width * 0.04), lineCap: .round)
        )

        let flags: [Color] = [
            Color(red: 0.98, green: 0.40, blue: 0.48),
            Color(red: 0.46, green: 0.72, blue: 0.96),
            Color(red: 0.62, green: 0.92, blue: 0.66)
        ]
        for (index, along) in [0.22, 0.5, 0.78].enumerated() {
            let hook = hanging(CGFloat(along))
            let span = plot.width * 0.12
            var flag = Path()
            flag.move(to: CGPoint(x: hook.x - span / 2, y: hook.y))
            flag.addLine(to: CGPoint(x: hook.x + span / 2, y: hook.y))
            flag.addLine(to: CGPoint(x: hook.x, y: hook.y + plot.height * 0.22))
            flag.closeSubpath()
            context.fill(flag, with: .color(flags[index % flags.count]))
        }
    }

    /// The desert's: a drift fence. Palings bleached to bone and wired together in a row with
    /// the gaps left in on purpose, since a fence out here is put up to slow the sand rather
    /// than to stop it — and the sand has already drifted up the foot of this one, which is
    /// what happens to everything anybody leaves standing in the dunes.
    private func drawDriftFence(in context: inout GraphicsContext, plot: CGRect) {
        var palings = Path()
        var lit = Path()
        let width = plot.width * 0.09
        let foot = plot.minY + plot.height * 0.9
        let stations: [CGFloat] = [0.14, 0.32, 0.5, 0.68, 0.86]
        for (index, paling) in stations.enumerated() {
            let x = plot.minX + plot.width * paling
            // No two of them the same height: they were cut where they stood and put in by hand.
            let top = plot.minY + plot.height * (index.isMultiple(of: 2) ? 0.15 : 0.21)
            palings.addRect(CGRect(x: x - width / 2, y: top, width: width, height: foot - top))
            lit.addRect(CGRect(x: x - width / 2, y: top, width: width * 0.38, height: foot - top))
        }
        context.fill(palings, with: .color(skin.picket))
        context.fill(lit, with: .color(.white.opacity(0.22)))

        // The two wires holding the row together, which is the whole of the joinery.
        var wires = Path()
        for wire in [0.34, 0.66] {
            let y = plot.minY + plot.height * CGFloat(wire)
            wires.move(to: CGPoint(x: plot.minX + plot.width * 0.08, y: y))
            wires.addLine(to: CGPoint(x: plot.maxX - plot.width * 0.08, y: y))
        }
        context.stroke(
            wires,
            with: .color(skin.rail),
            style: StrokeStyle(lineWidth: max(1, plot.width * 0.045), lineCap: .round)
        )

        // The drift the fence has caught, banked up the near side of it and burying the feet.
        var drift = Path()
        drift.move(to: CGPoint(x: plot.minX, y: foot))
        drift.addQuadCurve(
            to: CGPoint(x: plot.maxX, y: foot - plot.height * 0.06),
            control: CGPoint(x: plot.midX, y: foot - plot.height * 0.24)
        )
        drift.addLine(to: CGPoint(x: plot.maxX, y: plot.maxY))
        drift.addLine(to: CGPoint(x: plot.minX, y: plot.maxY))
        drift.closeSubpath()
        context.fill(drift, with: .color(skin.groundLit))
        context.stroke(
            drift,
            with: .color(.white.opacity(0.24)),
            style: StrokeStyle(lineWidth: max(1, plot.width * 0.03), lineCap: .round)
        )
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

/// The same field in every world there is: one board, one line of fencing, eight grounds. The
/// board underneath is River Bend in all eight, so anything that changes between them is the
/// skin and nothing else — which is the quickest way to see whether a world reads as its own
/// place or only as the meadow tinted a different colour.
#Preview("Eight grounds") {
    let level = PuzzleLevel.riverBend
    let fences = Set((3...9).map { GridPoint(row: $0, column: 0) })
        .union((1...5).map { GridPoint(row: 10, column: $0) })
    let grounds: [FieldSkin] = [
        .meadow, .thornwood, .emberpeak, .cogsworth,
        .starfall, .gloamdeep, .lanternCarnival, .sunbakedDunes
    ]

    return ScrollView {
        VStack(spacing: 18) {
            ForEach(grounds.indices, id: \.self) { index in
                FieldView(
                    level: level,
                    fences: fences,
                    penTiles: [],
                    penGlow: 0,
                    isAsGoodAsItGets: false,
                    animals: .standing(on: level),
                    skin: grounds[index],
                    onStroke: { _ in },
                    onStrokeEnd: {}
                )
            }
        }
        .padding()
    }
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
/// reach them. The two apples left out are left out in the open — no piece may be laid on
/// one, so the wall that passes them has to pass them by.
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
