import Foundation

// MARK: - The tundra's shots

extension CutScene.Picture {
    /// Every shot of Frostwhisker Tundra's three films.
    ///
    /// The tenth world is the one where the estate agent's vocabulary finally runs out. Charming
    /// and scenic are true; excellent natural refrigeration is what you say when the only
    /// remaining feature of a property is that it is cold. So the films are built the way every
    /// world's are — arrive, learn what scores, meet the resident, hold the place, look past it —
    /// and the camera spends all nine shots pointed at the one thing the tundra has, which is
    /// weather.
    ///
    /// The difficulty here is not composition, it is contrast: white ground under a white sky
    /// with white falling through it, which on its own is a blank page. Every shot is therefore
    /// hung on the three things that give snow an edge — the blue in a hollow, a pressure ridge
    /// standing up out of the flat, and open water, which out here is the darkest thing for a
    /// hundred miles and the only thing anybody wants.
    enum Frostwhisker: Hashable, Sendable {
        // MARK: The tundra's opening

        /// The edge of the ice with a low sun lying along it: ridges of broken pressure ice
        /// banked away to the horizon, the wind's combing across the near snow, and the pig
        /// small out on it. The listing, seen from the last place you can see all of it.
        case theIceEdge
        /// The scoring, changing hands halfway through: a ski stood up in its own light while
        /// the line is selling the slope access, and then a slick of black ice in the same spot
        /// with the light off it while the line is admitting what that does to the walkability.
        /// The meadow's apple and skull in a parka, worth exactly what they always were.
        case skisAndBlackIce
        /// The pig alone on a great deal of extremely expensive nothing, with one ski stood in
        /// the snow beside it like a board outside a house: the ski-town premium, understood.
        case theSkiTownPremium

        // MARK: The Haulout

        /// A lead of open water lying across the ice and the bull seal coming up out of it onto
        /// the near floe, arriving as the shot runs. The waterfront, and the resident it came
        /// with, in the same frame and in that order.
        case theWaterfront
        /// The two of them either side of a wall of pressure ice, the seal down on the water
        /// side and the pig up on the dry, both looking away from the other: the negotiation, in
        /// so far as there was one.
        case waterAccess
        /// The rule as a diagram: the lead running along the bottom of the frame, the seal's
        /// ghost pen sat with one edge on it, and the pig's opening away up the snow with a good
        /// deal of ice between. The water is the whole of what the shot is about, so it is the
        /// only dark thing in it.
        case aPenOnTheWater

        // MARK: The tundra held

        /// Both pens holding under the aurora: the seal's on the lead where it was promised, the
        /// pig's across the front of the frame with its skis lying where they were dropped.
        /// Quiet, beautiful, and the coldest picture in the game.
        case tundraHeld
        /// The pig up on the last ridge with its back to nine hundred square miles of held
        /// property, looking south at a low green country lying wet under the aurora: somewhere
        /// with less ice.
        case somewhereWithLessIce
        /// The same green country from inside it — reeds, standing water, mist to the knee — and
        /// something long coming through it that has not been mentioned. Much less ice.
        case muchLessIce

        var isCard: Bool {
            switch self {
            case .theSkiTownPremium, .aPenOnTheWater, .muchLessIce: true
            default: false
            }
        }
    }
}

// MARK: - The tundra's films

extension CutScene {
    /// Before the first walk out onto the tundra.
    ///
    /// Nothing here is being taught. A player at the tenth world knows what a bonus is worth and
    /// what a hazard costs, so the middle shot holds up the ski and then the ice slick in time
    /// with the two sentences it is captioned by, and the shots either side of it are simply the
    /// place: cold, empty, beautiful, and priced accordingly.
    static func frostwhiskerOpening(start: Date = .now) -> Self {
        Self(
            name: .frostwhiskerOpening,
            shots: [
                Shot(
                    picture: .frostwhisker(.theIceEdge),
                    caption: "Frostwhisker Tundra. Charming. Scenic. Excellent natural refrigeration."
                ),
                Shot(
                    picture: .frostwhisker(.skisAndBlackIce),
                    caption: "Slope access is a major amenity. Black ice hurts the walkability score."
                ),
                Shot(
                    picture: .frostwhisker(.theSkiTownPremium),
                    caption: "Pig was beginning to understand the ski-town premium."
                )
            ],
            start: start
        )
    }

    /// The tundra's boss briefing.
    ///
    /// Every resident so far has wanted a wall. This one wants a wall and an address: the seal
    /// will take its own pen provided that pen touches the lead, which is the first rule in the
    /// game about *where* a fence goes rather than how big it is. So the third shot is the only
    /// one in the tundra with the water put deliberately at the bottom of the frame — the pens
    /// are the diagram, and the lead is the line one of them has to reach.
    static func theHaulout(start: Date = .now) -> Self {
        Self(
            name: .theHaulout,
            shots: [
                Shot(
                    picture: .frostwhisker(.theWaterfront),
                    caption: "The waterfront came with a resident."
                ),
                Shot(
                    picture: .frostwhisker(.waterAccess),
                    caption: "The seal wanted its own place. With water access. Non-negotiable."
                ),
                Shot(
                    picture: .frostwhisker(.aPenOnTheWater),
                    caption: "Build separate pens. The seal's pen must border the water."
                )
            ],
            start: start
        )
    }

    /// After the last pen on the tundra holds.
    ///
    /// The thicket's send-off pointed over the trees at a mountain; this one turns its back on
    /// the whole hemisphere. Very cool, far too cool — the only complaint the pig has ever made
    /// about a property that was actually about the property — and then the fen, which is green,
    /// wet, warm and has its own problem waiting in it.
    static func frostwhiskerHeld(start: Date = .now) -> Self {
        Self(
            name: .frostwhiskerHeld,
            shots: [
                Shot(
                    picture: .frostwhisker(.tundraHeld),
                    caption: "Quiet. Beautiful. Very cool. Far too cool."
                ),
                Shot(
                    picture: .frostwhisker(.somewhereWithLessIce),
                    caption: "Pig decided to try somewhere with less ice."
                ),
                Shot(
                    picture: .frostwhisker(.muchLessIce),
                    caption: "Much less."
                )
            ],
            start: start
        )
    }
}
