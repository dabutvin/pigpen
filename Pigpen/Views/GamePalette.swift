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
}
