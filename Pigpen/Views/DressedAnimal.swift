import SwiftUI

/// An animal as the game draws it: its own glyph, with whatever the pig is wearing hung on top
/// of her.
///
/// It stands in for the bare `Text` the field and the trail used to draw, and it is the same
/// size as that bare text was — the outfit is laid over the glyph rather than beside it, so
/// nothing that places an animal has to know whether she has a hat on. Everything a caller
/// already does to the pig — squashing her on a landing, leaning her into a trot, dropping a
/// shadow under her — is done to the whole of her, clothes included, because it is done to this.
///
/// Only the pig is ever dressed. Every other animal in the game is somebody else's problem.
struct DressedAnimal: View {
    let animal: Animal
    /// The size the glyph is set at. The outfit is measured off it, so a pig anywhere in the
    /// game wears the same hat at the same angle.
    let size: CGFloat
    /// What she has on. Handed in rather than asked of the wardrobe here, so the dressing
    /// room can draw ten pigs in ten outfits at once and a preview can dress her without a
    /// choice saved on the machine.
    var outfit: PigOutfit = .asSheComes

    var body: some View {
        Text(animal.glyph)
            .font(.system(size: size))
            .overlay { garment }
    }

    /// What is actually hanging on her: nothing for an animal that is not the pig, and nothing
    /// for a pig on the bare peg.
    private var worn: OutfitFit? {
        guard animal == .pig else { return nil }
        return outfit.fit
    }

    /// The garment, laid over the glyph without taking up any room of its own — an overlay
    /// rather than a stack, so a dressed pig measures exactly the same as an undressed one and
    /// nothing on a board moves when a hat goes on.
    @ViewBuilder
    private var garment: some View {
        if let worn {
            Text(outfit.glyph)
                .font(.system(size: size * worn.scale))
                .rotationEffect(.degrees(worn.lean))
                .offset(x: size * worn.across, y: size * worn.down)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach([PigOutfit.asSheComes, .topHat, .shades, .scarf, .wellies]) { outfit in
            HStack(spacing: 24) {
                DressedAnimal(animal: .pig, size: 28, outfit: outfit)
                DressedAnimal(animal: .pig, size: 64, outfit: outfit)
                Text(outfit.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)
            }
        }
        DressedAnimal(animal: .deer, size: 64, outfit: .crown)
    }
    .padding(40)
    .background(GamePalette.beyond)
}
