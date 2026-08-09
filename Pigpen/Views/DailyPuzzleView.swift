import SwiftUI

/// One day's board: the puzzle the almanac keeps for that date, with a clock over it and
/// the day's record kept when the pen holds.
///
/// The only screen that knows a daily puzzle is a puzzle at all — everything below it is
/// the same board the meadow is played on, which is the point. A daily is not a different
/// game, it is the same game with a date on it.
@MainActor
struct DailyPuzzleView: View {
    let date: DailyDate
    let progress: DailyProgress
    /// The clock the board opens with. A running one for a player; one already stopped for
    /// a screenshot, which cannot photograph something that is still moving.
    var clock = Stopwatch()

    var body: some View {
        if let level = DailyAlmanac.level(on: date) {
            PuzzleView(level: level, clock: clock) { verdict, seconds in
                progress.record(verdict, seconds: seconds, on: date)
            }
        } else {
            NoPuzzleView(date: date)
        }
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
