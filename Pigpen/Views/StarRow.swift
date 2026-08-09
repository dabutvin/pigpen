import SwiftUI

/// Three stars, filled in as far as they have been won — and drifting through the spectrum
/// for a pen with nothing left above it.
///
/// The signposts on the world map draw their own, since a signpost's row has to line up
/// with the sign under it whatever a level has given up. Everything the daily puzzles put
/// on screen — the card on the title screen, the squares in the archive — uses this one.
struct StarRow: View {
    let stars: Int
    var size: CGFloat = 11
    /// True for a day that has given up the best pen it had in it. Nothing on a map beats
    /// such a pen, which is worth saying long after the board has gone.
    var hasTheBestPen = false

    var body: some View {
        row(filled: AnyShapeStyle(GamePalette.pen), hollow: AnyShapeStyle(GamePalette.cream.opacity(0.55)))
            .overlay {
                if hasTheBestPen {
                    RainbowWash()
                        .mask {
                            row(
                                filled: AnyShapeStyle(Color.white),
                                hollow: AnyShapeStyle(Color.clear)
                            )
                        }
                }
            }
            .accessibilityHidden(true)
    }

    private func row(filled: AnyShapeStyle, hollow: AnyShapeStyle) -> some View {
        HStack(spacing: size * 0.18) {
            ForEach(1...3, id: \.self) { star in
                Image(systemName: star <= stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .black))
                    .foregroundStyle(star <= stars ? filled : hollow)
            }
        }
    }
}

/// The whole colour wheel, turning slowly — the wash a pen with nothing left to beat gets
/// on the field, and the same one its stars keep afterwards. Mask it with whatever it is
/// meant to colour in.
struct RainbowWash: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// When the thing wearing it went up, so the drift runs from a fixed point rather than
    /// from whenever it happened to be scrolled into view.
    @State private var raised = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            // One turn round the colour wheel every twelve seconds, as on the field.
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSince(raised) / 12

            LinearGradient(
                gradient: GamePalette.rainbow(phase: phase),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        StarRow(stars: 0)
        StarRow(stars: 2)
        StarRow(stars: 3, size: 16)
        StarRow(stars: 3, size: 16, hasTheBestPen: true)
    }
    .padding(40)
    .background(GamePalette.post)
}
