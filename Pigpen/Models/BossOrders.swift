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
            return "Fence in both Pig and the \(boss.name). One pen or two. Whatever makes "
                + "the floor plan work."
        case .apart:
            return "Fence in Pig and the \(boss.name) separately."
        case .exclude:
            return "Fence in Pig. Keep the \(boss.name) out. Very, very out."
        case .together:
            return "Fence Pig and the \(boss.name) in together. Sometimes real estate is "
                + "about compromise."
        case .even:
            return "Build Pig and the \(boss.name) two separate pens. They must be exactly "
                + "the same size. Equal square footage. No exceptions."
        case .roost:
            // The flock is named for the one hanging at the top of it — the same animal the
            // rule itself is anchored on — rather than for whichever of them the map happens
            // to write down first, so moving the pup up a row does not rename the roost.
            let mother: Animal = otherAnimals.contains(.bat) ? .bat : boss
            return "Pig gets his own pen. Both \(mother.name)s share the other. Pig was "
                + "absolutely not accepting roommates."
        case .ring:
            return "Fence in Pig, the \(boss.name), and his ring. But don't let your fence "
                + "touch the ring. Apparently it's in the lease."
        case .berth:
            return "Build Pig and the \(boss.name) separate pens. And don't let them share a "
                + "fence. Adjoining properties were not approved."
        case .moat:
            return "Give the \(boss.name) its own pen. Then build Pig's around it. No shared "
                + "fences."
        case .hole:
            return "Build Pig and the \(boss.name) separate pens. The \(boss.name)'s pen "
                + "must border the water."
        case .wallow:
            return "Build Pig and the \(boss.name) separate pens. Fence the \(boss.name) in "
                + "with one entire waterway."
        case .stoop:
            return "Fence in Pig. Keep every tile of his pen out of the \(boss.name)'s line "
                + "of sight. The homeowners association is watching."
        case .shore, .basin, .span, .gap, .corner, .constellation, .detour, .obstruction, .bare:
            // The game's own question, asked on new ground. There is nothing to say about it
            // that the ground does not say itself.
            return nil
        }
    }
}
