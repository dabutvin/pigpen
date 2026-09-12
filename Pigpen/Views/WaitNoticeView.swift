import SwiftUI

/// The notice the map puts up after the full-game offer comes down without a purchase: the
/// free game's one-a-day rule, and how long is left of this day.
///
/// Laid out the way the toll notice is — a name on the page, and under it one card that is
/// only the thing being said — because it is the same kind of interruption and ought to look
/// like one. It says its one rule and stops: a player who has just waved the purchase away
/// does not also need selling it again, and the locked sign behind the card — with the same
/// clock this card is wearing — is already counting the hours down.
@MainActor
struct WaitNoticeView: View {
    @Environment(\.dismiss) private var dismiss

    let notice: WaitNotice

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

    /// What is being explained, and the way out of being told about it. The cross does
    /// exactly what the button at the bottom does: there is nothing to answer here, only
    /// something to read.
    private var header: some View {
        HStack(spacing: 12) {
            Text("One level a day")
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

    /// The clock, the time left written the way the signpost writes it, and the one line
    /// that says what those hours are for.
    private var card: some View {
        VStack(spacing: 14) {
            gate
            tally

            Text(rule)
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

    /// The same stone disc the locked signpost wears up the trail, with the clock on it
    /// instead of a padlock — so the card and the sign it is about are plainly the same news.
    private var gate: some View {
        Image(systemName: "clock.fill")
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

    /// How long is left, written the way the signpost writes it: `14h`, `40m`.
    private var tally: some View {
        HStack(spacing: 5) {
            Image(systemName: "clock.fill")
                .foregroundStyle(GamePalette.pen)
            Text(notice.wait.short)
                .foregroundStyle(GamePalette.post)
                .monospacedDigit()
        }
        .font(.system(size: 27, weight: .black, design: .rounded))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("opens in \(notice.wait.spoken)")
    }

    // MARK: - Words

    /// The whole of what the card has to say: the free game's rule, and when this stop
    /// opens under it. The countdown is already on the tally above, so the sentence names
    /// the rule the tally cannot — one every twenty-four hours — and stops.
    private var rule: String {
        "The free game opens one new level every twenty-four hours. This one opens in "
            + "\(notice.wait.spoken)."
    }
}

#Preview("Fourteen hours left") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            WaitNoticeView(notice: WaitNotice(wait: LevelWait(minutes: 14 * 60)))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
}

#Preview("Forty minutes left") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            WaitNoticeView(notice: WaitNotice(wait: LevelWait(minutes: 40)))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
}
