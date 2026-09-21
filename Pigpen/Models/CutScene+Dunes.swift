import Foundation

// MARK: - The dunes' shots

extension CutScene.Picture {
    /// Every shot of Sunbaked Dunes' three films.
    ///
    /// The eighth world does the same five jobs every world does — arrive and be sold the place,
    /// learn what is worth points, meet the resident and be told the rule, hold the ground, look
    /// past it at the next listing — and it does them with almost nothing in the frame. That is
    /// the whole of what makes these shots the dunes' shots. A wood can put a trunk in the way of
    /// the view and a cavern can put a ceiling on it; out here there is sand, one small white sun
    /// and the odd cactus, and every composition has to be built out of that and the light.
    ///
    /// Which turns out to suit the listing exactly. Warm, secluded, extremely low-maintenance
    /// landscaping is an estate agent describing a place with nothing in it, and a picture with
    /// nothing in it is the honest photograph to run beside the words. The shots are wide, the
    /// horizon shimmers, the shadows are the only cold colour on the screen, and the pig is small
    /// in most of them — because the lot really is enormous, and that really is the problem.
    enum Dunes: Hashable, Sendable {
        // MARK: The dunes' opening

        /// Crescent dunes marching away to a horizon that will not hold still, a sun small and
        /// white and directly overhead, and the pig on a near crest with the whole property in
        /// front of him: warm, secluded, and landscaped by the wind for free.
        case theSandSea
        /// One patch of sand that changes hands halfway through: the split melon while the line
        /// is calling water access a premium, then the snake in the same spot while the line is
        /// admitting what it does to buyer confidence. The meadow's apple and skull, dressed for
        /// a desert and worth what they always were — shown one at a time, because a player eight
        /// worlds in is being reminded rather than taught.
        case melonsAndSnakes
        /// The lot, all of it, with one small cactus standing in the middle of it and a puddle of
        /// shade at the foot of the cactus that the pig is standing in most of. The camera pulls
        /// back until the joke is obvious.
        case shadeSoldSeparately

        // MARK: Scorpion Flats

        /// The scorpion coming out from under its rock into the glare, small and unhurried, with
        /// the pig near the camera watching it come: the nearest neighbour, and the nearest thing
        /// for miles.
        case theNearestNeighbor
        /// The two of them at opposite ends of the frame with a great deal of open hardpan
        /// between, both turned away, both perfectly happy. Everywhere else in the game a party
        /// wall has to be argued about; here the distance is already there and the shot only has
        /// to point at it.
        case aLittleDistance
        /// Two ghost pens with a lit strip of untouched sand running between them: not two pens
        /// that happen to be apart, but two pens with a lot in between that belongs to neither.
        /// Adjoining properties were not approved, and the picture says which bit is the
        /// adjoining.
        case noSharedFence

        // MARK: The dunes held

        /// Both pens holding under the coldest night in the game: the scorpion in its own up the
        /// slope, the pig with the run of a pen the width of the frame, melons lying about in it,
        /// and more sky overhead than any other world gets. Tons of space, and nothing in the air
        /// to make any of it humid.
        case dunesHeld
        /// A blue line lying along the far edge of the sand at dusk, and the pig turned to look at
        /// it: the sand would be more appealing with water attached, and there is water, and it
        /// is attached to somebody else's sand.
        case waterAttached
        /// The last dune, the sea coming up the beach under it, a shell already lying on the wet
        /// strand, and the pig going down the slip face towards all of it. Eight worlds of
        /// evidence say this ends badly and the pig has never once asked.
        case theSea

        var isCard: Bool {
            switch self {
            case .shadeSoldSeparately, .noSharedFence, .theSea: true
            default: false
            }
        }
    }
}

// MARK: - The dunes' films

extension CutScene {
    /// Before the first walk into Sunbaked Dunes.
    ///
    /// Three shots, and the middle one is the only one carrying any rules: the melon stands where
    /// the apple stood and the snake where the skull did, so the shot holds up one and then the
    /// other in time with the two sentences it is captioned by. The two either side are the
    /// property itself, which is sand, and the joke they are building to is that there is nothing
    /// wrong with the place at all except that there is nothing on it.
    static func duneOpening(start: Date = .now) -> Self {
        Self(
            name: .duneOpening,
            shots: [
                Shot(
                    picture: .dunes(.theSandSea),
                    caption: "Sunbaked Dunes. Warm. Secluded. Extremely low-maintenance landscaping."
                ),
                Shot(
                    picture: .dunes(.melonsAndSnakes),
                    caption: "Water access is worth a premium. Snakes tend to hurt buyer confidence."
                ),
                Shot(
                    picture: .dunes(.shadeSoldSeparately),
                    caption: "The lot was enormous. Shade was sold separately."
                )
            ],
            start: start
        )
    }

    /// The dunes' boss briefing.
    ///
    /// The storybook calls this one the scorpion pit and the film calls it Scorpion Flats, which
    /// is the sort of thing that happens to a place when somebody has to sell it. Either way the
    /// three shots do what every briefing does: the resident arrives, the two of them decide what
    /// they think of each other, and the rule falls straight out of it. The rule here is the
    /// hardest one the game has asked for — separate pens and not so much as a shared fence — so
    /// the last shot has to draw the gap as well as the pens, because two pens standing apart and
    /// two pens that may never touch are different pictures and only one of them is the rule.
    static func scorpionFlats(start: Date = .now) -> Self {
        Self(
            name: .scorpionFlats,
            shots: [
                Shot(
                    picture: .dunes(.theNearestNeighbor),
                    caption: "Pig finally met the nearest neighbor."
                ),
                Shot(
                    picture: .dunes(.aLittleDistance),
                    caption: "Both parties requested a little distance."
                ),
                Shot(
                    picture: .dunes(.noSharedFence),
                    caption: "Build separate pens. And don't let them share a fence. Adjoining properties were not approved."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the dunes holds.
    ///
    /// The desert's send-off has an easier job than most, because the thing it has to point at is
    /// the one thing a desert is defined by not having. The pig gets his tons of space and his
    /// very low humidity, notices a blue line along the edge of all that sand, and walks at it.
    /// The sea is the next listing, and the last line is the same question the pig has asked at
    /// the end of seven other worlds without ever waiting for the answer.
    static func duneHeld(start: Date = .now) -> Self {
        Self(
            name: .duneHeld,
            shots: [
                Shot(
                    picture: .dunes(.dunesHeld),
                    caption: "Tons of space. Very low humidity."
                ),
                Shot(
                    picture: .dunes(.waterAttached),
                    caption: "Pig thought the sand would be more appealing with water attached."
                ),
                Shot(
                    picture: .dunes(.theSea),
                    caption: "What could go wrong?"
                )
            ],
            start: start
        )
    }
}
