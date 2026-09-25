import SwiftUI

/// The App Store preview video, played by the app itself.
///
/// Apple takes an app preview only as a recording of the app, so the App Store Assets
/// workflow records the simulator while this plays. It follows the preview on the live
/// listing, which is the source of truth, beat for beat — twenty seconds cut across three
/// boards at a player's pace, made to loop:
///
/// 1. The Great Floe's best pen, let go into: the lap of honour, confetti and all.
/// 2. Windfall Orchard from bare mud, its twelve pieces tapped in quickly — down the west
///    side, along the foot, back up the east — and the pig let go.
/// 3. Smoulder Ridge with three pieces left to lay, laid, and let go.
/// 4. The Great Floe with three pieces left: laid, let go, the verdict card, and *Start
///    over*, which leaves the bare floe the film loops back to the top of.
///
/// Every beat is on a fixed clock, so the same film comes out of every run. The reel opens
/// with `preRoll` held still on the first board, which is slack for the recording to
/// settle, and when the film proper starts it prints the moment to standard output
/// (`startMark`), which the workflow reads to cut the recording to the twenty seconds after.
struct PreviewReel: View {
    /// The boards the film cuts between, in the order it shows them.
    enum Board: Hashable {
        case floeHeld, orchard, smoulder, floe
    }

    @State private var board: Board = .floeHeld
    @State private var game = PuzzleGame.theGreatFloesBestPen()

    /// The still first board held before the film proper starts: slack the workflow cuts
    /// off, so the recording never has to catch the app's launch exactly.
    static let preRoll: Duration = .seconds(4)
    /// The gap in seconds between one tap and the next — a player who knows where the
    /// wall goes.
    static let perPiece = 0.37
    /// How long the film proper runs, which is what the workflow cuts it to.
    static let length: Duration = .seconds(20)
    /// What the reel prints, followed by the time since 1970 in seconds, the moment the
    /// film proper starts. The workflow finds this line in the app's standard output.
    static let startMark = "PREVIEW_REEL_START"

    /// The orchard's best pen in the order a player lays it: down the west side, along
    /// the foot, and back up the east. The same twelve pieces
    /// `PuzzleGame.theOrchardsBestPen()` lays, which `PuzzleGameTests` holds it to.
    static let orchardPieces: [GridPoint] = {
        let west = (3...8).map { GridPoint(row: $0, column: max(0, $0 - 5)) }
        let east = (3...8).reversed().map { GridPoint(row: $0, column: 12 - $0) }
        return west + east
    }()

    /// The last three pieces of Smoulder Ridge's best pen, down its west side; the rest is
    /// already standing when the film cuts to it.
    static let smoulderLastPieces = [
        GridPoint(row: 4, column: 1), GridPoint(row: 5, column: 0), GridPoint(row: 6, column: 0)
    ]

    /// The last three pieces of the Great Floe's best pen, down its east side.
    static let floeLastPieces = [
        GridPoint(row: 5, column: 11), GridPoint(row: 6, column: 11), GridPoint(row: 7, column: 10)
    ]

    /// A board with its best pen standing but for `pieces`, which the film lays itself.
    static func bestPen(_ best: PuzzleGame, leaving pieces: [GridPoint]) -> PuzzleGame {
        PuzzleGame(level: best.level, fences: best.fences.subtracting(pieces))
    }

    var body: some View {
        ZStack {
            // A new board is a new screen, not the old one rearranged.
            field.id(board)
        }
        // Outside the id, so a cut to the next board does not start the film over.
        .task { await play() }
    }

    @ViewBuilder
    private var field: some View {
        switch board {
        case .orchard:
            PuzzleView(game: game)
        case .smoulder:
            PuzzleView(
                game: game,
                treatSkin: WorldTheme.emberpeak.treats,
                skin: WorldTheme.emberpeak.field,
                day: .emberDay,
                chrome: WorldTheme.emberpeak.chrome
            )
        case .floeHeld, .floe:
            PuzzleView(
                game: game,
                treatSkin: WorldTheme.frostwhiskerTundra.treats,
                skin: WorldTheme.frostwhiskerTundra.field,
                day: .frostDay,
                chrome: WorldTheme.frostwhiskerTundra.chrome
            )
        }
    }

    private func play() async {
        // The floe's pen, held still until the film starts, then let go into.
        await wait(Self.preRoll)
        let start = ContinuousClock.now
        markTheStart()
        // Every beat is set against the film's own start rather than after the one
        // before it, so a slow simulator can make a beat late but never makes the rest
        // of the film later with it. The times are the listing's preview, beat for beat.
        func at(_ seconds: Double) async {
            try? await Task.sleep(until: start + .milliseconds(Int(seconds * 1000)), clock: .continuous)
        }
        game.openTheGate()

        // The orchard, laid from bare mud.
        await at(2.0)
        cut(to: .orchard, PuzzleGame(level: .windfallOrchard))
        for (i, tile) in Self.orchardPieces.enumerated() {
            await at(2.3 + Double(i) * Self.perPiece)
            lay(tile)
        }
        await at(6.7)
        game.openTheGate()

        // The ridge, finished off.
        await at(8.0)
        cut(to: .smoulder, Self.bestPen(.theSmoulderRidgesBestPen(), leaving: Self.smoulderLastPieces))
        for (i, tile) in Self.smoulderLastPieces.enumerated() {
            await at(8.3 + Double(i) * Self.perPiece)
            lay(tile)
        }
        await at(9.3)
        game.openTheGate()

        // The floe, finished off, held, and cleared for the loop.
        await at(11.0)
        cut(to: .floe, Self.bestPen(.theGreatFloesBestPen(), leaving: Self.floeLastPieces))
        for (i, tile) in Self.floeLastPieces.enumerated() {
            await at(11.3 + Double(i) * Self.perPiece)
            lay(tile)
        }
        await at(12.4)
        game.openTheGate()
        await at(17.5)
        game.startOver()
    }

    /// Says when the film proper starts. Written straight to the file descriptor rather
    /// than through `print`, which buffers when standard output is not a terminal.
    private func markTheStart() {
        let line = "\(Self.startMark) \(Date().timeIntervalSince1970)\n"
        FileHandle.standardOutput.write(Data(line.utf8))
    }

    private func cut(to next: Board, _ nextGame: PuzzleGame) {
        game = nextGame
        board = next
    }

    private func lay(_ tile: GridPoint) {
        game.beginStroke()
        if game.buildFence(on: tile) {
            Haptics.tap(.rigid)
            Sounds.play(.fenceIn)
        }
        game.endStroke()
    }

    private func wait(_ duration: Duration) async {
        try? await Task.sleep(for: duration)
    }
}
