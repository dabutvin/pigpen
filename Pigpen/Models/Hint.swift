/// A nudge towards the idea a field is built on, for a player the field has beaten.
///
/// Every level on a trail asks one question — see `Question` — and the answer to that
/// question is an idea rather than a set of tiles: the water is a wall you already own, a
/// staircase holds twice what a box does, a skull is a tile you cannot build on. A player
/// who is stuck is nearly always stuck on the idea and not on the tiles, so that is what a
/// hint says. It never says where a piece goes, never counts anything, and never shows the
/// pen: the same hint serves the meadow's River Bend and every shore the later worlds ask
/// harder, and on any of them the whole of the finding is still the player's.
///
/// A hint is locked until the gate has been opened twice. The first thing tapped on a new
/// board should never be the answer, and two goes is enough to have met the field — a go on
/// an empty board is a legal go and counts, since a player who wants the hint that badly
/// wants it. The lock resets with the board, so a level come back to a week later asks for
/// two goes again, which is the price of the hint being useful rather than a habit.
///
/// Only a field on a trail has one. A daily is generated, has no question to hint at, and
/// is a day's go against the clock besides; the practice pen is a lesson and says everything
/// it has to say already.
extension PuzzleLevel {
    /// How many times the gate has to be opened on a board before its hint is unlocked.
    static let goesBeforeAHint = 2

    /// Whether the bulb is lit after `goes` openings of the gate on this visit.
    static func hintIsUnlocked(afterGoes goes: Int) -> Bool {
        goes >= goesBeforeAHint
    }

    /// What a tap on the locked bulb says: how many more goes the hint wants, or nothing
    /// once it is unlocked. It says the number in words, since a digit on the board reads
    /// as a score.
    static func hintLockNote(afterGoes goes: Int) -> String? {
        let left = goesBeforeAHint - goes
        guard left > 0 else { return nil }
        if left == 1 {
            return "One more go first. Open the gate again, and the hint is yours."
        }
        let spelled = ["no", "one", "two", "three", "four", "five"]
        let count = left < spelled.count ? spelled[left] : String(left)
        return "Have \(count) goes at it first. Open the gate \(count) times, and the hint is yours."
    }

    /// *A* or *an*, for whatever a world calls its treats: an apple, a mushroom, an ice slick.
    /// Capitalised when it opens the sentence.
    private static func article(for noun: String, opening: Bool = false) -> String {
        let vowel = noun.lowercased().first.map { "aeiou".contains($0) } ?? false
        switch (vowel, opening) {
        case (true, true): return "An"
        case (true, false): return "an"
        case (false, true): return "A"
        case (false, false): return "a"
        }
    }

    /// The idea this field turns on, in two sentences that give no tile away — or nothing
    /// for a field with no question, which is every daily and the practice pen.
    ///
    /// - Parameter treats: How this world names its windfall and its hazard, so the hint
    ///   says mushroom in the woods and apple in the meadow.
    func hint(naming treats: TreatSkin) -> String? {
        guard let question else { return nil }
        let windfall = treats.name(for: .apple)
        let hazard = treats.name(for: .skull)
        let others = animals.map(\.kind).filter { $0 != .pig }
        let boss = others.first?.name ?? "other animal"

        switch question {
        case .shore:
            return "Water is a wall you already own. Find the stretch of bank that does the "
                + "most walling for free, and spend the pieces closing what it leaves open."
        case .basin:
            return "The water has nearly done the job on its own. Find the mouth it leaves "
                + "open and plug it — then ask what the pieces left over can reach."
        case .span:
            return "Neither stretch of water is any use on its own. A pen thrown across the "
                + "neck between them leans on both at once."
        case .gap:
            return "One dry tile is the only way through the water. Shut it and the whole far "
                + "bank becomes a wall that costs nothing — and where exactly that one piece "
                + "stands is worth a second look."
        case .corner:
            return "Two sides are water, so only two are yours to build. A wall that cuts the "
                + "corner off on the diagonal holds far more than one that meets it square."
        case .constellation:
            return "Every patch of water is a tile of wall that costs nothing. Look at how they "
                + "are scattered and ask what shape they are tracing — a pen that follows it "
                + "needs pieces only for the gaps."
        case .detour:
            return "\(Self.article(for: windfall, opening: true)) \(windfall) is worth five "
                + "tiles of ground. A pen that narrows to bring one inside usually gains more "
                + "than the ground it gives up getting there."
        case .obstruction:
            return "No piece will lie on \(Self.article(for: hazard)) \(hazard). A wall that "
                + "meets one either swallows it and pays five, or steps in beside it and gives "
                + "up that tile — and out at the edge of a pen, the step costs almost nothing."
        case .bare:
            return "Nothing here is free, so every piece has to earn its ground. A box wastes "
                + "its corners: cut them off on the diagonal and the same pieces hold more."
        case .herd:
            return "Water between the two of them is one wall doing two jobs. Two pens leaning "
                + "on it from either side cost less than one dragged round the pair — after "
                + "that, the whole question is how to split the pieces between Pig and the "
                + "\(boss)."
        case .apart:
            return "The \(boss) will not share, and the water touches neither him nor Pig. "
                + "Two pens leaning on the same water from opposite sides each spend fewer "
                + "pieces than one out in the open."
        case .exclude:
            return "Every piece is Pig's, and the \(boss) is a hole the wall has to go round. "
                + "Ask how much ground can be taken before the wall has to bend past him."
        case .together:
            return "One pen round Pig and the \(boss) both, so the only question is its shape. "
                + "A pen that runs out along the line between them, corners cut, holds more "
                + "than the box that squares them off."
        case .even:
            return "Look for the line the water draws between the two halves, and what is "
                + "missing from it. Once Pig and the \(boss) are in two pens, the question is "
                + "which ground to hand back so they come out level."
        case .roost:
            // The roost is named for the one hanging at the top of it, the way the orders
            // name it, so the hint and the rule sound like the same voice.
            let mother: Animal = others.contains(.bat) ? .bat : (others.first ?? .bat)
            return "The roost hangs either side of the water. One wall reaching round the "
                + "water's end can join the \(mother.name)s on one side and pen Pig on the "
                + "other — one wall doing both jobs."
        case .ring:
            return "Four pieces round Pig hold her and win nothing. Her ground has to go the "
                + "whole way round the \(boss), so think of the wall as a ring with him in the "
                + "middle — and a ring with its corners cut holds more than a box."
        case .berth:
            return "The two pens may not share a wall, so the strip of ground between them is "
                + "nobody's. Give the \(boss) the cheapest pen the water allows, and swing "
                + "Pig's wide of it rather than up against it."
        case .moat:
            return "The \(boss)'s pool is nearly closed already, and one piece finishes it. "
                + "The rest is a ring of Pig's ground round the whole pool — and a ring that "
                + "runs out to points reaches more than a square one."
        case .hole:
            return "A tidy yard for the \(boss) where he lies is dry, and dry is no good. Give "
                + "him a small yard where the ground meets the water, and spend the rest on "
                + "Pig along the longest free wall the board has."
        case .wallow:
            return "Half a channel is nobody's. Ring the \(boss)'s whole channel rather than "
                + "the tile he lies on, and swing the ring wide — it takes more ground than "
                + "one drawn tight, and Pig needs only a corner of her own."
        case .stoop:
            return "Only a fence blocks the \(boss)'s gaze. A single piece standing on its own "
                + "in his line of sight is no wall of any pen, but it puts out an eye — and "
                + "every ray put out is ground Pig may have."
        }
    }
}
