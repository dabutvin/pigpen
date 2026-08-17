import Observation
import UIKit

/// One shake of the phone. The two cases are the two kinds the game asks for: a tap, which
/// is a piece of fencing going into the ground or a button taking a press, and a buzz,
/// which is a verdict — the pen held, the pig away, the field refusing a piece.
enum Haptic: Equatable {
    case tap(UIImpactFeedbackGenerator.FeedbackStyle)
    case buzz(UINotificationFeedbackGenerator.FeedbackType)
}

/// What actually shakes the phone.
///
/// A protocol rather than the feedback generators outright, for the same reason the stars
/// go through a store: the tests can then watch what the game asks for without a phone in
/// the room to ask it of.
@MainActor
protocol HapticEngine {
    func play(_ haptic: Haptic)
}

/// The real thing: the phone in the player's hand.
struct PhoneHaptics: HapticEngine {
    func play(_ haptic: Haptic) {
        switch haptic {
        case let .tap(style):
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        case let .buzz(type):
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
}

/// An engine that shakes nothing and keeps a list of what it was asked for.
final class RecordedHaptics: HapticEngine {
    private(set) var played: [Haptic] = []

    func play(_ haptic: Haptic) { played.append(haptic) }
}

/// Where the player's answer to *do you want to feel this* is kept.
protocol HapticsStore {
    func loadIsOn() -> Bool
    func save(isOn: Bool)
}

/// The real thing: the switch survives the app being closed.
struct StoredHaptics: HapticsStore {
    private static let key = "pigpen.haptics-on"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsOn() -> Bool {
        // Nothing written means on. The buzz is part of the game as it comes — a player who
        // has never opened settings should feel the fencing go in — so the setting is read
        // as a thing turned off rather than a thing turned on.
        defaults.object(forKey: Self.key) as? Bool ?? true
    }

    func save(isOn: Bool) {
        defaults.set(isOn, forKey: Self.key)
    }
}

/// A switch that forgets the moment it is put down.
final class RememberedHaptics: HapticsStore {
    private var isOn: Bool

    init(isOn: Bool = true) {
        self.isOn = isOn
    }

    func loadIsOn() -> Bool { isOn }

    func save(isOn: Bool) { self.isOn = isOn }
}

/// Everything in the game that shakes the phone, and the one switch that stops it.
///
/// The whole game goes through `Haptics.tap` and `Haptics.buzz` rather than reaching for a
/// feedback generator where it stands, so that the switch in settings is the only place the
/// question is ever asked. A phone on a table, a player who cannot stand the buzzing, a
/// battery being nursed to the end of the day: one toggle, and the game plays exactly the
/// same without a word of it anywhere else.
///
/// Nothing here is a sound. Turning it off takes away only what the hand feels.
@MainActor
@Observable
final class Haptics {
    /// The one the game plays through, and the one the settings toggle holds.
    static let shared = Haptics()

    /// Whether the phone is allowed to move. Written the moment it changes, since a player
    /// who turns it off and puts the game down means it.
    var isOn: Bool {
        didSet {
            guard isOn != oldValue else { return }
            store.save(isOn: isOn)
        }
    }

    @ObservationIgnored private let store: any HapticsStore
    @ObservationIgnored private let engine: any HapticEngine

    init(store: any HapticsStore = StoredHaptics(), engine: any HapticEngine = PhoneHaptics()) {
        self.store = store
        self.engine = engine
        self.isOn = store.loadIsOn()
    }

    /// A knock: fencing going in, a button taking a press, a page settling.
    func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        play(.tap(style))
    }

    /// A verdict: the pen held, the pig away, the field refusing a piece.
    func buzz(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        play(.buzz(type))
    }

    /// The gate. Everything the game feels comes through here, and with the switch off
    /// nothing beyond it is even asked for.
    func play(_ haptic: Haptic) {
        guard isOn else { return }
        engine.play(haptic)
    }

    /// Reads the switch again, for a game that has been in the background while the setting
    /// was changed somewhere else.
    func reload() {
        isOn = store.loadIsOn()
    }

    static func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle) { shared.tap(style) }

    static func buzz(_ type: UINotificationFeedbackGenerator.FeedbackType) { shared.buzz(type) }
}
