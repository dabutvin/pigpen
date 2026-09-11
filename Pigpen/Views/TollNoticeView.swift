import SwiftUI

/// The notice the map puts up over a boss nobody can pay for yet: what is shut, the stars
/// against its price, and how many more of them there are to find.
///
/// Laid out the way the game's other offers are — a name on the page, and under it one card
/// that is only the thing being said — because it is the same kind of interruption and ought
/// to look like one. It says its one line and stops: a player who has just been told they
/// are two stars short does not also need telling where stars come from, and the map behind
/// the card — every stop on it open, every one of them worth another go — says that better
/// than a paragraph would.
@MainActor
struct TollNoticeView: View {
    @Environment(\.dismiss) private var dismiss

    let notice: TollNotice

    var body: some View {
        ZStack {
            // The cream page the game's other sheets stand on, with the card lifted off it
            // by its own shadow.
            LinearGradient(
                colors: [GamePalette.mudLit, GamePalette.mud],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    card
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .staysInDaylight()
    }

    // MARK: - Pieces

    /// What is shut, and the way out of being told about it. The cross does exactly what the
    /// button at the bottom does: there is nothing to answer here, only something to read.
    private var header: some View {
        HStack(spacing: 12) {
            Text("\(notice.boss) is locked")
                .font(.title3.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                Haptics.tap(.light)
                Sounds.play(.press)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    // No disc under it, but the tap target stays the size a disc would give.
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// The lock, the running count against the price, and the one line that says what the
    /// difference between them comes to.
    private var card: some View {
        VStack(spacing: 14) {
            gate
            tally

            Text(shortfall)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(GamePalette.post)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Haptics.tap(.medium)
                Sounds.play(.press)
                dismiss()
            } label: {
                Label("Back to the trail", systemImage: "signpost.right.fill")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
            // A wider gap than the line above it: what is being read ends here.
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(GamePalette.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(GamePalette.post.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }

    /// The same stone disc and padlock the boss's signpost is wearing up the trail, so the
    /// card and the sign it is about are plainly the same news.
    private var gate: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 30, weight: .black))
            .foregroundStyle(GamePalette.cream)
            .frame(width: 68, height: 68)
            .background {
                Circle()
                    .fill(GamePalette.stone)
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.35), lineWidth: 3))
            }
            .accessibilityHidden(true)
    }

    /// What the world holds against what the gate wants, written the way the signpost writes
    /// it and the banner across the map writes it: `have/need`, stars.
    private var tally: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .foregroundStyle(GamePalette.pen)
            Text("\(notice.have)/\(notice.need)")
                .foregroundStyle(GamePalette.post)
                .monospacedDigit()
        }
        .font(.system(size: 27, weight: .black, design: .rounded))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(notice.have) stars of the \(notice.need) it wants")
    }

    // MARK: - Words

    /// The whole of what the card has to say in words: how many stars short of playing this
    /// level the player is. What the gate costs and what they hold against it are already on
    /// the tally above, and where the rest of the stars are to be won is the trail itself —
    /// so the sentence says the one thing neither of those says, and stops.
    private var shortfall: String {
        "You need \(missing) to play this level."
    }

    /// The shortfall in words, since a sentence reads better with one and the tally above it
    /// is already showing the figures.
    private var missing: String {
        let spelled = [
            "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"
        ]
        let short = notice.shortBy
        let count = short >= 1 && short <= spelled.count ? spelled[short - 1] : "\(short)"
        return "\(count) more star\(short == 1 ? "" : "s")"
    }
}

#Preview("Two short") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            TollNoticeView(notice: TollNotice(boss: "Stag Mere", have: 19, need: 21))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("One short") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            TollNoticeView(notice: TollNotice(boss: "Boar Hollow", have: 20, need: 21))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
}
