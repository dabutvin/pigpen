/// One fence piece, sitting on the line between two neighbouring tiles.
///
/// Each line has a single representation no matter which side it is named from:
/// a horizontal fence is anchored to the tile directly below it, a vertical fence
/// to the tile directly to its right. So the fence north of tile *t* and the fence
/// south of the tile above *t* are the same value, and a `Set<Fence>` can never
/// hold a line twice.
struct Fence: Hashable, Sendable {
    enum Orientation: Hashable, Sendable {
        case horizontal, vertical
    }

    let orientation: Orientation
    /// The tile below a horizontal fence, or to the right of a vertical one.
    let anchor: GridPoint

    init(orientation: Orientation, anchor: GridPoint) {
        self.orientation = orientation
        self.anchor = anchor
    }

    /// The fence on the given side of a tile.
    init(side direction: Direction, of tile: GridPoint) {
        switch direction {
        case .up:
            self.init(orientation: .horizontal, anchor: tile)
        case .down:
            self.init(orientation: .horizontal, anchor: tile.stepped(.down))
        case .left:
            self.init(orientation: .vertical, anchor: tile)
        case .right:
            self.init(orientation: .vertical, anchor: tile.stepped(.right))
        }
    }

    /// The two tiles this fence keeps apart. Either one may lie off the grid.
    var separatedTiles: (GridPoint, GridPoint) {
        switch orientation {
        case .horizontal: (anchor.stepped(.up), anchor)
        case .vertical: (anchor.stepped(.left), anchor)
        }
    }
}
