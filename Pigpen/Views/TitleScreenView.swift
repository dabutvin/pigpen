import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a name that plants itself a letter at
/// a time like a run of fence, a Play button that is impossible to miss, and a Tutorial
/// beside it for anyone who wants the walkthrough before the meadow.
@MainActor
struct TitleScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// How much of the name has been driven into the ground, 0 to 1.
    @State private var planted: Double = 0
    /// The board under the name, the tally and the buttons all arrive a beat behind the
    /// lettering.
    @State private var arrived = false
    @State private var isPlaying = false
    @State private var isTutorial = false
    @State private var showsSettings = false
    /// The opening film, over the title screen. It plays over this rather than pushing the
    /// map behind it, so that the stack stays a title screen with a map on top of it and
    /// the way back off the map is the way it always was.
    @State private var showsOpening = false
    /// Whether the film that has just come down was the real thing rather than a player
    /// changing their mind, and so whether the map is what happens next.
    @State private var openingLedToTheMap = false
    /// The same progress the map is handed, so the stars on the tally above are the ones
    /// just won — and go the moment they are cleared from the settings sheet.
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
                topBar

                wordmark

                Spacer(minLength: 12)

                playBlock
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
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
        // The map is pushed as the film comes down rather than from inside it, so the two
        // never fight over the screen.
        .fullScreenCover(isPresented: $showsOpening, onDismiss: { openTheMeadow() }) {
            CutSceneView(.opening()) { endTheOpening() }
        }
        .onAppear {
            // The map keeps its own copy of the stars while it is up; read them back so a
            // player coming off the trail sees the ones they have just taken.
            progress.reload()
            raiseTheCurtain()
        }
    }

    // MARK: - The bar across the top

    /// How much of the meadow has been taken, and a gear well away from Play. What is
    /// behind the gear — the version, and a button that throws away every star — is
    /// nothing a player needs while they are playing.
    private var topBar: some View {
        HStack(spacing: 10) {
            starTally

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
        .padding(.bottom, 26)
    }

    /// The running total, up here where it is a badge rather than small print under the
    /// buttons. How much mud three stars takes on any given puzzle is left for the player
    /// to find out by taking it.
    private var starTally: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(GamePalette.pen)
                .shadow(color: GamePalette.post.opacity(0.25), radius: 0.5, y: 0.5)

            Text("\(progress.totalStars) of \(world.starTotal)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(Capsule().fill(GamePalette.cream.opacity(0.94)))
        .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(progress.totalStars) of \(world.starTotal) stars")
    }

    // MARK: - The name

    private var wordmark: some View {
        VStack(spacing: 16) {
            PlantedWord(word: "PIGPEN", size: 54, planted: planted)

            tagline
                .opacity(arrived ? 1 : 0)
                .scaleEffect(arrived ? 1 : 0.88)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pigpen. Fence in the pig.")
    }

    /// A board nailed up under the name, lit from above like the buttons are, with a nail
    /// head holding down each end of it.
    private var tagline: some View {
        Text("Fence in the pig")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 9)
            .padding(.horizontal, 26)
            .background(plank)
            .overlay(nailHeads)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 4)
            .rotationEffect(.degrees(-2))
    }

    private var plank: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(GamePalette.picket)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.42), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.28), lineWidth: 1.5)
            }
    }

    private var nailHeads: some View {
        HStack(spacing: 0) {
            nailHead
            Spacer(minLength: 0)
            nailHead
        }
        .padding(.horizontal, 9)
    }

    private var nailHead: some View {
        Circle()
            .fill(GamePalette.post.opacity(0.45))
            .frame(width: 6, height: 6)
    }

    // MARK: - Play

    private var playBlock: some View {
        VStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                play()
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

    /// Where Play leads, and what it is played for.
    private var signpost: some View {
        VStack(spacing: 3) {
            Text("\(world.name) · \(world.count) puzzles")
                .font(.footnote.weight(.heavy))
            Text("Pen in as much mud as you can")
                .font(.caption2.weight(.semibold))
                .opacity(0.85)
        }
        .foregroundStyle(GamePalette.cream)
        .multilineTextAlignment(.center)
        .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
        .padding(.top, 2)
    }

    // MARK: - Play

    /// Where Play goes: up the trail, or — the first time anybody presses it on a world
    /// with nothing won on it — through the film first.
    private func play() {
        if progress.isTheOpeningDue {
            showsOpening = true
        } else {
            isPlaying = true
        }
    }

    /// The film is over, watched or skipped. It has had its one showing either way, and the
    /// meadow is what it was always leading to.
    private func endTheOpening() {
        progress.markPlayed(.opening)
        openingLedToTheMap = true
        showsOpening = false
    }

    /// Called as the film comes down. A player who somehow leaves it by another road than
    /// the one above is simply put back on the title screen.
    private func openTheMeadow() {
        guard openingLedToTheMap else { return }
        openingLedToTheMap = false
        isPlaying = true
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

/// The name, set a letter at a time like a run of fence posts: each letter drops in, turns
/// straight and settles, and the one to its right follows it into the ground.
private struct PlantedWord: View {
    let word: String
    let size: CGFloat
    /// How much of the word is in the ground, 0 to 1. Values a little over 1 let the last
    /// letters overshoot, which is what gives the wordmark its pop.
    let planted: Double

    private var letters: [Character] { Array(word) }

    var body: some View {
        HStack(spacing: size * 0.06) {
            ForEach(letters.indices, id: \.self) { index in
                let landed = landing(of: index)
                let settling = 1 - min(landed, 1)

                lettering(letters[index])
                    .opacity(min(landed, 1))
                    .scaleEffect(CGFloat(0.7 + 0.3 * landed))
                    .rotationEffect(.degrees(-9 * settling))
                    .offset(y: -size * 0.45 * CGFloat(settling))
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
    }

    private func lettering(_ letter: Character) -> some View {
        ZStack {
            // A dark copy behind the letter gives it its cut-out edge.
            glyph(letter)
                .foregroundStyle(GamePalette.post)
                .offset(y: 4)

            glyph(letter)
                .foregroundStyle(
                    LinearGradient(
                        colors: [GamePalette.cream, GamePalette.pen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private func glyph(_ letter: Character) -> Text {
        Text(String(letter))
            .font(.system(size: size, weight: .black, design: .rounded))
    }

    /// Each letter waits its turn, then has the back half of the run to itself.
    private func landing(of index: Int) -> Double {
        guard letters.count > 1 else { return max(0, planted) }
        let turn = 0.5 * Double(index) / Double(letters.count - 1)
        return max(0, (planted - turn) / 0.5)
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
