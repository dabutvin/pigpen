import SwiftUI
import UIKit

/// The game's own offer of a knock each morning, put up once, after the player has held a
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

    /// What the run of days stands at, so the offer can say what there is to keep rather
    /// than talk about streaks in the abstract.
    var streak = 0
    /// The hour the knock would come at, in the player's own reckoning of o'clock.
    var time: ReminderTime = .morning
    /// Taken when the player says yes. Raising the phone's prompt is the caller's to do,
    /// since it is the caller that holds the book of days the fortnight is planned against.
    var onAccept: () -> Void
    /// Taken when the player waves it away, so the offer is marked as made either way.
    var onDecline: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GamePalette.rail, GamePalette.post],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                gate

                VStack(spacing: 10) {
                    Text("A knock each morning?")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(GamePalette.post)
                        .multilineTextAlignment(.center)

                    Text(offer)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(GamePalette.post.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                buttons
            }
            .padding(22)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(GamePalette.cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
            .padding(26)
        }
    }

    // MARK: - Pieces

    /// A gate on a post, which is the thing being knocked at.
    private var gate: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: 34, weight: .black))
            .symbolRenderingMode(.palette)
            .foregroundStyle(GamePalette.barn, GamePalette.rail)
            .frame(width: 68, height: 68)
            .background {
                Circle()
                    .fill(GamePalette.pen.opacity(0.35))
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.15), lineWidth: 1))
            }
            .accessibilityHidden(true)
    }

    private var buttons: some View {
        VStack(spacing: 6) {
            Button {
                Haptics.tap(.medium)
                onAccept()
                dismiss()
            } label: {
                Label("Knock at \(time.face)", systemImage: "bell.fill")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.post)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.pen, depth: 6))

            Button {
                Haptics.tap(.light)
                onDecline()
                dismiss()
            } label: {
                Text("Not now")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }

            Text("You can change the hour, or stop it, behind the gear.")
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Words

    /// What there is to be reminded about. A player with a run going is told what the run
    /// is worth keeping; a player without one is told what a new board is.
    private var offer: String {
        guard streak > 1 else {
            return """
                There is a fresh board every morning, and a day gone by is a day gone. \
                Pigpen can knock once a day to say the new one is up.
                """
        }
        return """
            You are \(streak) days in a row. A run like that is broken by forgetting far \
            more often than by a board nobody could hold — so Pigpen can knock once a \
            morning to say the new one is up.
            """
    }
}

#Preview("Nothing to lose yet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ReminderPromptView(onAccept: {}, onDecline: {})
                .presentationDetents([.medium, .large])
        }
}

#Preview("A run going") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ReminderPromptView(streak: 6, time: ReminderTime(hour: 19, minute: 30), onAccept: {}, onDecline: {})
                .presentationDetents([.medium, .large])
        }
}
