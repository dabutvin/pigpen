import Foundation

/// A star count spelled out, for the screens that are read aloud rather than looked at.
///
/// Five places had their own copy of the same four words and the same `star`/`stars` trick on
/// the end of them — the day on the title screen, the day in the archive, the signpost on a
/// trail, the postcard and the card behind it. Four words is not much to keep in one place; the
/// choice between one star and two is, once it is a choice a language makes for itself. Gathered
/// here, a translator answers it once.
///
/// Spelled rather than counted because a screen reader handed `3` in the middle of a sentence
/// full of numbers — a date, a clock, a run of days — reads one more number, and the star count
/// is the part a player actually asked for.
enum StarsInWords {
    /// Mid-sentence: `no stars`, `one star`, `three stars`.
    static func said(_ stars: Int) -> String {
        switch min(max(stars, 0), 3) {
        case 3: String(localized: "three stars")
        case 2: String(localized: "two stars")
        case 1: String(localized: "one star")
        default: String(localized: "no stars")
        }
    }

    /// The same at the head of a sentence, where every language the game speaks wants a
    /// capital on the front.
    static func saidFirst(_ stars: Int) -> String {
        let phrase = said(stars)
        return phrase.prefix(1).uppercased() + phrase.dropFirst()
    }
}
