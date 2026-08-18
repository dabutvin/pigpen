import SwiftUI

/// How a world paints the board itself: the ground it is cut out of, the water lying in that
/// ground, and the fencing the player builds on top of it.
///
/// A theme has always changed the light around the board — the trail, the sky, the ground the
/// screen sits on — while the board in the middle of it stayed the meadow's mud and the meadow's
/// blue water in every world in the game. That is the one place a themed world used to give
/// itself away: a mountain drawn in ash and cinder with a river bend in it, a cave with pasture
/// mud on the floor.
///
/// So the board carries a skin of its own now. It changes nothing a player can do — mud is
/// still the ground a fence goes into and water is still the wall a pen never pays for,
/// whatever either is called here — but the mud on Emberpeak is ash with cinder in it, the
/// water in Cogsworth is a canal with a slick on it, and the fencing at the carnival is
/// bunting strung between two poles. One board, one solver, eleven grounds.
///
/// Unlike the trail's palette, a skin does not follow the player's screen from daylight to
/// dusk. The board has always kept one set of colours whatever the appearance, because the
/// board is the thing being read rather than the thing being looked at.
struct FieldSkin: Sendable {
    /// The ground, with the light full on it and off it, so the field is lit from above the
    /// way every other drawn thing in the game is.
    let ground: Color
    let groundLit: Color
    let groundShade: Color
    /// What the ground is strewn or veined with, in whatever the grain makes of it: stones on
    /// the meadow, leaves in the wood, cinder still lit on the mountain, the wet lip of a rib
    /// down in the caverns.
    let grit: Color
    /// What the ground is made of, which is what decides the marks scattered over it.
    let grain: Grain

    /// The water: its shallows, its deep, the light breaking on it, and the bank it leaves.
    let water: Color
    let waterDeep: Color
    let waterLight: Color
    let shore: Color
    /// What the water is doing, which is what decides the marks drawn on the surface of it.
    let surface: Surface

    /// The fencing: the churned ground a piece stands in, the rails across it, and the
    /// uprights they are fixed to.
    let post: Color
    let rail: Color
    let picket: Color
    /// What a piece of fencing is, which is what decides how one is built on a tile.
    let fencing: Fencing

    /// What the ground of a world is made of. The board is drawn tile by tile, so this is the
    /// mark one tile of ground carries — three stones, a scatter of leaves, a course of setts.
    enum Grain: Sendable, Hashable {
        /// Stones turned up in the mud.
        case stones
        /// Leaves lying where they fell.
        case leafMould
        /// Ash, with the odd ember still going in it.
        case cinder
        /// Paving: courses of setts with the joints between them doing the drawing.
        case setts
        /// Dust with things having landed in it: shallow pits ringed pale.
        case pits
        /// Flowstone laid down in ribs, each with a lit lip and a black step under it.
        case ribs
        /// Trodden ground with sawdust thrown down over it.
        case sawdust
        /// Hardpan: baked clay dried until it cracked, in plates with the light on their lips.
        case hardpan
        /// Wet strand: sand the tide has only just let go of, with wrack and shell grit left
        /// lying in lines where the water turned back.
        case strand
        /// Sastrugi: snow over sea ice, combed by the wind into long parallel waves with a lit
        /// crest and a blue trough apiece.
        case sastrugi
        /// Peat: ground that has never dried out, with sedge coming up through it in tussocks
        /// and a wet sheen standing in the low places.
        case peat
    }

    /// What the water of a world does. Water is a wall the pen never pays for, so it is worth
    /// its looking like one — and worth its looking like the right one.
    enum Surface: Sendable, Hashable {
        /// Light breaking on open water.
        case ripples
        /// A standing pool, with rings where something went in.
        case peat
        /// A mountain tarn, giving off what the mountain is giving off.
        case steam
        /// A canal, with a slick lying on it.
        case sheen
        /// A well where a star went in, still holding the light of it.
        case starlight
        /// One river, running.
        case flow
        /// Not water at all: a crowd, stood shoulder to shoulder under the lanterns.
        case crowd
        /// Not water either: a dune, combed by the wind, lit along the crest and dropping away
        /// down the slipface under it.
        case dune
        /// A tidepool: seawater the tide left behind, ringed with foam where it settled and
        /// still catching the sky.
        case rockPool
        /// Not water to look at at all: a pressure ridge, ice crushed upward where two floes
        /// met, in jagged blades with the light caught on their broken edges.
        case pressureRidge
        /// A fen channel: still water skinned over with duckweed, dark where something has
        /// pushed through the green and closed it again.
        case duckweed
    }

    /// What a piece of fencing is on this world's ground. Every one of them is the same
    /// piece — one tile of the budget, laid or torn out the same way — and the only thing that
    /// changes is what somebody would have built out here.
    enum Fencing: Sendable, Hashable {
        /// Pickets and rails: the fence the meadow has always had.
        case pickets
        /// A hurdle: stakes with withies woven through them.
        case hurdle
        /// Stakes charred black, with the ground still warm under them.
        case charredStakes
        /// Wrought iron: bars under a spear head, the way a city fences anything.
        case railings
        /// Posts with a light strung between them, which is the only fence that shows out here.
        case beacons
        /// Pit props: two uprights and a lintel, wedged the way a gallery is held up.
        case props
        /// Painted poles with a swag of bunting between them.
        case bunting
        /// A drift fence: bleached palings wired together and half buried in what they caught.
        case driftFence
        /// Groynes: sea-blackened timbers driven into the strand, weeded to the waterline.
        case groynes
        /// A snow fence: slats wired to two driven posts, with the drift already banked up
        /// against them.
        case snowFence
        /// Bog oak: posts pulled black out of the peat and driven back into it, with one
        /// rail across and the rushes already up around their feet.
        case bogOak
    }
}

extension FieldSkin {
    /// The meadow's board, exactly as the game has always drawn it: mud with stones turned up
    /// in it, blue water with the light breaking on it, and pale timber fencing.
    static let meadow = Self(
        ground: Color(red: 0.64, green: 0.49, blue: 0.36),
        groundLit: Color(red: 0.71, green: 0.56, blue: 0.42),
        groundShade: Color(red: 0.55, green: 0.41, blue: 0.29),
        grit: Color(red: 0.44, green: 0.32, blue: 0.22),
        grain: .stones,
        water: Color(red: 0.24, green: 0.55, blue: 0.76),
        waterDeep: Color(red: 0.16, green: 0.42, blue: 0.64),
        waterLight: Color(red: 0.76, green: 0.90, blue: 0.98),
        shore: Color(red: 0.82, green: 0.72, blue: 0.54),
        surface: .ripples,
        post: Color(red: 0.27, green: 0.17, blue: 0.10),
        rail: Color(red: 0.62, green: 0.42, blue: 0.24),
        picket: Color(red: 0.78, green: 0.60, blue: 0.39),
        fencing: .pickets
    )

    /// The thicket's: leaf mould rather than mud, peat pools rather than open water — brown
    /// standing water with the green of the canopy in it — and hurdles, since a wood fences
    /// itself out of what it has lying about.
    static let thornwood = Self(
        ground: Color(red: 0.45, green: 0.38, blue: 0.25),
        groundLit: Color(red: 0.53, green: 0.45, blue: 0.30),
        groundShade: Color(red: 0.34, green: 0.28, blue: 0.18),
        grit: Color(red: 0.26, green: 0.22, blue: 0.11),
        grain: .leafMould,
        water: Color(red: 0.21, green: 0.44, blue: 0.40),
        waterDeep: Color(red: 0.12, green: 0.30, blue: 0.29),
        waterLight: Color(red: 0.66, green: 0.88, blue: 0.76),
        shore: Color(red: 0.52, green: 0.51, blue: 0.31),
        surface: .peat,
        post: Color(red: 0.20, green: 0.15, blue: 0.09),
        rail: Color(red: 0.50, green: 0.39, blue: 0.24),
        picket: Color(red: 0.68, green: 0.57, blue: 0.37),
        fencing: .hurdle
    )

    /// The mountain's: ash with cinder still going in it, and a tarn — meltwater standing on
    /// cold rock, which is a mineral green rather than a meadow blue, and steaming, because
    /// everything up here is. The fencing is what is left of the trees: stakes burnt black.
    static let emberpeak = Self(
        ground: Color(red: 0.43, green: 0.37, blue: 0.34),
        groundLit: Color(red: 0.51, green: 0.44, blue: 0.41),
        groundShade: Color(red: 0.31, green: 0.26, blue: 0.24),
        grit: Color(red: 0.85, green: 0.32, blue: 0.12),
        grain: .cinder,
        water: Color(red: 0.33, green: 0.59, blue: 0.59),
        waterDeep: Color(red: 0.17, green: 0.40, blue: 0.44),
        waterLight: Color(red: 0.90, green: 0.96, blue: 0.94),
        shore: Color(red: 0.58, green: 0.50, blue: 0.44),
        surface: .steam,
        post: Color(red: 0.14, green: 0.11, blue: 0.10),
        rail: Color(red: 0.40, green: 0.28, blue: 0.23),
        picket: Color(red: 0.34, green: 0.28, blue: 0.27),
        fencing: .charredStakes
    )

    /// The city's: paving rather than ground, laid in courses somebody set, and a canal — water
    /// that has been standing between two walls long enough to go green and take a slick. The
    /// fencing is wrought iron, since nothing here was made out of what was to hand.
    static let cogsworth = Self(
        ground: Color(red: 0.50, green: 0.50, blue: 0.53),
        groundLit: Color(red: 0.58, green: 0.58, blue: 0.61),
        groundShade: Color(red: 0.39, green: 0.39, blue: 0.43),
        grit: Color(red: 0.28, green: 0.28, blue: 0.32),
        grain: .setts,
        water: Color(red: 0.27, green: 0.43, blue: 0.41),
        waterDeep: Color(red: 0.15, green: 0.28, blue: 0.30),
        waterLight: Color(red: 0.72, green: 0.86, blue: 0.80),
        shore: Color(red: 0.44, green: 0.44, blue: 0.43),
        surface: .sheen,
        post: Color(red: 0.13, green: 0.14, blue: 0.17),
        rail: Color(red: 0.33, green: 0.36, blue: 0.41),
        picket: Color(red: 0.55, green: 0.58, blue: 0.63),
        fencing: .railings
    )

    /// The reaches': dust with the sky lying on it, pitted where things have come in, and
    /// water that is not weather at all — a well where a star went in, still lit from the
    /// bottom. The fencing is posts with a light strung between them, because on ground this
    /// pale nothing else would show.
    static let starfall = Self(
        ground: Color(red: 0.48, green: 0.45, blue: 0.56),
        groundLit: Color(red: 0.56, green: 0.53, blue: 0.64),
        groundShade: Color(red: 0.36, green: 0.34, blue: 0.45),
        grit: Color(red: 0.29, green: 0.27, blue: 0.38),
        grain: .pits,
        water: Color(red: 0.42, green: 0.42, blue: 0.86),
        waterDeep: Color(red: 0.22, green: 0.21, blue: 0.56),
        waterLight: Color(red: 0.94, green: 0.93, blue: 1.00),
        shore: Color(red: 0.60, green: 0.57, blue: 0.70),
        surface: .starlight,
        post: Color(red: 0.19, green: 0.17, blue: 0.28),
        rail: Color(red: 0.74, green: 0.70, blue: 1.00),
        picket: Color(red: 0.78, green: 0.76, blue: 0.90),
        fencing: .beacons
    )

    /// The caverns': wet flowstone laid down in ribs, and the river running through it — dark
    /// and glassy, since there is no sky down here for water to take a colour from and what it
    /// has instead is the crystals. The fencing is pit props, which is how anybody holds
    /// anything up underground.
    static let gloamdeep = Self(
        ground: Color(red: 0.38, green: 0.43, blue: 0.42),
        groundLit: Color(red: 0.46, green: 0.51, blue: 0.50),
        groundShade: Color(red: 0.27, green: 0.32, blue: 0.31),
        grit: Color(red: 0.74, green: 0.92, blue: 0.90),
        grain: .ribs,
        water: Color(red: 0.16, green: 0.43, blue: 0.46),
        waterDeep: Color(red: 0.07, green: 0.25, blue: 0.30),
        waterLight: Color(red: 0.68, green: 0.96, blue: 0.97),
        shore: Color(red: 0.44, green: 0.50, blue: 0.47),
        surface: .flow,
        post: Color(red: 0.17, green: 0.14, blue: 0.11),
        rail: Color(red: 0.52, green: 0.42, blue: 0.29),
        picket: Color(red: 0.66, green: 0.55, blue: 0.40),
        fencing: .props
    )

    /// The carnival's: trodden ground with sawdust thrown down over it, and a crowd where every
    /// other world has water — a body of people under the lanterns, which walls a pen exactly
    /// as a mere does and looks nothing like one. The fencing is painted poles with bunting
    /// between them, because a fairground fences things off to be looked at.
    static let lanternCarnival = Self(
        ground: Color(red: 0.55, green: 0.44, blue: 0.32),
        groundLit: Color(red: 0.63, green: 0.51, blue: 0.37),
        groundShade: Color(red: 0.44, green: 0.34, blue: 0.24),
        grit: Color(red: 0.88, green: 0.78, blue: 0.56),
        grain: .sawdust,
        water: Color(red: 0.60, green: 0.28, blue: 0.46),
        waterDeep: Color(red: 0.38, green: 0.15, blue: 0.33),
        waterLight: Color(red: 1.00, green: 0.84, blue: 0.56),
        shore: Color(red: 0.71, green: 0.55, blue: 0.38),
        surface: .crowd,
        post: Color(red: 0.28, green: 0.10, blue: 0.20),
        rail: Color(red: 0.98, green: 0.80, blue: 0.36),
        picket: Color(red: 0.96, green: 0.93, blue: 0.88),
        fencing: .bunting
    )

    /// The desert's: hardpan baked until it cracked into plates, and a dune where every other
    /// world has water — sand too steep to climb and too loose to hold a post, which walls a pen
    /// exactly as a river does and is the only wall in the game that could blow somewhere else by
    /// morning. The fencing is a drift fence: bleached palings wired together and already half
    /// buried in the sand they were put up to stop.
    static let sunbakedDunes = Self(
        ground: Color(red: 0.76, green: 0.67, blue: 0.51),
        groundLit: Color(red: 0.84, green: 0.75, blue: 0.58),
        groundShade: Color(red: 0.66, green: 0.57, blue: 0.42),
        grit: Color(red: 0.48, green: 0.38, blue: 0.27),
        grain: .hardpan,
        water: Color(red: 0.90, green: 0.76, blue: 0.47),
        waterDeep: Color(red: 0.70, green: 0.54, blue: 0.31),
        waterLight: Color(red: 1.00, green: 0.96, blue: 0.80),
        shore: Color(red: 0.86, green: 0.75, blue: 0.55),
        surface: .dune,
        post: Color(red: 0.35, green: 0.26, blue: 0.18),
        rail: Color(red: 0.58, green: 0.47, blue: 0.34),
        picket: Color(red: 0.88, green: 0.82, blue: 0.70),
        fencing: .driftFence
    )

    /// The cove's: wet strand rather than dry ground — sand the tide has only just let go of,
    /// dark with the water still in it — and the water a tidepool, ringed with foam and holding
    /// more sky than anything else on the board. The fencing is groynes: sea-blackened timbers
    /// driven in deep, because anything lighter goes with the tide.
    static let tidepoolCove = Self(
        ground: Color(red: 0.62, green: 0.56, blue: 0.45),
        groundLit: Color(red: 0.70, green: 0.64, blue: 0.52),
        groundShade: Color(red: 0.52, green: 0.46, blue: 0.36),
        grit: Color(red: 0.38, green: 0.34, blue: 0.27),
        grain: .strand,
        water: Color(red: 0.22, green: 0.58, blue: 0.62),
        waterDeep: Color(red: 0.12, green: 0.40, blue: 0.48),
        waterLight: Color(red: 0.85, green: 0.97, blue: 0.96),
        shore: Color(red: 0.80, green: 0.74, blue: 0.58),
        surface: .rockPool,
        post: Color(red: 0.20, green: 0.17, blue: 0.14),
        rail: Color(red: 0.42, green: 0.36, blue: 0.28),
        picket: Color(red: 0.55, green: 0.50, blue: 0.42),
        fencing: .groynes
    )

    /// The tundra's: snow over sea ice, combed into sastrugi and blue in every trough, and
    /// where every other world has water this one has a pressure ridge — ice crushed upward
    /// where two floes met, too sheer to climb and no ground to build on, which walls a pen
    /// exactly as a river does and stands *up* out of the board rather than lying in it. The
    /// fencing is a snow fence: slats wired to driven posts, half buried in their own drift,
    /// because that is the only fence anybody builds where the ground is frozen.
    static let frostwhiskerTundra = Self(
        ground: Color(red: 0.82, green: 0.87, blue: 0.92),
        groundLit: Color(red: 0.90, green: 0.94, blue: 0.97),
        groundShade: Color(red: 0.70, green: 0.77, blue: 0.86),
        grit: Color(red: 0.55, green: 0.65, blue: 0.78),
        grain: .sastrugi,
        water: Color(red: 0.62, green: 0.78, blue: 0.88),
        waterDeep: Color(red: 0.36, green: 0.54, blue: 0.72),
        waterLight: Color(red: 0.97, green: 0.99, blue: 1.00),
        shore: Color(red: 0.74, green: 0.82, blue: 0.90),
        surface: .pressureRidge,
        post: Color(red: 0.24, green: 0.20, blue: 0.16),
        rail: Color(red: 0.48, green: 0.40, blue: 0.30),
        picket: Color(red: 0.63, green: 0.55, blue: 0.44),
        fencing: .snowFence
    )

    /// The fen's: peat rather than mud — ground that has never once dried, with sedge coming
    /// up through it — and the water a channel skinned over with duckweed, greener than the
    /// ground it runs through, which is the one water in the game that looks more solid than
    /// the land. The fencing is bog oak: posts pulled black out of the peat and driven back
    /// into it, because out here the ground has already eaten every lighter fence anybody
    /// tried.
    static let mirebogFen = Self(
        ground: Color(red: 0.40, green: 0.36, blue: 0.24),
        groundLit: Color(red: 0.48, green: 0.44, blue: 0.30),
        groundShade: Color(red: 0.31, green: 0.28, blue: 0.18),
        grit: Color(red: 0.58, green: 0.58, blue: 0.34),
        grain: .peat,
        water: Color(red: 0.33, green: 0.47, blue: 0.25),
        waterDeep: Color(red: 0.16, green: 0.28, blue: 0.16),
        waterLight: Color(red: 0.68, green: 0.82, blue: 0.44),
        shore: Color(red: 0.52, green: 0.50, blue: 0.32),
        surface: .duckweed,
        post: Color(red: 0.13, green: 0.11, blue: 0.09),
        rail: Color(red: 0.35, green: 0.30, blue: 0.22),
        picket: Color(red: 0.28, green: 0.25, blue: 0.20),
        fencing: .bogOak
    )
}
