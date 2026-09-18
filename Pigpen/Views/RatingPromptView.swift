import SwiftUI
import UIKit

/// The game's own question — *are you enjoying Pigpen?* — and whichever of the two doors the
/// answer opens.
///
/// When it goes up, and how rarely, is `RatingPrompt`'s to decide, and every reason for it is
/// written down there: a high point, at most once a version, never inside four months, and
/// never over anything. What is here is the asking, and it is in two steps for one reason.
/// Apple shows its rating prompt three times a year at the outside, says nothing either way,
/// and cannot be asked to take it back down — so the game had better be spending that on
/// somebody with something good to say.
///
/// **Yes, I am** hands the player on to Apple's prompt, which is the only thing in the game
/// allowed to take a rating: nothing here draws a star, and nothing here asks for words that
/// would stand in for a review.
///
/// **Not really** is not a decline and not a door shut in somebody's face. The card is swapped
/// for the one that reaches a person, because a player who says the game is letting them down
/// has just told the game something worth far more than the rating it was about to ask for,
/// and the worst thing to do with that is thank them and go away.
///
/// The cross is neither, and is counted as neither. Either way the question has been asked and
/// is not asked again on this version.
@MainActor
struct RatingPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Which of the two cards is up. The step lives here rather than at the title screen
    /// because it is the shape of one question being asked, not two sheets in a row: the page
    /// stays where it is and the card on it changes.
    @State private var step: Step

    /// Taken when the player says yes. Raising Apple's prompt is the caller's to do, and it
    /// does it as this sheet comes down rather than from underneath it — a prompt that cannot
    /// be taken back down must never arrive over a sheet still on its way out.
    private let onEnjoying: () -> Void
    /// Taken when the player says no, as the card that reaches a person goes up.
    private let onDisappointed: () -> Void
    /// Taken when they go on to open the draft or the support page, which is the half of a no
    /// that the game actually hears.
    private let onWritingIn: () -> Void
    /// Taken when the cross is pressed before either answer.
    private let onClose: () -> Void

    private enum Step { case asking, writing }

    /// - Parameter showsFeedback: Opens on the second card rather than the first. Never true
    ///   in the game, where the only way to that card is a player pressing *Not really* —
    ///   handed in so a preview can be taken of it without pressing through.
    init(
        showsFeedback: Bool = false,
        onEnjoying: @escaping () -> Void,
        onDisappointed: @escaping () -> Void,
        onWritingIn: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        _step = State(initialValue: showsFeedback ? .writing : .asking)
        self.onEnjoying = onEnjoying
        self.onDisappointed = onDisappointed
        self.onWritingIn = onWritingIn
        self.onClose = onClose
    }

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
                    Group {
                        switch step {
                        case .asking: question
                        case .writing: invitation
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // The second card arrives in the place the first one left rather than sliding in from
        // the side: nothing has been navigated to, it is the same question still being asked.
        .animation(swap, value: step)
        .staysInDaylight()
    }

    /// The crossfade from one card to the other, and nothing at all for anybody who has asked
    /// the phone for stillness.
    private var swap: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.2)
    }

    // MARK: - Pieces

    /// The question on the page, and the way out of being asked it.
    ///
    /// The cross is a real answer on the first card and no answer at all on the second: by
    /// then the player has already said the thing worth knowing, and shutting a card that is
    /// only an offer of an address is not them changing their mind about the game.
    private var header: some View {
        HStack(spacing: 12) {
            Text(step == .asking ? "Are you enjoying Pigpen?" : "What would make it better?")
                .font(.title3.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                Haptics.tap(.light)
                Sounds.play(.press)
                if step == .asking { onClose() }
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

    /// The first card: the two answers, weighted the same.
    ///
    /// Both of them are buttons of the same size, which is the whole honesty of the thing. A
    /// yes in wood over a no in small grey type is a sheet that has decided what it wants to
    /// hear, and a player who works that out has learned something about the game that no
    /// rating is going to make up for.
    private var question: some View {
        card {
            emblem("heart.fill")

            Text(
                """
                Whichever way you answer, we will only ask you this once.
                """
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(GamePalette.post.opacity(0.75))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    Haptics.tap(.medium)
                    Sounds.play(.press)
                    onEnjoying()
                    dismiss()
                } label: {
                    Label("Yes, I am", systemImage: "hand.thumbsup.fill")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(GamePalette.cream)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clover, depth: 6))

                Button {
                    Haptics.tap(.light)
                    Sounds.play(.press)
                    onDisappointed()
                    step = .writing
                } label: {
                    Text("Not really")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(GamePalette.cream)
                        .frame(maxWidth: .infinity)
                }
                // Bare wood beside the painted one: the same button, the same size, and
                // nothing about it that says which answer the sheet was hoping for.
                .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 6))
            }
            // A wider gap than the one between the two answers: what is being read ends here
            // and what is being answered begins.
            .padding(.top, 16)
        }
    }

    /// The second card, for a no: the draft, and the two ways to reach a person that do not
    /// need one.
    ///
    /// The draft is a button rather than an address to copy out, because the gap between
    /// meaning to say something and saying it is exactly the width of that copying. The page
    /// underneath it is there for the phone with no mail account on it, and the address under
    /// that is there for the phone with no connection — every one of them the same address.
    private var invitation: some View {
        card {
            emblem("envelope.fill")

            Text(
                """
                Sorry to hear it. Tell us what is going wrong and a person will read it — the \
                build you are on goes with the message, so there is nothing to look up.
                """
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(GamePalette.post.opacity(0.75))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 6) {
                if let draft = SupportLinks.feedback() {
                    Button {
                        Haptics.tap(.medium)
                        Sounds.play(.press)
                        onWritingIn()
                        openURL(draft)
                        dismiss()
                    } label: {
                        Label("Write to us", systemImage: "envelope.fill")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(GamePalette.cream)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
                }

                Button {
                    Haptics.tap(.light)
                    Sounds.play(.press)
                    onWritingIn()
                    openURL(SupportLinks.support)
                    dismiss()
                } label: {
                    Text("Open the support page")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(GamePalette.post.opacity(0.6))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }

                Text("Or write to \(SupportLinks.email).")
                    .font(.caption2)
                    .foregroundStyle(GamePalette.post.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // The same gap the first card leaves: what is being read ends here and what is
            // being answered begins — and it is left whether or not the draft can be built.
            .padding(.top, 16)
        }
    }

    /// The one cream card both steps are drawn on, so the page under them does not move when
    /// the card on it changes.
    private func card<Contents: View>(@ViewBuilder _ contents: () -> Contents) -> some View {
        VStack(spacing: 14) {
            contents()
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

    /// The mark at the top of a card, drawn the way the reminder's bell is.
    private func emblem(_ symbol: String) -> some View {
        Image(systemName: symbol)
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
}

#Preview("The question") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            RatingPromptView(onEnjoying: {}, onDisappointed: {}, onWritingIn: {}, onClose: {})
                .presentationDetents([.medium, .large])
        }
}

#Preview("Not really") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            RatingPromptView(
                showsFeedback: true,
                onEnjoying: {},
                onDisappointed: {},
                onWritingIn: {},
                onClose: {}
            )
            .presentationDetents([.medium, .large])
        }
}
