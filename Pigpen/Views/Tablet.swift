import Foundation
import SwiftUI

/// How wide the game lets itself grow on a tablet.
///
/// Every screen was laid out for a phone: one column, the width of the glass, with the board
/// or the list taking all of it. An iPad's glass is two and a half phones wide, and a column
/// stretched across the lot of it is a button you cannot reach the end of, a rack of twelve
/// pickets huddled at one end of a board two feet long, and a trail whose signposts stand so
/// far apart the pig spends its time walking between them. So each kind of screen has a width
/// it stops at, and stands in the middle of whatever is left — the meadow, the starfield or
/// the cream page behind it is painted to the edges either way, so the screen is a phone's
/// worth of furniture standing in a tablet's worth of ground rather than a phone's screen
/// with a border round it.
///
/// Nothing here asks what device it is on. A width is a width: a phone never reaches any of
/// these, an iPad in a narrow split beside another app is a phone for the duration, and a
/// window resized under Stage Manager is whichever it happens to be that moment.
enum Tablet {
    /// A list of cards, a calendar, or the run of boards on the title screen.
    static let column: CGFloat = 600
    /// A board and the furniture stacked round it. Wider than a list: the board is the screen,
    /// and a tablet's board deserves tiles a tablet's finger can use.
    static let board: CGFloat = 720
    /// How far across a map a trail may wander between one signpost and the next.
    static let trail: CGFloat = 520
    /// The column of furniture beside a board on a tablet turned on its side: the rack, the
    /// boss's orders, and the button that ends the go, at a phone's width.
    static let aside: CGFloat = 380
}

extension View {
    /// Keeps a screen's furniture no wider than a phone's, in the middle of whatever width it
    /// was given. On a phone this does nothing at all.
    func keptToAColumn(_ width: CGFloat = Tablet.column) -> some View {
        frame(maxWidth: width)
            .frame(maxWidth: .infinity)
    }
}

/// How a board and its furniture share the screen: stacked, the way a phone holds them, or
/// side by side, the way a tablet turned on its side does.
enum BoardLayout: Equatable {
    /// The rack over the field and the controls under it, in one column.
    case stacked
    /// The field on its own, and everything else in a column beside it.
    case beside

    /// Which of the two suits a screen of `size`.
    ///
    /// Side by side is only worth it when a board laid beside its furniture comes out bigger
    /// than one stacked with it. Stacked, the board gets the height less the furniture over
    /// and under it; beside, it gets the whole height, or the width less the column, whichever
    /// is tighter. So the screen has to be wider than it is tall by about what the furniture
    /// costs, and wide enough to hold the column and a board worth having next to it. A tablet
    /// on its side is both. A tablet upright is neither, a narrow split beside another app is
    /// a phone, and a squarish window under Stage Manager is a phone with more room.
    static func fitting(_ size: CGSize, regularWidth: Bool) -> BoardLayout {
        guard regularWidth, size.width >= Self.narrowestBeside else { return .stacked }
        return size.width - size.height >= Self.wideEnoughForBeside ? .beside : .stacked
    }

    /// A screen has to be at least this wide to lay a board beside its furniture at all: a
    /// phone-wide column of controls, and a board at least as wide again beside it.
    static let narrowestBeside: CGFloat = 820
    /// And wider than it is tall by this much, which is about what the rack, the corrections
    /// and the button cost a stacked board in height.
    static let wideEnoughForBeside: CGFloat = 160
}
