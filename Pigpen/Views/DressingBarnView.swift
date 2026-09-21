import SwiftUI

/// A barn: the pig on a stand in the middle of it, and a wall of pegs round her.
///
/// It is the one screen in the game that changes nothing about playing it. There is no budget
/// here, nothing to hold and nothing to lose: tap a peg and the pig is wearing it, everywhere,
/// from the next board onwards. So it is built like a barn rather than like a board — the mirror
/// first and big, the pegs under it, and the only way out a cross in the corner.
///
/// The game has two of them, and they are this one screen told what to hang. The dressing barn
/// hangs the twelve outfits and the bare peg she arrived on; the woodland barn hangs the nine
/// companions and the empty perch. The mirror is the same in both — the pig as she stands,
/// wearing whatever the other barn put on her as well — and only the wall differs, so a player
/// choosing a hat can see it under the butterfly and one choosing a butterfly can see it on
/// the hat.
///
/// Each is reached two ways. The dressing barn stands on the meadow's map beside the orchard,
/// the woodland barn on the thicket's beside the fairy ring, and once the stop beside one has
/// been penned, tapping it walks straight in — there is no puzzle between a player and their
/// hats. The cards in settings are the other way, for a player who is nowhere near either map
/// when the urge takes them.
@MainActor
struct DressingBarnView: View {
    @Environment(\.dismiss) private var dismiss

    /// Which barn this is: what hangs on the wall.
    var rack: BarnRack = .outfits
    /// What the pig is wearing. The shared one by default — dressing her here is meant to dress
    /// her everywhere — and handed in by the previews, which must not leave a hat on the pig of
    /// whoever is running them.
    var wardrobe: PigWardrobe = .shared
    var haptics: Haptics = .shared

    /// One peg on the wall of either barn.
    private enum Peg: Hashable, Identifiable {
        case outfit(PigOutfit)
        case companion(PigCompanion)

        var id: String {
            switch self {
            case .outfit(let outfit): "outfit." + outfit.id
            case .companion(let companion): "companion." + companion.id
            }
        }

        var name: String {
            switch self {
            case .outfit(let outfit): outfit.name
            case .companion(let companion): companion.name
            }
        }
    }

    /// The pegs, in the order the barn hangs them, with the empty one at the front.
    private var pegs: [Peg] {
        switch rack {
        case .outfits: ([.asSheComes] + PigOutfit.wardrobe).map(Peg.outfit)
        case .companions: ([.nobody] + PigCompanion.friends).map(Peg.companion)
        }
    }

    /// The peg with the tick beside it.
    private var chosen: Peg {
        switch rack {
        case .outfits: .outfit(wardrobe.outfit)
        case .companions: .companion(wardrobe.companion)
        }
    }

    /// What the barn is called, over the door.
    private var title: String {
        switch rack {
        case .outfits: "Dressing Barn"
        case .companions: "Woodland Barn"
        }
    }

    /// What the wall is called. Company perches; clothes hang.
    private var wallHeading: String {
        switch rack {
        case .outfits: "The pegs"
        case .companions: "The perches"
        }
    }

    /// The deepest anything on either wall hangs below her: what both barns leave room for
    /// under every pig they draw, so the mirror shows the same pig at the same height whichever
    /// barn it stands in.
    private static var deepestOverhang: Double {
        max(PigOutfit.deepestOverhang, PigCompanion.deepestOverhang)
    }

    /// How large the pig is drawn on the mirror and on a peg.
    private static let mirrorSize: CGFloat = 124
    private static let pegSize: CGFloat = 46

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GamePalette.mudLit, GamePalette.mud],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    // One column with the mirror and the pegs, the way the settings page is.
                    .keptToAColumn()

                ScrollView {
                    VStack(spacing: 16) {
                        mirror
                        rail
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                    .keptToAColumn()
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // The barn is painted in one light, the way every board in the game is.
        .staysInDaylight()
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post)

            Spacer(minLength: 0)

            Button {
                haptics.tap(.light)
                Sounds.play(.press)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close the barn")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// The pig, full height, in whatever is on her: the one place in the game she stands still
    /// long enough to be looked at.
    private var mirror: some View {
        card {
            VStack(spacing: 10) {
                DressedAnimal(
                    animal: .pig,
                    size: Self.mirrorSize,
                    outfit: wardrobe.outfit,
                    companion: wardrobe.companion
                )
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
                    .padding(.top, 6)
                    // Room under her for whatever hangs below her chin, since the garment is
                    // laid over her rather than stacked with her and so asks for none of its
                    // own. Reserved for the deepest peg on either wall rather than for the one
                    // she has on, so the mirror does not jump as outfits are tried on.
                    .padding(.bottom, Self.mirrorSize * Self.deepestOverhang)
                    // The whole point of the screen, so it is said out loud as well as drawn.
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(wardrobe.spoken)
                    // A new outfit arrives with a bounce rather than appearing, so a tap on a
                    // peg is answered here as well as there.
                    .animation(.spring(duration: 0.35, bounce: 0.45), value: wardrobe.outfit)
                    .animation(.spring(duration: 0.35, bounce: 0.45), value: wardrobe.companion)

                Text(chosen.name)
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.post)
            }
            .frame(maxWidth: .infinity)
        }
    }

    /// Every peg in the barn. Each one is the pig in that outfit, or with that companion, rather
    /// than the garment or the creature on its own, because what a player is choosing between is
    /// twelve pigs and not twelve hats — and each says nothing but its name, since a picture of
    /// the pig in the thing is a better account of it than a line of writing under the picture.
    /// What the other barn put on her is on every peg here too, so the choice is seen as it
    /// will be worn.
    private var rail: some View {
        card {
            Text(wallHeading)
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: 10)],
                spacing: 10
            ) {
                ForEach(pegs) { peg in
                    self.peg(peg)
                }
            }
            .padding(.top, 4)
        }
    }

    private func peg(_ peg: Peg) -> some View {
        let worn = chosen == peg

        return Button {
            take(peg)
        } label: {
            VStack(spacing: 6) {
                pig(on: peg, size: Self.pegSize)
                    // The same room under her the mirror leaves, so a boot does not land on
                    // the name of the peg it is hanging from. Aligned to the top, or the extra
                    // height would be shared out above and below and only half of it would fall
                    // where the boot is.
                    .frame(
                        height: Self.pegSize * (1.26 + Self.deepestOverhang),
                        alignment: .top
                    )

                Text(peg.name)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(worn ? GamePalette.pen.opacity(0.35) : GamePalette.mud.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        worn ? GamePalette.clay : GamePalette.post.opacity(0.12),
                        lineWidth: worn ? 3 : 1
                    )
            )
            // The tick, where a signpost would carry its stars: the one peg in the barn that
            // is already on her.
            .overlay(alignment: .topTrailing) {
                if worn {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .black))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(GamePalette.cream, GamePalette.clover)
                        .padding(5)
                }
            }
        }
        .buttonStyle(SignpostButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken(peg))
        .accessibilityValue(worn ? "Worn" : "")
        .accessibilityAddTraits(worn ? [.isButton, .isSelected] : .isButton)
    }

    /// The pig as this peg would have her: that outfit with whoever is already with her, or
    /// that companion on whatever she already has on.
    private func pig(on peg: Peg, size: CGFloat) -> DressedAnimal {
        switch peg {
        case .outfit(let outfit):
            DressedAnimal(animal: .pig, size: size, outfit: outfit, companion: wardrobe.companion)
        case .companion(let companion):
            DressedAnimal(animal: .pig, size: size, outfit: wardrobe.outfit, companion: companion)
        }
    }

    /// How a peg is described out loud: the thing on it, said the way the mirror says it.
    private func spoken(_ peg: Peg) -> String {
        switch peg {
        case .outfit(let outfit): outfit.spoken
        case .companion(let companion):
            companion == .nobody ? "The pig on her own" : "The pig \(companion.spoken)"
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(GamePalette.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(GamePalette.post.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }

    // MARK: - Dressing her

    /// Takes a peg off the wall and puts it on the pig — or a companion off its perch to ride
    /// along. Tapping the one she already has is not nothing — it still answers in the hand —
    /// but it is not counted twice.
    private func take(_ peg: Peg) {
        guard peg != chosen else {
            haptics.tap(.light)
            Sounds.play(.press)
            return
        }
        haptics.tap(.medium)
        Sounds.play(.callout)
        switch peg {
        case .outfit(let outfit):
            wardrobe.wear(outfit)
            Analytics.record(.outfitWorn(outfit.rawValue))
        case .companion(let companion):
            wardrobe.keep(companion)
            Analytics.record(.companionKept(companion.rawValue))
        }
    }
}

#Preview("Wearing something") {
    DressingBarnView(wardrobe: .remembering(.topHat))
}

#Preview("Nothing on her yet") {
    DressingBarnView(wardrobe: .remembering())
}

#Preview("The woodland barn, with company") {
    DressingBarnView(rack: .companions, wardrobe: .remembering(.sunHat, with: .butterfly))
}

#Preview("The woodland barn, on her own") {
    DressingBarnView(rack: .companions, wardrobe: .remembering())
}
