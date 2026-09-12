import Foundation

/// The word a player gets when the trail runs out under a boss whose stars are not in.
///
/// The last ordinary level of a world is beaten by everybody who gets that far, and for some
/// of them that is the end of the road: the boss above it wants most of the stars the trail
/// below it holds, and a player who scraped up the world on ones and twos does not have
/// them. The map has been saying so all along — the boss's signpost carries `have/need` from
/// the first time it is seen — but a player who has just held the last pen they can reach is
/// looking at the pig and the level they beat, not at a locked sign a stop further up, and
/// nothing on the way back tells them what to do about it. Being stuck with no idea why is
/// the one way this game loses somebody at the top of a world. So the map says it out loud
/// once the pig has settled: the price, what they hold against it, and where the rest is to
/// be found.
///
/// It is raised once — the moment the trail under the boss is held and the stars are still
/// short, which is when the player would otherwise walk on to the boss and cannot — and
/// again on a tap of the boss itself, so a player who dismissed the card can ask for it
/// back. Going back down the trail to better old pens while still short does not raise it
/// again: that would turn a nudge into a nag. A level opened for another look and backed
/// out of says nothing, and neither does a replay that does no better.
struct TollNotice: Identifiable, Equatable {
    /// The stop the stars are for, by name — *Stag Mere*, not *the boss*.
    let boss: String
    /// The stars the world holds.
    let have: Int
    /// The stars that stop wants before it opens.
    let need: Int

    var id: String { "\(boss) \(have)/\(need)" }

    /// How many stars there are still to win. Never less than one, since a notice is only
    /// ever raised over a toll that is still owed.
    var shortBy: Int { max(need - have, 0) }

    /// The notice a level just played and put away owes the player, or nothing at all —
    /// which is the answer almost every time a level is put away.
    ///
    /// - Parameters:
    ///   - boss: What the tolled stop is called.
    ///   - toll: The stars it asks for.
    ///   - starsBefore: What the world held when the level was opened.
    ///   - starsNow: What it holds now.
    ///   - isTheTrailBelowHeld: Whether every stop under the boss has been beaten, which is
    ///     what makes the toll the only thing left in the player's way. Short of that there
    ///     is a level to go and play, and a player with somewhere to go is not stuck.
    ///   - wasTheTrailBelowHeld: Whether the trail under the boss was already held when the
    ///     level was opened. The card goes up only on the level that first runs the trail
    ///     out — the moment you would advance to the boss and cannot. A later star won on
    ///     an old pen leaves this true both before and after, so bettering your way toward
    ///     the toll does not keep putting the card back up; tapping the boss does that.
    static func afterALevel(
        boss: String,
        toll: Int,
        starsBefore: Int,
        starsNow: Int,
        isTheTrailBelowHeld: Bool,
        wasTheTrailBelowHeld: Bool
    ) -> TollNotice? {
        guard isTheTrailBelowHeld, !wasTheTrailBelowHeld,
              starsNow > starsBefore, starsNow < toll
        else { return nil }
        return TollNotice(boss: boss, have: starsNow, need: toll)
    }
}
