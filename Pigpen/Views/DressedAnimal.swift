import SwiftUI

/// An animal as the game draws it: its own glyph, with whatever the pig is wearing hung on top
/// of her, and whoever is riding along with her drawn on top of that.
///
/// It stands in for the bare `Text` the field and the trail used to draw, and it is the same
/// size as that bare text was — the outfit is laid over the glyph rather than beside it, so
/// nothing that places an animal has to know whether she has a hat on. Everything a caller
/// already does to the pig — squashing her on a landing, leaning her into a trot, dropping a
/// shadow under her — is done to the whole of her, clothes included, because it is done to this.
///
/// Only the pig is ever dressed, and only the pig keeps company. Every other animal in the
/// game is somebody else's problem.
struct DressedAnimal: View {
    let animal: Animal
    /// The size the glyph is set at. The outfit is measured off it, so a pig anywhere in the
    /// game wears the same hat at the same angle.
    let size: CGFloat
    /// What she has on. Handed in rather than asked of the wardrobe here, so the dressing
    /// room can draw twelve pigs in twelve outfits at once and a preview can dress her without
    /// a choice saved on the machine.
    var outfit: PigOutfit = .asSheComes
    /// Who is with her, on the same terms.
    var companion: PigCompanion = .nobody

    var body: some View {
        Text(animal.glyph)
            .font(.system(size: size))
            .overlay { garment }
            // Over the garment rather than under it, so a bird on her head sits on her hat and
            // a squirrel at her heel is not lost behind a boot: company is never hidden inside
            // an outfit.
            .overlay { company }
    }

    /// What is actually hanging on her: nothing for an animal that is not the pig, and nothing
    /// for a pig on the bare peg.
    private var worn: OutfitFit? {
        guard animal == .pig else { return nil }
        return outfit.fit
    }

    /// Who is actually with her: nobody for an animal that is not the pig, and nobody for a
    /// pig on the empty perch.
    private var riding: OutfitFit? {
        guard animal == .pig else { return nil }
        return companion.fit
    }

    /// The garment, laid over the glyph without taking up any room of its own — an overlay
    /// rather than a stack, so a dressed pig measures exactly the same as an undressed one and
    /// nothing on a board moves when a hat goes on.
    ///
    /// One of it, or two for the boots: a pair is the same glyph drawn twice, `apart` to each
    /// side of her, with the second one turned over so the two are a left and a right.
    @ViewBuilder
    private var garment: some View {
        if let worn {
            if let apart = worn.apart {
                piece(outfit.glyph, worn, across: worn.across + apart)
                piece(outfit.glyph, worn, across: worn.across - apart, mirrored: true)
            } else {
                piece(outfit.glyph, worn, across: worn.across)
            }
        }
    }

    /// The companion, on its perch: one glyph, hung the way a garment is, since a perch is
    /// measured the way a garment's fit is.
    @ViewBuilder
    private var company: some View {
        if let riding {
            piece(companion.glyph, riding, across: riding.across)
        }
    }

    /// One glyph, hung where it is worn. The turn comes before the mirroring so that a pair
    /// leans away from each other rather than both the same way, which is what a left and a
    /// right do.
    private func piece(_ glyph: String, _ worn: OutfitFit, across: Double, mirrored: Bool = false) -> some View {
        Text(glyph)
            .font(.system(size: size * worn.scale))
            .rotationEffect(.degrees(worn.lean))
            .scaleEffect(x: mirrored ? -1 : 1, y: 1)
            .offset(x: size * across, y: size * worn.down)
            .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 20) {
        let showing: [PigOutfit] = [
            .asSheComes, .baseballCap, .graduationCap, .shades, .scarf, .wellies
        ]
        ForEach(showing) { outfit in
            HStack(spacing: 24) {
                DressedAnimal(animal: .pig, size: 28, outfit: outfit)
                DressedAnimal(animal: .pig, size: 64, outfit: outfit)
                Text(outfit.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)
            }
        }
        DressedAnimal(animal: .deer, size: 64, outfit: .crown)
        HStack(spacing: 24) {
            DressedAnimal(animal: .pig, size: 64, outfit: .topHat, companion: .butterfly)
            DressedAnimal(animal: .pig, size: 64, outfit: .wellies, companion: .squirrel)
            DressedAnimal(animal: .pig, size: 64, companion: .ladybird)
        }
    }
    .padding(40)
    .background(GamePalette.beyond)
}
