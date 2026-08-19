import Foundation
import SwiftUI

@main
struct PigpenApp: App {
    /// The ear on the game's own reminders, installed at launch because a tap on one is
    /// handed over before any screen is up to hear it. It writes the morning down; the
    /// title screen opens it.
    @UIApplicationDelegateAdaptor(ReminderTapListener.self) private var reminderTaps

    /// CI launches the app with one of the arguments in `Photograph` below, or one of the
    /// film arguments in `stills`, so the pull request screenshots can show the boards, the
    /// universe map, each world's trail, the practice pen, the daily puzzle and its archive,
    /// the settings sheet, the offer of a daily reminder and every shot of every cut scene
    /// rather than only the title screen.
    ///
    /// The arguments themselves are not listed here any more. They were, and the list went
    /// out of date the way a list written down twice always does.
    ///
    /// The daily screens are opened on a fixed square of the calendar rather than on
    /// whatever day the runner is having, so the archive shows the same month of finished
    /// and shut days every time, and the clock over the board is handed over already stopped.
    /// The world and the plain board are shown part-way through, since an untouched world
    /// has nothing on it yet and an untouched field has no fencing and not a control on it
    /// lit. `-beaten` is the same first level opened again by somebody who has already held
    /// it: bare mud, and the tally up before a piece is laid with the score they took last
    /// time, the stars it was worth, and the trophy offering the whole wall back. The next
    /// two boards are the ones with something lying on the ground: the
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

    /// Every screen the camera can be opened straight onto, named by the argument that opens
    /// it — and the only place those arguments are written down.
    ///
    /// It is an enum rather than a list of strings checked one by one because two things
    /// have to agree about it and used to be able to drift apart: what the app opens, and
    /// what counting treats as a camera rather than a player. A run that opens straight onto
    /// Stag Mere and photographs it is not somebody who beat Stag Mere, and twice in three
    /// merges a new argument arrived without anybody remembering to say so.
    ///
    /// Now there is nowhere to say it twice. `photographArguments` is derived from these
    /// cases, and the switch that opens them is exhaustive, so an argument cannot exist
    /// without the compiler asking what it opens and counting already knowing to ignore it.
    enum Photograph: String, CaseIterable {
        case puzzle = "-puzzle"
        case beaten = "-beaten"
        case orchard = "-orchard"
        case sour = "-sour"
        case boss = "-boss"
        case truffles = "-truffles"
        case embers = "-embers"
        case pies = "-pies"
        case map = "-map"
        case universe = "-universe"
        case woodsMap = "-woods-map"
        case peakMap = "-peak-map"
        case cityMap = "-city-map"
        case tutorial = "-tutorial"
        case daily = "-daily"
        case archive = "-archive"
        case settings = "-settings"
        case reminder = "-reminder"
        case titleFresh = "-title-fresh"
        case title = "-title"
    }

    /// Every argument there is: the films above, and every screen beside them. The whole list
    /// of ways into the app that are not the front door, and none of them a player.
    static let photographArguments: Set<String> = Set(
        stills.map { $0.argument } + Photograph.allCases.map(\.rawValue)
    )

    static func isPhotographing(_ launch: [String] = ProcessInfo.processInfo.arguments) -> Bool {
        !photographArguments.isDisjoint(with: launch)
    }

    /// Which screen this run was opened onto, if it was opened onto one at all.
    private var photograph: Photograph? {
        Photograph.allCases.first { launch.contains($0.rawValue) }
    }

    /// Whether the game has been put down — the cue to send whatever has been counted so
    /// far, since a player who backgrounds the app may never bring it up again.
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let still = Self.stills.first(where: { launch.contains($0.argument) }) {
                    CutSceneView(.named(still.scene), still: still.seconds)
                } else if let photograph {
                    screen(for: photograph)
                } else {
                    TitleScreenView()
                }
            }
            .task {
                guard !Self.isPhotographing(launch) else { return }
                Analytics.record(.sessionStarted(isFirstRun: Analytics.shared.isFirstRun))
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // Anything counted since the last batch goes the moment the game is put down.
            // A phone in a pocket is where most sessions end, and a batch still in hand
            // when the system reclaims the app is a batch nobody ever sees.
            guard phase != .active else { return }
            Analytics.flush()
        }
    }

    /// What each argument opens onto. Exhaustive on purpose: this is the half of the bargain
    /// that makes a new screen argument impossible to add quietly, since the compiler will
    /// not let a case go unanswered.
    @ViewBuilder
    private func screen(for photograph: Photograph) -> some View {
        switch photograph {
        case .puzzle:
            PuzzleView(game: .partWayThrough())
        case .beaten:
            PuzzleView(game: .pickedBackUp())
        case .orchard:
            PuzzleView(game: .theOrchardsBestPen())
        case .sour:
            PuzzleView(game: .applesAndSkulls())
        case .boss:
            PuzzleView(game: .theStagMeresBestPen())
        case .truffles:
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
        case .embers:
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
        case .pies:
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
        case .map:
            WorldMapView(progress: .partWayThrough())
        case .universe:
            // The meadow held, the thicket open and beckoning, and the worlds past it
            // still silhouettes — the map with something to show at every standing.
            UniverseMapView(progress: .partWayThrough())
        case .woodsMap:
            WorldMapView(
                world: .thornwoodThicket,
                progress: .partWayThrough(world: .thornwoodThicket)
            )
        case .peakMap:
            WorldMapView(
                world: .emberpeak,
                progress: .partWayThrough(world: .emberpeak)
            )
        case .cityMap:
            WorldMapView(
                world: .cogsworthCity,
                progress: .partWayThrough(world: .cogsworthCity)
            )
        case .tutorial:
            TutorialView()
        case .daily:
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
        case .archive:
            DailyArchiveView(
                today: Self.photographed,
                progress: .partWayThroughTheMonth(today: Self.photographed)
            )
        case .settings:
            // With a fortnight of days complete as well, so the card behind the gear
            // has the dailies to say something about and the clear button has all
            // of it to clear. The reminder is switched on and held in memory, so the
            // reminder card is photographed with its hour showing and nothing is
            // left standing on the machine that took the picture.
            TitleScreenView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(today: Self.photographed),
                reminder: .reminding(),
                today: Self.photographed,
                showsSettings: true
            )
        case .reminder:
            // The game's own offer of a daily reminder, over a fortnight of days with
            // today held — which is the state it really appears in, since it is only
            // ever put up to somebody with a run of days to lose. Its reminder is
            // held in memory too: a screenshot runner must never be asked for
            // permission by the phone.
            TitleScreenView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(
                    today: Self.photographed,
                    includingToday: true
                ),
                reminder: .neverAsked(),
                today: Self.photographed,
                showsReminderPrompt: true
            )
        case .titleFresh:
            // The title screen with nothing won on it. It takes an argument of its
            // own now rather than being what a bare launch gives you, because a bare
            // launch on a device that has never been played opens the walkthrough
            // over the top of it — which is the point of the walkthrough, and no use
            // as a photograph of the title screen. The world is held in memory and
            // its tutorial already spent, so the shot is the empty title screen
            // however much the runner played before it.
            TitleScreenView(progress: .beforeTheFirstStar())
        case .title:
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
        }
    }
}
