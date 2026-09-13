import Foundation

/// A day's pen written out so it can be pasted into a chat: which day it was, what the pen
/// gave up, how long it took, the run of days behind it — and the board itself, a tile to
/// an emoji, with or without the fencing drawn on.
///
/// Text rather than a picture, because text is what a group chat is made of: it lands as
/// a message rather than an attachment, it is quoted and replied to like one, and a friend
/// who has not played can read the day off it and go and have their own go. The game's
/// own address stands at the bottom for that friend.
///
/// The fencing is a choice rather than a given. Everybody gets the same board on a given
/// day, which is the whole of what makes a daily worth comparing, and a card with the wall
/// drawn on it hands over the answer to anybody it reaches. So the board goes as it was
/// opened — the water, the pig, whatever was lying on the mud — and the fencing is put on
/// only when asked for, for the friend who has already had their go.
struct DailyPostcard: Identifiable, Sendable {
    let date: DailyDate
    let level: PuzzleLevel
    /// The wall that held.
    let fences: Set<GridPoint>
    /// The ground it shut the pig into.
    let pen: Set<GridPoint>
    let tally: PenTally
    let verdict: PenVerdict
    /// How long the day took, in whole seconds, and nothing for a board nobody timed.
    let seconds: Int?
    /// How many days in a row this one makes. Only worth saying for today: the run behind
    /// a day dug out of the archive is not a run anybody is on.
    let streak: Int

    var id: String { date.id }

    /// Writes the card for a wall that holds, and nothing at all for one that does not — a
    /// pig that walked out is not a solve, and there is no postcard for it.
    init?(
        date: DailyDate,
        level: PuzzleLevel,
        fences: Set<GridPoint>,
        seconds: TimeInterval? = nil,
        streak: Int = 0
    ) {
        guard case .penned(let pen) = level.release(fences: fences) else { return nil }
        let tally = level.tally(for: pen)
        self.date = date
        self.level = level
        self.fences = fences
        self.pen = pen
        self.tally = tally
        self.verdict = level.verdict(forScore: tally.score)
        self.seconds = seconds.map { max(0, Int($0.rounded())) }
        self.streak = streak
    }

    // MARK: - The card

    /// The whole card, top to bottom: the day, the verdict, the board, the address.
    func text(showingFencing: Bool) -> String {
        var lines = [heading, summary, remark, ""]
        lines += board(showingFencing: showingFencing)
        lines += ["", SupportLinks.host]
        return lines.joined(separator: "\n")
    }

    /// The game's name and the day's, the way the day names itself as a puzzle.
    var heading: String { "\(Self.pig) Pigpen · \(date.title)" }

    /// The stars, the rainbow a best pen keeps, the clock and the run of days — each of
    /// them only when there is one to say.
    var summary: String {
        var stars = String(repeating: "⭐", count: verdict.stars)
        if verdict.isAsGoodAsItGets { stars += "🌈" }

        var parts = [stars]
        if let seconds { parts.append("⏱️ \(Stopwatch.face(TimeInterval(seconds)))") }
        if streak > 1 { parts.append("🔥 \(streak) days in a row") }
        return parts.joined(separator: " · ")
    }

    /// What the pen came to, and what the pig makes of it. Points on a board with apples
    /// or skulls lying on it, tiles on one with nothing but ground to count, the way the
    /// verdict card reads a score.
    var remark: String {
        let ground = counted(tally.score, level.holdsTreats ? "point" : "tile")
        return "\(ground) with \(counted(fences.count, "piece")). \(pigSays)"
    }

    /// The pig's word on the pen, in the voice the verdict card uses: nothing to add to the
    /// best pen there is, and a little more to say the further below it the pen stands.
    var pigSays: String {
        guard !verdict.isAsGoodAsItGets else { return "Pig has no notes." }
        return switch verdict.stars {
        case 3: "A pen worth bragging about."
        case 2: "A great pen. Could be bigger."
        default: "Held, just about."
        }
    }

    /// The board, a row to a line and a tile to an emoji. With the fencing off it is the
    /// board every player was handed that morning; with it on, the wall stands as logs
    /// and the ground it holds is washed gold, as on the field.
    func board(showingFencing: Bool) -> [String] {
        (0..<level.rowCount).map { row in
            (0..<level.columnCount)
                .map { tile(GridPoint(row: row, column: $0), showingFencing: showingFencing) }
                .joined()
        }
    }

    /// The card said aloud, for a screen reader that would otherwise read the board out a
    /// square at a time: the day, the stars, the clock, the run and the pig's word.
    var spoken: String {
        let spelled = ["No", "One", "Two", "Three"]
        let stars = min(max(verdict.stars, 0), 3)
        var starsSaid = "\(spelled[stars]) star\(stars == 1 ? "" : "s")"
        if verdict.isAsGoodAsItGets { starsSaid += ", the best pen there is" }

        var said = ["Postcard for \(date.fullTitle).", "\(starsSaid)."]
        if let seconds { said.append("\(Stopwatch.spoken(TimeInterval(seconds))).") }
        if streak > 1 { said.append("\(streak) days in a row.") }
        said.append(remark)
        return said.joined(separator: " ")
    }

    // MARK: - The tiles

    /// Open ground. The field's mud is cream rather than brown, and the pale square is the
    /// one the keyboard has that reads as it.
    static let mud = "⬜"
    static let water = "🟦"
    /// Ground the pen holds, washed gold as it is on the field.
    static let held = "🟨"
    /// A fence piece. A log is the nearest thing a keyboard has to a picket.
    static let fence = "🪵"
    static let pig = "🐷"
    /// Any other animal, should a day ever stand one on the board. None does yet.
    static let somebodyElse = "🐾"
    static let apple = "🍎"
    static let skull = "💀"

    private func tile(_ point: GridPoint, showingFencing: Bool) -> String {
        if let animal = level.animals.first(where: { $0.tile == point }) {
            return animal.kind == .pig ? Self.pig : Self.somebodyElse
        }
        if let treat = level.treat(at: point) {
            return treat == .apple ? Self.apple : Self.skull
        }
        if level.terrain(at: point) == .water { return Self.water }
        if showingFencing {
            if fences.contains(point) { return Self.fence }
            if pen.contains(point) { return Self.held }
        }
        return Self.mud
    }

    private func counted(_ number: Int, _ noun: String) -> String {
        "\(number) \(noun)\(number == 1 ? "" : "s")"
    }
}
