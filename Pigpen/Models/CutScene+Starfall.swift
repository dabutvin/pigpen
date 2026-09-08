import Foundation

// MARK: - The reaches' shots

extension CutScene.Picture {
    /// Every shot of Starfall Reaches' three films.
    ///
    /// The fifth world is sold on emptiness, and emptiness is the one thing a picture cannot
    /// say by putting more into the frame. So these nine shots are composed the other way from
    /// every world below them: the horizon is pushed out flat, the pig is drawn small enough to
    /// lose, and the space left over is left over. What the thicket gives to trunks and the city
    /// to walls, the reaches give to nothing at all — a few pits where things have come in, a
    /// star lying where it landed, and a sky with the stars showing through it in the middle of
    /// the afternoon, because the air up here is too thin to hide them.
    ///
    /// The rhyme with the meadow holds all the same. A world is arrived at and sold, its bonus
    /// and its hazard are named, a resident turns up with a rule, the place is held, and the pig
    /// is already reading the next listing before the last pen has settled. The listing this time
    /// is a hole in the ground, which is the only direction left to move in.
    enum Starfall: Hashable, Sendable {
        // MARK: The reaches' opening

        /// The plain, seen from as far back as the frame will allow: one flat rim, a field of
        /// craters running away to it, and the pig a smudge in the middle of the lot he is being
        /// shown. No traffic and no crowds, drawn as an absence of anything to draw.
        case theReaches
        /// The scoring, changing hands halfway through: the star in its own light while the line
        /// is selling the sparkle, and then the meteor in the same spot with the light off it
        /// while the line is disclaiming the damage. The meadow's apple and skull again, come in
        /// from a very long way out and worth exactly what they always were.
        case starsAndMeteors
        /// The pig alone under the whole sky, with the ground low and the stars doing the work
        /// the thicket gave to trees: no neighbours, drawn as the amount of nothing between him
        /// and the edge of the frame.
        case noNeighbors

        // MARK: Visitor Crater

        /// The saucer coming down into the crater on its own light, unhurried, with the pig small
        /// at the near rim watching the one thing this world was advertised as not having.
        case theVisitor
        /// The two of them stood at opposite ends of a great deal of dust, and the ground between
        /// them measured out into halves that match: personal space, and then the fairness that
        /// makes it a rule rather than a preference.
        case personalSpace
        /// Two pens marked out on the dust, the same width and the same height and drawn from the
        /// same baseline so that the eye can check, with a dimension line under each saying the
        /// same thing twice. Equal square footage, drawn rather than written.
        case equalSquareFootage

        // MARK: The reaches held

        /// Two pens holding at dusk, matched to the tile, stars lying about the pig's like
        /// windfall — and one meteor coming down beyond the rim, which is the "mostly".
        case reachesHeld
        /// A hole in the dust out ahead of the pig, its lip catching what light there is, and the
        /// pig at the rim of it with his head over the edge: the next listing, and the first one
        /// in five worlds that is not somewhere further along.
        case belowMarket
        /// The same hole from its lip, going down out of the bottom of the frame with a cold
        /// glimmer a very long way down it. The description says below market; the picture says
        /// how far below.
        case theHole

        var isCard: Bool {
            switch self {
            case .noNeighbors, .equalSquareFootage, .theHole: true
            default: false
            }
        }
    }
}

// MARK: - The reaches' films

extension CutScene {
    /// Before the first walk out into Starfall Reaches.
    ///
    /// Three shots, and the middle one carries the scoring the way every world's middle one
    /// does — the star held up as an amenity, the meteor admitted to afterwards. The two either
    /// side of it are the sales pitch, which out here is a matter of how much of the picture can
    /// be left with nothing in it: no traffic, no crowds, and lot sizes a buyer four worlds deep
    /// in cramped listings is not going to believe.
    static func starfallOpening(start: Date = .now) -> Self {
        Self(
            name: .starfallOpening,
            shots: [
                Shot(
                    picture: .starfall(.theReaches),
                    caption: "Starfall Reaches. No traffic. No crowds. Unbelievable lot sizes."
                ),
                Shot(
                    picture: .starfall(.starsAndMeteors),
                    caption: "Stars add a little sparkle. Meteor damage is not covered."
                ),
                Shot(
                    picture: .starfall(.noNeighbors),
                    caption: "Finally. No neighbors."
                )
            ],
            start: start
        )
    }

    /// The reaches' boss briefing.
    ///
    /// The joke is in the order: the pig buys the emptiest lot in the game on the strength of
    /// having no neighbours, and the first film after it opens with one landing. The rule that
    /// follows is the only one in the game about fairness rather than about space — two pens, and
    /// the same square footage in each — so the last shot has to be a comparison rather than a
    /// separation. Two pens apart would only say what the thicket already said; two pens visibly
    /// identical is the new rule, and the picture makes the reader check.
    static func visitorCrater(start: Date = .now) -> Self {
        Self(
            name: .visitorCrater,
            shots: [
                Shot(
                    picture: .starfall(.theVisitor),
                    caption: "Turns out, there were neighbors."
                ),
                Shot(
                    picture: .starfall(.personalSpace),
                    caption: "Fortunately, both parties valued personal space. And fairness."
                ),
                Shot(
                    picture: .starfall(.equalSquareFootage),
                    caption: "Build two separate pens. They must be exactly the same size. Equal square footage. No exceptions."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the reaches holds.
    ///
    /// Every send-off in the game points somewhere along the horizon; this one points straight
    /// down. The pig has the biggest lot he will ever own, holds it with a neighbour he has
    /// measured himself against to the tile, and then finds something listed under the floor of
    /// it — which is the caverns, and which is the same joke the volcano was: the property is
    /// always fine, and there is always a cheaper one.
    static func starfallHeld(start: Date = .now) -> Self {
        Self(
            name: .starfallHeld,
            shots: [
                Shot(
                    picture: .starfall(.reachesHeld),
                    caption: "Remote. Spacious. Peaceful. Mostly."
                ),
                Shot(
                    picture: .starfall(.belowMarket),
                    caption: "Then Pig found something listed below market."
                ),
                Shot(
                    picture: .starfall(.theHole),
                    caption: "Very far below market."
                )
            ],
            start: start
        )
    }
}
