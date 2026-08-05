import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, let the
/// pig go, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @Environment(\.dismiss) private var dismiss

    /// Told how many stars a pen was worth, every time one holds.
    ///
    /// Nothing is listening when a level is played on its own — the previews and the
    /// screenshot runs open one straight — and that is also how the screen knows whether
    /// there is a world map behind it to offer a way back to.
    private let onPenned: ((Int) -> Void)?

    @State private var game: PuzzleGame
    @State private var pigTile: GridPoint
    @State private var pigOpacity: Double = 1
    /// Held back until the pig has finished its walk, so the verdict lands after the action.
    @State private var showsVerdict = false
    @State private var budgetShake: CGFloat = 0
    /// Whether the press in progress has already been turned down once.
    @State private var refusedThisPress = false

    init(level: PuzzleLevel, onPenned: ((Int) -> Void)? = nil) {
        self.onPenned = onPenned
        _game = State(initialValue: PuzzleGame(level: level))
        _pigTile = State(initialValue: level.pigStart)
    }

    private var level: PuzzleLevel { game.level }

    /// How deep the pen's wash goes. Fencing that closes colours the pen in straight away;
    /// letting the pig go and watching it fail to find a way out takes it the rest of the way.
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
                    isAsBigAsItGets: game.isPenAsBigAsItGets,
                    pigTile: pigTile,
                    pigOpacity: pigOpacity,
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
    private var buildingControls: some View {
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
                game.releasePig()
            } label: {
                Text("Release the pig")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(game.fences.isEmpty)
        }
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
        case .escaped:
            verdictCard(
                headline: "The pig got out",
                detail: "It found a way to the edge of the map. Follow its trail and close the gap.",
                tint: .orange
            ) {
                Button { game.resumeBuilding() } label: {
                    Label("Keep building", systemImage: "hammer")
                }
                .buttonStyle(.borderedProminent)
            }
        case .penned(let pen):
            verdictCard(
                headline: game.isPenAsBigAsItGets ? "The biggest pen there is" : "Penned in",
                detail: pennedDetail(pen: pen),
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
            if game.isPenAsBigAsItGets {
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
                    if !game.isPenAsBigAsItGets {
                        goBigger.buttonStyle(.bordered)
                    }
                }

                Button { dismiss() } label: {
                    Label("Back to the map", systemImage: "signpost.right.fill")
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

    private func pennedDetail(pen: Set<GridPoint>) -> String {
        let detail = "\(counted(pen.count, "mud tile")) held with \(counted(game.fences.count, "fence piece"))."
        if game.isPenAsBigAsItGets {
            return detail + " Not one more tile can be shut in on this map."
        }
        guard game.bestArea > pen.count else { return detail }
        return detail + " Your best so far is \(game.bestArea)."
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

    /// Says no to a tile the map or the budget will not take, once per press: a finger
    /// dragged across the field on a spent budget should not shake the counter at every tile.
    private func refuse() {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        withAnimation(.easeInOut(duration: 0.4)) { budgetShake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Plays out whatever the game just decided: the pig's walk to freedom, or a beat on a
    /// pen that held. The verdict card waits until the animation is done.
    private func reactToPhase() async {
        switch game.phase {
        case .building:
            pigTile = level.pigStart
            withAnimation(.easeOut(duration: 0.25)) {
                showsVerdict = false
                pigOpacity = 1
            }
        case .escaped(let route):
            await walk(route)
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .penned:
            // Told to whoever is keeping score before any of the celebrating, so a player
            // who leaves the moment the pen holds still keeps the stars for it.
            onPenned?(game.starRating ?? 1)
            // The wash is already on the field — it deepens itself as the phase changes,
            // and the verdict waits for it to settle.
            try? await Task.sleep(for: .milliseconds(350))
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    /// Walks the pig along its escape route and off the edge of the map.
    private func walk(_ route: [GridPoint]) async {
        for tile in route.dropFirst() {
            withAnimation(.easeInOut(duration: 0.2)) { pigTile = tile }
            try? await Task.sleep(for: .milliseconds(220))
        }
        withAnimation(.easeIn(duration: 0.35)) { pigOpacity = 0 }
        try? await Task.sleep(for: .milliseconds(350))
    }

    private func reveal() {
        withAnimation(.spring(duration: 0.35)) { showsVerdict = true }
    }
}

/// Nudges a view sideways when a tap is refused — used when the fence budget is spent.
private struct Shake: GeometryEffect {
    var amount: CGFloat

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(amount * .pi * 4) * 6, y: 0))
    }
}

#Preview {
    NavigationStack {
        PuzzleView(level: .riverBend)
    }
}
