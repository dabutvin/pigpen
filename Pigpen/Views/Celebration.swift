import Foundation
import UIKit

/// An animal part way through a celebration: where it stands in tile coordinates —
/// fractional between tiles while it is running — how far off the ground it is, which way
/// it is leaning, and how the spring in its legs has it drawn out or flattened.
struct AnimalPose: Equatable, Sendable {
    /// Whole numbers are tile centres; the fractions between them are the ground in
    /// between, which is where an animal mid-stride stands.
    var row: Double
    var column: Double
    /// How far off the ground it is, counted in tiles.
    var lift: Double = 0
    /// Degrees, leaning right when positive.
    var lean: Double = 0
    /// Across and up, 1 apiece being an animal standing square on its feet.
    var stretch: Double = 1
    var squash: Double = 1
}

/// The turn the field takes when the fencing holds: every animal shut in runs a little
/// circle of the ground it is holding — twice round, leaning into the corners — and
/// finishes on a hop where it started, under confetti.
///
/// Like the pasture behind the title, it is written as a clock rather than as a queue of
/// steps. The field asks where an animal is at a given moment and draws that, so the run
/// flows instead of jumping tile to tile, and two animals cannot fall out of time with
/// each other however different the circles they have room for.
struct Celebration: Equatable, Sendable {
    /// The circle each animal runs.
    let laps: [VictoryLap]
    /// The moment the gate opened on a pen that held.
    let start: Date

    /// A beat before anything moves, for the pen's wash to deepen into.
    static let beat: TimeInterval = 0.15
    /// How long a single tile of running takes, and how many times round the circle goes.
    static let pace: TimeInterval = 0.11
    static let timesRound = 2
    /// One hop at the end of the running, and how many of them there are.
    static let hop: TimeInterval = 0.28
    static let hops = 2
    /// How long the confetti keeps coming down after the animals have settled, which is
    /// from behind the verdict card by then.
    static let tail: TimeInterval = 0.7

    /// How far the gallop's bob and the finishing hop take an animal off the ground,
    /// in tiles.
    private static let bobHeight = 0.09
    private static let hopHeight = 0.34
    /// How far over an animal leans when it is running flat out across the field.
    private static let leanDegrees = 9.0

    /// Tiles of running every animal gets through. The same for all of them, so they set
    /// off and settle together: an animal with only two tiles to shuttle between covers
    /// them twice as often as one with a whole circle to run, and one with no room at all
    /// bounces on the spot for as long as a circle would have taken.
    private var strides: Int {
        Self.timesRound * max(laps.map(\.strides).max() ?? 0, 2)
    }

    private var runDuration: TimeInterval { Double(strides) * Self.pace }

    /// When each hop touches back down, counted from the start.
    var landings: [TimeInterval] {
        (0..<Self.hops).map { Self.beat + runDuration + Double($0 + 1) * Self.hop }
    }

    /// How long the animals are moving for. The verdict waits this long.
    var runtime: TimeInterval { landings.last ?? Self.beat }

    /// How long the celebration is worth drawing for, confetti and all.
    var life: TimeInterval { runtime + Self.tail }

    /// Where an animal is, and what it is doing, `elapsed` seconds in. Nothing for an
    /// animal that is not part of this celebration.
    func pose(of kind: Animal, secondsIn elapsed: TimeInterval) -> AnimalPose? {
        guard let lap = laps.first(where: { $0.animal.kind == kind }) else { return nil }
        let home = AnimalPose(
            row: Double(lap.animal.tile.row),
            column: Double(lap.animal.tile.column)
        )

        let running = elapsed - Self.beat
        guard running > 0 else { return home }
        if running < runDuration {
            return pose(of: lap, after: running / Self.pace)
        }

        let hops = (running - runDuration) / Self.hop
        guard hops < Double(Self.hops) else { return home }
        return hopping(home, hops: hops)
    }

    /// The frame of one lap `covered` tiles into the running. The bob is a rise and fall
    /// for every tile covered, whatever shape the lap is, which is what makes the run read
    /// as a gallop rather than a glide.
    private func pose(of lap: VictoryLap, after covered: Double) -> AnimalPose {
        let home = lap.animal.tile
        var pose = AnimalPose(row: Double(home.row), column: Double(home.column))
        let bob = abs(sin(.pi * covered))

        switch lap.route.count {
        case 5:
            // The four tiles of a square sit on a circle, so the lap can be run as one:
            // a quarter turn per tile, and no corners to stop dead in.
            let across = lap.route[2]
            let centre = (
                row: (Double(home.row) + Double(across.row)) / 2,
                column: (Double(home.column) + Double(across.column)) / 2
            )
            // Which way round the ring lies from the tile the animal starts on.
            let turn = Double((across.row - home.row) * (across.column - home.column))
            let radius = (0.5 as Double).squareRoot()
            let opening = atan2(Double(home.row) - centre.row, Double(home.column) - centre.column)
            let angle = opening + turn * (.pi / 2) * covered

            pose.row = centre.row + radius * sin(angle)
            pose.column = centre.column + radius * cos(angle)
            // However much of the running is across the field this instant is how far over
            // it leans, so it goes over hardest on the straights and comes upright through
            // the ends of the circle.
            pose.lean = -Self.leanDegrees * sin(angle) * turn
        case 3:
            // Two tiles is no circle at all, so it is run as a pendulum: out to the far
            // tile, easing round, and back.
            let far = lap.route[1]
            let sweep = (1 - cos(.pi * covered)) / 2

            pose.row += Double(far.row - home.row) * sweep
            pose.column += Double(far.column - home.column) * sweep
            pose.lean = Self.leanDegrees * Double(far.column - home.column) * sin(.pi * covered)
        default:
            // Penned onto its own tile, with nowhere to go but up. It bounces on the spot
            // in time with whatever the others are running.
            break
        }

        pose.lift = Self.bobHeight * bob
        pose.stretch = 1 - 0.04 * bob
        pose.squash = 1 + 0.05 * bob
        // The lean comes on over the first half tile and off again over the last, so an
        // animal sets off and pulls up upright rather than snapping over and back.
        pose.lean *= min(1, min(covered, Double(strides) - covered) / 0.5)
        return pose
    }

    /// A hop on the spot, `hops` of them in: up, over and down, drawn out at the top of
    /// the leap, and wagging the other way each time.
    private func hopping(_ home: AnimalPose, hops: Double) -> AnimalPose {
        let arc = sin(.pi * hops.truncatingRemainder(dividingBy: 1))
        let wag = Int(hops).isMultiple(of: 2) ? 1.0 : -1.0

        var pose = home
        pose.lift = Self.hopHeight * arc
        pose.lean = Self.leanDegrees * wag * arc
        pose.stretch = 1 - 0.08 * arc
        pose.squash = 1 + 0.12 * arc
        return pose
    }
}

extension Celebration {
    /// Waits out the running and the hopping, with a soft knock as each hop lands bar the
    /// last — the verdict card comes up on that one and says so louder.
    ///
    /// Returns whether it ran to the end. A player who clears the field part way through
    /// calls the whole thing off, and nothing should be waited on after that.
    @MainActor
    @discardableResult
    func waitOut() async -> Bool {
        var elapsed: TimeInterval = 0

        for (index, landing) in landings.enumerated() {
            guard await Task.pausing(for: .seconds(max(landing - elapsed, 0))) else { return false }
            elapsed = landing

            if index < landings.count - 1 {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
        return true
    }

    /// Waits for the last of the confetti to reach the ground, after which there is
    /// nothing left of the celebration to draw.
    @MainActor
    func waitForTheConfetti() async {
        _ = await Task.pausing(for: .seconds(Self.tail))
    }
}
