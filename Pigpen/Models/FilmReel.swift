import Foundation

/// Every film the game has, in the order a player walking the whole journey would meet them:
/// each world's opening, then the briefing before whatever field of it changes the rules, then
/// the send-off once every pen in it is held — world by world from the meadow out to the
/// heights.
///
/// The films are scattered across the game by design. A world keeps its own and plays each one
/// once, at the moment it means something, and `WorldProgress` remembers which have been seen so
/// nobody is sat down in front of one twice. That is right for playing and useless for watching:
/// a player who wants the story told to them end to end, or who skipped one and wishes they had
/// not, has no way back to any of it. A reel is that way back — every film in the game gathered
/// into one running order, held as the specs rather than the films themselves, so asking what is
/// on the reel does not start three dozen clocks.
///
/// It is the whole game's films rather than the ones a player has earned. Somebody who opens the
/// projection room is asking to be shown the story; hiding two thirds of it behind stars they
/// have not taken yet would answer a question nobody asked.
struct FilmReel: Sendable {
    /// Where a film falls in the world that owns it, which is the only thing that tells two
    /// films of the same world apart on a screen that lists them.
    enum Part: Sendable, Equatable {
        /// Before the first field of the world.
        case opening
        /// Before a field that changes the rules — a boss, in every world built so far.
        case briefing
        /// Once every pen in the world is held.
        case farewell

        /// What the reel calls it out loud.
        var word: String {
            switch self {
            case .opening: "Opening"
            case .briefing: "Briefing"
            case .farewell: "Send-off"
            }
        }
    }

    /// One film's billing on the reel: which world it belongs to, where it falls in that world,
    /// and how to raise the curtain on it.
    struct Billing: Sendable, Identifiable {
        /// The world that owns the film, as it is named on the map.
        let world: String
        let part: Part
        /// The film itself, still rolled up. Raised rather than held so the clock starts when
        /// the film goes up rather than when the reel is put together.
        let spec: WorldFilmSpec

        /// A film is told apart by the key its world remembers it by, which is unique across
        /// the whole game.
        var id: String { spec.key }

        /// The line over a film while it plays: the world, and which of its three this is.
        var title: String { "\(world) · \(part.word)" }

        /// The film, its clock started now.
        func raise(at start: Date = .now) -> WorldFilm { spec.raise(at: start) }
    }

    let billings: [Billing]

    var count: Int { billings.count }
    var isEmpty: Bool { billings.isEmpty }
    subscript(index: Int) -> Billing { billings[index] }

    /// The billing at an index, or nothing once the reel has run out — which is what says the
    /// projection room is done rather than the caller having to count.
    func billing(at index: Int) -> Billing? {
        billings.indices.contains(index) ? billings[index] : nil
    }

    /// Where the reel goes when a film ends, is skipped, or is tapped past: the next film, or
    /// nothing at all, which is the reel run out and the projection room done.
    func onward(from index: Int) -> Int? {
        billings.indices.contains(index + 1) ? index + 1 : nil
    }

    /// Where a step back lands: the film before this one, or this one over again at the head of
    /// the reel.
    ///
    /// A swipe back off the first film rewinds it rather than doing nothing. Nothing is the one
    /// answer a gesture must never give — a player who swipes and sees no change cannot tell a
    /// reel that has no more to go back to from a screen that did not feel the swipe at all.
    func backward(from index: Int) -> Int {
        max(min(index, count - 1) - 1, 0)
    }

    /// How long the whole reel runs, films only — the beat a player spends deciding to skip one
    /// is their own business. Read off the films rather than kept alongside them, so a script
    /// that grows a shot moves the number on the button by itself.
    var runtime: TimeInterval {
        billings.reduce(0) { $0 + $1.raise().runtime }
    }
}

extension FilmReel {
    /// The films one world has, in the order it plays them: the opening, then any briefing in
    /// trail order, then the send-off. Briefings are kept by level id rather than in a list, so
    /// the trail is what puts them in order — a world that ever briefs two fields gets them the
    /// way a player would meet them rather than the way a dictionary happens to hold them.
    static func billings(of world: GameWorld) -> [Billing] {
        var reel: [Billing] = []
        if let opening = world.opening {
            reel.append(Billing(world: world.name, part: .opening, spec: opening))
        }
        for node in world.map.nodes {
            guard let briefing = world.briefing(before: node.id) else { continue }
            reel.append(Billing(world: world.name, part: .briefing, spec: briefing))
        }
        if let farewell = world.farewell {
            reel.append(Billing(world: world.name, part: .farewell, spec: farewell))
        }
        return reel
    }

    /// Every film in a universe, world by world in the order they open.
    init(universe: Universe) {
        var reel: [Billing] = []
        for world in universe.worlds {
            guard let game = world.game else { continue }
            reel += FilmReel.billings(of: game)
        }
        billings = reel
    }

    /// The whole game's reel: every film of every world there is.
    static let everything = FilmReel(universe: .all)
}
