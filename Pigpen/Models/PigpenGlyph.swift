import CoreGraphics

/// The drawable shape of a single pigpen cipher letter, described in a
/// normalized 0...1 box with the origin at the top-left.
///
/// The cipher lays the alphabet out over four keys:
/// A–I in a tic-tac-toe grid, J–R in the same grid with a dot,
/// S–V in the quadrants of an X, and W–Z in the same quadrants with a dot.
struct PigpenGlyph: Equatable {
    struct Segment: Equatable {
        let start: CGPoint
        let end: CGPoint
    }

    let strokes: [Segment]
    let dot: CGPoint?

    init?(letter: Character) {
        let uppercased = letter.uppercased()
        guard uppercased.count == 1,
              let ascii = uppercased.unicodeScalars.first?.value,
              (65...90).contains(ascii) else { return nil }

        let index = Int(ascii - 65)

        switch index {
        case 0...8:
            self = PigpenGlyph.grid(index: index, dotted: false)
        case 9...17:
            self = PigpenGlyph.grid(index: index - 9, dotted: true)
        case 18...21:
            self = PigpenGlyph.wedge(index: index - 18, dotted: false)
        default:
            self = PigpenGlyph.wedge(index: index - 22, dotted: true)
        }
    }

    private init(strokes: [Segment], dot: CGPoint?) {
        self.strokes = strokes
        self.dot = dot
    }

    /// One cell of a tic-tac-toe grid: a side is drawn only where it is an
    /// interior line of the grid, which is what gives each cell its shape.
    private static func grid(index: Int, dotted: Bool) -> PigpenGlyph {
        let row = index / 3
        let column = index % 3

        var strokes: [Segment] = []
        if column > 0 { strokes.append(Segment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 1))) }
        if column < 2 { strokes.append(Segment(start: CGPoint(x: 1, y: 0), end: CGPoint(x: 1, y: 1))) }
        if row > 0 { strokes.append(Segment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0))) }
        if row < 2 { strokes.append(Segment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 1, y: 1))) }

        return PigpenGlyph(strokes: strokes, dot: dotted ? CGPoint(x: 0.5, y: 0.5) : nil)
    }

    /// One quadrant of an X, in reading order: top, left, right, bottom.
    private static func wedge(index: Int, dotted: Bool) -> PigpenGlyph {
        let center = CGPoint(x: 0.5, y: 0.5)
        let topLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x: 1, y: 0)
        let bottomLeft = CGPoint(x: 0, y: 1)
        let bottomRight = CGPoint(x: 1, y: 1)

        let corners: [CGPoint]
        let dotPosition: CGPoint

        switch index {
        case 0:
            corners = [topLeft, topRight]
            dotPosition = CGPoint(x: 0.5, y: 0.25)
        case 1:
            corners = [topLeft, bottomLeft]
            dotPosition = CGPoint(x: 0.25, y: 0.5)
        case 2:
            corners = [topRight, bottomRight]
            dotPosition = CGPoint(x: 0.75, y: 0.5)
        default:
            corners = [bottomLeft, bottomRight]
            dotPosition = CGPoint(x: 0.5, y: 0.75)
        }

        return PigpenGlyph(
            strokes: corners.map { Segment(start: $0, end: center) },
            dot: dotted ? dotPosition : nil
        )
    }
}
