import Foundation

/// The parts of the pig herself that something worn on her has to be measured against, as
/// fractions of the size she is drawn at and taken from the middle of the box she is drawn in.
///
/// Only her eyes are written down, because they are the only part of her a garment has ever had
/// to *cover* rather than merely sit near: a hat an eighth of her too high is a hat at a jaunty
/// angle, and a pair of sunglasses an eighth of her too high is a mistake anybody can see.
///
/// They are measured off the screenshots CI takes of the board and of the dressing barn, against
/// the middle of the text box the glyph is drawn in — which is what an overlay hangs from, and
/// which is *not* the middle of the pig. Her eyes are below it, not above it, and reading them
/// as above it is what once hung both pairs of glasses on her forehead.
enum PigFace {
    /// The top and the bottom of the dark of an eye.
    static let eyeTop = -0.058
    static let eyeBottom = 0.111
    /// How far the outer corner of an eye is from the middle of her — which is further out than
    /// a pair of glasses narrow enough to fit between her cheeks looks like it needs to reach.
    static let eyeReach = 0.283
    /// The line the pair of them sit on, which is what glasses are hung from.
    static var eyeLine: Double { (eyeTop + eyeBottom) / 2 }
}

/// Where the lenses are inside a pair of glasses, as a fraction of the size that glyph is set
/// at — measured the same way, off the pegs in the barn.
///
/// Glasses are drawn as a band across the middle of a picture that is empty above and below it,
/// so a pair set large enough to reach past her eyes is nothing like as big on her face as its
/// `scale` reads: at `0.72` the lenses themselves are a quarter of her deep. The sunglasses and
/// the spectacles are drawn within a few thousandths of each other, so one band covers both,
/// taken each way from whichever of the two covers less.
enum Lenses {
    static let top = -0.16
    static let bottom = 0.19
    /// How far the outside of a lens is from the middle of the glyph.
    static let reach = 0.46
    /// The middle of the band, which is what is put on her eye line.
    static var middle: Double { (top + bottom) / 2 }
}

/// Where a garment hangs on the pig, and how it sits there.
///
/// Every measure is a fraction of the size the pig herself is drawn at rather than a number of
/// points, so one set of numbers dresses her everywhere she appears: on a board tile the size
/// of a fingernail, trotting along the fence on the title screen, and standing full height on
/// the dressing-barn mirror. A hat that was measured in points would slide off the back of her
/// head the first time the board got bigger.
///
/// They are measured against the pig glyph rather than guessed at, off the screenshots CI takes
/// of the dressing barn. She does not sit in the middle of the box she is drawn in: her ears are
/// pulled up into the top of it and the weight of her face hangs under them, so her ear tips
/// reach only about `-0.42` while her chin goes down to `+0.51`. Everything on her is low —
/// her eyes are *below* the middle of the box rather than above it (`PigFace`), and her snout
/// is lower again — so anything placed by eye against the middle of the picture lands high,
/// and anything meant for her neck has to be put a long way further down than it looks.
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

    /// Something worn across the eyes — which means the eyes and not the middle of her face.
    ///
    /// It is the one place in the wardrobe where a garment has a job beyond looking like
    /// something: a pair of glasses that sits a little high is not a pair of glasses worn a
    /// little high, it is a pig looking over the top of them with both eyes showing under the
    /// lenses. So this one is not a number somebody liked the look of — it is worked out, from
    /// the line her eyes are actually drawn on and from where the lenses sit inside the glyph
    /// they are drawn in, and it moves with `scale` because the lenses do.
    static func onTheFace(scale: Double) -> OutfitFit {
        OutfitFit(
            scale: scale,
            across: 0,
            down: PigFace.eyeLine - scale * Lenses.middle,
            lean: 0
        )
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
/// Ten of them hang in the dressing barn, and `asSheComes` is the eleventh peg: the pig as the
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

    /// The ten outfits, in the order the dressing barn hangs them up: the hats together, then
    /// what goes on the face, then what is tucked behind an ear, then what hangs at the neck,
    /// and the boots last. `asSheComes` is not one of them — it is the bare peg the barn keeps
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
        // Both are set to bury her eyes rather than to look like glasses and no more: the
        // lenses are a shallow band inside their own picture, and her eyes are wide-set and
        // nearly as deep as they are apart, so a pair small enough to look neat between her
        // cheeks leaves the bottom of both eyes hanging below the lenses. `PigOutfitTests`
        // holds the two of them to covering her.
        case .shades: OutfitFit.onTheFace(scale: 0.72)
        case .spectacles: OutfitFit.onTheFace(scale: 0.72)
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
    /// that costs nothing, since there is ground under her. A screen that stands her on a shelf
    /// with her name written under it has to leave the room for it itself.
    var overhang: Double {
        guard let fit else { return 0 }
        return max(0, fit.down + fit.scale / 2 - 0.5)
    }

    /// The deepest anything in the wardrobe hangs. The dressing barn leaves this much space
    /// under every pig it draws rather than under only the ones that need it, so a peg is the
    /// same size whatever is on it and the wall does not shuffle as outfits are tried on.
    static var deepestOverhang: Double { allCases.map(\.overhang).max() ?? 0 }

    /// How the pig is described out loud while she is wearing it, for a screen reader that
    /// has no way of seeing the hat.
    /// *The* rather than *a*, so that one wording covers the sunglasses and the wellies as
    /// well as the top hat.
    var spoken: String {
        self == .asSheComes ? "The pig, wearing nothing" : "The pig wearing the \(name.lowercased())"
    }
}
