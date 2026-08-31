import Foundation
import SwiftUI

/// The budget, as a rack of fence pieces with the spent ones taken off it.
///
/// The board is the screen, so the one number the player has to keep in their head does not
/// belong in small print in the title bar: the count of pieces still in hand is the size of
/// a scoreboard, and beside it stands one picket for every piece the level allows, so a
/// glance says how much of the budget is left without reading the number at all. When the
/// last piece goes into the ground the count turns barn red, and a press the field will not
/// take shakes the whole board it is painted on.
struct FenceRack: View {
    /// How many pieces are already in the ground.
    let used: Int
    let budget: Int
    /// Turned up by one every time a press is refused, which is what shakes the rack.
    var shake: CGFloat = 0

    private var left: Int { max(budget - used, 0) }
    private var isSpent: Bool { left == 0 }

    var body: some View {
        HStack(spacing: 14) {
            count
            rack
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 14)
        .background { board }
        .modifier(Shake(amount: shake))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    /// What is left, big enough to read without looking for it, with what it was to start
    /// with underneath in small print.
    ///
    /// The two are centred on one another rather than sat on a shared baseline. Aligning the
    /// baselines lines "LEFT" up with the foot of the big number and leaves "of 12" hanging
    /// below it, so the small print reads as having sunk to the bottom of the board; centring
    /// hangs the pair either side of the number's middle, which is where the eye expects them.
    private var count: some View {
        HStack(alignment: .center, spacing: 5) {
            Text("\(left)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(isSpent ? GamePalette.barn : GamePalette.post)

            VStack(alignment: .leading, spacing: -1) {
                Text("LEFT")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(isSpent ? GamePalette.barn : GamePalette.post.opacity(0.85))
                Text("of \(budget)")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(GamePalette.post.opacity(0.55))
            }
        }
        .fixedSize()
        .animation(.easeInOut(duration: 0.2), value: left)
    }

    /// One picket for every piece the level allows: pale timber for the ones still in hand,
    /// and the dark socket it came out of for every one already in the ground.
    ///
    /// The pieces stand shoulder to shoulder from the left rather than spreading out to fill
    /// the rack, so six of them read as six pieces of fencing and not as a wide gappy comb —
    /// and a twenty-piece budget, which is the biggest in the game, still takes no more room
    /// than the rack has to give it.
    private var rack: some View {
        Canvas { context, size in
            guard budget > 0 else { return }

            let pitch = min(size.width / CGFloat(budget), 15)
            let width = min(pitch * 0.66, 11)
            let height = min(size.height, 26)
            let top = (size.height - height) / 2

            for piece in 0..<budget {
                let stall = CGRect(
                    x: pitch * (CGFloat(piece) + 0.5) - width / 2,
                    y: top,
                    width: width,
                    height: height
                )
                let inHand = piece < left
                let timber = picket(in: stall)
                context.fill(
                    timber,
                    with: .color(inHand ? GamePalette.picket : GamePalette.post.opacity(0.17))
                )
                guard inHand else { continue }
                // The lit side of the timber, the side the sun is on everywhere else.
                context.fill(
                    Path(CGRect(
                        x: stall.minX,
                        y: stall.minY + height * 0.24,
                        width: width * 0.34,
                        height: height * 0.76
                    )),
                    with: .color(.white.opacity(0.28))
                )
                context.stroke(timber, with: .color(GamePalette.post.opacity(0.35)), lineWidth: 1)
            }
        }
        .frame(height: 26)
        .frame(maxWidth: .infinity)
    }

    /// One piece of fencing as it stands on the rack: a picket with a point on the top of it.
    private func picket(in rect: CGRect) -> Path {
        let point = rect.height * 0.22
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + point))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + point))
        path.closeSubpath()
        return path
    }

    /// The painted board the whole thing is nailed to, the same one the signposts on the
    /// world map carry their names on.
    private var board: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(GamePalette.cream.opacity(0.96))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.22), radius: 5, y: 3)
    }

    private var spoken: String {
        guard !isSpent else { return "No fence pieces left of \(budget)" }
        return "\(left) of \(budget) fence pieces left"
    }
}

/// Nudges a view sideways when a press is refused — used when the fence budget is spent, or
/// the tile under the finger is one the map will not take.
struct Shake: GeometryEffect {
    var amount: CGFloat

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(amount * .pi * 4) * 6, y: 0))
    }
}

#Preview {
    VStack(spacing: 16) {
        FenceRack(used: 0, budget: 12)
        FenceRack(used: 5, budget: 12)
        FenceRack(used: 12, budget: 12)
        FenceRack(used: 14, budget: 20)
        FenceRack(used: 2, budget: 6)
    }
    .padding(20)
    .background { MeadowBackdrop() }
}
