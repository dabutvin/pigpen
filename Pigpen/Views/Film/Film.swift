import Foundation
import SwiftUI
import UIKit

/// One frame of a film, ready to draw.
///
/// Everything is placed as a fraction of the space the screen was handed, so the same shot
/// composes itself on any phone — and every shot is built out of the same handful of pieces
/// (a sky, a ridge, a band of grass, tufts along its edge) so that a dozen different views
/// of the meadow still look like the same meadow.
struct Film {
    let size: CGSize
    let frame: CutScene.Frame
    /// Whether the camera moves and the lines streak. A player who has asked for less
    /// motion still gets every shot and every caption; the shots are simply held still.
    let moves: Bool

    /// What light this shot is in, which is the shot's own business rather than the phone's.
    /// Each world answers for its own shots, beside the painting of them.
    var colors: GamePalette.Pasture {
        switch frame.shot.picture {
        case .meadow(let shot): Self.meadowLight(shot)
        case .thornwood(let shot): Self.thornwoodLight(shot)
        case .emberpeak(let shot): Self.emberpeakLight(shot)
        case .cogsworth(let shot): Self.cogsworthLight(shot)
        case .starfall(let shot): Self.starfallLight(shot)
        case .gloamdeep(let shot): Self.gloamdeepLight(shot)
        case .lantern(let shot): Self.lanternLight(shot)
        case .dunes(let shot): Self.dunesLight(shot)
        case .tidepool(let shot): Self.tidepoolLight(shot)
        case .frostwhisker(let shot): Self.frostwhiskerLight(shot)
        case .mirebog(let shot): Self.mirebogLight(shot)
        case .cloudspire(let shot): Self.cloudspireLight(shot)
        }
    }

    var progress: Double { moves ? frame.progress : 0.5 }

    /// Paints whichever shot is up, and the lick of light on the cut into it. Each world
    /// paints its own, in its own file; this only says whose turn it is.
    func draw(in context: inout GraphicsContext) {
        switch frame.shot.picture {
        case .meadow(let shot): drawMeadow(shot, in: &context)
        case .thornwood(let shot): drawThornwood(shot, in: &context)
        case .emberpeak(let shot): drawEmberpeak(shot, in: &context)
        case .cogsworth(let shot): drawCogsworth(shot, in: &context)
        case .starfall(let shot): drawStarfall(shot, in: &context)
        case .gloamdeep(let shot): drawGloamdeep(shot, in: &context)
        case .lantern(let shot): drawLantern(shot, in: &context)
        case .dunes(let shot): drawDunes(shot, in: &context)
        case .tidepool(let shot): drawTidepool(shot, in: &context)
        case .frostwhisker(let shot): drawFrostwhisker(shot, in: &context)
        case .mirebog(let shot): drawMirebog(shot, in: &context)
        case .cloudspire(let shot): drawCloudspire(shot, in: &context)
        }
        drawCutFlash(in: &context)
    }

    // MARK: - Things standing on the ground

    func drawTreat(
        in context: inout GraphicsContext,
        _ glyph: String,
        at feet: CGPoint,
        width: CGFloat
    ) {
        context.fill(
            Path(ellipseIn: CGRect(
                x: feet.x - width * 0.34, y: feet.y - width * 0.04,
                width: width * 0.68, height: width * 0.14
            )),
            with: .color(.black.opacity(0.22))
        )
        context.draw(
            Text(verbatim: glyph).font(.system(size: width)),
            at: CGPoint(x: feet.x, y: feet.y - width * 0.5),
            anchor: .center
        )
    }

    func drawForest(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        seed: UInt64,
        color: Color
    ) {
        let foot = y(base)
        let start = x(from)
        let end = x(to)
        var scatter = Scatter(seed: seed)

        // Back rank first and lighter, then the front rank darker over it.
        for rank in [1.0, 0.0] {
            let lift = y(height) * CGFloat(rank) * 0.18
            let step = x(0.055)
            var crowns = Path()
            var across = start - step * CGFloat(rank) * 0.5
            while across < end {
                let tall = y(height) * CGFloat(0.55 + scatter.next() * 0.7) * CGFloat(1 - 0.18 * rank)
                let wide = x(0.05) * CGFloat(0.8 + scatter.next() * 0.6)
                let tip = CGPoint(x: across, y: foot - lift - tall)
                crowns.move(to: CGPoint(x: tip.x - wide, y: foot - lift))
                crowns.addQuadCurve(to: tip, control: CGPoint(x: tip.x - wide * 0.45, y: foot - lift - tall * 0.45))
                crowns.addQuadCurve(
                    to: CGPoint(x: tip.x + wide, y: foot - lift),
                    control: CGPoint(x: tip.x + wide * 0.45, y: foot - lift - tall * 0.45)
                )
                crowns.closeSubpath()
                across += step
            }
            context.fill(
                crowns,
                with: .color(color.opacity(rank > 0 ? 0.55 : 0.92))
            )
        }
    }

    // MARK: - Sky

    /// The sky, painted well outside the frame so a camera move never finds an edge of it.
    func drawSky(in context: inout GraphicsContext, horizon: CGFloat) {
        context.fill(
            Path(CGRect(
                x: -size.width, y: -size.height,
                width: size.width * 3, height: size.height * 3
            )),
            with: .linearGradient(
                Gradient(colors: [colors.skyTop, colors.skyHorizon]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: horizon)
            )
        )
    }

    /// The sun, with the haze round it that a sun this low always has. `rays` puts the
    /// spokes of light behind it that an anime sunrise is not a sunrise without.
    func drawSun(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        radius: CGFloat,
        rays: Bool
    ) {
        let glow = radius * 4.4
        context.fill(
            circle(at: centre, radius: glow),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.6), colors.discHalo.opacity(0)]),
                center: centre,
                startRadius: radius * 0.5,
                endRadius: glow
            )
        )

        if rays {
            drawRays(in: &context, from: centre)
        }

        context.fill(circle(at: centre, radius: radius), with: .color(colors.disc))
    }

    /// Spokes of light turning slowly behind whatever the shot is about.
    func drawRays(in context: inout GraphicsContext, from centre: CGPoint) {
        let spokes = 16
        let reach = max(size.width, size.height) * 2
        let turn = progress * 0.4
        let width = (2 * .pi / Double(spokes)) * 0.32

        var wedges = Path()
        for spoke in 0..<spokes {
            let angle = Double(spoke) * 2 * .pi / Double(spokes) + turn
            wedges.move(to: centre)
            wedges.addLine(to: CGPoint(
                x: centre.x + reach * CGFloat(cos(angle - width)),
                y: centre.y + reach * CGFloat(sin(angle - width))
            ))
            wedges.addLine(to: CGPoint(
                x: centre.x + reach * CGFloat(cos(angle + width)),
                y: centre.y + reach * CGFloat(sin(angle + width))
            ))
            wedges.closeSubpath()
        }
        context.fill(wedges, with: .color(colors.discHalo.opacity(0.28)))
    }

    /// Three clouds, lit underneath the way clouds are at this hour.
    func drawClouds(in context: inout GraphicsContext, at height: Double, drift: Double) {
        let clouds: [(across: Double, height: Double, width: Double)] = [
            (0.14, 0.00, 0.32),
            (0.58, 0.06, 0.24),
            (0.86, -0.04, 0.28)
        ]

        for cloud in clouds {
            context.fill(
                cloudPath(
                    at: CGPoint(x: x(cloud.across + drift), y: y(height + cloud.height)),
                    width: x(cloud.width)
                ),
                with: .color(colors.cloud.opacity(0.85))
            )
        }
    }

    func cloudPath(at centre: CGPoint, width: CGFloat) -> Path {
        let height = width * 0.4
        var path = Path()
        path.addEllipse(in: CGRect(
            x: centre.x - width * 0.50, y: centre.y - height * 0.24,
            width: width * 0.52, height: height * 0.58
        ))
        path.addEllipse(in: CGRect(
            x: centre.x - width * 0.20, y: centre.y - height * 0.54,
            width: width * 0.58, height: height * 0.90
        ))
        path.addEllipse(in: CGRect(
            x: centre.x + width * 0.10, y: centre.y - height * 0.20,
            width: width * 0.42, height: height * 0.54
        ))
        path.addRoundedRect(
            in: CGRect(
                x: centre.x - width * 0.48, y: centre.y,
                width: width * 0.94, height: height * 0.30
            ),
            cornerSize: CGSize(width: height * 0.15, height: height * 0.15)
        )
        return path
    }

    /// A few birds up where there is nothing else, which is how a still sky reads as air.
    func drawBirds(in context: inout GraphicsContext, at height: Double) {
        let flock: [(across: Double, height: Double, span: Double)] = [
            (0.62, 0.00, 0.028),
            (0.70, -0.03, 0.022),
            (0.76, 0.02, 0.019)
        ]

        var wings = Path()
        for bird in flock {
            let centre = CGPoint(x: x(bird.across), y: y(height + bird.height))
            let span = x(bird.span)
            wings.move(to: CGPoint(x: centre.x - span, y: centre.y))
            wings.addQuadCurve(
                to: centre,
                control: CGPoint(x: centre.x - span * 0.5, y: centre.y - span * 0.5)
            )
            wings.addQuadCurve(
                to: CGPoint(x: centre.x + span, y: centre.y),
                control: CGPoint(x: centre.x + span * 0.5, y: centre.y - span * 0.5)
            )
        }
        context.stroke(
            wings,
            with: .color(GamePalette.post.opacity(0.4)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.004)), lineCap: .round)
        )
    }

    // MARK: - Land

    /// A band of land: a gently waving top edge filled all the way down past the bottom of
    /// the frame. Every horizon in the film is one of these.
    func drawLand(
        in context: inout GraphicsContext,
        ridge: Double,
        rise: Double,
        waves: Double,
        phase: Double,
        color: Color
    ) {
        context.fill(
            band(below: ridgeLine(at: ridge, rise: rise, waves: waves, phase: phase)),
            with: .color(color)
        )
    }

    /// A rise and fall across the width, so no horizon in the film is ruled straight.
    func ridgeLine(
        at baseline: Double,
        rise: Double,
        waves: Double,
        phase: Double
    ) -> (CGFloat) -> CGFloat {
        let level = y(baseline)
        let amplitude = y(rise)
        let width = max(size.width, 1)
        return { across in
            level - CGFloat(sin(Double(across / width) * waves * .pi + phase)) * amplitude
        }
    }

    /// Everything from a wavy top edge down past the bottom of the frame, and out either
    /// side of it, so a camera move cannot find the end of the ground.
    func band(below topEdge: (CGFloat) -> CGFloat) -> Path {
        var path = Path()
        let start = -size.width
        let end = size.width * 2

        path.move(to: CGPoint(x: start, y: topEdge(start)))
        var across = start
        while across < end {
            path.addLine(to: CGPoint(x: across, y: topEdge(across)))
            across += 8
        }
        path.addLine(to: CGPoint(x: end, y: topEdge(end)))
        path.addLine(to: CGPoint(x: end, y: size.height * 2))
        path.addLine(to: CGPoint(x: start, y: size.height * 2))
        path.closeSubpath()
        return path
    }

    /// Grass along the edge of a band, leaning as though there were a breeze off the hills.
    func drawTufts(
        in context: inout GraphicsContext,
        along baseline: Double,
        rise: Double,
        waves: Double,
        phase: Double,
        count: Int,
        height: Double,
        seed: UInt64
    ) {
        let edge = ridgeLine(at: baseline, rise: rise, waves: waves, phase: phase)
        let tall = y(height)
        var scatter = Scatter(seed: seed)
        var blades = Path()

        for index in 0..<count {
            let across = x((Double(index) + 0.2 + scatter.next() * 0.6) / Double(count))
            let foot = CGPoint(x: across, y: edge(across) + tall * 0.15)

            for lean in [-0.5, 0.0, 0.5] {
                let blade = tall * CGFloat(0.7 + scatter.next() * 0.5)
                blades.move(to: foot)
                blades.addQuadCurve(
                    to: CGPoint(x: foot.x + blade * CGFloat(lean), y: foot.y - blade),
                    control: CGPoint(x: foot.x, y: foot.y - blade * 0.7)
                )
            }
        }

        context.stroke(
            blades,
            with: .color(colors.blade),
            style: StrokeStyle(lineWidth: max(1, tall * 0.14), lineCap: .round)
        )
    }

    /// Mist lying in the folds of the meadow, which is what a field looks like at this hour
    /// and what puts the far hills behind the near ones.
    func drawMist(in context: inout GraphicsContext, at height: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        // Several flat, faint banks rather than a few fat bright ones: overlapping them is
        // what makes a band of haze, where any one of them on its own is a pale blob with
        // an edge you can see.
        for _ in 0..<9 {
            let width = x(0.34 + scatter.next() * 0.5)
            let centre = CGPoint(
                x: x(scatter.next() * 1.3 - 0.15),
                y: y(height + (scatter.next() - 0.5) * 0.055)
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - width / 2, y: centre.y - y(0.008),
                    width: width, height: y(0.016)
                )),
                with: .color(GamePalette.cream.opacity(0.13))
            )
        }
    }

    /// The trail every level of the game is strung along, seen from the ground: wide at the
    /// player's feet and narrowing away into the hills.
    func drawTrail(in context: inout GraphicsContext, from bottom: Double, to top: Double) {
        let foot = y(bottom)
        let head = y(top)
        let depth = foot - head

        // Wide at the foot of the frame: the near bank is drawn over the bottom of it, so a
        // trail any narrower than this is a thread by the time any of it can be seen.
        var path = Path()
        path.move(to: CGPoint(x: x(0.22), y: foot))
        path.addCurve(
            to: CGPoint(x: x(0.495), y: head),
            control1: CGPoint(x: x(0.32), y: foot - depth * 0.45),
            control2: CGPoint(x: x(0.60), y: head + depth * 0.40)
        )
        path.addLine(to: CGPoint(x: x(0.55), y: head))
        path.addCurve(
            to: CGPoint(x: x(0.70), y: foot),
            control1: CGPoint(x: x(0.70), y: head + depth * 0.40),
            control2: CGPoint(x: x(0.60), y: foot - depth * 0.45)
        )
        path.closeSubpath()

        context.fill(path, with: .color(GamePalette.mud.opacity(0.55)))
    }

    // MARK: - Fencing, and what it is put round

    func drawFenceRun(
        in context: inout GraphicsContext,
        base: Double,
        height: Double,
        from: Double,
        to: Double,
        posts: Int,
        gap: Int?
    ) {
        let foot = y(base)
        let tall = y(height)
        let start = x(from)
        let pitch = (x(to) - start) / CGFloat(max(posts - 1, 1))
        let width = pitch * 0.16

        var rails = Path()
        for rail in [0.72, 0.34] {
            let level = foot - tall * CGFloat(rail)
            for span in 0..<max(posts - 1, 0) {
                // Both lengths either side of a missing post come out along with it, which
                // is what makes the hole read as a gateway rather than as a post somebody
                // has pulled up.
                if let gap, span == gap || span == gap - 1 { continue }
                rails.move(to: CGPoint(x: start + pitch * CGFloat(span), y: level))
                rails.addLine(to: CGPoint(x: start + pitch * CGFloat(span + 1), y: level))
            }
        }
        context.stroke(
            rails,
            with: .color(GamePalette.rail),
            style: StrokeStyle(lineWidth: tall * 0.13, lineCap: .round)
        )

        for post in 0..<posts where post != gap {
            let centre = start + pitch * CGFloat(post)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre - width, y: foot - tall * 0.05,
                    width: width * 2, height: tall * 0.12
                )),
                with: .color(.black.opacity(0.18))
            )
            let timber = CGRect(x: centre - width / 2, y: foot - tall, width: width, height: tall)
            context.fill(
                Path(roundedRect: timber, cornerRadius: width * 0.35),
                with: .color(GamePalette.post)
            )
            context.fill(
                Path(roundedRect: CGRect(
                    x: timber.minX, y: timber.minY,
                    width: width * 0.34, height: tall
                ), cornerRadius: width * 0.2),
                with: .color(GamePalette.picket.opacity(0.9))
            )
        }

        // The gate itself, hung on the post to the left of the gap and swung up and out of
        // it. Tilting it is how a gate reads as open in a picture drawn side on, where
        // there is no room to swing it towards anybody.
        guard let gap else { return }
        let hinge = CGPoint(x: start + pitch * CGFloat(max(gap - 1, 0)), y: foot)
        var gate = context
        gate.translateBy(x: hinge.x, y: hinge.y)
        gate.rotate(by: .degrees(-24))

        // Wide enough to have bars in it: a leaf the width of one post is a card with a
        // hole in it however the timber is cut. It is still short of the gap it came out
        // of, so the way through stays a way through.
        let leaf = CGSize(width: pitch * 1.35, height: tall * 0.8)
        let timber = leaf.height * 0.13

        var panel = Path()
        for bar in [0.0, 0.87] {
            panel.addRoundedRect(
                in: CGRect(
                    x: 0, y: -leaf.height + leaf.height * CGFloat(bar),
                    width: leaf.width, height: timber
                ),
                cornerSize: CGSize(width: timber * 0.4, height: timber * 0.4)
            )
        }
        for stile in [0.0, 0.94] {
            panel.addRoundedRect(
                in: CGRect(
                    x: leaf.width * CGFloat(stile), y: -leaf.height,
                    width: leaf.width * 0.06, height: leaf.height
                ),
                cornerSize: CGSize(width: timber * 0.4, height: timber * 0.4)
            )
        }
        gate.fill(panel, with: .color(GamePalette.rail))

        // The diagonal, which is the thing that makes a farm gate a farm gate.
        var brace = Path()
        brace.move(to: CGPoint(x: timber, y: -timber * 1.4))
        brace.addLine(to: CGPoint(x: leaf.width - timber, y: -leaf.height + timber * 1.4))
        gate.stroke(
            brace,
            with: .color(GamePalette.rail),
            style: StrokeStyle(lineWidth: timber, lineCap: .round)
        )
    }

    /// An animal, drawn the way every other screen in the game draws it. A character a
    /// player is about to spend nine puzzles chasing has to be the same character here as
    /// it is on the board.
    func drawAnimal(
        in context: inout GraphicsContext,
        _ animal: Animal,
        feet: CGPoint,
        width pig: CGFloat,
        lean: Double = 0,
        squash: Double = 1,
        shadow: Double = 1
    ) {
        context.fill(
            Path(ellipseIn: CGRect(
                x: feet.x - pig * 0.34, y: feet.y - pig * 0.06,
                width: pig * 0.68, height: pig * 0.15
            )),
            with: .color(.black.opacity(0.24 * shadow))
        )

        var pigContext = context
        pigContext.translateBy(x: feet.x, y: feet.y - pig * 0.5)
        pigContext.rotate(by: .degrees(lean))
        pigContext.scaleBy(x: 1 / CGFloat(squash), y: CGFloat(squash))
        pigContext.draw(
            Text(verbatim: animal.glyph).font(.system(size: pig)),
            at: .zero,
            anchor: .center
        )
    }

    /// The ground a pen would take in round an animal standing at `feet`.
    func penBounds(round feet: CGPoint, width: Double, height: Double, drop: Double) -> CGRect {
        CGRect(
            x: feet.x - x(width) / 2,
            y: feet.y + y(drop) - y(height),
            width: x(width),
            height: y(height)
        )
    }

    func penRect(round feet: CGPoint, width: Double, height: Double, drop: Double) -> Path {
        Path(
            roundedRect: penBounds(round: feet, width: width, height: height, drop: drop),
            cornerRadius: x(0.025),
            style: .continuous
        )
    }

    /// The pen an animal is going to need, marked out round it in dashes: a plan rather
    /// than a fence, which is the whole point of the shot it appears in.
    ///
    /// `opacity` is for a plan being dropped in favour of a better one. Left alone it is the
    /// 0.9 every ghost pen in the game is drawn at — dashes that read as chalk on the grass
    /// rather than as a line somebody has already built.
    func drawGhostPen(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double,
        opacity: Double = 0.9
    ) {
        guard opacity > 0 else { return }

        context.stroke(
            penRect(round: feet, width: width, height: height, drop: drop),
            with: .color(GamePalette.cream.opacity(opacity)),
            style: StrokeStyle(
                lineWidth: max(2, x(0.009)),
                lineCap: .round,
                dash: [x(0.028), x(0.022)]
            )
        )
    }

    /// The ground inside a pen that holds, washed the same gold the board washes it.
    func drawPenWash(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double
    ) {
        context.fill(
            penRect(round: feet, width: width, height: height, drop: drop),
            with: .color(GamePalette.pen.opacity(0.8))
        )
    }

    /// The fencing round a pen that holds: posts in the ground with a rail between them.
    ///
    /// Drawn as actual posts rather than as a line round the edge. A stroked rectangle at
    /// any weight reads as the frame round a picture — it is the posts standing up out of
    /// the grass at intervals that say fence, and nothing else does.
    func drawPenFence(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double
    ) {
        let pen = penBounds(round: feet, width: width, height: height, drop: drop)

        var rails = Path()
        rails.addRect(pen)
        context.stroke(
            rails,
            with: .color(GamePalette.rail),
            lineWidth: max(1.5, x(0.005))
        )

        // A post every so often along the run, standing up out of the line rather than
        // sitting on it, with the near ones taller than the far ones.
        var posts = Path()
        let across = 7
        let down = 3
        let timber = max(2, x(0.009))

        func post(at foot: CGPoint, tall: CGFloat) {
            posts.addRoundedRect(
                in: CGRect(x: foot.x - timber / 2, y: foot.y - tall, width: timber, height: tall),
                cornerSize: CGSize(width: timber * 0.4, height: timber * 0.4)
            )
        }

        for step in 0...across {
            let along = pen.minX + pen.width * CGFloat(step) / CGFloat(across)
            post(at: CGPoint(x: along, y: pen.minY), tall: y(0.014))
            post(at: CGPoint(x: along, y: pen.maxY), tall: y(0.022))
        }
        for step in 1..<down {
            let along = pen.minY + pen.height * CGFloat(step) / CGFloat(down)
            let tall = y(0.014) + y(0.008) * CGFloat(step) / CGFloat(down)
            post(at: CGPoint(x: pen.minX, y: along), tall: tall)
            post(at: CGPoint(x: pen.maxX, y: along), tall: tall)
        }
        context.fill(posts, with: .color(GamePalette.post))
    }

    // MARK: - Motion

    /// The lick of light on a cut, which is what makes a new shot read as a cut rather than
    /// as one picture quietly replacing another.
    func drawCutFlash(in context: inout GraphicsContext) {
        guard moves, frame.flash > 0 else { return }

        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(.white.opacity(0.3 * frame.flash))
        )
    }

    /// Where in a bounce something is, given how many bounces the shot holds. 0 on the
    /// ground, 1 at the top.
    func hop(cycles: Double) -> Double {
        guard moves else { return 0 }
        return abs(sin(progress * .pi * cycles))
    }

    func easeOut(_ amount: Double) -> Double {
        1 - pow(1 - amount, 3)
    }

    // MARK: - Small helpers

    func x(_ fraction: Double) -> CGFloat { size.width * CGFloat(fraction) }
    func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) }

    func circle(at centre: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: centre.x - radius, y: centre.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }

    /// The camera: a push in on the middle of the frame, and a drift across it. Both are
    /// held inside what the drawing covers, so no move ever finds an edge of the meadow.
    func pushed(_ context: GraphicsContext, zoom: Double, drift: Double = 0) -> GraphicsContext {
        guard moves else { return context }

        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        var moved = context
        moved.translateBy(x: centre.x + x(drift), y: centre.y)
        moved.scaleBy(x: CGFloat(zoom), y: CGFloat(zoom))
        moved.translateBy(x: -centre.x, y: -centre.y)
        return moved
    }
}

