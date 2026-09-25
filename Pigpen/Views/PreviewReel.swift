import SwiftUI

/// Windfall Orchard playing itself, for the App Store preview video.
///
/// Apple takes an app preview only as a recording of the app, so the App Store Assets
/// workflow records the simulator while this plays: the board sits a moment, the best pen
/// the orchard has in it goes down a piece at a time the way a player taps it in — down
/// the west side, then back up the east — and the pig is let go to find it holds. The
/// lap of honour and the verdict card are the real ones, since the field underneath is.
///
/// Every beat is on a fixed clock, so the same film comes out of every run and the
/// recording can be cut at a fixed length without catching the reel part way through
/// a beat it did not have to be in.
struct PreviewReel: View {
    @State private var game = PuzzleGame(level: .windfallOrchard)

    /// How long the untouched board is held before the first piece goes in, which is also
    /// the slack the recording has to start in — an iPad simulator can take three seconds
    /// or more to start recording, and the film should still open on a bare board there.
    static let opening: Duration = .seconds(5)
    /// The gap between one piece and the next: slow enough to follow, quick enough that
    /// twelve of them leave room in thirty seconds for the pig.
    static let perPiece: Duration = .milliseconds(850)
    /// The breath between the last piece and the gate.
    static let beforeTheGate: Duration = .milliseconds(1200)

    /// The orchard's best pen in the order a player would lay it: the west wall top to
    /// bottom, then the east wall bottom to top. The same twelve pieces
    /// `PuzzleGame.theOrchardsBestPen()` lays, which `PreviewReelTests` holds it to.
    static let pieces: [GridPoint] = {
        let west = (3...8).map { GridPoint(row: $0, column: max(0, $0 - 5)) }
        let east = (3...8).reversed().map { GridPoint(row: $0, column: 12 - $0) }
        return west + east
    }()

    var body: some View {
        PuzzleView(game: game)
            .task { await play() }
    }

    private func play() async {
        try? await Task.sleep(for: Self.opening)
        for tile in Self.pieces {
            game.beginStroke()
            if game.buildFence(on: tile) {
                Haptics.tap(.rigid)
                Sounds.play(.fenceIn)
            }
            game.endStroke()
            try? await Task.sleep(for: Self.perPiece)
        }
        try? await Task.sleep(for: Self.beforeTheGate)
        game.openTheGate()
    }
}
