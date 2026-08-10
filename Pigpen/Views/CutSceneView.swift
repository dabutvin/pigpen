import Foundation
import SwiftUI
import UIKit

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

    /// Held rather than taken fresh each time the screen is drawn, so the clock starts when
    /// the film goes up and not again on every frame of it.
    @State private var scene: CutScene
    /// The way out, kept off the first frame or two so a film opens on its picture rather
    /// than on a button.
    @State private var offersSkip = false

    init(_ scene: CutScene, onFinish: @escaping () -> Void) {
        _scene = State(initialValue: scene)
        self.onFinish = onFinish
        self.still = nil
    }

    /// A still of a film `seconds` in.
    init(_ scene: CutScene, still seconds: TimeInterval) {
        _scene = State(initialValue: scene)
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

    /// The shots whose line is the point of the whole film rather than a note under the
    /// picture, and so is set big and in the middle.
    private static let cards: Set<CutScene.Picture> = [.fenceItIn, .somewhereElse]

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
        let words = Text(frame.shot.caption)
            .multilineTextAlignment(.center)
            .foregroundStyle(GamePalette.cream)
            .shadow(color: .black.opacity(0.7), radius: 5, y: 2)
            .padding(.horizontal, 32)
            .opacity(frame.captionOpacity)

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
    /// The opening is at sunrise and the meadow's last film ends in the same gold, so the
    /// world opens and closes on one light. Stag Mere is lit flat and bright in between,
    /// because a briefing wants reading rather than admiring, and the two shots out past
    /// the meadow are lit by nothing but stars.
    private var colors: GamePalette.Pasture {
        switch frame.shot.picture {
        case .theMere, .theStag, .bothOrNeither: .day
        case .theMeadowFromOut, .somewhereElse: .dusk
        default: .daybreak
        }
    }

    /// How far through the shot the camera is. Held at the middle of its move when the
    /// player has asked for less motion, so a still shot is still a composed one.
    private var progress: Double { moves ? frame.progress : 0.5 }

    func draw(in context: inout GraphicsContext) {
        switch frame.shot.picture {
        case .firstLight: drawFirstLight(in: &context)
        case .theOpenGate: drawTheOpenGate(in: &context)
        case .thePig: drawThePig(in: &context)
        case .away: drawAway(in: &context)
        case .theBiggestPen: drawTheBiggestPen(in: &context)
        case .fenceItIn: drawFenceItIn(in: &context)
        case .theMere: drawTheMere(in: &context)
        case .theStag: drawTheStag(in: &context)
        case .bothOrNeither: drawBothOrNeither(in: &context)
        case .bothPenned: drawBothPenned(in: &context)
        case .theStagStays: drawTheStagStays(in: &context)
        case .theWholeMeadow: drawTheWholeMeadow(in: &context)
        case .theMeadowFromOut: drawTheMeadowFromOut(in: &context)
        case .somewhereElse: drawSomewhereElse(in: &context)
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
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: middle.x, y: y(0.815) - y(0.006 * breath)),
            width: x(0.44),
            squash: 1 + 0.02 * breath
        )
    }

    /// Gone. The pig is across the middle of the frame at a gallop with the field streaking
    /// off the back of it and the dust it pushed off still hanging where it was.
    ///
    /// It is drawn big and up in the picture rather than small and away, because the pig is
    /// a face rather than a body: it cannot be seen to run, so the running has to be
    /// everything round it — the streaks, the dust, the lean and the bob.
    private func drawAway(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06, drift: 0.025 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        drawSun(in: &shot, at: CGPoint(x: x(0.84), y: y(0.30)), radius: x(0.075), rays: false)
        drawLand(in: &shot, ridge: 0.52, rise: 0.055, waves: 2.0, phase: 2.8, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 1.6, color: colors.ground)

        let across = x(0.20 + 0.56 * progress)
        let bob = hop(cycles: 4)

        drawStreaks(in: &shot, behind: across, at: 0.56...0.69, count: 11, seed: 67)
        drawDust(in: &shot, behind: across, at: 0.72)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: across, y: y(0.72) - y(0.022 * bob)),
            width: x(0.20),
            lean: 10,
            squash: 1 - 0.08 * bob,
            shadow: 0.7
        )
        drawStreaks(in: &shot, behind: across, at: 0.74...0.88, count: 9, seed: 71)

        drawLand(in: &shot, ridge: 0.93, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The scoring rule, drawn rather than written: the pig stood in open grass with the
    /// tightest pen that would hold it marked round it in dashes, and a second pen pushing
    /// out from that one across the meadow as the shot runs. The small one fades as
    /// the big one goes past it, so the shot is an answer being rejected for a better one
    /// rather than two plans sitting side by side.
    ///
    /// The camera pulls back while the pen grows, which is what stops the dashes simply
    /// walking off the sides: the meadow keeps giving it more room to take.
    private func drawTheBiggestPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.32))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.19)), radius: x(0.07), rays: false)
        drawClouds(in: &shot, at: 0.13, drift: 0.012 * progress)

        drawLand(in: &shot, ridge: 0.32, rise: 0.05, waves: 2.0, phase: 1.3, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.44, rise: 0.024, waves: 1.5, phase: 2.5, color: colors.ground)
        drawTufts(in: &shot, along: 0.44, rise: 0.024, waves: 1.5, phase: 2.5, count: 18, height: 0.016, seed: 137)

        // Low in the frame and a little off centre, so the pen that grows round the pig has
        // the meadow to grow into and the line of type has the bottom of the frame to
        // itself. Not so far off that the widest pen runs out past the side of the shot: a
        // rectangle with an edge missing is a pen that does not hold, which is the opposite
        // of what this one is for.
        let pig = CGPoint(x: x(0.46), y: y(0.80))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))

        // What would do, going: a pen the size of the animal in it scores the animal in it.
        drawGhostPen(
            in: &shot,
            round: pig,
            width: 0.26,
            height: 0.12,
            drop: 0.012,
            // Faded out evenly rather than snatched away, so the frame the screenshots and
            // the reduced-motion players are handed — the middle of the shot — still has
            // both pens in it, which is the whole comparison.
            opacity: 0.75 * max(0, 1 - progress / 0.8)
        )

        // And what is being asked for, opening out past it. It stops short of the frame
        // rather than reaching the edges: a pen is what the fencing in the rack will go
        // round, and a shot that says "all of it" would be teaching the wrong rule.
        let grown = easeOut(progress)
        drawGhostPen(
            in: &shot,
            round: pig,
            width: 0.28 + 0.52 * grown,
            height: 0.13 + 0.22 * grown,
            drop: 0.012
        )
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
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.735)), width: x(0.055), shadow: 0.5)

        // Stood clear of the bottom bar, so the fencing the player is being handed is all
        // of it in the picture rather than half of it behind the letterbox.
        drawFenceRun(in: &shot, base: 0.90, height: 0.13, from: -0.06, to: 1.06, posts: 9, gap: nil)
    }

    // MARK: - Stag Mere

    /// The mere, with an animal on either bank of it. The one thing a player needs to know
    /// about this map before they start is that there are two of them and water in between,
    /// so that is the whole of the picture: near bank, water, far bank, one on each.
    private func drawTheMere(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.36))
        drawClouds(in: &shot, at: 0.16, drift: 0.015 * progress)
        drawLand(in: &shot, ridge: 0.36, rise: 0.05, waves: 2.0, phase: 1.4, color: colors.farHill)

        // The far bank, with the stag on it, and then the water in front of that.
        drawLand(in: &shot, ridge: 0.48, rise: 0.022, waves: 1.5, phase: 2.2, color: colors.ground)
        drawTufts(in: &shot, along: 0.48, rise: 0.022, waves: 1.5, phase: 2.2, count: 16, height: 0.016, seed: 91)
        drawAnimal(in: &shot, .deer, feet: CGPoint(x: x(0.68), y: y(0.53)), width: x(0.13), shadow: 0.7)

        drawMere(in: &shot, from: 0.56, to: 0.68, seed: 97)

        drawLand(in: &shot, ridge: 0.68, rise: 0.02, waves: 1.3, phase: 0.6, color: colors.ground)
        // Well clear of the water: grass grows up out of its line, so a tuft rooted on the
        // shore itself comes up through the mere.
        drawTufts(in: &shot, along: 0.73, rise: 0.02, waves: 1.3, phase: 0.6, count: 18, height: 0.022, seed: 101)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.78)), width: x(0.15))
    }

    /// The stag, head on. The pig got spokes of light behind it because the pig is the whole
    /// game; the stag gets the water it stands over and nothing else, because the water is
    /// the point of it — this shot is the film saying whose shore the last field is, so that
    /// the rule after it is a piece of manners rather than a second animal to deal with.
    private func drawTheStag(in context: inout GraphicsContext) {
        let landed = easeOut(min(progress / 0.3, 1))
        var shot = pushed(context, zoom: 1.14 - 0.11 * landed)

        drawSky(in: &shot, horizon: y(0.50))
        drawClouds(in: &shot, at: 0.22, drift: 0.01 * progress)
        drawLand(in: &shot, ridge: 0.50, rise: 0.05, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.62, rise: 0.02, waves: 1.4, phase: 0.9, color: colors.ground)

        drawMere(in: &shot, from: 0.68, to: 0.84, seed: 103)

        drawLand(in: &shot, ridge: 0.84, rise: 0.016, waves: 1.2, phase: 1.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.89, rise: 0.016, waves: 1.2, phase: 1.8, count: 16, height: 0.022, seed: 107)

        // Standing on the far bank and looking straight back at whoever is coming.
        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .deer,
            feet: CGPoint(x: x(0.5), y: y(0.66) - y(0.005 * breath)),
            width: x(0.40),
            squash: 1 + 0.015 * breath
        )
    }

    /// The rule, drawn rather than written: both animals with the pen each of them is going
    /// to need marked out round it in dashes, so the shape of the answer — two enclosures,
    /// not one — is on screen before the player ever lays a piece.
    private func drawBothOrNeither(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawLand(in: &shot, ridge: 0.30, rise: 0.045, waves: 2.0, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.42, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)

        let stag = CGPoint(x: x(0.66), y: y(0.47))
        drawAnimal(in: &shot, .deer, feet: stag, width: x(0.16), shadow: 0.7)
        drawGhostPen(in: &shot, round: stag, width: 0.42, height: 0.115, drop: 0.012)

        drawMere(in: &shot, from: 0.52, to: 0.64, seed: 109)

        drawLand(in: &shot, ridge: 0.64, rise: 0.018, waves: 1.3, phase: 0.4, color: colors.ground)
        // Both pens have to sit clear of the line of type, since the line is the half of
        // this shot that says what the dashes mean.
        let pig = CGPoint(x: x(0.34), y: y(0.77))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawGhostPen(in: &shot, round: pig, width: 0.46, height: 0.125, drop: 0.012)
    }

    // MARK: - The meadow held

    /// Both of them shut in, on ground washed gold: the shape the last puzzle ends in, and
    /// the only picture in the game where the two pens are seen holding at once.
    private func drawBothPenned(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.20)), radius: x(0.08), rays: false)
        drawLand(in: &shot, ridge: 0.30, rise: 0.045, waves: 2.0, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.42, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)

        let stag = CGPoint(x: x(0.66), y: y(0.47))
        drawPenWash(in: &shot, round: stag, width: 0.42, height: 0.115, drop: 0.012)
        drawAnimal(in: &shot, .deer, feet: stag, width: x(0.16), shadow: 0.7)
        drawPenFence(in: &shot, round: stag, width: 0.42, height: 0.115, drop: 0.012)

        drawMere(in: &shot, from: 0.52, to: 0.64, seed: 109)

        drawLand(in: &shot, ridge: 0.64, rise: 0.018, waves: 1.3, phase: 0.4, color: colors.ground)
        let pig = CGPoint(x: x(0.34), y: y(0.77))
        drawPenWash(in: &shot, round: pig, width: 0.46, height: 0.125, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.46, height: 0.125, drop: 0.012)
    }

    /// The stag on its own shore with the trail running away out of the picture. Whoever is
    /// leaving is leaving; the stag was here before any of this and is staying.
    private func drawTheStagStays(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.07 * progress)

        drawSky(in: &shot, horizon: y(0.54))
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.50)), radius: x(0.09), rays: false)
        drawClouds(in: &shot, at: 0.26, drift: 0.012 * progress)
        drawLand(in: &shot, ridge: 0.54, rise: 0.06, waves: 2.1, phase: 1.7, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.66, rise: 0.04, waves: 1.5, phase: 2.8, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.76, rise: 0.024, waves: 1.3, phase: 0.9, color: colors.ground)
        drawTrail(in: &shot, from: 1.02, to: 0.77)
        drawTufts(in: &shot, along: 0.76, rise: 0.024, waves: 1.3, phase: 0.9, count: 20, height: 0.018, seed: 113)

        // Stood off the trail rather than on it, watching it go.
        drawAnimal(in: &shot, .deer, feet: CGPoint(x: x(0.70), y: y(0.83)), width: x(0.185))

        drawLand(in: &shot, ridge: 0.94, rise: 0.014, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.014, waves: 1.0, phase: 2.2, count: 13, height: 0.03, seed: 127)
    }

    /// The whole meadow at once, from higher up than the map ever gets: the trail winding
    /// from the barn at the bottom to the mere at the top, with a stop marked at every
    /// puzzle along it. Nine fields, and the player has fenced all of them.
    private func drawTheWholeMeadow(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.12 * progress)

        drawSky(in: &shot, horizon: y(0.24))
        drawLand(in: &shot, ridge: 0.24, rise: 0.04, waves: 2.2, phase: 1.5, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.32, rise: 0.03, waves: 1.7, phase: 2.7, color: colors.ground)

        // The mere at the head of the trail, which is where the film before this one was.
        drawMere(in: &shot, from: 0.28, to: 0.36, seed: 131)

        let trail = meadowTrail()
        shot.stroke(
            trail,
            with: .color(GamePalette.mudSpeckle.opacity(0.4)),
            style: StrokeStyle(lineWidth: max(3, x(0.032)), lineCap: .round)
        )
        shot.stroke(
            trail,
            with: .color(GamePalette.mud),
            style: StrokeStyle(lineWidth: max(2, x(0.024)), lineCap: .round)
        )

        // A stop for every puzzle, all of them held.
        for stop in 0..<9 {
            let along = Double(stop) / 8
            let spot = meadowStop(along)
            shot.fill(
                circle(at: CGPoint(x: spot.x, y: spot.y + y(0.006)), radius: x(0.018)),
                with: .color(.black.opacity(0.2))
            )
            shot.fill(circle(at: spot, radius: x(0.017)), with: .color(GamePalette.cream))
            shot.fill(circle(at: spot, radius: x(0.010)), with: .color(GamePalette.pen))
        }

        // Beside the foot of the trail and clear of the line of type. No grass along the
        // ridge here: the mere lies on that line, and tufts rooted on it come up through
        // the water.
        drawBarn(in: &shot, at: 0.82, base: 0.80, width: 0.15)
    }

    /// The meadow from further out than that: a world, with a stag standing on it for a
    /// mark. A world a player has finished is a world with something of its own left living
    /// on it, which is why the stag was left there rather than brought along.
    private func drawTheMeadowFromOut(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.16 - 0.14 * progress)

        drawSpace(in: &shot)
        drawWorld(
            in: &shot,
            at: CGPoint(x: x(0.5), y: y(0.60)),
            radius: x(0.30),
            lit: 1,
            keeper: .deer
        )
    }

    /// And another one out past it, coming alight. What is on it is nobody's business yet —
    /// including this film's, which is why it is drawn as country under cloud and left
    /// without a name.
    private func drawSomewhereElse(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.05 * progress)

        drawSpace(in: &shot)

        // The meadow, done with and dropping back. Both worlds keep out of the middle band
        // of the frame, which belongs to the line the film ends on.
        drawWorld(
            in: &shot,
            at: CGPoint(x: x(0.26), y: y(0.82)),
            radius: x(0.14),
            lit: 1,
            keeper: .deer
        )

        // The next one, coming up out of the dark over the shot rather than simply being
        // there: the light arriving is the whole point of the frame. It stops well short of
        // full, though — a world that lights up all the way reads as a second meadow, and
        // what is on this one is nobody's business yet.
        let waking = 0.55 * easeOut(min(progress / 0.75, 1))
        drawWorld(
            in: &shot,
            at: CGPoint(x: x(0.66), y: y(0.25)),
            radius: x(0.19),
            lit: waking,
            keeper: nil
        )

        // The road between them, drawn on as the far one lights.
        var road = Path()
        road.move(to: CGPoint(x: x(0.36), y: y(0.72)))
        road.addQuadCurve(
            to: CGPoint(x: x(0.56), y: y(0.38)),
            control: CGPoint(x: x(0.56), y: y(0.62))
        )
        shot.stroke(
            road,
            with: .color(GamePalette.cream.opacity(0.32 * waking)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.006)), lineCap: .round, dash: [x(0.02), x(0.026)])
        )
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

    /// A band of water lying across the frame, silted along both banks and with the light
    /// broken up on it. The same water a board is walled with, seen from the bank instead
    /// of from above.
    private func drawMere(
        in context: inout GraphicsContext,
        from top: Double,
        to bottom: Double,
        seed: UInt64
    ) {
        let near = ridgeLine(at: top, rise: 0.006, waves: 2.6, phase: 1.3)
        let far = ridgeLine(at: bottom, rise: 0.005, waves: 2.0, phase: 2.9)
        let start = -size.width
        let end = size.width * 2

        var water = Path()
        water.move(to: CGPoint(x: start, y: near(start)))
        var across = start
        while across < end {
            water.addLine(to: CGPoint(x: across, y: near(across)))
            across += 8
        }
        water.addLine(to: CGPoint(x: end, y: near(end)))
        water.addLine(to: CGPoint(x: end, y: far(end)))
        while across > start {
            water.addLine(to: CGPoint(x: across, y: far(across)))
            across -= 8
        }
        water.addLine(to: CGPoint(x: start, y: far(start)))
        water.closeSubpath()

        // Silt laid down first and covered over by the water, so it shows only on the banks.
        context.stroke(
            water,
            with: .color(GamePalette.shore.opacity(0.55)),
            lineWidth: max(2, y(0.012))
        )
        context.fill(
            water,
            with: .linearGradient(
                Gradient(colors: [GamePalette.waterDeep, GamePalette.water]),
                startPoint: CGPoint(x: 0, y: y(top)),
                endPoint: CGPoint(x: 0, y: y(bottom))
            )
        )

        var scatter = Scatter(seed: seed)
        var ripples = Path()
        for _ in 0..<10 {
            let level = y(scatter.next(in: (top + 0.012)...(bottom - 0.012)))
            let span = x(0.08 + scatter.next() * 0.16)
            let from = x(scatter.next() * 1.1 - 0.05)
            ripples.move(to: CGPoint(x: from, y: level))
            ripples.addQuadCurve(
                to: CGPoint(x: from + span, y: level),
                control: CGPoint(x: from + span / 2, y: level - y(0.006))
            )
        }
        context.stroke(
            ripples,
            with: .color(GamePalette.waterRipple.opacity(0.5)),
            style: StrokeStyle(lineWidth: max(1, y(0.003)), lineCap: .round)
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

    // MARK: - The meadow, and what is past it

    /// The meadow's trail as one winding line, `along` running 0 at the barn to 1 at the
    /// mere. The stops are taken off the same line, so a signpost cannot end up beside the
    /// path it is supposed to stand on.
    private func meadowStop(_ along: Double) -> CGPoint {
        CGPoint(
            x: x(0.5 + 0.26 * sin(along * .pi * 2.4 + 0.6)),
            y: y(0.78 - 0.44 * along)
        )
    }

    private func meadowTrail() -> Path {
        var path = Path()
        path.move(to: meadowStop(0))
        var along = 0.0
        while along < 1 {
            along = min(along + 0.02, 1)
            path.addLine(to: meadowStop(along))
        }
        return path
    }

    /// Out past the meadow: nothing but the dark, and the stars in it.
    private func drawSpace(in context: inout GraphicsContext) {
        context.fill(
            Path(CGRect(
                x: -size.width, y: -size.height,
                width: size.width * 3, height: size.height * 3
            )),
            with: .radialGradient(
                Gradient(colors: [colors.skyHorizon.opacity(0.45), colors.skyTop]),
                center: CGPoint(x: x(0.5), y: y(0.55)),
                startRadius: 0,
                endRadius: max(size.width, size.height)
            )
        )

        var scatter = Scatter(seed: 311)
        for _ in 0..<90 {
            let spot = CGPoint(
                x: x(scatter.next() * 1.2 - 0.1),
                y: y(scatter.next() * 1.2 - 0.1)
            )
            let radius = x(0.0025) * CGFloat(0.6 + scatter.next() * 1.5)
            context.fill(
                circle(at: spot, radius: radius),
                with: .color(.white.opacity(0.25 + scatter.next() * 0.55))
            )
        }
    }

    /// A world seen from outside it: a round patch of country with fields and water on it,
    /// and whatever was left living there standing on top of it for a mark.
    ///
    /// `lit` is how much of it has come out of the dark. A world nobody has been to yet is
    /// left under cloud at 0, which is all this film has to say about the next one.
    private func drawWorld(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        radius: CGFloat,
        lit: Double,
        keeper: Animal?
    ) {
        context.fill(
            circle(at: centre, radius: radius * 1.9),
            with: .radialGradient(
                Gradient(colors: [
                    GamePalette.pen.opacity(0.22 * lit),
                    GamePalette.pen.opacity(0)
                ]),
                center: centre,
                startRadius: radius * 0.9,
                endRadius: radius * 1.9
            )
        )

        let ball = circle(at: centre, radius: radius)
        context.fill(ball, with: .color(GamePalette.beyond.opacity(0.3 + 0.6 * lit)))

        var ground = context
        ground.clip(to: ball)

        // Fields on it, and a river through them: enough to read as country rather than
        // as a green marble.
        var scatter = Scatter(seed: 419)
        for _ in 0..<7 {
            let patch = CGRect(
                x: centre.x - radius + radius * 2 * CGFloat(scatter.next()),
                y: centre.y - radius + radius * 2 * CGFloat(scatter.next()),
                width: radius * CGFloat(0.3 + scatter.next() * 0.5),
                height: radius * CGFloat(0.2 + scatter.next() * 0.35)
            )
            ground.fill(
                Path(roundedRect: patch, cornerRadius: radius * 0.1),
                with: .color(.black.opacity(0.12 * lit))
            )
        }

        var river = Path()
        river.move(to: CGPoint(x: centre.x - radius, y: centre.y + radius * 0.2))
        river.addQuadCurve(
            to: CGPoint(x: centre.x + radius, y: centre.y - radius * 0.1),
            control: CGPoint(x: centre.x, y: centre.y + radius * 0.7)
        )
        ground.stroke(
            river,
            with: .color(GamePalette.water.opacity(0.7 * lit)),
            style: StrokeStyle(lineWidth: radius * 0.13, lineCap: .round)
        )

        // Lit down one side, like everything else the game draws.
        ground.fill(
            ball,
            with: .radialGradient(
                Gradient(colors: [.white.opacity(0.16 * lit), .black.opacity(0.5)]),
                center: CGPoint(x: centre.x - radius * 0.35, y: centre.y - radius * 0.4),
                startRadius: radius * 0.2,
                endRadius: radius * 1.5
            )
        )

        // Whatever has not come out of the dark yet stays under cloud.
        context.fill(ball, with: .color(colors.skyTop.opacity(0.66 * (1 - lit))))

        guard let keeper else { return }
        drawAnimal(
            in: &context,
            keeper,
            feet: CGPoint(x: centre.x, y: centre.y - radius * 0.8),
            width: radius * 0.6,
            shadow: 0.35
        )
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

    /// The field going past, as lines trailing off the back of whatever is outrunning the
    /// camera. Drawn rather than blurred: a line is what anime uses, and it costs nothing.
    ///
    /// They are kept to the band the runner is actually in and to the ground behind it. A
    /// streak across the empty sky is not speed, it is a scratch on the film.
    private func drawStreaks(
        in context: inout GraphicsContext,
        behind across: CGFloat,
        at band: ClosedRange<Double>,
        count: Int,
        seed: UInt64
    ) {
        guard moves else { return }

        var scatter = Scatter(seed: seed)
        var lines = Path()

        for _ in 0..<count {
            let level = y(scatter.next(in: band))
            let span = x(0.18 + scatter.next() * 0.34)
            // Off the back of it, and further back the longer the shot has been running.
            let tail = across - x(0.03 + scatter.next() * 0.46) - x(0.26) * CGFloat(progress)
            lines.move(to: CGPoint(x: tail - span, y: level))
            lines.addLine(to: CGPoint(x: tail, y: level))
        }

        context.stroke(
            lines,
            with: .color(GamePalette.cream.opacity(0.42)),
            style: StrokeStyle(lineWidth: max(1.5, y(0.005)), lineCap: .round)
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

#Preview("Opening · first light") { CutSceneView(.opening(), still: 1.6) }

#Preview("Opening · the gate") { CutSceneView(.opening(), still: 4.4) }

#Preview("Opening · the pig") { CutSceneView(.opening(), still: 6.8) }

#Preview("Opening · away") { CutSceneView(.opening(), still: 9.7) }

#Preview("Opening · the biggest pen") { CutSceneView(.opening(), still: 12.8) }

#Preview("Opening · fence it in") { CutSceneView(.opening(), still: 15.6) }

#Preview("Stag Mere · the mere") { CutSceneView(.stagMere(), still: 1.4) }

#Preview("Stag Mere · the stag") { CutSceneView(.stagMere(), still: 4.1) }

#Preview("Stag Mere · both or neither") { CutSceneView(.stagMere(), still: 7.2) }

#Preview("Meadow held · both penned") { CutSceneView(.theMeadowHeld(), still: 1.4) }

#Preview("Meadow held · the stag stays") { CutSceneView(.theMeadowHeld(), still: 4.0) }

#Preview("Meadow held · the whole meadow") { CutSceneView(.theMeadowHeld(), still: 7.2) }

#Preview("Meadow held · from out") { CutSceneView(.theMeadowHeld(), still: 10.4) }

#Preview("Meadow held · somewhere else") { CutSceneView(.theMeadowHeld(), still: 13.4) }

#Preview("Played through") { CutSceneView(.opening()) {} }
