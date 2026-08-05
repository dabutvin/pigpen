import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle` or `-map` so the pull request screenshots can
    /// show the board and the world map rather than only the title screen. The map is
    /// shown part-way through a world, since an untouched one has nothing on it yet.
    private let launch = ProcessInfo.processInfo.arguments

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if launch.contains("-puzzle") {
                    PuzzleView(level: .riverBend)
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
