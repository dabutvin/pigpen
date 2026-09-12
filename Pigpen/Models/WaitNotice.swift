import Foundation

/// The word a player gets when they wave away the offer of the full game and are left
/// with the free game's clock still running on the next stop.
///
/// Tapping a stop the free game has not handed over yet raises the purchase first, and
/// that sheet already says how long the wait is — but a player who closes it without
/// buying is looking at a locked sign with `14h` on it and nothing that says what those
/// hours *are*. The offer they just shut was selling the way round the wait; this is the
/// wait itself, said plainly once the money talk is over: one new level every twenty-four
/// hours, and how much of this day is left.
///
/// It is raised on the offer coming down empty rather than on the map coming back, which
/// is what keeps it an answer and not a nag. A player who never reaches for a shut stop is
/// not told; one who buys the game is not either — the clock is gone. Only the trail that
/// just met the wall and turned the offer down is owed the word.
struct WaitNotice: Identifiable, Equatable {
    /// How long is left of the free game's day.
    let wait: LevelWait

    var id: String { "wait \(wait.minutes)" }

    /// The notice a declined full-game offer owes the player, or nothing at all — which is
    /// the answer when the game was unlocked on the way down, or when there was no wait to
    /// explain (a locked world on the universe map, a shut day in the archive, the card in
    /// settings).
    static func afterDecliningTheOffer(
        isUnlocked: Bool,
        wait: LevelWait?
    ) -> WaitNotice? {
        guard !isUnlocked, let wait else { return nil }
        return WaitNotice(wait: wait)
    }
}
