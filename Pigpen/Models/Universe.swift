import SwiftUI

/// One world on the universe map: its look, and the playable world behind it once there is one.
///
/// Not every world is built yet. The ones that are carry a `GameWorld` — a trail of puzzles to
/// walk. The rest are silhouettes: a boss shape and a name, drawn on the map as somewhere to go
/// next, so a player can see the whole journey ahead of them long before it is all there to play.
struct UniverseWorld: Identifiable, Sendable {
    let theme: WorldTheme
    /// The playable world, or nothing for one still being built.
    let game: GameWorld?

    var id: String { theme.id }
    var isBuilt: Bool { game != nil }
    var boss: BossMark { theme.boss }
}

/// What the universe map has to say about a world.
enum WorldState: Sendable, Equatable {
    /// Built, and every pen in it held.
    case cleared
    /// Built and open, waiting to be played or finished.
    case playable
    /// Reached, but not built yet — a silhouette to look forward to.
    case comingSoon
    /// Still shut, because the world before it is not finished.
    case locked
}

/// Every world there is, in the order they are unlocked — the whole map from the meadow out.
///
/// A world opens when the one before it is finished, so the journey is a chain: hold every pen
/// in the meadow to reach the thicket, hold every pen in the thicket to reach the mountain, and
/// so on out to the edge of what has been built. A silhouette cannot be finished, so it is as
/// far as the chain reaches for now — which is exactly what "coming soon" should mean.
struct Universe: Sendable {
    let worlds: [UniverseWorld]

    var count: Int { worlds.count }
    subscript(index: Int) -> UniverseWorld { worlds[index] }

    /// The playable world at a stop, or nothing for a silhouette.
    func game(at index: Int) -> GameWorld? {
        worlds.indices.contains(index) ? worlds[index].game : nil
    }

    /// Whether a world is built and every level in it has been penned at least once.
    func isCleared(_ index: Int, stars: [String: Int]) -> Bool {
        guard let game = game(at: index) else { return false }
        return game.map.nodes.allSatisfy { (stars[$0.id] ?? 0) > 0 }
    }

    /// Whether a world can be entered: the first one always, and any other once the one before
    /// it is finished.
    func isUnlocked(_ index: Int, stars: [String: Int]) -> Bool {
        guard worlds.indices.contains(index) else { return false }
        return index == 0 || isCleared(index - 1, stars: stars)
    }

    /// Everything the map needs to draw a world in one answer.
    func state(of index: Int, stars: [String: Int]) -> WorldState {
        guard isUnlocked(index, stars: stars) else { return .locked }
        guard worlds[index].isBuilt else { return .comingSoon }
        return isCleared(index, stars: stars) ? .cleared : .playable
    }

    /// The furthest world open to the player: the first one not yet cleared, or the last stop
    /// once the whole chain that is built has been held.
    func frontier(stars: [String: Int]) -> Int {
        for index in worlds.indices where !isCleared(index, stars: stars) {
            return index
        }
        return max(count - 1, 0)
    }
}

extension Universe {
    /// The map the game ships: the meadow, the thicket, the mountain, the city, the reaches, the
    /// caverns and the carnival to play, and five more worlds standing out past them as
    /// silhouettes — a boss apiece, waiting to be built.
    static let all = Universe(worlds: [
        UniverseWorld(theme: .meadow, game: .mudlarkMeadow),
        UniverseWorld(theme: .thornwood, game: .thornwoodThicket),
        UniverseWorld(theme: .emberpeak, game: .emberpeak),
        UniverseWorld(theme: .cogsworth, game: .cogsworthCity),
        UniverseWorld(theme: .starfall, game: .starfallReaches),
        UniverseWorld(theme: .gloamdeep, game: .gloamdeepCaverns),
        UniverseWorld(theme: .lanternCarnival, game: .lanternCarnival),
        UniverseWorld(theme: silhouette(
            id: "sunbaked-dunes", name: "Sunbaked Dunes", blurb: "Sand to the horizon, and a sting in it.",
            boss: "🦂", bossName: "the scorpion",
            accent: Color(red: 0.93, green: 0.77, blue: 0.43), deep: Color(red: 0.62, green: 0.44, blue: 0.20)
        ), game: nil),
        UniverseWorld(theme: silhouette(
            id: "tidepool-cove", name: "Tidepool Cove", blurb: "Where the tide keeps rearranging the walls.",
            boss: "🦀", bossName: "the crab",
            accent: Color(red: 0.37, green: 0.74, blue: 0.72), deep: Color(red: 0.16, green: 0.44, blue: 0.46)
        ), game: nil),
        UniverseWorld(theme: silhouette(
            id: "frostwhisker-tundra", name: "Frostwhisker Tundra", blurb: "Ice, snow, and a pig that will not stay put.",
            boss: "🦭", bossName: "the bull seal",
            accent: Color(red: 0.69, green: 0.84, blue: 0.93), deep: Color(red: 0.36, green: 0.56, blue: 0.71)
        ), game: nil),
        UniverseWorld(theme: silhouette(
            id: "mirebog-fen", name: "Mirebog Fen", blurb: "Half water, half mud, all trouble.",
            boss: "🐊", bossName: "the old croc",
            accent: Color(red: 0.47, green: 0.56, blue: 0.35), deep: Color(red: 0.24, green: 0.32, blue: 0.18)
        ), game: nil),
        UniverseWorld(theme: silhouette(
            id: "cloudspire-heights", name: "Cloudspire Heights", blurb: "Fields in the sky, and a long way down.",
            boss: "🦅", bossName: "the eagle",
            accent: Color(red: 0.73, green: 0.83, blue: 0.96), deep: Color(red: 0.44, green: 0.58, blue: 0.79)
        ), game: nil)
    ])

    /// A theme for a world that is only a silhouette so far: it needs a name, a boss and a
    /// colour for the map, and stand-in palettes it will only ever draw with once it is built.
    private static func silhouette(
        id: String,
        name: String,
        blurb: String,
        boss: String,
        bossName: String,
        accent: Color,
        deep: Color
    ) -> WorldTheme {
        WorldTheme(
            id: id,
            name: name,
            blurb: blurb,
            day: .day,
            dusk: .dusk,
            treats: WorldTheme.meadow.treats,
            field: WorldTheme.meadow.field,
            boss: BossMark(glyph: boss, name: bossName),
            accent: accent,
            accentDeep: deep
        )
    }
}
