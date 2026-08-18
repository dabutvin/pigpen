/// What a boss field asks, in the one line a player needs while they are building it.
///
/// Every world's last field adds a rule the other eight do not use, and each world's briefing
/// says it once before the board opens. A film is a fine way to be told a thing and a poor way
/// to be reminded of it: a player who watched the caverns' briefing three days ago, or who
/// tapped past it, or who came back to better a two-star pen, is left building against a rule
/// nothing on the board is saying any more. So the rule stays on the screen, under the field,
/// for as long as the field is up.
///
/// The wording follows the briefing's own card — the shot that states the terms — so being told
/// and being reminded sound like the same voice. What it must never do is give the pen away:
/// it says what the board will accept, not where the fencing goes.
extension PuzzleLevel {
    /// Every animal on this board but the pig, in the order the map writes them down. The pig
    /// is on every map in the game, so it is never what makes a field a boss.
    private var otherAnimals: [Animal] {
        animals.map(\.kind).filter { $0 != .pig }
    }

    /// The animal a boss is named for — the deer of Stag Mere, the scorpion of Scorpion Flats.
    private var bossAnimal: Animal? { otherAnimals.first }

    /// The glyphs the orders are signed with: whatever a field stands on its ground besides the
    /// pig, each one drawn once, so the caverns' roost reads as one bat rather than two.
    var bossGlyphs: String {
        var seen: Set<String> = []
        return otherAnimals.map(\.glyph).filter { seen.insert($0).inserted }.joined()
    }

    /// The rule this field adds to the game, or nothing for a field that only asks the game's
    /// own question — which is every field but a boss, and every daily.
    var orders: String? {
        guard let question, let boss = bossAnimal else { return nil }

        switch question {
        case .herd:
            return "Hold the pig and the \(boss.name), both. One pen round the pair or a pen "
                + "apiece — whichever holds more."
        case .apart:
            return "Hold the pig and the \(boss.name), both — in two pens, never one. The "
                + "\(boss.name) shares its ground with nobody."
        case .exclude:
            return "Hold the pig and leave the \(boss.name) outside. Only the pig's ground counts."
        case .together:
            return "Hold the pig and the \(boss.name), both, in one pen — never two. The "
                + "\(boss.name) goes where the pig goes."
        case .even:
            return "Hold the pig and the \(boss.name), both, in two pens — and neither pen "
                + "bigger. The \(boss.name) wants ground to match."
        case .roost:
            // The flock is named for the one hanging at the top of it — the same animal the
            // rule itself is anchored on — rather than for whichever of them the map happens
            // to write down first, so moving the pup up a row does not rename the roost.
            let mother: Animal = otherAnimals.contains(.bat) ? .bat : boss
            return "Both \(mother.name)s in one pen, the pig in another. A pup hangs where its "
                + "mother does, and never beside a pig."
        case .ring:
            return "The \(boss.name) keeps the middle and will not be moved. Close the pig's "
                + "ground the whole way round — a pen alongside is no ring."
        case .berth:
            return "Hold the pig and the \(boss.name), both, and leave clear ground between "
                + "them: a sting goes straight through a fence, so no wall may do for two."
        case .moat:
            return "The \(boss.name) keeps his pool and will not leave it. Close the pig's "
                + "ground the whole way round the pool — break, \(boss.name) and all."
        case .hole:
            return "Hold the pig and the \(boss.name), both, in two pens — never one — and pen "
                + "the \(boss.name) against the water: he keeps a breathing hole."
        case .wallow:
            return "Hold the pig and the \(boss.name), both, in two pens — never one — and give "
                + "the \(boss.name) one whole channel: every bank of it is his."
        case .stoop:
            return "Hold the pig out of the \(boss.name)'s eye. He sees along his row and his "
                + "column, and only a fence breaks his line of sight."
        case .shore, .basin, .span, .gap, .corner, .constellation, .detour, .obstruction, .bare:
            // The game's own question, asked on new ground. There is nothing to say about it
            // that the ground does not say itself.
            return nil
        }
    }
}
