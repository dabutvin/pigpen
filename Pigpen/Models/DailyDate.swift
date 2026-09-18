import Foundation

/// A day on the calendar, written down the way the almanac keeps it.
///
/// Three plain numbers rather than a `Date`, because a daily puzzle belongs to a square on
/// a wall calendar rather than to an instant: the puzzle for the eighth of April is the
/// same puzzle at one minute past midnight as it is at bedtime, and the same puzzle
/// wherever the phone happens to be standing.
struct DailyDate: Hashable, Comparable, Sendable, Identifiable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// How the almanac writes a day down, and how a day's record is filed: `2026-04-08`.
    /// Sortable as text as well as as a date, which is what makes it a good key.
    var id: String { "\(year)-\(Self.padded(month))-\(Self.padded(day))" }

    static func < (left: Self, right: Self) -> Bool {
        (left.year, left.month, left.day) < (right.year, right.month, right.day)
    }

    /// Reads a day back out of the form `id` writes it in.
    init?(_ written: some StringProtocol) {
        let parts = written.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]),
              (1...12).contains(month), day >= 1, day <= Self.days(inMonth: month, of: year)
        else { return nil }
        self.init(year: year, month: month, day: day)
    }

    /// The day the phone is standing on, in whatever time zone it is standing in. The one
    /// place the almanac asks the system anything: which square of the calendar it is.
    static func today(_ now: Date = Date(), calendar: Calendar = .current) -> DailyDate {
        let parts = calendar.dateComponents([.year, .month, .day], from: now)
        return DailyDate(
            year: parts.year ?? 2026,
            month: parts.month ?? 1,
            day: parts.day ?? 1
        )
    }

    // MARK: - The week

    /// Which day of the week this falls on, which is the whole of how hard it is: the
    /// almanac starts a week gently on Monday and works up to Sunday.
    ///
    /// Worked out from the date itself rather than asked of a calendar, so a puzzle's
    /// difficulty is a property of the day and not of the phone's locale — a Sunday is the
    /// week's worst wherever the week is reckoned to start.
    var weekday: Weekday {
        // Sakamoto's, which puts the year back a step for January and February so that the
        // leap day falls at the end of it.
        let shifts = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
        var year = self.year
        if month < 3 { year -= 1 }
        let index = (year + year / 4 - year / 100 + year / 400 + shifts[month - 1] + day) % 7
        return Weekday(rawValue: index) ?? .sunday
    }

    // MARK: - Walking the calendar

    var dayBefore: DailyDate {
        if day > 1 { return DailyDate(year: year, month: month, day: day - 1) }
        if month > 1 {
            return DailyDate(year: year, month: month - 1, day: Self.days(inMonth: month - 1, of: year))
        }
        return DailyDate(year: year - 1, month: 12, day: 31)
    }

    var dayAfter: DailyDate {
        if day < Self.days(inMonth: month, of: year) {
            return DailyDate(year: year, month: month, day: day + 1)
        }
        if month < 12 { return DailyDate(year: year, month: month + 1, day: 1) }
        return DailyDate(year: year + 1, month: 1, day: 1)
    }

    static func days(inMonth month: Int, of year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: 31
        case 4, 6, 9, 11: 30
        default: isLeap(year) ? 29 : 28
        }
    }

    static func isLeap(_ year: Int) -> Bool {
        year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }

    // MARK: - Saying it out loud

    /// The day as a puzzle's name: `Wednesday 8 April`. The year is left off, since the
    /// month it belongs to is written over whatever screen led here.
    var title: String {
        String(localized: "date.title", defaultValue: "\(weekday.name) \(day) \(Self.monthName(month))")
    }

    /// The day with the year on it, for anywhere the month is not already written down.
    ///
    /// The year goes in as words rather than as a number. A number handed to a localised
    /// format is grouped by the locale's rules, and 2026 comes back as "2,026"; a year is
    /// never grouped in any language the game speaks, because it is a label and not a count.
    var fullTitle: String {
        String(localized: "date.fullTitle", defaultValue: "\(title) \(String(year))")
    }

    /// The day as a line under a button's own name: `Tue, September 8`. The month comes
    /// before the day and the weekday takes a comma, which is how a date is read rather than
    /// how a puzzle is named — and the weekday is shortened, since the line has a run of days
    /// to carry beside it and the day of the week reads at a glance from three letters.
    var written: String {
        String(localized: "date.written", defaultValue: "\(weekday.short), \(Self.monthName(month)) \(day)")
    }

    static func monthName(_ month: Int) -> String {
        switch month {
        case 1: String(localized: "month.january", defaultValue: "January")
        case 2: String(localized: "month.february", defaultValue: "February")
        case 3: String(localized: "month.march", defaultValue: "March")
        case 4: String(localized: "month.april", defaultValue: "April")
        case 5: String(localized: "month.may", defaultValue: "May")
        case 6: String(localized: "month.june", defaultValue: "June")
        case 7: String(localized: "month.july", defaultValue: "July")
        case 8: String(localized: "month.august", defaultValue: "August")
        case 9: String(localized: "month.september", defaultValue: "September")
        case 10: String(localized: "month.october", defaultValue: "October")
        case 11: String(localized: "month.november", defaultValue: "November")
        case 12: String(localized: "month.december", defaultValue: "December")
        default: ""
        }
    }

    private static func padded(_ number: Int) -> String {
        number < 10 ? "0\(number)" : "\(number)"
    }
}

/// A day of the week, in the order a calendar lays its columns out.
///
/// The raw values run from Sunday because that is the column a grid starts with; what the
/// almanac cares about is `rung`, which runs the other way — Monday is the gentlest puzzle
/// of the week and Sunday the worst of it.
enum Weekday: Int, CaseIterable, Sendable {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday

    /// Where the day stands in the week's climb, 1 for Monday up to 7 for Sunday.
    var rung: Int { self == .sunday ? 7 : rawValue }

    var name: String {
        switch self {
        case .sunday: String(localized: "weekday.sunday", defaultValue: "Sunday")
        case .monday: String(localized: "weekday.monday", defaultValue: "Monday")
        case .tuesday: String(localized: "weekday.tuesday", defaultValue: "Tuesday")
        case .wednesday: String(localized: "weekday.wednesday", defaultValue: "Wednesday")
        case .thursday: String(localized: "weekday.thursday", defaultValue: "Thursday")
        case .friday: String(localized: "weekday.friday", defaultValue: "Friday")
        case .saturday: String(localized: "weekday.saturday", defaultValue: "Saturday")
        }
    }

    /// The day shortened to the three letters a calendar uses, for a line with other things
    /// on it. Never spoken — VoiceOver is handed `name` wherever this is drawn.
    ///
    /// Written down a day at a time rather than cut off the front of `name`, because three
    /// letters is an English habit: German shortens Mittwoch to two, and a language that does
    /// not write its days in letters at all has nothing to take a prefix of.
    var short: String {
        switch self {
        case .sunday: String(localized: "weekday.sunday.short", defaultValue: "Sun")
        case .monday: String(localized: "weekday.monday.short", defaultValue: "Mon")
        case .tuesday: String(localized: "weekday.tuesday.short", defaultValue: "Tue")
        case .wednesday: String(localized: "weekday.wednesday.short", defaultValue: "Wed")
        case .thursday: String(localized: "weekday.thursday.short", defaultValue: "Thu")
        case .friday: String(localized: "weekday.friday.short", defaultValue: "Fri")
        case .saturday: String(localized: "weekday.saturday.short", defaultValue: "Sat")
        }
    }

    /// The letter over its column in the archive. Written down for the same reason as `short`,
    /// and with one more: Saturday and Sunday share a letter in English and the archive has
    /// always lived with it, but a language where they do not should not have to.
    var initial: String {
        switch self {
        case .sunday: String(localized: "weekday.sunday.initial", defaultValue: "S")
        case .monday: String(localized: "weekday.monday.initial", defaultValue: "M")
        case .tuesday: String(localized: "weekday.tuesday.initial", defaultValue: "T")
        case .wednesday: String(localized: "weekday.wednesday.initial", defaultValue: "W")
        case .thursday: String(localized: "weekday.thursday.initial", defaultValue: "T")
        case .friday: String(localized: "weekday.friday.initial", defaultValue: "F")
        case .saturday: String(localized: "weekday.saturday.initial", defaultValue: "S")
        }
    }
}

/// A month of the archive: the year and the month, and the days in it.
struct DailyMonth: Hashable, Comparable, Sendable, Identifiable {
    let year: Int
    let month: Int

    var id: String { "\(year)-\(month < 10 ? "0" : "")\(month)" }

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    init(of date: DailyDate) {
        self.init(year: date.year, month: date.month)
    }

    static func < (left: Self, right: Self) -> Bool {
        (left.year, left.month) < (right.year, right.month)
    }

    /// The year is written out rather than counted, for the reason `DailyDate.fullTitle`
    /// gives: a localised format would group it into "2,026".
    var name: String {
        String(localized: "date.month",
               defaultValue: "\(DailyDate.monthName(month)) \(String(year))")
    }

    var days: [DailyDate] {
        (1...DailyDate.days(inMonth: month, of: year)).map {
            DailyDate(year: year, month: month, day: $0)
        }
    }

    /// How many blank squares the grid opens with before the first of the month, counting
    /// from a Sunday column.
    var openingBlanks: Int {
        DailyDate(year: year, month: month, day: 1).weekday.rawValue
    }

    var next: DailyMonth {
        month < 12 ? DailyMonth(year: year, month: month + 1) : DailyMonth(year: year + 1, month: 1)
    }

    var previous: DailyMonth {
        month > 1 ? DailyMonth(year: year, month: month - 1) : DailyMonth(year: year - 1, month: 12)
    }

    func contains(_ date: DailyDate) -> Bool {
        date.year == year && date.month == month
    }
}
