import Foundation
import UserNotifications

/// Whatever it is that actually reminders: asks the phone where it stands, raises the system
/// prompt, and holds the fortnight of reminders the game has laid down.
///
/// A protocol rather than `UNUserNotificationCenter` outright, for the same reason the
/// progress stores are protocols. A test cannot raise a permission prompt and a screenshot
/// runner must not be asked one, and neither of them should be able to leave a real
/// notification standing on the machine afterwards.
protocol ReminderScheduler: Sendable {
    func standing() async -> ReminderStanding
    /// Raises the system's own prompt and answers with what the player said. A phone only
    /// ever shows it once, which is why nothing calls this until the player has already
    /// said yes to the game's own offer.
    func ask() async -> Bool
    /// Takes down every reminder this game has standing and lays these down instead.
    func replace(with reminders: [ScheduledReminder]) async
    /// Takes down every reminder this game has standing, and nothing else on the phone.
    func clear() async
}

/// The real thing: the phone's own notification centre.
///
/// Everything here is asked for through the callback side of the notification centre rather
/// than through its `async` twins, and every callback hands back a plain number, a flag or a
/// list of strings. A `UNNotificationRequest` never leaves the function that built it and
/// nothing the framework owns crosses out of one, so none of this has to make a claim about
/// which of the framework's classes may be carried between one task and another.
struct SystemReminderScheduler: ReminderScheduler {
    func standing() async -> ReminderStanding {
        let status: UNAuthorizationStatus = await withCheckedContinuation { asked in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                asked.resume(returning: settings.authorizationStatus)
            }
        }

        return switch status {
        case .notDetermined: .notAsked
        case .denied: .refused
        // Provisional and ephemeral both pass a reminder on, which is all this game asks of a
        // phone. Anything a later system adds is taken the same way rather than read as a
        // refusal, since a refusal is the one state the settings card apologises for.
        default: .allowed
        }
    }

    func ask() async -> Bool {
        let granted: Bool = await withCheckedContinuation { asked in
            // No badge: a count on the icon would have to be kept true by a game that does
            // not run while the phone is in a pocket, and a stale one is worse than none.
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
                allowed, _ in
                asked.resume(returning: allowed)
            }
        }
        return granted
    }

    func replace(with reminders: [ScheduledReminder]) async {
        await clear()

        let centre = UNUserNotificationCenter.current()
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            var when = DateComponents()
            when.year = reminder.date.year
            when.month = reminder.date.month
            when.day = reminder.date.day
            when.hour = reminder.time.hour
            when.minute = reminder.time.minute

            // Each reminder is its own day rather than one repeating every morning,
            // because what it says depends on which morning it is — and because a day
            // already held has to be able to lose its own without the rest going with it.
            //
            // Handed over without waiting for an answer: the only thing that can come back
            // is that one could not be laid down, and there is nothing the game would
            // do about that which it does not already do by laying the whole fortnight
            // down again the next time the player comes back.
            centre.add(
                UNNotificationRequest(
                    identifier: reminder.id,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
                ),
                withCompletionHandler: nil
            )
        }
    }

    func clear() async {
        let centre = UNUserNotificationCenter.current()
        let ours: [String] = await withCheckedContinuation { asked in
            centre.getPendingNotificationRequests { pending in
                asked.resume(
                    returning: pending
                        .map(\.identifier)
                        .filter { $0.hasPrefix(ScheduledReminder.idPrefix) }
                )
            }
        }
        guard !ours.isEmpty else { return }
        centre.removePendingNotificationRequests(withIdentifiers: ours)
    }
}

/// A gate that writes every reminder down in a ledger instead of posting one.
///
/// What the tests read to find out what the game would have said, and what the previews and
/// the screenshot runs are handed so that photographing the offer sheet does not put a real
/// prompt up on a machine in a datacentre.
actor RememberedReminders: ReminderScheduler {
    /// Where the phone is to be said to stand, and what it is to say when asked.
    private var standingGiven: ReminderStanding
    private let answerToAsking: Bool

    /// The reminders currently laid down, in the order they were handed over.
    private(set) var laid: [ScheduledReminder] = []
    private(set) var timesAsked = 0
    private(set) var timesCleared = 0

    init(standing: ReminderStanding = .notAsked, answersAsking: Bool = true) {
        self.standingGiven = standing
        self.answerToAsking = answersAsking
    }

    func standing() async -> ReminderStanding { standingGiven }

    func ask() async -> Bool {
        timesAsked += 1
        standingGiven = answerToAsking ? .allowed : .refused
        return answerToAsking
    }

    func replace(with reminders: [ScheduledReminder]) async {
        laid = reminders
    }

    func clear() async {
        timesCleared += 1
        laid = []
    }

    /// Turns the phone's answer round underneath the game, the way somebody walking into
    /// the system settings does.
    func stand(_ newStanding: ReminderStanding) {
        standingGiven = newStanding
    }
}
