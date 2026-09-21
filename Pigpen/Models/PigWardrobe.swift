import Foundation
import Observation

/// Where the two things the barns remember are kept: which peg the pig is wearing, and who
/// is riding along with her.
///
/// A protocol rather than `UserDefaults` outright, for the same reason the stars and the
/// buzzing go through one: a preview, a test or a screenshot run can dress the pig without
/// reaching into the defaults of the machine it is running on.
protocol WardrobeStore {
    func loadOutfit() -> PigOutfit
    func save(outfit: PigOutfit)
    func loadCompanion() -> PigCompanion
    func save(companion: PigCompanion)
    /// Hangs everything back up and sends everybody home, for the player asking for the game
    /// back as they found it.
    func erase()
}

/// The real thing: the outfit and the company both survive the app being closed.
struct StoredWardrobe: WardrobeStore {
    private static let key = "pigpen.pig-outfit"
    private static let companionKey = "pigpen.pig-companion"
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

    func loadCompanion() -> PigCompanion {
        // The same bargain: nothing written, or a name off a perch this build does not keep,
        // is the pig on her own.
        guard let kept = defaults.string(forKey: Self.companionKey) else { return .nobody }
        return PigCompanion(rawValue: kept) ?? .nobody
    }

    func save(companion: PigCompanion) {
        defaults.set(companion.rawValue, forKey: Self.companionKey)
    }

    func erase() {
        defaults.removeObject(forKey: Self.key)
        defaults.removeObject(forKey: Self.companionKey)
    }
}

/// A wardrobe that forgets the moment it is put down.
final class RememberedWardrobe: WardrobeStore {
    private var outfit: PigOutfit
    private var companion: PigCompanion

    init(outfit: PigOutfit = .asSheComes, companion: PigCompanion = .nobody) {
        self.outfit = outfit
        self.companion = companion
    }

    func loadOutfit() -> PigOutfit { outfit }

    func save(outfit: PigOutfit) { self.outfit = outfit }

    func loadCompanion() -> PigCompanion { companion }

    func save(companion: PigCompanion) { self.companion = companion }

    func erase() {
        outfit = .asSheComes
        companion = .nobody
    }
}

/// What the pig is wearing and who is with her, and the only place in the game those
/// questions are answered.
///
/// Everything that draws her — the board, the trail, the pasture behind the title — reads this
/// one switch, the way everything that shakes the phone goes through `Haptics`. So a hat chosen
/// in the barn is on her head on the next board without a single screen having to be told about
/// it, and there is nowhere for two drawings of the same pig to disagree. The companion is
/// kept here too rather than in a wardrobe of its own, since the two are worn together and
/// every screen that draws one draws the other.
///
/// It is a preference rather than progress: it survives a world being reset on its own, and is
/// only let go when a player asks for the whole game back as they found it — at which point the
/// pig is undressed along with everything else, since the stops that opened the barns have gone
/// with the stars.
@MainActor
@Observable
final class PigWardrobe {
    /// The one the game draws through, and the one both barns dress.
    static let shared = PigWardrobe()

    /// The peg with the tick beside it. Written the moment it changes: a player who puts a
    /// crown on the pig and shuts the game means it.
    var outfit: PigOutfit {
        didSet {
            guard outfit != oldValue else { return }
            store.save(outfit: outfit)
        }
    }

    /// The perch with the tick beside it, in the woodland barn. Written on the same terms.
    var companion: PigCompanion {
        didSet {
            guard companion != oldValue else { return }
            store.save(companion: companion)
        }
    }

    @ObservationIgnored private let store: any WardrobeStore

    init(store: any WardrobeStore = StoredWardrobe()) {
        self.store = store
        self.outfit = store.loadOutfit()
        self.companion = store.loadCompanion()
    }

    func wear(_ outfit: PigOutfit) {
        self.outfit = outfit
    }

    /// Takes a companion off its perch to ride along with her, or `nobody` to send it home.
    func keep(_ companion: PigCompanion) {
        self.companion = companion
    }

    /// Reads the choices again, for a screen that has been sitting behind another one while the
    /// pig was being dressed.
    func reload() {
        outfit = store.loadOutfit()
        companion = store.loadCompanion()
    }

    /// Hangs it all back up and sends everybody home. Called only by the button that throws
    /// every star away: each barn has its own empty peg for a player who simply wants the hats
    /// off, or the pig to herself.
    func eraseEverything() {
        outfit = .asSheComes
        companion = .nobody
        store.erase()
    }

    /// How the pig is described out loud as she stands: what she is wearing, and who is with
    /// her when anybody is.
    var spoken: String {
        companion == .nobody ? outfit.spoken : "\(outfit.spoken), \(companion.spoken)"
    }
}

extension PigWardrobe {
    /// A wardrobe held in memory, so that dressing the pig in a preview, a test or a screenshot
    /// run is not dressing the pig of whoever is looking at it.
    static func remembering(
        _ outfit: PigOutfit = .asSheComes,
        with companion: PigCompanion = .nobody
    ) -> PigWardrobe {
        PigWardrobe(store: RememberedWardrobe(outfit: outfit, companion: companion))
    }
}

/// What a barn hangs on its walls, which is the whole of what a door on a trail leads to:
/// the dressing barn's outfits, or the woodland barn's companions.
///
/// One screen serves both barns — a pig on a stand and a wall of pegs is a pig on a stand
/// and a wall of pegs — and this is what it is told to hang. A door on a map carries one so
/// the map knows which barn stands behind it without either barn's screen having to.
enum BarnRack: String, Hashable, Identifiable, Sendable {
    /// The dressing barn: twelve outfits and the bare peg.
    case outfits
    /// The woodland barn: nine companions and the empty perch.
    case companions

    var id: String { rawValue }
}

/// The barn beside the orchard, and the one thing in the game that is opened by standing next
/// to a level rather than by playing one.
///
/// Which stop opens it lives here rather than in the barn's own screen, because three places
/// need the answer and none of them should be the one that knows it: the settings card that
/// offers the way in, the map that draws the doors open, and the tests that pin the two
/// together.
enum DressingBarn {
    /// The two ways in, named so that what is counted cannot drift from what opened.
    enum Door: String, Sendable {
        /// The barn on the map, tapped.
        case map
        /// The card in settings, which is the way in from anywhere else.
        case settings
    }

    /// The stop it stands beside. Pen this and the doors are open.
    static var beside: PuzzleLevel { .windfallOrchard }

    /// Where to tell a player to go looking, said the way the map would say it.
    static let directions = "Pen Windfall Orchard, the seventh stop in Mudlark Meadow, and the barn opens beside the trail."

    /// Whether the doors are open, read off the ratings the game has kept. Any pen at all on the
    /// stop beside it does it, so a player is never asked to be good at the orchard — only to
    /// have got there.
    static func isOpen(stars: [String: Int]) -> Bool {
        (stars[beside.id] ?? 0) > 0
    }
}

/// The barn beside the fairy ring, four stops into Thornwood Thicket: the second door in the
/// game, and the one where the pig picks up company.
///
/// It stands further in than the dressing barn for two reasons. The thicket is the first
/// world past the meadow, so it is the first thing a player who has held the meadow finds
/// that the meadow did not have — and it is the world walked a level a day by a player who
/// has not paid, so a door four days in is something on that trail worth the four days.
///
/// Kept beside `DressingBarn` rather than folded into it, for the reason that one has: the
/// settings card, the map and the tests all need to know which stop opens it, and none of them
/// should be the one that knows.
enum WoodlandBarn {
    /// The stop it stands beside. Pen this and the doors are open.
    static var beside: PuzzleLevel { .fairyRing }

    /// Where to tell a player to go looking, said the way the map would say it.
    static let directions = "Pen Fairy Ring, the fourth stop in Thornwood Thicket, and the barn opens beside the trail."

    /// Whether the doors are open, on the dressing barn's terms: any pen at all on the stop
    /// beside it.
    static func isOpen(stars: [String: Int]) -> Bool {
        (stars[beside.id] ?? 0) > 0
    }
}
