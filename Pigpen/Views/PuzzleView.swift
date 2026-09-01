import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, open the
/// gate, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Only for the words painted straight onto the grass: the meadow is pale by day and
    /// dark after dusk, so what is written on it swaps between ink and cream to stay read.
    @Environment(\.colorScheme) private var colorScheme

    /// Told what a pen was worth — its stars, whether it was the best pen the map has in
    /// it, how long it took, and the fencing that held it — every time one holds.
    ///
    /// Nothing is listening when a level is played on its own — the previews and the
    /// screenshot runs open one straight — and that is also how the screen knows whether
    /// there is somewhere behind it to offer a way back to. A daily keeps the fencing so
    /// a day opened again can offer *Put it back*.
    private let onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)?
    /// Told the board as it stands when the screen goes away, so a daily can keep the
    /// fencing even if the animals were never released. Meadow levels leave this unset —
    /// a trail stop starts from bare mud every time.
    private let onLeave: ((PuzzleGame, Stopwatch?) -> Void)?
    /// What that way back is called, and the glyph it wears. The meadow's is Continue with
    /// a signpost, because the trail is waiting; a day's is Done with a seal, because the
    /// day is finished and the title is what sits behind it.
    private let wayOutTitle: String
    private let wayOutImage: String
    /// How this world dresses its windfall and hazard, handed on to the field. Meadow levels,
    /// dailies and the tutorial keep the apple and the skull; a themed world passes its own.
    private let treatSkin: TreatSkin
    /// How this world paints the board itself — its ground, its water and its fencing. The
    /// meadow's mud and blue water are the default, and a themed world passes its own, so the
    /// mountain's board is ash with a steaming tarn in it rather than mud with a mere.
    private let skin: FieldSkin
    /// Daylight and dusk for the ground the board is cut out of. Defaults to the meadow;
    /// a themed world passes its own so the thicket sits in leaf litter rather than mowing.
    private let day: GamePalette.Pasture
    private let dusk: GamePalette.Pasture
    /// Which world this board is a stop on, and how far up its trail — and nothing at all
    /// for a board that is not on a trail.
    ///
    /// It is what counting goes by. A trail stop is counted as a level, since the whole
    /// point of the numbers is which puzzle players get stuck on; a daily is counted as a
    /// day, by the screen above this one, because its board is generated and its id would
    /// mean nothing on a chart. A preview, a screenshot run and the practice pen pass
    /// nothing and are counted as nothing, which is what they are.
    private let trail: (world: String, stop: Int)?

    @State private var game: PuzzleGame
    /// The clock over the board, counting up from the moment it opened, and `nil` for a
    /// puzzle nobody is timing. The meadow is not timed — a level there is worth going back
    /// to and taking apart — but a daily is a day's go at one board, and how long it took
    /// is part of what it was. It stops when the pen holds, resumes on going bigger, resets
    /// on starting over, and returns to the submitted time when the best pen is put back.
    @State private var clock: Stopwatch?
    /// What the clock said when the pen held, so the verdict says the same thing however
    /// long the card is left up.
    @State private var heldIn: TimeInterval?
    /// Where each animal is standing this instant, which is its own tile until the gate
    /// is opened on a pen with a gap in it.
    @State private var marks: [AnimalMark]
    /// The lap of honour on a pen that held, from the moment the gate opens until the last
    /// of the confetti is down. Nothing while the field is being built.
    @State private var celebration: Celebration?
    /// Held back until the walking is over, so the verdict lands after the action.
    @State private var showsVerdict = false
    @State private var budgetShake: CGFloat = 0
    /// Whether the press in progress has already been turned down once.
    @State private var refusedThisPress = false
    /// What a press just got back off a tile — what a treat is worth, or the noise the animal
    /// standing there makes — rising off that tile so it is found out without reading anything.
    @State private var callout: FieldCallout?
    /// How many times the gate has been opened on this board. Counted rather than shown:
    /// how many goes a level takes before it gives is the closest thing the game has to a
    /// reading of how hard it actually is, as against how hard it was meant to be.
    @State private var attempts = 0
    /// Whether the pen has held at any point on this board, so that leaving is counted as
    /// giving up only when there was nothing to give up on.
    @State private var hasHeld = false

    /// - Parameter clock: A stopwatch for a board that is being timed, and nothing at all
    ///   for one that is not. A clock handed in already stopped — `Stopwatch.showing(_:)` —
    ///   is how the screenshot runs photograph a time rather than photographing whenever
    ///   the runner got round to it.
    /// - Parameter wayOutTitle: What the button that leaves after a held pen says. The
    ///   meadow keeps the default; a day passes "Done".
    init(
        level: PuzzleLevel,
        clock: Stopwatch? = nil,
        treatSkin: TreatSkin = WorldTheme.meadow.treats,
        skin: FieldSkin = .meadow,
        day: GamePalette.Pasture = .day,
        dusk: GamePalette.Pasture = .dusk,
        wayOutTitle: String = "Continue",
        wayOutImage: String = "signpost.right.fill",
        trail: (world: String, stop: Int)? = nil,
        onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)? = nil,
        onLeave: ((PuzzleGame, Stopwatch?) -> Void)? = nil
    ) {
        self.init(
            game: PuzzleGame(level: level),
            clock: clock,
            treatSkin: treatSkin,
            skin: skin,
            day: day,
            dusk: dusk,
            wayOutTitle: wayOutTitle,
            wayOutImage: wayOutImage,
            trail: trail,
            onPenned: onPenned,
            onLeave: onLeave
        )
    }

    /// Opens the screen on a puzzle already in progress, which is how the previews and the
    /// screenshot runs show a field with fencing on it.
    init(
        game: PuzzleGame,
        clock: Stopwatch? = nil,
        treatSkin: TreatSkin = WorldTheme.meadow.treats,
        skin: FieldSkin = .meadow,
        day: GamePalette.Pasture = .day,
        dusk: GamePalette.Pasture = .dusk,
        wayOutTitle: String = "Continue",
        wayOutImage: String = "signpost.right.fill",
        trail: (world: String, stop: Int)? = nil,
        onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)? = nil,
        onLeave: ((PuzzleGame, Stopwatch?) -> Void)? = nil
    ) {
        self.onPenned = onPenned
        self.onLeave = onLeave
        self.treatSkin = treatSkin
        self.skin = skin
        self.day = day
        self.dusk = dusk
        self.wayOutTitle = wayOutTitle
        self.wayOutImage = wayOutImage
        self.trail = trail
        _game = State(initialValue: game)
        _marks = State(initialValue: .standing(on: game.level))
        _clock = State(initialValue: clock)
    }

    private var level: PuzzleLevel { game.level }

    /// What the screen calls whatever it is holding: the pig on every map but the last,
    /// where a stag stands on the other shore.
    private var quarry: String {
        level.holdsAHerd ? "the animals" : "the \(level.animals[0].kind.name)"
    }

    /// How deep the pen's wash goes. Fencing that closes colours the pen in straight away;
    /// opening the gate and watching nothing find a way out takes it the rest of the way.
    private var penGlow: Double {
        if game.penTiles.isEmpty {
            0
        } else if game.isBuilding {
            0.8
        } else {
            1
        }
    }

    var body: some View {
        ZStack {
            MeadowBackdrop(day: day, dusk: dusk)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                bossOrders
                    .padding(.horizontal, 16)

                FenceRack(
                    used: game.fences.count,
                    budget: level.fenceBudget,
                    shake: budgetShake
                )
                .padding(.horizontal, 16)

                Spacer(minLength: 0)

                FieldView(
                    level: level,
                    fences: game.fences,
                    penTiles: game.penTiles,
                    penGlow: penGlow,
                    isAsGoodAsItGets: game.isPenAsGoodAsItGets,
                    animals: marks,
                    celebration: celebration,
                    callout: callout,
                    onCalloutFinished: { id in
                        if callout?.id == id { callout = nil }
                    },
                    treatSkin: treatSkin,
                    skin: skin,
                    onStroke: { build($0) },
                    onStrokeEnd: { game.endStroke() }
                )
                // Standing on the meadow rather than pasted onto it.
                .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                // The board is the screen, so it is given all the width there is to give.
                .padding(.horizontal, 6)

                fieldCorrections
                    // Right aligned to the same margin the button below keeps, so the row of
                    // glyphs and the end of the button stand on one line.
                    .padding(.horizontal, 16)
                    .opacity(showsVerdict ? 0 : 1)
                    .allowsHitTesting(!showsVerdict)

                Spacer(minLength: 0)

                Group {
                    if showsVerdict {
                        verdict
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        buildingControls
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
            }
            // The rack is the first thing under the title bar, so it is given room to stand
            // clear of it rather than being pressed up against the bar's underside.
            .padding(.top, 14)
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .fieldNavigationBar()
        .keepsSwipeFromPopping()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { clockFace }
        }
        .onAppear {
            clock?.start()
            if let trail {
                Analytics.record(.levelOpened(level, world: trail.world, stop: trail.stop))
            }
        }
        .onDisappear {
            onLeave?(game, clock)
            // A board walked away from without ever holding, and the goes they had at it
            // first. The pair is the difference between a puzzle that beat somebody and
            // one they took a look at and thought better of.
            if trail != nil, !hasHeld {
                Analytics.record(.levelLeftUnheld(level, attempts: attempts))
            }
        }
        .task(id: game.phase) { await reactToPhase() }
    }

    /// Undo, redo and clear, tucked under the right-hand corner of the board.
    ///
    /// No plaques: three glyphs painted straight onto the grass, the way the tally beneath
    /// them is, so that the only thing on this screen wearing a button's clothes is the
    /// button that ends the turn — and each keeps a finger's worth of room around it
    /// whatever the glyph inside is doing.
    ///
    /// They fade rather than vanish when the verdict is up: the card below covers what they
    /// act on, and a row that came and went would move the board it is pinned to.
    private var fieldCorrections: some View {
        HStack(spacing: 2) {
            Spacer(minLength: 0)

            fieldIcon("Undo", systemImage: "arrow.uturn.backward", enabled: game.canUndo) {
                game.undo()
            }
            .keyboardShortcut("z", modifiers: .command)

            fieldIcon("Redo", systemImage: "arrow.uturn.forward", enabled: game.canRedo) {
                game.redo()
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])

            fieldIcon("Clear the field", systemImage: "trash", enabled: game.canClearField) {
                game.startOver()
            }
        }
    }

    /// The clock, up in the bar with the day's name rather than down on the board: it is
    /// something to glance at afterwards, not something to play against. It stops while
    /// the pen holds and the card is up, and picks up again if the player goes back out.
    @ViewBuilder
    private var clockFace: some View {
        if let clock {
            StopwatchFace(clock: clock)
        }
    }

    // MARK: - Pieces

    /// The button that ends the turn, with the whole width of the screen to itself, and what
    /// the field has already been held for underneath it.
    ///
    /// Undo, redo and clear used to stand beside it and take three quarters of the row. They
    /// are corrections rather than the move, so they have gone up under the board as plain
    /// glyphs and the one button that finishes a go is now the only thing down here that
    /// looks like a button. The best pen sits below rather than above it, since it is the
    /// last thing to appear and has something to say only once a pen has closed.
    private var buildingControls: some View {
        VStack(spacing: 10) {
            Button {
                attempts += 1
                game.openTheGate()
            } label: {
                Text("Release \(quarry)")
                    .font(.headline.weight(.heavy))
                    // Cream lettering, because the face under it is the chrome's own
                    // terracotta rather than the pen's gold.
                    .foregroundStyle(GamePalette.cream)
                    // Two animals make for a longer button than one; it shrinks its
                    // lettering rather than growing a second line and moving the board.
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
            }
            // The same painted button the offer buys the game with: it stands on a ledge of
            // its own shadow and sinks onto it when pressed. This is the one press on the
            // screen that ends a go, so it is the one that is worth hitting.
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
            // Live on an empty field too. Opening the gate with nothing in the ground is a
            // legal go — the pig walks straight off the map and the verdict says so — and a
            // button greyed out until some unstated amount of work is done says less about
            // the rule than watching the pig leave does.
            .disabled(!game.isBuilding)

            bestPenTally
        }
        .animation(.easeInOut(duration: 0.25), value: game.bestScore)
        .animation(.easeInOut(duration: 0.25), value: game.canRestoreBestPen)
    }

    /// The rule this world's boss adds, on a small painted board above the rack — the first
    /// thing under the title bar, and the strip of grass every other level leaves empty.
    ///
    /// A boss is the one field in a world whose rule the ground cannot show: water walls a pen
    /// and an apple says what it is worth, but nothing on the board says the deer has to be
    /// held too. The briefing says it once before the field opens; this says it for as long as
    /// the field is up, so a player who tapped past that film, or who came back a week later to
    /// better a two-star pen, is never building against a rule they have to remember. Every
    /// other level shows nothing here, because there is nothing to add.
    ///
    /// It reads top down rather than left to right: a heading naming the thing, and the rule
    /// under it. The animal used to stand at the front of it as a glyph, which said the same
    /// thing the board below was already saying in the round — so the heading says what this
    /// is instead, which is the one thing neither the board nor the film ever says.
    @ViewBuilder
    private var bossOrders: some View {
        if let orders = level.orders {
            VStack(alignment: .leading, spacing: 2) {
                Text("What to do")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(GamePalette.post.opacity(0.55))
                    .textCase(.uppercase)

                Text(orders)
                    .font(.subheadline)
                    .foregroundStyle(GamePalette.post.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                GamePalette.cream.opacity(0.95),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("What to do on this level. \(orders)")
        }
    }

    /// What the field is holding, set against the most it has held, and the way back to it.
    /// A pen counts from the moment it closes, so the fencing can be pulled about, seen to
    /// fall short, and put back the way it was without the pig ever leaving its tile. Undo
    /// walks back a press at a time; this goes straight to the best, however long ago it was,
    /// which is why it wears the trophy rather than an arrow.
    ///
    /// Only the score, never the stars: stars are what the gate being opened pays out, so
    /// they are kept for the verdict card and the player has to release the pig to see them.
    /// On a level gone back to, the best is the one already won there rather than one closed
    /// this go, so the board still opens with the tally up — what there is to beat, before a
    /// single piece is laid.
    @ViewBuilder
    private var bestPenTally: some View {
        // The row is always laid out and only ever fades, so the button above it is standing
        // where it will stand all game before there is anything down here to say. Building it
        // the other way — putting the row in when the first pen closes — moved the one button
        // the player is aiming at, at the exact moment they had just been rewarded for
        // aiming at it.
        //
        // Height is the whole of what has to be held, so height is the only thing held: a
        // plaque nobody can see or touch stands in the stack and gives the row the height it
        // will have when a real one is in it. Reserving the width as well would have kept an
        // empty plaque's worth of room to the right of the tally and pushed the writing off
        // centre for the whole of a first go.
        ZStack {
            restorePlaque
                .hidden()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            HStack(spacing: 10) {
                Text(tallySummary)
                    .font(.footnote.weight(.heavy))
                    // Written straight onto the grass, so it is painted rather than
                    // printed — in ink on the pale daytime meadow, in cream with a shadow
                    // once the ground has gone dark.
                    .foregroundStyle(
                        colorScheme == .dark ? GamePalette.cream : GamePalette.post
                    )
                    .shadow(
                        color: .black.opacity(colorScheme == .dark ? 0.45 : 0),
                        radius: 3,
                        y: 1
                    )
                    .contentTransition(.numericText())
                    // Sits on one line beside the button rather than pushing it off the
                    // screen when the type is large.
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if game.canRestoreBestPen {
                    restorePlaque
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .opacity(game.bestScore > 0 ? 1 : 0)
        .accessibilityHidden(game.bestScore == 0)
    }

    /// The way back to the best pen this board has held, which is also the tallest thing the
    /// tally row ever carries — so it doubles as the row's own measure.
    private var restorePlaque: some View {
        Button { putBestPenBack() } label: {
            Label("Restore", systemImage: "clock.arrow.circlepath")
                .font(.footnote.weight(.heavy))
        }
        .buttonStyle(PlaqueButtonStyle(padding: 6))
        .accessibilityLabel("Restore your best pen, \(scored(game.bestScore))")
    }

    /// Reads out the best pen being kept, and what the fencing holds now when that is
    /// something other than the best.
    private var tallySummary: String {
        guard let holding = game.penTally?.score else {
            return "Best so far: \(scored(game.bestScore))"
        }
        return holding >= game.bestScore
            ? "Your best yet: \(scored(holding))"
            : "Holding \(holding), best \(game.bestScore)"
    }

    /// One of the small painted glyphs that work the fencing already down. A button with
    /// nothing to do fades rather than vanishing, so the three of them never move about.
    private func fieldIcon(
        _ title: String,
        systemImage: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            Haptics.tap(.soft)
        } label: {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.system(size: 17, weight: .heavy))
                // Painted straight onto the grass, the way the tally below is: ink on the
                // pale daytime meadow, and cream with a dark halo once the ground has gone
                // dark — the halo is what carries a light glyph clear of a dark green.
                .foregroundStyle(colorScheme == .dark ? GamePalette.cream : GamePalette.post)
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.8 : 0), radius: 2)
                .shadow(
                    color: .black.opacity(colorScheme == .dark ? 0.5 : 0),
                    radius: 6,
                    y: 2
                )
                .opacity(enabled ? 1 : 0.35)
                // One box for all three, so a wider glyph does not make a wider button — and
                // wider than the glyph needs, so a thumb has something to land on without
                // three plaques' worth of the board being spent on it.
                .frame(width: 42, height: 38)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var verdict: some View {
        switch game.phase {
        case .escaped(let escapes):
            verdictCard(
                headline: escapedHeadline(escapes),
                detail: escapedDetail(escapes),
                tint: GamePalette.barn
            ) {
                Button { game.resumeBuilding() } label: {
                    Label("Keep building", systemImage: "hammer")
                }
                .buttonStyle(.borderedProminent)
            }
        case .penned(let pen):
            verdictCard(
                headline: game.isPenAsGoodAsItGets ? "The best pen there is" : "Moved in",
                detail: pennedDetail(tally: level.tally(for: pen)),
                tint: GamePalette.clover
            ) {
                pennedActions
            }
        case .refused(_, let refusal):
            verdictCard(
                headline: refusedHeadline(refusal),
                detail: refusedDetail(refusal),
                tint: GamePalette.barn
            ) {
                Button { game.resumeBuilding() } label: {
                    Label("Keep building", systemImage: "hammer")
                }
                .buttonStyle(.borderedProminent)
            }
        case .building:
            EmptyView()
        }
    }

    /// What a field says when the fencing holds everything and the board still will not have
    /// it: the two that will not share are in one pen, or the one that had to stay out is in.
    private func refusedHeadline(_ refusal: Refusal) -> String {
        switch refusal {
        case .together(let animal): "The \(animal.name) wants its own place"
        case .apart(let animal): "The \(animal.name) will not live alone"
        case .uneven(let animal): "The \(animal.name) got the smaller place"
        case .split(let animal): "The \(animal.name) is on its own"
        case .shutIn(let animal): "The \(animal.name) came with the place"
        case .beside: "Pig is next door, not around"
        case .tooClose: "Too close for comfort"
        case .landlocked(let animal): "No water for the \(animal.name)"
        case .parched(let animal): "The \(animal.name) is sharing the water"
        case .spotted: "Pig has no privacy"
        }
    }

    private func refusedDetail(_ refusal: Refusal) -> String {
        switch refusal {
        case .together(let animal):
            "Both of them have a place, but it is the same place. The \(animal.name) wants its own."
        case .apart(let animal):
            "Both of them have a place, but one each. The \(animal.name) goes where Pig goes."
        case .uneven(let animal):
            "Both of them have a place, but one is bigger. The \(animal.name) wants ground to match Pig's."
        case .split(let animal):
            "Everything is held, but the roost is split between two places. The \(animal.name) lives where the other bat lives."
        case .shutIn(let animal):
            "Pig has a place, and the \(animal.name) is on it. Leave that one outside the fence."
        case .beside(let animal):
            "Both of them have a place, but side by side. Pig's ground has to go the whole way round the \(animal.name) — and it is ground she walks, so she needs a clear path the whole way round, with nothing she cannot cross breaking it."
        case .tooClose(let animal):
            "Both of them have a place, but one wall does for both — and a \(animal.name) stings straight through a fence. Leave clear ground between them."
        case .landlocked(let animal):
            "Both of them have a place, but the \(animal.name)'s never touches the water. He keeps a breathing hole, so his ground has to lie against it."
        case .parched(let animal):
            "Both of them have a place, but no channel is wholly the \(animal.name)'s. Every bank of one channel has to be his own ground — half a wallow is nobody's."
        case .spotted(let animal):
            "The pen is shut, but the \(animal.name) can see into it. He looks along his row and his column, and only a fence blocks the view — a wall of the pen's own, or one piece planted in his way."
        }
    }

    /// A pen that can still be widened sends the player back out to try; one that cannot
    /// leaves nothing to do but take the field again from scratch. A board opened from
    /// somewhere — the meadow, or today's puzzle — has one more way out of both: back to
    /// wherever opened it. What that button says is the caller's: Continue for the trail,
    /// Done for a day.
    @ViewBuilder
    private var pennedActions: some View {
        if onPenned == nil {
            if game.isPenAsGoodAsItGets {
                startOver.buttonStyle(.borderedProminent)
            } else {
                HStack(spacing: 10) {
                    startOver.buttonStyle(.bordered)
                    goBigger.buttonStyle(.borderedProminent)
                }
            }
        } else {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    startOver.buttonStyle(.bordered)
                    if !game.isPenAsGoodAsItGets {
                        goBigger.buttonStyle(.bordered)
                    }
                }

                Button { dismiss() } label: {
                    Label(wayOutTitle, systemImage: wayOutImage)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var startOver: some View {
        Button {
            // A fresh field is a fresh clock: the time of the pen just left behind is kept
            // in the day's record, not on the face.
            clock?.reset()
            heldIn = nil
            game.startOver()
        } label: {
            Label("Start over", systemImage: "arrow.counterclockwise")
        }
    }

    private var goBigger: some View {
        Button {
            // The lap of honour was not on the clock; going back out to widen the pen is.
            clock?.resume()
            game.resumeBuilding()
        } label: {
            Label("Go bigger", systemImage: "arrow.up.left.and.arrow.down.right")
        }
    }

    /// Who got out, which on a boss map may be one of the two rather than both.
    private func escapedHeadline(_ escapes: [Escape]) -> String {
        guard escapes.count == 1 else { return "They both walked out" }
        return "The \(escapes[0].animal.kind.name) walked out"
    }

    private func escapedDetail(_ escapes: [Escape]) -> String {
        guard escapes.count == 1 else {
            return "Both of them found a gap and showed themselves out. Follow the trails and close them."
        }
        guard level.holdsAHerd else {
            return "It found a gap and showed itself out. Follow the trail and close it."
        }
        return "It found a gap and showed itself out while the other stayed put — and both of them need a place. Follow the trail and close it."
    }

    /// What the pen came to, under the verdict.
    ///
    /// A pen that can still be bettered gets the whole account of itself: the ground, what it
    /// cost, what was standing on it and how that came out — because every one of those is a
    /// thing the next go could change. A pen there is nothing above gets one line, because
    /// there is no next go to inform. The card already says "The best pen there is" over the
    /// top of it; spending three more sentences on the arithmetic behind a verdict the player
    /// has just been given is reading them the receipt for a thing they have already won.
    private func pennedDetail(tally: PenTally) -> String {
        var detail: String

        if game.isPenAsGoodAsItGets {
            detail = "The biggest lot on this map — \(scored(tally.score))."
        } else {
            detail = "\(counted(tally.area, "mud tile")) held with \(counted(game.fences.count, "fence piece"))"
            if let spoils = spoils(in: tally) {
                detail += ", and \(spoils) shut in with \(quarry) — \(counted(tally.score, "point"))."
            } else {
                detail += "."
            }
        }

        if let heldIn {
            detail += " \(Stopwatch.face(heldIn)) on the clock."
        }

        guard !game.isPenAsGoodAsItGets, game.bestScore > tally.score else { return detail }
        return detail + " Your best so far is \(game.bestScore)."
    }

    /// What a pen caught besides ground: windfall worth having in it, hazards worth keeping out —
    /// named the way this world names them, an apple and a skull or a mushroom and a wilted flower.
    private func spoils(in tally: PenTally) -> String? {
        var caught: [String] = []
        if tally.apples > 0 { caught.append(counted(tally.apples, treatSkin.name(for: .apple))) }
        if tally.skulls > 0 { caught.append(counted(tally.skulls, treatSkin.name(for: .skull))) }
        return caught.isEmpty ? nil : caught.joined(separator: " and ")
    }

    /// A score reads as ground on a map with nothing lying about on it, since that is all
    /// it counts, and as points on one where an apple or a skull is worth more or less than
    /// the tile it sits on.
    private func scored(_ score: Int) -> String {
        counted(score, level.holdsTreats ? "point" : "mud tile")
    }

    private func counted(_ number: Int, _ noun: String) -> String {
        "\(number) \(noun)\(number == 1 ? "" : "s")"
    }

    /// The verdict, on a painted board nailed up over the field: the same cream the rack and
    /// the signposts are painted on, so the last word on a pen looks like it was written by
    /// the same hand that made the level.
    private func verdictCard<Actions: View>(
        headline: String,
        detail: String,
        tint: Color,
        @ViewBuilder actions: () -> Actions
    ) -> some View {
        VStack(spacing: 8) {
            if let stars = game.starRating {
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= stars ? "star.fill" : "star")
                            .foregroundStyle(
                                star <= stars ? GamePalette.pen : GamePalette.post.opacity(0.3)
                            )
                    }
                }
                .font(.title3)
                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
            }

            Text(headline)
                .font(.title3.weight(.black))
                .foregroundStyle(tint)

            Text(detail)
                .font(.footnote.weight(.medium))
                .foregroundStyle(GamePalette.post.opacity(0.78))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            actions()
                .tint(GamePalette.rail)
                .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(GamePalette.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.22), radius: 7, y: 4)
    }

    // MARK: - Actions

    /// Works one tile of a press: the tile a tap landed on, or each tile a drag reaches.
    private func build(_ stroke: FenceStroke) {
        if stroke.isFirst {
            refusedThisPress = false
            // Whatever the press goes on to do to the field, it undoes in one go.
            game.beginStroke()
        }

        switch stroke.mode {
        case .building:
            // Dragging back over your own fencing is not a refusal, it is just nothing to do.
            guard !game.fences.contains(stroke.tile) else { return }
            guard game.buildFence(on: stroke.tile) else {
                // No treat takes fencing, so a tap that would have planted a post says what
                // the tile is worth instead of shaking the rack like a spent budget. On an
                // apple that is the whole lesson in one tap: the ground is not refusing the
                // player, it is telling them there are five points here to shut in.
                if let treat = level.treat(at: stroke.tile) {
                    say(treat.pointsSaid, at: stroke.tile)
                } else if let animal = level.animals.first(where: { $0.tile == stroke.tile }) {
                    // Nor does an animal, and an animal can answer for itself: it hops where
                    // it stands and calls back, rather than the rack shaking at a player who
                    // has done nothing wrong but tap the pig.
                    greet(animal.kind, at: stroke.tile)
                } else {
                    refuse()
                }
                return
            }
            Haptics.tap(.rigid)
        case .clearing:
            guard game.clearFence(on: stroke.tile) else { return }
            Haptics.tap(.light)
        }
    }

    /// Puts the fencing back the way it stood on the best pen of the session, and — when
    /// a time was submitted for a pen that held — puts the clock back to that time too,
    /// so a rearrangement that was given up does not stay charged. The soft knock is the
    /// same one the other buttons that work the fencing already down give.
    private func putBestPenBack() {
        guard game.restoreBestPen() else { return }
        if let heldIn {
            clock?.setElapsed(heldIn)
        }
        Haptics.tap(.soft)
    }

    /// Says no to a tile the map or the budget will not take, once per press: a finger
    /// dragged across the field on a spent budget should not shake the counter at every tile.
    private func refuse() {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        withAnimation(.easeInOut(duration: 0.4)) { budgetShake += 1 }
        Haptics.buzz(.warning)
    }

    /// Floats a word off the tile a finger just landed on, once per press: a drag that
    /// crosses two treats should not stack the same five points twice, and one that crosses
    /// the pig and the deer should not have them both shouting at once.
    private func say(_ words: String, at tile: GridPoint) {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        callout = FieldCallout(tile: tile, said: words)
        Haptics.tap(.soft)
        UIAccessibility.post(notification: .announcement, argument: words)
    }

    /// What a press on an animal gets: its own noise off its own tile, and a hop where it
    /// stands. It is the one thing on the board that can answer a finger, and answering is
    /// all it does — an animal is never moved, fenced or scored by being tapped.
    private func greet(_ kind: Animal, at tile: GridPoint) {
        let alreadyAnswered = refusedThisPress
        say(kind.call, at: tile)
        guard !alreadyAnswered, !reduceMotion else { return }
        hop(kind)
    }

    /// Takes one animal off the ground and puts it back down: up fast, and down on a looser
    /// spring, which is the shape of a hop rather than a bounce.
    private func hop(_ kind: Animal) {
        guard let index = marks.firstIndex(where: { $0.kind == kind }) else { return }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) { marks[index].hop = 1 }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.16)) {
            marks[index].hop = 0
        }
    }

    /// Plays out whatever the game just decided: the walk to freedom, or the lap of honour
    /// on a pen that held. The verdict card waits until the animation is done.
    private func reactToPhase() async {
        switch game.phase {
        case .building:
            // The tiles snap back rather than animating, so nothing is seen trotting home
            // from the edge of the map; only the fading back in is played.
            celebration = nil
            sendHome()
            withAnimation(.easeOut(duration: 0.25)) {
                showsVerdict = false
                showEveryone()
            }
        case .escaped(let escapes):
            if trail != nil {
                Analytics.record(.levelEscaped(level, attempt: attempts))
            }
            // Bail if the phase changed under us (clearing the field, fetching them back):
            // otherwise the walk keeps stepping after sendHome and leaves a deer painted
            // on the grass outside the board.
            guard await walk(escapes) else { return }
            guard !Task.isCancelled else { return }
            reveal()
            Haptics.buzz(.error)
        case .refused(_, let refusal):
            // Which rule was broken rather than only that one was: a briefing nobody takes
            // in reads on the charts as the same refusal over and over on the same board.
            if trail != nil {
                Analytics.record(.levelRefused(level, refusal: refusal, attempt: attempts))
            }
            // Nothing walks anywhere — everything is where it was fenced. The card says what
            // the board wanted instead, and no clock is stopped and no score is told, since
            // the field is not won.
            guard !Task.isCancelled else { return }
            reveal()
            Haptics.buzz(.error)
        case .penned(let pen):
            // The clock stops on the pen holding rather than on the card coming up, so the
            // lap of honour is not charged to the player.
            clock?.stop()
            let took = clock?.elapsed() ?? 0
            if clock != nil { heldIn = took }
            let verdict = game.verdict ?? PenVerdict(stars: 1, isAsGoodAsItGets: false)
            hasHeld = true
            // Counted before the celebrating for the same reason it is told to whoever is
            // keeping score before it: a player who leaves the moment the pen holds has
            // still held it.
            if trail != nil {
                Analytics.record(
                    .levelHeld(
                        level,
                        verdict: verdict,
                        score: level.tally(for: pen).score,
                        pieces: game.fences.count,
                        attempts: attempts,
                        seconds: clock == nil ? nil : took
                    )
                )
            }
            // Told to whoever is keeping score before any of the celebrating, so a player
            // who leaves the moment the pen holds still keeps the stars for it.
            onPenned?(verdict, took, game.fences)
            // Whatever a cancelled escape walk left behind, the board about to be
            // celebrated on has every animal home and in plain view: a mark left past the
            // rim would otherwise stand outside the pen, and one left faded out would run
            // its lap invisibly, since a celebration poses a mark but still draws it at
            // the mark's own opacity.
            sendHome()
            showEveryone()
            await celebrate()
        }
    }

    /// The animals' turn on a pen that holds: a lap round the ground they are shut into,
    /// a hop to finish on, and confetti over the lot of it. The verdict card waits for the
    /// hopping to stop and then comes up through the last of the confetti.
    ///
    /// A player who would rather the board kept still gets the beat of nothing the pen's
    /// wash used to have to itself, and no confetti.
    private func celebrate() async {
        guard !reduceMotion else {
            guard await Task.pausing(for: .milliseconds(350)) else { return }
            reveal()
            Haptics.buzz(.success)
            return
        }

        let cheer = Celebration(laps: game.victoryLaps, start: .now)
        celebration = cheer

        guard await cheer.waitOut() else { return }
        reveal()
        Haptics.buzz(.success)

        await cheer.waitForTheConfetti()
        celebration = nil
    }

    /// Walks everything that got out along its own route and off the edge of the map. Two
    /// animals leave at the same pace and each one fades as it takes its last step, so a
    /// short way out is a quick exit rather than a wait for the other one to finish.
    ///
    /// Returns whether the walk ran to the end. A cancelled task — the field cleared or
    /// the animals fetched back mid-stride — must not keep stepping, or a mark is left
    /// standing one tile past the rim after sendHome has already brought it home.
    private func walk(_ escapes: [Escape]) async -> Bool {
        let longest = escapes.map(\.route.count).max() ?? 0
        guard longest > 1 else { return true }

        for step in 1..<longest {
            withAnimation(.easeInOut(duration: 0.2)) {
                for escape in escapes where step < escape.route.count {
                    move(escape.animal.kind, to: escape.route[step])
                }
            }
            guard await Task.pausing(for: .milliseconds(220)) else { return false }

            withAnimation(.easeIn(duration: 0.35)) {
                for escape in escapes where step == escape.route.count - 1 {
                    vanish(escape.animal.kind)
                }
            }
        }
        return await Task.pausing(for: .milliseconds(350))
    }

    private func move(_ kind: Animal, to tile: GridPoint) {
        guard let index = marks.firstIndex(where: { $0.kind == kind }) else { return }
        marks[index].tile = tile
    }

    /// Puts every animal back on the tile the map starts it on.
    private func sendHome() {
        for animal in level.animals {
            move(animal.kind, to: animal.tile)
        }
    }

    private func vanish(_ kind: Animal) {
        guard let index = marks.firstIndex(where: { $0.kind == kind }) else { return }
        marks[index].opacity = 0
    }

    /// Brings every animal back into view. Walking off the map is the only thing that ever
    /// fades one out, so this is what undoes it.
    private func showEveryone() {
        for index in marks.indices {
            marks[index].opacity = 1
        }
    }

    private func reveal() {
        withAnimation(.spring(duration: 0.35)) { showsVerdict = true }
    }
}

/// The clock a timed board wears in its bar: a stopwatch and a count that only exists
/// while it is running.
///
/// A clock is the one thing in this game that has to be redrawn on its own account, so it
/// is the one thing given a timeline of its own — and only while it is going. Once the pen
/// holds, the time is a fixed number and the view goes back to being a piece of text.
private struct StopwatchFace: View {
    let clock: Stopwatch

    var body: some View {
        if clock.isRunning {
            TimelineView(.periodic(from: clock.started ?? Date(), by: 1)) { timeline in
                face(clock.elapsed(at: timeline.date))
            }
        } else {
            face(clock.elapsed())
        }
    }

    private func face(_ seconds: TimeInterval) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "stopwatch")
                .font(.system(size: 12, weight: .black))
            Text(Stopwatch.face(seconds))
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(GamePalette.cream)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time on the clock, \(Stopwatch.spoken(seconds))")
    }
}

#Preview("A fresh field") {
    NavigationStack {
        PuzzleView(level: .riverBend)
    }
}

#Preview("Part way through") {
    NavigationStack {
        PuzzleView(game: .partWayThrough())
    }
}

#Preview("A level already held") {
    NavigationStack {
        PuzzleView(game: .pickedBackUp())
    }
}

#Preview("Apples and skulls") {
    NavigationStack {
        PuzzleView(level: .sourGround)
    }
}

#Preview("The boss") {
    NavigationStack {
        PuzzleView(level: .stagMere)
    }
}

#Preview("On the clock") {
    NavigationStack {
        PuzzleView(game: .partWayThrough(), clock: Stopwatch())
    }
}
