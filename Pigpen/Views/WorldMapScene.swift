import Foundation
import SwiftUI

/// The meadow the trail runs through: fields, trees, hay and a barn at the bottom
/// where the pig set out from. Every other world keeps the same trail and draws it the same
/// way, on its own ground — denser trees, leaf litter, ferns and a hollow stump in a
/// thicket; ash, loose rock, scorched pines and a cairn on a mountain.
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

/// One painting of the ground the trail runs through, top to bottom.
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

        for place in scenery() {
            draw(place, in: &context)
        }
        switch colors.cover {
        case .pasture: drawBarn(in: &context)
        case .woodland: drawHollow(in: &context)
        case .scree: drawCairn(in: &context)
        }
    }

    // MARK: - The lie of the land

    private func drawFields(in context: inout GraphicsContext) {
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(colors.ground))

        switch colors.cover {
        case .pasture: drawMowing(in: &context)
        case .woodland: drawLeafLitter(in: &context)
        case .scree: drawAshDrifts(in: &context)
        }
    }

    /// Bands of mown grass, each with a wandering edge, so the meadow reads as farmed
    /// ground rather than a flat green wall.
    private func drawMowing(in context: inout GraphicsContext) {
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

    /// Soft blotches of leaf mould under the canopy, so a thicket reads as woodland floor
    /// rather than a mown paddock painted a darker green.
    private func drawLeafLitter(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_109)
        for _ in 0..<28 {
            let centre = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 40...110))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.6,
                    y: centre.y - spread * 0.28,
                    width: spread * 1.2,
                    height: spread * 0.55
                )),
                with: .color(
                    colors.isNight
                        ? Color(red: 0.18, green: 0.14, blue: 0.08).opacity(0.22)
                        : Color(red: 0.42, green: 0.32, blue: 0.18).opacity(0.28)
                )
            )
        }
    }

    /// Drifts of ash with the cinder showing through, so the mountain's trail runs over
    /// burnt ground rather than through a paddock painted grey.
    private func drawAshDrifts(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_493)
        for index in 0..<30 {
            let centre = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 44...120))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.6,
                    y: centre.y - spread * 0.24,
                    width: spread * 1.2,
                    height: spread * 0.48
                )),
                with: .color(
                    index % 3 == 0
                        ? Color(red: 0.42, green: 0.14, blue: 0.08)
                            .opacity(colors.isNight ? 0.34 : 0.20)
                        : Color(red: 0.72, green: 0.68, blue: 0.66)
                            .opacity(colors.isNight ? 0.08 : 0.22)
                )
            )
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

        // A wooded sky keeps less open air: fewer, softer clouds under a canopy that
        // reaches up into the hills. A mountain sky is hazed rather than clouded, so what
        // is up there is thin and hangs low.
        var scatter = Scatter(seed: 311)
        let clouds: Int = switch colors.cover {
        case .pasture: 3
        case .woodland: 1
        case .scree: 2
        }
        for _ in 0..<clouds {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: 0.08...0.72)) * size.width,
                y: CGFloat(scatter.next(in: 0.18...0.72)) * horizon
            )
            context.fill(
                cloud(at: centre, width: size.width * CGFloat(scatter.next(in: 0.20...0.32))),
                with: .color(colors.cloud.opacity(cloudOpacity))
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

    /// The hills the world runs out into, and the hedge along the foot of them. A thicket
    /// gets a taller dark tree line instead of a low hedge, so the sky closes sooner; a
    /// mountain gets the peak itself, standing over the trail with smoke coming off it.
    private func drawHills(in context: inout GraphicsContext) {
        var hills = Path()
        hills.move(to: CGPoint(x: 0, y: horizon))
        hills.addQuadCurve(
            to: CGPoint(x: size.width * 0.46, y: horizon),
            control: CGPoint(x: size.width * 0.22, y: horizon - (colors.cover == .woodland ? 72 : 54))
        )
        hills.addQuadCurve(
            to: CGPoint(x: size.width, y: horizon),
            control: CGPoint(x: size.width * 0.74, y: horizon - (colors.cover == .woodland ? 96 : 78))
        )
        hills.addLine(to: CGPoint(x: size.width, y: horizon + 26))
        hills.addLine(to: CGPoint(x: 0, y: horizon + 26))
        hills.closeSubpath()
        context.fill(hills, with: .color(colors.farHill))

        if colors.cover == .scree {
            drawPeak(in: &context)
        }

        if colors.cover == .woodland {
            drawCanopyLine(in: &context)
        } else {
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
    }

    /// How solid what is up in the sky reads: a full white cloud over the meadow, something
    /// thinner over a canopy or a peak, and everything faint after dark.
    private var cloudOpacity: Double {
        if colors.isNight { return 0.55 }
        return colors.cover == .pasture ? 0.9 : 0.55
    }

    /// The peak itself, standing up out of the hills with smoke coming off the top of it.
    /// It is the one thing on this screen that says where the trail is going, so it is drawn
    /// behind the tree line and the signposts and never over them.
    private func drawPeak(in context: inout GraphicsContext) {
        let foot = horizon + 26
        let apex = CGPoint(x: size.width * 0.62, y: horizon - 104)
        let spread = size.width * 0.34

        var cone = Path()
        cone.move(to: CGPoint(x: apex.x - spread, y: foot))
        cone.addLine(to: CGPoint(x: apex.x - spread * 0.16, y: apex.y))
        // The crater: the summit is a notch rather than a point.
        cone.addLine(to: CGPoint(x: apex.x, y: apex.y + 12))
        cone.addLine(to: CGPoint(x: apex.x + spread * 0.18, y: apex.y - 4))
        cone.addLine(to: CGPoint(x: apex.x + spread, y: foot))
        cone.closeSubpath()
        context.fill(cone, with: .color(colors.canopyShade))

        // The lit western flank, the way the light falls on everything else in the game.
        var flank = Path()
        flank.move(to: CGPoint(x: apex.x - spread, y: foot))
        flank.addLine(to: CGPoint(x: apex.x - spread * 0.16, y: apex.y))
        flank.addLine(to: CGPoint(x: apex.x - spread * 0.06, y: foot))
        flank.closeSubpath()
        context.fill(flank, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.12)))

        // What the mountain is always doing, in three rising puffs.
        for step in 0..<3 {
            let lift = CGFloat(step)
            context.fill(
                circle(
                    at: CGPoint(x: apex.x + lift * 9, y: apex.y - 14 - lift * 26),
                    radius: 12 + lift * 7
                ),
                with: .color(colors.cloud.opacity(colors.isNight ? 0.22 : 0.34))
            )
        }
        context.fill(
            circle(at: CGPoint(x: apex.x, y: apex.y + 6), radius: 7),
            with: .color(Color(red: 0.95, green: 0.42, blue: 0.16).opacity(colors.isNight ? 0.85 : 0.5))
        )
    }

    /// A run of dark crowns along the horizon, so the thicket feels closed in rather than
    /// opening onto open country.
    private func drawCanopyLine(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 677)
        var across: CGFloat = -10
        while across < size.width + 20 {
            let spread = CGFloat(scatter.next(in: 28...46))
            let foot = CGPoint(
                x: across + CGFloat(scatter.next(in: -6...6)),
                y: horizon + 18
            )
            context.fill(
                circle(at: CGPoint(x: foot.x, y: foot.y - spread * 0.55), radius: spread * 0.55),
                with: .color(colors.canopyShade)
            )
            across += spread * 0.85
        }
    }

    // MARK: - What stands in the fields

    private enum Growth {
        case tree
        case bush
        case flowers
        case fern
        case rock
        case hayBale
        case stump
    }

    private struct Place {
        let at: CGPoint
        let growth: Growth
        let size: CGFloat
    }

    /// Spots for everything the ground is dressed with, on a jittered grid with the trail
    /// and the signposts cut out of it. A thicket packs the grid tighter and grows more
    /// trees, so the same trail reads as woods rather than open pasture.
    private func scenery() -> [Place] {
        let waymarks = trail.waymarks()
        let stops = (0..<trail.map.count).map { trail.point(of: $0) }
        var scatter = Scatter(seed: 4_071)
        var places: [Place] = []

        let stepAcross: CGFloat = colors.cover == .woodland ? 46 : 68
        let stepDown: CGFloat = colors.cover == .woodland ? 48 : 66
        var down = horizon + 34
        while down < size.height - 40 {
            var across: CGFloat = 22
            while across < size.width - 22 {
                let spot = CGPoint(
                    x: across + CGFloat(scatter.next(in: -18...18)),
                    y: down + CGFloat(scatter.next(in: -18...18))
                )
                let kind = growth(scatter.next())
                let scale = CGFloat(scatter.next(in: 0.8...1.25))
                    * (colors.cover == .woodland && kind == .tree ? 1.2 : 1)
                across += stepAcross

                guard nearest(to: spot, among: waymarks) > (colors.cover == .woodland ? 44 : 54),
                      nearest(to: spot, among: stops) > (colors.cover == .woodland ? 78 : 92),
                      distance(from: spot, to: landmarkStand) > 96
                else { continue }
                places.append(Place(at: spot, growth: kind, size: scale))
            }
            down += stepDown
        }

        return places
    }

    private func growth(_ roll: Double) -> Growth {
        switch colors.cover {
        case .woodland:
            switch roll {
            case ..<0.48: .tree
            case ..<0.70: .bush
            case ..<0.84: .fern
            case ..<0.93: .rock
            default: .stump
            }
        case .scree:
            // Burnt ground: mostly loose rock, with the odd dead stump and a pine that
            // came through it.
            switch roll {
            case ..<0.56: .rock
            case ..<0.78: .stump
            case ..<0.90: .bush
            default: .tree
            }
        case .pasture:
            switch roll {
            case ..<0.34: .tree
            case ..<0.52: .bush
            case ..<0.76: .flowers
            case ..<0.88: .rock
            default: .hayBale
            }
        }
    }

    private func draw(_ place: Place, in context: inout GraphicsContext) {
        switch place.growth {
        case .tree: drawTree(in: &context, at: place.at, scale: place.size)
        case .bush: drawBush(in: &context, at: place.at, scale: place.size)
        case .flowers: drawFlowers(in: &context, at: place.at, scale: place.size)
        case .fern: drawFern(in: &context, at: place.at, scale: place.size)
        case .rock: drawRock(in: &context, at: place.at, scale: place.size)
        case .hayBale: drawHayBale(in: &context, at: place.at, scale: place.size)
        case .stump: drawStump(in: &context, at: place.at, scale: place.size)
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

        // A pine that came through the burn: bare, dark and pointed, rather than the round
        // crown either of the green worlds grows.
        if colors.cover == .scree {
            var pine = Path()
            for tier in 0..<3 {
                let lift = spread * (1.34 - CGFloat(tier) * 0.34)
                let width = spread * (0.42 + CGFloat(tier) * 0.20)
                pine.move(to: CGPoint(x: foot.x - width, y: foot.y - lift + spread * 0.22))
                pine.addLine(to: CGPoint(x: foot.x, y: foot.y - lift - spread * 0.22))
                pine.addLine(to: CGPoint(x: foot.x + width, y: foot.y - lift + spread * 0.22))
                pine.closeSubpath()
            }
            context.fill(pine, with: .color(colors.canopyShade))
            return
        }

        var canopy = Path()
        if colors.cover == .woodland {
            // A taller, more irregular crown so a thicket tree is not the meadow's lollipop
            // painted a darker green.
            canopy.addEllipse(in: CGRect(
                x: foot.x - spread * 0.58, y: foot.y - spread * 1.45,
                width: spread * 0.78, height: spread * 0.78
            ))
            canopy.addEllipse(in: CGRect(
                x: foot.x - spread * 0.18, y: foot.y - spread * 1.62,
                width: spread * 0.86, height: spread * 0.86
            ))
            canopy.addEllipse(in: CGRect(
                x: foot.x - spread * 0.48, y: foot.y - spread * 1.08,
                width: spread * 0.98, height: spread * 0.72
            ))
            canopy.addEllipse(in: CGRect(
                x: foot.x - spread * 0.08, y: foot.y - spread * 1.18,
                width: spread * 0.62, height: spread * 0.58
            ))
        } else {
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
        }
        context.fill(canopy, with: .color(colors.canopy))
        if colors.cover == .woodland {
            context.fill(canopy, with: .color(colors.canopyShade.opacity(0.35)))
        }

        // One lit leaf cluster up on the left, where the light in this game always is.
        context.fill(
            circle(
                at: CGPoint(x: foot.x - spread * 0.24, y: foot.y - spread * 1.02),
                radius: spread * 0.22
            ),
            with: .color(
                GamePalette.cream
                    .opacity(colors.isNight ? 0.08 : (colors.cover == .woodland ? 0.12 : 0.22))
            )
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

    /// A few fronds for the thicket floor, in place of the meadow's wildflowers.
    private func drawFern(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let height = 16 * scale
        shadow(in: &context, at: foot, width: height * 0.7)
        var fronds = Path()
        for lean in [-0.85, -0.35, 0.2, 0.7] {
            let tip = CGPoint(
                x: foot.x + height * CGFloat(lean) * 0.55,
                y: foot.y - height * CGFloat(0.7 + abs(lean) * 0.2)
            )
            fronds.move(to: foot)
            fronds.addQuadCurve(
                to: tip,
                control: CGPoint(x: foot.x + height * CGFloat(lean) * 0.2, y: foot.y - height * 0.45)
            )
        }
        context.stroke(
            fronds,
            with: .color(colors.blade.opacity(colors.isNight ? 0.7 : 0.95)),
            style: StrokeStyle(lineWidth: max(1.5, height * 0.12), lineCap: .round)
        )
        // Small leaflets off the middle fronds, just enough to read as fern rather than grass.
        var leaflets = Path()
        for lean in [-0.35, 0.2] {
            let mid = CGPoint(
                x: foot.x + height * CGFloat(lean) * 0.28,
                y: foot.y - height * 0.4
            )
            leaflets.move(to: mid)
            leaflets.addLine(to: CGPoint(x: mid.x - height * 0.18, y: mid.y - height * 0.08))
            leaflets.move(to: mid)
            leaflets.addLine(to: CGPoint(x: mid.x + height * 0.18, y: mid.y - height * 0.08))
        }
        context.stroke(
            leaflets,
            with: .color(colors.canopy.opacity(0.85)),
            style: StrokeStyle(lineWidth: max(1, height * 0.08), lineCap: .round)
        )
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

    /// A cut stump for the thicket floor, where the meadow would have left a hay bale.
    private func drawStump(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 14 * scale
        shadow(in: &context, at: foot, width: spread)

        let bole = CGRect(
            x: foot.x - spread * 0.38, y: foot.y - spread * 0.55,
            width: spread * 0.76, height: spread * 0.55
        )
        context.fill(
            Path(roundedRect: bole, cornerRadius: spread * 0.12),
            with: .color(GamePalette.rail.opacity(colors.isNight ? 0.7 : 0.95))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.4, y: foot.y - spread * 0.62,
                width: spread * 0.8, height: spread * 0.28
            )),
            with: .color(GamePalette.picket.opacity(colors.isNight ? 0.45 : 0.85))
        )
        context.stroke(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.22, y: foot.y - spread * 0.55,
                width: spread * 0.44, height: spread * 0.14
            )),
            with: .color(GamePalette.post.opacity(0.35)),
            lineWidth: max(1, spread * 0.05)
        )
    }

    /// Where the landmark at the foot of the trail stands: the barn in a meadow, a hollow
    /// stump in the thicket — down in the grass below the first signpost, on whichever side
    /// of the world the trail does not start on.
    private var landmarkStand: CGPoint {
        CGPoint(
            x: trail.point(of: 0).x < size.width / 2 ? size.width - 74 : 74,
            y: size.height - WorldTrail.apron * 0.42
        )
    }

    private func drawBarn(in context: inout GraphicsContext) {
        let centre = landmarkStand
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

    /// A hollow stump at the foot of the thicket trail — the woods' answer to the barn the
    /// pig came out of in the meadow.
    private func drawHollow(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 64
        let tall: CGFloat = 58

        shadow(in: &context, at: CGPoint(x: centre.x, y: centre.y + tall * 0.35), width: wide)

        let bole = CGRect(
            x: centre.x - wide * 0.38, y: centre.y - tall * 0.15,
            width: wide * 0.76, height: tall * 0.7
        )
        context.fill(
            Path(roundedRect: bole, cornerRadius: wide * 0.12),
            with: .color(GamePalette.rail)
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.42, y: centre.y - tall * 0.28,
                width: wide * 0.84, height: tall * 0.28
            )),
            with: .color(GamePalette.picket.opacity(colors.isNight ? 0.5 : 0.9))
        )

        // The hollow itself, dark and mossy.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.18, y: centre.y + tall * 0.02,
                width: wide * 0.36, height: tall * 0.42
            )),
            with: .color(GamePalette.post.opacity(0.9))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.12, y: centre.y + tall * 0.08,
                width: wide * 0.24, height: tall * 0.28
            )),
            with: .color(colors.canopyShade.opacity(0.85))
        )

        // A cushion of moss on the rim.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.28, y: centre.y - tall * 0.22,
                width: wide * 0.34, height: tall * 0.14
            )),
            with: .color(colors.canopy.opacity(0.9))
        )
    }

    /// A cairn at the foot of the mountain trail, with a lantern burning in it — the peak's
    /// answer to the barn the pig came out of and the stump it went past in the woods.
    /// Somebody has been up here before, and this is what they left.
    private func drawCairn(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 58
        let tall: CGFloat = 56

        shadow(in: &context, at: CGPoint(x: centre.x, y: centre.y + tall * 0.34), width: wide)

        // Stones stacked smallest at the top, each one a little off the one below it.
        let courses: [(lift: Double, width: Double, drift: Double)] = [
            (0.30, 0.86, 0.00),
            (0.06, 0.70, 0.06),
            (-0.16, 0.54, -0.05),
            (-0.34, 0.36, 0.03)
        ]
        for course in courses {
            let stone = CGRect(
                x: centre.x + wide * CGFloat(course.drift) - wide * CGFloat(course.width) / 2,
                y: centre.y + tall * CGFloat(course.lift) - tall * 0.2,
                width: wide * CGFloat(course.width),
                height: tall * 0.22
            )
            context.fill(
                Path(roundedRect: stone, cornerRadius: tall * 0.09),
                with: .color(GamePalette.stone.opacity(colors.isNight ? 0.55 : 0.9))
            )
            context.fill(
                Path(roundedRect: CGRect(
                    x: stone.minX + stone.width * 0.1, y: stone.minY + stone.height * 0.14,
                    width: stone.width * 0.44, height: stone.height * 0.3
                ), cornerRadius: tall * 0.05),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.08 : 0.24))
            )
        }

        // The lantern somebody wedged into the top of it, and the light it throws.
        let lamp = CGPoint(x: centre.x + wide * 0.03, y: centre.y - tall * 0.44)
        context.fill(
            circle(at: lamp, radius: tall * 0.26),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 1.00, green: 0.66, blue: 0.30).opacity(colors.isNight ? 0.5 : 0.28),
                    Color(red: 1.00, green: 0.66, blue: 0.30).opacity(0)
                ]),
                center: lamp,
                startRadius: 0,
                endRadius: tall * 0.26
            )
        )
        context.fill(
            circle(at: lamp, radius: tall * 0.08),
            with: .color(Color(red: 0.98, green: 0.78, blue: 0.36))
        )
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
