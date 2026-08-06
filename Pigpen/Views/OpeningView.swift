import Foundation
import SwiftUI
import UIKit

/// The film that plays before a player's first walk up the meadow.
///
/// Five shots between black bars, with a line of type over each and a way out of the whole
/// thing in the corner. `Opening` says what is on screen at any moment; this paints it and
/// hands the player on to the map when the last frame has gone.
@MainActor
struct OpeningView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Called when the film is over, however it ended: watched to the last frame, or skipped.
    private let onFinish: () -> Void
    /// One moment of the film held still instead of the film played, for the previews and
    /// the screenshot runs. The clock is stopped there rather than started, so the same
    /// frame comes out every time — and a still hands nobody on to anywhere.
    private let still: TimeInterval?

    @State private var opening = Opening()
    /// The way out, kept off the first frame or two so the film opens on the meadow rather
    /// than on a button.
    @State private var offersSkip = false

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        self.still = nil
    }

    /// A still of the film `seconds` in.
    init(still seconds: TimeInterval) {
        self.onFinish = {}
        self.still = seconds
    }

    var body: some View {
        GeometryReader { proxy in
            // The bars, the type and the way out are all set as a fraction of the screen
            // for the same reason the shots are: an opening that composes itself on one
            // phone should do it on the small one and on a tablet as well.
            let bar = proxy.size.height * 0.072

            ZStack {
                // Under everything, so a shot that does not reach a corner leaves black
                // there rather than whatever the screen had on it before.
                Color.black

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: still != nil)) { timeline in
                    let elapsed = still ?? timeline.date.timeIntervalSince(opening.start)

                    ZStack {
                        if let frame = opening.frame(secondsIn: elapsed) {
                            Canvas { context, size in
                                Film(size: size, frame: frame, moves: !reduceMotion).draw(in: &context)
                            }
                            .accessibilityHidden(true)

                            bars(landed: opening.letterbox(secondsIn: elapsed), depth: bar)
                            caption(frame, clear: bar)
                        }

                        // Over the picture and the type alike: the film comes up out of
                        // black and goes back into it, bars and all.
                        Color.black
                            .opacity(opening.curtain(secondsIn: elapsed))
                            .allowsHitTesting(false)
                    }
                }

                skip(under: bar)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .task {
            // A still is a still: nothing counts down and nobody is handed on.
            guard still == nil else { return }
            if await opening.waitOut() {
                onFinish()
            }
        }
        .task {
            // Waited out rather than animated in on a delay, so the button cannot be
            // pressed in the beat before it can be seen.
            guard still == nil else { return }
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeIn(duration: 0.35)) { offersSkip = true }
        }
    }

    /// Whether the way out is on screen, and so whether it can be pressed.
    private var offersTheWayOut: Bool { still != nil || offersSkip }

    // MARK: - Over the picture

    /// The black bars a film is shown between, sliding in as it opens. They are what says
    /// "watch this" without a word of instruction.
    private func bars(landed: Double, depth: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black)
                .frame(height: depth)
                .offset(y: -depth * (1 - landed))

            Spacer(minLength: 0)

            Rectangle()
                .fill(Color.black)
                .frame(height: depth)
                .offset(y: depth * (1 - landed))
        }
        .allowsHitTesting(false)
    }

    /// The line over the shot. It is real type rather than something painted into the
    /// canvas, so a player listening to the screen instead of watching it still gets the
    /// story read out to them.
    @ViewBuilder
    private func caption(_ frame: Opening.Frame, clear bar: CGFloat) -> some View {
        let words = Text(frame.shot.caption)
            .multilineTextAlignment(.center)
            .foregroundStyle(GamePalette.cream)
            .shadow(color: .black.opacity(0.7), radius: 5, y: 2)
            .padding(.horizontal, 32)
            .opacity(frame.captionOpacity)

        if frame.shot.picture == .fenceItIn {
            // The last line is the one the game is being handed over on, so it is set in
            // the middle of the frame as a card rather than tucked along the bottom.
            words.font(.system(size: 34, weight: .black, design: .rounded))
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                words.font(.system(size: 18, weight: .heavy, design: .rounded))
            }
            // Clear of the bottom bar rather than on it.
            .padding(.bottom, bar + 26)
        }
    }

    /// A way out, for the player who has seen it or does not want it. It says *Skip* rather
    /// than being a tap anywhere on the screen: an opening worth watching should not be
    /// lost to a thumb resting on the glass.
    private func skip(under bar: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onFinish()
                } label: {
                    HStack(spacing: 5) {
                        Text("Skip")
                        Image(systemName: "forward.fill")
                    }
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Capsule().fill(GamePalette.cream.opacity(0.94)))
                    .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
                }
                .accessibilityLabel("Skip the opening")
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        // Below the top bar, so it sits on the picture rather than in the letterbox.
        .padding(.top, bar + 16)
        .opacity(offersTheWayOut ? 1 : 0)
        .allowsHitTesting(offersTheWayOut)
    }
}

/// One frame of the film, ready to draw.
///
/// Everything is placed as a fraction of the space the screen was handed, so the same shot
/// composes itself on any phone — and every shot is built out of the same handful of pieces
/// (a sky, a ridge, a band of grass, tufts along its edge) so that five different views of
/// the meadow still look like the same meadow.
private struct Film {
    let size: CGSize
    let frame: Opening.Frame
    /// Whether the camera moves and the lines streak. A player who has asked for less
    /// motion still gets all five shots and every caption; the shots are simply held still.
    let moves: Bool

    /// The film is shot at sunrise whatever the phone is set to — see `Pasture.daybreak`.
    private let colors = GamePalette.Pasture.daybreak

    /// How far through the shot the camera is. Held at the middle of its move when the
    /// player has asked for less motion, so a still shot is still a composed one.
    private var progress: Double { moves ? frame.progress : 0.5 }

    func draw(in context: inout GraphicsContext) {
        switch frame.shot.picture {
        case .firstLight: drawFirstLight(in: &context)
        case .theOpenGate: drawTheOpenGate(in: &context)
        case .thePig: drawThePig(in: &context)
        case .away: drawAway(in: &context)
        case .fenceItIn: drawFenceItIn(in: &context)
        }
        drawCutFlash(in: &context)
    }

    // MARK: - The shots

    /// The meadow, wide: the sun just clear of the far hills, mist lying in the folds, and
    /// the trail every level of the game is strung along running away into it. The camera
    /// pushes in slowly, which is what tells a player this is a film and not a menu.
    private func drawFirstLight(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.60))
        drawSun(
            in: &shot,
            at: CGPoint(x: x(0.31), y: y(0.60) - y(0.04 * progress)),
            radius: x(0.082),
            rays: false
        )
        drawClouds(in: &shot, at: 0.30, drift: 0.02 * progress)
        drawBirds(in: &shot, at: 0.22)

        drawLand(in: &shot, ridge: 0.60, rise: 0.075, waves: 2.2, phase: 0.7, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.69, rise: 0.05, waves: 1.6, phase: 2.4, color: colors.canopy)
        drawMist(in: &shot, at: 0.655, seed: 19)
        drawLand(in: &shot, ridge: 0.78, rise: 0.028, waves: 1.4, phase: 1.1, color: colors.ground)
        drawTrail(in: &shot, from: 1.02, to: 0.785)
        drawTufts(in: &shot, along: 0.78, rise: 0.028, waves: 1.4, phase: 1.1, count: 22, height: 0.019, seed: 23)
        drawLand(in: &shot, ridge: 0.91, rise: 0.018, waves: 1.1, phase: 3.0, color: colors.foreground)
        drawTufts(in: &shot, along: 0.91, rise: 0.018, waves: 1.1, phase: 3.0, count: 15, height: 0.03, seed: 31)
    }

    /// The barn, and the gate. The fence runs the width of the frame with one panel stood
    /// open on it, and the pig is already through the gap — small, and not looking back.
    /// The camera drifts right, following it out.
    private func drawTheOpenGate(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08, drift: -0.02 + 0.045 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawSun(in: &shot, at: CGPoint(x: x(0.78), y: y(0.50)), radius: x(0.07), rays: false)
        drawClouds(in: &shot, at: 0.26, drift: 0.01 * progress)

        drawLand(in: &shot, ridge: 0.58, rise: 0.06, waves: 1.8, phase: 1.9, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.72, rise: 0.03, waves: 1.3, phase: 0.5, color: colors.ground)

        drawBarn(in: &shot, at: 0.20, base: 0.72, width: 0.30)
        drawFenceRun(in: &shot, base: 0.80, height: 0.075, from: 0.30, to: 1.06, posts: 7, gap: 3)

        // Through the gap and going: it clears the gateway over the shot rather than
        // standing in it, so the picture is a pig leaving rather than a pig posing.
        drawPig(
            in: &shot,
            feet: CGPoint(x: x(0.63 + 0.14 * progress), y: y(0.845)),
            width: x(0.115),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, count: 14, height: 0.032, seed: 47)
    }

    /// The pig, head on and filling the frame, with the light coming apart behind it: the
    /// shot the whole film exists for. Anime sells a character on one held frame like this
    /// — spokes of light, the ground dropped to a line, and nothing else in the picture
    /// worth looking at. The camera snaps in and settles rather than easing, so the cut to
    /// it lands.
    private func drawThePig(in context: inout GraphicsContext) {
        let landed = easeOut(min(progress / 0.3, 1))
        var shot = pushed(context, zoom: 1.16 - 0.13 * landed)

        drawSky(in: &shot, horizon: y(0.70))

        // Right behind the pig rather than above it: the disc itself barely shows, and the
        // spokes come out from behind the thing the shot is of.
        let middle = CGPoint(x: x(0.5), y: y(0.60))
        drawSun(in: &shot, at: middle, radius: x(0.13), rays: true)

        // A hill behind it, which is what stops the spokes of light running down into the
        // ground and keeps the frame reading as the same meadow as the shots either side.
        drawLand(in: &shot, ridge: 0.74, rise: 0.03, waves: 1.7, phase: 2.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.80, rise: 0.02, waves: 1.5, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.80, rise: 0.02, waves: 1.5, phase: 0.9, count: 18, height: 0.026, seed: 53)

        // Breathing rather than hopping: it is standing still and being looked at.
        let breath = sin(progress * 2 * .pi * 1.5)
        drawPig(
            in: &shot,
            feet: CGPoint(x: middle.x, y: y(0.815) - y(0.006 * breath)),
            width: x(0.44),
            squash: 1 + 0.02 * breath
        )
    }

    /// Gone. The pig is already at the far side of the frame, the meadow is streaking past
    /// behind it, and the dust it kicked up is still hanging where it left.
    private func drawAway(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06, drift: 0.025 * progress)

        drawSky(in: &shot, horizon: y(0.56))
        drawSun(in: &shot, at: CGPoint(x: x(0.86), y: y(0.44)), radius: x(0.075), rays: false)
        drawLand(in: &shot, ridge: 0.56, rise: 0.055, waves: 2.0, phase: 2.8, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.74, rise: 0.025, waves: 1.4, phase: 1.6, color: colors.ground)

        drawStreaks(in: &shot, band: 0.36...0.70, count: 16, seed: 67)

        let across = x(0.24 + 0.52 * progress)
        drawDust(in: &shot, behind: across, at: 0.845)
        drawPig(
            in: &shot,
            feet: CGPoint(x: across, y: y(0.845) - y(0.014 * hop(cycles: 4))),
            width: x(0.135),
            lean: 12,
            squash: 1 - 0.07 * hop(cycles: 4),
            shadow: 0.6
        )
        drawStreaks(in: &shot, band: 0.76...0.93, count: 9, seed: 71)

        drawLand(in: &shot, ridge: 0.95, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The meadow again, calm, with a run of fencing stood along the front of it and the
    /// pig small and loose on the hill beyond: what the player has, and what it is for. The
    /// camera pulls back off the fencing, which hands the frame over to the line of type
    /// that lands in the middle of it.
    private func drawFenceItIn(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.56))
        drawSun(in: &shot, at: CGPoint(x: x(0.68), y: y(0.36)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.24, drift: 0.015 * progress)

        drawLand(in: &shot, ridge: 0.56, rise: 0.07, waves: 2.1, phase: 1.2, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.67, rise: 0.045, waves: 1.5, phase: 2.9, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.76, rise: 0.026, waves: 1.3, phase: 0.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.76, rise: 0.026, waves: 1.3, phase: 0.8, count: 20, height: 0.018, seed: 79)

        // Away up the hill, and no bigger than a signpost on the map: the thing all that
        // fencing along the front of the frame is for.
        drawPig(in: &shot, feet: CGPoint(x: x(0.30), y: y(0.735)), width: x(0.055), shadow: 0.5)

        // Stood clear of the bottom bar, so the fencing the player is being handed is all
        // of it in the picture rather than half of it behind the letterbox.
        drawFenceRun(in: &shot, base: 0.90, height: 0.13, from: -0.06, to: 1.06, posts: 9, gap: nil)
    }

    // MARK: - Sky

    /// The sky, painted well outside the frame so a camera move never finds an edge of it.
    private func drawSky(in context: inout GraphicsContext, horizon: CGFloat) {
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
    private func drawSun(
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
    private func drawRays(in context: inout GraphicsContext, from centre: CGPoint) {
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
    private func drawClouds(in context: inout GraphicsContext, at height: Double, drift: Double) {
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

    private func cloudPath(at centre: CGPoint, width: CGFloat) -> Path {
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
    private func drawBirds(in context: inout GraphicsContext, at height: Double) {
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
    private func drawLand(
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
    private func ridgeLine(
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
    private func band(below topEdge: (CGFloat) -> CGFloat) -> Path {
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
    private func drawTufts(
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
    private func drawMist(in context: inout GraphicsContext, at height: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<5 {
            let width = x(0.32 + scatter.next() * 0.46)
            let centre = CGPoint(
                x: x(scatter.next() * 1.2 - 0.1),
                y: y(height + (scatter.next() - 0.5) * 0.05)
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - width / 2, y: centre.y - y(0.013),
                    width: width, height: y(0.026)
                )),
                with: .color(GamePalette.cream.opacity(0.22))
            )
        }
    }

    /// The trail every level of the game is strung along, seen from the ground: wide at the
    /// player's feet and narrowing away into the hills.
    private func drawTrail(in context: inout GraphicsContext, from bottom: Double, to top: Double) {
        let foot = y(bottom)
        let head = y(top)
        let depth = foot - head

        var path = Path()
        path.move(to: CGPoint(x: x(0.32), y: foot))
        path.addCurve(
            to: CGPoint(x: x(0.505), y: head),
            control1: CGPoint(x: x(0.38), y: foot - depth * 0.45),
            control2: CGPoint(x: x(0.60), y: head + depth * 0.40)
        )
        path.addLine(to: CGPoint(x: x(0.545), y: head))
        path.addCurve(
            to: CGPoint(x: x(0.60), y: foot),
            control1: CGPoint(x: x(0.65), y: head + depth * 0.40),
            control2: CGPoint(x: x(0.54), y: foot - depth * 0.45)
        )
        path.closeSubpath()

        context.fill(path, with: .color(GamePalette.mud.opacity(0.5)))
    }

    // MARK: - What is standing in the meadow

    /// The barn at the bottom of the world map, seen from the field: a red shed with its
    /// roof pitched dark and its door standing open, which is the other half of the story
    /// the gate is telling.
    private func drawBarn(in context: inout GraphicsContext, at across: Double, base: Double, width: Double) {
        let span = x(width)
        let foot = y(base)
        let wall = span * 0.62
        let body = CGRect(x: x(across) - span / 2, y: foot - wall, width: span, height: wall)

        // Roof first, so the wall is what laps over it rather than the other way round.
        var roof = Path()
        roof.move(to: CGPoint(x: body.minX - span * 0.09, y: body.minY + span * 0.02))
        roof.addLine(to: CGPoint(x: body.midX, y: body.minY - span * 0.30))
        roof.addLine(to: CGPoint(x: body.maxX + span * 0.09, y: body.minY + span * 0.02))
        roof.closeSubpath()
        context.fill(roof, with: .color(GamePalette.post))

        context.fill(Path(body), with: .color(GamePalette.barn))
        // The lit side, so it sits in the same sunrise as everything else.
        context.fill(
            Path(CGRect(x: body.minX, y: body.minY, width: span * 0.22, height: wall)),
            with: .color(.white.opacity(0.16))
        )

        let door = CGRect(
            x: body.midX - span * 0.15, y: foot - wall * 0.66,
            width: span * 0.30, height: wall * 0.66
        )
        context.fill(
            Path(roundedRect: door, cornerRadius: span * 0.03),
            with: .color(GamePalette.post.opacity(0.85))
        )
        // One board line across the wall, which is all it takes to read as timber.
        var course = Path()
        course.move(to: CGPoint(x: body.minX, y: body.minY + wall * 0.42))
        course.addLine(to: CGPoint(x: body.maxX, y: body.minY + wall * 0.42))
        context.stroke(
            course,
            with: .color(GamePalette.cream.opacity(0.2)),
            lineWidth: max(1, span * 0.012)
        )
    }

    /// A run of fence, head on: posts with two rails across them, and `gap` left out of it
    /// where a gate should be. The same fencing a board is built out of, stood up in grass.
    private func drawFenceRun(
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

        // The gate itself, swung out of the gap and standing open in front of the fence.
        guard let gap else { return }
        let hinge = CGPoint(x: start + pitch * CGFloat(gap), y: foot)
        var gate = context
        gate.translateBy(x: hinge.x, y: hinge.y)
        gate.rotate(by: .degrees(-24))

        var panel = Path()
        let leaf = CGSize(width: pitch * 0.86, height: tall * 0.82)
        panel.addRoundedRect(
            in: CGRect(x: 0, y: -leaf.height, width: leaf.width, height: leaf.height * 0.16),
            cornerSize: CGSize(width: leaf.height * 0.06, height: leaf.height * 0.06)
        )
        panel.addRoundedRect(
            in: CGRect(x: 0, y: -leaf.height * 0.46, width: leaf.width, height: leaf.height * 0.16),
            cornerSize: CGSize(width: leaf.height * 0.06, height: leaf.height * 0.06)
        )
        panel.addRoundedRect(
            in: CGRect(x: 0, y: -leaf.height, width: leaf.width * 0.16, height: leaf.height),
            cornerSize: CGSize(width: leaf.height * 0.05, height: leaf.height * 0.05)
        )
        panel.addRoundedRect(
            in: CGRect(x: leaf.width * 0.84, y: -leaf.height, width: leaf.width * 0.16, height: leaf.height),
            cornerSize: CGSize(width: leaf.height * 0.05, height: leaf.height * 0.05)
        )
        gate.fill(panel, with: .color(GamePalette.rail))
    }

    /// The pig, drawn the way every other screen in the game draws it. A character a player
    /// is about to spend nine puzzles chasing has to be the same character here as there.
    private func drawPig(
        in context: inout GraphicsContext,
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
        pigContext.draw(Text(verbatim: "🐷").font(.system(size: pig)), at: .zero, anchor: .center)
    }

    /// Puffs of dust hanging where the pig last pushed off.
    private func drawDust(in context: inout GraphicsContext, behind across: CGFloat, at base: Double) {
        let foot = y(base)

        for step in 1...3 {
            let age = Double(step) / 3
            let back = x(0.055) * CGFloat(step)
            let radius = x(0.016) * CGFloat(1 + age * 1.4)
            context.fill(
                circle(
                    at: CGPoint(x: across - back, y: foot - radius * 0.5 - y(0.01 * age)),
                    radius: radius
                ),
                with: .color(GamePalette.cream.opacity(0.34 * (1 - age)))
            )
        }
    }

    // MARK: - Motion

    /// The streaks a shot gets when the thing in it is going faster than the camera. Drawn
    /// rather than blurred: a line is what anime uses, and it costs nothing.
    private func drawStreaks(
        in context: inout GraphicsContext,
        band: ClosedRange<Double>,
        count: Int,
        seed: UInt64
    ) {
        guard moves else { return }

        var scatter = Scatter(seed: seed)
        var lines = Path()

        for _ in 0..<count {
            let level = y(scatter.next(in: band))
            let span = x(0.14 + scatter.next() * 0.3)
            // Every streak runs the width of the frame twice over the shot, so the picture
            // never settles into a fixed set of lines.
            let travel = (scatter.next() + progress * 2).truncatingRemainder(dividingBy: 1.4) - 0.2
            let head = x(travel)
            lines.move(to: CGPoint(x: head, y: level))
            lines.addLine(to: CGPoint(x: head + span, y: level))
        }

        context.stroke(
            lines,
            with: .color(GamePalette.cream.opacity(0.3)),
            style: StrokeStyle(lineWidth: max(1, y(0.0035)), lineCap: .round)
        )
    }

    /// The lick of light on a cut, which is what makes a new shot read as a cut rather than
    /// as one picture quietly replacing another.
    private func drawCutFlash(in context: inout GraphicsContext) {
        guard moves, frame.flash > 0 else { return }

        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(.white.opacity(0.3 * frame.flash))
        )
    }

    /// Where in a bounce something is, given how many bounces the shot holds. 0 on the
    /// ground, 1 at the top.
    private func hop(cycles: Double) -> Double {
        guard moves else { return 0 }
        return abs(sin(progress * .pi * cycles))
    }

    private func easeOut(_ amount: Double) -> Double {
        1 - pow(1 - amount, 3)
    }

    // MARK: - Small helpers

    private func x(_ fraction: Double) -> CGFloat { size.width * CGFloat(fraction) }
    private func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) }

    private func circle(at centre: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: centre.x - radius, y: centre.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }

    /// The camera: a push in on the middle of the frame, and a drift across it. Both are
    /// held inside what the drawing covers, so no move ever finds an edge of the meadow.
    private func pushed(_ context: GraphicsContext, zoom: Double, drift: Double = 0) -> GraphicsContext {
        guard moves else { return context }

        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        var moved = context
        moved.translateBy(x: centre.x + x(drift), y: centre.y)
        moved.scaleBy(x: CGFloat(zoom), y: CGFloat(zoom))
        moved.translateBy(x: -centre.x, y: -centre.y)
        return moved
    }
}

#Preview("First light") {
    OpeningView(still: 1.4)
}

#Preview("The open gate") {
    OpeningView(still: 4.0)
}

#Preview("The pig") {
    OpeningView(still: 7.0)
}

#Preview("Away") {
    OpeningView(still: 9.6)
}

#Preview("Fence it in") {
    OpeningView(still: 12.0)
}

#Preview("Played through") {
    OpeningView {}
}
