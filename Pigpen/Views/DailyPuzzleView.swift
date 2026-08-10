import SwiftUI

/// One day's board: the puzzle the almanac keeps for that date, with a clock over it and
/// the day's record kept when the pen holds.
///
/// The only screen that knows a daily puzzle is a puzzle at all — everything below it is
/// the same board the meadow is played on, which is the point. A daily is not a different
/// game, it is the same game with a date on it.
///
/// Hitting back without releasing the animals still keeps the fencing: the board is filed
/// away as a draft on the way out, and laid back down the next time the day is opened.
@MainActor
struct DailyPuzzleView: View {
    let date: DailyDate
    let progress: DailyProgress
    /// The clock the board opens with when nothing has been timed on this day yet. A
    /// draft with a clock already under way takes its own; a screenshot hands one in
    /// already stopped, which cannot photograph something that is still moving.
    var clock = Stopwatch()
    /// Whether the board should open with the submitted wall already down — the player
    /// took *Put it back* on a day they had held before. Otherwise the wall is only
    /// remembered, so the trophy can offer it once the field is somewhere else.
    var restoreSubmitted = false

    var body: some View {
        if let level = DailyAlmanac.level(on: date) {
            // Done, not Continue: a day is finished when the pen holds, and there is no
            // trail behind it waiting for the next signpost — only the title screen.
            PuzzleView(
                game: game(for: level),
                clock: progress.hasDraft(on: date) ? progress.clock(on: date) : clock,
                wayOutTitle: "Done",
                wayOutImage: "checkmark.seal.fill",
                onPenned: { verdict, seconds, fences in
                    progress.record(verdict, seconds: seconds, fences: fences, on: date)
                },
                onLeave: { game, clock in
                    progress.saveDraft(from: game, clock: clock, on: date)
                }
            )
        } else {
            NoPuzzleView(date: date)
        }
    }

    /// The board the day opens on: whatever fencing was left standing when it was last
    /// put away, and behind that the wall submitted for the day's best pen — laid down
    /// already when the player asked for it back, or only kept so *Put it back* can offer
    /// it after they rearrange.
    private func game(for level: PuzzleLevel) -> PuzzleGame {
        let game = progress.game(for: level, on: date)
        guard let fences = progress.submittedFences(on: date) else { return game }
        if restoreSubmitted {
            game.putSubmittedPenBack(fences)
        } else {
            game.rememberSubmittedPen(fences)
        }
        return game
    }
}

/// What a day the almanac has nothing for looks like. The book runs out at the end of the
/// last year it was written for, so a player who has kept the game that long is told where
/// they have got to rather than handed an empty field.
struct NoPuzzleView: View {
    @Environment(\.dismiss) private var dismiss

    let date: DailyDate

    var body: some View {
        ZStack {
            MeadowBackdrop()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(GamePalette.rail)

                Text("No puzzle for \(date.fullTitle)")
                    .font(.title3.weight(.black))
                    .foregroundStyle(GamePalette.post)
                    .multilineTextAlignment(.center)

                Text(
                    """
                    The almanac this game shipped with does not go that far. \
                    The meadow is still there, and every day the book does have is in the archive.
                    """
                )
                .font(.footnote.weight(.medium))
                .foregroundStyle(GamePalette.post.opacity(0.78))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.borderedProminent)
                .tint(GamePalette.rail)
                .padding(.top, 4)
            }
            .padding(18)
            .background(GamePalette.cream.opacity(0.96), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.22), radius: 8, y: 5)
            .padding(28)
        }
        .navigationTitle(date.title)
        .navigationBarTitleDisplayMode(.inline)
        .fieldNavigationBar()
    }
}

#Preview("No puzzle") {
    NavigationStack {
        NoPuzzleView(date: DailyDate(year: 2099, month: 1, day: 1))
    }
}
