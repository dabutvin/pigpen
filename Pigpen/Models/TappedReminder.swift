import Foundation
import Observation

extension ScheduledReminder {
    /// The day a reminder is about, read back out of the name it was filed under.
    ///
    /// A tapped reminder hands the game nothing but its identifier, and the identifier is
    /// already the day: `pigpen.daily-reminder.2026-04-22`. Reading the square of the
    /// calendar back out of it is what lets a tap open that morning's board rather than
    /// the title screen — and reading it rather than writing the day into the payload as
    /// well keeps the two from ever being able to disagree about which morning it is.
    ///
    /// Anything not filed under this game's own prefix, and anything filed under it that is
    /// not a day, comes back as nothing. Another app's notification is not ours to answer,
    /// and neither is a reminder from a version of this game that filed them differently.
    static func day(ofID identifier: String) -> DailyDate? {
        guard identifier.hasPrefix(idPrefix) else { return nil }
        return DailyDate(identifier.dropFirst(idPrefix.count))
    }
}

/// The morning a tapped reminder is asking for, written down until a screen is up to open it.
///
/// A reminder that lands the player on the title screen with the board still a tap away has
/// spent its one interruption on nothing: they were told the day's puzzle is up, they said
/// yes, and the game answered by showing them the front door. So the tap is written down
/// here and the title screen opens the morning it names.
///
/// It is written down rather than acted on because the two happen in the wrong order. A tap
/// on a cold launch is handed over while the app is still standing its first screen up —
/// before there is anything to push a board onto — and a tap that wakes a backgrounded game
/// arrives at a screen that is already somewhere else entirely. Either way the notification
/// centre has nowhere to put a puzzle, so it leaves the day here and the screen picks it up
/// whenever it is ready to.
@MainActor
@Observable
final class TappedReminder {
    /// The one the phone's notification centre writes into. A single shared thing rather
    /// than something handed down the screens, because what writes to it is a delegate the
    /// system owns and nothing in the game gets to hand anything to.
    static let shared = TappedReminder()

    /// The morning waiting to be opened: a reminder has been tapped and nothing has
    /// answered it yet.
    private(set) var waiting: DailyDate?

    /// - Parameter waiting: A tap already made, which is what a test hands in rather than
    ///   trying to make the notification centre deliver one.
    init(waiting: DailyDate? = nil) {
        self.waiting = waiting
    }

    /// A reminder of ours has been tapped. Anything else the phone hands over is left alone.
    func tapped(_ identifier: String) {
        guard let day = ScheduledReminder.day(ofID: identifier) else { return }
        waiting = day
    }

    /// Takes the morning to open and leaves nothing behind, so one tap opens one board.
    /// A tap left lying about would open the day's puzzle again the next time the title
    /// screen came back, which is a game deciding where a player goes on the strength of
    /// something they did an hour ago.
    func take() -> DailyDate? {
        defer { waiting = nil }
        return waiting
    }
}
