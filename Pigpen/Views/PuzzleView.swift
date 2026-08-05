import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, let the
/// pig go, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @State private var game: PuzzleGame
    @State private var pigTile: GridPoint
    @State private var pigOpacity: Double = 1
    /// Held back until the pig has finished its walk, so the verdict lands after the action.
    @State private var showsVerdict = false
    @State private var budgetShake: CGFloat = 0
    /// Whether the press in progress has already been turned down once.
    @State private var refusedThisPress = false

    init(level: PuzzleLevel) {
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
                    isOptimal: game.isOptimal,
                    pigTile: pigTile,
                    pigOpacity: pigOpacity,
                    onStroke: { build($0) }
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

    private var buildingControls: some View {
        HStack(spacing: 10) {
            if !game.fences.isEmpty {
                Button { game.startOver() } label: {
                    Label("Clear", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
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
                headline: "Penned in",
                detail: pennedDetail(pen: pen),
                tint: .green
            ) {
                HStack(spacing: 10) {
                    Button { game.startOver() } label: {
                        Label("Start over", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Button { game.resumeBuilding() } label: {
                        Label("Go bigger", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        case .building:
            EmptyView()
        }
    }

    private func pennedDetail(pen: Set<GridPoint>) -> String {
        let detail = "\(counted(pen.count, "mud tile")) held with \(counted(game.fences.count, "fence piece"))."
        if game.isOptimal {
            return detail + " There is no bigger pen on this map."
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
        if stroke.isFirst { refusedThisPress = false }

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
