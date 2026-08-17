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
    /// The switch the whole game feels through. The shared one by default, since a toggle
    /// wired to anything else would move a switch nothing is listening to.
    @Bindable var haptics: Haptics = .shared

    /// Raised by the clear button. Nothing is erased until the prompt it puts up says so.
    @State private var isAsking = false
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
                        feel
                        reminders
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
            .onChange(of: haptics.isOn) { _, _ in
                haptics.tap(.medium)
            }

            Text("The little buzz as fencing goes in, a pen holds, or the pig gets away.")
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
                        await reminder.turnOn(progress: daily)
                    } else {
                        await reminder.turnOff()
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
                Task { await reminder.change(to: ReminderTime(of: moved), progress: daily) }
            }
        )
    }

    // MARK: - Actions

    private func clearEverything() {
        progress.eraseEverything()
        daily.eraseEverything()
        hasCleared = true
        haptics.buzz(.success)
        // The reminder is a preference rather than progress, so it survives — but what it had
        // planned does not. Every day is unheld again, so every morning is worth reminding
        // about again, and the fortnight has to be laid down knowing that.
        Task { await reminder.replan(progress: daily) }
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

#Preview("Part way through") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SettingsView(
                progress: .partWayThrough(),
                daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
                reminder: .reminding(),
                haptics: previewHaptics()
            )
            .presentationDetents([.medium, .large])
        }
}

#Preview("Nothing saved") {
    SettingsView(
        progress: WorldProgress(store: RememberedProgress()),
        daily: DailyProgress(store: RememberedDailyRecords()),
        reminder: .neverAsked(),
        haptics: previewHaptics()
    )
}

#Preview("The phone is refusing") {
    SettingsView(
        progress: .partWayThrough(),
        daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
        reminder: .refused(),
        haptics: previewHaptics()
    )
}

#Preview("Haptics off") {
    SettingsView(
        progress: .partWayThrough(),
        daily: DailyProgress(store: RememberedDailyRecords()),
        reminder: .reminding(),
        haptics: previewHaptics(isOn: false)
    )
}
