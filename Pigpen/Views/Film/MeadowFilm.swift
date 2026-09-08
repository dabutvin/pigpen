import Foundation
import SwiftUI
import UIKit

// MARK: - Mudlark Meadow, painted

extension Film {
    /// What light a shot is in, which is the shot's own business rather than the phone's.
    ///
    /// The opening is at sunrise and the meadow's last film opens in the same gold, so the
    /// property is always shown at its best. Stag Mere is lit flat and bright in between,
    /// because a briefing wants reading rather than admiring, and the two shots that turn
    /// toward the forest at the end fall into dusk, because the next listing is a dark one.
    static func meadowLight(_ shot: CutScene.Picture.Meadow) -> GamePalette.Pasture {
        switch shot {
        case .promisingLand, .theResident, .oneOrTwo: .day
        case .forestEdge, .intoTheForest: .dusk
        default: .daybreak
        }
    }

    func drawMeadow(_ shot: CutScene.Picture.Meadow, in context: inout GraphicsContext) {
        switch shot {
        case .homePen: drawHomePen(in: &context)
        case .theOpenGate: drawTheOpenGate(in: &context)
        case .welcomeMeadow: drawWelcomeMeadow(in: &context)
        case .applesAndSkulls: drawApplesAndSkulls(in: &context)
        case .closeTheFence: drawCloseTheFence(in: &context)
        case .promisingLand: drawPromisingLand(in: &context)
        case .theResident: drawTheResident(in: &context)
        case .oneOrTwo: drawOneOrTwo(in: &context)
        case .finishedPen: drawFinishedPen(in: &context)
        case .forestEdge: drawForestEdge(in: &context)
        case .intoTheForest: drawIntoTheForest(in: &context)
        }
    }

    // MARK: - The shots

    /// The pig in a poky farm pen bolted to the barn, up on the front rail and thoroughly
    /// unimpressed with the square footage. Morning, with the camera drifting in a touch, so
    /// the first thing the film says is how little room there is to say it in.
    private func drawHomePen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.05 + 0.05 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.56))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.30)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.26, drift: 0.015 * progress)
        drawBirds(in: &shot, at: 0.20)

        drawLand(in: &shot, ridge: 0.56, rise: 0.06, waves: 1.9, phase: 1.7, color: colors.farHill)
        drawMist(in: &shot, at: 0.60, seed: 19)
        drawLand(in: &shot, ridge: 0.70, rise: 0.03, waves: 1.4, phase: 0.6, color: colors.ground)

        // The barn the pen is bolted to, off to one side and small: home, such as it is.
        drawBarn(in: &shot, at: 0.78, base: 0.74, width: 0.24)

        // A cramped pen, the pig nearly the width of it and stepping up to the front rail:
        // there is nowhere in here it has not already been.
        let bob = hop(cycles: 2)
        let pig = CGPoint(x: x(0.40), y: y(0.83) - y(0.01 * bob))
        drawPenWash(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.17), lean: 4, squash: 1 - 0.03 * bob)
        drawPenFence(in: &shot, round: pig, width: 0.30, height: 0.15, drop: 0.012)

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, count: 14, height: 0.03, seed: 31)
    }

    /// The barn, and the gate. The fence runs the width of the frame with one panel stood
    /// open on it, and the pig is already through the gap — small, and not looking back.
    /// The camera drifts right, following it out.
    private func drawTheOpenGate(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08, drift: -0.02 + 0.045 * progress)

        drawSky(in: &shot, horizon: y(0.58))
        drawSun(in: &shot, at: CGPoint(x: x(0.78), y: y(0.50)), radius: x(0.07), rays: false)
        drawClouds(in: &shot, at: 0.26, drift: 0.01 * progress)

        drawLand(in: &shot, ridge: 0.58, rise: 0.06, waves: 1.8, phase: 1.9, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.72, rise: 0.03, waves: 1.3, phase: 0.5, color: colors.ground)

        // Far enough in that the push and the drift cannot walk the barn off the side of
        // the frame, and the fence starting clear of its far wall rather than across it.
        drawBarn(in: &shot, at: 0.26, base: 0.72, width: 0.30)
        drawFenceRun(in: &shot, base: 0.80, height: 0.075, from: 0.44, to: 1.06, posts: 7, gap: 3)

        // Through the gap and going: it clears the gateway over the shot rather than
        // standing in it, so the picture is a pig leaving rather than a pig posing.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.66 + 0.18 * progress), y: y(0.825)),
            width: x(0.125),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, color: colors.foreground)
        drawTufts(in: &shot, along: 0.94, rise: 0.016, waves: 1.0, phase: 2.6, count: 14, height: 0.032, seed: 47)
    }

    /// The meadow, wide and bright, with the pig stood in the middle of it and fence posts
    /// popping up out of the grass all round him in turn: the property, and the rack of
    /// fencing a player is handed to build the biggest pen they can on it.
    private func drawWelcomeMeadow(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.10 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.52))
        drawSun(in: &shot, at: CGPoint(x: x(0.30), y: y(0.24)), radius: x(0.08), rays: false)
        drawClouds(in: &shot, at: 0.16, drift: 0.015 * progress)
        drawBirds(in: &shot, at: 0.30)

        drawLand(in: &shot, ridge: 0.52, rise: 0.06, waves: 2.1, phase: 1.2, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.64, rise: 0.04, waves: 1.5, phase: 2.7, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.74, rise: 0.026, waves: 1.3, phase: 0.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.74, rise: 0.026, waves: 1.3, phase: 0.8, count: 20, height: 0.018, seed: 79)

        let pig = CGPoint(x: x(0.5), y: y(0.82))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))

        // A ring of fence posts standing up out of the grass round the pig, each one popping
        // in its own turn as the shot runs, so the fencing arrives a piece at a time rather
        // than all at once — the rack being handed over.
        drawFencePop(in: &shot, round: pig, width: 0.66, height: 0.11, drop: 0.02)
    }

    /// A pen shut round the pig with an apple inside it and a skull staked outside: the
    /// scoring rule drawn rather than written. Space scores, the apple improves it, and the
    /// skull is the one thing a good wall leaves on the far side of itself.
    private func drawApplesAndSkulls(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.44))
        drawSun(in: &shot, at: CGPoint(x: x(0.74), y: y(0.22)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.16, drift: 0.012 * progress)

        drawLand(in: &shot, ridge: 0.44, rise: 0.05, waves: 2.0, phase: 1.3, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, color: colors.ground)
        drawTufts(in: &shot, along: 0.56, rise: 0.03, waves: 1.5, phase: 2.5, count: 16, height: 0.016, seed: 137)

        let pig = CGPoint(x: x(0.44), y: y(0.80))
        drawPenWash(in: &shot, round: pig, width: 0.44, height: 0.26, drop: 0.02)

        // The apple, shut in with the pig where it is worth five tiles.
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.30), y: y(0.68)), width: x(0.072))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))
        drawPenFence(in: &shot, round: pig, width: 0.44, height: 0.26, drop: 0.02)

        // The skull, staked out on the wrong side of the wall where it costs nothing.
        drawTreat(in: &shot, "☠️", at: CGPoint(x: x(0.80), y: y(0.72)), width: x(0.072))

        drawLand(in: &shot, ridge: 0.93, rise: 0.014, waves: 1.0, phase: 0.3, color: colors.foreground)
    }

    /// The pen, shut but for one panel, and the pig walking straight out through the gap it
    /// leaves: the half of the rule the apple and the skull cannot teach. A pen the size of
    /// the meadow is worth nothing with a hole in it, and the pig will find the hole.
    private func drawCloseTheFence(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.08 * progress)

        drawSky(in: &shot, horizon: y(0.54))
        drawSun(in: &shot, at: CGPoint(x: x(0.70), y: y(0.34)), radius: x(0.075), rays: false)
        drawClouds(in: &shot, at: 0.22, drift: 0.015 * progress)

        drawLand(in: &shot, ridge: 0.54, rise: 0.06, waves: 2.0, phase: 1.2, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 2.9, color: colors.ground)

        // The pen washed gold behind the run, so what the pig is leaving reads as a pen that
        // held right up until the last piece was pulled.
        let pen = CGPoint(x: x(0.5), y: y(0.86))
        drawPenWash(in: &shot, round: pen, width: 0.9, height: 0.16, drop: 0.0)

        // The front run of it, one panel out of the middle for a gateway.
        drawFenceRun(in: &shot, base: 0.86, height: 0.14, from: -0.04, to: 1.04, posts: 9, gap: 4)

        // And the pig already through it and going, clear of the gap rather than stood in
        // it, because a pig does not pose in a hole it has found.
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.5 + 0.06 * progress), y: y(0.905)),
            width: x(0.14),
            lean: 6,
            squash: 1 - 0.05 * hop(cycles: 2.5)
        )

        drawLand(in: &shot, ridge: 0.96, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    /// Fence posts standing up out of the grass in a ring round `feet`, each rising in its
    /// own turn as the shot runs rather than all together: the rack of fencing arriving a
    /// piece at a time. Not a pen — the posts do not join up — but the promise of one.
    private func drawFencePop(
        in context: inout GraphicsContext,
        round feet: CGPoint,
        width: Double,
        height: Double,
        drop: Double
    ) {
        let count = 12
        let centre = CGPoint(x: feet.x, y: feet.y + y(drop) - y(height) * 0.5)
        let radiusX = x(width) / 2
        let radiusY = y(height) * 0.6
        let timber = max(2, x(0.011))

        var posts = Path()
        for index in 0..<count {
            let angle = Double(index) / Double(count) * 2 * .pi
            let base = CGPoint(
                x: centre.x + radiusX * CGFloat(cos(angle)),
                y: centre.y + radiusY * CGFloat(sin(angle))
            )
            // Each post pops in its turn — staggered round the ring — and eased so it
            // springs up rather than sliding.
            let due = Double(index) / Double(count) * 0.7
            let risen = easeOut(min(max((progress - due) / 0.3, 0), 1))
            guard risen > 0 else { continue }

            // The near posts, low in the frame, stand taller than the far ones.
            let depth = (sin(angle) + 1) / 2
            let tall = y(height) * CGFloat(0.55 + 0.45 * depth) * CGFloat(risen)
            posts.addRoundedRect(
                in: CGRect(x: base.x - timber / 2, y: base.y - tall, width: timber, height: tall),
                cornerSize: CGSize(width: timber * 0.4, height: timber * 0.4)
            )
        }
        context.fill(posts, with: .color(GamePalette.post))
    }

    /// A treat as the field draws it — an apple or a skull staked in the ground, glyph and
    /// all — so an apple in a cut scene reads as the same apple a board is scored on.
    // MARK: - Stag Mere

    /// The meadow, and a deer walking in from the far side of it behind the pig: a promising
    /// piece of land, and the one complication on it, arriving as the shot runs.
    private func drawPromisingLand(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawClouds(in: &shot, at: 0.18, drift: 0.015 * progress)
        drawLand(in: &shot, ridge: 0.40, rise: 0.05, waves: 2.0, phase: 1.4, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.54, rise: 0.026, waves: 1.5, phase: 2.2, color: colors.ground)
        drawTufts(in: &shot, along: 0.54, rise: 0.026, waves: 1.5, phase: 2.2, count: 16, height: 0.016, seed: 91)

        // Coming in from the right edge and slowing as it arrives, still up the field from
        // the pig: the resident, not yet met.
        let deerIn = easeOut(min(progress / 0.8, 1))
        drawAnimal(
            in: &shot,
            .deer,
            feet: CGPoint(x: x(1.06 - 0.30 * deerIn), y: y(0.60)),
            width: x(0.13),
            shadow: 0.7
        )

        drawLand(in: &shot, ridge: 0.70, rise: 0.02, waves: 1.3, phase: 0.6, color: colors.ground)
        drawTufts(in: &shot, along: 0.75, rise: 0.02, waves: 1.3, phase: 0.6, count: 18, height: 0.022, seed: 101)
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.30), y: y(0.80)), width: x(0.15))
    }

    /// The pig and the deer stood looking at each other across the grass, close in and much
    /// of a size: the current resident, and the discovery that this was not a vacant lot.
    private func drawTheResident(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.12 - 0.06 * progress)

        drawSky(in: &shot, horizon: y(0.48))
        drawClouds(in: &shot, at: 0.22, drift: 0.01 * progress)
        drawLand(in: &shot, ridge: 0.48, rise: 0.05, waves: 1.9, phase: 2.6, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.62, rise: 0.024, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.66, rise: 0.024, waves: 1.4, phase: 0.9, count: 16, height: 0.02, seed: 107)

        // Facing off across the middle of the frame, each breathing rather than moving,
        // because nobody in this shot has decided anything yet.
        let breath = sin(progress * 2 * .pi * 1.2)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.34), y: y(0.80) - y(0.004 * breath)),
            width: x(0.20),
            squash: 1 + 0.015 * breath
        )
        drawAnimal(
            in: &shot,
            .deer,
            feet: CGPoint(x: x(0.68), y: y(0.78) + y(0.004 * breath)),
            width: x(0.19),
            squash: 1 - 0.015 * breath
        )
    }

    /// The rule, drawn rather than written: both animals under one pen outline that splits
    /// into two as the shot runs, so the shape of the answer — one pen or two, whatever
    /// makes the floor plan work — is on screen before the player ever lays a piece.
    private func drawOneOrTwo(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.06 - 0.03 * progress)

        drawSky(in: &shot, horizon: y(0.32))
        drawLand(in: &shot, ridge: 0.32, rise: 0.045, waves: 2.0, phase: 1.1, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.44, rise: 0.02, waves: 1.5, phase: 2.4, color: colors.ground)
        drawTufts(in: &shot, along: 0.44, rise: 0.02, waves: 1.5, phase: 2.4, count: 16, height: 0.014, seed: 109)

        let deer = CGPoint(x: x(0.66), y: y(0.54))
        let pig = CGPoint(x: x(0.34), y: y(0.78))
        let both = CGPoint(x: (deer.x + pig.x) / 2, y: (deer.y + pig.y) / 2)

        drawAnimal(in: &shot, .deer, feet: deer, width: x(0.16), shadow: 0.7)
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.15))

        // One pen round the pair to begin with, fading as it gives way; then a pen apiece
        // opening up in its place. Split evenly, so the still the screenshots stop on — the
        // middle of the shot — has both readings of the rule in it at once.
        let split = easeOut(min(progress / 0.8, 1))
        drawGhostPen(in: &shot, round: both, width: 0.74, height: 0.44, drop: 0.012, opacity: 0.9 * (1 - split))
        drawGhostPen(in: &shot, round: deer, width: 0.42, height: 0.13, drop: 0.012, opacity: 0.9 * split)
        drawGhostPen(in: &shot, round: pig, width: 0.46, height: 0.135, drop: 0.012, opacity: 0.9 * split)
    }

    // MARK: - The meadow held

    /// The pig loose and easy in the finished meadow pen, washed gold, with windfall apples
    /// lying about it: space, good views, plenty of apples. The property, sold and settled.
    private func drawFinishedPen(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.04 + 0.04 * progress)

        drawSky(in: &shot, horizon: y(0.34))
        drawSun(in: &shot, at: CGPoint(x: x(0.22), y: y(0.20)), radius: x(0.085), rays: false)
        drawClouds(in: &shot, at: 0.14, drift: 0.012 * progress)
        drawBirds(in: &shot, at: 0.26)

        drawLand(in: &shot, ridge: 0.34, rise: 0.05, waves: 2.1, phase: 1.5, color: colors.farHill)
        drawLand(in: &shot, ridge: 0.48, rise: 0.03, waves: 1.5, phase: 2.6, color: colors.canopy)
        drawLand(in: &shot, ridge: 0.58, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)
        drawTufts(in: &shot, along: 0.58, rise: 0.024, waves: 1.4, phase: 0.8, count: 18, height: 0.016, seed: 113)

        // The whole front of the meadow one held pen, with the pig in the middle of all that
        // room and a couple of windfall apples lying in with it.
        let pig = CGPoint(x: x(0.5), y: y(0.86))
        drawPenWash(in: &shot, round: pig, width: 0.92, height: 0.30, drop: 0.0)
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.24), y: y(0.76)), width: x(0.05))
        drawTreat(in: &shot, "🍎", at: CGPoint(x: x(0.78), y: y(0.80)), width: x(0.05))
        drawAnimal(in: &shot, .pig, feet: pig, width: x(0.16))
        drawPenFence(in: &shot, round: pig, width: 0.92, height: 0.30, drop: 0.0)
    }

    /// The pig stood in its meadow with its back half-turned, looking at a dark stand of
    /// trees banked up at the edge of the world. It should be satisfied. It is looking at the
    /// forest.
    private func drawForestEdge(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.08 - 0.04 * progress, drift: 0.02 * progress)

        drawSky(in: &shot, horizon: y(0.42))
        drawClouds(in: &shot, at: 0.18, drift: 0.01 * progress)
        drawLand(in: &shot, ridge: 0.42, rise: 0.05, waves: 2.0, phase: 1.7, color: colors.farHill)

        // The forest banked up on the right, dark against the dusk: the next listing.
        drawForest(in: &shot, base: 0.62, from: 0.50, to: 1.10, height: 0.34, seed: 211, color: GamePalette.beyond)

        drawLand(in: &shot, ridge: 0.66, rise: 0.03, waves: 1.4, phase: 0.9, color: colors.ground)
        drawTufts(in: &shot, along: 0.70, rise: 0.03, waves: 1.4, phase: 0.9, count: 18, height: 0.02, seed: 127)

        // Stood off in the open meadow, turned toward the trees rather than toward whoever
        // is watching it.
        drawAnimal(in: &shot, .pig, feet: CGPoint(x: x(0.32), y: y(0.84)), width: x(0.17), lean: -3)

        drawLand(in: &shot, ridge: 0.94, rise: 0.016, waves: 1.0, phase: 2.2, color: colors.foreground)
    }

    /// The pig away up the trail and into the trees, small and getting smaller: gone to look
    /// at the next place before the paint is dry on this one. The line the film ends on lands
    /// in the middle of the frame over the top of it.
    private func drawIntoTheForest(in context: inout GraphicsContext) {
        var shot = pushed(context, zoom: 1.14 - 0.10 * progress)

        drawSky(in: &shot, horizon: y(0.40))
        drawLand(in: &shot, ridge: 0.40, rise: 0.045, waves: 2.1, phase: 1.5, color: colors.farHill)

        // The forest ahead and across the whole frame now, the meadow narrowing into it.
        drawForest(in: &shot, base: 0.56, from: -0.10, to: 1.10, height: 0.40, seed: 223, color: GamePalette.beyond)

        drawLand(in: &shot, ridge: 0.60, rise: 0.024, waves: 1.4, phase: 0.8, color: colors.ground)
        drawTrail(in: &shot, from: 1.02, to: 0.60)

        // On the trail and heading up it, dwindling toward the treeline as the shot runs.
        let along = easeOut(progress)
        drawAnimal(
            in: &shot,
            .pig,
            feet: CGPoint(x: x(0.46 + 0.02 * along), y: y(0.76 - 0.06 * along)),
            width: x(0.10 - 0.03 * along),
            shadow: 0.5
        )

        drawLand(in: &shot, ridge: 0.92, rise: 0.014, waves: 1.0, phase: 2.6, color: colors.foreground)
    }

    /// A stand of dark trees banked along the meadow's edge: two ranks of stubby conifer
    /// silhouettes, the back rank a shade lighter and lifted, so the forest reads as deep
    /// rather than as a cardboard cut-out. It is the next world's front door, drawn as a wall
    /// of dark rather than as somewhere you can already see into.
    // MARK: - What is standing in the meadow

    private func drawBarn(in context: inout GraphicsContext, at across: Double, base: Double, width: Double) {
        let span = x(width)
        let foot = y(base)
        let wall = span * 0.62
        let body = CGRect(x: x(across) - span / 2, y: foot - wall, width: span, height: wall)

        // Roof first, so the wall is what laps over it rather than the other way round.
        var roof = Path()
        roof.move(to: CGPoint(x: body.minX - span * 0.09, y: body.minY + span * 0.02))
        roof.addLine(to: CGPoint(x: body.midX, y: body.minY - span * 0.30))
        roof.addLine(to: CGPoint(x: body.maxX + span * 0.09, y: body.minY + span * 0.02))
        roof.closeSubpath()
        context.fill(roof, with: .color(GamePalette.post))

        context.fill(Path(body), with: .color(GamePalette.barn))
        // The lit side, so it sits in the same sunrise as everything else.
        context.fill(
            Path(CGRect(x: body.minX, y: body.minY, width: span * 0.22, height: wall)),
            with: .color(.white.opacity(0.16))
        )

        let door = CGRect(
            x: body.midX - span * 0.15, y: foot - wall * 0.66,
            width: span * 0.30, height: wall * 0.66
        )
        context.fill(
            Path(roundedRect: door, cornerRadius: span * 0.03),
            with: .color(GamePalette.post.opacity(0.85))
        )
        // One board line across the wall, which is all it takes to read as timber.
        var course = Path()
        course.move(to: CGPoint(x: body.minX, y: body.minY + wall * 0.42))
        course.addLine(to: CGPoint(x: body.maxX, y: body.minY + wall * 0.42))
        context.stroke(
            course,
            with: .color(GamePalette.cream.opacity(0.2)),
            lineWidth: max(1, span * 0.012)
        )
    }

    /// A run of fence, head on: posts with two rails across them, and `gap` left out of it
    /// where a gate should be. The same fencing a board is built out of, stood up in grass.
}
