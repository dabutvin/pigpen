import SwiftUI
import UIKit

/// Plays a `StorybookScene`: a themed backdrop with a motif held over it and a line of type,
/// between the same black bars the painted films use, with the same way out in the corner.
///
/// Where `CutSceneView` paints a whole meadow into a canvas per shot, this is the lighter hand
/// — a coloured ground, a big glyph, a few smaller ones strewn behind it — so a new world can
/// open and close on a film long before it has bespoke art of its own.
@MainActor
struct StorybookSceneView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let onFinish: () -> Void
    /// One moment held still for a preview or a screenshot, rather than the film played.
    private let still: TimeInterval?

    @State private var scene: StorybookScene
    @State private var offersSkip = false

    init(_ scene: StorybookScene, onFinish: @escaping () -> Void) {
        _scene = State(initialValue: scene)
        self.onFinish = onFinish
        self.still = nil
    }

    init(_ scene: StorybookScene, still seconds: TimeInterval) {
        _scene = State(initialValue: scene)
        self.onFinish = {}
        self.still = seconds
    }

    var body: some View {
        GeometryReader { proxy in
            let bar = proxy.size.height * 0.072

            ZStack {
                Color.black

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: still != nil)) { timeline in
                    let elapsed = still ?? timeline.date.timeIntervalSince(scene.start)

                    ZStack {
                        if let frame = scene.frame(secondsIn: elapsed) {
                            backdrop(size: proxy.size, frame: frame)
                            bars(landed: scene.letterbox(secondsIn: elapsed), depth: bar)
                            caption(frame, clear: bar)
                        }

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
            guard still == nil else { return }
            if await scene.waitOut() {
                onFinish()
            }
        }
        .task {
            guard still == nil else { return }
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeIn(duration: 0.35)) { offersSkip = true }
        }
    }

    private var offersTheWayOut: Bool { still != nil || offersSkip }

    // MARK: - The picture

    /// The themed ground the still is set on, the strewn glyphs of the world, and the motif the
    /// still is built around — the motif lifting a little as the shot runs, unless the player has
    /// asked for less motion.
    private func backdrop(size: CGSize, frame: StorybookScene.Frame) -> some View {
        let light = scene.light
        let lift = reduceMotion ? 0.5 : frame.progress
        let motif = min(size.width, size.height) * 0.34

        return ZStack {
            LinearGradient(
                colors: [light.skyTop, light.skyHorizon, light.ground],
                startPoint: .top,
                endPoint: .bottom
            )

            strewn(size: size, frame: frame)

            // A soft glow behind the motif, so a lone glyph on a field reads as lit rather than
            // pasted on.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [light.discHalo.opacity(0.5), light.discHalo.opacity(0)],
                        center: .center,
                        startRadius: motif * 0.1,
                        endRadius: motif * 0.9
                    )
                )
                .frame(width: motif * 1.8, height: motif * 1.8)
                .position(x: size.width / 2, y: size.height * 0.44)

            Text(frame.shot.motif)
                .font(.system(size: motif))
                .shadow(color: .black.opacity(0.35), radius: motif * 0.06, y: motif * 0.05)
                .position(
                    x: size.width / 2,
                    y: size.height * 0.44 - motif * 0.08 * CGFloat(lift)
                )
                .scaleEffect(1 + 0.03 * CGFloat(lift))
        }
        .accessibilityHidden(true)
    }

    /// A scatter of the world's smaller glyphs, placed the same way every time from a seed so the
    /// still is composed rather than sprinkled at random each frame.
    private func strewn(size: CGSize, frame: StorybookScene.Frame) -> some View {
        var scatter = Scatter(seed: UInt64(truncatingIfNeeded: frame.index &* 2_654_435_761 &+ 101))
        let glyphs = frame.shot.strewn
        let placed: [(glyph: String, at: CGPoint, size: CGFloat, fade: Double)] = glyphs.isEmpty ? [] :
            (0..<glyphs.count).map { index in
                (
                    glyph: glyphs[index],
                    at: CGPoint(
                        x: size.width * CGFloat(scatter.next(in: 0.12...0.88)),
                        y: size.height * CGFloat(scatter.next(in: 0.16...0.82))
                    ),
                    size: min(size.width, size.height) * CGFloat(scatter.next(in: 0.06...0.11)),
                    fade: scatter.next(in: 0.28...0.5)
                )
            }

        return ZStack {
            ForEach(placed.indices, id: \.self) { index in
                let mote = placed[index]
                Text(mote.glyph)
                    .font(.system(size: mote.size))
                    .opacity(mote.fade)
                    .position(mote.at)
            }
        }
    }

    /// The black bars, sliding in as the film opens and staying.
    private func bars(landed: Double, depth: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.black).frame(height: depth).offset(y: -depth * (1 - landed))
            Spacer(minLength: 0)
            Rectangle().fill(Color.black).frame(height: depth).offset(y: depth * (1 - landed))
        }
        .allowsHitTesting(false)
    }

    /// The line over the still: real type, so a screen read aloud still tells the story. A shot
    /// that is the point of the film sets its line big in the middle as a card; the rest tuck it
    /// along the bottom like a subtitle.
    @ViewBuilder
    private func caption(_ frame: StorybookScene.Frame, clear bar: CGFloat) -> some View {
        let words = Text(frame.shot.caption)
            .multilineTextAlignment(.center)
            .foregroundStyle(GamePalette.cream)
            .shadow(color: .black.opacity(0.7), radius: 5, y: 2)
            .padding(.horizontal, 32)
            .opacity(frame.captionOpacity)

        if frame.shot.isCard {
            words.font(.system(size: max(26, bar * 0.52), weight: .black, design: .rounded))
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                words.font(.system(size: max(16, bar * 0.30), weight: .heavy, design: .rounded))
            }
            .padding(.bottom, bar + 26)
        }
    }

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
        .padding(.top, bar + 16)
        .opacity(offersTheWayOut ? 1 : 0)
        .allowsHitTesting(offersTheWayOut)
    }
}

/// Plays whichever kind of film a world hands over — the meadow's painted `CutScene`, or a
/// themed world's `StorybookScene` — so a screen that presents a world film need not know which.
@MainActor
struct WorldFilmView: View {
    let film: WorldFilm
    let onFinish: () -> Void

    var body: some View {
        switch film {
        case .painted(let scene): CutSceneView(scene, onFinish: onFinish)
        case .storybook(let scene): StorybookSceneView(scene, onFinish: onFinish)
        }
    }
}

#Preview("Opening") {
    StorybookSceneView(.thornwoodOpening()) {}
}

#Preview("Send-off") {
    StorybookSceneView(.thornwoodHeld()) {}
}
