import SwiftUI
import UIKit

/// The game's own offer of a reminder each morning, put up once, after the player has held a
/// daily puzzle and so has something to lose by forgetting the next one.
///
/// It stands in front of the phone's prompt rather than instead of it. A phone shows its
/// permission sheet once and never again, so a game that raises it cold — on a title screen
/// somebody has just opened for the first time — spends its one chance on a player who does
/// not yet know what a daily puzzle is. This asks first, in the game's own words and on the
/// game's own boards, and only reaches for the system prompt once the answer is yes.
///
/// *Not now* is a real answer: nothing is asked of the phone, nothing is scheduled, and the
/// offer is not put up a second time. The switch behind the gear is where somebody changes
/// their mind afterwards, and it says so here so that no is not read as never.
@MainActor
struct ReminderPromptView: View {
    @Environment(\.dismiss) private var dismiss

    /// The hour the reminder would come at, in the player's own reckoning of o'clock.
    var time: ReminderTime = .morning
    /// Taken when the player says yes. Raising the phone's prompt is the caller's to do,
    /// since it is the caller that holds the book of days the fortnight is planned against.
    var onAccept: () -> Void
    /// Taken when the player waves it away, so the offer is marked as made either way.
    var onDecline: () -> Void

    var body: some View {
        ZStack {
            // A cream page rather than timber, the same as the other sheets, with the card
            // separated from it by its own dark shadow.
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
        // The wheel that picks the hour is stock, and a stock wheel follows the phone
        // unless it is told not to.
        .staysInDaylight()
    }

    // MARK: - Pieces

    /// What is being offered, and the way out of being offered it — laid out the way the
    /// full-game sheet is, since they are the same kind of thing: a name on the page, and
    /// under it one card that is only the offer.
    ///
    /// The cross is *Not now* by another route. A player who shuts the sheet has answered,
    /// and the answer has to be marked the same way the button marks it or the offer comes
    /// back tomorrow having already been made.
    private var header: some View {
        HStack(spacing: 12) {
            Text("Daily reminders")
                .font(.title3.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                Haptics.tap(.light)
                Sounds.play(.press)
                onDecline()
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

    /// The offer itself: the bell, what there is to be reminded about, and the two answers.
    private var card: some View {
        VStack(spacing: 14) {
            gate

            Text(offer)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(GamePalette.post.opacity(0.75))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            buttons
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
        // A darker, longer drop than a card on timber needed: on a cream page the shadow
        // is the whole of what lifts a cream card off it.
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }

    /// A bell over the gate, which is the whole of what this is offering.
    private var gate: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: 34, weight: .black))
            .symbolRenderingMode(.palette)
            .foregroundStyle(GamePalette.barn, GamePalette.clay)
            .frame(width: 68, height: 68)
            .background {
                Circle()
                    .fill(GamePalette.clay.opacity(0.18))
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.15), lineWidth: 1))
            }
            .accessibilityHidden(true)
    }

    private var buttons: some View {
        VStack(spacing: 6) {
            Button {
                Haptics.tap(.medium)
                Sounds.play(.press)
                onAccept()
                dismiss()
            } label: {
                Label("Remind me at \(time.face)", systemImage: "bell.fill")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
            // A wider gap than the one between the two answers: what is being read ends
            // here and what is being answered begins.
            .padding(.top, 16)

            Button {
                Haptics.tap(.light)
                Sounds.play(.press)
                onDecline()
                dismiss()
            } label: {
                Text("Not now")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }

            Text("You can change the time, or turn it off, in Settings.")
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Words

    /// What there is to be reminded about. One line for everybody: the offer is the same
    /// whether or not there is a run going, and a sentence that names the streak reads as a
    /// bargain struck over something the player already has rather than a plain offer of a
    /// morning nudge.
    private let offer = """
        Enable notifications to get daily reminders that help you build your streak.
        """
}

#Preview("Nine in the morning") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ReminderPromptView(onAccept: {}, onDecline: {})
                .presentationDetents([.medium, .large])
        }
}

#Preview("Half seven in the evening") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ReminderPromptView(time: ReminderTime(hour: 19, minute: 30), onAccept: {}, onDecline: {})
                .presentationDetents([.medium, .large])
        }
}
