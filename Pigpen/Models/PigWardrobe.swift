import Foundation
import Observation

/// Where the one thing the dressing room remembers is kept: which peg the pig is wearing.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the stars and the
/// buzzing go through one: a preview, a test or a screenshot run can dress the pig without
/// reaching into the defaults of the machine it is running on.
protocol WardrobeStore {
    func loadOutfit() -> PigOutfit
    func save(outfit: PigOutfit)
    /// Hangs everything back up, for the player asking for the game back as they found it.
    func erase()
}

/// The real thing: the outfit survives the app being closed.
struct StoredWardrobe: WardrobeStore {
    private static let key = "pigpen.pig-outfit"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadOutfit() -> PigOutfit {
        // Nothing written, or a name from a build that hung up a peg this one does not have,
        // both mean the pig as the game ships her. An outfit is decoration: it is never worth
        // refusing to draw a pig over.
        guard let kept = defaults.string(forKey: Self.key) else { return .asSheComes }
        return PigOutfit(rawValue: kept) ?? .asSheComes
    }

    func save(outfit: PigOutfit) {
        defaults.set(outfit.rawValue, forKey: Self.key)
    }

    func erase() {
        defaults.removeObject(forKey: Self.key)
    }
}

/// A wardrobe that forgets the moment it is put down.
final class RememberedWardrobe: WardrobeStore {
    private var outfit: PigOutfit

    init(outfit: PigOutfit = .asSheComes) {
        self.outfit = outfit
    }

    func loadOutfit() -> PigOutfit { outfit }

    func save(outfit: PigOutfit) { self.outfit = outfit }

    func erase() { outfit = .asSheComes }
}

/// What the pig is wearing, and the only place in the game that question is answered.
///
/// Everything that draws her — the board, the trail, the pasture behind the title — reads this
/// one switch, the way everything that shakes the phone goes through `Haptics`. So a hat chosen
/// in the dressing room is on her head on the next board without a single screen having to be
/// told about it, and there is nowhere for two drawings of the same pig to disagree.
///
/// It is a preference rather than progress: it survives a world being reset on its own, and is
/// only let go when a player asks for the whole game back as they found it — at which point the
/// pig is undressed along with everything else, since the lane that opened the room has gone
/// with the stars.
@MainActor
@Observable
final class PigWardrobe {
    /// The one the game draws through, and the one the dressing room dresses.
    static let shared = PigWardrobe()

    /// The peg with the tick beside it. Written the moment it changes: a player who puts a
    /// crown on the pig and shuts the game means it.
    var outfit: PigOutfit {
        didSet {
            guard outfit != oldValue else { return }
            store.save(outfit: outfit)
        }
    }

    @ObservationIgnored private let store: any WardrobeStore

    init(store: any WardrobeStore = StoredWardrobe()) {
        self.store = store
        self.outfit = store.loadOutfit()
    }

    /// Whether there is anything on her at all, which is the one thing the bare peg needs to
    /// know about itself.
    var isDressed: Bool { outfit != .asSheComes }

    func wear(_ outfit: PigOutfit) {
        self.outfit = outfit
    }

    /// Reads the choice again, for a screen that has been sitting behind another one while the
    /// pig was being dressed.
    func reload() {
        outfit = store.loadOutfit()
    }

    /// Hangs it all back up. Called only by the button that throws every star away: the room
    /// itself has the bare peg for a player who simply wants the hats off.
    func eraseEverything() {
        outfit = .asSheComes
        store.erase()
    }
}

extension PigWardrobe {
    /// A wardrobe held in memory, so that dressing the pig in a preview, a test or a screenshot
    /// run is not dressing the pig of whoever is looking at it.
    static func remembering(_ outfit: PigOutfit = .asSheComes) -> PigWardrobe {
        PigWardrobe(store: RememberedWardrobe(outfit: outfit))
    }
}

/// The room at the end of the lane, and the one thing in the game that is opened by a level off
/// a trail rather than by one on it.
///
/// Which level that is lives here rather than in the room's own screen, because three places
/// need the answer and none of them should be the one that knows it: the settings card that
/// offers the way in, the map that throws the doors open the first time the lane gives, and the
/// tests that pin the two together.
enum DressingRoom {
    /// The two ways in, named so that what is counted cannot drift from what opened.
    enum Door: String, Sendable {
        /// The lane giving way, which throws the doors open on the spot.
        case lane
        /// The card in settings, which is the way back in afterwards.
        case settings
    }

    /// The lane that opens it.
    static var lane: PuzzleLevel { .washdayLane }

    /// Where to tell a player to go looking, said the way the map would say it.
    static let directions = "Win the lane off Windfall Orchard, the seventh stop in Mudlark Meadow."

    /// Whether the doors are open, read off the ratings the game has kept. Any pen at all does
    /// it — one star down the lane is the whole price — so a player is never asked to be good
    /// at the side trip, only to take it.
    static func isOpen(stars: [String: Int]) -> Bool {
        (stars[lane.id] ?? 0) > 0
    }
}
