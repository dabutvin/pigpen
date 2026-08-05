import SwiftUI
import UIKit

/// The world map: every puzzle in the game as a stop on one trail through the meadow,
/// with the pig standing at the furthest one it has reached.
///
/// Beating a level opens the next stop, and the pig walks up the trail to it while the
/// meadow scrolls along behind — which is the only way the map ever moves on its own.
/// Everything already beaten stays open, so a level can be gone back to and played again
/// for a better rating; the stars on a signpost are the best that level has ever given up.
@MainActor
struct WorldMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var progress: WorldProgress
    /// Where the pig is standing, counted in stops along the trail.
    @State private var pigStop: Double
    /// The stop whose puzzle is on screen, if any. Emptying it pops back to the map.
    @State private var playing: Int?
    /// A stop that has only just opened, so its signpost can make something of itself.
    @State private var unveiled: Int?
    /// Held while the pig is on the move, so a second tap cannot send it two ways at once.
    @State private var walking = false
    /// How far the world had been opened when the puzzle now on screen was started, so
    /// that coming back from a level tells the map whether anything new was won.
    @State private var frontierWhenOpened = 0
    /// The stop the map has been asked to bring into view, and how long it has to do it in.
    @State private var scrollOrder: ScrollOrder?
    @State private var ordersGiven = 0

    init(progress: WorldProgress = WorldProgress()) {
        _progress = State(initialValue: progress)
        _pigStop = State(initialValue: Double(progress.frontier))
    }

    private var world: WorldMap { progress.world }
    private var colors: GamePalette.Pasture { colorScheme == .dark ? .dusk : .day }
    /// How much of the trail is the player's, which is as far as the pig has ever stood
    /// — walking back down to an old level does not shut the meadow behind you.
    private var opened: Double { max(pigStop, Double(progress.frontier)) }

    var body: some View {
        GeometryReader { proxy in
            let trail = WorldTrail(map: world, width: proxy.size.width)

            ScrollViewReader { scroller in
                ScrollView(.vertical) {
                    meadow(trail: trail)
                        .frame(width: proxy.size.width, height: trail.height)
                }
                .scrollIndicators(.hidden)
                .defaultScrollAnchor(.bottom)
                .onChange(of: scrollOrder) { _, order in
                    guard let order else { return }
                    obey(order, with: scroller)
                }
                .task { await arrive() }
                .onChange(of: playing) { _, level in
                    guard level == nil else { return }
                    Task { await follow() }
                }
            }
        }
        .background(colors.ground)
        .safeAreaInset(edge: .top, spacing: 0) { banner }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $playing) { index in
            PuzzleView(level: world[index].level) { stars in
                progress.record(stars: stars, for: world[index].id)
            }
        }
    }

    // MARK: - The world

    private func meadow(trail: WorldTrail) -> some View {
        ZStack(alignment: .topLeading) {
            WorldMapScene(trail: trail, colors: colors)
            ribbon(trail: trail)
            haze(trail: trail)
            signposts(trail: trail)
            pig(trail: trail)
        }
    }

    /// The trail itself: the whole of it worn faintly into the grass, and the part the
    /// player has opened up laid over the top as proper trodden path.
    private func ribbon(trail: WorldTrail) -> some View {
        ZStack {
            TrailPath(walked: Double(world.count - 1), trail: trail)
                .stroke(
                    GamePalette.mud.opacity(0.28),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )

            TrailPath(walked: opened, trail: trail)
                .stroke(
                    GamePalette.mudSpeckle.opacity(0.4),
                    style: StrokeStyle(lineWidth: 26, lineCap: .round)
                )

            TrailPath(walked: opened, trail: trail)
                .stroke(GamePalette.mud, style: StrokeStyle(lineWidth: 21, lineCap: .round))

            TrailPath(walked: opened, trail: trail)
                .stroke(
                    GamePalette.cream.opacity(0.3),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 11])
                )
        }
        .allowsHitTesting(false)
    }

    /// Morning mist over the part of the meadow that has not been earned yet. It lifts
    /// as the pig walks, so what is coming can always be seen — just not clearly.
    private func haze(trail: WorldTrail) -> some View {
        let mist = colors.isNight ? colors.skyTop : colors.skyHorizon
        return VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: mist.opacity(0.52), location: 0),
                    Gradient.Stop(color: mist.opacity(0.46), location: 0.55),
                    Gradient.Stop(color: mist.opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: max(trail.point(at: opened).y - 104, 0))

            Spacer(minLength: 0)
        }
        .allowsHitTesting(false)
    }

    private func signposts(trail: WorldTrail) -> some View {
        TrailLayout(stops: (0..<world.count).map { trail.point(of: $0) }) {
            ForEach(Array(0..<world.count), id: \.self) { index in
                Button {
                    visit(index)
                } label: {
                    LevelSignpost(
                        number: index + 1,
                        name: world[index].level.name,
                        stars: progress.stars(at: index),
                        standing: standing(at: index),
                        celebrating: unveiled == index
                    )
                }
                .buttonStyle(SignpostButtonStyle())
                .disabled(!progress.isUnlocked(index))
                .id(index)
            }
        }
    }

    private func pig(trail: WorldTrail) -> some View {
        Text("🐷")
            .font(.system(size: 36))
            .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
            .modifier(TrailWalk(walked: pigStop, trail: trail))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func standing(at index: Int) -> LevelSignpost.Standing {
        if progress.isCleared(index) {
            .cleared
        } else if progress.isUnlocked(index) {
            .open
        } else {
            .shut
        }
    }

    // MARK: - The banner across the top

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
                Text(world.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                Text("\(progress.clearedCount) of \(world.count) pens held")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.75)
            }
            .foregroundStyle(GamePalette.cream)

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(GamePalette.pen)
                Text("\(progress.totalStars)/\(world.starTotal)")
                    .foregroundStyle(GamePalette.cream)
                    .monospacedDigit()
            }
            .font(.system(size: 14, weight: .heavy, design: .rounded))
            .padding(.vertical, 6)
            .padding(.horizontal, 11)
            .background(Capsule().fill(.black.opacity(0.22)))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(progress.totalStars) of \(world.starTotal) stars earned")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            LinearGradient(
                colors: [GamePalette.rail, GamePalette.post],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .bottom) {
                Rectangle().fill(.black.opacity(0.25)).frame(height: 2)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Walking the trail

    /// Opens a level. If the pig is standing somewhere else — the player has gone back
    /// down the trail for a level they have already beaten — it trots over there first,
    /// so the map never cuts to a puzzle the pig is not standing at.
    private func visit(_ index: Int) {
        guard progress.isUnlocked(index), !walking else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        Task {
            await walk(to: Double(index), secondsPerStop: 0.3)
            frontierWhenOpened = progress.frontier
            playing = index
        }
    }

    /// Walks the pig on to wherever the world has got to, once a puzzle has been played
    /// and put away. This is what a player sees for beating a level: the pig sets off up
    /// a trail that was not there a moment ago, and the mist pulls back off the next stop.
    private func follow() async {
        let stop = progress.frontier
        let opened = stop > frontierWhenOpened
        guard abs(Double(stop) - pigStop) > 0.01 else { return }

        // Let the puzzle screen finish sliding away first, so the walk is not missed.
        try? await Task.sleep(for: .milliseconds(520))
        await walk(to: Double(stop), secondsPerStop: 0.9)
        if opened {
            celebrate(stop)
        }
    }

    private func walk(to stop: Double, secondsPerStop: Double) async {
        let steps = abs(stop - pigStop)
        guard steps > 0.01 else { return }

        guard !reduceMotion else {
            pigStop = stop
            scroll(to: Int(stop.rounded()), over: 0)
            return
        }

        walking = true
        let seconds = min(secondsPerStop * steps, 1.8)
        scroll(to: Int(stop.rounded()), over: seconds)
        withAnimation(.easeInOut(duration: seconds)) { pigStop = stop }
        try? await Task.sleep(for: .seconds(seconds))
        walking = false
    }

    /// The signpost the pig has just walked up to takes a bow.
    private func celebrate(_ index: Int) {
        guard progress.isUnlocked(index), !progress.isCleared(index) else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        guard !reduceMotion else { return }
        withAnimation(.spring(duration: 0.45, bounce: 0.55)) { unveiled = index }
        Task {
            try? await Task.sleep(for: .milliseconds(750))
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) { unveiled = nil }
        }
    }

    /// Brings the pig into view when the map opens. A world already part-way through runs
    /// up the trail from the barn, which says where the player is and how far there is to go.
    private func arrive() async {
        let stop = progress.frontier
        guard stop > 0 else { return }

        guard !reduceMotion else {
            scroll(to: stop, over: 0)
            return
        }
        try? await Task.sleep(for: .milliseconds(300))
        scroll(to: stop, over: 0.9)
    }

    /// Leaves the scroller a note to bring a stop into view.
    ///
    /// The proxy that does the scrolling only exists inside the scroll view's own builder
    /// and cannot be carried into the tasks that walk the pig, so the walk writes down
    /// where it is going and the scroll view reads it off.
    private func scroll(to stop: Int, over seconds: Double) {
        ordersGiven += 1
        scrollOrder = ScrollOrder(stop: stop, seconds: seconds, number: ordersGiven)
    }

    private func obey(_ order: ScrollOrder, with scroller: ScrollViewProxy) {
        guard order.seconds > 0 else {
            scroller.scrollTo(order.stop, anchor: .center)
            return
        }
        withAnimation(.easeInOut(duration: order.seconds)) {
            scroller.scrollTo(order.stop, anchor: .center)
        }
    }
}

/// A stop to bring into view, and how long the map has to get there.
private struct ScrollOrder: Equatable {
    let stop: Int
    let seconds: Double
    /// Two orders to the same stop are still two orders.
    let number: Int
}

/// Stands each signpost on its own stop.
///
/// A layout rather than `.position`, because a positioned view fills the space it is
/// given and the scroller would have nothing to scroll a stop into view *by*. Laid out
/// properly, every signpost has a frame of its own and the map can be told to go to one.
private struct TrailLayout: Layout {
    let stops: [CGPoint]

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        for (index, subview) in subviews.enumerated() where index < stops.count {
            subview.place(
                at: CGPoint(x: bounds.minX + stops[index].x, y: bounds.minY + stops[index].y),
                anchor: .center,
                proposal: .unspecified
            )
        }
    }
}

/// The trail, drawn as far as it has been opened. Animating the length is what makes the
/// path grow out ahead of the pig as it walks rather than snap into place all at once.
private struct TrailPath: Shape {
    var walked: Double
    let trail: WorldTrail

    var animatableData: Double {
        get { walked }
        set { walked = newValue }
    }

    func path(in rect: CGRect) -> Path {
        trail.path(upTo: walked)
    }
}

/// Carries the pig along the trail, hopping twice for every stop it walks. The hop falls
/// to nothing at a whole number of stops, so a pig that has arrived is standing still.
private struct TrailWalk: GeometryEffect {
    var walked: Double
    let trail: WorldTrail
    /// Where the pig stands next to the trail, so it never covers a signpost.
    var stance = CGSize(width: -34, height: 14)

    var animatableData: Double {
        get { walked }
        set { walked = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let spot = trail.point(at: walked)
        let hop = CGFloat(abs(sin(walked * 2 * .pi))) * 13
        return ProjectionTransform(
            CGAffineTransform(
                translationX: spot.x + stance.width - size.width / 2,
                y: spot.y + stance.height - size.height / 2 - hop
            )
        )
    }
}

#Preview {
    NavigationStack {
        WorldMapView(progress: .partWayThrough())
    }
}
