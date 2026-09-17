import Foundation

/// A day's pen made into something worth sending: which day it was, what the wall came to,
/// how long it took, the run of days behind it — and the board itself, which the card draws
/// the way the game draws it rather than spelling out in coloured squares.
///
/// This is only what the card *says*. `DailyPostcardCard` paints it, and what goes to the
/// chat is a picture of that painting: the game's own ground, its own water, its own pig,
/// with the day's address printed along the bottom. A grid of emoji was the first way this
/// went out and it was legible rather than lovely — the board every player is handed that
/// morning is a drawn thing, and a card that stands for it should be a drawn thing too.
///
/// The fencing goes on the card, and there is a switch for taking it off. Everybody is
/// handed the same board on a given day — the water, the pig, whatever is lying on the mud —
/// so the wall is the only part of the card that belongs to whoever built it, and a card
/// without it is a picture of somebody else's morning. It goes on.
///
/// Switching it off leaves the board as it opened, which is the card for the friend who has
/// not had their go yet: the same ground everybody else got that morning and none of the
/// answer to it.
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

    // MARK: - What the card says

    /// The game's name and the day's, across the top of the card and on the share sheet's
    /// own preview of it.
    var title: String { "Pigpen · \(date.title)" }

    /// What the pen came to and what it cost: points on a board with apples or skulls lying
    /// on it, tiles on one with nothing but ground to count, the way the verdict card reads
    /// a score.
    var ground: String { counted(tally.score, level.holdsTreats ? "point" : "tile") }
    var wall: String { counted(fences.count, "piece") }

    /// The clock, as a clock shows it, and nothing for a board nobody timed.
    var clock: String? { seconds.map { Stopwatch.face(TimeInterval($0)) } }

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

    /// The two together, for a screen reader and for anywhere a card has one line to say
    /// what happened rather than a card's worth of room.
    var remark: String { "\(ground) with \(wall). \(pigSays)" }

    // MARK: - Where it points

    /// The day's own address, which opens the game on that board on a phone that has it and
    /// the site on one that does not.
    var link: URL { DayLink.url(for: date) }

    /// The same address as it is printed along the bottom of the card. No scheme in front of
    /// it: nothing taps an address in a picture, so what is printed there is what somebody
    /// would type, and `https://` is four words of nothing to read.
    var address: String { DayLink.address(for: date) }

    /// The stars as a chat can print them, and the rainbow a best pen keeps. The card draws
    /// them; the words beside it have to say them, since a message is read before a picture
    /// loads and a good few chats show the words and nothing else.
    var starsInWriting: String {
        let won = min(max(verdict.stars, 0), 3)
        return String(repeating: "⭐", count: won) + (verdict.isAsGoodAsItGets ? "🌈" : "")
    }

    /// The words that go with the picture — what a chat puts in the message field while the
    /// card goes up as the attachment: the day's own address, so the friend on the far end
    /// has something to tap as well as something to look at, and what the pen was worth, so
    /// they know what the brag is before the picture has finished loading.
    ///
    /// The day is not in here, and that is deliberate. It is the share sheet's own title for
    /// the card — `title`, handed over as the preview — and a chat with no title line of its
    /// own prints that above the message. Saying it here as well is what had every card going
    /// out stuttering its own date, twice over: taking the subject off the share sheet did not
    /// fix it, because the preview's title becomes the subject when nothing else is given.
    ///
    /// The address goes above the tally rather than under it, and stands between two dots,
    /// for the same reason twice: a chat that decides a message *is* a link builds a second
    /// bubble out of it — a picture of the website, under a picture of the card, under the
    /// words — and what it goes on to show there is the front page, since a day's address
    /// sends a browser to the front page. The dots are the cheap half of the experiment. They
    /// have a space either side of them, which matters: a dot up against the address would be
    /// read as part of it or as the end of it, and the thing has to stay a link that a finger
    /// can land on.
    var caption: String {
        "· \(link.absoluteString) ·\n\(starsInWriting) \(remark)"
    }

    /// The card said aloud, for a screen reader that would otherwise have nothing to read at
    /// all: the day, the stars, the clock, the run and the pig's word.
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

    private func counted(_ number: Int, _ noun: String) -> String {
        "\(number) \(noun)\(number == 1 ? "" : "s")"
    }
}
