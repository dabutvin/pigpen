import SwiftUI
import UIKit

/// The title screen's how-to-play: the practice pen with a coach card that walks through
/// tapping, dragging, what a bonus and a penalty are worth, closing a pen and releasing
/// the pig.
@MainActor
struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var lesson = TutorialLesson()
    @State private var pig = AnimalMark(kind: .pig, tile: PuzzleLevel.practicePen.pigStart, opacity: 1)
    @State private var celebration: Celebration?
    @State private var budgetShake: CGFloat = 0
    /// Bumped when a press lands off the tiles the coach asked for, which shakes the
    /// highlight rather than the rack.
    @State private var targetShake: CGFloat = 0
    /// Bumped when the board is pressed during a step that is only asking to be read, which
    /// shakes Continue — the one thing there is to tap.
    @State private var continueShake: CGFloat = 0
    @State private var refusedThisPress = false

    /// The height of the one slot the walkthrough's button stands in: the button's own
    /// lettering and padding plus the depth it sinks through when pressed.
    private static let actionSlotHeight: CGFloat = 58

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

    /// Whether the walkthrough was seen through to the end, so that backing out of it is
    /// counted as backing out rather than as finishing.
    @State private var reachedTheMeadow = false

    var body: some View {
        ZStack {
            MeadowBackdrop()
                .ignoresSafeArea()

            // The coach talks from the bottom of the screen, under the board rather than over
            // it: what it is saying is always about the ground, and a card between the rack
            // and the field puts the reading furthest from the thing being read. Down here it
            // sits beside the thumb that has to act on it, and the board keeps the top of the
            // screen to itself.
            VStack(spacing: 12) {
                FenceRack(
                    used: game.fences.count,
                    budget: level.fenceBudget,
                    shake: budgetShake
                )
                .padding(.horizontal, 16)

                FieldView(
                    level: level,
                    fences: game.fences,
                    penTiles: game.penTiles,
                    penGlow: penGlow,
                    isAsGoodAsItGets: game.isPenAsGoodAsItGets,
                    animals: [pig],
                    celebration: celebration,
                    highlightedTiles: lesson.highlightedTiles,
                    highlightShake: targetShake,
                    pricedTiles: lesson.pricedTiles,
                    onStroke: { build($0) },
                    onStrokeEnd: { lesson.endStroke() }
                )
                .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                .padding(.horizontal, 6)

                coach
                    .padding(.horizontal, 16)

                // The only slack on the screen, and it is all below the card: the rack, the
                // field and the coach are pinned to the top in that order, so a card that
                // runs to two lines on one step and one on the next — or carries no button
                // at all — grows and shrinks downwards into this. Neither the ground the
                // player is being asked to tap nor the words about it ever move.
                Spacer(minLength: 0)
            }
            // The same distance off the bar the field keeps, so the walkthrough opens on the
            // board's own spacing rather than on a tighter version of it.
            .padding(.top, 22)
            .padding(.bottom, 12)
        }
        .navigationTitle(level.name)
        .navigationBarTitleDisplayMode(.inline)
        .fieldNavigationBar()
        .staysInDaylight()
        .keepsSwipeFromPopping()
        .task(id: game.phase) { await reactToPhase() }
        .animation(.easeInOut(duration: 0.25), value: lesson.step)
        .onAppear { Analytics.record(.tutorialOpened) }
        .onDisappear {
            // Which lesson they were on when they walked out is the whole value of this:
            // the walkthrough loses people at a particular step or it does not lose them
            // at all, and this is the only way to tell which.
            guard !reachedTheMeadow else { return }
            Analytics.record(
                .tutorialLeftEarly(
                    lesson: lesson.step.rawValue,
                    of: TutorialLesson.Step.allCases.count - 1
                )
            )
        }
    }

    // MARK: - Coach

    /// The coach, and the room the coach is given.
    ///
    /// The card itself closes up around whatever this step has to say: the steps that ask
    /// for a tap on the board carry no button, and no empty button's worth of air either.
    /// What does not change is the room set aside for it, which is held open by a copy of
    /// the wordiest card there is — laid underneath, never drawn, and measured by SwiftUI
    /// all the same. Without it the board took back every line the coach gave up and the
    /// ground resized under the player's thumb between one step and the next.
    private var coach: some View {
        ZStack(alignment: .top) {
            card(headline: Self.wordiestHeadline, detail: Self.wordiestDetail) {
                Color.clear
                    .frame(height: Self.actionSlotHeight)
                    .padding(.top, 2)
            }
            .hidden()

            coachCard
        }
    }

    /// The wordiest step's words, which are what the hidden copy is built from. Read off the
    /// lesson rather than written out again, so rewording a step cannot leave the room set
    /// aside for it the wrong size.
    private static let wordiestHeadline = TutorialLesson.Step.allCases
        .map(TutorialLesson.headline(for:))
        .max { $0.count < $1.count } ?? ""

    private static let wordiestDetail = TutorialLesson.Step.allCases
        .map(TutorialLesson.detail(for:))
        .max { $0.count < $1.count } ?? ""

    private var coachCard: some View {
        card(headline: lesson.headline, detail: lesson.detail) {
            if lesson.hasActionButton {
                actionButton
                    // Tall enough for the painted button and the ledge of shadow it stands on.
                    .frame(height: Self.actionSlotHeight)
                    .padding(.top, 2)
                    .modifier(Shake(amount: continueShake))
            }
        }
    }

    /// A painted card with a headline, a line or two under it and whatever the step wants
    /// pressed. The real one and the hidden one that sizes it are both built from this, so
    /// the two cannot drift apart.
    private func card<Action: View>(
        headline: String,
        detail: String,
        @ViewBuilder action: () -> Action
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline)
                .font(.title3.weight(.bold))
                .foregroundStyle(GamePalette.post)

            Text(detail)
                .font(.footnote.weight(.medium))
                .foregroundStyle(GamePalette.post.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            action()
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

    /// The one button the walkthrough ever offers, in the one place it ever offers it.
    ///
    /// Every step's button used to be its own: Continue inside the card, releasing the pig in
    /// a bar under the board, and nothing at all on the steps that only want a tap. Three
    /// different buttons in two different places meant the card changed height and the board
    /// moved under the player's thumb every time the lesson turned a page. So there is one
    /// slot, always the same height, and what changes is only which button is standing in it.
    /// The steps that ask for something on the board instead carry no slot at all.
    ///
    /// Whichever button it is, it is the painted one the field itself ends a go with, in the
    /// same dusty salmon as the bar overhead: the walkthrough is teaching the board, so the
    /// thing it asks the player to press should be the thing the board will ask them to press.
    @ViewBuilder
    private var actionButton: some View {
        if lesson.showsContinue {
            Button {
                if lesson.step == .finished {
                    Haptics.tap(.medium)
                    reachedTheMeadow = true
                    Analytics.record(.tutorialFinished)
                    dismiss()
                } else if lesson.continueTapped() {
                    Haptics.tap(.light)
                }
            } label: {
                Text(lesson.step == .finished ? "Play" : "Continue")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
        } else if lesson.step == .release {
            Button {
                lesson.releasePig()
            } label: {
                Text("Release the pig")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
            .disabled(!lesson.allowsRelease)
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

        // A press somewhere the coach did not ask for is a question about where to tap, so
        // the tiles it did ask for are what answers it. Anything else the field turns down —
        // which in the practice pen means the budget, since the script never asks for more
        // pieces than it hands over — still shakes the rack, because that is what is wrong.
        guard lesson.buildableTiles.contains(stroke.tile) else {
            // Whatever the coach is asking for is what answers a press in the wrong place:
            // the tiles it is pointing at while it wants fencing, and Continue while it only
            // wants reading — which is the one thing on screen a press can usefully land on.
            refuse { lesson.highlightedTiles.isEmpty ? (continueShake += 1) : (targetShake += 1) }
            return
        }
        guard lesson.buildFence(on: stroke.tile) else {
            refuse { budgetShake += 1 }
            return
        }
        Haptics.tap(.rigid)
    }

    /// One refusal per press, whichever thing is doing the shaking: a drag that crosses six
    /// tiles it may not fence is one wrong answer, not six.
    private func refuse(_ shake: () -> Void) {
        guard !refusedThisPress else { return }
        refusedThisPress = true
        withAnimation(.easeInOut(duration: 0.4)) { shake() }
        Haptics.buzz(.warning)
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
            Haptics.buzz(.error)
        case .penned:
            lesson.reconsider()
            await celebrate()
        case .refused:
            // The practice pen has one animal and no rule to break, so this cannot happen
            // here; the switch is whole so that a new rule cannot pass through unnoticed.
            Haptics.buzz(.error)
        }
    }

    /// The pig's lap of honour round the practice pen, which is the first one a new player
    /// sees a pen that holds take.
    private func celebrate() async {
        guard !reduceMotion else {
            guard await Task.pausing(for: .milliseconds(350)) else { return }
            Haptics.buzz(.success)
            return
        }

        let cheer = Celebration(laps: game.victoryLaps, start: .now)
        celebration = cheer

        guard await cheer.waitOut() else { return }
        Haptics.buzz(.success)

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
