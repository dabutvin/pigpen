import SwiftUI

/// Draws a single pigpen cipher glyph using the current foreground style.
struct PigpenGlyphView: View {
    let glyph: PigpenGlyph
    var lineWidth: CGFloat = 5

    var body: some View {
        Canvas { context, size in
            let inset = lineWidth / 2
            let box = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)

            var path = Path()
            for stroke in glyph.strokes {
                path.move(to: point(stroke.start, in: box))
                path.addLine(to: point(stroke.end, in: box))
            }
            context.stroke(
                path,
                with: .foreground,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )

            if let dot = glyph.dot {
                let center = point(dot, in: box)
                let radius = lineWidth * 0.9
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .foreground
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func point(_ normalized: CGPoint, in box: CGRect) -> CGPoint {
        CGPoint(
            x: box.minX + normalized.x * box.width,
            y: box.minY + normalized.y * box.height
        )
    }
}

/// Renders a word as a row of pigpen glyphs, skipping anything unencodable.
struct PigpenWordView: View {
    private let glyphs: [PigpenGlyph]
    private let glyphSize: CGFloat
    private let lineWidth: CGFloat

    init(word: String, glyphSize: CGFloat = 44, lineWidth: CGFloat = 5) {
        self.glyphs = word.compactMap { PigpenGlyph(letter: $0) }
        self.glyphSize = glyphSize
        self.lineWidth = lineWidth
    }

    var body: some View {
        HStack(spacing: glyphSize * 0.35) {
            ForEach(glyphs.indices, id: \.self) { index in
                PigpenGlyphView(glyph: glyphs[index], lineWidth: lineWidth)
                    .frame(width: glyphSize, height: glyphSize)
            }
        }
    }
}

#Preview {
    PigpenWordView(word: "PIGPEN")
        .foregroundStyle(.primary)
        .padding()
}
