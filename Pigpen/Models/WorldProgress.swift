import Foundation
import Observation

/// Where a player's best star rating for each level is kept.
///
/// A protocol rather than `UserDefaults` outright, so the tests, the previews and the
/// screenshot runs can hand the map a world part-way through without touching what is
/// on the device.
protocol ProgressStore {
    func loadStars() -> [String: Int]
    func save(_ stars: [String: Int])
    /// Which levels have given up the best pen they have in them, by level id. Kept beside
    /// the stars rather than inside them because three stars is set a little under the
    /// maximum: a level can be worth three and still have something left to beat.
    func loadBestPens() -> Set<String>
    func save(bestPens: Set<String>)
    /// The fencing that was down when the best pen of each level was released, by level id,
    /// each wall written as `"row,column"` tiles. Kept so a level gone back to opens with
    /// the best it has ever given up on show, and *Put it back* something to offer.
    func loadSubmittedPens() -> [String: [String]]
    func save(submittedPens: [String: [String]])
    /// Which films have been played already, by name. Worth keeping even where the stars
    /// nearly say it on their own: a player who watches one, backs out without penning
    /// anything and comes back has still seen it.
    func loadPlayedScenes() -> Set<String>
    func markScenePlayed(_ scene: String)
    /// Throws the lot away, for the player who wants the game back as they found it —
    /// the opening included, since that is part of finding it.
    func erase()
}

/// The real thing: stars survive the app being closed.
struct StoredProgress: ProgressStore {
    private static let key = "pigpen.best-stars"
    private static let bestPensKey = "pigpen.best-pens"
    private static let submittedPensKey = "pigpen.submitted-pens"
    private static let scenesKey = "pigpen.scenes-played"
    /// What the opening was kept under before there was more than one film. Read so that
    /// somebody already playing is not sat back down in front of it.
    private static let oldOpeningKey = "pigpen.opening-seen"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStars() -> [String: Int] {
        defaults.dictionary(forKey: Self.key) as? [String: Int] ?? [:]
    }

    func save(_ stars: [String: Int]) {
        defaults.set(stars, forKey: Self.key)
    }

    func loadBestPens() -> Set<String> {
        Set(defaults.stringArray(forKey: Self.bestPensKey) ?? [])
    }

    func save(bestPens: Set<String>) {
        defaults.set(Array(bestPens), forKey: Self.bestPensKey)
    }

    func loadSubmittedPens() -> [String: [String]] {
        defaults.dictionary(forKey: Self.submittedPensKey) as? [String: [String]] ?? [:]
    }

    func save(submittedPens: [String: [String]]) {
        defaults.set(submittedPens, forKey: Self.submittedPensKey)
    }

    func loadPlayedScenes() -> Set<String> {
        var played = Set(defaults.stringArray(forKey: Self.scenesKey) ?? [])
        if defaults.bool(forKey: Self.oldOpeningKey) {
            played.insert(CutScene.Name.opening.rawValue)
        }
        return played
    }

    func markScenePlayed(_ scene: String) {
        var played = loadPlayedScenes()
        played.insert(scene)
        defaults.set(Array(played), forKey: Self.scenesKey)
    }

    func erase() {
        defaults.removeObject(forKey: Self.key)
        defaults.removeObject(forKey: Self.bestPensKey)
        defaults.removeObject(forKey: Self.submittedPensKey)
        defaults.removeObject(forKey: Self.scenesKey)
        defaults.removeObject(forKey: Self.oldOpeningKey)
    }
}

/// A world that forgets everything the moment it is put down.
final class RememberedProgress: ProgressStore {
    private var stars: [String: Int]
    private var bestPens: Set<String>
    private var submittedPens: [String: [String]]
    private var scenes: Set<String>

    init(
        stars: [String: Int] = [:],
        bestPens: Set<String> = [],
        submittedPens: [String: [String]] = [:],
        scenesPlayed: Set<String> = []
    ) {
        self.stars = stars
        self.bestPens = bestPens
        self.submittedPens = submittedPens
        self.scenes = scenesPlayed
    }

    func loadStars() -> [String: Int] { stars }

    func save(_ stars: [String: Int]) { self.stars = stars }

    func loadBestPens() -> Set<String> { bestPens }

    func save(bestPens: Set<String>) { self.bestPens = bestPens }

    func loadSubmittedPens() -> [String: [String]] { submittedPens }

    func save(submittedPens: [String: [String]]) { self.submittedPens = submittedPens }

    func loadPlayedScenes() -> Set<String> { scenes }

    func markScenePlayed(_ scene: String) { scenes.insert(scene) }

    func erase() {
        stars = [:]
        bestPens = []
        submittedPens = [:]
        scenes = []
    }
}

/// How far a player has got through a world: the best rating earned on every level, and
/// therefore which levels are open.
///
/// A level opens as soon as the one before it has been penned at all, so the trail can
/// only ever be blocked by a puzzle you have not solved — never by one you solved badly.
/// Going back to an old level and doing worse than last time changes nothing: the map
/// keeps the best you have ever done.
///
/// The one exception is a stop with a star toll on it. The meadow's boss wants most of the
/// stars the trail below it holds, so beating the level before it is not enough — the
/// player has to go back and better their pens, and the stars they win doing it open it
/// wherever on the trail they happen to be standing.
@MainActor
@Observable
final class WorldProgress {
    let world: WorldMap
    private(set) var bestStars: [String: Int]
    /// The levels whose best pen has been found, by id. A level is in here for good once
    /// it has given its maximum up: a worse pen afterwards no more takes the rainbow off
    /// a signpost than it takes the stars off one.
    private(set) var bestPens: Set<String>
    /// The fencing that held the best pen each level has given up, by level id. Kept beside
    /// the stars so a level played again opens on what it has already been made to hold
    /// rather than on a blank tally.
    private(set) var submittedPens: [String: [String]]
    /// Which films have been played already.
    private(set) var playedScenes: Set<String>
    @ObservationIgnored private let store: any ProgressStore

    init(world: WorldMap = .mudlarkMeadow, store: any ProgressStore = StoredProgress()) {
        self.world = world
        self.store = store
        self.bestStars = store.loadStars()
        self.bestPens = store.loadBestPens()
        self.submittedPens = store.loadSubmittedPens()
        self.playedScenes = store.loadPlayedScenes()
    }

    /// The best rating earned on a level, or 0 for one nobody has held a pig in yet.
    func stars(for levelID: String) -> Int {
        bestStars[levelID] ?? 0
    }

    func stars(at index: Int) -> Int {
        world.nodes.indices.contains(index) ? stars(for: world[index].id) : 0
    }

    /// Whether the best pen a level has in it has been found there — the one thing three
    /// stars does not say on its own, and what turns a signpost's stars rainbow.
    func hasTheBestPen(for levelID: String) -> Bool {
        bestPens.contains(levelID)
    }

    func hasTheBestPen(at index: Int) -> Bool {
        world.nodes.indices.contains(index) && hasTheBestPen(for: world[index].id)
    }

    /// The fencing that held the best pen a level has ever given up, and nothing for one
    /// nobody has held a pig in yet. A level opened again lays this behind the board as its
    /// best so far, so the tally starts where the player left off rather than at nothing.
    func submittedFences(for levelID: String) -> Set<GridPoint>? {
        guard let tiles = submittedPens[levelID], !tiles.isEmpty else { return nil }
        let fences = Set(tiles.compactMap(GridPoint.init(stored:)))
        return fences.isEmpty ? nil : fences
    }

    func isCleared(_ index: Int) -> Bool { stars(at: index) > 0 }

    /// How far along the trail play has got: the first level still to be cleared, or the
    /// last stop on the map once the whole world is done. A stop with a star toll on it
    /// can still be shut inside that.
    private var reached: Int {
        for index in world.nodes.indices where !isCleared(index) {
            return index
        }
        return max(world.count - 1, 0)
    }

    /// The stop the pig stands at when nothing else has moved it: the furthest one open
    /// to it. A boss whose toll has not been paid is not a stop to stand at, so the pig
    /// waits below it until the stars for it are in.
    var frontier: Int {
        var stop = reached
        while stop > 0, !isTollPaid(stop) {
            stop -= 1
        }
        return stop
    }

    /// Whether a level can be played: the trail has to have reached it and any stars it
    /// asks for have to be won already. Everything behind the frontier stays open, which
    /// is what lets a player walk back down the trail to a level they have already beaten
    /// — and what lets them go back for the stars a boss is waiting on.
    func isUnlocked(_ index: Int) -> Bool {
        index >= 0 && index <= reached && isTollPaid(index)
    }

    /// Whether the world holds the stars a stop asks for. Every level but the boss asks
    /// for none, so this is true of all of them.
    func isTollPaid(_ index: Int) -> Bool {
        guard world.nodes.indices.contains(index) else { return false }
        return totalStars >= world[index].starToll
    }

    var clearedCount: Int {
        world.nodes.indices.filter { isCleared($0) }.count
    }

    var totalStars: Int {
        world.nodes.reduce(0) { $0 + stars(for: $1.id) }
    }

    /// Records how a level went: its stars, the rainbow if the pen was the best that map
    /// has in it, and the fencing that held it. All three are kept at the best they have
    /// ever been, so a worse go later costs nothing.
    ///
    /// - Parameter fences: The wall that was standing when the animals were released. Hand
    ///   nothing in for a caller with no wall to file — the stars stand on their own.
    ///
    /// Returns whether this opened the next level up — the pig's cue to walk on.
    @discardableResult
    func record(
        _ verdict: PenVerdict,
        fences: Set<GridPoint> = [],
        for levelID: String
    ) -> Bool {
        guard world.index(of: levelID) != nil else { return false }

        if verdict.isAsGoodAsItGets, verdict.stars > 0, !bestPens.contains(levelID) {
            bestPens.insert(levelID)
            store.save(bestPens: bestPens)
        }

        if verdict.stars > 0, isWorthKeeping(fences, for: levelID) {
            submittedPens[levelID] = fences.map(\.stored).sorted()
            store.save(submittedPens: submittedPens)
        }

        return record(stars: verdict.stars, for: levelID)
    }

    /// Whether a newly released wall beats the one on file: a better score, or the same
    /// score held with pieces to spare — the same bargain `PuzzleGame` keeps its running
    /// best on. An empty wall is never kept; the first wall that arrives is kept outright.
    private func isWorthKeeping(_ fences: Set<GridPoint>, for levelID: String) -> Bool {
        guard !fences.isEmpty else { return false }
        guard let kept = submittedFences(for: levelID) else { return true }
        guard let index = world.index(of: levelID) else { return false }

        let level = world[index].level
        guard case .penned(let pen) = level.release(fences: fences),
              case .penned(let held) = level.release(fences: kept)
        else {
            // A wall that will not close on the map as it now stands still replaces one
            // that uses more pieces, so a level whose ground has been redrawn under a
            // player's old wall is never stuck with it.
            return fences.count < kept.count
        }

        let scored = level.tally(for: pen).score
        let standing = level.tally(for: held).score
        return scored == standing ? fences.count < kept.count : scored > standing
    }

    /// Records how a level went, keeping the best rating it has ever been given.
    ///
    /// Returns whether this opened the next level up — the pig's cue to walk on.
    @discardableResult
    func record(stars rating: Int, for levelID: String) -> Bool {
        guard rating > 0, world.index(of: levelID) != nil else { return false }

        let before = frontier
        if rating > stars(for: levelID) {
            bestStars[levelID] = rating
            store.save(bestStars)
        }
        return frontier > before
    }

    /// Whether a film has been played, by the key it is remembered under. The keyed pair is
    /// what lets a world other than the meadow — whose films are `StorybookScene`s rather than
    /// `CutScene`s — track its own opening and send-off through the same store.
    func hasPlayed(sceneKey key: String) -> Bool {
        playedScenes.contains(key)
    }

    /// Remembers that a film has been played, watched or skipped, by its key. Either way it
    /// has had its one chance.
    func markPlayed(sceneKey key: String) {
        guard !hasPlayed(sceneKey: key) else { return }
        playedScenes.insert(key)
        store.markScenePlayed(key)
    }

    func hasPlayed(_ scene: CutScene.Name) -> Bool { hasPlayed(sceneKey: scene.rawValue) }

    /// Remembers that a film has been played, watched or skipped. Either way it has had
    /// its one chance.
    func markPlayed(_ scene: CutScene.Name) { markPlayed(sceneKey: scene.rawValue) }

    /// Whether a world's opening is owed, by its film's key: it plays once, on the first Play
    /// of a world nobody has taken a star out of yet. The meadow's `isTheOpeningDue` is this
    /// with the opening's own key.
    func isOpeningDue(key: String) -> Bool {
        !hasPlayed(sceneKey: key) && totalStars == 0
    }

    /// Whether a world's send-off is owed, by its film's key: once every pen in it is held and
    /// the film has not played.
    func isFarewellDue(key: String) -> Bool {
        !hasPlayed(sceneKey: key) && isTheWorldHeld
    }

    /// Whether the opening is still owed: it plays once, on the first Play of a world
    /// nobody has taken a star out of yet.
    ///
    /// The two conditions do different jobs. The flag is what stops it playing twice; the
    /// stars are what stop it playing at all for somebody who was already up the meadow
    /// before the film was ever added to the game — a player two levels in does not want
    /// to be introduced to the pig.
    var isTheOpeningDue: Bool {
        !hasPlayed(.opening) && totalStars == 0
    }

    /// The film owed before a level opens, if the world keeps one for it and it has not been
    /// played. Only a boss has one, since it is the only map in a world that changes the rules
    /// rather than the ground.
    ///
    /// Which films a world has is the world's business and which have been watched is this
    /// one's, so the world is handed in rather than held: the meadow's briefing is a painted
    /// `CutScene` and the thicket's a `StorybookScene`, and neither this nor the map it stops
    /// need know which.
    ///
    /// Returns the film rather than a yes or no so that asking whether to stop and asking what
    /// to play are one question. Two would be two things to keep in agreement.
    ///
    /// A level already held is never briefed, for the same reason the opening checks the stars
    /// as well as its own flag: somebody who has stood both animals in two pens of their own
    /// does not need telling there are two. That is what keeps a briefing added to a world
    /// already out in the world from stopping the player who finished it before the film was
    /// written.
    func briefingDue(forLevelAt index: Int, in game: GameWorld) -> WorldFilmSpec? {
        guard world.nodes.indices.contains(index), !isCleared(index) else { return nil }
        guard let briefing = game.briefing(before: world[index].id) else { return nil }
        return hasPlayed(sceneKey: briefing.key) ? nil : briefing
    }

    /// Every pen in the world held, which is the only thing that earns the last film.
    var isTheWorldHeld: Bool {
        clearedCount == world.count
    }

    /// Whether the film that closes the world out is owed.
    var isTheFarewellDue: Bool {
        !hasPlayed(.theMeadowHeld) && isTheWorldHeld
    }

    /// Reads the store again, for a screen that has been sitting behind another one while
    /// the stars were being won. The title screen does this every time it comes back.
    func reload() {
        bestStars = store.loadStars()
        bestPens = store.loadBestPens()
        submittedPens = store.loadSubmittedPens()
        playedScenes = store.loadPlayedScenes()
    }

    /// Forgets every star ever earned, on the device as well as on the screen, which shuts
    /// the world back to its first level. There is no undoing it, so nothing calls this
    /// without asking first.
    ///
    /// The films go with them: a player asking for the game back as they found it gets the
    /// ones that came with it.
    func eraseEverything() {
        bestStars = [:]
        bestPens = []
        submittedPens = [:]
        playedScenes = []
        store.erase()
    }
}

extension WorldProgress {
    /// A world a couple of levels in, so previews and the screenshots CI takes show a
    /// trail with stars on it, a level waiting to be played, and some still shut.
    ///
    /// The first stop has found its best pen as well as taking its three stars, so the
    /// rainbow a signpost keeps for one is on the map to be looked at.
    static func partWayThrough(world: WorldMap = .mudlarkMeadow) -> WorldProgress {
        var seeded: [String: Int] = [:]
        for (index, rating) in [3, 2].enumerated() where index < world.count {
            seeded[world[index].id] = rating
        }
        // Somebody this far up the trail has had the opening, whether or not the stars
        // already say so.
        return WorldProgress(
            world: world,
            store: RememberedProgress(
                stars: seeded,
                bestPens: world.count > 0 ? [world[0].id] : [],
                scenesPlayed: [CutScene.Name.opening.rawValue]
            )
        )
    }
}
