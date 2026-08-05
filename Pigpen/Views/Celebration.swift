import SwiftUI
import UIKit

/// The turn the field takes when a pen holds: everything shut in trots once round a little
/// circle of its own ground and finishes with a couple of hops on the spot. An animal
/// penned too tight to run skips straight to the hopping — four pieces round the pig is
/// still a win, and it should look like one.
@MainActor
struct Celebration {
    let laps: [VictoryLap]
    /// Puts one animal on a tile.
    let move: (Animal, GridPoint) -> Void
    /// Lifts every animal off the ground: 0 standing, 1 at the top of a hop.
    let lift: (Double) -> Void

    /// Plays it out, and gives up the moment the celebration is called off — a player who
    /// clears the field part way through has the animals put straight back where the map
    /// stands them, and nothing left mid-hop should move them again afterwards.
    func run() async {
        // A beat first, for the pen's wash to deepen before anything moves on it.
        guard await pause(.milliseconds(220)), await trot() else { return }
        await hop(times: 2)
    }

    /// Round the circle a step at a time, every animal moving together, the way they all
    /// walk out together when the fencing fails.
    private func trot() async -> Bool {
        let longest = laps.map(\.route.count).max() ?? 0
        guard longest > 1 else { return true }

        for step in 1..<longest {
            withAnimation(.easeInOut(duration: 0.16)) {
                for lap in laps where step < lap.route.count {
                    move(lap.animal.kind, lap.route[step])
                }
            }
            guard await pause(.milliseconds(150)) else { return false }
        }
        return true
    }

    private func hop(times: Int) async {
        for _ in 0..<times {
            withAnimation(.easeOut(duration: 0.16)) { lift(1) }
            guard await pause(.milliseconds(170)) else { return }

            withAnimation(.easeIn(duration: 0.14)) { lift(0) }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            guard await pause(.milliseconds(150)) else { return }
        }
    }

    /// Waits, and says whether the celebration is still wanted.
    private func pause(_ duration: Duration) async -> Bool {
        do {
            try await Task.sleep(for: duration)
            return true
        } catch {
            return false
        }
    }
}
