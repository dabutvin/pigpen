import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle` so the pull request screenshots can show the
    /// board itself rather than only the title screen.
    private let opensPuzzle = ProcessInfo.processInfo.arguments.contains("-puzzle")

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if opensPuzzle {
                    PuzzleView(level: .riverBend)
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
