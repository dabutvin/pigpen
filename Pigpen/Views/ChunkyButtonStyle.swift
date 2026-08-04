import SwiftUI

/// A painted wooden button that sits on a ledge of its own shadow and sinks onto it when
/// pressed — the shape of button a game asks you to hit rather than a control you fill in.
struct ChunkyButtonStyle: ButtonStyle {
    /// The face of the button. The ledge underneath is the same colour, darkened.
    var face: Color = GamePalette.pen
    var depth: CGFloat = 7

    func makeBody(configuration: Configuration) -> some View {
        let sunk = configuration.isPressed

        return ZStack {
            Capsule(style: .continuous)
                .fill(face)
                .brightness(-0.28)
                .saturation(1.1)
                .offset(y: depth)

            configuration.label
                .padding(.vertical, 15)
                .padding(.horizontal, 34)
                .background {
                    Capsule(style: .continuous)
                        .fill(face)
                        .overlay {
                            // A wash of light across the top, as if the sun is above it.
                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.45), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        }
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1.5)
                        }
                }
                .offset(y: sunk ? depth : 0)
        }
        .padding(.bottom, depth)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: sunk)
    }
}

#Preview {
    VStack(spacing: 24) {
        Button("Play") {}
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(GamePalette.post)
            .buttonStyle(ChunkyButtonStyle())

        Button("Keep building") {}
            .font(.headline.weight(.heavy))
            .foregroundStyle(GamePalette.cream)
            .buttonStyle(ChunkyButtonStyle(face: GamePalette.rail))
    }
    .padding(40)
    .background(GamePalette.beyond)
}
