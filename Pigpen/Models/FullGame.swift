import Foundation
import Observation

/// How a purchase went, in the four ways it can go: bought, backed out of, waiting on
/// somebody else's yes, or gone wrong. `unavailable` is the last of those with a name of
/// its own, because a store the phone could not reach is a thing the offer sheet has to be
/// able to say rather than a plain failure.
enum PurchaseOutcome: Sendable, Equatable {
    /// Bought and owned now.
    case unlocked
    /// The player closed the App Store's own sheet without buying.
    case cancelled
    /// Sent to somebody who has to approve it — Ask to Buy on a child's phone — and not yet
    /// answered. The game stays as it was; the yes arrives later, on its own, if it arrives.
    case pending
    /// Something went wrong putting the purchase through.
    case failed
    /// There was nothing to buy: no product came back, or the store could not be reached.
    case unavailable
}

/// What the App Store last told us about the one thing Pigpen sells: whether it is owned,
/// and what it costs in the player's own money.
struct StoreStanding: Sendable, Equatable {
    let owned: Bool
    /// The price to put on the button, already formatted in the storefront's currency, or
    /// nothing on a phone whose store answered without one.
    let price: String?
}

/// Where the last-known answer to *has the full game been bought* is kept on the device.
///
/// A soft cache rather than the truth: the App Store's own receipt is the truth, and it is
/// read back at every launch. This is only so the game can lock or unlock the instant it
/// draws, before the store has had a chance to answer — a map that flickered shut for a
/// second every launch on a phone that had paid would be worse than no cache at all.
protocol UnlockStore {
    func loadIsUnlocked() -> Bool
    func save(isUnlocked: Bool)
}

/// The real thing: what was bought survives the app being closed.
struct StoredUnlock: UnlockStore {
    private static let key = "pigpen.full-game-unlocked"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadIsUnlocked() -> Bool {
        // Nothing written means locked: the game ships as the meadow and the day, and the
        // rest is bought. The absent default is `false`, which is the right one here.
        defaults.bool(forKey: Self.key)
    }

    func save(isUnlocked: Bool) {
        defaults.set(isUnlocked, forKey: Self.key)
    }
}

/// A cache that forgets the moment it is put down, for previews and tests.
final class RememberedUnlock: UnlockStore {
    private var unlocked: Bool

    init(isUnlocked: Bool = false) {
        self.unlocked = isUnlocked
    }

    func loadIsUnlocked() -> Bool { unlocked }
    func save(isUnlocked: Bool) { unlocked = isUnlocked }
}

/// The App Store, on the other end of the one purchase Pigpen has.
///
/// A protocol rather than StoreKit outright, for the same reason the world's progress goes
/// through one: the tests and the previews can hand the game a store that is already owned,
/// still asking, or refusing, without anything talking to Apple on the machine they run on.
/// The real one lives in `AppStoreStorefront`, and is the only place in the game that
/// imports StoreKit.
@MainActor
protocol Storefront {
    /// Asks the App Store where things really stand — whether the full game is owned, and
    /// what it costs — and hands the answer back. Nothing at all when the store could not be
    /// reached, which is different from a store that answered *not owned*: one is silence,
    /// the other is a no, and only the second should ever lock a game that thought it was open.
    func reconcile() async -> StoreStanding?

    /// Puts the purchase through, showing the App Store's own sheet. Returns how it went.
    func purchase() async -> PurchaseOutcome

    /// Restores a purchase made on another device or before a reinstall. Returns whether the
    /// full game is owned once the dust settles.
    func restore() async -> Bool

    /// Ownership the store pushes on its own, after the game has stopped asking: a purchase a
    /// parent approves an hour later, a refund, a buy made on another device on the same
    /// Apple ID. Each value is the new ownership.
    func ownershipUpdates() -> AsyncStream<Bool>
}

/// A storefront held in memory, so a preview or a test can stand the game up already owned,
/// or refusing to sell, without a word to Apple.
@MainActor
final class RememberedStorefront: Storefront {
    private(set) var owned: Bool
    private let price: String?
    /// Whether the store can be reached at all. A storefront told it cannot returns silence
    /// from `reconcile`, which is how the offer sheet's "the store could not be reached" line
    /// is put under test.
    private let reachable: Bool
    /// What the next `purchase` will do. Defaults to selling; a test can set it to a cancel,
    /// a pending ask, or a failure to walk the offer sheet through each ending.
    var nextPurchase: PurchaseOutcome
    /// Whether a `restore` finds anything. A device that never bought it restores nothing.
    var restores: Bool

    private var pushes: [AsyncStream<Bool>.Continuation] = []

    /// Whether anybody is listening for pushes yet — true once `ownershipUpdates` has been
    /// asked for. A test waits on this before pushing, so the push is not sent into a stream
    /// nobody has subscribed to.
    var isWatched: Bool { !pushes.isEmpty }

    init(
        owned: Bool = false,
        price: String? = nil,
        reachable: Bool = true,
        nextPurchase: PurchaseOutcome = .unlocked,
        restores: Bool = false
    ) {
        self.owned = owned
        self.price = price
        self.reachable = reachable
        self.nextPurchase = nextPurchase
        self.restores = restores
    }

    func reconcile() async -> StoreStanding? {
        guard reachable else { return nil }
        return StoreStanding(owned: owned, price: price)
    }

    func purchase() async -> PurchaseOutcome {
        if nextPurchase == .unlocked { owned = true }
        return nextPurchase
    }

    func restore() async -> Bool {
        if restores { owned = true }
        return owned
    }

    func ownershipUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            pushes.append(continuation)
        }
    }

    /// Stands in for the App Store pushing a change on its own — a refund, a family member's
    /// approval — so the listening path can be put under test.
    func push(owned: Bool) {
        self.owned = owned
        for continuation in pushes {
            continuation.yield(owned)
        }
    }
}

/// Whether the full game has been bought, and the one purchase that buys it.
///
/// Pigpen ships as the meadow and the day: the first world, played end to end, and today's
/// board every morning. Everything past that — every other world on the universe map, and
/// every day but today in the archive — is the full game, unlocked once with a single
/// non-consumable purchase and owned for good after.
///
/// It is built the way `Analytics` is, with two seams rather than one: a `store`, where the
/// last-known answer is cached so the game can gate itself the instant it draws, and a
/// `storefront`, which is the App Store itself. The store is a convenience; the storefront is
/// the truth, read back at launch and listened to for anything it pushes afterwards.
///
/// The purchase is not game data. Clearing every star a player owns leaves it alone, the same
/// way clearing the stars leaves the buzzing and the counting switches alone: a player asking
/// for the game back as they found it has not asked to un-buy it, and nothing in the clear
/// path so much as mentions this file.
@MainActor
@Observable
final class FullGame {
    /// The one the whole game asks through, so the wall stands in the same place on every
    /// screen — the map, the archive and the settings sheet are all looking at this switch.
    static let shared = FullGame()

    /// Whether the meadow's fence has been thrown wide: every world open on the map, every
    /// day open in the archive. Seeded from the device so the game gates itself before the
    /// App Store has answered, then corrected by whatever the store says.
    private(set) var isUnlocked: Bool

    /// The price to put on the button, in the player's own money, once the store has said
    /// what it is. Nothing until then — and nothing on a phone that cannot reach the store,
    /// which is what the offer sheet leans on to know it has a price worth showing.
    private(set) var price: String?

    /// Whether a purchase or a restore is in flight, so the buttons can say so and cannot be
    /// pressed into starting a second one over the first.
    private(set) var isWorking = false

    @ObservationIgnored private let store: any UnlockStore
    @ObservationIgnored private let storefront: any Storefront
    /// The listener on the store's own pushes, started once and kept for the life of the app.
    @ObservationIgnored private var watcher: Task<Void, Never>?

    init(
        store: any UnlockStore = StoredUnlock(),
        storefront: any Storefront = AppStoreStorefront(),
        price: String? = nil
    ) {
        self.store = store
        self.storefront = storefront
        self.isUnlocked = store.loadIsUnlocked()
        self.price = price
    }

    /// Reconciles with the App Store once and then listens for anything it pushes afterwards.
    /// Called at launch, and safe to call again — the listener is only ever started once.
    func watch() {
        guard watcher == nil else { return }
        watcher = Task { [weak self] in
            await self?.reconcile()
            guard let self else { return }
            for await owned in storefront.ownershipUpdates() {
                apply(owned: owned)
            }
        }
    }

    /// Asks the store where things stand and takes the answer as the truth — the price to
    /// show, and whether the game is owned. Silence from the store leaves everything as it
    /// was: a phone that could not reach Apple keeps whatever the cache last knew.
    func reconcile() async {
        guard let standing = await storefront.reconcile() else { return }
        if let found = standing.price { price = found }
        apply(owned: standing.owned)
    }

    /// Buys the full game, showing the App Store's own sheet. Returns how it went, so the
    /// offer sheet can close on a sale, hold on a pending ask, or say its piece on a failure.
    @discardableResult
    func buy() async -> PurchaseOutcome {
        guard !isUnlocked else { return .unlocked }
        isWorking = true
        defer { isWorking = false }
        let outcome = await storefront.purchase()
        if outcome == .unlocked { apply(owned: true) }
        return outcome
    }

    /// Restores a purchase made elsewhere. Returns whether the full game is owned once it is
    /// done, so the caller can say whether anything was found.
    @discardableResult
    func restore() async -> Bool {
        isWorking = true
        defer { isWorking = false }
        let owned = await storefront.restore()
        apply(owned: owned)
        return owned
    }

    /// Writes a new standing down, on the screen and in the cache, but only when it has
    /// actually moved — so a store that keeps saying *still owned* does not write the same
    /// bool to disk on every launch.
    private func apply(owned: Bool) {
        guard owned != isUnlocked else { return }
        isUnlocked = owned
        store.save(isUnlocked: owned)
    }
}

extension FullGame {
    /// The game already bought, held in memory — for previews and screenshots that want the
    /// whole map open and the whole archive walkable, and nothing bought on the machine the
    /// picture is taken on.
    static func unlocked() -> FullGame {
        FullGame(
            store: RememberedUnlock(isUnlocked: true),
            storefront: RememberedStorefront(owned: true)
        )
    }

    /// The game not yet bought, with a price ready to show — for previews of the offer, the
    /// for-sale worlds on the map, and the upgrade card behind the gear.
    static func locked(price: String? = "$3.99") -> FullGame {
        FullGame(
            store: RememberedUnlock(isUnlocked: false),
            storefront: RememberedStorefront(owned: false, price: price),
            price: price
        )
    }
}
