import Foundation
import SwiftUI

@main
struct PigpenApp: App {
    /// CI launches the app with `-puzzle`, `-orchard`, `-sour`, `-boss`, `-truffles`,
    /// `-embers`, `-pies`, `-map`, `-universe`, `-woods-map`, `-peak-map`, `-city-map`,
    /// `-tutorial`, `-daily`, `-archive`, `-title`, `-title-fresh`, `-settings` or one of
    /// the film arguments so the pull request screenshots can show
    /// the boards, the universe map, each world's trail, the practice pen, the daily
    /// puzzle and its archive, the settings sheet and every shot of every cut scene
    /// rather than only the title screen.
    ///
    /// The daily screens are opened on a fixed square of the calendar rather than on
    /// whatever day the runner is having, so the archive shows the same month of finished
    /// and shut days every time, and the clock over the board is handed over already stopped.
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

    /// The square of the calendar the daily screens are photographed on. A day well into a
    /// month, so the archive has held days behind it and shut ones ahead of it in the same
    /// picture, and a Wednesday, so the board is one of the middling ones.
    private static let photographed = DailyDate(year: 2026, month: 4, day: 22)

    /// Where each shot of each film is stopped for its photograph: far enough into the
    /// shot that the camera has moved and the caption is fully up, and far enough from
    /// either end of it that a line rewritten a word longer does not photograph a shot
    /// with half its type still fading. `CutSceneTests` pins every one of them to the
    /// middle of the shot it belongs to, so a script edit that walks a still off its shot
    /// fails there rather than in a screenshot nobody looks at twice.
    static let stills: [(argument: String, scene: CutScene.Name, seconds: TimeInterval)] = [
        ("-opening", .opening, 1.6),
        ("-opening-gate", .opening, 4.4),
        ("-opening-pig", .opening, 6.8),
        ("-opening-away", .opening, 9.7),
        ("-opening-pen", .opening, 12.8),
        ("-opening-fence", .opening, 15.6),
        ("-mere", .stagMere, 1.4),
        ("-mere-stag", .stagMere, 4.1),
        ("-mere-both", .stagMere, 7.2),
        ("-held-penned", .theMeadowHeld, 1.4),
        ("-held-stag", .theMeadowHeld, 4.0),
        ("-held-meadow", .theMeadowHeld, 7.2),
        ("-held-world", .theMeadowHeld, 10.4),
        ("-held-beyond", .theMeadowHeld, 13.4)
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
                } else if launch.contains("-truffles") {
                    // A thicket board: the truffle and the bramble stand where the apple and
                    // the skull would, the same +5 and -5 dressed for the woods, on leaf
                    // mould with peat pools in it rather than mud and open water.
                    PuzzleView(
                        level: .nettleBank,
                        treatSkin: WorldTheme.thornwood.treats,
                        skin: WorldTheme.thornwood.field,
                        day: .forestDay,
                        dusk: .forestDusk
                    )
                } else if launch.contains("-embers") {
                    // A mountain board: the chestnut and the ember stand where the apple and
                    // the skull would, the same +5 and -5 dressed for the peak, on ash with
                    // cinder still going in it and a tarn steaming where a mere would be.
                    PuzzleView(
                        level: .smoulderRidge,
                        treatSkin: WorldTheme.emberpeak.treats,
                        skin: WorldTheme.emberpeak.field,
                        day: .emberDay,
                        dusk: .emberDusk
                    )
                } else if launch.contains("-pies") {
                    // A city board: the pie and the drain stand where the apple and the
                    // skull would, the same +5 and -5 dressed for the streets, on paving,
                    // with a canal for water and wrought iron for fencing.
                    PuzzleView(
                        level: .clocktowerSquare,
                        treatSkin: WorldTheme.cogsworth.treats,
                        skin: WorldTheme.cogsworth.field,
                        day: .cityDay,
                        dusk: .cityDusk
                    )
                } else if launch.contains("-map") {
                    WorldMapView(progress: .partWayThrough())
                } else if launch.contains("-universe") {
                    // The meadow held, the thicket open and beckoning, and the worlds past it
                    // still silhouettes — the map with something to show at every standing.
                    UniverseMapView(progress: .partWayThrough())
                } else if launch.contains("-woods-map") {
                    WorldMapView(
                        world: .thornwoodThicket,
                        progress: .partWayThrough(world: .thornwoodThicket)
                    )
                } else if launch.contains("-peak-map") {
                    WorldMapView(
                        world: .emberpeak,
                        progress: .partWayThrough(world: .emberpeak)
                    )
                } else if launch.contains("-city-map") {
                    WorldMapView(
                        world: .cogsworthCity,
                        progress: .partWayThrough(world: .cogsworthCity)
                    )
                } else if launch.contains("-tutorial") {
                    TutorialView()
                } else if launch.contains("-daily") {
                    // Part way through, like the meadow's plain board: an untouched field
                    // has no fencing on it and not a control lit. The clock is handed over
                    // already stopped, since a running one photographs as whenever the
                    // runner got round to it, the same way a film does.
                    if let day = DailyAlmanac.level(on: Self.photographed) {
                        PuzzleView(game: .aDayPartWayThrough(day), clock: .showing(227))
                    } else {
                        DailyPuzzleView(
                            date: Self.photographed,
                            progress: DailyProgress(store: RememberedDailyRecords())
                        )
                    }
                } else if launch.contains("-archive") {
                    DailyArchiveView(
                        today: Self.photographed,
                        progress: .partWayThroughTheMonth(today: Self.photographed)
                    )
                } else if launch.contains("-settings") {
                    // With a fortnight of days complete as well, so the card behind the gear
                    // has the dailies to say something about and the clear button has all
                    // of it to clear.
                    TitleScreenView(
                        progress: .partWayThrough(),
                        daily: .partWayThroughTheMonth(today: Self.photographed),
                        today: Self.photographed,
                        showsSettings: true
                    )
                } else if launch.contains("-title-fresh") {
                    // The title screen with nothing won on it. It takes an argument of its
                    // own now rather than being what a bare launch gives you, because a bare
                    // launch on a device that has never been played opens the walkthrough
                    // over the top of it — which is the point of the walkthrough, and no use
                    // as a photograph of the title screen. The world is held in memory and
                    // its tutorial already spent, so the shot is the empty title screen
                    // however much the runner played before it.
                    TitleScreenView(progress: .beforeTheFirstStar())
                } else if launch.contains("-title") {
                    // Today complete as well as the fortnight behind it, since what there is to
                    // see on the daily's row is the stars and the run of days that a day
                    // already penned leaves on it.
                    TitleScreenView(
                        progress: .partWayThrough(),
                        daily: .partWayThroughTheMonth(
                            today: Self.photographed,
                            includingToday: true
                        ),
                        today: Self.photographed
                    )
                } else {
                    TitleScreenView()
                }
            }
        }
    }
}
