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

                    Text("Decode the message")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 14) {
                Spacer()

                Text("Coming soon")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())

                Text("Version \(appVersion)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 20)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }
}

#Preview {
    TitleScreenView()
}
