import SwiftUI

/// The look of a world: everything that changes from one themed world to the next while the
/// game underneath stays exactly the same.
///
/// A world is the meadow's game played on new ground — fence in the pig, the biggest pen you
/// can, so long as it is shut. What a theme changes is only ever the dressing: the light the
/// trail and the board are drawn in, what grows around them, what the +5 windfall and the −5
/// hazard look like lying on the mud, and the shape that waits at the end of it. An apple in
/// the meadow is a truffle in the woods and worth the same five tiles; a skull is a bramble
/// and costs the same five. The board does not know the difference, which is why one board
/// and one solver serve every world there is.
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

    /// Emberpeak, the third world: the trees give out and the pig climbs a mountain that has
    /// never stopped smoking. The windfall is a chestnut roasting where it fell and the
    /// hazard an ember burning in the ash — each worth exactly what its meadow twin was, so
    /// the board underneath is the board it always was.
    static let emberpeak = WorldTheme(
        id: "emberpeak",
        name: "Emberpeak",
        blurb: "A mountain that never stops smoking. Chestnuts in the ash, embers under it.",
        day: .emberDay,
        dusk: .emberDusk,
        treats: TreatSkin(
            bonusGlyph: "🌰", bonusScale: 0.56, bonusName: "chestnut",
            hazardGlyph: "🔥", hazardScale: 0.62, hazardName: "ember"
        ),
        boss: BossMark(glyph: "🐉", name: "the wyrm"),
        accent: Color(red: 0.92, green: 0.47, blue: 0.26),
        accentDeep: Color(red: 0.55, green: 0.18, blue: 0.12)
    )

    /// Cogsworth City, the fourth world: down off the mountain and in under the gate, where
    /// the ground is paved and the water is a canal somebody dug. The windfall is a pie
    /// dropped outside a shop and the hazard a drain sunk in the road — each worth exactly
    /// what its meadow twin was, so the board underneath is the board it always was.
    ///
    /// Its colours on the universe map are the ones its silhouette wore for three worlds, so
    /// the planet a player has been walking towards is the planet they arrive at.
    static let cogsworth = WorldTheme(
        id: "cogsworth-city",
        name: "Cogsworth City",
        blurb: "Alleys, rooftops and a pig on the loose. Pies on the pavement, drains under it.",
        day: .cityDay,
        dusk: .cityDusk,
        treats: TreatSkin(
            bonusGlyph: "🥧", bonusScale: 0.58, bonusName: "pie",
            hazardGlyph: "🕳️", hazardScale: 0.60, hazardName: "drain"
        ),
        boss: BossMark(glyph: "🐀", name: "the rat king"),
        accent: Color(red: 0.62, green: 0.66, blue: 0.73),
        accentDeep: Color(red: 0.31, green: 0.35, blue: 0.42)
    )

    /// Starfall Reaches, the fifth world: up off the rooftops onto ground the sky keeps
    /// falling on. The windfall is a stardrop still cooling where it landed and the hazard a
    /// meteor sunk into the dust — each worth exactly what its meadow twin was, a stardrop
    /// five tiles to shut in, a meteor five to shut in with and no fencing at all, since
    /// nothing will drive a post through a stone that came in from that far out.
    ///
    /// Its colours on the universe map are the ones its silhouette wore for four worlds, so
    /// the planet a player has been walking towards is the planet they arrive at.
    static let starfall = WorldTheme(
        id: "starfall-reaches",
        name: "Starfall Reaches",
        blurb: "Fence a pig loose among the stars. Stardrops in the dust, meteors under it.",
        day: .starDay,
        dusk: .starDusk,
        treats: TreatSkin(
            bonusGlyph: "🌟", bonusScale: 0.58, bonusName: "stardrop",
            hazardGlyph: "☄️", hazardScale: 0.62, hazardName: "meteor"
        ),
        boss: BossMark(glyph: "🛸", name: "the visitor"),
        accent: Color(red: 0.61, green: 0.53, blue: 0.89),
        accentDeep: Color(red: 0.29, green: 0.23, blue: 0.52)
    )

    /// Gloamdeep Caverns, the sixth world: down off the dust and in under it, where the ground is
    /// wet flowstone and the water is one river running through the dark. The windfall is a
    /// crystal, which is the only light there is down here, and the hazard a boulder come off the
    /// roof — each worth exactly what its meadow twin was, a crystal five tiles to shut in, a
    /// boulder five to shut in with and no fencing at all, since nothing drives a post through a
    /// fallen stone.
    ///
    /// Its colours on the universe map are the ones its silhouette wore for five worlds, so the
    /// planet a player has been walking towards is the planet they arrive at.
    static let gloamdeep = WorldTheme(
        id: "gloamdeep-caverns",
        name: "Gloamdeep Caverns",
        blurb: "Deep dark, and something with wings. Crystals in the flowstone, boulders on it.",
        day: .gloamDay,
        dusk: .gloamDusk,
        treats: TreatSkin(
            bonusGlyph: "💎", bonusScale: 0.56, bonusName: "crystal",
            hazardGlyph: "🪨", hazardScale: 0.60, hazardName: "boulder"
        ),
        boss: BossMark(glyph: "🦇", name: "the roost"),
        accent: Color(red: 0.53, green: 0.47, blue: 0.63),
        accentDeep: Color(red: 0.24, green: 0.20, blue: 0.34)
    )
}
