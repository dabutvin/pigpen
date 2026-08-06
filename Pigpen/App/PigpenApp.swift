import Foundation
import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle`, `-orchard`, `-sour`, `-boss`, `-map`,
    /// `-tutorial`, `-settings` or one of the film arguments so the pull request
    /// screenshots can show the boards, the world map, the practice pen, the settings sheet
    /// and every shot of every cut scene rather than only the title screen.
    /// The world and the plain board are shown part-way through, since an untouched world
    /// has nothing on it yet and an untouched field has no fencing and not a control on it
    /// lit. The next two boards are the ones with something lying on the ground: the
    /// orchard with its best pen closed, where an apple inside the pen and an apple under
    /// the fencing sit side by side, and Sour Ground with a pen holding one of each, where
    /// the apple and the skull cancel out. `-boss` is the meadow's last level, where a
    /// stag stands on the far shore of the mere and the best pen holds both animals in two
    /// enclosures at once. Settings opens over a world part-way through as well, and one
    /// held in memory: the clear button then has something to clear, and nothing saved on
    /// the device to take with it.
    ///
    /// The films are shot a moment at a time rather than played, since a screenshot of
    /// something on a clock is a screenshot of whenever the runner happened to get round to
    /// it. Each film argument stops one of them on one of its shots, so the same frame
    /// comes out of every run.
    private let launch = ProcessInfo.processInfo.arguments

    /// Where each shot of each film is stopped for its photograph: far enough into the
    /// shot that the camera has moved and the caption is fully up.
    private static let stills: [(argument: String, scene: CutScene.Name, seconds: TimeInterval)] = [
        ("-opening", .opening, 1.4),
        ("-opening-gate", .opening, 4.0),
        ("-opening-pig", .opening, 7.0),
        ("-opening-away", .opening, 9.6),
        ("-opening-fence", .opening, 12.0),
        ("-mere", .stagMere, 1.3),
        ("-mere-stag", .stagMere, 3.9),
        ("-mere-both", .stagMere, 6.6),
        ("-held-penned", .theMeadowHeld, 1.3),
        ("-held-stag", .theMeadowHeld, 3.8),
        ("-held-meadow", .theMeadowHeld, 6.6),
        ("-held-world", .theMeadowHeld, 9.4),
        ("-held-beyond", .theMeadowHeld, 12.6)
    ]

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let still = Self.stills.first(where: { launch.contains($0.argument) }) {
                    CutSceneView(.named(still.scene), still: still.seconds)
                } else if launch.contains("-puzzle") {
                    PuzzleView(game: .partWayThrough())
                } else if launch.contains("-orchard") {
                    PuzzleView(game: .theOrchardsBestPen())
                } else if launch.contains("-sour") {
                    PuzzleView(game: .applesAndSkulls())
                } else if launch.contains("-boss") {
                    PuzzleView(game: .theStagMeresBestPen())
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else if launch.contains("-tutorial") {
                    TutorialView()
                } else if launch.contains("-settings") {
                    TitleScreenView(progress: .partWayThrough(), showsSettings: true)
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
