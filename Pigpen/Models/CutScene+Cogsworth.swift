import Foundation

// MARK: - The city's shots

extension CutScene.Picture {
    /// Every shot of Cogsworth City's three films.
    ///
    /// The fourth world is the first one somebody built. Three worlds of ground that grew — a
    /// meadow, a wood, a mountain that burnt itself bare — and then a horizon made of rooftops,
    /// with a canal in it that was dug and paving underfoot that was laid. So where the thicket
    /// answers the meadow's hills with a canopy, the city answers both with a skyline, and every
    /// shot in these three films is composed against one.
    ///
    /// The pig is small in all of them, which is the other thing a city is for. A pig at the
    /// mouth of a wood is still the biggest thing in the frame; a pig on a pavement under six
    /// storeys of somebody else's windows is a buyer being shown what the money buys here.
    enum Cogsworth: Hashable, Sendable {
        // MARK: The city's opening

        /// The street in under the rooftops, lamps down either side of it and the pig on the
        /// pavement at the foot of the frame: walkable, vibrant, close to everything, seen from
        /// the one spot where all of it still fits in a picture. The thicket's tree line, with
        /// the trees replaced by landlords.
        case theCityLine
        /// The clearing-house shot, changing hands halfway through: the pizza while the line is
        /// selling the neighbourhood, then the trash can standing in the same spot with the
        /// light off it while the line is admitting what the neighbourhood smells like. The
        /// meadow's apple and skull in city dress, worth exactly what they always were.
        case pizzaAndTrash
        /// The pig away along a towpath at the foot of the skyline, railings between it and the
        /// canal and a lamp burning over its head: the amenity walk, and a pig walking it.
        case cityLiving

        // MARK: Rat King Wharf

        /// The rat coming up out of the drain it has always lived in, with the pig backed off
        /// against the wall of a building it thought it had bought outright: the roommate, met.
        case theRoommate
        /// The pig leaning on the rat with everything it has and the rat not moving a hair for
        /// it. The only shot in the film where the two of them touch, and the only one where
        /// nothing happens.
        case neverLeaving
        /// One pen opening round the pair of them at once, which no other world's rule allows:
        /// the wharf is a compromise drawn rather than written.
        case onePenRoundBoth

        // MARK: The city held

        /// The pen holding across the front of the wharf at dusk, pig and rat inside it
        /// together, pizza in with them and the windows coming on overhead: great food,
        /// excellent location, and a rodent that came with the lease.
        case cityHeld
        /// The pig up on its own roof at dusk with the whole skyline below it, looking straight
        /// up at the one bright thing that is not a window. The thicket looked over the trees at
        /// a mountain; the city looks over the roofs at the sky, because there is nothing left
        /// on the ground to move to.
        case pastTheRooftops
        /// The star, on its way down over the rooftops with its tail behind it: the next
        /// listing, arriving under its own power for once. Quite far, apparently.
        case theFallingStar

        var isCard: Bool {
            switch self {
            case .cityLiving, .onePenRoundBoth, .theFallingStar: true
            default: false
            }
        }
    }
}

// MARK: - The city's films

extension CutScene {
    /// Before the first walk into Cogsworth City.
    ///
    /// The estate agent's voice is at its purest here, because the city is the first listing
    /// whose drawbacks are other people. Three shots: the street, the two things lying on it
    /// that are worth points, and the pig walking the canal like a man who has already decided.
    /// The middle one changes picture when the caption changes sentence — the pizza is a strong
    /// selling point right up until the trash arrives in the same spot.
    static func cogsworthOpening(start: Date = .now) -> Self {
        Self(
            name: .cogsworthOpening,
            shots: [
                Shot(
                    picture: .cogsworth(.theCityLine),
                    caption: "Cogsworth City. Walkable. Vibrant. Close to everything."
                ),
                Shot(
                    picture: .cogsworth(.pizzaAndTrash),
                    caption: "Pizza within walking distance is a strong selling point. Trash pickup appears to be… irregular."
                ),
                Shot(
                    picture: .cogsworth(.cityLiving),
                    caption: "Pig could get used to city living."
                )
            ],
            start: start
        )
    }

    /// The city's boss briefing.
    ///
    /// Every other resident in the game is a neighbour: something met out on the ground, sized
    /// up, and fenced off from. The rat is indoors. It was here before the pig, it has no
    /// intention of going anywhere, and the rule that follows is the only one in the game that
    /// puts two animals inside the same fence — so the third shot opens one pen round the pair
    /// rather than splitting or doubling anything, and the picture is the compromise.
    static func ratKingWharf(start: Date = .now) -> Self {
        Self(
            name: .ratKingWharf,
            shots: [
                Shot(
                    picture: .cogsworth(.theRoommate),
                    caption: "The apartment came with a roommate."
                ),
                Shot(
                    picture: .cogsworth(.neverLeaving),
                    caption: "The rat was not leaving. The rat had never considered leaving."
                ),
                Shot(
                    picture: .cogsworth(.onePenRoundBoth),
                    caption: "Fence them in together. Sometimes real estate is about compromise."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the city holds.
    ///
    /// The thicket's send-off pointed over the trees at a mountain, and the mountain's pointed
    /// down at these lights. There is nowhere left along the ground that does not have somebody
    /// on it, so this one points straight up — and the thing that answers is already falling,
    /// which is the first time in four worlds that the next listing has come to the pig.
    static func cogsworthHeld(start: Date = .now) -> Self {
        Self(
            name: .cogsworthHeld,
            shots: [
                Shot(
                    picture: .cogsworth(.cityHeld),
                    caption: "Great food. Excellent location. Minor rodent situation."
                ),
                Shot(
                    picture: .cogsworth(.pastTheRooftops),
                    caption: "Pig began wondering how far he'd have to go to get away from rats."
                ),
                Shot(
                    picture: .cogsworth(.theFallingStar),
                    caption: "Quite far, apparently."
                )
            ],
            start: start
        )
    }
}
