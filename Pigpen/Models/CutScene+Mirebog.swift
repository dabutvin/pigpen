import Foundation

// MARK: - The fen's shots

extension CutScene.Picture {
    /// Every shot of Mirebog Fen's three films.
    ///
    /// The jobs are the meadow's and the thicket's, done for the eleventh time: arrive and be
    /// sold the place, be shown what the ground is worth, meet the resident and be given his
    /// terms, hold the place, and look past it at the next listing. What the fen brings to them
    /// is water — not a pond in the corner of a picture but water lying through every shot, in
    /// channels the ground never managed to keep out, with mist coming up off the lot of it.
    ///
    /// Which makes the fen the one world whose scenery is also its rule. The thicket's boar
    /// wanted a fence of his own and could have been stood anywhere; the old croc wants a
    /// particular thing that is already in the picture, and so the channel that runs through
    /// his card is not decoration behind the rule — it is the rule, drawn.
    enum Mirebog: Hashable, Sendable {
        // MARK: The fen's opening

        /// The fen from the one bit of it that is dry: channels stacked away into the haze,
        /// reeds standing in every one of them, and the pig on a hag of peat in the middle with
        /// water on all four sides of him. Waterfront property in every direction, and no
        /// direction that is anything else.
        case waterfrontEverywhere
        /// The two halves of the scoring line, one after the other over the same still water:
        /// the lotus open on it while the line is calling it a pop of colour, and then the
        /// mosquito hanging in the same spot with the light gone off it. The meadow's apple and
        /// skull, wet through, and worth exactly what they always were.
        case lotusAndMosquitoes
        /// The pig waist-deep in a channel with the reeds shut over his head: lush, in the sense
        /// the word is doing a great deal of work in.
        case describedAsLush

        // MARK: The Wallow

        /// The croc coming up out of his own channel onto the near bank, unhurried and most of
        /// him still under: the neighbour, met, with the pig on dry peat well back from him.
        case oneRequirement
        /// One channel running the whole width of the frame, and the croc's interest going down
        /// it end to end as the shot runs — one waterway is enough, and this is the whole of one
        /// waterway. The pig is on the bank and not on any of it.
        case theWholeThing
        /// The rule drawn: a channel across the foot of the frame with a ghost pen swallowing
        /// the whole of it, both banks and both ends, and a second pen for the pig away up the
        /// dry ground with no water in it at all.
        case aWholeWaterway

        // MARK: The fen held

        /// Two pens holding at dusk, the croc's laid over the whole length of his channel and
        /// the pig's on the dry hag in front of it, lotus flowers open on the water and the bog
        /// making its own small lights in the reeds. Very green, very wet.
        case veryGreenVeryWet
        /// The pig on the highest peat in the fen with the mist round his knees, looking up
        /// rather than out — there being nothing to look out at here that is not more of this.
        case stillNotSatisfied
        /// What he is looking at: a spire standing out of a floor of cloud a long way above the
        /// mist, with something circling it. From the wettest ground in the game there is only
        /// one direction that is not more of the same.
        case onlyOneDirection

        var isCard: Bool {
            switch self {
            case .describedAsLush, .aWholeWaterway, .onlyOneDirection: true
            default: false
            }
        }
    }
}

// MARK: - The fen's films

extension CutScene {
    /// Before the first walk into Mirebog Fen.
    ///
    /// The estate agent's line is that everything here is waterfront, which is true, and the
    /// three shots take it at its word: water in the first, water in the second, and the pig
    /// standing in the water by the third. The middle one does the world's scoring the way
    /// every world since the thicket has — the windfall held up in its own light, then the
    /// hazard in the same spot with the light off it — because a player eleven worlds in is
    /// being told what the lotus and the mosquito are, not what a bonus is.
    static func mirebogOpening(start: Date = .now) -> Self {
        Self(
            name: .mirebogOpening,
            shots: [
                Shot(
                    picture: .mirebog(.waterfrontEverywhere),
                    caption: "Mirebog Fen. Waterfront property in every direction."
                ),
                Shot(
                    picture: .mirebog(.lotusAndMosquitoes),
                    caption: "Lotus flowers add a lovely pop of color. The mosquito situation is difficult to overlook."
                ),
                Shot(
                    picture: .mirebog(.describedAsLush),
                    caption: "The listing described it as \"lush.\" That was generous."
                )
            ],
            start: start
        )
    }

    /// The fen's boss briefing.
    ///
    /// Every boss since the thicket has wanted a pen of his own; the croc is the first who also
    /// says which one. So the middle shot is spent on the word *whole* — a channel lit end to
    /// end rather than a croc looking greedy — and the card that follows draws the pen round all
    /// of it, both banks, with the pig's own pen sent up onto dry ground where it cannot be
    /// mistaken for a share of the water.
    static func theWallow(start: Date = .now) -> Self {
        Self(
            name: .theWallow,
            shots: [
                Shot(
                    picture: .mirebog(.oneRequirement),
                    caption: "The crocodile had one requirement: waterfront."
                ),
                Shot(
                    picture: .mirebog(.theWholeThing),
                    caption: "One waterway is enough. But he wants the whole thing."
                ),
                Shot(
                    picture: .mirebog(.aWholeWaterway),
                    caption: "Build separate pens. Fence the crocodile in with one entire waterway."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the fen holds.
    ///
    /// Ten send-offs have pointed sideways at the next listing — over a tree line, along a
    /// shore, down off the ice. This one cannot: the fen goes on being the fen in every
    /// direction a camera can be turned, which is what the first film promised and what the pig
    /// has now bought. So the last shot of the world tilts up instead, and finds the only ground
    /// left in the game that is not underwater.
    static func mirebogHeld(start: Date = .now) -> Self {
        Self(
            name: .mirebogHeld,
            shots: [
                Shot(
                    picture: .mirebog(.veryGreenVeryWet),
                    caption: "Very green. Very wet."
                ),
                Shot(
                    picture: .mirebog(.stillNotSatisfied),
                    caption: "Pig still wasn't quite satisfied."
                ),
                Shot(
                    picture: .mirebog(.onlyOneDirection),
                    caption: "There was really only one direction left."
                )
            ],
            start: start
        )
    }
}
