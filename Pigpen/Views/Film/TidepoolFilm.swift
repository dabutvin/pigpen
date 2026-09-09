import Foundation
import SwiftUI
import UIKit

// MARK: - Tidepool Cove, painted

/// The cove's nine shots, and the seven brushes a world with a sea in it needs.
///
/// Every world before this one has been ground with something standing on it, and the picture
/// has ended where the ground ended. The cove ends a third of the way up: above that line there
/// is nothing but water, and the water is the horizon, the light, the weather and the landlord.
/// So the compositions here are built in four bands rather than three — sky, sea, surf, strand —
/// and the property is the strand, which is the narrowest of them and the only one that is not
/// moving.
///
/// Two things follow from that and hold every shot together. The wet sand is drawn as a mirror,
/// not as ground: whatever the sky is doing is laid back over the sand under the waterline at a
/// low opacity, because sand that has just been let go of holds more sky than colour, and a
/// beach painted flat reads as a desert with a blue stripe over it. And the joint between water
/// and land is never a ruled line — the sea is drawn well past the shoreline, the strand is
/// drawn over the foot of it, and a band of foam is laid along the seam, so the two meet in
/// white water the way they do on a beach rather than butting up against each other.
///
/// The rest is the tide's leavings, which is what the boards of this world are dressed with
/// too: broken rings of pool with a heart of dry sand in the middle, and a wrack line of weed
/// and shells thrown down where the water stopped.
extension Film {
    /// The cove's two films by day are lit under a clean maritime sky, and its send-off falls
    /// into sea fog after dark — the same trick every world plays at the end of its last film,
    /// because the next listing is always the darker one. Here the dusk is doing a second job:
    /// the far shore has gone white in it, and white shows up in the dark.
    static func tidepoolLight(_ shot: CutScene.Picture.Tidepool) -> GamePalette.Pasture {
        switch shot {
        case .coveHeld, .enoughOfSandAndSurf, .nearTheSlopes: .coveDusk
        default: .coveDay
        }
    }

    func drawTidepool(_ shot: CutScene.Picture.Tidepool, in context: inout GraphicsContext) {
        switch shot {
        case .theCove: drawTheCove(in: &context)
        case .shellsAndJellyfish: drawShellsAndJellyfish(in: &context)
        case .puttingInAnOffer: drawPuttingInAnOffer(in: &context)
        case .theGuestHouse: drawTheGuestHouse(in: &context)
        case .theCrabsOwnPen: drawTheCrabsOwnPen(in: &context)
        case .penWithinAPen: drawPenWithinAPen(in: &context)
        case .coveHeld: drawCoveHeld(in: &context)
        case .enoughOfSandAndSurf: drawEnoughOfSandAndSurf(in: &context)
        case .nearTheSlopes: drawNearTheSlopes(in: &context)
        }
    }

    // MARK: - The cove's opening

    /// The whole listing in one frame, in the order an agent would say it: ocean views along the
    /// top, fresh air in the gulls over the water, prime waterfront along the bottom, and the pig
    /// coming down onto it. The camera pushes in, which is the shot agreeing to take a look.
    func drawTheCove(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawSun(in: &shot, at: CGPoint(x: x(0.70), y: y(0.20)), radius: x(0.06), rays: false)
        drawClouds(in: &shot, at: 0.24, drift: 0.012 * progress)

        // The headland that shuts the far end of the cove, standing in the water rather than on
        // the beach: it is drawn before the sea and the sea is drawn over its feet, which is the
        // only way a cliff ever reads as a mile off rather than as a rock in the next bay.
        drawTidepoolHeadland(in: &shot, at: 0.14, base: 0.50, height: 0.17, width: 0.36, haze: 0.46, snow: 0)

        drawTidepoolSea(in: &shot, from: 0.42, to: 0.66, seed: 811)
        // Thin, out where the swell trips: any heavier and a line of surf on open water reads
        // as a ribbon lying on the sea rather than as water breaking in it.
        drawTidepoolSurf(in: &shot, at: 0.53, reach: 0.008, foam: 0.34, seed: 821)
        drawBirds(in: &shot, at: 0.30)

        // The strand, laid over the foot of the water, with the sky sitting in it.
        drawLand(in: &shot, ridge: 0.66, rise: 0.02, waves: 1.3, phase: 0.8, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.66, reach: 0.02, foam: 0.85, seed: 823)
        drawTidepoolSheen(in: &shot, from: 0.66, to: 0.84, seed: 1_117)

        drawTidepoolPool(in: &shot, at: CGPoint(x: x(0.74), y: y(0.78)), width: 0.22, seed: 827)
        drawTidepoolPool(in: &shot, at: CGPoint(x: x(0.14), y: y(0.72)), width: 0.15, seed: 833)

        // Down the beach, small, with the sea taking up most of what he is buying.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.42), y: y(0.79 + 0.02 * along)),
            width: x(0.15 + 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawTidepoolWrack(in: &shot, along: 0.845, count: 9, seed: 829)
        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 2.4, color: colors.foreground)
    }

    /// The two halves of the scoring rule, one after the other on the same stretch of sand: the
    /// seashell while the line is selling the charm, and then the jellyfish while the line is
    /// admitting the hazard.
    ///
    /// The meadow says this in one picture, with an apple shut in a pen and a skull staked
    /// outside it, because the meadow is teaching the rule and the fence is half the lesson. The
    /// cove is teaching nobody anything. So the fence stays out of it and the shot changes hands
    /// instead, crossing exactly where the caption changes sentence — and the tide obliges by
    /// bringing the second one in, since everything on this beach arrived the same way.
    func drawShellsAndJellyfish(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the charm to the hazard: the first sentence has faded out
        // and the second is coming up, so the strand may change its mind under cover of it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.38))
        drawSun(in: &shot, at: CGPoint(x: x(0.24), y: y(0.18)), radius: x(0.065), rays: false)
        drawClouds(in: &shot, at: 0.14, drift: -0.008 * progress)
        drawBirds(in: &shot, at: 0.26)
        drawTidepoolSea(in: &shot, from: 0.38, to: 0.60, seed: 839)
        drawTidepoolSurf(in: &shot, at: 0.49, reach: 0.011, foam: 0.45, seed: 853)

        drawLand(in: &shot, ridge: 0.60, rise: 0.022, waves: 1.4, phase: 2.1, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.60, reach: 0.02, foam: 0.8, seed: 857)
        drawTidepoolSheen(in: &shot, from: 0.60, to: 0.82, seed: 1_123)

        // Leaning in at what is being sold and back from what is being admitted, which is the
        // only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.26), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        // The charm, lying in its own light with the rest of its kind thrown down round it.
        var charm = shot
        charm.opacity = 1 - turn
        let spot = CGPoint(x: x(0.64), y: y(0.78))
        charm.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.34), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &charm, "🐚", at: spot, width: x(0.22))

        // And the hazard, stranded in the same spot with the light off it and a ring of wet
        // still round it, because it has not been out of the water long.
        var hazard = shot
        hazard.opacity = turn
        hazard.fill(
            Path(ellipseIn: CGRect(
                x: spot.x - x(0.11), y: spot.y - x(0.028),
                width: x(0.22), height: x(0.056)
            )),
            with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.18 : 0.38))
        )
        drawTreat(in: &hazard, "🪼", at: spot, width: x(0.22))

        // The wrack line belongs to the beach rather than to the half of the shot that is
        // being sold: drawn into the charm's own fading layer it took the strand's only texture
        // with it when the line turned, and left the pig standing on a slab of tan.
        drawTidepoolWrack(in: &shot, along: 0.855, count: 8, seed: 859)
        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 0.4, color: colors.foreground)
    }

    /// The pig planted on the waterline with the cove behind it and a wave coming up over its
    /// feet as it stands there: ready to put in an offer on ground that is on loan, and the
    /// picture is the only one saying so. The camera pulls back to fit the sea in.
    func drawPuttingInAnOffer(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.09 * progress)

        drawSky(in: &shot, horizon: y(0.24))
        drawSun(in: &shot, at: CGPoint(x: x(0.62), y: y(0.11)), radius: x(0.055), rays: false)
        drawClouds(in: &shot, at: 0.14, drift: -0.01 * progress)
        // Down the left, clear of the way out in the top right corner: a cape stood behind the
        // Skip button is a shape with a button on it rather than a headland.
        drawTidepoolHeadland(in: &shot, at: 0.12, base: 0.34, height: 0.16, width: 0.38, haze: 0.46, snow: 0)

        // Half sea and half strand rather than two thirds sea. The words go across open water,
        // which is the one thing on this beach with nothing on it — but a sea that runs to the
        // bottom of the frame is a wall of blue, and the property is the sand.
        drawTidepoolSea(in: &shot, from: 0.24, to: 0.64, seed: 863)
        // The one breaker line is kept above the middle band of the frame, since the words on a
        // card are cream and white water is the one thing they cannot be read over.
        drawTidepoolSurf(in: &shot, at: 0.32, reach: 0.010, foam: 0.35, seed: 877)
        drawBirds(in: &shot, at: 0.15)

        // The swash runs up the sand as the shot holds, so by the last frame the offer is being
        // made with the sea round his ankles.
        let swash = easeOut(progress)
        drawLand(in: &shot, ridge: 0.66, rise: 0.02, waves: 1.2, phase: 1.9, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.66 + 0.035 * swash, reach: 0.022, foam: 0.9, seed: 883)
        drawTidepoolSheen(in: &shot, from: 0.68, to: 0.90, seed: 1_129)

        drawTidepoolPool(in: &shot, at: CGPoint(x: x(0.26), y: y(0.84)), width: 0.24, seed: 887)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.64), y: y(0.82)),
            width: x(0.18),
            lean: 3,
            squash: 1 - 0.05 * hop(cycles: 2)
        )
        drawTidepoolWrack(in: &shot, along: 0.92, count: 8, seed: 907)
    }

    // MARK: - The Crab Pool

    /// The guest house, and the guest, found in the same second: the crab coming up out of the
    /// middle of a rock pool the pig had walked past twice taking it for a puddle. It arrives by
    /// growing out of the water rather than by walking in from the side, because that is what
    /// something that lives in a hole does, and the pig is already leaning away from it.
    func drawTheGuestHouse(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.05 * progress, drift: 0.012 * progress)

        drawSky(in: &shot, horizon: y(0.36))
        drawSun(in: &shot, at: CGPoint(x: x(0.78), y: y(0.21)), radius: x(0.055), rays: false)
        drawClouds(in: &shot, at: 0.15, drift: 0.01 * progress)
        drawBirds(in: &shot, at: 0.24)
        drawTidepoolSea(in: &shot, from: 0.36, to: 0.54, seed: 911)
        drawTidepoolSurf(in: &shot, at: 0.46, reach: 0.010, foam: 0.4, seed: 919)

        drawLand(in: &shot, ridge: 0.54, rise: 0.02, waves: 1.3, phase: 1.1, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.54, reach: 0.018, foam: 0.8, seed: 929)
        drawTidepoolSheen(in: &shot, from: 0.54, to: 0.72, seed: 1_151)
        drawTidepoolWrack(in: &shot, along: 0.665, count: 7, seed: 937)

        // The pool near the camera and large enough to be somebody's address rather than a
        // puddle: the same broken ring every board in this world is built out of.
        let pool = CGPoint(x: x(0.60), y: y(0.80))
        drawTidepoolPool(in: &shot, at: pool, width: 0.46, seed: 941)

        // Up out of the heart of it, and in no hurry.
        let up = easeOut(min(progress / 0.7, 1))
        drawAnimal(
            in: &shot,
            .crab,
            feet: CGPoint(x: pool.x, y: y(0.815 - 0.02 * up)),
            width: x(0.05 + 0.09 * up),
            shadow: 0.5 + 0.5 * up
        )

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.20), y: y(0.82)), width: x(0.17), lean: -7)
        drawLand(in: &shot, ridge: 0.92, rise: 0.012, waves: 1.0, phase: 2.0, color: colors.foreground)
    }

    /// The rule drawn in the order the caption says it: the crab's pen closing round its pool
    /// first, and then the pig's opening round the outside of that. Nothing else in the game is
    /// built this way — every other world's second pen goes beside the first — so the shot takes
    /// the two clauses one at a time and lets the second one swallow the first.
    func drawTheCrabsOwnPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawClouds(in: &shot, at: 0.12, drift: -0.008 * progress)
        drawBirds(in: &shot, at: 0.21)
        drawTidepoolSea(in: &shot, from: 0.30, to: 0.48, seed: 947)
        drawTidepoolSurf(in: &shot, at: 0.41, reach: 0.010, foam: 0.4, seed: 953)

        drawLand(in: &shot, ridge: 0.48, rise: 0.02, waves: 1.3, phase: 2.3, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.48, reach: 0.018, foam: 0.78, seed: 967)
        drawTidepoolSheen(in: &shot, from: 0.48, to: 0.66, seed: 1_153)

        let crab = CGPoint(x: x(0.56), y: y(0.72))
        let pig = CGPoint(x: x(0.24), y: y(0.79))
        drawTidepoolPool(in: &shot, at: crab, width: 0.30, seed: 971)
        drawAnimal(in: &shot, .crab, feet: crab, width: x(0.11), shadow: 0.8)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))

        // First clause: the crab's own, and it is barely bigger than the pool it is round,
        // because a crab does not need the room and nobody was offering it any.
        let his = easeOut(min(progress / 0.42, 1))
        drawGhostPen(in: &shot, round: crab, width: 0.30, height: 0.10, drop: 0.014, opacity: 0.9 * his)

        // Second clause, once the first has finished being said: the pig's, going the whole way
        // round the outside without ever touching it.
        let hers = easeOut(min(max((progress - 0.48) / 0.44, 0), 1))
        drawGhostPen(
            in: &shot,
            round: CGPoint(x: x(0.46), y: y(0.84)),
            width: 0.78,
            height: 0.24,
            drop: 0,
            opacity: 0.9 * hers
        )

        drawTidepoolWrack(in: &shot, along: 0.875, count: 7, seed: 977)
    }

    /// Both pens finished and one inside the other, with clear sand all the way round between
    /// them: the picture no other world in the game has to draw. Everywhere else two pens sit
    /// side by side and the gap between them is a corridor; here the gap is a moat, and it is
    /// the whole rule — the crab's ring is not allowed to lean on the pig's fence anywhere.
    ///
    /// Composed low, with the sea kept high and empty, so the words can be set big across the
    /// middle without landing on either fence.
    func drawPenWithinAPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.03 * progress)

        // The sea and its white water are held high and the pens low, so the whole middle of
        // the frame is bare wet sand for the words to sit on.
        drawSky(in: &shot, horizon: y(0.16))
        drawTidepoolSea(in: &shot, from: 0.16, to: 0.32, seed: 983)
        drawTidepoolSurf(in: &shot, at: 0.25, reach: 0.009, foam: 0.4, seed: 991)

        drawLand(in: &shot, ridge: 0.32, rise: 0.018, waves: 1.2, phase: 1.5, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.32, reach: 0.016, foam: 0.75, seed: 997)
        drawTidepoolSheen(in: &shot, from: 0.32, to: 0.56, seed: 1_163)
        // Something for the words to sit over other than one flat tan: the wrack line the tide
        // left high up the strand, and a pool away at the edge where nothing is being fenced.
        drawTidepoolWrack(in: &shot, along: 0.40, count: 9, seed: 1_003)
        drawTidepoolPool(in: &shot, at: CGPoint(x: x(0.15), y: y(0.60)), width: 0.18, seed: 1_007)

        let crab = CGPoint(x: x(0.58), y: y(0.80))
        drawTidepoolPool(in: &shot, at: crab, width: 0.26, seed: 1_009)
        drawAnimal(in: &shot, .crab, feet: crab, width: x(0.10), shadow: 0.8)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.22), y: y(0.84)), width: x(0.15))

        // Both at once this time, since the argument is no longer about the order. The inner
        // pen stops well short of the outer on every side; the sand between them is the shot.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: crab, width: 0.24, height: 0.085, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(
            in: &shot,
            round: CGPoint(x: x(0.48), y: y(0.88)),
            width: 0.84,
            height: 0.22,
            drop: 0,
            opacity: 0.9 * drawn
        )
    }

    // MARK: - The cove held

    /// Both pens holding after dark: the crab's own ring inside the pig's ground with sand all
    /// round it, shells lying about where the tide left them, and the moon laid out across the
    /// water. Beautiful views and excellent beach access, exactly as advertised — and out on the
    /// sand beyond the fence, arriving at their own pace, the uninvited.
    func drawCoveHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        // The disc at this hour is the moon, and on a coast it comes with a road.
        drawSun(in: &shot, at: CGPoint(x: x(0.68), y: y(0.14)), radius: x(0.05), rays: false)
        drawTidepoolSea(in: &shot, from: 0.30, to: 0.52, seed: 1_013)
        drawTidepoolGlitter(in: &shot, under: 0.68, from: 0.32, to: 0.52, seed: 1_019)
        drawTidepoolSurf(in: &shot, at: 0.43, reach: 0.010, foam: 0.35, seed: 1_021)

        drawLand(in: &shot, ridge: 0.52, rise: 0.02, waves: 1.3, phase: 0.9, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.52, reach: 0.018, foam: 0.6, seed: 1_031)
        drawTidepoolSheen(in: &shot, from: 0.52, to: 0.74, seed: 1_171)

        // The pig's ground first, since everything else in the shot is standing on it. It is
        // kept shallow and no wider than it needs to be: a held pen is washed the game's gold,
        // and a tall one on a dark beach comes out as a sheet of yellow card lying on the sand
        // with the picture stopped behind it.
        let pig = CGPoint(x: x(0.48), y: y(0.83))
        drawPenWash(in: &shot, round: pig, width: 0.68, height: 0.22, drop: 0)
        drawTidepoolWrack(in: &shot, along: 0.68, count: 7, seed: 1_037)

        // The guest house, inside it and fenced off from it: the crab has its pool, its own
        // rail round the pool, and a clear yard of sand between that rail and the pig's. The
        // pool goes on after the wash — under it, the gold swallowed the one thing the crab's
        // pen is round.
        let crab = CGPoint(x: x(0.62), y: y(0.76))
        drawPenWash(in: &shot, round: crab, width: 0.20, height: 0.07, drop: 0.012)
        drawTidepoolPool(in: &shot, at: crab, width: 0.18, seed: 1_033)
        drawAnimal(in: &shot, .crab, feet: crab, width: x(0.08), shadow: 0.6)
        drawPenFence(in: &shot, round: crab, width: 0.20, height: 0.07, drop: 0.012)

        drawTreat(in: &shot, "🐚", at: CGPoint(x: x(0.22), y: y(0.70)), width: x(0.05))
        drawTreat(in: &shot, "🐚", at: CGPoint(x: x(0.38), y: y(0.81)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.28), y: y(0.79)), width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.68, height: 0.22, drop: 0)

        // Outside the fence and sidling in from both ends, one of them further along than the
        // other: the third sentence of the caption, walking. Both stand clear of the edge of
        // the frame — a crab cut in half by it reads as a mistake rather than as an arrival.
        let creep = easeOut(progress)
        drawAnimal(
            in: &shot,
            .crab,
            feet: CGPoint(x: x(0.07 + 0.03 * creep), y: y(0.80)),
            width: x(0.055),
            shadow: 0.5
        )
        drawAnimal(
            in: &shot,
            .crab,
            feet: CGPoint(x: x(0.91 - 0.03 * creep), y: y(0.74)),
            width: x(0.05),
            shadow: 0.5
        )

        drawTidepoolWrack(in: &shot, along: 0.87, count: 8, seed: 1_039)
    }

    /// The pig going up the strand with its back to the sea for the first time in three films,
    /// the crabs it is leaving behind spread out over the sand it paid for, and the first cold
    /// of somewhere else coming in off the water. Nothing here is a disaster; it is simply four
    /// crustaceans too many, which is how most people leave a house.
    func drawEnoughOfSandAndSurf(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress, drift: -0.02 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawTidepoolSea(in: &shot, from: 0.34, to: 0.56, seed: 1_049)
        drawTidepoolSurf(in: &shot, at: 0.46, reach: 0.011, foam: 0.4, seed: 1_051)

        drawLand(in: &shot, ridge: 0.56, rise: 0.02, waves: 1.3, phase: 2.4, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.56, reach: 0.018, foam: 0.6, seed: 1_061)
        drawTidepoolSheen(in: &shot, from: 0.56, to: 0.76, seed: 1_181)
        drawTidepoolPool(in: &shot, at: CGPoint(x: x(0.32), y: y(0.70)), width: 0.24, seed: 1_063)

        // The reason he is leaving, at four different distances so it reads as a population
        // rather than as a line-up. They are kept well up the strand: this caption runs to
        // three lines and reaches higher up the frame than any other in the world, and a crab
        // standing in the middle of a sentence is a crab nobody can read past.
        let guests: [(across: Double, down: Double, width: Double, shadow: Double)] = [
            (0.16, 0.62, 0.045, 0.5),
            (0.30, 0.72, 0.062, 0.7),
            (0.46, 0.65, 0.05, 0.6),
            (0.58, 0.75, 0.068, 0.8)
        ]
        for (index, guest) in guests.enumerated() {
            let sidle = sin(progress * 2 * .pi + Double(index) * 1.7) * 0.012
            drawAnimal(
                in: &shot,
                .crab,
                feet: CGPoint(x: x(guest.across + (moves ? sidle : 0)), y: y(guest.down)),
                width: x(guest.width),
                shadow: guest.shadow
            )
        }

        // And away up the beach, leaning into a wind that has come a long way to be here.
        let off = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.76 + 0.06 * off), y: y(0.76)),
            width: x(0.16),
            lean: 7,
            squash: 1 - 0.04 * hop(cycles: 2)
        )

        drawTidepoolWrack(in: &shot, along: 0.79, count: 8, seed: 1_069)
        drawTidepoolFlurry(in: &shot, count: 14, seed: 1_087)
        drawLand(in: &shot, ridge: 0.94, rise: 0.012, waves: 1.0, phase: 1.3, color: colors.foreground)
    }

    /// The far shore, gone white while nobody was looking at it: slopes standing over the water
    /// with the snow already down them, ice riding in on the tide, and the pig small on the last
    /// warm sand in the game looking at the next listing.
    ///
    /// The slopes are drawn high enough that their tops clear the card, and the sea is drawn over
    /// their feet, so what the words sit on is open water between here and there.
    func drawNearTheSlopes(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.09 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.50))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.15)), radius: x(0.045), rays: false)

        // Two headlands: a dark cape close in on the right, and the far shore beyond it with the
        // snow lying above a line. A coast going white by degrees reads as somewhere colder than
        // here, where one white shape on its own reads as a cloud that has landed — and the
        // white is kept high, because the words on a card are cream too.
        drawTidepoolHeadland(in: &shot, at: 0.82, base: 0.66, height: 0.24, width: 0.40, haze: 0.34, snow: 0)
        drawTidepoolHeadland(in: &shot, at: 0.34, base: 0.58, height: 0.34, width: 0.62, haze: 0.18, snow: 0.24)

        drawTidepoolSea(in: &shot, from: 0.50, to: 0.78, seed: 1_091)
        drawTidepoolGlitter(in: &shot, under: 0.22, from: 0.60, to: 0.78, seed: 1_093)
        drawTidepoolSurf(in: &shot, at: 0.66, reach: 0.010, foam: 0.35, seed: 1_097)

        // What the next world sends ahead of itself, floating in on the same tide that has been
        // delivering crabs all week.
        drawTreat(in: &shot, "🧊", at: CGPoint(x: x(0.70), y: y(0.745)), width: x(0.05))

        drawLand(in: &shot, ridge: 0.80, rise: 0.018, waves: 1.2, phase: 0.6, color: colors.ground)
        drawTidepoolSurf(in: &shot, at: 0.80, reach: 0.016, foam: 0.6, seed: 1_103)
        drawTidepoolSheen(in: &shot, from: 0.80, to: 0.94, seed: 1_187)

        // Small, low, and already facing the wrong way for a beach.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.87)), width: x(0.13), lean: -4, shadow: 0.6)

        drawTidepoolFlurry(in: &shot, count: 22, seed: 1_109)
    }

    // MARK: - What a coast is made of

    /// The sea: a band of water from the horizon down past the shoreline, deep at the far end
    /// and shallow at the near one, with the swell running across it in long low lines.
    ///
    /// It is filled a long way below the shore it is given, because the strand is drawn over the
    /// bottom of it afterwards — a sea that stops exactly where the sand starts is two coloured
    /// rectangles, whichever way they are shaded. The far third has the sky laid back over it,
    /// which is the same trick a mountain needs and for the same reason: the water at the
    /// horizon is not a paler blue, it is the air in front of it.
    func drawTidepoolSea(
        in context: inout GraphicsContext,
        from horizon: Double,
        to shore: Double,
        seed: UInt64
    ) {
        let top = y(horizon)
        let foot = y(shore)
        let depth = max(foot - top, 1)
        let night = colors.isNight

        // Opaque, always. The sea is drawn after the headlands and over the feet of them, and a
        // water you can see through leaves the buried half of a cliff hanging in it as a ghost —
        // which is the one thing a picture of deep water must never do. Night is a wash laid
        // over the finished water rather than a thinner water.
        let sea = Path(CGRect(
            x: -size.width, y: top,
            width: size.width * 3, height: depth + size.height
        ))
        context.fill(
            sea,
            with: .linearGradient(
                Gradient(colors: [GamePalette.waterDeep, GamePalette.water]),
                startPoint: CGPoint(x: 0, y: top),
                endPoint: CGPoint(x: 0, y: foot)
            )
        )
        if night {
            context.fill(sea, with: .color(colors.skyTop.opacity(0.62)))
        }

        // The air between here and the horizon.
        context.fill(
            Path(CGRect(x: -size.width, y: top, width: size.width * 3, height: depth * 0.36)),
            with: .linearGradient(
                Gradient(colors: [
                    colors.skyHorizon.opacity(night ? 0.55 : 0.72),
                    colors.skyHorizon.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: top),
                endPoint: CGPoint(x: 0, y: top + depth * 0.36)
            )
        )

        // The swell: shallow arcs bowed the same way, each running across part of the width and
        // stopping. Ruled right across the frame and stacked evenly they came out as corduroy —
        // a striped floor rather than water — so they are fewer now, faint, and every one a
        // different length, which is what makes a flat blue read as a surface with a distance
        // in it. They shift sideways as the shot runs, and that is all the motion water needs.
        var scatter = Scatter(seed: seed)
        let sway = moves ? sin(progress * .pi) * 0.02 : 0

        for _ in 0..<10 {
            let along = pow(scatter.next(), 0.7)
            let down = top + depth * CGFloat(0.10 + along * 0.94)
            let lift = depth * CGFloat(0.012 + along * 0.03)
            let drift = x(sway * (0.3 + along))
            let start = x(scatter.next(in: -0.25...0.45)) + drift
            let end = start + x(scatter.next(in: 0.40...1.05))

            var line = Path()
            line.move(to: CGPoint(x: start, y: down))
            line.addCurve(
                to: CGPoint(x: end, y: down + lift * 0.3),
                control1: CGPoint(x: start + (end - start) * 0.35, y: down - lift),
                control2: CGPoint(x: start + (end - start) * 0.70, y: down - lift * 0.6)
            )
            context.stroke(
                line,
                with: .color(GamePalette.waterRipple.opacity((night ? 0.09 : 0.24) * (0.35 + along))),
                style: StrokeStyle(
                    lineWidth: max(0.8, depth * CGFloat(0.005 + along * 0.011)),
                    lineCap: .round
                )
            )
        }
    }

    /// White water, drawn as a band across the frame rather than as a line: a wavy upper edge, a
    /// wavy lower one, and a few torn-off lobes below it.
    ///
    /// One brush does both jobs a coast needs. Out on the water at low `foam` it is the line
    /// where the swell is breaking, which is what tells the eye the flat blue has a distance in
    /// it; laid along the shoreline at high `foam` it is the swash, and it is the reason the sand
    /// and the sea never meet on a ruled edge anywhere in this world.
    func drawTidepoolSurf(
        in context: inout GraphicsContext,
        at level: Double,
        reach: Double,
        foam: Double,
        seed: UInt64
    ) {
        let line = y(level)
        let thick = y(reach)
        let width = max(size.width, 1)
        var scatter = Scatter(seed: seed)
        let phase = scatter.next() * 6.0
        let waves = 5.0 + scatter.next() * 4.0

        func edge(_ across: CGFloat, _ bias: Double) -> CGFloat {
            line + thick * CGFloat(bias)
                - thick * CGFloat(sin(Double(across / width) * waves * .pi + phase)) * 0.42
        }

        var band = Path()
        let start = -size.width
        let end = size.width * 2
        band.move(to: CGPoint(x: start, y: edge(start, 0)))
        var across = start
        while across < end {
            band.addLine(to: CGPoint(x: across, y: edge(across, 0)))
            across += 10
        }
        band.addLine(to: CGPoint(x: end, y: edge(end, 1)))
        across = end
        while across > start {
            band.addLine(to: CGPoint(x: across, y: edge(across, 1)))
            across -= 10
        }
        band.closeSubpath()
        context.fill(band, with: .color(GamePalette.cream.opacity(foam * (colors.isNight ? 0.45 : 0.85))))

        // The torn edge: lobes of foam left behind under the band, thinning as they go, so the
        // white water has somewhere to have come from.
        for _ in 0..<7 {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.05...1.05)),
                y: line + thick * CGFloat(1.1 + scatter.next() * 1.6)
            )
            let wide = x(scatter.next(in: 0.05...0.16))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - wide / 2, y: centre.y - thick * 0.3,
                    width: wide, height: thick * 0.6
                )),
                with: .color(GamePalette.cream.opacity(foam * (colors.isNight ? 0.18 : 0.4)))
            )
        }
    }

    /// The sky lying in the sand under the waterline, which is the one thing a wet beach has and
    /// a dry one never does.
    ///
    /// A wash of the horizon's own colour over the ground, strongest at the water and gone by
    /// the time it reaches the front of the frame, with a few streaks of standing water in it.
    /// The sand is not repainted for this; it is the same band every other world uses, with the
    /// weather put back on top of it.
    func drawTidepoolSheen(
        in context: inout GraphicsContext,
        from waterline: Double,
        to dry: Double,
        seed: UInt64
    ) {
        let top = y(waterline)
        let foot = y(dry)
        let sheen = colors.isNight ? colors.discHalo : colors.skyHorizon

        context.fill(
            Path(CGRect(x: -size.width, y: top, width: size.width * 3, height: foot - top)),
            with: .linearGradient(
                Gradient(colors: [
                    sheen.opacity(colors.isNight ? 0.30 : 0.52),
                    sheen.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: top),
                endPoint: CGPoint(x: 0, y: foot)
            )
        )

        // Standing water in the flats, where the last wave did not quite drain away. Seeded per
        // shot rather than once for the world, so no two beaches dry the same way — a strand is
        // mostly one colour and these are most of what stops it being a slab of it.
        var scatter = Scatter(seed: seed)
        for _ in 0..<9 {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.1...1.1)),
                y: top + (foot - top) * CGFloat(scatter.next(in: 0.1...0.9))
            )
            let wide = x(scatter.next(in: 0.14...0.34))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - wide / 2, y: centre.y - wide * 0.05,
                    width: wide, height: wide * 0.1
                )),
                with: .color(GamePalette.waterRipple.opacity(colors.isNight ? 0.16 : 0.34))
            )
        }
    }

    /// A rock pool: a ring of tidewater round a heart of dry sand, with one break in its lip
    /// where the water got out.
    ///
    /// This is the world's own shape and the reason it exists. Every board in the cove is built
    /// out of broken rings, and a pool in the films has to be the same object seen from the
    /// beach — a finished pen with a bite taken out of it, offering itself for nothing, which is
    /// the joke every field here is playing. It is flattened hard, because a pool seen from
    /// standing height is an ellipse a fifth as tall as it is wide and anything rounder reads as
    /// a hole rather than as water.
    func drawTidepoolPool(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        width: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let wide = x(width)
        let tall = wide * 0.34
        let ring = CGRect(x: centre.x - wide / 2, y: centre.y - tall, width: wide, height: tall)
        let lip = wide * 0.15
        let night = colors.isNight

        // The wet rim the pool always has round it, so the water is set into the sand rather
        // than laid on it.
        context.fill(
            Path(ellipseIn: ring.insetBy(dx: -lip * 0.6, dy: -lip * 0.3)),
            with: .color(colors.blade.opacity(night ? 0.35 : 0.28))
        )
        context.fill(
            Path(ellipseIn: ring),
            with: .color(GamePalette.waterDeep.opacity(night ? 0.55 : 0.95))
        )
        // The sky sitting on the water, which is most of what a pool is by daylight.
        context.fill(
            Path(ellipseIn: ring.insetBy(dx: wide * 0.06, dy: tall * 0.12)),
            with: .color(colors.skyHorizon.opacity(night ? 0.22 : 0.34))
        )
        // And the heart of dry sand in the middle of it.
        context.fill(
            Path(ellipseIn: ring.insetBy(dx: wide * 0.26, dy: tall * 0.26)),
            with: .color(colors.ground)
        )

        // The break in the lip, scoured through wherever this pool happens to keep it: sand
        // carried across the ring, so the heart is joined to the beach at exactly one place.
        let gap = scatter.next() * 2 * .pi
        let mouth = CGPoint(
            x: ring.midX + CGFloat(cos(gap)) * wide * 0.38,
            y: ring.midY + CGFloat(sin(gap)) * tall * 0.38
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: mouth.x - wide * 0.09, y: mouth.y - tall * 0.22,
                width: wide * 0.18, height: tall * 0.44
            )),
            with: .color(colors.ground)
        )

        // A glint on the far side of the ring, and a stone or two on the near lip.
        context.fill(
            Path(ellipseIn: CGRect(
                x: ring.midX - wide * 0.16, y: ring.minY + tall * 0.06,
                width: wide * 0.3, height: tall * 0.1
            )),
            with: .color(GamePalette.cream.opacity(night ? 0.24 : 0.55))
        )
        for _ in 0..<3 {
            let stone = CGPoint(
                x: ring.midX + CGFloat(scatter.next(in: -0.55...0.55)) * wide,
                y: ring.maxY + CGFloat(scatter.next(in: -0.1...0.35)) * tall
            )
            let pebble = wide * CGFloat(scatter.next(in: 0.03...0.07))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: stone.x - pebble, y: stone.y - pebble * 0.6,
                    width: pebble * 2, height: pebble * 1.2
                )),
                with: .color(GamePalette.stone.opacity(night ? 0.45 : 0.7))
            )
        }
    }

    /// The wrack line: what the sea threw furthest up the strand and then left, in a strewn line
    /// across the frame — weed in dark torn ribbons with shells and weeded stones among it.
    ///
    /// The same dressing the cove's own boards carry along their front, which is the point: the
    /// junk in the film is the junk on the field. It also does the job a rank of tufts does in
    /// every other world, which is to give the flat foot of a picture something to catch on.
    func drawTidepoolWrack(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let weed = Color(red: 0.30, green: 0.30, blue: 0.16)

        for index in 0..<count {
            let foot = CGPoint(
                x: x((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)),
                y: y(baseline + (scatter.next() - 0.5) * 0.02)
            )
            let wide = x(0.03) * CGFloat(0.6 + scatter.next() * 1.1)

            if scatter.next() < 0.62 {
                // A ribbon of weed: a flattened lobe with a tail dragged off one end, which is
                // how kelp lies once the water is done with it.
                var ribbon = Path()
                ribbon.addEllipse(in: CGRect(
                    x: foot.x - wide / 2, y: foot.y - wide * 0.18,
                    width: wide, height: wide * 0.36
                ))
                ribbon.addEllipse(in: CGRect(
                    x: foot.x + wide * 0.3, y: foot.y - wide * 0.1,
                    width: wide * 0.7, height: wide * 0.2
                ))
                context.fill(ribbon, with: .color(weed.opacity(colors.isNight ? 0.5 : 0.72)))
            } else {
                // A shell, or a stone that has been in the water long enough to look like one.
                let shell = CGRect(
                    x: foot.x - wide * 0.22, y: foot.y - wide * 0.28,
                    width: wide * 0.44, height: wide * 0.3
                )
                context.fill(
                    Path(ellipseIn: shell),
                    with: .color(GamePalette.cream.opacity(colors.isNight ? 0.45 : 0.85))
                )
                context.stroke(
                    Path(ellipseIn: shell),
                    with: .color(GamePalette.stone.opacity(0.55)),
                    lineWidth: max(0.6, wide * 0.03)
                )
            }
        }
    }

    /// The light of whatever disc the shot has, laid out across the water toward the camera: a
    /// column of short bright dashes, narrow at the horizon and spreading as it comes in.
    ///
    /// The one thing that makes water read as water rather than as a coloured floor. It is also
    /// the cove's answer to the thicket's fireflies — something moving in a still frame — since
    /// the dashes shuffle along their own lines as the shot runs.
    func drawTidepoolGlitter(
        in context: inout GraphicsContext,
        under across: Double,
        from horizon: Double,
        to shore: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let top = y(horizon)
        let foot = y(shore)
        let depth = max(foot - top, 1)
        let centre = x(across)

        for _ in 0..<26 {
            let along = scatter.next()
            let down = top + depth * CGFloat(along)
            // The column spreads as it nears the beach, the way a moon path always does.
            let spread = x(0.02 + 0.14 * along)
            // Drawn from the scatter whether or not the camera is running, so a still frame
            // stands the dashes in the same places a moving one would pass through.
            let beat = scatter.next() * 6
            let shuffle = moves ? sin(progress * 2 * .pi + beat) * 0.25 : 0
            let dash = CGFloat(scatter.next(in: 0.4...1.0))
            let wide = spread * dash * 0.5

            context.fill(
                Path(roundedRect: CGRect(
                    x: centre + CGFloat(scatter.next(in: -1.0...1.0) + shuffle) * spread - wide / 2,
                    y: down,
                    width: wide,
                    height: max(1, depth * 0.012)
                ), cornerRadius: max(0.5, depth * 0.006)),
                with: .color(colors.discHalo.opacity(0.20 + 0.45 * Double(dash)))
            )
        }
    }

    /// A headland: a bluff standing out into the water, drawn as two faces meeting on a ridge
    /// that comes down to the sea, rather than as one shape with a wash over half of it.
    ///
    /// Both faces are the world's own far-hill colour, one lifted and one knocked back, rather
    /// than two different colours: a cliff painted in a green borrowed from a forest reads as a
    /// tent pitched on the horizon, and the fold is doing all the work anyway.
    ///
    /// `haze` lays the sky back over the finished rock, which is what puts one headland behind
    /// another. `snow` is how far down from the crest the white lies, as a fraction of the
    /// height, and it is what the send-off uses to say the far shore has gone white without
    /// having to say anything. The cap is cut to the two ridges it lies on rather than drawn to
    /// its own shape, since a wedge that ignores the rock under it reads as a paper dart.
    ///
    /// Its feet are meant to be buried — the sea is drawn after it and laps over the bottom of
    /// the cliff, so it stands in the water instead of on it.
    func drawTidepoolHeadland(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        haze: Double,
        snow: Double
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        let crest = CGPoint(x: centre - span * 0.12, y: foot - tall)
        // The shoulder the inland ridge runs out along, and the brow where the seaward face
        // turns over into the cliff: between them they put the two faces out of square with
        // each other, which is the whole difference between rock and a paper triangle.
        let shoulder = CGPoint(x: crest.x - span * 0.17, y: crest.y + tall * 0.20)
        let inland = CGPoint(x: centre - span * 0.50, y: foot)
        let hip = CGPoint(x: centre + span * 0.10, y: foot)
        let brow = CGPoint(x: centre + span * 0.38, y: crest.y + tall * 0.62)
        let seaFoot = CGPoint(x: centre + span * 0.50, y: foot)

        var landward = Path()
        landward.move(to: inland)
        landward.addLine(to: shoulder)
        landward.addLine(to: crest)
        landward.addLine(to: hip)
        landward.closeSubpath()
        context.fill(landward, with: .color(colors.farHill))
        context.fill(landward, with: .color(GamePalette.cream.opacity(0.12)))

        var seaward = Path()
        seaward.move(to: hip)
        seaward.addLine(to: crest)
        seaward.addLine(to: brow)
        seaward.addLine(to: seaFoot)
        seaward.closeSubpath()
        context.fill(seaward, with: .color(colors.farHill))
        context.fill(seaward, with: .color(.black.opacity(0.22)))

        if snow > 0 {
            let line = crest.y + tall * CGFloat(snow)

            // Where the snow line crosses each ridge, so the cap ends on the rock rather than
            // in the air beside it.
            func meeting(_ from: CGPoint, _ to: CGPoint) -> CGFloat {
                let drop = to.y - from.y
                guard abs(drop) > 0.5 else { return to.x }
                let along = min(max((line - from.y) / drop, 0), 1)
                return from.x + (to.x - from.x) * along
            }
            let landSide = line <= shoulder.y ? meeting(crest, shoulder) : meeting(shoulder, inland)
            let seaSide = line <= brow.y ? meeting(crest, brow) : meeting(brow, seaFoot)

            // A broken lower edge, so it reads as snow lying on rock rather than as white paint
            // ruled across it.
            var cap = Path()
            cap.move(to: crest)
            cap.addLine(to: CGPoint(x: seaSide, y: line))
            cap.addLine(to: CGPoint(x: (seaSide + crest.x) / 2, y: line - tall * 0.07))
            cap.addLine(to: CGPoint(x: (crest.x + landSide) / 2, y: line + tall * 0.04))
            cap.addLine(to: CGPoint(x: landSide, y: line - tall * 0.04))
            cap.closeSubpath()
            context.fill(cap, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.52 : 0.8)))
        }

        if haze > 0 {
            var whole = Path()
            whole.move(to: inland)
            whole.addLine(to: shoulder)
            whole.addLine(to: crest)
            whole.addLine(to: brow)
            whole.addLine(to: seaFoot)
            whole.closeSubpath()
            context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
        }
    }

    /// The first snow of the next world, blown in sideways off the water: flakes carried across
    /// the frame rather than falling down it, because on a coast nothing comes down straight.
    ///
    /// It is the send-off's only warm-blooded moving thing once the pig has turned round, and it
    /// does the arguing the caption is too polite to do — the cove is over, and the weather knew
    /// first.
    func drawTidepoolFlurry(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let lane = scatter.next()
            let phase = scatter.next()
            // Each flake crosses its own lane once, and starts wherever its phase put it, so at
            // any single frame the air is full rather than in step.
            let along = (phase + (moves ? progress * 0.7 : 0.35)).truncatingRemainder(dividingBy: 1)
            let spot = CGPoint(
                x: x(-0.05 + 1.1 * along),
                y: y(0.10 + lane * 0.78) + y(0.05) * CGFloat(sin(along * 3 * .pi + phase * 6))
            )
            let flake = x(0.004 + scatter.next() * 0.006)

            context.fill(
                circle(at: spot, radius: flake),
                with: .color(GamePalette.cream.opacity(0.35 + 0.45 * scatter.next()))
            )
        }
    }
}
