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
    /// The switch the whole game feels through. The shared one by default, since a toggle
    /// wired to anything else would move a switch nothing is listening to.
    @Bindable var haptics: Haptics = .shared
    /// The switch everything the game counts goes through, on the same terms as the
    /// buzzing: the shared one, so the toggle moves the thing it names.
    @Bindable var analytics: Analytics = .shared

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
                        counting
                        gameData
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
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
                haptics: previewHaptics(),
                analytics: previewAnalytics()
            )
            .presentationDetents([.medium, .large])
        }
}

#Preview("Nothing saved") {
    SettingsView(
        progress: WorldProgress(store: RememberedProgress()),
        daily: DailyProgress(store: RememberedDailyRecords()),
        haptics: previewHaptics(),
        analytics: previewAnalytics()
    )
}

#Preview("Haptics off") {
    SettingsView(
        progress: .partWayThrough(),
        daily: DailyProgress(store: RememberedDailyRecords()),
        haptics: previewHaptics(isOn: false),
        analytics: previewAnalytics()
    )
}
