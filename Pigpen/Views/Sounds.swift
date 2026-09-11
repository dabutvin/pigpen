import AVFoundation
import Observation

/// One noise out of the phone. Every case is a moment in the game that has a sound of its
/// own, and every one is named for the moment rather than the sound, so the board asks for
/// *the fence going in* and never has to know what that sounds like this week.
///
/// The raw value is the name of the file that holds it. `Tools/generate_sounds.py` writes
/// the files — none of them is a recording — and `SoundsTests` checks that every case here
/// has one to play.
enum Sound: String, CaseIterable, Equatable {
    /// A post going into the ground.
    case fenceIn = "fence-in"
    /// A piece pulled back up.
    case fenceOut = "fence-out"
    /// The field or the budget saying no.
    case refusal
    /// A word floating off a tile: an animal's call, a signpost unveiled.
    case callout
    /// An apple tapped: five points of good news.
    case bonus
    /// A skull tapped: five points of bad news.
    case penalty
    /// A button taking a press, a page turning, a peg tapped on the barn wall.
    case press
    /// An animal landing after a hop on its lap of honour.
    case hop
    /// The gate shut on a pen that holds, and no more than holds.
    case heldOneStar = "held-one-star"
    /// The gate shut on a good pen.
    case heldTwoStars = "held-two-stars"
    /// The gate shut on a pen worth the level's third star.
    case heldThreeStars = "held-three-stars"
    /// The gate shut on the best pen the map allows — the rainbow.
    case heldBestPen = "held-best-pen"
    /// The gate opened on a gap, or a boss's rule broken.
    case pigAway = "pig-away"
    /// A world held, a new one opening, the whole game bought.
    case fanfare

    /// The file this sound is kept in, if the bundle asked has it.
    func file(in bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: rawValue, withExtension: "wav")
    }

    /// What a pen that holds sounds like, by how well it held. The four are the same climb
    /// cut at different heights, so a player hears how they did before the card says it —
    /// and the best pen there is gets the run right up through the rainbow, whatever the
    /// star count beside it.
    static func held(_ verdict: PenVerdict) -> Sound {
        if verdict.isAsGoodAsItGets { return .heldBestPen }
        switch verdict.stars {
        case ...1: return .heldOneStar
        case 2: return .heldTwoStars
        default: return .heldThreeStars
        }
    }

    /// What tapping a treat sounds like: by its sign, since that is the whole of the news.
    static func tapped(_ treat: Treat) -> Sound {
        treat.worth > 0 ? .bonus : .penalty
    }
}

/// What actually makes the noise.
///
/// A protocol rather than the players outright, for the same reason the buzzing goes
/// through one: the tests can watch what the game asks for without a speaker in the room
/// to ask it of.
@MainActor
protocol SoundEngine {
    func play(_ sound: Sound)
}

/// The real thing: the speaker on the phone.
///
/// Every file is opened and readied once, when the engine is made, so the first fence of a
/// game goes in with its knock rather than a beat behind it. The players are then kept for
/// the life of the app: fourteen short clips is under a megabyte, and a player asked for
/// on every tile of a drag is not one to be opened on every tile of a drag.
@MainActor
final class SpeakerSounds: SoundEngine {
    private var players: [Sound: AVAudioPlayer] = [:]

    init(bundle: Bundle = .main) {
        // Ambient: the game's noises sit under whatever the player already has playing
        // rather than stopping it, and they go quiet with the ring/silent switch. A puzzle
        // played on a train should not need a volume control of its own.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        for sound in Sound.allCases {
            guard let file = sound.file(in: bundle),
                  let player = try? AVAudioPlayer(contentsOf: file) else { continue }
            player.prepareToPlay()
            players[sound] = player
        }
    }

    func play(_ sound: Sound) {
        guard let player = players[sound] else { return }
        // From the top every time. A run of fencing goes in faster than a knock lasts, and
        // each piece should get the whole of its own.
        player.currentTime = 0
        player.play()
    }
}

/// An engine that makes no noise and keeps a list of what it was asked for.
final class RecordedSounds: SoundEngine {
    private(set) var played: [Sound] = []

    func play(_ sound: Sound) { played.append(sound) }
}

/// Where the player's answer to *do you want to hear this* is kept.
protocol SoundsStore {
    func loadIsOn() -> Bool
    func save(isOn: Bool)
}

/// The real thing: the switch survives the app being closed.
struct StoredSounds: SoundsStore {
    private static let key = "pigpen.sounds-on"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsOn() -> Bool {
        // Nothing written means on, on the same terms as the buzzing: the knock of the
        // fencing is part of the game as it comes, and a player who would rather not hear
        // it has the ring/silent switch before they ever have to open settings.
        defaults.object(forKey: Self.key) as? Bool ?? true
    }

    func save(isOn: Bool) {
        defaults.set(isOn, forKey: Self.key)
    }
}

/// A switch that forgets the moment it is put down.
final class RememberedSounds: SoundsStore {
    private var isOn: Bool

    init(isOn: Bool = true) {
        self.isOn = isOn
    }

    func loadIsOn() -> Bool { isOn }

    func save(isOn: Bool) { self.isOn = isOn }
}

/// Everything in the game that makes a noise, and the one switch that stops it.
///
/// The whole game goes through `Sounds.play` rather than reaching for a player where it
/// stands, so that the switch in settings is the only place the question is ever asked — the
/// same bargain the buzzing keeps, and kept separately from it. The two switches are two
/// because the two reasons are: a phone on a table wants the buzz off and the sound on, and a
/// phone in a quiet room wants it the other way round.
///
/// Nothing here shakes the phone. Turning it off takes away only what the ear hears.
@MainActor
@Observable
final class Sounds {
    /// The one the game plays through, and the one the settings toggle holds.
    static let shared = Sounds()

    /// Whether the phone is allowed to make a noise. Written the moment it changes, since a
    /// player who turns it off and puts the game down means it.
    var isOn: Bool {
        didSet {
            guard isOn != oldValue else { return }
            store.save(isOn: isOn)
        }
    }

    @ObservationIgnored private let store: any SoundsStore
    @ObservationIgnored private let engine: any SoundEngine

    init(store: any SoundsStore = StoredSounds(), engine: any SoundEngine = SpeakerSounds()) {
        self.store = store
        self.engine = engine
        self.isOn = store.loadIsOn()
    }

    /// The gate. Everything the game says out loud comes through here, and with the switch
    /// off nothing beyond it is even asked for.
    func play(_ sound: Sound) {
        guard isOn else { return }
        engine.play(sound)
    }

    /// Reads the switch again, for a game that has been in the background while the setting
    /// was changed somewhere else.
    func reload() {
        isOn = store.loadIsOn()
    }

    static func play(_ sound: Sound) { shared.play(sound) }
}
