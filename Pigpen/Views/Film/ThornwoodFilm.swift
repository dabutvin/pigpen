import Foundation
import SwiftUI
import UIKit

// MARK: - Thornwood Thicket, painted

/// The thicket's nine shots, and the four brushes the meadow never needed.
///
/// Everything a meadow shot is built from is built the same way here — a sky, a ridge, a band
/// of ground, an animal stood on it — and then a roof goes over the lot. That is the whole
/// difference between the two worlds as a camera sees them: the meadow is open ground under an
/// open sky, and the thicket has a canopy hanging into the top of every frame with trunks
/// standing in the way of whatever you were trying to look at. A listing that is secluded,
/// wooded and very private is one you cannot see out of, and the pictures say so before the
/// captions get a chance to.
///
/// Two rules hold every one of these compositions together, both learnt the hard way from
/// photographing them. A wood is drawn feet-first: a rank of trees is laid down and then the
/// ground is laid over the bottom of it, because a rank of crowns has a dead flat lower edge
/// that reads as a shelf the moment anything lets you see it. And nothing that matters is put
/// where the words go — the foot of the frame on a shot with a subtitle, the middle of it on
/// the three that hand the film over on a card.
extension Film {
    /// The thicket's two films by day are lit flat under the leaves, and its send-off falls
    /// into dusk — the same trick the meadow plays at the end of its own last film, because the
    /// next listing is always a darker one than this.
    static func thornwoodLight(_ shot: CutScene.Picture.Thornwood) -> GamePalette.Pasture {
        switch shot {
        case .thicketHeld, .mountainViews, .theVolcano: .forestDusk
        default: .forestDay
        }
    }

    func drawThornwood(_ shot: CutScene.Picture.Thornwood, in context: inout GraphicsContext) {
        switch shot {
        case .theTreeLine: drawTheTreeLine(in: &context)
        case .mushroomsAndFlowers: drawMushroomsAndFlowers(in: &context)
        case .offTheBeatenPath: drawOffTheBeatenPath(in: &context)
        case .theNeighbor: drawTheNeighbor(in: &context)
        case .separateUnits: drawSeparateUnits(in: &context)
        case .aPenApiece: drawAPenApiece(in: &context)
        case .thicketHeld: drawThicketHeld(in: &context)
        case .mountainViews: drawMountainViews(in: &context)
        case .theVolcano: drawTheVolcano(in: &context)
        }
    }

    // MARK: - The thicket's opening

    /// The mouth of the woods: two ranks of trees banked away under a canopy, light coming down
    /// through the gap between them, and the pig on the trail at the foot of it all. The camera
    /// pushes in gently, which is the shot agreeing to go in.
    func drawTheTreeLine(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.50))
        drawSun(in: &shot, at: CGPoint(x: x(0.52), y: y(0.44)), radius: x(0.055), rays: false)

        drawLand(in: &shot, ridge: 0.50, rise: 0.05, waves: 1.9, phase: 1.4, color: colors.farHill)
        // The far rank first and lighter, then the near rank over it, and then the ground over
        // the feet of both: trees standing in a wood rather than on a shelf.
        drawForest(in: &shot, base: 0.58, from: -0.10, to: 1.10, height: 0.18, seed: 307, color: colors.canopy)
        drawForest(in: &shot, base: 0.66, from: -0.10, to: 1.10, height: 0.26, seed: 313, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.62, rise: 0.026, waves: 1.4, phase: 0.7, color: colors.ground)

        drawTrail(in: &shot, from: 1.02, to: 0.62)
        drawTufts(in: &shot, along: 0.62, rise: 0.026, waves: 1.4, phase: 0.7, count: 18, height: 0.018, seed: 317)

        // On the trail and starting up it, small against the wood: the property is the size of
        // the picture, and the buyer is not.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.46), y: y(0.80 - 0.02 * along)),
            width: x(0.16 - 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawMushrooms(in: &shot, along: 0.84, count: 5, scale: 1, seed: 331)
        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 2.4, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.17, seed: 337, drift: 0.01 * progress)
        drawShafts(in: &shot, count: 4, lean: 0.16, seed: 347)
    }

    /// The two halves of the scoring rule, one after the other in the same clearing: the
    /// mushroom while the line is selling it as an amenity, and then the wilted flower while the
    /// line is admitting what it does to the curb appeal.
    ///
    /// The meadow says this in one picture — a pen with an apple shut inside it and a skull
    /// staked outside — because the meadow is teaching the rule for the first time and the fence
    /// is half of what it is teaching. The thicket is not teaching anything; a player here has
    /// fenced a whole meadow. So the pen comes out and the shot changes instead, crossing from
    /// one to the other exactly where the caption changes sentence, and the picture is whichever
    /// half of the line is being read.
    func drawMushroomsAndFlowers(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the amenity to the drawback: the first sentence has faded
        // out and the second is coming up, so the picture may change hands under cover of it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        // A clearing, so there is sky over this one: the only shot in the film that can afford
        // a proper look at anything.
        drawSky(in: &shot, horizon: y(0.42))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.24)), radius: x(0.07), rays: false)

        drawLand(in: &shot, ridge: 0.42, rise: 0.05, waves: 2.0, phase: 1.3, color: colors.farHill)
        drawForest(in: &shot, base: 0.60, from: -0.10, to: 1.10, height: 0.22, seed: 353, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, color: colors.ground)
        drawTufts(in: &shot, along: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, count: 16, height: 0.016, seed: 359)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.28), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        // The amenity, stood in its own light with its own kind coming up round it.
        var amenity = shot
        amenity.opacity = 1 - turn
        let spot = CGPoint(x: x(0.64), y: y(0.78))
        amenity.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.34), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &amenity, "🍄", at: spot, width: x(0.22))
        drawMushrooms(in: &amenity, along: 0.80, count: 4, scale: 1.3, seed: 367)

        // And the drawback, in the same spot with the light off it.
        var drawback = shot
        drawback.opacity = turn
        drawTreat(in: &drawback, "🥀", at: spot, width: x(0.22))

        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.15, seed: 373, drift: 0.008 * progress)
    }

    /// The pig well up the trail with the wood closing over behind it: off the beaten path,
    /// which is a thing people say about a property when they mean you will not be found. The
    /// camera pulls back as it goes, so the trees get bigger and the pig gets smaller.
    func drawOffTheBeatenPath(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.16 - 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawLand(in: &shot, ridge: 0.40, rise: 0.045, waves: 2.1, phase: 1.6, color: colors.farHill)
        drawForest(in: &shot, base: 0.60, from: -0.10, to: 1.10, height: 0.30, seed: 379, color: colors.canopy)
        drawForest(in: &shot, base: 0.72, from: -0.10, to: 1.10, height: 0.26, seed: 389, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.68, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)

        drawTrail(in: &shot, from: 1.02, to: 0.68)

        // Up the trail and dwindling, the way the meadow's last shot dwindles into these same
        // trees — this is what that shot was pointing at, seen from inside it.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.48 + 0.02 * along), y: y(0.82 - 0.05 * along)),
            width: x(0.13 - 0.035 * along),
            shadow: 0.5
        )

        // The near trunks, one either side and both cut off by the frame: the wood standing
        // between the picture and whoever is watching it.
        drawTrunks(in: &shot, base: 1.02, at: [0.04, 0.95], width: 0.075, seed: 397)
        drawLand(in: &shot, ridge: 0.94, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.22, seed: 401, drift: -0.01 * progress)
    }

    // MARK: - Boar Hollow

    /// The boar coming down through the trees into the hollow, arriving as the shot runs, with
    /// the pig near the camera watching it come. Stag Mere's opening shot, one world on and a
    /// good deal less relaxed about it.
    func drawTheNeighbor(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawLand(in: &shot, ridge: 0.44, rise: 0.05, waves: 2.0, phase: 1.4, color: colors.farHill)
        drawForest(in: &shot, base: 0.58, from: -0.10, to: 1.10, height: 0.22, seed: 409, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.54, rise: 0.026, waves: 1.5, phase: 2.2, color: colors.ground)

        // In from the left and slowing as it arrives, up the slope from the pig: bigger than
        // the deer ever was, and not stopping at the edge of the frame to be admired.
        let boarIn = easeOut(min(progress / 0.8, 1))
        drawAnimal(
            in: &shot,
            .boar,
            feet: CGPoint(x: x(-0.06 + 0.38 * boarIn), y: y(0.64)),
            width: x(0.17),
            shadow: 0.7
        )

        // A trunk it comes past rather than one down the middle of the frame, so the boar reads
        // as walking through a wood and the picture keeps its middle.
        drawTrunks(in: &shot, base: 0.78, at: [0.13], width: 0.055, seed: 421)

        drawLand(in: &shot, ridge: 0.70, rise: 0.02, waves: 1.3, phase: 0.6, color: colors.ground)
        drawTufts(in: &shot, along: 0.72, rise: 0.02, waves: 1.3, phase: 0.6, count: 16, height: 0.022, seed: 431)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.74), y: y(0.82)), width: x(0.17), lean: -4)

        drawLand(in: &shot, ridge: 0.92, rise: 0.014, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.14, seed: 433, drift: 0.01 * progress)
    }

    /// The two of them either side of a stand of trunks, each turned away from the other and
    /// both breathing: the one thing they agree on, and the wall they already agree on it
    /// through. Nobody has decided anything yet, so nothing in the shot moves but the air.
    func drawSeparateUnits(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        drawLand(in: &shot, ridge: 0.46, rise: 0.05, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawForest(in: &shot, base: 0.60, from: -0.10, to: 1.10, height: 0.20, seed: 439, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.56, rise: 0.024, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.62, rise: 0.024, waves: 1.4, phase: 0.9, count: 16, height: 0.02, seed: 443)

        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.26), y: y(0.80) - y(0.004 * breath)),
            width: x(0.19),
            lean: -5,
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .boar,
            feet: CGPoint(x: x(0.76), y: y(0.78) + y(0.004 * breath)),
            width: x(0.20),
            lean: 5,
            squash: 1 - 0.015 * breath
        )

        // The party wall, and it grew there: one trunk between the two of them, thick enough to
        // read as a tree rather than as a post. It is the shot's whole argument.
        drawTrunks(in: &shot, base: 0.96, at: [0.50], width: 0.15, seed: 449)
        drawMushrooms(in: &shot, along: 0.80, count: 4, scale: 1, seed: 457)
        drawLand(in: &shot, ridge: 0.92, rise: 0.012, waves: 1.0, phase: 1.1, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.13, seed: 461)
    }

    /// A pen apiece, opening round each of them and never meeting: the rule drawn rather than
    /// written. Stag Mere splits one pen into two because a deer could have shared; nothing here
    /// is ever one pen, so both open at once, one up the slope and one down it, with clear
    /// ground between them and the middle of the frame left to the words.
    func drawAPenApiece(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawLand(in: &shot, ridge: 0.30, rise: 0.045, waves: 2.0, phase: 1.1, color: colors.farHill)
        drawForest(in: &shot, base: 0.42, from: -0.10, to: 1.10, height: 0.16, seed: 463, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.38, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)
        drawTufts(in: &shot, along: 0.38, rise: 0.02, waves: 1.5, phase: 2.4, count: 16, height: 0.014, seed: 467)

        let boar = CGPoint(x: x(0.70), y: y(0.74))
        let pig = CGPoint(x: x(0.30), y: y(0.86))

        drawAnimal(in: &shot, .boar, feet: boar, width: x(0.16), shadow: 0.7)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))

        // Both pens open together and stop well short of each other. The gap between them is
        // the rule: no shared fence, and nowhere the two runs could be mistaken for one.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: boar, width: 0.38, height: 0.10, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: pig, width: 0.40, height: 0.11, drop: 0.012, opacity: 0.9 * drawn)

        // No trunks in this one. A trunk at the edge of a card is a brown border rather than a
        // tree, and the shot is a diagram: two pens, a gap, and the words between them.
        drawCanopy(in: &shot, depth: 0.12, seed: 487)
    }

    // MARK: - The thicket held

    /// Two pens holding in the hollow after dark: the boar's up the slope in its own, the pig's
    /// across the front of the frame with mushrooms lying about in it. Private, peaceful,
    /// spacious — and clear ground between the two of them, which is what makes it peaceful.
    func drawThicketHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        // The disc at this hour is the moon, and the wood barely lets it in.
        drawSun(in: &shot, at: CGPoint(x: x(0.24), y: y(0.16)), radius: x(0.05), rays: false)
        drawLand(in: &shot, ridge: 0.34, rise: 0.05, waves: 2.1, phase: 1.5, color: colors.farHill)
        drawForest(in: &shot, base: 0.50, from: -0.10, to: 1.10, height: 0.18, seed: 491, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.46, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)

        // The neighbour, held and content, at the far end of his own lot.
        let boar = CGPoint(x: x(0.76), y: y(0.60))
        drawPenWash(in: &shot, round: boar, width: 0.32, height: 0.10, drop: 0.01)
        drawAnimal(in: &shot, .boar, feet: boar, width: x(0.12), shadow: 0.6)
        drawPenFence(in: &shot, round: boar, width: 0.32, height: 0.10, drop: 0.01)

        drawTufts(in: &shot, along: 0.64, rise: 0.024, waves: 1.4, phase: 0.8, count: 18, height: 0.016, seed: 503)

        // And the pig with the run of everything in front, windfall mushrooms and all.
        let pig = CGPoint(x: x(0.42), y: y(0.82))
        drawPenWash(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)
        drawTreat(in: &shot, "🍄", at: CGPoint(x: x(0.16), y: y(0.78)), width: x(0.045))
        drawTreat(in: &shot, "🍄", at: CGPoint(x: x(0.64), y: y(0.80)), width: x(0.045))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)

        drawFireflies(in: &shot, count: 8, seed: 509)
        drawCanopy(in: &shot, depth: 0.16, seed: 521, drift: 0.008 * progress)
    }

    /// A gap in the trees at dusk with a mountain standing in it, and the pig turned to look at
    /// it rather than at any of the wood it spent three films buying. The meadow's send-off
    /// pointed at these trees; this one points straight over their heads.
    func drawMountainViews(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.46))

        // The listing, standing beyond the hills rather than in among them: it is drawn first
        // and the far country is drawn over its feet, which is the only way a mountain ever
        // reads as a long way off rather than as a shape stood in the next field.
        drawPeak(in: &shot, at: 0.60, base: 0.50, height: 0.21, width: 0.50, smoking: false, haze: 0.35)
        drawLand(in: &shot, ridge: 0.46, rise: 0.04, waves: 1.8, phase: 1.7, color: colors.farHill)

        // The wood banked in either side of it, which is what makes the mountain a glimpse
        // rather than a view.
        drawForest(in: &shot, base: 0.74, from: -0.12, to: 0.30, height: 0.38, seed: 523, color: colors.canopyShade)
        drawForest(in: &shot, base: 0.74, from: 0.86, to: 1.12, height: 0.38, seed: 541, color: colors.canopyShade)

        drawLand(in: &shot, ridge: 0.68, rise: 0.03, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.70, rise: 0.03, waves: 1.4, phase: 0.9, count: 18, height: 0.02, seed: 547)

        // Stood in his own hollow with his back half-turned, looking at somebody else's.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.28), y: y(0.82)), width: x(0.17), lean: -3)

        drawFireflies(in: &shot, count: 6, seed: 557)
        drawLand(in: &shot, ridge: 0.92, rise: 0.016, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawCanopy(in: &shot, depth: 0.13, seed: 563)
    }

    /// The same mountain, near enough now to see what it is doing: a plume going up off the top
    /// of it and a red light in the crater. The pig is out over the treetops and walking at it,
    /// because the description did not mention the volcano and the pig has not asked.
    func drawTheVolcano(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawLand(in: &shot, ridge: 0.44, rise: 0.04, waves: 1.9, phase: 1.2, color: colors.farHill)
        // Summit high in the frame, so the crater and its plume are above the card rather than
        // behind it, and the words land on the dark of the flanks.
        drawPeak(in: &shot, at: 0.52, base: 0.88, height: 0.46, width: 1.9, smoking: true)

        // Out over the top of the wood at last: the trees are a band along the bottom of the
        // frame now rather than the walls of it.
        drawForest(in: &shot, base: 0.88, from: -0.10, to: 1.10, height: 0.16, seed: 569, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.84, rise: 0.02, waves: 1.3, phase: 0.7, color: colors.ground)

        // Small, on the ridge, and going. The whole journey in one silhouette.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.32 + 0.06 * along), y: y(0.88)),
            width: x(0.11),
            lean: 5,
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.5
        )

        drawLand(in: &shot, ridge: 0.95, rise: 0.012, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    // MARK: - What the woods are made of

    /// The roof: two ranks of leaf mass hung from the top of the frame, the near one darker and
    /// reaching further down, with a lobed edge that never repeats.
    ///
    /// Built out of overlapping ellipses along the bottom of a slab rather than out of curves,
    /// because leaves are round and anything drawn to a point up there reads as icicles. It is
    /// carried well outside the frame in every direction, like the sky it is standing in for, so
    /// no camera move ever finds a corner of it.
    func drawCanopy(in context: inout GraphicsContext, depth: Double, seed: UInt64, drift: Double = 0) {
        for rank in [1.0, 0.0] {
            var scatter = Scatter(seed: seed &+ UInt64(rank * 31))
            let reach = y(depth) * CGFloat(rank > 0 ? 0.66 : 1)
            let shift = x(drift) * CGFloat(rank > 0 ? 0.4 : 1)
            let hem = reach * 0.42
            let start = -size.width
            let end = size.width * 2
            let step = x(0.07)

            var leaves = Path()
            leaves.addRect(CGRect(
                x: start, y: -size.height,
                width: (end - start), height: size.height + hem
            ))

            var across = start
            while across < end {
                let lobe = reach * CGFloat(0.5 + scatter.next() * 0.8)
                let wide = step * CGFloat(1.15 + scatter.next() * 0.7)
                leaves.addEllipse(in: CGRect(
                    x: across - wide / 2 + shift, y: hem - lobe * 0.75,
                    width: wide, height: lobe * 1.5
                ))
                across += step
            }
            context.fill(leaves, with: .color(rank > 0 ? colors.canopy : colors.canopyShade))
        }
    }

    /// Trunks standing on the ground and running up out of the top of the frame: wide at the
    /// foot, half that by the time they leave, flared where they meet the ground and lit down
    /// one side. Every one is drawn to leave the frame, because a tree whose top you can see is
    /// a shrub — and they are placed off the middle, because a trunk down the centre of a shot
    /// is a stripe rather than a tree.
    func drawTrunks(
        in context: inout GraphicsContext,
        base: Double,
        at columns: [Double],
        width: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        let top = -size.height
        let waist = foot - size.height * 0.5

        for column in columns {
            let thick = x(width) * CGFloat(0.85 + scatter.next() * 0.4)
            let centre = x(column)
            let lean = thick * CGFloat(scatter.next() - 0.5) * 2.8
            let narrow = thick * 0.24

            var trunk = Path()
            trunk.move(to: CGPoint(x: centre - thick / 2, y: foot))
            trunk.addQuadCurve(
                to: CGPoint(x: centre - narrow + lean, y: top),
                control: CGPoint(x: centre - thick * 0.44 + lean * 0.4, y: waist)
            )
            trunk.addLine(to: CGPoint(x: centre + narrow + lean, y: top))
            trunk.addQuadCurve(
                to: CGPoint(x: centre + thick / 2, y: foot),
                control: CGPoint(x: centre + thick * 0.44 + lean * 0.4, y: waist)
            )
            // A root flare, so the tree grows out of the ground rather than standing on it.
            trunk.addQuadCurve(
                to: CGPoint(x: centre - thick / 2, y: foot),
                control: CGPoint(x: centre, y: foot + thick * 0.28)
            )
            context.fill(trunk, with: .color(GamePalette.post))

            // The lit side, the same sliver of light the barn and every fence post in the game
            // carry, so a tree belongs to the same afternoon as everything else.
            var lit = Path()
            lit.move(to: CGPoint(x: centre - thick * 0.40, y: foot))
            lit.addQuadCurve(
                to: CGPoint(x: centre - narrow * 0.8 + lean, y: top),
                control: CGPoint(x: centre - thick * 0.35 + lean * 0.4, y: waist)
            )
            lit.addLine(to: CGPoint(x: centre - narrow * 0.2 + lean, y: top))
            lit.addQuadCurve(
                to: CGPoint(x: centre - thick * 0.12, y: foot),
                control: CGPoint(x: centre - thick * 0.10 + lean * 0.4, y: waist)
            )
            context.fill(
                lit,
                with: .linearGradient(
                    Gradient(colors: [
                        GamePalette.rail.opacity(colors.isNight ? 0.34 : 0.60),
                        GamePalette.rail.opacity(0)
                    ]),
                    startPoint: CGPoint(x: centre - thick * 0.40, y: foot),
                    endPoint: CGPoint(x: centre - thick * 0.05, y: foot)
                )
            )
        }
    }

    /// Light coming down through the leaves in slants. Wide at the top and narrowing as it
    /// falls, faint enough to be air rather than paint — the one thing that says there is a sky
    /// above a roof this thick.
    func drawShafts(in context: inout GraphicsContext, count: Int, lean: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        let fall = size.height * 0.8

        for index in 0..<count {
            let top = x((Double(index) + 0.3 + scatter.next() * 0.5) / Double(count))
            let wide = x(0.05 + scatter.next() * 0.05)
            let drop = fall * CGFloat(0.6 + scatter.next() * 0.5)
            let slant = x(lean)

            var shaft = Path()
            shaft.move(to: CGPoint(x: top - wide / 2, y: 0))
            shaft.addLine(to: CGPoint(x: top + wide / 2, y: 0))
            shaft.addLine(to: CGPoint(x: top + slant + wide * 0.16, y: drop))
            shaft.addLine(to: CGPoint(x: top + slant - wide * 0.16, y: drop))
            shaft.closeSubpath()

            context.fill(
                shaft,
                with: .linearGradient(
                    Gradient(colors: [
                        colors.discHalo.opacity(0.20),
                        colors.discHalo.opacity(0)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: drop)
                )
            )
        }
    }

    /// Mushrooms up through the leaf mould along a line across the frame: cream stems and
    /// terracotta caps, drawn exactly as the thicket's own boards dress themselves, so the
    /// amenity in the film is the amenity on the field.
    func drawMushrooms(
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
                y: y(baseline + (scatter.next() - 0.5) * 0.03)
            )
            let stem = x(0.011) * CGFloat(scale) * CGFloat(0.7 + scatter.next() * 0.7)
            let cap = stem * 1.9

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
        }
    }

    /// The mountain the thicket's send-off is about, standing a long way beyond the trees.
    ///
    /// Two faces meeting along a ridge that runs down from the summit, rather than one triangle
    /// with a light wash over half of it: the fold is what the eye reads as rock, and a wash
    /// over a flat shape only ever reads as a flat shape with a wash on it.
    ///
    /// `base` is where its feet are, and they are meant to be buried — the ground drawn after it
    /// laps over the bottom of the cone, so the mountain stands in the country rather than
    /// hovering over it. `haze` lays the sky back over the finished rock, which is what puts a
    /// mountain miles away rather than in the next field — distance is a colour before it is a
    /// size. `smoking` is the punchline: a plume off the top and a light in the crater, which is
    /// the only warm colour in the whole film.
    func drawPeak(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        smoking: Bool,
        haze: Double = 0
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        let tip = CGPoint(x: centre, y: foot - tall)
        let crown = span * 0.02
        let lit = Color(red: 0.30, green: 0.25, blue: 0.31)
        let shade = Color(red: 0.17, green: 0.14, blue: 0.19)
        let ember = Color(red: 0.95, green: 0.42, blue: 0.18)
        // Where the ridge comes down to the ground, which is what puts the two faces out of
        // square with each other and stops the mountain reading as a paper triangle.
        let hip = centre + span * 0.14

        var far = Path()
        far.move(to: CGPoint(x: hip, y: foot))
        far.addLine(to: CGPoint(x: tip.x, y: tip.y))
        far.addLine(to: CGPoint(x: tip.x + crown, y: tip.y))
        far.addLine(to: CGPoint(x: centre + span / 2, y: foot))
        far.closeSubpath()
        context.fill(far, with: .color(shade))

        var near = Path()
        near.move(to: CGPoint(x: centre - span / 2, y: foot))
        near.addLine(to: CGPoint(x: tip.x - crown, y: tip.y))
        near.addLine(to: CGPoint(x: tip.x, y: tip.y))
        near.addLine(to: CGPoint(x: hip, y: foot))
        near.closeSubpath()
        context.fill(near, with: .color(lit))

        // A cap of old ash sitting on the summit the way snow would, its lower edge broken so it
        // reads as lying on the rock rather than painted across it. A summit with a crater
        // burning in it has light enough of its own and goes without.
        let capDrop = tall * 0.14
        if !smoking {
            var cap = Path()
            cap.move(to: CGPoint(x: tip.x - crown, y: tip.y))
            cap.addLine(to: CGPoint(x: tip.x + crown, y: tip.y))
            cap.addLine(to: CGPoint(x: tip.x + crown + span * 0.055, y: tip.y + capDrop * 0.75))
            cap.addLine(to: CGPoint(x: tip.x + crown * 0.4, y: tip.y + capDrop * 0.45))
            cap.addLine(to: CGPoint(x: tip.x - crown * 0.6, y: tip.y + capDrop))
            cap.addLine(to: CGPoint(x: tip.x - crown - span * 0.05, y: tip.y + capDrop * 0.5))
            cap.closeSubpath()
            context.fill(cap, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.20 : 0.42)))
        }

        // The air between here and there, laid back over the lot of it.
        if haze > 0 {
            var whole = Path()
            whole.move(to: CGPoint(x: centre - span / 2, y: foot))
            whole.addLine(to: CGPoint(x: tip.x - crown, y: tip.y))
            whole.addLine(to: CGPoint(x: tip.x + crown, y: tip.y))
            whole.addLine(to: CGPoint(x: centre + span / 2, y: foot))
            whole.closeSubpath()
            context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
        }

        guard smoking else { return }

        // The plume: banks stacked straight off the crater, close enough together to be one
        // column of smoke rather than three clouds that happen to be passing.
        let lift = 0.5 + 0.5 * progress
        for bank in 0..<4 {
            let rise = tall * CGFloat(0.06 + Double(bank) * 0.075) * CGFloat(lift)
            let puff = span * CGFloat(0.10 + Double(bank) * 0.035)
            let sway = span * CGFloat(0.025 * Double(bank)) * CGFloat(progress)
            context.fill(
                cloudPath(at: CGPoint(x: tip.x + sway, y: tip.y - rise), width: puff),
                with: .color(GamePalette.cream.opacity(0.20 - 0.03 * Double(bank)))
            )
        }

        // The light in the crater, and the glow it throws up into what it is sending out.
        let crater = CGPoint(x: tip.x, y: tip.y + crown * 0.6)
        context.fill(
            circle(at: crater, radius: span * 0.16),
            with: .radialGradient(
                Gradient(colors: [ember.opacity(0.55), ember.opacity(0)]),
                center: crater,
                startRadius: span * 0.004,
                endRadius: span * 0.16
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: crater.x - crown * 1.1, y: crater.y - crown * 0.5,
                width: crown * 2.2, height: crown
            )),
            with: .color(ember.opacity(0.9))
        )
    }

    /// A few lights adrift in the dark under the trees, and kept low where the ground is. The
    /// thicket after dark gets fireflies where the meadow gets birds, and for the same reason:
    /// something has to be moving in a picture this still, or it reads as a painting of a wood
    /// rather than a wood.
    func drawFireflies(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let home = CGPoint(x: x(scatter.next(in: 0.05...0.95)), y: y(scatter.next(in: 0.55...0.86)))
            let phase = scatter.next() * 2 * .pi
            let drift = moves ? sin(progress * 2 * .pi + phase) : 0
            let glow = 0.35 + 0.65 * (moves ? (sin(progress * 4 * .pi + phase) + 1) / 2 : 0.7)
            let spot = CGPoint(x: home.x + x(0.012) * CGFloat(drift), y: home.y - y(0.008) * CGFloat(drift))

            context.fill(
                circle(at: spot, radius: x(0.014)),
                with: .radialGradient(
                    Gradient(colors: [
                        GamePalette.pen.opacity(0.55 * glow),
                        GamePalette.pen.opacity(0)
                    ]),
                    center: spot,
                    startRadius: 0,
                    endRadius: x(0.014)
                )
            )
            context.fill(circle(at: spot, radius: x(0.003)), with: .color(GamePalette.cream.opacity(0.85 * glow)))
        }
    }
}
