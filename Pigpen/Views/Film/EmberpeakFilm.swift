import Foundation
import SwiftUI
import UIKit

// MARK: - Emberpeak, painted

/// The mountain's nine shots, and the seven brushes the low country never needed.
///
/// A meadow shot and a thicket shot are built the same way — a sky, a ridge, a band of ground,
/// an animal stood on it — and so is every shot up here. What changes is where the light comes
/// from. The meadow has a sun over it and the thicket has a roof under that sun, and both of
/// them are lit from above like anywhere else; Emberpeak is lit from underneath. There is a
/// crater going at the top of it, vents going in the rock, cinder still alight in the ash, and
/// after dark the sky is the darkest thing in the frame and the ground is the brightest. Every
/// composition here is built to say so, because "naturally heated" is the listing's whole pitch
/// and the pictures ought to make the reader nervous before the captions get their turn.
///
/// Three rules hold these together. Nothing has a flat foot: the summit, the burnt pines and
/// the city in the valley are all drawn first and then had ground laid over the bottom of them,
/// because a shape with a visible base reads as a sticker on a backdrop rather than a thing
/// standing in a country. Nothing that matters goes where the words go — the foot of the frame
/// on a shot with a subtitle, the middle band of it on the three that hand the film over on a
/// card. And the mountain is always doing something: steam leaning out of a vent, ash going up
/// off a cinder, a plume drifting off the summit. A volcano that holds perfectly still is a
/// postcard of a volcano.
///
/// The wyrm is drawn like every other animal in the game, as its own glyph over painted
/// scenery, and it is never once inside a fence. That is not decoration — it is the world's
/// rule, and the briefing's card would be lying if it drew the thing a pen.
extension Film {
    /// The climb and the briefing are lit by day, the send-off falls into dusk. Emberpeak makes
    /// more of that drop than either world below it: `emberDusk` is the first palette in the
    /// game whose ground carries a colour its sky does not, and the last film is the one that
    /// needs it, since a city coming on in a valley only reads as an invitation if everything
    /// above it has gone out.
    static func emberpeakLight(_ shot: CutScene.Picture.Emberpeak) -> GamePalette.Pasture {
        switch shot {
        case .theMountainHeld, .theCityBelow, .buildingCodes: .emberDusk
        default: .emberDay
        }
    }

    func drawEmberpeak(_ shot: CutScene.Picture.Emberpeak, in context: inout GraphicsContext) {
        switch shot {
        case .theSmokingPeak: drawEmberpeakSmokingPeak(in: &context)
        case .coinsAndFlames: drawEmberpeakCoinsAndFlames(in: &context)
        case .theViewFromTheRim: drawEmberpeakViewFromTheRim(in: &context)
        case .theLocalWildlife: drawEmberpeakLocalWildlife(in: &context)
        case .notJoiningTheAssociation: drawEmberpeakNoAssociation(in: &context)
        case .keepTheWyrmOut: drawEmberpeakKeepOut(in: &context)
        case .theMountainHeld: drawEmberpeakHeld(in: &context)
        case .theCityBelow: drawEmberpeakCityBelow(in: &context)
        case .buildingCodes: drawEmberpeakBuildingCodes(in: &context)
        }
    }

    // MARK: - The mountain's opening

    /// The property, from the bottom of the drive: burnt pines along a shelf of ash, the trail
    /// going up through them, and the peak standing over the lot of it with its plume out. The
    /// camera pushes in, which is the shot agreeing to make the climb.
    func drawEmberpeakSmokingPeak(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.54))
        // A sun with the mountain's own output between it and here, which is why it is set
        // small and low and has haze for a halo.
        drawSun(in: &shot, at: CGPoint(x: x(0.18), y: y(0.28)), radius: x(0.05), rays: false)
        drawClouds(in: &shot, at: 0.18, drift: 0.02 * progress)

        drawEmberpeakSummit(in: &shot, at: 0.62, base: 0.60, height: 0.40, width: 1.15, glow: 0.8, haze: 0.16)
        drawLand(in: &shot, ridge: 0.58, rise: 0.05, waves: 1.8, phase: 1.4, color: colors.farHill)

        // The tree line, if you can still call it that: the pines are what the mountain has
        // instead of a canopy, and there is nothing left of them but the spars.
        drawEmberpeakSnags(in: &shot, base: 0.70, from: -0.08, to: 1.08, height: 0.11, count: 15, seed: 601)
        drawLand(in: &shot, ridge: 0.68, rise: 0.03, waves: 1.5, phase: 0.7, color: colors.ground)

        drawTrail(in: &shot, from: 1.02, to: 0.68)
        drawEmberpeakScree(in: &shot, along: 0.76, count: 9, scale: 1, seed: 607)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.82), y: y(0.74)), width: x(0.10), steam: 0.8, glow: 0.6, seed: 613)

        // On the trail and starting up it, small against the climb: the mountain is the size of
        // the picture, and the buyer is not.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.44), y: y(0.82 - 0.02 * along)),
            width: x(0.16 - 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 2.4, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 10, seed: 617)
    }

    /// The two halves of the scoring rule, one after the other on the same shelf of ash: the
    /// coin while the line is calling the mineral rights a perk, and then the flame in the same
    /// spot while the line is calling the open ones a maintenance concern.
    ///
    /// The meadow taught this with a fence in the picture, because the fence was half of what
    /// it was teaching. Nobody up here needs teaching, so the pen stays out and the shot changes
    /// hands instead, crossing exactly where the caption changes sentence. The crossing is also
    /// where the light changes ends: the coin is held up in a shaft of daylight, and the flame
    /// is lit from below out of a crack in the ground, which is the difference between the two
    /// halves of this world in one cut.
    func drawEmberpeakCoinsAndFlames(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the perk to the concern: the first sentence has faded out
        // and the second is coming up, so the picture may change hands under cover of it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.44))
        drawSun(in: &shot, at: CGPoint(x: x(0.76), y: y(0.22)), radius: x(0.065), rays: false)
        drawClouds(in: &shot, at: 0.15, drift: 0.015 * progress)

        drawEmberpeakSummit(in: &shot, at: 0.22, base: 0.48, height: 0.22, width: 0.62, glow: 0.4, haze: 0.42)
        drawLand(in: &shot, ridge: 0.44, rise: 0.04, waves: 1.9, phase: 1.3, color: colors.farHill)
        // A burnt tree line along the shelf above, and a vent going at the far end of it: this
        // shot is a shelf of ash with two things standing on it, and without something between
        // the horizon and the ash it is two flat bands with the whole story in the last inch.
        drawEmberpeakSnags(in: &shot, base: 0.58, from: -0.08, to: 1.08, height: 0.09, count: 13, seed: 617)
        drawLand(in: &shot, ridge: 0.54, rise: 0.025, waves: 1.5, phase: 2.5, color: colors.ground)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.09), y: y(0.70)), width: x(0.09), steam: 0.7, glow: 0.6, seed: 653)
        drawEmberpeakScree(in: &shot, along: 0.64, count: 10, scale: 0.9, seed: 619)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.28), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.64), y: y(0.78))

        // The perk, stood in its own light with more of it turned up in the ash round about.
        var perk = shot
        perk.opacity = 1 - turn
        perk.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.11)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.38), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.11)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &perk, "🪙", at: spot, width: x(0.22))
        // Kept well up the slope. Down at the foot of the frame, where they were, they sat in
        // among the words — and a coin the size of a full stop beside a caption is a typo.
        drawTreat(in: &perk, "🪙", at: CGPoint(x: x(0.87), y: y(0.74)), width: x(0.07))
        drawTreat(in: &perk, "🪙", at: CGPoint(x: x(0.45), y: y(0.70)), width: x(0.06))

        // And the concern, in the same spot with the daylight off it and a crack in the ground
        // underneath doing the lighting instead.
        var concern = shot
        concern.opacity = turn
        drawEmberpeakVent(
            in: &concern,
            at: CGPoint(x: spot.x, y: spot.y + y(0.008)),
            width: x(0.17),
            steam: 0.45,
            glow: 1,
            seed: 631
        )
        drawTreat(in: &concern, "🔥", at: spot, width: x(0.22))

        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 8, seed: 641)
    }

    /// The pig on the near rim with the whole basin steaming away under it: a few issues, laid
    /// out end to end and being overlooked in both senses of the word. The card takes the middle
    /// of the frame, so the pig is put low on the rim and everything between it and the far wall
    /// is steam, which is the one thing in this game a reader loses nothing by having words over.
    func drawEmberpeakViewFromTheRim(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.24))
        drawSun(in: &shot, at: CGPoint(x: x(0.72), y: y(0.12)), radius: x(0.045), rays: false)

        // The far wall of the basin, two summits deep, both pushed back with haze rather than
        // with size — distance is a colour here before it is anything else. They are set low
        // enough to keep their craters: the camera pulls back through this shot, and a summit
        // whose top is off the frame at the start of it is a pyramid rather than a volcano.
        drawEmberpeakSummit(in: &shot, at: 0.30, base: 0.42, height: 0.20, width: 0.85, glow: 0.55, haze: 0.34)
        drawEmberpeakSummit(in: &shot, at: 0.88, base: 0.42, height: 0.16, width: 0.55, glow: 0.3, haze: 0.44)
        drawLand(in: &shot, ridge: 0.36, rise: 0.03, waves: 1.7, phase: 1.1, color: colors.farHill)

        // The floor, a long way down and hard at work.
        drawLand(in: &shot, ridge: 0.50, rise: 0.02, waves: 1.4, phase: 2.2, color: colors.ground)
        // Both vents sit clear of the rim drawn after them: a vent throws a round light onto the
        // ash, and a later band of ground across the bottom of that light leaves a translucent
        // grey box lying on the floor of the basin.
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.28), y: y(0.56)), width: x(0.11), steam: 0.7, glow: 0.7, seed: 643)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.70), y: y(0.60)), width: x(0.14), steam: 0.7, glow: 0.85, seed: 647)
        drawEmberpeakTarn(in: &shot, at: CGPoint(x: x(0.50), y: y(0.68)), width: x(0.34), seed: 653)
        // One bank of haze, and it is kept under the card. The upper one lay straight across
        // the line the words are set on, where it read as a thumbprint rather than as air.
        drawMist(in: &shot, at: 0.66, seed: 661)

        // The near rim, and the buyer stood on the edge of it with his weight forward. He is
        // set large and high on the rim, and the rim is dressed the whole way to the bottom of
        // the frame: a card carries no subtitle, so the foot of this one is picture rather than
        // the acre of bare ash it was.
        drawLand(in: &shot, ridge: 0.70, rise: 0.022, waves: 1.2, phase: 0.5, color: colors.foreground)
        drawEmberpeakSnags(in: &shot, base: 0.78, from: 0.56, to: 1.10, height: 0.09, count: 6, seed: 667)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.36), y: y(0.76)), width: x(0.20), lean: 4)
        drawEmberpeakScree(in: &shot, along: 0.83, count: 8, scale: 1.2, seed: 673)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.26), y: y(0.88)), width: x(0.14), steam: 0.8, glow: 0.9, seed: 691)
        drawEmberpeakScree(in: &shot, along: 0.95, count: 6, scale: 1.5, seed: 701)
        drawEmberpeakEmbers(in: &shot, count: 9, seed: 677)
    }

    // MARK: - Wyrm Caldera

    /// The neighbour, coming up out of the caldera and getting bigger the whole time the shot
    /// runs. Stag Mere walks the deer in from the side and Boar Hollow brings the boar down
    /// through the trees; neither of them needed to grow on the way. The disclosure said local
    /// wildlife, so the animal is drawn at the size the word does not cover.
    func drawEmberpeakLocalWildlife(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.05 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawEmberpeakSummit(in: &shot, at: 0.10, base: 0.44, height: 0.26, width: 0.70, glow: 0.4, haze: 0.35)
        drawEmberpeakSummit(in: &shot, at: 0.94, base: 0.44, height: 0.22, width: 0.60, glow: 0.3, haze: 0.40)
        drawLand(in: &shot, ridge: 0.40, rise: 0.035, waves: 1.8, phase: 1.4, color: colors.farHill)
        // Dead pines along the crater rim. Without them the whole upper half of the caldera is
        // one unbroken slab of colour, and a slab is not a place.
        drawEmberpeakSnags(in: &shot, base: 0.56, from: -0.08, to: 1.08, height: 0.08, count: 14, seed: 673)
        drawLand(in: &shot, ridge: 0.52, rise: 0.022, waves: 1.5, phase: 2.2, color: colors.ground)
        drawEmberpeakTarn(in: &shot, at: CGPoint(x: x(0.20), y: y(0.64)), width: x(0.28), seed: 683)

        // Up out of the crater and still coming: half again the size it started at, and its feet
        // buried by the ground drawn after it, so it is standing in the caldera rather than on it.
        let rise = easeOut(min(progress / 0.85, 1))
        drawAnimal(
            in: &shot,
            .wyrm,
            feet: CGPoint(x: x(0.66), y: y(0.60 + 0.04 * rise)),
            width: x(0.15 + 0.15 * rise),
            shadow: 0.6
        )

        // Well above the near bank drawn after it, which would otherwise cut the light it
        // throws off square and leave a grey pane lying on the caldera floor.
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.46), y: y(0.66)), width: x(0.12), steam: 0.9, glow: 0.8, seed: 691)
        drawLand(in: &shot, ridge: 0.74, rise: 0.02, waves: 1.3, phase: 0.6, color: colors.ground)
        drawEmberpeakScree(in: &shot, along: 0.72, count: 8, scale: 1.1, seed: 701)

        // And the buyer at the near lip, leaning away, at the size a buyer is — up off the foot
        // of the frame, where his shadow was landing in the middle of the caption.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.20), y: y(0.79)), width: x(0.16), lean: -5)

        drawLand(in: &shot, ridge: 0.92, rise: 0.014, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 10, seed: 709)
    }

    /// The two of them either side of a fumarole, each leaning away from it and both breathing.
    /// The thicket put a tree between its pair and called it a party wall; this one is a crack
    /// in the ground that neither of them made, neither of them crosses and neither of them is
    /// going to be talked into sharing. Nothing has been decided yet, so nothing moves but the
    /// air and what is coming up out of the floor.
    func drawEmberpeakNoAssociation(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        drawClouds(in: &shot, at: 0.17, drift: -0.015 * progress)
        drawEmberpeakSummit(in: &shot, at: 0.80, base: 0.50, height: 0.24, width: 0.70, glow: 0.45, haze: 0.34)
        drawLand(in: &shot, ridge: 0.46, rise: 0.035, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawEmberpeakSnags(in: &shot, base: 0.60, from: -0.08, to: 1.08, height: 0.09, count: 12, seed: 757)
        drawLand(in: &shot, ridge: 0.56, rise: 0.022, waves: 1.4, phase: 0.9, color: colors.ground)
        drawEmberpeakScree(in: &shot, along: 0.68, count: 8, scale: 1, seed: 719)

        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.23), y: y(0.80) - y(0.004 * breath)),
            width: x(0.18),
            lean: -5,
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .wyrm,
            feet: CGPoint(x: x(0.77), y: y(0.78) + y(0.004 * breath)),
            width: x(0.24),
            lean: 5,
            squash: 1 - 0.015 * breath
        )

        // The wall, and nobody built it: one vent up the middle, wide enough and hot enough to
        // be the reason these two are stood where they are stood. It is the shot's whole
        // argument, and it is the only thing in the frame doing anything — so it sits a little
        // up the slope and behind them rather than at the foot of the frame, where its mouth
        // was burning a hole through the first line of the caption.
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.50), y: y(0.76)), width: x(0.17), steam: 0.9, glow: 1, seed: 727)

        drawLand(in: &shot, ridge: 0.94, rise: 0.012, waves: 1.0, phase: 1.1, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 8, seed: 733)
    }

    /// One pen, round the pig, and the wyrm outside it going further out while you watch.
    ///
    /// Both the worlds below this one end their briefing on a pair of pens, because both of
    /// their residents are livestock with an opinion about sharing. The wyrm is not livestock.
    /// The board wants it left where it is, on the far side of whatever gets built, so drawing
    /// it a lot of its own would be a lie about the rule. What the picture says instead is: this
    /// much ground is yours, that animal is not in it, and the distance between the two is the
    /// point. The pig and its pen sit low, the wyrm sits high on the far rim, and the whole
    /// middle of the frame is left empty for the line that spells it out.
    func drawEmberpeakKeepOut(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.22))
        drawEmberpeakSummit(in: &shot, at: 0.88, base: 0.30, height: 0.22, width: 0.62, glow: 0.5, haze: 0.30)
        drawLand(in: &shot, ridge: 0.24, rise: 0.035, waves: 1.9, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.34, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)

        // Out, and getting further out: away up the rim and smaller with every frame, which is
        // what "very, very out" looks like when it has to be drawn rather than said.
        let out = easeOut(min(progress / 0.9, 1))
        drawAnimal(
            in: &shot,
            .wyrm,
            feet: CGPoint(x: x(0.70 + 0.09 * out), y: y(0.35 - 0.012 * out)),
            width: x(0.17 - 0.04 * out),
            shadow: 0.45
        )
        drawEmberpeakScree(in: &shot, along: 0.30, count: 7, scale: 0.8, seed: 739)

        // And the whole of the job, down where the ground is: one pen, marked out in chalk round
        // one pig, closing as the line is read.
        let pig = CGPoint(x: x(0.36), y: y(0.82))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: pig, width: 0.54, height: 0.13, drop: 0.014, opacity: 0.9 * drawn)

        // Ground worth having, drawn as ground: a vent still going off the open side of the pen
        // and cinder lying about the foot of the frame. The diagram was legible without any of
        // it and the half of the frame it stood in was a blank grey wall.
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.84), y: y(0.78)), width: x(0.13), steam: 0.9, glow: 0.9, seed: 769)
        drawEmberpeakScree(in: &shot, along: 0.70, count: 7, scale: 1.1, seed: 773)
        drawEmberpeakScree(in: &shot, along: 0.93, count: 7, scale: 1.4, seed: 787)
        drawEmberpeakEmbers(in: &shot, count: 8, seed: 743)
    }

    // MARK: - The mountain held

    /// A pen holding on the ridge after dark, with coins lying about the ash inside it, a vent
    /// going at one end and the crater lit above: excellent views, unbeatable heating, and the
    /// neighbour still out on the skyline exactly where the rule left him.
    ///
    /// The thicket's held shot pens the boar in a lot of his own at the far end of the frame.
    /// This one cannot and does not — the wyrm is drawn loose out beyond the rim, unfenced and
    /// uninterested, because that is what a held mountain looks like and anything else would
    /// contradict the film before it.
    func drawEmberpeakHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        // The disc at this hour is the moon, and it is not the brightest thing in the frame.
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.13)), radius: x(0.045), rays: false)
        // Set off the right-hand corner: the crater is the brightest thing in this frame, and up
        // where it was it burned away behind the Skip button.
        drawEmberpeakSummit(in: &shot, at: 0.56, base: 0.42, height: 0.28, width: 0.80, glow: 1, haze: 0.16)
        drawLand(in: &shot, ridge: 0.40, rise: 0.045, waves: 2.1, phase: 1.5, color: colors.farHill)

        // Still out there. Still not in anything.
        drawAnimal(in: &shot, .wyrm, feet: CGPoint(x: x(0.86), y: y(0.46)), width: x(0.10), shadow: 0.35)

        drawLand(in: &shot, ridge: 0.48, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.14), y: y(0.62)), width: x(0.12), steam: 0.7, glow: 0.9, seed: 751)
        drawEmberpeakTarn(in: &shot, at: CGPoint(x: x(0.80), y: y(0.61)), width: x(0.26), seed: 757)
        drawEmberpeakScree(in: &shot, along: 0.68, count: 8, scale: 1, seed: 761)

        // And the pig with the run of the ridge, windfall coins and all. The pen is dropped
        // below his feet rather than ruled through them, so he is standing in his own ground
        // instead of balancing on the bottom rail of it, and the gold is strewn with what the
        // mountain leaves lying about — an unbroken acre of it is a sheet of paper, and the
        // brightest sheet of paper in a dark frame is the only thing anybody looks at.
        let pen = CGPoint(x: x(0.42), y: y(0.81))
        drawPenWash(in: &shot, round: pen, width: 0.66, height: 0.15, drop: 0.022)
        drawEmberpeakScree(in: &shot, along: 0.755, count: 9, scale: 0.8, seed: 773)
        drawTreat(in: &shot, "🪙", at: CGPoint(x: x(0.19), y: y(0.79)), width: x(0.05))
        drawTreat(in: &shot, "🪙", at: CGPoint(x: x(0.63), y: y(0.785)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pen, width: x(0.15))
        drawPenFence(in: &shot, round: pen, width: 0.66, height: 0.15, drop: 0.022)

        drawEmberpeakEmbers(in: &shot, count: 12, seed: 769)
    }

    /// Down off the mountain at dusk, with a city coming on in the valley window by window and
    /// the pig turned away from three worlds of property to look at it.
    ///
    /// This is the send-off's job in every world, and it is the first time the thing being
    /// pointed at is somewhere people live. The meadow pointed at a wood and the thicket at this
    /// mountain, and both of those were shapes on a skyline; a city lights itself, so the shot
    /// gives it the one thing nothing else in the frame has — its own light, coming on a window
    /// at a time for as long as the line lasts. Everything above it has gone out on purpose, so
    /// that the brightest thing in a shot about wanting to leave is the place being left for.
    func drawEmberpeakCityBelow(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        // Kept over on the left. Hung where it was, it came up behind the Skip button and read
        // as a smudge of light leaking out from under the chrome.
        drawSun(in: &shot, at: CGPoint(x: x(0.20), y: y(0.14)), radius: x(0.04), rays: false)
        drawClouds(in: &shot, at: 0.27, drift: 0.015 * progress)
        drawLand(in: &shot, ridge: 0.46, rise: 0.04, waves: 1.8, phase: 1.7, color: colors.farHill)

        // The listing, a long way down and coming on as it is looked at.
        let lit = easeOut(min(progress / 0.85, 1))
        drawEmberpeakCity(in: &shot, at: 0.58, base: 0.68, width: 0.90, height: 0.13, lit: lit, haze: 0.30, seed: 773)
        // No haze laid over the roofs. Cream ellipses on a valley this dark do not read as the
        // air over a city; they read as somebody having scraped the picture, and the city has
        // its own distance in it already.
        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 0.9, color: colors.ground)
        drawEmberpeakScree(in: &shot, along: 0.74, count: 7, scale: 1, seed: 797)

        // Stood on his own ridge with his back half-turned, looking at somebody else's.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.26), y: y(0.82)), width: x(0.17), lean: -3)
        drawEmberpeakVent(in: &shot, at: CGPoint(x: x(0.86), y: y(0.80)), width: x(0.10), steam: 0.6, glow: 0.85, seed: 809)

        drawLand(in: &shot, ridge: 0.92, rise: 0.016, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 9, seed: 811)
    }

    /// The same city, nearer and taller, with the pig up on the rim and already walking down at
    /// it. The card takes the middle, so the skyline is kept under it and the pig above it, and
    /// what fills the band between the two is the smoke the mountain and the city are both
    /// putting into the same air — which is as close as this film comes to saying that the next
    /// world may not be an improvement.
    func drawEmberpeakBuildingCodes(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawEmberpeakSummit(in: &shot, at: 0.14, base: 0.36, height: 0.26, width: 0.55, glow: 0.75, haze: 0.20)
        // The last of the burnt pines, along the rim he is walking off: something for the pig
        // to be leaving, and a broken edge along the top of a frame that was otherwise sky over
        // a long dark drop. They stop well short of where he walks — a bare pine standing up
        // behind that particular glyph gives the pig antlers, and the pig becomes the stag from
        // two worlds ago.
        drawEmberpeakSnags(in: &shot, base: 0.34, from: -0.06, to: 0.25, height: 0.09, count: 6, seed: 829)
        drawLand(in: &shot, ridge: 0.30, rise: 0.03, waves: 1.7, phase: 1.2, color: colors.farHill)

        // Small, on the rim, and going. The whole journey in one silhouette, the way the
        // thicket's last card had it — except that this one is walking downhill for once.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34 + 0.07 * along), y: y(0.33)),
            width: x(0.11),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.5
        )

        // The valley the words sit over, and the city at the bottom of it: big, close, lit, and
        // built by nobody in particular. Its towers are brought up to just under the card, since
        // what stood between the pig and the skyline before was a third of a frame of nothing —
        // and the bank of haze that used to lie across the roofs is gone with it, because at
        // this hour it read as somebody having scratched the picture rather than as air.
        drawEmberpeakCity(in: &shot, at: 0.52, base: 0.96, width: 1.20, height: 0.28, lit: 0.55 + 0.45 * along, haze: 0.12, seed: 821)
        drawLand(in: &shot, ridge: 0.92, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawEmberpeakEmbers(in: &shot, count: 10, seed: 827)
    }

    // MARK: - What the mountain is made of

    /// The mountain itself: two faces meeting on a ridge that comes down off the summit, a
    /// crater between them instead of a point, and a plume standing off the top of it.
    ///
    /// A single triangle with a wash over half of it reads as a triangle with a wash on it, so
    /// the two faces are drawn out of square with each other and the fold between them does the
    /// work the wash cannot. The top is cut flat and tipped a little rather than brought to a
    /// point, because a live mountain has had its summit blown off and a mountain drawn to a
    /// point is a child's drawing of one.
    ///
    /// `base` is where its feet are, and they are meant to be buried — draw the ground after it,
    /// with a ridge a little above this line, so the mountain stands in the country rather than
    /// hovering over it. It carries a deep hem below that line for the ground to lap over,
    /// because a burying ridge waves up and down and a ridge that sags below the foot of a
    /// mountain shows the flat cut it was drawn on: the hem is what makes the burial hold
    /// wherever the wave happens to be. `haze` lays the sky back over the finished rock, which
    /// is what puts a summit miles off rather than in the next field, and it dims the fire to
    /// match: a crater that burns just as bright at any distance is what gives a painted
    /// backdrop away. `glow` is how much of a fire is in it, from a cold cone at 0 to the one
    /// this world is named for at 1.
    func drawEmberpeakSummit(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        glow: Double,
        haze: Double = 0
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        let rim = span * 0.065
        let crest = foot - tall
        // Ground colour is the whole of what says near or far in this game, and rock lit by a
        // sky that has gone out is not the same rock. By day the faces are stone with a warm
        // light on one of them; after dark they are nearly black, or the mountain floats over
        // an unlit country like a pane of glass.
        let lit = colors.isNight
            ? Color(red: 0.19, green: 0.13, blue: 0.14)
            : Color(red: 0.33, green: 0.26, blue: 0.28)
        let shade = colors.isNight
            ? Color(red: 0.11, green: 0.07, blue: 0.08)
            : Color(red: 0.18, green: 0.13, blue: 0.15)
        let ember = Color(red: 0.97, green: 0.45, blue: 0.16)
        let clear = 1 - haze
        // What is left below the foot for the ground to lap over.
        let hem = y(0.10)

        // The lip is tipped, so the top of the mountain is not a ruled line.
        let leftLip = CGPoint(x: centre - rim, y: crest)
        let rightLip = CGPoint(x: centre + rim, y: crest + tall * 0.04)
        let shoulder = CGPoint(x: centre - rim - span * 0.035, y: crest + tall * 0.06)
        // Where the ridge comes down to the ground, well off centre, which is what puts the two
        // faces out of square and stops the whole thing reading as paper.
        let hip = centre + span * 0.15

        var far = Path()
        far.move(to: CGPoint(x: hip, y: foot))
        far.addLine(to: leftLip)
        far.addLine(to: rightLip)
        far.addLine(to: CGPoint(x: centre + span / 2, y: foot))
        far.addLine(to: CGPoint(x: centre + span / 2, y: foot + hem))
        far.addLine(to: CGPoint(x: hip, y: foot + hem))
        far.closeSubpath()
        context.fill(far, with: .color(shade))

        var near = Path()
        near.move(to: CGPoint(x: centre - span / 2, y: foot))
        near.addLine(to: shoulder)
        near.addLine(to: leftLip)
        near.addLine(to: CGPoint(x: hip, y: foot))
        near.addLine(to: CGPoint(x: hip, y: foot + hem))
        near.addLine(to: CGPoint(x: centre - span / 2, y: foot + hem))
        near.closeSubpath()
        context.fill(near, with: .color(lit))

        // A gully down the lit face, and nothing brighter than the rock it is cut into. There
        // were two fire-coloured seams here, and however they were drawn — hairline or heavy,
        // long or short — a warm line lying on a face at that angle reads as a wire somebody
        // has strung down the mountain, and against a dark sky as a scratch on the glass. A
        // wedge of the shaded rock, widening as it falls, does the job the seams were there
        // for: it breaks the flat of the face, and it can only be read as a fold in it.
        var gully = Path()
        gully.move(to: CGPoint(x: centre - rim * 0.55, y: crest + tall * 0.10))
        gully.addQuadCurve(
            to: CGPoint(x: centre - span * 0.17, y: foot),
            control: CGPoint(x: centre - span * 0.06, y: crest + tall * 0.55)
        )
        gully.addLine(to: CGPoint(x: centre - span * 0.29, y: foot))
        gully.addQuadCurve(
            to: CGPoint(x: centre - rim * 0.9, y: crest + tall * 0.13),
            control: CGPoint(x: centre - span * 0.14, y: crest + tall * 0.58)
        )
        gully.closeSubpath()
        context.fill(gully, with: .color(shade.opacity(0.5)))

        // The air between here and there, laid back over the rock before anything bright is put
        // on top of it.
        if haze > 0 {
            var whole = Path()
            whole.move(to: CGPoint(x: centre - span / 2, y: foot + hem))
            whole.addLine(to: CGPoint(x: centre - span / 2, y: foot))
            whole.addLine(to: shoulder)
            whole.addLine(to: leftLip)
            whole.addLine(to: rightLip)
            whole.addLine(to: CGPoint(x: centre + span / 2, y: foot))
            whole.addLine(to: CGPoint(x: centre + span / 2, y: foot + hem))
            whole.closeSubpath()
            context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
        }

        // The plume: banks stacked straight off the crater, the lowest of them sitting in the
        // lip rather than hanging over it, so the smoke is coming out of the mountain rather
        // than passing above it.
        let rise = 0.55 + 0.45 * progress
        for bank in 0..<4 {
            let up = tall * CGFloat(0.03 + Double(bank) * 0.085) * CGFloat(rise)
            let puff = span * CGFloat(0.10 + Double(bank) * 0.045)
            let sway = span * CGFloat(0.03 * Double(bank)) * CGFloat(progress)
            context.fill(
                cloudPath(at: CGPoint(x: centre + sway, y: crest - up), width: puff),
                with: .color(GamePalette.cream.opacity((0.22 - 0.035 * Double(bank)) * clear))
            )
        }

        guard glow > 0 else { return }

        // The fire in the crater: the light it throws first, then the dark of the bowl, then a
        // small pool of molten in the bottom of it. Filled the other way round — one broad
        // orange disc across the summit — it reads as a lozenge somebody has stuck on the top,
        // because a hole has to be dark somewhere before anything glowing inside it is a hole.
        let crater = CGPoint(x: centre, y: crest + tall * 0.02)
        context.fill(
            circle(at: crater, radius: rim * 4),
            with: .radialGradient(
                Gradient(colors: [ember.opacity(0.34 * glow * clear), ember.opacity(0)]),
                center: crater,
                startRadius: rim * 0.2,
                endRadius: rim * 4
            )
        )
        let mouth = CGRect(
            x: crater.x - rim * 0.95, y: crater.y - rim * 0.28,
            width: rim * 1.90, height: rim * 0.56
        )
        context.fill(
            Path(ellipseIn: mouth),
            with: .color(Color(red: 0.10, green: 0.06, blue: 0.06).opacity(0.85))
        )
        context.fill(
            Path(ellipseIn: mouth.insetBy(dx: rim * 0.42, dy: rim * 0.13)),
            with: .color(ember.opacity(0.90 * glow * clear))
        )
    }

    /// A fumarole: a crack in the ash with light in it and steam leaning out of the top.
    ///
    /// This is the mountain's answer to the thicket's shafts of light through the leaves, and it
    /// runs the other way up — the light is under the ground rather than over it, and it lands
    /// on the underside of everything near it. The wisps lean as they rise, because nothing on
    /// this mountain goes straight up, and they lean further as the shot runs, which is the
    /// cheapest movement in the film and the one that does the most work.
    func drawEmberpeakVent(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        width: CGFloat,
        steam: Double,
        glow: Double,
        seed: UInt64
    ) {
        let ember = Color(red: 0.96, green: 0.40, blue: 0.14)

        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - width / 2, y: foot.y - width * 0.11,
                width: width, height: width * 0.22
            )),
            with: .color(Color(red: 0.11, green: 0.08, blue: 0.08).opacity(0.85))
        )
        context.fill(
            circle(at: foot, radius: width * 1.3),
            with: .radialGradient(
                Gradient(colors: [ember.opacity(0.34 * glow), ember.opacity(0)]),
                center: foot,
                startRadius: width * 0.1,
                endRadius: width * 1.3
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(
                x: foot.x - width * 0.30, y: foot.y - width * 0.07,
                width: width * 0.60, height: width * 0.14
            )),
            with: .color(ember.opacity(0.50 + 0.40 * glow))
        )

        guard steam > 0 else { return }

        // Four short ones rather than two long ones. A wisp drawn three times the width of its
        // own vent is a bent wire standing in the frame; the steam has to be a huddle of short
        // strokes at the mouth before any of them reads as steam at all.
        var scatter = Scatter(seed: seed)
        var wisps = Path()
        for _ in 0..<4 {
            let start = CGPoint(
                x: foot.x + width * CGFloat(scatter.next() - 0.5) * 0.8,
                y: foot.y - width * 0.06
            )
            let up = width * CGFloat(0.75 + scatter.next() * 0.95) * CGFloat(steam)
            let lean = width * CGFloat(0.2 + scatter.next() * 0.4) * CGFloat(0.6 + 0.8 * progress)
            wisps.move(to: start)
            wisps.addQuadCurve(
                to: CGPoint(x: start.x + lean, y: start.y - up),
                control: CGPoint(x: start.x - lean * 0.5, y: start.y - up * 0.55)
            )
        }
        context.stroke(
            wisps,
            with: .color(GamePalette.cream.opacity(0.20 * steam)),
            style: StrokeStyle(lineWidth: max(1.5, width * 0.09), lineCap: .round)
        )
    }

    /// A tarn: meltwater standing on cold rock, which is a mineral green rather than a meadow
    /// blue, with a rim of wet ash round it and steam coming off the top — the same water the
    /// mountain's own boards are cut round, so the pool in the film is the pool on the field.
    func drawEmberpeakTarn(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        width: CGFloat,
        seed: UInt64
    ) {
        let water = Color(red: 0.33, green: 0.59, blue: 0.59)
        let deep = Color(red: 0.17, green: 0.40, blue: 0.44)
        let shore = Color(red: 0.58, green: 0.50, blue: 0.44)
        let bowl = CGRect(
            x: centre.x - width / 2, y: centre.y - width * 0.17,
            width: width, height: width * 0.34
        )

        context.fill(
            Path(ellipseIn: bowl.insetBy(dx: -width * 0.05, dy: -width * 0.022)),
            with: .color(shore.opacity(colors.isNight ? 0.40 : 0.75))
        )
        context.fill(
            Path(ellipseIn: bowl),
            with: .linearGradient(
                Gradient(colors: [deep, water]),
                startPoint: CGPoint(x: bowl.minX, y: bowl.minY),
                endPoint: CGPoint(x: bowl.minX, y: bowl.maxY)
            )
        )
        // The light along the near edge, which is the only thing that says this is a surface
        // rather than a hole.
        context.fill(
            Path(ellipseIn: CGRect(
                x: bowl.minX + width * 0.20, y: bowl.midY + width * 0.05,
                width: width * 0.42, height: width * 0.045
            )),
            with: .color(Color(red: 0.90, green: 0.96, blue: 0.94).opacity(colors.isNight ? 0.35 : 0.65))
        )

        var scatter = Scatter(seed: seed)
        var wisps = Path()
        for _ in 0..<4 {
            let start = CGPoint(
                x: centre.x + width * CGFloat(scatter.next() - 0.5) * 0.8,
                y: centre.y - width * 0.02
            )
            let up = width * CGFloat(0.20 + scatter.next() * 0.30)
            let lean = width * CGFloat(0.06 + scatter.next() * 0.10) * CGFloat(0.6 + 0.8 * progress)
            wisps.move(to: start)
            wisps.addQuadCurve(
                to: CGPoint(x: start.x + lean, y: start.y - up),
                control: CGPoint(x: start.x - lean * 0.6, y: start.y - up * 0.55)
            )
        }
        context.stroke(
            wisps,
            with: .color(GamePalette.cream.opacity(0.16)),
            style: StrokeStyle(lineWidth: max(1.5, width * 0.035), lineCap: .round)
        )
    }

    /// Loose rock and cinder strewn along a line across the frame, some of it still going. What
    /// the thicket dresses its ground with is mushrooms and what the meadow dresses it with is
    /// wildflowers; nothing takes root this near the summit, so the mountain is dressed with
    /// what fell off it — drawn exactly as its own boards dress themselves, cinder and all.
    func drawEmberpeakScree(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        scale: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let rock = Color(red: 0.19, green: 0.15, blue: 0.15)
        let ember = Color(red: 0.95, green: 0.42, blue: 0.16)

        for index in 0..<count {
            let foot = CGPoint(
                x: x((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)),
                y: y(baseline + (scatter.next() - 0.5) * 0.03)
            )
            let spread = x(0.022) * CGFloat(scale) * CGFloat(0.6 + scatter.next() * 0.9)

            context.fill(
                Path(ellipseIn: CGRect(
                    x: foot.x - spread * 0.5, y: foot.y - spread * 0.44,
                    width: spread, height: spread * 0.52
                )),
                with: .color(rock.opacity(colors.isNight ? 0.85 : 0.7))
            )
            // Two in five have not gone out yet, and after dark they are the lit ones — the
            // light down here comes up through the cinder rather than down out of the sky.
            guard scatter.next() < 0.4 else { continue }
            context.fill(
                Path(ellipseIn: CGRect(
                    x: foot.x - spread * 0.22, y: foot.y - spread * 0.34,
                    width: spread * 0.44, height: spread * 0.24
                )),
                with: .color(ember.opacity(colors.isNight ? 0.9 : 0.6))
            )
        }
    }

    /// What is left of the tree line: burnt pine spars along a baseline, bare but for a stub or
    /// two of branch, leaning whichever way they were pushed.
    ///
    /// Drawn as strokes rather than as filled crowns, because a burnt pine has no mass left in
    /// it — a rank of them is a comb of black lines against the sky, and filling them in would
    /// only make the thicket's forest again in a darker colour. Like any rank, they are drawn
    /// first and then had the ground laid over their feet.
    func drawEmberpeakSnags(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        var spars = Path()

        for index in 0..<count {
            let across = x(from + (to - from) * (Double(index) + 0.2 + scatter.next() * 0.6) / Double(count))
            let tall = y(height) * CGFloat(0.5 + scatter.next() * 0.9)
            let lean = tall * CGFloat(scatter.next() - 0.5) * 0.24

            spars.move(to: CGPoint(x: across, y: foot))
            spars.addQuadCurve(
                to: CGPoint(x: across + lean, y: foot - tall),
                control: CGPoint(x: across + lean * 0.3, y: foot - tall * 0.6)
            )

            for stub in [0.52, 0.78] {
                let level = foot - tall * CGFloat(stub)
                let reach = tall * CGFloat(0.10 + scatter.next() * 0.13)
                let side: CGFloat = stub > 0.6 ? -1 : 1
                spars.move(to: CGPoint(x: across + lean * CGFloat(stub), y: level))
                spars.addLine(to: CGPoint(
                    x: across + lean * CGFloat(stub) + reach * side,
                    y: level - reach * 0.5
                ))
            }
        }

        context.stroke(
            spars,
            with: .color(Color(red: 0.13, green: 0.10, blue: 0.10).opacity(colors.isNight ? 0.9 : 0.8)),
            style: StrokeStyle(lineWidth: max(1.5, x(0.005)), lineCap: .round)
        )
    }

    /// Sparks and ash going up off the ground, each on its own little climb.
    ///
    /// The meadow gets birds and the thicket gets fireflies; a mountain gets what it is throwing
    /// off, and it throws it upwards, which is the one direction nothing else in this game moves
    /// in. Each mote carries its own place in the climb, so at any moment some are just off the
    /// ground and some are nearly gone — including at the single frozen instant a player who has
    /// asked for less motion is ever shown.
    func drawEmberpeakEmbers(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        let ember = Color(red: 1.00, green: 0.55, blue: 0.22)

        for _ in 0..<count {
            let home = CGPoint(x: x(scatter.next(in: 0.04...0.96)), y: y(scatter.next(in: 0.44...0.88)))
            let phase = scatter.next()
            let climb = moves ? (progress + phase).truncatingRemainder(dividingBy: 1) : phase
            let spot = CGPoint(
                x: home.x + x(0.03) * CGFloat(sin((climb + phase) * 4 * .pi)),
                y: home.y - y(0.17) * CGFloat(climb)
            )
            // Lit at the bottom of the climb, out by the top of it: an ember that reaches the
            // sky still burning is a firework.
            let life = sin(climb * .pi)

            context.fill(
                circle(at: spot, radius: x(0.012)),
                with: .radialGradient(
                    Gradient(colors: [ember.opacity(0.45 * life), ember.opacity(0)]),
                    center: spot,
                    startRadius: 0,
                    endRadius: x(0.012)
                )
            )
            context.fill(
                circle(at: spot, radius: x(0.0028)),
                with: .color(GamePalette.cream.opacity((colors.isNight ? 0.9 : 0.55) * life))
            )
        }
    }

    /// The next listing, seen from above: a run of blocks along the floor of the valley with
    /// their windows coming on, chimneys putting up what chimneys put up, and the whole thing
    /// laid back into the sky with haze.
    ///
    /// It is drawn as a skyline rather than as a place — nothing here has a door on it, because
    /// the pig is a long way up and none of this is his problem yet. What makes it a city and
    /// not a row of boxes is the pitch on some of the roofs and the height on none of the rest:
    /// a run of flat tops all the same reads as a bar chart. `lit` is how far through its
    /// evening the place is, and it only ever goes up, so a window that has come on stays on.
    /// `haze` is the distance, and the windows are put on after it, since the one thing that
    /// carries across a valley at dusk is somebody else's lights.
    func drawEmberpeakCity(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        width: Double,
        height: Double,
        lit: Double,
        haze: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        let span = x(width)
        let left = x(across) - span / 2
        let tallest = y(height)
        let stone = Color(red: 0.15, green: 0.13, blue: 0.17)
        let window = Color(red: 1.00, green: 0.82, blue: 0.45)
        let step = span * 0.055

        var blocks = Path()
        var lamps = Path()
        var stacks: [CGRect] = []
        var atX = left

        while atX < left + span {
            let wide = step * CGFloat(0.7 + scatter.next() * 0.9)
            let tall = tallest * CGFloat(0.30 + scatter.next() * 0.90)
            let block = CGRect(x: atX, y: foot - tall, width: wide, height: tall)
            blocks.addRect(block)

            let roll = scatter.next()
            if roll < 0.32 {
                var roof = Path()
                roof.move(to: CGPoint(x: block.minX, y: block.minY))
                roof.addLine(to: CGPoint(x: block.midX, y: block.minY - wide * 0.55))
                roof.addLine(to: CGPoint(x: block.maxX, y: block.minY))
                roof.closeSubpath()
                blocks.addPath(roof)
            } else if roll < 0.58 {
                stacks.append(CGRect(
                    x: block.midX - wide * 0.10, y: block.minY - tall * 0.22,
                    width: wide * 0.20, height: tall * 0.22
                ))
            }

            var level = block.minY + tall * 0.14
            while level < foot - tall * 0.10 {
                var side = block.minX + wide * 0.16
                while side < block.maxX - wide * 0.14 {
                    if scatter.next() < 0.28 + 0.5 * lit {
                        lamps.addRect(CGRect(x: side, y: level, width: wide * 0.13, height: tall * 0.05))
                    }
                    side += wide * 0.26
                }
                level += tall * 0.12
            }

            atX += wide + step * 0.18
        }

        for stack in stacks {
            blocks.addRect(stack)
        }
        context.fill(blocks, with: .color(stone))
        context.fill(blocks, with: .color(colors.skyHorizon.opacity(haze)))
        context.fill(lamps, with: .color(window.opacity(0.30 + 0.65 * lit)))

        // The light a city throws up into its own smoke, which is what a valley full of them
        // looks like from a mountain and the reason anybody up here starts packing.
        let sky = CGPoint(x: x(across), y: foot - tallest * 0.55)
        context.fill(
            Path(ellipseIn: CGRect(
                x: sky.x - span * 0.55, y: sky.y - tallest * 1.1,
                width: span * 1.1, height: tallest * 2.2
            )),
            with: .radialGradient(
                Gradient(colors: [window.opacity(0.22 * lit), window.opacity(0)]),
                center: sky,
                startRadius: 0,
                endRadius: span * 0.5
            )
        )

        // And what the chimneys are putting into it, drifting the way the summit's plume drifts.
        for (index, stack) in stacks.enumerated() {
            let sway = span * CGFloat(0.012 * Double(index % 3 + 1)) * CGFloat(progress)
            context.fill(
                cloudPath(
                    at: CGPoint(x: stack.midX + sway, y: stack.minY - tallest * 0.10),
                    width: stack.width * 3.2
                ),
                with: .color(GamePalette.cream.opacity(0.10))
            )
        }
    }
}
