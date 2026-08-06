import Foundation
import SwiftUI

/// The meadow a board is cut out of: the same mown fields the world map's trail runs
/// through, laid behind the puzzle so a level looks like a patch of ground somebody has
/// staked out rather than a grid on a slab of colour.
///
/// Painted once rather than on a clock. The board is the thing being looked at, and a
/// backdrop that repainted every blade of grass thirty times a second behind it would be
/// spending the battery on something nobody is watching. It follows the system appearance
/// the way the rest of the world does — daylight, or the meadow after dark.
struct MeadowBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors: GamePalette.Pasture = colorScheme == .dark ? .dusk : .day

        Canvas { context, size in
            Paddock(size: size, colors: colors).draw(in: &context)
        }
        .accessibilityHidden(true)
    }
}

/// One painting of the meadow behind a board, top to bottom.
private struct Paddock {
    let size: CGSize
    let colors: GamePalette.Pasture

    /// The board takes the middle of the screen and the controls the foot of it, so
    /// everything the meadow is dressed with keeps to these two bands, where there is
    /// grass to see it on.
    private let clearings: [ClosedRange<Double>] = [0.02...0.20, 0.74...0.99]

    func draw(in context: inout GraphicsContext) {
        drawGrass(in: &context)
        drawMowing(in: &context)
        drawDressing(in: &context)
        drawVignette(in: &context)
    }

    /// The grass itself, darkening towards the bottom of the screen the way the near bank
    /// does on the title screen.
    private func drawGrass(in context: inout GraphicsContext) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [colors.ground, colors.foreground]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    /// Bands of mown grass, every one of them with a wandering edge, so the meadow reads as
    /// farmed ground rather than a flat green wall — the same trick the world map uses.
    private func drawMowing(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 613)
        var top = -y(0.04)
        var shaded = true
        while top < size.height {
            let depth = y(scatter.next(in: 0.08...0.15))
            if shaded {
                context.fill(
                    band(from: top, to: top + depth, wobble: scatter.next()),
                    with: .color(colors.foreground.opacity(0.2))
                )
            }
            shaded.toggle()
            top += depth
        }
    }

    /// A band across the whole width with a gently curved top and bottom edge.
    private func band(from top: CGFloat, to bottom: CGFloat, wobble: Double) -> Path {
        let sway = y(0.012)
        var path = Path()
        path.move(to: CGPoint(x: 0, y: top))
        path.addQuadCurve(
            to: CGPoint(x: size.width, y: top + sway * CGFloat(wobble)),
            control: CGPoint(x: size.width / 2, y: top - sway)
        )
        path.addLine(to: CGPoint(x: size.width, y: bottom + sway * CGFloat(wobble)))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: bottom),
            control: CGPoint(x: size.width / 2, y: bottom + sway)
        )
        path.closeSubpath()
        return path
    }

    /// Grass, wildflowers and the odd stone, scattered on a fixed seed so the meadow behind
    /// a level is the same meadow every time the level is opened.
    private func drawDressing(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 2_311)
        for clearing in clearings {
            for _ in 0..<15 {
                let spot = CGPoint(
                    x: x(scatter.next(in: -0.02...1.02)),
                    y: y(scatter.next(in: clearing))
                )
                let scale = CGFloat(scatter.next(in: 0.75...1.3))
                switch scatter.next() {
                case ..<0.52: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                case ..<0.86: drawFlowers(in: &context, at: spot, scale: scale, scatter: &scatter)
                default: drawStone(in: &context, at: spot, scale: scale)
                }
            }
        }
    }

    /// A tuft of grass, leaning the way the breeze on the title screen leans.
    private func drawTuft(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        scale: CGFloat,
        scatter: inout Scatter
    ) {
        let height = x(0.03) * scale
        var blades = Path()
        for lean in [-0.6, -0.15, 0.35, 0.75] {
            let tall = height * CGFloat(scatter.next(in: 0.6...1.1))
            let tip = CGPoint(x: foot.x + tall * CGFloat(lean), y: foot.y - tall)
            blades.move(to: foot)
            blades.addQuadCurve(to: tip, control: CGPoint(x: foot.x, y: foot.y - tall * 0.7))
        }
        context.stroke(
            blades,
            with: .color(colors.blade.opacity(0.8)),
            style: StrokeStyle(lineWidth: max(1, height * 0.14), lineCap: .round)
        )
    }

    /// A clump of wildflowers: cream petals round a golden eye, the same flowers that grow
    /// along the trail.
    private func drawFlowers(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        scale: CGFloat,
        scatter: inout Scatter
    ) {
        let petal = x(0.008) * scale

        for _ in 0..<3 {
            let centre = CGPoint(
                x: foot.x + x(0.03) * CGFloat(scatter.next(in: -1...1)),
                y: foot.y + x(0.02) * CGFloat(scatter.next(in: -1...1))
            )
            var petals = Path()
            for turn in 0..<5 {
                let angle = Double(turn) * 2 * .pi / 5
                petals.addEllipse(in: CGRect(
                    x: centre.x + petal * 0.62 * CGFloat(cos(angle)) - petal * 0.55,
                    y: centre.y + petal * 0.62 * CGFloat(sin(angle)) - petal * 0.55,
                    width: petal * 1.1,
                    height: petal * 1.1
                ))
            }
            context.fill(
                petals,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.3 : 0.85))
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - petal * 0.42, y: centre.y - petal * 0.42,
                    width: petal * 0.84, height: petal * 0.84
                )),
                with: .color(GamePalette.pen.opacity(colors.isNight ? 0.35 : 0.9))
            )
        }
    }

    private func drawStone(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = x(0.022) * scale
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.5, y: foot.y - spread * 0.1,
                width: spread, height: spread * 0.3
            )),
            with: .color(.black.opacity(0.14))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.5, y: foot.y - spread * 0.58,
                width: spread, height: spread * 0.66
            )),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.5 : 0.85))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.3, y: foot.y - spread * 0.52,
                width: spread * 0.4, height: spread * 0.22
            )),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.1 : 0.26))
        )
    }

    /// The corners taken down a little, which is all it takes to make the board the lit
    /// thing on the screen.
    private func drawVignette(in context: inout GraphicsContext) {
        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        let reach = max(size.width, size.height) * 0.8
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [
                    .black.opacity(0),
                    .black.opacity(colors.isNight ? 0.3 : 0.2)
                ]),
                center: centre,
                startRadius: reach * 0.4,
                endRadius: reach
            )
        )
    }

    private func x(_ fraction: Double) -> CGFloat { size.width * CGFloat(fraction) }
    private func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) }
}

extension View {
    /// The bar the board screens wear across the top: the same timber the world map's
    /// banner is cut from, so a puzzle opened off the trail looks like the next room of the
    /// same building rather than a sheet of paper laid over it.
    func fieldNavigationBar() -> some View {
        toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    colors: [GamePalette.rail, GamePalette.post],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    MeadowBackdrop()
        .ignoresSafeArea()
}
