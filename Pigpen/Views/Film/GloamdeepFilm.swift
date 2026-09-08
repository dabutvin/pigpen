import Foundation
import SwiftUI
import UIKit

// MARK: - Gloamdeep Caverns, painted

/// The caverns' nine shots, and the ten brushes a world with a lid on it needs.
///
/// Every other world in the game is a floor with weather over it. This one is a floor with a
/// roof over it, and that single swap is the whole look: `drawSky` still paints the space above
/// the horizon, but nothing hangs in that space except rock, so the top of every frame is a rank
/// of stalactites rather than cloud. Think of the thicket's canopy done in stone — same job,
/// same feet-first order of drawing, pointed instead of lobed, because a cave roof that curves
/// is a hedge and a hedge underground is nonsense.
///
/// The other swap is where the light comes from. The meadow has a sun, the thicket has a sun it
/// cannot quite see, and Gloamdeep has crystals: the palette's `disc` and `discHalo` are a
/// mineral cyan rather than a warm gold, and every pool of light in these nine shots is
/// something in the picture glowing rather than something outside it shining in. That makes the
/// dark negotiable — a shot can be nearly black as long as the thing the caption is about has a
/// crystal near it — and it makes the send-off land, because the first warm light in the world
/// arrives through a hole in the wall with a fairground behind it.
///
/// Two rules from the thicket carry over unchanged, since they are rules about pictures rather
/// than about trees. Anything with a flat bottom edge gets ground drawn over its feet, or it
/// reads as a sticker. And nothing that matters goes where the words go: the foot of the frame
/// on a shot with a subtitle, the middle band of it on the three that hand the film over on a
/// card.
extension Film {
    /// The caverns' two films by day are lit by whatever crystal happens to be nearest, and the
    /// send-off drops to the dusk palette, where the far walls go altogether and only the
    /// crystals are left. Down here "day" and "dusk" are a fiction the rest of the game keeps
    /// up, which is a joke the palettes were already making before these shots existed.
    static func gloamdeepLight(_ shot: CutScene.Picture.Gloamdeep) -> GamePalette.Pasture {
        switch shot {
        case .cavernsHeld, .betterLighting, .muchBetterLighting: .gloamDusk
        default: .gloamDay
        }
    }

    func drawGloamdeep(_ shot: CutScene.Picture.Gloamdeep, in context: inout GraphicsContext) {
        switch shot {
        case .theWayDown: drawTheWayDown(in: &context)
        case .mineralRights: drawMineralRights(in: &context)
        case .limitedNaturalLight: drawLimitedNaturalLight(in: &context)
        case .alreadyOccupied: drawAlreadyOccupied(in: &context)
        case .happyToShare: drawHappyToShare(in: &context)
        case .noRoommates: drawNoRoommates(in: &context)
        case .cavernsHeld: drawCavernsHeld(in: &context)
        case .betterLighting: drawBetterLighting(in: &context)
        case .muchBetterLighting: drawMuchBetterLighting(in: &context)
        }
    }

    // MARK: - The caverns' opening

    /// The chamber at the bottom of the way down: flowstone stepping away in ribs, a seam of
    /// crystal burning on the far wall, columns cut off by both edges of the frame, and the pig
    /// small in the middle of the floor. The camera pushes in, which is the shot agreeing to go
    /// down there.
    ///
    /// The far wall does the work a horizon does everywhere else in the game — it is what stops
    /// the eye — and it is deliberately close, because the sell is solid construction and a room
    /// you can see the end of is the only way to draw that.
    func drawTheWayDown(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.05 * progress)

        drawSky(in: &shot, horizon: y(0.50))
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.63), y: y(0.38)), height: y(0.08), glow: 1)

        drawLand(in: &shot, ridge: 0.50, rise: 0.05, waves: 1.9, phase: 1.4, color: colors.farHill)
        // Two banks of stalagmites, the far one lighter, the near one over it, and the floor
        // laid over the feet of both. A bank of points has the same dead flat bottom edge a
        // rank of tree crowns has, and the same cure.
        drawGloamdeepStalagmites(in: &shot, base: 0.58, from: -0.10, to: 1.10, height: 0.15, seed: 1_601, color: colors.canopy)
        drawGloamdeepStalagmites(in: &shot, base: 0.66, from: -0.10, to: 1.10, height: 0.22, seed: 1_607, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.62, rise: 0.026, waves: 1.4, phase: 0.7, color: colors.ground)

        drawGloamdeepLedges(in: &shot, from: 0.86, to: 0.64, count: 5, seed: 1_609)

        // On the floor and starting across it, small against the room: the property is the size
        // of the picture, and the buyer is not.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.42), y: y(0.80 - 0.02 * along)),
            width: x(0.16 - 0.015 * along),
            squash: 1 - 0.04 * hop(cycles: 2.5)
        )

        drawGloamdeepCrystals(in: &shot, along: 0.83, count: 5, scale: 1, seed: 1_613)
        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 2.4, color: colors.foreground)
        drawGloamdeepColumns(in: &shot, base: 1.02, at: [0.05, 0.96], width: 0.085, seed: 1_619)
        drawGloamdeepRoof(in: &shot, depth: 0.19, seed: 1_621, drift: 0.008 * progress)
        drawGloamdeepMotes(in: &shot, count: 9, seed: 1_627)
    }

    /// The two halves of the scoring rule, one after the other in the same seam: the diamond
    /// while the line is selling the mineral rights, and then the boulder while it is admitting
    /// what a boulder does to a floor plan.
    ///
    /// The meadow says this in a single picture, a pen with an apple shut in it and a skull
    /// staked outside, because the meadow is teaching the rule and the fence is half of what it
    /// is teaching. Six worlds on nobody is being taught anything, so the fence comes out and the
    /// shot changes hands instead, crossing exactly where the caption changes sentence.
    ///
    /// It also gets to make the swap with the light, which no other world can. The diamond is
    /// lit because a diamond down here is genuinely a lamp; the boulder is the same rock with
    /// nothing in it, so when the sentence turns, the glow goes out and the seam keeps only
    /// what the walls were giving it.
    func drawMineralRights(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        // Where the line turns from the asset to the obstacle: the first sentence has faded out
        // and the second is coming up, so the picture may change hands under cover of it.
        //
        // The thicket crosses at 0.46, which is a shade before the middle of the shot — and the
        // middle of the shot is exactly where this film is stopped for a still, and where every
        // shot is frozen for a player who has asked for less motion. Crossing there leaves the
        // held frame seven parts boulder to three parts diamond: two treats ghosted over each
        // other with the drawback winning, on the line that is selling the mineral rights. So
        // this one crosses just after the halfway mark instead. The still gets the diamond
        // alone and fully lit, and the boulder still arrives inside its own sentence.
        let turn = easeOut(min(max((progress - 0.52) / 0.10, 0), 1))

        drawSky(in: &shot, horizon: y(0.42))
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.82), y: y(0.36)), height: y(0.07), glow: 0.8)

        drawLand(in: &shot, ridge: 0.42, rise: 0.05, waves: 2.0, phase: 1.3, color: colors.farHill)
        drawGloamdeepStalagmites(in: &shot, base: 0.60, from: -0.10, to: 1.10, height: 0.18, seed: 1_637, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, color: colors.ground)
        drawGloamdeepLedges(in: &shot, from: 0.88, to: 0.58, count: 5, seed: 1_657)

        // The pig leans in at what is being sold and back from what is being admitted, which is
        // the only opinion the shot has to offer.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.26), y: y(0.80)),
            width: x(0.19),
            lean: 6 - 12 * turn
        )

        let seam = CGPoint(x: x(0.62), y: y(0.78))

        // The asset, lit by itself, with its own kind coming up out of the rock round it.
        var asset = shot
        asset.opacity = 1 - turn
        drawGloamdeepGlow(
            in: &asset,
            at: CGPoint(x: seam.x, y: seam.y - x(0.11)),
            radius: x(0.22),
            strength: 1
        )
        drawTreat(in: &asset, "💎", at: seam, width: x(0.22))
        drawGloamdeepCrystals(in: &asset, along: 0.79, count: 4, scale: 1.3, seed: 1_663)

        // And the obstacle, in the same spot with the light off it. Nothing under a boulder ever
        // glows, which is the entire objection to boulders.
        var obstacle = shot
        obstacle.opacity = turn
        drawTreat(in: &obstacle, "🪨", at: seam, width: x(0.22))

        drawLand(in: &shot, ridge: 0.90, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
        drawGloamdeepRoof(in: &shot, depth: 0.15, seed: 1_667, drift: 0.006 * progress)
        drawGloamdeepMotes(in: &shot, count: 7, seed: 1_669)
    }

    /// One thread of daylight coming down from a hole a very long way up, with the pig standing
    /// in the puddle it makes and the rest of the world black. The camera pulls back as it runs,
    /// so the dark gets bigger and the daylight does not.
    ///
    /// A card, so the middle band is the caption's and everything the picture is about is pushed
    /// to the bottom of it. That suits this one exactly: the whole gag is scale, and a pig
    /// standing at the very foot of an enormous empty frame is the gag drawn.
    func drawLimitedNaturalLight(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.16 - 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.30))
        drawLand(in: &shot, ridge: 0.30, rise: 0.04, waves: 2.1, phase: 1.6, color: colors.farHill)
        // Lower than the banks in the other shots. These stalagmites are solid where the old
        // spikes were thin, and this is a card: what stood harmlessly behind the caption as a
        // row of slivers would stand behind it as a wall.
        drawGloamdeepStalagmites(in: &shot, base: 0.74, from: -0.10, to: 1.10, height: 0.17, seed: 1_693, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.70, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)

        // The thread itself: struck from a hole off the top of the frame down to the floor,
        // narrow at the top and spreading barely at all, because the joke is how little of it
        // there is. Its own shape rather than a brush — no other shot in this world has any
        // daylight in it to reuse one with.
        let hole = CGPoint(x: x(0.52), y: -y(0.04))
        let pool = CGPoint(x: x(0.49), y: y(0.84))
        var thread = Path()
        thread.move(to: CGPoint(x: hole.x - x(0.012), y: hole.y))
        thread.addLine(to: CGPoint(x: hole.x + x(0.012), y: hole.y))
        thread.addLine(to: CGPoint(x: pool.x + x(0.055), y: pool.y))
        thread.addLine(to: CGPoint(x: pool.x - x(0.055), y: pool.y))
        thread.closeSubpath()
        shot.fill(
            thread,
            with: .linearGradient(
                Gradient(colors: [
                    GamePalette.cream.opacity(0.22),
                    GamePalette.cream.opacity(0.06)
                ]),
                startPoint: hole,
                endPoint: pool
            )
        )
        shot.fill(
            Path(ellipseIn: CGRect(
                x: pool.x - x(0.09), y: pool.y - y(0.014),
                width: x(0.18), height: y(0.028)
            )),
            with: .color(GamePalette.cream.opacity(0.16))
        )

        // Standing in the one lit spot in the world and looking pleased with it.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.49), y: y(0.84)),
            width: x(0.12),
            lean: -2,
            shadow: 0.6
        )

        drawGloamdeepCrystals(in: &shot, along: 0.79, count: 4, scale: 0.9, seed: 1_697)
        drawLand(in: &shot, ridge: 0.94, rise: 0.012, waves: 1.0, phase: 2.6, color: colors.foreground)
        // Deeper than any other roof in the film, and hung round the thread rather than over it:
        // the rock is what the shot is measuring the daylight against.
        drawGloamdeepRoof(in: &shot, depth: 0.24, seed: 1_699, drift: -0.006 * progress)
        drawGloamdeepMotes(in: &shot, count: 12, seed: 1_709)
    }

    // MARK: - The Roost

    /// The residents, found where residents down here are always found: overhead. Two bats on the
    /// teeth of the roof, the second unfolding as the shot runs so the count arrives on the word,
    /// and the pig on the floor beneath with his head back.
    ///
    /// Every other boss in the game walks in from the side of the frame. This one is already in
    /// it, and has been since the cut — which is the difference between a neighbour arriving and
    /// a property being occupied.
    func drawAlreadyOccupied(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.04 * progress, drift: -0.015 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.84), y: y(0.38)), height: y(0.07), glow: 0.9)
        drawLand(in: &shot, ridge: 0.44, rise: 0.05, waves: 2.0, phase: 1.4, color: colors.farHill)
        drawGloamdeepStalagmites(in: &shot, base: 0.62, from: -0.10, to: 1.10, height: 0.18, seed: 1_721, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.58, rise: 0.026, waves: 1.5, phase: 2.2, color: colors.ground)
        drawGloamdeepLedges(in: &shot, from: 0.88, to: 0.60, count: 4, seed: 1_723)

        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.30), y: y(0.82)),
            width: x(0.17),
            lean: 5
        )

        drawGloamdeepRoof(in: &shot, depth: 0.17, seed: 1_733, drift: 0.006 * progress)
        drawGloamdeepFang(in: &shot, at: 0.58, to: 0.30, width: 0.23)
        drawGloamdeepFang(in: &shot, at: 0.74, to: 0.24, width: 0.19)

        // One hanging from the cut, and one that turns out to have been hanging there all along:
        // the second bat fades up over the first half of the shot, so "twice" lands on a picture
        // that has just become true rather than on one that was true before the line started.
        let sway = sin(progress * 2 * .pi * 0.8)
        drawGloamdeepHang(in: &shot, .bat, from: 0.30, at: 0.58, width: x(0.13), sway: sway)
        drawGloamdeepHang(
            in: &shot,
            .pup,
            from: 0.24,
            at: 0.74,
            width: x(0.11),
            sway: -sway,
            opacity: easeOut(min(progress / 0.55, 1))
        )

        drawGloamdeepMotes(in: &shot, count: 8, seed: 1_741)
    }

    /// The pair of them on the two nearest teeth of a roof with hundreds, wing over wing and
    /// entirely comfortable, with the pig as far the other way as the frame allows and leaning
    /// further.
    ///
    /// The thicket's middle shot puts a trunk between the two of them because the boar and the
    /// pig have already agreed. Nothing is agreed here, so there is nothing between them: the
    /// composition is the disagreement, one crowded half and one empty one, and the empty half
    /// is the pig's opinion of roommates.
    func drawHappyToShare(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.46))
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.16), y: y(0.40)), height: y(0.06), glow: 0.75)
        drawLand(in: &shot, ridge: 0.46, rise: 0.05, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawGloamdeepStalagmites(in: &shot, base: 0.64, from: -0.10, to: 1.10, height: 0.17, seed: 1_747, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.60, rise: 0.024, waves: 1.4, phase: 0.9, color: colors.ground)
        drawGloamdeepLedges(in: &shot, from: 0.88, to: 0.62, count: 4, seed: 1_753)

        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.78), y: y(0.82)),
            width: x(0.19),
            lean: -7,
            squash: 1 + 0.015 * breath
        )

        drawGloamdeepRoof(in: &shot, depth: 0.14, seed: 1_759)
        // Two teeth out of a roof full of them, and they are the two nearest each other. Both are
        // off to the left rather than down the middle, because a shape hung dead centre is a
        // stripe and because the empty half of the frame is doing as much of the arguing as the
        // crowded half.
        drawGloamdeepFang(in: &shot, at: 0.30, to: 0.33, width: 0.23)
        drawGloamdeepFang(in: &shot, at: 0.41, to: 0.29, width: 0.20)
        drawGloamdeepCrystals(in: &shot, along: 0.84, count: 3, scale: 0.9, seed: 1_777)

        // Close enough that the glyphs overlap, which is the entire argument: there is a whole
        // cavern going spare and they have chosen to hang wing over wing in the corner of it.
        drawGloamdeepHang(in: &shot, .bat, from: 0.33, at: 0.30, width: x(0.15), sway: 0.4 * breath)
        drawGloamdeepHang(in: &shot, .pup, from: 0.29, at: 0.41, width: x(0.13), sway: 0.4 * breath)

        drawGloamdeepMotes(in: &shot, count: 7, seed: 1_783)
    }

    /// The rule, drawn: a pen round the pig on the floor and a pen round both bats on the ledge
    /// above him, opening together and never coming near each other.
    ///
    /// This is the first briefing card in the game with three bodies in it, and the only thing it
    /// has to get across is which grouping is which. So the two pens are drawn as different
    /// shapes on different levels — one wide and low and containing one animal, one small and
    /// high and containing two — and the bats are touching inside theirs, because a pair drawn
    /// with a gap between them is two animals that happen to be near each other and a pair drawn
    /// overlapping is a roost.
    func drawNoRoommates(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.24))
        drawLand(in: &shot, ridge: 0.24, rise: 0.035, waves: 2.0, phase: 1.1, color: colors.farHill)

        // The upper gallery, which is the roost's floor and the ceiling of nothing in particular,
        // with the lamp that lights it standing on it rather than hidden behind it.
        drawGloamdeepStalagmites(in: &shot, base: 0.36, from: -0.10, to: 1.10, height: 0.09, seed: 1_787, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.33, rise: 0.014, waves: 1.6, phase: 2.4, color: colors.ground)
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.14), y: y(0.33)), height: y(0.045), glow: 0.7)

        // The wall between the two levels, and then the near floor over the foot of it. Nothing
        // else lives in this band: it is where the words go.
        drawLand(in: &shot, ridge: 0.72, rise: 0.018, waves: 1.2, phase: 0.5, color: colors.foreground)

        let roost = CGPoint(x: x(0.68), y: y(0.33))
        let pig = CGPoint(x: x(0.36), y: y(0.86))

        // Shoulder to shoulder and overlapping on purpose, and the pup a size smaller so the two
        // of them are a pair rather than a mirror.
        drawAnimal(in: &shot, .bat, feet: CGPoint(x: roost.x - x(0.035), y: roost.y), width: x(0.115), lean: -4, shadow: 0.5)
        drawAnimal(in: &shot, .pup, feet: CGPoint(x: roost.x + x(0.045), y: roost.y), width: x(0.095), lean: 4, shadow: 0.5)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))

        // Both plans go up together, one round two and one round one, with the whole depth of the
        // chamber between them: no shared wall, and nowhere the two could be read as one run.
        let drawn = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: roost, width: 0.34, height: 0.09, drop: 0.012, opacity: 0.9 * drawn)
        drawGhostPen(in: &shot, round: pig, width: 0.46, height: 0.11, drop: 0.012, opacity: 0.9 * drawn)

        drawGloamdeepCrystals(in: &shot, along: 0.31, count: 3, scale: 0.7, seed: 1_789)
        // A shallow roof and no columns. A column at the edge of a card is a dark border rather
        // than a rock, and this shot is a diagram: two pens, a drop between them, and the line.
        drawGloamdeepRoof(in: &shot, depth: 0.09, seed: 1_801)
        drawGloamdeepMotes(in: &shot, count: 6, seed: 1_811)
    }

    // MARK: - The caverns held

    /// Two pens holding after the last puzzle: the roost's up on its ledge with the pair of them
    /// in it, the pig's across the front of the frame with diamonds lying about in the flowstone.
    /// Affordable, quiet, and — with the palette dropped to dusk and the far wall gone with it —
    /// extremely dark, which the picture is happy to be blamed for.
    func drawCavernsHeld(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawGloamdeepCrystal(in: &shot, at: CGPoint(x: x(0.20), y: y(0.32)), height: y(0.075), glow: 1)
        drawLand(in: &shot, ridge: 0.34, rise: 0.05, waves: 2.1, phase: 1.5, color: colors.farHill)
        drawGloamdeepStalagmites(in: &shot, base: 0.52, from: -0.10, to: 1.10, height: 0.14, seed: 1_823, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.48, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)

        // The neighbours, held and content, on their own shelf at the far end of the chamber.
        let roost = CGPoint(x: x(0.76), y: y(0.60))
        drawPenWash(in: &shot, round: roost, width: 0.32, height: 0.10, drop: 0.01)
        drawAnimal(in: &shot, .bat, feet: CGPoint(x: roost.x - x(0.03), y: roost.y), width: x(0.10), shadow: 0.5)
        drawAnimal(in: &shot, .pup, feet: CGPoint(x: roost.x + x(0.04), y: roost.y), width: x(0.085), shadow: 0.5)
        drawPenFence(in: &shot, round: roost, width: 0.32, height: 0.10, drop: 0.01)

        drawGloamdeepLedges(in: &shot, from: 0.90, to: 0.64, count: 4, seed: 1_831)

        // And the pig with the run of the floor, windfall diamonds and all.
        let pig = CGPoint(x: x(0.42), y: y(0.82))
        drawPenWash(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)
        drawTreat(in: &shot, "💎", at: CGPoint(x: x(0.17), y: y(0.78)), width: x(0.045))
        drawTreat(in: &shot, "💎", at: CGPoint(x: x(0.64), y: y(0.80)), width: x(0.045))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.68, height: 0.15, drop: 0.0)

        drawGloamdeepCrystals(in: &shot, along: 0.71, count: 4, scale: 0.8, seed: 1_847)
        drawGloamdeepRoof(in: &shot, depth: 0.15, seed: 1_861, drift: 0.006 * progress)
        drawGloamdeepMotes(in: &shot, count: 10, seed: 1_867)
    }

    /// A break in the far wall of the chamber with warm light coming through it, and the pig
    /// turned to look at that rather than at the caverns he has just finished buying.
    ///
    /// The thicket's send-off puts a mountain in a gap in the canopy; this one puts a fairground
    /// in a gap in the rock, and gets a free trick out of it that no other world has. Six worlds
    /// of cyan and one thread of daylight have gone by, so the first warm colour in Gloamdeep is
    /// doing the whole job of the caption before the caption is read.
    func drawBetterLighting(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.48))

        // Drawn first and the far country drawn over its feet, which is the only way a hole in a
        // wall reads as a hole a long way off rather than a lit shape stood in the room.
        drawGloamdeepCarnival(in: &shot, at: 0.60, base: 0.52, height: 0.20, width: 0.34, haze: 0.34)
        drawLand(in: &shot, ridge: 0.48, rise: 0.035, waves: 1.8, phase: 1.7, color: colors.farHill)

        // Stalagmites banked in either side of it, which is what makes the light a glimpse rather
        // than a view.
        drawGloamdeepStalagmites(in: &shot, base: 0.76, from: -0.12, to: 0.32, height: 0.34, seed: 1_871, color: colors.canopyShade)
        drawGloamdeepStalagmites(in: &shot, base: 0.76, from: 0.84, to: 1.12, height: 0.34, seed: 1_873, color: colors.canopyShade)

        drawLand(in: &shot, ridge: 0.70, rise: 0.03, waves: 1.4, phase: 0.9, color: colors.ground)
        drawGloamdeepLedges(in: &shot, from: 0.90, to: 0.72, count: 3, seed: 1_877)

        // Stood in his own chamber with his back half turned, looking at somebody else's.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.26), y: y(0.82)), width: x(0.17), lean: -3)

        drawGloamdeepCrystals(in: &shot, along: 0.84, count: 3, scale: 0.8, seed: 1_879)
        drawLand(in: &shot, ridge: 0.93, rise: 0.014, waves: 1.0, phase: 2.2, color: colors.foreground)
        drawGloamdeepRoof(in: &shot, depth: 0.13, seed: 1_889)
        drawGloamdeepMotes(in: &shot, count: 8, seed: 1_901)
    }

    /// The same break, near enough now to see what is behind it: a big top, a string of lanterns
    /// swinging over it, and more light out of one hole in the rock than this world has managed
    /// in nine shots. The pig is on the last ledge and walking at it.
    ///
    /// A card, so the mouth is set high and the pig low, and the band across the middle is left
    /// as the dark flank of the rock for the words to sit on. The light spills down over that
    /// flank rather than filling it, which keeps the line readable and is also, as it happens,
    /// what warm light does to wet stone.
    func drawMuchBetterLighting(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.38))
        drawLand(in: &shot, ridge: 0.44, rise: 0.035, waves: 1.9, phase: 1.2, color: colors.farHill)
        // High in the frame, and its light thrown down the rock rather than across it: the words
        // land on the flank, and the flank is only ever lit enough to say what is lighting it.
        drawGloamdeepCarnival(in: &shot, at: 0.54, base: 0.38, height: 0.30, width: 0.72, haze: 0)

        // The gallery it is seen from: a bank of stalagmites along the bottom of the frame rather
        // than a wall round it, because the world is nearly over and the camera is nearly out.
        drawGloamdeepStalagmites(in: &shot, base: 0.86, from: -0.10, to: 1.10, height: 0.15, seed: 1_907, color: colors.canopyShade)
        drawLand(in: &shot, ridge: 0.82, rise: 0.02, waves: 1.3, phase: 0.7, color: colors.ground)

        // Small, on the ledge, and going. The whole journey in one silhouette.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34 + 0.06 * along), y: y(0.87)),
            width: x(0.11),
            lean: 5,
            squash: 1 - 0.05 * hop(cycles: 2.5),
            shadow: 0.5
        )

        drawLand(in: &shot, ridge: 0.95, rise: 0.012, waves: 1.0, phase: 2.6, color: colors.foreground)
        // The last of the rock, and shallow: the roof is thinning out because the way is out.
        drawGloamdeepRoof(in: &shot, depth: 0.08, seed: 1_913)
    }

    // MARK: - What a cave is made of

    /// The roof: two ranks of stalactites hung off the top of the frame, the near one darker and
    /// reaching further down, with teeth that never repeat.
    ///
    /// It is the thicket's canopy with the leaves taken off. Same construction — a slab carried
    /// well outside the frame in every direction so no camera move finds a corner of it, and a
    /// broken hem hung along the bottom of the slab — but the hem is built out of cones drawn to
    /// a point, where the wood's is built out of ellipses. That one change is the difference
    /// between a hedge and a ceiling, and the thicket's own comment says as much: anything drawn
    /// to a point up there reads as icicles, which is exactly what is wanted here.
    ///
    /// The near rank carries a thin wet line down its edge, because a cave roof that is not
    /// dripping is a quarry.
    func drawGloamdeepRoof(in context: inout GraphicsContext, depth: Double, seed: UInt64, drift: Double = 0) {
        for rank in [1.0, 0.0] {
            var scatter = Scatter(seed: seed &+ UInt64(rank * 37))
            let reach = y(depth) * CGFloat(rank > 0 ? 0.62 : 1)
            let shift = x(drift) * CGFloat(rank > 0 ? 0.4 : 1)
            let hem = reach * 0.30
            let start = -size.width
            let end = size.width * 2
            // Every tooth is measured against its own width rather than against the frame. The
            // first cut of this brush took its drop from `reach` — a fraction of the screen
            // height — and its width from a fraction of the screen width, which on a phone is
            // two and a half times narrower: teeth came out seven and ten to one and read as
            // icicles. A stalactite is nearer three to one, so the drop is figured from the
            // width and only then clipped to the depth the shot asked for.
            let step = x(0.075)

            var rock = Path()
            rock.addRect(CGRect(
                x: start, y: -size.height,
                width: end - start, height: size.height + hem
            ))

            var across = start
            while across < end {
                let wide = step * CGFloat(0.95 + scatter.next() * 0.75)
                let drop = min(wide * CGFloat(1.1 + scatter.next() * 2.5), reach * 1.35)
                let shoulder = hem - reach * 0.12
                let tip = CGPoint(
                    x: across + shift + wide * CGFloat(scatter.next() - 0.5) * 0.4,
                    y: hem + drop
                )
                // A slight belly on each side, so a tooth is a cone that has been growing for
                // ten thousand years rather than a dart somebody has thrown at the ceiling.
                rock.move(to: CGPoint(x: across + shift - wide / 2, y: shoulder))
                rock.addQuadCurve(
                    to: tip,
                    control: CGPoint(x: across + shift - wide * 0.22, y: hem + drop * 0.45)
                )
                rock.addQuadCurve(
                    to: CGPoint(x: across + shift + wide / 2, y: shoulder),
                    control: CGPoint(x: across + shift + wide * 0.22, y: hem + drop * 0.45)
                )
                rock.closeSubpath()
                across += step
            }

            context.fill(rock, with: .color(rank > 0 ? colors.canopy : colors.canopyShade))
            if rank == 0 {
                context.stroke(
                    rock,
                    with: .color(GamePalette.cream.opacity(colors.isNight ? 0.05 : 0.10)),
                    lineWidth: max(0.6, y(0.0012))
                )
            }
        }
    }

    /// A bank of stalagmites standing up off the floor: blunt, bellied, overlapping, and never
    /// more than about half again as tall as they are wide.
    ///
    /// The first cut of this world borrowed `drawForest` for these, on the theory that a rank of
    /// pointed crowns is a rank of pointed crowns. The photographs said otherwise, in eight shots
    /// out of nine: evenly pitched cones of even width with the sides drawn *in* from the foot
    /// are a fir wood, and a fir wood at the back of a cave is the thicket at night. What tells
    /// a stalagmite from a fir is the profile and the spacing — the sides bulge outward as they
    /// come down, the top is blunt rather than sharp, the heights are wildly uneven, and they
    /// stand close enough to grow into one another rather than in a queue. All four are in here,
    /// and the aspect is clamped so no cone can ever be drawn out into a spike whatever height
    /// the shot asks for.
    func drawGloamdeepStalagmites(
        in context: inout GraphicsContext,
        base: Double,
        from: Double,
        to: Double,
        height: Double,
        seed: UInt64,
        color: Color
    ) {
        let end = x(to)

        for rank in [1.0, 0.0] {
            var scatter = Scatter(seed: seed &+ UInt64(rank * 43))
            let unit = y(height) * CGFloat(1 - 0.18 * rank)
            let foot = y(base) - y(height) * CGFloat(rank) * 0.16
            // The width a cone of this height ought to have. It tracks the bank's height rather
            // than the screen, so a tall framing bank is made of big rocks and a low one at the
            // back of a card is made of small ones — but both keep the same proportions.
            let span = max(x(0.030), unit * 0.17)

            var mass = Path()
            var across = x(from) - span * CGFloat(rank)
            while across < end {
                let half = span * CGFloat(0.7 + scatter.next() * 0.9)
                let tall = min(unit * CGFloat(0.30 + scatter.next() * 0.70), half * 3.2)
                let crown = half * CGFloat(0.16 + scatter.next() * 0.22)
                let tip = CGPoint(x: across + half * CGFloat(scatter.next() - 0.5) * 0.6, y: foot - tall)

                mass.move(to: CGPoint(x: across - half, y: foot))
                mass.addQuadCurve(
                    to: CGPoint(x: tip.x - crown, y: tip.y),
                    control: CGPoint(x: across - half * 0.80, y: foot - tall * 0.30)
                )
                mass.addQuadCurve(
                    to: CGPoint(x: tip.x + crown, y: tip.y),
                    control: CGPoint(x: tip.x, y: tip.y - crown * 1.2)
                )
                mass.addQuadCurve(
                    to: CGPoint(x: across + half, y: foot),
                    control: CGPoint(x: across + half * 0.80, y: foot - tall * 0.30)
                )
                mass.closeSubpath()

                // Often less than a full width along, so neighbours run into each other and the
                // bank reads as one lumpy mass rather than as a row of separate things.
                across += half * CGFloat(0.85 + scatter.next() * 1.15)
            }
            context.fill(mass, with: .color(color.opacity(rank > 0 ? 0.55 : 0.92)))
        }
    }

    /// One stalactite big enough to hang something off, drawn after the roof and reaching well
    /// past it.
    ///
    /// The roof's own teeth are scenery and are sized to stay out of the way; a bat needs a
    /// particular tooth in a particular place, and a picture needs to be able to see which one it
    /// is hanging from. So this is the same rock at four times the size, and it starts above the
    /// top of the frame so it belongs to the ceiling rather than floating under it.
    ///
    /// Two things were making it an icicle rather than a stalactite, and the photographs made
    /// both obvious. It had a bright mineral highlight down one side, which is exactly what one
    /// draws to say *this is made of ice*; that is gone, and the modelling is dark banding
    /// instead — the rings a stalactite grows in, the same ones the columns carry. And its sides
    /// drew in from the shoulder, so it was thin for most of its visible length. Now they fall
    /// nearly straight and only gather in over the last third, which is where a real one does its
    /// tapering, and it is drawn a good deal fatter besides.
    func drawGloamdeepFang(in context: inout GraphicsContext, at across: Double, to tip: Double, width: Double) {
        let point = CGPoint(x: x(across), y: y(tip))
        let half = x(width) / 2
        let top = -y(0.05)
        let fall = point.y - top

        var fang = Path()
        fang.move(to: CGPoint(x: point.x - half, y: top))
        fang.addCurve(
            to: CGPoint(x: point.x - half * 0.09, y: point.y),
            control1: CGPoint(x: point.x - half * 0.94, y: top + fall * 0.48),
            control2: CGPoint(x: point.x - half * 0.52, y: top + fall * 0.88)
        )
        fang.addQuadCurve(
            to: CGPoint(x: point.x + half * 0.09, y: point.y),
            control: CGPoint(x: point.x, y: point.y + half * 0.10)
        )
        fang.addCurve(
            to: CGPoint(x: point.x + half, y: top),
            control1: CGPoint(x: point.x + half * 0.52, y: top + fall * 0.88),
            control2: CGPoint(x: point.x + half * 0.94, y: top + fall * 0.48)
        )
        fang.closeSubpath()
        context.fill(fang, with: .color(colors.canopyShade))

        // The growth rings, narrowing as the rock does.
        var rings = Path()
        for step in 1...5 {
            let along = CGFloat(step) / 6
            let level = top + fall * along
            let wide = half * (1 - 0.72 * along * along)
            rings.move(to: CGPoint(x: point.x - wide * 0.86, y: level))
            rings.addQuadCurve(
                to: CGPoint(x: point.x + wide * 0.86, y: level),
                control: CGPoint(x: point.x, y: level + wide * 0.30)
            )
        }
        context.stroke(rings, with: .color(.black.opacity(0.20)), lineWidth: max(0.8, half * 0.05))
    }

    /// Columns standing on the floor and running up out of the top of the frame: wide at the
    /// foot, flared where they meet the rock, banded across the front with the ledges the water
    /// left on the way down, and lit down one edge by whatever crystal is nearest.
    ///
    /// The thicket's trunks with the bark taken off, and placed the same way and for the same
    /// reason: never down the middle, because a column dead centre is a stripe, and always
    /// leaving the frame, because a rock formation whose top you can see is a bollard.
    func drawGloamdeepColumns(
        in context: inout GraphicsContext,
        base: Double,
        at columns: [Double],
        width: Double,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let foot = y(base)
        let top = -size.height
        let waist = foot - size.height * 0.55

        for column in columns {
            let thick = x(width) * CGFloat(0.85 + scatter.next() * 0.4)
            let centre = x(column)
            let lean = thick * CGFloat(scatter.next() - 0.5) * 1.6
            let neck = thick * 0.42

            var stone = Path()
            stone.move(to: CGPoint(x: centre - thick / 2, y: foot))
            stone.addQuadCurve(
                to: CGPoint(x: centre - neck + lean, y: top),
                control: CGPoint(x: centre - neck * 0.7 + lean * 0.4, y: waist)
            )
            stone.addLine(to: CGPoint(x: centre + neck + lean, y: top))
            stone.addQuadCurve(
                to: CGPoint(x: centre + thick / 2, y: foot),
                control: CGPoint(x: centre + neck * 0.7 + lean * 0.4, y: waist)
            )
            // A skirt where it meets the floor, so the column grew out of the flowstone rather
            // than being stood on it.
            stone.addQuadCurve(
                to: CGPoint(x: centre - thick / 2, y: foot),
                control: CGPoint(x: centre, y: foot + thick * 0.34)
            )
            context.fill(stone, with: .color(colors.canopyShade))

            // The banding: every rib is one flood's worth of rock, and drawing them is the only
            // thing that tells a column from a chimney.
            var bands = Path()
            var down = foot - thick * 0.5
            while down > foot - size.height * 0.95 {
                let along = min(max((foot - down) / max(size.height, 1), 0), 1)
                let half = (thick / 2 + (neck - thick / 2) * along) * 0.84
                let drift = lean * along
                bands.move(to: CGPoint(x: centre - half + drift, y: down))
                bands.addQuadCurve(
                    to: CGPoint(x: centre + half + drift, y: down),
                    control: CGPoint(x: centre + drift, y: down + half * 0.30)
                )
                down -= thick * CGFloat(0.45 + scatter.next() * 0.6)
            }
            context.stroke(
                bands,
                with: .color(.black.opacity(0.22)),
                lineWidth: max(0.8, thick * 0.035)
            )

            context.fill(
                stone,
                with: .linearGradient(
                    Gradient(colors: [
                        colors.disc.opacity(colors.isNight ? 0.07 : 0.14),
                        colors.disc.opacity(0)
                    ]),
                    startPoint: CGPoint(x: centre - thick * 0.5, y: foot),
                    endPoint: CGPoint(x: centre - thick * 0.05, y: foot)
                )
            )
        }
    }

    /// The floor: ribs of wet flowstone stepping away from the camera, each with a lit lip where
    /// the water comes over it, and a shallow sheet standing on some of the steps.
    ///
    /// The caverns' boards are drawn exactly this way — rock the water has been running over long
    /// enough to lay it down in bands — so a floor in the film is the same floor a player has
    /// been fencing all world. The nearest ribs are the deepest and the darkest, which is what
    /// makes the floor step away rather than lie flat.
    ///
    /// The first cut ruled them: even spacing, a lip drawn at full strength on every one, and a
    /// curve so shallow it came out straight. Five shots came back looking like lined paper. What
    /// fixed it was taking the regularity out rather than taking the ribs out — the spacing is
    /// jittered, each rib sags by its own amount and in its own direction, the lip is a third of
    /// what it was, and only about half of them get one at all. Water does not lay rock down at
    /// a constant pitch, and the eye knows it.
    func drawGloamdeepLedges(
        in context: inout GraphicsContext,
        from near: Double,
        to far: Double,
        count: Int,
        seed: UInt64
    ) {
        var scatter = Scatter(seed: seed)
        let start = -x(0.12)
        let end = size.width + x(0.12)

        for index in 0..<count {
            let along = min((Double(index) + 0.15 + scatter.next() * 0.7) / Double(count), 1)
            let level = y(far + (near - far) * along)
            let deep = y(0.010 + 0.028 * along) * CGFloat(0.7 + scatter.next() * 0.7)
            let sag = y(0.014 + 0.030 * along) * CGFloat(scatter.next() - 0.5)
            let tilt = y(0.010 + 0.020 * along) * CGFloat(scatter.next() - 0.5)

            var lip = Path()
            lip.move(to: CGPoint(x: start, y: level))
            lip.addCurve(
                to: CGPoint(x: end, y: level + tilt),
                control1: CGPoint(x: x(0.30), y: level + sag),
                control2: CGPoint(x: x(0.72), y: level - sag * 1.4)
            )

            var rib = lip
            rib.addLine(to: CGPoint(x: end, y: level + tilt + deep))
            rib.addCurve(
                to: CGPoint(x: start, y: level + deep),
                control1: CGPoint(x: x(0.72), y: level - sag * 1.4 + deep),
                control2: CGPoint(x: x(0.30), y: level + sag + deep)
            )
            rib.closeSubpath()
            context.fill(rib, with: .color(.black.opacity(0.07 + 0.10 * along)))

            // Only the ribs the water is actually coming over get a lit lip. Drawing one on
            // every rib is what ruled the floor.
            if scatter.next() > 0.45 {
                context.stroke(
                    lip,
                    with: .color(GamePalette.cream.opacity(colors.isNight ? 0.03 : 0.06)),
                    lineWidth: max(1, y(0.0016))
                )
            }

            // Standing water on the step, which is what makes a cave floor read as wet rather
            // than as a dark meadow.
            guard scatter.next() > 0.42 else { continue }
            let pool = CGPoint(x: x(scatter.next(in: 0.15...0.85)), y: level + deep * 0.55)
            let spread = x(scatter.next(in: 0.10...0.26))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: pool.x - spread / 2, y: pool.y - spread * 0.06,
                    width: spread, height: spread * 0.12
                )),
                with: .color(colors.disc.opacity(colors.isNight ? 0.09 : 0.15))
            )
        }
    }

    /// A pool of crystal light. Every glow in this world is one of these, because every glow in
    /// this world is a mineral rather than a sun, and a mineral lights the yard or so around
    /// itself and gives up.
    func drawGloamdeepGlow(
        in context: inout GraphicsContext,
        at centre: CGPoint,
        radius: CGFloat,
        strength: Double
    ) {
        guard strength > 0, radius > 0 else { return }

        context.fill(
            circle(at: centre, radius: radius),
            with: .radialGradient(
                Gradient(colors: [
                    colors.discHalo.opacity(0.42 * strength),
                    colors.discHalo.opacity(0)
                ]),
                center: centre,
                startRadius: radius * 0.04,
                endRadius: radius
            )
        )
    }

    /// One crystal growing out of the rock with its own light in it: three shards off a single
    /// root, the middle one tallest, and a pool of glow round the lot.
    ///
    /// Drawn the way the caverns' own backdrop draws them, so the thing lighting the film is the
    /// thing lighting the board. In the shots that want a sun, this is what stands in for it —
    /// hung on the far wall at four or five times the size of the ones underfoot, which is a
    /// perfectly good way to light a room and the only one available.
    func drawGloamdeepCrystal(
        in context: inout GraphicsContext,
        at foot: CGPoint,
        height tall: CGFloat,
        glow: Double
    ) {
        let wide = tall * 0.46
        drawGloamdeepGlow(
            in: &context,
            at: CGPoint(x: foot.x, y: foot.y - tall * 0.5),
            radius: tall * 3.2,
            strength: glow
        )

        for lean in [-0.42, 0.06, 0.5] {
            let tip = CGPoint(
                x: foot.x + tall * CGFloat(lean) * 0.7,
                y: foot.y - tall * (lean == 0.06 ? 1.0 : 0.62)
            )
            let spread = wide * (lean == 0.06 ? 1.0 : 0.66)

            var shard = Path()
            shard.move(to: tip)
            shard.addLine(to: CGPoint(x: tip.x + spread * 0.5, y: foot.y - spread * 0.3))
            shard.addLine(to: CGPoint(x: tip.x + spread * 0.28, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - spread * 0.28, y: foot.y))
            shard.addLine(to: CGPoint(x: tip.x - spread * 0.5, y: foot.y - spread * 0.3))
            shard.closeSubpath()
            context.fill(shard, with: .color(colors.disc.opacity(colors.isNight ? 0.9 : 0.74)))
            context.stroke(
                shard,
                with: .color(GamePalette.cream.opacity(colors.isNight ? 0.5 : 0.34)),
                lineWidth: max(0.6, wide * 0.08)
            )
        }
    }

    /// Crystals up out of the flowstone along a line across the frame, which is what this world
    /// has instead of wildflowers and what the thicket's mushrooms are to the thicket.
    func drawGloamdeepCrystals(
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
            drawGloamdeepCrystal(
                in: &context,
                at: foot,
                height: x(0.028) * CGFloat(scale) * CGFloat(0.7 + scatter.next() * 0.7),
                glow: 0.45 + scatter.next() * 0.3
            )
        }
    }

    /// Something hanging off the roof by its feet, which down here is how the neighbours are met.
    ///
    /// The glyph is drawn the way every animal in the game is drawn, at the end of a thin claw
    /// line up into the rock, with the whole thing swinging a little off vertical. Its shadow is
    /// turned off, because a shadow under a hanging bat is a bat standing on the air, and it is
    /// hung from a point rather than stood on the ground, so `sway` is the only thing keeping it
    /// alive — which is enough, since a bat that is perfectly still is a decoration.
    func drawGloamdeepHang(
        in context: inout GraphicsContext,
        _ animal: Animal,
        from roof: Double,
        at across: Double,
        width: CGFloat,
        sway: Double,
        opacity: Double = 1
    ) {
        guard opacity > 0 else { return }

        var hung = context
        hung.opacity = opacity

        let anchor = CGPoint(x: x(across), y: y(roof))
        let head = CGPoint(x: anchor.x + width * CGFloat(sway) * 0.14, y: anchor.y + width * 0.18)

        // A bat is a dark glyph and the roof it hangs off is dark rock, which in the darkest
        // world in the game is two dark things in front of each other. So the roost gets a
        // crystal behind it — no cheat, since a crystal is what everything down here is lit by,
        // and it is the difference between a resident and a smudge.
        drawGloamdeepGlow(
            in: &hung,
            at: CGPoint(x: head.x, y: head.y + width * 0.45),
            radius: width * 1.6,
            strength: 0.75
        )

        var claw = Path()
        claw.move(to: CGPoint(x: anchor.x, y: anchor.y - width * 0.1))
        claw.addQuadCurve(
            to: head,
            control: CGPoint(x: anchor.x + width * CGFloat(sway) * 0.05, y: anchor.y + width * 0.06)
        )
        hung.stroke(
            claw,
            with: .color(GamePalette.post.opacity(0.85)),
            style: StrokeStyle(lineWidth: max(1.2, width * 0.06), lineCap: .round)
        )

        drawAnimal(
            in: &hung,
            animal,
            feet: CGPoint(x: head.x, y: head.y + width * 0.96),
            width: width,
            lean: 7 * sway,
            shadow: 0
        )
    }

    /// The next listing, seen through a break in the cavern wall: a hole with the seventh world's
    /// sky in it, a big top standing in the middle of that, and a string of lanterns swinging
    /// over the lot.
    ///
    /// The thicket's peak brush and this one have the same job — put the next world in the back
    /// of the last two shots, far off and hazed in the first, near and unmistakable in the
    /// second — and they solve it in opposite directions. A mountain is a shape drawn darker than
    /// the sky; a fairground is a hole drawn brighter than the wall. Everything inside the break
    /// is clipped to it, so the light never touches the rock except as the spill thrown back out
    /// of it, which is the part that sells the caption: the glow lands on the flowstone outside
    /// and nothing else in nine shots has been that colour.
    ///
    /// `haze` lays the caverns' own dark back over the finished hole, for the version of this
    /// that is a long way off. Distance is a colour before it is a size, even when the distant
    /// thing is the brightest object in the world.
    func drawGloamdeepCarnival(
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

        // The seventh world's palette, borrowed rather than imported: amber at the bottom of its
        // sky, plum at the top, and lantern gold hung between them.
        let amber = Color(red: 0.98, green: 0.68, blue: 0.42)
        let plum = Color(red: 0.30, green: 0.14, blue: 0.34)
        let lantern = Color(red: 1.00, green: 0.88, blue: 0.58)

        // The spill, thrown out onto the rock before the hole itself is painted, so it reads as
        // light landing on stone rather than as a ring drawn round a window.
        context.fill(
            circle(at: CGPoint(x: centre, y: foot - tall * 0.45), radius: span * 1.5),
            with: .radialGradient(
                Gradient(colors: [
                    amber.opacity(0.30 * (1 - haze)),
                    amber.opacity(0)
                ]),
                center: CGPoint(x: centre, y: foot - tall * 0.45),
                startRadius: span * 0.2,
                endRadius: span * 1.5
            )
        )

        // The break: lopsided on purpose, because a hole in a cave wall that is symmetrical is a
        // doorway and nobody fitted one.
        var mouth = Path()
        mouth.move(to: CGPoint(x: centre - span / 2, y: foot))
        mouth.addLine(to: CGPoint(x: centre - span * 0.42, y: foot - tall * 0.48))
        mouth.addQuadCurve(
            to: CGPoint(x: centre + span * 0.10, y: foot - tall),
            control: CGPoint(x: centre - span * 0.30, y: foot - tall * 0.94)
        )
        mouth.addQuadCurve(
            to: CGPoint(x: centre + span * 0.46, y: foot - tall * 0.40),
            control: CGPoint(x: centre + span * 0.46, y: foot - tall * 0.84)
        )
        mouth.addLine(to: CGPoint(x: centre + span / 2, y: foot))
        // A broken lower lip rather than a sill. Everything else in this game with a flat bottom
        // edge gets ground drawn over its feet; a hole cannot be buried that way without burying
        // the light coming out of it, so it is given a ragged one instead.
        //
        // Three points across the whole span turned out to be two very long diagonals meeting in
        // the middle, which is a folded sheet of paper rather than broken rock. It takes a lot of
        // small irregular steps to read as rubble, so it gets nine.
        var rubble = Scatter(seed: 2_003)
        for step in 1...9 {
            let along = 1 - Double(step) / 10
            mouth.addLine(to: CGPoint(
                x: centre - span / 2 + span * CGFloat(along),
                y: foot - tall * CGFloat(0.015 + rubble.next() * 0.075)
            ))
        }
        mouth.closeSubpath()
        context.fill(
            mouth,
            with: .linearGradient(
                Gradient(colors: [plum, amber]),
                startPoint: CGPoint(x: centre, y: foot - tall),
                endPoint: CGPoint(x: centre, y: foot)
            )
        )

        var beyond = context
        beyond.clip(to: mouth)

        let ring = CGPoint(x: centre + span * 0.02, y: foot - tall * 0.04)
        let peak = CGPoint(x: ring.x, y: ring.y - tall * 0.46)
        // Near-black rather than plum. A plum tent inside a plum sky is a shape with an edge on
        // it: the top half of the canvas vanished into the sky and only the half standing against
        // the amber could be seen at all. A big top is a silhouette with light behind it.
        let canvas = Color(red: 0.14, green: 0.06, blue: 0.17)

        var tent = Path()
        tent.move(to: CGPoint(x: ring.x - span * 0.32, y: ring.y))
        tent.addQuadCurve(to: peak, control: CGPoint(x: ring.x - span * 0.19, y: ring.y - tall * 0.32))
        tent.addQuadCurve(
            to: CGPoint(x: ring.x + span * 0.32, y: ring.y),
            control: CGPoint(x: ring.x + span * 0.19, y: ring.y - tall * 0.32)
        )
        tent.closeSubpath()
        beyond.fill(tent, with: .color(canvas))

        // Panels down the canvas from the peak. Without them the silhouette is a hill; with them
        // it is unmistakably a tent, which is the whole job of this shape.
        var panels = Path()
        for side in [-0.20, 0.06, 0.30] {
            panels.move(to: peak)
            panels.addLine(to: CGPoint(x: ring.x + span * CGFloat(side) - span * 0.045, y: ring.y))
            panels.addLine(to: CGPoint(x: ring.x + span * CGFloat(side) + span * 0.045, y: ring.y))
            panels.closeSubpath()
        }
        beyond.fill(panels, with: .color(amber.opacity(0.20)))

        // A mast and a pennant flying off the left of it. The first cut hung a right-pointing
        // triangle on the apex, which on a dark rectangle is not a flag, it is a play button.
        var mast = Path()
        mast.move(to: peak)
        mast.addLine(to: CGPoint(x: peak.x, y: peak.y - tall * 0.14))
        beyond.stroke(
            mast,
            with: .color(canvas),
            style: StrokeStyle(lineWidth: max(1, span * 0.012), lineCap: .round)
        )

        var pennant = Path()
        pennant.move(to: CGPoint(x: peak.x, y: peak.y - tall * 0.14))
        pennant.addLine(to: CGPoint(x: peak.x - span * 0.10, y: peak.y - tall * 0.115))
        pennant.addLine(to: CGPoint(x: peak.x - span * 0.055, y: peak.y - tall * 0.088))
        pennant.addLine(to: CGPoint(x: peak.x - span * 0.10, y: peak.y - tall * 0.062))
        pennant.addLine(to: CGPoint(x: peak.x, y: peak.y - tall * 0.088))
        pennant.closeSubpath()
        beyond.fill(pennant, with: .color(lantern.opacity(0.9)))

        // The lanterns, swagged across the opening and swinging: the punchline of the caption,
        // and the only thing in the whole world that moves because somebody hung it up.
        let swing = CGFloat(sin(progress * 2 * .pi)) * tall * 0.012
        for index in 0...7 {
            let along = Double(index) / 7
            let dip = CGFloat(sin(along * .pi))
            let bulb = CGPoint(
                x: ring.x - span * 0.44 + span * 0.88 * CGFloat(along),
                y: ring.y - tall * 0.66 + tall * 0.14 * dip + swing * dip
            )
            beyond.fill(
                circle(at: bulb, radius: span * 0.055),
                with: .radialGradient(
                    Gradient(colors: [lantern.opacity(0.7), lantern.opacity(0)]),
                    center: bulb,
                    startRadius: 0,
                    endRadius: span * 0.055
                )
            )
            beyond.fill(circle(at: bulb, radius: span * 0.013), with: .color(lantern))
        }

        guard haze > 0 else { return }
        context.fill(mouth, with: .color(colors.skyHorizon.opacity(haze)))
    }

    /// Motes adrift in the dark: spray off the water and dust off the roof, sinking slowly and
    /// fading in and out at either end of the fall so nothing ever pops.
    ///
    /// The thicket gets fireflies and the meadow gets birds, and this world gets these, for the
    /// same reason all three exist: something has to be moving or the shot reads as a painting of
    /// a cave rather than a cave. They fall rather than fly, because nothing down here is
    /// cheerful enough to blink.
    func drawGloamdeepMotes(in context: inout GraphicsContext, count: Int, seed: UInt64) {
        var scatter = Scatter(seed: seed)

        for _ in 0..<count {
            let home = CGPoint(
                x: x(scatter.next(in: 0.04...0.96)),
                y: y(scatter.next(in: 0.16...0.80))
            )
            let phase = scatter.next()
            let fall = moves ? (phase + progress).truncatingRemainder(dividingBy: 1) : phase
            let spot = CGPoint(
                x: home.x + x(0.016) * CGFloat(sin((phase + progress) * 2 * .pi)),
                y: home.y + y(0.10) * CGFloat(fall - 0.5)
            )
            let fade = 0.35 + 0.65 * sin(fall * .pi)

            context.fill(
                circle(at: spot, radius: x(0.010)),
                with: .radialGradient(
                    Gradient(colors: [
                        colors.discHalo.opacity(0.45 * fade),
                        colors.discHalo.opacity(0)
                    ]),
                    center: spot,
                    startRadius: 0,
                    endRadius: x(0.010)
                )
            )
            context.fill(
                circle(at: spot, radius: x(0.0022)),
                with: .color(GamePalette.cream.opacity(0.7 * fade))
            )
        }
    }
}
