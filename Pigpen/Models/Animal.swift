import Foundation

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
/// The cove stands a crab in the heart of a broken ring of tidewater, and he is the first one
/// whose home matters as much as he does: the pool walls him in on every side but its break,
/// and what the board asks is that the pig's own ground close the whole way round the pool.
///
/// The tundra stands a bull seal on the ice, and he is the first one particular about the pen
/// he is given rather than only about who shares it: two pens, the pig's and his, and his has
/// to lie against the water — a seal penned on dry ice has no breathing hole, and the board
/// will not have it.
///
/// The fen stands an old croc in the reeds, and he is greedier than the seal by a whole
/// channel: his pen has to hold every bank of one body of water — a croc keeps a wallow
/// rather than visits one, and half a wallow is nobody's.
///
/// The spire perches an eagle above everything, and he is the first one that matters at a
/// distance. Like the wyrm he is never fenced and never held — his perch is a hole in the
/// wall's way — but the wyrm only sat where the wall wanted to go. The eagle sees: four ways
/// from his perch, straight along his row and his column, over mud and open sky alike, and
/// no tile of the pig's pen may stand anywhere his eye reaches. Only a fence breaks his line
/// of sight, which makes a fence two tools in one world — a wall, and an eyelid pulled down
/// over somebody else's eye.
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
    case seal = "L"
    case croc = "G"
    case eagle = "E"

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
        case .seal: "🦭"
        case .croc: "🐊"
        case .eagle: "🦅"
        }
    }

    /// What it says back when a finger lands on it.
    ///
    /// Nothing on the board takes a fence where an animal is standing, so a tap on one used to
    /// be turned down the way a spent budget is — a shake of the rack and nothing learned. An
    /// animal is the one thing on the field that can answer for itself, so it does: a noise, a
    /// hop, and the tile it was standing on all along.
    var call: String {
        switch self {
        case .pig: String(localized: "animal.pig.call", defaultValue: "Oink!")
        case .deer: String(localized: "animal.deer.call", defaultValue: "Snort!")
        case .boar: String(localized: "animal.boar.call", defaultValue: "Grunt!")
        case .wyrm: String(localized: "animal.wyrm.call", defaultValue: "Rumble!")
        case .rat: String(localized: "animal.rat.call", defaultValue: "Squeak!")
        case .visitor: String(localized: "animal.visitor.call", defaultValue: "Bleep!")
        case .bat: String(localized: "animal.bat.call", defaultValue: "Screech!")
        case .pup: String(localized: "animal.pup.call", defaultValue: "Peep!")
        case .ringmaster: String(localized: "animal.ringmaster.call", defaultValue: "Ta-da!")
        case .scorpion: String(localized: "animal.scorpion.call", defaultValue: "Tik-tik!")
        case .crab: String(localized: "animal.crab.call", defaultValue: "Click!")
        case .seal: String(localized: "animal.seal.call", defaultValue: "Arf!")
        case .croc: String(localized: "animal.croc.call", defaultValue: "Snap!")
        case .eagle: String(localized: "animal.eagle.call", defaultValue: "Kree!")
        }
    }

    /// What the game calls it out loud: the bare noun, lower case, for a sentence that
    /// supplies its own article — "Release the %@", "No water for the %@".
    var name: String {
        switch self {
        case .pig: String(localized: "animal.pig.name", defaultValue: "pig")
        case .deer: String(localized: "animal.deer.name", defaultValue: "deer")
        case .boar: String(localized: "animal.boar.name", defaultValue: "boar")
        case .wyrm: String(localized: "animal.wyrm.name", defaultValue: "wyrm")
        case .rat: String(localized: "animal.rat.name", defaultValue: "rat king")
        case .visitor: String(localized: "animal.visitor.name", defaultValue: "visitor")
        case .bat: String(localized: "animal.bat.name", defaultValue: "bat")
        case .pup: String(localized: "animal.pup.name", defaultValue: "pup")
        case .ringmaster: String(localized: "animal.ringmaster.name", defaultValue: "ringmaster")
        case .scorpion: String(localized: "animal.scorpion.name", defaultValue: "scorpion")
        case .crab: String(localized: "animal.crab.name", defaultValue: "crab")
        case .seal: String(localized: "animal.seal.name", defaultValue: "bull seal")
        case .croc: String(localized: "animal.croc.name", defaultValue: "old croc")
        case .eagle: String(localized: "animal.eagle.name", defaultValue: "eagle")
        }
    }

    /// The same animal with its article on the front, for the head of a sentence about it —
    /// "The deer wants its own place". English only has to choose "the"; a language with
    /// genders has to choose between two or three articles, and it cannot do that from a
    /// template that is shared by fourteen animals. So the article travels with the noun.
    var subject: String {
        switch self {
        case .pig: String(localized: "animal.pig.subject", defaultValue: "the pig")
        case .deer: String(localized: "animal.deer.subject", defaultValue: "the deer")
        case .boar: String(localized: "animal.boar.subject", defaultValue: "the boar")
        case .wyrm: String(localized: "animal.wyrm.subject", defaultValue: "the wyrm")
        case .rat: String(localized: "animal.rat.subject", defaultValue: "the rat king")
        case .visitor: String(localized: "animal.visitor.subject", defaultValue: "the visitor")
        case .bat: String(localized: "animal.bat.subject", defaultValue: "the bat")
        case .pup: String(localized: "animal.pup.subject", defaultValue: "the pup")
        case .ringmaster: String(localized: "animal.ringmaster.subject", defaultValue: "the ringmaster")
        case .scorpion: String(localized: "animal.scorpion.subject", defaultValue: "the scorpion")
        case .crab: String(localized: "animal.crab.subject", defaultValue: "the crab")
        case .seal: String(localized: "animal.seal.subject", defaultValue: "the bull seal")
        case .croc: String(localized: "animal.croc.subject", defaultValue: "the old croc")
        case .eagle: String(localized: "animal.eagle.subject", defaultValue: "the eagle")
        }
    }

    /// `subject` with a capital on the front, for the head of a sentence — "The deer walked
    /// out". Every language the game speaks starts a sentence with one, so this is a turn of
    /// the crank rather than another fourteen lines for a translator to keep.
    var subjectCapitalized: String {
        let phrase = subject
        return phrase.prefix(1).uppercased() + phrase.dropFirst()
    }

    /// And again for the middle of a sentence, where something is being done to it — "Fence in
    /// Pig and the deer separately". English cannot tell this apart from `subject`; German can,
    /// and says "der Hirsch" in one and "den Hirsch" in the other.
    var object: String {
        switch self {
        case .pig: String(localized: "animal.pig.object", defaultValue: "the pig")
        case .deer: String(localized: "animal.deer.object", defaultValue: "the deer")
        case .boar: String(localized: "animal.boar.object", defaultValue: "the boar")
        case .wyrm: String(localized: "animal.wyrm.object", defaultValue: "the wyrm")
        case .rat: String(localized: "animal.rat.object", defaultValue: "the rat king")
        case .visitor: String(localized: "animal.visitor.object", defaultValue: "the visitor")
        case .bat: String(localized: "animal.bat.object", defaultValue: "the bat")
        case .pup: String(localized: "animal.pup.object", defaultValue: "the pup")
        case .ringmaster: String(localized: "animal.ringmaster.object", defaultValue: "the ringmaster")
        case .scorpion: String(localized: "animal.scorpion.object", defaultValue: "the scorpion")
        case .crab: String(localized: "animal.crab.object", defaultValue: "the crab")
        case .seal: String(localized: "animal.seal.object", defaultValue: "the bull seal")
        case .croc: String(localized: "animal.croc.object", defaultValue: "the old croc")
        case .eagle: String(localized: "animal.eagle.object", defaultValue: "the eagle")
        }
    }

    /// More than one of it, for the one rule that fences a flock — "Both bats share the other".
    var plural: String {
        switch self {
        case .pig: String(localized: "animal.pig.plural", defaultValue: "pigs")
        case .deer: String(localized: "animal.deer.plural", defaultValue: "deer")
        case .boar: String(localized: "animal.boar.plural", defaultValue: "boars")
        case .wyrm: String(localized: "animal.wyrm.plural", defaultValue: "wyrms")
        case .rat: String(localized: "animal.rat.plural", defaultValue: "rat kings")
        case .visitor: String(localized: "animal.visitor.plural", defaultValue: "visitors")
        case .bat: String(localized: "animal.bat.plural", defaultValue: "bats")
        case .pup: String(localized: "animal.pup.plural", defaultValue: "pups")
        case .ringmaster: String(localized: "animal.ringmaster.plural", defaultValue: "ringmasters")
        case .scorpion: String(localized: "animal.scorpion.plural", defaultValue: "scorpions")
        case .crab: String(localized: "animal.crab.plural", defaultValue: "crabs")
        case .seal: String(localized: "animal.seal.plural", defaultValue: "bull seals")
        case .croc: String(localized: "animal.croc.plural", defaultValue: "old crocs")
        case .eagle: String(localized: "animal.eagle.plural", defaultValue: "eagles")
        }
    }
}

/// One animal standing on a map: what it is, and the tile it starts on.
struct AnimalStart: Hashable, Sendable {
    let kind: Animal
    let tile: GridPoint
}
