import Foundation
import SwiftUI
import UIKit

// MARK: - Cloudspire Heights, painted

/// Which side of a ring of neighbours is being painted: the half standing behind whoever is in
/// the middle of it, the half standing in front, or the lot in one go.
///
/// It exists so the pig can be drawn between the two halves of his own crowd. Painted in one
/// pass the ring goes down over him whichever way it is sorted, and twelve animals standing on
/// top of a pig is not a picture of a pig surrounded.
enum CloudspireRing: Hashable, Sendable {
    case whole
    case far
    case near
}

/// The heights' thirteen shots, and the nine brushes a world with no ground under it needs.
///
/// Every other world in the game is drawn from the horizon down: a sky, a ridge, a band of
/// something to stand on, and an animal stood on it. Up here the ridge is missing. The horizon
/// is the top of the weather — a sea of cloud with eleven worlds somewhere underneath it, out of
/// sight — and the only ground in any of these shots is the turf cap on the spire the camera
/// happens to be stood on, which runs out a little way either side of whoever is on it. That
/// drop is the whole drama of the world and it is in nearly every frame: the terrace narrows
/// away toward its far rim, both its flanks fall out of the picture, and the corners of the
/// frame under them are weather rather than land.
///
/// So the composition rules the wood taught still hold, upside down. A spire is drawn feet-first
/// and the cloud sea is laid over the bottom of it, exactly as the thicket lays leaf mould over
/// the feet of a rank of trees, because a rock with a visible flat bottom reads as a sticker
/// however good the rock is. Distance is still a colour: the far spires are the near ones with
/// the sky laid back over them. And nothing that matters goes where the words go — the foot of
/// the frame on the ten shots with a subtitle, the middle of it on the three that hand the film
/// over on a card, the last of which hands the whole game over.
extension Film {
    /// Every world's boss, in the order the pig met them, for the shots at the end of the last
    /// film that gather them round him.
    ///
    /// The same twelve glyphs the storybook version of this film rings round its motif, kept in
    /// the same order for the same reason: they arrive one at a time, and a cast list that
    /// arrives out of order is a crowd rather than a curtain call.
    static let cloudspireBosses = ["🦌", "🐗", "🐉", "🐀", "🛸", "🦇", "🤹", "🦂", "🦀", "🦭", "🐊", "🦅"]

    /// The heights' first two films are the clearest daylight in the game, and the last one is
    /// the darkest night in it — the only send-off in the game where dusk is not a hint about the
    /// next listing, because there is no next listing. It is just late.
    ///
    /// The one exception is the shot in the middle of that last film, which is not lit by this
    /// world at all. It is not this world: it is the meadow at daybreak, borrowed whole from the
    /// opening of the game, and it has to arrive in the light it was painted in or the ending is
    /// remembering somewhere it has never been.
    static func cloudspireLight(_ shot: CutScene.Picture.Cloudspire) -> GamePalette.Pasture {
        switch shot {
        case .theSpires, .rainbowsAndStorms, .offTheGround: .spireDay
        case .strictOversight, .theLineOfSight, .outOfSight: .spireDay
        case .whatHeWanted: .daybreak
        default: .spireDusk
        }
    }

    func drawCloudspire(_ shot: CutScene.Picture.Cloudspire, in context: inout GraphicsContext) {
        switch shot {
        case .theSpires: drawTheSpires(in: &context)
        case .rainbowsAndStorms: drawRainbowsAndStorms(in: &context)
        case .offTheGround: drawOffTheGround(in: &context)
        case .strictOversight: drawStrictOversight(in: &context)
        case .theLineOfSight: drawTheLineOfSight(in: &context)
        case .outOfSight: drawOutOfSight(in: &context)
        case .everyMarket: drawEveryMarket(in: &context)
        case .interestingNeighbors: drawInterestingNeighbors(in: &context)
        case .whatHeWanted: drawWhatHeWanted(in: &context)
        case .theBestPen: drawTheBestPen(in: &context)
        case .oneProblem: drawOneProblem(in: &context)
        case .wordOfMouth: drawWordOfMouth(in: &context)
        case .openHouse: drawOpenHouse(in: &context)
        }
    }

    // MARK: - The heights' opening

    /// The spires, seen from the rim of one of them: three away in the haze, one nearer with the
    /// sun on its turf, and the cloud sea lying over the feet of all four. The camera leans in a
    /// little, which on a terrace with nothing beyond it is as close to the edge as it wants to
    /// get.
    func drawTheSpires(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.62))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.18)), radius: x(0.07), rays: false)
        drawBirds(in: &shot, at: 0.26)

        // Feet first and the weather over them afterwards: the far three are the near one with
        // the sky laid back over the rock, which is the only thing that puts a spire miles off
        // rather than in the next field.
        drawCloudspireSpire(in: &shot, at: 0.14, top: 0.46, foot: 0.80, width: 0.09, haze: 0.62, seed: 1_009)
        drawCloudspireSpire(in: &shot, at: 0.33, top: 0.40, foot: 0.84, width: 0.11, haze: 0.48, seed: 1_013)
        drawCloudspireSpire(in: &shot, at: 0.87, top: 0.44, foot: 0.82, width: 0.10, haze: 0.55, seed: 1_019)
        drawCloudspireSpire(in: &shot, at: 0.64, top: 0.36, foot: 0.88, width: 0.15, haze: 0.22, seed: 1_021)
        drawCloudspireSea(in: &shot, at: 0.66, drift: 0.012 * progress, seed: 1_031)

        // The terrace the camera is stood on, and the pig out at the rim of it looking at all of
        // the above: the endless views, and the property line they start at.
        drawCloudspireTerrace(in: &shot, rim: 0.74, spread: 0.76, seed: 1_033)
        drawCloudspirePines(
            in: &shot, along: 0.755, from: 0.24, to: 0.72,
            count: 4, height: 0.05, lean: 0.28, seed: 1_039
        )
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.42), y: y(0.84)),
            width: x(0.16),
            lean: 3,
            squash: 1 - 0.03 * hop(cycles: 2)
        )

        drawCloudspireWind(in: &shot, count: 5, seed: 1_049)
    }

    /// The two halves of the scoring rule, one after the other on the same terrace: the rainbow
    /// while the line is selling it as instant appeal, and then the storm while the line is
    /// admitting what it does to the place.
    ///
    /// The same crossover every world's second shot makes, timed to the same beat — the first
    /// sentence gone, the second not yet up — and given one extra job here, because on the
    /// heights the weather is the hazard rather than something lying in the grass. So the light
    /// goes out of the whole frame as it turns, and not only off the glyph: the sun's halo dies,
    /// a grey wash comes over the lot, and the cloud sea underneath stops being scenery.
    func drawRainbowsAndStorms(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the amenity to the drawback.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.54))
        var lit = shot
        lit.opacity = 1 - turn
        drawSun(in: &lit, at: CGPoint(x: x(0.72), y: y(0.20)), radius: x(0.075), rays: false)

        drawCloudspireSpire(in: &shot, at: 0.20, top: 0.42, foot: 0.76, width: 0.10, haze: 0.55, seed: 1_051)
        drawCloudspireSpire(in: &shot, at: 0.84, top: 0.38, foot: 0.78, width: 0.12, haze: 0.45, seed: 1_061)
        drawCloudspireSea(in: &shot, at: 0.60, drift: 0.01 * progress, seed: 1_063)
        drawCloudspireTerrace(in: &shot, rim: 0.68, spread: 0.82, seed: 1_069)

        // Leaning at what is being sold and away from what is being admitted, which is the only
        // opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.27), y: y(0.82)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        // The amenity, in its own light with a bow standing over it.
        let spot = CGPoint(x: x(0.64), y: y(0.80))
        var amenity = shot
        amenity.opacity = 1 - turn
        drawCloudspireBow(
            in: &amenity,
            centre: CGPoint(x: spot.x, y: spot.y + x(0.10)),
            radius: x(0.32),
            opacity: 0.5
        )
        amenity.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.34), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &amenity, "🌈", at: spot, width: x(0.22))

        // And the drawback, in the same spot with the weather over the whole frame rather than
        // over the glyph alone.
        var drawback = shot
        drawback.opacity = turn
        drawback.fill(
            Path(CGRect(x: -size.width, y: -size.height, width: size.width * 3, height: size.height * 3)),
            with: .color(Color(red: 0.24, green: 0.26, blue: 0.32).opacity(0.4))
        )
        drawTreat(in: &drawback, "🌩️", at: spot, width: x(0.22))

        drawCloudspireWind(in: &shot, count: 6, seed: 1_087)
    }

    /// One pinnacle with the pig on the top of it, a bow over the whole frame and nothing under
    /// any of it: the property search, off the ground.
    ///
    /// The camera pulls back rather than pushing in, because the joke of the card is how little
    /// there is left to stand on, and the way to say that is to show more sky rather than more
    /// pig. Everything else is kept low, and the bow is struck from so far below the frame that
    /// all that shows of it is a shallow arch across the top — in at both sides well above where
    /// the card sets its line, and clear of it the whole way over.
    func drawOffTheGround(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.20 - 0.13 * progress)

        drawSky(in: &shot, horizon: y(0.84))
        // A centre below the bottom of the picture and a radius wider than the picture: what
        // shows is the crown of an arch far too big to fit, which is the only way a bow gets
        // into a card shot without lying across the words.
        drawCloudspireBow(
            in: &shot,
            centre: CGPoint(x: x(0.5), y: y(0.95)),
            radius: x(1.36),
            opacity: 0.38
        )

        // A needle rather than a table: no room on it for anything but the buyer.
        drawCloudspireSpire(in: &shot, at: 0.50, top: 0.72, foot: 0.98, width: 0.07, haze: 0, seed: 1_091)
        drawCloudspireSea(in: &shot, at: 0.88, drift: 0.02 * progress, seed: 1_093)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.50), y: y(0.715)),
            width: x(0.13),
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.4
        )

        drawCloudspireWind(in: &shot, count: 7, seed: 1_097)
    }

    // MARK: - The Eyrie

    /// The eagle coming down onto the needle that stands over the pig's terrace, and the pig
    /// looking up at it. Eleven neighbours have walked into their briefings from the side of the
    /// frame; this one drops in from the top of it, and does not come the rest of the way down.
    func drawStrictOversight(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.012 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.26)), radius: x(0.06), rays: false)

        // The perch: tall, thin, and unclimbable, which is the whole of the neighbour's position.
        drawCloudspireSpire(in: &shot, at: 0.30, top: 0.46, foot: 0.74, width: 0.09, haze: 0.5, seed: 1_103)
        drawCloudspireSpire(in: &shot, at: 0.68, top: 0.28, foot: 0.86, width: 0.06, haze: 0, seed: 1_109)
        drawCloudspireSea(in: &shot, at: 0.62, drift: 0.008 * progress, seed: 1_117)
        drawCloudspireTerrace(in: &shot, rim: 0.72, spread: 0.8, seed: 1_123)

        // In from over the top of the frame and settling: the arrival is done well before the
        // caption is, so the shot holds on a landed bird rather than on a falling one.
        let landing = easeOut(min(progress / 0.7, 1))
        drawAnimal(
            in: &shot,
            .eagle,
            feet: CGPoint(x: x(0.68), y: y(0.10 + 0.17 * landing)),
            width: x(0.17),
            lean: 6 - 6 * landing,
            shadow: 0.3 * landing
        )

        // Small, on his own turf, and craning. The neighbour is a good deal higher up than the
        // property, which is the point of the picture and of the neighbourhood. Set well up the
        // terrace: this caption runs to two lines, and two lines reach a good deal further up the
        // frame than the one line the 0.84 mark was measured against.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.30), y: y(0.795)),
            width: x(0.16),
            lean: -7
        )

        drawCloudspireWind(in: &shot, count: 5, seed: 1_129)
    }

    /// The rule, coming out of the bird: four lines of sight opening off the perch to the edges
    /// of the frame in the order the caption names them — above, below, then both ways beside.
    ///
    /// The pig is put directly under the perch rather than off to one side, so the second line
    /// out is the one that lands on him: the first thing the rule is demonstrated on is the
    /// buyer. That line goes down through the cloud sea and out of the bottom of the picture
    /// rather than stopping anywhere, because what the board means by the eagle's line of sight
    /// is that it crosses open air exactly as happily as it crosses ground.
    func drawTheLineOfSight(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.60))
        drawCloudspireSpire(in: &shot, at: 0.15, top: 0.50, foot: 0.78, width: 0.09, haze: 0.6, seed: 1_151)
        drawCloudspireSpire(in: &shot, at: 0.52, top: 0.34, foot: 0.86, width: 0.07, haze: 0, seed: 1_153)
        drawCloudspireSea(in: &shot, at: 0.66, drift: 0.006 * progress, seed: 1_163)
        drawCloudspireTerrace(in: &shot, rim: 0.74, spread: 0.86, seed: 1_171)

        // Staggered in the caption's own order, and every one of them at least half open by the
        // middle of the shot, since that is the whole of the picture a player who asked for less
        // motion will ever see.
        let perch = CGPoint(x: x(0.52), y: y(0.34))
        func opened(after start: Double) -> Double {
            easeOut(min(max((progress - start) / 0.34, 0), 1))
        }
        drawCloudspireGaze(
            in: &shot,
            from: perch,
            up: opened(after: 0.02),
            down: opened(after: 0.14),
            left: opened(after: 0.26),
            right: opened(after: 0.26),
            opacity: 0.9
        )

        drawAnimal(in: &shot, .eagle, feet: perch, width: x(0.15), shadow: 0)

        // Stood in the downward line and thoroughly lit by it, with nowhere on the terrace to
        // step that is not somebody's row or somebody's column.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.52), y: y(0.80)),
            width: x(0.15),
            lean: -3
        )

        drawCloudspireWind(in: &shot, count: 4, seed: 1_181)
    }

    /// The rule as a floor plan: the perch up in one corner with both its lines ruled the whole
    /// way across the frame, and a ghost pen opening round the pig down in the quarter that
    /// neither line reaches.
    ///
    /// The lines are drawn faint here where they were bright in the shot before, because this one
    /// is a diagram with a long line of words across the middle of it and the gaze has already
    /// been established. What the card has to say is not *look how far he can see* — it is *the
    /// pen goes here, and here is everywhere it cannot go*.
    func drawOutOfSight(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        drawCloudspireSpire(in: &shot, at: 0.84, top: 0.24, foot: 0.72, width: 0.055, haze: 0, seed: 1_187)
        drawCloudspireSea(in: &shot, at: 0.56, drift: 0.006 * progress, seed: 1_193)
        drawCloudspireTerrace(in: &shot, rim: 0.64, spread: 0.9, seed: 1_201)

        // Further into the corner than the shot before it, so the downward line runs off the
        // margin rather than down the middle of a three-sentence card, and strong enough that the
        // thing the card is about is actually visible.
        let perch = CGPoint(x: x(0.84), y: y(0.22))
        drawCloudspireGaze(in: &shot, from: perch, up: 1, down: 1, left: 1, right: 1, opacity: 0.6)
        drawAnimal(in: &shot, .eagle, feet: perch, width: x(0.12), shadow: 0)

        // Low, left, and short of both lines by a clear margin. A pen that only just misses the
        // gaze is a pen a player has to measure; this one has to be read at a glance.
        let pig = CGPoint(x: x(0.34), y: y(0.82))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawGhostPen(
            in: &shot,
            round: pig,
            width: 0.44,
            height: 0.12,
            drop: 0.014,
            opacity: 0.9 * easeOut(min(progress / 0.8, 1))
        )

        drawCloudspireWind(in: &shot, count: 4, seed: 1_213)
    }

    // MARK: - The heights held, and the end of the game

    /// The whole tour in one frame: the pig on the highest turf there is at nightfall, with a
    /// rank of spires standing away into the dark behind him, hazed down until the furthest are
    /// barely a colour. Twelve markets, and the last of them is the one he is stood on.
    func drawEveryMarket(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.66))
        drawCloudspireStars(in: &shot, count: 34, seed: 1_217)
        // The disc at this hour is the moon, and up here nothing at all is in front of it.
        drawSun(in: &shot, at: CGPoint(x: x(0.24), y: y(0.16)), radius: x(0.055), rays: false)

        // A crowd of them, thinning into the distance rather than three obvious ones: what the
        // shot is counting is how many places the pig has been.
        var scatter = Scatter(seed: 1_223)
        for index in 0..<11 {
            let along = (Double(index) + 0.2 + scatter.next() * 0.6) / 11
            drawCloudspireSpire(
                in: &shot,
                at: along,
                top: 0.40 + scatter.next() * 0.14,
                foot: 0.80,
                width: 0.05 + scatter.next() * 0.06,
                haze: 0.32 + scatter.next() * 0.4,
                seed: 1_229 &+ UInt64(index)
            )
        }
        drawCloudspireSea(in: &shot, at: 0.68, drift: 0.01 * progress, seed: 1_231)

        drawCloudspireTerrace(in: &shot, rim: 0.76, spread: 0.78, seed: 1_237)
        drawCloudspirePines(
            in: &shot, along: 0.775, from: 0.62, to: 0.86,
            count: 3, height: 0.05, lean: 0.3, seed: 1_249
        )

        // Facing out, small, and finished. Nothing in this shot is being sold to him.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.40), y: y(0.80)), width: x(0.16), lean: -2)

        drawCloudspireWind(in: &shot, count: 5, seed: 1_259)
    }

    /// The cast list, taken as a photograph: every boss the game has, ringed round the pig on the
    /// terrace and arriving one at a time in the order he met them — the stag from the meadow
    /// first and the eagle overhead last.
    ///
    /// The ring is set wide and its centre is put well above the pig's feet, so the near half of
    /// it lands on turf in front of him and the far half stands behind him without a single glyph
    /// getting down into the words.
    func drawInterestingNeighbors(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.60))
        drawCloudspireStars(in: &shot, count: 28, seed: 1_277)
        // Kept out of the top right corner, where the Skip button lives: a moon's halo behind
        // the one piece of chrome on the screen reads as a blown highlight rather than as a moon.
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.15)), radius: x(0.05), rays: false)
        drawCloudspireSpire(in: &shot, at: 0.12, top: 0.44, foot: 0.74, width: 0.08, haze: 0.5, seed: 1_279)
        drawCloudspireSea(in: &shot, at: 0.62, drift: 0.008 * progress, seed: 1_283)
        drawCloudspireTerrace(in: &shot, rim: 0.68, spread: 0.94, seed: 1_289)

        // The ring is struck on the pig's own feet and flattened hard, so every one of them is
        // standing on the turf. It was set high and open before, and the far half of it came out
        // stood in the cloud sea beyond the rim — a stag hanging in mid-air off the front of the
        // property, which is a different film.
        let pig = CGPoint(x: x(0.50), y: y(0.755))
        drawCloudspireGathering(
            in: &shot,
            round: pig,
            radius: x(0.34),
            squash: 0.28,
            glyph: x(0.10),
            settled: 0,
            part: .far
        )
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawCloudspireGathering(
            in: &shot,
            round: pig,
            radius: x(0.34),
            squash: 0.28,
            glyph: x(0.10),
            settled: 0,
            part: .near
        )
    }

    /// The poky farm pen from the very first shot of the very first film, and not a line of it
    /// painted here.
    ///
    /// The whole point of the shot is that it is the same picture, so it is the same picture: the
    /// meadow's own opening frame, drawn by the meadow's own brush, in the meadow's own daybreak.
    /// Repainting it in this file would produce something that looked very like the pen the pig
    /// started in, which is exactly what a memory must not be — a shot that recalls the first
    /// frame of the game has to *be* the first frame of the game, down to the barn on the hill
    /// and the bob of the pig on the rail, or the ending is remembering it wrong.
    func drawWhatHeWanted(in context: inout GraphicsContext) {
        drawMeadow(.homePen, in: &context)
    }

    /// The same pen, rebuilt on top of a spire and measured off the shot before it: the identical
    /// rectangle, the same drop, the pig the same size in it — and around it the emptiest lot in
    /// the game, with apples staked on the turf outside.
    ///
    /// It is the film's flattest joke and its best one. Twelve markets, a hundred and eight
    /// puzzles and every rule the game has, to arrive at the floor plan he was given for nothing
    /// on the first morning. The pen is deliberately tiny against the terrace, because *plenty of
    /// space* is the one line in the caption the picture is allowed to disagree with.
    func drawTheBestPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawCloudspireStars(in: &shot, count: 30, seed: 1_291)
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.17)), radius: x(0.055), rays: false)
        drawCloudspireSpire(in: &shot, at: 0.16, top: 0.42, foot: 0.72, width: 0.09, haze: 0.5, seed: 1_297)
        drawCloudspireSpire(in: &shot, at: 0.88, top: 0.46, foot: 0.72, width: 0.07, haze: 0.58, seed: 1_301)
        drawCloudspireSea(in: &shot, at: 0.58, drift: 0.008 * progress, seed: 1_303)
        drawCloudspireTerrace(in: &shot, rim: 0.66, spread: 0.92, seed: 1_307)

        // The first pen's own measurements, kept to the digit: 0.30 across, 0.15 down, dropped
        // 0.012 below his feet. Anything else here would be a different pen.
        let bob = hop(cycles: 2)
        let pig = CGPoint(x: x(0.44), y: y(0.83) - y(0.01 * bob))
        drawPenWash(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.74), y: y(0.80)), width: x(0.07))
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.20), y: y(0.845)), width: x(0.065))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.17), lean: 4, squash: 1 - 0.03 * bob)
        drawPenFence(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)

        drawCloudspireWind(in: &shot, count: 4, seed: 1_319)
    }

    /// The neighbours arriving over the rim of the terrace, all round, one at a time. The caption
    /// says there was one problem; the picture counts twelve of them, which is the joke, and the
    /// ring is set out at the edge of the turf so they read as coming rather than as gathered.
    func drawOneProblem(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawCloudspireStars(in: &shot, count: 26, seed: 1_321)
        drawCloudspireSea(in: &shot, at: 0.58, drift: 0.006 * progress, seed: 1_327)
        // A rim set well above the pen's far rail, so there is turf between the fence and the
        // drop for the back of the crowd to be standing on.
        drawCloudspireTerrace(in: &shot, rim: 0.635, spread: 0.96, seed: 1_361)

        let pig = CGPoint(x: x(0.50), y: y(0.80))
        drawPenWash(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16), lean: -4)
        drawPenFence(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)

        drawCloudspireGathering(
            in: &shot,
            round: CGPoint(x: x(0.50), y: y(0.755)),
            radius: x(0.44),
            squash: 0.30,
            glyph: x(0.09),
            settled: 0
        )
    }

    /// The same crowd, nearer: the ring drawn in and the camera pushing after it, which between
    /// them turn a gathering into a queue at a door. Everybody is already here by the time the
    /// line about word of mouth is read, because the line is an explanation rather than news.
    func drawWordOfMouth(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.07 * progress)

        drawSky(in: &shot, horizon: y(0.56))
        drawCloudspireStars(in: &shot, count: 24, seed: 1_367)
        drawCloudspireSea(in: &shot, at: 0.56, drift: 0.005 * progress, seed: 1_373)
        drawCloudspireTerrace(in: &shot, rim: 0.64, spread: 0.98, seed: 1_381)

        let pig = CGPoint(x: x(0.50), y: y(0.80))
        drawPenWash(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        drawPenFence(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)

        // Two thirds of them are up before the shot starts: this is the middle of an arrival
        // rather than the beginning of one.
        drawCloudspireGathering(
            in: &shot,
            round: CGPoint(x: x(0.50), y: y(0.745)),
            radius: x(0.38),
            squash: 0.36,
            glyph: x(0.095),
            settled: 0.66
        )
    }

    /// The last frame of the game: the pen full of everybody the pig has ever met, him somewhere
    /// underneath it all, and the entire night sky left empty above for the line to land in.
    ///
    /// The ring is drawn tighter than the pen it is standing round, so the crowd is inside the
    /// fence rather than politely outside it, and the pig is squashed down among them and lit by
    /// nothing. Everything sits in the bottom third; the middle of the frame — where the card
    /// sets *Open house was a mistake* across the whole width — is stars.
    func drawOpenHouse(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.02 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.66))
        drawCloudspireStars(in: &shot, count: 40, seed: 1_399)
        drawSun(in: &shot, at: CGPoint(x: x(0.26), y: y(0.15)), radius: x(0.05), rays: false)
        drawCloudspireSea(in: &shot, at: 0.60, drift: 0.004 * progress, seed: 1_409)
        drawCloudspireTerrace(in: &shot, rim: 0.68, spread: 0.98, seed: 1_423)

        let pig = CGPoint(x: x(0.50), y: y(0.84))
        drawPenWash(in: &shot, round: pig, width: 0.62, height: 0.16, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.14), squash: 1.08, shadow: 0.5)
        drawPenFence(in: &shot, round: pig, width: 0.62, height: 0.16, drop: 0.012)

        // Everybody, and the last of them still landing as the game fades out.
        drawCloudspireGathering(
            in: &shot,
            round: CGPoint(x: x(0.50), y: y(0.795)),
            radius: x(0.34),
            squash: 0.42,
            glyph: x(0.105),
            settled: 0.8
        )
    }

    // MARK: - What the heights are made of

    /// The horizon of the twelfth world, which is weather rather than land: two banks of cloud
    /// tops filled all the way down past the bottom of the frame, the far one higher and paler,
    /// with a lobed crest that never repeats and a lip of light along it.
    ///
    /// It is the thicket's canopy stood on its head and used for the opposite job. A wood hangs
    /// leaf mass into the top of a frame to say *you cannot see out*; a spire top lays cloud
    /// across the bottom of one to say *there is no floor* — so it is filled downward and carried
    /// well outside the frame in every direction, and everything that stands in it is drawn
    /// first, so the weather laps over the feet of it.
    func drawCloudspireSea(in context: inout GraphicsContext, at height: Double, drift: Double, seed: UInt64) {
        let start = -size.width
        let end = size.width * 2
        let step = x(0.075)
        let floor = size.height * 2
        // What the deck goes to underneath the lit crest. A cloud sea is only white along the tops
        // it is turning to the sun; everything below that is in the shadow of the tops above it,
        // and without this the bottom third of every daylight shot came out as blank paper.
        let deep = colors.isNight
            ? Color(red: 0.14, green: 0.17, blue: 0.26)
            : Color(red: 0.70, green: 0.77, blue: 0.86)
        let middling = colors.isNight
            ? Color(red: 0.22, green: 0.26, blue: 0.36)
            : Color(red: 0.86, green: 0.90, blue: 0.95)

        // Three ranks of tops falling away one behind the other, furthest and dimmest first. One
        // lobed edge with a flat fill under it is an edge; three of them stacked is a mile of
        // weather, which is what has to be under a spire for the drop to mean anything.
        for rank in 0..<3 {
            var scatter = Scatter(seed: seed &+ UInt64(rank * 41))
            let level = y(height) + y(0.055) * CGFloat(rank)
            let shift = x(drift) * CGFloat(1 + Double(rank) * 0.5)
            let lobe = y(0.020) * CGFloat(1 + Double(rank) * 0.22)

            var bank = Path()
            bank.addRect(CGRect(x: start, y: level, width: end - start, height: floor))
            var across = start
            while across < end {
                let swell = lobe * CGFloat(0.6 + scatter.next() * 1.1)
                let wide = step * CGFloat(1.1 + scatter.next() * 0.8)
                bank.addEllipse(in: CGRect(
                    x: across - wide / 2 + shift, y: level - swell,
                    width: wide, height: swell * 2.1
                ))
                across += step
            }

            if rank < 2 {
                context.fill(bank, with: .color(rank == 0 ? deep : middling))
            } else {
                // The near rank carries the light, and falls away under itself rather than
                // sitting there as one flat tone all the way to the bottom of the frame.
                context.fill(
                    bank,
                    with: .linearGradient(
                        Gradient(colors: [colors.cloud, deep]),
                        startPoint: CGPoint(x: 0, y: level),
                        endPoint: CGPoint(x: 0, y: level + y(0.30))
                    )
                )
            }
        }

        // The lip: the sun, or the moon, catching the very top of the near rank.
        var scatter = Scatter(seed: seed &+ 7)
        var crest = Path()
        var across = start
        while across < end {
            let wide = step * CGFloat(0.9 + scatter.next() * 0.7)
            crest.addEllipse(in: CGRect(
                x: across - wide / 2 + x(drift) * 2, y: y(height) + y(0.11) - y(0.012),
                width: wide, height: y(0.016)
            ))
            across += step
        }
        context.fill(crest, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.16 : 0.55)))
    }

    /// A spire standing out of the weather: a rock shaft splaying as it falls, two faces meeting
    /// on a ridge that runs down off the summit, and a cap of turf sitting on the top of it.
    ///
    /// Two faces rather than one tapered shape with a wash over half of it, for the reason the
    /// thicket's mountain has two: the fold is what the eye reads as rock, and a flat silhouette
    /// with a highlight on it stays a flat silhouette. `foot` is meant to be buried — the cloud
    /// sea is drawn afterwards and laps over the bottom of the shaft, so a spire stands *in* the
    /// weather rather than on top of it. `haze` lays the sky back over the finished rock, which
    /// is what puts a spire a mile off instead of an arm's length away; the whole receding rank
    /// in the last film's opening shot is the same brush at eight different strengths.
    func drawCloudspireSpire(
        in context: inout GraphicsContext,
        at across: Double,
        top: Double,
        foot: Double,
        width: Double,
        haze: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let centre = x(across)
        let crown = y(top)
        let base = y(foot)
        let halfTop = x(width) * 0.5
        // Wider at the bottom, and never symmetrically so: a spire that tapers evenly reads as a
        // chess piece.
        let halfBase = halfTop * CGFloat(1.7 + scatter.next() * 0.9)
        let ridgeTop = centre + halfTop * CGFloat(0.1 + scatter.next() * 0.4)
        let ridgeBase = centre + halfBase * CGFloat(0.05 + scatter.next() * 0.25)
        let lit = colors.isNight
            ? Color(red: 0.20, green: 0.23, blue: 0.31)
            : Color(red: 0.68, green: 0.65, blue: 0.63)
        let shade = colors.isNight
            ? Color(red: 0.10, green: 0.12, blue: 0.18)
            : Color(red: 0.46, green: 0.44, blue: 0.47)

        var near = Path()
        near.move(to: CGPoint(x: centre - halfBase, y: base))
        near.addQuadCurve(
            to: CGPoint(x: centre - halfTop, y: crown),
            control: CGPoint(x: centre - halfBase * 0.72, y: crown + (base - crown) * 0.5)
        )
        near.addLine(to: CGPoint(x: ridgeTop, y: crown))
        near.addLine(to: CGPoint(x: ridgeBase, y: base))
        near.closeSubpath()
        context.fill(near, with: .color(lit))

        var far = Path()
        far.move(to: CGPoint(x: ridgeBase, y: base))
        far.addLine(to: CGPoint(x: ridgeTop, y: crown))
        far.addLine(to: CGPoint(x: centre + halfTop, y: crown))
        far.addQuadCurve(
            to: CGPoint(x: centre + halfBase, y: base),
            control: CGPoint(x: centre + halfBase * 0.74, y: crown + (base - crown) * 0.5)
        )
        far.closeSubpath()
        context.fill(far, with: .color(shade))

        // The turf: the underside first and a shade lower, then the top of it over that, so the
        // cap sits on the rock rather than being painted across the end of it.
        let capWide = halfTop * 2.6
        let capTall = halfTop * 0.62
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre - capWide / 2, y: crown - capTall * 0.2,
                width: capWide, height: capTall
            )),
            with: .color(colors.foreground)
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre - capWide * 0.46, y: crown - capTall * 0.7,
                width: capWide * 0.92, height: capTall
            )),
            with: .color(colors.ground)
        )

        // The air between here and there, laid back over the lot of it — over the rock and over
        // the turf, but over nothing else. This used to be one path with an ellipse on top of it
        // that reached wider than the cap did, and every hazed spire in the world came out
        // wearing a pale lozenge in the sky above its head.
        guard haze > 0 else { return }
        var shaft = Path()
        shaft.move(to: CGPoint(x: centre - halfBase, y: base))
        shaft.addQuadCurve(
            to: CGPoint(x: centre - halfTop, y: crown),
            control: CGPoint(x: centre - halfBase * 0.72, y: crown + (base - crown) * 0.5)
        )
        shaft.addLine(to: CGPoint(x: centre + halfTop, y: crown))
        shaft.addQuadCurve(
            to: CGPoint(x: centre + halfBase, y: base),
            control: CGPoint(x: centre + halfBase * 0.74, y: crown + (base - crown) * 0.5)
        )
        shaft.closeSubpath()
        shaft.addEllipse(in: CGRect(
            x: centre - capWide / 2, y: crown - capTall * 0.2,
            width: capWide, height: capTall
        ))
        shaft.addEllipse(in: CGRect(
            x: centre - capWide * 0.46, y: crown - capTall * 0.7,
            width: capWide * 0.92, height: capTall
        ))
        context.fill(shaft, with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// The ground the camera is standing on: the turf cap of a spire, seen from just above it.
    ///
    /// It is the one shape in this world that does the job a `drawLand` band does everywhere
    /// else, and it is drawn differently on purpose. A band of ground runs out of both sides of
    /// the frame and says *there is more of this*. A terrace does the opposite: its far rim is an
    /// arc across the middle distance, its flanks fall away inside the frame, and the corners of
    /// the picture underneath them are weather. `spread` is how much of the far rim you can see —
    /// turn it up and the drop moves out to the edges of the frame, turn it down and the pig is
    /// stood on a ledge.
    ///
    /// The wind-combing on it is the same wind the boards get: long shallow strokes all bowed one
    /// way, because they are one wind's work and not many, with bared rock showing through in
    /// scoured bars where the turf gave up.
    func drawCloudspireTerrace(
        in context: inout GraphicsContext,
        rim: Double,
        spread: Double,
        seed: UInt64
    ) {
        let level = y(rim)
        let left = x(0.5 - spread / 2)
        let right = x(0.5 + spread / 2)
        let floor = size.height * 2

        var turf = Path()
        turf.move(to: CGPoint(x: left, y: level))
        // The far rim bows away from the camera, which is what makes the top of a spire read as
        // a dome of turf rather than as a shelf sawn level.
        turf.addQuadCurve(
            to: CGPoint(x: right, y: level),
            control: CGPoint(x: x(0.5), y: level - y(0.022))
        )
        turf.addCurve(
            to: CGPoint(x: size.width * 1.12, y: floor),
            control1: CGPoint(x: right + x(0.06), y: level + y(0.06)),
            control2: CGPoint(x: size.width * 1.05, y: level + y(0.22))
        )
        turf.addLine(to: CGPoint(x: -size.width * 0.12, y: floor))
        turf.addCurve(
            to: CGPoint(x: left, y: level),
            control1: CGPoint(x: -size.width * 0.05, y: level + y(0.22)),
            control2: CGPoint(x: left - x(0.06), y: level + y(0.06))
        )
        turf.closeSubpath()
        context.fill(turf, with: .color(colors.ground))

        // Where the turf rolls over the edge and becomes rock, shaded into the ground rather than
        // ruled round it. This was an outline once, and an outline round a shape is a sticker on
        // a picture however good the shape is — the terrace came out reading as a green tablet
        // laid on the sky. Shading the two flanks instead lets the ground curve away over its own
        // edge, which is the only thing that has ever said *there is nothing under that side*.
        let rock = colors.isNight
            ? Color(red: 0.07, green: 0.09, blue: 0.14)
            : Color(red: 0.44, green: 0.43, blue: 0.42)
        var flanks = context
        flanks.clip(to: turf)
        let reach = x(0.26)
        for side in [0.0, 1.0] {
            let edge = side > 0 ? size.width : CGFloat(0)
            let inward = side > 0 ? size.width - reach : reach
            flanks.fill(
                Path(CGRect(x: min(edge, inward), y: level - y(0.05), width: reach, height: floor)),
                with: .linearGradient(
                    Gradient(colors: [rock.opacity(0.62), rock.opacity(0)]),
                    startPoint: CGPoint(x: edge, y: 0),
                    endPoint: CGPoint(x: inward, y: 0)
                )
            )
        }

        // The light on the rim itself, which is the line that says the far edge is an edge.
        var edge = Path()
        edge.move(to: CGPoint(x: left, y: level))
        edge.addQuadCurve(
            to: CGPoint(x: right, y: level),
            control: CGPoint(x: x(0.5), y: level - y(0.022))
        )
        context.stroke(
            edge,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.14 : 0.34)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.005)), lineCap: .round)
        )

        var scatter = Scatter(seed: seed)
        var bars = Path()
        for _ in 0..<5 {
            let spot = CGPoint(x: x(scatter.next(in: 0.1...0.9)), y: y(rim + scatter.next(in: 0.02...0.2)))
            let wide = x(scatter.next(in: 0.10...0.24))
            bars.addEllipse(in: CGRect(
                x: spot.x - wide / 2, y: spot.y - wide * 0.06,
                width: wide, height: wide * 0.12
            ))
        }
        context.fill(
            bars,
            with: .color(Color(red: 0.62, green: 0.63, blue: 0.58).opacity(colors.isNight ? 0.12 : 0.22))
        )

        var combing = Path()
        for _ in 0..<14 {
            let down = y(rim + scatter.next(in: 0.015...0.24))
            let from = x(scatter.next(in: -0.05...0.85))
            let run = x(scatter.next(in: 0.08...0.2))
            combing.move(to: CGPoint(x: from, y: down))
            combing.addQuadCurve(
                to: CGPoint(x: from + run, y: down - y(scatter.next(in: 0.004...0.012))),
                control: CGPoint(x: from + run * 0.5, y: down + y(0.008))
            )
        }
        context.stroke(
            combing,
            with: .color(colors.blade.opacity(colors.isNight ? 0.5 : 0.7)),
            style: StrokeStyle(lineWidth: max(1, y(0.003)), lineCap: .round)
        )
    }

    /// Pines along a rim, all leaning the same way and none of them upright.
    ///
    /// The thicket's `drawForest` would do this in one line and would be wrong: its crowns are
    /// symmetrical, which is exactly what a tree that has spent its life in a wind that never
    /// drops is not. These are built as three tiers stacked up a leaning trunk, each tier
    /// dragged downwind of the one below, so the rank reads as bent rather than as a row of
    /// little Christmas trees on a hill.
    func drawCloudspirePines(
        in context: inout GraphicsContext,
        along baseline: Double,
        from: Double,
        to: Double,
        count: Int,
        height: Double,
        lean: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for index in 0..<count {
            let along = from + (to - from) * (Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)
            let foot = CGPoint(x: x(along), y: y(baseline + scatter.next(in: -0.006...0.012)))
            let tall = y(height) * CGFloat(0.7 + scatter.next() * 0.6)
            let drag = x(lean) * CGFloat(0.6 + scatter.next() * 0.8)
            // Broad boughs on a thin stem. They were the other way round and photographed as dead
            // twigs lying on the rim: on a tree this small the needles are the whole silhouette
            // and the trunk is only what holds them up.
            let wide = tall * 0.58

            var trunk = Path()
            trunk.move(to: CGPoint(x: foot.x - tall * 0.04, y: foot.y))
            trunk.addQuadCurve(
                to: CGPoint(x: foot.x + drag * 0.7, y: foot.y - tall * 0.9),
                control: CGPoint(x: foot.x + drag * 0.1, y: foot.y - tall * 0.5)
            )
            context.stroke(
                trunk,
                with: .color(GamePalette.post.opacity(colors.isNight ? 0.7 : 0.9)),
                style: StrokeStyle(lineWidth: max(1, tall * 0.055), lineCap: .round)
            )

            var boughs = Path()
            for tier in 0..<3 {
                let up = tall * CGFloat(0.30 + Double(tier) * 0.27)
                let side = drag * CGFloat(0.18 + Double(tier) * 0.30)
                let span = wide * CGFloat(1 - Double(tier) * 0.20)
                let hub = CGPoint(x: foot.x + side, y: foot.y - up)
                // Wide where it leaves the trunk and drawn out to a point on the lee side, which
                // is the shape a conifer in a wind that never drops actually takes.
                boughs.move(to: CGPoint(x: hub.x - span * 0.55, y: hub.y + span * 0.30))
                boughs.addQuadCurve(
                    to: CGPoint(x: hub.x + span * 1.15, y: hub.y - span * 0.06),
                    control: CGPoint(x: hub.x + span * 0.10, y: hub.y - span * 0.78)
                )
                boughs.addQuadCurve(
                    to: CGPoint(x: hub.x - span * 0.55, y: hub.y + span * 0.30),
                    control: CGPoint(x: hub.x + span * 0.16, y: hub.y + span * 0.36)
                )
                boughs.closeSubpath()
            }
            context.fill(boughs, with: .color(colors.canopyShade))
        }
    }

    /// The eagle's four lines of sight: two rules crossed on his perch, run out to the edges of
    /// the frame, each one opening from nothing to its full reach as its share of the shot comes
    /// round.
    ///
    /// Drawn as a wedge with a bright thread down the middle of it rather than as a stroked line,
    /// because a line ruled across a picture reads as a border on the picture, and a beam that
    /// widens as it goes reads as something coming out of the bird. Each arm is carried a good
    /// deal past the frame so no camera move ever finds the end of one — the whole rule is that
    /// it does not end.
    func drawCloudspireGaze(
        in context: inout GraphicsContext,
        from perch: CGPoint,
        up: Double,
        down: Double,
        left: Double,
        right: Double,
        opacity: Double
    ) {
        let arms: [(dx: CGFloat, dy: CGFloat, reach: CGFloat, opened: Double)] = [
            (0, -1, size.height * 1.4, up),
            (0, 1, size.height * 1.4, down),
            (-1, 0, size.width * 1.4, left),
            (1, 0, size.width * 1.4, right)
        ]
        let near = x(0.02)
        let far = x(0.085)
        // Gold, not the sky's own halo. Pale cream on a pale blue sky is nothing at all — the
        // four lines came out reading as glare on the lens rather than as something coming out
        // of the bird, which is the one thing this shot exists to say. Gold is the only colour in
        // the game's box that holds against a bright sky and against the blackest night in it.
        let beam = GamePalette.pen

        for arm in arms where arm.opened > 0.001 {
            let run = arm.reach * CGFloat(arm.opened)
            let tip = CGPoint(x: perch.x + arm.dx * run, y: perch.y + arm.dy * run)
            // Across the beam rather than along it: the wedge is widest where it is furthest out.
            let sideX = -arm.dy
            let sideY = arm.dx

            var wedge = Path()
            wedge.move(to: CGPoint(x: perch.x + sideX * near, y: perch.y + sideY * near))
            wedge.addLine(to: CGPoint(x: tip.x + sideX * far, y: tip.y + sideY * far))
            wedge.addLine(to: CGPoint(x: tip.x - sideX * far, y: tip.y - sideY * far))
            wedge.addLine(to: CGPoint(x: perch.x - sideX * near, y: perch.y - sideY * near))
            wedge.closeSubpath()

            context.fill(
                wedge,
                with: .linearGradient(
                    Gradient(colors: [
                        beam.opacity(0.60 * opacity),
                        beam.opacity(0.10 * opacity)
                    ]),
                    startPoint: perch,
                    endPoint: tip
                )
            )

            var thread = Path()
            thread.move(to: perch)
            thread.addLine(to: tip)
            context.stroke(
                thread,
                with: .color(GamePalette.cream.opacity(0.8 * opacity)),
                style: StrokeStyle(lineWidth: max(1.5, x(0.006)), lineCap: .round)
            )
        }
    }

    /// A rainbow: seven arcs struck from one centre, red outside and violet in.
    ///
    /// Not `GamePalette.rainbow`, which lays the whole colour wheel round a pen that has nothing
    /// left to beat and comes back to red so it never seams. A bow in the sky is a spectrum
    /// rather than a wheel — it has two ends and they are different colours — so the hues here
    /// run once from red to violet and stop, which is what makes the arc read as weather instead
    /// of as a party.
    func drawCloudspireBow(
        in context: inout GraphicsContext,
        centre: CGPoint,
        radius: CGFloat,
        opacity: Double
    ) {
        let bands = 7
        // Thin, and thin at any size: a band struck as a flat fraction of the radius turns an
        // arch across the whole sky into a paint roller.
        let band = min(radius * 0.035, x(0.018))

        for index in 0..<bands {
            var arc = Path()
            arc.addArc(
                center: centre,
                radius: radius - band * CGFloat(index),
                startAngle: .degrees(188),
                endAngle: .degrees(352),
                clockwise: false
            )
            context.stroke(
                arc,
                with: .color(
                    Color(
                        hue: Double(index) / Double(bands) * 0.78,
                        saturation: 0.62,
                        brightness: colors.isNight ? 0.7 : 0.98
                    )
                    .opacity(opacity * (index == 0 || index == bands - 1 ? 0.6 : 1))
                ),
                style: StrokeStyle(lineWidth: band * 1.15, lineCap: .round)
            )
        }
    }

    /// Torn-off wisps of the cloud sea streaming past on the wind that never stops, which is what
    /// the heights get where the meadow gets pollen and the thicket gets fireflies.
    ///
    /// They go across rather than up or down, and they wrap, so a shot held still on a spire top
    /// is still a place with weather in it rather than a painting of one. At the frozen middle of
    /// a shot for a player who asked for less motion they are simply strewn, which is why none of
    /// them is ever the thing the shot is about.
    func drawCloudspireWind(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let home = scatter.next()
            let level = scatter.next(in: 0.1...0.72)
            let speed = scatter.next(in: 0.18...0.42)
            let long = scatter.next(in: 0.1...0.26)
            let across = (home + progress * speed).truncatingRemainder(dividingBy: 1.3) - 0.15

            context.fill(
                Path(ellipseIn: CGRect(
                    x: x(across), y: y(level),
                    width: x(long), height: y(0.006)
                )),
                with: .color(colors.cloud.opacity(colors.isNight ? 0.16 : 0.5))
            )
        }
    }

    /// Stars, and only after dark. The heights are the one place in the game with no weather
    /// above them, so this is the only sky in it that gets a proper field of them — a slow
    /// twinkle out of `progress`, so even the stillest of the last film's shots is moving
    /// somewhere.
    func drawCloudspireStars(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        guard colors.isNight else { return }
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let spot = CGPoint(x: x(scatter.next()), y: y(scatter.next(in: 0.02...0.6)))
            let spark = x(scatter.next(in: 0.002...0.005))
            let phase = scatter.next() * 2 * .pi
            let shine = moves ? 0.55 + 0.45 * (sin(progress * 2 * .pi + phase) + 1) / 2 : 0.8
            context.fill(
                circle(at: spot, radius: spark),
                with: .color(GamePalette.cream.opacity(shine))
            )
        }
    }

    /// Every boss in the game, ringed round a point and arriving one at a time in the order the
    /// pig met them.
    ///
    /// The ring is flattened by `squash` because it is standing on ground rather than hanging on
    /// a wall, and it is painted back to front — sorted by how far up the frame each one's feet
    /// are — so the ones behind the pig go down before the ones in front of him and the crowd
    /// has a depth to it. `settled` is how much of the arrival has already happened when the shot
    /// cuts in, which is how three shots in a row can show the same gathering getting worse
    /// without any of them starting over from an empty terrace.
    func drawCloudspireGathering(
        in context: inout GraphicsContext,
        round centre: CGPoint,
        radius: CGFloat,
        squash: Double,
        glyph: CGFloat,
        settled: Double,
        part: CloudspireRing = .whole
    ) {
        let cast = Film.cloudspireBosses
        let lift = settled + (1 - settled) * progress

        var standing: [(feet: CGPoint, glyph: String, pop: Double)] = []
        for index in cast.indices {
            // Turned half a step off the top of the ring, so nothing ever stands at the dead
            // bottom of it — which is exactly where the pig is, and a boss set down on top of him
            // is one fewer boss and one fewer pig.
            let step = 2 * Double.pi / Double(cast.count)
            let angle = -Double.pi / 2 + step * (Double(index) + 0.5)
            let due = Double(index) / Double(cast.count) * 0.62
            let pop = easeOut(min(max((lift - due) / 0.28, 0), 1))
            guard pop > 0.02 else { continue }
            // Behind the pig or in front of him, so the shot can put him inside his own crowd
            // rather than under all of it.
            let behind = sin(angle) < 0
            switch part {
            case .whole: break
            case .far where !behind: continue
            case .near where behind: continue
            default: break
            }
            standing.append((
                feet: CGPoint(
                    x: centre.x + radius * CGFloat(cos(angle)),
                    y: centre.y + radius * CGFloat(squash) * CGFloat(sin(angle))
                ),
                glyph: cast[index],
                pop: pop
            ))
        }

        for arrival in standing.sorted(by: { $0.feet.y < $1.feet.y }) {
            var stamp = context
            stamp.opacity = arrival.pop
            // The far side of the ring is further away as well as further up, so it is drawn
            // smaller: a ring of identically sized glyphs is a clock face.
            // Far side smaller, but only a little. At the range this was set to, the boss at the
            // back of the ring came out the size of a fly and read as a speck of dirt.
            let depth = 0.89 + 0.13 * (arrival.feet.y - centre.y) / (radius * CGFloat(squash))
            drawTreat(in: &stamp, arrival.glyph, at: arrival.feet, width: glyph * depth * CGFloat(arrival.pop))
        }
    }
}
