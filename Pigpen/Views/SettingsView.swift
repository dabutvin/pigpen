import SwiftUI
import UIKit

/// What is behind the gear on the title screen: which version of the game this is, how far
/// the player has got, and the one button that hands it all back.
///
/// Nothing in here is part of playing, so it stays out of the way on a sheet rather than
/// taking a screen of its own — and the button that throws away every star a player owns
/// asks before it does anything.
@MainActor
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    let progress: WorldProgress

    /// Raised by the clear button. Nothing is erased until the prompt it puts up says so.
    @State private var isAsking = false
    /// Remembered so that the card says something after it empties, rather than simply
    /// reading as though the player had never played.
    @State private var hasCleared = false

    private var world: WorldMap { progress.world }
    private var hasSomethingToClear: Bool { progress.clearedCount > 0 }

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
                Every star you have earned and every level you have opened will be forgotten, \
                and \(world.name) goes back to its first puzzle. There is no getting them back.
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

    /// The name in cipher, as it is on the title screen, and the version underneath it —
    /// which is the number a player reads out when something has gone wrong.
    private var about: some View {
        card {
            PigpenWordView(word: "PIGPEN", glyphSize: 18, lineWidth: 2.5)
                .foregroundStyle(GamePalette.post)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Pigpen")

            Text(version)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(GamePalette.post.opacity(0.7))
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
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        return """
            \(progress.totalStars) of \(world.starTotal) stars, \
            \(progress.clearedCount) of \(world.count) pens held.
            """
    }

    // MARK: - Actions

    private func clearEverything() {
        progress.eraseEverything()
        hasCleared = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

#Preview("Part way through") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SettingsView(progress: .partWayThrough())
                .presentationDetents([.medium, .large])
        }
}

#Preview("Nothing saved") {
    SettingsView(progress: WorldProgress(store: RememberedProgress()))
}
