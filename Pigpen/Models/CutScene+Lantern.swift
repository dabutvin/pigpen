import Foundation

// MARK: - The carnival's shots

extension CutScene.Picture {
    /// Every shot of the Lantern Carnival's three films.
    ///
    /// The carnival is the seventh place the pig is shown round and the first one that is not a
    /// landscape at all. Six worlds have been ground with weather over it — pasture, wood, ash,
    /// paving, dust, rock — and every one of them was lit by whatever was in its sky. This one
    /// has somebody's fair pitched on top of a field for the week, and the sky has stopped
    /// mattering: the light comes down off a string of lanterns, the skyline is a tent and a
    /// wheel, and the horizon is a crowd. The films are composed around that and nothing else.
    ///
    /// They still rhyme with the meadow's, because every world's three do — arrive and be sold
    /// the place, learn what scores, meet the resident and be told the rule, hold the place, look
    /// past it. What is different is the volume. The thicket's joke was that a buyer cannot see
    /// out of it; the carnival's is that a buyer cannot hear himself think in it, which is a much
    /// harder thing to draw and is why the noise in these shots is drawn as light.
    enum Lantern: Hashable, Sendable {
        // MARK: The carnival's opening

        /// The fair seen whole from the track outside it: the big top, the wheel behind, the
        /// strings already lit over the lot of it, and the pig small at the gate. The last shot
        /// in the film that stands far enough back to take the place in — everything after this
        /// is inside it.
        case theFairground
        /// The concession stand, changing hands halfway through: the popcorn while the line is
        /// calling it a perk, and then the megaphone in the same spot while the line is admitting
        /// what the noise does to the deal. The meadow's apple and skull with the fair's dressing
        /// on, worth exactly what they always were — one at a time, since a player seven worlds
        /// in is being reminded rather than taught.
        case popcornAndMegaphones
        /// The pig in the thick of it under a lit string with the wheel turning overhead: more
        /// lively than the cave, which is a low bar and is being cleared by a mile.
        case moreLivelyThanTheCave

        // MARK: The Center Ring

        /// The ringmaster coming out into his ring under the big top, taking his time about it,
        /// with the pig small at the near edge of the frame. Management, met.
        case theManagement
        /// A fence run building in from the left and stopping dead short of the ring, with the
        /// clearance he keeps round it lying on the sawdust like a spilt light: a tight ship,
        /// and the width of his personal space, drawn rather than argued about.
        case aTightShip
        /// The ring on the ground with a pen opening round the whole of it — the pig, the
        /// ringmaster and the ring all inside, and daylight between the fence and the ring on
        /// every side. The lease in one picture.
        case theRingAndTheFence

        // MARK: The carnival held

        /// The pen holding after dark with every lantern on it, popcorn trodden into the
        /// sawdust, the wheel still going round and the ringmaster still stood in his ring:
        /// food, entertainment, nightlife, and no prospect of it ever stopping.
        case constantNightlife
        /// The pig at the last lantern on the string with his back to the fair, looking out at
        /// a dark line of dunes: somewhere more peaceful, and the first thing all film that is
        /// not lit up.
        case somewhereMorePeaceful
        /// The dunes themselves under a full moon, with the fair a glow left behind on the
        /// skyline and one cactus for company: quiet hours, enforcing themselves.
        case quietHours

        var isCard: Bool {
            switch self {
            case .moreLivelyThanTheCave, .theRingAndTheFence, .quietHours: true
            default: false
            }
        }
    }
}

// MARK: - The carnival's films

extension CutScene {
    /// Before the first walk into the Lantern Carnival.
    ///
    /// Three shots, and the middle one does the work: the world's scoring is the meadow's
    /// scoring in fancy dress, so the popcorn goes up where the apple went and the megaphone
    /// where the skull did, one after the other in time with the two sentences that name them.
    /// The two either side are the fair itself — first from outside it, where it still looks
    /// like a place somebody might live, and then from inside it, where it plainly is not.
    static func lanternOpening(start: Date = .now) -> Self {
        Self(
            name: .lanternOpening,
            shots: [
                Shot(
                    picture: .lantern(.theFairground),
                    caption: "Lantern Carnival. Bright. Bustling. Absolutely no shortage of entertainment."
                ),
                Shot(
                    picture: .lantern(.popcornAndMegaphones),
                    caption: "On-site concessions are a definite perk. The noise alone could sink the deal."
                ),
                Shot(
                    picture: .lantern(.moreLivelyThanTheCave),
                    caption: "It was certainly more lively than the cave."
                )
            ],
            start: start
        )
    }

    /// The carnival's boss briefing.
    ///
    /// Every briefing so far has been about who shares a pen with whom. This one is about a
    /// thing on the floor. The ringmaster will not be moved off his ring and will not have a
    /// post driven anywhere near it, so the rule has a shape rather than a headcount — fence in
    /// all three of them, and leave a gap — and the three shots are the shape being arrived at:
    /// the man, the clearance he keeps, and the fence that has to go round the outside of both.
    static func theCenterRing(start: Date = .now) -> Self {
        Self(
            name: .theCenterRing,
            shots: [
                Shot(
                    picture: .lantern(.theManagement),
                    caption: "Then Pig met management."
                ),
                Shot(
                    picture: .lantern(.aTightShip),
                    caption: "The ringmaster runs a tight ship. Keep your construction out of his personal space."
                ),
                Shot(
                    picture: .lantern(.theRingAndTheFence),
                    caption: "Fence in Pig, the ringmaster, and his ring. But don't let your fence touch the ring. Apparently it's in the lease."
                )
            ],
            start: start
        )
    }

    /// After the last pen in the carnival holds.
    ///
    /// The joke this world was built for. Every other send-off has the pig looking at somewhere
    /// louder, brighter or more spectacular than the place he has just finished paying for; this
    /// is the one where he has finally got everything a listing can promise, all of it at once
    /// and all of it switched on, and what he wants next is for it to stop. So the film walks out
    /// of its own light — lit, then half lit, then a moon over sand — and the next listing is the
    /// only one in the game whose selling point is that there is nothing there.
    static func lanternHeld(start: Date = .now) -> Self {
        Self(
            name: .lanternHeld,
            shots: [
                Shot(
                    picture: .lantern(.constantNightlife),
                    caption: "Food. Entertainment. Nightlife. Constant nightlife."
                ),
                Shot(
                    picture: .lantern(.somewhereMorePeaceful),
                    caption: "Pig decided he wanted somewhere more peaceful."
                ),
                Shot(
                    picture: .lantern(.quietHours),
                    caption: "Somewhere quiet hours practically enforce themselves."
                )
            ],
            start: start
        )
    }
}
