import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, open the
/// gate, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Told what a pen was worth — its stars, whether it was the best pen the map has in
    /// it, how long it took, and the fencing that held it — every time one holds.
    ///
    /// Nothing is listening when a level is played on its own — the previews and the
    /// screenshot runs open one straight — and that is also how the screen knows whether
    /// there is somewhere behind it to offer a way back to. A daily keeps the fencing so
    /// a day opened again can offer *Put it back*.
    private let onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)?
    /// What that way back is called, and the glyph it wears. The meadow's is Continue with
    /// a signpost, because the trail is waiting; a day's is Done with a seal, because the
    /// day is finished and the title is what sits behind it.
    private let wayOutTitle: String
    private let wayOutImage: String

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
    /// What a tap on a treat just said — five more for an apple, five fewer for a skull —
    /// rising off that tile so the cost is found out without reading anything.
    @State private var worthCallout: WorthCallout?

    /// - Parameter clock: A stopwatch for a board that is being timed, and nothing at all
    ///   for one that is not. A clock handed in already stopped — `Stopwatch.showing(_:)` —
    ///   is how the screenshot runs photograph a time rather than photographing whenever
    ///   the runner got round to it.
    /// - Parameter wayOutTitle: What the button that leaves after a held pen says. The
    ///   meadow keeps the default; a day passes "Done".
    init(
        level: PuzzleLevel,
        clock: Stopwatch? = nil,
        wayOutTitle: String = "Continue",
        wayOutImage: String = "signpost.right.fill",
        onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)? = nil
    ) {
        self.init(
            game: PuzzleGame(level: level),
            clock: clock,
            wayOutTitle: wayOutTitle,
            wayOutImage: wayOutImage,
            onPenned: onPenned
        )
    }

    /// Opens the screen on a puzzle already in progress, which is how the previews and the
    /// screenshot runs show a field with fencing on it.
    init(
        game: PuzzleGame,
        clock: Stopwatch? = nil,
        wayOutTitle: String = "Continue",
        wayOutImage: String = "signpost.right.fill",
        onPenned: ((PenVerdict, TimeInterval, Set<GridPoint>) -> Void)? = nil
    ) {
        self.onPenned = onPenned
        self.wayOutTitle = wayOutTitle
        self.wayOutImage = wayOutImage
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
            MeadowBackdrop()
                .ignoresSafeArea()

            VStack(spacing: 12) {
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
                    worthCallout: worthCallout,
                    onWorthCalloutFinished: { id in
                        if worthCallout?.id == id { worthCallout = nil }
                    },
                    onStroke: { build($0) },
                    onStrokeEnd: { game.endStroke() }
                )
                // Standing on the meadow rather than pasted onto it.
                .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                // The board is the screen, so it is given all the width there is to give.
                .padding(.horizontal, 6)

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
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .fieldNavigationBar()
        .keepsSwipeFromPopping()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { clockFace }
        }
        .onAppear { clock?.start() }
        .task(id: game.phase) { await reactToPhase() }
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

    /// Undo, redo and clear sit to the left of the button that ends the turn, small and
    /// always in the same place so the board keeps the room and the thumb learns where
    /// they are. Each greys out rather than vanishing when there is nothing for it to do.
    /// The tally of the best pen sits above them, since it has something to say only once
    /// a pen has closed.
    private var buildingControls: some View {
        VStack(spacing: 10) {
            bestPenTally

            HStack(spacing: 10) {
                fieldButton("Undo", systemImage: "arrow.uturn.backward", enabled: game.canUndo) {
                    game.undo()
                }
                .keyboardShortcut("z", modifiers: .command)

                fieldButton("Redo", systemImage: "arrow.uturn.forward", enabled: game.canRedo) {
                    game.redo()
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])

                fieldButton("Clear the field", systemImage: "trash", enabled: !game.fences.isEmpty) {
                    game.startOver()
                }

                Button {
                    game.openTheGate()
                } label: {
                    Text("Release \(quarry)")
                        .font(.headline.weight(.heavy))
                        // Two animals make for a longer button than one; it shrinks its
                        // lettering rather than growing a second line and moving the board.
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(GamePalette.rail)
                .disabled(game.fences.isEmpty)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: game.bestScore)
        .animation(.easeInOut(duration: 0.25), value: game.canRestoreBestPen)
    }

    /// What the field is holding, set against the most it has held, and the way back to it.
    /// A pen counts from the moment it closes, so the fencing can be pulled about, seen to
    /// fall short, and put back the way it was without the pig ever leaving its tile.
    /// Undo walks back a press at a time; this goes straight to the best, however long ago
    /// it was, which is why it wears the trophy rather than an arrow.
    @ViewBuilder
    private var bestPenTally: some View {
        if game.bestScore > 0 {
            HStack(spacing: 10) {
                Text(tallySummary)
                    .font(.footnote.weight(.heavy))
                    // Written straight onto the grass, so it is painted rather than printed.
                    .foregroundStyle(GamePalette.cream)
                    .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
                    .contentTransition(.numericText())
                    // Sits on one line beside the button rather than pushing it off the
                    // screen when the type is large.
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if game.canRestoreBestPen {
                    Button { putBestPenBack() } label: {
                        Label("Put it back", systemImage: "trophy")
                            .font(.footnote.weight(.heavy))
                    }
                    .buttonStyle(PlaqueButtonStyle(padding: 6))
                    .accessibilityLabel(
                        "Put the fencing back to your best pen, \(scored(game.bestScore))"
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .transition(.opacity)
        }
    }

    /// Reads out the best pen of the session, and what the fencing holds now when that is
    /// something other than the best.
    private var tallySummary: String {
        guard let holding = game.penTally?.score else {
            return "Best so far: \(scored(game.bestScore))"
        }
        return holding >= game.bestScore
            ? "Your best yet: \(scored(holding))"
            : "Holding \(holding), best \(game.bestScore)"
    }

    /// One of the small painted boards that work the fencing already down. A button with
    /// nothing to do fades rather than vanishing, so the three of them never move about.
    private func fieldButton(
        _ title: String,
        systemImage: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.body.weight(.heavy))
                // One box for all three, so a wider glyph does not make a wider button.
                .frame(width: 24, height: 24)
                // The glyph fades, not the board it is painted on: a see-through plaque
                // would only pick up the colour of the grass behind it.
                .opacity(enabled ? 1 : 0.3)
        }
        .buttonStyle(PlaqueButtonStyle())
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
                headline: game.isPenAsGoodAsItGets ? "The best pen there is" : "Penned in",
                detail: pennedDetail(tally: level.tally(for: pen)),
                tint: GamePalette.clover
            ) {
                pennedActions
            }
        case .building:
            EmptyView()
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

    /// Who got out, which on the meadow's last map may be one of the two rather than both.
    private func escapedHeadline(_ escapes: [Escape]) -> String {
        guard escapes.count == 1 else { return "They both got out" }
        return "The \(escapes[0].animal.kind.name) got out"
    }

    private func escapedDetail(_ escapes: [Escape]) -> String {
        guard escapes.count == 1 else {
            return "Both of them found a way to the edge of the map. Follow the trails and close the gaps."
        }
        guard level.holdsAHerd else {
            return "It found a way to the edge of the map. Follow its trail and close the gap."
        }
        return "It found a way to the edge of the map while the other stayed put — and both of them have to be held. Follow its trail and close the gap."
    }

    private func pennedDetail(tally: PenTally) -> String {
        var detail = "\(counted(tally.area, "mud tile")) held with \(counted(game.fences.count, "fence piece"))"
        if let spoils = spoils(in: tally) {
            detail += ", and \(spoils) shut in with \(quarry) — \(counted(tally.score, "point"))."
        } else {
            detail += "."
        }

        if let heldIn {
            detail += " \(Stopwatch.face(heldIn)) on the clock."
        }

        if game.isPenAsGoodAsItGets {
            return detail + (level.holdsTreats
                ? " There is no better pen on this map."
                : " Not one more tile can be shut in on this map.")
        }
        guard game.bestScore > tally.score else { return detail }
        return detail + " Your best so far is \(game.bestScore)."
    }

    /// What a pen caught besides ground: apples worth having in it, skulls worth keeping out.
    private func spoils(in tally: PenTally) -> String? {
        var caught: [String] = []
        if tally.apples > 0 { caught.append(counted(tally.apples, "apple")) }
        if tally.skulls > 0 { caught.append(counted(tally.skulls, "skull")) }
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
                // A skull takes no fencing, so a tap that would have planted a post says
                // what the tile costs instead of shaking the rack like a spent budget.
                if let treat = level.treat(at: stroke.tile), !treat.takesFencing {
                    sayWorth(of: treat, at: stroke.tile)
                } else {
                    refuse()
                }
                return
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .clearing:
            guard game.clearFence(on: stroke.tile) else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    /// Says no to a tile the map or the budget will not take, once per press: a finger
    /// dragged across the field on a spent budget should not shake the counter at every tile.
    private func refuse() {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        withAnimation(.easeInOut(duration: 0.4)) { budgetShake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Floats what a treat is worth off the tile a finger just found it on, once per
    /// press: a drag that crosses two skulls should not stack the same five points twice.
    private func sayWorth(of treat: Treat, at tile: GridPoint) {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        worthCallout = WorthCallout(tile: tile, treat: treat)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        UIAccessibility.post(notification: .announcement, argument: treat.pointsSaid)
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
                for index in marks.indices {
                    marks[index].opacity = 1
                }
            }
        case .escaped(let escapes):
            await walk(escapes)
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .penned:
            // The clock stops on the pen holding rather than on the card coming up, so the
            // lap of honour is not charged to the player.
            clock?.stop()
            let took = clock?.elapsed() ?? 0
            if clock != nil { heldIn = took }
            // Told to whoever is keeping score before any of the celebrating, so a player
            // who leaves the moment the pen holds still keeps the stars for it.
            onPenned?(
                game.verdict ?? PenVerdict(stars: 1, isAsGoodAsItGets: false),
                took,
                game.fences
            )
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
            try? await Task.sleep(for: .milliseconds(350))
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        let cheer = Celebration(laps: game.victoryLaps, start: .now)
        celebration = cheer

        guard await cheer.waitOut() else { return }
        reveal()
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        await cheer.waitForTheConfetti()
        celebration = nil
    }

    /// Walks everything that got out along its own route and off the edge of the map. Two
    /// animals leave at the same pace and each one fades as it takes its last step, so a
    /// short way out is a quick exit rather than a wait for the other one to finish.
    private func walk(_ escapes: [Escape]) async {
        let longest = escapes.map(\.route.count).max() ?? 0
        guard longest > 1 else { return }

        for step in 1..<longest {
            withAnimation(.easeInOut(duration: 0.2)) {
                for escape in escapes where step < escape.route.count {
                    move(escape.animal.kind, to: escape.route[step])
                }
            }
            try? await Task.sleep(for: .milliseconds(220))

            withAnimation(.easeIn(duration: 0.35)) {
                for escape in escapes where step == escape.route.count - 1 {
                    vanish(escape.animal.kind)
                }
            }
        }
        try? await Task.sleep(for: .milliseconds(350))
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
