import Foundation

// MARK: - The cove's shots

extension CutScene.Picture {
    /// Every shot of Tidepool Cove's three films.
    ///
    /// The cove is the ninth market the pig tours and the first with a horizon in it. Eight
    /// worlds have been ground with something standing on it — hills, trees, rock, paving, a big
    /// top, a dune — and the picture has always ended where the land ended. Here the land runs
    /// out a third of the way up the frame and the rest is water, which changes what every shot
    /// is of: the property is the strip of wet sand between the sea and the words, and the view
    /// the listing keeps advertising is the thing that will be taking the property back at some
    /// point this afternoon.
    ///
    /// So the shapes rhyme with the meadow's — arrive, learn the scoring, meet the resident,
    /// hold the place, look past it — and everything in them is the tide's. The ground is what
    /// the water has only just let go of, the amenity is what it left lying there, the hazard is
    /// what it stranded, and the resident lives in a hole full of it.
    enum Tidepool: Hashable, Sendable {
        // MARK: The cove's opening

        /// The cove seen whole from the top of the strand: sea to the horizon, a line of surf,
        /// wet sand with the sky lying in it, a headland shutting one end of it, and the pig
        /// coming down onto the beach. Ocean views, fresh air, prime waterfront, all four
        /// visible at once and one of them moving.
        case theCove
        /// The strand changing hands halfway through: the seashell while the line is calling it
        /// coastal charm, then the jellyfish while the line is admitting what else the coast
        /// brings in. The meadow's apple and skull, wet through — shown one at a time, because a
        /// player nine worlds in is being reminded rather than taught.
        case shellsAndJellyfish
        /// The pig planted on the waterline with the whole cove behind it and a wave running up
        /// over its feet: ready to put in an offer, on ground that is on loan.
        case puttingInAnOffer

        // MARK: The Crab Pool

        /// The crab coming up out of the middle of a rock pool the pig had taken for a puddle:
        /// the guest house, and the guest, discovered in the same second.
        case theGuestHouse
        /// The rule drawn in the order it is said: the crab's own pen closing round its pool
        /// first, and then the pig's opening round the outside of it, which is a plan no other
        /// world has ever asked for.
        case theCrabsOwnPen
        /// Both pens finished, one inside the other, with clear sand all the way round between
        /// them: a pen within a pen and not a post shared, which is what privacy costs here.
        case penWithinAPen

        // MARK: The cove held

        /// Both pens holding at dusk, the crab in its pool inside the pig's ground, shells lying
        /// about the strand — and crabs on the sand outside the fence, arriving, which is the
        /// part of the listing the pig is starting to have an opinion about.
        case coveHeld
        /// The pig walking off up the strand with the crabs behind it and the first cold of
        /// somewhere else coming in off the water: enough sand, enough surf, enough surprises.
        case enoughOfSandAndSurf
        /// The far shore across the water gone white, slopes standing over it, ice on the tide
        /// and the pig looking straight at all of it: the next listing, and it is freezing.
        case nearTheSlopes

        var isCard: Bool {
            switch self {
            case .puttingInAnOffer, .penWithinAPen, .nearTheSlopes: true
            default: false
            }
        }
    }
}

// MARK: - The cove's films

extension CutScene {
    /// Before the first walk down onto Tidepool Cove.
    ///
    /// Three shots and no rules, the way every opening after the meadow's is: what the cove has
    /// to say is that the scoring it already knows has been dressed in seaweed. The seashell
    /// stands where the apple stood and the jellyfish where the skull did, so the middle shot
    /// holds up one and then the other in time with the two sentences over it, and the shots
    /// either side are the water itself — which is the only thing here that is not for sale and
    /// the only thing that will matter.
    static func tidepoolOpening(start: Date = .now) -> Self {
        Self(
            name: .tidepoolOpening,
            shots: [
                Shot(
                    picture: .tidepool(.theCove),
                    caption: "Tidepool Cove. Ocean views. Fresh air. Prime waterfront."
                ),
                Shot(
                    picture: .tidepool(.shellsAndJellyfish),
                    caption: "Seashells add coastal charm. Jellyfish add coastal hazard."
                ),
                Shot(
                    picture: .tidepool(.puttingInAnOffer),
                    caption: "Pig was ready to put in an offer."
                )
            ],
            start: start
        )
    }

    /// The cove's boss briefing.
    ///
    /// Every other resident in the game has been met on open ground and fenced somewhere near
    /// the pig. The crab is met at home — it has a pool, it is not leaving it, and what the
    /// board asks is that the pig's own ground close the whole way round it. That is a picture
    /// no world before this one has had to draw, so the last two shots draw it twice: once in
    /// the order the caption says it, and once finished, with the gap between the two fences
    /// left wide enough to read as the point.
    static func theCrabPool(start: Date = .now) -> Self {
        Self(
            name: .theCrabPool,
            shots: [
                Shot(
                    picture: .tidepool(.theGuestHouse),
                    caption: "Then Pig discovered the property came with a guest house."
                ),
                Shot(
                    picture: .tidepool(.theCrabsOwnPen),
                    caption: "Give the crab its own pen. Then build Pig's around it."
                ),
                Shot(
                    picture: .tidepool(.penWithinAPen),
                    caption: "No shared fences. Everyone likes a little privacy."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the cove holds.
    ///
    /// The listing was accurate and that is the trouble: the views are beautiful, the beach
    /// access is excellent, and the beach keeps bringing people. So the send-off turns the pig
    /// away from the sea for the first time in three films, and what it turns him towards is
    /// cold — the far shore has gone white while nobody was watching it, and a cozy place near
    /// the slopes has never sounded better than it does on a beach full of crabs.
    static func tidepoolHeld(start: Date = .now) -> Self {
        Self(
            name: .tidepoolHeld,
            shots: [
                Shot(
                    picture: .tidepool(.coveHeld),
                    caption: "Beautiful views. Excellent beach access. One too many uninvited guests."
                ),
                Shot(
                    picture: .tidepool(.enoughOfSandAndSurf),
                    caption: "Pig decided he'd had enough of sand, surf, and surprise crustaceans."
                ),
                Shot(
                    picture: .tidepool(.nearTheSlopes),
                    caption: "A cozy place near the slopes sounded hard to beat."
                )
            ],
            start: start
        )
    }
}
