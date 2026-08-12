import Foundation
import SwiftUI
import UIKit

/// The ground a board is cut out of: the same fields the world map's trail runs through,
/// laid behind the puzzle so a level looks like a patch of ground somebody has staked out
/// rather than a grid on a slab of colour. A themed world hands its own light in, and the
/// dressing follows — leaf litter and ferns in a thicket, ash and cinder on a mountain,
/// paving and drains in a city, where the meadow had mowing and wildflowers.
///
/// The ground it is all standing on is painted once. Only the things that would move in a
/// breeze — the grass, the flowers, the fireflies over them after dark — are on a clock,
/// and they are on a slow one, so a level has some air moving through it without the whole
/// meadow being repainted behind a board nobody is looking past. It follows the system
/// appearance the way the rest of the world does — daylight, or the ground after dark.
struct MeadowBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var opened = Date()

    /// Daylight and dusk for this patch of ground. Defaults to the meadow, which is what
    /// every board that is not a themed world — dailies, the tutorial, a level opened on
    /// its own — is cut out of.
    var day: GamePalette.Pasture = .day
    var dusk: GamePalette.Pasture = .dusk

    var body: some View {
        let colors: GamePalette.Pasture = colorScheme == .dark ? dusk : day

        ZStack {
            Canvas { context, size in
                Paddock(size: size, elapsed: 0, colors: colors).drawGround(in: &context)
            }

            // A sway this slow has nowhere near thirty frames of movement in it to show,
            // and the ground underneath is not repainted to keep it company.
            TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion)) { timeline in
                let elapsed = reduceMotion ? 0 : timeline.date.timeIntervalSince(opened)

                Canvas { context, size in
                    Paddock(size: size, elapsed: elapsed, colors: colors).drawGrowth(in: &context)
                }
            }

            Canvas { context, size in
                Paddock(size: size, elapsed: 0, colors: colors).drawVignette(in: &context)
            }
        }
        .accessibilityHidden(true)
    }
}

/// One painting of the ground behind a board, top to bottom, in the three layers the screen
/// asks for it: the ground, what grows on it, and the light over the lot.
private struct Paddock {
    let size: CGSize
    /// How long the screen has been open, which is the only thing the sway is a function of.
    /// The layers with nothing moving in them are drawn at zero, and so is the whole meadow
    /// for a player who would rather it kept still.
    let elapsed: TimeInterval
    let colors: GamePalette.Pasture

    /// The board takes the middle of the screen, the rack the top of it and the controls the
    /// foot, so everything the ground is dressed with keeps to the two bands either side of
    /// the board, where there is grass to see it on.
    private let clearings: [ClosedRange<Double>] = [0.19...0.28, 0.82...0.99]

    /// The field itself: grass and the bands it was mown in, the leaf litter under a
    /// canopy, the drifts of ash on a mountain, or the paving of a city street. Nothing
    /// here moves.
    func drawGround(in context: inout GraphicsContext) {
        drawGrass(in: &context)
        switch colors.cover {
        case .pasture: drawMowing(in: &context)
        case .woodland: drawLeafLitter(in: &context)
        case .scree: drawAshDrifts(in: &context)
        case .cobbles: drawPaving(in: &context)
        }
    }

    /// Everything growing on the field, which is everything the breeze has any hold over.
    func drawGrowth(in context: inout GraphicsContext) {
        drawDressing(in: &context)
        drawVerge(in: &context)
        if colors.isNight {
            drawFireflies(in: &context)
        }
    }

    /// How hard the breeze is leaning on something rooted at a given spot, in -1...1.
    ///
    /// One slow gust travels across the meadow with a slower swell under it, so the grass
    /// on one side leans a beat before the grass on the other and the field never sways as
    /// a single blade. Everything takes its lean from where it stands, which is why moving
    /// the meadow costs it no randomness and leaves it laid out exactly as it always was.
    private func gust(at foot: CGPoint) -> CGFloat {
        let across = Double(foot.x / max(size.width, 1))
        let down = Double(foot.y / max(size.height, 1))
        let travelling = sin(elapsed * 0.62 - across * 2.4 + down * 2.2)
        let swell = sin(elapsed * 0.24 + across * 0.7)
        return CGFloat(travelling * 0.72 + swell * 0.28)
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
                    // After dark the grass and the shadow on it are already all but the
                    // same colour, so the mowing is picked out with light instead.
                    with: .color(
                        colors.isNight
                            ? Color.white.opacity(0.025)
                            : colors.foreground.opacity(0.2)
                    )
                )
            }
            shaded.toggle()
            top += depth
        }
    }

    /// Soft blotches of leaf mould, so a thicket board sits in woodland floor rather than
    /// in a mown paddock tinted green.
    private func drawLeafLitter(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 821)
        for _ in 0..<18 {
            let centre = CGPoint(x: x(scatter.next()), y: y(scatter.next()))
            let spread = x(scatter.next(in: 0.08...0.22))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.6,
                    y: centre.y - spread * 0.28,
                    width: spread * 1.2,
                    height: spread * 0.55
                )),
                with: .color(
                    colors.isNight
                        ? Color(red: 0.18, green: 0.14, blue: 0.08).opacity(0.2)
                        : Color(red: 0.42, green: 0.32, blue: 0.18).opacity(0.26)
                )
            )
        }
    }

    /// Drifts of ash with cinder showing through them, so a mountain board sits on burnt
    /// ground rather than in a paddock painted grey. Pale where the ash has settled, dark
    /// where it has blown off the rock — and after dark the cinder is the lit one of the
    /// two, since what light there is down here is coming up rather than down.
    private func drawAshDrifts(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 733)
        for index in 0..<22 {
            let centre = CGPoint(x: x(scatter.next()), y: y(scatter.next()))
            let spread = x(scatter.next(in: 0.06...0.20))
            let cinder = index % 3 == 0
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.6,
                    y: centre.y - spread * 0.24,
                    width: spread * 1.2,
                    height: spread * 0.48
                )),
                with: .color(
                    cinder
                        ? Color(red: 0.42, green: 0.14, blue: 0.08)
                            .opacity(colors.isNight ? 0.34 : 0.20)
                        : Color(red: 0.72, green: 0.68, blue: 0.66)
                            .opacity(colors.isNight ? 0.08 : 0.22)
                )
            )
        }
    }

    /// Courses of setts, laid in rows with every other course offset by half a stone, so a
    /// city board sits on paving rather than on a grey field. The joints are what read at
    /// this size, so the stones themselves are only lightened and darkened a shade either
    /// side of the ground colour and the mortar between them does the drawing.
    private func drawPaving(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_277)
        let course = y(0.028)
        let sett = x(0.075)
        var top = -course
        var offset = false
        while top < size.height {
            var across = offset ? -sett / 2 : 0
            while across < size.width {
                let stone = CGRect(
                    x: across + sett * 0.04,
                    y: top + course * 0.08,
                    width: sett * 0.92,
                    height: course * 0.84
                )
                let roll = scatter.next()
                context.fill(
                    Path(roundedRect: stone, cornerRadius: course * 0.18),
                    with: .color(
                        roll < 0.5
                            ? Color.white.opacity(colors.isNight ? 0.014 : 0.05)
                            : Color.black.opacity(colors.isNight ? 0.10 : 0.05)
                    )
                )
                across += sett
            }
            offset.toggle()
            top += course
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

    /// Grass, wildflowers and the odd stone on a meadow; ferns, mushrooms and a denser
    /// verge in a thicket; stones, cinders and hardly anything alive on a mountain; loose
    /// setts, drains and whatever comes up between the paving in a city. Scattered on a
    /// fixed seed so the ground behind a level is the same ground every time the level is
    /// opened.
    private func drawDressing(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 2_311)
        let count: Int = switch colors.cover {
        case .pasture: 15
        case .woodland: 18
        case .scree: 13
        case .cobbles: 12
        }
        for clearing in clearings {
            for _ in 0..<count {
                let spot = CGPoint(
                    x: x(scatter.next(in: -0.02...1.02)),
                    y: y(scatter.next(in: clearing))
                )
                let scale = CGFloat(scatter.next(in: 0.75...1.3))
                let roll = scatter.next()
                switch colors.cover {
                case .pasture:
                    switch roll {
                    case ..<0.52: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                    case ..<0.86: drawFlowers(in: &context, at: spot, scale: scale, scatter: &scatter)
                    default: drawStone(in: &context, at: spot, scale: scale)
                    }
                case .woodland:
                    switch roll {
                    case ..<0.40: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                    case ..<0.68: drawFern(in: &context, at: spot, scale: scale, scatter: &scatter)
                    case ..<0.86: drawMushroom(in: &context, at: spot, scale: scale)
                    default: drawStone(in: &context, at: spot, scale: scale)
                    }
                case .scree:
                    switch roll {
                    case ..<0.58: drawStone(in: &context, at: spot, scale: scale)
                    case ..<0.84: drawCinder(in: &context, at: spot, scale: scale)
                    default: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                    }
                case .cobbles:
                    switch roll {
                    case ..<0.46: drawStone(in: &context, at: spot, scale: scale)
                    case ..<0.76: drawDrain(in: &context, at: spot, scale: scale)
                    default: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                    }
                }
            }
        }
    }

    /// Long grass along the foot of the screen. Wherever the board ends up on whatever phone
    /// it is being played on, this much of the ground is always in view.
    private func drawVerge(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 977)
        let tufts: Int = switch colors.cover {
        case .pasture: 26
        case .woodland: 32
        case .scree: 22
        case .cobbles: 20
        }
        for index in 0..<tufts {
            let foot = CGPoint(
                x: x((Double(index) + scatter.next()) / Double(tufts)),
                y: size.height + y(0.005)
            )
            let roll = scatter.next()
            switch colors.cover {
            case .woodland where roll < 0.35:
                drawFern(
                    in: &context,
                    at: foot,
                    scale: CGFloat(scatter.next(in: 1.1...1.8)),
                    scatter: &scatter
                )
            case .scree where roll < 0.7:
                // A verge of loose rock rather than long grass: nothing takes root this
                // close to the peak.
                drawStone(in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.0...1.8)))
            case .cobbles where roll < 0.6:
                // A kerb rather than a verge: the grass in a city is whatever has pushed up
                // through the joints, so most of the foot of the screen is stone.
                drawStone(in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.0...1.7)))
            default:
                drawTuft(
                    in: &context,
                    at: foot,
                    scale: CGFloat(scatter.next(in: 1.0...1.9)),
                    scatter: &scatter
                )
            }
        }
    }

    /// A few specks of light over the grass after dark, the same fireflies the title screen
    /// keeps. They wander a little way off where they were and pulse as they go, each on its
    /// own phase, so no two of them are ever bright at the same moment.
    private func drawFireflies(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_493)
        for clearing in clearings {
            for _ in 0..<5 {
                let roost = CGPoint(x: x(scatter.next()), y: y(scatter.next(in: clearing)))
                let radius = x(0.005) * CGFloat(scatter.next(in: 0.7...1.5))
                let phase = Double(roost.x + roost.y)
                let centre = CGPoint(
                    x: roost.x + x(0.014) * CGFloat(sin(elapsed * 0.31 + phase)),
                    y: roost.y + y(0.006) * CGFloat(sin(elapsed * 0.47 + phase * 1.7))
                )
                let glow = 0.4 + 0.6 * (0.5 + 0.5 * sin(elapsed * 1.15 + phase))
                context.fill(
                    circle(at: centre, radius: radius * 3.4),
                    with: .color(GamePalette.pen.opacity(0.16 * glow))
                )
                context.fill(
                    circle(at: centre, radius: radius),
                    with: .color(GamePalette.pen.opacity(0.75 * glow))
                )
            }
        }
    }

    /// A tuft of grass, leaning the way the breeze on the title screen leans. The blade is
    /// rooted where it stands and bends along its length, so the sway is all in the tips.
    private func drawTuft(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        scale: CGFloat,
        scatter: inout Scatter
    ) {
        let height = x(0.03) * scale
        let breeze = gust(at: foot)
        var blades = Path()
        for lean in [-0.6, -0.15, 0.35, 0.75] {
            let tall = height * CGFloat(scatter.next(in: 0.6...1.1))
            // A long blade has more of itself to bend than a short one beside it.
            let bend = tall * 0.22 * breeze
            let tip = CGPoint(x: foot.x + tall * CGFloat(lean) + bend, y: foot.y - tall)
            blades.move(to: foot)
            blades.addQuadCurve(
                to: tip,
                control: CGPoint(x: foot.x + bend * 0.35, y: foot.y - tall * 0.7)
            )
        }
        context.stroke(
            blades,
            with: .color(colors.blade.opacity(0.8)),
            style: StrokeStyle(lineWidth: max(1, height * 0.14), lineCap: .round)
        )
    }

    /// A clump of wildflowers: cream petals round a golden eye, the same flowers that grow
    /// along the trail. Each head nods on its own stalk rather than the clump moving as a
    /// block, since they are not all standing in quite the same air.
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
            let nod = petal * 0.3 * gust(at: centre)

            var petals = Path()
            for turn in 0..<5 {
                let angle = Double(turn) * 2 * .pi / 5
                petals.addEllipse(in: CGRect(
                    x: centre.x + nod + petal * 0.62 * CGFloat(cos(angle)) - petal * 0.55,
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
                    x: centre.x + nod - petal * 0.42, y: centre.y - petal * 0.42,
                    width: petal * 0.84, height: petal * 0.84
                )),
                with: .color(GamePalette.pen.opacity(colors.isNight ? 0.35 : 0.9))
            )
        }
    }

    /// A few fronds for the thicket, nodding the same way the meadow's grass does.
    private func drawFern(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        scale: CGFloat,
        scatter: inout Scatter
    ) {
        let height = x(0.034) * scale
        let breeze = gust(at: foot)
        var fronds = Path()
        for lean in [-0.8, -0.25, 0.3, 0.75] {
            let tall = height * CGFloat(scatter.next(in: 0.7...1.1))
            let bend = tall * 0.18 * breeze
            let tip = CGPoint(x: foot.x + tall * CGFloat(lean) * 0.5 + bend, y: foot.y - tall)
            fronds.move(to: foot)
            fronds.addQuadCurve(
                to: tip,
                control: CGPoint(x: foot.x + bend * 0.3, y: foot.y - tall * 0.55)
            )
        }
        context.stroke(
            fronds,
            with: .color(colors.blade.opacity(0.9)),
            style: StrokeStyle(lineWidth: max(1.2, height * 0.13), lineCap: .round)
        )
    }

    /// A small toadstool on the thicket floor — the backdrop's echo of the truffles that
    /// lie on the board itself.
    private func drawMushroom(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let stem = x(0.01) * scale
        let cap = x(0.018) * scale
        context.fill(
            Path(roundedRect: CGRect(
                x: foot.x - stem * 0.35, y: foot.y - stem * 1.6,
                width: stem * 0.7, height: stem * 1.6
            ), cornerRadius: stem * 0.2),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.35 : 0.8))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - cap * 0.55, y: foot.y - stem * 1.6 - cap * 0.55,
                width: cap * 1.1, height: cap * 0.85
            )),
            with: .color(
                Color(red: 0.62, green: 0.28, blue: 0.22)
                    .opacity(colors.isNight ? 0.55 : 0.9)
            )
        )
        context.fill(
            circle(at: CGPoint(x: foot.x - cap * 0.15, y: foot.y - stem * 1.6 - cap * 0.15), radius: cap * 0.12),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.25 : 0.7))
        )
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

    /// A cinder lying on the ash with a little heat still in it — the backdrop's echo of
    /// the embers staked out on the board itself, and what a mountain has instead of
    /// wildflowers.
    private func drawCinder(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = x(0.016) * scale
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.5, y: foot.y - spread * 0.42,
                width: spread, height: spread * 0.5
            )),
            with: .color(Color(red: 0.16, green: 0.12, blue: 0.12).opacity(colors.isNight ? 0.8 : 0.7))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.24, y: foot.y - spread * 0.34,
                width: spread * 0.48, height: spread * 0.26
            )),
            with: .color(
                Color(red: 0.95, green: 0.42, blue: 0.16)
                    .opacity(colors.isNight ? 0.85 : 0.55)
            )
        )
    }

    /// A drain sunk into the paving with its bars across it — the backdrop's echo of the
    /// drains staked out on the board itself, and what a city has instead of wildflowers.
    private func drawDrain(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = x(0.020) * scale
        let grate = CGRect(
            x: foot.x - spread * 0.5, y: foot.y - spread * 0.34,
            width: spread, height: spread * 0.44
        )
        context.fill(
            Path(roundedRect: grate, cornerRadius: spread * 0.08),
            with: .color(Color(red: 0.14, green: 0.14, blue: 0.15).opacity(colors.isNight ? 0.75 : 0.6))
        )
        var bars = Path()
        for line in [0.3, 0.5, 0.7] {
            let across = grate.minX + grate.width * CGFloat(line)
            bars.move(to: CGPoint(x: across, y: grate.minY + grate.height * 0.16))
            bars.addLine(to: CGPoint(x: across, y: grate.maxY - grate.height * 0.16))
        }
        context.stroke(
            bars,
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.3 : 0.55)),
            style: StrokeStyle(lineWidth: max(1, spread * 0.07), lineCap: .round)
        )
    }

    /// The corners taken down a little, which is all it takes to make the board the lit
    /// thing on the screen. A thicket closes in harder, so the canopy feels overhead; a
    /// mountain sits somewhere between the two, open sky but a hazed one; and a city closes
    /// in nearly as hard as a wood, since the buildings are the canopy here.
    func drawVignette(in context: inout GraphicsContext) {
        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        let reach = max(size.width, size.height) * 0.8
        let edge: Double = switch colors.cover {
        case .pasture: colors.isNight ? 0.3 : 0.2
        case .woodland: colors.isNight ? 0.42 : 0.32
        case .scree: colors.isNight ? 0.38 : 0.26
        case .cobbles: colors.isNight ? 0.44 : 0.30
        }
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [
                    .black.opacity(0),
                    .black.opacity(edge)
                ]),
                center: centre,
                startRadius: reach * (colors.cover == .woodland ? 0.32 : 0.4),
                endRadius: reach
            )
        )
    }

    private func x(_ fraction: Double) -> CGFloat { size.width * CGFloat(fraction) }
    private func y(_ fraction: Double) -> CGFloat { size.height * CGFloat(fraction) }

    private func circle(at centre: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: centre.x - radius, y: centre.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }
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

    /// Stops the navigation stack from reading a drag across the left of the board as a
    /// swipe back to the screen behind. On a field that drag is fencing, and the edge is
    /// exactly where a wall often has to go — so the way out stays the bar's back button,
    /// not a gesture the fence was already using.
    func keepsSwipeFromPopping() -> some View {
        background(KeepsSwipeFromPopping())
    }
}

/// Turns off the interactive pop gesture for as long as the field that hosts it is up,
/// and turns it back on the moment that field is put away, so the screens behind it can
/// still be swiped closed the usual way.
private struct KeepsSwipeFromPopping: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            setPopGesture(enabled: false)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            setPopGesture(enabled: true)
        }

        /// Walks up from this hosted controller to the navigation stack SwiftUI is
        /// actually driving. A representable dropped in as a background does not always
        /// sit where `navigationController` alone can see it.
        private func setPopGesture(enabled: Bool) {
            var current: UIViewController? = self
            while let controller = current {
                if let navigation = controller as? UINavigationController
                    ?? controller.navigationController
                {
                    navigation.interactivePopGestureRecognizer?.isEnabled = enabled
                    return
                }
                current = controller.parent
            }
        }
    }
}

#Preview("Meadow") {
    MeadowBackdrop()
        .ignoresSafeArea()
}

#Preview("Thicket") {
    MeadowBackdrop(day: .forestDay, dusk: .forestDusk)
        .ignoresSafeArea()
}

#Preview("Emberpeak") {
    MeadowBackdrop(day: .emberDay, dusk: .emberDusk)
        .ignoresSafeArea()
}

#Preview("Cogsworth City") {
    MeadowBackdrop(day: .cityDay, dusk: .cityDusk)
        .ignoresSafeArea()
}
