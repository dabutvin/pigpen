import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle`, `-orchard`, `-sour`, `-map` or `-settings` so the
    /// pull request screenshots can show the boards, the world map and the settings sheet
    /// rather than only the title screen.
    /// The world and the plain board are shown part-way through, since an untouched world
    /// has nothing on it yet and an untouched field has no fencing and not a control on it
    /// lit. The other two boards are the ones with something lying on the ground: the
    /// orchard with its best pen closed, where an apple inside the pen and an apple under
    /// the fencing sit side by side, and Sour Ground with a pen holding one of each, where
    /// the apple and the skull cancel out. Settings opens over a world part-way through as
    /// well, and one held in memory: the clear button then has something to clear, and
    /// nothing saved on the device to take with it.
    private let launch = ProcessInfo.processInfo.arguments

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if launch.contains("-puzzle") {
                    PuzzleView(game: .partWayThrough())
                } else if launch.contains("-orchard") {
                    PuzzleView(game: .theOrchardsBestPen())
                } else if launch.contains("-sour") {
                    PuzzleView(game: .applesAndSkulls())
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else if launch.contains("-settings") {
                    TitleScreenView(progress: .partWayThrough(), showsSettings: true)
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
