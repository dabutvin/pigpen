/// Something that has to be shut in.
///
/// The pig is on every map. The deer turns up on the meadow's last one, the boar on
/// the thicket's and the wyrm on the mountain's, where the same budget has to hold two
/// animals instead of one — together in a single pen or apart in two, but both of them,
/// or the level is lost.
enum Animal: Character, CaseIterable, Sendable {
    case pig = "P"
    case deer = "D"
    case boar = "B"
    case wyrm = "W"

    /// What the field draws it as.
    var glyph: String {
        switch self {
        case .pig: "🐷"
        case .deer: "🦌"
        case .boar: "🐗"
        case .wyrm: "🐉"
        }
    }

    /// What the game calls it out loud.
    var name: String {
        switch self {
        case .pig: "pig"
        case .deer: "deer"
        case .boar: "boar"
        case .wyrm: "wyrm"
        }
    }
}

/// One animal standing on a map: what it is, and the tile it starts on.
struct AnimalStart: Hashable, Sendable {
    let kind: Animal
    let tile: GridPoint
}
