import SwiftUI

/// Where the offer of the full game was raised, so it can say the right analytics word and,
/// on the smallest phones, so the sheet knows which wall the player just walked into.
enum FullGameOfferSource: String {
    /// A locked world on the universe map.
    case map
    /// A level on a world's trail that the free game has not handed over yet — the next one
    /// past the meadow, with the day's wait still on it.
    case trail
    /// A day out of the archive that is not today.
    case archive
    /// The upgrade card behind the gear.
    case settings
}

/// The offer of the full game: what buying it opens, what it costs, and the one button that
/// buys it — with the restore every store makes an app keep beside it.
///
/// One sheet, raised from all four places the wall stands: a locked world on the map, a level
/// still waiting on the free game's clock up a trail, a shut day in the archive, and the card in
/// settings. It says the same thing in each, because the purchase is the same purchase — the
/// meadow and the day are free, the worlds past the meadow come a level a day, and this opens
/// the whole map at once and the rest of the book of days, once, for good.
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
    /// How long the trail is making the player wait for their next free level, when that is
    /// the wall they walked into. Said on the first perk, so the offer answers the thing the
    /// player just met: the wait, and the fact that buying the game ends it.
    var wait: LevelWait? = nil
    /// The offer of a reminder for when the wait is up, made on the same sheet as the offer to
    /// end it: see `LevelNudge`. Nothing everywhere but the wait up a trail.
    var nudge: LevelNudge? = nil
    /// Every ask the game has made lately. The store's own offer is written into it, so the
    /// others know to keep clear; the reminder offered here reads it to stay clear of them.
    var asks: AskLedger = .shared

    /// Where the reminder offered at the wait has got to, while this sheet is up.
    @State private var nudging: Nudging = .notShown

    private enum Nudging: Equatable {
        /// Not offered here: not the wait, or not due, or too soon after another ask.
        case notShown
        /// Up, and not yet answered.
        case offered
        /// Taken, and what the phone said to it.
        case taken(allowed: Bool)
    }

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
        page
            // A cream page, wherever it is raised from — including over the starfield of
            // the universe map, which is the one screen in the game that is night.
            .staysInDaylight()
    }

    private var page: some View {
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
        .onAppear { asks.note(.store) }
        .task {
            // The price is usually in hand by the time the sheet opens — the game asks for it
            // at launch — but a first run that reaches the wall quickly might beat it here, so
            // ask again rather than show a button with no price on it.
            if fullGame.price == nil { await fullGame.reconcile() }
        }
        .task { await offerTheNudgeIfItIsDue() }
        // A reminder offered and left unanswered is a *Not now*: the sheet has no button that
        // says so, since closing it says so.
        .onDisappear {
            guard nudging == .offered else { return }
            Analytics.record(.reminderAnswered(about: .level, taken: false))
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
            if nudging != .notShown {
                nudgeRow
            }
            pitch
            buy
        }
        .animation(.easeInOut(duration: 0.2), value: note)
        .animation(.easeInOut(duration: 0.2), value: fullGame.isWorking)
    }

    /// What is being sold, and the way out of being sold it. The name sits up here on the page
    /// rather than inside the card, so the card is only the offer itself — what the money buys
    /// and the button that spends it — and the player reads the title before the box, the way
    /// a title is read.
    private var header: some View {
        HStack(spacing: 12) {
            Text(headline)
                .font(.title3.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    // No disc under it, but the tap target stays the size the disc was.
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// What the money buys, said in the three things it opens: the rest of the levels, the
    /// days already gone, and the promise that none of it is paid for twice.
    ///
    /// The card is the three perks and nothing before them. It used to open with a paragraph
    /// of warmth about exploring every market, which said in prose what the first perk says in
    /// a line, under a title that had already named the thing — so the reader met the offer
    /// three times before reaching the price. The days are named as the past, because that is
    /// what is actually behind the wall — today's board is free and always will be, and calling
    /// the archive "every day" invited the reading that a daily is what is being sold.
    ///
    /// The last perk is the absence of a thing, which is worth as much room as the two
    /// presences above it: a one-off purchase in a game with no advertising in it is a
    /// different offer from the same price in a game that has some, and the player cannot see
    /// the difference from inside a paywall unless it is said.
    @ViewBuilder
    private var pitch: some View {
        perk(
            icon: "globe.americas.fill",
            title: "Every level, right away",
            detail: everyLevel
        )
        perk(
            icon: "calendar",
            title: "Every daily puzzle",
            detail: "Get access to every daily puzzle including all past puzzles."
        )
        perk(
            icon: "hand.raised.slash.fill",
            title: "Never any ads",
            detail: "Pigpen will never have any ads. Buy it once, it is yours forever."
        )
    }

    /// What the sheet is called. At the wait up a trail it says when the next level opens
    /// before it says anything about money, so the wall reads as progress — the next level is
    /// coming — with the purchase as the way to skip the wait rather than the only way on.
    private var headline: String {
        if let wait { return "Next level in \(wait.spoken)" }
        return "Unlock the full game"
    }

    /// What the first perk says. The free game already reaches every world, one level a day,
    /// so what the money buys there is the waiting taken away — and a player who has just been
    /// told how long the wait is, in the title, has the way round it said back to them.
    private var everyLevel: String {
        if wait != nil {
            return "Or skip the wait: unlock the full game and every level in every world "
                + "is open today."
        }
        return "Help Pig explore the whole universe with no waiting. The free game opens one "
            + "level a day past the meadow; this opens all of them at once."
    }

    private func perk(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(GamePalette.clay)
                .frame(width: 34, height: 34)
                .background(Circle().fill(GamePalette.clay.opacity(0.14)))

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
                .foregroundStyle(GamePalette.cream)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(tint: GamePalette.clay, depth: 6))
        .disabled(fullGame.isWorking)
        .opacity(fullGame.isWorking ? 0.6 : 1)
        // The perks are a list and this is not part of it: a wider gap than the one between
        // perks marks where reading stops and buying starts.
        .padding(.top, 18)

        Button {
            Task { await restore() }
        } label: {
            Text("Restore a purchase")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(GamePalette.clayShade)
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
                .foregroundStyle(GamePalette.clayShade)
                .frame(maxWidth: .infinity)
        }
    }

    /// The button's own words: the price when the store has handed one over, and a plain
    /// invitation when it has not — a button that will not sit there blank while the price
    /// is still on its way.
    private var buyTitle: String {
        if fullGame.isWorking { return "One moment…" }
        let words = wait == nil ? "Unlock the full game" : "Unlock everything now"
        if let price = fullGame.price { return "\(words) · \(price)" }
        return words
    }

    // MARK: - The reminder at the wait

    /// The offer of a reminder when the wait is up, at the top of the card: the free way on,
    /// before the paid one.
    @ViewBuilder
    private var nudgeRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(GamePalette.clay)
                .frame(width: 34, height: 34)
                .background(Circle().fill(GamePalette.clay.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(nudgeTitle)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
                if let detail = nudgeDetail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(GamePalette.post.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            if nudging == .offered {
                Button {
                    Task { await takeTheNudge() }
                } label: {
                    Text("Remind me")
                        .font(.footnote.weight(.heavy))
                }
                .buttonStyle(.bordered)
                .tint(GamePalette.clay)
            }
        }
        .padding(.bottom, 12)
        .accessibilityElement(children: .combine)
    }

    private var nudgeTitle: String {
        switch nudging {
        case .taken(allowed: true): "We'll nudge you when it opens"
        case .taken(allowed: false): "Notifications are off for Pigpen"
        default: "Want a nudge when your next level opens?"
        }
    }

    private var nudgeDetail: String? {
        switch nudging {
        case .taken(allowed: false): "Turn them on in the Settings app to be reminded."
        case .taken(allowed: true): nil
        default: nudge.map { "Pig will let you know the moment \($0.level.worldName) has another level." }
        }
    }

    /// Puts the reminder's offer up if this is the wait, the offer is due, and the game has
    /// not just asked something else. Marked as made the moment it shows, whatever comes of
    /// it, the same as the offer on the title screen: it is made once.
    private func offerTheNudgeIfItIsDue() async {
        guard let nudge, wait != nil else { return }
        await nudge.reminder.readTheStanding()
        guard nudge.reminder.isDueALevelOffer,
              !asks.wasRecent(.reminder),
              !asks.isCrowded(for: .reminder, alongside: [.store])
        else { return }
        nudge.reminder.markLevelOffered()
        asks.note(.reminder)
        Analytics.record(.reminderOffered(about: .theNextLevel(in: nudge.level.worldName)))
        nudging = .offered
    }

    private func takeTheNudge() async {
        guard let nudge else { return }
        Haptics.tap(.light)
        Sounds.play(.press)
        let allowed = await nudge.reminder.turnOn(progress: nudge.daily, nextLevel: nudge.level)
        Analytics.record(.reminderAnswered(about: .level, taken: true, allowed: allowed))
        nudging = .taken(allowed: allowed)
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
        Sounds.play(.press)
        note = nil
        let outcome = await fullGame.buy()
        Analytics.record(.purchaseFinished(outcome: outcome.word, from: source.rawValue))
        switch outcome {
        case .unlocked:
            // The onChange on `isUnlocked` closes the sheet and the world behind it is open;
            // a buzz to mark the fence coming down.
            Haptics.buzz(.success)
            Sounds.play(.fanfare)
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
        Sounds.play(.press)
        note = nil
        let restored = await fullGame.restore()
        Analytics.record(.restoreFinished(restored: restored))
        if restored {
            Haptics.buzz(.success)
            Sounds.play(.fanfare)
        } else {
            note = .nothingToRestore
        }
    }
}

/// What the offer at the free game's wait needs to offer a reminder beside it: the reminder
/// itself, the book of days its mornings are laid down against, and the level it would be
/// reminding about.
struct LevelNudge {
    let reminder: DailyReminder
    let daily: DailyProgress
    let level: NextLevel
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

#Preview("Up a trail, mid-wait") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            FullGameOffer(fullGame: .locked(), source: .trail, wait: LevelWait(minutes: 14 * 60))
                .presentationDetents([.medium, .large])
        }
}
