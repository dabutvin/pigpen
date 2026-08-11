import SwiftUI

/// The colours of the field. Mud is warm and dull so the water and the finished pen
/// can be the two things that catch the eye.
enum GamePalette {
    static let mud = Color(red: 0.64, green: 0.49, blue: 0.36)
    /// The same mud with the light full on it and with the light off it, so the field can
    /// be lit from above the way every other drawn thing in the game is.
    static let mudLit = Color(red: 0.71, green: 0.56, blue: 0.42)
    static let mudShade = Color(red: 0.55, green: 0.41, blue: 0.29)
    static let mudSpeckle = Color(red: 0.44, green: 0.32, blue: 0.22)
    static let water = Color(red: 0.24, green: 0.55, blue: 0.76)
    /// Out in the middle of a lake, where the bottom of it is further down.
    static let waterDeep = Color(red: 0.16, green: 0.42, blue: 0.64)
    static let waterRipple = Color(red: 0.76, green: 0.90, blue: 0.98)
    /// Wet silt along a bank, where the water gives out and the mud starts.
    static let shore = Color(red: 0.82, green: 0.72, blue: 0.54)
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
        /// where the mountain has burnt everything off.
        let cover: Cover
    }

    /// The three kinds of ground the game draws. A world picks one and the backdrop and the
    /// world map both follow it, which is the whole of what makes a thicket read as woods
    /// and a mountain as bare rock rather than as a meadow tinted a different colour.
    enum Cover: Sendable {
        case pasture
        case woodland
        case scree
    }
}

extension GamePalette.Pasture {
    static let day = Self(
        skyTop: Color(red: 0.36, green: 0.66, blue: 0.92),
        skyHorizon: Color(red: 0.94, green: 0.94, blue: 0.83),
        disc: Color(red: 1.00, green: 0.91, blue: 0.55),
        discHalo: Color(red: 1.00, green: 0.94, blue: 0.66),
        cloud: .white,
        farHill: Color(red: 0.60, green: 0.78, blue: 0.49),
        ground: GamePalette.beyond,
        foreground: Color(red: 0.38, green: 0.59, blue: 0.30),
        blade: Color(red: 0.30, green: 0.50, blue: 0.24),
        canopy: Color(red: 0.36, green: 0.61, blue: 0.31),
        canopyShade: Color(red: 0.25, green: 0.46, blue: 0.24),
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
}
