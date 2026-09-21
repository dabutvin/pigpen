import Foundation
import Observation

extension ScheduledReminder {
    /// What a reminder was about, read back out of the name it was filed under.
    ///
    /// A tapped reminder hands the game nothing but its identifier, and the identifier
    /// already says: `pigpen.daily-reminder.2026-04-22` is a morning, and
    /// `pigpen.daily-reminder.level.thornwood-thicket` is the free game's next level on
    /// that world's trail. Reading the day or the world back out of it is what lets a tap
    /// open that board or that trail rather than the title screen — and reading it rather
    /// than writing it into the payload as well keeps the two from ever being able to
    /// disagree about what the reminder was for.
    ///
    /// Anything not filed under this game's own prefix, and anything filed under it that is
    /// neither a day nor a world, comes back as nothing. Another app's notification is not
    /// ours to answer, and neither is a reminder from a version of this game that filed
    /// them differently.
    static func occasion(ofID identifier: String) -> Occasion? {
        guard identifier.hasPrefix(idPrefix) else { return nil }
        if identifier.hasPrefix(levelIDPrefix) {
            let world = identifier.dropFirst(levelIDPrefix.count)
            return world.isEmpty ? nil : .nextLevel(world: String(world))
        }
        return DailyDate(identifier.dropFirst(idPrefix.count)).map { .morning($0) }
    }

    /// The day a morning's reminder is about, and nothing for any other reminder.
    static func day(ofID identifier: String) -> DailyDate? {
        guard case .morning(let day) = occasion(ofID: identifier) else { return nil }
        return day
    }
}

/// How a day came to be asked for from outside the game: a reminder tapped on the lock
/// screen, or a link to the day followed from somewhere else — the bottom of a postcard, in
/// a chat. The two open the same board and are counted apart, since one says whether the
/// mornings bring anybody back and the other whether the postcards bring anybody in.
enum WayIn: Equatable, Sendable {
    case reminder
    case link
}

/// Something asked for from outside the game: a day's board, and how it was asked for, or
/// the trail the free game's next level stands on.
enum Knock: Equatable, Sendable {
    case day(DailyDate, wayIn: WayIn)
    /// The trail of the world named by its id, asked for by a tap on the reminder that
    /// said the next free level there is ready.
    case trail(world: String)
}

/// What a tapped reminder — or a followed link — is asking for, written down until a screen
/// is up to open it.
///
/// A reminder that lands the player on the title screen with the board still a tap away has
/// spent its one interruption on nothing: they were told the day's puzzle is up, they said
/// yes, and the game answered by showing them the front door. So the tap is written down
/// here and the title screen opens the morning it names. A link to a day is the same knock
/// from a different direction, and comes in by the same door — and so is the reminder that
/// the next free level is ready, which asks for a trail rather than a board.
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

    /// What is waiting to be opened, and how it was asked for: a reminder has been tapped or
    /// a link followed, and nothing has answered it yet.
    private(set) var waiting: Knock?

    /// - Parameter waiting: A knock already made, which is what a test hands in rather than
    ///   trying to make the notification centre deliver one.
    init(waiting: Knock? = nil) {
        self.waiting = waiting
    }

    /// A reminder of ours has been tapped: a morning's, which asks for its board, or the
    /// level's, which asks for its trail. Anything else the phone hands over is left alone.
    func tapped(_ identifier: String) {
        switch ScheduledReminder.occasion(ofID: identifier) {
        case .morning(let day): waiting = .day(day, wayIn: .reminder)
        case .nextLevel(let world): waiting = .trail(world: world)
        case nil: return
        }
    }

    /// An address has been handed to the game. A day's own address — `DayLink` — is written
    /// down like a tap; anything else the phone opens the game with is left alone.
    func followed(_ url: URL) {
        guard let day = DayLink.day(in: url) else { return }
        waiting = .day(day, wayIn: .link)
    }

    /// Takes what is to be opened and leaves nothing behind, so one knock opens one board.
    /// A tap left lying about would open the day's puzzle again the next time the title
    /// screen came back, which is a game deciding where a player goes on the strength of
    /// something they did an hour ago.
    func take() -> Knock? {
        defer { waiting = nil }
        return waiting
    }
}
