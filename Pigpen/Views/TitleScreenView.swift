import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a name that plants itself a letter at
/// a time like a run of fence, and a Play button that is impossible to miss.
///
/// Under Play is the day's own board on a card of its own — what day it is, what that day
/// asks, and once it has been held, the stars it gave up, the time it took and the run of
/// days it is part of. Under that, the archive of every daily there has been this year, and
/// the tutorial for anybody who wants the walkthrough before the meadow.
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
    @State private var isDailyOpen = false
    @State private var restoreSubmittedDaily = false
    @State private var isOfferingSubmittedDaily = false
    @State private var isArchiveOpen = false
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
    /// The same book of days the archive and today's board are handed, so the card below
    /// shows the stars that were just won without having to be told about them.
    @State private var daily: DailyProgress
    /// Which square of the calendar the game is standing on. Read once when the screen
    /// arrives rather than on every redraw, so the card cannot change under a finger — and
    /// read again every time the screen comes back, which is what carries a player over
    /// midnight onto tomorrow's puzzle.
    @State private var today: DailyDate
    /// Whether the day was handed in rather than asked of the phone. A screenshot run opens
    /// on a fixed square of the calendar, and must not have the screen quietly put it back
    /// to whatever day the runner is having.
    private let dayWasGiven: Bool

    /// - Parameters:
    ///   - today: The day the game is being played on, or nothing at all to ask the phone.
    ///     Handed in so the previews and the screenshot runs open on a known square of the
    ///     calendar.
    ///   - showsSettings: Opens with the settings sheet already up, which is how CI
    ///     photographs it without tapping through the title screen.
    init(
        progress: WorldProgress = WorldProgress(),
        daily: DailyProgress = DailyProgress(),
        today: DailyDate? = nil,
        showsSettings: Bool = false
    ) {
        _progress = State(initialValue: progress)
        _daily = State(initialValue: daily)
        _today = State(initialValue: today ?? .today())
        dayWasGiven = today != nil
        _showsSettings = State(initialValue: showsSettings)
    }

    private var world: WorldMap { progress.world }
    private var hasADailyPuzzle: Bool { DailyAlmanac.holdsAPuzzle(on: today) }

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
        .navigationDestination(isPresented: $isDailyOpen) {
            DailyPuzzleView(
                date: today,
                progress: daily,
                restoreSubmitted: restoreSubmittedDaily
            )
        }
        .confirmationDialog(
            today.fullTitle,
            isPresented: $isOfferingSubmittedDaily,
            titleVisibility: .visible
        ) {
            Button("Put it back") {
                restoreSubmittedDaily = true
                isDailyOpen = true
            }
            Button("Play again") {
                // Clear the field means clear the field: the board filed away when the day
                // was left is the submitted wall itself, so it has to go or *Play again*
                // opens on the very wall *Put it back* offers. The wall stays on the books
                // — the trophy still has it once the new field is somewhere else.
                daily.clearDraft(on: today)
                restoreSubmittedDaily = false
                isDailyOpen = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Put the fencing back the way you submitted it, or clear the field and try again.")
        }
        .navigationDestination(isPresented: $isArchiveOpen) {
            DailyArchiveView(today: today, progress: daily)
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView(progress: progress, daily: daily)
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
            daily.reload()
            // A game left open overnight comes back to a new day's puzzle rather than to
            // yesterday's, already held.
            if !dayWasGiven { today = .today() }
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

            signpost

            dailyButton

            HStack(spacing: 10) {
                sideButton("Archive", systemImage: "calendar") {
                    isArchiveOpen = true
                }
                .accessibilityHint("Every daily puzzle of the year, a month at a time")

                sideButton("Tutorial", systemImage: "hand.tap.fill") {
                    isTutorial = true
                }
                .accessibilityHint("Walk through how to fence in the pig")
            }
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// Today's board, as a card rather than a button: what day it is, what the day asks,
    /// and once it has been held, the stars and the time it gave up. A day with nothing in
    /// the almanac still gets its card, saying so — better than a button that does nothing.
    private var dailyButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            openToday()
        } label: {
            DailyCard(
                date: today,
                stars: daily.stars(on: today),
                hasTheBestPen: daily.hasTheBestPen(on: today),
                bestTime: daily.bestTime(on: today),
                streak: daily.streak(upTo: today),
                hasAPuzzle: hasADailyPuzzle
            )
        }
        .buttonStyle(SignpostButtonStyle())
        .disabled(!hasADailyPuzzle)
        .padding(.top, 2)
    }

    /// Opens today's board, or — once a wall has been submitted — offers to put that wall
    /// back before the field comes up empty.
    private func openToday() {
        if daily.submittedFences(on: today) != nil {
            isOfferingSubmittedDaily = true
        } else {
            restoreSubmittedDaily = false
            isDailyOpen = true
        }
    }

    /// The two smaller ways off this screen, painted on the same boards the puzzle's own
    /// buttons are.
    private func sideButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlaqueButtonStyle(padding: 8))
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

#Preview("A week of dailies in") {
    NavigationStack {
        TitleScreenView(
            progress: .partWayThrough(),
            daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
            today: DailyDate(year: 2026, month: 4, day: 22)
        )
    }
}
