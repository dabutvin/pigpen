import Foundation

/// Where a garment hangs on the pig, and how it sits there.
///
/// Every measure is a fraction of the size the pig herself is drawn at rather than a number of
/// points, so one set of numbers dresses her everywhere she appears: on a board tile the size
/// of a fingernail, trotting along the fence on the title screen, and standing full height on
/// the dressing-room mirror. A hat that was measured in points would slide off the back of her
/// head the first time the board got bigger.
///
/// They are measured against the pig glyph rather than guessed at, off the screenshots CI takes
/// of the dressing room. She fills her box: the tips of her ears are at `-0.5` and her chin at
/// `+0.5`, her eyes sit at about `-0.05`, and her snout — which is the trap — is only at `+0.16`,
/// so anything meant for her neck has to be put a long way further down than it looks.
///
/// `down` is measured to the middle of the garment's own box, and a garment is rarely in the
/// middle of its picture: a scarf carries its knot high and hangs tassels below it, a rosette
/// hangs its disc low under a ribbon. What has to line up with her is the part of the garment
/// that touches her, not the middle of the picture it is drawn in — which is why two things worn
/// at the same place do not share a number.
struct OutfitFit: Equatable, Sendable {
    /// How large the garment is set beside the pig, as a fraction of her own size.
    let scale: Double
    /// How far out from the middle of the pig it hangs: `across` to her right, `down` towards
    /// her feet. Both are fractions of her size too.
    let across: Double
    let down: Double
    /// How far it is tipped, in degrees. A hat worn dead straight is a hat nobody had any fun
    /// with.
    let lean: Double

    /// Something worn on top of the head.
    static func hat(scale: Double, down: Double = -0.44, lean: Double = -10) -> OutfitFit {
        OutfitFit(scale: scale, across: 0.02, down: down, lean: lean)
    }

    /// Something worn across the eyes.
    static func onTheFace(scale: Double) -> OutfitFit {
        OutfitFit(scale: scale, across: 0, down: -0.06, lean: 0)
    }

    /// Something tucked behind one ear.
    static func behindTheEar(scale: Double) -> OutfitFit {
        OutfitFit(scale: scale, across: 0.30, down: -0.29, lean: 14)
    }

    /// Something worn under the chin — which is at `+0.5`, so this hangs most of itself below
    /// her and only tucks its top edge under her jaw.
    static func atTheNeck(scale: Double, down: Double = 0.52) -> OutfitFit {
        OutfitFit(scale: scale, across: 0, down: down, lean: 0)
    }

    /// Something worn on the feet, which on a pig drawn as a face means under her: clear of her
    /// chin rather than across her mouth, or it reads as something she is eating.
    static func onTheFeet(scale: Double) -> OutfitFit {
        OutfitFit(scale: scale, across: 0, down: 0.62, lean: 0)
    }
}

/// What the pig has on.
///
/// The game has drawn her as one glyph since the first build, and an outfit does not change
/// that: it is a second glyph hung on the first at a fixed place and angle. So a pig in a top
/// hat is still the pig the board is playing with — the same tile, the same size, the same
/// shadow, the same hop when a finger lands on her — and nothing in the game has to be taught
/// about clothes to draw her in them. It also means an outfit costs nothing to carry about:
/// a string in the defaults, and two numbers and a turn at the moment of drawing.
///
/// Ten of them hang in the dressing room, and `asSheComes` is the eleventh peg: the pig as the
/// game has always shipped her, which is where a player who has had enough of hats goes.
///
/// The raw values are what the choice is kept under on the phone, so they are not to be
/// renamed — a player who has put a crown on her is entitled to find it there next week.
enum PigOutfit: String, CaseIterable, Identifiable, Sendable {
    /// Nothing on at all. The default, and the way out of every other peg.
    case asSheComes
    case sunHat
    case topHat
    case crown
    case shades
    case spectacles
    case ribbon
    case sunflower
    case scarf
    case rosette
    case wellies

    var id: String { rawValue }

    /// The ten outfits, in the order the dressing room hangs them up: the hats together, then
    /// what goes on the face, then what is tucked behind an ear, then what hangs at the neck,
    /// and the boots last. `asSheComes` is not one of them — it is the bare peg the room keeps
    /// at the front, and a player wearing nothing is not wearing an outfit.
    static var wardrobe: [PigOutfit] { allCases.filter { $0 != .asSheComes } }

    /// What the peg is labelled.
    var name: String {
        switch self {
        case .asSheComes: "Just the pig"
        case .sunHat: "Sun Hat"
        case .topHat: "Top Hat"
        case .crown: "Crown"
        case .shades: "Sunglasses"
        case .spectacles: "Spectacles"
        case .ribbon: "Ribbon"
        case .sunflower: "Sunflower"
        case .scarf: "Scarf"
        case .rosette: "Rosette"
        case .wellies: "Wellies"
        }
    }

    /// The glyph hung on her, and nothing at all for the bare peg.
    var glyph: String {
        switch self {
        case .asSheComes: ""
        case .sunHat: "👒"
        case .topHat: "🎩"
        case .crown: "👑"
        case .shades: "🕶️"
        case .spectacles: "👓"
        case .ribbon: "🎀"
        case .sunflower: "🌻"
        case .scarf: "🧣"
        case .rosette: "🏅"
        case .wellies: "🥾"
        }
    }

    /// Where that glyph hangs, and nothing at all for the bare peg — which is how everything
    /// that draws the pig knows whether there is anything to draw on top of her.
    var fit: OutfitFit? {
        switch self {
        case .asSheComes: nil
        case .sunHat: OutfitFit.hat(scale: 0.60, down: -0.41, lean: -12)
        case .topHat: OutfitFit.hat(scale: 0.56, down: -0.46)
        case .crown: OutfitFit.hat(scale: 0.48, down: -0.47, lean: 0)
        case .shades: OutfitFit.onTheFace(scale: 0.54)
        case .spectacles: OutfitFit.onTheFace(scale: 0.52)
        case .ribbon: OutfitFit.behindTheEar(scale: 0.36)
        case .sunflower: OutfitFit.behindTheEar(scale: 0.38)
        // Lower than the rosette, because the knot a scarf is worn by sits high in its own
        // picture: at 0.58 the knot lands on her jaw and the tassels hang under it.
        case .scarf: OutfitFit.atTheNeck(scale: 0.40, down: 0.58)
        // Lower again, and for the scarf's reason: a medal is a ribbon over a disc, and the
        // ribbon it hangs by is the top of its picture. At 0.60 the ribbon crosses her jaw and
        // the disc hangs under it, where a rosette is worn.
        case .rosette: OutfitFit.atTheNeck(scale: 0.36, down: 0.60)
        case .wellies: OutfitFit.onTheFeet(scale: 0.34)
        }
    }

    /// How far below her a garment hangs, as a fraction of her size, and nothing at all for one
    /// that stays on her.
    ///
    /// The overlay that draws it takes up no room on purpose — a dressed pig has to measure
    /// exactly what an undressed one does, or a board would shift under a hat. Out on the mud
    /// that costs nothing, since there is ground under her. A room that stands her on a shelf
    /// with her name written under it has to leave the room for it itself.
    var overhang: Double {
        guard let fit else { return 0 }
        return max(0, fit.down + fit.scale / 2 - 0.5)
    }

    /// The deepest anything in the wardrobe hangs. The dressing room leaves this much space
    /// under every pig it draws rather than under the ones that need it, so a peg is the same
    /// size whatever is on it and the wall does not shuffle as outfits are tried on.
    static var deepestOverhang: Double { allCases.map(\.overhang).max() ?? 0 }

    /// How the pig is described out loud while she is wearing it, for a screen reader that
    /// has no way of seeing the hat.
    /// *The* rather than *a*, so that one wording covers the sunglasses and the wellies as
    /// well as the top hat.
    var spoken: String {
        self == .asSheComes ? "The pig, wearing nothing" : "The pig wearing the \(name.lowercased())"
    }
}
