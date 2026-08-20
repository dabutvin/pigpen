import SwiftUI
import UIKit

/// The universe map: every world there is, strung up a winding path through space, each drawn as
/// a little planet with its boss shown on it.
///
/// It opens from Play only once the meadow is held, and it is where a world's send-off lands —
/// the world just finished behind you, the next one lit up ahead, and the rest standing out past
/// them as silhouettes to go on for. A world opens once the one before it is held; tapping an
/// open one drops into its trail, playing the world's own opening film first if it is owed.
@MainActor
struct UniverseMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var progress: UniverseProgress
    /// The world whose trail is on screen, if any.
    @State private var entering: Int?
    /// A world's opening film, over the map, before its trail comes up.
    @State private var openingFilm: WorldFilm?
    /// The world to drop into once that film has come down, so the two never fight over the
    /// screen — the same hand-off the title screen makes for the opening.
    @State private var pendingEntry: Int?
    /// A world that has only just opened, so it can make something of itself when the map
    /// comes back from the one before it.
    @State private var unveiled: Int?
    @State private var frontierWhenLeft: Int
    /// Whether the map has already settled on the frontier once, so coming back from a world
    /// does not haul the view off it.
    @State private var settled = false
    /// Whether the offer of the full game is up, raised by tapping a world that is behind the
    /// wall rather than shut for want of stars.
    @State private var isOffering = false

    init(progress: UniverseProgress = UniverseProgress()) {
        _progress = State(initialValue: progress)
        _frontierWhenLeft = State(initialValue: progress.frontier)
    }

    // The winding path up the map.
    private static let spacing: CGFloat = 156
    private static let apron: CGFloat = 150
    private static let headroom: CGFloat = 150

    private var height: CGFloat {
        Self.apron + CGFloat(max(progress.count - 1, 0)) * Self.spacing + Self.headroom
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scroller in
                ScrollView(.vertical) {
                    map(width: proxy.size.width)
                        .frame(width: proxy.size.width, height: height)
                }
                .scrollIndicators(.hidden)
                .defaultScrollAnchor(.bottom)
                .task { await settleOnFrontier(scroller) }
            }
        }
        .background(Color(red: 0.04, green: 0.05, blue: 0.12))
        .safeAreaInset(edge: .top, spacing: 0) { banner }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $entering) { index in
            if let game = progress.universe.game(at: index), let world = progress.progress(for: index) {
                WorldMapView(world: game, progress: world)
            }
        }
        .fullScreenCover(item: $openingFilm, onDismiss: { openPendingWorld() }) { film in
            WorldFilmView(film: film) { endOpening(film) }
        }
        .sheet(isPresented: $isOffering) {
            FullGameOffer(fullGame: progress.fullGame, source: .map)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            progress.reload()
            revealAnyNewWorld()
        }
    }

    // MARK: - The map

    private func map(width: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            CosmicBackdrop(accents: accents)
            path(width: width)
            worlds(width: width)
        }
    }

    /// The dashed road between the worlds, drawn faint the whole way and bright as far as the
    /// player has opened it.
    private func path(width: CGFloat) -> some View {
        let points = (0..<progress.count).map { position(of: $0, width: width) }
        let opened = progress.frontier
        return Canvas { context, _ in
            guard points.count > 1 else { return }

            var whole = Path()
            whole.move(to: points[0])
            for index in 1..<points.count {
                whole.addQuadCurve(to: points[index], control: control(points[index - 1], points[index]))
            }
            context.stroke(
                whole,
                with: .color(.white.opacity(0.12)),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [3, 12])
            )

            let litTo = min(opened, points.count - 1)
            if litTo >= 1 {
                var lit = Path()
                lit.move(to: points[0])
                for index in 1...litTo {
                    lit.addQuadCurve(to: points[index], control: control(points[index - 1], points[index]))
                }
                context.stroke(
                    lit,
                    with: .color(.white.opacity(0.5)),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [3, 12])
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func worlds(width: CGFloat) -> some View {
        // Laid out rather than positioned: a positioned view fills the space it is given, so
        // the scroller would have nothing to bring a world into view by. Placed properly, each
        // planet has a frame of its own and the map can be told to settle on one.
        let points = (0..<progress.count).map { position(of: $0, width: width) }
        return ConstellationLayout(points: points) {
            ForEach(Array(0..<progress.count), id: \.self) { index in
                let world = progress.world(at: index)
                Button {
                    enter(index)
                } label: {
                    WorldPlanet(
                        theme: world.theme,
                        boss: world.boss,
                        state: progress.state(of: index),
                        subtitle: subtitle(for: index),
                        forSale: progress.isForSale(index),
                        beckons: beckons(for: index),
                        celebrating: unveiled == index
                    )
                }
                .buttonStyle(SignpostButtonStyle())
                // A world for sale is tappable even where progress has not reached it — the tap
                // is what raises the offer. Only worlds that are neither open nor for sale are
                // dead to the touch.
                .disabled(!progress.isUnlocked(index) && !progress.isForSale(index))
                .id(index)
            }
        }
    }

    /// Which world pulses its ring: the frontier alone, whether that is the next world to play
    /// or — before a player pays — the thicket at the head of everything for sale. One world
    /// moving on a map where all the rest past the meadow are for sale, rather than eleven.
    private func beckons(for index: Int) -> Bool {
        guard index == progress.frontier else { return false }
        return progress.isForSale(index) || progress.state(of: index) == .playable
    }

    /// A line under a world's name: how much of it is held, or what is keeping it shut. A
    /// world behind the wall says so over whatever its stars would — it is not locked for
    /// want of play, it is waiting on the full game.
    private func subtitle(for index: Int) -> String {
        if progress.isForSale(index) { return "Unlock the full game" }
        switch progress.state(of: index) {
        case .cleared: return "Every pen held"
        case .playable:
            return progress.isCleared(index) ? "Every pen held" : "\(heldCount(index)) of \(worldCount(index)) held"
        case .comingSoon: return "Coming soon"
        case .locked: return "Locked"
        }
    }

    private func heldCount(_ index: Int) -> Int {
        guard let game = progress.universe.game(at: index) else { return 0 }
        return game.map.nodes.filter { (progress.stars[$0.id] ?? 0) > 0 }.count
    }

    private func worldCount(_ index: Int) -> Int {
        progress.universe.game(at: index)?.map.count ?? 0
    }

    /// The colours of the worlds, for tinting the nebulae behind them.
    private var accents: [Color] {
        progress.universe.worlds.map(\.theme.accent)
    }

    // MARK: - Where a world stands

    private func position(of index: Int, width: CGFloat) -> CGPoint {
        let verge = max(width * 0.24, 54)
        let sway = sin(Double(index) * 0.9 + 0.7)
        return CGPoint(
            x: width / 2 + CGFloat(sway) * (width / 2 - verge),
            y: height - Self.apron - CGFloat(index) * Self.spacing
        )
    }

    private func control(_ from: CGPoint, _ to: CGPoint) -> CGPoint {
        CGPoint(x: (from.x + to.x) / 2 + (to.y - from.y) * 0.12, y: (from.y + to.y) / 2)
    }

    // MARK: - The banner

    private var banner: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(GamePalette.post)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(GamePalette.cream))
            }
            .accessibilityLabel("Back to the title screen")

            VStack(alignment: .leading, spacing: 0) {
                Text("The Universe")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                Text("\(clearedWorlds) of \(progress.count) worlds held")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.75)
            }
            .foregroundStyle(GamePalette.cream)

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "globe.americas.fill")
                    .foregroundStyle(GamePalette.pen)
                Text("\(clearedWorlds)/\(progress.count)")
                    .foregroundStyle(GamePalette.cream)
                    .monospacedDigit()
            }
            .font(.system(size: 14, weight: .heavy, design: .rounded))
            .padding(.vertical, 6)
            .padding(.horizontal, 11)
            .background(Capsule().fill(.black.opacity(0.28)))
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            LinearGradient(
                colors: [Color(red: 0.14, green: 0.12, blue: 0.28), Color(red: 0.07, green: 0.06, blue: 0.16)],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .bottom) {
                Rectangle().fill(.black.opacity(0.3)).frame(height: 2)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    private var clearedWorlds: Int {
        (0..<progress.count).filter { progress.isCleared($0) }.count
    }

    // MARK: - Entering a world

    private func enter(_ index: Int) {
        // A world behind the wall opens the offer rather than its trail — checked before the
        // progress gate, since a world for sale is one the player has not yet earned their way
        // to and would otherwise be turned away from. This is the upgrade reached from the
        // universe map, raised on the very world the player reached for.
        if progress.isBehindTheWall(index) {
            Haptics.tap(.medium)
            Analytics.record(.offerShown(from: FullGameOfferSource.map.rawValue))
            isOffering = true
            return
        }
        guard progress.isUnlocked(index) else { return }
        guard let game = progress.universe.game(at: index) else {
            // A silhouette: nothing to drop into yet, but say it was heard.
            Haptics.tap(.rigid)
            return
        }
        Haptics.tap(.medium)

        if let opening = game.opening,
           let world = progress.progress(for: index),
           world.isOpeningDue(key: opening.key) {
            pendingEntry = index
            openingFilm = opening.raise()
        } else {
            entering = index
        }
    }

    private func endOpening(_ film: WorldFilm) {
        progress.markPlayed(sceneKey: film.key)
        openingFilm = nil
    }

    private func openPendingWorld() {
        guard let index = pendingEntry else { return }
        pendingEntry = nil
        entering = index
    }

    // MARK: - Coming and going

    /// Brings the frontier into view when the map first opens, so a player picking up part-way
    /// through is shown where they have got to rather than the bottom of the map.
    private func settleOnFrontier(_ scroller: ScrollViewProxy) async {
        guard !settled else { return }
        settled = true
        let stop = progress.frontier
        guard stop > 0 else { return }

        guard !reduceMotion else {
            scroller.scrollTo(stop, anchor: .center)
            return
        }
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.easeInOut(duration: 0.9)) { scroller.scrollTo(stop, anchor: .center) }
    }

    /// A world held while the map was away opens the next one; when it does, that new world
    /// takes a bow as the map comes back.
    private func revealAnyNewWorld() {
        let now = progress.frontier
        defer { frontierWhenLeft = now }
        guard now > frontierWhenLeft else { return }

        Haptics.buzz(.success)
        guard !reduceMotion else { return }
        withAnimation(.spring(duration: 0.5, bounce: 0.5)) { unveiled = now }
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) { unveiled = nil }
        }
    }
}

/// Stands each planet on its own point up the map, giving every one a frame of its own so the
/// scroller can bring it into view — the same reason the world trail lays its signposts out
/// rather than positioning them.
private struct ConstellationLayout: Layout {
    let points: [CGPoint]

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        for (index, subview) in subviews.enumerated() where index < points.count {
            subview.place(
                at: CGPoint(x: bounds.minX + points[index].x, y: bounds.minY + points[index].y),
                anchor: .center,
                proposal: .unspecified
            )
        }
    }
}

/// One world on the universe map: a planet in its own colour, the boss shown on it — a silhouette
/// while the world is shut, in full colour once it is open — and a plate with its name.
private struct WorldPlanet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let theme: WorldTheme
    let boss: BossMark
    let state: WorldState
    let subtitle: String
    /// Whether the world is behind the wall: waiting on the full game. Drawn in full colour
    /// rather than as a silhouette — the point of a world for sale is to want it — with a lock
    /// on it and its name plated in gold.
    var forSale = false
    /// Whether this world pulses its ring to draw the eye. Handed in rather than worked out
    /// from the state, so the map can single out one world on a map full of worlds for sale.
    var beckons = false
    var celebrating = false

    /// A world for sale shows itself as the open, in-colour thing it is about to become,
    /// rather than as one of the dark silhouettes past the frontier.
    private var isOpen: Bool {
        if forSale { return true }
        switch state {
        case .cleared, .playable: return true
        case .comingSoon, .locked: return false
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            planet
            plate
        }
        .scaleEffect(celebrating ? 1.16 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        // A world for sale is a button however locked its state reads, since tapping it is what
        // opens the offer; only a world with nothing behind the tap goes without the trait.
        .accessibilityAddTraits(state == .locked && !forSale ? [] : .isButton)
    }

    private var planet: some View {
        ZStack {
            if beckons, !reduceMotion {
                beckoning
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.accent, theme.accentDeep],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 4,
                        endRadius: 46
                    )
                )
                .frame(width: 72, height: 72)
                .overlay {
                    Circle().fill(
                        LinearGradient(
                            colors: [.white.opacity(isOpen ? 0.4 : 0.14), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                }
                .overlay { Circle().strokeBorder(ringColor, lineWidth: 3) }
                .saturation(isOpen ? 1 : 0.5)
                .brightness(state == .locked ? -0.12 : 0)
                .shadow(color: theme.accent.opacity(isOpen ? 0.55 : 0.2), radius: 12)

            bossMark

            badge
        }
        .frame(width: 84, height: 84)
    }

    /// The boss on the planet: a silhouette in the world's deep colour while it is shut, and in
    /// full colour once the world is open — which is what "show a silhouette of each boss" means
    /// on a map that is mostly worlds you have not reached.
    @ViewBuilder
    private var bossMark: some View {
        let glyph = Text(boss.glyph).font(.system(size: 34))
        // A world for sale is drawn as the open thing it is about to become — its boss in
        // full colour behind the lock — so the wall entices rather than reads as dead.
        if forSale {
            glyph.shadow(color: .black.opacity(0.4), radius: 3, y: 2)
        } else {
            switch state {
            case .cleared, .playable:
                glyph.shadow(color: .black.opacity(0.4), radius: 3, y: 2)
            case .comingSoon:
                glyph.colorMultiply(theme.accentDeep).opacity(0.85)
            case .locked:
                glyph.colorMultiply(.black).opacity(0.72)
            }
        }
    }

    /// A ring pushed out from a world waiting to be played — the one thing on the map that moves
    /// when nothing else is.
    private var beckoning: some View {
        Circle()
            .strokeBorder(GamePalette.cream, lineWidth: 3)
            .frame(width: 72, height: 72)
            .phaseAnimator([0.0, 1.0]) { ring, phase in
                ring.scaleEffect(1 + 0.3 * phase).opacity(0.8 - 0.8 * phase)
            } animation: { _ in
                .easeOut(duration: 1.6)
            }
    }

    /// A corner mark for a world's standing: a check when it is held, a lock when it is shut, a
    /// star when it is open and waiting.
    @ViewBuilder
    private var badge: some View {
        let mark: (name: String, tint: Color)? = {
            // The wall wears a gold lock — a world you can have, not one you cannot reach —
            // which is the one badge that stands over whatever the state would otherwise show.
            if forSale { return ("lock.fill", GamePalette.pen) }
            switch state {
            case .cleared: return ("checkmark.seal.fill", GamePalette.pen)
            case .playable: return nil
            case .comingSoon: return ("hourglass", GamePalette.cream)
            case .locked: return ("lock.fill", GamePalette.cream)
            }
        }()

        if let mark {
            Image(systemName: mark.name)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(mark.tint)
                .padding(4)
                .background(Circle().fill(.black.opacity(0.55)))
                .offset(x: 28, y: 26)
        }
    }

    private var ringColor: Color {
        if forSale { return GamePalette.pen }
        switch state {
        case .cleared: return GamePalette.pen
        case .playable: return GamePalette.cream
        case .comingSoon: return .white.opacity(0.35)
        case .locked: return .white.opacity(0.2)
        }
    }

    private var plate: some View {
        VStack(spacing: 1) {
            Text(theme.name)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(GamePalette.post)
            Text(subtitle)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(GamePalette.post.opacity(0.7))
        }
        .lineLimit(1)
        .fixedSize()
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(Capsule().fill(GamePalette.cream.opacity(isOpen ? 0.96 : 0.6)))
        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
    }

    private var spokenLabel: String {
        let standing: String
        if forSale {
            standing = "unlock the full game to play it"
        } else {
            switch state {
            case .cleared: standing = "held"
            case .playable: standing = "open, \(subtitle)"
            case .comingSoon: standing = "coming soon"
            case .locked: standing = "locked"
            }
        }
        return "\(theme.name), \(boss.name). \(standing)."
    }
}

/// The star field and drifting nebulae the worlds hang in. Drawn once as a clock only for the
/// twinkle, since the map itself does not move on its own.
private struct CosmicBackdrop: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let accents: [Color]
    @State private var opened = Date()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion)) { timeline in
            let elapsed = reduceMotion ? 0 : timeline.date.timeIntervalSince(opened)
            Canvas { context, size in
                draw(in: &context, size: size, elapsed: elapsed)
            }
        }
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, elapsed: TimeInterval) {
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.09, green: 0.08, blue: 0.22),
                    Color(red: 0.04, green: 0.05, blue: 0.12),
                    Color(red: 0.02, green: 0.03, blue: 0.08)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )

        // A nebula or two per world's colour, drifting up the map.
        var clouds = Scatter(seed: 8_311)
        for accent in accents {
            let center = CGPoint(
                x: size.width * CGFloat(clouds.next()),
                y: size.height * CGFloat(clouds.next())
            )
            let radius = size.width * CGFloat(clouds.next(in: 0.22...0.4))
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - radius, y: center.y - radius,
                    width: radius * 2, height: radius * 2
                )),
                with: .radialGradient(
                    Gradient(colors: [accent.opacity(0.12), accent.opacity(0)]),
                    center: center,
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }

        var stars = Scatter(seed: 2_027)
        let count = Int(size.height / 9)
        for _ in 0..<count {
            let center = CGPoint(
                x: size.width * CGFloat(stars.next()),
                y: size.height * CGFloat(stars.next())
            )
            let radius = CGFloat(stars.next(in: 0.5...1.6))
            let twinkle = 0.5 + 0.5 * sin(elapsed * 1.5 + stars.next() * 6.3)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - radius, y: center.y - radius,
                    width: radius * 2, height: radius * 2
                )),
                with: .color(.white.opacity(0.25 + 0.5 * twinkle))
            )
        }
    }
}

#Preview {
    NavigationStack {
        UniverseMapView(progress: .partWayThrough())
    }
}

#Preview("Behind the wall") {
    NavigationStack {
        UniverseMapView(progress: .partWayThrough(forSale: true))
    }
}
