import Foundation
import SwiftUI
import UIKit

/// How deep the black bars a film is shown between are, as a fraction of the screen's height.
///
/// Shared by both kinds of film and by anything laid over one, so the Skip in the corner of a
/// painted film, the Skip in the corner of a storybook one and the billing on a reel of them all
/// sit at the same height on the glass.
enum FilmBars {
    static let fraction: CGFloat = 0.072
}

/// Any of the game's films, played between black bars with a line of type over each shot
/// and a way out of the whole thing in the corner.
///
/// `CutScene` says what is on screen at any moment; this paints it and hands the player on
/// when the last frame has gone.
@MainActor
struct CutSceneView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Called when the film is over, however it ended: watched to the last frame, or skipped.
    private let onFinish: () -> Void
    /// One moment of the film held still instead of the film played, for the previews and
    /// the screenshot runs. The clock is stopped there rather than started, so the same
    /// frame comes out every time — and a still hands nobody on to anywhere.
    private let still: TimeInterval?
    /// Whether this playing of the film is one the charts should hear about. A film met where
    /// the game plays it is; the same film leafed through in the projection room behind the
    /// gear is not, since a player rattling down a reel of three dozen skips most of them by
    /// definition and would drown out the one question the counting is here to answer.
    private let counted: Bool

    /// Held rather than taken fresh each time the screen is drawn, so the clock starts when
    /// the film goes up and not again on every frame of it.
    @State private var scene: CutScene
    /// The way out, kept off the first frame or two so a film opens on its picture rather
    /// than on a button.
    @State private var offersSkip = false

    init(_ scene: CutScene, counted: Bool = true, onFinish: @escaping () -> Void) {
        _scene = State(initialValue: scene)
        self.onFinish = onFinish
        self.still = nil
        self.counted = counted
    }

    /// A still of a film `seconds` in.
    init(_ scene: CutScene, still seconds: TimeInterval) {
        _scene = State(initialValue: scene)
        self.onFinish = {}
        self.still = seconds
        self.counted = false
    }

    var body: some View {
        GeometryReader { proxy in
            // The bars, the type and the way out are all set as a fraction of the screen
            // for the same reason the shots are: an opening that composes itself on one
            // phone should do it on the small one and on a tablet as well.
            let bar = proxy.size.height * FilmBars.fraction

            ZStack {
                // Under everything, so a shot that does not reach a corner leaves black
                // there rather than whatever the screen had on it before.
                Color.black

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: still != nil)) { timeline in
                    let elapsed = still ?? timeline.date.timeIntervalSince(scene.start)

                    ZStack {
                        if let frame = scene.frame(secondsIn: elapsed) {
                            Canvas { context, size in
                                Film(size: size, frame: frame, moves: !reduceMotion).draw(in: &context)
                            }
                            .accessibilityHidden(true)

                            bars(landed: scene.letterbox(secondsIn: elapsed), depth: bar)
                            caption(frame, clear: bar)
                        }

                        // Over the picture and the type alike: the film comes up out of
                        // black and goes back into it, bars and all.
                        Color.black
                            .opacity(scene.curtain(secondsIn: elapsed))
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
            if await scene.waitOut() {
                finish(watched: true)
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

    /// The one way out, however it was reached. Counting happens here rather than in
    /// `onFinish` because this is the only place that knows which of the two it was — and
    /// that is the whole question about a film. One everybody skips is one that should be
    /// shorter, and a film nobody skips is worth the money it cost to draw.
    private func finish(watched: Bool) {
        if counted {
            Analytics.record(.filmPlayed(scene.name.rawValue, watched: watched))
        }
        onFinish()
    }

    /// The shots whose line is the point of the whole film rather than a note under the
    /// picture, and so is set big and in the middle.
    private static let cards: Set<CutScene.Picture> = [.closeTheFence, .intoTheForest]

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
    private func caption(_ frame: CutScene.Frame, clear bar: CGFloat) -> some View {
        // The line is read out a sentence at a time under the held picture, so what is shown is
        // whichever sentence is up now, at however far up it is.
        let line = frame.caption
        let words = Text(line.sentence)
            .multilineTextAlignment(.center)
            .foregroundStyle(GamePalette.cream)
            .shadow(color: .black.opacity(0.7), radius: 5, y: 2)
            .padding(.horizontal, 32)
            .opacity(line.opacity)

        if Self.cards.contains(frame.shot.picture) {
            // The line a film hands the game over on is set in the middle of the frame as
            // a card rather than tucked along the bottom like a subtitle.
            words.font(.system(size: max(26, bar * 0.52), weight: .black, design: .rounded))
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                words.font(.system(size: max(16, bar * 0.30), weight: .heavy, design: .rounded))
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
                    Haptics.tap(.light)
                    finish(watched: false)
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
                .accessibilityLabel("Skip")
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

/// One frame of a film, ready to draw.
///
/// Everything is placed as a fraction of the space the screen was handed, so the same shot
/// composes itself on any phone — and every shot is built out of the same handful of pieces
/// (a sky, a ridge, a band of grass, tufts along its edge) so that a dozen different views
/// of the meadow still look like the same meadow.
private struct Film {
    let size: CGSize
    let frame: CutScene.Frame
    /// Whether the camera moves and the lines streak. A player who has asked for less
    /// motion still gets every shot and every caption; the shots are simply held still.
    let moves: Bool

    /// What light a shot is in, which is the shot's own business rather than the phone's.
    ///
    /// The opening is at sunrise and the meadow's last film opens in the same gold, so the
    /// property is always shown at its best. Stag Mere is lit flat and bright in between,
    /// because a briefing wants reading rather than admiring, and the two shots that turn
    /// toward the forest at the end fall into dusk, because the next listing is a dark one.
    private var colors: GamePalette.Pasture {
        switch frame.shot.picture {
        case .promisingLand, .theResident, .oneOrTwo: .day
        case .forestEdge, .intoTheForest: .dusk
        default: .daybreak
        }
    }

    /// How far through the shot the camera is. Held at the middle of its move when the
    /// player has asked for less motion, so a still shot is still a composed one.
    private var progress: Double { moves ? frame.progress : 0.5 }

    func draw(in context: inout GraphicsContext) {
        switch frame.shot.picture {
        case .homePen: drawHomePen(in: &context)
        case .theOpenGate: drawTheOpenGate(in: &context)
        case .welcomeMeadow: drawWelcomeMeadow(in: &context)
        case .applesAndSkulls: drawApplesAndSkulls(in: &context)
        case .closeTheFence: drawCloseTheFence(in: &context)
        case .promisingLand: drawPromisingLand(in: &context)
        case .theResident: drawTheResident(in: &context)
        case .oneOrTwo: drawOneOrTwo(in: &context)
        case .finishedPen: drawFinishedPen(in: &context)
        case .forestEdge: drawForestEdge(in: &context)
        case .intoTheForest: drawIntoTheForest(in: &context)
        }
        drawCutFlash(in: &context)
    }

    // MARK: - The shots

    /// The pig in a poky farm pen bolted to the barn, up on the front rail and thoroughly
    /// unimpressed with the square footage. Morning, with the camera drifting in a touch, so
    /// the first thing the film says is how little room there is to say it in.
    private func drawHomePen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.05 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.56))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.30)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.26, drift: 0.015 * progress)
        drawBirds(in: &shot, at: 0.20)

        drawLand(in: &shot, ridge: 0.56, rise: 0.06, waves: 1.9, phase: 1.7, color: colors.farHill)
        drawMist(in: &shot, at: 0.60, seed: 19)
        drawLand(in: &shot, ridge: 0.70, rise: 0.03, waves: 1.4, phase: 0.6, color: colors.ground)

        // The barn the pen is bolted to, off to one side and small: home, such as it is.
        drawBarn(in: &shot, at: 0.78, base: 0.74, width: 0.24)

        // A cramped pen, the pig nearly the width of it and stepping up to the front rail:
        // there is nowhere in here it has not already been.
        let bob = hop(cycles: 2)
        let pig = CGPoint(x: x(0.40), y: y(0.83) - y(0.01 * bob))
        drawPenWash(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.17), lean: 4, squash: 1 - 0.03 * bob)
        drawPenFence(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, count: 14, height: 0.03, seed: 31)
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

        // Far enough in that the push and the drift cannot walk the barn off the side of
        // the frame, and the fence starting clear of its far wall rather than across it.
        drawBarn(in: &shot, at: 0.26, base: 0.72, width: 0.30)
        drawFenceRun(in: &shot, base: 0.80, height: 0.075, from: 0.44, to: 1.06, posts: 7, gap: 3)

        // Through the gap and going: it clears the gateway over the shot rather than
        // standing in it, so the picture is a pig leaving rather than a pig posing.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.66 + 0.18 * progress), y: y(0.825)),
            width: x(0.125),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, count: 14, height: 0.032, seed: 47)
    }

    /// The meadow, wide and bright, with the pig stood in the middle of it and fence posts
    /// popping up out of the grass all round him in turn: the property, and the rack of
    /// fencing a player is handed to build the biggest pen they can on it.
    private func drawWelcomeMeadow(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.24)), radius: x(0.08), rays: false)
        drawClouds(in: &shot, at: 0.16, drift: 0.015 * progress)
        drawBirds(in: &shot, at: 0.30)

        drawLand(in: &shot, ridge: 0.52, rise: 0.06, waves: 2.1, phase: 1.2, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.64, rise: 0.04, waves: 1.5, phase: 2.7, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.74, rise: 0.026, waves: 1.3, phase: 0.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.74, rise: 0.026, waves: 1.3, phase: 0.8, count: 20, height: 0.018, seed: 79)

        let pig = CGPoint(x: x(0.5), y: y(0.82))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))

        // A ring of fence posts standing up out of the grass round the pig, each one popping
        // in its own turn as the shot runs, so the fencing arrives a piece at a time rather
        // than all at once — the rack being handed over.
        drawFencePop(in: &shot, round: pig, width: 0.66, height: 0.11, drop: 0.02)
    }

    /// A pen shut round the pig with an apple inside it and a skull staked outside: the
    /// scoring rule drawn rather than written. Space scores, the apple improves it, and the
    /// skull is the one thing a good wall leaves on the far side of itself.
    private func drawApplesAndSkulls(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.22)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.16, drift: 0.012 * progress)

        drawLand(in: &shot, ridge: 0.44, rise: 0.05, waves: 2.0, phase: 1.3, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, color: colors.ground)
        drawTufts(in: &shot, along: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, count: 16, height: 0.016, seed: 137)

        let pig = CGPoint(x: x(0.44), y: y(0.80))
        drawPenWash(in: &shot, round: pig, width: 0.44, height: 0.26, drop: 0.02)

        // The apple, shut in with the pig where it is worth five tiles.
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.30), y: y(0.68)), width: x(0.072))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.44, height: 0.26, drop: 0.02)

        // The skull, staked out on the wrong side of the wall where it costs nothing.
        drawTreat(in: &shot, "☠️", at: CGPoint(x: x(0.80), y: y(0.72)), width: x(0.072))

        drawLand(in: &shot, ridge: 0.93, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The pen, shut but for one panel, and the pig walking straight out through the gap it
    /// leaves: the half of the rule the apple and the skull cannot teach. A pen the size of
    /// the meadow is worth nothing with a hole in it, and the pig will find the hole.
    private func drawCloseTheFence(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.54))
        drawSun(in: &shot, at: CGPoint(x: x(0.70), y: y(0.34)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.22, drift: 0.015 * progress)

        drawLand(in: &shot, ridge: 0.54, rise: 0.06, waves: 2.0, phase: 1.2, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 2.9, color: colors.ground)

        // The pen washed gold behind the run, so what the pig is leaving reads as a pen that
        // held right up until the last piece was pulled.
        let pen = CGPoint(x: x(0.5), y: y(0.86))
        drawPenWash(in: &shot, round: pen, width: 0.9, height: 0.16, drop: 0.0)

        // The front run of it, one panel out of the middle for a gateway.
        drawFenceRun(in: &shot, base: 0.86, height: 0.14, from: -0.04, to: 1.04, posts: 9, gap: 4)

        // And the pig already through it and going, clear of the gap rather than stood in
        // it, because a pig does not pose in a hole it has found.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.5 + 0.06 * progress), y: y(0.905)),
            width: x(0.14),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.96, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    /// Fence posts standing up out of the grass in a ring round `feet`, each rising in its
    /// own turn as the shot runs rather than all together: the rack of fencing arriving a
    /// piece at a time. Not a pen — the posts do not join up — but the promise of one.
    private func drawFencePop(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double
    ) {
        let count = 12
        let centre = CGPoint(x: feet.x, y: feet.y + y(drop) - y(height) * 0.5)
        let radiusX = x(width) / 2
        let radiusY = y(height) * 0.6
        let timber = max(2, x(0.011))

        var posts = Path()
        for index in 0..<count {
            let angle = Double(index) / Double(count) * 2 * .pi
            let base = CGPoint(
                x: centre.x + radiusX * CGFloat(cos(angle)),
                y: centre.y + radiusY * CGFloat(sin(angle))
            )
            // Each post pops in its turn — staggered round the ring — and eased so it
            // springs up rather than sliding.
            let due = Double(index) / Double(count) * 0.7
            let risen = easeOut(min(max((progress - due) / 0.3, 0), 1))
            guard risen > 0 else { continue }

            // The near posts, low in the frame, stand taller than the far ones.
            let depth = (sin(angle) + 1) / 2
            let tall = y(height) * CGFloat(0.55 + 0.45 * depth) * CGFloat(risen)
            posts.addRoundedRect(
                in: CGRect(x: base.x - timber / 2, y: base.y - tall, width: timber, height: tall),
                cornerSize: CGSize(width: timber * 0.4, height: timber * 0.4)
            )
        }
        context.fill(posts, with: .color(GamePalette.post))
    }

    /// A treat as the field draws it — an apple or a skull staked in the ground, glyph and
    /// all — so an apple in a cut scene reads as the same apple a board is scored on.
    private func drawTreat(
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

    // MARK: - Stag Mere

    /// The meadow, and a deer walking in from the far side of it behind the pig: a promising
    /// piece of land, and the one complication on it, arriving as the shot runs.
    private func drawPromisingLand(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawClouds(in: &shot, at: 0.18, drift: 0.015 * progress)
        drawLand(in: &shot, ridge: 0.40, rise: 0.05, waves: 2.0, phase: 1.4, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.54, rise: 0.026, waves: 1.5, phase: 2.2, color: colors.ground)
        drawTufts(in: &shot, along: 0.54, rise: 0.026, waves: 1.5, phase: 2.2, count: 16, height: 0.016, seed: 91)

        // Coming in from the right edge and slowing as it arrives, still up the field from
        // the pig: the resident, not yet met.
        let deerIn = easeOut(min(progress / 0.8, 1))
        drawAnimal(
            in: &shot,
            .deer,
            feet: CGPoint(x: x(1.06 - 0.30 * deerIn), y: y(0.60)),
            width: x(0.13),
            shadow: 0.7
        )

        drawLand(in: &shot, ridge: 0.70, rise: 0.02, waves: 1.3, phase: 0.6, color: colors.ground)
        drawTufts(in: &shot, along: 0.75, rise: 0.02, waves: 1.3, phase: 0.6, count: 18, height: 0.022, seed: 101)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.80)), width: x(0.15))
    }

    /// The pig and the deer stood looking at each other across the grass, close in and much
    /// of a size: the current resident, and the discovery that this was not a vacant lot.
    private func drawTheResident(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.48))
        drawClouds(in: &shot, at: 0.22, drift: 0.01 * progress)
        drawLand(in: &shot, ridge: 0.48, rise: 0.05, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.62, rise: 0.024, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.66, rise: 0.024, waves: 1.4, phase: 0.9, count: 16, height: 0.02, seed: 107)

        // Facing off across the middle of the frame, each breathing rather than moving,
        // because nobody in this shot has decided anything yet.
        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34), y: y(0.80) - y(0.004 * breath)),
            width: x(0.20),
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .deer,
            feet: CGPoint(x: x(0.68), y: y(0.78) + y(0.004 * breath)),
            width: x(0.19),
            squash: 1 - 0.015 * breath
        )
    }

    /// The rule, drawn rather than written: both animals under one pen outline that splits
    /// into two as the shot runs, so the shape of the answer — one pen or two, whatever
    /// makes the floor plan work — is on screen before the player ever lays a piece.
    private func drawOneOrTwo(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.32))
        drawLand(in: &shot, ridge: 0.32, rise: 0.045, waves: 2.0, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.44, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)
        drawTufts(in: &shot, along: 0.44, rise: 0.02, waves: 1.5, phase: 2.4, count: 16, height: 0.014, seed: 109)

        let deer = CGPoint(x: x(0.66), y: y(0.54))
        let pig = CGPoint(x: x(0.34), y: y(0.78))
        let both = CGPoint(x: (deer.x + pig.x) / 2, y: (deer.y + pig.y) / 2)

        drawAnimal(in: &shot, .deer, feet: deer, width: x(0.16), shadow: 0.7)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))

        // One pen round the pair to begin with, fading as it gives way; then a pen apiece
        // opening up in its place. Split evenly, so the still the screenshots stop on — the
        // middle of the shot — has both readings of the rule in it at once.
        let split = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: both, width: 0.74, height: 0.44, drop: 0.012, opacity: 0.9 * (1 - split))
        drawGhostPen(in: &shot, round: deer, width: 0.42, height: 0.13, drop: 0.012, opacity: 0.9 * split)
        drawGhostPen(in: &shot, round: pig, width: 0.46, height: 0.135, drop: 0.012, opacity: 0.9 * split)
    }

    // MARK: - The meadow held

    /// The pig loose and easy in the finished meadow pen, washed gold, with windfall apples
    /// lying about it: space, good views, plenty of apples. The property, sold and settled.
    private func drawFinishedPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.20)), radius: x(0.085), rays: false)
        drawClouds(in: &shot, at: 0.14, drift: 0.012 * progress)
        drawBirds(in: &shot, at: 0.26)

        drawLand(in: &shot, ridge: 0.34, rise: 0.05, waves: 2.1, phase: 1.5, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.48, rise: 0.03, waves: 1.5, phase: 2.6, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.58, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.58, rise: 0.024, waves: 1.4, phase: 0.8, count: 18, height: 0.016, seed: 113)

        // The whole front of the meadow one held pen, with the pig in the middle of all that
        // room and a couple of windfall apples lying in with it.
        let pig = CGPoint(x: x(0.5), y: y(0.86))
        drawPenWash(in: &shot, round: pig, width: 0.92, height: 0.30, drop: 0.0)
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.24), y: y(0.76)), width: x(0.05))
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.78), y: y(0.80)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        drawPenFence(in: &shot, round: pig, width: 0.92, height: 0.30, drop: 0.0)
    }

    /// The pig stood in its meadow with its back half-turned, looking at a dark stand of
    /// trees banked up at the edge of the world. It should be satisfied. It is looking at the
    /// forest.
    private func drawForestEdge(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawClouds(in: &shot, at: 0.18, drift: 0.01 * progress)
        drawLand(in: &shot, ridge: 0.42, rise: 0.05, waves: 2.0, phase: 1.7, color: colors.farHill)

        // The forest banked up on the right, dark against the dusk: the next listing.
        drawForest(in: &shot, base: 0.62, from: 0.50, to: 1.10, height: 0.34, seed: 211)

        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.70, rise: 0.03, waves: 1.4, phase: 0.9, count: 18, height: 0.02, seed: 127)

        // Stood off in the open meadow, turned toward the trees rather than toward whoever
        // is watching it.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.32), y: y(0.84)), width: x(0.17), lean: -3)

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.2, color: colors.foreground)
    }

    /// The pig away up the trail and into the trees, small and getting smaller: gone to look
    /// at the next place before the paint is dry on this one. The line the film ends on lands
    /// in the middle of the frame over the top of it.
    private func drawIntoTheForest(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawLand(in: &shot, ridge: 0.40, rise: 0.045, waves: 2.1, phase: 1.5, color: colors.farHill)

        // The forest ahead and across the whole frame now, the meadow narrowing into it.
        drawForest(in: &shot, base: 0.56, from: -0.10, to: 1.10, height: 0.40, seed: 223)

        drawLand(in: &shot, ridge: 0.60, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)
        drawTrail(in: &shot, from: 1.02, to: 0.60)

        // On the trail and heading up it, dwindling toward the treeline as the shot runs.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.46 + 0.02 * along), y: y(0.76 - 0.06 * along)),
            width: x(0.10 - 0.03 * along),
            shadow: 0.5
        )

        drawLand(in: &shot, ridge: 0.92, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    /// A stand of dark trees banked along the meadow's edge: two ranks of stubby conifer
    /// silhouettes, the back rank a shade lighter and lifted, so the forest reads as deep
    /// rather than as a cardboard cut-out. It is the next world's front door, drawn as a wall
    /// of dark rather than as somewhere you can already see into.
    private func drawForest(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        seed: UInt64
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
                with: .color(GamePalette.beyond.opacity(rank > 0 ? 0.55 : 0.92))
            )
        }
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
    private func drawTrail(in context: inout GraphicsContext, from bottom: Double, to top: Double) {
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
    private func drawAnimal(
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
    private func penBounds(round feet: CGPoint, width: Double, height: Double, drop: Double) -> CGRect {
        CGRect(
            x: feet.x - x(width) / 2,
            y: feet.y + y(drop) - y(height),
            width: x(width),
            height: y(height)
        )
    }

    private func penRect(round feet: CGPoint, width: Double, height: Double, drop: Double) -> Path {
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
    private func drawGhostPen(
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
    private func drawPenWash(
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
    private func drawPenFence(
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

#Preview("Opening · home pen") { CutSceneView(.opening(), still: 1.8) }

#Preview("Opening · the gate") { CutSceneView(.opening(), still: 13.3) }

#Preview("Opening · welcome") { CutSceneView(.opening(), still: 20.1) }

#Preview("Opening · apples and skulls") { CutSceneView(.opening(), still: 29.1) }

#Preview("Opening · close the fence") { CutSceneView(.opening(), still: 38.3) }

#Preview("Stag Mere · promising land") { CutSceneView(.stagMere(), still: 2.2) }

#Preview("Stag Mere · the resident") { CutSceneView(.stagMere(), still: 8.9) }

#Preview("Stag Mere · one or two") { CutSceneView(.stagMere(), still: 15.7) }

#Preview("Meadow held · finished pen") { CutSceneView(.theMeadowHeld(), still: 1.8) }

#Preview("Meadow held · forest edge") { CutSceneView(.theMeadowHeld(), still: 10.8) }

#Preview("Meadow held · into the forest") { CutSceneView(.theMeadowHeld(), still: 15.9) }

#Preview("Played through") { CutSceneView(.opening()) {} }
