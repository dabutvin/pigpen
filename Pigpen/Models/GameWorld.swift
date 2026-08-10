import Foundation

/// A film a world plays, whichever kind it is: the meadow's hand-painted `CutScene`, or a
/// themed world's lighter `StorybookScene`. One type so a single screen can present either and
/// a world can be wrapped in whichever it has.
enum WorldFilm: Sendable, Identifiable {
    case painted(CutScene)
    case storybook(StorybookScene)

    /// A film on screen is told apart by its key, so presenting a new one swaps the screen.
    var id: String { key }

    /// What the world remembers the film by, so it plays once and is never shown twice.
    var key: String {
        switch self {
        case .painted(let scene): scene.name.rawValue
        case .storybook(let scene): scene.key
        }
    }

    var runtime: TimeInterval {
        switch self {
        case .painted(let scene): scene.runtime
        case .storybook(let scene): scene.runtime
        }
    }
}

/// A film a world owns but has not started yet: the key it is tracked by, and how to raise the
/// curtain on it at a given moment. Held apart from the film itself so asking whether a film is
/// owed does not build one, and presenting it starts its clock fresh.
struct WorldFilmSpec: Sendable {
    let key: String
    let make: @Sendable (Date) -> WorldFilm

    /// The film, its clock started now.
    func raise(at start: Date = .now) -> WorldFilm { make(start) }
}

/// A whole world: the puzzles up its trail, the look that dresses them, and the films that open
/// and close it.
///
/// The map and the theme are the two halves the rest of the game reads — one for what a pen is
/// worth, the other for what it looks like — and every world is the same game underneath. The
/// films are what wrap it: an opening before the first field, a send-off once every pen is held.
struct GameWorld: Sendable {
    let theme: WorldTheme
    let map: WorldMap
    /// The film before the first walk into the world, if it has one. Played on entering the
    /// world with nothing yet won on it.
    let opening: WorldFilmSpec?
    /// The film that sees the world out once every pen in it is held.
    let farewell: WorldFilmSpec?

    var name: String { theme.name }
}

extension GameWorld {
    /// Mudlark Meadow: the world the game has always shipped, now the first stop of many. Its
    /// films stay the meadow's own painted ones, and keyed exactly as before so a player who
    /// has already seen the opening is not sat back down in front of it.
    static let mudlarkMeadow = GameWorld(
        theme: .meadow,
        map: .mudlarkMeadow,
        opening: WorldFilmSpec(key: CutScene.Name.opening.rawValue) { .painted(.opening(start: $0)) },
        farewell: WorldFilmSpec(key: CutScene.Name.theMeadowHeld.rawValue) {
            .painted(.theMeadowHeld(start: $0))
        }
    )

    /// Thornwood Thicket: the second world, wrapped in storybook films until it earns painted
    /// ones. The send-off points on past the trees, the way the meadow's points past the hills.
    static let thornwoodThicket = GameWorld(
        theme: .thornwood,
        map: .thornwoodThicket,
        opening: WorldFilmSpec(key: "thornwood-opening") { .storybook(.thornwoodOpening(start: $0)) },
        farewell: WorldFilmSpec(key: "thornwood-held") { .storybook(.thornwoodHeld(start: $0)) }
    )
}
