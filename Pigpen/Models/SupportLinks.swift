import Foundation

/// The two pages outside the game, and the address behind them.
///
/// Every app on the store has to have somewhere a player can go when something is wrong and
/// somewhere they can read what the game keeps about them, and both have to be reachable
/// from inside the app rather than only from the store listing — a review that cannot find
/// them reads the app as unfinished. They live here rather than typed into the settings
/// sheet so there is one place to change when the pages move, and so a test can check that
/// what the buttons point at is a real address rather than a typo that fails silently at
/// the moment a player presses it.
///
/// The pages themselves are the static HTML in `site/`, which Netlify serves at pigpen.app
/// whenever `main` moves — no build step, no upload. The front page there is the
/// game's own, for somebody who has not played it; these two are for somebody who has, which
/// is why neither of them is the root. The same strings go in App Store Connect: the support
/// URL, the privacy policy URL, the marketing URL, and the support address on the app's
/// information page.
enum SupportLinks {
    /// Where the pages are served from. Changing this line moves every button in the game.
    static let host = "https://pigpen.app"

    /// Help, common questions, and the way to write to a person.
    static let support = URL(string: "\(host)/support.html")!

    /// What the game keeps, what it counts, and what it never asks for.
    static let privacy = URL(string: "\(host)/privacy.html")!

    /// The address, in the words a player would read it out in. Shown as text under the
    /// support button as well as being what the page hands over, so a player with no
    /// connection still has somewhere to write to.
    static let email = "support@pigpen.app"
}
