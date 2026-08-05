import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle`, `-penned` or `-map` so the pull request
    /// screenshots can show the board and the world map rather than only the title screen.
    /// None of them opens on a blank slate, since an untouched world has nothing on it yet
    /// and an untouched field has no fencing and not a control on it lit. `-penned` goes
    /// one further and opens on a pen that has closed, which is the half of the board —
    /// the wash, the tally, the count on the release button — that a field still being
    /// built has nothing to say about.
    private let launch = ProcessInfo.processInfo.arguments

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if launch.contains("-puzzle") {
                    PuzzleView(game: .partWayThrough())
                } else if launch.contains("-penned") {
                    PuzzleView(game: .holdingAPen())
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
