import AVFoundation
import Observation

/// What actually plays the tune.
///
/// A protocol rather than the player outright, for the same reason the noises and the
/// buzzing go through one: the tests can watch when the game asks for music and when it
/// asks for quiet, without a speaker in the room.
@MainActor
protocol MusicEngine {
    /// Start, or carry on from where it was paused.
    func start()
    /// Pause where it is, so that starting again picks the tune up rather than restarting it.
    func stop()
}

/// The real thing: the one tune the game has, on a loop.
///
/// A sixteen-bar waltz written by `Tools/generate_sounds.py`, rendered so that its last
/// bar's tails wrap round into its first, which is what lets the phone loop it without a
/// seam. It plays on the ambient session, under the noises, and at a fraction of their
/// level: it is there to be under a puzzle, not over one.
@MainActor
final class SpeakerMusic: MusicEngine {
    /// The file the tune is kept in, without its extension.
    static let file = "meadow-waltz"

    private let player: AVAudioPlayer?

    init(bundle: Bundle = .main) {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        player = Self.url(in: bundle).flatMap { try? AVAudioPlayer(contentsOf: $0) }
        player?.numberOfLoops = -1
        player?.volume = 0.35
        player?.prepareToPlay()
    }

    /// Where the tune is, if the bundle asked has it.
    static func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: file, withExtension: "wav")
    }

    func start() {
        // Never over the top of somebody's own music. A player who opened the game with a
        // podcast going has already chosen what to listen to, and the switch in settings
        // is theirs to reach for if they want the waltz instead.
        guard !AVAudioSession.sharedInstance().isOtherAudioPlaying else { return }
        player?.play()
    }

    func stop() {
        player?.pause()
    }
}

/// An engine that plays nothing and remembers whether it was asked to.
final class RecordedMusic: MusicEngine {
    private(set) var isPlaying = false
    /// How many times it was started, since a tune restarted on every toggle of an
    /// unrelated switch would be a tune that never gets past its first bar.
    private(set) var starts = 0

    func start() {
        isPlaying = true
        starts += 1
    }

    func stop() { isPlaying = false }
}

/// Where the player's answer to *do you want the tune* is kept.
protocol MusicStore {
    func loadIsOn() -> Bool
    func save(isOn: Bool)
}

/// The real thing: the switch survives the app being closed.
struct StoredMusic: MusicStore {
    private static let key = "pigpen.music-on"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsOn() -> Bool {
        // Nothing written means on, on the same terms as the noises and the buzzing.
        defaults.object(forKey: Self.key) as? Bool ?? true
    }

    func save(isOn: Bool) {
        defaults.set(isOn, forKey: Self.key)
    }
}

/// A switch that forgets the moment it is put down.
final class RememberedMusic: MusicStore {
    private var isOn: Bool

    init(isOn: Bool = true) {
        self.isOn = isOn
    }

    func loadIsOn() -> Bool { isOn }

    func save(isOn: Bool) { self.isOn = isOn }
}

/// The tune under the game, and the one switch that stops it.
///
/// Whether the waltz is playing is the answer to two questions, not one: does the player
/// want it, and is the game up on the screen. The switch in settings is the first, and the
/// app tells this the second as it comes to the front and goes away again — so the tune
/// stops when the phone is locked or the game is put down, and picks up where it left off
/// when the game comes back. It is a third switch beside the noises and the buzzing rather
/// than a part of either, since a player who wants the knock of the fencing and not a tune
/// under it is not a strange one.
@MainActor
@Observable
final class Music {
    /// The one the game plays through, and the one the settings toggle holds.
    static let shared = Music()

    /// Whether the player wants the tune. Written the moment it changes, since a player who
    /// turns it off and puts the game down means it — and answered straight away, since
    /// a switch that is turned off while the tune plays on is a broken switch.
    var isOn: Bool {
        didSet {
            guard isOn != oldValue else { return }
            store.save(isOn: isOn)
            settle()
        }
    }

    /// Whether the game is up on the screen, as told by the app.
    @ObservationIgnored private var isUp = false
    @ObservationIgnored private let store: any MusicStore
    @ObservationIgnored private let engine: any MusicEngine

    init(store: any MusicStore = StoredMusic(), engine: any MusicEngine = SpeakerMusic()) {
        self.store = store
        self.engine = engine
        self.isOn = store.loadIsOn()
    }

    /// The game has come to the front.
    func resume() {
        isUp = true
        settle()
    }

    /// The game has gone away: to the background, behind the lock screen, or into a call.
    func pause() {
        isUp = false
        settle()
    }

    /// Reads the switch again, for a game that has been in the background while the setting
    /// was changed somewhere else.
    func reload() {
        isOn = store.loadIsOn()
    }

    /// The gate. Both answers have to be yes for the tune to play, and either turning to
    /// no stops it where it is.
    private func settle() {
        if isOn, isUp {
            engine.start()
        } else {
            engine.stop()
        }
    }

    static func resume() { shared.resume() }

    static func pause() { shared.pause() }
}
