import Foundation

/// Who rides along with the pig.
///
/// The second thing the game lets a player do to her, and it is not another outfit. An outfit
/// is one peg at a time — a hat comes off when the glasses go on — and everything in the
/// dressing barn hangs on the pig herself. A companion is a second glyph again, but it hangs
/// on a perch of its own, beside the outfit rather than in place of it: a butterfly on her ear
/// under a top hat, a squirrel at her heel over a pair of wellies. So the two barns compose,
/// and a player with both open dresses her twice over.
///
/// They come from the thicket, because that is where they live. The woodland barn stands
/// beside the fairy ring, four stops into Thornwood Thicket, and the nine on its perches are
/// what a pig walking those woods would pick up: the small creatures of the undergrowth and
/// the trees. None of them is a treat or a boss — a mushroom is the thicket's windfall and a
/// boar is its boss, and neither is company.
///
/// `nobody` is the empty perch: the pig on her own, which is where she starts and where a
/// player who would rather she was goes back to.
///
/// The raw values are what the choice is kept under on the phone, so they are not to be
/// renamed — a player who put a ladybird on her is entitled to find it there next week.
enum PigCompanion: String, CaseIterable, Identifiable, Sendable {
    /// Nobody at all. The default, and the way out of every other perch.
    case nobody
    case butterfly
    case bee
    case ladybird
    case snail
    case caterpillar
    case songbird
    case frog
    case squirrel
    case hedgehog

    var id: String { rawValue }

    /// The nine companions, in the order the woodland barn perches them: what flies first,
    /// then what crawls on her face, then what sits on her head, and what stands at her feet
    /// last. `nobody` is not one of them — it is the empty perch the barn keeps at the front,
    /// and a pig on her own has no companion.
    static var friends: [PigCompanion] { allCases.filter { $0 != .nobody } }

    /// What the perch is labelled.
    var name: String {
        switch self {
        case .nobody: "On her own"
        case .butterfly: "Butterfly"
        case .bee: "Bee"
        case .ladybird: "Ladybird"
        case .snail: "Snail"
        case .caterpillar: "Caterpillar"
        case .songbird: "Songbird"
        case .frog: "Frog"
        case .squirrel: "Squirrel"
        case .hedgehog: "Hedgehog"
        }
    }

    /// The glyph riding on her, and nothing at all for the empty perch.
    var glyph: String {
        switch self {
        case .nobody: ""
        case .butterfly: "🦋"
        case .bee: "🐝"
        case .ladybird: "🐞"
        case .snail: "🐌"
        case .caterpillar: "🐛"
        case .songbird: "🐦"
        case .frog: "🐸"
        case .squirrel: "🐿️"
        case .hedgehog: "🦔"
        }
    }

    /// Where on her the companion rides, and nothing at all for the empty perch — which is how
    /// everything that draws the pig knows whether there is anybody to draw beside her.
    ///
    /// Measured the way the outfits are, as fractions of the pig herself, and placed where the
    /// outfits are not: the wardrobe hangs its hats on the crown of her head, its ribbon behind
    /// her right ear, its scarf under her chin and its boots under her, so a companion keeps to
    /// her left ear, her cheeks and her flanks. Not entirely — a bird on her head is a bird on
    /// her hat when she has one on, and that is the point of a bird — but a companion is drawn
    /// over the outfit rather than under it, so it is never lost inside one.
    var fit: OutfitFit? {
        switch self {
        case .nobody: nil
        // On the tip of her left ear, which the ribbon and the sunflower leave alone: they are
        // tucked behind her right one, at the mirror of this. A little bigger than the ribbon,
        // since a butterfly with its wings open is mostly wing.
        case .butterfly: OutfitFit.onHerLeftEar(scale: 0.34)
        // Hovering off that ear rather than sat on it, higher and further out: a bee that
        // lands is a bee that stings, and this one is company.
        case .bee: OutfitFit(scale: 0.28, across: -0.40, down: -0.40, lean: -22)
        // On her left cheek, under her eye and above her chin. Small, because a ladybird is,
        // and set a touch higher than the snail so the two do not read as one perch twice.
        case .ladybird: OutfitFit.onHerCheek(scale: 0.22, across: -0.28, down: 0.24)
        case .snail: OutfitFit.onHerCheek(scale: 0.30, across: -0.31, down: 0.30)
        // On her right cheek, leaning up it, which is the one place on her face the wardrobe
        // never reaches: the glasses stop at her eyes and the scarf starts at her chin.
        case .caterpillar: OutfitFit.onHerCheek(scale: 0.30, across: 0.31, down: 0.30, lean: 8)
        // Perched on top of her head, off to the left, where a hat's brim would be. It sits
        // on the hat when there is one — drawn after it — which is where a bird sits.
        case .songbird: OutfitFit.onHerHead(scale: 0.34, across: -0.22)
        // Sat on the other side of her head, a little lower and leaning, the way a frog sits
        // on anything: not quite square to it.
        case .frog: OutfitFit.onHerHead(scale: 0.32, across: 0.22, down: -0.45, lean: 6)
        // Standing at her left heel, the biggest thing on any perch, since a squirrel beside a
        // pig's face is a squirrel and not a mite. It hangs a little below her, and no deeper
        // than the scarf does, so the barn needs no more room under her than it already leaves.
        case .squirrel: OutfitFit.atHerHeel(scale: 0.40, across: -0.38, down: 0.46)
        // At her right heel, beside the right boot when she has them on rather than under it.
        case .hedgehog: OutfitFit.atHerHeel(scale: 0.36, across: 0.38, down: 0.49)
        }
    }

    /// How far below her the companion stands, as a fraction of her size, and nothing at all
    /// for one that keeps to her face or her head. The same measure the outfits keep, for the
    /// same reason: the barn has to leave the room, since the glyph asks for none.
    var overhang: Double {
        guard let fit else { return 0 }
        return max(0, fit.down + fit.scale / 2 - 0.5)
    }

    /// The deepest anything on a perch stands below her.
    static var deepestOverhang: Double { allCases.map(\.overhang).max() ?? 0 }

    /// How the companion is described out loud beside the pig, for a screen reader that has no
    /// way of seeing the butterfly — and nothing for a pig on her own, so the wardrobe's own
    /// line stands unadorned.
    var spoken: String {
        self == .nobody ? "" : "with a \(name.lowercased()) riding along"
    }
}

extension OutfitFit {
    /// On the tip of her left ear: the mirror of `behindTheEar`, which is the right one.
    static func onHerLeftEar(scale: Double) -> OutfitFit {
        OutfitFit(scale: scale, across: -0.30, down: -0.29, lean: -14)
    }

    /// On a cheek: below her eyes, which end at `PigFace.eyeBottom`, and above her chin.
    static func onHerCheek(scale: Double, across: Double, down: Double, lean: Double = 0) -> OutfitFit {
        OutfitFit(scale: scale, across: across, down: down, lean: lean)
    }

    /// Sat on top of her head, off to one side, where a hat's crown is not.
    static func onHerHead(scale: Double, across: Double, down: Double = -0.47, lean: Double = 0) -> OutfitFit {
        OutfitFit(scale: scale, across: across, down: down, lean: lean)
    }

    /// Standing beside her at the ground, out past where the boots stand.
    static func atHerHeel(scale: Double, across: Double, down: Double) -> OutfitFit {
        OutfitFit(scale: scale, across: across, down: down, lean: 0)
    }
}
