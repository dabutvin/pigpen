import SwiftUI

/// The paintwork a world wears round its board: the bar across the top of the screen, the face
/// of the one button that ends a go, and the colour of anything written straight onto the
/// ground between them.
///
/// The chrome used to be one dusty salmon everywhere, so a player who had climbed from a meadow
/// to a mountain to a cave was still looking at the same terracotta bar over all three. The
/// board below it had been re-skinned world by world for a while — ash on Emberpeak, flowstone
/// down in the caverns — and the bar was the last thing that gave the re-dressing away.
///
/// So each world paints its own now, out of a colour already in its ground or its sky: bark
/// green over the thicket, canal slate over the city, glacier blue over the tundra. Every
/// paint is mixed deep enough to be lettered in cream, so the bar's title, its back button
/// and the button's own word are the same white lettering in every world — what changes is
/// only what they are lettered on.
struct ChromeSkin: Sendable {
    /// The face: the top of the bar's glaze and the front of the button that ends a go.
    let paint: Color
    /// The same paint with the light off it — the bottom of that glaze, and the ledge the
    /// button stands on.
    let paintShade: Color
    /// What is painted straight onto this world's ground rather than onto a board of its own:
    /// the undo, redo and clear glyphs under the field, and the tally under the button. Those
    /// have nothing between them and the world, so they take ink where the ground is pale and
    /// chalk where it is dark — a dark glyph on the meadow's mown grass and the tundra's snow,
    /// a pale one on the thicket's leaf mould and the fen's peat.
    let groundInk: Color
}

extension ChromeSkin {
    /// Mudlark Meadow keeps the dusty salmon the whole game wore before any world had its own:
    /// it is the colour of the title screen's lettering and the first bar anybody ever sees, so
    /// the home world is the one that does not move. Ink on the ground, which is mown pasture.
    static let meadow = Self(
        paint: GamePalette.clay,
        paintShade: GamePalette.clayShade,
        groundInk: GamePalette.post
    )

    /// Thornwood Thicket: bark and moss, a shade off the canopy over the trail. Chalk on the
    /// ground, which is leaf mould in deep shade.
    static let thornwood = Self(
        paint: Color(red: 0.38, green: 0.50, blue: 0.32),
        paintShade: Color(red: 0.32, green: 0.42, blue: 0.27),
        groundInk: GamePalette.cream
    )

    /// Emberpeak: the colour of what is still burning under the ash, hotter and darker than the
    /// meadow's terracotta so the two are never mistaken for one another. Chalk on the ground,
    /// which is cinder.
    static let emberpeak = Self(
        paint: Color(red: 0.78, green: 0.30, blue: 0.17),
        paintShade: Color(red: 0.66, green: 0.25, blue: 0.14),
        groundInk: GamePalette.cream
    )

    /// Cogsworth City: wet slate off the rooftops, the blue-grey the city's silhouette has worn
    /// on the universe map since long before anybody could walk into it. Chalk on the ground,
    /// which is paving in the shade of the buildings.
    static let cogsworth = Self(
        paint: Color(red: 0.42, green: 0.46, blue: 0.53),
        paintShade: Color(red: 0.36, green: 0.39, blue: 0.45),
        groundInk: GamePalette.cream
    )

    /// Starfall Reaches: the violet the sky comes down in out past the last rooftop. Chalk on
    /// the ground, which is star dust with the night in it.
    static let starfall = Self(
        paint: Color(red: 0.45, green: 0.37, blue: 0.68),
        paintShade: Color(red: 0.38, green: 0.31, blue: 0.58),
        groundInk: GamePalette.cream
    )

    /// Gloamdeep Caverns: the dim plum of stone with no daylight on it. Chalk on the ground,
    /// which is wet flowstone lit by nothing but the diamonds in it.
    static let gloamdeep = Self(
        paint: Color(red: 0.40, green: 0.35, blue: 0.50),
        paintShade: Color(red: 0.34, green: 0.30, blue: 0.42),
        groundInk: GamePalette.cream
    )

    /// Lantern Carnival: big-top magenta, the loudest paint in the game and the only world with
    /// any business wearing it. Chalk on the ground, which is trodden sawdust after dark.
    static let lanternCarnival = Self(
        paint: Color(red: 0.80, green: 0.30, blue: 0.52),
        paintShade: Color(red: 0.68, green: 0.25, blue: 0.44),
        groundInk: GamePalette.cream
    )

    /// Sunbaked Dunes: sandstone baked a few hours past noon. Ink on the ground, which is the
    /// palest hardpan in the game and lit by nothing but glare.
    static let sunbakedDunes = Self(
        paint: Color(red: 0.78, green: 0.54, blue: 0.22),
        paintShade: Color(red: 0.66, green: 0.46, blue: 0.19),
        groundInk: GamePalette.post
    )

    /// Tidepool Cove: the green-blue of water standing in a rock pool. Ink on the ground, which
    /// is wet strand with the sun full on it.
    static let tidepoolCove = Self(
        paint: Color(red: 0.24, green: 0.56, blue: 0.57),
        paintShade: Color(red: 0.20, green: 0.47, blue: 0.48),
        groundInk: GamePalette.post
    )

    /// Frostwhisker Tundra: the blue that stands in the trough of a drift. Ink on the ground,
    /// which is snow — the brightest ground the game has, and the one that most wants a dark
    /// glyph on it.
    static let frostwhiskerTundra = Self(
        paint: Color(red: 0.42, green: 0.60, blue: 0.74),
        paintShade: Color(red: 0.36, green: 0.51, blue: 0.63),
        groundInk: GamePalette.post
    )

    /// Mirebog Fen: sedge and peat water, olive rather than the thicket's green so the two wet
    /// worlds do not read alike. Chalk on the ground, which is peat.
    static let mirebogFen = Self(
        paint: Color(red: 0.42, green: 0.47, blue: 0.28),
        paintShade: Color(red: 0.36, green: 0.40, blue: 0.24),
        groundInk: GamePalette.cream
    )

    /// Cloudspire Heights: the sky itself, since up here there is nothing else the bar could
    /// be made of. Ink on the ground, which is high turf in full daylight.
    static let cloudspireHeights = Self(
        paint: Color(red: 0.42, green: 0.57, blue: 0.78),
        paintShade: Color(red: 0.36, green: 0.48, blue: 0.66),
        groundInk: GamePalette.post
    )
}

private extension WorldTheme {
    /// Every world in trail order, so the preview below can put the twelve paints side by side
    /// and a new one is a line rather than a block.
    static let everyWorld: [WorldTheme] = [
        .meadow, .thornwood, .emberpeak, .cogsworth, .starfall, .gloamdeep,
        .lanternCarnival, .sunbakedDunes, .tidepoolCove, .frostwhiskerTundra,
        .mirebogFen, .cloudspireHeights
    ]
}

#Preview("Every world's paintwork") {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(WorldTheme.everyWorld, id: \.id) { theme in
                VStack(spacing: 0) {
                    HStack {
                        Text(theme.name)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(GamePalette.cream)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [theme.chrome.paint, theme.chrome.paintShade],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    HStack(spacing: 14) {
                        Text("Best so far: 24")
                            .font(.footnote.weight(.heavy))
                        Spacer()
                        Image(systemName: "arrow.uturn.backward")
                        Image(systemName: "arrow.uturn.forward")
                        Image(systemName: "trash")
                    }
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(theme.chrome.groundInk)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(theme.day.foreground)
                }
            }
        }
    }
}
