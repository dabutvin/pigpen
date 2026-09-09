import Foundation
import SwiftUI
import UIKit

// MARK: - Frostwhisker Tundra, painted

/// The tundra's nine shots, and the brushes a world made of one colour turned out to need.
///
/// Every other world in this game is drawn by putting a dark thing in front of a light one. The
/// tundra has nothing dark in it. Snow under an overcast is white ground below a white sky with
/// white coming down between them, and painted honestly it is a blank rectangle — so nothing out
/// here is drawn in white at all. It is drawn in the blue that snow keeps in its own hollows,
/// which is the only reason a drift has a shape, and the white is put back afterwards as a hair
/// of light along the top of each ridge. Get those two the wrong way round and the whole world
/// disappears.
///
/// From that follow the three things every shot here leans on. Pressure ridges, because a plain
/// with nothing standing up out of it has no distance in it. Sastrugi — the wind's combing, all
/// of it pulled the same way because it is one wind's work and not many — because that combing
/// is what tells the eye which way the ground is lying. And snow falling through the frame, since
/// a world this still needs something moving in it or it reads as a photograph of a wall.
///
/// The fourth thing is open water, and it only appears in the seal's three shots and the send-off.
/// A lead in the ice is the darkest thing for a hundred miles, so it is worth twice what it costs
/// on the page: put one along the bottom of a frame and everything else in the shot is instantly
/// legible as ice. That is also, not by coincidence, what the seal's rule is about.
///
/// And the fifth is the captions, which out here are a composition problem rather than somebody
/// else's. The films letter their lines in cream; cream on this world's daylight snow is a
/// contrast of about 1.15 to one, against 1.9 in the meadow and 2.3 in the thicket, and it is the
/// only world in the game where the ground is close enough to the type to swallow it whole. So
/// every daylight shot puts shadow where its line goes — down the foot of the frame on the six
/// that run a subtitle, across the middle as a squall on the two that hand over on a card — until
/// the type reads about as well as the meadow's does. The three dusk shots need none of it and
/// get none. It is the same blue as everything else here, so what fixes the words also happens
/// to be the weather.
extension Film {
    // MARK: - The tundra's ink

    /// The blue in every hollow, every lee face and every shadow out here — the colour that does
    /// all the drawing in a world with nothing to draw with. It is the same blue the boards
    /// themselves are combed with, so a film and a field agree about what snow looks like.
    static let frostwhiskerShadow = Color(red: 0.30, green: 0.42, blue: 0.60)
    /// The shaded face of a blade of pressure ice: lighter than a shadow, still nowhere near
    /// white, because a slab of ice on its dark side is blue rather than grey.
    static let frostwhiskerLee = Color(red: 0.40, green: 0.56, blue: 0.76)
    /// The hair of light along a crest, and the only near-white the tundra is allowed to use.
    /// Spent anywhere but on an edge it flattens the picture it was meant to carve.
    static let frostwhiskerCrest = Color(red: 0.95, green: 0.98, blue: 1.00)
    /// Open water seen from on top of the ice: not blue, not black, and colder than either.
    static let frostwhiskerWater = Color(red: 0.05, green: 0.14, blue: 0.26)

    /// Two films by day and a send-off into the dark, as every world does it — except that the
    /// tundra's night is the one night in the game with a light of its own in it, so falling
    /// into dusk here buys the aurora rather than costing the picture.
    static func frostwhiskerLight(_ shot: CutScene.Picture.Frostwhisker) -> GamePalette.Pasture {
        switch shot {
        case .tundraHeld, .somewhereWithLessIce, .muchLessIce: .frostDusk
        default: .frostDay
        }
    }

    func drawFrostwhisker(_ shot: CutScene.Picture.Frostwhisker, in context: inout GraphicsContext) {
        switch shot {
        case .theIceEdge: drawTheIceEdge(in: &context)
        case .skisAndBlackIce: drawSkisAndBlackIce(in: &context)
        case .theSkiTownPremium: drawTheSkiTownPremium(in: &context)
        case .theWaterfront: drawTheWaterfront(in: &context)
        case .waterAccess: drawWaterAccess(in: &context)
        case .aPenOnTheWater: drawAPenOnTheWater(in: &context)
        case .tundraHeld: drawTundraHeld(in: &context)
        case .somewhereWithLessIce: drawSomewhereWithLessIce(in: &context)
        case .muchLessIce: drawMuchLessIce(in: &context)
        }
    }

    // MARK: - The tundra's opening

    /// The arrival: ranks of pressure ice banked away under a sun that never gets far off the
    /// horizon, the wind's combing running across the near snow, and the pig out on it at the
    /// size the property makes it. The camera pushes in, which is the shot agreeing to go out
    /// there.
    func drawTheIceEdge(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        // Low and to one side rather than overhead. A sun straight up puts the light down the
        // throat of every hollow and fills in the only shadows the picture has.
        drawSun(in: &shot, at: CGPoint(x: x(0.28), y: y(0.44)), radius: x(0.055), rays: false)

        drawLand(in: &shot, ridge: 0.52, rise: 0.028, waves: 1.7, phase: 1.2, color: colors.farHill)

        // Two ranks of rubble ice, the far one taken most of the way back to the sky, then the
        // snow laid over the feet of both: a ridge grows out of the floe it buckled, and a rank
        // of ice with a flat lower edge is a row of teeth on a shelf.
        drawFrostwhiskerRidge(in: &shot, base: 0.610, from: -0.08, to: 1.08, height: 0.055, seed: 8_101, haze: 0.55)
        drawLand(in: &shot, ridge: 0.575, rise: 0.02, waves: 1.3, phase: 2.4, color: colors.ground)
        drawFrostwhiskerRidge(in: &shot, base: 0.725, from: 0.52, to: 1.14, height: 0.085, seed: 8_111, haze: 0.18)
        drawLand(in: &shot, ridge: 0.685, rise: 0.018, waves: 1.1, phase: 0.6, color: colors.ground)

        drawFrostwhiskerSastrugi(in: &shot, from: 0.70, to: 0.90, count: 9, seed: 8_117)

        // Out on the flat and getting smaller in it, which is the only way to say how big the
        // flat is when there is nothing else in the frame to measure it against.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.44), y: y(0.80 - 0.015 * along)),
            width: x(0.16 - 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawFrostwhiskerRidge(in: &shot, base: 0.985, from: -0.08, to: 0.34, height: 0.07, seed: 8_123)
        drawLand(in: &shot, ridge: 0.95, rise: 0.012, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 46, seed: 8_147)

        // The words go here, and daylight snow is very nearly the colour of them.
        drawFrostwhiskerShade(in: &context, from: 0.80, strength: 0.44)
    }

    /// The two halves of the scoring, one after the other on the same slope: the ski while the
    /// line is calling the slope access an amenity, and then the slick of black ice while it is
    /// admitting what that does to the walkability score.
    ///
    /// The meadow drew this as one picture with a fence in it, because the meadow was teaching
    /// what a fence was at the same time. Ten worlds on there is nothing to teach, so the shot
    /// simply changes hands where the caption changes sentence — the amenity in its own light
    /// with two ski tracks running down to it, and then the hazard in the same spot with the
    /// light off it and the combing of the snow swallowed by it.
    func drawSkisAndBlackIce(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from what is being sold to what is being owned up to: the first
        // sentence has faded and the second has not landed, so the picture can change under it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.38))
        drawSun(in: &shot, at: CGPoint(x: x(0.78), y: y(0.20)), radius: x(0.06), rays: false)

        // A long fall from the top right rather than a wave across the frame: one slow shoulder
        // of snow, which is what a piste is before anybody grooms it.
        drawLand(in: &shot, ridge: 0.34, rise: 0.16, waves: 0.55, phase: 2.7, color: colors.farHill)
        drawFrostwhiskerRidge(in: &shot, base: 0.635, from: -0.08, to: 1.08, height: 0.06, seed: 8_161, haze: 0.4)
        drawLand(in: &shot, ridge: 0.585, rise: 0.03, waves: 1.4, phase: 2.5, color: colors.ground)
        drawFrostwhiskerSastrugi(in: &shot, from: 0.62, to: 0.88, count: 8, seed: 8_167)

        // Leaning in at what is being sold and back from what is being admitted, which is the
        // only opinion this shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.28), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.64), y: y(0.78))

        // The amenity, stood in its own light, with a pair of tracks coming off the shoulder
        // above it: somebody has already had the run and enjoyed it.
        var amenity = shot
        amenity.opacity = 1 - turn
        amenity.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.40), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawFrostwhiskerTracks(in: &amenity, from: CGPoint(x: x(0.86), y: y(0.44)), to: CGPoint(x: x(0.66), y: y(0.74)))
        drawTreat(in: &amenity, "🎿", at: spot, width: x(0.22))

        // And the drawback in the same spot with the light off it: a sheet of black ice with the
        // sky lying flat in it, which is exactly how you fail to see one.
        var drawback = shot
        drawback.opacity = turn
        drawFrostwhiskerSlick(in: &drawback, at: CGPoint(x: spot.x, y: spot.y + y(0.008)), width: x(0.34))
        drawTreat(in: &drawback, "🧊", at: spot, width: x(0.22))

        drawLand(in: &shot, ridge: 0.94, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 40, seed: 8_179)

        // The words go here, and daylight snow is very nearly the colour of them.
        drawFrostwhiskerShade(in: &context, from: 0.80, strength: 0.44)
    }

    /// A very large amount of extremely expensive nothing, with the pig at the bottom of it and
    /// one ski stood in the snow beside him like a board outside a house. The camera pulls back
    /// as it holds, so the property grows and the buyer does not.
    ///
    /// The middle of this frame belongs to the words, and for once that costs nothing: an empty
    /// white middle distance is not a hole in the composition here, it is the composition. What
    /// the shot is worth is decided entirely along its top and bottom edges.
    func drawTheSkiTownPremium(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.28))
        drawSun(in: &shot, at: CGPoint(x: x(0.70), y: y(0.17)), radius: x(0.05), rays: false)

        drawLand(in: &shot, ridge: 0.28, rise: 0.035, waves: 1.6, phase: 0.9, color: colors.farHill)
        // The far wall of the property, well up out of the card's way and taken most of the way
        // into the sky, because at this distance ice is a colour rather than a shape.
        drawFrostwhiskerRidge(in: &shot, base: 0.365, from: -0.08, to: 1.08, height: 0.075, seed: 8_191, haze: 0.6)
        drawLand(in: &shot, ridge: 0.325, rise: 0.02, waves: 1.2, phase: 2.1, color: colors.ground)

        // Everything between here and there is one wind's work, and the combing is the only
        // thing telling the eye how far away the far wall is.
        drawFrostwhiskerSastrugi(in: &shot, from: 0.38, to: 0.90, count: 13, seed: 8_209)

        let along = easeOut(progress)
        // The board outside the house, and a house nowhere in it.
        drawTreat(in: &shot, "🎿", at: CGPoint(x: x(0.58), y: y(0.83)), width: x(0.13))
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.40), y: y(0.82)),
            width: x(0.15 - 0.02 * along),
            lean: 4
        )

        drawFrostwhiskerRidge(in: &shot, base: 1.005, from: 0.62, to: 1.16, height: 0.085, seed: 8_219)
        drawLand(in: &shot, ridge: 0.975, rise: 0.012, waves: 1.0, phase: 1.4, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 52, seed: 8_231)

        // A card speaks from the middle, so the middle is where the weather goes.
        drawFrostwhiskerDrift(in: &context, at: 0.505, depth: 0.47, strength: 0.38)
    }

    // MARK: - The Haulout

    /// A lead of open water lying across the ice, and the bull seal coming up out of it onto the
    /// near floe as the shot runs. The waterfront is drawn before the resident and the resident
    /// arrives out of it, which is the order the caption puts them in.
    func drawTheWaterfront(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.012 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawSun(in: &shot, at: CGPoint(x: x(0.72), y: y(0.33)), radius: x(0.05), rays: false)

        drawLand(in: &shot, ridge: 0.40, rise: 0.03, waves: 1.8, phase: 1.4, color: colors.farHill)
        drawFrostwhiskerRidge(in: &shot, base: 0.535, from: -0.08, to: 1.08, height: 0.055, seed: 8_233, haze: 0.5)
        drawLand(in: &shot, ridge: 0.49, rise: 0.02, waves: 1.3, phase: 2.0, color: colors.ground)

        // The only dark thing in the world, and the reason anybody lives here.
        drawFrostwhiskerLead(in: &shot, at: 0.655, depth: 0.085, from: -0.10, to: 1.10, seed: 8_237)
        drawLand(in: &shot, ridge: 0.634, rise: 0.010, waves: 1.2, phase: 0.5, color: colors.ground)
        drawFrostwhiskerSastrugi(in: &shot, from: 0.71, to: 0.90, count: 7, seed: 8_243)

        // Up out of the lead and onto the ice, growing as it comes over the near lip: a seal
        // hauling out is the one thing this animal does that has a name, and the world is named
        // after it.
        let out = easeOut(min(progress / 0.85, 1))
        drawAnimal(
            in: &shot,
            .seal,
            feet: CGPoint(x: x(0.62), y: y(0.655 + 0.06 * out)),
            width: x(0.15 + 0.05 * out),
            lean: 3 - 6 * out,
            shadow: 0.4 + 0.6 * out
        )

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.22), y: y(0.79)), width: x(0.16), lean: 5)

        drawLand(in: &shot, ridge: 0.94, rise: 0.012, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 38, seed: 8_263)

        // The words go here, and daylight snow is very nearly the colour of them.
        drawFrostwhiskerShade(in: &context, from: 0.80, strength: 0.44)
    }

    /// The two of them either side of a wall of pressure ice that neither of them built, the seal
    /// down on the water side and the pig up on the dry, each facing away from the other. The
    /// thicket drew this with a tree between them; out here the party wall is the only thing on
    /// the property that stands up by itself.
    ///
    /// Nothing has been decided yet, so nothing moves but breathing and the weather.
    func drawWaterAccess(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawLand(in: &shot, ridge: 0.44, rise: 0.03, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawFrostwhiskerRidge(in: &shot, base: 0.58, from: -0.08, to: 1.08, height: 0.05, seed: 8_269, haze: 0.5)
        drawLand(in: &shot, ridge: 0.535, rise: 0.02, waves: 1.4, phase: 0.9, color: colors.ground)

        // The water reaches in from one side only, so the frame has a wet half and a dry half
        // and the wall stands on the line between them.
        drawFrostwhiskerLead(in: &shot, at: 0.895, depth: 0.12, from: 0.56, to: 1.14, seed: 8_273)
        drawFrostwhiskerSastrugi(in: &shot, from: 0.60, to: 0.86, count: 7, seed: 8_287)

        // The party wall, and it grew there: one buckled seam of ice between the two of them,
        // tall enough to read as a wall rather than as rubble. It is drawn before either animal
        // so that it can only ever stand between them, never in front of one.
        drawFrostwhiskerRidge(in: &shot, base: 0.90, from: 0.46, to: 0.56, height: 0.11, seed: 8_291)

        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.24), y: y(0.80) - y(0.004 * breath)),
            width: x(0.19),
            lean: -5,
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .seal,
            feet: CGPoint(x: x(0.78), y: y(0.775) + y(0.004 * breath)),
            width: x(0.21),
            lean: 4,
            squash: 1 - 0.015 * breath
        )

        drawLand(in: &shot, ridge: 0.872, rise: 0.010, waves: 1.0, phase: 1.1, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 40, seed: 8_293)

        // The words go here, and daylight snow is very nearly the colour of them.
        drawFrostwhiskerShade(in: &context, from: 0.80, strength: 0.44)
    }

    /// The rule, drawn: the lead running the whole width of the bottom of the frame, the seal's
    /// pen sat down on it with one edge touching the water, and the pig's opening away up the
    /// snow with half a mile of ice in between.
    ///
    /// Every other boss card in the game is about two pens not meeting. This one is about one of
    /// them meeting something else, so the water is put where a card leaves room — along the
    /// bottom edge — and everything above it is left pale, which makes the one dark band in the
    /// picture read as the thing the whole rule is hung on. The pig is small and high because far
    /// away from the water is the only thing its pen is required to be.
    func drawAPenOnTheWater(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.20))
        drawLand(in: &shot, ridge: 0.20, rise: 0.03, waves: 1.7, phase: 1.1, color: colors.farHill)
        drawFrostwhiskerRidge(in: &shot, base: 0.30, from: -0.08, to: 1.08, height: 0.05, seed: 8_297, haze: 0.55)
        drawLand(in: &shot, ridge: 0.255, rise: 0.018, waves: 1.3, phase: 2.4, color: colors.ground)
        drawFrostwhiskerSastrugi(in: &shot, from: 0.30, to: 0.80, count: 11, seed: 8_311)

        let seal = CGPoint(x: x(0.56), y: y(0.835))
        let pig = CGPoint(x: x(0.32), y: y(0.325))

        // The waterline, and the seal's feet almost in it.
        drawFrostwhiskerLead(in: &shot, at: 1.06, depth: 0.20, from: -0.10, to: 1.10, seed: 8_317)

        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.10), shadow: 0.6)
        drawAnimal(in: &shot, .seal, feet: seal, width: x(0.17))

        // Both plans go up together, and the seal's stops exactly on the water rather than short
        // of it: a pen that borders the lead is the only pen out here worth having.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: pig, width: 0.34, height: 0.09, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: seal, width: 0.46, height: 0.11, drop: 0.028, opacity: 0.9 * drawn)

        drawFrostwhiskerSnow(in: &shot, count: 34, seed: 8_329)

        // A card speaks from the middle, so the middle is where the weather goes.
        drawFrostwhiskerDrift(in: &context, at: 0.505, depth: 0.47, strength: 0.38)
    }

    // MARK: - The tundra held

    /// Both pens holding under the aurora: the seal's down on the lead where it was promised, and
    /// the pig's across the front of the frame with its skis lying where they were dropped. The
    /// coldest picture in the game, and the only night in it with a colour of its own.
    func drawTundraHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawFrostwhiskerAurora(in: &shot, count: 4, seed: 8_353)
        // The disc at this hour is the moon, and out here it is the second brightest thing in
        // the sky rather than the first.
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.13)), radius: x(0.042), rays: false)

        drawLand(in: &shot, ridge: 0.34, rise: 0.03, waves: 2.0, phase: 1.5, color: colors.farHill)
        drawFrostwhiskerRidge(in: &shot, base: 0.475, from: -0.08, to: 1.08, height: 0.055, seed: 8_363, haze: 0.45)
        drawLand(in: &shot, ridge: 0.43, rise: 0.02, waves: 1.4, phase: 0.8, color: colors.ground)

        // The neighbour, held, and still on the water — which is the whole of what he asked for
        // and the reason this pen is the far one rather than the front one.
        drawFrostwhiskerLead(in: &shot, at: 0.60, depth: 0.075, from: 0.40, to: 1.12, seed: 8_369)
        drawLand(in: &shot, ridge: 0.585, rise: 0.008, waves: 1.2, phase: 2.3, color: colors.ground)
        let seal = CGPoint(x: x(0.78), y: y(0.655))
        drawPenWash(in: &shot, round: seal, width: 0.34, height: 0.075, drop: 0.006)
        drawAnimal(in: &shot, .seal, feet: seal, width: x(0.12), shadow: 0.6)
        drawPenFence(in: &shot, round: seal, width: 0.34, height: 0.075, drop: 0.006)

        drawFrostwhiskerSastrugi(in: &shot, from: 0.70, to: 0.86, count: 6, seed: 8_377)

        // And the pig with the run of the rest of it, kit still lying about.
        let pig = CGPoint(x: x(0.40), y: y(0.83))
        drawPenWash(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)
        drawTreat(in: &shot, "🎿", at: CGPoint(x: x(0.15), y: y(0.79)), width: x(0.05))
        drawTreat(in: &shot, "🎿", at: CGPoint(x: x(0.63), y: y(0.815)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)

        drawFrostwhiskerSnow(in: &shot, count: 30, seed: 8_387)
    }

    /// The pig up on the last ridge with its back to everything it has just finished fencing,
    /// looking south at a low green country lying wet under the aurora. The thicket looked over
    /// its own roof at a mountain; this looks off the edge of the ice at the first warm thing
    /// anyone has seen in three films.
    func drawSomewhereWithLessIce(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        drawFrostwhiskerAurora(in: &shot, count: 3, seed: 8_389)

        // The listing, lying beyond the ice rather than at the end of it: drawn first, hazed
        // back into the sky, and then the near country laid over its bottom edge, because a
        // green country that starts at a hard line is a stripe rather than a distance.
        drawFrostwhiskerFen(in: &shot, base: 0.50, scale: 0.45, haze: 0.45, seed: 8_397)
        drawLand(in: &shot, ridge: 0.615, rise: 0.02, waves: 1.6, phase: 1.7, color: colors.farHill)

        // The ice banked in either side of it, which is what makes the fen a glimpse rather than
        // a view — and what makes leaving feel like leaving through something.
        drawFrostwhiskerRidge(in: &shot, base: 0.80, from: -0.12, to: 0.16, height: 0.11, seed: 8_419)
        drawFrostwhiskerRidge(in: &shot, base: 0.80, from: 0.86, to: 1.14, height: 0.11, seed: 8_423)
        drawLand(in: &shot, ridge: 0.755, rise: 0.022, waves: 1.3, phase: 0.9, color: colors.ground)
        drawFrostwhiskerSastrugi(in: &shot, from: 0.79, to: 0.90, count: 5, seed: 8_429)

        // Stood on his own held ice with his back half-turned, looking at somebody else's mud.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.34), y: y(0.79)), width: x(0.17), lean: -3)

        drawLand(in: &shot, ridge: 0.94, rise: 0.014, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawFrostwhiskerSnow(in: &shot, count: 26, seed: 8_431)
    }

    /// The same green country from inside it: reeds, standing water, mist to the knee, and the
    /// last of the ice under the pig's feet at the edge of the frame. Something long comes
    /// through the water while the card is up, and nobody in the picture has noticed.
    ///
    /// The snow stops falling in this one. It is the only shot in the tundra's nine without it,
    /// and that absence is what says the journey is already over.
    func drawMuchLessIce(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawFrostwhiskerAurora(in: &shot, count: 2, seed: 8_443)
        drawLand(in: &shot, ridge: 0.34, rise: 0.03, waves: 1.8, phase: 1.2, color: colors.farHill)

        // Mist across the middle of the frame, where the card's words go: the one place in this
        // film where something has to be in the way, and haze is the only thing that can be in
        // the way of a reader without being in the way of a picture.
        drawMist(in: &shot, at: 0.50, seed: 8_447)

        drawFrostwhiskerFen(in: &shot, base: 0.585, scale: 1.0, haze: 0.12, seed: 8_461)

        // In from the right along its own water, at the pace of something that has all evening.
        let along = easeOut(min(progress / 0.9, 1))
        drawAnimal(
            in: &shot,
            .croc,
            feet: CGPoint(x: x(1.08 - 0.36 * along), y: y(0.80)),
            width: x(0.22),
            shadow: 0.35
        )

        // The last of the ice, holding up one corner of the frame with the pig stood on it.
        drawFrostwhiskerRidge(in: &shot, base: 0.92, from: -0.10, to: 0.16, height: 0.09, seed: 8_471)
        drawLand(in: &shot, ridge: 0.875, rise: 0.02, waves: 1.1, phase: 2.6, color: colors.foreground)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.17), y: y(0.835)),
            width: x(0.12),
            lean: 6,
            shadow: 0.5
        )
    }

    // MARK: - What the tundra is made of

    /// A pressure ridge: the seam where two floes met and one of them lost, drawn as a rank of
    /// blades stood along a line.
    ///
    /// Every blade gets two faces meeting on a crest rather than one shape with a wash over it —
    /// the fold is the entire reason a lump of ice reads as solid, and a flat triangle with a
    /// light half never does. They are shadowed first, all to the same side, because a rank of
    /// ice without a shadow line under it hovers; and they are spaced by a wandering step so the
    /// rank reads as rubble rather than as railings.
    ///
    /// `haze` lays the sky back over the finished rank, which is how a ridge gets put a mile off
    /// instead of ten yards: out here distance is entirely a matter of colour, since a ridge a
    /// mile away and a ridge at your feet are the same white and very nearly the same size.
    func drawFrostwhiskerRidge(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        seed: UInt64,
        haze: Double = 0
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        let start = x(from)
        let end = x(to)
        let step = x(0.05)

        var shadows = Path()
        var lee = Path()
        var lit = Path()
        var whole = Path()

        var across = start
        while across < end {
            let tall = y(height) * CGFloat(0.4 + scatter.next() * 0.95)
            // Half as wide as it is tall, and no wider. A blade used to be given a width of
            // around its own height, which on a frame half again taller than it is wide made a
            // single blade of a full-height ridge wider than the screen — the wall in the seal's
            // second shot swallowed the pig whole. Ice under pressure goes up, not out.
            let half = tall * CGFloat(0.28 + scatter.next() * 0.30)
            let lean = half * CGFloat(scatter.next() - 0.5) * 1.1
            let crest = CGPoint(x: across + lean, y: foot - tall)
            let left = CGPoint(x: across - half, y: foot)
            let right = CGPoint(x: across + half, y: foot)
            // Where the ridge of the blade comes down to the snow, which is what puts its two
            // faces out of square with each other.
            let hip = CGPoint(x: across + lean * 0.3, y: foot)

            shadows.addEllipse(in: CGRect(
                x: left.x, y: foot - tall * 0.04,
                width: half * 2.6, height: tall * 0.14
            ))

            var sunward = Path()
            sunward.move(to: left)
            sunward.addLine(to: crest)
            sunward.addLine(to: hip)
            sunward.closeSubpath()
            lit.addPath(sunward)

            var leeward = Path()
            leeward.move(to: hip)
            leeward.addLine(to: crest)
            leeward.addLine(to: right)
            leeward.closeSubpath()
            lee.addPath(leeward)

            var blade = Path()
            blade.move(to: left)
            blade.addLine(to: crest)
            blade.addLine(to: right)
            blade.closeSubpath()
            whole.addPath(blade)

            across += step * CGFloat(0.5 + scatter.next() * 0.8)
        }

        context.fill(
            shadows,
            with: .color(Self.frostwhiskerShadow.opacity(colors.isNight ? 0.34 : 0.26))
        )
        context.fill(lee, with: .color(Self.frostwhiskerLee.opacity(colors.isNight ? 0.5 : 0.9)))
        context.fill(lit, with: .color(Self.frostwhiskerCrest.opacity(colors.isNight ? 0.42 : 0.95)))

        if haze > 0 {
            context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
        }
    }

    /// Sastrugi: what the wind does to snow it has been over often enough. Long shallow waves
    /// combed across the frame, every one bowed the same way because they are one wind's work
    /// and not many — a blue trough with its lit crest a hair above it.
    ///
    /// This is the brush that makes the tundra a place rather than a colour. Without it a snow
    /// field is a flat fill and the eye has no idea which way the ground is lying, how far off
    /// the horizon is, or whether it is looking at ground at all. The waves are stacked closer
    /// near the top of the run than the bottom, which is the only perspective the shot gets.
    func drawFrostwhiskerSastrugi(
        in context: inout GraphicsContext,
        from top: Double,
        to bottom: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for index in 0..<count {
            let step = (Double(index) + 0.4 + scatter.next() * 0.4) / Double(count)
            let down = y(top + (bottom - top) * pow(step, 1.5))
            let drift = y((scatter.next() - 0.5) * 0.03)
            let bow = y(0.008 + 0.022 * step)

            var wave = Path()
            wave.move(to: CGPoint(x: -x(0.06), y: down))
            wave.addCurve(
                to: CGPoint(x: size.width + x(0.06), y: down + drift),
                control1: CGPoint(x: x(0.32), y: down - bow),
                control2: CGPoint(x: x(0.68), y: down - bow * CGFloat(0.5 + scatter.next()))
            )

            let width = max(0.8, y(0.003 + 0.008 * step))
            // The trough first, a hair below where the crest will go, so the pair reads as one
            // lip of snow lit from above rather than as two lines.
            context.translateBy(x: 0, y: width)
            context.stroke(
                wave,
                with: .color(Self.frostwhiskerShadow.opacity(colors.isNight ? 0.3 : 0.2)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
            context.translateBy(x: 0, y: -width)
            context.stroke(
                wave,
                with: .color(Self.frostwhiskerCrest.opacity(colors.isNight ? 0.12 : 0.5)),
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
        }
    }

    /// Snow coming down through the frame. Flakes are given a depth and everything follows from
    /// it — the near ones bigger, faster, brighter and swinging further — because a fall of
    /// identical dots is a texture and a fall with depth in it is weather.
    ///
    /// Each one wraps from the bottom of the frame back to the top on its own phase, so there is
    /// never a moment where the fall starts or ends; and at rest, when a player has asked for
    /// less motion, they are simply a field of flakes hanging in the air, which is a perfectly
    /// good thing for snow to be doing.
    func drawFrostwhiskerSnow(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let column = scatter.next()
            let depth = scatter.next()
            let phase = scatter.next()
            let fall = (phase + progress * (0.35 + depth * 0.75)).truncatingRemainder(dividingBy: 1)
            let sway = sin((fall + phase) * 2 * .pi * 1.5) * (0.008 + 0.022 * depth)

            let spot = CGPoint(
                x: x(column * 1.2 - 0.1 + sway),
                y: y(fall * 1.16 - 0.08)
            )
            context.fill(
                circle(at: spot, radius: x(0.003 + 0.006 * depth)),
                with: .color(Self.frostwhiskerCrest.opacity(0.25 + 0.55 * depth))
            )
        }
    }

    /// A lead: open water in the ice, which out here is the darkest thing for a hundred miles and
    /// the most valuable.
    ///
    /// Both edges wander, because a crack that opened in a floe is not a canal, and the ice edge
    /// gets a hair of light along it — that lip is what stops the water reading as a hole cut in
    /// the paper. `from` and `to` let it run the whole width of a frame or reach in from one side
    /// only, which is the difference between a waterfront and a wet corner. What slides along it
    /// is the sky it has caught, moved just enough that the surface is liquid rather than paint.
    func drawFrostwhiskerLead(
        in context: inout GraphicsContext,
        at level: Double,
        depth: Double,
        from: Double,
        to: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let near = y(level)
        let far = y(level - depth)
        let left = x(from)
        let right = x(to)
        let middle = (near + far) / 2

        // A lead that stops inside the frame closes to a crack rather than to a square end, and
        // both its edges wander along their whole length. One curve drawn from side to side is
        // straight to look at however it is controlled, and a straight waterline is the flattest
        // thing that can happen to a picture made of ice.
        let shutLeft = from > -0.05
        let shutRight = to < 1.05
        let spans = 7
        var lip: [CGPoint] = []
        var hem: [CGPoint] = []

        for step in 0...spans {
            let along = CGFloat(step) / CGFloat(spans)
            let across = left + (right - left) * along
            let pinch = min(
                shutLeft ? min(along / 0.16, 1) : 1,
                shutRight ? min((1 - along) / 0.16, 1) : 1
            )
            let wander = y(0.011) * CGFloat(scatter.next() - 0.5)
            lip.append(CGPoint(x: across, y: middle + (far - middle) * pinch + wander))
            hem.append(CGPoint(x: across, y: middle + (near - middle) * pinch + wander * 0.7))
        }

        func trace(_ path: inout Path, through points: [CGPoint]) {
            path.addLine(to: points[0])
            for index in 1..<(points.count - 1) {
                let waist = CGPoint(
                    x: (points[index].x + points[index + 1].x) / 2,
                    y: (points[index].y + points[index + 1].y) / 2
                )
                path.addQuadCurve(to: waist, control: points[index])
            }
            path.addLine(to: points[points.count - 1])
        }

        var lead = Path()
        lead.move(to: lip[0])
        trace(&lead, through: lip)
        trace(&lead, through: Array(hem.reversed()))
        lead.closeSubpath()

        context.fill(
            lead,
            with: .linearGradient(
                Gradient(colors: [
                    Self.frostwhiskerWater.opacity(colors.isNight ? 0.94 : 0.82),
                    Self.frostwhiskerWater
                ]),
                startPoint: CGPoint(x: 0, y: far),
                endPoint: CGPoint(x: 0, y: near)
            )
        )

        // The lip along the ice edge, catching what light there is: snow standing a little proud
        // of the water that is undercutting it.
        var edge = Path()
        edge.move(to: lip[0])
        trace(&edge, through: lip)
        context.stroke(
            edge,
            with: .color(Self.frostwhiskerCrest.opacity(colors.isNight ? 0.35 : 0.85)),
            style: StrokeStyle(lineWidth: max(1.2, y(0.004)), lineCap: .round)
        )

        // And the sky lying on it in broken lines, sliding along as the shot runs. Thin and pale
        // rather than soft and grey: anything half-lit on water this dark reads as dirt.
        for _ in 0..<5 {
            let along = scatter.next()
            let slide = moves ? (along + progress * 0.12).truncatingRemainder(dividingBy: 1) : along
            let width = (right - left) * CGFloat(0.05 + scatter.next() * 0.13)
            let centre = CGPoint(
                x: left + (right - left) * CGFloat(slide),
                y: far + (near - far) * CGFloat(0.3 + scatter.next() * 0.5)
            )
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - width / 2, y: centre.y - y(0.0016),
                    width: width, height: y(0.0032)
                )),
                with: .color(Self.frostwhiskerCrest.opacity(colors.isNight ? 0.13 : 0.20))
            )
        }
    }

    /// A slick of black ice: rain that arrived, lay down and set, sheeted over the snow.
    ///
    /// Drawn dark in the middle and feathered out at the rim rather than as a shape with an
    /// outline, because black ice has no edge — that is the entire complaint about it — and then
    /// given one hard streak of glare across the top, which is the only way anybody ever spots
    /// one and the only mark in the picture that says ice rather than hole.
    func drawFrostwhiskerSlick(in context: inout GraphicsContext, at centre: CGPoint, width: CGFloat) {
        // Feathered in a space squashed to the slick's own proportions, so it fades out at its
        // rim instead of stopping there. Drawn round rather than oval and then flattened, the
        // gradient runs out well inside the shape and leaves a hard grey edge — which is how the
        // hazard came to look like a puddle of shadow rather than like ice.
        var sheet = context
        sheet.translateBy(x: centre.x, y: centre.y)
        sheet.scaleBy(x: 1, y: 0.34)
        sheet.fill(
            circle(at: .zero, radius: width * 0.5),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: Self.frostwhiskerWater.opacity(0.78), location: 0),
                    .init(color: Self.frostwhiskerWater.opacity(0.5), location: 0.45),
                    .init(color: Self.frostwhiskerWater.opacity(0), location: 1)
                ]),
                center: .zero,
                startRadius: 0,
                endRadius: width * 0.5
            )
        )

        var glare = Path()
        glare.move(to: CGPoint(x: centre.x - width * 0.26, y: centre.y - width * 0.02))
        glare.addQuadCurve(
            to: CGPoint(x: centre.x + width * 0.20, y: centre.y - width * 0.07),
            control: CGPoint(x: centre.x - width * 0.02, y: centre.y - width * 0.11)
        )
        context.stroke(
            glare,
            with: .color(Self.frostwhiskerCrest.opacity(0.6)),
            style: StrokeStyle(lineWidth: max(1, width * 0.022), lineCap: .round)
        )
    }

    /// The aurora: curtains hung from the top of the frame, waving where they hang and thinning
    /// away to nothing before they reach the ground.
    ///
    /// Painted in the palette's own canopy greens rather than in a colour of its own, which is
    /// deliberate — the tundra's night borrows its greens for the sky because there is nothing
    /// growing under it to spend them on, and using the same two makes the aurora and the boards
    /// beneath it agree about what colour the night is. Kept faint: an aurora that competes with
    /// the moon is a stage light.
    func drawFrostwhiskerAurora(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for index in 0..<count {
            let centre = x((Double(index) + 0.25 + scatter.next() * 0.5) / Double(count))
            let wide = x(0.09 + scatter.next() * 0.13)
            let drop = y(0.20 + scatter.next() * 0.24)
            let phase = scatter.next() * 2 * .pi
            let sway = x(0.035) * CGFloat(moves ? sin(progress * 2 * .pi + phase) : sin(phase))

            var curtain = Path()
            curtain.move(to: CGPoint(x: centre - wide / 2, y: -y(0.04)))
            curtain.addQuadCurve(
                to: CGPoint(x: centre - wide * 0.28 + sway, y: drop),
                control: CGPoint(x: centre - wide * 0.85 + sway * 0.5, y: drop * 0.55)
            )
            curtain.addLine(to: CGPoint(x: centre + wide * 0.28 + sway, y: drop))
            curtain.addQuadCurve(
                to: CGPoint(x: centre + wide / 2, y: -y(0.04)),
                control: CGPoint(x: centre + wide * 0.85 + sway * 0.5, y: drop * 0.55)
            )
            curtain.closeSubpath()

            context.fill(
                curtain,
                with: .linearGradient(
                    Gradient(colors: [
                        colors.canopyShade.opacity(0.0),
                        colors.canopy.opacity(0.42),
                        colors.canopy.opacity(0)
                    ]),
                    startPoint: CGPoint(x: 0, y: -y(0.04)),
                    endPoint: CGPoint(x: 0, y: drop)
                )
            )
        }
    }

    /// The fen, which is where this world's send-off is pointed: peat green, standing water lying
    /// flat in it, reeds along its edge and mist off the lot of it.
    ///
    /// It is the same brush at both ends of the send-off — `scale` and `haze` between them do all
    /// the work of distance, so it is a hazed green line on the far side of the ice in one shot
    /// and near enough to count the reeds by in the next. Warm on purpose. It is the first green the pig has seen in three films and
    /// the picture is meant to want it, which is what makes the last line funny.
    func drawFrostwhiskerFen(
        in context: inout GraphicsContext,
        base: Double,
        scale: Double,
        haze: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let peat = Color(red: 0.20, green: 0.34, blue: 0.22)
        let reed = Color(red: 0.34, green: 0.50, blue: 0.29)
        let pool = Color(red: 0.07, green: 0.14, blue: 0.16)

        let edge = ridgeLine(at: base, rise: 0.014, waves: 1.5, phase: 1.9)
        let ground = band(below: edge)
        context.fill(ground, with: .color(peat))

        // Standing water, lying dead flat in it: the fen's own trick, and the one thing that
        // stops a green band reading as another hill.
        for _ in 0..<6 {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.1...1.1)),
                y: y(base + 0.04 + scatter.next() * 0.30)
            )
            let width = x(scatter.next(in: 0.14...0.44)) * CGFloat(scale)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - width / 2, y: centre.y - width * 0.05,
                    width: width, height: width * 0.10
                )),
                with: .color(pool.opacity(0.7))
            )
        }

        // Reeds along the waterline, drawn upright rather than leaning: nothing bends them out
        // here yet, and standing straight is what makes them read as reeds and not as grass.
        var beds = Path()
        for index in 0..<26 {
            let across = x((Double(index) + 0.2 + scatter.next() * 0.6) / 26)
            let foot = CGPoint(x: across, y: edge(across) + y(0.004))
            let tall = y(0.018 + scatter.next() * 0.026) * CGFloat(scale)
            for offset in [-0.35, 0.0, 0.4] {
                beds.move(to: foot)
                beds.addQuadCurve(
                    to: CGPoint(x: foot.x + tall * CGFloat(offset) * 0.45, y: foot.y - tall),
                    control: CGPoint(x: foot.x, y: foot.y - tall * 0.6)
                )
            }
        }
        context.stroke(
            beds,
            with: .color(reed),
            style: StrokeStyle(lineWidth: max(1, y(0.0026)), lineCap: .round)
        )

        if haze > 0 {
            context.fill(ground, with: .color(colors.skyHorizon.opacity(haze)))
        }
    }

    /// The near snow lying in the shade of a sun that never gets far off the horizon, laid across
    /// the foot of a daylight frame.
    ///
    /// This one is here for the words rather than for the weather, and it is worth saying why.
    /// Every other world in the game hands its captions something dark to sit on — the meadow's
    /// grass backs cream type at about 1.9 to one, the thicket's leaf mould at 2.3. Frostwhisker
    /// by day backs it at 1.15, because the whole point of the world is that the ground is very
    /// nearly the colour of the type, and no drop shadow rescues that. So the bottom of every
    /// daylight shot is put into shadow until it reaches roughly the meadow's figure and not a
    /// shade further: enough to read by, not enough to stop the tundra being pale.
    ///
    /// It is painted in the same blue as every other hollow out here, and it is drawn into the
    /// unmoved frame rather than into the camera's, so a push never slides it off the line it was
    /// put there to sit behind.
    func drawFrostwhiskerShade(in context: inout GraphicsContext, from top: Double, strength: Double) {
        context.fill(
            Path(CGRect(
                x: -size.width, y: y(top),
                width: size.width * 3, height: size.height * 2
            )),
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: Self.frostwhiskerShadow.opacity(0), location: 0),
                    .init(color: Self.frostwhiskerShadow.opacity(strength * 0.7), location: 0.4),
                    .init(color: Self.frostwhiskerShadow.opacity(strength), location: 1)
                ]),
                startPoint: CGPoint(x: 0, y: y(top)),
                endPoint: CGPoint(x: 0, y: y(0.92))
            )
        )
    }

    /// A bank of blowing snow lying across the flat, soft at both edges and going nowhere.
    ///
    /// The daylight cards need what the daylight subtitles need — something for the type to sit
    /// on — but a card sets its line across the middle of the frame, and shading the foot of the
    /// picture does nothing for it. This does the same job in the same blue at the height a card
    /// speaks from, and earns its place twice over: the middle of a shot of an empty snow field
    /// is the one place a tundra picture genuinely has nothing in it, and a squall drifting along
    /// the flat is both the fix and the most honest thing that could be standing there.
    ///
    /// Drawn into the unmoved frame for the same reason as the shade above.
    func drawFrostwhiskerDrift(
        in context: inout GraphicsContext,
        at level: Double,
        depth: Double,
        strength: Double
    ) {
        let top = y(level - depth / 2)
        let foot = y(level + depth / 2)

        context.fill(
            Path(CGRect(x: -size.width, y: top, width: size.width * 3, height: foot - top)),
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: Self.frostwhiskerShadow.opacity(0), location: 0),
                    .init(color: Self.frostwhiskerShadow.opacity(strength), location: 0.22),
                    .init(color: Self.frostwhiskerShadow.opacity(strength), location: 0.80),
                    .init(color: Self.frostwhiskerShadow.opacity(0), location: 1)
                ]),
                startPoint: CGPoint(x: 0, y: top),
                endPoint: CGPoint(x: 0, y: foot)
            )
        )
    }

    /// Two tracks running down a slope to whatever is at the bottom of it: somebody has already
    /// had this run and enjoyed it, which is the entire case for the amenity. Drawn narrowing as
    /// they come, so the slope has a top to it.
    func drawFrostwhiskerTracks(in context: inout GraphicsContext, from top: CGPoint, to foot: CGPoint) {
        let gap = x(0.018)
        let bow = (foot.x - top.x) * 0.5

        for side in [-1.0, 1.0] {
            var track = Path()
            track.move(to: CGPoint(x: top.x + gap * 0.35 * CGFloat(side), y: top.y))
            track.addQuadCurve(
                to: CGPoint(x: foot.x + gap * CGFloat(side), y: foot.y),
                control: CGPoint(x: top.x + bow, y: (top.y + foot.y) / 2 - y(0.03))
            )
            context.stroke(
                track,
                with: .color(Self.frostwhiskerShadow.opacity(0.34)),
                style: StrokeStyle(lineWidth: max(1.2, x(0.006)), lineCap: .round)
            )
        }
    }
}
