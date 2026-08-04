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
    private let planted: Double

    /// - Parameter planted: How much of the word has been driven into the ground, 0 to 1.
    ///   Glyphs drop in left to right, so animating this builds the word like a run of fence.
    ///   Values a little over 1 make the last glyphs overshoot, which is what gives the pop.
    init(word: String, glyphSize: CGFloat = 44, lineWidth: CGFloat = 5, planted: Double = 1) {
        self.glyphs = word.compactMap { PigpenGlyph(letter: $0) }
        self.glyphSize = glyphSize
        self.lineWidth = lineWidth
        self.planted = planted
    }

    var body: some View {
        HStack(spacing: glyphSize * 0.35) {
            ForEach(glyphs.indices, id: \.self) { index in
                let landed = landing(of: index)

                PigpenGlyphView(glyph: glyphs[index], lineWidth: lineWidth)
                    .frame(width: glyphSize, height: glyphSize)
                    .scaleEffect(CGFloat(0.4 + 0.6 * landed))
                    .rotationEffect(.degrees(-10 * (1 - min(landed, 1))))
                    .offset(y: -glyphSize * 0.5 * CGFloat(1 - min(landed, 1)))
                    .opacity(min(landed, 1))
            }
        }
    }

    /// Each glyph waits its turn, then has the back half of the run to itself.
    private func landing(of index: Int) -> Double {
        guard glyphs.count > 1 else { return planted }
        let turn = 0.5 * Double(index) / Double(glyphs.count - 1)
        return max(0, (planted - turn) / 0.5)
    }
}

#Preview {
    PigpenWordView(word: "PIGPEN")
        .foregroundStyle(.primary)
        .padding()
}
