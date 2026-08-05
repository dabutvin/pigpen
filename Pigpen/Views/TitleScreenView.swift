import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a wordmark that plants itself like a
/// run of fence, a Play button that is impossible to miss, and a Tutorial beside it for
/// anyone who wants the walkthrough before the meadow.
@MainActor
struct TitleScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// How much of the cipher wordmark has been driven into the ground, 0 to 1.
    @State private var planted: Double = 0
    /// The lettering, the sign and the button all arrive a beat behind the glyphs.
    @State private var arrived = false
    @State private var isPlaying = false
    @State private var isTutorial = false
    @State private var showsSettings = false
    /// The same progress the map is handed, so the stars on the signpost below are the
    /// ones just won — and go the moment they are cleared from the settings sheet.
    @State private var progress: WorldProgress

    /// - Parameter showsSettings: Opens with the settings sheet already up, which is how
    ///   CI photographs it without tapping through the title screen.
    init(progress: WorldProgress = WorldProgress(), showsSettings: Bool = false) {
        _progress = State(initialValue: progress)
        _showsSettings = State(initialValue: showsSettings)
    }

    private var world: WorldMap { progress.world }

    var body: some View {
        ZStack {
            TitleSceneView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                settingsBar

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
            WorldMapView(progress: progress)
        }
        .navigationDestination(isPresented: $isTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView(progress: progress)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            // The map keeps its own copy of the stars while it is up; read them back so a
            // player coming off the trail sees the ones they have just taken.
            progress.reload()
            raiseTheCurtain()
        }
    }

    // MARK: - Settings

    /// A gear in the corner, small and well away from Play. What is behind it — the
    /// version, and a button that throws away every star — is nothing a player needs
    /// while they are playing.
    private var settingsBar: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showsSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(GamePalette.cream.opacity(0.94)))
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            }
            .accessibilityLabel("Settings")
        }
        .opacity(arrived ? 1 : 0)
        .padding(.bottom, 10)
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

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isTutorial = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                    Text("Tutorial")
                }
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(GamePalette.cream)
                .frame(maxWidth: 180)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 5))
            .accessibilityHint("Walk through how to fence in the pig")

            signpost
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// Where Play leads, and how much of it is left. How much mud three stars takes on
    /// any given puzzle is left for the player to find out by taking it.
    private var signpost: some View {
        VStack(spacing: 3) {
            Text("\(world.name) · \(world.count) puzzles")
                .font(.footnote.weight(.heavy))
            Text("\(progress.totalStars) of \(world.starTotal) stars · pen in as much mud as you can")
                .font(.caption2.weight(.semibold))
                .opacity(0.85)
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

#Preview("Settings up") {
    NavigationStack {
        TitleScreenView(progress: .partWayThrough(), showsSettings: true)
    }
}
