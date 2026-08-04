import SwiftUI
import UIKit

/// One puzzle, end to end: build a pen out of a fixed number of fence pieces, let the
/// pig go, and find out whether it holds.
@MainActor
struct PuzzleView: View {
    @State private var game: PuzzleGame
    @State private var pigTile: GridPoint
    @State private var pigOpacity: Double = 1
    @State private var penGlow: Double = 0
    /// Held back until the pig has finished its walk, so the verdict lands after the action.
    @State private var showsVerdict = false
    @State private var budgetShake: CGFloat = 0

    init(level: PuzzleLevel) {
        _game = State(initialValue: PuzzleGame(level: level))
        _pigTile = State(initialValue: level.pigStart)
    }

    private var level: PuzzleLevel { game.level }

    var body: some View {
        ZStack {
            GamePalette.beyond
                .opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                budgetBar

                Spacer(minLength: 0)

                FieldView(
                    level: level,
                    fences: game.fences,
                    penTiles: game.penTiles,
                    penGlow: penGlow,
                    pigTile: pigTile,
                    pigOpacity: pigOpacity,
                    onTapLine: { place($0) }
                )
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)

                Spacer(minLength: 0)

                if showsVerdict {
                    verdict
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    buildingControls
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: game.phase) { await reactToPhase() }
    }

    // MARK: - Pieces

    private var budgetBar: some View {
        HStack(spacing: 10) {
            statPill(
                title: "Fences left",
                value: "\(game.fencesRemaining)",
                tint: game.fencesRemaining == 0 ? .orange : .primary
            )
            .modifier(Shake(amount: budgetShake))

            if game.bestArea > 0 {
                statPill(title: "Your best pen", value: "\(game.bestArea)", tint: .primary)
            } else {
                statPill(title: "Three stars at", value: "\(level.threeStarArea)", tint: .primary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statPill(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var buildingControls: some View {
        VStack(spacing: 10) {
            Text(level.hint)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

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

    private func place(_ fence: Fence) {
        let existing = game.fences.contains(fence)
        guard game.toggleFence(fence) else {
            withAnimation(.easeInOut(duration: 0.4)) { budgetShake += 1 }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        UIImpactFeedbackGenerator(style: existing ? .light : .rigid).impactOccurred()
    }

    /// Plays out whatever the game just decided: the pig's walk to freedom, or the gold
    /// wash over a pen that held. The verdict card waits until the animation is done.
    private func reactToPhase() async {
        switch game.phase {
        case .building:
            pigTile = level.pigStart
            withAnimation(.easeOut(duration: 0.25)) {
                showsVerdict = false
                penGlow = 0
                pigOpacity = 1
            }
        case .escaped(let route):
            await walk(route)
            reveal()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .penned:
            withAnimation(.easeOut(duration: 0.5)) { penGlow = 1 }
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
