/// How much of the whole game has been taken — every world, every level, every star and every
/// rainbow — as the one number the title screen wears on its Play button.
///
/// A level is worth four marks: one for each star it can give up, and a fourth for the rainbow it
/// keeps for the best pen the map has in it. So three stars on every level in the game is three
/// quarters of the way, and the last quarter is the rainbows. That is what makes a hundred per
/// cent mean what a player expects it to mean: the game is not finished until every map has given
/// up the best pen it has in it, and nothing short of that reads as finished.
///
/// Only the worlds that are built count. A silhouette out past the frontier has no levels in it
/// to take, so counting it would leave the game permanently unfinishable — and would move the
/// number every time another world was drawn on the map. The dailies do not count either: they
/// come and go with the calendar, and a game whose completion drops overnight is a game that
/// cannot be completed.
struct GameCompletion: Equatable, Sendable {
    /// What one level is worth: its three stars, and the rainbow above them.
    static let marksPerLevel = 4

    /// Every mark there is to win, across every world that is built.
    let total: Int
    /// How many of them are in.
    let won: Int

    /// How far along the game is, 0 to 1.
    var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(won) / Double(total)
    }

    /// Whether every star and every rainbow in the game is in — the only thing that reads 100%.
    var isEverything: Bool { total > 0 && won >= total }

    /// The number on the button, 0 to 100.
    ///
    /// Rounded down rather than to nearest, and held at 99 for anything short of the lot, so a
    /// hundred is only ever the real thing: a player one rainbow shy of the whole game must not
    /// be told they have finished it. It is held at 1 the other way round for the same reason in
    /// reverse — the first star of a long game should show on the button rather than round away
    /// to nothing.
    var percent: Int {
        guard won > 0 else { return 0 }
        guard !isEverything else { return 100 }
        return min(99, max(1, Int(fraction * 100)))
    }
}

extension Universe {
    /// How much of the universe the given stars and rainbows add up to.
    ///
    /// Handed the two stores rather than reading them, so the same sum serves the title screen,
    /// the previews and the tests without any of them touching what is on the device. Level ids
    /// are unique across worlds, so one dictionary and one set hold every world between them.
    func completion(stars: [String: Int], bestPens: Set<String>) -> GameCompletion {
        var total = 0
        var won = 0

        for world in worlds {
            guard let game = world.game else { continue }
            for node in game.map.nodes {
                total += GameCompletion.marksPerLevel
                won += min(max(stars[node.id] ?? 0, 0), 3)
                if bestPens.contains(node.id) { won += 1 }
            }
        }

        return GameCompletion(total: total, won: won)
    }
}
