import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, open the
/// gate, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Told how many stars a pen was worth, every time one holds.
    ///
    /// Nothing is listening when a level is played on its own — the previews and the
    /// screenshot runs open one straight — and that is also how the screen knows whether
    /// there is a world map behind it to offer a way back to.
    private let onPenned: ((Int) -> Void)?

    @State private var game: PuzzleGame
    /// Where each animal is standing this instant, which is its own tile until the gate
    /// is opened on a pen with a gap in it.
    @State private var marks: [AnimalMark]
    /// Held back until the walking is over, so the verdict lands after the action.
    @State private var showsVerdict = false
    @State private var budgetShake: CGFloat = 0
    /// Whether the press in progress has already been turned down once.
    @State private var refusedThisPress = false

    init(level: PuzzleLevel, onPenned: ((Int) -> Void)? = nil) {
        self.init(game: PuzzleGame(level: level), onPenned: onPenned)
    }

    /// Opens the screen on a puzzle already in progress, which is how the previews and the
    /// screenshot runs show a field with fencing on it.
    init(game: PuzzleGame, onPenned: ((Int) -> Void)? = nil) {
        self.onPenned = onPenned
        _game = State(initialValue: game)
        _marks = State(initialValue: .standing(on: game.level))
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
            GamePalette.beyond
                .opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer(minLength: 0)

                FieldView(
                    level: level,
                    fences: game.fences,
                    penTiles: game.penTiles,
                    penGlow: penGlow,
                    isAsGoodAsItGets: game.isPenAsGoodAsItGets,
                    animals: marks,
                    onStroke: { build($0) },
                    onStrokeEnd: { game.endStroke() }
                )
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
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
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { fenceTally }
        }
        .task(id: game.phase) { await reactToPhase() }
    }

    // MARK: - Pieces

    /// How much of the budget has gone into the ground, counting up as fencing is laid.
    /// Small and in the title bar, so the board can have the rest of the screen.
    private var fenceTally: some View {
        HStack(spacing: 4) {
            Text("Fences")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(game.fences.count)/\(level.fenceBudget)")
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(game.fencesRemaining == 0 ? .orange : .primary)
        }
        .modifier(Shake(amount: budgetShake))
        // Room either side for the shake to move into rather than be clipped by the bar.
        .padding(.horizontal, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(game.fences.count) of \(level.fenceBudget) fence pieces used")
    }

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
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
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
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    // Sits on one line beside the button rather than pushing it off the
                    // screen when the type is large.
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if game.canRestoreBestPen {
                    Button { restoreBestPen() } label: {
                        Label("Put it back", systemImage: "trophy")
                            .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
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

    /// One of the small square buttons that work the fencing already down.
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
                .font(.body.weight(.semibold))
                // One box for all three, so a wider glyph does not make a wider button.
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.bordered)
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
                tint: .orange
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
                tint: .green
            ) {
                pennedActions
            }
        case .building:
            EmptyView()
        }
    }

    /// A pen that can still be widened sends the player back out to try; one that cannot
    /// leaves nothing to do but take the field again from scratch. A level opened from
    /// the world map has one more way out of both: the map itself, where the stars just
    /// earned are waiting on the signpost.
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
                    Label("Continue", systemImage: "signpost.right.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var startOver: some View {
        Button { game.startOver() } label: {
            Label("Start over", systemImage: "arrow.counterclockwise")
        }
    }

    private var goBigger: some View {
        Button { game.resumeBuilding() } label: {
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
                            .foregroundStyle(star <= stars ? .yellow : .secondary)
                    }
                }
                .font(.title3)
            }

            Text(headline)
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)

            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            actions()
                .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
                refuse()
                return
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .clearing:
            guard game.clearFence(on: stroke.tile) else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    /// Puts the fencing back the way it stood on the best pen of the session, with the
    /// same soft knock the other buttons that work the fencing already down give.
    private func restoreBestPen() {
        guard game.restoreBestPen() else { return }
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

    /// Plays out whatever the game just decided: the walk to freedom, or the lap of honour
    /// on a pen that held. The verdict card waits until the animation is done.
    private func reactToPhase() async {
        switch game.phase {
        case .building:
            // The tiles snap back rather than animating, so nothing is seen trotting home
            // from the edge of the map; only the fading back in is played.
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
            // Told to whoever is keeping score before any of the celebrating, so a player
            // who leaves the moment the pen holds still keeps the stars for it.
            onPenned?(game.starRating ?? 1)
            // The wash is already on the field — it deepens itself as the phase changes.
            // The animals take their turn on it, and the verdict waits for them.
            await celebrate()
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    /// The animals' turn on a pen that holds: a little circle round the ground they are
    /// shut into and a hop or two at the end of it, before the verdict card comes up over
    /// the field. A player who would rather the board kept still gets the same beat of
    /// nothing the wash used to have to itself.
    private func celebrate() async {
        guard !reduceMotion else {
            try? await Task.sleep(for: .milliseconds(350))
            return
        }

        await Celebration(
            laps: game.victoryLaps,
            move: { kind, tile in move(kind, to: tile) },
            lift: { height in
                for index in marks.indices {
                    marks[index].hop = height
                }
            }
        ).run()
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

    /// Puts every animal back on the tile the map starts it on, feet on the ground: a
    /// celebration cut short by a field being cleared leaves nothing hanging in the air.
    private func sendHome() {
        for animal in level.animals {
            move(animal.kind, to: animal.tile)
        }
        for index in marks.indices {
            marks[index].hop = 0
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

/// Nudges a view sideways when a tap is refused — used when the fence budget is spent.
struct Shake: GeometryEffect {
    var amount: CGFloat

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(amount * .pi * 4) * 6, y: 0))
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
