import Foundation

/// Every time the game asks a player for something — to buy it, to be reminded, to rate it —
/// written down, so the asks do not pile up on one another.
///
/// They used to be decided each on its own, and each on the same kind of high point: the end
/// of the meadow, the first day held. So the counting found players being handed three or
/// four of them within the same few minutes — the store, Apple's rating prompt and a reminder
/// offer or two — and answering most of them *Not now*. Each ask here is worth more on a
/// quiet moment than on a crowded one, so the ones that can wait, wait.
///
/// The store is the ask that never waits. It is only ever raised by a tap on something the
/// free game has shut, which is the player asking rather than the game, and the counting says
/// that moment is exactly when players buy. It is written down all the same, so the others
/// know to keep clear of it.
enum Ask: String, CaseIterable, Sendable {
    /// The offer of the full game put up.
    case store
    /// The game's own offer of a reminder — the run of days, or the level a day away.
    case reminder
    /// Apple's rating prompt asked for.
    case rating
}

/// Where the last time of each ask is kept, so a game closed and opened again still knows it
/// asked something ten minutes ago.
protocol AskStore {
    func loadLastAsked() -> [Ask: Date]
    func save(lastAsked: [Ask: Date])
}

/// The real thing, kept beside the rest of the game's settings.
struct StoredAsks: AskStore {
    private static let key = "pigpen.asks-last-made"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadLastAsked() -> [Ask: Date] {
        let raw = defaults.dictionary(forKey: Self.key) as? [String: Date] ?? [:]
        var asked: [Ask: Date] = [:]
        for (name, day) in raw {
            if let ask = Ask(rawValue: name) { asked[ask] = day }
        }
        return asked
    }

    func save(lastAsked: [Ask: Date]) {
        var raw: [String: Date] = [:]
        for (ask, day) in lastAsked { raw[ask.rawValue] = day }
        defaults.set(raw, forKey: Self.key)
    }
}

/// A ledger that forgets itself the moment it is put down.
final class RememberedAsks: AskStore {
    private var lastAsked: [Ask: Date]

    init(lastAsked: [Ask: Date] = [:]) {
        self.lastAsked = lastAsked
    }

    func loadLastAsked() -> [Ask: Date] { lastAsked }
    func save(lastAsked: [Ask: Date]) { self.lastAsked = lastAsked }
}

/// When the game last asked for each thing, and whether another ask would be piling on.
///
/// Two rules, one about time and one about the sitting. An ask made within the last hour is
/// too recent for another, whichever launch it was made in. And an ask made at any point
/// since the game was opened keeps the rest quiet until the next time it is, since a sitting
/// is how a player experiences the game and three asks spread over one long evening are still
/// three asks in one evening.
@MainActor
final class AskLedger {
    /// The one the whole game writes into, so every ask sees every other.
    static let shared = AskLedger()

    /// How long an ask keeps the others quiet across launches.
    static let gap: TimeInterval = 60 * 60

    private(set) var lastAsked: [Ask: Date]
    /// What has been asked since the game was opened. Held in memory alone, which is what
    /// makes it a sitting: the next launch starts with nothing in it.
    private(set) var askedThisSitting: Set<Ask> = []

    private let store: any AskStore

    init(store: any AskStore = StoredAsks()) {
        self.store = store
        self.lastAsked = store.loadLastAsked()
    }

    /// Writes an ask down as made.
    func note(_ ask: Ask, at now: Date = Date()) {
        askedThisSitting.insert(ask)
        lastAsked[ask] = now
        store.save(lastAsked: lastAsked)
    }

    /// Whether an ask has been made this sitting or within the gap.
    ///
    /// A clock wound backwards reads as recent, which keeps things quiet: the cost of an ask
    /// withheld is an ask made on the next visit instead.
    func wasRecent(_ ask: Ask, now: Date = Date()) -> Bool {
        if askedThisSitting.contains(ask) { return true }
        guard let when = lastAsked[ask] else { return false }
        return now.timeIntervalSince(when) < Self.gap
    }

    /// Whether any ask other than the one named — and other than any it is being made
    /// alongside — has been made recently, and so whether this one should wait for a
    /// quieter moment.
    ///
    /// - Parameter alongside: Asks this one is deliberately made together with. The offer of
    ///   a reminder at the free game's wait is made on the same sheet as the store's offer,
    ///   since both answer the same wait, and that is one moment rather than two.
    func isCrowded(for ask: Ask, alongside: Set<Ask> = [], now: Date = Date()) -> Bool {
        Ask.allCases.contains { other in
            guard other != ask, !alongside.contains(other) else { return false }
            return wasRecent(other, now: now)
        }
    }

    /// Whether this very ask has already been made this sitting.
    func hasAsked(_ ask: Ask) -> Bool { askedThisSitting.contains(ask) }
}

extension AskLedger {
    /// A ledger with nothing in it and nowhere to keep anything, for a preview or a test.
    static func empty() -> AskLedger { AskLedger(store: RememberedAsks()) }
}
