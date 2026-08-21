import Foundation

/// Which build of the game this is, read out of the bundle in one place.
///
/// Two things want to know. The card behind the gear prints it, so a player writing in can say
/// which build they are holding; the rating prompt uses it to make sure nobody is ever asked
/// twice about the same version of the game. They read the same two keys, and reading them a
/// line apart in two files is one place too many for a string that has to mean the same thing
/// in both.
enum AppRelease {
    /// The version a player would name — `1.0.0` — rather than the build behind it.
    static var marketing: String { string("CFBundleShortVersionString") ?? "1.0.0" }

    /// The build. A timestamp on anything that came out of the release workflow, so it says
    /// which build a player is actually holding rather than only which version.
    static var build: String { string("CFBundleVersion") ?? "1" }

    /// Both of them, the way the settings card prints them.
    static var full: String { "Version \(marketing) (\(build))" }

    private static func string(_ key: String) -> String? {
        Bundle.main.infoDictionary?[key] as? String
    }
}
