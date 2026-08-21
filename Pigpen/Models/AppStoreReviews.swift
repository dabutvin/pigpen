import StoreKit
import UIKit

// Apple's own rating prompt, and the one address that opens the listing behind it: the other
// half of what Pigpen uses StoreKit for. `AppStoreStorefront` sells the full game; this asks
// what the player thought of it, and between them they are the whole of the game's dealings
// with the store — nothing else in Pigpen imports StoreKit, so everything else, including
// every test over any of it, runs without a network and without an Apple ID.

/// The real thing: Apple's prompt, raised in the window the game is standing in.
///
/// There is nothing to configure and nothing to hand it. `AppStore.requestReview` knows which
/// app is asking, keeps the count of how often it has been asked this year, and decides on its
/// own whether to show anything at all — which is why `ReviewRequester.request` has nothing to
/// return. A scene that is not foreground-active is one the prompt would be raised over
/// nothing, so the ask is dropped rather than aimed at a window nobody is looking at.
@MainActor
struct SystemReviews: ReviewRequester {
    func request() {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        guard let scene else { return }
        AppStore.requestReview(in: scene)
    }
}

/// The game's page on the App Store, and the one line that fills it in.
///
/// Kept here for the same reason `SupportLinks` keeps the two pages on the web: one place to
/// change, and somewhere a test can check that what a button opens is a real address rather
/// than a typo that fails silently under a player's finger. The difference is that this one
/// cannot be written until the app exists — the Apple ID is minted the day it is created in
/// App Store Connect, and there is no guessing it beforehand.
enum AppStoreListing {
    /// The Apple ID out of App Store Connect: the digits in every `apps.apple.com/app/id…`
    /// address. Nothing until the app is created there, which is where this repository stands
    /// until its first submission — and while it is nothing, every door below it is closed
    /// rather than opening onto a page that does not exist. The same call the front page makes
    /// with its *Coming to the App Store* chip, in the same state, for the same reason.
    static let id: String? = nil

    /// The listing itself, once there is one.
    static var page: URL? { id.flatMap(address(forAppleID:)) }

    /// The listing with the review sheet already open on it: `action=write-review` is Apple's
    /// own parameter for it, so a player who came to say something lands on the box they came
    /// to type in rather than on a page they have to find it from.
    static var reviewPage: URL? { id.flatMap(reviewAddress(forAppleID:)) }

    /// The two addresses a given Apple ID makes, held apart from the ID itself — so the shape
    /// of them is under test on a day when there is no ID to test it with.
    static func address(forAppleID id: String) -> URL? {
        URL(string: "https://apps.apple.com/app/id\(id)")
    }

    static func reviewAddress(forAppleID id: String) -> URL? {
        URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }
}
