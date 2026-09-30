import SwiftUI

/// The middle of the commercial: the board, played by the app.
///
/// The spot is nine seconds in three parts, and only this one is the app. It opens on a
/// painted 3D pig — `Tools/spot/pig.html`, rendered by the store job — who trots along
/// behind a fence, finds the one gap in it, gives the camera a look, and bolts out through
/// the gap past the lens. Cut to this: the board, and a player shutting her in. Then the pig
/// again, up on her hind legs against the fence with the name over her. The listing's preview shows a
/// player at work; the spot is shown to somebody who has never heard of the game, in a
/// feed, with the sound on, once, so it tells the whole rule as a joke with a payoff, and
/// the board is the payoff.
///
/// What this plays, on the film's own clock:
///
/// 1. **The wall, half built.** Windfall Orchard with the west side and the foot of its best
///    pen standing and the whole east side open, six pickets on the rack. Held for a
///    moment, so the eye finds the board.
/// 2. **The play.** The six go in one after another, up the east side from the foot, at
///    the pace of a player who knows where the wall goes — and on the last one the ground
///    washes rainbow: the best pen the orchard has in it.
/// 3. **The payoff.** The gate opens. Nowhere to go, so the lap of honour, the hop, the
///    confetti, three stars, held until the cut.
///
/// Like the preview, every beat is on a fixed clock counted from the film's start, so the
/// same film comes out of every run, and the reel opens with `preRoll` held still for the
/// recording to settle. When the film proper starts it prints `startMark`, the moment and
/// the film's length, which the workflow reads to cut the recording. The simulator records
/// no sound, so the reel also prints every noise the game makes and when it made it
/// (`soundMark`), and the workflow lays the same files under the cut at those moments, over
/// the game's own tune. Nothing here is drawn for the film: the board, the knock, the lap
/// and the card are the game's own views, which is the point — what the spot shows the app
/// doing is what the app does.
struct SpotReel: View {
    @State private var game = SpotReel.theOrchardShortOfItsEastSide()

    /// The still board held before the film proper starts: slack the workflow cuts off, so
    /// the recording never has to catch the app's launch exactly.
    static let preRoll: Duration = .seconds(4)
    /// How long the film proper runs, which is what the workflow cuts it to: six pieces, the
    /// lap of honour, and the card with three stars on it held long enough to read.
    static let length: Duration = .milliseconds(4100)
    /// What the reel prints, followed by the time since 1970 in seconds and the film's
    /// length in seconds, the moment the film proper starts. The workflow finds this line in
    /// the app's standard output.
    static let startMark = "SPOT_REEL_START"
    /// What the reel prints, followed by a sound's file name and the seconds into the film it
    /// was asked for, every time the game makes a noise. The workflow lays the soundtrack
    /// from these lines. A negative time is a noise made during the pre-roll, which the
    /// workflow leaves out.
    static let soundMark = "SPOT_REEL_SOUND"

    /// The pieces the film lays: the east side of the orchard's best pen, from the foot up,
    /// which is the second half of the order the preview lays the whole pen in. The west
    /// side and the foot are already standing when the film opens. `PuzzleGameTests` holds
    /// the board to being open until the last of them, and closed and held by it.
    static let pieces = Array(PreviewReel.orchardPieces.suffix(6))

    /// When each thing happens, in seconds from the film's start. The gap after the last
    /// piece is the game's own animation, which is on a clock of its own: the lap of honour
    /// takes about a second and a half to be back on its tile with the card up through the
    /// confetti.
    enum Beat {
        /// The first piece goes in; the rest follow at `perPiece`.
        static let firstPiece = 0.2
        /// The gap between one piece and the next: quicker than the preview's player, since
        /// a spot has no time to spare, and every knock still lands as its own.
        static let perPiece = 0.2
        /// When the last piece goes in, and the ground washes rainbow.
        static var lastPiece: Double { firstPiece + Double(SpotReel.pieces.count - 1) * perPiece }
        /// The gate opens on the pen that holds. The lap of honour is a second and a half on
        /// paper and runs a quarter second longer on a simulator, and the card with three
        /// stars on it wants most of a second before the cut, which is what sets this.
        static let release = 1.5
    }

    /// Windfall Orchard with its best pen standing but for `pieces`, which the film lays
    /// itself.
    static func theOrchardShortOfItsEastSide() -> PuzzleGame {
        PreviewReel.bestPen(.theOrchardsBestPen(), leaving: pieces)
    }

    var body: some View {
        PuzzleView(game: game)
            .task { await play() }
    }

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

        // The play: the east side, up from the foot.
        for (i, tile) in Self.pieces.enumerated() {
            await at(Beat.firstPiece + Double(i) * Beat.perPiece)
            lay(tile)
        }

        // The payoff: nowhere to go.
        await at(Beat.release)
        game.openTheGate()
    }

    /// Says when the film proper starts, and how long it runs. Written straight to the file
    /// descriptor rather than through `print`, which buffers when standard output is not a
    /// terminal.
    private static func markTheStart() {
        write("\(startMark) \(Date().timeIntervalSince1970) \(seconds(of: length))\n")
    }

    /// Says what noise the game just made, and how far into the film it made it.
    private static func markTheSound(_ sound: Sound, at into: Duration) {
        write("\(soundMark) \(sound.rawValue) \(String(format: "%.3f", seconds(of: into)))\n")
    }

    private static func seconds(of duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
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
