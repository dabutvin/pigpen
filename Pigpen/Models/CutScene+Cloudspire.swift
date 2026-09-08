import Foundation

// MARK: - The heights' shots

extension CutScene.Picture {
    /// Every shot of Cloudspire Heights' three films — thirteen of them, because the last one
    /// is the end of the game and takes seven.
    ///
    /// The heights are the twelfth market and the last, so their films are built the way the
    /// other eleven were — arrive, learn the property, meet the resident, hold the place — right
    /// up until the point where there is nowhere left to be sold, and then the shape breaks. No
    /// world's send-off has ever done anything but point at the next listing. This one has no
    /// next listing to point at, so it turns round and points at the first one instead.
    ///
    /// What the camera is pointed at up here is a horizon that is not ground. Every other world
    /// stands on something: pasture, leaf mould, ash, paving, sand, ice, peat. A spire top stands
    /// on nothing, and the whole look of these shots is that the turf runs out a little way
    /// either side of whoever is stood on it and after that there is only weather, a long way
    /// down, with the eleven worlds the pig has already bought somewhere underneath it out of
    /// sight. A listing with absolutely no flood risk is one with no ground under it, and the
    /// pictures say so before the captions get a chance to.
    enum Cloudspire: Hashable, Sendable {
        // MARK: The heights' opening

        /// The spires themselves, standing out of the cloud sea with the sun full on their turf
        /// caps, and the pig small at the rim of the nearest one: fresh air, endless views, and
        /// a property line that ends in mid-air on all four sides.
        case theSpires
        /// The terrace that changes weather halfway through: the rainbow while the line is
        /// selling it as instant appeal, then the storm while the line is admitting what it does
        /// to the place. The meadow's apple and skull, one world of dressing later and worth
        /// exactly what they always were — shown one at a time, because a player this far in has
        /// been told eleven times.
        case rainbowsAndStorms
        /// One pinnacle, the pig on the top of it, a rainbow over the lot and nothing under any
        /// of it: the property search, officially off the ground.
        case offTheGround

        // MARK: The Eyrie

        /// The eagle coming down onto a needle of rock that stands over the pig's terrace, and
        /// the pig looking up at it: the neighbour, met — and this one arrives from above, which
        /// no neighbour in eleven worlds has managed.
        case strictOversight
        /// The perch with four lines of sight running off it to the edges of the frame — up,
        /// down, and both ways along — opening one after another in the order the caption names
        /// them, with the pig caught standing in one of them.
        case theLineOfSight
        /// The rule drawn rather than written: the perch off in one corner with its two lines
        /// ruled across the whole frame, and a ghost pen opened round the pig in the one quarter
        /// of the terrace that neither line reaches.
        case outOfSight

        // MARK: The heights held, and the end of the game

        /// The pig on the highest terrace at nightfall with every spire he has ever toured
        /// standing away into the dark behind him: twelve markets, seen at once and from above.
        case everyMarket
        /// Every boss in the game ringed round him and arriving one at a time — the stag first,
        /// the eagle last, in the order he met them. The cast list, taken as a photograph.
        case interestingNeighbors
        /// The poky farm pen from the first shot of the first film, painted exactly as the
        /// opening painted it: what the pig has finally worked out he wanted, which is what he
        /// already had.
        case whatHeWanted
        /// The same pen rebuilt on the top of a spire, to the inch: the identical rectangle of
        /// gold in the middle of the emptiest lot in the game, with apples staked outside it.
        /// Twelve markets to arrive back at the floor plan he started with.
        case theBestPen
        /// The neighbours coming up over the rim of the terrace, all round, one at a time. The
        /// caption says there was one problem. There are twelve.
        case oneProblem
        /// The ring closing on the pen: the same crowd, nearer, with the camera pushing in on
        /// what is about to happen to the square footage.
        case wordOfMouth
        /// The last frame of the game: the pen crammed with every animal the pig has met, him
        /// somewhere in the middle of it, and the whole night sky left empty overhead for the
        /// line to land in.
        case openHouse

        var isCard: Bool {
            switch self {
            case .offTheGround, .outOfSight, .openHouse: true
            default: false
            }
        }
    }
}

// MARK: - The heights' films

extension CutScene {
    /// Before the first walk onto the heights.
    ///
    /// The twelfth arrival and the shortest sell in the game, because by now the joke tells
    /// itself: absolutely no flood risk is a fine thing to promise about a field with no ground
    /// under it. The middle shot does the job it does in every world — the windfall held up in
    /// its own light and then the hazard in the same spot with the light off it — and the two
    /// either side of it are the drop.
    static func cloudspireOpening(start: Date = .now) -> Self {
        Self(
            name: .cloudspireOpening,
            shots: [
                Shot(
                    picture: .cloudspire(.theSpires),
                    caption: "Cloudspire Heights. Fresh air. Endless views. Absolutely no flood risk."
                ),
                Shot(
                    picture: .cloudspire(.rainbowsAndStorms),
                    caption: "A rainbow adds instant appeal. Severe weather is a notable drawback."
                ),
                Shot(
                    picture: .cloudspire(.offTheGround),
                    caption: "Pig's property search had officially left the ground."
                )
            ],
            start: start
        )
    }

    /// The heights' boss briefing, and the last rule the game has.
    ///
    /// Eleven neighbours have cared where the pens went. This one cares what he can see, which
    /// is a rule about lines rather than about ground, and so the three shots go: the resident
    /// arrives from above, the lines come out of him, and the pen is opened in the one place the
    /// lines do not reach. It is the only briefing in the game whose middle shot is the rule
    /// itself rather than the two of them sizing each other up — there is nothing to size up
    /// when the neighbour is forty feet over your head and not coming down.
    static func theEyrie(start: Date = .now) -> Self {
        Self(
            name: .theEyrie,
            shots: [
                Shot(
                    picture: .cloudspire(.strictOversight),
                    caption: "Unfortunately, the neighborhood had very strict oversight."
                ),
                Shot(
                    picture: .cloudspire(.theLineOfSight),
                    caption: "The eagle sees everything directly above, below, and beside it. Everything."
                ),
                Shot(
                    picture: .cloudspire(.outOfSight),
                    caption: "Fence in Pig. Keep every piece of fence out of the eagle's line of sight. The homeowners association is watching."
                )
            ],
            start: start
        )
    }

    /// The last film in the game, and the only one that is seven shots long.
    ///
    /// Every send-off before this one has been three: the place held, a look past it, and the
    /// next listing. There is no next listing. So this one spends its extra four shots doing the
    /// only thing left — going back. The pig totals up twelve markets, has his neighbours
    /// gathered round him for the photograph, remembers the pen he started in, builds it again
    /// on top of a spire, and is then visited by everybody at once.
    ///
    /// The third shot is the whole point of the film and is not painted here at all: it is the
    /// opening's own first frame, borrowed intact. A game that ends where it began should end on
    /// the same picture it began on, not on a fresh drawing of it.
    static func cloudspireHeld(start: Date = .now) -> Self {
        Self(
            name: .cloudspireHeld,
            shots: [
                Shot(
                    picture: .cloudspire(.everyMarket),
                    caption: "And that was it. Pig had toured every market imaginable."
                ),
                Shot(
                    picture: .cloudspire(.interestingNeighbors),
                    caption: "He'd met some interesting neighbors. Very interesting neighbors."
                ),
                Shot(
                    picture: .cloudspire(.whatHeWanted),
                    caption: "After all that, Pig finally knew exactly what he wanted."
                ),
                Shot(
                    picture: .cloudspire(.theBestPen),
                    caption: "The best pen was already his. Plenty of space. Apples nearby. No fine print."
                ),
                Shot(
                    picture: .cloudspire(.oneProblem),
                    caption: "There was just one problem."
                ),
                Shot(
                    picture: .cloudspire(.wordOfMouth),
                    caption: "Apparently the listing had excellent word of mouth."
                ),
                Shot(
                    picture: .cloudspire(.openHouse),
                    caption: "Open house was a mistake."
                )
            ],
            start: start
        )
    }
}
