import Foundation
import SwiftUI
import UIKit

/// The ground a board is cut out of: the same fields the world map's trail runs through,
/// laid behind the puzzle so a level looks like a patch of ground somebody has staked out
/// rather than a grid on a slab of colour. A themed world hands its own light in, and the
/// dressing follows — leaf litter and ferns in a thicket, ash and cinder on a mountain,
/// paving and drains in a city, dust and sparks out in the reaches, flowstone and stalagmites
/// in the caverns, and sawdust with tent pegs in it at the carnival, where the meadow had
/// mowing and wildflowers.
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
        case .dust: drawDust(in: &context)
        case .flowstone: drawFlowstone(in: &context)
        case .sawdust: drawSawdust(in: &context)
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

    /// Dust with things having landed in it: shallow pits ringed pale where the ground was
    /// thrown up, and no bands and no courses, because nobody has ever mown or laid anything
    /// out here. It is the emptiest ground the game draws, which is the point of the world.
    private func drawDust(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_609)
        for _ in 0..<20 {
            let centre = CGPoint(x: x(scatter.next()), y: y(scatter.next()))
            let spread = x(scatter.next(in: 0.05...0.17))
            let pit = CGRect(
                x: centre.x - spread * 0.5, y: centre.y - spread * 0.2,
                width: spread, height: spread * 0.4
            )
            context.fill(
                Path(ellipseIn: pit),
                with: .color(.black.opacity(colors.isNight ? 0.22 : 0.12))
            )
            context.stroke(
                Path(ellipseIn: pit.insetBy(dx: -spread * 0.05, dy: -spread * 0.02)),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.14)),
                lineWidth: max(1, spread * 0.05)
            )
        }
    }

    /// Flowstone: the floor of a cave, which is rock the water has been running over long
    /// enough to lay it down in ribs. So the ground is banded the way the meadow's mowing is
    /// banded and for the opposite reason — nobody laid these out, they poured — and the near
    /// edge of every rib catches what light there is while the step under it stays black.
    private func drawFlowstone(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 3_167)
        var top = y(-0.02)
        while top < size.height {
            let deep = y(scatter.next(in: 0.05...0.11))
            let rib = band(from: top, to: top + deep, wobble: scatter.next(in: -1.2...1.2))
            context.fill(rib, with: .color(.black.opacity(scatter.next(in: 0.05...0.13))))
            // The lip of the ledge, where the water comes over and the light with it.
            context.stroke(
                rib,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.13)),
                lineWidth: max(1, y(0.0016))
            )
            top += deep
        }

        // And the wet of it: shallow sheets standing where the rock dipped, which is what
        // makes a cave floor read as wet rather than as a dark meadow.
        for _ in 0..<9 {
            let centre = CGPoint(x: x(scatter.next()), y: y(scatter.next()))
            let spread = x(scatter.next(in: 0.06...0.16))
            let sheet = CGRect(
                x: centre.x - spread * 0.5, y: centre.y - spread * 0.13,
                width: spread, height: spread * 0.26
            )
            context.fill(
                Path(ellipseIn: sheet),
                with: .color(colors.disc.opacity(colors.isNight ? 0.07 : 0.13))
            )
        }
    }

    /// Sawdust: a field that has had a fairground put on it for the week. The grass is still
    /// under there and it is still trodden into mud in the walkways, and over the top of that
    /// somebody has thrown down sawdust in the places people stand.
    ///
    /// Then the lights. Every other world in the game is lit from one place — a sun, a fissure,
    /// a crystal — and this one is lit by a string of lanterns nobody thought about, so the
    /// ground comes in pools of colour that overlap and disagree. That is the whole of why the
    /// carnival reads as a carnival rather than as the meadow after dark: not the tents, which
    /// are off the top of the screen, but the fact that the floor is three colours at once.
    private func drawSawdust(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 4_099)

        // Walkways worn through to the mud, running the way a crowd walks rather than the way
        // a mower drives: wide, wandering and crossing one another.
        for _ in 0..<5 {
            let down = y(scatter.next())
            var track = Path()
            track.move(to: CGPoint(x: -x(0.05), y: down))
            track.addCurve(
                to: CGPoint(x: size.width + x(0.05), y: down + y(scatter.next(in: -0.08...0.08))),
                control1: CGPoint(x: x(0.3), y: down + y(scatter.next(in: -0.06...0.06))),
                control2: CGPoint(x: x(0.7), y: down + y(scatter.next(in: -0.06...0.06)))
            )
            context.stroke(
                track,
                with: .color(.black.opacity(colors.isNight ? 0.16 : 0.09)),
                style: StrokeStyle(lineWidth: y(scatter.next(in: 0.02...0.05)), lineCap: .round)
            )
        }

        // The sawdust itself, thrown down in patches where the standing is.
        for _ in 0..<16 {
            let centre = CGPoint(x: x(scatter.next()), y: y(scatter.next()))
            let spread = x(scatter.next(in: 0.05...0.15))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.17,
                    width: spread, height: spread * 0.34
                )),
                with: .color(
                    Color(red: 0.86, green: 0.74, blue: 0.52)
                        .opacity(colors.isNight ? 0.10 : 0.24)
                )
            )
        }

        // And the lanterns' pools, which are the light in this world. They are laid on the
        // ground rather than hung in the air, because the string itself is above the screen.
        let lanterns: [Color] = [
            Color(red: 1.00, green: 0.78, blue: 0.36),
            Color(red: 0.98, green: 0.40, blue: 0.48),
            Color(red: 0.46, green: 0.72, blue: 0.96),
            Color(red: 0.62, green: 0.92, blue: 0.66)
        ]
        for index in 0..<9 {
            let centre = CGPoint(x: x(scatter.next(in: -0.05...1.05)), y: y(scatter.next()))
            let reach = x(scatter.next(in: 0.14...0.30))
            context.fill(
                circle(at: centre, radius: reach),
                with: .radialGradient(
                    Gradient(colors: [
                        lanterns[index % lanterns.count]
                            .opacity(colors.isNight ? 0.20 : 0.13),
                        lanterns[index % lanterns.count].opacity(0)
                    ]),
                    center: centre,
                    startRadius: 0,
                    endRadius: reach
                )
            )
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
    /// setts, drains and whatever comes up between the paving in a city; thrown stone and
    /// cooling sparks out in the reaches, where nothing comes up at all. Scattered on a
    /// fixed seed so the ground behind a level is the same ground every time the level is
    /// opened.
    private func drawDressing(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 2_311)
        let count: Int = switch colors.cover {
        case .pasture: 15
        case .woodland: 18
        case .scree: 13
        case .cobbles: 12
        case .dust: 11
        case .flowstone: 14
        case .sawdust: 16
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
                case .dust:
                    // Nothing grows out here, so the ground is dressed with what has landed
                    // on it: stones thrown out of the pits, and the odd spark still cooling.
                    switch roll {
                    case ..<0.52: drawStone(in: &context, at: spot, scale: scale)
                    default: drawSpark(in: &context, at: spot, scale: scale)
                    }
                case .flowstone:
                    // Nothing grows down here either, and the light does not come from
                    // overhead: it comes out of the rock. So the floor is dressed with what
                    // the roof has dropped on it and what the water has grown up out of it,
                    // with a crystal here and there doing the work the sky does elsewhere.
                    switch roll {
                    case ..<0.42: drawStalagmite(in: &context, at: spot, scale: scale)
                    case ..<0.72: drawStone(in: &context, at: spot, scale: scale)
                    default: drawCrystal(in: &context, at: spot, scale: scale)
                    }
                case .sawdust:
                    // A field with a fair on it is still a field, so the grass is here — but
                    // it is trodden grass with the fair's own leavings in it: pegs driven in
                    // with the rope going up out of shot, and a lantern hung low enough to
                    // stand beside. The board's own hazard is a guy rope, and this is where a
                    // player has already seen one before the first field asks about it.
                    switch roll {
                    case ..<0.44: drawTuft(in: &context, at: spot, scale: scale, scatter: &scatter)
                    case ..<0.76: drawPeg(in: &context, at: spot, scale: scale)
                    default: drawLantern(in: &context, at: spot, scale: scale)
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
        case .dust: 18
        case .flowstone: 24
        case .sawdust: 28
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
            case .dust:
                // No verge at all up here — a scatter of what came down, all the way to the
                // bottom of the screen.
                if roll < 0.7 {
                    drawStone(in: &context, at: foot, scale: CGFloat(scatter.next(in: 0.9...1.7)))
                } else {
                    drawSpark(in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.0...1.8)))
                }
            case .sawdust where roll < 0.3:
                // The front of the fair is where the ropes are pegged out, so the verge is
                // long grass with pegs standing in it.
                drawPeg(in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.0...1.7)))
            case .flowstone:
                // A rank of stalagmites along the front of the cave instead of long grass,
                // with the odd crystal in among them.
                if roll < 0.78 {
                    drawStalagmite(
                        in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.1...2.1))
                    )
                } else {
                    drawCrystal(in: &context, at: foot, scale: CGFloat(scatter.next(in: 1.0...1.7)))
                }
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

    /// A four-pointed spark lying in the dust with a little of the sky still in it — the
    /// backdrop's echo of the stardrops out on the board, and what the reaches have instead
    /// of wildflowers. It reads brightest after dark, since it is the one thing out here
    /// giving off light of its own.
    private func drawSpark(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let reach = x(0.013) * scale
        let glow = GamePalette.cream.opacity(colors.isNight ? 0.85 : 0.55)

        context.fill(
            circle(at: foot, radius: reach * 1.9),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.78, green: 0.72, blue: 1.00).opacity(colors.isNight ? 0.34 : 0.18),
                    Color(red: 0.78, green: 0.72, blue: 1.00).opacity(0)
                ]),
                center: foot,
                startRadius: 0,
                endRadius: reach * 1.9
            )
        )

        var points = Path()
        points.move(to: CGPoint(x: foot.x, y: foot.y - reach))
        points.addQuadCurve(
            to: CGPoint(x: foot.x + reach * 0.55, y: foot.y),
            control: CGPoint(x: foot.x + reach * 0.12, y: foot.y - reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: foot.x, y: foot.y + reach),
            control: CGPoint(x: foot.x + reach * 0.12, y: foot.y + reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: foot.x - reach * 0.55, y: foot.y),
            control: CGPoint(x: foot.x - reach * 0.12, y: foot.y + reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: foot.x, y: foot.y - reach),
            control: CGPoint(x: foot.x - reach * 0.12, y: foot.y - reach * 0.12)
        )
        context.fill(points, with: .color(glow))
    }

    /// A stalagmite stood up off the cave floor where the roof has been dripping on one spot
    /// for long enough — what the caverns have instead of a tuft of grass. It does not move,
    /// because nothing down here does: the one thing a cave has no weather.
    private func drawStalagmite(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = x(0.03) * scale
        let base = tall * 0.34

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - base * 0.7, y: foot.y - base * 0.12,
                width: base * 1.4, height: base * 0.34
            )),
            with: .color(.black.opacity(0.18))
        )

        var cone = Path()
        cone.move(to: CGPoint(x: foot.x - base * 0.5, y: foot.y))
        cone.addQuadCurve(
            to: CGPoint(x: foot.x + base * 0.08, y: foot.y - tall),
            control: CGPoint(x: foot.x - base * 0.34, y: foot.y - tall * 0.55)
        )
        cone.addQuadCurve(
            to: CGPoint(x: foot.x + base * 0.5, y: foot.y),
            control: CGPoint(x: foot.x + base * 0.42, y: foot.y - tall * 0.5)
        )
        cone.closeSubpath()
        context.fill(cone, with: .color(GamePalette.stone.opacity(colors.isNight ? 0.42 : 0.78)))

        // The wet side of it, which is the side the light is coming from.
        var sheen = Path()
        sheen.move(to: CGPoint(x: foot.x - base * 0.28, y: foot.y - tall * 0.06))
        sheen.addQuadCurve(
            to: CGPoint(x: foot.x + base * 0.02, y: foot.y - tall * 0.92),
            control: CGPoint(x: foot.x - base * 0.2, y: foot.y - tall * 0.5)
        )
        context.stroke(
            sheen,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.14 : 0.3)),
            style: StrokeStyle(lineWidth: max(1, base * 0.16), lineCap: .round)
        )
    }

    /// A crystal growing out of the flowstone with its own light in it — the backdrop's echo
    /// of the crystals lying on the board, and what the caverns have instead of wildflowers.
    /// It reads brightest after dark for the same reason a stardrop does, and for a better
    /// one: down here it is the only light there is.
    private func drawCrystal(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = x(0.024) * scale
        let wide = tall * 0.46

        context.fill(
            circle(at: CGPoint(x: foot.x, y: foot.y - tall * 0.5), radius: tall * 1.5),
            with: .radialGradient(
                Gradient(colors: [
                    colors.disc.opacity(colors.isNight ? 0.32 : 0.18),
                    colors.disc.opacity(0)
                ]),
                center: CGPoint(x: foot.x, y: foot.y - tall * 0.5),
                startRadius: 0,
                endRadius: tall * 1.5
            )
        )

        // Three shards out of one root, the tallest leaning a little off upright.
        for lean in [-0.42, 0.06, 0.5] {
            let tip = CGPoint(
                x: foot.x + tall * CGFloat(lean) * 0.7,
                y: foot.y - tall * (lean == 0.06 ? 1.0 : 0.62)
            )
            let spread = wide * (lean == 0.06 ? 1.0 : 0.66)
            var shard = Path()
            shard.move(to: tip)
            shard.addLine(to: CGPoint(x: tip.x + spread * 0.5, y: foot.y - spread * 0.3))
            shard.addLine(to: CGPoint(x: tip.x + spread * 0.28, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - spread * 0.28, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - spread * 0.5, y: foot.y - spread * 0.3))
            shard.closeSubpath()
            context.fill(shard, with: .color(colors.disc.opacity(colors.isNight ? 0.9 : 0.72)))
            context.stroke(
                shard,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.5 : 0.32)),
                lineWidth: max(0.6, wide * 0.08)
            )
        }
    }

    /// A tent peg driven into the ground with the guy rope going up off the top of the screen
    /// — the backdrop's echo of the ropes staked out on the board, and what the carnival has
    /// instead of wildflowers. The rope is drawn taut because a slack one is a tent down.
    private func drawPeg(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = x(0.026) * scale
        let lean = tall * 0.42

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - tall * 0.22, y: foot.y - tall * 0.05,
                width: tall * 0.44, height: tall * 0.14
            )),
            with: .color(.black.opacity(0.2))
        )

        var peg = Path()
        peg.move(to: CGPoint(x: foot.x - lean * 0.5, y: foot.y - tall * 0.34))
        peg.addLine(to: CGPoint(x: foot.x + lean * 0.2, y: foot.y))
        context.stroke(
            peg,
            with: .color(Color(red: 0.32, green: 0.24, blue: 0.18).opacity(colors.isNight ? 0.7 : 0.85)),
            style: StrokeStyle(lineWidth: max(1, tall * 0.13), lineCap: .round)
        )

        var rope = Path()
        rope.move(to: CGPoint(x: foot.x - lean * 0.5, y: foot.y - tall * 0.3))
        rope.addLine(to: CGPoint(x: foot.x + lean * 1.5, y: foot.y - tall * 1.5))
        context.stroke(
            rope,
            with: .color(
                Color(red: 0.80, green: 0.70, blue: 0.52).opacity(colors.isNight ? 0.42 : 0.62)
            ),
            style: StrokeStyle(lineWidth: max(0.8, tall * 0.07), lineCap: .round)
        )
    }

    /// A paper lantern hung low on its own short pole, with the light it is throwing on the
    /// ground under it. It reads brightest after dark for the reason a crystal does — and for
    /// a better one, since after dark it is the only reason anybody can see the fair at all.
    private func drawLantern(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = x(0.034) * scale
        let bulb = CGPoint(x: foot.x, y: foot.y - tall)
        let wide = tall * 0.34
        let shade = Color(red: 0.98, green: 0.52, blue: 0.42)

        context.fill(
            circle(at: bulb, radius: tall * 1.1),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 1.00, green: 0.80, blue: 0.46).opacity(colors.isNight ? 0.36 : 0.18),
                    Color(red: 1.00, green: 0.80, blue: 0.46).opacity(0)
                ]),
                center: bulb,
                startRadius: 0,
                endRadius: tall * 1.1
            )
        )

        var pole = Path()
        pole.move(to: foot)
        pole.addLine(to: CGPoint(x: bulb.x, y: bulb.y + wide * 0.5))
        context.stroke(
            pole,
            with: .color(Color(red: 0.26, green: 0.19, blue: 0.16).opacity(colors.isNight ? 0.6 : 0.8)),
            style: StrokeStyle(lineWidth: max(1, tall * 0.07), lineCap: .round)
        )

        context.fill(
            Path(ellipseIn: CGRect(
                x: bulb.x - wide * 0.5, y: bulb.y - wide * 0.6,
                width: wide, height: wide * 1.2
            )),
            with: .color(shade.opacity(colors.isNight ? 0.92 : 0.78))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: bulb.x - wide * 0.22, y: bulb.y - wide * 0.42,
                width: wide * 0.44, height: wide * 0.84
            )),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.7 : 0.45))
        )
    }

    /// The corners taken down a little, which is all it takes to make the board the lit
    /// thing on the screen. A thicket closes in harder, so the canopy feels overhead; a
    /// mountain sits somewhere between the two, open sky but a hazed one; a city closes
    /// in nearly as hard as a wood, since the buildings are the canopy here; the reaches close
    /// in harder still, because what is round the edge of them is space; and the caverns close
    /// in hardest of all, because what is round the edge of them is rock and no light on it.
    /// The carnival is the exception in both directions: it opens back up, since what is round
    /// the edge of it is more fair.
    func drawVignette(in context: inout GraphicsContext) {
        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        let reach = max(size.width, size.height) * 0.8
        let edge: Double = switch colors.cover {
        case .pasture: colors.isNight ? 0.3 : 0.2
        case .woodland: colors.isNight ? 0.42 : 0.32
        case .scree: colors.isNight ? 0.38 : 0.26
        case .cobbles: colors.isNight ? 0.44 : 0.30
        case .dust: colors.isNight ? 0.52 : 0.34
        case .flowstone: colors.isNight ? 0.62 : 0.44
        // The one world that closes in *less* after dark than by day, because after dark
        // somebody has switched the lights on.
        case .sawdust: colors.isNight ? 0.40 : 0.28
        }
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [
                    .black.opacity(0),
                    .black.opacity(edge)
                ]),
                center: centre,
                startRadius: reach * (colors.cover == .woodland || colors.cover == .flowstone
                    ? 0.32 : 0.4),
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

#Preview("Starfall Reaches") {
    MeadowBackdrop(day: .starDay, dusk: .starDusk)
        .ignoresSafeArea()
}

#Preview("Gloamdeep Caverns") {
    MeadowBackdrop(day: .gloamDay, dusk: .gloamDusk)
        .ignoresSafeArea()
}
