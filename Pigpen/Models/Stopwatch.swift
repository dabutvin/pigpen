import Foundation

/// A clock that counts up, for a board that is being timed.
///
/// Two instants and no ticking. Like everything else in this game that moves — the pasture
/// behind the title, the lap of honour, the films — the clock is a sum rather than a queue
/// of steps, so the view draws whatever `elapsed(at:)` says at the moment it happens to be
/// drawing and nothing has to be kept in step with anything.
///
/// It starts when the board appears and stops the moment the pen holds, so the lap of
/// honour is not charged. Going bigger picks it back up where it stood; starting over puts
/// it back to nothing; putting the best pen back puts the submitted time back with it.
struct Stopwatch: Equatable, Sendable {
    private(set) var started: Date?
    private(set) var stopped: Date?

    init() {}

    /// A clock picked back up on time already spent, running from this instant — how a
    /// board put away comes back to the player. What a board has cost is the time spent
    /// on it, so the hours the phone spent in a pocket in between are not part of it.
    static func resuming(_ seconds: TimeInterval, at now: Date = Date()) -> Stopwatch {
        var clock = Stopwatch()
        clock.setElapsed(seconds, at: now)
        return clock
    }

    var isRunning: Bool { started != nil && stopped == nil }
    var hasStarted: Bool { started != nil }

    /// Starts the clock, if it has not been started already. Coming back to a board that
    /// was already being timed does not put the clock back to nothing.
    mutating func start(at now: Date = Date()) {
        guard started == nil else { return }
        started = now
    }

    /// Stops the clock where it stands. A clock already stopped stays where it was stopped.
    mutating func stop(at now: Date = Date()) {
        guard isRunning else { return }
        stopped = now
    }

    /// Picks the clock back up where it stood when it was stopped, without counting the
    /// time it spent still — so going bigger after a pen holds keeps charging from the
    /// submitted time rather than from when the player tapped through the verdict.
    mutating func resume(at now: Date = Date()) {
        guard let started, let stopped else { return }
        let held = max(0, stopped.timeIntervalSince(started))
        self.started = now.addingTimeInterval(-held)
        self.stopped = nil
    }

    /// Puts the clock back to nothing and starts it counting again — what starting the
    /// field over does to the time as well as the fencing.
    mutating func reset(at now: Date = Date()) {
        started = now
        stopped = nil
    }

    /// Sets a running clock to a time already taken. Putting the fencing back on the best
    /// pen puts the submitted time back with it, so a rearrangement that was given up does
    /// not stay on the clock.
    mutating func setElapsed(_ seconds: TimeInterval, at now: Date = Date()) {
        started = now.addingTimeInterval(-max(0, seconds))
        stopped = nil
    }

    /// How long the clock has been running, which is fixed once it has been stopped.
    func elapsed(at now: Date = Date()) -> TimeInterval {
        guard let started else { return 0 }
        return max(0, (stopped ?? now).timeIntervalSince(started))
    }

    /// A clock already stopped at a given time, which is how a screenshot photographs one:
    /// a running clock reads as whenever the runner got round to it.
    static func showing(_ seconds: TimeInterval, at now: Date = Date()) -> Stopwatch {
        var clock = Stopwatch()
        clock.started = now.addingTimeInterval(-seconds)
        clock.stopped = now
        return clock
    }

    /// A count of seconds as a clock face reads it: `0:07`, `12:34`, and `1:02:03` for
    /// anybody still at it after an hour.
    static func face(_ seconds: TimeInterval) -> String {
        let whole = max(0, Int(seconds))
        let minutes = (whole / 60) % 60
        let remainder = whole % 60
        let hours = whole / 3600
        guard hours > 0 else { return "\(minutes):\(padded(remainder))" }
        return "\(hours):\(padded(minutes)):\(padded(remainder))"
    }

    /// The same count, said out loud rather than shown, for a screen reader that would
    /// otherwise read `4:07` as a date.
    static func spoken(_ seconds: TimeInterval) -> String {
        let whole = max(0, Int(seconds))
        let minutes = whole / 60
        let remainder = whole % 60
        var said: [String] = []
        if minutes > 0 { said.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }
        if remainder > 0 || minutes == 0 {
            said.append("\(remainder) second\(remainder == 1 ? "" : "s")")
        }
        return said.joined(separator: " ")
    }

    private static func padded(_ number: Int) -> String {
        number < 10 ? "0\(number)" : "\(number)"
    }
}
