import SwiftUI

/// The look of a world: everything that changes from one themed world to the next while the
/// game underneath stays exactly the same.
///
/// A world is the meadow's game played on new ground — fence in the pig, the biggest pen you
/// can, so long as it is shut. What a theme changes is only ever the dressing: the light the
/// trail is drawn in, what the +5 windfall and the −5 hazard look like lying on the mud, and
/// the shape that waits at the end of it. An apple in the meadow is a truffle in the woods and
/// worth the same five tiles; a skull is a bramble and costs the same five. The board does not
/// know the difference, which is why one board and one solver serve every world there is.
struct WorldTheme: Sendable {
    let id: String
    /// What the world is called, on the universe map and across the top of its own trail.
    let name: String
    /// A line for the universe map, so a world says what it is before it is ever opened.
    let blurb: String
    /// The trail's daylight and nightfall, following the player's own screen the way the
    /// meadow always has.
    let day: GamePalette.Pasture
    let dusk: GamePalette.Pasture
    /// How the windfall bonus and the staked hazard are dressed on this world's ground.
    let treats: TreatSkin
    /// The thing at the end of the world, as its silhouette shows on the universe map.
    let boss: BossMark
    /// The world's own colour on the universe map: the planet it is drawn as, lit and shaded.
    let accent: Color
    let accentDeep: Color

    /// The palette for a world map drawn under a given appearance.
    func pasture(dark: Bool) -> GamePalette.Pasture { dark ? dusk : day }
}

/// How a world dresses the two things that can lie on its ground: the windfall worth five
/// tiles to shut in, and the hazard that costs five and takes no fencing. The mechanic is the
/// meadow's apple and skull whatever the skin; only the glyph and the word for it change, so a
/// truffle scores like an apple and reads like a truffle.
struct TreatSkin: Sendable {
    /// The +5 windfall: an apple in the meadow, a truffle in the woods.
    let bonusGlyph: String
    let bonusScale: CGFloat
    let bonusName: String
    /// The −5 hazard, staked in the ground and never fenced: a skull, or a bramble.
    let hazardGlyph: String
    let hazardScale: CGFloat
    let hazardName: String

    /// The emoji a treat is drawn as on this world's ground.
    func glyph(for treat: Treat) -> String {
        switch treat {
        case .apple: bonusGlyph
        case .skull: hazardGlyph
        }
    }

    /// How large that emoji is set, as a fraction of a tile: glyphs fill their box
    /// differently, so each is sized to carry the same weight.
    func scale(for treat: Treat) -> CGFloat {
        switch treat {
        case .apple: bonusScale
        case .skull: hazardScale
        }
    }

    /// What the world calls a treat out loud, for a verdict and for a screen read aloud.
    func name(for treat: Treat) -> String {
        switch treat {
        case .apple: bonusName
        case .skull: hazardName
        }
    }
}

/// The boss of a world as it shows on the universe map: a glyph drawn in silhouette on a
/// world still shut, and a name for anybody listening to the screen rather than watching it.
struct BossMark: Sendable {
    let glyph: String
    let name: String
}

extension WorldTheme {
    /// Mudlark Meadow, exactly as the game has always drawn it: apples and skulls on open
    /// pasture, with a stag standing on the far shore of the last field.
    static let meadow = WorldTheme(
        id: "mudlark-meadow",
        name: "Mudlark Meadow",
        blurb: "Where it all began. A pig, an open gate, and nine fields of nothing to stop it.",
        day: .day,
        dusk: .dusk,
        treats: TreatSkin(
            bonusGlyph: "🍎", bonusScale: 0.58, bonusName: "apple",
            hazardGlyph: "☠️", hazardScale: 0.68, hazardName: "skull"
        ),
        boss: BossMark(glyph: "🦌", name: "the stag"),
        accent: Color(red: 0.58, green: 0.78, blue: 0.45),
        accentDeep: Color(red: 0.36, green: 0.58, blue: 0.30)
    )

    /// Thornwood Thicket, the second world: the same pig loose in deep woods, where the
    /// windfall is a truffle and the hazard a bramble, and neither turns up where the last
    /// world would have put it.
    static let thornwood = WorldTheme(
        id: "thornwood-thicket",
        name: "Thornwood Thicket",
        blurb: "The pig took the tree line. Truffles in the leaf mould, brambles in the dark.",
        day: .forestDay,
        dusk: .forestDusk,
        treats: TreatSkin(
            bonusGlyph: "🍄", bonusScale: 0.56, bonusName: "truffle",
            hazardGlyph: "🥀", hazardScale: 0.60, hazardName: "bramble"
        ),
        boss: BossMark(glyph: "🐗", name: "the boar"),
        accent: Color(red: 0.40, green: 0.62, blue: 0.36),
        accentDeep: Color(red: 0.20, green: 0.38, blue: 0.22)
    )
}
