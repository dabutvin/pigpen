import SwiftUI

/// The dressing room: the pig on a stand in the middle of it, and eleven pegs round the walls —
/// ten outfits and the bare one she arrived in.
///
/// It is the one screen in the game that changes nothing about playing it. There is no budget
/// here, nothing to hold and nothing to lose: tap a peg and the pig is wearing it, everywhere,
/// from the next board onwards. So it is built like a room rather than like a board — the mirror
/// first and big, the pegs under it, and the only way out a cross in the corner.
///
/// It is reached two ways, and both of them matter. Penning the lane off the orchard throws the
/// doors open there and then, which is the whole reward for having gone down a lane that leads
/// nowhere; after that the card in settings is the way back in, because a reward a player cannot
/// find again is a reward they had once.
@MainActor
struct DressingRoomView: View {
    @Environment(\.dismiss) private var dismiss

    /// What the pig is wearing. The shared one by default — dressing her here is meant to dress
    /// her everywhere — and handed in by the previews, which must not leave a hat on the pig of
    /// whoever is running them.
    var wardrobe: PigWardrobe = .shared
    var haptics: Haptics = .shared
    /// Whether the room was opened by the lane giving way rather than out of settings, which is
    /// the one time it has something to say for itself.
    var hasJustOpened = false

    /// The pegs, in the order the wardrobe hangs them, with the bare one at the front.
    private var pegs: [PigOutfit] { [.asSheComes] + PigOutfit.wardrobe }

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

                ScrollView {
                    VStack(spacing: 16) {
                        mirror
                        rail
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // The room is painted in one light, the way every board in the game is.
        .staysInDaylight()
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            Text("Dressing Room")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post)

            Spacer(minLength: 0)

            Button {
                haptics.tap(.light)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close the dressing room")
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
                DressedAnimal(animal: .pig, size: Self.mirrorSize, outfit: wardrobe.outfit)
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
                    .padding(.top, 6)
                    // Room under her for whatever hangs below her chin, since the garment is
                    // laid over her rather than stacked with her and so asks for none of its
                    // own. Reserved for the deepest peg in the wardrobe rather than for the one
                    // she has on, so the mirror does not jump as outfits are tried on.
                    .padding(.bottom, Self.mirrorSize * PigOutfit.deepestOverhang)
                    // The whole point of the screen, so it is said out loud as well as drawn.
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(wardrobe.outfit.spoken)
                    // A new outfit arrives with a bounce rather than appearing, so a tap on a
                    // peg is answered here as well as there.
                    .animation(.spring(duration: 0.35, bounce: 0.45), value: wardrobe.outfit)

                Text(wardrobe.outfit.name)
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.post)

                Text(greeting)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(GamePalette.post.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }

    /// What the room says about itself: a word of welcome the first time, and after that the
    /// one thing worth knowing — that the choice follows her out of the door.
    private var greeting: String {
        if hasJustOpened {
            return """
                The washing line at the end of the lane is yours. Pick a peg and she wears it \
                everywhere — up the trail, on the board, and out in front of the title.
                """
        }
        return wardrobe.isDressed
            ? "She wears it everywhere: up the trail, on the board, and out in front of the title."
            : "Pick a peg. She wears it everywhere — up the trail, on the board, and out in front of the title."
    }

    /// Every peg in the room. Each one is the pig in that outfit rather than the garment on its
    /// own, because what a player is choosing between is eleven pigs and not eleven hats.
    private var rail: some View {
        card {
            Text("The pegs")
                .font(.headline.weight(.heavy))
                .foregroundStyle(GamePalette.post)

            Text("\(PigOutfit.wardrobe.count) outfits, and the peg she arrived on.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(GamePalette.post.opacity(0.7))

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: 10)],
                spacing: 10
            ) {
                ForEach(pegs) { outfit in
                    peg(outfit)
                }
            }
            .padding(.top, 4)
        }
    }

    private func peg(_ outfit: PigOutfit) -> some View {
        let worn = wardrobe.outfit == outfit

        return Button {
            wear(outfit)
        } label: {
            VStack(spacing: 6) {
                DressedAnimal(animal: .pig, size: Self.pegSize, outfit: outfit)
                    // The same room under her the mirror leaves, so a boot does not land on
                    // the name of the peg it is hanging from. Aligned to the top, or the extra
                    // height would be shared out above and below and only half of it would fall
                    // where the boot is.
                    .frame(
                        height: Self.pegSize * (1.26 + PigOutfit.deepestOverhang),
                        alignment: .top
                    )

                Text(outfit.name)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(outfit.said)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2, reservesSpace: true)
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
            // The tick, where a signpost would carry its stars: the one peg in the room that
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
        .accessibilityLabel(outfit.spoken)
        .accessibilityValue(worn ? "Worn" : "")
        .accessibilityAddTraits(worn ? [.isButton, .isSelected] : .isButton)
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

    /// Takes a peg off the wall and puts it on the pig. Tapping the one she is already wearing
    /// is not nothing — it still answers in the hand — but it is not counted twice.
    private func wear(_ outfit: PigOutfit) {
        guard outfit != wardrobe.outfit else {
            haptics.tap(.light)
            return
        }
        haptics.tap(.medium)
        wardrobe.wear(outfit)
        Analytics.record(.outfitWorn(outfit.rawValue))
    }
}

#Preview("Opened from settings") {
    DressingRoomView(wardrobe: .remembering(.topHat))
}

#Preview("The lane has just given") {
    DressingRoomView(wardrobe: .remembering(), hasJustOpened: true)
}
