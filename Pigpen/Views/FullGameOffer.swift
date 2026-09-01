import SwiftUI

/// Where the offer of the full game was raised, so it can say the right analytics word and,
/// on the smallest phones, so the sheet knows which wall the player just walked into.
enum FullGameOfferSource: String {
    /// A locked world on the universe map.
    case map
    /// A day out of the archive that is not today.
    case archive
    /// The upgrade card behind the gear.
    case settings
}

/// The offer of the full game: what buying it opens, what it costs, and the one button that
/// buys it — with the restore every store makes an app keep beside it.
///
/// One sheet, raised from all three places the wall stands: a locked world on the map, a shut
/// day in the archive, and the card in settings. It says the same thing in each, because the
/// purchase is the same purchase — the meadow and the day are free, and this opens the rest of
/// the map and the rest of the book of days, once, for good.
///
/// It closes itself the moment the game is unlocked, whichever way that happened: the player
/// bought it here, restored it here, or an approval the store was waiting on came through while
/// the sheet was up.
@MainActor
struct FullGameOffer: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    /// The switch the whole game feels through. Handed in so a preview can stand it up owned,
    /// refusing, or priced, but the shared one in the game itself.
    var fullGame: FullGame = .shared
    /// Where the offer was raised from, counted so the funnel knows which wall does the work.
    let source: FullGameOfferSource

    /// What the last purchase or restore had to say for itself, once it has said anything —
    /// a pending ask, a restore that found nothing, or something gone wrong. Held so the
    /// sheet can answer in place rather than vanishing on an ending that is not a sale.
    @State private var note: Note?

    private enum Note: Equatable {
        case pending
        case nothingToRestore
        case failed
        case unavailable
    }

    var body: some View {
        ZStack {
            // A cream page rather than timber, the same as the settings sheet, with the
            // card separated from it by its own dark shadow.
            LinearGradient(
                colors: [GamePalette.mudLit, GamePalette.mud],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    offer
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .task {
            // The price is usually in hand by the time the sheet opens — the game asks for it
            // at launch — but a first run that reaches the wall quickly might beat it here, so
            // ask again rather than show a button with no price on it.
            if fullGame.price == nil { await fullGame.reconcile() }
        }
        // Closes on the unlock however it arrived: bought here, restored here, or an approval
        // the store was holding that came through while this was up.
        .onChange(of: fullGame.isUnlocked) { _, unlocked in
            if unlocked { dismiss() }
        }
    }

    // MARK: - Pieces

    /// The whole offer in one box: what the money buys, and the button that buys it.
    ///
    /// It used to be two, which drew a line across the middle of a single thought and left
    /// the reader to decide whether the second box was more of the same offer or a different
    /// one. There is only one thing being sold here, so there is one card.
    private var offer: some View {
        card {
            pitch
            buy
        }
        .animation(.easeInOut(duration: 0.2), value: note)
        .animation(.easeInOut(duration: 0.2), value: fullGame.isWorking)
    }

    /// The way out, and nothing else. The sheet used to name itself over the top of the card
    /// below, which then named the same thing again in the heading that says what the money
    /// buys — so the bar keeps the close button and gives the rest of its width back.
    private var header: some View {
        HStack(spacing: 12) {
            Spacer(minLength: 0)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(GamePalette.post)
                    .frame(width: 34, height: 34)
                    .background {
                        Circle()
                            .fill(GamePalette.cream)
                            .overlay(
                                Circle().strokeBorder(
                                    GamePalette.post.opacity(0.15), lineWidth: 1
                                )
                            )
                            .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
                    }
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// What the money buys, said in the three things it opens: the rest of the markets, the
    /// days already gone, and the promise that none of it is paid for twice.
    ///
    /// The heading is the thing being bought rather than a line of warmth about it, so a
    /// player reading one line of this card reads the one that answers their question. The
    /// days are named as the past, because that is what is actually behind the wall — today's
    /// board is free and always will be, and calling the archive "every day" invited the
    /// reading that a daily is what is being sold.
    ///
    /// The last perk is the absence of a thing, which is worth as much room as the two
    /// presences above it: a one-off purchase in a game with no advertising in it is a
    /// different offer from the same price in a game that has some, and the player cannot see
    /// the difference from inside a paywall unless it is said.
    @ViewBuilder
    private var pitch: some View {
        Text("Unlock the full game")
            .font(.headline.weight(.heavy))
            .foregroundStyle(GamePalette.post)

        Text(
            """
            Help Pig explore every market imaginable. Twelve worlds in the universe, each \
            with its own challenges and its own boss at the top.
            """
        )
        .font(.footnote.weight(.semibold))
        .foregroundStyle(GamePalette.post.opacity(0.7))
        .fixedSize(horizontal: false, vertical: true)

        perk(
            icon: "globe.americas.fill",
            title: "Every market",
            detail: "The whole universe map past the meadow — eleven more worlds, each with its own boss and its own send-off."
        )
        perk(
            icon: "calendar",
            title: "Every past puzzle",
            detail: "The whole archive behind today — every daily puzzle there has ever been, any day you like."
        )
        perk(
            icon: "hand.raised.slash.fill",
            title: "Never any ads",
            detail: "There are none in Pigpen and there never will be. You buy it once and that is the end of it."
        )
    }

    private func perk(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(GamePalette.rail)
                .frame(width: 34, height: 34)
                .background(Circle().fill(GamePalette.rail.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
    }

    /// The button that buys it, the restore beside it, and the small print underneath —
    /// everything the store asks an offer to carry.
    @ViewBuilder
    private var buy: some View {
        Button {
            Task { await purchase() }
        } label: {
            Label(buyTitle, systemImage: "lock.open.fill")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(tint: GamePalette.pen, depth: 6))
        .disabled(fullGame.isWorking)
        .opacity(fullGame.isWorking ? 0.6 : 1)
        // The perks end where this begins now that one box holds both.
        .padding(.top, 6)

        Button {
            Task { await restore() }
        } label: {
            Text("Restore a purchase")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(GamePalette.rail)
                .frame(maxWidth: .infinity)
        }
        .disabled(fullGame.isWorking)
        .padding(.top, 2)

        // Everything under the button is centred on it. The card reads left to right down to
        // the purchase and then stops being a list, so the terms and the policy line up under
        // the thing they are the terms of rather than trailing off the left edge of it.
        if let note {
            Text(words(for: note))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(note == .pending ? GamePalette.post.opacity(0.7) : GamePalette.barn)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
        }

        Text("A one-time purchase. Restores free on every device you sign in to.")
            .font(.caption2)
            .foregroundStyle(GamePalette.post.opacity(0.55))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)

        Button {
            openURL(SupportLinks.privacy)
        } label: {
            Text("Privacy policy")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(GamePalette.rail)
                .frame(maxWidth: .infinity)
        }
    }

    /// The button's own words: the price when the store has handed one over, and a plain
    /// invitation when it has not — a button that will not sit there blank while the price
    /// is still on its way.
    private var buyTitle: String {
        if fullGame.isWorking { return "One moment…" }
        if let price = fullGame.price { return "Unlock the full game · \(price)" }
        return "Unlock the full game"
    }

    private func words(for note: Note) -> String {
        switch note {
        case .pending:
            "Waiting on approval. The full game opens as soon as it comes through — nothing more to do here."
        case .nothingToRestore:
            "Nothing to restore on this Apple ID yet. Buying it above is what puts it there."
        case .failed:
            "That didn't go through, and you have not been charged. Have another go in a moment."
        case .unavailable:
            "The App Store could not be reached just now. Check the connection and try again."
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    // MARK: - Actions

    private func purchase() async {
        Haptics.tap(.medium)
        note = nil
        let outcome = await fullGame.buy()
        Analytics.record(.purchaseFinished(outcome: outcome.word))
        switch outcome {
        case .unlocked:
            // The onChange on `isUnlocked` closes the sheet and the world behind it is open;
            // a buzz to mark the fence coming down.
            Haptics.buzz(.success)
        case .cancelled:
            break
        case .pending:
            note = .pending
        case .failed:
            note = .failed
        case .unavailable:
            note = .unavailable
        }
    }

    private func restore() async {
        Haptics.tap(.light)
        note = nil
        let restored = await fullGame.restore()
        Analytics.record(.restoreFinished(restored: restored))
        if restored {
            Haptics.buzz(.success)
        } else {
            note = .nothingToRestore
        }
    }
}

extension PurchaseOutcome {
    /// The word this outcome goes under on a chart, matched to what `purchaseFinished` reads.
    var word: String {
        switch self {
        case .unlocked: "unlocked"
        case .cancelled: "cancelled"
        case .pending: "pending"
        case .failed: "failed"
        case .unavailable: "unavailable"
        }
    }
}

#Preview("Priced") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FullGameOffer(fullGame: .locked(), source: .map)
                .presentationDetents([.medium, .large])
        }
}

#Preview("Price still on its way") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FullGameOffer(fullGame: .locked(price: nil), source: .archive)
                .presentationDetents([.medium, .large])
        }
}
