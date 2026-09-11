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
    /// universe map, each world's trail, the dressing barn beside the meadow's orchard and a
    /// pig wearing what she found in it, the practice pen, the daily puzzle and its archive,
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
    /// the device to take with it. Every shot of the title screen is handed a rating prompt
    /// held in memory for the same reason turned the other way round: these open onto a
    /// player with a world held and a fortnight of days behind them, which is the very
    /// standing the prompt watches for, and Apple's prompt cannot be asked to keep out of a
    /// photograph once it is up.
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
        ("-opening", .opening, 1.9),
        ("-opening-gate", .opening, 12.2),
        ("-opening-welcome", .opening, 20.6),
        ("-opening-treats", .opening, 30.7),
        ("-opening-close", .opening, 36.6),
        ("-mere", .stagMere, 2.4),
        ("-mere-resident", .stagMere, 9.1),
        ("-mere-both", .stagMere, 15.0),
        ("-held-penned", .theMeadowHeld, 1.9),
        ("-held-forest", .theMeadowHeld, 10.1),
        ("-held-away", .theMeadowHeld, 15.0),
        ("-thicket", .thornwoodOpening, 1.9),
        ("-thicket-treats", .thornwoodOpening, 11.9),
        ("-thicket-path", .thornwoodOpening, 20.1),
        ("-hollow", .boarHollow, 1.9),
        ("-hollow-apart", .boarHollow, 5.9),
        ("-hollow-pens", .boarHollow, 10.3),
        ("-thicket-held", .thornwoodHeld, 1.9),
        ("-thicket-mountain", .thornwoodHeld, 12.5),
        ("-thicket-volcano", .thornwoodHeld, 17.4),
        ("-peak-open-1", .emberpeakOpening, 1.9),
        ("-peak-open-2", .emberpeakOpening, 9.9),
        ("-peak-open-3", .emberpeakOpening, 18.3),
        ("-peak-boss-1", .wyrmCaldera, 2.7),
        ("-peak-boss-2", .wyrmCaldera, 10.0),
        ("-peak-boss-3", .wyrmCaldera, 18.5),
        ("-peak-held-1", .emberpeakHeld, 1.9),
        ("-peak-held-2", .emberpeakHeld, 8.6),
        ("-peak-held-3", .emberpeakHeld, 12.6),
        ("-city-open-1", .cogsworthOpening, 1.9),
        ("-city-open-2", .cogsworthOpening, 12.4),
        ("-city-open-3", .cogsworthOpening, 19.9),
        ("-city-boss-1", .ratKingWharf, 2.3),
        ("-city-boss-2", .ratKingWharf, 8.4),
        ("-city-boss-3", .ratKingWharf, 14.7),
        ("-city-held-1", .cogsworthHeld, 1.9),
        ("-city-held-2", .cogsworthHeld, 10.5),
        ("-city-held-3", .cogsworthHeld, 14.8),
        ("-reach-open-1", .starfallOpening, 1.9),
        ("-reach-open-2", .starfallOpening, 14.0),
        ("-reach-open-3", .starfallOpening, 19.3),
        ("-reach-boss-1", .visitorCrater, 2.2),
        ("-reach-boss-2", .visitorCrater, 6.2),
        ("-reach-boss-3", .visitorCrater, 14.5),
        ("-reach-held-1", .starfallHeld, 1.9),
        ("-reach-held-2", .starfallHeld, 12.1),
        ("-reach-held-3", .starfallHeld, 15.7),
        ("-cave-open-1", .gloamdeepOpening, 1.9),
        ("-cave-open-2", .gloamdeepOpening, 14.0),
        ("-cave-open-3", .gloamdeepOpening, 17.8),
        ("-cave-boss-1", .theRoost, 2.3),
        ("-cave-boss-2", .theRoost, 8.0),
        ("-cave-boss-3", .theRoost, 18.7),
        ("-cave-held-1", .gloamdeepHeld, 1.9),
        ("-cave-held-2", .gloamdeepHeld, 9.8),
        ("-cave-held-3", .gloamdeepHeld, 13.6),
        ("-fair-open-1", .lanternOpening, 9.2),
        ("-fair-open-2", .lanternOpening, 12.9),
        ("-fair-open-3", .lanternOpening, 20.2),
        ("-fair-boss-1", .theCenterRing, 1.9),
        ("-fair-boss-2", .theCenterRing, 8.4),
        ("-fair-boss-3", .theCenterRing, 12.5),
        ("-fair-held-1", .lanternHeld, 1.9),
        ("-fair-held-2", .lanternHeld, 12.1),
        ("-fair-held-3", .lanternHeld, 17.0),
        ("-dune-open-1", .duneOpening, 9.1),
        ("-dune-open-2", .duneOpening, 15.4),
        ("-dune-open-3", .duneOpening, 21.1),
        ("-dune-boss-1", .scorpionFlats, 2.4),
        ("-dune-boss-2", .scorpionFlats, 6.4),
        ("-dune-boss-3", .scorpionFlats, 15.6),
        ("-dune-held-1", .duneHeld, 1.9),
        ("-dune-held-2", .duneHeld, 8.3),
        ("-dune-held-3", .duneHeld, 12.5),
        ("-cove-open-1", .tidepoolOpening, 1.9),
        ("-cove-open-2", .tidepoolOpening, 14.0),
        ("-cove-open-3", .tidepoolOpening, 17.5),
        ("-cove-boss-1", .theCrabPool, 3.2),
        ("-cove-boss-2", .theCrabPool, 10.0),
        ("-cove-boss-3", .theCrabPool, 15.6),
        ("-cove-held-1", .tidepoolHeld, 1.9),
        ("-cove-held-2", .tidepoolHeld, 11.0),
        ("-cove-held-3", .tidepoolHeld, 16.4),
        ("-ice-open-1", .frostwhiskerOpening, 9.0),
        ("-ice-open-2", .frostwhiskerOpening, 15.1),
        ("-ice-open-3", .frostwhiskerOpening, 19.7),
        ("-ice-boss-1", .theHaulout, 2.4),
        ("-ice-boss-2", .theHaulout, 6.0),
        ("-ice-boss-3", .theHaulout, 16.3),
        ("-ice-held-1", .frostwhiskerHeld, 1.9),
        ("-ice-held-2", .frostwhiskerHeld, 12.0),
        ("-ice-held-3", .frostwhiskerHeld, 15.6),
        ("-fen-open-1", .mirebogOpening, 4.8),
        ("-fen-open-2", .mirebogOpening, 11.9),
        ("-fen-open-3", .mirebogOpening, 15.8),
        ("-fen-boss-1", .theWallow, 2.8),
        ("-fen-boss-2", .theWallow, 9.0),
        ("-fen-boss-3", .theWallow, 15.4),
        ("-fen-held-1", .mirebogHeld, 1.9),
        ("-fen-held-2", .mirebogHeld, 7.3),
        ("-fen-held-3", .mirebogHeld, 11.3),
        ("-spire-open-1", .cloudspireOpening, 1.9),
        ("-spire-open-2", .cloudspireOpening, 14.5),
        ("-spire-open-3", .cloudspireOpening, 19.1),
        ("-spire-boss-1", .theEyrie, 3.3),
        ("-spire-boss-2", .theEyrie, 8.9),
        ("-spire-boss-3", .theEyrie, 18.3),
        ("-spire-held-1", .cloudspireHeld, 4.8),
        ("-spire-held-2", .cloudspireHeld, 8.3),
        ("-spire-held-3", .cloudspireHeld, 14.8),
        ("-spire-held-4", .cloudspireHeld, 18.7),
        ("-spire-held-5", .cloudspireHeld, 28.3),
        ("-spire-held-6", .cloudspireHeld, 31.9),
        ("-spire-held-7", .cloudspireHeld, 35.8)
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
        case toll = "-toll"
        case barnMap = "-barn-map"
        case barn = "-barn"
        case dressedBoard = "-dressed-board"
        case dressedTitle = "-dressed-title"
        case suitor = "-suitor"
        case noRoses = "-no-roses"
        case dailySuitor = "-daily-suitor"
        case universe = "-universe"
        case universeLocked = "-universe-locked"
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
                // Reconcile the full game with the App Store and then listen for anything it
                // pushes afterwards — a family member's approval, a refund, a buy made on
                // another device. The cache has already gated the first frame; this corrects it.
                FullGame.shared.watch()
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
        case .suitor:
            // River Bend part way through with Hamish already out on it: asked for a rose as
            // the board opens, so he is photographed standing on the tile the next piece of
            // the wall goes on, his line on the board over the rack and one rose gone from
            // his count. The roses are held in memory so the runner spends none.
            PuzzleView(game: .partWayThrough(), roses: .remembering(), askingHamish: true)
        case .beaten:
            PuzzleView(game: .pickedBackUp())
        case .orchard:
            PuzzleView(game: .theOrchardsBestPen())
        case .sour:
            PuzzleView(game: .applesAndSkulls())
        case .boss:
            PuzzleView(game: .theStagMeresBestPen())
        case .truffles:
            // A thicket board: the mushroom and the wilted flower stand where the apple
            // and the skull would, the same +5 and -5 dressed for the woods, on leaf
            // mould with peat pools in it rather than mud and open water.
            PuzzleView(
                level: .nettleBank,
                treatSkin: WorldTheme.thornwood.treats,
                skin: WorldTheme.thornwood.field,
                day: .forestDay,
                chrome: WorldTheme.thornwood.chrome
            )
        case .embers:
            // A mountain board: the coin and the flame stand where the apple and
            // the skull would, the same +5 and -5 dressed for the peak, on ash with
            // cinder still going in it and a tarn steaming where a mere would be.
            PuzzleView(
                level: .smoulderRidge,
                treatSkin: WorldTheme.emberpeak.treats,
                skin: WorldTheme.emberpeak.field,
                day: .emberDay,
                chrome: WorldTheme.emberpeak.chrome
            )
        case .pies:
            // A city board: the pizza and the trash can stand where the apple and the
            // skull would, the same +5 and -5 dressed for the streets, on paving,
            // with a canal for water and wrought iron for fencing.
            PuzzleView(
                level: .clocktowerSquare,
                treatSkin: WorldTheme.cogsworth.treats,
                skin: WorldTheme.cogsworth.field,
                day: .cityDay,
                chrome: WorldTheme.cogsworth.chrome
            )
        case .map:
            WorldMapView(progress: .partWayThrough())
        case .toll:
            // The meadow run out to the top and stopped there: every pen below Stag Mere
            // held, on twos and threes, and the stars still short of the twenty-one it
            // asks for. The card the map puts up in that standing is already on screen,
            // since what is being photographed is the card and not the trail behind it.
            WorldMapView(progress: .stoppedAtTheToll(), showsTollNotice: true)
        case .barnMap:
            // The fork: the orchard penned, the trail climbing on past it, and the barn
            // standing open off to one side — the one shape on any trail in the game that is
            // not a line, and the only way to photograph it is to stand a world at it.
            WorldMapView(progress: .atTheBarn())
        case .barn:
            // The barn itself, with something already on her, since an undressed pig on the
            // stand says nothing the trail does not say. The wellies rather than a hat: nine
            // of the eleven pegs are on screen under the mirror already, and the two that are
            // not are the ones worn lowest — so the shot shows the most of the barn by
            // standing one of those on the mirror, and it is the furthest-hung garment in the
            // wardrobe that most wants looking at.
            DressingBarnView(wardrobe: .remembering(.wellies))
        case .dressedBoard:
            // What the barn is for, and the half of it the barn itself cannot show: a board
            // opened by a pig who has been dressed. The outfit is not a thing she wears in
            // there — it is a thing she wears, and this is the picture that says so.
            PuzzleView(game: .partWayThrough(), wardrobe: .remembering(.topHat))
        case .dressedTitle:
            // The same again out in front of the title, which is the one pig in the game
            // painted into a canvas rather than drawn as a glyph on a board — a different
            // piece of drawing, and so worth its own photograph.
            TitleScreenView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(today: Self.photographed, includingToday: true),
                // Already offered, and held in memory. A fortnight of days behind the player is
                // exactly the standing the game's own reminder offer watches for, and a sheet
                // over the pasture is a photograph of a sheet: the pig is the whole subject here.
                reminder: .reminding(),
                today: Self.photographed,
                wardrobe: .remembering(.crown),
                rating: .neverAsked()
            )
        case .universe:
            // The meadow held, the thicket open and beckoning, and the worlds past it
            // still silhouettes — the map with something to show at every standing.
            UniverseMapView(progress: .partWayThrough())
        case .universeLocked:
            // The same map as a player sees it before they pay: the meadow held and free,
            // and every world past it for sale — each in colour with a gold lock, the
            // thicket beckoning at the head of them. Tapping any one opens the offer.
            UniverseMapView(progress: .partWayThrough(forSale: true))
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
        case .noRoses:
            // The other half of what Hamish has to say: the same bubble, with its tail on him
            // down in his corner rather than on a square, telling a player who has spent the
            // day's three roses when the next one comes. The three are handed in already
            // given, and held in memory, so the runner spends nobody's.
            PuzzleView(
                game: .partWayThrough(),
                roses: .remembering([.now, .now, .now]),
                askingHamish: true
            )
        case .dailySuitor:
            // The same day's board with Hamish asked for a rose as it opens: the proof that
            // a daily is a board he helps on like any other, off the wall its line of the
            // almanac carries. The roses are held in memory so the runner spends none.
            if let day = DailyAlmanac.level(on: Self.photographed) {
                PuzzleView(
                    game: .aDayPartWayThrough(day),
                    clock: .showing(227),
                    roses: .remembering(),
                    askingHamish: true
                )
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
                showsSettings: true,
                // Locked with a price to show, so the settings shot carries the upgrade card
                // as a player who has not bought it sees it, and nothing bought on the runner.
                fullGame: .locked(),
                rating: .neverAsked()
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
                showsReminderPrompt: true,
                rating: .neverAsked()
            )
        case .titleFresh:
            // The title screen with nothing won on it. It takes an argument of its
            // own now rather than being what a bare launch gives you, because a bare
            // launch on a device that has never been played opens the walkthrough
            // over the top of it — which is the point of the walkthrough, and no use
            // as a photograph of the title screen. The world is held in memory and
            // its tutorial already spent, so the shot is the empty title screen
            // however much the runner played before it.
            TitleScreenView(progress: .beforeTheFirstStar(), rating: .neverAsked())
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
                today: Self.photographed,
                rating: .neverAsked()
            )
        }
    }
}
