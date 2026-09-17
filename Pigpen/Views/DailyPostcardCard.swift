import CoreTransferable
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// A held day painted onto a card: the game's own wordmark across the top, the day under
/// it, the day's own board drawn the way the game draws it, the stars it gave up, what the
/// pen came to, the pig's word on it, and the day's address along the bottom.
///
/// The board is a real `FieldView` rather than a picture of one — the same mud with the same
/// stones in it, the same water, the same pig in whatever she has on this week. Nothing here
/// knows how to draw a field, which is the point: a card that drew its own would drift away
/// from the board it stands for the first time a world was repainted.
///
/// It is laid out to be *rendered*: handed to `ImageRenderer`, it comes out a picture a chat
/// can carry. So it is always exactly `width` across, on screen as well as in the picture —
/// the card held up before it goes is the card that goes, down to the pixel — and everything
/// on it is measured in points off that rather than left to the room it is given.
struct DailyPostcardCard: View {
    let postcard: DailyPostcard
    /// Whether the wall is standing on the board. Off is the day as everybody was handed it
    /// that morning, which is the card that can be sent to somebody who has not played yet.
    var showsFencing = false
    /// What the pig has on. Handed in rather than asked of the wardrobe here, so a preview
    /// can dress her without a choice saved on the machine it is running on.
    var outfit: PigOutfit = .asSheComes

    /// How wide the card is, always. Narrow enough to stand inside the narrowest phone the
    /// game runs on with room either side, wide enough that a nine by nine board drawn on it
    /// has tiles a friend can count.
    static let width: CGFloat = 340
    /// The grass round the card, and the card's own margin inside that.
    private static let verge: CGFloat = 14
    private static let margin: CGFloat = 15
    /// What is left across the middle for the board and everything written under it.
    private static var span: CGFloat { width - 2 * verge - 2 * margin }

    var body: some View {
        VStack(spacing: 11) {
            masthead
            field
            stars
            chips
            saying
            address
        }
        .padding(Self.margin)
        .background(plank)
        .overlay(nailHeads)
        .shadow(color: .black.opacity(0.28), radius: 7, y: 4)
        .padding(Self.verge)
        .background(pasture)
        .frame(width: Self.width)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(postcard.spoken)
    }

    // MARK: - Up the card

    /// The game's own name over the day it is a card for, painted the way the title screen
    /// paints it rather than typed in capitals: `PlantedWord`, the same letters cut out on
    /// the same white, at a size a card can hold. A card is the game turning up in somebody
    /// else's chat, and it should turn up under its own name.
    ///
    /// Centred, like everything under it. The one row that was not was the only thing on the
    /// card reading as a form rather than as a card.
    private var masthead: some View {
        VStack(spacing: 6) {
            PlantedWord(word: "PIGPEN", size: 30, planted: 1)

            Text(postcard.date.title.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(GamePalette.post.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    /// The wall as the card draws it: standing on the board, or not on it at all. The whole
    /// of the promise the switch makes lives on this line and the one under it, which is why
    /// both are out here in the open where a test can read them — nothing on a phone reports
    /// a card that quietly handed over the answer.
    var wallDrawn: Set<GridPoint> { showsFencing ? postcard.fences : [] }
    /// The ground that wall holds, washed gold the way the field washes it.
    var groundHeld: Set<GridPoint> { showsFencing ? postcard.pen : [] }

    /// The day's board. Standing still and answering nothing — a picture of a field cannot be
    /// fenced, and a finger on the card should not think otherwise.
    private var field: some View {
        FieldView(
            level: postcard.level,
            fences: wallDrawn,
            penTiles: groundHeld,
            penGlow: showsFencing ? 1 : 0,
            isAsGoodAsItGets: showsFencing && postcard.verdict.isAsGoodAsItGets,
            animals: .standing(on: postcard.level),
            outfit: outfit,
            onStroke: { _ in },
            onStrokeEnd: {}
        )
        .allowsHitTesting(false)
        // Measured rather than proposed. A field lays itself out inside whatever height it is
        // handed, and a card being painted into a picture is handed none at all — so the board
        // is given the span across and as many tiles down as the day has rows, which is the
        // same arithmetic the board would have done for itself.
        .frame(width: Self.span, height: boardHeight)
        // Standing on the card rather than printed onto it, the same as the board standing
        // on the meadow.
        .shadow(color: .black.opacity(0.28), radius: 5, y: 3)
    }

    /// The span across, cut into as many tiles as the day has columns, as many times down as
    /// it has rows — which is the same arithmetic `BoardGeometry` would have done for itself
    /// had anything told it how tall it was allowed to be.
    private var boardHeight: CGFloat {
        let cell = Self.span / CGFloat(max(postcard.level.columnCount, 1))
        return cell * CGFloat(postcard.level.rowCount)
    }

    /// What the day gave up, big enough to read at the size a chat shows a picture. Empty
    /// stars in ink rather than the cream they wear on a dark square: three pale ones on a
    /// cream card read as no stars at all.
    private var stars: some View {
        StarRow(
            stars: postcard.verdict.stars,
            size: 21,
            hasTheBestPen: postcard.verdict.isAsGoodAsItGets,
            hollow: GamePalette.post.opacity(0.17)
        )
        .padding(.top, 1)
    }

    /// What the pen came to, what it cost, how long it took and the run of days behind it —
    /// each on a tag of its own, and each only when there is one to show.
    private var chips: some View {
        // What the pen came to wears the pen's own gold; everything beside it is a quieter
        // tag in ink, so the card has one number on it that is meant to be read first.
        let quiet = GamePalette.post.opacity(0.08)
        let quietInk = GamePalette.post.opacity(0.72)

        return HStack(spacing: 6) {
            chip(postcard.ground, on: GamePalette.pen, ink: GamePalette.post)
            chip(postcard.wall, on: quiet, ink: quietInk)

            if let clock = postcard.clock {
                chip(clock, icon: "stopwatch", on: quiet, ink: quietInk)
            }
            if postcard.streak > 1 {
                chip(
                    "\(postcard.streak)",
                    icon: "flame.fill",
                    on: GamePalette.barn.opacity(0.12),
                    ink: GamePalette.barn
                )
            }
        }
    }

    private func chip(_ said: String, icon: String? = nil, on back: Color, ink: Color) -> some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .black))
            }
            Text(said)
                .font(.system(size: 11.5, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(ink)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(back))
    }

    /// The pig's word on the pen, which is the line a friend actually reads.
    private var saying: some View {
        Text("“\(postcard.pigSays)”")
            .font(.system(size: 14, weight: .heavy, design: .rounded))
            .foregroundStyle(GamePalette.post.opacity(0.8))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Where the day lives. Typed out rather than tapped: this is a picture, and the address
    /// in it is for the friend who would rather go and have their own go than ask how.
    private var address: some View {
        VStack(spacing: 7) {
            Rectangle()
                .fill(GamePalette.post.opacity(0.14))
                .frame(height: 1)

            Text(postcard.address)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(GamePalette.post.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    // MARK: - What it is painted on

    /// Sawn board, the same plank today's puzzle is nailed to on the title screen.
    private var plank: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(GamePalette.cream)
            // Lit along its top edge, the way every painted thing in the game is. It used to
            // run to the middle of the plank, which on a card this tall is half of it: the
            // masthead came out on cold grey-white and the tally under the board on cream,
            // with the seam between them across the middle. A hand's breadth of light at the
            // top does what the light was for and leaves the cream alone.
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.45), .clear],
                            startPoint: .top,
                            endPoint: UnitPoint(x: 0.5, y: 0.15)
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.22), lineWidth: 1.5)
            }
    }

    private var nailHeads: some View {
        VStack {
            HStack {
                nailHead
                Spacer(minLength: 0)
                nailHead
            }
            Spacer(minLength: 0)
            HStack {
                nailHead
                Spacer(minLength: 0)
                nailHead
            }
        }
        .padding(8)
    }

    private var nailHead: some View {
        Circle()
            .fill(GamePalette.post.opacity(0.32))
            .frame(width: 5, height: 5)
    }

    /// The grass the card is standing on, which is also what keeps it a card: a cream page
    /// sent bare into a chat is a cream page on a white bubble, with nothing to say where it
    /// stops.
    ///
    /// Grass in the shade, which took two goes to find. The pasture's own two lightest greens
    /// left the card looking unfinished at the edges rather than mounted; open country's
    /// green, which came next, is a summer green at full strength and read as a slab of
    /// colour somebody had dropped the card onto — it shouted across a board painted in muds
    /// and creams. What a border is for is to say where the card stops, and these are the
    /// greens the meadow keeps for ground the light is off: dark enough against cream to be
    /// a mount, quiet enough to let the board be the thing looked at.
    private var pasture: some View {
        LinearGradient(
            colors: [GamePalette.Pasture.day.foreground, GamePalette.Pasture.day.blade],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - The picture it makes

/// The card as a picture, which is the thing a share sheet actually carries: a PNG, handed
/// over as one to anything that will take an image.
struct PostcardPicture: Transferable, Sendable {
    let png: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { $0.png }
            .suggestedFileName("Pigpen.png")
    }
}

extension DailyPostcardCard {
    /// Paints the card and hands back the picture along with the picture as an `Image`, for
    /// the share sheet's own thumbnail of it.
    ///
    /// Three times over, so the card arrives on a friend's screen at the size a photo does
    /// rather than as a card blown up — a phone hands a picture on at the pixels it was given
    /// and nothing downstream can put back what was never drawn.
    @MainActor
    func painted() -> (picture: PostcardPicture, thumbnail: Image)? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        guard let drawn = renderer.uiImage, let png = drawn.pngData() else { return nil }
        return (PostcardPicture(png: png), Image(uiImage: drawn))
    }
}

// MARK: - Previews

#Preview("The best pen there is") {
    let wednesday = DailyDate(year: 2026, month: 4, day: 22)
    let card = DailyAlmanac.level(on: wednesday).flatMap {
        DailyPostcard(
            date: wednesday,
            level: $0,
            fences: [
                GridPoint(row: 1, column: 3), GridPoint(row: 2, column: 4),
                GridPoint(row: 3, column: 0), GridPoint(row: 3, column: 5),
                GridPoint(row: 4, column: 0), GridPoint(row: 5, column: 0),
                GridPoint(row: 6, column: 1), GridPoint(row: 7, column: 2),
                GridPoint(row: 7, column: 4), GridPoint(row: 8, column: 3)
            ],
            seconds: 134,
            streak: 6
        )
    }

    return ScrollView {
        VStack(spacing: 20) {
            if let card {
                DailyPostcardCard(postcard: card, showsFencing: true, outfit: .baseballCap)
                DailyPostcardCard(postcard: card)
            }
        }
        .frame(maxWidth: DailyPostcardCard.width)
        .padding(20)
    }
    .background(GamePalette.mud)
}
