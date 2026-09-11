import Foundation
import Observation

/// Where the roses Hamish has given away are written down, so that three a day is three a day
/// across the app being closed.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the stars and the outfit
/// go through one: a preview, a test or a screenshot run can hand out roses without touching
/// the defaults of the machine it is running on.
protocol HintAllowanceStore {
    /// When each rose was given, oldest first.
    func loadRoses() -> [Date]
    func save(roses: [Date])
    /// Forgets every rose, for the player asking for the game back as they found it.
    func erase()
}

/// The real thing: the roses survive the app being closed.
struct StoredHintAllowance: HintAllowanceStore {
    private static let key = "pigpen.roses-given"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadRoses() -> [Date] {
        let kept = defaults.array(forKey: Self.key) as? [Double] ?? []
        return kept.map { Date(timeIntervalSinceReferenceDate: $0) }.sorted()
    }

    func save(roses: [Date]) {
        defaults.set(roses.map(\.timeIntervalSinceReferenceDate), forKey: Self.key)
    }

    func erase() {
        defaults.removeObject(forKey: Self.key)
    }
}

/// A count that forgets the moment it is put down.
final class RememberedHintAllowance: HintAllowanceStore {
    private var roses: [Date]

    init(roses: [Date] = []) {
        self.roses = roses
    }

    func loadRoses() -> [Date] { roses }

    func save(roses: [Date]) { self.roses = roses }

    func erase() { roses = [] }
}

/// How many hints are left today, and the only place in the game that question is answered.
///
/// Three roses in any twenty-four hours, counted from when each was given rather than from
/// midnight: a rose given at nine in the evening is back at nine the next evening, so there is
/// no hour of the day at which the count snaps back and no clock to game. The count is the
/// player's rather than a level's — three roses spent on one field are three spent — since the
/// point of the limit is that a hint is something to be a little careful with.
///
/// It is progress of a sort, so *Clear all game data* throws the roses away with the stars.
@MainActor
@Observable
final class HintAllowance {
    /// The one the boards hand roses out of.
    static let shared = HintAllowance()

    /// How many roses a day holds.
    static let perDay = 3
    /// How long a rose given stays given.
    static let day: TimeInterval = 24 * 60 * 60

    /// When each rose still counted against the player was given, oldest first. Roses older
    /// than a day are dropped as they are read, so this never carries more than three.
    private(set) var given: [Date]

    @ObservationIgnored private let store: any HintAllowanceStore

    init(store: any HintAllowanceStore = StoredHintAllowance()) {
        self.store = store
        self.given = store.loadRoses()
    }

    /// The roses given inside the last day, as of `now`.
    private func counted(at now: Date) -> [Date] {
        given.filter { now.timeIntervalSince($0) < Self.day && $0 <= now }
    }

    /// How many roses are left to give, as of `now`.
    func remaining(at now: Date = .now) -> Int {
        max(0, Self.perDay - counted(at: now).count)
    }

    /// When the next rose comes back, or nothing while there is still one to give.
    func nextRose(at now: Date = .now) -> Date? {
        let counted = counted(at: now)
        guard counted.count >= Self.perDay, let oldest = counted.first else { return nil }
        return oldest.addingTimeInterval(Self.day)
    }

    /// Gives one rose, if there is one to give. Returns whether there was.
    @discardableResult
    func spend(at now: Date = .now) -> Bool {
        let counted = counted(at: now)
        guard counted.count < Self.perDay else { return false }
        given = (counted + [now]).sorted()
        store.save(roses: given)
        return true
    }

    /// Forgets every rose. Called only by the button that throws every star away.
    func eraseEverything() {
        given = []
        store.erase()
    }

    /// How long until `until`, said the way a notice board says it: *in about three hours*,
    /// *in about an hour*, *in twenty minutes*, *in a minute*. Never a clock time, since a
    /// board in the meadow does not know what time zone the meadow is in.
    static func said(until: Date, from now: Date) -> String {
        let seconds = max(60, until.timeIntervalSince(now))
        let minutes = Int((seconds / 60).rounded(.up))
        let hours = Int((seconds / 3600).rounded())
        if seconds >= 90 * 60 {
            return "in about \(spelled(hours)) hours"
        } else if seconds >= 45 * 60 {
            return "in about an hour"
        } else if minutes <= 1 {
            return "in a minute"
        } else {
            return "in \(spelled(minutes)) minutes"
        }
    }

    /// A count in words, up to ninety-nine: *three*, *twenty-four*, *forty-four*. Anything a
    /// day's wait could come to, and digits past that, which nothing here ever asks for.
    private static func spelled(_ number: Int) -> String {
        let ones = [
            "no", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
            "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
            "seventeen", "eighteen", "nineteen"
        ]
        let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
        guard number >= 0, number < 100 else { return String(number) }
        if number < 20 { return ones[number] }
        let rest = number % 10
        return rest == 0 ? tens[number / 10] : "\(tens[number / 10])-\(ones[rest])"
    }
}

extension HintAllowance {
    /// An allowance held in memory, so that a preview, a test or a screenshot run handing out
    /// roses is not spending the roses of whoever is looking at it.
    static func remembering(_ roses: [Date] = []) -> HintAllowance {
        HintAllowance(store: RememberedHintAllowance(roses: roses))
    }
}
