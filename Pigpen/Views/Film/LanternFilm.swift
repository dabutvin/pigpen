import Foundation
import SwiftUI
import UIKit

// MARK: - Lantern Carnival, painted

/// The carnival's nine shots, and the eleven brushes a field with a fair on it needs.
///
/// Every world before this one is drawn from the ground up and lit from the sky down: a horizon,
/// a band of whatever the ground is made of, and one light — a sun, a fissure, a crystal — that
/// says what time it is and what colour everything is that day. The carnival keeps the ground
/// and throws the rest away. Its skyline is canvas and steelwork rather than hills, and its
/// light comes off a string of paper lanterns hung between the two, which means the sky is the
/// least interesting thing in the frame and the floor is three colours at once. Painting it is
/// mostly a matter of remembering that: put the tent and the wheel up first, then the pools of
/// coloured light on the sawdust, then everything else standing in them.
///
/// Two things hold these compositions together, and both are borrowed from the thicket because
/// they were paid for the hard way. Nothing is put where the words go — the foot of the frame on
/// a shot with a subtitle, the middle of it on the three that hand the film over on a card. And
/// anything with a flat bottom edge is drawn first and had ground laid over its feet afterwards,
/// which for a tent means the ground band laps up the hem of it, for a wheel means the crowd
/// stands in front of the legs, and for the concession stand — which stands too far forward for
/// any of that — means a shadow under it and sawdust drifted over the join. A big top with a
/// visible hem is a sticker of a big top, and so is a stall.
extension Film {
    /// The carnival's first two films are lit by a sun that has very nearly gone — a fair at
    /// noon is a field with tents in it — and its send-off falls all the way into dark, which is
    /// the one world in the game where that is an improvement rather than a warning. It is also
    /// the shape of the joke: the film has to walk out of its own light to get to the desert.
    static func lanternLight(_ shot: CutScene.Picture.Lantern) -> GamePalette.Pasture {
        switch shot {
        case .constantNightlife, .somewhereMorePeaceful, .quietHours: .lanternDusk
        default: .lanternDay
        }
    }

    func drawLantern(_ shot: CutScene.Picture.Lantern, in context: inout GraphicsContext) {
        switch shot {
        case .theFairground: drawTheFairground(in: &context)
        case .popcornAndMegaphones: drawPopcornAndMegaphones(in: &context)
        case .moreLivelyThanTheCave: drawMoreLivelyThanTheCave(in: &context)
        case .theManagement: drawTheManagement(in: &context)
        case .aTightShip: drawATightShip(in: &context)
        case .theRingAndTheFence: drawTheRingAndTheFence(in: &context)
        case .constantNightlife: drawConstantNightlife(in: &context)
        case .somewhereMorePeaceful: drawSomewhereMorePeaceful(in: &context)
        case .quietHours: drawQuietHours(in: &context)
        }
    }

    // MARK: - The carnival's opening

    /// The fair from the track outside it, which is the only place in the film it can be seen
    /// whole: the big top in the middle, the wheel standing behind it, two side shows banked in
    /// either side, and the pig arriving at the foot of the lot. The camera pushes in, which is
    /// the shot agreeing to go through the gate.
    func drawTheFairground(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        // The sun is nearly down and is going down *behind* the fair, so the tents read as
        // canvas with a light in it rather than as canvas with a light on it.
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.54)), radius: x(0.065), rays: false)
        drawLand(in: &shot, ridge: 0.58, rise: 0.04, waves: 1.8, phase: 1.2, color: colors.farHill)

        // The skyline, back to front: the wheel furthest off and hazed, then the side shows, then
        // the big top over the lot of them.
        drawLanternWheel(in: &shot, at: CGPoint(x: x(0.83), y: y(0.44)), radius: x(0.15), haze: 0.35)
        drawLanternBigTop(in: &shot, at: 0.19, base: 0.66, height: 0.14, width: 0.20, haze: 0.30)
        drawLanternBigTop(in: &shot, at: 0.86, base: 0.67, height: 0.12, width: 0.18, haze: 0.30)
        drawLanternBigTop(in: &shot, at: 0.50, base: 0.70, height: 0.26, width: 0.42, haze: 0.08)

        // And the ground over the hems of all four, so the fair is pitched in a field instead of
        // standing on one.
        drawLand(in: &shot, ridge: 0.66, rise: 0.022, waves: 1.4, phase: 0.6, color: colors.ground)
        drawLanternSawdust(in: &shot, along: 0.74, count: 7, seed: 1_301)
        drawLanternPools(in: &shot, along: 0.78, spread: 0.30, count: 6, seed: 1_303)

        // The crowd between the pig and the tents, which is the difference between a fair and a
        // camp site.
        drawLanternCrowd(in: &shot, along: 0.70, count: 10, seed: 1_307)

        // At the gate and walking in: the property is the size of the picture and the buyer never
        // is. He stands clear of the foot of the frame, though — photographed at y(0.83) his chin
        // was in the first line of the caption, and a pig with words across it is not small, it is
        // in the way.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34 + 0.05 * along), y: y(0.79)),
            width: x(0.17),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawLanternBunting(in: &shot, at: 0.10, sag: 0.06, count: 16, seed: 1_309)
        drawLanternStrings(in: &shot, at: 0.05, sag: 0.09, count: 7, seed: 1_319, drift: 0.006 * progress)
    }

    /// The two halves of the scoring rule, one after the other at the same concession stand: the
    /// popcorn while the line is calling the concessions a perk, and then the megaphone somebody
    /// left switched on in exactly the same spot while the line is admitting what the noise does
    /// to a sale.
    ///
    /// The meadow said this in one picture, with a fence round the apple and the skull staked
    /// outside it, because the meadow was teaching what a fence is for at the same time. Nothing
    /// here is teaching anything, so the picture simply changes hands where the caption changes
    /// sentence — the perk lit like a perk, and the drawback with the light off it and the noise
    /// coming out of it instead.
    func drawPopcornAndMegaphones(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns: the first sentence is gone and the second is not up yet, which
        // is the only cover the shot gets to change under.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.44))
        drawSun(in: &shot, at: CGPoint(x: x(0.16), y: y(0.30)), radius: x(0.06), rays: false)
        drawLand(in: &shot, ridge: 0.44, rise: 0.04, waves: 1.9, phase: 1.5, color: colors.farHill)
        drawLanternBigTop(in: &shot, at: 0.24, base: 0.58, height: 0.16, width: 0.26, haze: 0.34)
        drawLand(in: &shot, ridge: 0.54, rise: 0.024, waves: 1.5, phase: 2.5, color: colors.ground)

        drawLanternStall(in: &shot, at: 0.70, base: 0.72, width: 0.34)
        drawLanternSawdust(in: &shot, along: 0.78, count: 6, seed: 1_321)
        drawLanternPools(in: &shot, along: 0.80, spread: 0.26, count: 4, seed: 1_327)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the whole of the opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.26), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.60), y: y(0.79))

        // The perk, stood in a light of its own with more of it spilt round its feet.
        var perk = shot
        perk.opacity = 1 - turn
        let halo = CGPoint(x: spot.x, y: spot.y - x(0.11))
        perk.fill(
            circle(at: halo, radius: x(0.22)),
            with: .radialGradient(
                Gradient(colors: [colors.disc.opacity(0.38), colors.disc.opacity(0)]),
                center: halo,
                startRadius: x(0.02),
                endRadius: x(0.22)
            )
        )
        drawTreat(in: &perk, "🍿", at: spot, width: x(0.22))
        drawTreat(in: &perk, "🍿", at: CGPoint(x: x(0.44), y: y(0.84)), width: x(0.07))
        drawTreat(in: &perk, "🍿", at: CGPoint(x: x(0.80), y: y(0.83)), width: x(0.06))

        // And the drawback in the same spot with the light off it, throwing rings of noise it is
        // not going to stop throwing.
        var drawback = shot
        drawback.opacity = turn
        var blare = Path()
        for ring in 1...3 {
            let reach = x(0.06) * CGFloat(ring) + x(0.03) * CGFloat(turn)
            blare.addArc(
                center: CGPoint(x: spot.x + x(0.04), y: spot.y - x(0.12)),
                radius: reach,
                startAngle: .degrees(-52),
                endAngle: .degrees(52),
                clockwise: false
            )
        }
        drawback.stroke(
            blare,
            with: .color(GamePalette.barn.opacity(0.55)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.008)), lineCap: .round)
        )
        drawTreat(in: &drawback, "📣", at: spot, width: x(0.21))

        drawLanternStrings(in: &shot, at: 0.06, sag: 0.10, count: 6, seed: 1_361, drift: -0.005 * progress)
    }

    /// The pig in the middle of the fair with the wheel turning over its head, a crowd either
    /// side and a lantern string right across the top of the frame: more lively than the cave,
    /// which is true of most things and is not the compliment it sounds like.
    ///
    /// A card, so the middle of the frame belongs to the words. Everything the shot is about is
    /// either up in the wires or down in the sawdust, and the band between them is left to the
    /// sky the fair has stopped needing.
    func drawMoreLivelyThanTheCave(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.30))

        // High and small, so the wheel clears the line rather than standing behind it.
        drawLanternWheel(in: &shot, at: CGPoint(x: x(0.76), y: y(0.17)), radius: x(0.14), haze: 0.18)
        drawLanternBigTop(in: &shot, at: 0.16, base: 0.30, height: 0.16, width: 0.24, haze: 0.22)

        drawLand(in: &shot, ridge: 0.28, rise: 0.03, waves: 1.7, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.68, rise: 0.024, waves: 1.4, phase: 0.5, color: colors.ground)
        drawLanternSawdust(in: &shot, along: 0.80, count: 8, seed: 1_367)
        drawLanternPools(in: &shot, along: 0.84, spread: 0.32, count: 6, seed: 1_373)

        // The crowd close and either side of the pig rather than behind it: a fair is a place
        // you are in the middle of, and this is the shot that says so.
        drawLanternCrowd(in: &shot, along: 0.76, count: 11, seed: 1_381)

        drawTreat(in: &shot, "🍿", at: CGPoint(x: x(0.18), y: y(0.86)), width: x(0.06))
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.46), y: y(0.84)),
            width: x(0.20),
            lean: 4 * sin(progress * 2 * .pi),
            squash: 1 - 0.05 * hop(cycles: 3)
        )

        drawLanternBunting(in: &shot, at: 0.16, sag: 0.07, count: 14, seed: 1_399)
        drawLanternStrings(in: &shot, at: 0.04, sag: 0.11, count: 8, seed: 1_409, drift: 0.008 * progress)
        drawLanternSparks(in: &shot, count: 9, seed: 1_423)
    }

    // MARK: - The Center Ring

    /// Management, arriving. The big top fills the back of the frame, the ring is raked and empty
    /// at the front of it, and the ringmaster walks out to the middle of his own floor and stops
    /// there — which is the last time in this world he moves at all.
    func drawTheManagement(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawLand(in: &shot, ridge: 0.40, rise: 0.04, waves: 1.9, phase: 1.4, color: colors.farHill)
        // Close enough now to be a building rather than a skyline: the tent is the wall of the
        // room this whole film happens in.
        drawLanternBigTop(in: &shot, at: 0.52, base: 0.68, height: 0.36, width: 0.86)
        drawLand(in: &shot, ridge: 0.62, rise: 0.02, waves: 1.3, phase: 0.7, color: colors.ground)

        drawLanternSawdust(in: &shot, along: 0.70, count: 5, seed: 1_427)
        let ring = CGPoint(x: x(0.58), y: y(0.74))
        drawLanternRing(in: &shot, at: ring, width: 0.44)

        // Out of the tent and into the middle, slowing as he arrives. He is a glyph like every
        // other resident in the game, and like the boar he does not stop at the edge of the
        // frame to be admired.
        let entrance = easeOut(min(progress / 0.8, 1))
        drawAnimal(
            in: &shot,
            .ringmaster,
            feet: CGPoint(x: x(0.52) + x(0.06) * CGFloat(entrance), y: ring.y),
            width: x(0.17),
            shadow: 0.8
        )

        drawLanternPools(in: &shot, along: 0.82, spread: 0.24, count: 4, seed: 1_429)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.17), y: y(0.83)), width: x(0.16), lean: -4)

        drawLanternStrings(in: &shot, at: 0.05, sag: 0.08, count: 6, seed: 1_433, drift: 0.006 * progress)
    }

    /// A fence run coming in from the left and stopping dead: the clearance the ringmaster keeps
    /// round his ring, drawn as the one bit of sawdust in the world with nothing on it.
    ///
    /// The run builds across the shot as it plays and pulls up short, which is the whole briefing
    /// in one move — the rule is not about how much fence, it is about where the last post goes.
    /// The clear ground comes up as the fence arrives at it, so the picture says *this far* at the
    /// moment the caption does.
    func drawATightShip(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawLand(in: &shot, ridge: 0.42, rise: 0.04, waves: 1.8, phase: 2.2, color: colors.farHill)
        drawLanternBigTop(in: &shot, at: 0.74, base: 0.60, height: 0.22, width: 0.40, haze: 0.26)
        drawLand(in: &shot, ridge: 0.56, rise: 0.022, waves: 1.4, phase: 0.9, color: colors.ground)
        drawLanternSawdust(in: &shot, along: 0.66, count: 5, seed: 1_439)

        let ring = CGPoint(x: x(0.66), y: y(0.76))
        let built = easeOut(min(progress / 0.7, 1))

        // His personal space: a ring of clear light round the ring itself, brightening as the
        // fence gets near enough for it to matter.
        let space = lanternRingBounds(at: ring, width: 0.40).insetBy(dx: -x(0.07), dy: -x(0.045))
        shot.fill(
            Path(ellipseIn: space),
            with: .radialGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0),
                    GamePalette.cream.opacity(0.06 + 0.16 * built)
                ]),
                center: ring,
                startRadius: space.width * 0.28,
                endRadius: space.width * 0.5
            )
        )
        shot.stroke(
            Path(ellipseIn: space),
            with: .color(GamePalette.cream.opacity(0.16 + 0.34 * built)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.005)), dash: [x(0.02), x(0.018)])
        )

        drawLanternRing(in: &shot, at: ring, width: 0.40)
        drawAnimal(in: &shot, .ringmaster, feet: ring, width: x(0.16), shadow: 0.8)

        // The run, building in from the edge of the frame and stopping a clear post short of the
        // clearance. Nothing about the gap is subtle: it is the rule.
        drawFenceRun(
            in: &shot,
            base: 0.83,
            height: 0.09,
            from: -0.04,
            to: 0.10 + 0.20 * built,
            posts: 5,
            gap: nil
        )

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.26), y: y(0.72)), width: x(0.14), lean: 4)
        drawLanternPools(in: &shot, along: 0.86, spread: 0.22, count: 3, seed: 1_447)
        drawLanternStrings(in: &shot, at: 0.05, sag: 0.09, count: 6, seed: 1_451, drift: -0.006 * progress)
    }

    /// The lease, drawn. The ring lies on the sawdust with the ringmaster in the middle of it and
    /// the pig off to one side, and a pen opens round the whole arrangement with clear ground
    /// between the fence and the ring on every side of it.
    ///
    /// The gap is the point and so it is measured rather than eyeballed: the pen is set from the
    /// ring's own bounds with a margin added, so no screen the game runs on can ever draw a post
    /// touching the boards. Everything sits low, because the caption on a card takes the middle
    /// of the frame at the size of a headline.
    func drawTheRingAndTheFence(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.26))
        drawLanternWheel(in: &shot, at: CGPoint(x: x(0.84), y: y(0.15)), radius: x(0.11), haze: 0.34)
        drawLanternBigTop(in: &shot, at: 0.22, base: 0.30, height: 0.14, width: 0.24, haze: 0.32)
        drawLand(in: &shot, ridge: 0.28, rise: 0.03, waves: 1.6, phase: 1.3, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.34, rise: 0.02, waves: 1.4, phase: 2.4, color: colors.ground)
        // No grass along that edge. The meadow's tufts photographed here as a row of small black
        // bristles standing on the far hill — barbed wire at this distance, and on a fairground
        // floor there is nothing left growing to justify them anyway.
        // The floor of the fair runs the whole way up this shot, and the words sit on the empty
        // middle of it: soft light, nothing in it to read, which is what a card wants underneath.
        drawLanternPools(in: &shot, along: 0.50, spread: 0.30, count: 4, seed: 1_457)
        drawLanternSawdust(in: &shot, along: 0.72, count: 6, seed: 1_459)

        let ring = CGPoint(x: x(0.52), y: y(0.79))
        drawLanternRing(in: &shot, at: ring, width: 0.28)
        drawAnimal(in: &shot, .ringmaster, feet: ring, width: x(0.15), shadow: 0.8)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.18), y: y(0.85)), width: x(0.15))

        // One pen round all three of them, and the clearance held open inside it: the fence is
        // laid out from where the boards actually are, not from where they look like they are.
        let boards = lanternRingBounds(at: ring, width: 0.28)
        let clear = boards.insetBy(dx: -x(0.045), dy: -x(0.025))
        shot.stroke(
            Path(ellipseIn: clear),
            with: .color(GamePalette.cream.opacity(0.22)),
            style: StrokeStyle(lineWidth: max(1, x(0.004)), dash: [x(0.014), x(0.014)])
        )

        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(
            in: &shot,
            round: CGPoint(x: x(0.40), y: y(0.90)),
            width: 0.74,
            height: 0.24,
            drop: 0,
            opacity: 0.9 * drawn
        )

        drawLanternStrings(in: &shot, at: 0.03, sag: 0.07, count: 6, seed: 1_471, drift: 0.005 * progress)
    }

    // MARK: - The carnival held

    /// The pen holding after dark with the whole fair still running round it: the wheel lit and
    /// turning, the ringmaster stood in his own held ring up the ground, popcorn trodden into the
    /// sawdust, and not one light anywhere showing the least sign of going off.
    ///
    /// Every other world's held shot is a picture of quiet. This is a picture of a listing that
    /// delivered on absolutely everything it promised, which turns out to be the problem.
    func drawConstantNightlife(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawSun(in: &shot, at: CGPoint(x: x(0.16), y: y(0.14)), radius: x(0.045), rays: false)
        drawLand(in: &shot, ridge: 0.34, rise: 0.04, waves: 2.0, phase: 1.5, color: colors.farHill)

        drawLanternWheel(in: &shot, at: CGPoint(x: x(0.80), y: y(0.30)), radius: x(0.16), haze: 0.10)
        drawLanternBigTop(in: &shot, at: 0.34, base: 0.52, height: 0.20, width: 0.36, haze: 0.10)
        drawLand(in: &shot, ridge: 0.48, rise: 0.022, waves: 1.4, phase: 0.8, color: colors.ground)

        // Management, held in his own lot at the far end, with his ring inside the fence and
        // nowhere near it.
        let ring = CGPoint(x: x(0.76), y: y(0.60))
        drawPenWash(in: &shot, round: ring, width: 0.32, height: 0.10, drop: 0.032)
        drawLanternRing(in: &shot, at: ring, width: 0.14)
        drawAnimal(in: &shot, .ringmaster, feet: ring, width: x(0.11), shadow: 0.6)
        drawPenFence(in: &shot, round: ring, width: 0.32, height: 0.10, drop: 0.032)

        drawLanternSawdust(in: &shot, along: 0.68, count: 6, seed: 1_481)
        drawLanternPools(in: &shot, along: 0.78, spread: 0.34, count: 7, seed: 1_483)

        // And the pig with the run of the front of the fair, windfall popcorn and all.
        let pig = CGPoint(x: x(0.40), y: y(0.84))
        drawPenWash(in: &shot, round: pig, width: 0.66, height: 0.115, drop: 0)
        drawTreat(in: &shot, "🍿", at: CGPoint(x: x(0.14), y: y(0.82)), width: x(0.05))
        drawTreat(in: &shot, "🍿", at: CGPoint(x: x(0.62), y: y(0.83)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        drawPenFence(in: &shot, round: pig, width: 0.66, height: 0.115, drop: 0)

        // The lanterns thrown back over the top of the held ground. Photographed without this the
        // two pens were flat gold slabs — the brightest, emptiest things in a shot whose whole
        // point is that the lights never go off. Gold with coloured light lying across it still
        // reads as a pen that holds, and starts reading as a floor as well.
        drawLanternPools(in: &shot, along: 0.80, spread: 0.24, count: 5, seed: 1_497)

        drawLanternBunting(in: &shot, at: 0.14, sag: 0.06, count: 14, seed: 1_487)
        drawLanternStrings(in: &shot, at: 0.04, sag: 0.10, count: 8, seed: 1_489, drift: 0.007 * progress)
        drawLanternSparks(in: &shot, count: 10, seed: 1_493)
    }

    /// The last lantern on the string, and the pig stood under it with its back to everything
    /// else: the fair going on brightly away to one side, and out the other a dark line of dunes
    /// with nothing lit on it at all.
    ///
    /// The camera drifts away from the lights rather than towards them, which is the only shot in
    /// the world that moves that way.
    func drawSomewhereMorePeaceful(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.025 * progress)

        drawSky(in: &shot, horizon: y(0.48))

        // The next listing, standing well beyond the last of the fair: drawn first, hazed with
        // the sky, and had the near country laid over its feet, because that is the only way
        // anything ever reads as a long way off.
        drawLanternDune(in: &shot, at: 0.74, base: 0.54, height: 0.11, width: 0.72, haze: 0.28)
        drawLanternDune(in: &shot, at: 0.96, base: 0.55, height: 0.08, width: 0.50, haze: 0.38)
        drawLand(in: &shot, ridge: 0.50, rise: 0.03, waves: 1.7, phase: 1.7, color: colors.farHill)

        // The fair banked into the left of the frame only, so the picture is half lit and half
        // not, and the pig is standing on the line between the two.
        drawLanternWheel(in: &shot, at: CGPoint(x: x(0.09), y: y(0.34)), radius: x(0.13), haze: 0.20)
        drawLanternBigTop(in: &shot, at: 0.30, base: 0.62, height: 0.16, width: 0.28, haze: 0.18)
        drawLand(in: &shot, ridge: 0.60, rise: 0.024, waves: 1.4, phase: 0.9, color: colors.ground)
        drawLanternSawdust(in: &shot, along: 0.70, count: 4, seed: 1_499)
        drawLanternPools(in: &shot, along: 0.76, spread: 0.22, count: 3, seed: 1_511)

        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.82)), width: x(0.17), lean: -3)

        // One string, running off the left edge and ending overhead: the fair stops here, and the
        // last bulb on it is the light the pig is standing in.
        drawLanternStrings(in: &shot, at: 0.06, sag: 0.09, count: 3, seed: 1_523, drift: 0.005 * progress)
        drawLanternSparks(in: &shot, count: 5, seed: 1_531)
        drawLand(in: &shot, ridge: 0.94, rise: 0.014, waves: 1.0, phase: 2.4, color: colors.foreground)
    }

    /// The dunes, with a moon over them and one cactus on them, and the carnival reduced to a
    /// smear of colour on the skyline behind. The pig is small and walking out into it, because a
    /// place where quiet hours enforce themselves is a place with nobody in it to enforce them —
    /// which is a thought the pig has not had yet and the picture is not going to spoil.
    ///
    /// A card, so the sand is kept low and the moon high and the whole middle band is left empty
    /// on purpose. Emptiness is the amenity being advertised.
    func drawQuietHours(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        // Off to the left of where it was: at x(0.68) the moon came up behind the Skip button and
        // was photographed with a bite out of it. Nothing the game draws should have to share a
        // corner with the chrome.
        drawSun(in: &shot, at: CGPoint(x: x(0.40), y: y(0.19)), radius: x(0.07), rays: false)

        // What is left of the carnival: a low glow in one corner of the sky, no shape to it at
        // all. Six worlds have ended by pointing at something spectacular; this one ends by
        // pointing away from it.
        let afterglow = CGPoint(x: x(0.06), y: y(0.34))
        shot.fill(
            circle(at: afterglow, radius: x(0.34)),
            with: .radialGradient(
                Gradient(colors: [colors.canopy.opacity(0.34), colors.canopy.opacity(0)]),
                center: afterglow,
                startRadius: x(0.02),
                endRadius: x(0.34)
            )
        )

        drawLand(in: &shot, ridge: 0.32, rise: 0.03, waves: 1.6, phase: 1.1, color: colors.farHill)
        // Both crests kept under the card's line, and both sets of feet buried by the near sand
        // drawn over them: the whole band across the middle of this shot is meant to be nothing.
        drawLanternDune(in: &shot, at: 0.30, base: 0.80, height: 0.14, width: 0.90, haze: 0.22)
        drawLanternDune(in: &shot, at: 0.84, base: 0.84, height: 0.11, width: 0.70, haze: 0.12)
        drawLand(in: &shot, ridge: 0.87, rise: 0.02, waves: 1.2, phase: 0.6, color: colors.ground)

        drawTreat(in: &shot, "🌵", at: CGPoint(x: x(0.78), y: y(0.88)), width: x(0.13))

        // Small, low and going. The same silhouette every send-off in the game ends on.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.30 + 0.07 * along), y: y(0.86)),
            width: x(0.11),
            lean: 5,
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.5
        )

        drawLand(in: &shot, ridge: 0.94, rise: 0.012, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    // MARK: - What a fair is made of

    /// The four colours every paper lantern, light pool and rim lamp in this world is one of.
    ///
    /// They are the carnival board's own lantern colours, copied rather than re-mixed, because a
    /// player who has spent nine levels watching amber and rose and blue and green slide about on
    /// the sawdust should walk into a film lit by exactly the same bulbs.
    static let lanternGlobes: [Color] = [
        Color(red: 1.00, green: 0.78, blue: 0.36),
        Color(red: 0.98, green: 0.40, blue: 0.48),
        Color(red: 0.46, green: 0.72, blue: 0.96),
        Color(red: 0.62, green: 0.92, blue: 0.66)
    ]

    /// A big top: a striped cone on a low wall, with a pennant off the peak and a scalloped hem
    /// round the eaves.
    ///
    /// The stripes are drawn as wedges running to the peak rather than as bands ruled down the
    /// front, which is the difference between a tent and a deckchair — canvas cut in gores
    /// converges, and the eye knows it even when it could not say so. One half then takes a wash,
    /// so two faces meet along the centre pole: a single flat shape reads as a shape whatever is
    /// painted on it, and a fold reads as canvas over air.
    ///
    /// `haze` lays the sky back over the finished tent for the ones standing further off, and
    /// suppresses the doorway, since a tent far enough away to be hazed has no visible way in.
    /// Its feet are meant to be buried by whatever ground is drawn next.
    func drawLanternBigTop(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        haze: Double = 0
    ) {
        let centre = x(across)
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let eaves = foot - tall * 0.58
        let tip = CGPoint(x: centre, y: foot - tall)
        let cloth = colors.isNight ? colors.canopyShade : GamePalette.cream
        let stripe = colors.isNight ? colors.canopy.opacity(0.55) : colors.canopy

        var tent = Path()
        tent.move(to: CGPoint(x: centre - span / 2, y: foot))
        tent.addLine(to: CGPoint(x: centre - span / 2, y: eaves))
        tent.addQuadCurve(to: tip, control: CGPoint(x: centre - span * 0.30, y: eaves - tall * 0.20))
        tent.addQuadCurve(
            to: CGPoint(x: centre + span / 2, y: eaves),
            control: CGPoint(x: centre + span * 0.30, y: eaves - tall * 0.20)
        )
        tent.addLine(to: CGPoint(x: centre + span / 2, y: foot))
        tent.closeSubpath()
        context.fill(tent, with: .color(cloth))

        var canvas = context
        canvas.clip(to: tent)

        var gores = Path()
        let panels = 9
        for panel in stride(from: 0, to: panels, by: 2) {
            let left = centre - span / 2 + span * CGFloat(panel) / CGFloat(panels)
            let right = left + span / CGFloat(panels)
            gores.move(to: tip)
            gores.addLine(to: CGPoint(x: left, y: foot))
            gores.addLine(to: CGPoint(x: right, y: foot))
            gores.closeSubpath()
        }
        canvas.fill(gores, with: .color(stripe))

        // The shaded face, and the pole they meet along.
        canvas.fill(
            Path(CGRect(x: centre, y: foot - tall * 1.1, width: span, height: tall * 1.2)),
            with: .color(colors.canopyShade.opacity(0.30))
        )

        // The hem: a row of half-rounds along the eaves, which is the one piece of a fairground
        // tent that nothing else in the game has and the thing that names it at any size.
        var hem = Path()
        let scallops = max(4, Int(width * 22))
        let lap = span / CGFloat(scallops)
        for scallop in 0..<scallops {
            let left = centre - span / 2 + lap * CGFloat(scallop)
            hem.addEllipse(in: CGRect(x: left, y: eaves - lap * 0.3, width: lap, height: lap * 0.9))
        }
        canvas.fill(hem, with: .color(cloth))
        canvas.fill(
            Path(CGRect(x: centre - span / 2, y: eaves - lap, width: span, height: lap * 0.75)),
            with: .color(colors.canopyShade.opacity(0.22))
        )

        // The way in, with the light of the place coming out of it.
        if haze < 0.2 {
            let doorTall = (foot - eaves) * 0.82
            let doorWide = span * 0.17
            let door = CGRect(
                x: centre - doorWide / 2, y: foot - doorTall,
                width: doorWide, height: doorTall
            )
            context.fill(
                Path(roundedRect: door, cornerSize: CGSize(width: doorWide / 2, height: doorWide / 2)),
                with: .linearGradient(
                    Gradient(colors: [colors.disc.opacity(0.85), colors.discHalo.opacity(0.45)]),
                    startPoint: CGPoint(x: 0, y: door.minY),
                    endPoint: CGPoint(x: 0, y: door.maxY)
                )
            )
        }

        // The pennant, which is how anybody at the back of a field knows whose tent it is.
        var flag = Path()
        flag.move(to: CGPoint(x: tip.x, y: tip.y - tall * 0.14))
        flag.addLine(to: CGPoint(x: tip.x + span * 0.10, y: tip.y - tall * 0.09))
        flag.addLine(to: CGPoint(x: tip.x, y: tip.y - tall * 0.04))
        flag.closeSubpath()
        context.fill(flag, with: .color(colors.canopy))
        var mast = Path()
        mast.move(to: CGPoint(x: tip.x, y: tip.y + tall * 0.02))
        mast.addLine(to: CGPoint(x: tip.x, y: tip.y - tall * 0.16))
        context.stroke(
            mast,
            with: .color(GamePalette.post.opacity(0.8)),
            style: StrokeStyle(lineWidth: max(1, span * 0.008), lineCap: .round)
        )

        guard haze > 0 else { return }
        context.fill(tent, with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// The big wheel: a rim on twelve spokes with a car hanging off every one of them, standing
    /// on a pair of legs, turning a fraction of a revolution across the shot.
    ///
    /// The cars hang plumb whatever the wheel is doing, which is the only part of this that has
    /// to be right — a wheel drawn with its cars rotating with the rim reads as a cog. It is
    /// stroked as one path so the sky can be stroked back over the same lines for the ones that
    /// are far off, and the rim lamps are the world's four lantern colours going round.
    func drawLanternWheel(
        in context: inout GraphicsContext,
        at hub: CGPoint,
        radius: CGFloat,
        haze: Double = 0
    ) {
        let spokes = 12
        let turn = progress * 0.4
        let ground = hub.y + radius * 1.32
        let steel = GamePalette.post

        var frame = Path()
        frame.addEllipse(in: CGRect(
            x: hub.x - radius, y: hub.y - radius,
            width: radius * 2, height: radius * 2
        ))
        frame.addEllipse(in: CGRect(
            x: hub.x - radius * 0.12, y: hub.y - radius * 0.12,
            width: radius * 0.24, height: radius * 0.24
        ))
        for leg in [-1.0, 1.0] {
            frame.move(to: CGPoint(x: hub.x, y: hub.y))
            frame.addLine(to: CGPoint(x: hub.x + radius * 0.5 * CGFloat(leg), y: ground))
        }

        var cars = Path()
        var lamps = Path()
        var seats: [(CGPoint, Int)] = []
        for spoke in 0..<spokes {
            let angle = Double(spoke) * 2 * .pi / Double(spokes) + turn * 2 * .pi
            let rim = CGPoint(
                x: hub.x + radius * CGFloat(cos(angle)),
                y: hub.y + radius * CGFloat(sin(angle))
            )
            frame.move(to: hub)
            frame.addLine(to: rim)
            lamps.addEllipse(in: CGRect(
                x: rim.x - radius * 0.035, y: rim.y - radius * 0.035,
                width: radius * 0.07, height: radius * 0.07
            ))
            seats.append((rim, spoke))
            cars.addRoundedRect(
                in: CGRect(
                    x: rim.x - radius * 0.075, y: rim.y + radius * 0.05,
                    width: radius * 0.15, height: radius * 0.11
                ),
                cornerSize: CGSize(width: radius * 0.03, height: radius * 0.03)
            )
        }

        context.stroke(
            frame,
            with: .color(steel.opacity(colors.isNight ? 0.85 : 0.7)),
            style: StrokeStyle(lineWidth: max(1, radius * 0.035), lineCap: .round)
        )
        context.fill(cars, with: .color(colors.canopyShade))

        for (rim, spoke) in seats {
            let bulb = Self.lanternGlobes[spoke % Self.lanternGlobes.count]
            context.fill(
                circle(at: rim, radius: radius * 0.16),
                with: .radialGradient(
                    Gradient(colors: [
                        bulb.opacity((colors.isNight ? 0.30 : 0.18) * (1 - haze)),
                        bulb.opacity(0)
                    ]),
                    center: rim,
                    startRadius: 0,
                    endRadius: radius * 0.16
                )
            )
        }
        context.fill(lamps, with: .color(GamePalette.cream.opacity((colors.isNight ? 0.95 : 0.8) * (1 - haze))))

        guard haze > 0 else { return }
        // Distance, laid back over the same lines rather than painted into them.
        context.stroke(
            frame,
            with: .color(colors.skyHorizon.opacity(haze)),
            style: StrokeStyle(lineWidth: max(1, radius * 0.035), lineCap: .round)
        )
        context.fill(cars, with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// Where something hung on a slack line ends up, `along` of the way across it.
    ///
    /// The line is a quadratic curve and this is the point on it, which matters because things
    /// hung on a sagging wire bunch towards the middle: spacing lanterns evenly across the width
    /// instead puts them evenly across a shop sign, and the sag stops being a sag.
    func lanternHang(from start: CGPoint, to end: CGPoint, dip: CGPoint, at along: Double) -> CGPoint {
        let travelled = CGFloat(along)
        let left = 1 - travelled
        return CGPoint(
            x: left * left * start.x + 2 * left * travelled * dip.x + travelled * travelled * end.x,
            y: left * left * start.y + 2 * left * travelled * dip.y + travelled * travelled * end.y
        )
    }

    /// A string of paper lanterns hung across the top of the frame, which is this world's canopy:
    /// the thing that hangs into every shot and the only reason anything below it can be seen.
    ///
    /// Two runs, the far one shallower and dimmer, both carried well outside the frame so no
    /// camera move ever finds the end of a wire. The bulbs are spaced along the actual curve
    /// rather than along the width, because lanterns hung on a slack line bunch towards the
    /// bottom of it, and a row of them ruled at even x reads as a shop sign.
    func drawLanternStrings(
        in context: inout GraphicsContext,
        at height: Double,
        sag: Double,
        count: Int,
        seed: UInt64,
        drift: Double = 0
    ) {
        var scatter = Scatter(seed: seed)

        for run in [1.0, 0.0] {
            let near = run == 0
            let start = CGPoint(x: -x(0.15), y: y(height) - y(0.05) * CGFloat(run))
            let end = CGPoint(x: x(1.15), y: y(height + 0.02) - y(0.06) * CGFloat(run))
            let dip = CGPoint(
                x: x(0.5 + drift),
                y: y(height + sag * (near ? 1 : 0.7)) * 2 - (start.y + end.y) / 2
            )

            var wire = Path()
            wire.move(to: start)
            wire.addQuadCurve(to: end, control: dip)
            context.stroke(
                wire,
                with: .color(GamePalette.post.opacity(near ? 0.7 : 0.4)),
                style: StrokeStyle(lineWidth: max(1, x(0.004)), lineCap: .round)
            )

            let bulbs = near ? count : max(2, count - 2)
            for bulb in 0..<bulbs {
                let hang = lanternHang(
                    from: start, to: end, dip: dip,
                    at: (Double(bulb) + 0.5) / Double(bulbs)
                )
                let colour = Self.lanternGlobes[(bulb &+ Int(run) * 2) % Self.lanternGlobes.count]
                let wide = x(near ? 0.036 : 0.026) * CGFloat(0.85 + scatter.next() * 0.35)
                let sway = moves ? sin(progress * 2 * .pi + Double(bulb)) * 0.12 : 0
                let centre = CGPoint(x: hang.x + wide * CGFloat(sway), y: hang.y + wide * 0.9)

                var stem = Path()
                stem.move(to: hang)
                stem.addLine(to: CGPoint(x: centre.x, y: centre.y - wide * 0.4))
                context.stroke(
                    stem,
                    with: .color(GamePalette.post.opacity(0.6)),
                    style: StrokeStyle(lineWidth: max(0.8, x(0.0025)), lineCap: .round)
                )

                let glow = colors.isNight ? 0.46 : 0.30
                context.fill(
                    circle(at: centre, radius: wide * 2.4),
                    with: .radialGradient(
                        Gradient(colors: [colour.opacity(glow), colour.opacity(0)]),
                        center: centre,
                        startRadius: wide * 0.2,
                        endRadius: wide * 2.4
                    )
                )
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: centre.x - wide / 2, y: centre.y - wide * 0.45,
                        width: wide, height: wide * 0.9
                    )),
                    with: .color(colour.opacity(colors.isNight ? 0.95 : 0.85))
                )
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: centre.x - wide * 0.22, y: centre.y - wide * 0.3,
                        width: wide * 0.44, height: wide * 0.6
                    )),
                    with: .color(GamePalette.cream.opacity(colors.isNight ? 0.8 : 0.55))
                )
            }
        }
    }

    /// Bunting: the same slack line with paper triangles on it instead of lights. It carries no
    /// light of its own and is there for one reason — a fair is a place where somebody has gone
    /// to the trouble of hanging things up, and two kinds of hung thing say that better than
    /// twice as much of one.
    func drawLanternBunting(
        in context: inout GraphicsContext,
        at height: Double,
        sag: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let start = CGPoint(x: -x(0.12), y: y(height))
        let end = CGPoint(x: x(1.12), y: y(height - 0.03))
        let dip = CGPoint(x: x(0.46), y: y(height + sag) * 2 - (start.y + end.y) / 2)

        var line = Path()
        line.move(to: start)
        line.addQuadCurve(to: end, control: dip)
        context.stroke(
            line,
            with: .color(GamePalette.post.opacity(0.45)),
            style: StrokeStyle(lineWidth: max(0.8, x(0.003)), lineCap: .round)
        )

        for flag in 0..<count {
            let peg = lanternHang(
                from: start, to: end, dip: dip,
                at: (Double(flag) + 0.5) / Double(count)
            )
            let wide = x(0.030)
            let tall = wide * CGFloat(1.0 + scatter.next() * 0.4)
            // A little flutter, and only ever from the wire: a flag pivots where it is pinned.
            let flutter = moves ? sin(progress * 2 * .pi * 1.3 + Double(flag) * 0.7) * 0.16 : 0

            var cloth = Path()
            cloth.move(to: CGPoint(x: peg.x - wide / 2, y: peg.y))
            cloth.addLine(to: CGPoint(x: peg.x + wide / 2, y: peg.y))
            cloth.addLine(to: CGPoint(x: peg.x + wide * CGFloat(flutter), y: peg.y + tall))
            cloth.closeSubpath()
            context.fill(
                cloth,
                with: .color(
                    flag % 2 == 0
                        ? colors.canopy.opacity(colors.isNight ? 0.75 : 0.9)
                        : GamePalette.cream.opacity(colors.isNight ? 0.55 : 0.85)
                )
            )
        }
    }

    /// The floor of the place: trodden ground with sawdust thrown down where the standing is.
    ///
    /// It used to peg guy ropes across this as well, on the theory that a rope running off the
    /// top of the frame says the tent is bigger than the shot. It does not. Photographed, a taut
    /// hairline that starts at a peg and stops in mid-air reads as a scratch on the lens — nine
    /// times out of nine, and in one shot it went straight across the pig's face. A rope only
    /// works when both of its ends are somewhere, and in a shot composed round a tent that is off
    /// to one side there is nowhere for the far end to be. So the floor is patches now, and the
    /// carnival says it is temporary with its lights instead.
    func drawLanternSawdust(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let dust = Color(red: 0.86, green: 0.74, blue: 0.52)

        for _ in 0..<count {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.05...1.05)),
                y: y(baseline + scatter.next(in: -0.05...0.12))
            )
            let spread = x(scatter.next(in: 0.10...0.26))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - spread / 2, y: centre.y - spread * 0.16,
                    width: spread, height: spread * 0.32
                )),
                with: .color(dust.opacity(colors.isNight ? 0.12 : 0.26))
            )
        }
    }

    /// The pools of coloured light the strings throw down, laid on the ground and left to
    /// overlap and disagree with one another.
    ///
    /// This is the world, really. Every other place in the game has one light and therefore one
    /// colour of shadow; the carnival has four lights hung at random and a floor that cannot make
    /// its mind up, and painting that is what stops these shots reading as the meadow after dark
    /// with tents added.
    func drawLanternPools(
        in context: inout GraphicsContext,
        along baseline: Double,
        spread: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for pool in 0..<count {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.08...1.08)),
                y: y(baseline + scatter.next(in: -0.10...0.10))
            )
            let reach = x(spread) * CGFloat(0.6 + scatter.next() * 0.8)
            let colour = Self.lanternGlobes[pool % Self.lanternGlobes.count]

            // Flattened, because a pool of light on the ground is seen at an angle and a round
            // one reads as a spotlight aimed at the camera.
            var wash = context
            wash.translateBy(x: centre.x, y: centre.y)
            wash.scaleBy(x: 1, y: 0.42)
            wash.fill(
                circle(at: .zero, radius: reach),
                with: .radialGradient(
                    Gradient(colors: [
                        colour.opacity(colors.isNight ? 0.26 : 0.16),
                        colour.opacity(0)
                    ]),
                    center: .zero,
                    startRadius: 0,
                    endRadius: reach
                )
            )
        }
    }

    /// The ground a ring takes up, which the fence has to stay off.
    ///
    /// It exists so the briefing's two shots can measure the clearance instead of guessing at it.
    /// The rule this world is built on is a gap, and a gap that is only correct on the phone it
    /// was drawn on is not a rule.
    func lanternRingBounds(at centre: CGPoint, width: Double) -> CGRect {
        CGRect(
            x: centre.x - x(width) / 2,
            y: centre.y - x(width) * 0.19,
            width: x(width),
            height: x(width) * 0.38
        )
    }

    /// The ring itself: raked sawdust inside a low kerb of boards, painted in alternate lengths
    /// the way every ring since the first one has been.
    ///
    /// Drawn as an ellipse rather than a circle because it is on the floor and being looked at
    /// from standing height, and drawn light-inside-dark-edge because that is what makes the eye
    /// read a flat shape as a thing lying down rather than a thing standing up.
    func drawLanternRing(in context: inout GraphicsContext, at centre: CGPoint, width: Double) {
        let bounds = lanternRingBounds(at: centre, width: width)
        let kerb = max(1.5, bounds.width * 0.045)

        context.fill(
            Path(ellipseIn: bounds),
            with: .radialGradient(
                Gradient(colors: [
                    Color(red: 0.86, green: 0.74, blue: 0.52).opacity(colors.isNight ? 0.30 : 0.52),
                    Color(red: 0.86, green: 0.74, blue: 0.52).opacity(colors.isNight ? 0.14 : 0.30)
                ]),
                center: CGPoint(x: bounds.midX, y: bounds.midY),
                startRadius: 0,
                endRadius: bounds.width * 0.5
            )
        )

        // The boards, in lengths: a solid ring reads as a stain on the floor, and the paint is
        // the thing that says somebody maintains this.
        let lengths = 14
        for length in 0..<lengths {
            let from = Double(length) / Double(lengths) * 360
            var arc = Path()
            arc.addArc(
                center: CGPoint(x: bounds.midX, y: bounds.midY),
                radius: bounds.width / 2,
                startAngle: .degrees(from),
                endAngle: .degrees(from + 360 / Double(lengths)),
                clockwise: false,
                transform: CGAffineTransform(translationX: bounds.midX, y: bounds.midY)
                    .scaledBy(x: 1, y: bounds.height / bounds.width)
                    .translatedBy(x: -bounds.midX, y: -bounds.midY)
            )
            context.stroke(
                arc,
                with: .color(
                    length % 2 == 0
                        ? GamePalette.barn.opacity(colors.isNight ? 0.7 : 0.9)
                        : GamePalette.cream.opacity(colors.isNight ? 0.6 : 0.9)
                ),
                style: StrokeStyle(lineWidth: kerb, lineCap: .butt)
            )
        }
    }

    /// A crowd, as a band of heads and shoulders across the ground with the lights behind them.
    ///
    /// Nobody in it has a face and nobody is meant to. What the shot needs is the fact of other
    /// people, at the size other people are when you are trying to see past them.
    ///
    /// Two things were learnt photographing it. The lit edge has to be **clipped into** the body:
    /// stroked along the silhouette it came out as a bright coloured stick standing beside
    /// somebody rather than as light on them, and since the figures overlap, each stick landed on
    /// its neighbour and read as a separate object — a row of people carrying poles. Filled inside
    /// a clip it can only ever be light on a shoulder. And the crowd is drawn in two ranks at two
    /// sizes: one rank at one size across the whole width is a fence of identical dark slabs, and
    /// a fair is a place with depth in it.
    func drawLanternCrowd(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for body in 0..<count {
            // Every third one stands further back: smaller, higher up the ground and dimmer.
            let far = body % 3 == 0
            let across = x((Double(body) + scatter.next(in: 0.1...0.9)) / Double(count))
            let foot = y(baseline + (far ? -0.045 : 0.01) + scatter.next(in: -0.015...0.05))
            let tall = y(far ? 0.040 : 0.058) * CGFloat(0.82 + scatter.next() * 0.42)
            let wide = tall * 0.52
            let bob = moves ? sin(progress * 2 * .pi + Double(body)) * 0.06 : 0
            let lift = tall * CGFloat(bob)

            var figure = Path()
            figure.addEllipse(in: CGRect(
                x: across - wide * 0.28, y: foot - tall - lift,
                width: wide * 0.56, height: wide * 0.62
            ))
            figure.addRoundedRect(
                in: CGRect(
                    x: across - wide / 2, y: foot - tall * 0.72 - lift,
                    width: wide, height: tall * 0.72 + lift
                ),
                cornerSize: CGSize(width: wide * 0.34, height: wide * 0.34)
            )
            context.fill(
                figure,
                with: .color(colors.foreground.opacity(far ? 0.62 : 0.92))
            )

            // The light on them, on the same side for everybody, because there is one string of
            // lanterns over there and a crowd lit from all sides is a crowd cut out of paper.
            var lit = context
            lit.clip(to: figure)
            lit.fill(
                Path(CGRect(
                    x: across - wide * 0.6, y: foot - tall * 1.2 - lift,
                    width: wide * 0.7, height: tall * 1.4
                )),
                with: .linearGradient(
                    Gradient(colors: [
                        Self.lanternGlobes[body % Self.lanternGlobes.count]
                            .opacity(colors.isNight ? 0.42 : 0.30),
                        Self.lanternGlobes[body % Self.lanternGlobes.count].opacity(0)
                    ]),
                    startPoint: CGPoint(x: across - wide * 0.5, y: 0),
                    endPoint: CGPoint(x: across - wide * 0.1, y: 0)
                )
            )
        }
    }

    /// The concession stand: a counter with a striped awning over it, a lamp under the awning and
    /// a blank board over the top of that.
    ///
    /// The board is left blank on purpose. Lettering it would mean choosing a word, and the shot
    /// it stands in is already carrying two sentences that disagree with each other; a stall with
    /// nothing written on it reads as *a stall* and gets out of the caption's way.
    func drawLanternStall(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        width: Double
    ) {
        let centre = x(across)
        let foot = y(base)
        let span = x(width)
        let roof = foot - span * 0.58
        let counter = CGRect(x: centre - span / 2, y: foot - span * 0.26, width: span, height: span * 0.26)

        // The shadow it stands in, laid down before it. Photographed without one the counter's
        // bottom edge was a ruled line across open ground and the whole stall read as a sticker
        // somebody had pressed onto the picture.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre - span * 0.62, y: foot - span * 0.07,
                width: span * 1.24, height: span * 0.16
            )),
            with: .color(.black.opacity(colors.isNight ? 0.26 : 0.18))
        )

        for post in [-1.0, 1.0] {
            context.fill(
                Path(roundedRect: CGRect(
                    x: centre + span * 0.46 * CGFloat(post) - span * 0.018,
                    y: roof,
                    width: span * 0.036,
                    height: foot - roof
                ), cornerRadius: span * 0.012),
                with: .color(GamePalette.post)
            )
        }

        // The light inside, which is what a stall is for after dark and what makes this one the
        // brightest thing at the bottom of its shot.
        context.fill(
            Path(CGRect(x: counter.minX, y: roof, width: span, height: counter.minY - roof)),
            with: .linearGradient(
                Gradient(colors: [colors.disc.opacity(0.55), colors.disc.opacity(0.08)]),
                startPoint: CGPoint(x: 0, y: roof),
                endPoint: CGPoint(x: 0, y: counter.minY)
            )
        )

        context.fill(
            Path(roundedRect: counter, cornerRadius: span * 0.02),
            with: .color(GamePalette.signboard.opacity(colors.isNight ? 0.55 : 0.95))
        )

        // And the sawdust drifted up against the front of it, over the join, so the counter ends
        // in trodden ground rather than in a straight line.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre - span * 0.56, y: foot - span * 0.055,
                width: span * 1.12, height: span * 0.12
            )),
            with: .color(
                Color(red: 0.86, green: 0.74, blue: 0.52)
                    .opacity(colors.isNight ? 0.16 : 0.34)
            )
        )

        // The board over the hatch, left blank: the shot it stands in is already carrying two
        // sentences that disagree with each other.
        context.fill(
            Path(roundedRect: CGRect(
                x: centre - span * 0.30, y: roof + span * 0.10,
                width: span * 0.60, height: span * 0.11
            ), cornerRadius: span * 0.02),
            with: .color(GamePalette.signboard.opacity(colors.isNight ? 0.7 : 0.95))
        )

        // The awning: the tent's stripes again, at a fifth the size, so the two read as belonging
        // to the same fair.
        let bays = 7
        let bay = span * 1.06 / CGFloat(bays)
        for slice in 0..<bays {
            let left = centre - span * 0.53 + bay * CGFloat(slice)
            var cloth = Path()
            cloth.addRect(CGRect(x: left, y: roof - span * 0.05, width: bay, height: span * 0.05))
            cloth.addEllipse(in: CGRect(
                x: left, y: roof - bay * 0.42,
                width: bay, height: bay * 0.84
            ))
            context.fill(
                cloth,
                with: .color(
                    slice % 2 == 0
                        ? colors.canopy.opacity(colors.isNight ? 0.8 : 0.95)
                        : GamePalette.cream.opacity(colors.isNight ? 0.7 : 0.95)
                )
            )
        }
    }

    /// Motes of light coming up off the lamps, drifting sideways as they go.
    ///
    /// The carnival's answer to the thicket's fireflies and the meadow's birds: after dark a shot
    /// with nothing moving in it is a painting of a place rather than the place, and the only
    /// thing loose in the air over a fairground is what the lights are throwing off.
    func drawLanternSparks(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for spark in 0..<count {
            let home = CGPoint(x: x(scatter.next(in: 0.04...0.96)), y: y(scatter.next(in: 0.30...0.80)))
            let phase = scatter.next()
            let rise = (phase + progress).truncatingRemainder(dividingBy: 1)
            let drift = moves ? sin(progress * 2 * .pi + phase * 6) : 0
            let mote = CGPoint(
                x: home.x + x(0.03) * CGFloat(drift),
                y: home.y - y(0.10) * CGFloat(rise)
            )
            // Brightest halfway up and gone by the top, so nothing ever pops out of existence at
            // the end of its run.
            let life = sin(rise * .pi)
            let colour = Self.lanternGlobes[spark % Self.lanternGlobes.count]

            context.fill(
                circle(at: mote, radius: x(0.012)),
                with: .radialGradient(
                    Gradient(colors: [colour.opacity(0.5 * life), colour.opacity(0)]),
                    center: mote,
                    startRadius: 0,
                    endRadius: x(0.012)
                )
            )
            context.fill(
                circle(at: mote, radius: x(0.0025)),
                with: .color(GamePalette.cream.opacity(0.8 * life))
            )
        }
    }

    /// A dune, for the two shots that look at the next listing.
    ///
    /// It is the thicket's mountain rebuilt out of curves: two faces meeting along a crest that
    /// runs off to one side, the long windward slope lit and the short slip face in shade, so a
    /// shape with no hard edges anywhere on it still reads as solid. Kept low and wide, because
    /// the whole selling point of the place is that there is nothing tall on it.
    func drawLanternDune(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        haze: Double = 0
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        let crest = CGPoint(x: centre + span * 0.12, y: foot - tall)
        // The two faces are held further apart at night than a daylight dune would need. A wash of
        // sky over the finished shape closes the gap between any two values under it, and these
        // are always drawn under one: photographed at the old values both faces came out the same
        // mauve and each dune read as a paper triangle laid on the dark.
        let sand = colors.isNight
            ? Color(red: 0.40, green: 0.27, blue: 0.31)
            : Color(red: 0.86, green: 0.71, blue: 0.52)
        let slip = colors.isNight
            ? Color(red: 0.16, green: 0.09, blue: 0.15)
            : Color(red: 0.66, green: 0.50, blue: 0.40)

        var lee = Path()
        lee.move(to: crest)
        lee.addQuadCurve(
            to: CGPoint(x: centre + span / 2, y: foot),
            control: CGPoint(x: crest.x + span * 0.10, y: foot - tall * 0.25)
        )
        lee.addLine(to: CGPoint(x: centre + span / 2, y: foot + tall))
        lee.addLine(to: CGPoint(x: crest.x, y: foot + tall))
        lee.closeSubpath()
        context.fill(lee, with: .color(slip))

        var wind = Path()
        wind.move(to: crest)
        wind.addCurve(
            to: CGPoint(x: centre - span / 2, y: foot),
            control1: CGPoint(x: crest.x - span * 0.22, y: foot - tall * 0.92),
            control2: CGPoint(x: centre - span * 0.30, y: foot - tall * 0.18)
        )
        wind.addLine(to: CGPoint(x: centre - span / 2, y: foot + tall))
        wind.addLine(to: CGPoint(x: crest.x, y: foot + tall))
        wind.closeSubpath()
        context.fill(wind, with: .color(sand))

        if haze > 0 {
            var whole = Path()
            whole.addPath(lee)
            whole.addPath(wind)
            context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
        }

        // The crest, lit, drawn last so it survives the haze: the one line that says the two
        // faces are two faces. Without it a dune under any wash at all is a shape, and the eye
        // reads a shape with no edge in it as paper.
        var ridge = Path()
        ridge.move(to: CGPoint(x: centre + span * 0.30, y: foot - tall * 0.42))
        ridge.addQuadCurve(
            to: crest,
            control: CGPoint(x: crest.x + span * 0.08, y: foot - tall * 0.88)
        )
        ridge.addCurve(
            to: CGPoint(x: centre - span * 0.34, y: foot - tall * 0.22),
            control1: CGPoint(x: crest.x - span * 0.16, y: foot - tall * 0.94),
            control2: CGPoint(x: centre - span * 0.22, y: foot - tall * 0.42)
        )
        context.stroke(
            ridge,
            with: .color(colors.disc.opacity((colors.isNight ? 0.30 : 0.42) * (1 - haze * 0.5))),
            style: StrokeStyle(lineWidth: max(1, y(0.0022)), lineCap: .round)
        )
    }
}
