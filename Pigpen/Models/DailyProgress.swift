import Foundation
import Observation

/// Where what a player did with each daily puzzle is kept: the stars, the quickest they
/// have ever held it, and whether they found the best pen the day had in it.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the world's progress
/// is one: the archive in a preview or a screenshot run wants a month with something in it,
/// and nothing on the device to show for it afterwards.
protocol DailyRecordStore {
    /// Best stars by day, keyed the way `DailyDate.id` writes a day down.
    func loadStars() -> [String: Int]
    func save(stars: [String: Int])
    /// The quickest hold on each day, in whole seconds. A slower run later does not replace
    /// it, the same way a worse pen does not take a star back off a signpost.
    func loadTimes() -> [String: Int]
    func save(times: [String: Int])
    /// The days that have given up the best pen they had in them.
    func loadBestPens() -> Set<String>
    func save(bestPens: Set<String>)
    func erase()
}

/// The real thing: what you did on Tuesday survives Wednesday.
struct StoredDailyRecords: DailyRecordStore {
    private static let starsKey = "pigpen.daily-stars"
    private static let timesKey = "pigpen.daily-times"
    private static let bestPensKey = "pigpen.daily-best-pens"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStars() -> [String: Int] {
        defaults.dictionary(forKey: Self.starsKey) as? [String: Int] ?? [:]
    }

    func save(stars: [String: Int]) {
        defaults.set(stars, forKey: Self.starsKey)
    }

    func loadTimes() -> [String: Int] {
        defaults.dictionary(forKey: Self.timesKey) as? [String: Int] ?? [:]
    }

    func save(times: [String: Int]) {
        defaults.set(times, forKey: Self.timesKey)
    }

    func loadBestPens() -> Set<String> {
        Set(defaults.stringArray(forKey: Self.bestPensKey) ?? [])
    }

    func save(bestPens: Set<String>) {
        defaults.set(Array(bestPens), forKey: Self.bestPensKey)
    }

    func erase() {
        defaults.removeObject(forKey: Self.starsKey)
        defaults.removeObject(forKey: Self.timesKey)
        defaults.removeObject(forKey: Self.bestPensKey)
    }
}

/// A book of days that forgets everything the moment it is put down.
final class RememberedDailyRecords: DailyRecordStore {
    private var stars: [String: Int]
    private var times: [String: Int]
    private var bestPens: Set<String>

    init(stars: [String: Int] = [:], times: [String: Int] = [:], bestPens: Set<String> = []) {
        self.stars = stars
        self.times = times
        self.bestPens = bestPens
    }

    func loadStars() -> [String: Int] { stars }
    func save(stars: [String: Int]) { self.stars = stars }
    func loadTimes() -> [String: Int] { times }
    func save(times: [String: Int]) { self.times = times }
    func loadBestPens() -> Set<String> { bestPens }
    func save(bestPens: Set<String>) { self.bestPens = bestPens }

    func erase() {
        stars = [:]
        times = [:]
        bestPens = []
    }
}

/// What the player has made of the daily puzzles: which days are held, how well, how
/// quickly, and how many days in a row.
///
/// Nothing here unlocks anything. A daily is opened by the calendar rather than by the day
/// before it, so a week missed is a week missed rather than a wall — the only thing a run
/// of held days buys is the run itself.
@MainActor
@Observable
final class DailyProgress {
    private(set) var starsByDay: [String: Int]
    private(set) var timesByDay: [String: Int]
    private(set) var bestPens: Set<String>
    @ObservationIgnored private let store: any DailyRecordStore

    init(store: any DailyRecordStore = StoredDailyRecords()) {
        self.store = store
        self.starsByDay = store.loadStars()
        self.timesByDay = store.loadTimes()
        self.bestPens = store.loadBestPens()
    }

    /// The best stars a day has ever given up, and 0 for one nobody has held.
    func stars(on date: DailyDate) -> Int { starsByDay[date.id] ?? 0 }

    func isHeld(_ date: DailyDate) -> Bool { stars(on: date) > 0 }

    /// The quickest that day has ever been held, in seconds.
    func bestTime(on date: DailyDate) -> Int? { timesByDay[date.id] }

    /// Whether the best pen that day had in it has been found, which is what turns its
    /// stars rainbow in the archive — the same thing it means on a signpost.
    func hasTheBestPen(on date: DailyDate) -> Bool { bestPens.contains(date.id) }

    var heldCount: Int { starsByDay.values.filter { $0 > 0 }.count }

    func heldCount(in month: DailyMonth) -> Int {
        month.days.filter { isHeld($0) }.count
    }

    /// How many days in a row have been held, counting back from today. A day still to be
    /// played does not break the run — the run simply has not been added to yet — so a
    /// player who has not had their go this morning still sees yesterday's streak.
    func streak(upTo today: DailyDate) -> Int {
        var day = isHeld(today) ? today : today.dayBefore
        var run = 0
        // A run cannot be longer than the book it is counted out of.
        while isHeld(day), run <= starsByDay.count {
            run += 1
            day = day.dayBefore
        }
        return run
    }

    /// Files what a day gave up. Stars, time and the rainbow are each kept at their best,
    /// so a slower or worse second attempt costs nothing — the same bargain the meadow's
    /// signposts offer.
    func record(_ verdict: PenVerdict, seconds: TimeInterval, on date: DailyDate) {
        guard verdict.stars > 0 else { return }

        if verdict.stars > stars(on: date) {
            starsByDay[date.id] = verdict.stars
            store.save(stars: starsByDay)
        }

        let held = max(0, Int(seconds.rounded()))
        if held < (timesByDay[date.id] ?? Int.max) {
            timesByDay[date.id] = held
            store.save(times: timesByDay)
        }

        if verdict.isAsGoodAsItGets, !bestPens.contains(date.id) {
            bestPens.insert(date.id)
            store.save(bestPens: bestPens)
        }
    }

    /// Reads the book again, for a screen that has been sitting behind a board while a day
    /// was being played.
    func reload() {
        starsByDay = store.loadStars()
        timesByDay = store.loadTimes()
        bestPens = store.loadBestPens()
    }

    /// Forgets every day ever held. Goes with the meadow's stars rather than on its own:
    /// a player asking for the game back as they found it means all of it.
    func eraseEverything() {
        starsByDay = [:]
        timesByDay = [:]
        bestPens = []
        store.erase()
    }
}

extension DailyProgress {
    /// A fortnight's worth of days behind the player, so previews and the screenshots CI
    /// takes open on an archive with something on it: a run of held days up to yesterday,
    /// one of them with the best pen the day had in it, and today still to be played.
    ///
    /// - Parameter holdingToday: Hands the player today as well, with the best pen it had
    ///   in it. The archive wants today still open, so that the square everybody is going
    ///   to press is shown waiting; the card on the title screen wants the opposite, since
    ///   what there is to see there is the stars and the clock a held day leaves behind.
    static func partWayThroughTheMonth(
        today: DailyDate,
        holdingToday: Bool = false
    ) -> DailyProgress {
        var stars: [String: Int] = [:]
        var times: [String: Int] = [:]
        var bestPens: Set<String> = [today.dayBefore.id]

        var day = today.dayBefore
        for step in 0..<12 {
            stars[day.id] = [3, 2, 3, 1, 2, 3][step % 6]
            times[day.id] = 96 + step * 37
            day = day.dayBefore
        }

        if holdingToday {
            stars[today.id] = 3
            times[today.id] = 187
            bestPens.insert(today.id)
        }

        return DailyProgress(
            store: RememberedDailyRecords(stars: stars, times: times, bestPens: bestPens)
        )
    }
}
