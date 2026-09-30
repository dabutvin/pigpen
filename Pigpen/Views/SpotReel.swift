import SwiftUI

/// The commercial: nine seconds of the game selling itself, played by the app.
///
/// The listing's preview shows a player at work. This is the other film — the one shown to
/// somebody who has never heard of the game, in a feed, with the sound on, once — so it has
/// to say the whole rule in a breath and end on the name. It is a joke with a payoff, and
/// the game already has both halves of it: a pig that finds the gap, and a pig that
/// cannot.
///
/// The storyboard, on the film's own clock:
///
/// 1. **The gap.** Windfall Orchard with eleven of its twelve pieces standing and one left
///    on the rack, the foot of the wall open by a single tile. Held for a moment, then the
///    gate opens and the pig walks straight down through the gap and off the map. *Pig
///    walked out.*
/// 2. **The fix.** The pig is fetched back, the last piece knocks in where the gap was,
///    and the ground washes rainbow: the best pen the orchard has in it.
/// 3. **The payoff.** The gate opens again. Nowhere to go, so the lap of honour, the hop,
///    the confetti, three stars.
/// 4. **The name.** Cut to the pasture, PIGPEN planted a letter at a time the way the title
///    screen plants it, *Build the perfect pen* hung under it, and the pig trotting along
///    the fence until the film ends.
///
/// Like the preview, every beat is on a fixed clock counted from the film's start, so the
/// same film comes out of every run, and the reel opens with `preRoll` held still on the
/// first board for the recording to settle. When the film proper starts it prints
/// `startMark` and the moment, which the workflow reads to cut the recording. The
/// simulator records no sound, so the reel also prints every noise the game makes and when
/// it made it (`soundMark`), and the workflow lays the same files under the cut at those
/// moments, over the game's own tune. Nothing in the film is drawn for the film: the board,
/// the walk, the lap, the card and the pasture are the game's own views, which is the
/// point — what the spot shows is what the app does.
struct SpotReel: View {
    /// The two screens the film cuts between.
    enum Scene: Hashable {
        case board, endCard
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scene: Scene = .board
    @State private var game = SpotReel.theOrchardShortOfItsLastPiece()
    /// The name's way in on the end card: planted from 0 to 1, and the sign under it arriving
    /// a beat behind, on the title screen's own springs.
    @State private var planted: Double = 0
    @State private var arrived = false

    /// The still first board held before the film proper starts: slack the workflow cuts
    /// off, so the recording never has to catch the app's launch exactly.
    static let preRoll: Duration = .seconds(4)
    /// How long the film proper runs, which is what the workflow cuts it to. A spot is six
    /// to ten seconds; this one takes nine, and the last two and a half of them are the name.
    static let length: Duration = .seconds(9)
    /// What the reel prints, followed by the time since 1970 in seconds, the moment the
    /// film proper starts. The workflow finds this line in the app's standard output.
    static let startMark = "SPOT_REEL_START"
    /// What the reel prints, followed by a sound's file name and the seconds into the film it
    /// was asked for, every time the game makes a noise. The workflow lays the soundtrack
    /// from these lines. A negative time is a noise made during the pre-roll, which the
    /// workflow leaves out.
    static let soundMark = "SPOT_REEL_SOUND"

    /// The piece the orchard's best pen is short of when the film opens: the western of the
    /// two at the foot of the wall, straight below the pig, so the walk out is a straight
    /// march down the middle of the pen, between the apples and out through the gap.
    static let lastPiece = GridPoint(row: 8, column: 3)

    /// When each thing happens, in seconds from the film's start. The gaps between them are
    /// the game's own animations, which are on clocks of their own: the walk out takes the
    /// pig about two seconds to be off the map and the card up, and the lap of honour about
    /// one and a half to be back on its tile and the card up through the confetti.
    enum Beat {
        /// The gate opens on the board with the gap in it.
        static let release = 0.6
        /// The pig is fetched back and the card goes down.
        static let fetchBack = 3.2
        /// The last piece goes in, and the ground washes rainbow.
        static let lastPiece = 3.5
        /// The gate opens on the pen that holds.
        static let releaseAgain = 4.1
        /// Cut to the name.
        static let endCard = 6.6
    }

    /// Windfall Orchard with its best pen standing but for `lastPiece`, which the film lays
    /// itself. `PuzzleGameTests` holds it to being one piece short, open, and let out of by
    /// the foot of the wall — and closed and held by that one piece.
    static func theOrchardShortOfItsLastPiece() -> PuzzleGame {
        let best = PuzzleGame.theOrchardsBestPen()
        return PuzzleGame(level: best.level, fences: best.fences.subtracting([lastPiece]))
    }

    var body: some View {
        ZStack {
            switch scene {
            case .board:
                PuzzleView(game: game)
            case .endCard:
                endCard
            }
        }
        // Outside the switch, so the cut to the name does not start the film over.
        .task { await play() }
    }

    // MARK: - The name

    /// The pasture behind the title with the name over it and nothing else: no tally, no
    /// gear, no menu. The title screen's own pieces, on the title screen's own springs, so
    /// the name arrives in the film the way it arrives in the app.
    private var endCard: some View {
        ZStack {
            TitleSceneView()
                .ignoresSafeArea()

            VStack(spacing: 18) {
                PlantedWord(word: "PIGPEN", size: 84, planted: planted)
                    // Over the sign, for the same reason the title screen puts it there.
                    .zIndex(1)

                Text("Build the perfect pen")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 28)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(GamePalette.signboard)
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
                    .opacity(arrived ? 1 : 0)
                    .scaleEffect(arrived ? 1 : 0.88)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            // Where the title screen's name sits: under the bar the tally and the gear
            // stand in, over the open band of pasture the fence runs through.
            .padding(.top, 96)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Pigpen. Build the perfect pen.")
        }
        .onAppear(perform: raiseTheCurtain)
    }

    /// The title screen's own timing: the name springs into the ground, and the sign
    /// arrives under it a beat behind. Nothing moves for a player who has asked for less
    /// motion; the name is simply there.
    private func raiseTheCurtain() {
        guard !reduceMotion else {
            planted = 1
            arrived = true
            return
        }
        withAnimation(.spring(duration: 0.9, bounce: 0.4)) { planted = 1 }
        withAnimation(.spring(duration: 0.6, bounce: 0.3).delay(0.45)) { arrived = true }
    }

    // MARK: - The film

    private func play() async {
        // Every noise from here on is written down against the film's clock, the pre-roll's
        // included, so the workflow has the whole beat sheet and can leave out what came
        // before the start.
        let start = ContinuousClock.now + Self.preRoll
        Sounds.shared.listener = { sound in
            Self.markTheSound(sound, at: ContinuousClock.now - start)
        }

        // The board with the gap in it, held still until the film starts.
        try? await Task.sleep(until: start, clock: .continuous)
        Self.markTheStart()
        // Every beat is set against the film's own start rather than after the one before
        // it, so a slow simulator can make a beat late but never makes the rest of the film
        // later with it.
        func at(_ seconds: Double) async {
            try? await Task.sleep(until: start + .milliseconds(Int(seconds * 1000)), clock: .continuous)
        }

        // The gap: the pig walks out of it.
        await at(Beat.release)
        game.openTheGate()

        // The fix: fetched back, and the last piece in where the gap was.
        await at(Beat.fetchBack)
        game.resumeBuilding()
        await at(Beat.lastPiece)
        lay(Self.lastPiece)

        // The payoff: nowhere to go.
        await at(Beat.releaseAgain)
        game.openTheGate()

        // The name.
        await at(Beat.endCard)
        scene = .endCard
    }

    /// Says when the film proper starts. Written straight to the file descriptor rather
    /// than through `print`, which buffers when standard output is not a terminal.
    private static func markTheStart() {
        write("\(Self.startMark) \(Date().timeIntervalSince1970)\n")
    }

    /// Says what noise the game just made, and how far into the film it made it.
    private static func markTheSound(_ sound: Sound, at into: Duration) {
        let seconds = Double(into.components.seconds)
            + Double(into.components.attoseconds) / 1e18
        write("\(Self.soundMark) \(sound.rawValue) \(String(format: "%.3f", seconds))\n")
    }

    private static func write(_ line: String) {
        FileHandle.standardOutput.write(Data(line.utf8))
    }

    private func lay(_ tile: GridPoint) {
        game.beginStroke()
        if game.buildFence(on: tile) {
            Haptics.tap(.rigid)
            Sounds.play(.fenceIn)
        }
        game.endStroke()
    }
}
