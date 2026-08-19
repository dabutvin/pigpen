/// Every daily puzzle the game ships with, and which of them a player is allowed to open.
///
/// The almanac is written into the app rather than fetched, so the puzzles for the rest of
/// the year are already in the player's pocket the day they install it. What keeps tomorrow
/// out of reach is not that it is missing — it is that `isOpen(_:today:)` says no. A player
/// who moves the phone's clock forward can of course walk into next week, and is welcome
/// to: the point of the gate is that the archive is a calendar rather than a list, not that
/// anybody is being kept out of a puzzle.
///
/// The maps themselves come from `Tools/generate_dailies.py`, which shapes a map from the
/// date, searches it for the best pen it has in it the same way the meadow's levels were
/// authored, and keeps only those whose gap between that pen and the obvious one falls in
/// the band its weekday asks for. That is what makes a week a climb: the number is measured
/// rather than declared.
///
/// Running the other way across that climb is what the water on a board looks like. Most
/// days drop it in bodies until the board is wet enough, but about a quarter of the book
/// has it arranged instead — freckled over every other square, stepped across a corner as
/// a shore, or split into two banks with a neck of ground between them. It changes nothing
/// about what a day asks, since the band is measured on the board that came out either way.
/// It is only there so that opening the archive on the fourth Tuesday running is not the
/// same board a fourth time.
enum DailyAlmanac {
    /// One day's line of the almanac, split from its date.
    ///
    /// Held as text and turned into a level only when one is asked for, since the archive
    /// wants to know which days exist far more often than it wants a board.
    static let entries: [String: Substring] = {
        var found: [String: Substring] = [:]
        for year in almanac {
            for line in year.split(whereSeparator: \.isNewline) {
                guard let space = line.firstIndex(of: " ") else { continue }
                found[String(line[line.startIndex..<space])] = line[line.index(after: space)...]
            }
        }
        return found
    }()

    /// The first and last days the almanac has anything to say about. A game running past
    /// the last of them has no daily puzzle, and says so rather than inventing one.
    static let firstDay: DailyDate? = entries.keys.compactMap { DailyDate($0) }.min()
    static let lastDay: DailyDate? = entries.keys.compactMap { DailyDate($0) }.max()

    /// Whether the almanac holds a puzzle for a day at all.
    static func holdsAPuzzle(on date: DailyDate) -> Bool {
        entries[date.id] != nil
    }

    /// Whether a day can be played: the almanac has it, and it is not still to come.
    static func isOpen(_ date: DailyDate, today: DailyDate) -> Bool {
        date <= today && holdsAPuzzle(on: date)
    }

    /// The puzzle for a day, built from the line the almanac keeps it on.
    ///
    /// A malformed line is a mistake in generated source rather than anything a player can
    /// bring about, so it comes back as `nil` and the screen that asked says there is no
    /// puzzle — `DailyAlmanacTests` walks every day in the book so that never ships.
    static func level(on date: DailyDate) -> PuzzleLevel? {
        guard let entry = entries[date.id] else { return nil }
        let fields = entry.split(separator: " ")
        guard fields.count == 5,
              let budget = Int(fields[0]),
              let twoStar = Int(fields[1]),
              let threeStar = Int(fields[2]),
              let maximum = Int(fields[3])
        else { return nil }

        return PuzzleLevel(
            id: "daily-\(date.id)",
            name: date.title,
            fenceBudget: budget,
            twoStarScore: twoStar,
            threeStarScore: threeStar,
            maximumScore: maximum,
            map: fields[4].split(separator: "/").joined(separator: "\n")
        )
    }

    /// The months the archive offers: every one of them, from the first day the almanac has
    /// up to the month the player is standing in. A daily puzzle does not expire on New
    /// Year's Eve, so neither does the calendar that holds it — a player who comes to the
    /// game in its second year can still turn back to the first day of the book.
    ///
    /// The far end is the sooner of today and the last day the book has. Nothing past today
    /// is worth turning to, since every day on that page would be shut; and nothing past
    /// the end of the book is worth turning to either, since every day on that page would
    /// be a gap. A player still on this build once the book has run out is left standing on
    /// its last month of puzzles rather than on a page of empty squares.
    static func months(upTo today: DailyDate) -> [DailyMonth] {
        guard let first = firstDay, let last = lastDay else { return [DailyMonth(of: today)] }

        let start = DailyMonth(of: first)
        let end = min(DailyMonth(of: today), DailyMonth(of: last))
        return run(from: start, to: max(start, end))
    }

    private static func run(from start: DailyMonth, to end: DailyMonth) -> [DailyMonth] {
        var found: [DailyMonth] = []
        var month = start
        while month <= end {
            found.append(month)
            month = month.next
        }
        return found
    }
}
