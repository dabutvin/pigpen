import Foundation
import SwiftUI

/// The pasture behind the title: a sky with weather in it, rolling ground, a run of fence,
/// and a pig trotting up and down in front of it.
///
/// Every moving part is a function of how long the scene has been on screen rather than a
/// piece of animation state, so nothing can fall out of step — and when the system asks for
/// reduced motion the clock simply stops at zero and the pasture becomes a still painting.
struct TitleSceneView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var opened = Date()

    var body: some View {
        let colors: GamePalette.Pasture = colorScheme == .dark ? .dusk : .day

        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            let elapsed = reduceMotion ? 0 : timeline.date.timeIntervalSince(opened)

            Canvas { context, size in
                TitleScene(size: size, elapsed: elapsed, colors: colors).draw(in: &context)
            }
        }
        .accessibilityHidden(true)
    }
}

/// One frame of the pasture, ready to draw. Everything is placed as a fraction of the space
/// the scene was handed, so it composes itself on any screen.
private struct TitleScene {
    let size: CGSize
    let elapsed: TimeInterval
    let colors: GamePalette.Pasture

    /// The pig covers this stretch of the width, out and back, once every `lapDuration`.
    private let trot = (from: 0.14, to: 0.86)
    private let lapDuration: TimeInterval = 11
    /// One hop of the trot, and how far off the ground it takes the pig.
    private let hopDuration: TimeInterval = 0.62
    private let hopHeight = 0.028

    /// The whole pasture is drawn a shade higher than the space would put it, so the fence
    /// and the pig trotting along it sit in the open band between the wordmark and the menu
    /// rather than behind them. It scales every vertical measure — bands, clouds, birds and
    /// motes alike — by the same amount, so the scene lifts without any part of it coming
    /// loose from another, and the ground still runs off the bottom of the screen.
    private let rise: CGFloat = 0.82

    // The bands of the scene, top to bottom.
    private var horizon: CGFloat { y(0.56) }
    private var ridge: CGFloat { y(0.62) }
    private var fenceBase: CGFloat { y(0.665) }
    private var pigFeet: CGFloat { y(0.695) }
    private var foregroundEdge: CGFloat { y(0.86) }

    func draw(in context: inout GraphicsContext) {
        drawSky(in: &context)
        if colors.isNight {
            drawStars(in: &context)
        } else {
            drawBirds(in: &context)
        }
        drawDisc(in: &context)
        drawClouds(in: &context)
        drawFarHills(in: &context)
        drawGrove(in: &context)
        drawGround(in: &context)
        drawPath(in: &context)
        drawFlowers(in: &context)
        drawFence(in: &context)
        drawPig(in: &context)
        drawForeground(in: &context)
        drawMotes(in: &context)
    }

    // MARK: - Sky

    private func drawSky(in context: inout GraphicsContext) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [colors.skyTop, colors.skyHorizon]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: horizon)
            )
        )
    }

    /// Stars thin out towards the horizon, where the last of the light still is.
    private func drawStars(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 11)
        for _ in 0..<56 {
            let center = CGPoint(x: x(scatter.next()), y: y(scatter.next() * 0.52))
            let radius = CGFloat(0.7 + scatter.next() * 1.2)
            let twinkle = 0.5 + 0.5 * sin(elapsed * 1.6 + scatter.next() * 6.3)
            let height = Double(center.y / max(horizon, 1))
            context.fill(
                circle(at: center, radius: radius),
                with: .color(.white.opacity((0.25 + 0.5 * twinkle) * (1 - height * 0.7)))
            )
        }
    }

    /// The sun and the clouds keep to the band of sky below the wordmark, where they have
    /// the place to themselves.
    private func drawDisc(in context: inout GraphicsContext) {
        let center = CGPoint(x: x(0.80), y: y(0.375))
        let radius = x(0.072) * CGFloat(1 + 0.04 * sin(elapsed * 0.8))

        let glow = radius * 3.4
        context.fill(
            circle(at: center, radius: glow),
            with: .radialGradient(
                Gradient(colors: [
                    colors.discHalo.opacity(colors.isNight ? 0.45 : 0.35),
                    colors.discHalo.opacity(0)
                ]),
                center: center,
                startRadius: radius * 0.7,
                endRadius: glow
            )
        )
        context.fill(circle(at: center, radius: radius), with: .color(colors.disc))

        guard colors.isNight else { return }
        for crater in [CGPoint(x: -0.32, y: -0.18), CGPoint(x: 0.22, y: 0.3), CGPoint(x: 0.06, y: -0.5)] {
            context.fill(
                circle(
                    at: CGPoint(x: center.x + radius * crater.x, y: center.y + radius * crater.y),
                    radius: radius * 0.17
                ),
                with: .color(colors.discHalo.opacity(0.5))
            )
        }
    }

    /// Three clouds crossing at their own speeds, each reappearing on the left once it has
    /// drifted clear of the right edge.
    private func drawClouds(in context: inout GraphicsContext) {
        let clouds: [(head: Double, height: Double, width: Double, speed: Double)] = [
            (0.05, 0.335, 0.34, 0.011),
            (0.46, 0.425, 0.24, 0.018),
            (0.74, 0.475, 0.28, 0.007)
        ]

        for cloud in clouds {
            let drift = (cloud.head + elapsed * cloud.speed).truncatingRemainder(dividingBy: 1.3) - 0.15
            context.fill(
                cloudPath(
                    at: CGPoint(x: x(drift), y: y(cloud.height)),
                    width: x(cloud.width)
                ),
                with: .color(colors.cloud.opacity(colors.isNight ? 0.7 : 0.92))
            )
        }
    }

    private func cloudPath(at center: CGPoint, width: CGFloat) -> Path {
        let height = width * 0.42
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - width * 0.50, y: center.y - height * 0.26,
            width: width * 0.54, height: height * 0.60
        ))
        path.addEllipse(in: CGRect(
            x: center.x - width * 0.20, y: center.y - height * 0.56,
            width: width * 0.60, height: height * 0.92
        ))
        path.addEllipse(in: CGRect(
            x: center.x + width * 0.12, y: center.y - height * 0.20,
            width: width * 0.42, height: height * 0.54
        ))
        path.addRoundedRect(
            in: CGRect(x: center.x - width * 0.48, y: center.y, width: width * 0.94, height: height * 0.32),
            cornerSize: CGSize(width: height * 0.16, height: height * 0.16)
        )
        return path
    }

    /// Three birds keeping loose company, crossing the same band of sky as the clouds.
    private func drawBirds(in context: inout GraphicsContext) {
        let flock: [(lead: Double, height: Double, span: Double)] = [
            (0.00, 0.315, 0.030),
            (0.08, 0.288, 0.024),
            (0.14, 0.345, 0.021)
        ]
        let drift = (0.06 + elapsed * 0.016).truncatingRemainder(dividingBy: 1.4) - 0.2

        for bird in flock {
            let bob = sin(elapsed * 0.9 + bird.lead * 18) * 0.004
            let center = CGPoint(x: x(drift + bird.lead), y: y(bird.height + bob))
            let wing = x(bird.span)
            let flap = CGFloat(0.3 + 0.55 * abs(sin(elapsed * 4.0 + bird.lead * 16)))

            var path = Path()
            path.move(to: CGPoint(x: center.x - wing, y: center.y))
            path.addQuadCurve(to: center, control: CGPoint(x: center.x - wing * 0.5, y: center.y - wing * flap))
            path.addQuadCurve(
                to: CGPoint(x: center.x + wing, y: center.y),
                control: CGPoint(x: center.x + wing * 0.5, y: center.y - wing * flap)
            )
            context.stroke(
                path,
                with: .color(.black.opacity(0.25)),
                style: StrokeStyle(lineWidth: max(1.5, wing * 0.15), lineCap: .round)
            )
        }
    }

    // MARK: - Land

    private func drawFarHills(in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: horizon))
        path.addQuadCurve(
            to: CGPoint(x: x(0.44), y: horizon),
            control: CGPoint(x: x(0.20), y: horizon - y(0.075))
        )
        path.addQuadCurve(
            to: CGPoint(x: size.width, y: horizon),
            control: CGPoint(x: x(0.76), y: horizon - y(0.105))
        )
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        context.fill(path, with: .color(colors.farHill))
    }

    /// A line of trees rooted in the hillside, small enough to read as distance. They stand
    /// on the near field's edge, so the grass along it comes up over their feet — and after
    /// dark they go to silhouette, since a tree the colour of the hill behind it is no tree.
    private func drawGrove(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 53)
        let edge = groundEdge
        let leaf = colors.isNight ? colors.canopyShade : colors.canopy
        let count = 6

        for index in 0..<count {
            let across = x((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count))
            let spread = x(0.062) * CGFloat(0.7 + scatter.next() * 0.5)
            let foot = CGPoint(x: across, y: edge(across) + spread * 0.2)

            context.fill(
                Path(roundedRect: CGRect(
                    x: foot.x - spread * 0.10, y: foot.y - spread * 0.62,
                    width: spread * 0.20, height: spread * 0.62
                ), cornerRadius: spread * 0.06),
                with: .color(GamePalette.rail.opacity(colors.isNight ? 0.5 : 0.9))
            )

            var canopy = Path()
            for lobe in [(-0.34, 0.86, 0.66), (0.0, 1.12, 0.84), (0.34, 0.84, 0.62)] {
                canopy.addEllipse(in: CGRect(
                    x: foot.x + spread * CGFloat(lobe.0) - spread * CGFloat(lobe.2) / 2,
                    y: foot.y - spread * CGFloat(lobe.1),
                    width: spread * CGFloat(lobe.2),
                    height: spread * CGFloat(lobe.2)
                ))
            }
            context.fill(canopy, with: .color(leaf))
            context.fill(
                circle(
                    at: CGPoint(x: foot.x - spread * 0.22, y: foot.y - spread * 0.86),
                    radius: spread * 0.18
                ),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.06 : 0.20))
            )
        }
    }

    private func drawGround(in context: inout GraphicsContext) {
        context.fill(band(below: groundEdge), with: .color(colors.ground))
        drawTufts(in: &context, along: groundEdge, count: 22, height: y(0.016), seed: 17)
    }

    /// The top of the near field, which is also the line the grove is rooted along.
    private var groundEdge: (CGFloat) -> CGFloat {
        groundLine(around: ridge, waves: 2.2, phase: 0.7)
    }

    /// The near bank, dark enough to sit the button and the small print on.
    private func drawForeground(in context: inout GraphicsContext) {
        let line = groundLine(around: foregroundEdge, waves: 1.4, phase: 2.1)
        context.fill(band(below: line), with: .color(colors.foreground))
        drawTufts(in: &context, along: line, count: 16, height: y(0.026), seed: 41)
    }

    /// A gentle rise and fall across the width, so no edge in the pasture is a straight line.
    private func groundLine(around baseline: CGFloat, waves: Double, phase: Double) -> (CGFloat) -> CGFloat {
        let amplitude = y(0.011)
        let width = max(size.width, 1)
        return { across in
            baseline + CGFloat(sin(Double(across / width) * waves * .pi + phase)) * amplitude
        }
    }

    /// Everything from a wavy top edge down to the bottom of the scene.
    private func band(below topEdge: (CGFloat) -> CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: topEdge(0)))
        var across: CGFloat = 0
        while across < size.width {
            path.addLine(to: CGPoint(x: across, y: topEdge(across)))
            across += 8
        }
        path.addLine(to: CGPoint(x: size.width, y: topEdge(size.width)))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        return path
    }

    /// Grass along an edge, leaning in the same breeze that pushes the clouds along.
    private func drawTufts(
        in context: inout GraphicsContext,
        along topEdge: (CGFloat) -> CGFloat,
        count: Int,
        height: CGFloat,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        var blades = Path()

        for index in 0..<count {
            let across = x((Double(index) + 0.2 + scatter.next() * 0.6) / Double(count))
            let base = CGPoint(x: across, y: topEdge(across) + height * 0.15)
            let sway = CGFloat(sin(elapsed * 1.2 + Double(index) * 0.8)) * height * 0.3

            for lean in [-0.55, 0.0, 0.55] {
                let tall = height * CGFloat(0.7 + scatter.next() * 0.5)
                let tip = CGPoint(x: base.x + tall * CGFloat(lean) + sway, y: base.y - tall)
                blades.move(to: base)
                blades.addQuadCurve(to: tip, control: CGPoint(x: base.x + sway * 0.4, y: base.y - tall * 0.7))
            }
        }

        context.stroke(
            blades,
            with: .color(colors.blade),
            style: StrokeStyle(lineWidth: max(1, height * 0.14), lineCap: .round)
        )
    }

    /// The grass along the fence, walked back to bare mud — the same mud the board is made of.
    private func drawPath(in context: inout GraphicsContext) {
        let bounds = CGRect(
            x: x(trot.from - 0.08),
            y: pigFeet - y(0.011),
            width: x(trot.to - trot.from + 0.16),
            height: y(0.024)
        )
        let worn = GamePalette.mud.opacity(colors.isNight ? 0.3 : 0.45)

        // Overlapping lobes filled as one shape, so the trail has a trodden edge rather
        // than the outline of an ellipse.
        var trail = Path()
        for lobe in [
            (along: 0.5, width: 1.0, height: 1.0, rise: 0.0),
            (along: 0.22, width: 0.46, height: 0.78, rise: -0.22),
            (along: 0.76, width: 0.38, height: 0.70, rise: 0.24)
        ] {
            let width = bounds.width * CGFloat(lobe.width)
            let height = bounds.height * CGFloat(lobe.height)
            trail.addEllipse(in: CGRect(
                x: bounds.minX + bounds.width * CGFloat(lobe.along) - width / 2,
                y: bounds.midY + bounds.height * CGFloat(lobe.rise) - height / 2,
                width: width,
                height: height
            ))
        }
        context.fill(trail, with: .color(worn))

        var scatter = Scatter(seed: 61)
        for _ in 0..<14 {
            let stone = x(0.004) * CGFloat(0.6 + scatter.next())
            let center = CGPoint(
                x: bounds.minX + bounds.width * CGFloat(0.06 + scatter.next() * 0.88),
                y: bounds.midY + bounds.height * CGFloat(scatter.next() - 0.5) * 0.6
            )
            context.fill(
                circle(at: center, radius: stone),
                with: .color(GamePalette.mudSpeckle.opacity(0.3))
            )
        }
    }

    /// Wildflowers in the near field, spaced along it so the run down to the button is
    /// neither bare grass nor a clump.
    private func drawFlowers(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 83)
        let count = 12
        let petal = x(0.010)

        for index in 0..<count {
            let center = CGPoint(
                x: x((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)),
                y: y(0.706 + scatter.next() * 0.042)
            )
            let nod = CGFloat(sin(elapsed * 1.3 + Double(index) * 1.1)) * petal * 0.3

            var petals = Path()
            for turn in 0..<5 {
                let angle = Double(turn) * 2 * .pi / 5
                petals.addEllipse(in: CGRect(
                    x: center.x + nod + petal * 0.6 * CGFloat(cos(angle)) - petal * 0.55,
                    y: center.y + petal * 0.6 * CGFloat(sin(angle)) - petal * 0.55,
                    width: petal * 1.1,
                    height: petal * 1.1
                ))
            }
            context.fill(petals, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.4 : 0.9)))
            context.fill(
                circle(at: CGPoint(x: center.x + nod, y: center.y), radius: petal * 0.42),
                with: .color(GamePalette.pen.opacity(colors.isNight ? 0.45 : 0.95))
            )
        }
    }

    // MARK: - Fence and pig

    private func drawFence(in context: inout GraphicsContext) {
        let posts = 7
        let inset = x(0.06)
        let span = size.width - inset * 2
        let height = y(0.055)
        let width = x(0.023)

        var rails = Path()
        for rail in [0.78, 0.36] {
            let level = fenceBase - height * CGFloat(rail)
            rails.move(to: CGPoint(x: inset - x(0.04), y: level))
            rails.addLine(to: CGPoint(x: size.width - inset + x(0.04), y: level))
        }
        context.stroke(
            rails,
            with: .color(GamePalette.rail),
            style: StrokeStyle(lineWidth: height * 0.15, lineCap: .round)
        )

        for index in 0..<posts {
            let center = inset + span * CGFloat(index) / CGFloat(posts - 1)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center - width, y: fenceBase - height * 0.06,
                    width: width * 2, height: height * 0.14
                )),
                with: .color(.black.opacity(0.18))
            )
            let post = CGRect(x: center - width / 2, y: fenceBase - height, width: width, height: height)
            context.fill(
                Path(roundedRect: post, cornerRadius: width * 0.35),
                with: .color(GamePalette.post)
            )
            // A sliver of light down one side, so the posts still read at dusk.
            context.fill(
                Path(roundedRect: CGRect(
                    x: post.minX, y: post.minY,
                    width: width * 0.33, height: post.height
                ), cornerRadius: width * 0.2),
                with: .color(GamePalette.rail.opacity(0.85))
            )
        }
    }

    private func drawPig(in context: inout GraphicsContext) {
        let hop = abs(sin(.pi * elapsed / hopDuration))
        let across = trotPosition(at: elapsed)
        let pig = x(0.125)
        let lift = y(hopHeight * hop)
        // Squashed flat on landing, drawn out long at the top of the hop.
        let squash = CGFloat(1 - 0.13 * (1 - hop))
        let stretch = CGFloat(1 + 0.10 * (1 - hop))
        let lean = trotDirection(at: elapsed) * 7 * hop

        drawDust(in: &context)

        context.fill(
            Path(ellipseIn: CGRect(
                x: across - pig * 0.34 * (1 - CGFloat(hop) * 0.3),
                y: pigFeet - pig * 0.07,
                width: pig * 0.68 * (1 - CGFloat(hop) * 0.3),
                height: pig * 0.16
            )),
            with: .color(.black.opacity(0.22 * (1 - hop * 0.5)))
        )

        var pigContext = context
        pigContext.translateBy(x: across, y: pigFeet - lift - pig * 0.5)
        pigContext.rotate(by: .degrees(lean))
        pigContext.scaleBy(x: stretch, y: squash)
        pigContext.draw(Text(verbatim: "🐷").font(.system(size: pig)), at: .zero, anchor: .center)
    }

    /// Puffs of dust kicked up where the pig last came down.
    private func drawDust(in context: inout GraphicsContext) {
        let landing = (elapsed / hopDuration).rounded(.down) * hopDuration
        let life = 0.45

        for step in 0..<2 {
            let touchdown = landing - Double(step) * hopDuration
            let age = elapsed - touchdown
            guard touchdown > 0, age < life else { continue }

            let fade = 1 - age / life
            let across = trotPosition(at: touchdown)
            let spread = x(0.02) * CGFloat(1 + (1 - fade) * 1.6)
            let radius = x(0.014) * CGFloat(0.6 + (1 - fade) * 0.9)

            for side in [-1.0, 1.0] {
                context.fill(
                    circle(
                        at: CGPoint(x: across + spread * CGFloat(side), y: pigFeet - radius * 0.4),
                        radius: radius
                    ),
                    with: .color(GamePalette.cream.opacity(0.3 * fade))
                )
            }
        }
    }

    /// Where along the fence the pig is, easing to a stop at each end before turning back.
    private func trotPosition(at time: TimeInterval) -> CGFloat {
        let lap = (time / lapDuration).truncatingRemainder(dividingBy: 1)
        let sweep = (1 - cos(lap * 2 * .pi)) / 2
        return x(trot.from + (trot.to - trot.from) * sweep)
    }

    /// Which way the pig is heading, as a lean of the whole body.
    private func trotDirection(at time: TimeInterval) -> Double {
        let lap = (time / lapDuration).truncatingRemainder(dividingBy: 1)
        return sin(lap * 2 * .pi) >= 0 ? 1 : -1
    }

    // MARK: - Specks of light

    /// Pollen in the sunshine, fireflies over the grass after dark.
    private func drawMotes(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 29)
        let tint = colors.isNight ? GamePalette.pen : Color.white
        let top = colors.isNight ? 0.58 : 0.30

        for _ in 0..<11 {
            let phase = scatter.next() * 6.3
            let center = CGPoint(
                x: x(scatter.next() + 0.04 * sin(elapsed * 0.32 + phase)),
                y: y(top + scatter.next() * 0.26 + 0.02 * sin(elapsed * 0.5 + phase * 2))
            )
            let radius = x(0.005) * CGFloat(0.7 + scatter.next() * 0.8)
            let glow = 0.35 + 0.65 * (0.5 + 0.5 * sin(elapsed * 1.4 + phase))

            if colors.isNight {
                context.fill(circle(at: center, radius: radius * 3), with: .color(tint.opacity(0.16 * glow)))
            }
            context.fill(circle(at: center, radius: radius), with: .color(tint.opacity(0.7 * glow)))
        }
    }

    // MARK: - Small helpers

    private func x(_ fraction: Double) -> CGFloat { size.width * CGFloat(fraction) }
    private func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) * rise }

    private func circle(at center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }
}

#Preview {
    TitleSceneView()
        .ignoresSafeArea()
}
