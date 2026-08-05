import Foundation
import SwiftUI

/// The meadow the trail runs through: fields, trees, ponds, and a barn at the bottom
/// where the pig set out from.
///
/// Everything is placed from the shape of the trail itself, so no tree ever lands on the
/// path or on a signpost however wide the screen is. It is drawn once rather than on a
/// clock — the moving parts of this screen are the pig and the trail, and a scrolling
/// world that repainted every blade of grass at 30 frames a second would not be worth it.
struct WorldMapScene: View {
    let trail: WorldTrail
    let colors: GamePalette.Pasture

    var body: some View {
        Canvas { context, size in
            Meadow(trail: trail, size: size, colors: colors).draw(in: &context)
        }
        .accessibilityHidden(true)
    }
}

/// One painting of the meadow, top to bottom.
private struct Meadow {
    let trail: WorldTrail
    let size: CGSize
    let colors: GamePalette.Pasture

    /// Where the far hills meet the fields, at the top of the world.
    private var horizon: CGFloat { WorldTrail.headroom * 0.62 }

    func draw(in context: inout GraphicsContext) {
        drawFields(in: &context)
        drawSky(in: &context)
        drawHills(in: &context)

        let dressing = scenery()
        for pond in dressing.ponds {
            drawPond(in: &context, at: pond)
        }
        for place in dressing.places {
            draw(place, in: &context)
        }
        drawBarn(in: &context)
    }

    // MARK: - The lie of the land

    private func drawFields(in context: inout GraphicsContext) {
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(colors.ground))

        // Bands of mown grass, each with a wandering edge, so the meadow reads as farmed
        // ground rather than a flat green wall.
        var scatter = Scatter(seed: 907)
        var top = horizon
        var shaded = true
        while top < size.height {
            let depth = CGFloat(scatter.next(in: 90...170))
            if shaded {
                context.fill(
                    band(from: top, to: top + depth, wobble: scatter.next()),
                    with: .color(colors.foreground.opacity(0.22))
                )
            }
            shaded.toggle()
            top += depth
        }
    }

    /// A band across the whole width with a gently curved top and bottom edge.
    private func band(from top: CGFloat, to bottom: CGFloat, wobble: Double) -> Path {
        var path = Path()
        let sway = CGFloat(9)
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

    private func drawSky(in context: inout GraphicsContext) {
        let sky = CGRect(x: 0, y: 0, width: size.width, height: horizon)
        context.fill(
            Path(sky),
            with: .linearGradient(
                Gradient(colors: [colors.skyTop, colors.skyHorizon]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: horizon)
            )
        )

        let disc = CGPoint(x: size.width * 0.78, y: horizon * 0.42)
        let radius = size.width * 0.055
        context.fill(
            circle(at: disc, radius: radius * 3),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.4), colors.discHalo.opacity(0)]),
                center: disc,
                startRadius: radius * 0.6,
                endRadius: radius * 3
            )
        )
        context.fill(circle(at: disc, radius: radius), with: .color(colors.disc))

        var scatter = Scatter(seed: 311)
        for _ in 0..<3 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: 0.08...0.72)) * size.width,
                y: CGFloat(scatter.next(in: 0.18...0.72)) * horizon
            )
            context.fill(
                cloud(at: centre, width: size.width * CGFloat(scatter.next(in: 0.20...0.32))),
                with: .color(colors.cloud.opacity(colors.isNight ? 0.55 : 0.9))
            )
        }
    }

    private func cloud(at centre: CGPoint, width: CGFloat) -> Path {
        let height = width * 0.4
        var path = Path()
        path.addEllipse(in: CGRect(
            x: centre.x - width * 0.48, y: centre.y - height * 0.2,
            width: width * 0.52, height: height * 0.56
        ))
        path.addEllipse(in: CGRect(
            x: centre.x - width * 0.18, y: centre.y - height * 0.54,
            width: width * 0.58, height: height * 0.9
        ))
        path.addRoundedRect(
            in: CGRect(x: centre.x - width * 0.46, y: centre.y, width: width * 0.9, height: height * 0.3),
            cornerSize: CGSize(width: height * 0.15, height: height * 0.15)
        )
        return path
    }

    /// The hills the world runs out into, and the hedge along the foot of them.
    private func drawHills(in context: inout GraphicsContext) {
        var hills = Path()
        hills.move(to: CGPoint(x: 0, y: horizon))
        hills.addQuadCurve(
            to: CGPoint(x: size.width * 0.46, y: horizon),
            control: CGPoint(x: size.width * 0.22, y: horizon - 54)
        )
        hills.addQuadCurve(
            to: CGPoint(x: size.width, y: horizon),
            control: CGPoint(x: size.width * 0.74, y: horizon - 78)
        )
        hills.addLine(to: CGPoint(x: size.width, y: horizon + 26))
        hills.addLine(to: CGPoint(x: 0, y: horizon + 26))
        hills.closeSubpath()
        context.fill(hills, with: .color(colors.farHill))

        var hedge = Path()
        hedge.move(to: CGPoint(x: 0, y: horizon + 24))
        hedge.addQuadCurve(
            to: CGPoint(x: size.width, y: horizon + 20),
            control: CGPoint(x: size.width / 2, y: horizon + 32)
        )
        context.stroke(
            hedge,
            with: .color(colors.canopyShade),
            style: StrokeStyle(lineWidth: 12, lineCap: .round)
        )
    }

    // MARK: - What stands in the fields

    private enum Growth {
        case tree
        case bush
        case flowers
        case rock
        case hayBale
    }

    private struct Place {
        let at: CGPoint
        let growth: Growth
        let size: CGFloat
        /// How far the spot is from the nearest bit of trail, which is what decides
        /// whether there is room for a pond here.
        let room: CGFloat
    }

    /// Spots for everything the meadow is dressed with, on a jittered grid with the trail
    /// and the signposts cut out of it. Ponds want more room than a tree, so they take
    /// the two clearest spots the grid found and shoulder their neighbours out of the way.
    private func scenery() -> (places: [Place], ponds: [CGPoint]) {
        let waymarks = trail.waymarks()
        let stops = (0..<trail.map.count).map { trail.point(of: $0) }
        var scatter = Scatter(seed: 4_071)
        var candidates: [Place] = []

        var down = horizon + 34
        while down < size.height - 40 {
            var across: CGFloat = 24
            while across < size.width - 24 {
                let spot = CGPoint(
                    x: across + CGFloat(scatter.next(in: -20...20)),
                    y: down + CGFloat(scatter.next(in: -20...20))
                )
                let kind = growth(scatter.next())
                let scale = CGFloat(scatter.next(in: 0.8...1.25))
                across += 76

                let room = nearest(to: spot, among: waymarks)
                guard room > 56, nearest(to: spot, among: stops) > 92 else { continue }
                candidates.append(Place(at: spot, growth: kind, size: scale, room: room))
            }
            down += 74
        }

        var ponds: [CGPoint] = []
        for candidate in candidates.sorted(by: { $0.room > $1.room }) {
            guard ponds.count < 2, candidate.room > 104 else { break }
            guard ponds.allSatisfy({ abs($0.y - candidate.at.y) > 260 }) else { continue }
            ponds.append(candidate.at)
        }

        let places = candidates.filter { place in
            ponds.allSatisfy { distance(from: place.at, to: $0) > 96 }
        }
        return (places, ponds)
    }

    private func growth(_ roll: Double) -> Growth {
        switch roll {
        case ..<0.34: .tree
        case ..<0.52: .bush
        case ..<0.76: .flowers
        case ..<0.88: .rock
        default: .hayBale
        }
    }

    private func draw(_ place: Place, in context: inout GraphicsContext) {
        switch place.growth {
        case .tree: drawTree(in: &context, at: place.at, scale: place.size)
        case .bush: drawBush(in: &context, at: place.at, scale: place.size)
        case .flowers: drawFlowers(in: &context, at: place.at, scale: place.size)
        case .rock: drawRock(in: &context, at: place.at, scale: place.size)
        case .hayBale: drawHayBale(in: &context, at: place.at, scale: place.size)
        }
    }

    private func drawTree(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 26 * scale
        shadow(in: &context, at: foot, width: spread * 0.9)

        let trunk = CGRect(
            x: foot.x - spread * 0.11, y: foot.y - spread * 0.62,
            width: spread * 0.22, height: spread * 0.62
        )
        context.fill(
            Path(roundedRect: trunk, cornerRadius: spread * 0.08),
            with: .color(GamePalette.rail)
        )

        var canopy = Path()
        canopy.addEllipse(in: CGRect(
            x: foot.x - spread * 0.52, y: foot.y - spread * 1.22,
            width: spread * 0.72, height: spread * 0.72
        ))
        canopy.addEllipse(in: CGRect(
            x: foot.x - spread * 0.16, y: foot.y - spread * 1.42,
            width: spread * 0.80, height: spread * 0.80
        ))
        canopy.addEllipse(in: CGRect(
            x: foot.x - spread * 0.42, y: foot.y - spread * 0.98,
            width: spread * 0.90, height: spread * 0.66
        ))
        context.fill(canopy, with: .color(colors.canopy))

        // One lit leaf cluster up on the left, where the light in this game always is.
        context.fill(
            circle(
                at: CGPoint(x: foot.x - spread * 0.24, y: foot.y - spread * 1.02),
                radius: spread * 0.22
            ),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.08 : 0.22))
        )
    }

    private func drawBush(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 17 * scale
        shadow(in: &context, at: foot, width: spread)

        var bush = Path()
        for lobe in [(-0.42, 0.34, 0.52), (0.0, 0.0, 0.72), (0.44, 0.30, 0.50)] {
            bush.addEllipse(in: CGRect(
                x: foot.x + spread * CGFloat(lobe.0) - spread * CGFloat(lobe.2) / 2,
                y: foot.y - spread * CGFloat(lobe.2) + spread * CGFloat(lobe.1) * 0.4,
                width: spread * CGFloat(lobe.2),
                height: spread * CGFloat(lobe.2)
            ))
        }
        context.fill(bush, with: .color(colors.canopyShade))
    }

    private func drawFlowers(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        var scatter = Scatter(seed: UInt64(abs(foot.x * 7 + foot.y * 13)))
        let petal = 3.4 * scale

        for _ in 0..<5 {
            let centre = CGPoint(
                x: foot.x + CGFloat(scatter.next(in: -14...14)) * scale,
                y: foot.y + CGFloat(scatter.next(in: -10...10)) * scale
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
            context.fill(petals, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.35 : 0.92)))
            context.fill(
                circle(at: centre, radius: petal * 0.42),
                with: .color(GamePalette.pen.opacity(colors.isNight ? 0.4 : 0.95))
            )
        }
    }

    private func drawRock(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 13 * scale
        shadow(in: &context, at: foot, width: spread)
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.5, y: foot.y - spread * 0.62,
                width: spread, height: spread * 0.74
            )),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.55 : 0.9))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.32, y: foot.y - spread * 0.56,
                width: spread * 0.44, height: spread * 0.26
            )),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.1 : 0.28))
        )
    }

    private func drawHayBale(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 20 * scale
        shadow(in: &context, at: foot, width: spread)

        let bale = CGRect(
            x: foot.x - spread * 0.5, y: foot.y - spread * 0.86,
            width: spread, height: spread * 0.86
        )
        context.fill(
            Path(roundedRect: bale, cornerRadius: spread * 0.42),
            with: .color(GamePalette.pen.opacity(colors.isNight ? 0.5 : 0.95))
        )
        var strands = Path()
        for line in [0.32, 0.58, 0.82] {
            let y = bale.minY + bale.height * CGFloat(line)
            strands.move(to: CGPoint(x: bale.minX + bale.width * 0.16, y: y))
            strands.addLine(to: CGPoint(x: bale.maxX - bale.width * 0.16, y: y))
        }
        context.stroke(
            strands,
            with: .color(GamePalette.rail.opacity(0.45)),
            style: StrokeStyle(lineWidth: max(1, spread * 0.06), lineCap: .round)
        )
    }

    private func drawPond(in context: inout GraphicsContext, at centre: CGPoint) {
        // Pulled back in from the sides, so a pond is never a half-pond cut off by the
        // edge of the screen.
        let across = min(max(centre.x, 50), size.width - 50)
        let bounds = CGRect(x: across - 46, y: centre.y - 26, width: 92, height: 52)
        context.fill(
            Path(ellipseIn: bounds.insetBy(dx: -4, dy: -4)),
            with: .color(colors.canopyShade.opacity(0.45))
        )
        context.fill(Path(ellipseIn: bounds), with: .color(colors.lake))

        for level in [0.36, 0.62] {
            var ripple = Path()
            let y = bounds.minY + bounds.height * CGFloat(level)
            ripple.move(to: CGPoint(x: bounds.minX + bounds.width * 0.24, y: y))
            ripple.addQuadCurve(
                to: CGPoint(x: bounds.maxX - bounds.width * 0.24, y: y),
                control: CGPoint(x: bounds.midX, y: y - bounds.height * 0.16)
            )
            context.stroke(
                ripple,
                with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.3 : 0.6)),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
        }
    }

    /// The barn the pig came out of, standing in the grass below the first signpost.
    private func drawBarn(in context: inout GraphicsContext) {
        let start = trail.point(of: 0)
        let centre = CGPoint(
            x: start.x < size.width / 2 ? size.width - 74 : 74,
            y: size.height - WorldTrail.apron * 0.42
        )
        let wide: CGFloat = 78
        let tall: CGFloat = 50

        shadow(in: &context, at: CGPoint(x: centre.x, y: centre.y + tall / 2), width: wide * 0.9)

        let walls = CGRect(x: centre.x - wide / 2, y: centre.y - tall * 0.1, width: wide, height: tall * 0.6)
        context.fill(Path(walls), with: .color(GamePalette.barn))

        var roof = Path()
        roof.move(to: CGPoint(x: walls.minX - 7, y: walls.minY))
        roof.addLine(to: CGPoint(x: centre.x, y: walls.minY - tall * 0.5))
        roof.addLine(to: CGPoint(x: walls.maxX + 7, y: walls.minY))
        roof.closeSubpath()
        context.fill(roof, with: .color(GamePalette.post))

        let door = CGRect(
            x: centre.x - wide * 0.15, y: walls.minY + walls.height * 0.24,
            width: wide * 0.3, height: walls.height * 0.76
        )
        context.fill(
            Path(roundedRect: door, cornerRadius: 3),
            with: .color(GamePalette.post.opacity(0.85))
        )

        var trim = Path()
        trim.move(to: CGPoint(x: walls.minX + 6, y: walls.minY + walls.height * 0.34))
        trim.addLine(to: CGPoint(x: door.minX - 4, y: walls.minY + walls.height * 0.34))
        trim.move(to: CGPoint(x: door.maxX + 4, y: walls.minY + walls.height * 0.34))
        trim.addLine(to: CGPoint(x: walls.maxX - 6, y: walls.minY + walls.height * 0.34))
        context.stroke(trim, with: .color(GamePalette.cream.opacity(0.8)), lineWidth: 3)
    }

    // MARK: - Small helpers

    private func shadow(in context: inout GraphicsContext, at foot: CGPoint, width: CGFloat) {
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - width / 2, y: foot.y - width * 0.12,
                width: width, height: width * 0.3
            )),
            with: .color(.black.opacity(0.16))
        )
    }

    private func circle(at centre: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: centre.x - radius, y: centre.y - radius,
            width: radius * 2, height: radius * 2
        ))
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let across = from.x - to.x
        let down = from.y - to.y
        return sqrt(across * across + down * down)
    }

    private func nearest(to spot: CGPoint, among points: [CGPoint]) -> CGFloat {
        points.reduce(CGFloat.greatestFiniteMagnitude) { min($0, distance(from: spot, to: $1)) }
    }
}
