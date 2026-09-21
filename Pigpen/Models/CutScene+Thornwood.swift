import Foundation

// MARK: - The thicket's shots

extension CutScene.Picture {
    /// Every shot of Thornwood Thicket's three films.
    ///
    /// They rhyme with the meadow's on purpose. The thicket is the second market the pig tours
    /// and the first that has to prove the game has more than one world in it, so its films are
    /// built the way the meadow's are — arrive, learn the property, meet the resident, hold the
    /// place, look past it — and the rhyme is what makes the second world read as the same
    /// story rather than as a different game with the same pig in it.
    ///
    /// What changes is everything the camera is pointed at. The meadow is open ground under an
    /// open sky; the thicket has a roof on it, and every shot here is composed under a canopy
    /// with trunks standing in the way of the view. A world you cannot see out of is the whole
    /// joke of the listing: secluded, wooded, very private.
    enum Thornwood: Hashable, Sendable {
        // MARK: The thicket's opening

        /// The tree line off the meadow, the trail running in under it, and the pig small at
        /// the mouth of the woods: the secluded, wooded, very private listing, seen from the
        /// one spot it can still be seen whole from.
        case theTreeLine
        /// A clearing that changes hands halfway through: the mushroom while the line is
        /// selling it as an amenity, then the wilted flower while the line is admitting what it
        /// does to the curb appeal. The meadow's apple and skull, dressed for the woods and
        /// worth exactly what they always were — shown one at a time, because a player this far
        /// in is being reminded rather than taught.
        case mushroomsAndFlowers
        /// The pig away up the trail with the trunks closing over it: off the beaten path, and
        /// pleased about it.
        case offTheBeatenPath

        // MARK: Boar Hollow

        /// The boar coming down through the trees into the hollow, big and unhurried, with the
        /// pig small at the near edge of the frame: the neighbour, met.
        case theNeighbor
        /// The two of them stood back to back with a stand of trunks between: the one thing
        /// they agree on, drawn rather than written.
        case separateUnits
        /// A ghost pen apiece, opening round each of them and never touching: fence them in
        /// separately, and no shared wall about it.
        case aPenApiece

        // MARK: The thicket held

        /// Two pens holding in the hollow at dusk, the pig loose in the larger, the boar in
        /// its own, mushrooms lying about the leaf mould: private, peaceful, almost perfect.
        case thicketHeld
        /// A gap in the canopy at dusk with a mountain standing in it, and the pig turned to
        /// look: the listing with the spectacular views.
        case mountainViews
        /// The same mountain, closer, with a plume going up off it and a red light under the
        /// cloud: the part of the description that was left out.
        case theVolcano

        var isCard: Bool {
            switch self {
            case .offTheBeatenPath, .aPenApiece, .theVolcano: true
            default: false
            }
        }
    }
}

// MARK: - The thicket's films

extension CutScene {
    /// Before the first walk into Thornwood Thicket.
    ///
    /// Three shots and no rules: a player who has fenced a whole meadow does not need telling
    /// what a pen is worth. What the thicket has to say is that it is a different place with the
    /// same scoring — the mushroom stands where the apple stood and the wilted flower where the
    /// skull did — so the middle shot holds up one and then the other, in time with the two
    /// sentences it is captioned by, and the two either side of it are the woods themselves.
    static func thornwoodOpening(start: Date = .now) -> Self {
        Self(
            name: .thornwoodOpening,
            shots: [
                Shot(
                    picture: .thornwood(.theTreeLine),
                    caption: "Thornwood Thicket. Secluded. Wooded. Very private."
                ),
                Shot(
                    picture: .thornwood(.mushroomsAndFlowers),
                    caption: "Mushrooms are a charming local amenity. Wilted flowers do nothing for curb appeal."
                ),
                Shot(
                    picture: .thornwood(.offTheBeatenPath),
                    caption: "Pig was warming to the idea of living off the beaten path."
                )
            ],
            start: start
        )
    }

    /// The thicket's boss briefing.
    ///
    /// Stag Mere's three shots, one world on: the resident arrives, the two of them size each
    /// other up, and the rule follows from what they think of each other. The rule is not the
    /// mere's, though — the deer could share a pen and the boar will not — so the third shot
    /// opens two pens rather than splitting one, and they never touch.
    static func boarHollow(start: Date = .now) -> Self {
        Self(
            name: .boarHollow,
            shots: [
                Shot(
                    picture: .thornwood(.theNeighbor),
                    caption: "Then Pig met the neighbor."
                ),
                Shot(
                    picture: .thornwood(.separateUnits),
                    caption: "They agreed immediately on one thing: separate units."
                ),
                Shot(
                    picture: .thornwood(.aPenApiece),
                    caption: "Fence in Pig and the boar separately."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the thicket holds.
    ///
    /// The meadow's send-off pointed at the trees; this one points over them. The pig has the
    /// wood he wanted and is already looking at a mountain through a hole in his own roof,
    /// which is the joke the whole journey runs on: the property is always fine, and there is
    /// always another listing.
    static func thornwoodHeld(start: Date = .now) -> Self {
        Self(
            name: .thornwoodHeld,
            shots: [
                Shot(
                    picture: .thornwood(.thicketHeld),
                    caption: "Private. Peaceful. Spacious. Almost perfect."
                ),
                Shot(
                    picture: .thornwood(.mountainViews),
                    caption: "Then Pig spotted a listing with spectacular mountain views."
                ),
                Shot(
                    picture: .thornwood(.theVolcano),
                    caption: "The description did not mention the volcano."
                )
            ],
            start: start
        )
    }
}
