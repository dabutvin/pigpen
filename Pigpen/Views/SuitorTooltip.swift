import SwiftUI

/// What Hamish says, in a little cream bubble with a tail pointing at whatever he is talking
/// about: the tile a piece goes on, or himself down in the corner when he is not on the board
/// to be pointed at.
///
/// A tooltip rather than a notice board, because what he says is about one square rather than
/// about the level. His words used to go on the same painted board the boss's rule goes on,
/// above the rack, which read as a second announcement and left the player to work out which
/// tile it meant — the pig was on the board and the sentence about him was at the top of the
/// screen. A bubble with a tail says it where it applies and nowhere else.
///
/// It is painted in the same cream the rack and the signposts are, so it belongs to the same
/// hand that made the level; it is only the shape that is new.
struct SuitorTooltip: View {
    /// Which way the tail sticks out, which is to say which side of the bubble the thing it
    /// is about is standing on.
    enum Tail {
        /// The bubble sits above what it points at.
        case down
        /// The bubble hangs below it.
        case up
    }

    let words: String
    /// How wide the bubble is. Fixed rather than shrink-wrapped to its words, so that whoever
    /// puts one up can work out where it will sit and how far the tail has to lean without
    /// measuring anything first.
    let width: CGFloat
    var tail: Tail = .down
    /// How far the tail stands from the middle of the bubble. A bubble shoved back onto the
    /// board to stay readable still has to point at the tile it is about, and this is how it
    /// keeps doing that.
    var tailOffset: CGFloat = 0

    private static let tailWidth: CGFloat = 16
    private static let tailHeight: CGFloat = 8

    /// The lean, kept far enough from the ends that the tail never hangs off a rounded corner.
    private var leaning: CGFloat {
        let room = max(0, width / 2 - Self.tailWidth)
        return min(max(tailOffset, -room), room)
    }

    var body: some View {
        // A point of overlap, so the card's outline does not draw a line across the base of
        // its own tail; the tail is laid over that line rather than beside it.
        VStack(spacing: -1) {
            if tail == .up { point.zIndex(1) }
            card
            if tail == .down { point.zIndex(1) }
        }
        .shadow(color: .black.opacity(0.28), radius: 6, y: 3)
    }

    private var card: some View {
        Text(words)
            .font(.footnote.weight(.heavy))
            .foregroundStyle(GamePalette.post.opacity(0.92))
            .multilineTextAlignment(.center)
            // Its height is its own business: a bubble is hung off a point of the board with
            // no room offered to it, and it has to take what its words need anyway.
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .frame(width: width)
            .background(
                GamePalette.cream.opacity(0.97),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
            }
    }

    private var point: some View {
        Point(tail: tail)
            .fill(GamePalette.cream.opacity(0.97))
            .frame(width: Self.tailWidth, height: Self.tailHeight)
            .offset(x: leaning)
    }

    /// The tail itself: a triangle with its point on whatever the bubble is about.
    private struct Point: Shape {
        let tail: Tail

        func path(in rect: CGRect) -> Path {
            var path = Path()
            switch tail {
            case .down:
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            case .up:
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            }
            path.closeSubpath()
            return path
        }
    }
}

#Preview("Both ways round") {
    ZStack {
        MeadowBackdrop(day: .day).ignoresSafeArea()

        VStack(spacing: 60) {
            SuitorTooltip(words: Suitor.hint, width: 230)
            SuitorTooltip(words: Suitor.hint, width: 230, tail: .up, tailOffset: -90)
            SuitorTooltip(
                words: Suitor.outOfRoses(until: .now.addingTimeInterval(3 * 3600), from: .now),
                width: 250,
                tailOffset: -104
            )
        }
    }
}
