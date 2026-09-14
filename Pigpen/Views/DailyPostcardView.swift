import SwiftUI

/// The postcard held up before it goes: the day's board drawn in emoji on a cream card, a
/// switch for whether the fencing goes with it, and the button that hands the lot to the
/// phone's share sheet.
///
/// A preview rather than straight to the sheet, because the card is the thing being sent
/// and the sheet shows a line of it at most. Seeing the pen in emoji before it goes is half
/// the fun, and the other half is choosing whether the friend on the far end gets the
/// answer with it.
@MainActor
struct DailyPostcardView: View {
    @Environment(\.dismiss) private var dismiss

    let postcard: DailyPostcard
    /// Whether the fencing is drawn on. Off as the card comes up: everybody gets the same
    /// board, and a card sent to somebody who has not had their go should not hand them
    /// the answer. The switch is for the friend who has.
    @State private var showsFencing = false

    private var text: String { postcard.text(showingFencing: showsFencing) }

    var body: some View {
        ZStack {
            // A cream page rather than timber, the same as the other sheets.
            LinearGradient(
                colors: [GamePalette.mudLit, GamePalette.mud],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 14) {
                        card
                        fencingSwitch
                        shareButton

                        Text("Everybody gets the same board. The fencing is your answer to it.")
                            .font(.caption2)
                            .foregroundStyle(GamePalette.post.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .staysInDaylight()
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            Text("Share the day")
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

    /// The card itself, word for word what goes into the chat, so what is admired here is
    /// what arrives there. Selectable, for anybody who would rather copy it by hand.
    private var card: some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(GamePalette.post)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
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
            // A darker, longer drop than a card on timber needed: on a cream page the shadow
            // is the whole of what lifts a cream card off it.
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            .accessibilityLabel(postcard.spoken)
    }

    /// The one choice on the card: whether the wall goes on it.
    private var fencingSwitch: some View {
        Toggle(isOn: $showsFencing) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Show my fencing")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)

                Text(
                    showsFencing
                        ? "The pen goes with it, wall and all."
                        : "Just the board, the way the day opened."
                )
                .font(.caption)
                .foregroundStyle(GamePalette.post.opacity(0.6))
            }
        }
        .tint(GamePalette.clay)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(GamePalette.cream.opacity(0.7))
        )
        .onChange(of: showsFencing) { _, _ in
            Haptics.tap(.light)
        }
    }

    /// Hands the card to the phone. Counted on the way, with whether the fencing went.
    private var shareButton: some View {
        ShareLink(item: text) {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.cream)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
        .simultaneousGesture(
            TapGesture().onEnded {
                Haptics.tap(.medium)
                Sounds.play(.press)
                Analytics.record(.dailyShared(fencing: showsFencing))
            }
        )
        .padding(.top, 4)
    }
}

#Preview("The best pen there is") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            let wednesday = DailyDate(year: 2026, month: 4, day: 22)
            if let level = DailyAlmanac.level(on: wednesday),
               let postcard = DailyPostcard(
                   date: wednesday,
                   level: level,
                   fences: [
                       GridPoint(row: 1, column: 3), GridPoint(row: 2, column: 4),
                       GridPoint(row: 3, column: 0), GridPoint(row: 3, column: 5),
                       GridPoint(row: 4, column: 0), GridPoint(row: 5, column: 0),
                       GridPoint(row: 6, column: 1), GridPoint(row: 7, column: 2),
                       GridPoint(row: 7, column: 4), GridPoint(row: 8, column: 3)
                   ],
                   seconds: 134,
                   streak: 6
               ) {
                DailyPostcardView(postcard: postcard)
                    .presentationDragIndicator(.visible)
            }
        }
}
