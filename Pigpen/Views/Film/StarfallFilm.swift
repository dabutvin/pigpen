import Foundation
import SwiftUI
import UIKit

// MARK: - Starfall Reaches, painted

/// The reaches' nine shots, and the seven brushes a world with nothing in it turned out to need.
///
/// Every other world in the game is painted by adding: the thicket puts a roof on the meadow, the
/// mountain puts a peak in it, the city puts walls down both sides. The reaches are sold on the
/// opposite, and a picture cannot say *empty* by having more in it. So these shots are composed
/// by subtraction — the horizon is ruled almost flat, the ground carries no grass at all, and the
/// pig is drawn small enough that a reader has to find him. What is left over is left over, which
/// is the listing: no traffic, no crowds, unbelievable lot sizes.
///
/// Two things fill the gap the trees and the buildings leave. Overhead there are stars, showing
/// through in the middle of the afternoon because the air up here is too thin to hide them, and
/// meteors coming down through them at intervals — the one thing out here that moves on its own.
/// Underfoot there are craters, laid in perspective so that a plain of them reads as distance
/// rather than as spots on a wall; they are the same shallow pits with pale thrown-up rims that
/// this world's boards are dressed with, so the ground in the film is the ground in the game.
///
/// The rules the thicket learnt hold here too. Nothing that matters goes where the words go, and
/// the horizon on a card is dropped right down so the caption lands on open sky. And the crater
/// rims and the hole in the last two shots are drawn first and then had ground laid over the
/// bottom of them, because a shape with a visible flat foot reads as a sticker wherever it is.
extension Film {
    /// The reaches by day, which is not much of a day — thin violet sky, a small cold sun — and
    /// the send-off after dark, when the stars are the whole point of the place. The same
    /// arrangement every world uses: the two films that sell and explain are lit, and the one
    /// that looks at the next listing falls into the dark, because the next listing always is.
    static func starfallLight(_ shot: CutScene.Picture.Starfall) -> GamePalette.Pasture {
        switch shot {
        case .reachesHeld, .belowMarket, .theHole: .starDusk
        default: .starDay
        }
    }

    func drawStarfall(_ shot: CutScene.Picture.Starfall, in context: inout GraphicsContext) {
        switch shot {
        case .theReaches: drawTheReaches(in: &context)
        case .starsAndMeteors: drawStarsAndMeteors(in: &context)
        case .noNeighbors: drawNoNeighbors(in: &context)
        case .theVisitor: drawTheVisitor(in: &context)
        case .personalSpace: drawPersonalSpace(in: &context)
        case .equalSquareFootage: drawEqualSquareFootage(in: &context)
        case .reachesHeld: drawReachesHeld(in: &context)
        case .belowMarket: drawBelowMarket(in: &context)
        case .theHole: drawTheHole(in: &context)
        }
    }

    // MARK: - The reaches' opening

    /// The plain, and the camera backing off it. The thicket's first shot pushes in because a
    /// wood has to be entered; this one pulls out, because the only way to photograph a lot this
    /// size is to keep retreating until the whole of it fits, and the pig gets smaller the longer
    /// the sales pitch goes on.
    func drawTheReaches(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.09 * progress)

        drawSky(in: &shot, horizon: y(0.48))
        drawStarfallStars(in: &shot, count: 26, above: 0.44, seed: 601)
        // Small and high and giving off no warmth at all: a sun at this distance is a light
        // source rather than a climate. Kept in off the top right corner, because that corner
        // belongs to the Skip button and the disc was photographed hiding behind it.
        drawSun(in: &shot, at: CGPoint(x: x(0.64), y: y(0.22)), radius: x(0.032), rays: false)
        drawStarfallFall(in: &shot, count: 2, top: 0.14, drop: 0.24, seed: 607)

        // The flattest horizon in the game, and deliberately: a hill out here would be somewhere
        // to walk to, and the whole argument of the shot is that there is nowhere.
        drawStarfallFar(in: &shot, ridge: 0.48, rise: 0.012, waves: 1.1, phase: 1.3, haze: 0.44)
        drawMist(in: &shot, at: 0.49, seed: 611)
        drawLand(in: &shot, ridge: 0.56, rise: 0.016, waves: 1.4, phase: 2.2, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.84, to: 0.58, count: 15, seed: 613)

        // A smudge in the middle of his own lot. He is the smallest thing in the film and the
        // frame keeps giving him less, which is the joke the caption is about to make in words.
        let out = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.44), y: y(0.72)),
            width: x(0.085 - 0.018 * out),
            squash: 1 - 0.03 * hop(cycles: 2.5),
            shadow: 0.6
        )

        drawStarfallSparks(in: &shot, along: 0.80, count: 3, scale: 1, seed: 617)
        drawLand(in: &shot, ridge: 0.90, rise: 0.010, waves: 1.0, phase: 0.4, color: colors.foreground)
    }

    /// The scoring, in the two halves the line comes in: the star while it is being sold as a
    /// sparkle, and the meteor in the same spot afterwards while the small print is being read.
    ///
    /// Built the way the thicket builds its own — one picture that changes hands where the
    /// caption changes sentence, rather than two things held up at once — because by the fifth
    /// world nobody is being taught what a bonus is. What is worth saying is that the meadow's
    /// apple and skull have come this far and are still worth what they were, so the star gets
    /// the halo the mushroom got and the meteor gets the flat light the wilted flower got, and
    /// the pig gives his opinion by leaning at one and away from the other.
    func drawStarsAndMeteors(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the amenity becomes the disclaimer: the first sentence has faded and the second
        // has not arrived, which is the only moment the picture can change hands unnoticed.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.44))
        drawStarfallStars(in: &shot, count: 22, above: 0.40, seed: 619)
        drawSun(in: &shot, at: CGPoint(x: x(0.18), y: y(0.16)), radius: x(0.036), rays: false)

        drawStarfallFar(in: &shot, ridge: 0.44, rise: 0.014, waves: 1.2, phase: 2.0, haze: 0.44)
        drawMist(in: &shot, at: 0.485, seed: 621)
        drawLand(in: &shot, ridge: 0.58, rise: 0.018, waves: 1.5, phase: 0.9, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.84, to: 0.60, count: 11, seed: 623)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.27), y: y(0.80)),
            width: x(0.18),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.66), y: y(0.78))

        // The sparkle, in a light of its own, with more of its kind lying about it.
        var sparkle = shot
        sparkle.opacity = 1 - turn
        sparkle.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.21)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.40), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.21)
            )
        )
        drawTreat(in: &sparkle, "🌟", at: spot, width: x(0.22))
        drawStarfallSparks(in: &sparkle, along: 0.84, count: 4, scale: 1.4, seed: 629)

        // And the damage, in the same spot with the light off it and a fresh pit under it. It
        // arrives having already landed, because nothing about the second sentence is an event.
        var damage = shot
        damage.opacity = turn
        damage.fill(
            Path(ellipseIn: CGRect(
                x: spot.x - x(0.15), y: spot.y - x(0.045),
                width: x(0.30), height: x(0.09)
            )),
            with: .color(.black.opacity(0.20))
        )
        drawTreat(in: &damage, "☄️", at: spot, width: x(0.22))

        drawLand(in: &shot, ridge: 0.90, rise: 0.012, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// No neighbours, drawn as the amount of nothing between the pig and every edge of the frame.
    ///
    /// The horizon goes right down to the bottom quarter, which is a thing none of the other
    /// worlds' cards can do — a card needs its middle left clear for the line, and out here the
    /// middle is empty sky with stars in it, so the composition the card wants and the
    /// composition the world wants are the same composition for once.
    func drawNoNeighbors(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.20 - 0.13 * progress)

        drawSky(in: &shot, horizon: y(0.70))
        drawStarfallStars(in: &shot, count: 40, above: 0.32, seed: 631)
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.13)), radius: x(0.030), rays: false)
        drawStarfallFall(in: &shot, count: 2, top: 0.10, drop: 0.16, seed: 641)

        // Dust hanging over the plain, which is the only thing between the words and half a
        // frame of flat sky: empty is the selling point, dull is not.
        drawMist(in: &shot, at: 0.60, seed: 637)
        drawStarfallFar(in: &shot, ridge: 0.70, rise: 0.010, waves: 1.1, phase: 1.8, haze: 0.44)
        drawMist(in: &shot, at: 0.735, seed: 639)
        drawLand(in: &shot, ridge: 0.78, rise: 0.014, waves: 1.3, phase: 0.5, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.90, to: 0.79, count: 9, seed: 643)

        // Dead centre and tiny, with a hop in him. Anywhere else in the frame would read as him
        // heading for something, and there is nothing to head for.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.50), y: y(0.83)),
            width: x(0.078),
            squash: 1 - 0.05 * hop(cycles: 2),
            shadow: 0.6
        )

        drawStarfallSparks(in: &shot, along: 0.88, count: 3, scale: 1.1, seed: 647)
        drawLand(in: &shot, ridge: 0.94, rise: 0.008, waves: 1.0, phase: 2.7, color: colors.foreground)
    }

    // MARK: - Visitor Crater

    /// The saucer coming down on its own light, into the crater, in front of a pig who bought the
    /// place on the strength of there being nobody here. It descends through the whole shot and
    /// does not land, which is the correct amount of consideration to show a neighbour.
    func drawTheVisitor(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 + 0.05 * progress, drift: -0.012 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        drawStarfallStars(in: &shot, count: 24, above: 0.42, seed: 653)
        drawStarfallFall(in: &shot, count: 1, top: 0.12, drop: 0.20, seed: 659)

        // The far rim of the crater, which is the one place in this world the ground is allowed
        // to stand up: it is a bowl, and a bowl has an edge.
        drawStarfallFar(in: &shot, ridge: 0.46, rise: 0.035, waves: 1.3, phase: 2.4, haze: 0.46)
        drawMist(in: &shot, at: 0.515, seed: 657)
        drawLand(in: &shot, ridge: 0.60, rise: 0.020, waves: 1.4, phase: 1.1, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.83, to: 0.62, count: 11, seed: 661)

        // Down through the frame as the shot runs, and still coming when it cuts.
        let down = easeOut(min(progress / 0.85, 1))
        let craft = CGPoint(x: x(0.66), y: y(0.30 + 0.28 * down))
        drawStarfallBeam(in: &shot, from: craft, to: 0.74, width: 0.26, opacity: 0.35 + 0.45 * down)
        // No cast shadow on this one: an ellipse of black under something in mid-air reads as a
        // hole rather than as a shadow, and this world has real holes in it to confuse it with.
        drawAnimal(
            in: &shot,
            .visitor,
            feet: craft,
            width: x(0.21),
            lean: 3 * sin(progress * 2 * .pi),
            shadow: 0
        )

        // Near, small, and leaning at the thing the brochure did not mention.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.21), y: y(0.82)), width: x(0.15), lean: 6)

        drawLand(in: &shot, ridge: 0.92, rise: 0.010, waves: 1.0, phase: 0.8, color: colors.foreground)
    }

    /// The two of them at opposite ends of a great deal of dust, and the dust between them
    /// measured: a span out from the middle to each, both the same length, drawn as the line is
    /// read. Personal space is the gap; fairness is the two halves of it matching, and a
    /// dimension line is the only thing that says *matching* without saying it in words.
    func drawPersonalSpace(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.07 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawStarfallStars(in: &shot, count: 20, above: 0.36, seed: 673)
        drawSun(in: &shot, at: CGPoint(x: x(0.50), y: y(0.16)), radius: x(0.034), rays: false)

        drawStarfallFar(in: &shot, ridge: 0.40, rise: 0.025, waves: 1.3, phase: 0.6, haze: 0.46)
        drawMist(in: &shot, at: 0.455, seed: 671)
        drawLand(in: &shot, ridge: 0.54, rise: 0.018, waves: 1.4, phase: 2.1, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.80, to: 0.56, count: 12, seed: 677)

        // Both pushed right out to the edges of the frame. Any closer together and the shot is
        // about the two of them rather than about the distance, which is what they have agreed on.
        //
        // And both kept high: this line runs to two sentences and therefore to two rows of type,
        // and the measure under them has to finish well above where the second row starts.
        let breath = sin(progress * 2 * .pi * 1.1)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.16), y: y(0.70) - y(0.004 * breath)),
            width: x(0.14),
            lean: -4
        )
        drawAnimal(
            in: &shot,
            .visitor,
            feet: CGPoint(x: x(0.84), y: y(0.68) + y(0.004 * breath)),
            width: x(0.16),
            lean: 4,
            shadow: 0.6
        )

        // The halves ruled out from the boundary rather than in from the ends, so they arrive
        // together and a reader watching either one is watching both.
        let ruled = easeOut(min(progress / 0.55, 1))
        drawStarfallSpan(in: &shot, from: 0.50 - 0.34 * ruled, to: 0.50, at: 0.755, opacity: 0.85 * ruled)
        drawStarfallSpan(in: &shot, from: 0.50, to: 0.50 + 0.34 * ruled, at: 0.755, opacity: 0.85 * ruled)

        drawLand(in: &shot, ridge: 0.93, rise: 0.010, waves: 1.0, phase: 1.4, color: colors.foreground)
    }

    /// The rule: two pens, and the same square footage in each.
    ///
    /// The thicket's equivalent card opens two pens far apart, because its rule is about not
    /// sharing a wall and distance is the whole of it. This rule is about equality instead, and
    /// two pens merely apart do not say equal — so these two are drawn to the same width, the
    /// same height and the same baseline, side by side where the eye can put one against the
    /// other, with a dimension line under each saying the same number twice. The reader is meant
    /// to check. That is the shot.
    func drawEqualSquareFootage(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 - 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawStarfallStars(in: &shot, count: 18, above: 0.30, seed: 683)

        drawStarfallFar(in: &shot, ridge: 0.34, rise: 0.020, waves: 1.3, phase: 1.9, haze: 0.40)
        drawMist(in: &shot, at: 0.42, seed: 687)
        drawLand(in: &shot, ridge: 0.52, rise: 0.016, waves: 1.4, phase: 0.7, color: colors.ground)
        // Kept well down the frame: the middle of a card belongs to the line, and a crater in
        // among the words is a smudge on the lens.
        drawStarfallCraters(in: &shot, from: 0.90, to: 0.68, count: 9, seed: 691)

        let pig = CGPoint(x: x(0.27), y: y(0.80))
        let visitor = CGPoint(x: x(0.73), y: y(0.80))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.13), shadow: 0.8)
        drawAnimal(in: &shot, .visitor, feet: visitor, width: x(0.14), shadow: 0.8)

        // The same four numbers twice over. Anything else here — a wider lot for the pig, a
        // taller one for the visitor — would be a different rule.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: pig, width: 0.36, height: 0.13, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: visitor, width: 0.36, height: 0.13, drop: 0.012, opacity: 0.9 * drawn)

        // And the measure under them, opening after the pens and out from each centre, so the two
        // lines grow at the same rate and finish level. They finish early on purpose: the still
        // this shot is photographed at is barely half way in, and a half-drawn measure reads as a
        // bracket rather than as a width.
        let ruled = easeOut(min(max((progress - 0.14) / 0.22, 0), 1))
        drawStarfallSpan(in: &shot, from: 0.27 - 0.18 * ruled, to: 0.27 + 0.18 * ruled, at: 0.885, opacity: 0.8 * ruled)
        drawStarfallSpan(in: &shot, from: 0.73 - 0.18 * ruled, to: 0.73 + 0.18 * ruled, at: 0.885, opacity: 0.8 * ruled)
    }

    // MARK: - The reaches held

    /// Two pens holding after dark, matched to the tile because the rule would not have it any
    /// other way, with stars lying about the pig's the way windfall mushrooms lie about his in
    /// the wood. Remote, spacious and peaceful — and then a meteor comes down beyond the rim,
    /// which is the "mostly" the caption ends on.
    func drawReachesHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.38))
        drawStarfallStars(in: &shot, count: 46, above: 0.34, seed: 701)
        // The disc at this hour is a moon, and out here it is the second-brightest thing in the
        // sky after the ground.
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.14)), radius: x(0.046), rays: false)
        drawStarfallFall(in: &shot, count: 1, top: 0.22, drop: 0.14, seed: 709)

        drawStarfallFar(in: &shot, ridge: 0.38, rise: 0.018, waves: 1.2, phase: 2.3, haze: 0.30)
        drawLand(in: &shot, ridge: 0.50, rise: 0.016, waves: 1.4, phase: 1.0, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.88, to: 0.53, count: 12, seed: 719)
        drawStarfallSparks(in: &shot, along: 0.60, count: 4, scale: 1, seed: 727)

        // Both lots the same to the tile, and both drawn long and low: a pen as tall as it is
        // wide reads as a gold card stood up in the dust rather than as ground somebody owns.
        let lot = (width: 0.44, height: 0.11, drop: 0.01)

        // The neighbour, held, at the far end of a lot exactly the size of the pig's.
        let visitor = CGPoint(x: x(0.72), y: y(0.65))
        drawPenWash(in: &shot, round: visitor, width: lot.width, height: lot.height, drop: lot.drop)
        drawAnimal(in: &shot, .visitor, feet: visitor, width: x(0.12), shadow: 0.5)
        drawPenFence(in: &shot, round: visitor, width: lot.width, height: lot.height, drop: lot.drop)

        // And the pig in his, with the windfall still where it landed.
        let pig = CGPoint(x: x(0.28), y: y(0.82))
        drawPenWash(in: &shot, round: pig, width: lot.width, height: lot.height, drop: lot.drop)
        drawTreat(in: &shot, "🌟", at: CGPoint(x: x(0.11), y: y(0.80)), width: x(0.05))
        drawTreat(in: &shot, "🌟", at: CGPoint(x: x(0.44), y: y(0.815)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.14))
        drawPenFence(in: &shot, round: pig, width: lot.width, height: lot.height, drop: lot.drop)
    }

    /// A hole in the dust out ahead of him, catching a little light on its lip, and the pig with
    /// his head over the edge of it. Every send-off in the game so far has pointed along the
    /// horizon at somewhere further off; this one points down, because after a lot this size the
    /// only thing left to want is a cheaper one.
    func drawBelowMarket(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 + 0.05 * progress, drift: 0.015 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawStarfallStars(in: &shot, count: 38, above: 0.38, seed: 733)
        // Down out of the corner the Skip button sits in, for the same reason the opening's sun
        // came down out of it: a moon behind a button is a smudge on the button.
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.26)), radius: x(0.042), rays: false)

        drawStarfallFar(in: &shot, ridge: 0.42, rise: 0.016, waves: 1.2, phase: 0.9, haze: 0.30)
        drawLand(in: &shot, ridge: 0.56, rise: 0.018, waves: 1.4, phase: 2.5, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.84, to: 0.60, count: 10, seed: 739)

        // Small enough that it could be another pit, until the light down it says otherwise.
        drawStarfallShaft(
            in: &shot,
            at: CGPoint(x: x(0.66), y: y(0.72)),
            width: 0.30,
            depth: 0.28,
            glimmer: 0.30 + 0.30 * progress,
            seed: 743
        )

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.32), y: y(0.80)), width: x(0.16), lean: 7)

        drawLand(in: &shot, ridge: 0.93, rise: 0.010, waves: 1.0, phase: 1.7, color: colors.foreground)
    }

    /// The same hole, from its lip: the mouth across the top of the frame, the throat going down
    /// out of the bottom of it, and a cold glimmer a very long way below that is the next world
    /// keeping its light on. The camera leans in as the shot runs.
    ///
    /// The card's line lands on the throat, which is the darkest and emptiest thing this game has
    /// ever put behind a caption — so the pig goes right up at the far rim above it, tiny, and
    /// everything else worth seeing is either up there with him or deep enough to be under the
    /// words rather than in among them.
    func drawTheHole(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.03 + 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.15))
        drawStarfallStars(in: &shot, count: 20, above: 0.12, seed: 751)

        drawStarfallFar(in: &shot, ridge: 0.15, rise: 0.010, waves: 1.2, phase: 1.5, haze: 0.30)
        drawLand(in: &shot, ridge: 0.21, rise: 0.008, waves: 1.3, phase: 0.4, color: colors.ground)
        drawStarfallCraters(in: &shot, from: 0.245, to: 0.215, count: 5, seed: 753)

        // The pig on the far rim, up above the mouth where he can still be seen. He was inside it
        // the first time this was photographed: a hole drawn wide enough to be the next world
        // will swallow anything standing at the edge of it, and the subject of the shot is the
        // one thing that cannot go missing.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.44), y: y(0.245)), width: x(0.075), lean: 9, shadow: 0.5)

        // Wide enough to run out of both sides of the frame at the bottom, and deep enough that
        // the bottom of it is somebody else's world.
        drawStarfallShaft(
            in: &shot,
            at: CGPoint(x: x(0.50), y: y(0.33)),
            width: 0.88,
            depth: 0.70,
            glimmer: 0.60 + 0.50 * progress,
            seed: 757
        )
    }

    // MARK: - What the reaches are made of

    /// The far country, with the air between here and there laid back over it.
    ///
    /// This world's `farHill` is darker than its ground, which is the wrong way round for
    /// distance: painted flat it comes out as a black stripe across the middle of every shot and
    /// reads as a wall rather than as somewhere further off. So the band is filled and then the
    /// sky is washed over the same shape — distance is a colour before it is a size, and out here
    /// it is the only depth cue there is, since nothing stands up to be dwarfed by anything else.
    func drawStarfallFar(
        in context: inout GraphicsContext,
        ridge: Double,
        rise: Double,
        waves: Double,
        phase: Double,
        haze: Double
    ) {
        let edge = ridgeLine(at: ridge, rise: rise, waves: waves, phase: phase)
        context.fill(band(below: edge), with: .color(colors.farHill))
        context.fill(band(below: edge), with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// The stars, which up here are out all day: the air is too thin to hide them, and they are
    /// what this world has instead of a canopy — the thing that fills the part of the frame the
    /// picture is not using.
    ///
    /// Each is a four-pointed spark with a haze round it, the same mark the boards are strewn
    /// with, and each twinkles on its own phase so the sky is never all bright or all dim at
    /// once. `above` keeps them out of whatever the shot has put in the lower half, and on a card
    /// it is dropped further still, to keep the line's own middle clear.
    func drawStarfallStars(in context: inout GraphicsContext, count: Int, above baseline: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        let lit = colors.isNight ? 0.95 : 0.42

        for _ in 0..<count {
            let spot = CGPoint(
                x: x(scatter.next(in: -0.04...1.04)),
                y: y(scatter.next(in: -0.04...baseline))
            )
            let reach = x(0.004 + scatter.next() * 0.009)
            let phase = scatter.next() * 2 * .pi
            let twinkle = moves ? 0.55 + 0.45 * sin(progress * 2 * .pi * 1.5 + phase) : 0.82

            context.fill(
                circle(at: spot, radius: reach * 2.6),
                with: .radialGradient(
                    Gradient(colors: [
                        colors.discHalo.opacity(0.34 * lit * twinkle),
                        colors.discHalo.opacity(0)
                    ]),
                    center: spot,
                    startRadius: 0,
                    endRadius: reach * 2.6
                )
            )
            context.fill(
                starfallStarPath(at: spot, reach: reach),
                with: .color(GamePalette.cream.opacity(lit * twinkle))
            )
        }
    }

    /// Things coming down: a streak with a bright head and a tail that fades out behind it,
    /// falling on its own clock so that no two arrive together.
    ///
    /// Each fades up and out over its own pass, rather than starting and stopping, because a
    /// meteor that appears from nowhere at the top of the frame reads as a scratch on the film.
    /// Every one is offset by its own phase, so a shot held still at half way — which is what a
    /// player who asked for less motion sees — still has one in the air.
    func drawStarfallFall(in context: inout GraphicsContext, count: Int, top: Double, drop: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let start = CGPoint(
                x: x(scatter.next(in: 0.08...1.02)),
                y: y(top + scatter.next(in: -0.05...0.05))
            )
            let fall = y(drop) * CGFloat(0.7 + scatter.next() * 0.6)
            let lean = -fall * CGFloat(0.35 + scatter.next() * 0.30)
            let along = (progress + scatter.next()).truncatingRemainder(dividingBy: 1)
            let bright = sin(along * .pi)
            let head = CGPoint(x: start.x + lean * CGFloat(along), y: start.y + fall * CGFloat(along))
            let tail = CGPoint(x: head.x - lean * 0.30, y: head.y - fall * 0.30)

            var streak = Path()
            streak.move(to: tail)
            streak.addLine(to: head)
            context.stroke(
                streak,
                with: .linearGradient(
                    Gradient(colors: [
                        GamePalette.cream.opacity(0),
                        GamePalette.cream.opacity(0.75 * bright)
                    ]),
                    startPoint: tail,
                    endPoint: head
                ),
                style: StrokeStyle(lineWidth: max(1, x(0.004)), lineCap: .round)
            )
            context.fill(
                circle(at: head, radius: max(1, x(0.005))),
                with: .color(GamePalette.cream.opacity(0.9 * bright))
            )
        }
    }

    /// The pits, which are what this world has instead of grass: a shallow shadow with a pale
    /// ring of thrown-up dust round the rim, exactly as the reaches' own boards dress themselves.
    ///
    /// `from` is the near edge of the field of them and `to` the far, and they are drawn wide at
    /// the near edge and small at the far one — which is the only trick keeping a plain of these
    /// from reading as spots on a wall. It is also the only depth cue the world has: no trees to
    /// dwindle, no buildings to stack, just the same hole over and over getting smaller.
    func drawStarfallCraters(
        in context: inout GraphicsContext,
        from near: Double,
        to far: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let depth = scatter.next()
            let level = near + (far - near) * depth
            let spread = x(0.045 + (1 - depth) * 0.13) * CGFloat(0.6 + scatter.next() * 0.7)
            let centre = CGPoint(x: x(scatter.next(in: -0.06...1.06)), y: y(level))
            let pit = CGRect(
                x: centre.x - spread * 0.5, y: centre.y - spread * 0.18,
                width: spread, height: spread * 0.36
            )

            context.fill(
                Path(ellipseIn: pit),
                with: .color(.black.opacity(colors.isNight ? 0.28 : 0.14))
            )
            // The spoil on the far lip only, rather than a ring all the way round. A closed pale
            // ring reads as something lying on the ground; a crescent along the top of a shadow
            // reads as a dip in it, which is what these are.
            var lip = context
            lip.clip(to: Path(CGRect(
                x: pit.minX - spread * 0.2, y: pit.minY - spread * 0.2,
                width: pit.width + spread * 0.4, height: spread * 0.2 + pit.height * 0.58
            )))
            lip.stroke(
                Path(ellipseIn: pit.insetBy(dx: -spread * 0.05, dy: -spread * 0.025)),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.06 : 0.16)),
                lineWidth: max(1, spread * 0.05)
            )
        }
    }

    /// Fallen stars lying about in the dust along a line across the frame, still cooling. The
    /// thicket has mushrooms coming up through the leaf mould in the same places for the same
    /// reason: a ground with something scattered on it is a ground somebody lives on.
    func drawStarfallSparks(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        scale: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for index in 0..<count {
            let foot = CGPoint(
                x: x((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)),
                y: y(baseline + (scatter.next() - 0.5) * 0.04)
            )
            let reach = x(0.012) * CGFloat(scale) * CGFloat(0.7 + scatter.next() * 0.7)

            context.fill(
                circle(at: foot, radius: reach * 2.2),
                with: .radialGradient(
                    Gradient(colors: [
                        colors.discHalo.opacity(colors.isNight ? 0.36 : 0.20),
                        colors.discHalo.opacity(0)
                    ]),
                    center: foot,
                    startRadius: 0,
                    endRadius: reach * 2.2
                )
            )
            context.fill(
                starfallStarPath(at: foot, reach: reach),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.88 : 0.62))
            )
        }
    }

    /// One four-pointed star: two points long and two short, with the waists pinched in so the
    /// arms taper. The same mark whether it is a mile up in the sky or lying in the dust at the
    /// pig's feet, which is the joke this world is built on.
    func starfallStarPath(at centre: CGPoint, reach: CGFloat) -> Path {
        let waist = reach * 0.14
        var points = Path()
        points.move(to: CGPoint(x: centre.x, y: centre.y - reach))
        points.addQuadCurve(
            to: CGPoint(x: centre.x + reach * 0.58, y: centre.y),
            control: CGPoint(x: centre.x + waist, y: centre.y - waist)
        )
        points.addQuadCurve(
            to: CGPoint(x: centre.x, y: centre.y + reach),
            control: CGPoint(x: centre.x + waist, y: centre.y + waist)
        )
        points.addQuadCurve(
            to: CGPoint(x: centre.x - reach * 0.58, y: centre.y),
            control: CGPoint(x: centre.x - waist, y: centre.y + waist)
        )
        points.addQuadCurve(
            to: CGPoint(x: centre.x, y: centre.y - reach),
            control: CGPoint(x: centre.x - waist, y: centre.y - waist)
        )
        return points
    }

    /// The light the visitor comes down on: a cone from the underside of the craft to a pool on
    /// the dust, brightening as it gets nearer the ground.
    ///
    /// Narrow at the top and wide at the bottom, and faint enough throughout to be air rather
    /// than paint — the same restraint the thicket's light shafts are drawn with, and for the
    /// same reason. A solid cone is a traffic bollard.
    func drawStarfallBeam(
        in context: inout GraphicsContext,
        from craft: CGPoint,
        to ground: Double,
        width: Double,
        opacity: Double
    ) {
        let foot = y(ground)
        let spread = x(width)

        // Two cones rather than one: a wide faint spill and a brighter core inside it, both
        // fading out before they reach the ground. A single flat-sided cone at one opacity comes
        // out as a paved ramp leaning against the saucer, which is not what light does.
        for shell in [1.0, 0.55] {
            let mouth = spread * 0.28 * CGFloat(shell)
            let base = spread * 0.5 * CGFloat(shell)

            var cone = Path()
            cone.move(to: CGPoint(x: craft.x - mouth, y: craft.y))
            cone.addLine(to: CGPoint(x: craft.x - base, y: foot))
            cone.addLine(to: CGPoint(x: craft.x + base, y: foot))
            cone.addLine(to: CGPoint(x: craft.x + mouth, y: craft.y))
            cone.closeSubpath()
            context.fill(
                cone,
                with: .linearGradient(
                    Gradient(colors: [
                        colors.disc.opacity(0.20 * opacity),
                        colors.disc.opacity(0)
                    ]),
                    startPoint: CGPoint(x: 0, y: craft.y),
                    endPoint: CGPoint(x: 0, y: foot)
                )
            )
        }

        // What it puts on the ground, which is the half of the effect that says the beam is
        // landing somewhere rather than stopping in mid-air.
        context.fill(
            Path(ellipseIn: CGRect(
                x: craft.x - spread * 0.55, y: foot - spread * 0.13,
                width: spread * 1.1, height: spread * 0.26
            )),
            with: .radialGradient(
                Gradient(colors: [
                    colors.disc.opacity(0.34 * opacity),
                    colors.disc.opacity(0)
                ]),
                center: CGPoint(x: craft.x, y: foot),
                startRadius: 0,
                endRadius: spread * 0.55
            )
        )
    }

    /// A dimension line on the dust: a dashed run with an upright tick at each end, the way a
    /// floor plan marks a width.
    ///
    /// It is the reaches' one piece of notation, and it exists because this world's rule is the
    /// only one in the game about two things being *equal*. A pen drawn beside another pen says
    /// "two"; two of these, the same length, say "the same", and they say it to a reader who has
    /// never been told what the mark means, because everybody has seen a tape measure.
    func drawStarfallSpan(
        in context: inout GraphicsContext,
        from: Double,
        to: Double,
        at baseline: Double,
        opacity: Double
    ) {
        guard opacity > 0, to > from else { return }

        let level = y(baseline)
        let left = x(from)
        let right = x(to)
        let tick = y(0.016)
        let ink = GamePalette.cream.opacity(opacity)

        var rule = Path()
        rule.move(to: CGPoint(x: left, y: level))
        rule.addLine(to: CGPoint(x: right, y: level))
        context.stroke(
            rule,
            with: .color(ink),
            style: StrokeStyle(
                lineWidth: max(1.5, x(0.005)),
                lineCap: .round,
                dash: [x(0.020), x(0.014)]
            )
        )

        var ends = Path()
        for end in [left, right] {
            ends.move(to: CGPoint(x: end, y: level - tick))
            ends.addLine(to: CGPoint(x: end, y: level + tick * 0.5))
        }
        context.stroke(
            ends,
            with: .color(ink),
            style: StrokeStyle(lineWidth: max(1.5, x(0.006)), lineCap: .round)
        )
    }

    /// The hole the last film is about: a mouth cut into the dust with a rim of spoil round it, a
    /// throat tapering away below, and a cold glimmer at the bottom of it that is the caverns
    /// leaving a light on.
    ///
    /// Drawn as three things rather than as one dark ellipse, because a dark ellipse is a puddle.
    /// The throat goes down first and the mouth is laid over the top of it, which is what puts an
    /// edge between the ground and the drop; then the far wall alone is lit — only the far wall,
    /// clipped to the upper half, since the near wall of a hole is the one thing the sky cannot
    /// reach. The motes falling down it are there because a shot of a hole has nothing else in it
    /// that can move.
    func drawStarfallShaft(
        in context: inout GraphicsContext,
        at mouth: CGPoint,
        width: Double,
        depth: Double,
        glimmer: Double,
        seed: UInt64
    ) {
        let span = x(width)
        let lip = span * 0.34
        let drop = y(depth)
        let dark = Color(red: 0.03, green: 0.03, blue: 0.06)
        // The cold blue-green of the world underneath, borrowed from the light its own flowstone
        // gives off: whatever is down there, it is not lit by this sky.
        let crystal = Color(red: 0.74, green: 0.94, blue: 0.95)
        let rim = CGRect(x: mouth.x - span / 2, y: mouth.y - lip / 2, width: span, height: lip)

        // The spoil, thrown out round the edge the way it is round every pit in this world, only
        // more of it: whatever made this one was not stopping at the surface.
        context.fill(
            Path(ellipseIn: rim.insetBy(dx: -span * 0.11, dy: -lip * 0.20)),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.08 : 0.18))
        )

        // The throat, narrowing hard as it goes and losing its edges on the way down: a shaft
        // drawn with two straight sides all the way to the bottom of the frame is a bucket, and
        // what puts the walls into the dark instead is the taper plus a fade off either side.
        var throat = Path()
        throat.move(to: CGPoint(x: mouth.x - span / 2, y: mouth.y))
        throat.addLine(to: CGPoint(x: mouth.x - span * 0.20, y: mouth.y + drop))
        throat.addLine(to: CGPoint(x: mouth.x + span * 0.20, y: mouth.y + drop))
        throat.addLine(to: CGPoint(x: mouth.x + span / 2, y: mouth.y))
        throat.closeSubpath()
        context.fill(
            throat,
            with: .linearGradient(
                Gradient(colors: [dark.opacity(0.88), dark]),
                startPoint: CGPoint(x: 0, y: mouth.y),
                endPoint: CGPoint(x: 0, y: mouth.y + drop * 0.6)
            )
        )
        // The walls, lit down the near side of each and going to nothing in the middle, which is
        // the fold that stops a hole reading as a flat black shape cut out of the ground.
        for side in [-1.0, 1.0] {
            var wall = Path()
            wall.move(to: CGPoint(x: mouth.x + span * 0.5 * CGFloat(side), y: mouth.y))
            wall.addLine(to: CGPoint(x: mouth.x + span * 0.20 * CGFloat(side), y: mouth.y + drop))
            wall.addLine(to: CGPoint(x: mouth.x, y: mouth.y + drop))
            wall.addLine(to: CGPoint(x: mouth.x, y: mouth.y))
            wall.closeSubpath()
            context.fill(
                wall,
                with: .linearGradient(
                    Gradient(colors: [
                        GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.09),
                        GamePalette.cream.opacity(0)
                    ]),
                    startPoint: CGPoint(x: mouth.x + span * 0.5 * CGFloat(side), y: 0),
                    endPoint: CGPoint(x: mouth.x, y: 0)
                )
            )
        }

        context.fill(Path(ellipseIn: rim), with: .color(dark))

        var lit = context
        lit.clip(to: Path(CGRect(
            x: mouth.x - span, y: mouth.y - lip,
            width: span * 2, height: lip * 0.82
        )))
        lit.stroke(
            Path(ellipseIn: rim),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.26 : 0.42)),
            lineWidth: max(1, lip * 0.09)
        )

        // Whatever is down there, keeping a light on. It has to be found from the top of a very
        // dark column, so it is drawn twice: a wide wash to lift the bottom of the shaft off flat
        // black, and a smaller core inside it to give the eye somewhere to land.
        let deep = CGPoint(x: mouth.x, y: mouth.y + drop * 0.84)
        context.fill(
            circle(at: deep, radius: span * 0.42),
            with: .radialGradient(
                Gradient(colors: [crystal.opacity(0.26 * glimmer), crystal.opacity(0)]),
                center: deep,
                startRadius: 0,
                endRadius: span * 0.42
            )
        )
        context.fill(
            circle(at: deep, radius: span * 0.15),
            with: .radialGradient(
                Gradient(colors: [crystal.opacity(0.34 * glimmer), crystal.opacity(0)]),
                center: deep,
                startRadius: 0,
                endRadius: span * 0.15
            )
        )

        var scatter = Scatter(seed: seed)
        for _ in 0..<7 {
            let lane = CGFloat(scatter.next(in: -0.34...0.34))
            let along = (progress + scatter.next()).truncatingRemainder(dividingBy: 1)
            let mote = CGPoint(
                x: mouth.x + span * lane * CGFloat(1 - 0.35 * along),
                y: mouth.y + drop * CGFloat(along)
            )
            context.fill(
                circle(at: mote, radius: max(1, span * 0.006)),
                with: .color(GamePalette.cream.opacity(0.32 * (1 - along)))
            )
        }
    }
}
