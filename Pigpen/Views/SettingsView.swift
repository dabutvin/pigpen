import SwiftUI
import UIKit

/// What is behind the gear on the title screen: which version of the game this is, whether
/// the phone is allowed to buzz, how far the player has got, and the one button that hands
/// it all back.
///
/// Nothing in here is part of playing, so it stays out of the way on a sheet rather than
/// taking a screen of its own — and the button that throws away every star a player owns
/// asks before it does anything.
@MainActor
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    /// The way out to the two pages the game keeps on the web.
    @Environment(\.openURL) private var openURL

    let progress: WorldProgress
    /// The book of days goes with the meadow's stars: a player asking for the game back as
    /// they found it means all of it, dailies included.
    let daily: DailyProgress
    /// The daily reminder. Here rather than only on the sheet that offers it, because a
    /// player who waved that offer away has to be able to find it afterwards, and one who
    /// took it has to be able to move the hour or stop it.
    ///
    /// Handed in rather than made here, and made nowhere else either: the title screen owns
    /// the one reminder the game has, so this card and the fortnight it lays down are always
    /// talking about the same switch.
    let reminder: DailyReminder
    /// Every film in the game, in the order the journey meets them. Handed in rather than
    /// reached for inside the card so a preview can put a short reel behind the button.
    var reel: FilmReel = .everything
    /// The switch the whole game feels through. The shared one by default, since a toggle
    /// wired to anything else would move a switch nothing is listening to.
    @Bindable var haptics: Haptics = .shared
    /// The switch everything the game counts goes through, on the same terms as the
    /// buzzing: the shared one, so the toggle moves the thing it names.
    @Bindable var analytics: Analytics = .shared
    /// Whether the full game has been bought. The card it draws is the third door to the
    /// offer — beside the locked worlds on the map and the shut days in the archive — and
    /// the one place a player who already owns it can be told so.
    var fullGame: FullGame = .shared

    /// Whether the projection room is up: every film in the game, one after another.
    @State private var isWatchingFilms = false
    /// Raised by the clear button. Nothing is erased until the prompt it puts up says so.
    @State private var isAsking = false
    /// Whether the offer of the full game is up, raised by the card's own button.
    @State private var isOffering = false
    /// Remembered so that the card says something after it empties, rather than simply
    /// reading as though the player had never played.
    @State private var hasCleared = false

    private var world: WorldMap { progress.world }
    private var hasSomethingToClear: Bool {
        progress.clearedCount > 0 || daily.completedCount > 0 || daily.hasDrafts
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GamePalette.rail, GamePalette.post],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 14) {
                        about
                        fullGameCard
                        help
                        films
                        feel
                        reminders
                        counting
                        gameData
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // Permission is granted and taken away in the system settings, which is a place
        // this screen cannot see into. Reading it on the way in is what lets the card admit
        // that the phone has stopped passing the reminders on.
        .task { await reminder.readTheStanding() }
        // Over the whole screen rather than on another card of this sheet: a film is shown
        // between black bars with nothing else on the glass, and a reel of them is no different.
        .fullScreenCover(isPresented: $isWatchingFilms) {
            FilmReelView(reel: reel)
        }
        .sheet(isPresented: $isOffering) {
            FullGameOffer(fullGame: fullGame, source: .settings)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Clear all game data?", isPresented: $isAsking) {
            Button("Cancel", role: .cancel) {}
            Button("Clear everything", role: .destructive) { clearEverything() }
        } message: {
            Text(
                """
                Every star you have earned, every level you have opened and every daily \
                puzzle you have held will be forgotten, and \(world.name) goes back to its \
                first puzzle. There is no getting them back.
                """
            )
        }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            Text("Settings")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.cream)
                .shadow(color: .black.opacity(0.35), radius: 3, y: 1)

            Spacer(minLength: 0)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(GamePalette.post)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(GamePalette.cream))
            }
            .accessibilityLabel("Close settings")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// The name, set as it is on the title screen, and the version underneath it — which
    /// is the number a player reads out when something has gone wrong.
    private var about: some View {
        card {
            Text("PIGPEN")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .tracking(3)
                .foregroundStyle(GamePalette.post)
                .accessibilityLabel("Pigpen")

            Text(version)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(GamePalette.post.opacity(0.7))
        }
    }

    /// The third door to the full game, and the only one a player who already owns it ever
    /// sees: a card that offers the upgrade while it is locked, and thanks the player who has
    /// bought it once it is theirs — so somebody who paid is never shown a button asking them
    /// to pay again.
    ///
    /// While locked it opens the same offer sheet the map and the archive raise, restore and
    /// all, rather than keeping a second buy button of its own that could drift from theirs.
    @ViewBuilder
    private var fullGameCard: some View {
        if fullGame.isUnlocked {
            card {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(GamePalette.clover)
                    Text("The full game")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(GamePalette.post)
                }

                Text("Every world and every day is yours. Thank you for buying Pigpen.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(GamePalette.post.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            card {
                Text("The full game")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)

                Text(
                    """
                    The meadow and today's board are free. Unlock the rest of the worlds and \
                    the whole archive — once, for good.
                    """
                )
                .font(.footnote.weight(.semibold))
                .foregroundStyle(GamePalette.post.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

                Button {
                    haptics.tap(.medium)
                    Analytics.record(.offerShown(from: FullGameOfferSource.settings.rawValue))
                    isOffering = true
                } label: {
                    Label(unlockTitle, systemImage: "lock.open.fill")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(GamePalette.post)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(tint: GamePalette.pen, depth: 5))
                .padding(.top, 4)
            }
        }
    }

    /// The card's button, with the price on it when the store has handed one over.
    private var unlockTitle: String {
        if let price = fullGame.price { return "Unlock the full game · \(price)" }
        return "Unlock the full game"
    }

    /// The way out of the game to a person.
    ///
    /// A player who has hit something broken has, until now, had nowhere to say so from
    /// inside the game — and a reviewer looking for the support page has had nowhere to find
    /// it either. The button opens the page; the address underneath it is there in plain text
    /// for the phone that is not on a network, or the player who would rather write from
    /// their own mail app than be handed one.
    private var help: some View {
        card {
            Text("Help")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Text(
                """
                Something broken, something confusing, or an idea for the game — the support \
                page has the common questions on it, and an address that reaches a person.
                """
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(GamePalette.post.opacity(0.7))
            .fixedSize(horizontal: false, vertical: true)

            Button {
                open(SupportLinks.support, as: "support")
            } label: {
                Label("Support and contact", systemImage: "lifepreserver.fill")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 5))
            .padding(.top, 4)

            Text("Or write to \(SupportLinks.email).")
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.55))
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// The daily reminder: whether the game says anything when a new board goes up, and at
    /// what hour.
    ///
    /// The switch is the player's wish and the line under it is the phone's answer, and the
    /// two come apart the moment somebody turns this game's notifications off in the system
    /// settings. When they do, the card says so and hands over the only door that can put
    /// it right, rather than sitting on a switch that is on and silent.
    private var reminders: some View {
        card {
            Text("Daily puzzle reminder")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Toggle(isOn: wantsReminding) {
                Text("Remind me when a new board goes up")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
            }
            .tint(GamePalette.clover)

            if reminder.isOn, !reminder.isBeingRefused {
                DatePicker(
                    selection: hour,
                    displayedComponents: .hourAndMinute
                ) {
                    Text("At")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(GamePalette.post)
                }
                .tint(GamePalette.rail)

                Text(planned)
                    .font(.caption2)
                    .foregroundStyle(GamePalette.post.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if reminder.isBeingRefused {
                refusal
            }
        }
        .animation(.easeInOut(duration: 0.25), value: reminder.isOn)
        .animation(.easeInOut(duration: 0.25), value: reminder.isBeingRefused)
    }

    /// What to say when the player wants reminding and the phone will not pass it on. There
    /// is nothing the game can do about it from in here, so it says which door to go
    /// through and opens it.
    private var refusal: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "Notifications for Pigpen are turned off on this phone, so nothing will come through.",
                systemImage: "exclamationmark.triangle.fill"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(GamePalette.barn)
            .fixedSize(horizontal: false, vertical: true)

            Button {
                Haptics.tap(.light)
                openTheSystemSettings()
            } label: {
                Label("Open iPhone Settings", systemImage: "arrow.up.forward.app.fill")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 4))
        }
        .padding(.top, 2)
    }

    /// The buzzing, and the switch that stops it.
    ///
    /// Turning it on gives the tap it is promising straight away, so the switch answers in
    /// the thing it governs rather than in words. Turning it off says nothing, which is the
    /// whole point of turning it off.
    private var feel: some View {
        card {
            Text("Feel")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Toggle(isOn: $haptics.isOn) {
                Text("Haptics")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
            }
            .tint(GamePalette.clover)
            .onChange(of: haptics.isOn) { _, on in
                haptics.tap(.medium)
                Analytics.record(.hapticsSwitched(on: on))
            }

            Text("The little buzz as fencing goes in, a pen holds, or the pig gets away.")
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// What the game counts, and the switch that stops it.
    ///
    /// It says what is counted in the same words it would be said in out loud, because a
    /// player deciding whether to leave it on deserves the actual answer rather than a
    /// link to one: which puzzles are played, how they went, and nothing else. There is no
    /// name here, no account, no advertising identifier and nothing that leaves the phone
    /// with a player's name on it — which is why the switch sits here rather than in front
    /// of a game a child might be opening.
    private var counting: some View {
        card {
            Text("Privacy")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Toggle(isOn: $analytics.isOn) {
                Text("Anonymous usage")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.post)
            }
            .tint(GamePalette.clover)
            .onChange(of: analytics.isOn) { _, _ in
                haptics.tap(.medium)
            }

            Text(
                """
                Which puzzles get played and how they go — stars, scores, and how many \
                goes a pen took. It is what says which levels are too hard. No name, no \
                account, no advertising identifier, and nothing that says who you are.
                """
            )
            .font(.caption2)
            .foregroundStyle(GamePalette.post.opacity(0.55))
            .fixedSize(horizontal: false, vertical: true)

            // The words above are the whole of what the game counts, and the policy says the
            // same thing at length. The button is here rather than only on the store listing
            // because this card is where somebody wondering about it is standing.
            Button {
                open(SupportLinks.privacy, as: "privacy")
            } label: {
                Label("Privacy policy", systemImage: "hand.raised.fill")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 5))
            .padding(.top, 4)
        }
    }

    /// Every film in the game, and the way back to them.
    ///
    /// A film plays once, where it means something, and a player who skipped one or wants the
    /// story told to them again has had no way back to any of it. This is that way back: the
    /// whole reel end to end, in the order the journey meets them, with Skip moving on to the
    /// next film rather than out of the lot.
    ///
    /// It is the whole game's films rather than the ones a player has earned, and the line under
    /// the button says so plainly, since somebody a world in is being offered eleven worlds of
    /// story they have not reached. Watching them here changes nothing the game remembers: every
    /// film still plays where it belongs, to the player who has got there.
    private var films: some View {
        card {
            Text("Cut scenes")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Text(
                """
                Every film in the game, one after another: the opening, the boss briefing \
                and the send-off of every world there is. Tap to move on, swipe back for the \
                one before.
                """
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(GamePalette.post.opacity(0.7))
            .fixedSize(horizontal: false, vertical: true)

            Button {
                haptics.tap(.medium)
                Analytics.record(.reelOpened)
                isWatchingFilms = true
            } label: {
                Label("Watch every cut scene", systemImage: "film.fill")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail, depth: 5))
            .padding(.top, 4)

            Text(runningOrder)
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Everything the game has kept, and the way to be rid of it.
    private var gameData: some View {
        card {
            Text("Game data")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Text(saved)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(GamePalette.post.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                haptics.tap(.medium)
                isAsking = true
            } label: {
                Label("Clear all game data", systemImage: "trash.fill")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(GamePalette.cream)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.barn, depth: 5))
            .disabled(!hasSomethingToClear)
            .opacity(hasSomethingToClear ? 1 : 0.45)
            .padding(.top, 4)

            Text("You will be asked first. It cannot be undone.")
                .font(.caption2)
                .foregroundStyle(GamePalette.post.opacity(0.55))
        }
        .animation(.easeInOut(duration: 0.25), value: progress.totalStars)
        .animation(.easeInOut(duration: 0.25), value: daily.completedCount)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .shadow(color: .black.opacity(0.22), radius: 6, y: 4)
    }

    // MARK: - Words

    /// What is running. The build number is a timestamp on anything that came from
    /// TestFlight, so it says which build a player is actually holding.
    private var version: String {
        let info = Bundle.main.infoDictionary
        let marketing = info?["CFBundleShortVersionString"] as? String ?? "0.1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(marketing) (\(build))"
    }

    /// What is on the reel and how long it takes, said before the button is pressed rather than
    /// found out eight minutes in — and the warning that goes with it, since the reel holds the
    /// story of worlds a player may be nowhere near.
    private var runningOrder: String {
        let minutes = max(1, Int((reel.runtime / 60).rounded()))
        return """
            \(counted(reel.count, "film")), about \(counted(minutes, "minute")) in all — \
            including the worlds you have not reached yet.
            """
    }

    private var saved: String {
        if hasCleared {
            return "Cleared. \(world.name) is as it comes."
        }
        guard hasSomethingToClear else {
            return "Nothing saved yet — \(world.name) is as it comes."
        }
        let meadow = """
            \(progress.totalStars) of \(world.starTotal) stars, \
            \(progress.clearedCount) of \(world.count) puzzles complete.
            """
        guard daily.completedCount > 0 else { return meadow }
        return meadow + " \(counted(daily.completedCount, "daily puzzle")) as well."
    }

    private func counted(_ number: Int, _ noun: String) -> String {
        "\(number) \(noun)\(number == 1 ? "" : "s")"
    }

    /// What the reminder is going to do, under the hour it is set to. The fortnight is said
    /// out loud because it is the one surprising thing about it: the game lays down every
    /// morning it can see ahead at once, so it goes on reminding through a fortnight the
    /// player never opens it.
    private var planned: String {
        "A reminder at \(reminder.time.face), on any morning you have not already held the day."
    }

    // MARK: - The switch

    /// The player's wish, read out of the reminder and written back through it. Turning it
    /// on is a conversation with the phone rather than a flag, so the switch may come back
    /// off — which is exactly what should happen when the phone says no.
    private var wantsReminding: Binding<Bool> {
        Binding(
            get: { reminder.isOn && !reminder.isBeingRefused },
            set: { wanted in
                Haptics.tap(.light)
                Task {
                    if wanted {
                        // The phone's answer travels with the player's, the same way it does
                        // on the offer sheet: a switch that comes straight back off is a
                        // refusal, and a refusal counted as an opt-out would read as somebody
                        // changing their mind.
                        let allowed = await reminder.turnOn(progress: daily)
                        Analytics.record(.reminderSwitched(on: true, allowed: allowed))
                    } else {
                        await reminder.turnOff()
                        Analytics.record(.reminderSwitched(on: false))
                    }
                }
            }
        )
    }

    /// The hour, as the picker wants it: a moment on today's date with the right o'clock on
    /// it. Only the hour and the minute are read back out, since the day is the picker's
    /// scaffolding rather than anything the reminder keeps.
    private var hour: Binding<Date> {
        Binding(
            get: { reminder.time.on(Date()) },
            set: { moved in
                let wanted = ReminderTime(of: moved)
                // Counted only when the hour actually moves. A picker being dragged emits a
                // set on every step it passes through, and an hour reported forty times on
                // the way from nine to seven is forty rows saying nothing.
                guard wanted != reminder.time else { return }
                Analytics.record(.reminderHourChanged(to: wanted))
                Task { await reminder.change(to: wanted, progress: daily) }
            }
        )
    }

    // MARK: - Actions

    private func clearEverything() {
        // Said before it is thrown away, since the number it would be counted under is one
        // of the things going. What survives is the switch itself: a player who turned
        // counting off and then cleared their stars has not asked to be counted again.
        Analytics.record(.dataCleared)
        Analytics.flush()
        progress.eraseEverything()
        daily.eraseEverything()
        analytics.eraseEverything()
        hasCleared = true
        haptics.buzz(.success)
        // The reminder is a preference rather than progress, so it survives — but what it had
        // planned does not. Every day is unheld again, so every morning is worth reminding
        // about again, and the fortnight has to be laid down knowing that.
        Task { await reminder.replan(progress: daily) }
    }

    /// Out to one of the game's own pages on the web. Counted by which page rather than by
    /// the address, so the signal survives the day the pages move.
    private func open(_ page: URL, as name: String) {
        haptics.tap(.light)
        Analytics.record(.pageOpened(name))
        openURL(page)
    }

    /// The one door out of the game, for the phone that has stopped passing reminders on.
    private func openTheSystemSettings() {
        guard let door = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(door)
    }
}

/// A switch held in memory, so that flicking the toggle in a preview is not a change to the
/// setting on the machine the preview is running on.
@MainActor
private func previewHaptics(isOn: Bool = true) -> Haptics {
    Haptics(store: RememberedHaptics(isOn: isOn), engine: RecordedHaptics())
}

/// Counting held in memory and going nowhere, so that flicking the toggle in a preview
/// neither changes the setting on this machine nor puts a preview on the charts.
@MainActor
private func previewAnalytics(isOn: Bool = true) -> Analytics {
    Analytics(store: RememberedAnalytics(isOn: isOn), sink: RecordedAnalytics())
}

#Preview("Part way through") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SettingsView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
                reminder: .reminding(),
                haptics: previewHaptics(),
                analytics: previewAnalytics(),
                fullGame: .locked()
            )
            .presentationDetents([.medium, .large])
        }
}

#Preview("The full game bought") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SettingsView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
                reminder: .reminding(),
                haptics: previewHaptics(),
                analytics: previewAnalytics(),
                fullGame: .unlocked()
            )
            .presentationDetents([.medium, .large])
        }
}

#Preview("Nothing saved") {
    SettingsView(
        progress: WorldProgress(store: RememberedProgress()),
        daily: DailyProgress(store: RememberedDailyRecords()),
        reminder: .neverAsked(),
        haptics: previewHaptics(),
        analytics: previewAnalytics()
    )
}

#Preview("The phone is refusing") {
    SettingsView(
        progress: .partWayThrough(),
        daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
        reminder: .refused(),
        haptics: previewHaptics(),
        analytics: previewAnalytics()
    )
}

#Preview("Haptics off") {
    SettingsView(
        progress: .partWayThrough(),
        daily: DailyProgress(store: RememberedDailyRecords()),
        reminder: .reminding(),
        haptics: previewHaptics(isOn: false),
        analytics: previewAnalytics()
    )
}
