import SwiftUI
import UIKit

/// The title screen's how-to-play: the practice pen with a coach card that walks through
/// tapping, dragging, water, closing a pen and releasing the pig.
@MainActor
struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var lesson = TutorialLesson()
    @State private var pig = AnimalMark(kind: .pig, tile: PuzzleLevel.practicePen.pigStart, opacity: 1)
    @State private var celebration: Celebration?
    @State private var budgetShake: CGFloat = 0
    @State private var refusedThisPress = false

    private var game: PuzzleGame { lesson.game }
    private var level: PuzzleLevel { game.level }

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
                coachCard
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

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
                    animals: [pig],
                    celebration: celebration,
                    highlightedTiles: lesson.highlightedTiles,
                    onStroke: { build($0) },
                    onStrokeEnd: { lesson.endStroke() }
                )
                .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                .padding(.horizontal, 6)

                Spacer(minLength: 0)

                controls
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .fieldNavigationBar()
        .keepsSwipeFromPopping()
        .task(id: game.phase) { await reactToPhase() }
        .animation(.easeInOut(duration: 0.25), value: lesson.step)
    }

    // MARK: - Coach

    private var coachCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lesson.headline)
                .font(.title3.weight(.bold))
                .foregroundStyle(GamePalette.post)

            Text(lesson.detail)
                .font(.footnote.weight(.medium))
                .foregroundStyle(GamePalette.post.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            if lesson.showsContinue {
                Button {
                    if lesson.step == .finished {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    } else if lesson.continueTapped() {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } label: {
                    Text(lesson.step == .finished ? "To the meadow" : "Continue")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(GamePalette.rail)
                .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GamePalette.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Controls

    @ViewBuilder
    private var controls: some View {
        if lesson.step == .release || lesson.step == .finished {
            Button {
                lesson.releasePig()
            } label: {
                Text(lesson.step == .finished ? "Penned in" : "Release the pig")
                    .font(.headline.weight(.heavy))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(GamePalette.rail)
            .controlSize(.large)
            .disabled(!lesson.allowsRelease)
            .opacity(lesson.step == .finished ? 0 : 1)
        } else {
            // Keeps the board's vertical place steady while the coach is talking, without
            // offering undo or clear — the walkthrough only ever asks for posts to go down.
            Color.clear.frame(height: 50)
        }
    }

    // MARK: - Actions

    private func build(_ stroke: FenceStroke) {
        if stroke.isFirst {
            refusedThisPress = false
            lesson.beginStroke()
        }

        // The lesson only ever builds; clearing would walk the script backwards.
        guard stroke.mode == .building else { return }

        guard !game.fences.contains(stroke.tile) else { return }
        guard lesson.buildFence(on: stroke.tile) else {
            refuse()
            return
        }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    private func refuse() {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        withAnimation(.easeInOut(duration: 0.4)) { budgetShake += 1 }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func reactToPhase() async {
        switch game.phase {
        case .building:
            celebration = nil
            pig.tile = level.pigStart
            withAnimation(.easeOut(duration: 0.25)) { pig.opacity = 1 }
        case .escaped(let escapes):
            // The scripted pen holds, so this path is only a safety net if the field is
            // somehow opened early — walk the pig out and leave the coach where it is.
            guard await walk(escapes.first?.route ?? []) else { return }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .penned:
            lesson.reconsider()
            await celebrate()
        case .refused:
            // The practice pen has one animal and no rule to break, so this cannot happen
            // here; the switch is whole so that a new rule cannot pass through unnoticed.
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    /// The pig's lap of honour round the practice pen, which is the first one a new player
    /// sees a pen that holds take.
    private func celebrate() async {
        guard !reduceMotion else {
            guard await Task.pausing(for: .milliseconds(350)) else { return }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        let cheer = Celebration(laps: game.victoryLaps, start: .now)
        celebration = cheer

        guard await cheer.waitOut() else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        await cheer.waitForTheConfetti()
        celebration = nil
    }

    /// Returns whether the walk ran to the end. A cancelled task must not keep stepping
    /// after the pig has been sent home.
    private func walk(_ route: [GridPoint]) async -> Bool {
        for tile in route.dropFirst() {
            withAnimation(.easeInOut(duration: 0.2)) { pig.tile = tile }
            guard await Task.pausing(for: .milliseconds(220)) else { return false }
        }
        withAnimation(.easeIn(duration: 0.35)) { pig.opacity = 0 }
        return await Task.pausing(for: .milliseconds(350))
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}
