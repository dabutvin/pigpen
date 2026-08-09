import SwiftUI

/// Today's puzzle, as it stands on the title screen: which day it is, what that day asks,
/// and — once the pen has held — the stars it gave up and the time it took.
///
/// A board nailed to the front of the game rather than a button, because there is more to
/// say about today than a word. Before it is played it says what the day is for; afterwards
/// it says what you made of it, which is what brings a player back tomorrow.
struct DailyCard: View {
    let date: DailyDate
    /// The stars the day has given up, and 0 for a day not finished yet.
    let stars: Int
    /// True for a day that gave up the best pen it had in it.
    var hasTheBestPen = false
    /// The quickest the day has been finished, in seconds.
    var bestTime: Int?
    /// How many days in a row have been completed, counting back from today.
    var streak: Int = 0
    /// False when the almanac has run out and there is no puzzle for today at all.
    var hasAPuzzle = true

    private var isComplete: Bool { stars > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            heading
            billing
            if hasAPuzzle { tally }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(plank)
        .overlay(nailHeads)
        .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    // MARK: - Pieces

    private var heading: some View {
        HStack(spacing: 7) {
            Image(systemName: isComplete ? "checkmark.seal.fill" : "sun.max.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(isComplete ? GamePalette.clover : GamePalette.rail)

            Text("TODAY'S PUZZLE")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(GamePalette.post.opacity(0.7))

            Spacer(minLength: 0)

            if streak > 1 {
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                    Text("\(streak)")
                        .monospacedDigit()
                }
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.barn)
            }
        }
    }

    private var billing: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(hasAPuzzle ? date.title : "Nothing in the book")
                .font(.system(size: 19, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(hasAPuzzle ? date.weekday.billing : "The almanac stops before today")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(GamePalette.post.opacity(0.62))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// What is there to show for it: the stars, the clock, or — before it has been played
    /// — what the button is going to do.
    private var tally: some View {
        HStack(spacing: 10) {
            if isComplete {
                StarRow(stars: stars, size: 13, hasTheBestPen: hasTheBestPen)

                if let bestTime {
                    HStack(spacing: 3) {
                        Image(systemName: "stopwatch")
                        Text(Stopwatch.face(TimeInterval(bestTime)))
                            .monospacedDigit()
                    }
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post.opacity(0.62))
                }

                Spacer(minLength: 0)

                Label("Play again", systemImage: "arrow.counterclockwise")
                    .labelStyle(.titleOnly)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.rail)
            } else {
                Text("Not complete yet")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(GamePalette.post.opacity(0.5))

                Spacer(minLength: 0)

                HStack(spacing: 5) {
                    Text("Play")
                    Image(systemName: "play.fill")
                }
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.rail)
            }
        }
        .padding(.top, 1)
    }

    // MARK: - The board it is painted on

    private var plank: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(GamePalette.cream.opacity(0.96))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.22), lineWidth: 1.5)
            }
    }

    private var nailHeads: some View {
        VStack {
            HStack {
                nailHead
                Spacer(minLength: 0)
                nailHead
            }
            Spacer(minLength: 0)
            HStack {
                nailHead
                Spacer(minLength: 0)
                nailHead
            }
        }
        .padding(7)
    }

    private var nailHead: some View {
        Circle()
            .fill(GamePalette.post.opacity(0.35))
            .frame(width: 5, height: 5)
    }

    private var spokenLabel: String {
        guard hasAPuzzle else { return "Today's puzzle. There is none — the almanac stops before today." }
        let spelled = ["no", "one", "two", "three"]
        var said = "Today's puzzle. \(date.fullTitle). \(date.weekday.billing)."
        if isComplete {
            said += " Complete, \(spelled[min(max(stars, 0), 3)]) star\(stars == 1 ? "" : "s")."
            if hasTheBestPen { said += " The best pen there is." }
            if let bestTime { said += " Best time \(Stopwatch.spoken(TimeInterval(bestTime)))." }
        } else {
            said += " Not complete yet."
        }
        if streak > 1 { said += " \(streak) days in a row." }
        return said
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyCard(date: DailyDate(year: 2026, month: 8, day: 9), stars: 0)
        DailyCard(
            date: DailyDate(year: 2026, month: 8, day: 9),
            stars: 3,
            hasTheBestPen: true,
            bestTime: 187,
            streak: 6
        )
        DailyCard(date: DailyDate(year: 2099, month: 1, day: 1), stars: 0, hasAPuzzle: false)
    }
    .padding(24)
    .background(GamePalette.beyond)
}
