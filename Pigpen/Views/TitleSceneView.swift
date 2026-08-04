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
        drawLake(in: &context)
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

        for halo in [3.1, 2.2, 1.5] {
            context.fill(
                circle(at: center, radius: radius * CGFloat(halo)),
                with: .color(colors.discHalo.opacity(0.10))
            )
        }
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

    private func drawBirds(in context: inout GraphicsContext) {
        let birds: [(head: Double, height: Double, speed: Double, span: Double)] = [
            (0.18, 0.23, 0.021, 1.0),
            (0.34, 0.18, 0.027, 0.72),
            (0.02, 0.30, 0.016, 0.58)
        ]

        for bird in birds {
            let drift = (bird.head + elapsed * bird.speed).truncatingRemainder(dividingBy: 1.25) - 0.12
            let bob = sin(elapsed * 0.9 + bird.head * 9) * 0.006
            let center = CGPoint(x: x(drift), y: y(bird.height + bob))
            let wing = x(0.024 * bird.span)
            let flap = CGFloat(0.3 + 0.6 * abs(sin(elapsed * 4.4 + bird.head * 8)))

            var path = Path()
            path.move(to: CGPoint(x: center.x - wing, y: center.y))
            path.addQuadCurve(to: center, control: CGPoint(x: center.x - wing * 0.5, y: center.y - wing * flap))
            path.addQuadCurve(
                to: CGPoint(x: center.x + wing, y: center.y),
                control: CGPoint(x: center.x + wing * 0.5, y: center.y - wing * flap)
            )
            context.stroke(
                path,
                with: .color(.black.opacity(0.22)),
                style: StrokeStyle(lineWidth: max(1, wing * 0.16), lineCap: .round)
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

    /// A lake in the valley between the hills, because water is half of the game.
    private func drawLake(in context: inout GraphicsContext) {
        let bounds = CGRect(x: x(0.34), y: y(0.567), width: x(0.24), height: y(0.024))
        context.fill(Path(ellipseIn: bounds), with: .color(colors.lake))

        for band in [0.4, 0.68] {
            var ripple = Path()
            let level = bounds.minY + bounds.height * CGFloat(band)
            ripple.move(to: CGPoint(x: bounds.minX + bounds.width * 0.24, y: level))
            ripple.addQuadCurve(
                to: CGPoint(x: bounds.maxX - bounds.width * 0.24, y: level),
                control: CGPoint(x: bounds.midX, y: level - bounds.height * 0.3)
            )
            context.stroke(
                ripple,
                with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.25 : 0.5)),
                style: StrokeStyle(lineWidth: max(1, bounds.height * 0.1), lineCap: .round)
            )
        }
    }

    private func drawGround(in context: inout GraphicsContext) {
        let line = groundLine(around: ridge, waves: 2.2, phase: 0.7)
        context.fill(band(below: line), with: .color(colors.ground))
        drawTufts(in: &context, along: line, count: 22, height: y(0.016), seed: 17)
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
        context.fill(
            Path(ellipseIn: bounds),
            with: .color(GamePalette.mud.opacity(colors.isNight ? 0.35 : 0.55))
        )

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

    /// Wildflowers in the near field, so the run down to the button is not bare grass.
    private func drawFlowers(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 83)
        let petal = x(0.0075)

        for _ in 0..<11 {
            let center = CGPoint(x: x(0.03 + scatter.next() * 0.94), y: y(0.708 + scatter.next() * 0.038))
            let nod = CGFloat(sin(elapsed * 1.3 + scatter.next() * 6.3)) * petal * 0.25

            var petals = Path()
            for turn in 0..<4 {
                let angle = Double(turn) * .pi / 2
                petals.addEllipse(in: CGRect(
                    x: center.x + nod + petal * CGFloat(cos(angle)) - petal * 0.5,
                    y: center.y + petal * CGFloat(sin(angle)) - petal * 0.5,
                    width: petal,
                    height: petal
                ))
            }
            context.fill(petals, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.35 : 0.85)))
            context.fill(
                circle(at: CGPoint(x: center.x + nod, y: center.y), radius: petal * 0.5),
                with: .color(GamePalette.pen.opacity(colors.isNight ? 0.4 : 0.95))
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
    private func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) }

    private func circle(at center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }
}

/// A tiny deterministic generator, so the scattered parts of the scene — stars, grass,
/// fireflies — land in the same places on every frame and every launch.
private struct Scatter {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed &* 2_862_933_555_777_941_757 &+ 3_037_000_493
    }

    /// The next value in 0..<1.
    mutating func next() -> Double {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Double((state >> 33) % 10_000) / 10_000
    }
}

#Preview {
    TitleSceneView()
        .ignoresSafeArea()
}
