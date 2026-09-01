import SwiftUI

/// The colours of the game, mixed the way a storybook watercolour is: the ground pale and
/// papery, the water a soft wash of blue, so the fencing and the finished pen can be the
/// two things that catch the eye.
///
/// The board in the middle of the screen no longer draws itself out of these: a world hands
/// it a `FieldSkin` and the ground, the water and the fencing come out of that, so the
/// mountain's field is ash and the city's is paving. What is left here is the meadow's own
/// version of those colours — which the films, the world map and the title screen are all
/// still painted in, since every one of them is somewhere in Mudlark Meadow — along with the
/// colours that belong to no world at all: the pen's gold, the cream of a painted board, barn
/// red for bad news and clover for good.
enum GamePalette {
    static let mud = Color(red: 0.93, green: 0.88, blue: 0.77)
    /// The same ground with the light full on it and with the light off it, so the field can
    /// be lit from above the way every other drawn thing in the game is.
    static let mudLit = Color(red: 0.96, green: 0.92, blue: 0.83)
    static let mudShade = Color(red: 0.86, green: 0.80, blue: 0.68)
    static let mudSpeckle = Color(red: 0.72, green: 0.63, blue: 0.50)
    static let water = Color(red: 0.62, green: 0.80, blue: 0.92)
    /// Out in the middle of a lake, where the bottom of it is further down.
    static let waterDeep = Color(red: 0.50, green: 0.71, blue: 0.88)
    static let waterRipple = Color(red: 0.97, green: 0.99, blue: 1.00)
    /// Wet silt along a bank, where the water gives out and the mud starts.
    static let shore = Color(red: 0.91, green: 0.88, blue: 0.80)
    static let pen = Color(red: 0.98, green: 0.78, blue: 0.33)
    /// The wash for a pen with nothing left to beat: the whole colour wheel laid across it,
    /// starting `phase` turns round from red. Turning the phase over time is what makes the
    /// rainbow drift, and the last stop is the same hue as the first, so it never seams.
    static func rainbow(phase: Double) -> Gradient {
        Gradient(colors: (0...6).map { stop in
            Color(
                hue: (phase + Double(stop) / 6).truncatingRemainder(dividingBy: 1),
                saturation: 0.78,
                brightness: 0.96
            )
        })
    }
    static let post = Color(red: 0.27, green: 0.17, blue: 0.10)
    static let rail = Color(red: 0.62, green: 0.42, blue: 0.24)
    /// Pale, freshly cut timber, light enough to stand out against the mud.
    static let picket = Color(red: 0.78, green: 0.60, blue: 0.39)
    /// Everything past the edge of the map: open country, and a lost pig.
    static let beyond = Color(red: 0.47, green: 0.68, blue: 0.38)
    /// Painted board: lettering and signage that has to read against sky or grass alike.
    static let cream = Color(red: 0.99, green: 0.95, blue: 0.87)
    /// The barn at the bottom of the world map, and the only red in the game. It doubles as
    /// the colour of bad news on a painted board: a pig out on the loose, a budget spent.
    static let barn = Color(red: 0.70, green: 0.27, blue: 0.22)
    /// The terracotta the game's chrome is glazed in: the bar over a board, and the one
    /// button on a field that ends a go. Warmer than the barn's red, because it is paint on
    /// woodwork rather than a verdict.
    static let clay = Color(red: 0.81, green: 0.45, blue: 0.34)
    /// The same glaze with the light off it, for the underside of whatever wears it.
    static let clayShade = Color(red: 0.71, green: 0.36, blue: 0.27)
    /// Good news on a painted board: a pen that held, dark enough to read against cream.
    static let clover = Color(red: 0.17, green: 0.43, blue: 0.22)
    /// A signpost for a level that is still shut: weathered, unpainted, and dull on purpose.
    static let stone = Color(red: 0.55, green: 0.53, blue: 0.50)

    /// The pasture on the title screen. The board itself keeps one set of colours whatever
    /// the system appearance; only this backdrop moves from daylight to dusk.
    struct Pasture: Sendable {
        let skyTop: Color
        let skyHorizon: Color
        /// The sun by day, the moon at night.
        let disc: Color
        let discHalo: Color
        let cloud: Color
        let farHill: Color
        let ground: Color
        let foreground: Color
        let blade: Color
        /// The trees along the world map's trail, lit and shaded.
        let canopy: Color
        let canopyShade: Color
        /// Dusk gets stars and fireflies where daylight gets birds and pollen.
        let isNight: Bool
        /// What the ground is made of. The same trail and the same board run through every
        /// world; what changes is the dressing around them — mown bands, wildflowers and a
        /// barn on pasture, leaf litter and ferns under a canopy, ash drifts and cinder
        /// where the mountain has burnt everything off, paving and lamp posts in a city.
        let cover: Cover
    }

    /// The six kinds of ground the game draws. A world picks one and the backdrop and the
    /// world map both follow it, which is the whole of what makes a thicket read as woods,
    /// a mountain as bare rock and a city as somewhere paved rather than as a meadow tinted
    /// a different colour.
    enum Cover: Sendable {
        case pasture
        case woodland
        case scree
        case cobbles
        /// Star dust: fine grey ground with the sky in it, pitted where things have landed.
        case dust
        /// Cave floor: wet flowstone in ribs and ledges, with crystal light coming off it and
        /// stalactites hanging into the dark overhead.
        case flowstone
        /// Fairground: trodden grass under sawdust, with guy ropes pegged across it and a string
        /// of lanterns overhead throwing coloured light down onto all of it.
        case sawdust
        /// Desert: baked hardpan with wind ripples combed across it, the odd cactus standing up
        /// out of it, and nothing overhead but glare.
        case sand
        /// Seashore: wet strand the tide has only just let go of, with rock pools standing in
        /// it and wrack thrown down in lines.
        case shingle
        /// Tundra: snow over sea ice, combed into sastrugi by the wind, with pressure ridges
        /// standing up out of it and snow coming down through everything.
        case snowfield
        /// Fen: peat and standing water in equal measure, reeds in beds, dead trees silvering
        /// where the bog got their roots, and mist lying low over the lot of it.
        case marsh
        /// Heights: turf terraces on the tops of spires that stand up out of a sea of cloud,
        /// with wind-bent pines holding on where they can and nothing below the edge but air.
        case cloudtop
    }
}

extension GamePalette.Pasture {
    /// The meadow by day, washed the way a storybook paints one: a hazed sky, sage hills,
    /// and grass more grey-green than green, so the board and its fencing are the strongest
    /// colours on the screen.
    static let day = Self(
        skyTop: Color(red: 0.71, green: 0.81, blue: 0.85),
        skyHorizon: Color(red: 0.94, green: 0.93, blue: 0.86),
        disc: Color(red: 1.00, green: 0.93, blue: 0.68),
        discHalo: Color(red: 1.00, green: 0.95, blue: 0.78),
        cloud: .white,
        farHill: Color(red: 0.71, green: 0.78, blue: 0.61),
        ground: Color(red: 0.77, green: 0.81, blue: 0.64),
        foreground: Color(red: 0.67, green: 0.73, blue: 0.55),
        blade: Color(red: 0.54, green: 0.62, blue: 0.45),
        canopy: Color(red: 0.46, green: 0.59, blue: 0.44),
        canopyShade: Color(red: 0.34, green: 0.47, blue: 0.35),
        isNight: false,
        cover: .pasture
    )

    /// The meadow at sunrise, which is the only light the opening film is shot in.
    ///
    /// Every other backdrop in the game follows the system appearance, since it is the
    /// player's own screen. The film is not: it is lit by whoever pointed the camera, and
    /// the first thing it says is that the sun is coming up — so it says that at midnight
    /// too, on a phone set to dark, rather than opening on a meadow nobody can see.
    static let daybreak = Self(
        skyTop: Color(red: 0.20, green: 0.28, blue: 0.52),
        skyHorizon: Color(red: 0.98, green: 0.76, blue: 0.55),
        disc: Color(red: 1.00, green: 0.93, blue: 0.68),
        discHalo: Color(red: 1.00, green: 0.82, blue: 0.52),
        cloud: Color(red: 1.00, green: 0.85, blue: 0.72),
        farHill: Color(red: 0.42, green: 0.55, blue: 0.46),
        ground: Color(red: 0.40, green: 0.60, blue: 0.34),
        foreground: Color(red: 0.28, green: 0.45, blue: 0.26),
        blade: Color(red: 0.22, green: 0.38, blue: 0.22),
        canopy: Color(red: 0.30, green: 0.50, blue: 0.28),
        canopyShade: Color(red: 0.20, green: 0.36, blue: 0.22),
        isNight: false,
        cover: .pasture
    )

    static let dusk = Self(
        skyTop: Color(red: 0.05, green: 0.07, blue: 0.16),
        skyHorizon: Color(red: 0.36, green: 0.24, blue: 0.36),
        disc: Color(red: 0.95, green: 0.96, blue: 1.00),
        discHalo: Color(red: 0.75, green: 0.79, blue: 0.95),
        cloud: Color(red: 0.26, green: 0.26, blue: 0.38),
        farHill: Color(red: 0.14, green: 0.22, blue: 0.24),
        ground: Color(red: 0.11, green: 0.19, blue: 0.17),
        foreground: Color(red: 0.08, green: 0.14, blue: 0.13),
        blade: Color(red: 0.05, green: 0.10, blue: 0.09),
        canopy: Color(red: 0.12, green: 0.21, blue: 0.20),
        canopyShade: Color(red: 0.07, green: 0.13, blue: 0.13),
        isNight: true,
        cover: .pasture
    )

    /// The second world's daylight: a wooded thicket, darker and closer than the open
    /// meadow. The same trail runs through it, so the same scene draws it — only the light
    /// and the dressing change, deep moss and leaf litter where the meadow is bright and
    /// mown.
    static let forestDay = Self(
        skyTop: Color(red: 0.28, green: 0.42, blue: 0.38),
        skyHorizon: Color(red: 0.62, green: 0.72, blue: 0.52),
        disc: Color(red: 1.00, green: 0.93, blue: 0.60),
        discHalo: Color(red: 1.00, green: 0.95, blue: 0.70),
        cloud: Color(red: 0.82, green: 0.88, blue: 0.78),
        farHill: Color(red: 0.18, green: 0.32, blue: 0.22),
        ground: Color(red: 0.20, green: 0.34, blue: 0.20),
        foreground: Color(red: 0.14, green: 0.26, blue: 0.15),
        blade: Color(red: 0.11, green: 0.22, blue: 0.12),
        canopy: Color(red: 0.16, green: 0.34, blue: 0.18),
        canopyShade: Color(red: 0.10, green: 0.22, blue: 0.14),
        isNight: false,
        cover: .woodland
    )

    /// The thicket after dark: the canopy closes the sky right down, and what light there is
    /// pools green rather than blue.
    static let forestDusk = Self(
        skyTop: Color(red: 0.03, green: 0.07, blue: 0.08),
        skyHorizon: Color(red: 0.10, green: 0.18, blue: 0.14),
        disc: Color(red: 0.90, green: 0.94, blue: 0.90),
        discHalo: Color(red: 0.52, green: 0.66, blue: 0.56),
        cloud: Color(red: 0.12, green: 0.18, blue: 0.15),
        farHill: Color(red: 0.06, green: 0.12, blue: 0.10),
        ground: Color(red: 0.05, green: 0.11, blue: 0.09),
        foreground: Color(red: 0.03, green: 0.08, blue: 0.07),
        blade: Color(red: 0.03, green: 0.06, blue: 0.05),
        canopy: Color(red: 0.07, green: 0.15, blue: 0.12),
        canopyShade: Color(red: 0.04, green: 0.09, blue: 0.08),
        isNight: true,
        cover: .woodland
    )

    /// The third world by day: a mountain that has burnt everything off itself. The sky is
    /// hazed with what the peak is giving off rather than blue, and the ground under it is
    /// ash, cinder and the odd scorched pine — the same trail and the same board as
    /// everywhere else, on ground with nothing growing on it.
    static let emberDay = Self(
        skyTop: Color(red: 0.52, green: 0.44, blue: 0.48),
        skyHorizon: Color(red: 0.96, green: 0.72, blue: 0.47),
        disc: Color(red: 1.00, green: 0.83, blue: 0.48),
        discHalo: Color(red: 1.00, green: 0.68, blue: 0.40),
        cloud: Color(red: 0.72, green: 0.64, blue: 0.62),
        farHill: Color(red: 0.34, green: 0.24, blue: 0.24),
        ground: Color(red: 0.42, green: 0.34, blue: 0.32),
        foreground: Color(red: 0.31, green: 0.24, blue: 0.23),
        blade: Color(red: 0.24, green: 0.18, blue: 0.17),
        canopy: Color(red: 0.38, green: 0.29, blue: 0.27),
        canopyShade: Color(red: 0.26, green: 0.19, blue: 0.18),
        isNight: false,
        cover: .scree
    )

    /// The mountain after dark, which is when it shows what it is doing: the sky goes out
    /// but the ground keeps a red in it, because the light down here is coming up through
    /// the cinder rather than down out of the sky.
    static let emberDusk = Self(
        skyTop: Color(red: 0.06, green: 0.05, blue: 0.09),
        skyHorizon: Color(red: 0.32, green: 0.14, blue: 0.11),
        disc: Color(red: 0.98, green: 0.90, blue: 0.86),
        discHalo: Color(red: 0.86, green: 0.46, blue: 0.30),
        cloud: Color(red: 0.24, green: 0.16, blue: 0.16),
        farHill: Color(red: 0.16, green: 0.10, blue: 0.10),
        ground: Color(red: 0.14, green: 0.10, blue: 0.10),
        foreground: Color(red: 0.10, green: 0.07, blue: 0.07),
        blade: Color(red: 0.07, green: 0.05, blue: 0.05),
        canopy: Color(red: 0.18, green: 0.11, blue: 0.10),
        canopyShade: Color(red: 0.11, green: 0.07, blue: 0.07),
        isNight: true,
        cover: .scree
    )

    /// The fourth world by day: a city under its own smoke. Nothing here is a colour that
    /// grew — the sky is hazed the colour of what the chimneys are putting into it, the
    /// ground is paving and soot, and the green is down to whatever comes up between the
    /// stones. The same trail and the same board as everywhere else, on ground somebody laid.
    static let cityDay = Self(
        skyTop: Color(red: 0.55, green: 0.60, blue: 0.68),
        skyHorizon: Color(red: 0.87, green: 0.83, blue: 0.73),
        disc: Color(red: 0.99, green: 0.94, blue: 0.76),
        discHalo: Color(red: 0.95, green: 0.88, blue: 0.70),
        cloud: Color(red: 0.78, green: 0.77, blue: 0.75),
        farHill: Color(red: 0.38, green: 0.39, blue: 0.45),
        ground: Color(red: 0.50, green: 0.49, blue: 0.51),
        foreground: Color(red: 0.40, green: 0.39, blue: 0.42),
        blade: Color(red: 0.31, green: 0.34, blue: 0.28),
        canopy: Color(red: 0.47, green: 0.45, blue: 0.49),
        canopyShade: Color(red: 0.33, green: 0.32, blue: 0.37),
        isNight: false,
        cover: .cobbles
    )

    /// The city after dark, which is when it is worth looking at: the sky goes out entirely
    /// and everything under it takes its colour from the lamps, so the ground reads warm
    /// where the mountain's reads red and the meadow's reads blue.
    static let cityDusk = Self(
        skyTop: Color(red: 0.05, green: 0.06, blue: 0.11),
        skyHorizon: Color(red: 0.24, green: 0.18, blue: 0.15),
        disc: Color(red: 0.96, green: 0.95, blue: 0.98),
        discHalo: Color(red: 0.82, green: 0.72, blue: 0.50),
        cloud: Color(red: 0.19, green: 0.18, blue: 0.20),
        farHill: Color(red: 0.13, green: 0.13, blue: 0.17),
        ground: Color(red: 0.15, green: 0.14, blue: 0.17),
        foreground: Color(red: 0.11, green: 0.10, blue: 0.13),
        blade: Color(red: 0.08, green: 0.09, blue: 0.08),
        canopy: Color(red: 0.17, green: 0.16, blue: 0.20),
        canopyShade: Color(red: 0.11, green: 0.10, blue: 0.14),
        isNight: true,
        cover: .cobbles
    )

    /// The fifth world by day, which up here is not much of a day at all: the sky is thin
    /// enough that the violet of what is behind it comes through, the sun is small and cold,
    /// and the ground is dust with the light of the sky lying on it. The same trail and the
    /// same board as everywhere else, on ground nothing has ever grown in.
    static let starDay = Self(
        skyTop: Color(red: 0.30, green: 0.27, blue: 0.56),
        skyHorizon: Color(red: 0.86, green: 0.79, blue: 0.90),
        disc: Color(red: 1.00, green: 0.97, blue: 0.88),
        discHalo: Color(red: 0.88, green: 0.82, blue: 0.99),
        cloud: Color(red: 0.80, green: 0.78, blue: 0.91),
        farHill: Color(red: 0.35, green: 0.32, blue: 0.50),
        ground: Color(red: 0.53, green: 0.50, blue: 0.61),
        foreground: Color(red: 0.41, green: 0.38, blue: 0.50),
        blade: Color(red: 0.33, green: 0.31, blue: 0.45),
        canopy: Color(red: 0.47, green: 0.44, blue: 0.57),
        canopyShade: Color(red: 0.31, green: 0.29, blue: 0.43),
        isNight: false,
        cover: .dust
    )

    /// The reaches after dark, which is what they are for. The sky goes out altogether and
    /// what is left is the stars in it and the light coming *up* off the ground, out of every
    /// well a star put there — so this world reads cold and violet where the mountain's dark
    /// reads red and the city's warm.
    static let starDusk = Self(
        skyTop: Color(red: 0.02, green: 0.02, blue: 0.08),
        skyHorizon: Color(red: 0.17, green: 0.13, blue: 0.33),
        disc: Color(red: 0.94, green: 0.95, blue: 1.00),
        discHalo: Color(red: 0.64, green: 0.60, blue: 0.95),
        cloud: Color(red: 0.15, green: 0.14, blue: 0.26),
        farHill: Color(red: 0.11, green: 0.10, blue: 0.21),
        ground: Color(red: 0.12, green: 0.11, blue: 0.21),
        foreground: Color(red: 0.09, green: 0.08, blue: 0.16),
        blade: Color(red: 0.07, green: 0.06, blue: 0.14),
        canopy: Color(red: 0.15, green: 0.13, blue: 0.25),
        canopyShade: Color(red: 0.09, green: 0.08, blue: 0.18),
        isNight: true,
        cover: .dust
    )

    /// The sixth world, which has no daylight to offer at all: the sky is the roof of the cave,
    /// and what stands in for the sun is the crystal light coming off the flowstone. This is the
    /// world's *lit* palette all the same — a gallery deep enough to see across, where the far
    /// wall catches enough light to tell there is one.
    ///
    /// The rock is a wet limestone grey with the green of standing water in it, which is the one
    /// thing this world cannot borrow from the one above it. The reaches are violet dust lit from
    /// the sky; a cave dimmed to the same violet would only read as the reaches after dark. So the
    /// floor goes cold and mineral and the light on it goes to crystal, and the two worlds are
    /// told apart by their colour rather than only by their brightness.
    static let gloamDay = Self(
        skyTop: Color(red: 0.08, green: 0.11, blue: 0.11),
        skyHorizon: Color(red: 0.34, green: 0.42, blue: 0.42),
        disc: Color(red: 0.74, green: 0.94, blue: 0.95),
        discHalo: Color(red: 0.38, green: 0.74, blue: 0.76),
        cloud: Color(red: 0.19, green: 0.25, blue: 0.25),
        farHill: Color(red: 0.17, green: 0.23, blue: 0.23),
        ground: Color(red: 0.41, green: 0.46, blue: 0.44),
        foreground: Color(red: 0.30, green: 0.35, blue: 0.34),
        blade: Color(red: 0.24, green: 0.29, blue: 0.29),
        canopy: Color(red: 0.35, green: 0.41, blue: 0.40),
        canopyShade: Color(red: 0.21, green: 0.26, blue: 0.26),
        isNight: false,
        cover: .flowstone
    )

    /// The caverns with the light out — which down here is only a matter of how far off the next
    /// crystal is. The roof goes altogether, the walls go with it, and the crystals read brighter
    /// for having nothing to compete with: the reaches took their light from the sky and this
    /// world takes what it has out of the rock.
    static let gloamDusk = Self(
        skyTop: Color(red: 0.02, green: 0.03, blue: 0.03),
        skyHorizon: Color(red: 0.07, green: 0.10, blue: 0.10),
        disc: Color(red: 0.66, green: 0.96, blue: 0.98),
        discHalo: Color(red: 0.26, green: 0.68, blue: 0.72),
        cloud: Color(red: 0.05, green: 0.08, blue: 0.08),
        farHill: Color(red: 0.04, green: 0.06, blue: 0.06),
        ground: Color(red: 0.10, green: 0.14, blue: 0.13),
        foreground: Color(red: 0.07, green: 0.10, blue: 0.10),
        blade: Color(red: 0.05, green: 0.08, blue: 0.08),
        canopy: Color(red: 0.09, green: 0.13, blue: 0.12),
        canopyShade: Color(red: 0.05, green: 0.08, blue: 0.08),
        isNight: true,
        cover: .flowstone
    )

    /// The seventh world's lit palette, which is a fairground in the last of the evening rather
    /// than a fairground by day — a carnival lit at noon is a field with tents in it.
    ///
    /// The light comes from two places at once and that is the whole look of the world: a warm
    /// low sun going down behind the big top, and the lanterns already on. So the sky is amber at
    /// the horizon and plum above it, and the ground has both of those lying on it. Every world
    /// so far has taken its colour from what its ground is made of; this one takes it from what
    /// is strung up over the ground, which is why it is the only world in the game where the
    /// brightest thing is not the sky or the floor but the lights between them.
    static let lanternDay = Self(
        skyTop: Color(red: 0.24, green: 0.12, blue: 0.30),
        skyHorizon: Color(red: 0.96, green: 0.62, blue: 0.44),
        disc: Color(red: 1.00, green: 0.88, blue: 0.58),
        discHalo: Color(red: 0.99, green: 0.66, blue: 0.46),
        cloud: Color(red: 0.60, green: 0.32, blue: 0.44),
        farHill: Color(red: 0.35, green: 0.17, blue: 0.33),
        ground: Color(red: 0.49, green: 0.38, blue: 0.31),
        foreground: Color(red: 0.37, green: 0.28, blue: 0.25),
        blade: Color(red: 0.30, green: 0.22, blue: 0.21),
        canopy: Color(red: 0.83, green: 0.36, blue: 0.48),
        canopyShade: Color(red: 0.55, green: 0.19, blue: 0.33),
        isNight: false,
        cover: .sawdust
    )

    /// The carnival once the sun has gone, which is when a carnival is itself. Nothing is left of
    /// the sky, the tents go to silhouettes, and the lanterns are the only light there is — so
    /// the ground reads warm and the dark reads plum, where the reaches after dark read cold and
    /// the caverns read wet. It is the one night in the game that somebody put on purpose.
    static let lanternDusk = Self(
        skyTop: Color(red: 0.05, green: 0.02, blue: 0.09),
        skyHorizon: Color(red: 0.27, green: 0.09, blue: 0.23),
        disc: Color(red: 1.00, green: 0.84, blue: 0.62),
        discHalo: Color(red: 0.86, green: 0.42, blue: 0.44),
        cloud: Color(red: 0.16, green: 0.06, blue: 0.16),
        farHill: Color(red: 0.11, green: 0.04, blue: 0.13),
        ground: Color(red: 0.24, green: 0.15, blue: 0.16),
        foreground: Color(red: 0.17, green: 0.10, blue: 0.13),
        blade: Color(red: 0.13, green: 0.07, blue: 0.11),
        canopy: Color(red: 0.48, green: 0.17, blue: 0.29),
        canopyShade: Color(red: 0.28, green: 0.09, blue: 0.19),
        isNight: true,
        cover: .sawdust
    )

    /// The eighth world's daylight, and the one light in the game that is too much of it.
    ///
    /// Every world below this has a sky somebody would want to stand under. A desert at noon has
    /// glare instead: the sun is small and white rather than big and yellow, the horizon is
    /// burnt out to nearly nothing, and the blue only comes back well overhead. Which makes the
    /// sand the brightest thing on the screen and the shadows the bluest — the only light left to
    /// fill them with is the sky — so the world reads hot by being pale, where Emberpeak reads hot
    /// by being orange.
    static let duneDay = Self(
        skyTop: Color(red: 0.34, green: 0.58, blue: 0.82),
        skyHorizon: Color(red: 0.98, green: 0.93, blue: 0.80),
        disc: Color(red: 1.00, green: 0.99, blue: 0.92),
        discHalo: Color(red: 1.00, green: 0.95, blue: 0.74),
        cloud: Color(red: 0.99, green: 0.96, blue: 0.89),
        farHill: Color(red: 0.83, green: 0.72, blue: 0.55),
        ground: Color(red: 0.91, green: 0.79, blue: 0.55),
        foreground: Color(red: 0.80, green: 0.66, blue: 0.43),
        blade: Color(red: 0.66, green: 0.52, blue: 0.34),
        canopy: Color(red: 0.45, green: 0.56, blue: 0.34),
        canopyShade: Color(red: 0.29, green: 0.40, blue: 0.24),
        isNight: false,
        cover: .sand
    )

    /// The desert after dark, which is the coldest night in the game for the same reason the day
    /// is the hottest: there is nothing over the sand to hold anything in. So the heat goes
    /// straight up and out, the sand turns from gold to a blue-grey with no warmth left in it at
    /// all, and the sky comes down further than anywhere else — the caverns are dark and the
    /// reaches are cold, and this is both at once with a great deal of sky on top.
    static let duneDusk = Self(
        skyTop: Color(red: 0.03, green: 0.05, blue: 0.14),
        skyHorizon: Color(red: 0.20, green: 0.24, blue: 0.40),
        disc: Color(red: 0.97, green: 0.97, blue: 1.00),
        discHalo: Color(red: 0.72, green: 0.78, blue: 0.94),
        cloud: Color(red: 0.14, green: 0.17, blue: 0.28),
        farHill: Color(red: 0.12, green: 0.14, blue: 0.24),
        ground: Color(red: 0.24, green: 0.25, blue: 0.32),
        foreground: Color(red: 0.17, green: 0.18, blue: 0.25),
        blade: Color(red: 0.12, green: 0.13, blue: 0.19),
        canopy: Color(red: 0.20, green: 0.28, blue: 0.24),
        canopyShade: Color(red: 0.12, green: 0.18, blue: 0.17),
        isNight: true,
        cover: .sand
    )

    /// The ninth world's daylight: sea light, which is the desert's glare with the heat taken
    /// out of it. Everything here has just been under water and half of it still is, so the sky
    /// is a washed pale blue, the ground is dark with wet rather than bright with sun, and the
    /// horizon is the one line in the game that is actually the sea. The world reads cool by
    /// being damp, where the dunes read hot by being pale.
    static let coveDay = Self(
        skyTop: Color(red: 0.45, green: 0.68, blue: 0.80),
        skyHorizon: Color(red: 0.85, green: 0.92, blue: 0.91),
        disc: Color(red: 1.00, green: 0.98, blue: 0.90),
        discHalo: Color(red: 0.95, green: 0.97, blue: 0.88),
        cloud: Color(red: 0.96, green: 0.97, blue: 0.96),
        farHill: Color(red: 0.42, green: 0.62, blue: 0.66),
        ground: Color(red: 0.72, green: 0.66, blue: 0.52),
        foreground: Color(red: 0.60, green: 0.54, blue: 0.42),
        blade: Color(red: 0.46, green: 0.42, blue: 0.32),
        canopy: Color(red: 0.36, green: 0.55, blue: 0.46),
        canopyShade: Color(red: 0.22, green: 0.38, blue: 0.34),
        isNight: false,
        cover: .shingle
    )

    /// The cove after dark, under a sea fog coming in with the tide: the sky never goes as
    /// black as the desert's because the water underneath it holds what light there is and
    /// hands it back, so the night here is a deep green-grey with a pale line where the sea
    /// still shows, and the wet sand keeps a sheen the dry worlds lose at dusk.
    static let coveDusk = Self(
        skyTop: Color(red: 0.05, green: 0.10, blue: 0.16),
        skyHorizon: Color(red: 0.18, green: 0.30, blue: 0.36),
        disc: Color(red: 0.94, green: 0.96, blue: 0.94),
        discHalo: Color(red: 0.62, green: 0.78, blue: 0.80),
        cloud: Color(red: 0.13, green: 0.20, blue: 0.25),
        farHill: Color(red: 0.10, green: 0.18, blue: 0.22),
        ground: Color(red: 0.22, green: 0.26, blue: 0.28),
        foreground: Color(red: 0.16, green: 0.19, blue: 0.21),
        blade: Color(red: 0.11, green: 0.14, blue: 0.16),
        canopy: Color(red: 0.16, green: 0.30, blue: 0.27),
        canopyShade: Color(red: 0.10, green: 0.20, blue: 0.19),
        isNight: true,
        cover: .shingle
    )

    /// The tenth world's daylight, which is the palest light in the game and the flattest: a
    /// low sun over sea ice, with nothing anywhere for it to warm. The cove read cool by being
    /// damp; this one reads cold by being blue — snow takes the sky's colour into every shadow
    /// it has, so the ground and the sky are two blues of the same weather, and the horizon is
    /// the one line where they nearly stop being different at all.
    static let frostDay = Self(
        skyTop: Color(red: 0.51, green: 0.70, blue: 0.86),
        skyHorizon: Color(red: 0.90, green: 0.94, blue: 0.96),
        disc: Color(red: 1.00, green: 0.98, blue: 0.90),
        discHalo: Color(red: 0.96, green: 0.94, blue: 0.82),
        cloud: Color(red: 0.94, green: 0.96, blue: 0.98),
        farHill: Color(red: 0.66, green: 0.78, blue: 0.87),
        ground: Color(red: 0.85, green: 0.90, blue: 0.94),
        foreground: Color(red: 0.73, green: 0.80, blue: 0.87),
        blade: Color(red: 0.58, green: 0.68, blue: 0.78),
        canopy: Color(red: 0.42, green: 0.56, blue: 0.60),
        canopyShade: Color(red: 0.28, green: 0.41, blue: 0.47),
        isNight: false,
        cover: .snowfield
    )

    /// The tundra after dark, which is the one night in the game with its own light in it: the
    /// aurora. The desert's night is black because there is nothing overhead; this one never
    /// quite manages black because there is — a green hanging in the sky and lying faintly on
    /// every ridge of the snow, so the canopy colours here are borrowed by the sky itself and
    /// the ground keeps a blue glow the way the cove's sand keeps its sheen.
    static let frostDusk = Self(
        skyTop: Color(red: 0.03, green: 0.07, blue: 0.15),
        skyHorizon: Color(red: 0.12, green: 0.28, blue: 0.32),
        disc: Color(red: 0.96, green: 0.98, blue: 1.00),
        discHalo: Color(red: 0.66, green: 0.86, blue: 0.86),
        cloud: Color(red: 0.10, green: 0.17, blue: 0.24),
        farHill: Color(red: 0.13, green: 0.21, blue: 0.30),
        ground: Color(red: 0.16, green: 0.22, blue: 0.32),
        foreground: Color(red: 0.11, green: 0.16, blue: 0.24),
        blade: Color(red: 0.08, green: 0.12, blue: 0.19),
        canopy: Color(red: 0.16, green: 0.42, blue: 0.36),
        canopyShade: Color(red: 0.09, green: 0.27, blue: 0.25),
        isNight: true,
        cover: .snowfield
    )

    /// The eleventh world's daylight, which never quite arrives: fen light, flat and green,
    /// under a sky that is mostly the water's own breath. The tundra was the palest light in
    /// the game; this is the heaviest — the horizon shortened by haze, the sun a smear behind
    /// it, and everything below in the greens and browns of ground that has never once dried
    /// out. The world reads wet by being dim, where the cove read cool by being damp.
    static let fenDay = Self(
        skyTop: Color(red: 0.56, green: 0.62, blue: 0.55),
        skyHorizon: Color(red: 0.83, green: 0.84, blue: 0.72),
        disc: Color(red: 0.97, green: 0.95, blue: 0.82),
        discHalo: Color(red: 0.88, green: 0.88, blue: 0.72),
        cloud: Color(red: 0.78, green: 0.80, blue: 0.72),
        farHill: Color(red: 0.38, green: 0.46, blue: 0.33),
        ground: Color(red: 0.36, green: 0.40, blue: 0.24),
        foreground: Color(red: 0.27, green: 0.31, blue: 0.18),
        blade: Color(red: 0.21, green: 0.25, blue: 0.14),
        canopy: Color(red: 0.32, green: 0.44, blue: 0.26),
        canopyShade: Color(red: 0.20, green: 0.30, blue: 0.17),
        isNight: false,
        cover: .marsh
    )

    /// The fen after dark, which is when it does its talking: the mist thickens off the
    /// channels and holds what light there is just above the ground, so the night here is a
    /// grey-green with its darkness overhead rather than round your feet — the one night in
    /// the game that is lighter low down than up — and the odd pale glow stands in the reeds
    /// where the marsh is making its own light.
    static let fenDusk = Self(
        skyTop: Color(red: 0.04, green: 0.06, blue: 0.09),
        skyHorizon: Color(red: 0.22, green: 0.28, blue: 0.24),
        disc: Color(red: 0.93, green: 0.95, blue: 0.90),
        discHalo: Color(red: 0.68, green: 0.78, blue: 0.66),
        cloud: Color(red: 0.14, green: 0.18, blue: 0.16),
        farHill: Color(red: 0.10, green: 0.15, blue: 0.12),
        ground: Color(red: 0.14, green: 0.19, blue: 0.14),
        foreground: Color(red: 0.10, green: 0.14, blue: 0.10),
        blade: Color(red: 0.07, green: 0.10, blue: 0.07),
        canopy: Color(red: 0.18, green: 0.30, blue: 0.20),
        canopyShade: Color(red: 0.11, green: 0.19, blue: 0.13),
        isNight: true,
        cover: .marsh
    )

    /// The twelfth world's daylight, and the clearest in the game: there is less sky left
    /// overhead than anywhere else, so what there is goes a deeper blue than any world below,
    /// and the light on the turf is thin and brilliant with no haze in it at all. The fen was
    /// the heaviest light in the game; this is its opposite in every register — and the
    /// horizon is not land or sea but the top of the weather, a floor of sunlit cloud with
    /// the worlds underneath it out of sight.
    static let spireDay = Self(
        skyTop: Color(red: 0.30, green: 0.55, blue: 0.92),
        skyHorizon: Color(red: 0.88, green: 0.93, blue: 0.98),
        disc: Color(red: 1.00, green: 0.98, blue: 0.90),
        discHalo: Color(red: 0.97, green: 0.96, blue: 0.86),
        cloud: Color(red: 0.99, green: 0.99, blue: 1.00),
        farHill: Color(red: 0.80, green: 0.86, blue: 0.94),
        ground: Color(red: 0.62, green: 0.74, blue: 0.62),
        foreground: Color(red: 0.50, green: 0.63, blue: 0.53),
        blade: Color(red: 0.40, green: 0.53, blue: 0.45),
        canopy: Color(red: 0.38, green: 0.54, blue: 0.50),
        canopyShade: Color(red: 0.26, green: 0.40, blue: 0.40),
        isNight: false,
        cover: .cloudtop
    )

    /// The heights after dark, which is the blackest sky in the game for the best reason:
    /// the weather is underneath you. Nothing hazes the stars up here, so the top of the sky
    /// goes nearly out — past even the desert's — while the cloud sea below holds the
    /// moonlight and gives it back, the way the cove's wet sand did. It is the one night in
    /// the game where the brightest thing under the moon is the floor of the world.
    static let spireDusk = Self(
        skyTop: Color(red: 0.01, green: 0.02, blue: 0.07),
        skyHorizon: Color(red: 0.16, green: 0.20, blue: 0.36),
        disc: Color(red: 0.97, green: 0.98, blue: 1.00),
        discHalo: Color(red: 0.80, green: 0.84, blue: 0.98),
        cloud: Color(red: 0.30, green: 0.34, blue: 0.46),
        farHill: Color(red: 0.26, green: 0.30, blue: 0.43),
        ground: Color(red: 0.13, green: 0.17, blue: 0.24),
        foreground: Color(red: 0.09, green: 0.12, blue: 0.18),
        blade: Color(red: 0.06, green: 0.09, blue: 0.14),
        canopy: Color(red: 0.14, green: 0.20, blue: 0.26),
        canopyShade: Color(red: 0.08, green: 0.13, blue: 0.19),
        isNight: true,
        cover: .cloudtop
    )
}
