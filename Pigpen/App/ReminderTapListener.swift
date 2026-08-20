import UIKit
import UserNotifications

/// The ear the game keeps on its own reminders: what happens when one is tapped.
///
/// It exists because a tap has to be heard before there is anything to hear it. The phone
/// hands a tapped notification to whatever is standing as the notification centre's
/// delegate at the moment the app finishes launching, and a game that waits until its
/// first screen is up to volunteer has already missed the tap that woke it. So this is
/// installed at launch, and all it ever does is write the morning down for the title screen
/// to open.
///
/// Nothing here decides anything. Whether that morning can be played, whether something
/// else is up in front of it and what happens to a day already held are all questions with
/// a screen's worth of context behind them, and this has none — it is a delegate the system
/// owns, on the way in from the lock screen.
final class ReminderTapListener: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// A notification of this game's has been acted on. Only a tap on the reminder itself
    /// opens anything: a reminder swiped away is a player saying they have seen it, which is
    /// the opposite of asking for the board.
    ///
    /// Nothing the framework owns is carried out of here. The identifier is a string, read
    /// off the response before anything is handed to the main actor, so the notification and
    /// its request stay where they were given.
    nonisolated func userNotificationCenter(
        _ centre: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        let wasTapped = response.actionIdentifier == UNNotificationDefaultActionIdentifier
        if wasTapped {
            Task { @MainActor in TappedReminder.shared.tapped(identifier) }
        }
        // Answered straight away rather than after the day is written down: the system is
        // waiting on this to know the response has been taken, and what the title screen
        // then does with the morning is the game's own business and none of the phone's.
        completionHandler()
    }
}
