import Foundation

// MARK: - The caverns' shots

extension CutScene.Picture {
    /// Every shot of Gloamdeep Caverns' three films.
    ///
    /// They do the same nine jobs the meadow's and the thicket's do — arrive and be sold the
    /// place, learn what is worth points, meet the resident and be told the rule, hold the
    /// ground, and look past it at the next listing — because a player six worlds in knows the
    /// shape of a Pigpen film and any world that broke it would only look lost. The rhyme is the
    /// point; the pictures are the world's own.
    ///
    /// What is the caverns' own is that there is no sky in any of them. Every other world the
    /// pig has toured is a floor with weather over it, and this one is a floor with a roof over
    /// it: rock hanging in the top of the frame, rock standing in the middle of it, and no
    /// horizon anywhere that is not another wall. The light comes off the crystals in the walls
    /// and out of nothing else, which is why the third shot of the opening can say the quiet part
    /// out loud — natural light was admittedly limited — and get away with it, because the two
    /// shots before it have already been that dark without mentioning it.
    ///
    /// The one structural thing this world does that no earlier one does is stand three animals
    /// in a briefing instead of two. The roost is a pair and the board wants the pair in one pen,
    /// so the rule shot has to show three bodies and two pens and make it obvious which way round
    /// they go, without a word of it in the picture.
    enum Gloamdeep: Hashable, Sendable {
        // MARK: The caverns' opening

        /// The chamber at the bottom of the way down, with the pig small on the flowstone and
        /// the roof shut over the lot of it: solid construction, no street noise, and — since the
        /// only way in is a hole in the ceiling of the world — no street.
        case theWayDown
        /// The seam that changes hands halfway through: the diamond while the line is selling the
        /// mineral rights, then the boulder in the same spot while the line is admitting what it
        /// does to the floor plan. The meadow's apple and skull, five worlds on and worth exactly
        /// what they always were — shown one at a time, in time with the sentence being read.
        case mineralRights
        /// One thread of daylight coming down from a hole a very long way up, the pig standing in
        /// the puddle of it, and everything else in the frame black: the listing's one admitted
        /// drawback, framed so the admission is the smallest thing in the picture.
        case limitedNaturalLight

        // MARK: The Roost

        /// Two bats hanging off the stalactites over the pig's head, the second one unfolding as
        /// the shot runs so the count lands on the word: already occupied, twice.
        case alreadyOccupied
        /// The pair of them crowded onto one stalactite, wing to wing and perfectly content, with
        /// the pig on the floor leaning as far the other way as the frame allows. Nobody has
        /// argued. Nobody is going to have to.
        case happyToShare
        /// Two ghost pens, one round the pig and one round both bats: the rule drawn rather than
        /// written, and the only briefing card in the game that has to say *these two together,
        /// that one alone* without a word to do it in.
        case noRoommates

        // MARK: The caverns held

        /// Two pens holding in the dark: the roost's up on its ledge with the pair of them in it,
        /// the pig's across the front of the frame with diamonds lying about in the flowstone.
        /// Affordable, quiet, and extremely dark — all three of which the picture can be blamed
        /// for personally.
        case cavernsHeld
        /// A break in the cavern wall away off across the chamber with warm light coming through
        /// it, and the pig turned to look at that instead of at the property he has just spent
        /// three films buying.
        case betterLighting
        /// The same break, near enough now to see what is behind it: lanterns strung across a
        /// tent, and more light coming out of one hole in the rock than this world has managed in
        /// nine shots. Much, much better lighting.
        case muchBetterLighting

        var isCard: Bool {
            switch self {
            case .limitedNaturalLight, .noRoommates, .muchBetterLighting: true
            default: false
            }
        }
    }
}

// MARK: - The caverns' films

extension CutScene {
    /// Before the first walk down into Gloamdeep Caverns.
    ///
    /// The sell is an estate agent's, which is to say it is all true. Solid construction is what
    /// you call a wall of rock; no street noise is what you call being under a mountain; the
    /// mineral rights really are excellent and the boulders really will stop you extending. The
    /// middle shot holds up one and then the other in time with the two sentences it is captioned
    /// by, the same crossing the thicket's clearing makes, because by the sixth world the scoring
    /// is a reminder rather than a lesson and a reminder is best given one thing at a time.
    static func gloamdeepOpening(start: Date = .now) -> Self {
        Self(
            name: .gloamdeepOpening,
            shots: [
                Shot(
                    picture: .gloamdeep(.theWayDown),
                    caption: "Gloamdeep Caverns. Solid construction. No street noise. No street, either."
                ),
                Shot(
                    picture: .gloamdeep(.mineralRights),
                    caption: "Excellent mineral rights. Boulders make expansion difficult."
                ),
                Shot(
                    picture: .gloamdeep(.limitedNaturalLight),
                    caption: "Natural light was admittedly limited."
                )
            ],
            start: start
        )
    }

    /// The caverns' boss briefing.
    ///
    /// The first one in the game with three animals in it, and the whole film is arranged round
    /// that. The bats are drawn as a pair from the first frame — never one bat and then another
    /// bat, always two of a thing — so that when the last shot puts one pen round both of them it
    /// reads as the roost being housed rather than as two neighbours being made to share.
    ///
    /// The joke underneath is that the bats are the reasonable party. They would happily have had
    /// the pig in with them; it is the pig who wants a wall, and the rule the board enforces is
    /// the pig's preference dressed up as a floor plan.
    static func theRoost(start: Date = .now) -> Self {
        Self(
            name: .theRoost,
            shots: [
                Shot(
                    picture: .gloamdeep(.alreadyOccupied),
                    caption: "The property was already occupied. Twice."
                ),
                Shot(
                    picture: .gloamdeep(.happyToShare),
                    caption: "The bats were happy to share. Pig was not."
                ),
                Shot(
                    picture: .gloamdeep(.noRoommates),
                    caption: "Pig gets his own pen. Both bats share the other. Pig was absolutely not accepting roommates."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the caverns holds.
    ///
    /// Every send-off in the game is the same shrug — the property is fine, and there is always
    /// another listing — and this one gets to make the point with the light rather than with the
    /// view. Three films of crystal glow and one thread of daylight, and then a hole in the wall
    /// with a fairground behind it: the pig does not need telling what he is looking at, and
    /// neither does anybody watching.
    static func gloamdeepHeld(start: Date = .now) -> Self {
        Self(
            name: .gloamdeepHeld,
            shots: [
                Shot(
                    picture: .gloamdeep(.cavernsHeld),
                    caption: "Affordable. Quiet. Extremely dark."
                ),
                Shot(
                    picture: .gloamdeep(.betterLighting),
                    caption: "Then Pig saw somewhere with better lighting."
                ),
                Shot(
                    picture: .gloamdeep(.muchBetterLighting),
                    caption: "Much, much better lighting."
                )
            ],
            start: start
        )
    }
}
