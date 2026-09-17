import SwiftUI

/// The postcard held up before it goes: the day's card as it will arrive, a switch for
/// whether the fencing goes with it, and the button that hands the picture to the phone's
/// share sheet.
///
/// A preview rather than straight to the sheet, because the card is the thing being sent and
/// the sheet shows a line of it at most. What is held up here is the card itself — the same
/// view that is painted into the picture — so what is admired is what arrives.
@MainActor
struct DailyPostcardView: View {
    @Environment(\.dismiss) private var dismiss

    let postcard: DailyPostcard
    /// What the pig has on, so she is dressed on the card the way she was on the board. The
    /// one wardrobe the game keeps, by default; a preview hands in its own.
    var wardrobe: PigWardrobe = .shared

    /// Whether the fencing is standing on the card. Off as it comes up: everybody gets the
    /// same board, and a card sent to somebody who has not had their go should not hand them
    /// the answer. The switch is for the friend who has.
    @State private var showsFencing = false

    /// The card itself, held up on this screen.
    private var card: DailyPostcardCard {
        DailyPostcardCard(postcard: postcard, showsFencing: showsFencing, outfit: wardrobe.outfit)
    }

    /// The same card as the thing that goes — which is the card and not a painting of it,
    /// since the painting happens when the share sheet asks. So the button below is live the
    /// moment the screen is, whatever the phone is busy with.
    private var picture: PostcardPicture {
        PostcardPicture(postcard: postcard, showsFencing: showsFencing, outfit: wardrobe.outfit)
    }

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
                        // The card is one fixed width whatever is holding it, so it is
                        // centred rather than stretched — and the page is padded narrowly
                        // enough that the whole of it stands on the narrowest phone.
                        card.frame(maxWidth: .infinity)

                        fencingSwitch
                        shareButton

                        Text("Everybody gets the same board. The fencing is your answer to it.")
                            .font(.caption2)
                            .foregroundStyle(GamePalette.post.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .staysInDaylight()
        .onChange(of: showsFencing) { _, _ in
            Haptics.tap(.light)
        }
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
    }

    /// Hands the picture to the phone, with the day, what the pen was worth and the day's
    /// address as the words that go with it — a chat that takes both gets something to look
    /// at and something to tap. Counted on the way, with whether the fencing went.
    ///
    /// No subject. A subject is a thing Mail has and a chat has not, and a chat handed one
    /// prints it above the message rather than dropping it: the day came out twice, once
    /// from the subject and once from the top of the caption. The caption says everything
    /// now, and says it once.
    private var shareButton: some View {
        ShareLink(
            item: picture,
            message: Text(postcard.caption),
            preview: SharePreview(postcard.title)
        ) {
            shareLabel
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

    private var shareLabel: some View {
        Label("Share your score", systemImage: "square.and.arrow.up")
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(GamePalette.cream)
            .frame(maxWidth: .infinity)
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
