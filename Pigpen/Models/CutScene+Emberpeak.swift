import Foundation

// MARK: - The mountain's shots

extension CutScene.Picture {
    /// Every shot of Emberpeak's three films.
    ///
    /// They do the meadow's five jobs and the thicket's, in the meadow's order: arrive and be
    /// sold the place, be told what is worth points and what is not, meet the resident, be
    /// given the rule, hold the ground and then look past it at the next listing. A third
    /// world that broke the shape would only read as a different game; keeping it is what
    /// makes the mountain the next chapter rather than the next app.
    ///
    /// What is new is what the camera is pointed at, and the mountain gives it a subject the
    /// low country never could: everything up here is lit from underneath. The meadow is a
    /// place with a sun over it and the thicket is a place with a roof on it, and Emberpeak is
    /// a place with a fire under it — ash on the ground, cinder alight in the ash, vents going
    /// in the rock, and a crater at the top throwing more light than the sky does. Every shot
    /// is composed round that, which is also the joke the listing runs on: the heating is
    /// included, and it is never going off.
    ///
    /// The other thing this world has that neither of the others did is a resident who is not
    /// a neighbour. The deer could share a pen and the boar would not; the wyrm is not
    /// livestock at all, and the board wants it left exactly where it is, on the far side of
    /// whatever gets built. So the briefing's last shot draws one pen rather than two — the
    /// pig's, with the wyrm well outside it and getting further out while you watch.
    enum Emberpeak: Hashable, Sendable {
        // MARK: The mountain's opening

        /// The peak from the ash slope below it, smoking the way it has always smoked, with
        /// the trail going up into it and the pig small at the foot of the climb: dramatic
        /// views and naturally heated, both true and neither of them reassuring.
        case theSmokingPeak
        /// A shelf of ash that changes hands halfway through: the coin turned up out of the
        /// mineral rights while the line is calling it a perk, and then the flame burning in
        /// the same spot while the line is calling it a maintenance concern. The meadow's
        /// apple and skull in their third set of clothes, shown one at a time — a player this
        /// far in is being reminded of the scoring rather than taught it.
        case coinsAndFlames
        /// The pig up on the rim with the whole steaming basin under it: overlooking a few
        /// issues, in both senses, which is as close as this pig gets to due diligence.
        case theViewFromTheRim

        // MARK: Wyrm Caldera

        /// The wyrm in the caldera, coming up out of it and getting bigger the whole time the
        /// shot runs, with the pig small at the near lip. The seller disclosed some local
        /// wildlife; the disclosure was drawn to scale and the animal is not.
        case theLocalWildlife
        /// The two of them either side of a fumarole, both leaning away from it: a party wall
        /// nobody built, nobody crosses, and nobody is going to be talked into sharing.
        case notJoiningTheAssociation
        /// One pen, round the pig, with the wyrm outside it and drifting further out as the
        /// shot runs. Boar Hollow opens two pens because a boar is a neighbour; nothing here
        /// is fencing the wyrm in, so the picture is a pen and an exclusion rather than a pair
        /// of lots.
        case keepTheWyrmOut

        // MARK: The mountain held

        /// A pen holding on the ridge after dark, coins lying about the ash, vents going under
        /// it and the crater lit above: excellent views, unbeatable heating, and the neighbour
        /// still out on the skyline where the rule left him.
        case theMountainHeld
        /// Down off the mountain at dusk with a city coming on in the valley, window by
        /// window, and the pig turned away from three worlds of property to look at it.
        case theCityBelow
        /// The same city, nearer and taller, with the pig starting down the rim towards it:
        /// somewhere with rules about what may be built where, which is a novelty worth the
        /// walk.
        case buildingCodes

        var isCard: Bool {
            switch self {
            case .theViewFromTheRim, .keepTheWyrmOut, .buildingCodes: true
            default: false
            }
        }
    }
}

// MARK: - The mountain's films

extension CutScene {
    /// Before the first walk up Emberpeak.
    ///
    /// Three shots, and the middle one carries the whole of what a player needs: the coin
    /// stands where the apple and the mushroom stood, the flame where the skull and the wilted
    /// flower did, and both are worth exactly what they always were. It is the same two
    /// sentences the thicket used — one selling, one admitting — so the picture changes with
    /// them rather than holding the pair up side by side, and the shots either side of it are
    /// the mountain doing its own advertising.
    static func emberpeakOpening(start: Date = .now) -> Self {
        Self(
            name: .emberpeakOpening,
            shots: [
                Shot(
                    picture: .emberpeak(.theSmokingPeak),
                    caption: "Welcome to Emberpeak. Dramatic views. Naturally heated."
                ),
                Shot(
                    picture: .emberpeak(.coinsAndFlames),
                    caption: "Turns out the mineral rights have their perks. Open flames are a maintenance concern."
                ),
                Shot(
                    picture: .emberpeak(.theViewFromTheRim),
                    caption: "Pig was willing to overlook a few issues for the right property."
                )
            ],
            start: start
        )
    }

    /// The mountain's boss briefing.
    ///
    /// Stag Mere's three shots for the third time — the resident arrives, the two of them take
    /// each other's measure, and the rule falls out of what they made of each other — and the
    /// rule is the odd one of the three. A deer will share a pen and a boar wants his own; the
    /// wyrm is not asking for anything, and the board would rather it were not fenced at all.
    /// So the last shot has one pen in it and a second animal standing well clear of it, which
    /// is a harder picture to read than two pens and a gap and the reason the wyrm is drawn
    /// leaving rather than merely elsewhere.
    static func wyrmCaldera(start: Date = .now) -> Self {
        Self(
            name: .wyrmCaldera,
            shots: [
                Shot(
                    picture: .emberpeak(.theLocalWildlife),
                    caption: "The seller had disclosed some local wildlife. They had undersold it."
                ),
                Shot(
                    picture: .emberpeak(.notJoiningTheAssociation),
                    caption: "This neighbor will not be joining the homeowners association."
                ),
                Shot(
                    picture: .emberpeak(.keepTheWyrmOut),
                    caption: "Fence in Pig. Keep the wyrm out. Very, very out."
                )
            ],
            start: start
        )
    }

    /// After the last pen on Emberpeak holds.
    ///
    /// The meadow pointed at a wood and the thicket pointed over its own roof at this mountain;
    /// from up here there is nothing left to point at but down. The send-off spends its first
    /// shot being pleased with the property and its other two looking at a city coming on in
    /// the valley, because the property is always fine and there is always another listing —
    /// and because a city seen from a mountain at dusk is the only thing in this game worth
    /// crossing a mountain for.
    static func emberpeakHeld(start: Date = .now) -> Self {
        Self(
            name: .emberpeakHeld,
            shots: [
                Shot(
                    picture: .emberpeak(.theMountainHeld),
                    caption: "The views were excellent. The heating bill was unbeatable."
                ),
                Shot(
                    picture: .emberpeak(.theCityBelow),
                    caption: "Still, Pig wondered if maybe a city had more to offer."
                ),
                Shot(
                    picture: .emberpeak(.buildingCodes),
                    caption: "At least cities had building codes. Probably."
                )
            ],
            start: start
        )
    }
}
