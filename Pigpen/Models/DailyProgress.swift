import Foundation
import Observation

/// Where what a player did with each daily puzzle is kept: the stars, the quickest they
/// have ever finished it, whether they found the best pen the day had in it, and the
/// board as it stood when a day was put away mid-puzzle.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the world's progress
/// is one: the archive in a preview or a screenshot run wants a month with something in it,
/// and nothing on the device to show for it afterwards.
protocol DailyRecordStore {
    /// Best stars by day, keyed the way `DailyDate.id` writes a day down.
    func loadStars() -> [String: Int]
    func save(stars: [String: Int])
    /// The quickest run on each day, in whole seconds. A slower one later does not replace
    /// it, the same way a worse pen does not take a star back off a signpost.
    func loadTimes() -> [String: Int]
    func save(times: [String: Int])
    /// The days that have given up the best pen they had in them.
    func loadBestPens() -> Set<String>
    func save(bestPens: Set<String>)
    /// Boards put away mid-puzzle, keyed the same way: fencing, the session's best pen,
    /// and where the clock stood, so hitting back without releasing the animals still
    /// keeps the day as it was.
    func loadDrafts() -> [String: DailyDraft]
    func save(drafts: [String: DailyDraft])
    func erase()
}

/// What was on a day's board when it was put away without the animals being released —
/// or after they were, if the player went back out to widen the pen and left again.
///
/// Kept as coordinates rather than a live `PuzzleGame`, so a draft survives the screen
/// that built it and can be laid back down on a fresh board.
struct DailyDraft: Equatable, Codable, Sendable {
    /// Every tile that had fencing on it.
    var fences: [GridPoint]
    /// The fencing of the best pen closed this go, when there was one.
    var bestPen: [GridPoint]?
    /// When the clock first started on this go, and when it stopped if the pen has held.
    var clockStarted: Date?
    var clockStopped: Date?

    var fenceTiles: Set<GridPoint> { Set(fences) }
    var bestPenTiles: Set<GridPoint>? { bestPen.map(Set.init) }

    /// Whether there is anything on this draft worth opening the board back onto —
    /// fencing still in the ground, or a best pen of the go waiting to be put back.
    /// A clock alone is not progress; it travels with the fencing when there is some.
    var hasAnythingOnIt: Bool {
        !fences.isEmpty || bestPen != nil
    }
}

/// The real thing: what you did on Tuesday survives Wednesday.
struct StoredDailyRecords: DailyRecordStore {
    private static let starsKey = "pigpen.daily-stars"
    private static let timesKey = "pigpen.daily-times"
    private static let bestPensKey = "pigpen.daily-best-pens"
    private static let draftsKey = "pigpen.daily-drafts"
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

    func loadDrafts() -> [String: DailyDraft] {
        guard let data = defaults.data(forKey: Self.draftsKey) else { return [:] }
        return (try? JSONDecoder().decode([String: DailyDraft].self, from: data)) ?? [:]
    }

    func save(drafts: [String: DailyDraft]) {
        guard let data = try? JSONEncoder().encode(drafts) else { return }
        defaults.set(data, forKey: Self.draftsKey)
    }

    func erase() {
        defaults.removeObject(forKey: Self.starsKey)
        defaults.removeObject(forKey: Self.timesKey)
        defaults.removeObject(forKey: Self.bestPensKey)
        defaults.removeObject(forKey: Self.draftsKey)
    }
}

/// A book of days that forgets everything the moment it is put down.
final class RememberedDailyRecords: DailyRecordStore {
    private var stars: [String: Int]
    private var times: [String: Int]
    private var bestPens: Set<String>
    private var drafts: [String: DailyDraft]

    init(
        stars: [String: Int] = [:],
        times: [String: Int] = [:],
        bestPens: Set<String> = [],
        drafts: [String: DailyDraft] = [:]
    ) {
        self.stars = stars
        self.times = times
        self.bestPens = bestPens
        self.drafts = drafts
    }

    func loadStars() -> [String: Int] { stars }
    func save(stars: [String: Int]) { self.stars = stars }
    func loadTimes() -> [String: Int] { times }
    func save(times: [String: Int]) { self.times = times }
    func loadBestPens() -> Set<String> { bestPens }
    func save(bestPens: Set<String>) { self.bestPens = bestPens }
    func loadDrafts() -> [String: DailyDraft] { drafts }
    func save(drafts: [String: DailyDraft]) { self.drafts = drafts }

    func erase() {
        stars = [:]
        times = [:]
        bestPens = []
        drafts = [:]
    }
}

/// What the player has made of the daily puzzles: which days are complete, how well, how
/// quickly, and how many days in a row.
///
/// Nothing here unlocks anything. A daily is opened by the calendar rather than by the day
/// before it, so a week missed is a week missed rather than a wall — the only thing a run
/// of completed days buys is the run itself.
@MainActor
@Observable
final class DailyProgress {
    private(set) var starsByDay: [String: Int]
    private(set) var timesByDay: [String: Int]
    private(set) var bestPens: Set<String>
    private(set) var draftsByDay: [String: DailyDraft]
    @ObservationIgnored private let store: any DailyRecordStore

    init(store: any DailyRecordStore = StoredDailyRecords()) {
        self.store = store
        self.starsByDay = store.loadStars()
        self.timesByDay = store.loadTimes()
        self.bestPens = store.loadBestPens()
        self.draftsByDay = store.loadDrafts()
    }

    /// The best stars a day has ever given up, and 0 for one nobody has finished.
    func stars(on date: DailyDate) -> Int { starsByDay[date.id] ?? 0 }

    func isComplete(_ date: DailyDate) -> Bool { stars(on: date) > 0 }

    /// The quickest that day has ever been finished, in seconds.
    func bestTime(on date: DailyDate) -> Int? { timesByDay[date.id] }

    /// Whether the best pen that day had in it has been found, which is what turns its
    /// stars rainbow in the archive — the same thing it means on a signpost.
    func hasTheBestPen(on date: DailyDate) -> Bool { bestPens.contains(date.id) }

    /// Whether a day was put away with fencing, a remembered pen, or a clock already
    /// running on it — enough that opening it again should not start from bare mud.
    func hasDraft(on date: DailyDate) -> Bool {
        draftsByDay[date.id]?.hasAnythingOnIt == true
    }

    /// True when any day still has a board mid-puzzle on it.
    var hasDrafts: Bool { draftsByDay.values.contains(where: \.hasAnythingOnIt) }

    var completedCount: Int { starsByDay.values.filter { $0 > 0 }.count }

    func completedCount(in month: DailyMonth) -> Int {
        month.days.filter { isComplete($0) }.count
    }

    /// How many days in a row are complete, counting back from today. A day still to be
    /// played does not break the run — the run simply has not been added to yet — so a
    /// player who has not had their go this morning still sees yesterday's streak.
    func streak(upTo today: DailyDate) -> Int {
        var day = isComplete(today) ? today : today.dayBefore
        var run = 0
        // A run cannot be longer than the book it is counted out of.
        while isComplete(day), run <= starsByDay.count {
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

        let taken = max(0, Int(seconds.rounded()))
        if taken < (timesByDay[date.id] ?? Int.max) {
            timesByDay[date.id] = taken
            store.save(times: timesByDay)
        }

        if verdict.isAsGoodAsItGets, !bestPens.contains(date.id) {
            bestPens.insert(date.id)
            store.save(bestPens: bestPens)
        }
    }

    /// Puts a day's board away as it stands — fencing, the best pen of the go, and the
    /// clock — so hitting back without releasing the animals does not throw the work out.
    /// An empty field with a clock that never started is forgotten rather than kept.
    func saveDraft(from game: PuzzleGame, clock: Stopwatch?, on date: DailyDate) {
        let draft = DailyDraft(
            fences: game.fences.sorted { ($0.row, $0.column) < ($1.row, $1.column) },
            bestPen: game.bestPen.map {
                $0.fences.sorted { ($0.row, $0.column) < ($1.row, $1.column) }
            },
            clockStarted: clock?.started,
            clockStopped: clock?.stopped
        )

        guard draft.hasAnythingOnIt else {
            clearDraft(on: date)
            return
        }

        draftsByDay[date.id] = draft
        store.save(drafts: draftsByDay)
    }

    /// The board a day should open on: the draft left behind, or a fresh field when there
    /// was nothing to pick back up.
    func game(for level: PuzzleLevel, on date: DailyDate) -> PuzzleGame {
        guard let draft = draftsByDay[date.id], draft.hasAnythingOnIt else {
            return PuzzleGame(level: level)
        }

        let best: PuzzleGame.Pen?
        if let tiles = draft.bestPenTiles,
           case .penned(let pen) = level.release(fences: tiles) {
            best = PuzzleGame.Pen(fences: tiles, tally: level.tally(for: pen))
        } else {
            best = nil
        }

        return PuzzleGame(level: level, fences: draft.fenceTiles, bestPen: best)
    }

    /// The clock a day should open with: the one left running or stopped on the draft, or
    /// a fresh clock when the day has never been timed.
    func clock(on date: DailyDate) -> Stopwatch {
        guard let draft = draftsByDay[date.id], let started = draft.clockStarted else {
            return Stopwatch()
        }
        return Stopwatch(started: started, stopped: draft.clockStopped)
    }

    /// Forgets a day's unfinished board, leaving the stars and times alone.
    func clearDraft(on date: DailyDate) {
        guard draftsByDay.removeValue(forKey: date.id) != nil else { return }
        store.save(drafts: draftsByDay)
    }

    /// Reads the book again, for a screen that has been sitting behind a board while a day
    /// was being played.
    func reload() {
        starsByDay = store.loadStars()
        timesByDay = store.loadTimes()
        bestPens = store.loadBestPens()
        draftsByDay = store.loadDrafts()
    }

    /// Forgets every day ever finished. Goes with the meadow's stars rather than on its own:
    /// a player asking for the game back as they found it means all of it.
    func eraseEverything() {
        starsByDay = [:]
        timesByDay = [:]
        bestPens = []
        draftsByDay = [:]
        store.erase()
    }
}

extension DailyProgress {
    /// A fortnight's worth of days behind the player, so previews and the screenshots CI
    /// takes open on an archive with something on it: a run of finished days up to yesterday,
    /// one of them with the best pen the day had in it, and today still to be played.
    ///
    /// - Parameter includingToday: Hands the player today as well, with the best pen it had
    ///   in it. The archive wants today still open, so that the square everybody is going
    ///   to press is shown waiting; the card on the title screen wants the opposite, since
    ///   what there is to see there is the stars and the clock a finished day leaves behind.
    static func partWayThroughTheMonth(
        today: DailyDate,
        includingToday: Bool = false
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

        if includingToday {
            stars[today.id] = 3
            times[today.id] = 187
            bestPens.insert(today.id)
        }

        return DailyProgress(
            store: RememberedDailyRecords(stars: stars, times: times, bestPens: bestPens)
        )
    }
}
