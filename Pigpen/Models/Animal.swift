/// Something that has to be shut in.
///
/// The pig is on every map. The deer turns up on the meadow's last one, the boar on
/// the thicket's, the wyrm on the mountain's, the rat king on the city's and the visitor on
/// the last field of the reaches, where the same budget has to hold two animals instead of
/// one — together in a single pen, apart in two, or in two pens holding the same ground,
/// depending on what that world asks — but both of them, or the level is lost.
///
/// The caverns' last field is the first to stand three animals on one board: a bat, its pup and
/// the pig. The two bats are one roost and the board asks for them in one pen, so they are drawn
/// alike on purpose — what a player has to read off the floor is *there hang two bats*, and the
/// game only needs them told apart to say which of them is the one hanging on its own.
///
/// The carnival's is the first one that is not an animal at all. The ringmaster stands in the
/// middle of his ring and will not be moved off it, so as far as the board is concerned he is one
/// more thing to be shut in — which is the joke, and also the rule.
///
/// The dunes stand a scorpion on the sand, and he is the first one it matters how *near* to. Every
/// other animal in the game is either in the pig's pen or out of it; a scorpion stings through a
/// fence, so a wall with the pig on one side of it and him on the other is no wall at all.
///
/// The cove's crab is the first one the *board* works differently for. Every animal above him is
/// stopped by two things, fencing and water; he is stopped by one. Nine worlds have handed the pig
/// water for nothing and called it a wall, and the last field of the ninth stands something on the
/// sand that walks straight over it.
enum Animal: Character, CaseIterable, Sendable {
    case pig = "P"
    case deer = "D"
    case boar = "B"
    case wyrm = "W"
    case rat = "R"
    case visitor = "V"
    case bat = "T"
    case pup = "U"
    case ringmaster = "M"
    case scorpion = "S"
    case crab = "C"

    /// What the field draws it as.
    var glyph: String {
        switch self {
        case .pig: "🐷"
        case .deer: "🦌"
        case .boar: "🐗"
        case .wyrm: "🐉"
        case .rat: "🐀"
        case .visitor: "🛸"
        case .bat, .pup: "🦇"
        case .ringmaster: "🤹"
        case .scorpion: "🦂"
        case .crab: "🦀"
        }
    }

    /// Whether water is ground to this animal rather than a wall.
    ///
    /// True of the crab and nothing else. It is the ninth world's whole rule, and it lives here
    /// rather than on the question because it is a fact about the animal: a crab would swim on any
    /// board in the game, and the only reason no board above the cove has to think about it is
    /// that no board above the cove has a crab standing on it.
    var swims: Bool {
        switch self {
        case .crab: true
        case .pig, .deer, .boar, .wyrm, .rat, .visitor, .bat, .pup, .ringmaster, .scorpion: false
        }
    }

    /// What the game calls it out loud.
    var name: String {
        switch self {
        case .pig: "pig"
        case .deer: "deer"
        case .boar: "boar"
        case .wyrm: "wyrm"
        case .rat: "rat king"
        case .visitor: "visitor"
        case .bat: "bat"
        case .pup: "pup"
        case .ringmaster: "ringmaster"
        case .scorpion: "scorpion"
        case .crab: "crab"
        }
    }
}

/// One animal standing on a map: what it is, and the tile it starts on.
struct AnimalStart: Hashable, Sendable {
    let kind: Animal
    let tile: GridPoint
}
