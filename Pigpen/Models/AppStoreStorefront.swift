import StoreKit

/// Where Pigpen sells the one thing it sells.
///
/// Everything else asks `FullGame` whether the game is unlocked; `FullGame` asks a
/// `Storefront`; and this is the storefront wired to the real App Store. Kept behind that
/// seam so the rest of the game — the map, the archive, the offer sheet, and every test over
/// them — never imports StoreKit and never needs a network to run. The only other file that
/// imports it is `AppStoreReviews`, which asks what the player thought of what they bought.
///
/// The full game is one non-consumable product. Ownership is read from `currentEntitlements`,
/// which is Apple's own record of what the Apple ID has bought: it survives a reinstall and
/// is the same on every device the player signs into, so there is no receipt to keep and no
/// server to keep it on.
@MainActor
final class AppStoreStorefront: Storefront {
    /// The full game, as it is written down in App Store Connect. One id, in one place, so
    /// the product the code asks for and the product a reviewer approves are the same string.
    static let productID = "com.pigpen.app.fullgame"

    /// The product once it has been fetched, kept so the price and the purchase do not each
    /// fetch it again.
    private var product: Product?

    /// The full-game product, fetched the first time it is asked for. Nothing when the store
    /// could not be reached or has no such product to sell — either way there is nothing to
    /// buy, and the offer sheet is told as much.
    private func fullGameProduct() async -> Product? {
        if let product { return product }
        product = try? await Product.products(for: [Self.productID]).first
        return product
    }

    func reconcile() async -> StoreStanding? {
        // No product means the store could not be reached, or has nothing to sell: silence,
        // rather than a false *not owned* that would lock a game somebody had paid for.
        guard let product = await fullGameProduct() else { return nil }
        return StoreStanding(owned: await isEntitled(), price: product.displayPrice)
    }

    /// Whether Apple's own record says the full game is owned: a verified, un-refunded
    /// entitlement for the product. An unverified one is not trusted, which is the whole
    /// point of asking StoreKit to verify rather than reading a receipt by hand.
    private func isEntitled() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == Self.productID, transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    func purchase() async -> PurchaseOutcome {
        guard let product = await fullGameProduct() else { return .unavailable }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                // A purchase that will not verify is not a purchase: the game stays locked
                // rather than opening on a signature StoreKit could not vouch for.
                guard case .verified(let transaction) = verification else { return .failed }
                await transaction.finish()
                return .unlocked
            case .userCancelled:
                return .cancelled
            case .pending:
                // Ask to Buy, or any other hold. The yes, if it comes, arrives later through
                // `ownershipUpdates`, so nothing here waits on it.
                return .pending
            @unknown default:
                return .failed
            }
        } catch {
            return .failed
        }
    }

    func restore() async -> Bool {
        // `AppStore.sync` is the button Apple asks every app to have: it pulls the account's
        // purchases down again for the player who reinstalled or switched devices. The
        // entitlements are read afterwards rather than trusting the sync's own return.
        try? await AppStore.sync()
        return await isEntitled()
    }

    func ownershipUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await update in Transaction.updates {
                    guard case .verified(let transaction) = update else { continue }
                    await transaction.finish()
                    if transaction.productID == Self.productID {
                        continuation.yield(transaction.revocationDate == nil)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
