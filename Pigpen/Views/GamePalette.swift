import SwiftUI

/// The colours of the field. Mud is warm and dull so the water and the finished pen
/// can be the two things that catch the eye.
enum GamePalette {
    static let mud = Color(red: 0.64, green: 0.49, blue: 0.36)
    static let mudSpeckle = Color(red: 0.44, green: 0.32, blue: 0.22)
    static let water = Color(red: 0.24, green: 0.55, blue: 0.76)
    static let waterRipple = Color(red: 0.76, green: 0.90, blue: 0.98)
    static let pen = Color(red: 0.98, green: 0.78, blue: 0.33)
    static let post = Color(red: 0.27, green: 0.17, blue: 0.10)
    static let rail = Color(red: 0.62, green: 0.42, blue: 0.24)
    /// Pale, freshly cut timber, light enough to stand out against the mud.
    static let picket = Color(red: 0.78, green: 0.60, blue: 0.39)
    /// Everything past the edge of the map: open country, and a lost pig.
    static let beyond = Color(red: 0.47, green: 0.68, blue: 0.38)
    /// Painted board: lettering and signage that has to read against sky or grass alike.
    static let cream = Color(red: 0.99, green: 0.95, blue: 0.87)

    /// The pasture on the title screen. The board itself keeps one set of colours whatever
    /// the system appearance; only this backdrop moves from daylight to dusk.
    struct Pasture {
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
        let lake: Color
        /// Dusk gets stars and fireflies where daylight gets birds and pollen.
        let isNight: Bool
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
        lake: Color(red: 0.44, green: 0.70, blue: 0.84),
        isNight: false
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
        lake: Color(red: 0.16, green: 0.30, blue: 0.45),
        isNight: true
    )
}
