import Foundation
import SwiftUI
import UIKit

// MARK: - Cogsworth City, painted

/// The city's nine shots, and the nine brushes a world nobody grew turns out to need.
///
/// Three worlds of scenery came up out of the ground: a meadow, a wood, and a mountain that had
/// burnt the wood off itself. This one was put here. So the horizon is a skyline where the other
/// worlds have hills — a rank of blocks with their feet in the ground and their windows coming on
/// — the water is a canal with two straight banks and a wall along it, and the ground is setts
/// somebody laid in courses. Nothing in these films is a shape that happened by itself, and that
/// is the whole difference between the fourth world and the three behind it.
///
/// The pig is small in every one of them. A pig at the mouth of a wood is still the biggest thing
/// in the picture; a pig on a pavement under six storeys of somebody else's windows is a buyer
/// being shown the going rate. The three rules that hold these compositions together are the same
/// three the thicket was photographed under, only answered in brick: a rank of blocks has a dead
/// flat lower edge, so the paving or the canal is always laid over its feet; distance is the sky
/// laid back over the rock, or here over the brick; and nothing that matters goes where the words
/// go — the foot of the frame on a shot with a subtitle, the middle of it on the three cards.
extension Film {
    /// The city's two daylight films are lit under its own smoke, and the send-off falls into
    /// dusk — which is the one hour a city is worth looking at, since it is the only one where
    /// the lights are the picture rather than the weather.
    static func cogsworthLight(_ shot: CutScene.Picture.Cogsworth) -> GamePalette.Pasture {
        switch shot {
        case .cityHeld, .pastTheRooftops, .theFallingStar: .cityDusk
        default: .cityDay
        }
    }

    func drawCogsworth(_ shot: CutScene.Picture.Cogsworth, in context: inout GraphicsContext) {
        switch shot {
        case .theCityLine: drawTheCityLine(in: &context)
        case .pizzaAndTrash: drawPizzaAndTrash(in: &context)
        case .cityLiving: drawCityLiving(in: &context)
        case .theRoommate: drawTheRoommate(in: &context)
        case .neverLeaving: drawNeverLeaving(in: &context)
        case .onePenRoundBoth: drawOnePenRoundBoth(in: &context)
        case .cityHeld: drawCityHeld(in: &context)
        case .pastTheRooftops: drawPastTheRooftops(in: &context)
        case .theFallingStar: drawTheStarOverTheRooftops(in: &context)
        }
    }

    // MARK: - The city's opening

    /// The street running in under the rooftops, a lamp standing either side of it, and the pig
    /// on the paving at the foot of the frame walking into town. The thicket's tree line with
    /// landlords instead of trees: two ranks banked away, the far one hazed back into the smoke
    /// and the near one close enough to have windows in it.
    func drawTheCityLine(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.50))
        // A sun with the city's own chimneys between it and the street, so it is a bright patch
        // rather than a disc anybody could look at.
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.32)), radius: x(0.055), rays: false)
        drawClouds(in: &shot, at: 0.14, drift: 0.012 * progress)

        // Both ranks stand their feet well below the ground line rather than on it. A block whose
        // base is level with the ground leaves a slot of bare sky between the two wherever the
        // rank in front of it happens to be short, and a pale slot low in a city frame reads as a
        // wall somebody has left in the middle distance.
        drawCogsworthSkyline(
            in: &shot, base: 0.70, from: -0.12, to: 1.12,
            height: 0.44, seed: 601, color: colors.canopy, haze: 0.42
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.72, from: -0.12, to: 1.12,
            height: 0.27, seed: 607, color: colors.canopyShade, lit: 0.08
        )
        drawLand(in: &shot, ridge: 0.64, rise: 0.012, waves: 1.2, phase: 0.7, color: colors.ground)

        // The trail every world is strung along, in its city clothes: a pale roadway running away
        // between the blocks, with the setts laid over the top of it.
        drawTrail(in: &shot, from: 1.02, to: 0.64)
        drawCogsworthPaving(in: &shot, from: 0.64, to: 0.88, seed: 613)

        drawCogsworthLamp(in: &shot, at: 0.11, base: 0.88, height: 0.32, glow: 0)
        drawCogsworthLamp(in: &shot, at: 0.90, base: 0.92, height: 0.36, glow: 0)

        // On the pavement and starting up it, small against six storeys of somebody else's
        // property: the listing is the size of the picture, and the buyer is not.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.47), y: y(0.80 - 0.02 * along)),
            width: x(0.15 - 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawCogsworthSmuts(in: &shot, count: 10, seed: 617)
        // The near kerb, brought right up under the words. The roadway is the palest thing in the
        // frame and the caption is set in cream, so without a dark band across the foot of the
        // shot the line is written on the one surface it cannot be read on — and the road's own
        // flat bottom edge goes under the same band.
        drawLand(in: &shot, ridge: 0.865, rise: 0.008, waves: 1.0, phase: 2.4, color: colors.foreground)
    }

    /// The two halves of the scoring rule, one after the other on the same stretch of pavement:
    /// the pizza while the line is selling the neighbourhood, and then the trash can standing in
    /// exactly the same spot while the line is admitting what the neighbourhood does about its
    /// rubbish.
    ///
    /// The meadow says this in one picture, with an apple shut inside a pen and a skull staked
    /// outside it, because the meadow is teaching the rule for the first time. Three worlds on
    /// nobody needs teaching, so the shot changes hands instead — crossing over exactly where the
    /// caption changes sentence, with the light going off the spot as it goes.
    func drawPizzaAndTrash(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the selling point to the drawback: the first sentence has
        // faded out and the second is coming up, so the pavement may change hands under it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.40))
        drawSun(in: &shot, at: CGPoint(x: x(0.76), y: y(0.20)), radius: x(0.07), rays: false)

        drawCogsworthSkyline(
            in: &shot, base: 0.68, from: -0.12, to: 1.12,
            height: 0.46, seed: 619, color: colors.canopy, haze: 0.40
        )
        // The parade of shops the pizza came out of, banked up the right-hand side of the street
        // with its lights on in the middle of the afternoon.
        drawCogsworthSkyline(
            in: &shot, base: 0.68, from: 0.38, to: 1.16,
            height: 0.38, seed: 631, color: colors.canopyShade, lit: 0.22
        )
        // And the other side of the street, which the shot went without to begin with and paid
        // for in a quarter of the frame of flat pale nothing: a rank that stops halfway across
        // leaves the sky standing on the pavement beside it.
        drawCogsworthSkyline(
            in: &shot, base: 0.68, from: -0.20, to: 0.26,
            height: 0.30, seed: 647, color: colors.canopyShade, lit: 0.16
        )
        drawLand(in: &shot, ridge: 0.60, rise: 0.014, waves: 1.3, phase: 2.4, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.60, to: 0.92, seed: 641)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.27), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        // The selling point, stood in its own light outside the shop that dropped it.
        var amenity = shot
        amenity.opacity = 1 - turn
        let spot = CGPoint(x: x(0.63), y: y(0.78))
        amenity.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.28)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.55), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.28)
            )
        )
        drawTreat(in: &amenity, "🍕", at: spot, width: x(0.22))

        // And the collection, in the same spot with the light off it and one of its friends
        // further up the kerb, because they never do come out one at a time.
        var drawback = shot
        drawback.opacity = turn
        drawTreat(in: &drawback, "🗑️", at: spot, width: x(0.22))
        drawTreat(in: &drawback, "🗑️", at: CGPoint(x: x(0.88), y: y(0.84)), width: x(0.10))

        drawCogsworthSmuts(in: &shot, count: 8, seed: 643)
        drawLand(in: &shot, ridge: 0.90, rise: 0.008, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The towpath along the canal at the foot of the city, railings between the water and the
    /// walk, and the pig going along it as though it lived here. Everything a listing means by
    /// walkable, in one picture: somewhere to walk to, something to look at on the way, and a
    /// rail so nobody ends up in the cut.
    ///
    /// The card sets its line across the middle of the frame, so the middle of the frame is water
    /// and nothing else — the blocks are up above it and the pig is down below it.
    func drawCityLiving(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.28))
        drawCogsworthSkyline(
            in: &shot, base: 0.42, from: -0.12, to: 1.12,
            height: 0.34, seed: 647, color: colors.canopy, haze: 0.35
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.44, from: 0.54, to: 1.14,
            height: 0.26, seed: 653, color: colors.canopyShade, lit: 0.14
        )
        drawLand(in: &shot, ridge: 0.34, rise: 0.010, waves: 1.2, phase: 1.1, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.34, to: 0.53, seed: 659)

        // The cut itself, dug straight across the frame: two parallel banks and a wall, which is
        // the one thing no river in the first three worlds could ever be mistaken for.
        //
        // It is brought up into the middle of the frame on purpose. A card lays its line across
        // the waist of the picture, and the shot as first composed put nothing there but an acre
        // of flat pavement — the water carries the same words with something in it to look at.
        drawCogsworthCanal(in: &shot, from: 0.53, to: 0.68, lamps: [0.88], seed: 661)

        drawLand(in: &shot, ridge: 0.68, rise: 0.006, waves: 1.0, phase: 0.4, color: colors.foreground)
        drawCogsworthPaving(in: &shot, from: 0.68, to: 1.02, seed: 673)
        drawCogsworthRailing(in: &shot, base: 0.69, height: 0.07, from: -0.06, to: 1.06, bars: 24)
        drawCogsworthLamp(in: &shot, at: 0.88, base: 0.90, height: 0.28, glow: 0)
        // The one thing on the near pavement besides the pig, and the rat's front door besides:
        // an empty towpath with a single small animal on it is a grey field with a mistake in it.
        drawCogsworthDrain(in: &shot, at: CGPoint(x: x(0.72), y: y(0.90)), width: x(0.20))

        // Walking it rather than standing on it, because the line is about getting used to a
        // place and nobody gets used to anywhere stood still. Bigger than the pig in the other
        // two shots of this film: those are pictures of the city, and this one is the pig's.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.30 + 0.06 * along), y: y(0.86)),
            width: x(0.20),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawCogsworthSmuts(in: &shot, count: 7, seed: 677)
    }

    // MARK: - Rat King Wharf

    /// The rat coming up out of its drain as the shot runs, with the pig backed against the
    /// warehouse wall of a property it had believed it was buying on its own. Every other world
    /// introduces its resident by walking it in from the edge of the frame; this one was already
    /// inside, which is what a roommate is.
    func drawTheRoommate(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawCogsworthSkyline(
            in: &shot, base: 0.66, from: -0.12, to: 1.12,
            height: 0.42, seed: 683, color: colors.canopy, haze: 0.38
        )
        // The wharf's own warehouses, close enough to be a wall rather than a view.
        drawCogsworthSkyline(
            in: &shot, base: 0.70, from: -0.14, to: 0.66,
            height: 0.44, seed: 691, color: colors.canopyShade, lit: 0.16
        )
        // The water laid over their feet, which is how a building stands on a wharf rather than
        // on a shelf: the cut goes right up to the wall and always has.
        drawCogsworthCanal(in: &shot, from: 0.60, to: 0.72, lamps: [0.82], seed: 701)

        drawLand(in: &shot, ridge: 0.72, rise: 0.008, waves: 1.1, phase: 0.6, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.72, to: 0.98, seed: 709)
        drawCogsworthRailing(in: &shot, base: 0.73, height: 0.055, from: -0.06, to: 1.06, bars: 22)

        // Its front door, and the tenant coming up through it — growing rather than walking in,
        // because there is no distance for it to arrive across. It lives under the floor.
        // Both of them stand a good deal higher up the quay than they first did. The line over
        // this shot runs to two lines on a phone, and at that length the words come up far enough
        // to take the grate and the rat's feet with them.
        let arrived = easeOut(min(progress / 0.8, 1))
        let hole = CGPoint(x: x(0.37), y: y(0.795))
        drawCogsworthDrain(in: &shot, at: hole, width: x(0.17))
        drawAnimal(
            in: &shot,
            .rat,
            feet: CGPoint(x: hole.x, y: hole.y - y(0.004)),
            width: x(0.08 + 0.08 * arrived),
            shadow: 0.5
        )

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.76), y: y(0.79)), width: x(0.17), lean: -5)

        drawCogsworthSmuts(in: &shot, count: 8, seed: 719)
        // A near kerb under the words, the same as the rest of the world's daylight shots get:
        // pale setts are the worst thing this palette owns to letter cream across.
        drawLand(in: &shot, ridge: 0.855, rise: 0.008, waves: 1.0, phase: 1.7, color: colors.foreground)
    }

    /// The pig with a shoulder into the rat and the rat not registering it. The thicket's two
    /// neighbours stand back to back either side of a tree, agreeing; these two are in contact,
    /// and only one of them is trying.
    ///
    /// Everything in the frame moves a little — the smuts, the pig leaning and giving up and
    /// leaning again — except the rat, which is drawn at the same size in the same place for the
    /// whole shot. That is the caption, and there is no other way to say it in a picture.
    func drawNeverLeaving(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawCogsworthSkyline(
            in: &shot, base: 0.72, from: -0.12, to: 1.12,
            height: 0.42, seed: 727, color: colors.canopy, haze: 0.40
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.74, from: -0.14, to: 1.14,
            height: 0.34, seed: 733, color: colors.canopyShade, lit: 0.20
        )
        drawLand(in: &shot, ridge: 0.66, rise: 0.012, waves: 1.2, phase: 0.9, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.66, to: 0.98, seed: 739)
        drawCogsworthLamp(in: &shot, at: 0.13, base: 0.88, height: 0.34, glow: 0)

        // The shove, and the coming back for another go at it. Close enough to be touching the
        // rat: at arm's length the two of them are simply an animal each and the caption is doing
        // all the work, and the shot is meant to be the one place in the film where they meet.
        let heave = sin(progress * 2 * .pi * 1.5)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.45) + x(0.012 * heave), y: y(0.80)),
            width: x(0.19),
            lean: 11 + 5 * heave
        )

        // Sat on the grate it holds the freehold to, at the size and in the place it will still
        // be in when the shot cuts away.
        let hole = CGPoint(x: x(0.66), y: y(0.80))
        drawCogsworthDrain(in: &shot, at: hole, width: x(0.22))
        drawAnimal(in: &shot, .rat, feet: CGPoint(x: hole.x, y: hole.y - y(0.004)), width: x(0.17))

        drawCogsworthSmuts(in: &shot, count: 9, seed: 743)
        drawLand(in: &shot, ridge: 0.855, rise: 0.008, waves: 1.0, phase: 1.1, color: colors.foreground)
    }

    /// One pen, opening from between the two of them and taking in both: the only rule in the
    /// game that fences two animals together, drawn rather than written.
    ///
    /// The mere splits one pen into two and the hollow opens two that never touch. This one goes
    /// the other way — it starts as a line round nothing much and grows outwards until the pig
    /// and the rat are inside the same fence, because that is what compromise looks like from
    /// above. The street is left bare and the blocks pushed up out of the way, so the middle of
    /// the frame is clear for the words.
    func drawOnePenRoundBoth(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.24))
        drawCogsworthSkyline(
            in: &shot, base: 0.36, from: -0.12, to: 1.12,
            height: 0.19, seed: 751, color: colors.canopyShade, lit: 0.12, haze: 0.30
        )
        drawLand(in: &shot, ridge: 0.28, rise: 0.010, waves: 1.2, phase: 2.4, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.28, to: 1.02, seed: 757)

        // A lamp down the left edge and a grate over on the right, both outside the pen and both
        // clear of the words. The shot was composed bare on the argument that a card is a diagram
        // — and photographed as better than half a screen of flat paving with nothing in it. Two
        // pieces of street furniture at the margins cost the diagram nothing and give the eye the
        // scale of the place it is being asked to fence.
        drawCogsworthLamp(in: &shot, at: 0.07, base: 0.99, height: 0.28, glow: 0)
        drawCogsworthDrain(in: &shot, at: CGPoint(x: x(0.92), y: y(0.92)), width: x(0.19))

        let rat = CGPoint(x: x(0.60), y: y(0.80))
        let pig = CGPoint(x: x(0.40), y: y(0.84))

        drawAnimal(in: &shot, .rat, feet: rat, width: x(0.15), shadow: 0.7)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.17))

        // Out from between them rather than in from the edges, so the shot reads as one plan
        // being made larger to fit two tenants instead of two plans being drawn at once.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(
            in: &shot,
            round: CGPoint(x: x(0.50), y: y(0.84)),
            width: 0.34 + 0.30 * drawn,
            height: 0.13 + 0.07 * drawn,
            drop: 0.012,
            opacity: 0.9 * drawn
        )

        // No lamp and no railing in this one. Ironwork along the edge of a card is a border
        // rather than a city, and the shot is a diagram: two tenants, one fence, and the words
        // across the middle of it.
        drawCogsworthSmuts(in: &shot, count: 6, seed: 761)
    }

    // MARK: - The city held

    /// The pen holding across the whole front of the wharf after dark, with both of them inside
    /// it, a slice going spare on the paving and the windows coming on over the water. The
    /// thicket's send-off puts a fence between the neighbours and calls it peaceful; the city's
    /// puts them in the same one and calls it a minor rodent situation.
    func drawCityHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawCogsworthStars(in: &shot, count: 12, seed: 769)
        // The disc at this hour is the moon, and it is losing to the windows.
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.13)), radius: x(0.045), rays: false)

        drawCogsworthSkyline(
            in: &shot, base: 0.60, from: -0.12, to: 1.12,
            height: 0.40, seed: 773, color: colors.canopy, lit: 0.34, haze: 0.26
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.62, from: -0.12, to: 1.12,
            height: 0.40, seed: 787, color: colors.canopyShade, lit: 0.55
        )
        // The lamps are stood on the far bank rather than on the near quay, where they would be
        // inside the pen and reading as somebody's garden lighting. Over there they light the
        // water instead, which is what a canal is for after dark, and the cut laps over their
        // feet on the way past.
        drawCogsworthLamp(in: &shot, at: 0.13, base: 0.528, height: 0.20, glow: 1)
        drawCogsworthLamp(in: &shot, at: 0.85, base: 0.528, height: 0.22, glow: 1)
        drawCogsworthCanal(in: &shot, from: 0.54, to: 0.64, lamps: [0.13, 0.85], seed: 797)

        drawLand(in: &shot, ridge: 0.64, rise: 0.008, waves: 1.1, phase: 0.8, color: colors.ground)
        drawCogsworthPaving(in: &shot, from: 0.64, to: 1.02, seed: 809)
        drawCogsworthRailing(in: &shot, base: 0.65, height: 0.05, from: -0.06, to: 1.06, bars: 26)

        // One pen across the front of the wharf with the pair of them in it, which is the shape
        // the whole world's last puzzle ends in.
        let pen = CGPoint(x: x(0.50), y: y(0.84))
        drawCogsworthPenWash(in: &shot, round: pen, width: 0.88, height: 0.22, drop: 0.0)
        drawTreat(in: &shot, "🍕", at: CGPoint(x: x(0.20), y: y(0.77)), width: x(0.05))
        drawTreat(in: &shot, "🍕", at: CGPoint(x: x(0.78), y: y(0.80)), width: x(0.05))
        drawAnimal(in: &shot, .rat, feet: CGPoint(x: x(0.66), y: y(0.76)), width: x(0.11), shadow: 0.6)
        // Stood inside the pen rather than on its front rail, which is where the fence was
        // crossing the pig's face.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.40), y: y(0.805)), width: x(0.16))
        drawPenFence(in: &shot, round: pen, width: 0.88, height: 0.22, drop: 0.0)

        drawCogsworthSmuts(in: &shot, count: 8, seed: 811)
    }

    /// The pig up on the roof of the thing it has just finished buying, with the rest of the city
    /// lit below it and its head tipped back. The thicket looked over the trees at a mountain and
    /// the mountain looked down at these lights; from up here there is nothing left along the
    /// ground that has not already got somebody on it, so the only listing left is overhead —
    /// and it is small, and very far off, and already on its way.
    func drawPastTheRooftops(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawCogsworthStars(in: &shot, count: 16, seed: 821)
        // The moon is pushed off to the corner. Where it was, its halo — four radii wide — sat
        // straight over the star this shot exists to point at, and the one thing the pig is
        // looking at was the one thing washed out.
        drawSun(in: &shot, at: CGPoint(x: x(0.90), y: y(0.12)), radius: x(0.05), rays: false)

        drawCogsworthSkyline(
            in: &shot, base: 0.76, from: -0.12, to: 1.12,
            height: 0.36, seed: 823, color: colors.canopy, lit: 0.40, haze: 0.24
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.80, from: -0.12, to: 1.12,
            height: 0.28, seed: 827, color: colors.canopyShade, lit: 0.58
        )

        // The roof underfoot, laid over the feet of the block it belongs to, with the parapet
        // rail along the far side of it: this is the pig's, and the rest of it is the view.
        //
        // Drawn twice, a whisker apart, and the lower band pale: what shows between the two is a
        // line of light along the coping. Without it the roof is the same black as the blocks
        // behind it and the pig stands on nothing at all — the ironwork cannot save it either,
        // being black on black at this hour.
        drawLand(in: &shot, ridge: 0.752, rise: 0.006, waves: 1.0, phase: 0.5, color: GamePalette.stone.opacity(0.5))
        drawLand(in: &shot, ridge: 0.760, rise: 0.006, waves: 1.0, phase: 0.5, color: colors.foreground)
        drawCogsworthRailing(in: &shot, base: 0.80, height: 0.05, from: 0.52, to: 1.10, bars: 12)

        // Turned away and looking up, which is the pose this pig ends every world in. It stands
        // well up its own roof: this caption runs to two lines, and at the foot of the frame the
        // words were being read through the pig's chin.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.33), y: y(0.79)), width: x(0.16), lean: -6)

        // The next listing, at the distance it is still possible to mistake for a star.
        drawCogsworthFallingStar(
            in: &shot,
            from: CGPoint(x: x(0.42), y: y(0.13)),
            to: CGPoint(x: x(0.34), y: y(0.29)),
            reach: x(0.022),
            along: 0.10 + 0.14 * progress
        )

        drawCogsworthSmuts(in: &shot, count: 7, seed: 829)
    }

    /// The same star, no longer arguable: coming down over the rooftops on a flat arc with its
    /// tail behind it, while the city sits along the bottom of the frame minding its own
    /// business. Four worlds of the pig walking towards the next listing, and this one is coming
    /// to him.
    ///
    /// The card wants the middle of the frame, so the star is given the top of it and the city
    /// the bottom, and the pig is a silhouette on a roofline rather than anything anybody has to
    /// look for.
    func drawTheStarOverTheRooftops(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.60))
        drawCogsworthStars(in: &shot, count: 18, seed: 839)

        drawCogsworthSkyline(
            in: &shot, base: 0.92, from: -0.12, to: 1.12,
            height: 0.30, seed: 853, color: colors.canopy, lit: 0.34, haze: 0.24
        )
        drawCogsworthSkyline(
            in: &shot, base: 0.96, from: -0.12, to: 1.12,
            height: 0.32, seed: 857, color: colors.canopyShade, lit: 0.52
        )
        // The same lit coping as the shot before it, and for the same reason: this roof and the
        // blocks it is cut out of are within a shade of each other, so without a line of light
        // along its edge the pig is a sticker on a wall of buildings rather than an animal stood
        // on top of one.
        drawLand(in: &shot, ridge: 0.874, rise: 0.006, waves: 1.0, phase: 2.6, color: GamePalette.stone.opacity(0.5))
        drawLand(in: &shot, ridge: 0.882, rise: 0.006, waves: 1.0, phase: 2.6, color: colors.foreground)

        // Small, on the roofline, and watching it come. The whole journey in one silhouette,
        // except that this time the pig is standing still and the property is doing the moving.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.28), y: y(0.905)),
            width: x(0.11),
            lean: -8,
            shadow: 0.4
        )

        // Straight across the top of the frame and down, and linear rather than eased, so a
        // player who has asked for less motion is handed the middle of the arc rather than
        // either end of it.
        drawCogsworthFallingStar(
            in: &shot,
            from: CGPoint(x: x(0.12), y: y(0.06)),
            to: CGPoint(x: x(0.78), y: y(0.32)),
            reach: x(0.055),
            along: progress
        )
    }

    // MARK: - What a city is made of

    /// The horizon of every shot in this world: a rank of blocks stood along a baseline, each one
    /// a different width and height, with a parapet across the top, a lit face down one side and
    /// a shaded one down the other.
    ///
    /// The fold is doing the same job the fold on the thicket's mountain does — a flat slab with a
    /// wash over half of it reads as a slab, and two faces meeting on an edge read as a building
    /// — and `haze` is the same trick as well: the sky laid back over the finished brick, which is
    /// what puts a rank half a mile away instead of across the road. `lit` is the fraction of the
    /// windows that have somebody in. It is small by day, since a window with the sun on it is a
    /// dark hole, and most of the way up after dark, which is the only reason to look at a city
    /// at all.
    ///
    /// Like every rank in the game it is drawn feet-first and expects the caller to lay the
    /// paving, the ground or the canal over the bottom of it afterwards.
    func drawCogsworthSkyline(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        seed: UInt64,
        color: Color,
        lit: Double = 0,
        haze: Double = 0
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        let tallest = y(height)
        let end = x(to)
        let sink = y(0.04)

        var mass = Path()
        var panes = Path()
        var litPanes = Path()
        var across = x(from)

        while across < end {
            let wide = x(0.085) * CGFloat(0.5 + scatter.next() * 1.1)
            let tall = tallest * CGFloat(0.40 + scatter.next() * 0.85)
            let body = CGRect(x: across, y: foot - tall, width: wide, height: tall + sink)
            let parapet = CGRect(
                x: body.minX - wide * 0.05, y: body.minY - tallest * 0.022,
                width: wide * 1.10, height: tallest * 0.03
            )

            context.fill(Path(body), with: .color(color))
            context.fill(Path(parapet), with: .color(color))
            mass.addRect(body)
            mass.addRect(parapet)

            // The two faces. Sunlight in a city arrives off whatever is across the street, so the
            // lit side is a narrow one and the shaded side does most of the work.
            context.fill(
                Path(CGRect(x: body.minX, y: body.minY, width: wide * 0.20, height: body.height)),
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.13))
            )
            context.fill(
                Path(CGRect(x: body.maxX - wide * 0.26, y: body.minY, width: wide * 0.26, height: body.height)),
                with: .color(.black.opacity(0.16))
            )

            // A chimney or a tank on about half the roofs, which is what stops a rank of blocks
            // reading as a bar chart.
            if scatter.next() < 0.5 {
                let stack = CGRect(
                    x: body.midX + wide * CGFloat(scatter.next() * 0.28 - 0.08),
                    y: parapet.minY - tallest * CGFloat(0.06 + scatter.next() * 0.08),
                    width: wide * 0.16,
                    height: tallest * 0.14
                )
                context.fill(Path(stack), with: .color(color))
                mass.addRect(stack)
            }

            // Windows, on anything near enough and tall enough to have them read as windows
            // rather than as grain in the paint.
            if wide > x(0.048) && tall > tallest * 0.45 {
                let step = x(0.026)
                let course = y(0.030)
                let columns = max(2, Int((wide - x(0.014)) / step))
                let rows = max(2, Int((tall - y(0.020)) / course))
                let paneWide = step * 0.46
                let paneTall = course * 0.44
                let inset = (wide - step * CGFloat(columns)) / 2

                for column in 0..<columns {
                    for row in 0..<rows {
                        let pane = CGRect(
                            x: body.minX + inset + step * CGFloat(column) + step * 0.27,
                            y: body.minY + course * CGFloat(row) + course * 0.5,
                            width: paneWide,
                            height: paneTall
                        )
                        if scatter.next() < lit {
                            litPanes.addRect(pane)
                        } else {
                            panes.addRect(pane)
                        }
                    }
                }
            }

            across += wide + x(0.004)
        }

        context.fill(panes, with: .color(.black.opacity(colors.isNight ? 0.42 : 0.24)))
        context.fill(litPanes, with: .color(GamePalette.pen.opacity(colors.isNight ? 0.88 : 0.55)))

        // The air between here and there, laid back over the lot of it.
        if haze > 0 {
            context.fill(mass, with: .color(colors.skyHorizon.opacity(haze)))
        }
    }

    /// The ground of the fourth world: setts in courses, laid in a bond that shifts a half stone
    /// every other course, and opening out as they come down the frame.
    ///
    /// The board's own paving is drawn on a flat grid, because a board is looked at from straight
    /// above. A film is looked at from the pavement, so the courses here grow as they approach —
    /// which is the only perspective anywhere in these films, and the only thing that stops a
    /// street reading as a tiled wall somebody has laid the camera on. Each stone is a shade off
    /// its neighbour and nothing more; paving is a texture, not a subject.
    func drawCogsworthPaving(
        in context: inout GraphicsContext,
        from top: Double,
        to bottom: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let hem = y(bottom)
        let start = -size.width * 0.5
        let end = size.width * 1.5

        var pale = Path()
        var dark = Path()
        var level = y(top)
        var course = y(0.010)
        var offset = false

        while level < hem {
            let sett = course * 3.0
            var across = start + (offset ? sett / 2 : 0)
            while across < end {
                let stone = CGRect(
                    x: across + sett * 0.05, y: level + course * 0.10,
                    width: sett * 0.90, height: course * 0.80
                )
                if scatter.next() < 0.5 {
                    pale.addRoundedRect(
                        in: stone,
                        cornerSize: CGSize(width: course * 0.2, height: course * 0.2)
                    )
                } else {
                    dark.addRoundedRect(
                        in: stone,
                        cornerSize: CGSize(width: course * 0.2, height: course * 0.2)
                    )
                }
                across += sett
            }
            offset.toggle()
            level += course
            course *= 1.16
        }

        context.fill(pale, with: .color(.white.opacity(colors.isNight ? 0.02 : 0.06)))
        context.fill(dark, with: .color(.black.opacity(colors.isNight ? 0.11 : 0.07)))
    }

    /// The canal: a band of standing water between two straight banks, dark at the far side and
    /// with the sky lying on the near one.
    ///
    /// Nothing about it is a river. The meadow's water is a wash with a wandering edge; this has
    /// two parallel banks and a coping stone along the top, because somebody dug it and somebody
    /// walled it. What moves in it is the only thing that moves in a cut — a few flat ripples
    /// working sideways — and `lamps` drops a column of light into the water under each lamp
    /// stood on the quay above, which is what a canal is for after dark.
    func drawCogsworthCanal(
        in context: inout GraphicsContext,
        from top: Double,
        to bottom: Double,
        lamps: [Double],
        seed: UInt64
    ) {
        let head = y(top)
        let hem = y(bottom)
        let deep = Color(red: 0.13, green: 0.16, blue: 0.18)
        let cut = Path(CGRect(x: -size.width, y: head, width: size.width * 3, height: hem - head))

        // Opaque by day and not by night, which is not an inconsistency but the difference
        // between the two hours. Daylight water hides what is under it: laid on translucent it
        // let the warehouses behind show straight through the cut, and a canal you can see a
        // building through is fog. After dark the same translucency is the whole point — the lit
        // windows above come through the water directly under themselves, which is what a
        // reflection is, and it costs nothing to draw.
        context.fill(
            cut,
            with: .color(
                colors.isNight
                    ? deep.opacity(0.90)
                    : Color(red: 0.29, green: 0.33, blue: 0.32)
            )
        )
        // The sky lying on the water, strongest at the far bank where the eye is looking across
        // it rather than into it.
        context.fill(
            cut,
            with: .linearGradient(
                Gradient(colors: [colors.skyHorizon.opacity(0.42), colors.skyHorizon.opacity(0.04)]),
                startPoint: CGPoint(x: 0, y: head),
                endPoint: CGPoint(x: 0, y: hem)
            )
        )

        // The coping along the far bank: one pale course of stone, which is what makes the top
        // edge of the water read as a wall rather than as a shoreline.
        context.fill(
            Path(CGRect(x: -size.width, y: head - y(0.008), width: size.width * 3, height: y(0.008))),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.24 : 0.42))
        )

        for lamp in lamps {
            let column = CGPoint(x: x(lamp), y: head)
            context.fill(
                Path(CGRect(
                    x: column.x - x(0.014), y: head,
                    width: x(0.028), height: (hem - head) * 0.9
                )),
                with: .linearGradient(
                    Gradient(colors: [
                        GamePalette.pen.opacity(colors.isNight ? 0.45 : 0.14),
                        GamePalette.pen.opacity(0)
                    ]),
                    startPoint: column,
                    endPoint: CGPoint(x: column.x, y: hem)
                )
            )
        }

        var scatter = Scatter(seed: seed)
        var ripples = Path()
        for _ in 0..<16 {
            let level = head + (hem - head) * CGFloat(scatter.next(in: 0.14...0.92))
            let centre = x(scatter.next(in: -0.05...1.05))
            let wide = x(scatter.next(in: 0.04...0.16))
            let sway = x(0.010) * CGFloat(moves ? sin(progress * 2 * .pi + scatter.next() * 6.28) : 0)
            ripples.move(to: CGPoint(x: centre - wide / 2 + sway, y: level))
            ripples.addLine(to: CGPoint(x: centre + wide / 2 + sway, y: level))
        }
        context.stroke(
            ripples,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.16 : 0.26)),
            style: StrokeStyle(lineWidth: max(1, y(0.002)), lineCap: .round)
        )
    }

    /// Wrought iron along the edge of a quay or the parapet of a roof: two rails, an upright every
    /// pitch, and a heavier standard with a spearhead on it every fourth one.
    ///
    /// Thin, black and regular, which is the point of it — a rail is the one thing in the city
    /// that is allowed to be a straight line, and it is what tells the eye that the pale band
    /// beyond it is water and not more pavement. It is drawn light enough to see the shot
    /// through, since it is always in front of something the shot is about.
    func drawCogsworthRailing(
        in context: inout GraphicsContext,
        base: Double,
        height: Double,
        from: Double,
        to: Double,
        bars: Int
    ) {
        let foot = y(base)
        let tall = y(height)
        let start = x(from)
        let pitch = (x(to) - start) / CGFloat(max(bars - 1, 1))
        let iron = Color(red: 0.10, green: 0.10, blue: 0.12)
            .opacity(colors.isNight ? 0.90 : 0.78)

        var light = Path()
        for rail in [0.96, 0.36] {
            let level = foot - tall * CGFloat(rail)
            light.move(to: CGPoint(x: start, y: level))
            light.addLine(to: CGPoint(x: x(to), y: level))
        }
        for bar in 0..<bars where bar % 4 != 0 {
            let along = start + pitch * CGFloat(bar)
            light.move(to: CGPoint(x: along, y: foot))
            light.addLine(to: CGPoint(x: along, y: foot - tall))
        }
        context.stroke(light, with: .color(iron), lineWidth: max(1, x(0.0035)))

        var heavy = Path()
        var finials = Path()
        for bar in stride(from: 0, to: bars, by: 4) {
            let along = start + pitch * CGFloat(bar)
            let head = foot - tall * 1.16
            heavy.move(to: CGPoint(x: along, y: foot))
            heavy.addLine(to: CGPoint(x: along, y: head))

            let spear = tall * 0.18
            finials.move(to: CGPoint(x: along, y: head - spear))
            finials.addLine(to: CGPoint(x: along + spear * 0.42, y: head))
            finials.addLine(to: CGPoint(x: along, y: head + spear * 0.5))
            finials.addLine(to: CGPoint(x: along - spear * 0.42, y: head))
            finials.closeSubpath()
        }
        context.stroke(heavy, with: .color(iron), lineWidth: max(1.5, x(0.006)))
        context.fill(finials, with: .color(iron))
    }

    /// A lamp post: a tapered column on a plinth with a lantern on top of it.
    ///
    /// `glow` is what hour it is. Unlit it is a black shape standing in the street, which is all a
    /// lamp is by day and worth having anyway, since a street with lamps down it is a street and a
    /// street without them is a road. Lit, it is the warmest thing in the frame — the city's dusk
    /// palette takes its colour from these rather than from the sky, which has gone out entirely
    /// by the time they come on.
    func drawCogsworthLamp(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        glow: Double
    ) {
        let foot = CGPoint(x: x(across), y: y(base))
        let tall = y(height)
        let iron = Color(red: 0.10, green: 0.10, blue: 0.13)
            .opacity(colors.isNight ? 0.94 : 0.82)
        let head = CGPoint(x: foot.x, y: foot.y - tall)

        if glow > 0 {
            let lit = CGPoint(x: head.x, y: head.y - tall * 0.09)
            context.fill(
                circle(at: lit, radius: tall * 0.42),
                with: .radialGradient(
                    Gradient(colors: [
                        GamePalette.pen.opacity(0.34 * glow),
                        GamePalette.pen.opacity(0)
                    ]),
                    center: lit,
                    startRadius: tall * 0.02,
                    endRadius: tall * 0.42
                )
            )
        }

        var column = Path()
        column.move(to: CGPoint(x: foot.x - tall * 0.040, y: foot.y))
        column.addQuadCurve(
            to: CGPoint(x: head.x - tall * 0.014, y: head.y),
            control: CGPoint(x: foot.x - tall * 0.020, y: foot.y - tall * 0.5)
        )
        column.addLine(to: CGPoint(x: head.x + tall * 0.014, y: head.y))
        column.addQuadCurve(
            to: CGPoint(x: foot.x + tall * 0.040, y: foot.y),
            control: CGPoint(x: foot.x + tall * 0.020, y: foot.y - tall * 0.5)
        )
        column.closeSubpath()
        context.fill(column, with: .color(iron))

        context.fill(
            Path(roundedRect: CGRect(
                x: foot.x - tall * 0.075, y: foot.y - tall * 0.05,
                width: tall * 0.15, height: tall * 0.06
            ), cornerRadius: tall * 0.012),
            with: .color(iron)
        )

        // The lantern: a glass that widens downwards, with a cap over it. Filled with the pen's
        // own gold when it is burning, so the light in a city film is the same colour as a pen
        // that holds.
        var glass = Path()
        glass.move(to: CGPoint(x: head.x - tall * 0.070, y: head.y - tall * 0.010))
        glass.addLine(to: CGPoint(x: head.x + tall * 0.070, y: head.y - tall * 0.010))
        glass.addLine(to: CGPoint(x: head.x + tall * 0.046, y: head.y - tall * 0.150))
        glass.addLine(to: CGPoint(x: head.x - tall * 0.046, y: head.y - tall * 0.150))
        glass.closeSubpath()
        context.fill(
            glass,
            with: .color(
                glow > 0
                    ? GamePalette.pen.opacity(0.55 + 0.40 * glow)
                    : GamePalette.cream.opacity(colors.isNight ? 0.16 : 0.30)
            )
        )
        context.stroke(glass, with: .color(iron), lineWidth: max(1, tall * 0.012))

        var cap = Path()
        cap.move(to: CGPoint(x: head.x - tall * 0.062, y: head.y - tall * 0.150))
        cap.addLine(to: CGPoint(x: head.x + tall * 0.062, y: head.y - tall * 0.150))
        cap.addLine(to: CGPoint(x: head.x, y: head.y - tall * 0.215))
        cap.closeSubpath()
        context.fill(cap, with: .color(iron))
    }

    /// The gold a held pen is washed with, mixed for a city after dark.
    ///
    /// The shared wash is mixed for a meadow: near-opaque gold laid over pale daylit grass, where
    /// it reads as the light of a good afternoon lying on the field. This world's dusk ground is
    /// very nearly black, and the same wash came out of the camera as a solid gold card with two
    /// animals stood on it — a quarter of the screen, the brightest thing in the film by a
    /// distance, and the only bright thing in it that is not a light source. So the pen is laid on
    /// at a fraction of the strength here, and brightest along its far rail where the lamps are,
    /// which makes it lit paving rather than a slab. It is the same colour either way, because a
    /// pen that holds has to be the same news in every world.
    func drawCogsworthPenWash(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double
    ) {
        let pen = penBounds(round: feet, width: width, height: height, drop: drop)
        let shape = penRect(round: feet, width: width, height: height, drop: drop)

        context.fill(shape, with: .color(GamePalette.pen.opacity(0.18)))
        context.fill(
            shape,
            with: .linearGradient(
                Gradient(colors: [GamePalette.pen.opacity(0.30), GamePalette.pen.opacity(0.03)]),
                startPoint: CGPoint(x: pen.midX, y: pen.minY),
                endPoint: CGPoint(x: pen.midX, y: pen.maxY)
            )
        )
    }

    /// A drain in the kerb: a dark mouth with bars across it. The board's own paving has these
    /// scattered over it as dressing, and the film keeps them for one reason — this is where the
    /// rat lives, so it is the only piece of street furniture in the world with a tenant.
    func drawCogsworthDrain(in context: inout GraphicsContext, at foot: CGPoint, width: CGFloat) {
        let grate = CGRect(
            x: foot.x - width / 2, y: foot.y - width * 0.30,
            width: width, height: width * 0.34
        )
        context.fill(
            Path(roundedRect: grate, cornerRadius: width * 0.05),
            with: .color(Color(red: 0.09, green: 0.09, blue: 0.10).opacity(colors.isNight ? 0.85 : 0.72))
        )

        var bars = Path()
        for line in [0.22, 0.38, 0.54, 0.70] {
            let along = grate.minX + grate.width * CGFloat(line)
            bars.move(to: CGPoint(x: along, y: grate.minY + grate.height * 0.18))
            bars.addLine(to: CGPoint(x: along, y: grate.maxY - grate.height * 0.18))
        }
        context.stroke(
            bars,
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.30 : 0.55)),
            style: StrokeStyle(lineWidth: max(1, width * 0.035), lineCap: .round)
        )

        // The lip of the kerbstone the grate is set into, so it lies in the road rather than on
        // top of it.
        context.fill(
            Path(roundedRect: CGRect(
                x: grate.minX - width * 0.06, y: grate.minY - width * 0.05,
                width: grate.width + width * 0.12, height: width * 0.05
            ), cornerRadius: width * 0.02),
            with: .color(GamePalette.stone.opacity(colors.isNight ? 0.22 : 0.40))
        )
    }

    /// Smuts: flakes of soot going up on the warm air off the chimneys, and drifting sideways
    /// while they do it.
    ///
    /// The thicket gets fireflies and the meadow gets birds, and this world gets the thing its own
    /// chimneys are putting into the sky. It does the same job all three do — something has to be
    /// moving or a still reads as a painting of a place rather than the place — and it does one
    /// more besides: a city with dirt in the air over it is being sold honestly, which is more
    /// than the caption is doing.
    func drawCogsworthSmuts(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        let soot = colors.isNight
            ? colors.discHalo.opacity(0.30)
            : Color.black.opacity(0.16)

        for _ in 0..<count {
            let home = CGPoint(x: x(scatter.next(in: 0.03...0.97)), y: y(scatter.next(in: 0.20...0.78)))
            let phase = scatter.next() * 2 * .pi
            let sway = moves ? sin(progress * 2 * .pi + phase) : 0
            let lift = moves ? progress : 0.5
            let flake = x(0.004) * CGFloat(0.7 + scatter.next() * 0.9)
            let spot = CGPoint(
                x: home.x + x(0.035) * CGFloat(sway),
                y: home.y - y(0.05) * CGFloat(lift)
            )

            context.fill(
                Path(ellipseIn: CGRect(
                    x: spot.x - flake, y: spot.y - flake * 0.7,
                    width: flake * 2, height: flake * 1.4
                )),
                with: .color(soot)
            )
        }
    }

    /// The few stars a city lets through: small, cold and thinned out, because most of what is up
    /// there is losing to the windows underneath it. They breathe rather than twinkle, and they
    /// are laid on before the skyline so that nothing is ever standing in front of a building it
    /// should be behind.
    func drawCogsworthStars(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        var points = Path()

        for _ in 0..<count {
            let spot = CGPoint(x: x(scatter.next(in: 0.03...0.97)), y: y(scatter.next(in: 0.02...0.48)))
            let phase = scatter.next() * 2 * .pi
            let breath = moves ? (sin(progress * 2 * .pi + phase) + 1) / 2 : 0.6
            points.addEllipse(in: CGRect(
                x: spot.x - x(0.0035) * CGFloat(0.6 + breath * 0.7),
                y: spot.y - x(0.0035) * CGFloat(0.6 + breath * 0.7),
                width: x(0.007) * CGFloat(0.6 + breath * 0.7),
                height: x(0.007) * CGFloat(0.6 + breath * 0.7)
            ))
        }
        context.fill(points, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.7 : 0.3)))
    }

    /// The fifth world, arriving: a four-pointed star running down a line from `from` to `to`,
    /// with a tail stretched out behind it and a halo round it.
    ///
    /// It is painted rather than set as a glyph, which is the one place these films break their
    /// own rule about emoji being the actors. A star lying in the dust is a treat and gets the
    /// glyph the board gives it; this one is scenery — a light a long way off, going somewhere —
    /// and a piece of type hung in the sky would read as a sticker on the window rather than as
    /// something out beyond it. `along` is where it has got to, and it is deliberately left to
    /// the caller rather than eased in here, so a shot can hand a still camera the middle of the
    /// arc instead of either end of it.
    func drawCogsworthFallingStar(
        in context: inout GraphicsContext,
        from: CGPoint,
        to: CGPoint,
        reach: CGFloat,
        along: Double
    ) {
        let travelled = CGFloat(min(max(along, 0), 1))
        let head = CGPoint(
            x: from.x + (to.x - from.x) * travelled,
            y: from.y + (to.y - from.y) * travelled
        )
        // The tail runs back up the line it came down, and never further back than the point it
        // started from, so the shot never shows a streak coming out of nothing.
        let back = min(travelled, 0.34)
        let tail = CGPoint(
            x: head.x - (to.x - from.x) * back,
            y: head.y - (to.y - from.y) * back
        )
        let run = CGPoint(x: head.x - tail.x, y: head.y - tail.y)
        let length = max(sqrt(run.x * run.x + run.y * run.y), 0.001)
        let side = CGPoint(x: -run.y / length * reach * 0.42, y: run.x / length * reach * 0.42)

        var streak = Path()
        streak.move(to: CGPoint(x: head.x + side.x, y: head.y + side.y))
        streak.addLine(to: CGPoint(x: head.x - side.x, y: head.y - side.y))
        streak.addLine(to: tail)
        streak.closeSubpath()
        context.fill(
            streak,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0.55),
                    GamePalette.cream.opacity(0)
                ]),
                startPoint: head,
                endPoint: tail
            )
        )

        context.fill(
            circle(at: head, radius: reach * 2.2),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.80, green: 0.75, blue: 1.00).opacity(0.40),
                    Color(red: 0.80, green: 0.75, blue: 1.00).opacity(0)
                ]),
                center: head,
                startRadius: 0,
                endRadius: reach * 2.2
            )
        )

        // The same four points the board draws a star with, so the thing coming down out of the
        // sky is recognisably the thing the next world is paved with.
        var points = Path()
        points.move(to: CGPoint(x: head.x, y: head.y - reach))
        points.addQuadCurve(
            to: CGPoint(x: head.x + reach * 0.55, y: head.y),
            control: CGPoint(x: head.x + reach * 0.12, y: head.y - reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: head.x, y: head.y + reach),
            control: CGPoint(x: head.x + reach * 0.12, y: head.y + reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: head.x - reach * 0.55, y: head.y),
            control: CGPoint(x: head.x - reach * 0.12, y: head.y + reach * 0.12)
        )
        points.addQuadCurve(
            to: CGPoint(x: head.x, y: head.y - reach),
            control: CGPoint(x: head.x - reach * 0.12, y: head.y - reach * 0.12)
        )
        context.fill(points, with: .color(GamePalette.cream.opacity(0.95)))
    }
}
