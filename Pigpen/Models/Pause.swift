import Foundation

extension Task where Success == Never, Failure == Never {
    /// Waits out `duration`, and says whether the wait ran to the end rather than being
    /// called off part way through.
    ///
    /// Every animation in this game is a run of waits inside a task the view owns, and that
    /// task is cancelled the moment the board moves on underneath it — the field cleared,
    /// the animals fetched back, the phase changed. Sleeping with `try?` swallows the
    /// cancellation, so the animation carries on stepping over a board that has already been
    /// put back, and leaves a mark standing where the board no longer keeps an animal.
    /// Waiting through here hands the cancellation back instead, as a `false` for the caller
    /// to stop on.
    static func pausing(for duration: Duration) async -> Bool {
        do {
            try await Task.sleep(for: duration)
            return true
        } catch {
            return false
        }
    }
}
