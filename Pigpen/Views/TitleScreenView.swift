import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a wordmark that plants itself like a
/// run of fence, and one button that is impossible to miss.
@MainActor
struct TitleScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// How much of the cipher wordmark has been driven into the ground, 0 to 1.
    @State private var planted: Double = 0
    /// The lettering, the sign and the button all arrive a beat behind the glyphs.
    @State private var arrived = false
    @State private var isPlaying = false

    private let level = PuzzleLevel.riverBend

    var body: some View {
        ZStack {
            TitleSceneView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                wordmark

                Spacer(minLength: 12)

                playBlock
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 18)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isPlaying) {
            PuzzleView(level: level)
        }
        .onAppear(perform: raiseTheCurtain)
    }

    // MARK: - Wordmark

    private var wordmark: some View {
        VStack(spacing: 12) {
            PigpenWordView(word: "PIGPEN", glyphSize: 38, lineWidth: 5, planted: planted)
                .foregroundStyle(GamePalette.cream)
                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)

            ZStack {
                // A dark copy behind the letters gives the wordmark its cut-out edge.
                lettering.foregroundStyle(GamePalette.post).offset(y: 4)
                lettering.foregroundStyle(
                    LinearGradient(
                        colors: [GamePalette.cream, GamePalette.pen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
            .scaleEffect(arrived ? 1 : 0.8)
            .opacity(arrived ? 1 : 0)

            tagline
                .opacity(arrived ? 1 : 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pigpen. Fence in the pig.")
    }

    private var lettering: some View {
        Text("PIGPEN")
            .font(.system(size: 46, weight: .black, design: .rounded))
            .tracking(5)
    }

    /// A little board nailed up under the name.
    private var tagline: some View {
        Text("Fence in the pig")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 7)
            .padding(.horizontal, 16)
            .background(Capsule().fill(GamePalette.cream.opacity(0.94)))
            .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
            .rotationEffect(.degrees(-2))
    }

    // MARK: - Play

    private var playBlock: some View {
        VStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                isPlaying = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(GamePalette.post)
                .frame(maxWidth: 180)
            }
            .buttonStyle(ChunkyButtonStyle())
            .modifier(Breathing(active: !reduceMotion))

            signpost
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// What the one puzzle in the game is, and what it takes to beat it properly.
    private var signpost: some View {
        VStack(spacing: 3) {
            Text("Puzzle 1 · \(level.name)")
                .font(.footnote.weight(.heavy))
            Text("\(level.fenceBudget) fence pieces · \(level.threeStarArea) mud tiles for three stars")
                .font(.caption2.weight(.semibold))
                .opacity(0.85)
            Text("Version \(appVersion)")
                .font(.caption2)
                .opacity(0.55)
                .padding(.top, 2)
        }
        .foregroundStyle(GamePalette.cream)
        .multilineTextAlignment(.center)
        .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
    }

    // MARK: - Timing

    private func raiseTheCurtain() {
        guard !reduceMotion else {
            planted = 1
            arrived = true
            return
        }
        withAnimation(.spring(duration: 0.9, bounce: 0.4)) { planted = 1 }
        withAnimation(.spring(duration: 0.6, bounce: 0.3).delay(0.45)) { arrived = true }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }
}

/// A slow pulse to hold the eye on the button. It has to be a phase animator rather than a
/// repeating animation on a flag: the flag flips as the button is arriving, and a repeating
/// animation would take the arrival with it and swing the button about the screen for good.
private struct Breathing: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content.phaseAnimator([1.0, 1.04]) { button, scale in
                button.scaleEffect(CGFloat(scale))
            } animation: { _ in
                .easeInOut(duration: 1.5)
            }
        } else {
            content
        }
    }
}

#Preview {
    NavigationStack {
        TitleScreenView()
    }
}
