import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle` or `-map` so the pull request screenshots can
    /// show the board and the world map rather than only the title screen. Both are shown
    /// part-way through, since an untouched world has nothing on it yet and an untouched
    /// field has no fencing and not a control on it lit.
    private let launch = ProcessInfo.processInfo.arguments

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if launch.contains("-puzzle") {
                    PuzzleView(game: .partWayThrough())
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
