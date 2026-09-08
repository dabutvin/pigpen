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

        if frame.shot.picture.isCard {
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

#Preview("Opening · home pen") { CutSceneView(.opening(), still: 1.9) }

#Preview("Opening · the gate") { CutSceneView(.opening(), still: 12.2) }

#Preview("Opening · welcome") { CutSceneView(.opening(), still: 18.1) }

#Preview("Opening · apples and skulls") { CutSceneView(.opening(), still: 25.9) }

#Preview("Opening · close the fence") { CutSceneView(.opening(), still: 33.8) }

#Preview("Stag Mere · promising land") { CutSceneView(.stagMere(), still: 2.4) }

#Preview("Stag Mere · the resident") { CutSceneView(.stagMere(), still: 8.5) }

#Preview("Stag Mere · one or two") { CutSceneView(.stagMere(), still: 14.5) }

#Preview("Meadow held · finished pen") { CutSceneView(.theMeadowHeld(), still: 1.9) }

#Preview("Meadow held · forest edge") { CutSceneView(.theMeadowHeld(), still: 10.1) }

#Preview("Meadow held · into the forest") { CutSceneView(.theMeadowHeld(), still: 15.0) }

#Preview("Thicket · the tree line") { CutSceneView(.thornwoodOpening(), still: 1.9) }

#Preview("Thicket · the amenity") { CutSceneView(.thornwoodOpening(), still: 11.9) }

#Preview("Thicket · the drawback") { CutSceneView(.thornwoodOpening(), still: 15.1) }

#Preview("Thicket · off the beaten path") { CutSceneView(.thornwoodOpening(), still: 20.1) }

#Preview("Boar Hollow · the neighbor") { CutSceneView(.boarHollow(), still: 1.9) }

#Preview("Boar Hollow · separate units") { CutSceneView(.boarHollow(), still: 5.9) }

#Preview("Boar Hollow · a pen apiece") { CutSceneView(.boarHollow(), still: 10.3) }

#Preview("Thicket held · the hollow") { CutSceneView(.thornwoodHeld(), still: 1.9) }

#Preview("Thicket held · mountain views") { CutSceneView(.thornwoodHeld(), still: 12.5) }

#Preview("Thicket held · the volcano") { CutSceneView(.thornwoodHeld(), still: 17.4) }

#Preview("Played through") { CutSceneView(.opening()) {} }
