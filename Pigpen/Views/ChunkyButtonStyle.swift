import SwiftUI

/// A painted wooden button that stands on a ledge of its own shadow and sinks onto it when
/// pressed — the shape of button a game asks you to hit, rather than a control you fill in.
struct ChunkyButtonStyle: ButtonStyle {
    /// The colour of the face. The ledge beneath it is the same colour, darkened.
    var tint: Color = GamePalette.pen
    /// How far the button stands off its ledge, and so how far it travels when pressed.
    var depth: CGFloat = 7

    func makeBody(configuration: Configuration) -> some View {
        let sunk = configuration.isPressed

        return configuration.label
            .padding(.vertical, 15)
            .padding(.horizontal, 34)
            .background { face }
            .offset(y: sunk ? depth : 0)
            // Laid on after the offset, so the ledge holds its place while the face sinks.
            .background { ledge.offset(y: depth) }
            .padding(.bottom, depth)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: sunk)
    }

    private var face: some View {
        Capsule(style: .continuous)
            .fill(tint)
            .overlay {
                // A wash of light across the top, as though the sun were above it.
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

    private var ledge: some View {
        Capsule(style: .continuous)
            .fill(tint)
            .brightness(-0.3)
            .saturation(1.1)
            .shadow(color: .black.opacity(0.28), radius: 8, y: 5)
    }
}

/// A small painted board with a press in it: what the buttons round the edge of a puzzle
/// are made of, so they belong to the same farm as the signposts and the fence rack rather
/// than to the system's grey.
struct PlaqueButtonStyle: ButtonStyle {
    /// The room round the label. Icon buttons want it even; a button with words in it wants
    /// a little more either side.
    var padding: CGFloat = 9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, padding)
            .padding(.horizontal, padding + 3)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(GamePalette.cream.opacity(0.95))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
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
            .buttonStyle(ChunkyButtonStyle(tint: GamePalette.rail))

        HStack(spacing: 10) {
            Button {} label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .labelStyle(.iconOnly)
                    .font(.body.weight(.semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlaqueButtonStyle())

            Button {} label: {
                Label("Put it back", systemImage: "trophy")
                    .font(.footnote.weight(.heavy))
            }
            .buttonStyle(PlaqueButtonStyle(padding: 7))
        }
    }
    .padding(40)
    .background(GamePalette.beyond)
}
