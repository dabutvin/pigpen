import SwiftUI
import UIKit

struct TitleScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.28),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                PigpenWordView(word: "PIGPEN", glyphSize: 46, lineWidth: 5)
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 10) {
                    Text("PIGPEN")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .tracking(10)

                    Text("Fence in the pig")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 14) {
                Spacer()

                NavigationLink {
                    PuzzleView(level: .riverBend)
                } label: {
                    Text("Play")
                        .font(.title3.weight(.bold))
                        .frame(maxWidth: 220)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Text("Puzzle 1 · \(PuzzleLevel.riverBend.name)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("Version \(appVersion)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }
}

#Preview {
    NavigationStack {
        TitleScreenView()
    }
}
