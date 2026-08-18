import Foundation
import SwiftUI

/// The meadow the trail runs through: fields, trees, hay and a barn at the bottom
/// where the pig set out from. Every other world keeps the same trail and draws it the same
/// way, on its own ground — denser trees, leaf litter, ferns and a hollow stump in a
/// thicket; ash, loose rock, scorched pines and a cairn on a mountain; paving, lamp posts,
/// crates and a clocktower in a city; dust, craters, splinters of star-stone and the first
/// crater of all out in the reaches; sinter terraces, flowstone columns, crystals and the
/// mouth the pig came in by, down in the caverns; trodden sawdust, booths, lantern poles and
/// the big top itself at the carnival.
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
        case .cobbles: drawClocktower(in: &context)
        case .dust: drawFirstCrater(in: &context)
        case .flowstone: drawCaveMouth(in: &context)
        case .sawdust: drawBigTop(in: &context)
        case .sand: drawRockArch(in: &context)
        case .shingle: drawWreck(in: &context)
        case .snowfield: drawIgloo(in: &context)
        case .marsh: drawStiltHut(in: &context)
        }
    }

    // MARK: - The lie of the land

    private func drawFields(in context: inout GraphicsContext) {
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(colors.ground))

        switch colors.cover {
        case .pasture: drawMowing(in: &context)
        case .woodland: drawLeafLitter(in: &context)
        case .scree: drawAshDrifts(in: &context)
        case .cobbles: drawPaving(in: &context)
        case .dust: drawPits(in: &context)
        case .flowstone: drawSinterTerraces(in: &context)
        case .sawdust: drawTroddenGround(in: &context)
        case .sand: drawRippledSand(in: &context)
        case .shingle: drawTideLines(in: &context)
        case .snowfield: drawSnowdrifts(in: &context)
        case .marsh: drawFenPools(in: &context)
        }
    }

    /// The floor of a fairground: grass that a week of people have walked into mud, with
    /// sawdust thrown down over the worst of it and rings of it trodden out where a crowd has
    /// stood round something. Where the meadow's bands were mown and the city's courses were
    /// laid, nobody laid these out at all — they are the marks of the people who were here.
    private func drawTroddenGround(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 6_101)

        for _ in 0..<7 {
            let down = horizon + CGFloat(scatter.next()) * (size.height - horizon)
            var walkway = Path()
            walkway.move(to: CGPoint(x: -20, y: down))
            walkway.addCurve(
                to: CGPoint(x: size.width + 20, y: down + CGFloat(scatter.next(in: -70...70))),
                control1: CGPoint(x: size.width * 0.32, y: down + CGFloat(scatter.next(in: -50...50))),
                control2: CGPoint(x: size.width * 0.68, y: down + CGFloat(scatter.next(in: -50...50)))
            )
            context.stroke(
                walkway,
                with: .color(.black.opacity(colors.isNight ? 0.16 : 0.10)),
                style: StrokeStyle(lineWidth: CGFloat(scatter.next(in: 18...42)), lineCap: .round)
            )
        }

        // Rings worn in the grass where a crowd has stood round an attraction, which is the
        // shape the whole world is about.
        for _ in 0..<9 {
            let centre = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 46...118))
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.19,
                    width: spread, height: spread * 0.38
                )),
                with: .color(
                    Color(red: 0.86, green: 0.74, blue: 0.52)
                        .opacity(colors.isNight ? 0.12 : 0.26)
                ),
                lineWidth: CGFloat(scatter.next(in: 5...12))
            )
        }
    }

    /// The floor of a cave: terraces of sinter, poured rather than laid, each with a lip that
    /// catches the light and a step under it that does not. Where the meadow's bands are mown
    /// and the city's courses are laid, these are what a few thousand years of water running
    /// over the same rock leaves behind — so they wander, and they are never the same depth
    /// twice, and there is standing water lying in the dips between them.
    private func drawSinterTerraces(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 5_231)
        var top = horizon
        while top < size.height {
            let depth = CGFloat(scatter.next(in: 58...124))
            let terrace = band(from: top, to: top + depth, wobble: scatter.next())
            context.fill(terrace, with: .color(.black.opacity(scatter.next(in: 0.06...0.16))))
            context.stroke(
                terrace,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.14)),
                lineWidth: 2
            )
            top += depth
        }

        for _ in 0..<14 {
            let centre = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 40...104))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.12,
                    width: spread, height: spread * 0.24
                )),
                with: .color(GamePalette.water.opacity(colors.isNight ? 0.24 : 0.34))
            )
        }
    }

    /// Pits in the dust where things have come down, ringed pale with what they threw up. It
    /// is the only ground on any trail with no pattern laid over it at all — no bands, no
    /// courses, no drifts — because out here nothing has ever been farmed, burnt or built.
    private func drawPits(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 2_129)
        for _ in 0..<26 {
            let centre = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 34...96))
            let pit = CGRect(
                x: centre.x - spread * 0.5, y: centre.y - spread * 0.2,
                width: spread, height: spread * 0.4
            )
            context.fill(
                Path(ellipseIn: pit),
                with: .color(.black.opacity(colors.isNight ? 0.24 : 0.13))
            )
            context.stroke(
                Path(ellipseIn: pit.insetBy(dx: -4, dy: -2)),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.06 : 0.16)),
                lineWidth: 2
            )
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

    /// Courses of setts running the width of the world, every other course offset by half a
    /// stone, so the city's trail runs over paving rather than through a grey field.
    private func drawPaving(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_831)
        let course: CGFloat = 26
        let sett: CGFloat = 62
        var top = horizon
        var offset = false
        while top < size.height {
            var across: CGFloat = offset ? -sett / 2 : 0
            while across < size.width {
                let stone = CGRect(
                    x: across + 2, y: top + 2,
                    width: sett - 4, height: course - 4
                )
                context.fill(
                    Path(roundedRect: stone, cornerRadius: 5),
                    with: .color(
                        scatter.next() < 0.5
                            ? Color.white.opacity(colors.isNight ? 0.015 : 0.05)
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
        // is up there is thin and hangs low, and a city sky is whatever its chimneys have
        // put into it.
        // Out in the reaches the sky is thin enough that the stars are up in it whatever the
        // hour, which is the one thing this world's sky has that no other world's does.
        if colors.cover == .dust {
            drawStars(in: &context)
        }

        var scatter = Scatter(seed: 311)
        let clouds: Int = switch colors.cover {
        case .pasture: 3
        case .woodland: 1
        case .scree: 2
        case .cobbles: 3
        case .dust: 1
        // Nothing is up there but rock, so there is nothing for a cloud to be.
        case .flowstone: 0
        case .sawdust: 2
        // One cloud, a long way off, doing nobody any good.
        case .sand: 1
        case .shingle: 2
        // Snow weather: the sky is one low sheet rather than clouds a player could count.
        case .snowfield: 2
        // Fen sky: half of it is the water's own breath, hanging low.
        case .marsh: 3
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

    /// The stars over the reaches, with one of them on its way down. They are what the world
    /// is named for, so they are in the sky by day as well as after dark — thinner by day,
    /// the way a star is when there is still some light to compete with.
    private func drawStars(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 3_581)
        for _ in 0..<46 {
            let spot = CGPoint(
                x: CGFloat(scatter.next()) * size.width,
                y: CGFloat(scatter.next(in: 0.04...0.92)) * horizon
            )
            let radius = CGFloat(scatter.next(in: 0.8...2.2))
            context.fill(
                circle(at: spot, radius: radius),
                with: .color(
                    GamePalette.cream.opacity(
                        (colors.isNight ? 0.9 : 0.45) * scatter.next(in: 0.4...1.0)
                    )
                )
            )
        }

        // One coming in, drawn as the streak it leaves rather than as the star itself.
        let entry = CGPoint(x: size.width * 0.22, y: horizon * 0.24)
        var streak = Path()
        streak.move(to: entry)
        streak.addLine(to: CGPoint(x: entry.x + size.width * 0.13, y: entry.y + horizon * 0.34))
        context.stroke(
            streak,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0),
                    GamePalette.cream.opacity(colors.isNight ? 0.75 : 0.5)
                ]),
                startPoint: entry,
                endPoint: CGPoint(x: entry.x + size.width * 0.13, y: entry.y + horizon * 0.34)
            ),
            style: StrokeStyle(lineWidth: 2.4, lineCap: .round)
        )
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
        } else if colors.cover == .cobbles {
            drawSkyline(in: &context)
        } else if colors.cover == .dust {
            drawFarRim(in: &context)
        } else if colors.cover == .flowstone {
            drawCaveRoof(in: &context)
        } else if colors.cover == .sawdust {
            drawFairSkyline(in: &context)
        } else if colors.cover == .sand {
            drawDuneHorizon(in: &context)
        } else if colors.cover == .shingle {
            drawSeaHorizon(in: &context)
        } else if colors.cover == .snowfield {
            drawBergLine(in: &context)
        } else if colors.cover == .marsh {
            drawFenTreeline(in: &context)
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
    /// thinner over a canopy or a peak, and everything faint after dark. There is next to no
    /// air over the reaches, so what little is up there barely shows at all.
    private var cloudOpacity: Double {
        if colors.cover == .dust { return colors.isNight ? 0.16 : 0.24 }
        if colors.isNight { return 0.55 }
        return colors.cover == .pasture ? 0.9 : 0.55
    }

    /// The far rim along the horizon of the reaches: the raised lip of the craters out past
    /// the trail, low and broken. Where a thicket closes the sky with a canopy and a city with
    /// rooftops, this world closes it with the ground it has been battered into — which leaves
    /// the sky wide open above it, and the sky is what is worth looking at here.
    private func drawFarRim(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 4_507)
        let base = horizon + 26
        var rim = Path()
        rim.move(to: CGPoint(x: -10, y: base))
        var across: CGFloat = -10
        while across < size.width + 20 {
            let step = CGFloat(scatter.next(in: 34...78))
            let lift = CGFloat(scatter.next(in: 5...22))
            rim.addQuadCurve(
                to: CGPoint(x: across + step, y: base - CGFloat(scatter.next(in: 0...8))),
                control: CGPoint(x: across + step * 0.5, y: base - lift)
            )
            across += step
        }
        rim.addLine(to: CGPoint(x: across, y: base + 12))
        rim.addLine(to: CGPoint(x: -10, y: base + 12))
        rim.closeSubpath()
        context.fill(rim, with: .color(colors.canopyShade))
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

    /// A run of rooftops along the horizon, so the city closes the sky the way the thicket's
    /// canopy does — with chimneys on some of them, since the smoke over this world has to
    /// be coming from somewhere.
    private func drawSkyline(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 1_223)
        let base = horizon + 24
        var across: CGFloat = -12
        while across < size.width + 12 {
            let wide = CGFloat(scatter.next(in: 30...58))
            let tall = CGFloat(scatter.next(in: 26...64))
            let roof = CGRect(x: across, y: base - tall, width: wide, height: tall + 6)
            context.fill(Path(roof), with: .color(colors.canopyShade))

            // A chimney on about half of them, and a lit window on about half of those.
            if scatter.next() < 0.5 {
                let stack = CGRect(
                    x: roof.minX + wide * CGFloat(scatter.next(in: 0.2...0.7)),
                    y: roof.minY - 12,
                    width: 7,
                    height: 13
                )
                context.fill(Path(stack), with: .color(colors.canopyShade))
            }
            if colors.isNight, scatter.next() < 0.55 {
                context.fill(
                    Path(CGRect(
                        x: roof.minX + wide * 0.3, y: roof.minY + tall * 0.3,
                        width: 6, height: 7
                    )),
                    with: .color(Color(red: 1.00, green: 0.78, blue: 0.40).opacity(0.5))
                )
            }
            across += wide + CGFloat(scatter.next(in: 0...5))
        }
    }

    /// The floor of a desert: hardpan with the wind's combing over it, all of it leaning one way.
    ///
    /// Every ground below this was laid out by somebody or grown by something — mown bands, courses
    /// of paving, walkways trodden by a crowd. Nobody laid this out and nothing grew it. It is the
    /// record of one wind blowing across it for a long time, which is why every line on it is
    /// parallel to every other line on it, and why the world reads as empty without being blank.
    private func drawRippledSand(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 8_527)

        // Pans of bare hardpan where the sand has been scoured off altogether.
        for _ in 0..<8 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: -0.1...1.1)) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 120...300))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.1,
                    width: spread, height: spread * 0.2
                )),
                with: .color(colors.foreground.opacity(colors.isNight ? 0.4 : 0.5))
            )
        }

        // The combing itself, each crest drawn with its own shadow tucked under it.
        for _ in 0..<30 {
            let down = horizon + CGFloat(scatter.next(in: -0.02...1.02)) * (size.height - horizon)
            var crest = Path()
            crest.move(to: CGPoint(x: -20, y: down))
            crest.addCurve(
                to: CGPoint(x: size.width + 20, y: down + CGFloat(scatter.next(in: -40...40))),
                control1: CGPoint(x: size.width * 0.3, y: down + CGFloat(scatter.next(in: -22...22))),
                control2: CGPoint(x: size.width * 0.7, y: down + CGFloat(scatter.next(in: -22...22)))
            )
            let width = CGFloat(scatter.next(in: 1.6...4.2))
            context.translateBy(x: 0, y: width)
            context.stroke(
                crest,
                with: .color(shade.opacity(colors.isNight ? 0.22 : 0.17)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
            context.translateBy(x: 0, y: -width)
            context.stroke(
                crest,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.06 : 0.3)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
        }
    }

    /// The dunes out along the horizon: a rank of crests going away one behind another, each one
    /// lit on the windward side and shaded on the lee.
    ///
    /// The city closes its sky with rooftops and the caverns close theirs with rock. This closes
    /// its sky with more of the same thing the trail is standing on, going back until it runs out
    /// — which is the one honest thing a desert horizon can be, and what the world's own blurb
    /// promises: sand to the horizon.
    private func drawDuneHorizon(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 9_209)
        let base = horizon + 26

        // Three ranks, the furthest palest, so the sand reads as going a long way back.
        for rank in 0..<3 {
            let depth = CGFloat(rank)
            let lift = 46 - depth * 13
            let fade = 1.0 - Double(rank) * 0.26
            var ridge = Path()
            ridge.move(to: CGPoint(x: -20, y: base - depth * 4))
            var across: CGFloat = -20
            var crest = true
            while across < size.width + 60 {
                let span = CGFloat(scatter.next(in: 90...190))
                let top = base - depth * 4 - lift * CGFloat(scatter.next(in: 0.5...1.0))
                // A dune is not a hill: it rises long and gently to a crest and then drops away
                // short and steep, so each hump is drawn asymmetric on purpose.
                if crest {
                    ridge.addQuadCurve(
                        to: CGPoint(x: across + span * 0.78, y: top),
                        control: CGPoint(x: across + span * 0.5, y: top + lift * 0.24)
                    )
                    ridge.addQuadCurve(
                        to: CGPoint(x: across + span, y: base - depth * 4),
                        control: CGPoint(x: across + span * 0.9, y: top + lift * 0.1)
                    )
                } else {
                    ridge.addLine(to: CGPoint(x: across + span, y: base - depth * 4))
                }
                crest = !crest
                across += span
            }
            ridge.addLine(to: CGPoint(x: size.width + 60, y: base + 40))
            ridge.addLine(to: CGPoint(x: -20, y: base + 40))
            ridge.closeSubpath()

            context.fill(
                ridge,
                with: .color(
                    rank == 0
                        ? colors.ground.opacity(0.95)
                        : colors.farHill.opacity(0.55 + fade * 0.3)
                )
            )
        }
    }

    /// The rest of the fair, out along the horizon: tent tops, a big wheel turned side on, and
    /// a string of bunting slung over the lot. Where the city closes the sky with rooftops and
    /// the caverns close it with rock, this closes it with more of itself — so a player looking
    /// up from the trail sees that the nine fields they are walking are one corner of something
    /// much larger, which is what a fairground is.
    private func drawFairSkyline(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 7_331)
        let base = horizon + 24

        // The big wheel, stood off to one side so the tents can run under it.
        let hub = CGPoint(x: size.width * 0.72, y: base - 54)
        let spokes = 12
        context.stroke(
            circle(at: hub, radius: 46),
            with: .color(colors.canopyShade),
            lineWidth: 3
        )
        var frame = Path()
        for spoke in 0..<spokes {
            let angle = Double(spoke) / Double(spokes) * 2 * .pi
            frame.move(to: hub)
            frame.addLine(to: CGPoint(x: hub.x + 46 * cos(angle), y: hub.y + 46 * sin(angle)))
        }
        context.stroke(frame, with: .color(colors.canopyShade.opacity(0.7)), lineWidth: 1.6)
        var legs = Path()
        legs.move(to: CGPoint(x: hub.x - 26, y: base + 6))
        legs.addLine(to: hub)
        legs.addLine(to: CGPoint(x: hub.x + 26, y: base + 6))
        context.stroke(legs, with: .color(colors.canopyShade), lineWidth: 4)
        if colors.isNight {
            for spoke in 0..<spokes {
                let angle = Double(spoke) / Double(spokes) * 2 * .pi
                context.fill(
                    circle(
                        at: CGPoint(x: hub.x + 46 * cos(angle), y: hub.y + 46 * sin(angle)),
                        radius: 2.6
                    ),
                    with: .color(Color(red: 1.00, green: 0.82, blue: 0.44).opacity(0.75))
                )
            }
        }

        // Tent tops running the width of the world, none of them the same height.
        var across: CGFloat = -14
        while across < size.width + 14 {
            let wide = CGFloat(scatter.next(in: 34...66))
            let tall = CGFloat(scatter.next(in: 24...52))
            var tent = Path()
            tent.move(to: CGPoint(x: across, y: base + 6))
            tent.addQuadCurve(
                to: CGPoint(x: across + wide / 2, y: base - tall),
                control: CGPoint(x: across + wide * 0.28, y: base - tall * 0.55)
            )
            tent.addQuadCurve(
                to: CGPoint(x: across + wide, y: base + 6),
                control: CGPoint(x: across + wide * 0.72, y: base - tall * 0.55)
            )
            tent.closeSubpath()
            context.fill(tent, with: .color(colors.canopyShade))

            // A pennant on the pole of about half of them.
            if scatter.next() < 0.5 {
                var flag = Path()
                let peak = CGPoint(x: across + wide / 2, y: base - tall)
                flag.move(to: CGPoint(x: peak.x, y: peak.y - 12))
                flag.addLine(to: CGPoint(x: peak.x + 11, y: peak.y - 8))
                flag.addLine(to: CGPoint(x: peak.x, y: peak.y - 4))
                flag.closeSubpath()
                context.fill(flag, with: .color(colors.canopy.opacity(0.9)))
                context.stroke(
                    Path { line in
                        line.move(to: peak)
                        line.addLine(to: CGPoint(x: peak.x, y: peak.y - 12))
                    },
                    with: .color(colors.canopyShade),
                    lineWidth: 1.6
                )
            }
            across += wide * 0.88
        }

        // And the bunting, which is the one thing on this horizon that is neither ground nor
        // building: a line of flags slung from one side of the world to the other.
        var string = Path()
        string.move(to: CGPoint(x: -10, y: base - 62))
        string.addQuadCurve(
            to: CGPoint(x: size.width + 10, y: base - 68),
            control: CGPoint(x: size.width / 2, y: base - 34)
        )
        context.stroke(string, with: .color(colors.canopyShade.opacity(0.8)), lineWidth: 1.8)
        let flags: [Color] = [
            Color(red: 1.00, green: 0.78, blue: 0.36),
            Color(red: 0.98, green: 0.40, blue: 0.48),
            Color(red: 0.46, green: 0.72, blue: 0.96),
            Color(red: 0.62, green: 0.92, blue: 0.66)
        ]
        for index in 0..<18 {
            let along = CGFloat(index) / 17
            let hang = CGPoint(
                x: -10 + (size.width + 20) * along,
                // The same quadratic the string is drawn with, so the flags hang off it.
                y: (1 - along) * (1 - along) * (base - 62)
                    + 2 * (1 - along) * along * (base - 34)
                    + along * along * (base - 68)
            )
            var flag = Path()
            flag.move(to: CGPoint(x: hang.x - 5, y: hang.y))
            flag.addLine(to: CGPoint(x: hang.x + 5, y: hang.y))
            flag.addLine(to: CGPoint(x: hang.x, y: hang.y + 11))
            flag.closeSubpath()
            context.fill(
                flag,
                with: .color(flags[index % flags.count].opacity(colors.isNight ? 0.62 : 0.85))
            )
        }
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
        case lamp
        case crate
        case crater
        case shard
        case column
        case crystal
        case stall
        case lanternPost
        case cactus
        case sandMound
        case bones
        case strandPool
        case shell
        case driftwood
        case iceBlade
        case bergyBit
        case snowDrift
        case reedBed
        case deadTree
        case fenPool
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
        case .cobbles:
            // Paved ground: lamp posts and crates left out on it, loose setts, and the odd
            // street tree somebody planted and nobody has looked at since.
            switch roll {
            case ..<0.36: .lamp
            case ..<0.62: .crate
            case ..<0.86: .rock
            default: .tree
            }
        case .dust:
            // Nothing grows out here and nobody has built anything: what the ground has on it
            // is the pits things have made in it and the pieces they broke into.
            switch roll {
            case ..<0.44: .crater
            case ..<0.76: .rock
            default: .shard
            }
        case .flowstone:
            // Nothing grows down here and nobody has built anything either: what stands on the
            // floor is what the roof has been dripping onto it, and what light there is comes
            // out of the rock rather than down onto it.
            switch roll {
            case ..<0.42: .column
            case ..<0.72: .rock
            default: .crystal
            }
        case .sawdust:
            // A field somebody has put a fair on for the week: booths and lantern poles
            // wherever there was room for them, straw thrown down between, and the grass and
            // the odd stone still there underneath the whole arrangement.
            switch roll {
            case ..<0.34: .stall
            case ..<0.62: .lanternPost
            case ..<0.82: .hayBale
            default: .flowers
            }
        case .sand:
            // Nothing has been built out here and next to nothing grows: what stands on the sand
            // is a cactus that found water, a mound the wind has piled up and not yet taken away
            // again, a rock scoured bare, and the bones of something that did not make it across.
            switch roll {
            case ..<0.30: .cactus
            case ..<0.62: .sandMound
            case ..<0.86: .rock
            default: .bones
            }
        case .shingle:
            // Nothing was built on the strand and nothing grows there: what stands on it is
            // what the last tide set down — a rock pool, which is the shape every board out
            // here is made of, a shell washed up whole, a weeded rock, and a length of
            // driftwood the sea has finished with.
            switch roll {
            case ..<0.34: .strandPool
            case ..<0.60: .shell
            case ..<0.84: .rock
            default: .driftwood
            }
        case .snowfield:
            // Nothing was built on the ice and nothing grows through it: what stands on it is
            // what the pressure and the weather have made — a blade of ridge ice, which is the
            // wall every board out here is built with, a drift the wind has piled and not yet
            // taken back, a bergy bit stranded where it calved, and the odd scoured rock.
            switch roll {
            case ..<0.32: .iceBlade
            case ..<0.60: .snowDrift
            case ..<0.86: .bergyBit
            default: .rock
            }
        case .marsh:
            // Nothing was built on the fen either — nothing anybody built has stayed up — and
            // what stands on it is what the water grows and what it kills: reed beds, a pool
            // ringed with rushes, a dead snag the bog got the roots of, and grass on whatever
            // passes for high ground.
            switch roll {
            case ..<0.36: .reedBed
            case ..<0.60: .fenPool
            case ..<0.80: .deadTree
            default: .bush
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
        case .lamp: drawLamp(in: &context, at: place.at, scale: place.size)
        case .crate: drawCrate(in: &context, at: place.at, scale: place.size)
        case .crater: drawCrater(in: &context, at: place.at, scale: place.size)
        case .shard: drawShard(in: &context, at: place.at, scale: place.size)
        case .column: drawColumn(in: &context, at: place.at, scale: place.size)
        case .crystal: drawCrystalCluster(in: &context, at: place.at, scale: place.size)
        case .stall: drawStall(in: &context, at: place.at, scale: place.size)
        case .lanternPost: drawLanternPost(in: &context, at: place.at, scale: place.size)
        case .cactus: drawCactus(in: &context, at: place.at, scale: place.size)
        case .sandMound: drawSandMound(in: &context, at: place.at, scale: place.size)
        case .bones: drawBones(in: &context, at: place.at, scale: place.size)
        case .strandPool: drawStrandPool(in: &context, at: place.at, scale: place.size)
        case .shell: drawShell(in: &context, at: place.at, scale: place.size)
        case .driftwood: drawDriftwood(in: &context, at: place.at, scale: place.size)
        case .iceBlade: drawIceBlade(in: &context, at: place.at, scale: place.size)
        case .bergyBit: drawBergyBit(in: &context, at: place.at, scale: place.size)
        case .snowDrift: drawSnowDrift(in: &context, at: place.at, scale: place.size)
        case .reedBed: drawReedBed(in: &context, at: place.at, scale: place.size)
        case .deadTree: drawDeadTree(in: &context, at: place.at, scale: place.size)
        case .fenPool: drawFenPool(in: &context, at: place.at, scale: place.size)
        }
    }

    /// A cactus standing on the sand with its shadow pulled out long beside it. It is what the
    /// dunes have where the meadow has a tree — and it is the world's hazard seen doing what a
    /// hazard does, since a cactus is the one thing on these boards no post will go through.
    private func drawCactus(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = 42 * scale
        let wide = tall * 0.24

        var shadow = Path()
        shadow.move(to: CGPoint(x: foot.x - wide * 0.4, y: foot.y))
        shadow.addLine(to: CGPoint(x: foot.x + tall * 1.0, y: foot.y + tall * 0.18))
        shadow.addLine(to: CGPoint(x: foot.x + tall * 1.0, y: foot.y + tall * 0.27))
        shadow.addLine(to: CGPoint(x: foot.x + wide * 0.4, y: foot.y + tall * 0.11))
        shadow.closeSubpath()
        context.fill(shadow, with: .color(shade.opacity(colors.isNight ? 0.24 : 0.32)))

        var body = Path()
        body.addRoundedRect(
            in: CGRect(x: foot.x - wide * 0.5, y: foot.y - tall, width: wide, height: tall),
            cornerSize: CGSize(width: wide * 0.5, height: wide * 0.5)
        )
        for (side, height, reach) in [(-1.0, 0.60, 0.32), (1.0, 0.44, 0.28)] {
            let elbow = CGPoint(x: foot.x + wide * 0.5 * side, y: foot.y - tall * height)
            let thick = wide * 0.74
            let out = tall * reach
            let tip = CGPoint(x: elbow.x + out * side, y: elbow.y - tall * (height * 0.42 + 0.1))
            // The run out of the trunk, tucked back into it so the two read as one plant.
            body.addRoundedRect(
                in: CGRect(
                    x: min(elbow.x, tip.x) - (side > 0 ? thick * 0.5 : 0),
                    y: elbow.y - thick * 0.5,
                    width: out + thick * 0.5,
                    height: thick
                ),
                cornerSize: CGSize(width: thick * 0.5, height: thick * 0.5)
            )
            // And the elbow turning up, which is the shape that says cactus and not shrub.
            body.addRoundedRect(
                in: CGRect(
                    x: tip.x - thick * 0.5,
                    y: tip.y,
                    width: thick,
                    height: elbow.y - tip.y + thick * 0.5
                ),
                cornerSize: CGSize(width: thick * 0.5, height: thick * 0.5)
            )
        }
        context.fill(body, with: .color(colors.canopy))
        context.stroke(body, with: .color(colors.canopyShade), lineWidth: max(1, wide * 0.12))

        // Ribs down the trunk, which is what tells a cactus from a green post.
        var ribs = Path()
        for offset in [-0.22, 0.0, 0.22] {
            ribs.move(to: CGPoint(x: foot.x + wide * CGFloat(offset), y: foot.y - tall * 0.9))
            ribs.addLine(to: CGPoint(x: foot.x + wide * CGFloat(offset), y: foot.y - tall * 0.08))
        }
        context.stroke(ribs, with: .color(colors.canopyShade.opacity(0.55)), lineWidth: 1)
    }

    /// A mound of loose sand the wind has piled up and not yet taken away again: a lit face
    /// upwind, a sharp crest, and the steep shaded slipface behind it.
    ///
    /// Which is the same shape the world's *water* is, at a size a player can stand next to. So
    /// the map is dressed with little versions of the thing every board is built out of, and the
    /// first time a crescent turns up on a field it is already a familiar shape.
    private func drawSandMound(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 52 * scale
        let tall = wide * 0.34

        var lit = Path()
        lit.move(to: CGPoint(x: foot.x - wide * 0.5, y: foot.y))
        lit.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.16, y: foot.y - tall),
            control: CGPoint(x: foot.x - wide * 0.18, y: foot.y - tall * 0.9)
        )
        lit.addLine(to: CGPoint(x: foot.x + wide * 0.5, y: foot.y))
        lit.closeSubpath()
        context.fill(lit, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.10 : 0.42)))

        var slipface = Path()
        slipface.move(to: CGPoint(x: foot.x + wide * 0.16, y: foot.y - tall))
        slipface.addLine(to: CGPoint(x: foot.x + wide * 0.5, y: foot.y))
        slipface.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.2, y: foot.y + tall * 0.16),
            control: CGPoint(x: foot.x + wide * 0.38, y: foot.y + tall * 0.14)
        )
        slipface.closeSubpath()
        context.fill(slipface, with: .color(shade.opacity(colors.isNight ? 0.34 : 0.28)))
    }

    /// The bones of something that did not get across: a ribcage half buried, and a skull beside
    /// it. Drawn small and pale, because the joke is only funny at a distance.
    private func drawBones(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 26 * scale
        let bone = GamePalette.cream.opacity(colors.isNight ? 0.42 : 0.86)

        var ribs = Path()
        for index in 0..<4 {
            let across = foot.x - wide * 0.34 + wide * 0.22 * CGFloat(index)
            ribs.move(to: CGPoint(x: across, y: foot.y))
            ribs.addQuadCurve(
                to: CGPoint(x: across + wide * 0.05, y: foot.y - wide * 0.3),
                control: CGPoint(x: across - wide * 0.12, y: foot.y - wide * 0.2)
            )
        }
        context.stroke(ribs, with: .color(bone), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x + wide * 0.34, y: foot.y - wide * 0.24,
                width: wide * 0.3, height: wide * 0.24
            )),
            with: .color(bone)
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - wide * 0.5, y: foot.y - wide * 0.02,
                width: wide, height: wide * 0.12
            )),
            with: .color(shade.opacity(colors.isNight ? 0.2 : 0.24))
        )
    }

    /// The blue the desert fills a shadow with. There is one small hot sun over this world and
    /// nothing else to light the shade with except the sky, so every shadow on the sand is a cold
    /// colour — which is the whole reason the map reads as glare rather than as a yellow meadow.
    private var shade: Color {
        Color(red: 0.30, green: 0.34, blue: 0.54)
    }

    /// A sideshow booth with a striped awning over it, guyed down at the corners. It is what
    /// the carnival has where the meadow has a tree — and the ropes going down off the awning
    /// are the hazard the world's boards are strewn with, seen doing the job they are for.
    private func drawStall(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 34 * scale
        let tall = 26 * scale
        shadow(in: &context, at: foot, width: wide * 0.9)

        let counter = CGRect(
            x: foot.x - wide * 0.42, y: foot.y - tall * 0.5,
            width: wide * 0.84, height: tall * 0.5
        )
        context.fill(
            Path(roundedRect: counter, cornerRadius: 2),
            with: .color(GamePalette.rail)
        )

        // The awning, in the two colours every awning at every fair has ever been.
        let stripes = 5
        for stripe in 0..<stripes {
            let left = counter.minX - wide * 0.08
                + (counter.width + wide * 0.16) * CGFloat(stripe) / CGFloat(stripes)
            var panel = Path()
            panel.move(to: CGPoint(x: left, y: counter.minY))
            panel.addLine(to: CGPoint(
                x: left + (counter.width + wide * 0.16) / CGFloat(stripes),
                y: counter.minY
            ))
            panel.addLine(to: CGPoint(x: foot.x, y: counter.minY - tall * 0.62))
            panel.closeSubpath()
            context.fill(
                panel,
                with: .color(stripe % 2 == 0 ? colors.canopy : GamePalette.cream.opacity(0.85))
            )
        }

        var guys = Path()
        guys.move(to: CGPoint(x: foot.x, y: counter.minY - tall * 0.62))
        guys.addLine(to: CGPoint(x: counter.minX - wide * 0.22, y: foot.y))
        guys.move(to: CGPoint(x: foot.x, y: counter.minY - tall * 0.62))
        guys.addLine(to: CGPoint(x: counter.maxX + wide * 0.22, y: foot.y))
        context.stroke(
            guys,
            with: .color(
                Color(red: 0.80, green: 0.70, blue: 0.52).opacity(colors.isNight ? 0.45 : 0.7)
            ),
            lineWidth: 1.4
        )
    }

    /// A pole with a lantern hung off the top of it, throwing a pool of light on the ground.
    /// The city has lamp posts doing the same job; the difference is that a lamp post is put
    /// up for the year and this went in on Tuesday and comes out on Sunday.
    private func drawLanternPost(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = 44 * scale
        shadow(in: &context, at: foot, width: 14 * scale)

        let head = CGPoint(x: foot.x, y: foot.y - tall)
        context.stroke(
            Path { pole in
                pole.move(to: foot)
                pole.addLine(to: head)
            },
            with: .color(GamePalette.rail),
            lineWidth: 3
        )

        let glow = Color(red: 1.00, green: 0.80, blue: 0.44)
        context.fill(
            circle(at: CGPoint(x: head.x, y: head.y + 6), radius: 22 * scale),
            with: .radialGradient(
                Gradient(colors: [
                    glow.opacity(colors.isNight ? 0.34 : 0.16),
                    glow.opacity(0)
                ]),
                center: CGPoint(x: head.x, y: head.y + 6),
                startRadius: 0,
                endRadius: 22 * scale
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: head.x - 6 * scale, y: head.y, width: 12 * scale, height: 15 * scale
            )),
            with: .color(Color(red: 0.98, green: 0.52, blue: 0.42).opacity(colors.isNight ? 0.95 : 0.8))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: head.x - 2.6 * scale, y: head.y + 3 * scale,
                width: 5.2 * scale, height: 9 * scale
            )),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.8 : 0.5))
        )
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

        // A stump in the woods is sawn timber; a stump on the mountain is what the fire left,
        // so the bole goes to charcoal and the cut face keeps a little heat rather than
        // showing pale, fresh rings.
        let burnt = colors.cover == .scree
        let bole = CGRect(
            x: foot.x - spread * 0.38, y: foot.y - spread * 0.55,
            width: spread * 0.76, height: spread * 0.55
        )
        context.fill(
            Path(roundedRect: bole, cornerRadius: spread * 0.12),
            with: .color(
                burnt
                    ? Color(red: 0.16, green: 0.12, blue: 0.11).opacity(colors.isNight ? 0.85 : 0.95)
                    : GamePalette.rail.opacity(colors.isNight ? 0.7 : 0.95)
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.4, y: foot.y - spread * 0.62,
                width: spread * 0.8, height: spread * 0.28
            )),
            with: .color(
                burnt
                    ? Color(red: 0.34, green: 0.20, blue: 0.15).opacity(colors.isNight ? 0.7 : 0.9)
                    : GamePalette.picket.opacity(colors.isNight ? 0.45 : 0.85)
            )
        )
        context.stroke(
            Path(ellipseIn: CGRect(
                x: foot.x - spread * 0.22, y: foot.y - spread * 0.55,
                width: spread * 0.44, height: spread * 0.14
            )),
            with: .color(
                burnt
                    ? Color(red: 0.95, green: 0.42, blue: 0.16).opacity(colors.isNight ? 0.6 : 0.3)
                    : GamePalette.post.opacity(0.35)
            ),
            lineWidth: max(1, spread * 0.05)
        )
    }

    /// A gas lamp on the pavement, lit after dark. It is the city's answer to the meadow's
    /// wildflowers: the thing there is most of, and the only thing along this trail that
    /// gives off any light of its own.
    private func drawLamp(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let height = 34 * scale
        shadow(in: &context, at: foot, width: height * 0.34)

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - height * 0.12, y: foot.y - height * 0.1,
                width: height * 0.24, height: height * 0.12
            )),
            with: .color(GamePalette.post.opacity(colors.isNight ? 0.8 : 0.95))
        )
        context.fill(
            Path(roundedRect: CGRect(
                x: foot.x - height * 0.035, y: foot.y - height * 0.86,
                width: height * 0.07, height: height * 0.8
            ), cornerRadius: height * 0.03),
            with: .color(GamePalette.post.opacity(colors.isNight ? 0.8 : 0.95))
        )

        // The lantern on top: a housing, the flame in it, and a wash of light after dark.
        let lamp = CGPoint(x: foot.x, y: foot.y - height * 0.92)
        if colors.isNight {
            context.fill(
                circle(at: lamp, radius: height * 0.42),
                with: .radialGradient(
                    Gradient(colors: [
                        Color(red: 1.00, green: 0.72, blue: 0.34).opacity(0.34),
                        Color(red: 1.00, green: 0.72, blue: 0.34).opacity(0)
                    ]),
                    center: lamp,
                    startRadius: 0,
                    endRadius: height * 0.42
                )
            )
        }
        context.fill(
            Path(roundedRect: CGRect(
                x: lamp.x - height * 0.1, y: lamp.y - height * 0.11,
                width: height * 0.2, height: height * 0.22
            ), cornerRadius: height * 0.04),
            with: .color(
                colors.isNight
                    ? Color(red: 1.00, green: 0.82, blue: 0.44)
                    : GamePalette.pen.opacity(0.55)
            )
        )
        context.fill(
            Path(CGRect(
                x: lamp.x - height * 0.12, y: lamp.y - height * 0.16,
                width: height * 0.24, height: height * 0.05
            )),
            with: .color(GamePalette.post.opacity(colors.isNight ? 0.8 : 0.95))
        )
    }

    /// A crate left out on the pavement, where the meadow would have left a hay bale and the
    /// thicket a cut stump.
    private func drawCrate(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 17 * scale
        shadow(in: &context, at: foot, width: spread)

        let box = CGRect(
            x: foot.x - spread * 0.5, y: foot.y - spread * 0.72,
            width: spread, height: spread * 0.72
        )
        context.fill(
            Path(roundedRect: box, cornerRadius: spread * 0.08),
            with: .color(GamePalette.rail.opacity(colors.isNight ? 0.65 : 0.95))
        )
        var boards = Path()
        for line in [0.34, 0.68] {
            let down = box.minY + box.height * CGFloat(line)
            boards.move(to: CGPoint(x: box.minX + spread * 0.08, y: down))
            boards.addLine(to: CGPoint(x: box.maxX - spread * 0.08, y: down))
        }
        boards.move(to: CGPoint(x: box.minX, y: box.minY))
        boards.addLine(to: CGPoint(x: box.maxX, y: box.maxY))
        context.stroke(
            boards,
            with: .color(GamePalette.post.opacity(colors.isNight ? 0.5 : 0.4)),
            style: StrokeStyle(lineWidth: max(1, spread * 0.06), lineCap: .round)
        )
        context.fill(
            Path(CGRect(
                x: box.minX, y: box.minY, width: box.width, height: spread * 0.08
            )),
            with: .color(GamePalette.picket.opacity(colors.isNight ? 0.4 : 0.85))
        )
    }

    /// A crater in the dust with a well of water standing in the bottom of it — the same thing
    /// the boards of this world are scattered with, and what the reaches have instead of a
    /// bush or a hay bale.
    private func drawCrater(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let spread = 22 * scale
        let bowl = CGRect(
            x: foot.x - spread * 0.5, y: foot.y - spread * 0.24,
            width: spread, height: spread * 0.48
        )

        // The lip, thrown up all round and lit on the western side like everything else here.
        context.fill(
            Path(ellipseIn: bowl.insetBy(dx: -spread * 0.08, dy: -spread * 0.04)),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.4 : 0.72))
        )
        context.fill(Path(ellipseIn: bowl), with: .color(.black.opacity(0.35)))
        context.fill(
            Path(ellipseIn: bowl.insetBy(dx: spread * 0.16, dy: spread * 0.08)),
            with: .color(GamePalette.water.opacity(colors.isNight ? 0.7 : 0.85))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: bowl.minX + spread * 0.24, y: bowl.minY + spread * 0.12,
                width: spread * 0.2, height: spread * 0.08
            )),
            with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.5 : 0.8))
        )
    }

    /// What the caverns have where every other world has a horizon: the roof, come down close
    /// enough to see, with stalactites hanging off it. A thicket closes the sky with a canopy
    /// and a city with rooftops; here there is no sky to close, so the top of the world is the
    /// underside of the rock and the far end of the gallery is simply where the light stops.
    private func drawCaveRoof(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 6_143)
        let base = horizon + 26

        var roof = Path()
        roof.move(to: CGPoint(x: -10, y: base))
        var across: CGFloat = -10
        while across < size.width + 20 {
            let step = CGFloat(scatter.next(in: 26...58))
            // A stalactite every so often, hanging a good deal further down than the rock
            // between them, so the roof reads as teeth rather than as a hedge.
            let drop = scatter.next() < 0.42
                ? CGFloat(scatter.next(in: 26...64))
                : CGFloat(scatter.next(in: 4...14))
            roof.addLine(to: CGPoint(x: across + step * 0.5, y: base + drop))
            roof.addLine(to: CGPoint(x: across + step, y: base + CGFloat(scatter.next(in: 0...6))))
            across += step
        }
        roof.addLine(to: CGPoint(x: across, y: base - 40))
        roof.addLine(to: CGPoint(x: -10, y: base - 40))
        roof.closeSubpath()
        context.fill(roof, with: .color(colors.canopyShade))
    }

    /// A splinter of whatever came down, standing up out of the dust where it landed. It is
    /// the one thing on this trail that is taller than it is wide, so it does for the reaches
    /// what a tree does everywhere else.
    private func drawShard(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let height = 26 * scale
        shadow(in: &context, at: foot, width: height * 0.5)

        var splinter = Path()
        splinter.move(to: CGPoint(x: foot.x - height * 0.16, y: foot.y))
        splinter.addLine(to: CGPoint(x: foot.x - height * 0.06, y: foot.y - height * 0.86))
        splinter.addLine(to: CGPoint(x: foot.x + height * 0.13, y: foot.y - height * 0.62))
        splinter.addLine(to: CGPoint(x: foot.x + height * 0.18, y: foot.y))
        splinter.closeSubpath()
        context.fill(splinter, with: .color(colors.canopyShade))

        var lit = Path()
        lit.move(to: CGPoint(x: foot.x - height * 0.16, y: foot.y))
        lit.addLine(to: CGPoint(x: foot.x - height * 0.06, y: foot.y - height * 0.86))
        lit.addLine(to: CGPoint(x: foot.x - height * 0.01, y: foot.y))
        lit.closeSubpath()
        context.fill(
            lit,
            with: .color(Color(red: 0.80, green: 0.74, blue: 1.00).opacity(colors.isNight ? 0.3 : 0.45))
        )
    }

    /// A column of flowstone, grown up off the floor to meet what was coming down off the roof
    /// and joined to it somewhere in the middle. It is what the caverns have instead of a tree,
    /// and it is the only thing on this trail that reaches all the way up out of the frame.
    private func drawColumn(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let height = 30 * scale
        shadow(in: &context, at: foot, width: height * 0.56)

        // The waist is narrower than either end: a column is two cones that met.
        var stone = Path()
        stone.move(to: CGPoint(x: foot.x - height * 0.26, y: foot.y))
        stone.addQuadCurve(
            to: CGPoint(x: foot.x - height * 0.09, y: foot.y - height),
            control: CGPoint(x: foot.x - height * 0.08, y: foot.y - height * 0.52)
        )
        stone.addLine(to: CGPoint(x: foot.x + height * 0.11, y: foot.y - height))
        stone.addQuadCurve(
            to: CGPoint(x: foot.x + height * 0.26, y: foot.y),
            control: CGPoint(x: foot.x + height * 0.10, y: foot.y - height * 0.52)
        )
        stone.closeSubpath()
        context.fill(stone, with: .color(colors.canopy))

        // The lit western side, where the light in this game always is.
        var lit = Path()
        lit.move(to: CGPoint(x: foot.x - height * 0.26, y: foot.y))
        lit.addQuadCurve(
            to: CGPoint(x: foot.x - height * 0.09, y: foot.y - height),
            control: CGPoint(x: foot.x - height * 0.08, y: foot.y - height * 0.52)
        )
        lit.addLine(to: CGPoint(x: foot.x - height * 0.02, y: foot.y - height))
        lit.addLine(to: CGPoint(x: foot.x - height * 0.09, y: foot.y))
        lit.closeSubpath()
        context.fill(lit, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.10 : 0.22)))
    }

    /// A cluster of crystals growing out of the floor with their own light in them — the same
    /// thing the boards of this world are scattered with, and what the caverns have instead of
    /// wildflowers. It is the only light source on any trail in the game that is on the ground
    /// rather than in the sky.
    private func drawCrystalCluster(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        scale: CGFloat
    ) {
        let height = 20 * scale

        context.fill(
            circle(at: CGPoint(x: foot.x, y: foot.y - height * 0.5), radius: height * 1.6),
            with: .radialGradient(
                Gradient(colors: [
                    colors.disc.opacity(colors.isNight ? 0.30 : 0.18),
                    colors.disc.opacity(0)
                ]),
                center: CGPoint(x: foot.x, y: foot.y - height * 0.5),
                startRadius: 0,
                endRadius: height * 1.6
            )
        )

        for lean in [-0.5, 0.05, 0.55] {
            let tall = height * (lean == 0.05 ? 1.0 : 0.6)
            let wide = height * (lean == 0.05 ? 0.24 : 0.17)
            let tip = CGPoint(x: foot.x + height * CGFloat(lean) * 0.6, y: foot.y - tall)
            var shard = Path()
            shard.move(to: tip)
            shard.addLine(to: CGPoint(x: tip.x + wide, y: foot.y - wide * 1.4))
            shard.addLine(to: CGPoint(x: tip.x + wide * 0.6, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - wide * 0.6, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - wide, y: foot.y - wide * 1.4))
            shard.closeSubpath()
            context.fill(shard, with: .color(colors.disc.opacity(colors.isNight ? 0.9 : 0.75)))
            context.stroke(
                shard,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.5 : 0.35)),
                lineWidth: 1.2
            )
        }
    }

    /// Where the landmark at the foot of the trail stands: the barn in a meadow, a hollow
    /// stump in the thicket, a cairn on the mountain, a clocktower in the city, the first
    /// crater out in the reaches, the mouth of the cave down in the caverns — below the first
    /// signpost, on whichever side of the world the trail does not start on.
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

    /// The clocktower at the foot of the city trail, with the hands stopped at whatever hour
    /// nobody has been up to wind it — the city's answer to the barn the pig came out of, the
    /// stump it went past in the woods and the cairn somebody left on the mountain. It is
    /// what the world is named for, and the first thing the pig walked in under.
    private func drawClocktower(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 46
        let tall: CGFloat = 78

        shadow(in: &context, at: CGPoint(x: centre.x, y: centre.y + tall * 0.34), width: wide)

        let tower = CGRect(
            x: centre.x - wide * 0.38, y: centre.y - tall * 0.5,
            width: wide * 0.76, height: tall * 0.84
        )
        context.fill(Path(tower), with: .color(GamePalette.barn.opacity(colors.isNight ? 0.6 : 0.85)))
        // The lit western face, the way the light falls on everything else in the game.
        context.fill(
            Path(CGRect(x: tower.minX, y: tower.minY, width: tower.width * 0.3, height: tower.height)),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.14))
        )

        // The roof, and a weathervane over the whole city.
        var roof = Path()
        roof.move(to: CGPoint(x: tower.minX - 6, y: tower.minY))
        roof.addLine(to: CGPoint(x: centre.x, y: tower.minY - tall * 0.26))
        roof.addLine(to: CGPoint(x: tower.maxX + 6, y: tower.minY))
        roof.closeSubpath()
        context.fill(roof, with: .color(GamePalette.post))

        // The face itself, which is the only round thing in this world.
        let face = CGPoint(x: centre.x, y: tower.minY + tower.height * 0.26)
        context.fill(
            circle(at: face, radius: wide * 0.24),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.7 : 0.95))
        )
        var hands = Path()
        hands.move(to: face)
        hands.addLine(to: CGPoint(x: face.x, y: face.y - wide * 0.17))
        hands.move(to: face)
        hands.addLine(to: CGPoint(x: face.x + wide * 0.12, y: face.y + wide * 0.06))
        context.stroke(
            hands,
            with: .color(GamePalette.post),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )

        // The archway the pig came in under.
        let arch = CGRect(
            x: centre.x - wide * 0.14, y: tower.maxY - tower.height * 0.3,
            width: wide * 0.28, height: tower.height * 0.3
        )
        context.fill(
            Path(roundedRect: arch, cornerRadius: wide * 0.14),
            with: .color(GamePalette.post.opacity(0.9))
        )
    }

    /// The first crater, at the foot of the trail through the reaches: the one that came down
    /// on the night the pig got up here, with a well of water standing in it and the stardrop
    /// that made it still lying in the middle. It is this world's answer to the barn the pig
    /// came out of, the stump it went past in the woods, the cairn somebody left on the
    /// mountain and the clocktower it walked in under in the city — the thing at the bottom of
    /// the world that says where all this started.
    private func drawFirstCrater(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 92
        let tall: CGFloat = 46

        let bowl = CGRect(
            x: centre.x - wide / 2, y: centre.y - tall / 2,
            width: wide, height: tall
        )

        // The lip, thrown up all round and standing higher on the far side.
        context.fill(
            Path(ellipseIn: bowl.insetBy(dx: -9, dy: -6)),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.45 : 0.8))
        )
        context.fill(
            Path(ellipseIn: bowl.insetBy(dx: -4, dy: -3)),
            with: .color(.black.opacity(0.3))
        )

        // The well itself, and the light coming up out of it — which is why the trail through
        // this world reads as lit from below rather than from the sky.
        let well = bowl.insetBy(dx: 14, dy: 8)
        context.fill(
            Path(ellipseIn: well.insetBy(dx: -18, dy: -12)),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.72, green: 0.68, blue: 1.00).opacity(colors.isNight ? 0.4 : 0.2),
                    Color(red: 0.72, green: 0.68, blue: 1.00).opacity(0)
                ]),
                center: CGPoint(x: well.midX, y: well.midY),
                startRadius: 0,
                endRadius: well.width * 0.9
            )
        )
        context.fill(
            Path(ellipseIn: well),
            with: .color(GamePalette.waterDeep.opacity(colors.isNight ? 0.85 : 0.95))
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: well.minX + well.width * 0.16, y: well.minY + well.height * 0.2,
                width: well.width * 0.3, height: well.height * 0.24
            )),
            with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.45 : 0.75))
        )

        // The stardrop that dug it, still sitting in the middle of its own crater.
        let star = CGPoint(x: well.midX, y: well.midY - 1)
        context.fill(
            circle(at: star, radius: 12),
            with: .radialGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0.6),
                    GamePalette.cream.opacity(0)
                ]),
                center: star,
                startRadius: 0,
                endRadius: 12
            )
        )
        var points = Path()
        for turn in 0..<4 {
            let angle = Double(turn) * .pi / 2
            points.move(to: star)
            points.addLine(to: CGPoint(
                x: star.x + 9 * CGFloat(cos(angle)),
                y: star.y + 6 * CGFloat(sin(angle))
            ))
        }
        context.stroke(
            points,
            with: .color(GamePalette.cream.opacity(0.95)),
            style: StrokeStyle(lineWidth: 2.6, lineCap: .round)
        )
    }

    /// The way in, down at the foot of the caverns: the mouth of the cave with daylight still
    /// coming through it. Every other world's landmark is something the pig arrived to find —
    /// a barn, a stump, a cairn, a clocktower, the crater that started the reaches. This one is
    /// the hole it came down, which is the only daylight anywhere in the world and is behind
    /// the pig from the first field on.
    private func drawCaveMouth(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 86
        let tall: CGFloat = 76

        // The rock round it, thrown up in a heap the way a sink hole leaves it.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.62, y: centre.y - tall * 0.2,
                width: wide * 1.24, height: tall * 0.44
            )),
            with: .color(colors.canopyShade)
        )

        // The arch itself: a mouth taller than it is wide, cut into the far wall.
        var arch = Path()
        arch.move(to: CGPoint(x: centre.x - wide * 0.42, y: centre.y + tall * 0.06))
        arch.addLine(to: CGPoint(x: centre.x - wide * 0.36, y: centre.y - tall * 0.3))
        arch.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.36, y: centre.y - tall * 0.3),
            control: CGPoint(x: centre.x, y: centre.y - tall * 0.86)
        )
        arch.addLine(to: CGPoint(x: centre.x + wide * 0.42, y: centre.y + tall * 0.06))
        arch.closeSubpath()

        // The light coming down it, brightest at the top where the outside is.
        context.fill(
            arch,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(colors.isNight ? 0.34 : 0.72),
                    colors.disc.opacity(colors.isNight ? 0.18 : 0.34),
                    .black.opacity(0.5)
                ]),
                startPoint: CGPoint(x: centre.x, y: centre.y - tall * 0.8),
                endPoint: CGPoint(x: centre.x, y: centre.y + tall * 0.1)
            )
        )
        context.stroke(
            arch,
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.5 : 0.8)),
            style: StrokeStyle(lineWidth: 5, lineCap: .round)
        )

        // And a shaft of it lying across the floor, pointing the way the pig came.
        var shaft = Path()
        shaft.move(to: CGPoint(x: centre.x - wide * 0.3, y: centre.y + tall * 0.06))
        shaft.addLine(to: CGPoint(x: centre.x + wide * 0.3, y: centre.y + tall * 0.06))
        shaft.addLine(to: CGPoint(x: centre.x + wide * 0.52, y: centre.y + tall * 0.4))
        shaft.addLine(to: CGPoint(x: centre.x - wide * 0.52, y: centre.y + tall * 0.4))
        shaft.closeSubpath()
        context.fill(
            shaft,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(colors.isNight ? 0.16 : 0.3),
                    GamePalette.cream.opacity(0)
                ]),
                startPoint: CGPoint(x: centre.x, y: centre.y + tall * 0.06),
                endPoint: CGPoint(x: centre.x, y: centre.y + tall * 0.4)
            )
        )
    }

    /// The big top at the foot of the carnival trail, with its doorway open and the light of
    /// the ring coming out of it. Every landmark before this was something standing still that
    /// the pig arrived to find — a barn, a stump, a cairn, a clocktower, a crater, the hole it
    /// came down. This one has somebody in it, and at the end of the world the pig has to go in
    /// and fence him.
    private func drawBigTop(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 96
        let tall: CGFloat = 84

        shadow(in: &context, at: CGPoint(x: centre.x, y: centre.y + tall * 0.34), width: wide)

        // The canvas: a tall cone with the walls hanging straight down off it, panelled in the
        // two colours a big top is always painted.
        let eaves = centre.y - tall * 0.06
        let panels = 6
        for panel in 0..<panels {
            let left = centre.x - wide * 0.5 + wide * CGFloat(panel) / CGFloat(panels)
            var cloth = Path()
            cloth.move(to: CGPoint(x: left, y: eaves))
            cloth.addLine(to: CGPoint(x: left + wide / CGFloat(panels), y: eaves))
            cloth.addLine(to: CGPoint(x: centre.x, y: centre.y - tall * 0.86))
            cloth.closeSubpath()
            context.fill(
                cloth,
                with: .color(
                    panel % 2 == 0
                        ? colors.canopy
                        : GamePalette.cream.opacity(colors.isNight ? 0.72 : 0.92)
                )
            )
        }
        let walls = CGRect(
            x: centre.x - wide * 0.5, y: eaves, width: wide, height: tall * 0.34
        )
        context.fill(Path(walls), with: .color(colors.canopyShade))

        // The doorway, tied back, with the ring lit behind it.
        let door = CGRect(
            x: centre.x - wide * 0.15, y: walls.minY + walls.height * 0.1,
            width: wide * 0.3, height: walls.height * 0.9
        )
        context.fill(
            Path(roundedRect: door, cornerRadius: door.width * 0.4),
            with: .color(Color(red: 1.00, green: 0.82, blue: 0.48).opacity(colors.isNight ? 0.9 : 0.75))
        )
        context.fill(
            circle(at: CGPoint(x: door.midX, y: door.midY), radius: wide * 0.34),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 1.00, green: 0.82, blue: 0.48).opacity(colors.isNight ? 0.30 : 0.14),
                    Color(red: 1.00, green: 0.82, blue: 0.48).opacity(0)
                ]),
                center: CGPoint(x: door.midX, y: door.midY),
                startRadius: 0,
                endRadius: wide * 0.34
            )
        )

        // The king pole and its flag, and the guys running down off the eaves to their pegs.
        let peak = CGPoint(x: centre.x, y: centre.y - tall * 0.86)
        context.stroke(
            Path { pole in
                pole.move(to: peak)
                pole.addLine(to: CGPoint(x: peak.x, y: peak.y - 18))
            },
            with: .color(GamePalette.rail),
            lineWidth: 2.4
        )
        var flag = Path()
        flag.move(to: CGPoint(x: peak.x, y: peak.y - 18))
        flag.addLine(to: CGPoint(x: peak.x + 16, y: peak.y - 13))
        flag.addLine(to: CGPoint(x: peak.x, y: peak.y - 8))
        flag.closeSubpath()
        context.fill(flag, with: .color(colors.canopy))

        var guys = Path()
        for side in [-1.0, 1.0] {
            guys.move(to: CGPoint(x: centre.x + wide * 0.5 * CGFloat(side), y: eaves))
            guys.addLine(to: CGPoint(
                x: centre.x + wide * 0.72 * CGFloat(side),
                y: centre.y + tall * 0.3
            ))
        }
        context.stroke(
            guys,
            with: .color(
                Color(red: 0.80, green: 0.70, blue: 0.52).opacity(colors.isNight ? 0.5 : 0.75)
            ),
            lineWidth: 1.6
        )
    }

    /// The rock arch at the foot of the dunes trail: a fin of sandstone the wind has cut a hole
    /// clean through, standing on its own out on the sand with the sky showing under it.
    ///
    /// Every landmark before it was somewhere to shelter or somewhere to go in — a barn, a hollow,
    /// a cave mouth, a big top with the ring lit behind the door. This one is nowhere to go. It is
    /// the only thing standing between here and the horizon, and all it is good for is telling a
    /// player which way is which, which is what a landmark in a desert is actually for.
    private func drawRockArch(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 104
        let tall: CGFloat = 78

        // The shadow, thrown long and to one side to match every other shadow in the world.
        var thrown = Path()
        thrown.move(to: CGPoint(x: centre.x - wide * 0.44, y: centre.y + tall * 0.06))
        thrown.addLine(to: CGPoint(x: centre.x + wide * 1.05, y: centre.y + tall * 0.34))
        thrown.addLine(to: CGPoint(x: centre.x + wide * 1.05, y: centre.y + tall * 0.46))
        thrown.addLine(to: CGPoint(x: centre.x - wide * 0.4, y: centre.y + tall * 0.22))
        thrown.closeSubpath()
        context.fill(thrown, with: .color(shade.opacity(colors.isNight ? 0.28 : 0.34)))

        let stone = Color(red: 0.74, green: 0.48, blue: 0.32)
        let sunlit = Color(red: 0.89, green: 0.66, blue: 0.44)

        // The fin: two legs of different weights with a span thrown across the top of them, and
        // the hole the wind made between. The legs are uneven because a symmetrical arch reads as
        // something built, and nobody built this.
        var rock = Path()
        rock.move(to: CGPoint(x: centre.x - wide * 0.46, y: centre.y + tall * 0.1))
        rock.addLine(to: CGPoint(x: centre.x - wide * 0.30, y: centre.y - tall * 0.52))
        rock.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.30, y: centre.y - tall * 0.58),
            control: CGPoint(x: centre.x, y: centre.y - tall * 0.96)
        )
        rock.addLine(to: CGPoint(x: centre.x + wide * 0.48, y: centre.y + tall * 0.1))
        rock.addLine(to: CGPoint(x: centre.x + wide * 0.26, y: centre.y + tall * 0.1))
        // The underside of the span, which is the hole.
        rock.addQuadCurve(
            to: CGPoint(x: centre.x - wide * 0.24, y: centre.y + tall * 0.1),
            control: CGPoint(x: centre.x, y: centre.y - tall * 0.56)
        )
        rock.closeSubpath()
        context.fill(
            rock,
            with: .linearGradient(
                Gradient(colors: [sunlit, stone]),
                startPoint: CGPoint(x: centre.x - wide * 0.5, y: centre.y - tall),
                endPoint: CGPoint(x: centre.x + wide * 0.5, y: centre.y + tall * 0.1)
            )
        )
        context.stroke(rock, with: .color(stone.opacity(0.9)), lineWidth: 2)

        // Bedding planes, which is what says sandstone rather than boulder.
        var beds = Path()
        for level in [0.62, 0.34, 0.06] {
            beds.move(to: CGPoint(x: centre.x - wide * 0.44, y: centre.y + tall * CGFloat(level) * 0.16))
            beds.addLine(to: CGPoint(x: centre.x - wide * 0.31, y: centre.y + tall * CGFloat(level) * 0.16))
            beds.move(to: CGPoint(x: centre.x + wide * 0.28, y: centre.y + tall * CGFloat(level) * 0.16))
            beds.addLine(to: CGPoint(x: centre.x + wide * 0.46, y: centre.y + tall * CGFloat(level) * 0.16))
        }
        context.stroke(beds, with: .color(shade.opacity(0.3)), lineWidth: 1.4)

        // A drift of sand piled against the windward leg, since that is what happens to anything
        // that stands still out here for long enough.
        var drift = Path()
        drift.move(to: CGPoint(x: centre.x - wide * 0.62, y: centre.y + tall * 0.12))
        drift.addQuadCurve(
            to: CGPoint(x: centre.x - wide * 0.22, y: centre.y + tall * 0.12),
            control: CGPoint(x: centre.x - wide * 0.42, y: centre.y - tall * 0.06)
        )
        drift.closeSubpath()
        context.fill(drift, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.12 : 0.44)))
    }

    /// The wreck at the foot of the cove trail: the ribs of an old boat, beached past the reach
    /// of the ordinary tide and half swallowed by the sand anyway.
    ///
    /// The dunes' arch was the first landmark that was nowhere to go, and this is the second —
    /// but where the arch was never anything else, the wreck used to be somewhere to go, which
    /// is the cove's whole story about the sea: it rearranges whatever it is given.
    private func drawWreck(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 96
        let tall: CGFloat = 44

        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.52, y: centre.y - tall * 0.08,
                width: wide * 1.04, height: tall * 0.3
            )),
            with: .color(.black.opacity(colors.isNight ? 0.24 : 0.18))
        )

        let timber = Color(red: 0.32, green: 0.26, blue: 0.21)
        let worn = Color(red: 0.52, green: 0.45, blue: 0.38)

        // The hull, keeled over and open to the sky: one long sweep of gunwale with the bow
        // still standing and the stern gone into the sand.
        var hull = Path()
        hull.move(to: CGPoint(x: centre.x - wide * 0.5, y: centre.y))
        hull.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.34, y: centre.y - tall * 0.34),
            control: CGPoint(x: centre.x - wide * 0.06, y: centre.y - tall * 0.62)
        )
        hull.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.5, y: centre.y - tall * 0.9),
            control: CGPoint(x: centre.x + wide * 0.46, y: centre.y - tall * 0.5)
        )
        hull.addLine(to: CGPoint(x: centre.x + wide * 0.42, y: centre.y))
        hull.closeSubpath()
        context.fill(
            hull,
            with: .linearGradient(
                Gradient(colors: [worn, timber]),
                startPoint: CGPoint(x: centre.x, y: centre.y - tall),
                endPoint: CGPoint(x: centre.x, y: centre.y)
            )
        )
        context.stroke(hull, with: .color(timber.opacity(0.9)), lineWidth: 2)

        // The ribs standing proud where the planking has gone, which is what says wreck
        // rather than boat.
        var ribs = Path()
        for along in [0.2, 0.42, 0.64] {
            let x = centre.x - wide * 0.5 + wide * CGFloat(along)
            ribs.move(to: CGPoint(x: x, y: centre.y - tall * 0.02))
            ribs.addQuadCurve(
                to: CGPoint(x: x + wide * 0.05, y: centre.y - tall * 0.66),
                control: CGPoint(x: x - wide * 0.06, y: centre.y - tall * 0.4)
            )
        }
        context.stroke(
            ribs,
            with: .color(worn.opacity(colors.isNight ? 0.6 : 0.9)),
            style: StrokeStyle(lineWidth: 3.4, lineCap: .round)
        )

        // The sand drifted up the stern, and a pool the tide keeps in the shadow of the bow.
        var bank = Path()
        bank.move(to: CGPoint(x: centre.x - wide * 0.62, y: centre.y + 1))
        bank.addQuadCurve(
            to: CGPoint(x: centre.x - wide * 0.1, y: centre.y + 1),
            control: CGPoint(x: centre.x - wide * 0.38, y: centre.y - tall * 0.18)
        )
        bank.closeSubpath()
        context.fill(bank, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.1 : 0.34)))
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x + wide * 0.2, y: centre.y + tall * 0.1,
                width: wide * 0.3, height: tall * 0.14
            )),
            with: .color(Color(red: 0.22, green: 0.52, blue: 0.55).opacity(colors.isNight ? 0.5 : 0.7))
        )
    }

    /// The floor of the cove: wet sand with the tide's own lines across it, every one bowed the
    /// same way because they are one sea's edges remembered at different heights, and pans of
    /// standing water still holding the sky.
    ///
    /// Nobody laid this out, the way nobody laid out the dunes' combing — but where the desert's
    /// lines were cut by something that kept going, these were left by something that means to
    /// come back, which is why they get the sky's own light lying in among them.
    private func drawTideLines(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 5_419)

        // Pans of standing water, flat and full of sky.
        for _ in 0..<7 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: -0.1...1.1)) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 60...180))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.08,
                    width: spread, height: spread * 0.16
                )),
                with: .color(
                    Color(red: 0.55, green: 0.75, blue: 0.76)
                        .opacity(colors.isNight ? 0.26 : 0.45)
                )
            )
        }

        // The tide lines themselves: a pale foam edge over a damp shadow, bowed seawards.
        for _ in 0..<24 {
            let down = horizon + CGFloat(scatter.next(in: -0.02...1.02)) * (size.height - horizon)
            var line = Path()
            line.move(to: CGPoint(x: -20, y: down))
            line.addCurve(
                to: CGPoint(x: size.width + 20, y: down + CGFloat(scatter.next(in: -24...24))),
                control1: CGPoint(x: size.width * 0.3, y: down - CGFloat(scatter.next(in: 6...22))),
                control2: CGPoint(x: size.width * 0.7, y: down - CGFloat(scatter.next(in: 6...22)))
            )
            let width = CGFloat(scatter.next(in: 1.4...3.6))
            context.translateBy(x: 0, y: width)
            context.stroke(
                line,
                with: .color(Color(red: 0.20, green: 0.30, blue: 0.32).opacity(colors.isNight ? 0.24 : 0.16)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
            context.translateBy(x: 0, y: -width)
            context.stroke(
                line,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.07 : 0.26)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
        }
    }

    /// The sea out along the horizon, which is what the cove's sky comes down to: a band of
    /// open water with the light lying on it in streaks, and one low headland standing out
    /// into it a long way off.
    ///
    /// Every world before this closed its horizon with more of its own ground — trees, roofs,
    /// rock, sand going back until it ran out. This is the first one closed by the thing the
    /// whole world is about: the water that keeps coming back for it.
    private func drawSeaHorizon(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 4_177)
        let base = horizon + 26

        // The sea itself: one band from rim to rim, darkest at the skyline.
        var sea = Path()
        sea.move(to: CGPoint(x: -20, y: base - 34))
        sea.addLine(to: CGPoint(x: size.width + 20, y: base - 36))
        sea.addLine(to: CGPoint(x: size.width + 20, y: base + 26))
        sea.addLine(to: CGPoint(x: -20, y: base + 30))
        sea.closeSubpath()
        context.fill(
            sea,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.14, green: 0.38, blue: 0.44),
                    Color(red: 0.28, green: 0.56, blue: 0.58)
                ]),
                startPoint: CGPoint(x: size.width / 2, y: base - 36),
                endPoint: CGPoint(x: size.width / 2, y: base + 30)
            )
        )

        // The light on it, in flat streaks that get shorter as they get further away.
        var streaks = Path()
        for _ in 0..<10 {
            let down = base - 30 + CGFloat(scatter.next()) * 52
            let nearness = (down - (base - 30)) / 52
            let span = CGFloat(scatter.next(in: 18...56)) * (0.5 + nearness)
            let x = CGFloat(scatter.next()) * size.width
            streaks.move(to: CGPoint(x: x, y: down))
            streaks.addLine(to: CGPoint(x: x + span, y: down))
        }
        context.stroke(
            streaks,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.14 : 0.4)),
            style: StrokeStyle(lineWidth: 2, lineCap: .round)
        )

        // The headland, low and far, with the sea going on behind it.
        var headland = Path()
        headland.move(to: CGPoint(x: size.width * 0.68, y: base - 34))
        headland.addQuadCurve(
            to: CGPoint(x: size.width * 0.9, y: base - 34),
            control: CGPoint(x: size.width * 0.79, y: base - 52)
        )
        headland.closeSubpath()
        context.fill(headland, with: .color(colors.farHill.opacity(0.85)))
    }

    /// A rock pool at trailside size: a broken ring of tidewater round a heart of dry sand —
    /// the same shape every board in this world is built from, so the first ring a player
    /// meets on a field is one they have already stood beside on the way there.
    private func drawStrandPool(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 46 * scale
        let tall = wide * 0.5
        let ring = CGRect(x: foot.x - wide / 2, y: foot.y - tall, width: wide, height: tall)
        let water = Color(red: 0.20, green: 0.50, blue: 0.54)

        context.stroke(
            Path(ellipseIn: ring),
            with: .color(water.opacity(colors.isNight ? 0.6 : 0.85)),
            lineWidth: wide * 0.14
        )
        context.fill(
            Path(ellipseIn: ring.insetBy(dx: wide * 0.26, dy: tall * 0.26)),
            with: .color(colors.foreground)
        )

        // The break in the lip, and the sky caught on the far side of the water.
        context.fill(
            Path(ellipseIn: CGRect(
                x: ring.midX + wide * 0.3, y: ring.maxY - tall * 0.22,
                width: wide * 0.16, height: tall * 0.2
            )),
            with: .color(colors.foreground)
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: ring.midX - wide * 0.2, y: ring.minY - tall * 0.02,
                width: wide * 0.28, height: tall * 0.14
            )),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.22 : 0.55))
        )
    }

    /// A shell washed up whole, drawn pale against the wet sand with its whorl showing.
    private func drawShell(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 15 * scale
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - wide * 0.55, y: foot.y - wide * 0.08,
                width: wide * 1.1, height: wide * 0.2
            )),
            with: .color(.black.opacity(colors.isNight ? 0.2 : 0.15))
        )
        let body = Path(ellipseIn: CGRect(
            x: foot.x - wide / 2, y: foot.y - wide * 0.7, width: wide, height: wide * 0.7
        ))
        context.fill(body, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.5 : 0.9)))
        context.stroke(
            body,
            with: .color(Color(red: 0.6, green: 0.48, blue: 0.4).opacity(0.6)),
            lineWidth: 1.2
        )
        var whorl = Path()
        for inset in [0.24, 0.46] {
            whorl.addEllipse(in: CGRect(
                x: foot.x - wide / 2 + wide * CGFloat(inset),
                y: foot.y - wide * 0.7 + wide * 0.7 * CGFloat(inset),
                width: wide * (1 - CGFloat(inset) * 1.6),
                height: wide * 0.7 * (1 - CGFloat(inset))
            ))
        }
        context.stroke(
            whorl,
            with: .color(Color(red: 0.6, green: 0.48, blue: 0.4).opacity(0.35)),
            lineWidth: 1
        )
    }

    /// A length of driftwood the sea has finished with: one bleached bough with a stub of
    /// branch, half sunk in the sand it was thrown onto.
    private func drawDriftwood(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 34 * scale
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - wide * 0.5, y: foot.y - wide * 0.03,
                width: wide, height: wide * 0.12
            )),
            with: .color(.black.opacity(colors.isNight ? 0.2 : 0.15))
        )
        var bough = Path()
        bough.move(to: CGPoint(x: foot.x - wide * 0.5, y: foot.y))
        bough.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.5, y: foot.y - wide * 0.08),
            control: CGPoint(x: foot.x, y: foot.y - wide * 0.18)
        )
        context.stroke(
            bough,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.4 : 0.8)),
            style: StrokeStyle(lineWidth: max(2, wide * 0.1), lineCap: .round)
        )
        var stub = Path()
        stub.move(to: CGPoint(x: foot.x + wide * 0.12, y: foot.y - wide * 0.12))
        stub.addLine(to: CGPoint(x: foot.x + wide * 0.24, y: foot.y - wide * 0.3))
        context.stroke(
            stub,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.36 : 0.7)),
            style: StrokeStyle(lineWidth: max(1.4, wide * 0.06), lineCap: .round)
        )
    }

    /// The igloo at the foot of the tundra trail: somebody's winter house, built out of the
    /// only thing there is to build with, with its low tunnel doorway facing away from the
    /// wind — and after dark a warm light showing through the doorway, which makes it the one
    /// landmark since the carnival with somebody at home in it.
    private func drawIgloo(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 88
        let tall: CGFloat = 46

        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.56, y: centre.y - tall * 0.08,
                width: wide * 1.12, height: tall * 0.3
            )),
            with: .color(
                Color(red: 0.30, green: 0.42, blue: 0.60).opacity(colors.isNight ? 0.3 : 0.22)
            )
        )

        let block = Color(red: 0.88, green: 0.93, blue: 0.97)
        let joint = Color(red: 0.58, green: 0.70, blue: 0.82)

        // The dome, lit the way snow is: nearly white on top, blue in its own shadow.
        var dome = Path()
        dome.move(to: CGPoint(x: centre.x - wide * 0.5, y: centre.y))
        dome.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.5, y: centre.y),
            control: CGPoint(x: centre.x, y: centre.y - tall * 1.42)
        )
        dome.closeSubpath()
        context.fill(
            dome,
            with: .linearGradient(
                Gradient(colors: [block, Color(red: 0.68, green: 0.78, blue: 0.88)]),
                startPoint: CGPoint(x: centre.x, y: centre.y - tall),
                endPoint: CGPoint(x: centre.x, y: centre.y)
            )
        )
        context.stroke(dome, with: .color(joint.opacity(0.8)), lineWidth: 2)

        // The courses of blocks, which is what says built rather than drifted.
        var courses = Path()
        for course in [0.36, 0.66] {
            let y = centre.y - tall * CGFloat(course)
            let reach = wide * 0.5 * CGFloat(1 - course * 0.55)
            courses.move(to: CGPoint(x: centre.x - reach, y: y))
            courses.addQuadCurve(
                to: CGPoint(x: centre.x + reach, y: y),
                control: CGPoint(x: centre.x, y: y - tall * 0.1)
            )
        }
        for upright in [-0.3, 0.0, 0.3] {
            let x = centre.x + wide * CGFloat(upright)
            courses.move(to: CGPoint(x: x, y: centre.y - tall * 0.04))
            courses.addLine(to: CGPoint(x: x, y: centre.y - tall * 0.32))
        }
        context.stroke(courses, with: .color(joint.opacity(0.55)), lineWidth: 1.6)

        // The tunnel doorway, and whoever is in there keeping a lamp on after dark.
        var tunnel = Path()
        tunnel.move(to: CGPoint(x: centre.x + wide * 0.26, y: centre.y))
        tunnel.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.52, y: centre.y),
            control: CGPoint(x: centre.x + wide * 0.39, y: centre.y - tall * 0.5)
        )
        tunnel.closeSubpath()
        context.fill(tunnel, with: .color(block))
        context.stroke(tunnel, with: .color(joint.opacity(0.8)), lineWidth: 1.6)
        var doorway = Path()
        doorway.move(to: CGPoint(x: centre.x + wide * 0.33, y: centre.y))
        doorway.addQuadCurve(
            to: CGPoint(x: centre.x + wide * 0.45, y: centre.y),
            control: CGPoint(x: centre.x + wide * 0.39, y: centre.y - tall * 0.3)
        )
        doorway.closeSubpath()
        context.fill(
            doorway,
            with: .color(
                colors.isNight
                    ? GamePalette.pen.opacity(0.85)
                    : Color.black.opacity(0.5)
            )
        )
        if colors.isNight {
            context.fill(
                circle(at: CGPoint(x: centre.x + wide * 0.39, y: centre.y - tall * 0.08), radius: wide * 0.18),
                with: .color(GamePalette.pen.opacity(0.18))
            )
        }

        // The drift banked up its windward side.
        var bank = Path()
        bank.move(to: CGPoint(x: centre.x - wide * 0.64, y: centre.y + 1))
        bank.addQuadCurve(
            to: CGPoint(x: centre.x - wide * 0.12, y: centre.y + 1),
            control: CGPoint(x: centre.x - wide * 0.4, y: centre.y - tall * 0.2)
        )
        bank.closeSubpath()
        context.fill(bank, with: .color(.white.opacity(colors.isNight ? 0.16 : 0.5)))
    }

    /// The floor of the tundra: snow with the wind's own lines combed across it, every one
    /// pulled the same way because they are one wind's work, and patches of blue ice scoured
    /// bare in among them.
    ///
    /// Nobody laid this out, the way nobody laid out the cove's tide lines — but where the
    /// sea's lines were left by something that means to come back, these are being redrawn by
    /// something that never left.
    private func drawSnowdrifts(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 6_121)

        // The scoured patches: old sea ice showing through, flat and blue.
        for _ in 0..<6 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: -0.1...1.1)) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 60...170))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.08,
                    width: spread, height: spread * 0.16
                )),
                with: .color(
                    Color(red: 0.46, green: 0.62, blue: 0.80)
                        .opacity(colors.isNight ? 0.24 : 0.35)
                )
            )
        }

        // The sastrugi: a lit crest over a blue trough, bowed downwind.
        for _ in 0..<24 {
            let down = horizon + CGFloat(scatter.next(in: -0.02...1.02)) * (size.height - horizon)
            var wave = Path()
            wave.move(to: CGPoint(x: -20, y: down))
            wave.addCurve(
                to: CGPoint(x: size.width + 20, y: down + CGFloat(scatter.next(in: -24...24))),
                control1: CGPoint(x: size.width * 0.3, y: down - CGFloat(scatter.next(in: 6...20))),
                control2: CGPoint(x: size.width * 0.7, y: down - CGFloat(scatter.next(in: 6...20)))
            )
            let width = CGFloat(scatter.next(in: 1.4...3.4))
            context.translateBy(x: 0, y: width)
            context.stroke(
                wave,
                with: .color(
                    Color(red: 0.30, green: 0.42, blue: 0.60).opacity(colors.isNight ? 0.26 : 0.18)
                ),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
            context.translateBy(x: 0, y: -width)
            context.stroke(
                wave,
                with: .color(.white.opacity(colors.isNight ? 0.08 : 0.3)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
        }
    }

    /// The berg line out along the horizon, which is what the tundra's sky comes down to: the
    /// frozen sea going back in floes and stranded bergs — and after dark the aurora standing
    /// up over the lot of it, which is the one sky in the game with its own light in it.
    private func drawBergLine(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 5_209)
        let base = horizon + 26

        // The frozen sea: one pale band from rim to rim, darkest at the skyline.
        var sea = Path()
        sea.move(to: CGPoint(x: -20, y: base - 34))
        sea.addLine(to: CGPoint(x: size.width + 20, y: base - 36))
        sea.addLine(to: CGPoint(x: size.width + 20, y: base + 26))
        sea.addLine(to: CGPoint(x: -20, y: base + 30))
        sea.closeSubpath()
        context.fill(
            sea,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.44, green: 0.58, blue: 0.74),
                    Color(red: 0.70, green: 0.80, blue: 0.90)
                ]),
                startPoint: CGPoint(x: size.width / 2, y: base - 36),
                endPoint: CGPoint(x: size.width / 2, y: base + 30)
            )
        )

        // The bergs standing out of it, blue-white and flat-topped, smaller further off.
        for _ in 0..<5 {
            let x = CGFloat(scatter.next()) * size.width
            let wide = CGFloat(scatter.next(in: 22...58))
            let tall = wide * CGFloat(scatter.next(in: 0.3...0.5))
            var berg = Path()
            berg.move(to: CGPoint(x: x - wide / 2, y: base - 32))
            berg.addLine(to: CGPoint(x: x - wide * 0.3, y: base - 32 - tall))
            berg.addLine(to: CGPoint(x: x + wide * 0.34, y: base - 32 - tall * 0.85))
            berg.addLine(to: CGPoint(x: x + wide / 2, y: base - 32))
            berg.closeSubpath()
            context.fill(
                berg,
                with: .color(
                    Color(red: 0.82, green: 0.90, blue: 0.96).opacity(colors.isNight ? 0.4 : 0.9)
                )
            )
        }

        // After dark, the aurora: two ribbons of green hanging over the skyline, brighter
        // along their lower edges the way a curtain is at its hem.
        if colors.isNight {
            for (index, lift) in [0.30, 0.52].enumerated() {
                let hang = horizon * CGFloat(lift)
                var ribbon = Path()
                ribbon.move(to: CGPoint(x: -20, y: hang))
                ribbon.addCurve(
                    to: CGPoint(x: size.width + 20, y: hang - horizon * 0.08),
                    control1: CGPoint(x: size.width * 0.3, y: hang - horizon * (index == 0 ? 0.14 : 0.06)),
                    control2: CGPoint(x: size.width * 0.7, y: hang + horizon * 0.1)
                )
                context.stroke(
                    ribbon,
                    with: .color(Color(red: 0.32, green: 0.84, blue: 0.62).opacity(index == 0 ? 0.3 : 0.2)),
                    style: StrokeStyle(lineWidth: index == 0 ? 14 : 22, lineCap: .round)
                )
                context.stroke(
                    ribbon,
                    with: .color(Color(red: 0.52, green: 0.96, blue: 0.74).opacity(0.35)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
            }
        }
    }

    /// A blade of pressure ice at trailside size: one shard stood up out of the snow, lit down
    /// its sunward edge and blue down its lee — the same wall every board in this world is
    /// built with, so the first ridge a player meets on a field is one they have already stood
    /// beside on the way there.
    private func drawIceBlade(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = 34 * scale
        let half = tall * 0.28

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - half * 1.4, y: foot.y - tall * 0.05,
                width: half * 2.8, height: tall * 0.16
            )),
            with: .color(
                Color(red: 0.30, green: 0.42, blue: 0.60).opacity(colors.isNight ? 0.3 : 0.24)
            )
        )

        let peak = CGPoint(x: foot.x + tall * 0.08, y: foot.y - tall)
        var lee = Path()
        lee.move(to: CGPoint(x: foot.x - half, y: foot.y))
        lee.addLine(to: peak)
        lee.addLine(to: CGPoint(x: foot.x + half, y: foot.y))
        lee.closeSubpath()
        context.fill(
            lee,
            with: .color(
                Color(red: 0.40, green: 0.56, blue: 0.76).opacity(colors.isNight ? 0.6 : 0.85)
            )
        )
        var lit = Path()
        lit.move(to: CGPoint(x: foot.x - half, y: foot.y))
        lit.addLine(to: peak)
        lit.addLine(to: CGPoint(x: foot.x - half * 0.15, y: foot.y))
        lit.closeSubpath()
        context.fill(lit, with: .color(.white.opacity(colors.isNight ? 0.4 : 0.85)))
    }

    /// A bergy bit: a knuckle of old glacier ice calved, drifted and stranded — rounder and
    /// bluer than anything the snow makes, with its lit top and the deep blue showing at its
    /// waterline.
    private func drawBergyBit(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 26 * scale
        let tall = wide * 0.62
        let berg = CGRect(x: foot.x - wide / 2, y: foot.y - tall, width: wide, height: tall)

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - wide * 0.6, y: foot.y - tall * 0.1,
                width: wide * 1.2, height: tall * 0.26
            )),
            with: .color(
                Color(red: 0.30, green: 0.42, blue: 0.60).opacity(colors.isNight ? 0.3 : 0.24)
            )
        )
        context.fill(
            Path(roundedRect: berg, cornerRadius: wide * 0.24),
            with: .color(
                Color(red: 0.72, green: 0.84, blue: 0.94).opacity(colors.isNight ? 0.55 : 0.95)
            )
        )
        context.fill(
            Path(roundedRect: CGRect(
                x: berg.minX + wide * 0.08, y: berg.minY, width: wide * 0.84, height: tall * 0.4
            ), cornerRadius: wide * 0.2),
            with: .color(.white.opacity(colors.isNight ? 0.3 : 0.7))
        )
        context.fill(
            Path(roundedRect: CGRect(
                x: berg.minX + wide * 0.1, y: berg.maxY - tall * 0.24,
                width: wide * 0.8, height: tall * 0.18
            ), cornerRadius: wide * 0.1),
            with: .color(Color(red: 0.36, green: 0.56, blue: 0.78).opacity(0.5))
        )
    }

    /// A drift the wind has piled and not yet taken back: one long comb of snow with a sharp
    /// lit crest, lying the same way as every other line on this ground because the one wind
    /// made all of them.
    private func drawSnowDrift(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 44 * scale
        var drift = Path()
        drift.move(to: CGPoint(x: foot.x - wide * 0.5, y: foot.y))
        drift.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.5, y: foot.y - wide * 0.05),
            control: CGPoint(x: foot.x - wide * 0.05, y: foot.y - wide * 0.22)
        )
        drift.addLine(to: CGPoint(x: foot.x + wide * 0.5, y: foot.y + wide * 0.02))
        drift.addLine(to: CGPoint(x: foot.x - wide * 0.5, y: foot.y + wide * 0.02))
        drift.closeSubpath()
        context.fill(drift, with: .color(.white.opacity(colors.isNight ? 0.2 : 0.6)))
        var trough = Path()
        trough.move(to: CGPoint(x: foot.x - wide * 0.46, y: foot.y + wide * 0.03))
        trough.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.48, y: foot.y - wide * 0.01),
            control: CGPoint(x: foot.x, y: foot.y + wide * 0.09)
        )
        context.stroke(
            trough,
            with: .color(
                Color(red: 0.30, green: 0.42, blue: 0.60).opacity(colors.isNight ? 0.3 : 0.24)
            ),
            style: StrokeStyle(lineWidth: max(1.4, wide * 0.05), lineCap: .round)
        )
    }

    /// The turf-cutter's hut at the foot of the fen trail: one room up on stilts, because the
    /// only dry ground out here is the ground you bring with you. The ladder is drawn leaning
    /// rather than fixed — whoever lives here takes it up at night — and after dark the one
    /// window is lit, which makes it the second home in a row with somebody in it.
    private func drawStiltHut(in context: inout GraphicsContext) {
        let centre = landmarkStand
        let wide: CGFloat = 74
        let tall: CGFloat = 58

        context.fill(
            Path(ellipseIn: CGRect(
                x: centre.x - wide * 0.6, y: centre.y - tall * 0.06,
                width: wide * 1.2, height: tall * 0.22
            )),
            with: .color(Color(red: 0.10, green: 0.16, blue: 0.12).opacity(colors.isNight ? 0.5 : 0.35))
        )

        let timber = Color(red: 0.30, green: 0.24, blue: 0.17)
        let plank = Color(red: 0.46, green: 0.38, blue: 0.26)

        // The stilts, each with its own slight lean, and the water sheen round their feet.
        var stilts = Path()
        for (index, leg) in [0.18, 0.42, 0.62, 0.84].enumerated() {
            let x = centre.x - wide / 2 + wide * CGFloat(leg)
            let tilt: CGFloat = index.isMultiple(of: 2) ? 2.5 : -2
            stilts.move(to: CGPoint(x: x, y: centre.y))
            stilts.addLine(to: CGPoint(x: x + tilt, y: centre.y - tall * 0.34))
        }
        context.stroke(stilts, with: .color(timber), style: StrokeStyle(lineWidth: 4, lineCap: .round))

        // The one room, planked, under a rush-thatch roof with a brow over the door.
        let floorLine = centre.y - tall * 0.34
        let room = CGRect(x: centre.x - wide * 0.46, y: floorLine - tall * 0.4, width: wide * 0.92, height: tall * 0.4)
        context.fill(Path(room), with: .color(plank))
        var boards = Path()
        for course in 1..<4 {
            let y = room.minY + room.height * CGFloat(course) / 4
            boards.move(to: CGPoint(x: room.minX, y: y))
            boards.addLine(to: CGPoint(x: room.maxX, y: y))
        }
        context.stroke(boards, with: .color(timber.opacity(0.5)), lineWidth: 1.2)

        var roof = Path()
        roof.move(to: CGPoint(x: room.minX - wide * 0.1, y: room.minY))
        roof.addLine(to: CGPoint(x: centre.x, y: room.minY - tall * 0.3))
        roof.addLine(to: CGPoint(x: room.maxX + wide * 0.1, y: room.minY))
        roof.closeSubpath()
        context.fill(roof, with: .color(Color(red: 0.42, green: 0.40, blue: 0.22)))
        context.stroke(roof, with: .color(Color(red: 0.28, green: 0.27, blue: 0.15)), lineWidth: 1.6)

        // The window, and whoever is in there keeping a lamp on after dark.
        let window = CGRect(
            x: centre.x - wide * 0.09, y: room.minY + room.height * 0.24,
            width: wide * 0.18, height: room.height * 0.45
        )
        context.fill(
            Path(roundedRect: window, cornerRadius: 2),
            with: .color(colors.isNight ? GamePalette.pen.opacity(0.9) : Color.black.opacity(0.45))
        )
        if colors.isNight {
            context.fill(
                circle(at: CGPoint(x: window.midX, y: window.midY), radius: wide * 0.2),
                with: .color(GamePalette.pen.opacity(0.15))
            )
        }

        // The ladder, leaned rather than fixed.
        var ladder = Path()
        ladder.move(to: CGPoint(x: centre.x + wide * 0.3, y: centre.y + tall * 0.02))
        ladder.addLine(to: CGPoint(x: centre.x + wide * 0.16, y: floorLine))
        ladder.move(to: CGPoint(x: centre.x + wide * 0.38, y: centre.y))
        ladder.addLine(to: CGPoint(x: centre.x + wide * 0.24, y: floorLine - 2))
        context.stroke(ladder, with: .color(timber), style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
        var rungs = Path()
        for rung in stride(from: 0.15, through: 0.85, by: 0.175) {
            let a = CGPoint(
                x: centre.x + wide * 0.3 - wide * 0.14 * rung,
                y: centre.y + tall * 0.02 - (centre.y + tall * 0.02 - floorLine) * rung
            )
            rungs.move(to: a)
            rungs.addLine(to: CGPoint(x: a.x + wide * 0.08, y: a.y - 1))
        }
        context.stroke(rungs, with: .color(timber.opacity(0.85)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    /// The floor of the fen: standing water in pools and laces between hags of drier peat,
    /// with the sky's little light lying on every pool. Nobody laid this out and nothing
    /// keeps it — the water table draws it fresh whenever it likes.
    private func drawFenPools(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 7_211)

        for _ in 0..<12 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: -0.1...1.1)) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 40...130))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.1,
                    width: spread, height: spread * 0.2
                )),
                with: .color(
                    Color(red: 0.10, green: 0.16, blue: 0.12).opacity(colors.isNight ? 0.5 : 0.38)
                )
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.28, y: centre.y - spread * 0.045,
                    width: spread * 0.56, height: spread * 0.09
                )),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.1))
            )
        }

        // The hags between, paler and an inch prouder.
        for _ in 0..<9 {
            let centre = CGPoint(
                x: CGFloat(scatter.next(in: -0.1...1.1)) * size.width,
                y: horizon + CGFloat(scatter.next()) * (size.height - horizon)
            )
            let spread = CGFloat(scatter.next(in: 40...110))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread * 0.5, y: centre.y - spread * 0.07,
                    width: spread, height: spread * 0.14
                )),
                with: .color(
                    Color(red: 0.42, green: 0.40, blue: 0.22).opacity(colors.isNight ? 0.1 : 0.2)
                )
            )
        }
    }

    /// The fen's horizon: no hills, no sea, no skyline — reeds going back until the haze has
    /// them, with dead snags standing up out of the beds and mist lying in a band along the
    /// bottom of the sky. The flattest horizon in the game, because a fen is where the ground
    /// gave up trying.
    private func drawFenTreeline(in context: inout GraphicsContext) {
        var scatter = Scatter(seed: 6_421)
        let base = horizon + 26

        // The far reed beds: one soft band, darker than the sky and lighter than the ground.
        var beds = Path()
        beds.move(to: CGPoint(x: -20, y: base - 18))
        beds.addQuadCurve(
            to: CGPoint(x: size.width + 20, y: base - 22),
            control: CGPoint(x: size.width * 0.5, y: base - 30)
        )
        beds.addLine(to: CGPoint(x: size.width + 20, y: base + 26))
        beds.addLine(to: CGPoint(x: -20, y: base + 30))
        beds.closeSubpath()
        context.fill(beds, with: .color(colors.farHill.opacity(0.9)))

        // Reed heads along the band's top edge, and the odd dead snag above them.
        var heads = Path()
        for _ in 0..<26 {
            let x = CGFloat(scatter.next()) * size.width
            let tall = CGFloat(scatter.next(in: 6...14))
            heads.move(to: CGPoint(x: x, y: base - 18))
            heads.addLine(to: CGPoint(x: x + CGFloat(scatter.next(in: -2...3)), y: base - 18 - tall))
        }
        context.stroke(
            heads,
            with: .color(colors.canopyShade.opacity(0.9)),
            style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
        )
        for _ in 0..<4 {
            let x = CGFloat(scatter.next()) * size.width
            let tall = CGFloat(scatter.next(in: 18...30))
            var snag = Path()
            snag.move(to: CGPoint(x: x, y: base - 16))
            snag.addLine(to: CGPoint(x: x + 2, y: base - 16 - tall))
            snag.move(to: CGPoint(x: x + 1, y: base - 16 - tall * 0.6))
            snag.addLine(to: CGPoint(x: x - tall * 0.3, y: base - 16 - tall * 0.8))
            context.stroke(
                snag,
                with: .color(colors.canopyShade),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )
        }

        // The mist, lying in a band across the foot of the sky — thicker after dark, when
        // the fen does its talking.
        context.fill(
            Path(CGRect(x: -20, y: base - 12, width: size.width + 40, height: 18)),
            with: .linearGradient(
                Gradient(colors: [
                    Color.white.opacity(0),
                    Color.white.opacity(colors.isNight ? 0.16 : 0.12),
                    Color.white.opacity(0)
                ]),
                startPoint: CGPoint(x: size.width / 2, y: base - 12),
                endPoint: CGPoint(x: size.width / 2, y: base + 6)
            )
        )
    }

    /// A reed bed at trailside size: a stand of tall stems with seed heads, higher than any
    /// grass on the map, because a reed is a blade that found water.
    private func drawReedBed(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        var stems = Path()
        var heads = Path()
        let tall = 30 * scale
        for (index, lean) in [-0.45, -0.2, 0.05, 0.3, 0.5].enumerated() {
            let height = tall * (0.72 + 0.07 * CGFloat(index % 3))
            let tip = CGPoint(x: foot.x + height * CGFloat(lean) * 0.4, y: foot.y - height)
            stems.move(to: CGPoint(x: foot.x + CGFloat(index - 2) * 2, y: foot.y))
            stems.addQuadCurve(
                to: tip,
                control: CGPoint(x: foot.x + height * CGFloat(lean) * 0.14, y: foot.y - height * 0.55)
            )
            heads.addEllipse(in: CGRect(x: tip.x - 1.4, y: tip.y - 6, width: 2.8, height: 7))
        }
        context.stroke(
            stems,
            with: .color(colors.canopyShade),
            style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
        )
        context.fill(
            heads,
            with: .color(Color(red: 0.48, green: 0.38, blue: 0.24).opacity(colors.isNight ? 0.6 : 0.9))
        )
    }

    /// A dead snag standing in the fields: a tree the bog got the roots of, silvered bare,
    /// with two arms and no leaf on either.
    private func drawDeadTree(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let tall = 34 * scale
        let silver = colors.isNight
            ? Color(red: 0.33, green: 0.35, blue: 0.32)
            : Color(red: 0.60, green: 0.60, blue: 0.54)

        shadow(in: &context, at: foot, width: tall * 0.5)
        var trunk = Path()
        trunk.move(to: foot)
        trunk.addQuadCurve(
            to: CGPoint(x: foot.x + tall * 0.08, y: foot.y - tall),
            control: CGPoint(x: foot.x - tall * 0.06, y: foot.y - tall * 0.5)
        )
        var arms = Path()
        arms.move(to: CGPoint(x: foot.x + tall * 0.02, y: foot.y - tall * 0.55))
        arms.addLine(to: CGPoint(x: foot.x - tall * 0.3, y: foot.y - tall * 0.8))
        arms.move(to: CGPoint(x: foot.x + tall * 0.05, y: foot.y - tall * 0.72))
        arms.addLine(to: CGPoint(x: foot.x + tall * 0.3, y: foot.y - tall * 0.92))
        context.stroke(trunk, with: .color(silver), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        context.stroke(arms, with: .color(silver.opacity(0.9)), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
    }

    /// A pool ringed with rushes: standing water at trailside size, with the sky's light on
    /// its middle and the rushes leaning over their own reflection.
    private func drawFenPool(in context: inout GraphicsContext, at foot: CGPoint, scale: CGFloat) {
        let wide = 42 * scale
        let pool = CGRect(x: foot.x - wide / 2, y: foot.y - wide * 0.11, width: wide, height: wide * 0.22)
        context.fill(
            Path(ellipseIn: pool),
            with: .color(Color(red: 0.10, green: 0.16, blue: 0.12).opacity(colors.isNight ? 0.6 : 0.5))
        )
        context.fill(
            Path(ellipseIn: pool.insetBy(dx: wide * 0.14, dy: wide * 0.05)),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.08 : 0.14))
        )
        var rushes = Path()
        for reed in [-0.42, -0.3, 0.34, 0.46] {
            let x = foot.x + wide * CGFloat(reed)
            let tall = wide * 0.3
            rushes.move(to: CGPoint(x: x, y: foot.y + wide * 0.02))
            rushes.addQuadCurve(
                to: CGPoint(x: x + wide * 0.05, y: foot.y - tall),
                control: CGPoint(x: x - wide * 0.03, y: foot.y - tall * 0.5)
            )
        }
        context.stroke(
            rushes,
            with: .color(colors.canopyShade),
            style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
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
