import SwiftUI

/// The barn: red walls, a dark gable roof standing out over them on its eaves, the big doors shut
/// in the middle, and a trim board running either side of them.
///
/// One painting, because the game has two barns to draw and they are the same building. The world
/// map stands it at the foot of the meadow trail, where the pig came out of it; the dressing barn's
/// signpost carries it small, where a numbered stop carries its number. A second barn drawn by
/// hand for the sign would be a second barn to keep in step with this one, and the alternative was
/// an emoji — there is no barn in Unicode, so that would have meant a house or a washing basket
/// standing in for a building this game already knows how to paint.
enum Barn {
    /// How far the eaves stand out past the walls, each side, as a fraction of the walls' width.
    private static let eaves = 7.0 / 78.0
    /// How tall the walls stand, likewise, and how tall the gable over them.
    private static let wallHeight = 30.0 / 78.0
    private static let gableHeight = 25.0 / 78.0

    /// How much room the whole building takes for one `wide` across its walls.
    static func span(walls wide: CGFloat) -> CGSize {
        CGSize(
            width: wide * (1 + 2 * eaves),
            height: wide * (wallHeight + gableHeight)
        )
    }

    /// Paints it into `bounds`: the ridge along the top edge, the eaves out to both sides, the
    /// foot of the walls along the bottom. `span(walls:)` gives a rect in the building's own
    /// proportions, and anything else stretches it.
    static func paint(in context: inout GraphicsContext, bounds: CGRect) {
        let wide = bounds.width / (1 + 2 * eaves)
        let tall = bounds.height * wallHeight / (wallHeight + gableHeight)

        let walls = CGRect(
            x: bounds.midX - wide / 2, y: bounds.maxY - tall,
            width: wide, height: tall
        )
        context.fill(Path(walls), with: .color(GamePalette.barn))

        var roof = Path()
        roof.move(to: CGPoint(x: bounds.minX, y: walls.minY))
        roof.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
        roof.addLine(to: CGPoint(x: bounds.maxX, y: walls.minY))
        roof.closeSubpath()
        context.fill(roof, with: .color(GamePalette.post))

        let door = CGRect(
            x: bounds.midX - wide * 0.15, y: walls.minY + tall * 0.24,
            width: wide * 0.3, height: tall * 0.76
        )
        context.fill(
            Path(roundedRect: door, cornerRadius: door.width * 0.13),
            with: .color(GamePalette.post.opacity(0.85))
        )

        var trim = Path()
        let line = walls.minY + tall * 0.34
        trim.move(to: CGPoint(x: walls.minX + wide * 0.077, y: line))
        trim.addLine(to: CGPoint(x: door.minX - wide * 0.051, y: line))
        trim.move(to: CGPoint(x: door.maxX + wide * 0.051, y: line))
        trim.addLine(to: CGPoint(x: walls.maxX - wide * 0.077, y: line))
        context.stroke(trim, with: .color(GamePalette.cream.opacity(0.8)), lineWidth: tall * 0.1)
    }
}

/// The barn as something to put on a signpost: the building above, painted at whatever width its
/// walls are asked to stand, and taking exactly the room it needs.
struct BarnMark: View {
    /// How wide the walls stand. The eaves, the gable and the doors all follow from it.
    var walls: CGFloat

    var body: some View {
        let span = Barn.span(walls: walls)

        Canvas { context, size in
            Barn.paint(in: &context, bounds: CGRect(origin: .zero, size: size))
        }
        .frame(width: span.width, height: span.height)
    }
}

#Preview {
    VStack(spacing: 24) {
        BarnMark(walls: 30)
        BarnMark(walls: 78)
    }
    .padding(40)
    .background(GamePalette.beyond)
}
