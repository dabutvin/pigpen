import Foundation
import SwiftUI
import UIKit

// MARK: - Mirebog Fen, painted

/// The fen's nine shots, and the six brushes a world with this much water in it needs.
///
/// Every other world in the game is drawn as ground with things standing on it. The fen is
/// drawn as ground that lost: bands of dark peat water lying across the frame with the sky
/// caught on them, reeds standing in the bands, dead trees silvering where the bog got their
/// roots, and mist coming up off the lot of it — the one weather in the game that rises rather
/// than falls. A shot here is composed by deciding how many channels are between the camera and
/// whatever it is meant to be looking at, and the answer is never none.
///
/// The flatness is deliberate and is the hardest part. A fen has no ridge to hang a picture on,
/// so every `drawLand` in this file has a `rise` a third of what the meadow's shots use and the
/// depth is carried by the water instead: a channel high in the frame is thin and hazed, a
/// channel low in it is wide and dark, and the ground between them is only the gap. Where a
/// horizon would ordinarily do the work of putting one thing behind another, a bank of mist
/// does it here.
///
/// The other thing this world has that the others do not is a rule made of scenery. The croc
/// wants a whole waterway, both banks and both ends, so his two shots are built round a channel
/// that runs clean out of the frame either side and his ghost pen is drawn wide enough to
/// swallow the whole run of it — while the pig's pen is sent up onto dry peat where no part of
/// it can be mistaken for a share of the water.
extension Film {
    /// The fen's opening and its briefing are lit by day, for whatever daylight here is worth,
    /// and its send-off falls into dusk the way every world's does — the next listing is always
    /// the darker one, and this time it is also the higher one.
    static func mirebogLight(_ shot: CutScene.Picture.Mirebog) -> GamePalette.Pasture {
        switch shot {
        case .veryGreenVeryWet, .stillNotSatisfied, .onlyOneDirection: .fenDusk
        default: .fenDay
        }
    }

    func drawMirebog(_ shot: CutScene.Picture.Mirebog, in context: inout GraphicsContext) {
        switch shot {
        case .waterfrontEverywhere: drawWaterfrontEverywhere(in: &context)
        case .lotusAndMosquitoes: drawLotusAndMosquitoes(in: &context)
        case .describedAsLush: drawDescribedAsLush(in: &context)
        case .oneRequirement: drawOneRequirement(in: &context)
        case .theWholeThing: drawTheWholeThing(in: &context)
        case .aWholeWaterway: drawAWholeWaterway(in: &context)
        case .veryGreenVeryWet: drawVeryGreenVeryWet(in: &context)
        case .stillNotSatisfied: drawStillNotSatisfied(in: &context)
        case .onlyOneDirection: drawOnlyOneDirection(in: &context)
        }
    }

    // MARK: - The fen's opening

    /// The listing's own claim, taken at its word: four channels stacked away into the haze,
    /// reeds standing in all of them, and the pig on the one hag of peat in the middle with
    /// water behind him, water either side of him and water between him and the camera.
    ///
    /// The camera pushes in, which is the only thing in the shot that does anything — a fen has
    /// no wind worth drawing and nothing here is going anywhere.
    func drawWaterfrontEverywhere(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.03 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        // The sun of this world is a smear rather than a disc, so it is drawn small and left to
        // its own halo, which is most of what there is of it.
        drawSun(in: &shot, at: CGPoint(x: x(0.62), y: y(0.34)), radius: x(0.05), rays: false)

        drawLand(in: &shot, ridge: 0.44, rise: 0.014, waves: 1.5, phase: 1.2, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.46, at: [0.09, 0.16, 0.88], height: 0.11, seed: 601, haze: 0.5)
        drawLand(in: &shot, ridge: 0.48, rise: 0.010, waves: 1.2, phase: 0.4, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.48, depth: 0.05, seed: 607)

        // The far water: thin, pale and half lost, which is the whole of what puts it far off.
        drawMirebogChannel(in: &shot, along: 0.56, from: -0.10, to: 1.10, thickness: 0.020, seed: 613)
        drawMirebogReeds(
            in: &shot, along: 0.545, from: -0.05, to: 1.05,
            count: 12, height: 0.035, sway: 0.10 * progress, seed: 617
        )

        drawLand(in: &shot, ridge: 0.62, rise: 0.010, waves: 1.3, phase: 2.2, color: colors.ground)
        drawMirebogHags(in: &shot, along: 0.66, count: 5, spread: 0.22, seed: 619)
        drawMirebogSnags(in: &shot, base: 0.66, at: [0.79], height: 0.17, seed: 631, haze: 0.12)

        // The two ends of one channel with a causeway of peat between them, which is the shape
        // every field in this world is set on: dry ground is what is left over.
        drawMirebogChannel(in: &shot, along: 0.73, from: -0.10, to: 0.40, thickness: 0.035, seed: 641)
        drawMirebogChannel(in: &shot, along: 0.73, from: 0.62, to: 1.10, thickness: 0.035, seed: 643)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.51), y: y(0.76)),
            width: x(0.16),
            squash: 1 - 0.03 * hop(cycles: 2)
        )

        // And one more in front of him, so the water is on the camera's side of the pig as well
        // as on his. A property with a channel behind it has a view; a property with one in
        // front of it as well has a problem.
        drawMirebogChannel(in: &shot, along: 0.84, from: -0.10, to: 1.10, thickness: 0.030, seed: 647)
        drawMirebogMist(in: &shot, at: 0.80, depth: 0.06, seed: 653)
        drawLand(in: &shot, ridge: 0.92, rise: 0.010, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    /// The two halves of the scoring line over the same stretch of still water: the lotus open
    /// on it while the line is calling it a pop of colour, and the mosquito hanging in the same
    /// spot once the line has moved on to what else lives here.
    ///
    /// The meadow taught this rule inside a pen because the fence was half of what it was
    /// teaching; eleven worlds on there is nothing to teach, only two glyphs to name, so the
    /// shot hands over from one to the other exactly where the caption changes sentence. The
    /// mosquito gets the wobble the lotus does not: a flower on water is the stillest thing in
    /// the world, and the thing that comes after it will not hold still at all.
    func drawLotusAndMosquitoes(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the amenity becomes the drawback: the first sentence has gone and the second is
        // coming up, so the water may change hands under cover of it.
        let turn = easeOut(min(max((progress - 0.46) / 0.12, 0), 1))

        drawSky(in: &shot, horizon: y(0.40))
        drawSun(in: &shot, at: CGPoint(x: x(0.72), y: y(0.24)), radius: x(0.055), rays: false)

        drawLand(in: &shot, ridge: 0.40, rise: 0.012, waves: 1.4, phase: 1.1, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.43, at: [0.84, 0.92], height: 0.12, seed: 659, haze: 0.45)
        drawLand(in: &shot, ridge: 0.46, rise: 0.010, waves: 1.2, phase: 2.5, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.47, depth: 0.05, seed: 661)
        drawMirebogReeds(
            in: &shot, along: 0.50, from: -0.05, to: 1.05,
            count: 12, height: 0.045, sway: 0.08 * progress, seed: 673
        )

        // The pool both halves of the line happen over. Wide and flat and dead still: the only
        // shot in the film where the water is the subject rather than the obstacle.
        drawMirebogChannel(in: &shot, along: 0.66, from: -0.10, to: 1.10, thickness: 0.075, seed: 677)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.26), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let spot = CGPoint(x: x(0.64), y: y(0.68))

        // The amenity, in its own light, with a second one open further out to say there are
        // more where that came from.
        var amenity = shot
        amenity.opacity = 1 - turn
        amenity.fill(
            circle(at: CGPoint(x: spot.x, y: spot.y - x(0.10)), radius: x(0.20)),
            with: .radialGradient(
                Gradient(colors: [colors.discHalo.opacity(0.36), colors.discHalo.opacity(0)]),
                center: CGPoint(x: spot.x, y: spot.y - x(0.10)),
                startRadius: x(0.02),
                endRadius: x(0.20)
            )
        )
        drawTreat(in: &amenity, "🪷", at: spot, width: x(0.22))
        drawTreat(in: &amenity, "🪷", at: CGPoint(x: x(0.88), y: y(0.64)), width: x(0.09))

        // And the drawback, in the same spot with the light off it and not staying put.
        var drawback = shot
        drawback.opacity = turn
        let whine = sin(progress * 2 * .pi * 3)
        drawTreat(
            in: &drawback,
            "🦟",
            at: CGPoint(
                x: spot.x + x(0.014) * CGFloat(whine),
                y: spot.y - y(0.020) - y(0.010) * CGFloat(cos(progress * 2 * .pi * 3))
            ),
            width: x(0.20)
        )

        drawLand(in: &shot, ridge: 0.90, rise: 0.010, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The pig standing in the channel with the reed bed shut over his shoulders. Lush is the
    /// word, and the picture is what the word turns out to have meant.
    ///
    /// A card, so the middle of the frame belongs to the line: the fen's horizon is put up high
    /// where a fen's horizon belongs anyway, everything worth seeing is in the bottom third, and
    /// the band between them is mist, which is the one thing big type reads better over. The
    /// camera pulls back as it goes and more reeds arrive at the edges, none of which the shot
    /// needs to be read — it only needs the pig to be in the water, and he is from the first
    /// frame.
    func drawDescribedAsLush(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawLand(in: &shot, ridge: 0.30, rise: 0.012, waves: 1.5, phase: 1.8, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.32, at: [0.07, 0.19, 0.91], height: 0.09, seed: 683, haze: 0.5)
        drawLand(in: &shot, ridge: 0.34, rise: 0.008, waves: 1.2, phase: 0.6, color: colors.ground)
        drawMirebogReeds(
            in: &shot, along: 0.35, from: -0.05, to: 1.05,
            count: 14, height: 0.030, sway: 0.10 * progress, seed: 691
        )
        drawMirebogMist(in: &shot, at: 0.42, depth: 0.07, seed: 701)

        // The channel he is in, wide and near and going out of frame both ways.
        drawMirebogChannel(in: &shot, along: 0.72, from: -0.10, to: 1.10, thickness: 0.115, seed: 709)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.44), y: y(0.79)),
            width: x(0.16),
            lean: -3,
            shadow: 0.35
        )

        // A lip of the same water laid back over his feet. Anything stood in a fen and not
        // drawn into it is stood on it, which is a different world and a much drier one.
        drawMirebogChannel(in: &shot, along: 0.795, from: -0.10, to: 1.10, thickness: 0.026, seed: 719)

        // The lushness: a bed tall enough to close over him, drawn last so it is between the
        // pig and the camera rather than behind him. Its feet go under the near band rather
        // than onto it — fifteen clumps whose stems all stop dead on one line read as a fringe
        // stuck to the picture, and a bed of reeds has no bottom edge to see.
        drawMirebogReeds(
            in: &shot, along: 0.885, from: -0.05, to: 1.05,
            count: 15, height: 0.115, sway: 0.14 * progress, seed: 727
        )
        drawLand(in: &shot, ridge: 0.868, rise: 0.010, waves: 1.0, phase: 2.4, color: colors.foreground)
    }

    // MARK: - The Wallow

    /// The croc coming up out of his channel onto the near bank, big and in no hurry, with the
    /// pig away on the far side of the water where he was standing when this started.
    ///
    /// Every boss film in the game opens with the resident arriving. This one arrives out of the
    /// scenery rather than across it: he is in the picture from the first frame, being most of a
    /// channel's worth of water, and what the shot does is let the rest of him out.
    func drawOneRequirement(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawSun(in: &shot, at: CGPoint(x: x(0.28), y: y(0.30)), radius: x(0.05), rays: false)
        drawLand(in: &shot, ridge: 0.42, rise: 0.012, waves: 1.5, phase: 1.3, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.45, at: [0.70, 0.78], height: 0.12, seed: 733, haze: 0.45)
        drawLand(in: &shot, ridge: 0.48, rise: 0.010, waves: 1.2, phase: 0.8, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.50, depth: 0.05, seed: 739)
        drawMirebogReeds(
            in: &shot, along: 0.54, from: -0.05, to: 1.05,
            count: 12, height: 0.040, sway: 0.08 * progress, seed: 743
        )

        // The pig on the far bank, small and already a fair way back from the water, which is
        // the position he will be holding for the rest of the film.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.80), y: y(0.60)),
            width: x(0.12),
            lean: -4,
            shadow: 0.6
        )

        drawMirebogChannel(in: &shot, along: 0.70, from: -0.10, to: 1.10, thickness: 0.090, seed: 751)

        // Out and along the near bank, slowing as he comes. Half the frame wide, because the
        // thing the shot has to establish is that this is not a lodger.
        let out = easeOut(min(progress / 0.85, 1))
        drawAnimal(
            in: &shot,
            .croc,
            feet: CGPoint(x: x(-0.04 + 0.42 * out), y: y(0.77)),
            width: x(0.30),
            shadow: 0.45
        )

        drawMirebogReeds(
            in: &shot, along: 0.905, from: -0.06, to: 0.24,
            count: 4, height: 0.080, sway: 0.10 * progress, seed: 757
        )
        drawLand(in: &shot, ridge: 0.888, rise: 0.010, waves: 1.0, phase: 2.1, color: colors.foreground)
    }

    /// One waterway, running clean out of the frame at both ends, with the croc's claim going
    /// down the length of it as the shot runs.
    ///
    /// The caption is two sentences and the second one takes back the generosity of the first,
    /// so the picture spends itself on the word *whole*: the water lights up from the croc's end
    /// outward until every foot of it is his, and it is still lighting when the line lands. A
    /// croc looking greedy would have said nothing a boss glyph does not already say; a channel
    /// going gold end to end says the rule.
    func drawTheWholeThing(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.38))
        drawLand(in: &shot, ridge: 0.38, rise: 0.012, waves: 1.4, phase: 2.1, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.41, at: [0.10, 0.90], height: 0.10, seed: 761, haze: 0.5)
        drawLand(in: &shot, ridge: 0.44, rise: 0.008, waves: 1.2, phase: 0.5, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.46, depth: 0.05, seed: 769)
        drawMirebogReeds(
            in: &shot, along: 0.50, from: -0.05, to: 1.05,
            count: 13, height: 0.040, sway: 0.08 * progress, seed: 773
        )

        // The pig kept up on the bank, which on this board is the only place he is ever going
        // to be allowed to stand.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.83), y: y(0.58)),
            width: x(0.12),
            lean: -4,
            shadow: 0.6
        )

        let waterway = mirebogChannelPath(along: 0.68, from: -0.10, to: 1.10, thickness: 0.10)
        drawMirebogChannel(in: &shot, along: 0.68, from: -0.10, to: 1.10, thickness: 0.10, seed: 787)

        // The claim: the pen's own gold, run along the water from where he is lying to the far
        // end of it, so what the eye reads is a length being taken rather than a colour being
        // turned on all over.
        //
        // It is a gradient with moving stops and not a clip. A clipped pane has a straight edge
        // down it, and a straight edge halfway across a picture is a rectangle laid over the
        // shot however slowly it grows — which is precisely what it looked like. A gradient front
        // has nothing to see but the front.
        let taken = easeOut(min(progress / 0.85, 1))
        let front = 0.12 + 1.05 * taken
        let held = min(max(front - 0.14, 0.002), 0.997)
        let edge = min(max(front, held + 0.002), 1)
        shot.fill(
            waterway,
            with: .linearGradient(
                Gradient(stops: [
                    Gradient.Stop(color: GamePalette.pen.opacity(0.34), location: 0),
                    Gradient.Stop(color: GamePalette.pen.opacity(0.34), location: CGFloat(held)),
                    Gradient.Stop(color: GamePalette.pen.opacity(0), location: CGFloat(edge))
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: 0)
            )
        )

        drawAnimal(
            in: &shot,
            .croc,
            feet: CGPoint(x: x(0.18), y: y(0.72)),
            width: x(0.26),
            shadow: 0.4
        )

        drawLand(in: &shot, ridge: 0.90, rise: 0.010, waves: 1.0, phase: 1.4, color: colors.foreground)
    }

    /// The rule, drawn: a channel across the foot of the frame with a ghost pen laid round the
    /// whole of it — both banks, both ends and the croc lying in the middle of it — and the
    /// pig's own pen away up the dry peat with no water anywhere in it.
    ///
    /// The thicket's card put two pens side by side with a gap between them and the gap was the
    /// rule. Here the gap is only half of it: what the second pen has to say is not merely *not
    /// this one* but *not on the water*, so it is put as far up the frame as a pen can go, on
    /// ground the channel never reaches. The words go through the middle, where there is nothing
    /// but mist between the two of them.
    func drawAWholeWaterway(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 - 0.02 * progress)

        // A high camera and a short sky: the shot is a plan of a piece of ground, and almost all
        // of it is ground.
        drawSky(in: &shot, horizon: y(0.18))
        drawLand(in: &shot, ridge: 0.18, rise: 0.010, waves: 1.4, phase: 1.0, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.20, at: [0.06, 0.94], height: 0.07, seed: 797, haze: 0.5)
        drawLand(in: &shot, ridge: 0.22, rise: 0.008, waves: 1.2, phase: 2.0, color: colors.ground)
        drawMirebogHags(in: &shot, along: 0.30, count: 4, spread: 0.20, seed: 809)

        let pig = CGPoint(x: x(0.27), y: y(0.30))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.10), shadow: 0.7)

        drawMirebogMist(in: &shot, at: 0.52, depth: 0.08, seed: 811)

        // The waterway, with its ends inside the frame on purpose: a channel that ran off the
        // edge would leave the pen swallowing as much of it as we happen to be shown, and the
        // word the rule turns on is *entire*. Both ends stop a good way short of where the pen
        // will be drawn, and the far bank's reeds stand between the water and the fence line,
        // so what is inside the dashes is a whole channel with a margin of peat all round it
        // rather than a channel the pen has been laid on top of.
        drawMirebogReeds(
            in: &shot, along: 0.730, from: 0.11, to: 0.89,
            count: 10, height: 0.030, sway: 0.08 * progress, seed: 821
        )
        drawMirebogChannel(in: &shot, along: 0.775, from: 0.14, to: 0.86, thickness: 0.070, seed: 823)

        let croc = CGPoint(x: x(0.50), y: y(0.80))
        drawAnimal(in: &shot, .croc, feet: croc, width: x(0.22), shadow: 0.4)

        // Both pens open together. His takes in the whole run of water and the ground either
        // side of it; hers is up on the peat and stops well short of the far bank.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: croc, width: 0.94, height: 0.14, drop: 0.035, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: pig, width: 0.30, height: 0.09, drop: 0.012, opacity: 0.9 * drawn)
    }

    // MARK: - The fen held

    /// Two pens holding at dusk: the croc's laid over the whole length of his channel with a
    /// lotus open on the water inside it, and the pig's on the dry hag in front, with the bog
    /// making its own small lights in the reeds behind them both.
    ///
    /// The gold goes down before the water rather than over it, which is the one thing this
    /// world's held shot needed that no other world's did. A pen wash painted over a channel
    /// swallows the channel, and the property the pig has just spent nine fields buying stops
    /// being waterfront in the frame that proves it is.
    func drawVeryGreenVeryWet(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.03 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        // The disc at this hour is the moon, and this world's air barely lets it through.
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.14)), radius: x(0.045), rays: false)
        drawLand(in: &shot, ridge: 0.30, rise: 0.012, waves: 1.5, phase: 1.4, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.33, at: [0.11, 0.87], height: 0.13, seed: 827, haze: 0.3)
        drawLand(in: &shot, ridge: 0.36, rise: 0.010, waves: 1.2, phase: 0.7, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.40, depth: 0.05, seed: 829)
        drawMirebogReeds(
            in: &shot, along: 0.44, from: -0.05, to: 1.05,
            count: 12, height: 0.040, sway: 0.06 * progress, seed: 839
        )

        // The neighbour, held, with the whole of his wallow inside the fence and the water
        // still reading as water.
        let croc = CGPoint(x: x(0.52), y: y(0.62))
        drawPenWash(in: &shot, round: croc, width: 0.86, height: 0.11, drop: 0.02)
        drawMirebogChannel(in: &shot, along: 0.58, from: 0.13, to: 0.91, thickness: 0.045, seed: 853)
        drawTreat(in: &shot, "🪷", at: CGPoint(x: x(0.25), y: y(0.59)), width: x(0.05))
        drawAnimal(in: &shot, .croc, feet: croc, width: x(0.17), shadow: 0.5)
        drawPenFence(in: &shot, round: croc, width: 0.86, height: 0.11, drop: 0.02)

        // And the pig with the run of the dry ground, such as it is.
        let pig = CGPoint(x: x(0.40), y: y(0.82))
        drawPenWash(in: &shot, round: pig, width: 0.66, height: 0.13, drop: 0.0)
        drawTreat(in: &shot, "🪷", at: CGPoint(x: x(0.17), y: y(0.79)), width: x(0.045))
        drawTreat(in: &shot, "🪷", at: CGPoint(x: x(0.63), y: y(0.81)), width: x(0.045))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.66, height: 0.13, drop: 0.0)

        drawMirebogWisps(in: &shot, count: 7, seed: 857)
        drawMirebogMist(in: &shot, at: 0.72, depth: 0.06, seed: 859)
    }

    /// The pig on the highest peat in the fen with the mist round his knees, tipped back and
    /// looking up.
    ///
    /// Ten worlds have ended by looking sideways at the next one — over a tree line, along a
    /// shore, down off the ice. This one cannot, because there is nothing in any direction but
    /// more fen and the first film said so, so the camera pulls back and hands the top half of
    /// the frame to the sky instead. What he is dissatisfied with is not the property. It never
    /// is.
    func drawStillNotSatisfied(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.20)), radius: x(0.05), rays: false)
        drawClouds(in: &shot, at: 0.22, drift: 0.02 * progress)

        drawLand(in: &shot, ridge: 0.58, rise: 0.012, waves: 1.4, phase: 1.6, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.61, at: [0.13, 0.21, 0.89], height: 0.14, seed: 863, haze: 0.25)
        drawLand(in: &shot, ridge: 0.66, rise: 0.010, waves: 1.2, phase: 0.9, color: colors.ground)
        drawMirebogChannel(in: &shot, along: 0.72, from: -0.10, to: 1.10, thickness: 0.038, seed: 877)
        drawMirebogHags(in: &shot, along: 0.78, count: 4, spread: 0.24, seed: 881)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.42), y: y(0.80)),
            width: x(0.17),
            lean: -7
        )

        // The mist laid over his feet after he is stood in it: the fen's weather comes up off
        // the water, so it goes in front of whatever is standing in the water.
        drawMirebogMist(in: &shot, at: 0.79, depth: 0.05, seed: 883)
        drawMirebogReeds(
            in: &shot, along: 0.900, from: -0.05, to: 1.05,
            count: 12, height: 0.070, sway: 0.10 * progress, seed: 887
        )
        drawMirebogWisps(in: &shot, count: 6, seed: 907)
        drawLand(in: &shot, ridge: 0.884, rise: 0.010, waves: 1.0, phase: 2.3, color: colors.foreground)
    }

    /// What he is looking at: a spire standing out of a floor of cloud a long way above the
    /// mist, with something circling it, and the pig small at the bottom of the frame in the
    /// wettest ground in the game.
    ///
    /// The card that hands the world on, so the middle of the frame is left to the line and the
    /// picture is put in the two ends of it — the heights up top where they belong and the fen
    /// along the bottom where it has been all along, with nothing between them but air. It is
    /// the only shot in the film with a proper distance in it, and the distance is straight up.
    func drawOnlyOneDirection(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.66))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.12)), radius: x(0.045), rays: false)

        // The next listing, and the floor of weather it stands on. The floor is drawn after the
        // spire and along the same line its feet are on, because three clouds hung near a
        // mountain leave its bottom edge in plain sight and a shape with a visible flat bottom
        // is a sticker — the spire has to go into the cloud rather than stand in front of it.
        //
        // Short and broad rather than tall and thin, and its summit well down from the top edge.
        // Drawn to y(0.10) it went off the top of the frame under the camera push and read as a
        // searchlight beam standing in the cloud: a mountain with no summit in the picture is not
        // a mountain, and the turf on the top of it is the whole reason this one is being looked
        // at. It sits left of centre so the Skip button is not on its shoulder.
        drawMirebogSpire(in: &shot, at: 0.58, base: 0.30, height: 0.145, width: 0.30, haze: 0.30)
        drawMirebogCloudFloor(in: &shot, at: 0.302, drift: -0.02 * progress, seed: 941)

        // The resident up there, circling, and not on the ground because there is none.
        drawAnimal(
            in: &shot,
            .eagle,
            feet: CGPoint(x: x(0.29 + 0.05 * progress), y: y(0.225 - 0.01 * sin(progress * 2 * .pi))),
            width: x(0.07),
            lean: -6,
            shadow: 0
        )

        drawLand(in: &shot, ridge: 0.66, rise: 0.010, waves: 1.4, phase: 1.9, color: colors.farHill)
        drawMirebogSnags(in: &shot, base: 0.68, at: [0.08, 0.92], height: 0.08, seed: 911, haze: 0.4)
        drawLand(in: &shot, ridge: 0.70, rise: 0.008, waves: 1.2, phase: 0.4, color: colors.ground)
        drawMirebogMist(in: &shot, at: 0.74, depth: 0.05, seed: 919)
        drawMirebogChannel(in: &shot, along: 0.785, from: -0.10, to: 1.10, thickness: 0.030, seed: 929)

        // Small, low, and with his chin up: the whole journey in one silhouette, and the last of
        // the fen anybody sees.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.44), y: y(0.82)),
            width: x(0.13),
            lean: -7,
            shadow: 0.5
        )
        drawMirebogReeds(
            in: &shot, along: 0.905, from: -0.05, to: 1.05,
            count: 12, height: 0.065, sway: 0.10 * progress, seed: 937
        )
        drawLand(in: &shot, ridge: 0.888, rise: 0.010, waves: 1.0, phase: 2.7, color: colors.foreground)
    }

    // MARK: - What the fen is made of

    /// Peat water: near enough black, because the bottom of a channel is a metre of rotted
    /// vegetation rather than sand.
    ///
    /// The night value is not the day value taken down again, which was the first thing tried and
    /// which turned the held shot's channel into a hole cut in the middle of a gold pen. Water at
    /// night is dark but it is still water; it wants to sit a shade above the black it would
    /// otherwise be, so the sky it carries has something to sit on.
    var mirebogPeat: Color {
        colors.isNight
            ? Color(red: 0.08, green: 0.13, blue: 0.12)
            : Color(red: 0.11, green: 0.17, blue: 0.13)
    }

    /// Dead standing timber with the bark gone off it, which is the palest thing in this world
    /// by a distance and the only thing here that reads as a vertical.
    var mirebogSilver: Color {
        colors.isNight
            ? Color(red: 0.30, green: 0.34, blue: 0.31)
            : Color(red: 0.60, green: 0.61, blue: 0.54)
    }

    /// The ground a channel takes up, as a shape: a band across the frame with a different wave
    /// on each of its two banks.
    ///
    /// The two edges are given different wavelengths on purpose, so that the far bank and the
    /// near bank disagree slightly about where the water is and it reads as something that found
    /// its own way across flat ground rather than as a ruled band. Slightly is the whole of it:
    /// the first cut of this gave the two banks a quarter of the channel's depth to wave through
    /// and the result was an hourglass — the sides pinched in the middle and swelled at the
    /// ends, which is a bow tie and not a waterway. A tenth is plenty.
    ///
    /// It is handed back as a path rather than only drawn, because the briefing needs to fill
    /// the same shape a second time to lay the croc's claim along it.
    func mirebogChannelPath(along baseline: Double, from: Double, to: Double, thickness: Double) -> Path {
        let start = x(from)
        let end = x(to)
        let across = max(size.width, 1)
        let deep = y(thickness)
        let level = y(baseline)
        // How far from each end the water takes to close. Short in absolute terms rather than a
        // share of the length, so a channel that runs off both sides of the frame does all its
        // closing outside it and one that stops inside the frame — the croc's — closes over the
        // last tenth of the width and comes to a point instead of a sawn end.
        let hem = min(x(0.10), max(end - start, 1) * 0.33)

        func taper(_ at: CGFloat) -> CGFloat {
            let closing = min(at - start, end - at) / hem
            let amount = min(max(closing, 0), 1)
            return amount * amount * (3 - 2 * amount)
        }
        let far = { (at: CGFloat) -> CGFloat in
            let hold = taper(at)
            return level - deep * 0.5 * hold
                - deep * 0.10 * hold * CGFloat(sin(Double(at / across) * 2.4 * .pi + 0.7))
        }
        let near = { (at: CGFloat) -> CGFloat in
            let hold = taper(at)
            return level + deep * 0.5 * hold
                + deep * 0.12 * hold * CGFloat(sin(Double(at / across) * 1.7 * .pi + 2.1))
        }

        var path = Path()
        path.move(to: CGPoint(x: start, y: far(start)))
        var along = start
        while along < end {
            path.addLine(to: CGPoint(x: along, y: far(along)))
            along += 8
        }
        path.addLine(to: CGPoint(x: end, y: far(end)))
        path.addLine(to: CGPoint(x: end, y: near(end)))
        along = end
        while along > start {
            path.addLine(to: CGPoint(x: along, y: near(along)))
            along -= 8
        }
        path.addLine(to: CGPoint(x: start, y: near(start)))
        path.closeSubpath()
        return path
    }

    /// Standing water: dark peat with the sky caught along its far bank and a glint or two lying
    /// on that.
    ///
    /// The sky is laid on as this shot's own `skyHorizon`, which is what keeps a channel in the
    /// same weather as everything above it. How much of it, and where, is the whole difference
    /// between water and a stripe of paint. A third of the sky spread over the entire band —
    /// which is what this did at first — lifts peat to within a shade of the fen's own grass and
    /// leaves a picture of dry ground with grey mats lying on it; the glints then become the only
    /// thing with any contrast in the frame and read as spilt milk. So the sky now covers the far
    /// half only and stops well short of the near bank, the near bank stays as dark as the water
    /// under it, and the glints are faint enough to be a sheen on something rather than a shape
    /// on top of it.
    func drawMirebogChannel(
        in context: inout GraphicsContext,
        along baseline: Double,
        from: Double,
        to: Double,
        thickness: Double,
        seed: UInt64
    ) {
        let water = mirebogChannelPath(along: baseline, from: from, to: to, thickness: thickness)
        context.fill(water, with: .color(mirebogPeat))

        context.fill(
            water,
            with: .linearGradient(
                Gradient(colors: [
                    colors.skyHorizon.opacity(colors.isNight ? 0.16 : 0.20),
                    colors.skyHorizon.opacity(0)
                ]),
                startPoint: CGPoint(x: 0, y: y(baseline - thickness * 0.5)),
                endPoint: CGPoint(x: 0, y: y(baseline + thickness * 0.10))
            )
        )

        // Everything from here down is on the water and nowhere else, so it is drawn through the
        // water's own shape. A glint that strays past a bank — off the end of one of these, where
        // the channel has closed to a hairline — is a pale blob lying on peat, which is the one
        // thing a wet world must never put on dry ground.
        var sheen = context
        sheen.clip(to: water)

        var scatter = Scatter(seed: seed)
        var glints = Path()
        for _ in 0..<4 {
            let centre = CGPoint(
                x: x(scatter.next(in: from...to)),
                y: y(baseline - thickness * 0.16 + (scatter.next() - 0.5) * thickness * 0.28)
            )
            let wide = x(0.04 + scatter.next() * 0.10)
            glints.addEllipse(in: CGRect(
                x: centre.x - wide / 2, y: centre.y - y(thickness) * 0.03,
                width: wide, height: y(thickness) * 0.06
            ))
        }
        sheen.fill(glints, with: .color(GamePalette.cream.opacity(colors.isNight ? 0.07 : 0.11)))

        // The wet lip along the near bank, where the water gives out and the peat starts. It is
        // half a line rather than a stroke round the whole shape, because the far bank of a
        // channel is somebody else's problem and is never lit.
        var lip = Path()
        lip.move(to: CGPoint(x: x(from), y: y(baseline) + y(thickness) * 0.50))
        lip.addLine(to: CGPoint(x: x(to), y: y(baseline) + y(thickness) * 0.50))
        sheen.stroke(
            lip,
            with: .color(GamePalette.cream.opacity(colors.isNight ? 0.04 : 0.07)),
            style: StrokeStyle(lineWidth: max(1, y(thickness) * 0.08), lineCap: .round)
        )
    }

    /// A reed bed along a line across the frame: straight stems in clumps of four with a seed
    /// head apiece, all leaning the one way.
    ///
    /// The thicket got tufts of grass along the foot of its bands; a fen gets these instead, and
    /// they are taller than anything else growing in the game because a reed is a blade of grass
    /// that found water and never had to stop. `sway` is the shot's own breeze, passed in rather
    /// than taken from `progress` here, so a bed in the distance can be stiller than a bed at
    /// the front of the same frame.
    func drawMirebogReeds(
        in context: inout GraphicsContext,
        along baseline: Double,
        from: Double,
        to: Double,
        count: Int,
        height: Double,
        sway: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        var stems = Path()
        var heads = Path()
        let tall = y(height)

        for index in 0..<count {
            let foot = CGPoint(
                x: x(from + (to - from) * (Double(index) + 0.15 + scatter.next() * 0.7) / Double(count)),
                y: y(baseline + (scatter.next() - 0.5) * 0.012)
            )

            for lean in [-0.34, -0.06, 0.20, 0.48] {
                let stalk = tall * CGFloat(0.55 + scatter.next() * 0.6)
                let tip = CGPoint(
                    x: foot.x + stalk * CGFloat(lean) * 0.34 + stalk * CGFloat(sway),
                    y: foot.y - stalk
                )
                stems.move(to: foot)
                stems.addQuadCurve(
                    to: tip,
                    control: CGPoint(x: foot.x + stalk * CGFloat(lean) * 0.12, y: foot.y - stalk * 0.55)
                )
                let head = stalk * 0.07
                heads.addEllipse(in: CGRect(
                    x: tip.x - head / 2, y: tip.y - head * 2.1,
                    width: head, height: head * 2.3
                ))
            }
        }

        context.stroke(
            stems,
            with: .color(colors.blade),
            style: StrokeStyle(lineWidth: max(1, tall * 0.05), lineCap: .round)
        )
        context.fill(
            heads,
            with: .color(
                Color(red: 0.48, green: 0.38, blue: 0.24).opacity(colors.isNight ? 0.55 : 0.9)
            )
        )
    }

    /// Dead trees the bog got the roots of: a bent trunk apiece, two bare arms and no leaf on
    /// either, silvered where the bark has gone.
    ///
    /// They are the fen's forest, and they are drawn as strokes rather than as filled shapes
    /// because there is nothing left of one of these to fill — a rank of them is a handful of
    /// pale scratches standing up out of a flat world, which is exactly what it looks like from
    /// a mile off. `haze` restrokes the same lines in the sky's own colour, which is how a snag
    /// is put a long way back: distance here is a colour before it is a size, and a fen offers
    /// no other way of saying it.
    func drawMirebogSnags(
        in context: inout GraphicsContext,
        base: Double,
        at columns: [Double],
        height: Double,
        seed: UInt64,
        haze: Double = 0
    ) {
        var scatter = Scatter(seed: seed)

        for column in columns {
            let foot = CGPoint(x: x(column), y: y(base + scatter.next() * 0.010))
            let tall = y(height) * CGFloat(0.72 + scatter.next() * 0.55)
            let thick = max(1.3, tall * 0.038)
            let sideways = tall * CGFloat(scatter.next() - 0.5) * 0.26

            var trunk = Path()
            trunk.move(to: foot)
            trunk.addQuadCurve(
                to: CGPoint(x: foot.x + sideways, y: foot.y - tall),
                control: CGPoint(x: foot.x - sideways * 0.5, y: foot.y - tall * 0.55)
            )

            var arms = Path()
            arms.move(to: CGPoint(x: foot.x + sideways * 0.22, y: foot.y - tall * 0.52))
            arms.addLine(to: CGPoint(x: foot.x - tall * 0.30, y: foot.y - tall * 0.78))
            arms.move(to: CGPoint(x: foot.x + sideways * 0.48, y: foot.y - tall * 0.70))
            arms.addLine(to: CGPoint(x: foot.x + tall * 0.33, y: foot.y - tall * 0.95))

            context.stroke(
                trunk,
                with: .color(mirebogSilver),
                style: StrokeStyle(lineWidth: thick, lineCap: .round)
            )
            context.stroke(
                arms,
                with: .color(mirebogSilver.opacity(0.85)),
                style: StrokeStyle(lineWidth: thick * 0.55, lineCap: .round)
            )

            guard haze > 0 else { continue }
            context.stroke(
                trunk,
                with: .color(colors.skyHorizon.opacity(haze)),
                style: StrokeStyle(lineWidth: thick, lineCap: .round)
            )
            context.stroke(
                arms,
                with: .color(colors.skyHorizon.opacity(haze)),
                style: StrokeStyle(lineWidth: thick * 0.55, lineCap: .round)
            )
        }
    }

    /// Hags of drier peat lying about a band of ground: flat pale blotches, and the nearest
    /// thing this world has to a hill.
    ///
    /// They do the job the thicket's leaf mould does — they stop a band of ground being a flat
    /// area of one colour — and they do a second job besides, which is to say which parts of a
    /// fen an animal could actually stand on. A pig drawn on bare ground here is a pig standing
    /// in water; a pig drawn on one of these is a pig who found the dry bit.
    func drawMirebogHags(
        in context: inout GraphicsContext,
        along baseline: Double,
        count: Int,
        spread: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let centre = CGPoint(
                x: x(scatter.next(in: -0.05...1.05)),
                y: y(baseline + (scatter.next() - 0.5) * 0.04)
            )
            let wide = x(spread) * CGFloat(0.6 + scatter.next() * 0.8)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centre.x - wide / 2, y: centre.y - wide * 0.09,
                    width: wide, height: wide * 0.18
                )),
                with: .color(
                    Color(red: 0.42, green: 0.40, blue: 0.24).opacity(colors.isNight ? 0.14 : 0.24)
                )
            )
        }
    }

    /// The air of this world: banks of mist lying low across the frame, thickest where the water
    /// is and fading out to nothing at every edge.
    ///
    /// The meadow's `drawMist` lays flat cream ellipses at a fixed opacity, which works over pale
    /// grass and does not work here. On peat this dark, an ellipse with an edge to it stops being
    /// haze and starts being a puddle of milk lying on the ground — the same fault the thicket
    /// found over its own dark leaf mould — and this world has real standing water in the same
    /// shots for it to be confused with. So every bank here is a circle of falling opacity drawn
    /// in a squashed context: the fade is radial, which means there is no edge anywhere on it in
    /// any direction, and `depth` rather than a fixed height says how deep the air is at this
    /// point in the frame. Overlapping seven of them is what makes a band of weather; any one of
    /// them alone is nothing at all, which is the point.
    func drawMirebogMist(in context: inout GraphicsContext, at height: Double, depth: Double, seed: UInt64) {
        var scatter = Scatter(seed: seed)
        let lift = colors.isNight ? 0.13 : 0.11

        for _ in 0..<7 {
            let wide = x(0.55 + scatter.next() * 0.75)
            let centre = CGPoint(
                x: x(scatter.next() * 1.6 - 0.3),
                y: y(height + (scatter.next() - 0.5) * depth)
            )
            let tall = y(depth) * CGFloat(0.55 + scatter.next() * 0.7)

            var bank = context
            bank.translateBy(x: centre.x, y: centre.y)
            bank.scaleBy(x: 1, y: tall / wide)
            bank.fill(
                circle(at: .zero, radius: wide / 2),
                with: .radialGradient(
                    Gradient(colors: [
                        GamePalette.cream.opacity(lift),
                        GamePalette.cream.opacity(lift * 0.55),
                        GamePalette.cream.opacity(0)
                    ]),
                    center: .zero,
                    startRadius: 0,
                    endRadius: wide / 2
                )
            )
        }
    }

    /// A floor of cloud running the whole way across, for the one shot that looks at the next
    /// world: the sea of weather the heights stand on, seen from underneath everything.
    ///
    /// It is a rank of overlapping puffs rather than the three clouds the sky brushes hang in a
    /// blue, because what it has to do is bury the foot of a spire along its whole width. A
    /// mountain with three clouds parked near it is a mountain with a flat bottom edge and some
    /// clouds; a mountain going into a floor has no bottom edge at all. Two ranks, the far one
    /// higher and thinner, so the floor has a depth to it and not merely a line.
    ///
    /// It is painted in cream rather than in this world's `cloud`, which after dark is within a
    /// shade of this world's sky and would have buried nothing. The weather up there is in
    /// sunlight while the fen is in the dark — that is most of what the shot is about — so the
    /// floor is the one bright thing in the frame, and the spire's feet go into something the
    /// eye can see them going into.
    func drawMirebogCloudFloor(in context: inout GraphicsContext, at height: Double, drift: Double, seed: UInt64) {
        for rank in [1.0, 0.0] {
            var scatter = Scatter(seed: seed &+ UInt64(rank * 17))
            let level = y(height - 0.012 * rank)
            let shift = x(drift) * CGFloat(rank > 0 ? 0.45 : 1)
            let step = x(0.12)
            var across = x(-0.2)

            while across < x(1.2) {
                let puff = step * CGFloat(1.5 + scatter.next() * 1.3)
                context.fill(
                    cloudPath(
                        at: CGPoint(x: across + shift, y: level + y(0.008) * CGFloat(scatter.next() - 0.5)),
                        width: puff
                    ),
                    with: .color(
                        GamePalette.cream.opacity(
                            rank > 0
                                ? (colors.isNight ? 0.30 : 0.55)
                                : (colors.isNight ? 0.52 : 0.90)
                        )
                    )
                )
                across += step
            }
        }
    }

    /// The lights the bog makes for itself, low down in the reeds where the gas comes up.
    ///
    /// The thicket gets fireflies after dark and the fen gets these, for the same reason and to
    /// a different rhythm: a firefly blinks and a marsh light does not, it swims. So they are
    /// slower, colder, greener and never quite out, and they are kept in the bottom third of the
    /// frame because a wisp up in the sky is a star and this world has no stars worth the name.
    func drawMirebogWisps(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let home = CGPoint(
                x: x(scatter.next(in: 0.05...0.95)),
                y: y(scatter.next(in: 0.58...0.84))
            )
            let phase = scatter.next() * 2 * .pi
            let swim = moves ? sin(progress * 2 * .pi * 0.6 + phase) : 0
            let glow = 0.45 + 0.55 * (moves ? (sin(progress * 2 * .pi + phase) + 1) / 2 : 0.7)
            let spot = CGPoint(
                x: home.x + x(0.020) * CGFloat(swim),
                y: home.y - y(0.006) * CGFloat(swim)
            )

            context.fill(
                circle(at: spot, radius: x(0.020)),
                with: .radialGradient(
                    Gradient(colors: [
                        colors.discHalo.opacity(0.34 * glow),
                        colors.discHalo.opacity(0)
                    ]),
                    center: spot,
                    startRadius: 0,
                    endRadius: x(0.020)
                )
            )
            context.fill(
                circle(at: spot, radius: x(0.0035)),
                with: .color(GamePalette.cream.opacity(0.7 * glow))
            )
        }
    }

    /// The next world, seen from the bottom of this one: a spire of rock standing out of a floor
    /// of cloud, with turf on the top of it where the fen has water.
    ///
    /// Two faces meeting on a ridge that comes down off the crown, the same way the thicket's
    /// volcano is built and for the same reason — one flat shape with a wash over half of it
    /// reads as a paper cut-out however carefully the wash is done, and it is the fold that says
    /// rock. The sides are curved and the foot is wider than the head, because the thing has
    /// been stood in weather since before anybody was looking. `haze` lays the sky back over the
    /// finished thing; the cloud its feet go into is the caller's business, and is what actually
    /// puts it above the world rather than at the end of it.
    func drawMirebogSpire(
        in context: inout GraphicsContext,
        at across: Double,
        base: Double,
        height: Double,
        width: Double,
        haze: Double
    ) {
        let foot = y(base)
        let tall = y(height)
        let span = x(width)
        let centre = x(across)
        let tip = CGPoint(x: centre, y: foot - tall)
        let crown = span * 0.17
        let hip = centre + span * 0.10
        let lit = Color(red: 0.34, green: 0.34, blue: 0.38)
        let shade = Color(red: 0.19, green: 0.19, blue: 0.23)

        var near = Path()
        near.move(to: CGPoint(x: centre - span / 2, y: foot))
        near.addQuadCurve(
            to: CGPoint(x: tip.x - crown, y: tip.y),
            control: CGPoint(x: centre - span * 0.42, y: foot - tall * 0.55)
        )
        near.addLine(to: CGPoint(x: tip.x, y: tip.y))
        near.addLine(to: CGPoint(x: hip, y: foot))
        near.closeSubpath()
        context.fill(near, with: .color(lit))

        var far = Path()
        far.move(to: CGPoint(x: hip, y: foot))
        far.addLine(to: CGPoint(x: tip.x, y: tip.y))
        far.addLine(to: CGPoint(x: tip.x + crown, y: tip.y))
        far.addQuadCurve(
            to: CGPoint(x: centre + span / 2, y: foot),
            control: CGPoint(x: centre + span * 0.42, y: foot - tall * 0.55)
        )
        far.closeSubpath()
        context.fill(far, with: .color(shade))

        // The turf on top, hanging a little over the edge on both sides: the whole promise of
        // the last world in the game is that there is grass up there.
        context.fill(
            Path(ellipseIn: CGRect(
                x: tip.x - crown * 1.5, y: tip.y - crown * 0.42,
                width: crown * 3, height: crown * 0.84
            )),
            with: .color(colors.canopy.opacity(0.9))
        )

        guard haze > 0 else { return }
        var whole = Path()
        whole.addPath(near)
        whole.addPath(far)
        context.fill(whole, with: .color(colors.skyHorizon.opacity(haze)))
    }
}
