import Foundation

/// The address a day of the almanac has on the web, and the day read back out of one.
///
/// `https://pigpen.app/day/2026-04-22` is what the bottom of a postcard says. On a phone with
/// the game on it the address opens the game on that day's board — it is a universal link,
/// claimed by the associated-domains entitlement and vouched for by the file the site serves
/// at `/.well-known/apple-app-site-association` — and on a phone without it the address opens
/// the site, where the App Store button is. One link, and the best thing it can do for
/// whoever taps it.
///
/// The day is read back out of the path the way a tapped reminder's is read out of its
/// identifier: nothing is carried but the date, so there is nothing for it to disagree with.
enum DayLink {
    /// Where the days hang off the host: `/day/<date>`. Named once here and nowhere else in
    /// the app; the site's association file and its redirect name the same path, and
    /// `DayLinkTests` holds the three to each other.
    static let folder = "day"

    /// A day's own address.
    static func url(for date: DailyDate) -> URL {
        URL(string: "\(SupportLinks.host)/\(folder)/\(date.id)")!
    }

    /// The day an address is asking for, and nothing for an address that is not one of
    /// ours: another host, another path, another scheme, or a day that is not a day. Only
    /// `https` is honoured, since that is the only kind of address the phone will ever hand
    /// the game as its own; `www.` in front of the host is let through, since a person typing
    /// the address may well put it there.
    static func day(in url: URL) -> DailyDate? {
        guard url.scheme?.lowercased() == "https",
              let host = url.host(percentEncoded: false)?.lowercased(),
              let ours = URL(string: SupportLinks.host)?.host(percentEncoded: false)?.lowercased(),
              host == ours || host == "www.\(ours)"
        else { return nil }

        // A trailing slash comes through as a component of its own, and is not a day.
        let parts = url.pathComponents.filter { $0 != "/" }
        guard parts.count == 2, parts[0] == folder else { return nil }
        return DailyDate(parts[1])
    }
}
