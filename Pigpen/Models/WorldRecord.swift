import Foundation

/// What a world has given up to one player, and what it has given up to everybody else.
///
/// The landmark at the foot of every trail opens this: the barn in the meadow, the cairn on
/// the mountain, the clocktower in the city. It is the one place in the game that looks
/// sideways at other people. Everywhere else the game only ever asks a player to beat a map.
///
/// Two halves, and the second is optional. The player's own record is read off the same
/// stars and best pens the signposts are already drawing, so it is right for anybody who has
/// ever played — there is nothing new to start counting and no level plays differently for
/// having been counted. What the field has made of the same trail comes out of
/// `LevelBenchmarks`, which is a photograph taken when the build was cut, and which stays
/// quiet about any level too few players have reached to speak for. A world where that is
/// every level — which is most of them, most of the time, since the late worlds fill up
/// years after the early ones — shows the first half and says so.
struct WorldRecord {
    /// One stop on the trail: what the player got out of it, and what everybody else did.
    struct Row: Identifiable, Equatable {
        let id: String
        /// Which stop on the trail it is, counting from 1 the way the signpost does.
        let stop: Int
        let name: String
        /// The best rating the player has ever had out of it, 0 for one they have not held.
        let stars: Int
        /// Whether they have found the best pen the map has in it.
        let hasTheBestPen: Bool
        /// What the field made of it, and nothing for a level too few players have reached.
        let benchmark: LevelBenchmark?

        var isSolved: Bool { stars > 0 }
    }

    let world: String
    let rows: [Row]
    /// Stops held, out of the stops there are.
    let solved: Int
    let count: Int
    /// Stars won, out of the stars the trail holds.
    let stars: Int
    let starTotal: Int
    /// Best pens found, out of the stops there are — the rarest thing a trail gives up.
    let bestPens: Int

    init(world: WorldMap, stars bestStars: [String: Int], bestPens foundPens: Set<String>) {
        self.world = world.name
        self.count = world.count
        self.starTotal = world.starTotal
        let rows = world.nodes.indices.map { index in
            let node = world[index]
            return Row(
                id: node.id,
                stop: index + 1,
                name: node.level.name,
                stars: bestStars[node.id] ?? 0,
                hasTheBestPen: foundPens.contains(node.id),
                benchmark: LevelBenchmarks.benchmark(for: node.id)
            )
        }
        self.rows = rows
        self.solved = rows.filter(\.isSolved).count
        self.stars = rows.reduce(0) { $0 + $1.stars }
        self.bestPens = rows.filter(\.hasTheBestPen).count
    }

    // MARK: - What the field has to say

    /// A stop paired with what the field made of it — a row of the panel that has two
    /// things to say rather than one.
    struct Measured: Identifiable, Equatable {
        let row: Row
        let benchmark: LevelBenchmark

        var id: String { row.id }
    }

    /// The stops on this trail the counting has enough players behind to speak for. Empty on
    /// most worlds for most of the game's life, which is the case the panel is built around
    /// rather than the exception it handles.
    var measured: [Measured] {
        rows.compactMap { row in row.benchmark.map { Measured(row: row, benchmark: $0) } }
    }

    /// Whether there is anything to say about anybody but the player.
    var hasField: Bool { !measured.isEmpty }

    /// Stops the player three-starred that most players do not. The one figure here worth
    /// calling a ranking, and deliberately a count rather than a percentile: a percentile off
    /// fifty-odd players would be a decimal point pretending to be a fact.
    var aheadOfMost: Int {
        measured.filter { $0.row.stars == 3 && $0.benchmark.threeStarShare < 0.5 }.count
    }

    /// Best pens the player holds that most players do not.
    var rarePens: Int {
        measured.filter { $0.row.hasTheBestPen && $0.benchmark.bestPenShare < 0.5 }.count
    }
}
