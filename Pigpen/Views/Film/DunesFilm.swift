import Foundation
import SwiftUI
import UIKit

// MARK: - Sunbaked Dunes, painted

/// The dunes' nine shots, and the dozen brushes a world with nothing in it turns out to need.
///
/// Every other world hands the camera something to point at. The meadow has hedges and a barn,
/// the thicket has trunks in the way of the view, the mountain has the mountain. A desert has
/// sand, one small white sun, and — if the shot is lucky — a cactus. So these compositions are
/// built out of the two things that are actually here in quantity: the shape the wind has left in
/// the ground, and the light coming down on it.
///
/// The light is the world. There is one hot sun up there and nothing in the air to soften it, so
/// the sand is the brightest thing on the screen and every shadow is filled with the only other
/// light there is, which is the sky — the shade in these shots is blue, and it is the blue that
/// says *noon* rather than the sun does. Emberpeak reads hot by being orange; the dunes read hot
/// by being pale, by the horizon refusing to hold still, and by a white bloom over the whole
/// frame that a photograph taken out here would have whether the photographer wanted it or not.
///
/// Three rules hold the lot together. A dune is drawn as two faces meeting on a crest — a long
/// gentle back the wind climbs and a short steep face it drops everything down — because one
/// smooth hump with a wash over half of it is a paper cut-out and no amount of colour fixes it.
/// A rank of dunes gets a band of ground laid over its feet afterwards, the same way the thicket
/// buries the feet of a rank of trees. And the caption zone is kept dark: cream lettering over
/// sand at noon is the one legibility problem this world has that no other world has, so where a
/// line has to be read, the long blue shade of a dune standing out of shot is thrown across it.
extension Film {
    /// The dunes' two daylight films are lit by more sun than anybody asked for, and the send-off
    /// falls into the coldest night in the game — nothing over the sand holds the heat in, so the
    /// same ground that was gold at noon is a blue-grey with no warmth left in it at all. The
    /// next listing is always the darker one, and this time the dark is the point.
    static func dunesLight(_ shot: CutScene.Picture.Dunes) -> GamePalette.Pasture {
        switch shot {
        case .dunesHeld, .waterAttached, .theSea: .duneDusk
        default: .duneDay
        }
    }

    func drawDunes(_ shot: CutScene.Picture.Dunes, in context: inout GraphicsContext) {
        switch shot {
        case .theSandSea: drawDuneSandSea(in: &context)
        case .melonsAndSnakes: drawDuneMelonsAndSnakes(in: &context)
        case .shadeSoldSeparately: drawDuneShadeSoldSeparately(in: &context)
        case .theNearestNeighbor: drawDuneNearestNeighbor(in: &context)
        case .aLittleDistance: drawDuneLittleDistance(in: &context)
        case .noSharedFence: drawDuneNoSharedFence(in: &context)
        case .dunesHeld: drawDunesHeld(in: &context)
        case .waterAttached: drawDuneWaterAttached(in: &context)
        case .theSea: drawDuneSeaBeyond(in: &context)
        }
    }

    // MARK: - The dunes' opening

    /// The property, seen from the last rise on the way in: crescent dunes marching off to a
    /// horizon that will not hold still, the sun small and white almost overhead, and the pig
    /// standing on a near crest with the whole of it in front of him.
    ///
    /// Wide, empty and pushed into slowly, because that is what the caption is doing — a line
    /// that goes warm, secluded, extremely low-maintenance is a line being read out while
    /// somebody sweeps an arm across an emptiness, and the shot may as well sweep with it.
    private func drawDuneSandSea(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.03 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        // Small, white and high. A big yellow sun low in the frame is a nice evening; this one
        // is directly over the lot and is the reason nothing is standing under it.
        let sun = CGPoint(x: x(0.54), y: y(0.20))
        drawSun(in: &shot, at: sun, radius: x(0.038), rays: true)

        drawLand(in: &shot, ridge: 0.52, rise: 0.014, waves: 1.6, phase: 1.1, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.565, height: 0.055, from: -0.15, to: 1.15,
            count: 6, seed: 811, color: colors.farHill, haze: 0.30
        )
        drawLand(in: &shot, ridge: 0.55, rise: 0.012, waves: 1.3, phase: 0.4, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.545)

        // Drawn in the near sand's own colour rather than the flat's. Painted `ground` it was the
        // same colour as the band it stands on, so the body of the dune vanished and only its
        // shaded face was left — a floating pane of grey with nothing holding it up.
        drawDuneField(
            in: &shot, base: 0.70, height: 0.11, from: -0.2, to: 1.2,
            count: 3, seed: 823, color: colors.foreground, haze: 0.0
        )
        drawLand(in: &shot, ridge: 0.675, rise: 0.018, waves: 1.2, phase: 2.2, color: colors.foreground)

        // The one thing growing on the whole property, and it is standing at the edge of the
        // frame rather than in it, which is roughly how much of it there is.
        drawDuneCactus(in: &shot, at: CGPoint(x: x(0.88), y: y(0.72)), height: 0.055)

        // Up on the crest and small against the lot, the way the thicket puts the pig small at
        // the mouth of the woods: the property is the size of the picture and the buyer is not.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.42), y: y(0.76)),
            width: x(0.15),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        // The combing runs from the middle distance to the bottom of the frame rather than
        // only across the near band. Left bare, the sand between the two ranks photographed as
        // a slab of flat colour — this world is meant to be empty, not blank.
        drawDuneRipples(in: &shot, from: 0.56, to: 0.99, count: 20, seed: 827)
        drawDuneBlownSand(in: &shot, count: 12, seed: 829)
        drawDuneGlare(in: &shot, from: sun, strength: 0.22)
    }

    /// The two halves of the scoring rule, one after the other on the same patch of sand: the
    /// split melon while the line is calling water access a premium, and then the snake in the
    /// same spot while the line is admitting what it does to buyer confidence.
    ///
    /// Built exactly as the thicket's changeover is, and for the same reason — a player eight
    /// worlds in does not need a fence drawn round the lesson. What is new is what the desert
    /// does to the two glyphs. The melon gets a patch of damp under it, because out here the
    /// windfall is not food so much as water, and the snake gets its own track coming in across
    /// the sand, because a snake in a desert is a thing that was somewhere else a moment ago.
    private func drawDuneMelonsAndSnakes(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.04 * progress)

        // Where the line turns from the premium to the problem: the first sentence has faded out
        // and the second is coming up, so the sand may change hands under cover of it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.46))
        let sun = CGPoint(x: x(0.78), y: y(0.18))
        drawSun(in: &shot, at: sun, radius: x(0.035), rays: false)

        drawLand(in: &shot, ridge: 0.46, rise: 0.014, waves: 1.7, phase: 1.3, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.51, height: 0.05, from: -0.15, to: 1.15,
            count: 6, seed: 839, color: colors.farHill, haze: 0.32
        )
        drawLand(in: &shot, ridge: 0.50, rise: 0.012, waves: 1.4, phase: 2.5, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.495)
        drawLand(in: &shot, ridge: 0.66, rise: 0.022, waves: 1.2, phase: 0.9, color: colors.foreground)
        // All the way up to the far band. This shot has the emptiest middle of the nine and it
        // photographed as a bare slab of gold with nothing happening in it at all.
        drawDuneRipples(in: &shot, from: 0.50, to: 0.99, count: 20, seed: 853)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.27), y: y(0.76)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.64), y: y(0.74))

        // The premium, stood in its own light with the sand darkened under it. Damp ground is
        // the only luxury this listing has and it is the size of a dinner plate.
        var premium = shot
        premium.opacity = 1 - turn
        premium.fill(
            Path(ellipseIn: CGRect(
                x: spot.x - x(0.13), y: spot.y - x(0.030),
                width: x(0.26), height: x(0.060)
            )),
            with: .color(GamePalette.water.opacity(0.28))
        )
        premium.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.42), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &premium, "🍈", at: spot, width: x(0.22))
        drawTreat(in: &premium, "🍈", at: CGPoint(x: x(0.86), y: y(0.79)), width: x(0.09))

        // And the problem, in the same spot with the light off it and a track saying where it
        // came from — which is somewhere on this lot, and it is not saying where.
        var problem = shot
        problem.opacity = turn
        drawDuneSnakeTrack(
            in: &problem,
            from: CGPoint(x: spot.x + x(0.06), y: spot.y + y(0.008)),
            length: 0.42
        )
        drawTreat(in: &problem, "🐍", at: spot, width: x(0.22))

        drawDuneBlownSand(in: &shot, count: 10, seed: 857)
        drawDuneGlare(in: &shot, from: sun, strength: 0.20)
    }

    /// The lot, all of it, with one cactus standing in the middle and a puddle of shade at the
    /// foot of the cactus that the pig is standing in as much of as will fit. The camera pulls
    /// back the whole way through, so the joke gets bigger rather than being explained.
    ///
    /// This one hands the film over on a card, so the words go big across the middle of the
    /// frame — which on this world is a problem nowhere else has, since cream lettering over
    /// sunlit sand is cream over cream. What fixes it is the ground's own trick: the long blue
    /// shade of a dune standing out of shot, thrown across the middle of the picture. The
    /// caption gets something to sit on, and the shot gets to point out that the only shade for
    /// miles belongs to something that is not on the property.
    private func drawDuneShadeSoldSeparately(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.16 - 0.12 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        let sun = CGPoint(x: x(0.70), y: y(0.11))
        drawSun(in: &shot, at: sun, radius: x(0.036), rays: true)

        drawLand(in: &shot, ridge: 0.30, rise: 0.012, waves: 1.8, phase: 1.5, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.345, height: 0.045, from: -0.15, to: 1.15,
            count: 7, seed: 863, color: colors.farHill, haze: 0.34
        )
        drawLand(in: &shot, ridge: 0.335, rise: 0.010, waves: 1.5, phase: 0.6, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.33)

        // A very long run of nothing between the horizon and the pig's feet, which is the entire
        // subject of the shot. The near band is the only thing dividing it.
        drawLand(in: &shot, ridge: 0.62, rise: 0.020, waves: 1.0, phase: 1.7, color: colors.foreground)
        drawDuneRipples(in: &shot, from: 0.36, to: 0.99, count: 16, seed: 877)

        drawDuneCactus(in: &shot, at: CGPoint(x: x(0.44), y: y(0.80)), height: 0.13)
        // Stood in the shade of it, and it is not enough shade, and he is going to buy anyway.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.58), y: y(0.82)),
            width: x(0.15),
            lean: -3
        )
        drawTreat(in: &shot, "🦴", at: CGPoint(x: x(0.17), y: y(0.84)), width: x(0.07))

        drawDuneBlownSand(in: &shot, count: 14, seed: 881)
        drawDuneGlare(in: &shot, from: sun, strength: 0.14)
        drawDuneShade(in: &shot, at: CGPoint(x: x(0.26), y: y(0.50)), radius: 0.72, strength: 0.24)
    }

    // MARK: - Scorpion Flats

    /// The scorpion coming out from under its rock into the open, small and in no hurry, with the
    /// pig near the camera watching it arrive. The thicket's boar comes down through the trees
    /// because a wood has somewhere to come from; a desert does not, so the resident has to be
    /// somewhere in the shot already, and out here the only somewhere is under a stone.
    private func drawDuneNearestNeighbor(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        let sun = CGPoint(x: x(0.30), y: y(0.16))
        drawSun(in: &shot, at: sun, radius: x(0.035), rays: true)

        drawLand(in: &shot, ridge: 0.44, rise: 0.014, waves: 1.7, phase: 1.4, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.49, height: 0.05, from: -0.15, to: 1.15,
            count: 6, seed: 883, color: colors.farHill, haze: 0.32
        )
        drawLand(in: &shot, ridge: 0.48, rise: 0.012, waves: 1.4, phase: 2.2, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.475)
        // The flats, combed the whole way down. The scorpion crosses a lot of open ground in
        // this shot and it was crossing a blank one.
        drawDuneRipples(in: &shot, from: 0.50, to: 0.99, count: 20, seed: 887)

        // The rock, and then the ground laid over the bottom of it: a boulder with a flat foot
        // is a sticker, and this one has to look like it has been sat there long enough for
        // something to have moved in underneath.
        drawDuneRock(in: &shot, at: 0.29, base: 0.675, width: 0.26)
        drawLand(in: &shot, ridge: 0.645, rise: 0.014, waves: 1.3, phase: 0.7, color: colors.ground)
        // Off the frame edge rather than half out of it: a cactus cut in two by the side of the
        // picture reads as a mistake rather than as one more plant.
        drawDuneCactus(in: &shot, at: CGPoint(x: x(0.17), y: y(0.71)), height: 0.075)

        // Out from the shade and stopping in the sun, close enough to be met and small enough
        // that meeting it was optional. Nothing about the arrival is dramatic, which is worse.
        let out = easeOut(min(progress / 0.8, 1))
        drawAnimal(
            in: &shot,
            .scorpion,
            feet: CGPoint(x: x(0.31 + 0.17 * out), y: y(0.70)),
            width: x(0.13),
            shadow: 0.7
        )

        drawLand(in: &shot, ridge: 0.78, rise: 0.016, waves: 1.1, phase: 1.9, color: colors.foreground)
        drawDuneRipples(in: &shot, from: 0.79, to: 0.99, count: 8, seed: 907)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.76), y: y(0.80)), width: x(0.18), lean: -4)

        drawDuneBlownSand(in: &shot, count: 11, seed: 911)
        drawDuneGlare(in: &shot, from: sun, strength: 0.20)
    }

    /// The two of them at opposite ends of the frame with a great deal of hardpan in between,
    /// both turned away and both entirely content about it. The camera pulls back while they
    /// each drift a little further out, so the gap grows without either of them appearing to
    /// have moved.
    ///
    /// The thicket had to put a trunk between its two residents to make the point. Out here
    /// there is nothing to put between them and that is the point: the distance both parties
    /// requested was already on the property, going spare, in enormous quantity. So the middle
    /// of the shot is left completely empty and the wind's combing is run straight through it,
    /// because a run of ripples crossing an emptiness is what gives an emptiness a width.
    private func drawDuneLittleDistance(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        let sun = CGPoint(x: x(0.50), y: y(0.14))
        drawSun(in: &shot, at: sun, radius: x(0.034), rays: false)

        drawLand(in: &shot, ridge: 0.46, rise: 0.014, waves: 1.6, phase: 2.1, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.51, height: 0.05, from: -0.15, to: 1.15,
            count: 6, seed: 913, color: colors.farHill, haze: 0.32
        )
        drawLand(in: &shot, ridge: 0.50, rise: 0.012, waves: 1.3, phase: 0.5, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.495)
        // The gap between the two of them is the subject, and a gap has to be made of something.
        // Combed sand running the whole way down gives the emptiness a width; bare, it read as
        // the largest dead patch of flat colour in the world.
        drawDuneRipples(in: &shot, from: 0.51, to: 0.99, count: 22, seed: 919)

        // A cactus a long way back and dead small, so the gap has something to be measured
        // against without having anything standing in it.
        drawDuneCactus(in: &shot, at: CGPoint(x: x(0.51), y: y(0.58)), height: 0.045)

        drawLand(in: &shot, ridge: 0.70, rise: 0.020, waves: 1.1, phase: 1.6, color: colors.foreground)
        drawDuneRipples(in: &shot, from: 0.71, to: 0.99, count: 9, seed: 923)

        let breath = sin(progress * 2 * .pi * 1.2)
        let apart = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.24 - 0.03 * apart), y: y(0.76) - y(0.004 * breath)),
            width: x(0.19),
            lean: -5,
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .scorpion,
            feet: CGPoint(x: x(0.78 + 0.03 * apart), y: y(0.75) + y(0.004 * breath)),
            width: x(0.15),
            lean: 5,
            squash: 1 - 0.015 * breath
        )

        drawDuneBlownSand(in: &shot, count: 13, seed: 929)
        drawDuneGlare(in: &shot, from: sun, strength: 0.20)
    }

    /// The rule, drawn: a pen apiece with a lit strip of sand running down between them that
    /// belongs to neither.
    ///
    /// Two pens standing apart and two pens that may never touch are different pictures, and the
    /// briefing is asking for the second one. So the strip is drawn first and lit as the pens
    /// land, and it is wide enough to have a bone lying in it — a lane on the plan rather than a
    /// coincidence of spacing. Both pens are kept low in the frame and the middle is left to the
    /// words, with the shade of an off-screen dune thrown across it so cream lettering has
    /// something other than sunlit sand to sit on.
    private func drawDuneNoSharedFence(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.26))
        let sun = CGPoint(x: x(0.15), y: y(0.10))
        drawSun(in: &shot, at: sun, radius: x(0.034), rays: false)

        drawLand(in: &shot, ridge: 0.26, rise: 0.012, waves: 1.8, phase: 1.2, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.305, height: 0.045, from: -0.15, to: 1.15,
            count: 7, seed: 937, color: colors.farHill, haze: 0.34
        )
        drawLand(in: &shot, ridge: 0.30, rise: 0.010, waves: 1.5, phase: 2.4, color: colors.ground)
        drawDuneShimmer(in: &shot, along: 0.295)
        drawDuneRipples(in: &shot, from: 0.31, to: 0.99, count: 22, seed: 941)

        drawLand(in: &shot, ridge: 0.66, rise: 0.016, waves: 1.1, phase: 0.8, color: colors.foreground)
        drawDuneRipples(in: &shot, from: 0.67, to: 0.99, count: 8, seed: 947)

        // Wider apart than they were. At a fortieth of the frame the gap photographed as two
        // pens that happen not to touch, which is a different rule from the one being read out.
        let pig = CGPoint(x: x(0.24), y: y(0.80))
        let scorpion = CGPoint(x: x(0.76), y: y(0.80))
        let drawn = easeOut(min(progress / 0.8, 1))

        // The lane between the two lots, coming up as the plans do. It is lit rather than
        // outlined, because a third line on a diagram of two pens reads as a third pen — and it
        // is faded out at both sides and stopped level with the pens, since a hard-edged column
        // hanging below them photographed as a panel laid over the sand rather than as ground.
        let lane = CGRect(x: x(0.42), y: y(0.682), width: x(0.16), height: y(0.130))
        shot.fill(
            Path(lane),
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: colors.discHalo.opacity(0), location: 0),
                    .init(color: colors.discHalo.opacity(0.5 * drawn), location: 0.5),
                    .init(color: colors.discHalo.opacity(0), location: 1)
                ]),
                startPoint: CGPoint(x: lane.minX, y: 0),
                endPoint: CGPoint(x: lane.maxX, y: 0)
            )
        )

        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        drawAnimal(in: &shot, .scorpion, feet: scorpion, width: x(0.13), shadow: 0.7)

        drawGhostPen(in: &shot, round: pig, width: 0.36, height: 0.13, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: scorpion, width: 0.36, height: 0.13, drop: 0.012, opacity: 0.9 * drawn)

        // Somebody else's lot line, from before there were any — lying in the lane itself, so
        // the strip reads as ground that belongs to neither rather than as a gap.
        drawTreat(in: &shot, "🦴", at: CGPoint(x: x(0.50), y: y(0.795)), width: x(0.06))

        drawDuneBlownSand(in: &shot, count: 12, seed: 953)
        drawDuneGlare(in: &shot, from: sun, strength: 0.14)
        drawDuneShade(in: &shot, at: CGPoint(x: x(0.50), y: y(0.46)), radius: 0.80, strength: 0.22)
    }

    // MARK: - The dunes held

    /// Both pens holding under the coldest sky in the game: the scorpion up the slope in its own,
    /// the pig with the run of a pen the width of the frame, melons lying about in it, and a
    /// clear strip of sand between the two that nobody has to be reminded about any more.
    ///
    /// The joke of the caption is that the two things being sold — tons of space and very low
    /// humidity — are the same fact said twice, and the picture agrees by giving over most of
    /// itself to sky. There is more sky here than in any other held shot in the game, because
    /// nothing over the sand holds anything in, which is exactly why it is this cold.
    private func drawDunesHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawDuneStars(in: &shot, above: 0.40, count: 64, seed: 953)
        // The disc at this hour is the moon, and out here there is nothing in the way of it.
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.14)), radius: x(0.045), rays: false)

        drawLand(in: &shot, ridge: 0.40, rise: 0.014, waves: 1.7, phase: 1.5, color: colors.farHill)
        drawDuneField(
            in: &shot, base: 0.45, height: 0.05, from: -0.15, to: 1.15,
            count: 6, seed: 967, color: colors.farHill, haze: 0.24
        )
        drawLand(in: &shot, ridge: 0.44, rise: 0.012, waves: 1.4, phase: 0.9, color: colors.ground)
        // Combed before the pens go down rather than after, so the ripples lie under the wash
        // and the fencing instead of running across the top of both.
        drawDuneRipples(in: &shot, from: 0.45, to: 0.68, count: 10, seed: 969)

        // The neighbour, held and perfectly happy, at the far end of his own lot.
        let scorpion = CGPoint(x: x(0.78), y: y(0.60))
        drawPenWash(in: &shot, round: scorpion, width: 0.30, height: 0.10, drop: 0.01)
        drawAnimal(in: &shot, .scorpion, feet: scorpion, width: x(0.10), shadow: 0.6)
        drawPenFence(in: &shot, round: scorpion, width: 0.30, height: 0.10, drop: 0.01)

        drawDuneCactus(in: &shot, at: CGPoint(x: x(0.16), y: y(0.63)), height: 0.085)
        drawLand(in: &shot, ridge: 0.68, rise: 0.020, waves: 1.1, phase: 2.3, color: colors.foreground)

        // And the pig with the run of everything in front, melons and all.
        let pig = CGPoint(x: x(0.44), y: y(0.82))
        drawPenWash(in: &shot, round: pig, width: 0.72, height: 0.16, drop: 0.0)
        drawTreat(in: &shot, "🍈", at: CGPoint(x: x(0.15), y: y(0.79)), width: x(0.05))
        drawTreat(in: &shot, "🍈", at: CGPoint(x: x(0.69), y: y(0.81)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.72, height: 0.16, drop: 0.0)

        drawDuneRipples(in: &shot, from: 0.68, to: 0.99, count: 9, seed: 971)
        drawDuneBlownSand(in: &shot, count: 10, seed: 977)
    }

    /// A blue line lying along the far edge of the sand at dusk, and the pig up on the near crest
    /// turned to look at it rather than at the lot he spent three films buying.
    ///
    /// The sea is drawn first and the far sand laid over its near edge, which is the only way
    /// water reads as being beyond a country rather than lying on top of it — the same burial
    /// that keeps a rank of dunes from floating. It is a thin line and it is a long way off, and
    /// it is already more appealing than everything in front of it.
    private func drawDuneWaterAttached(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.48))
        drawDuneStars(in: &shot, above: 0.44, count: 56, seed: 983)
        drawSun(in: &shot, at: CGPoint(x: x(0.72), y: y(0.18)), radius: x(0.040), rays: false)

        // The next listing, seen as a strip about four pixels tall from the top of somebody
        // else's dune. Distance is a colour before it is a size.
        drawDuneSea(in: &shot, from: 0.455, to: 0.505, swell: 3)
        drawLand(in: &shot, ridge: 0.495, rise: 0.010, waves: 1.6, phase: 1.4, color: colors.farHill)

        drawDuneField(
            in: &shot, base: 0.56, height: 0.06, from: -0.15, to: 1.15,
            count: 5, seed: 991, color: colors.farHill, haze: 0.22
        )
        drawLand(in: &shot, ridge: 0.55, rise: 0.012, waves: 1.3, phase: 0.7, color: colors.ground)
        drawDuneRipples(in: &shot, from: 0.56, to: 0.80, count: 11, seed: 993)

        // The near crest in the foreground's colour, not the flat's: same fault as the opening's
        // middle rank, and worse after dark, where the invisible body left three lit triangles
        // standing in mid-air.
        drawDuneField(
            in: &shot, base: 0.78, height: 0.13, from: -0.2, to: 1.2,
            count: 3, seed: 997, color: colors.foreground, haze: 0.0
        )
        drawLand(in: &shot, ridge: 0.755, rise: 0.018, waves: 1.1, phase: 2.0, color: colors.foreground)

        // Stood on his own crest with his back half-turned, looking at somebody else's. Kept
        // well up the slope: this caption runs to two lines and at the foot of the frame the
        // pig was photographed with the words across his chin.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.76)), width: x(0.17), lean: -3)

        drawDuneRipples(in: &shot, from: 0.755, to: 0.99, count: 9, seed: 1_009)
        drawDuneBlownSand(in: &shot, count: 9, seed: 1_013)
    }

    /// The last dune, the sea coming up the beach under it, a shell already lying on the wet
    /// strand, and the pig going down towards all of it at a trot.
    ///
    /// The card sits in the middle of the frame, so the middle of the frame is water: a dark,
    /// even, obliging surface, which after three shots of trying to keep lettering off sunlit
    /// sand is a relief. Everything the pig owns is behind him and off the bottom of the picture.
    private func drawDuneSeaBeyond(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawDuneStars(in: &shot, above: 0.28, count: 60, seed: 1_019)
        drawSun(in: &shot, at: CGPoint(x: x(0.78), y: y(0.12)), radius: x(0.042), rays: false)

        drawDuneSea(in: &shot, from: 0.30, to: 0.74, swell: 7)
        // The strand, laid over the foot of the water so the sea ends in a shoreline rather than
        // in a straight edge, with the foam picked out along the same line it ends on.
        drawLand(in: &shot, ridge: 0.72, rise: 0.014, waves: 1.5, phase: 0.9, color: colors.ground)
        drawDuneFoam(in: &shot, along: 0.72, rise: 0.014, waves: 1.5, phase: 0.9)
        drawLand(in: &shot, ridge: 0.86, rise: 0.018, waves: 1.2, phase: 2.1, color: colors.foreground)

        // The next world's windfall, lying about on the next world's ground, being walked past.
        drawTreat(in: &shot, "🐚", at: CGPoint(x: x(0.70), y: y(0.80)), width: x(0.07))

        // Small, going down the slip face, and not slowing. The whole journey in one silhouette.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34 + 0.07 * along), y: y(0.83)),
            width: x(0.13),
            lean: 5,
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.6
        )

        drawDuneRipples(in: &shot, from: 0.86, to: 0.99, count: 5, seed: 1_021)
        drawDuneBlownSand(in: &shot, count: 7, seed: 1_031)
    }

    // MARK: - What a desert is made of

    /// The one cold colour in the world: the blue that fills every shadow out here, because the
    /// only light left to fill one with is the sky. Black shade would read as a hole cut in the
    /// sand; this reads as noon.
    ///
    /// After dark it has to be a different blue, and this cost a round of photographs to notice.
    /// The daylight blue is darker than sunlit sand and lighter than the desert at night, so used
    /// unchanged after sunset every shadow in the world came out *brighter* than the ground it
    /// was lying on — dune faces glowing like panes of glass rather than falling into shade.
    private var duneShadow: Color {
        colors.isNight
            ? Color(red: 0.05, green: 0.06, blue: 0.13)
            : Color(red: 0.30, green: 0.34, blue: 0.54)
    }

    /// One barchan: a long gentle back the wind climbs, a short steep face it drops everything
    /// down, and a horn trailing off downwind.
    ///
    /// The two faces are the whole brush. A dune drawn as a smooth hump with a wash over half of
    /// it is a paper cut-out at any size, and no amount of colour fixes it — it is the crest,
    /// with a lit face on one side and a shaded face on the other, that the eye reads as sand
    /// piled up. Every dune in the world leans the same way, because there is one wind, and the
    /// direction they all lean is the reason the ground under them is combed the way it is.
    ///
    /// `haze` lays the sky back over the finished shape, which is what puts a dune a mile off
    /// rather than in the next lot. It is doing exactly the job the thicket's mountain haze does.
    private func drawDuneCrest(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        color: Color,
        haze: Double = 0
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        // The summit sits downwind of the middle, which is what makes a heap of sand a barchan
        // rather than a hill.
        let summit = CGPoint(x: centre + span * 0.16, y: foot - tall)
        let windward = CGPoint(x: centre - span / 2, y: foot)
        let horn = CGPoint(x: centre + span / 2, y: foot)
        let slipControl = CGPoint(x: summit.x + span * 0.06, y: foot - tall * 0.74)
        // The dune runs off the bottom of the frame rather than closing along its own foot. A
        // rank of these with a base drawn on it shows a dead flat lower edge wherever the band
        // laid over the top of it dips, and a flat lower edge is a sticker.
        let skirt = foot + size.height
        // Where the crest comes down to the ground, which is what puts the two faces out of
        // square with each other.
        let hip = CGPoint(x: summit.x - span * 0.04, y: foot)

        // The back the wind climbs: shallow at the foot and steepening into the crest. Drawn as
        // a cubic rather than a quad because a single control point can only give a straight
        // ramp with a bend in it, and a straight ramp is a pyramid.
        func climb(_ path: inout Path) {
            path.addCurve(
                to: summit,
                control1: CGPoint(x: centre - span * 0.30, y: foot - tall * 0.16),
                control2: CGPoint(x: centre - span * 0.02, y: foot - tall * 0.96)
            )
        }

        var body = Path()
        body.move(to: CGPoint(x: windward.x, y: skirt))
        body.addLine(to: windward)
        climb(&body)
        body.addQuadCurve(to: horn, control: slipControl)
        body.addQuadCurve(
            to: CGPoint(x: horn.x + span * 0.24, y: foot + tall * 0.12),
            control: CGPoint(x: horn.x + span * 0.13, y: foot - tall * 0.08)
        )
        body.addLine(to: CGPoint(x: horn.x + span * 0.24, y: skirt))
        body.closeSubpath()
        context.fill(body, with: .color(color))

        // The sun on the windward back, laid on as a wash that fades out down the slope. It was
        // a stroke along the crest once, and a stroke up there photographs as a scratch ruled
        // across the dune rather than as a lit edge.
        var back = Path()
        back.move(to: windward)
        climb(&back)
        back.addLine(to: hip)
        back.closeSubpath()
        context.fill(
            back,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0),
                    GamePalette.cream.opacity(colors.isNight ? 0.10 : 0.26)
                ]),
                startPoint: CGPoint(x: 0, y: foot),
                endPoint: CGPoint(x: 0, y: foot - tall)
            )
        )

        // The slip face, in the shade of its own crest: the fold that makes the shape solid.
        //
        // It runs down to the dune's own foot and fades out as it goes, rather than being closed
        // off with a straight line from the summit to the ground. Closed that way it is a hard
        // triangle of flat shadow, and on the big near dunes — where the fold is a third of the
        // frame across — that triangle is the whole thing anybody sees.
        var slip = Path()
        slip.move(to: summit)
        slip.addQuadCurve(to: horn, control: slipControl)
        slip.addLine(to: CGPoint(x: horn.x, y: skirt))
        slip.addLine(to: CGPoint(x: hip.x, y: skirt))
        slip.closeSubpath()
        context.fill(
            slip,
            with: .linearGradient(
                Gradient(colors: [
                    duneShadow.opacity(colors.isNight ? 0.50 : 0.38),
                    duneShadow.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: summit.y),
                endPoint: CGPoint(x: 0, y: foot + tall * 0.25)
            )
        )

        guard haze > 0 else { return }
        context.fill(body, with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// A rank of dunes marching across the frame, which is what this world has instead of a rank
    /// of trees — and it is laid down the same way, with a band of ground drawn over its feet
    /// afterwards, because a row of anything with a dead flat lower edge reads as a shelf.
    private func drawDuneField(
        in context: inout GraphicsContext,
        base: Double,
        height: Double,
        from: Double,
        to: Double,
        count: Int,
        seed: UInt64,
        color: Color,
        haze: Double = 0
    ) {
        var scatter = Scatter(seed: seed)
        let step = (to - from) / Double(max(count, 1))

        for index in 0..<count {
            drawDuneCrest(
                in: &context,
                at: from + step * (Double(index) + scatter.next(in: 0.15...0.85)),
                base: base + scatter.next(in: -0.012...0.012),
                height: height * scatter.next(in: 0.70...1.30),
                width: step * scatter.next(in: 1.5...2.4),
                color: color,
                haze: haze
            )
        }
    }

    /// The wind's combing across the near sand: shallow curves all leaning the same way, each
    /// drawn twice — a lit crest with its own shadow under it — because that pairing is the only
    /// reason a flat pale ground reads as having any shape at all. Nearer ripples are drawn
    /// heavier than far ones, which is what gives an empty foreground its depth.
    private func drawDuneRipples(
        in context: inout GraphicsContext,
        from top: Double,
        to bottom: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for index in 0..<count {
            let depth = (Double(index) + scatter.next(in: 0.1...0.9)) / Double(max(count, 1))
            let down = y(top + (bottom - top) * depth)
            let drift = y(scatter.next(in: -0.018...0.018))

            var crest = Path()
            crest.move(to: CGPoint(x: -x(0.08), y: down))
            crest.addCurve(
                to: CGPoint(x: size.width + x(0.08), y: down + drift),
                control1: CGPoint(x: x(0.30), y: down + y(scatter.next(in: -0.014...0.014))),
                control2: CGPoint(x: x(0.70), y: down + y(scatter.next(in: -0.014...0.014)))
            )

            let thick = max(0.8, y(0.0016 + 0.0055 * depth))
            context.translateBy(x: 0, y: thick)
            context.stroke(
                crest,
                with: .color(duneShadow.opacity(colors.isNight ? 0.24 : 0.17)),
                style: StrokeStyle(lineWidth: thick, lineCap: .round)
            )
            context.translateBy(x: 0, y: -thick)
            context.stroke(
                crest,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.07 : 0.30)),
                style: StrokeStyle(lineWidth: thick, lineCap: .round)
            )
        }
    }

    /// The horizon refusing to hold still: flat slivers of sky laid along the far edge of the
    /// sand, each sliding at its own rate, so the join between ground and air is never quite
    /// where it was. It is the one thing in a still desert that is always moving, and since every
    /// sliver sits at a different offset it still reads as heat when the shot is frozen for a
    /// player who asked for less motion.
    private func drawDuneShimmer(in context: inout GraphicsContext, along baseline: Double) {
        for bar in 0..<7 {
            let phase = Double(bar) * 1.7
            let slide = x(0.022 * sin(progress * 2 * .pi + phase))
            let down = y(baseline) + y(0.0045 * Double(bar) - 0.012)
            let thick = y(0.006 + 0.002 * Double(bar % 3))

            context.fill(
                Path(ellipseIn: CGRect(
                    x: -x(0.12) + slide, y: down - thick / 2,
                    width: size.width + x(0.24), height: thick
                )),
                with: .color(colors.skyHorizon.opacity(0.32 - 0.03 * Double(bar)))
            )
        }
    }

    /// Too much sun, laid over the finished picture: a white bloom centred on the disc and
    /// falling off across the whole frame. Every photograph anybody has ever brought back from a
    /// place like this has it, and without it the shots read as a nice afternoon rather than as
    /// a lot that nothing will stand on.
    private func drawDuneGlare(in context: inout GraphicsContext, from centre: CGPoint, strength: Double) {
        context.fill(
            Path(CGRect(
                x: -size.width, y: -size.height,
                width: size.width * 3, height: size.height * 3
            )),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(strength), colors.discHalo.opacity(0)]),
                center: centre,
                startRadius: 0,
                endRadius: max(size.width, size.height) * 1.15
            )
        )
    }

    /// The long blue shade of a dune standing out of shot, thrown across part of the frame.
    ///
    /// It does two jobs at once, which is why it is here rather than being a nice touch. It says
    /// there is something big just off the picture, which an empty shot badly needs; and it is
    /// what a card's lettering is given to sit on, because cream words over sunlit sand are cream
    /// over cream and the caption is the only thing on the screen that must be readable.
    private func drawDuneShade(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        radius: Double,
        strength: Double
    ) {
        let reach = x(radius)
        context.fill(
            circle(at: centre, radius: reach),
            with: .radialGradient(
                Gradient(colors: [duneShadow.opacity(strength), duneShadow.opacity(0)]),
                center: centre,
                startRadius: 0,
                endRadius: reach
            )
        )
    }

    /// A cactus: a trunk with an arm each side of it, a rib of sun down the windward edge, and
    /// the shadow it is throwing pulled out long and blue across the sand.
    ///
    /// The shadow is what makes it read as desert rather than as a green stick, and every cactus
    /// in the film throws it the same way, since they are all standing under the one sun. Its
    /// flesh is the world's own canopy green — the same green the trail draws its scrub in — so a
    /// plant in a film is the plant on the board.
    private func drawDuneCactus(in context: inout GraphicsContext, at foot: CGPoint, height: Double) {
        let tall = y(height)
        let wide = tall * 0.24

        // The shadow tapers to a point and fades as it goes. Drawn as a bar with a squared-off
        // far end it photographed as a plank lying on the sand with the plant standing on it,
        // which is the one thing a shadow must never look like.
        var shade = Path()
        shade.move(to: CGPoint(x: foot.x - wide * 0.5, y: foot.y))
        shade.addQuadCurve(
            to: CGPoint(x: foot.x + tall * 1.05, y: foot.y + tall * 0.14),
            control: CGPoint(x: foot.x + tall * 0.5, y: foot.y + tall * 0.02)
        )
        shade.addQuadCurve(
            to: CGPoint(x: foot.x + wide * 0.5, y: foot.y + tall * 0.05),
            control: CGPoint(x: foot.x + tall * 0.45, y: foot.y + tall * 0.13)
        )
        shade.closeSubpath()
        context.fill(
            shade,
            with: .linearGradient(
                Gradient(colors: [
                    duneShadow.opacity(colors.isNight ? 0.24 : 0.34),
                    duneShadow.opacity(0)
                ]),
                startPoint: CGPoint(x: foot.x, y: 0),
                endPoint: CGPoint(x: foot.x + tall * 1.05, y: 0)
            )
        )

        var body = Path()
        body.addRoundedRect(
            in: CGRect(x: foot.x - wide / 2, y: foot.y - tall, width: wide, height: tall),
            cornerSize: CGSize(width: wide * 0.5, height: wide * 0.5)
        )
        // An arm each side, going up at a different height — the shape everybody draws a cactus
        // as, and by luck the shape they grow in.
        for (side, up, reach) in [(-1.0, 0.62, 0.34), (1.0, 0.46, 0.30)] {
            let elbow = CGPoint(x: foot.x + wide * 0.5 * CGFloat(side), y: foot.y - tall * CGFloat(up))
            let thick = wide * 0.68
            let out = tall * CGFloat(reach)
            let tip = CGPoint(x: elbow.x + out * CGFloat(side), y: elbow.y - tall * CGFloat(up * 0.42 + 0.10))

            body.addRoundedRect(
                in: CGRect(
                    x: min(elbow.x, tip.x) - (side > 0 ? thick * 0.5 : 0),
                    y: elbow.y - thick / 2,
                    width: out + thick * 0.5,
                    height: thick
                ),
                cornerSize: CGSize(width: thick * 0.5, height: thick * 0.5)
            )
            body.addRoundedRect(
                in: CGRect(
                    x: tip.x - thick / 2,
                    y: tip.y,
                    width: thick,
                    height: elbow.y - tip.y + thick * 0.5
                ),
                cornerSize: CGSize(width: thick * 0.5, height: thick * 0.5)
            )
        }
        context.fill(body, with: .color(colors.canopy))

        context.fill(
            Path(
                roundedRect: CGRect(
                    x: foot.x - wide * 0.40, y: foot.y - tall * 0.90,
                    width: wide * 0.22, height: tall * 0.84
                ),
                cornerRadius: wide * 0.11
            ),
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.09 : 0.26))
        )
    }

    /// A boulder sat on the hardpan with something living under it: two faces meeting on a ridge
    /// that comes down off the crown, and a shadow pulled out beside it. Drawn so the ground can
    /// be laid over its foot afterwards — a rock with a visible flat bottom is a sticker, and a
    /// sticker is not somewhere a scorpion could plausibly have been all afternoon.
    private func drawDuneRock(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        width: Double
    ) {
        let foot = y(base)
        let span = x(width)
        let centre = x(across)
        let tall = span * 0.66
        let crown = CGPoint(x: centre - span * 0.10, y: foot - tall)
        let hip = CGPoint(x: centre + span * 0.16, y: foot - tall * 0.24)
        let heel = CGPoint(x: centre + span * 0.20, y: foot + tall * 0.10)

        // The shade it throws, pulled out downwind the way everything else out here throws one.
        context.fill(
            Path(ellipseIn: CGRect(
                x: centre - span * 0.36, y: foot - tall * 0.06,
                width: span * 1.5, height: tall * 0.26
            )),
            with: .color(duneShadow.opacity(colors.isNight ? 0.22 : 0.30))
        )

        // Both faces run off the bottom of the frame, so the ground drawn over them afterwards
        // buries the foot rather than meeting a flat edge.
        let skirt = foot + size.height

        // Sun-baked rather than quarried: a warm grey-brown mixed towards the ground it is sat
        // on. Drawn in the game's cool `stone` it photographed as a blue-grey object imported
        // from another world and set down on the sand.
        let baked = Color(red: 0.52, green: 0.45, blue: 0.40)

        var lit = Path()
        lit.move(to: CGPoint(x: centre - span / 2, y: skirt))
        lit.addLine(to: CGPoint(x: centre - span / 2, y: foot + tall * 0.08))
        lit.addQuadCurve(to: crown, control: CGPoint(x: centre - span * 0.48, y: foot - tall * 0.82))
        // The ridge coming down off the crown, bowed rather than ruled: a straight split down
        // the middle of a dome is what makes it read as two flat halves instead of one stone.
        lit.addQuadCurve(to: heel, control: CGPoint(x: hip.x, y: hip.y))
        lit.addLine(to: CGPoint(x: heel.x, y: skirt))
        lit.closeSubpath()
        context.fill(lit, with: .color(baked))
        context.fill(
            lit,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(colors.isNight ? 0.10 : 0.36),
                    GamePalette.cream.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: foot - tall),
                endPoint: CGPoint(x: 0, y: foot)
            )
        )

        var shaded = Path()
        shaded.move(to: crown)
        shaded.addQuadCurve(to: heel, control: CGPoint(x: hip.x, y: hip.y))
        shaded.addLine(to: CGPoint(x: heel.x, y: skirt))
        shaded.addLine(to: CGPoint(x: centre + span / 2, y: skirt))
        shaded.addLine(to: CGPoint(x: centre + span / 2, y: foot + tall * 0.06))
        shaded.addQuadCurve(to: crown, control: CGPoint(x: centre + span * 0.42, y: foot - tall * 0.88))
        shaded.closeSubpath()
        context.fill(shaded, with: .color(baked))
        // Deepest under the crown and letting go towards the ground, so the far face turns away
        // rather than sitting there as a second flat panel.
        context.fill(
            shaded,
            with: .linearGradient(
                Gradient(colors: [
                    duneShadow.opacity(0.58),
                    duneShadow.opacity(0.18)
                ]),
                startPoint: CGPoint(x: 0, y: foot - tall),
                endPoint: CGPoint(x: 0, y: foot)
            )
        )
    }

    /// The track a snake left getting to where it is: short bars laid down in a slack S, each one
    /// the print of a length of the animal rather than a line it dragged.
    ///
    /// It is here because a snake in a desert is a thing that was somewhere else a moment ago,
    /// and a glyph on its own does not say that. The bars get shorter towards the far end, which
    /// is perspective doing the only work perspective can do on a flat pale ground.
    private func drawDuneSnakeTrack(in context: inout GraphicsContext, from start: CGPoint, length: Double) {
        let run = x(length)
        let rungs = 11
        var marks = Path()

        for rung in 0..<rungs {
            let along = Double(rung) / Double(rungs - 1)
            let centre = CGPoint(
                x: start.x + run * CGFloat(along),
                y: start.y - x(0.022) * CGFloat(sin(along * 3.6))
            )
            let bar = run * 0.055 * CGFloat(1 - along * 0.45)
            marks.move(to: CGPoint(x: centre.x - bar, y: centre.y + bar * 0.55))
            marks.addLine(to: CGPoint(x: centre.x + bar, y: centre.y - bar * 0.55))
        }

        context.stroke(
            marks,
            with: .color(duneShadow.opacity(0.36)),
            style: StrokeStyle(lineWidth: max(1, x(0.004)), lineCap: .round)
        )
    }

    /// Stars, and a great many of them, because the desert at night has more sky in it than
    /// anywhere else in the game and nothing whatever in the air to lose any of it to. They pulse
    /// rather than travel — a star that moved would be a plane — and the pulse is off at
    /// different phases so the sky still reads as alive in a frame held still.
    private func drawDuneStars(
        in context: inout GraphicsContext,
        above horizon: Double,
        count: Int,
        seed: UInt64
    ) {
        guard colors.isNight else { return }
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let spot = CGPoint(
                x: x(scatter.next(in: -0.05...1.05)),
                y: y(scatter.next(in: -0.04...horizon))
            )
            let phase = scatter.next() * 2 * .pi
            let lit = 0.30 + 0.55 * (moves ? (sin(progress * 3 * .pi + phase) + 1) / 2 : 0.6)
            let radius = max(0.7, x(0.0022) * CGFloat(scatter.next(in: 0.6...1.9)))
            context.fill(circle(at: spot, radius: radius), with: .color(GamePalette.cream.opacity(lit)))
        }
    }

    /// The next listing: water, lying in a slab with swell lines crossing it and the dusk laid
    /// back over the lot.
    ///
    /// The slab is drawn well outside the frame and always ends under something — a band of sand
    /// laid over its lower edge — because water with a ruled bottom edge reads as a strip of
    /// blue paper. The swells slide as the shot runs, which is the only moving thing in the two
    /// dusk shots that have no wind worth drawing.
    private func drawDuneSea(
        in context: inout GraphicsContext,
        from top: Double,
        to shore: Double,
        swell: Int
    ) {
        let head = y(top)
        let strand = y(shore)
        let water = CGRect(x: -size.width, y: head, width: size.width * 3, height: strand - head)

        context.fill(
            Path(water),
            with: .linearGradient(
                Gradient(colors: [GamePalette.waterDeep, GamePalette.water]),
                startPoint: CGPoint(x: 0, y: head),
                endPoint: CGPoint(x: 0, y: strand)
            )
        )
        // The hour, laid back over it. Distance and dusk are both colours before they are
        // anything else, and this is both at once.
        context.fill(Path(water), with: .color(colors.skyHorizon.opacity(colors.isNight ? 0.52 : 0.20)))

        // The far water, taken back into the sky. Without it the sea meets the air along a
        // ruled horizontal edge and the whole slab reads as a rectangle of blue paper laid on
        // the picture — the same burial every other far thing in this world gets.
        context.fill(
            Path(CGRect(
                x: -size.width, y: head,
                width: size.width * 3, height: (strand - head) * 0.34
            )),
            with: .linearGradient(
                Gradient(colors: [
                    colors.skyHorizon.opacity(colors.isNight ? 0.95 : 0.75),
                    colors.skyHorizon.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: head),
                endPoint: CGPoint(x: 0, y: head + (strand - head) * 0.34)
            )
        )

        guard swell > 0 else { return }

        // Swells at uneven depths and uneven weights. Evenly spaced they photographed as the
        // rules on a sheet of notepaper, which is the sea's version of the flat cut-out.
        var scatter = Scatter(seed: 1_033)
        for line in 0..<swell {
            let depth = min((Double(line) + scatter.next(in: 0.15...0.95)) / Double(swell), 1)
            let down = head + (strand - head) * CGFloat(depth)
            let slide = x(0.05 * sin(progress * 2 * .pi + Double(line) * 1.3)) * CGFloat(depth)
            let sag = y(scatter.next(in: 0.002...0.010))

            var crest = Path()
            crest.move(to: CGPoint(x: -x(0.1) + slide, y: down))
            crest.addCurve(
                to: CGPoint(x: size.width + x(0.1) + slide, y: down + sag * 0.5),
                control1: CGPoint(x: x(0.3), y: down - sag),
                control2: CGPoint(x: x(0.7), y: down + sag)
            )
            context.stroke(
                crest,
                with: .color(
                    GamePalette.waterRipple
                        .opacity((0.06 + 0.20 * depth) * scatter.next(in: 0.5...1.3))
                ),
                style: StrokeStyle(lineWidth: max(0.8, y(0.001 + 0.003 * depth)), lineCap: .round)
            )
        }
    }

    /// Foam along a shoreline: the same wavy edge a band of ground was drawn to, picked out in
    /// cream and broken up so it reads as water arriving rather than as a line ruled round the
    /// sand. It is the one warm-white thing in the dunes' last shot, and it is what tells the eye
    /// which of the two flat colours either side of it is the sea.
    private func drawDuneFoam(
        in context: inout GraphicsContext,
        along baseline: Double,
        rise: Double,
        waves: Double,
        phase: Double
    ) {
        let edge = ridgeLine(at: baseline, rise: rise, waves: waves, phase: phase)
        let surge = y(0.004 * sin(progress * 2 * .pi))
        // Runs and gaps of uneven length, and each run set down at its own weight. Evenly cut
        // dashes at one opacity photographed as the centre line of a road.
        var scatter = Scatter(seed: 1_039)

        var across = -x(0.05)
        let end = size.width + x(0.05)
        while across < end {
            let run = x(scatter.next(in: 0.015...0.075))
            var lace = Path()
            lace.move(to: CGPoint(x: across, y: edge(across) + surge))
            lace.addQuadCurve(
                to: CGPoint(x: across + run, y: edge(across + run) + surge),
                control: CGPoint(
                    x: across + run / 2,
                    y: edge(across + run / 2) + surge + y(scatter.next(in: -0.004 ... -0.001))
                )
            )
            context.stroke(
                lace,
                with: .color(
                    GamePalette.cream
                        .opacity((colors.isNight ? 0.42 : 0.66) * scatter.next(in: 0.45...1.0))
                ),
                style: StrokeStyle(lineWidth: max(1, y(0.0026)), lineCap: .round)
            )
            across += run + x(scatter.next(in: 0.006...0.030))
        }
    }

    /// Grains going by, low and all one way, which is what the dunes have instead of the meadow's
    /// birds or the thicket's fireflies.
    ///
    /// Each streak is nothing at the back and brightest at the front, so it can be told apart
    /// from the ripple it is passing over, and it fades in at one edge and out at the other
    /// rather than stopping. There is one wind, so they all travel the same way at nearly the
    /// same speed — and it is the same wind that built every dune in the frame, which is the
    /// quiet argument for putting it in every shot of the world.
    private func drawDuneBlownSand(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let down = y(scatter.next(in: 0.50...0.99))
            // A grain near the front of the shot goes by faster and shows up bigger than one
            // further off, the same way the near bank of the title screen outruns the far one.
            let nearness = Double(down / max(size.height, 1))
            let start = scatter.next()
            let along = (start + progress * (0.5 + 0.7 * nearness)).truncatingRemainder(dividingBy: 1)

            let head = CGPoint(
                x: x(-0.1) + (size.width + x(0.2)) * CGFloat(along),
                // Skipping rather than flying: it lifts off the sand and settles back onto it.
                y: down + y(0.008) * CGFloat(sin(progress * 8 + start * 12))
            )
            let length = x(scatter.next(in: 0.02...0.055)) * CGFloat(0.7 + nearness)
            let tail = CGPoint(x: head.x - length, y: down)

            var streak = Path()
            streak.move(to: tail)
            streak.addQuadCurve(
                to: head,
                control: CGPoint(x: (tail.x + head.x) / 2, y: (tail.y + head.y) / 2 + y(0.004))
            )
            context.stroke(
                streak,
                with: .linearGradient(
                    Gradient(colors: [
                        GamePalette.cream.opacity(0),
                        GamePalette.cream.opacity((colors.isNight ? 0.40 : 0.68) * sin(along * .pi))
                    ]),
                    startPoint: tail,
                    endPoint: head
                ),
                style: StrokeStyle(
                    lineWidth: max(0.7, y(0.0018) * CGFloat(0.6 + nearness)),
                    lineCap: .round
                )
            )
        }
    }
}
