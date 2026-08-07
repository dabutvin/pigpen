import SwiftUI

/// A stop on the world map: the stars earned there, a painted sign with the level's
/// number on it, and the name of the puzzle on a board underneath.
struct LevelSignpost: View {
    /// What the map has to say about a level.
    enum Standing: Equatable {
        /// Penned, and worth the stars shown above it.
        case cleared
        /// Open, and waiting to be played for the first time.
        case open
        /// Still shut, because the level before it has not been beaten.
        case shut
        /// Shut behind a toll of stars, and how many the world wants for it. The number is
        /// shown where the stars earned would go, since it is the one thing worth knowing
        /// about a level nobody can open yet.
        case tolled(stars: Int)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let number: Int
    let name: String
    let stars: Int
    let standing: Standing
    /// True for a level that has given up the best pen it has in it. Its stars go rainbow,
    /// the same drift the field itself washes with the moment such a pen closes — the map's
    /// record of a score with nothing left above it.
    var hasTheBestPen = false
    /// True for a stop that has only just opened, so it can make something of itself.
    var celebrating = false

    /// When the signpost went up, so the rainbow drifts from a fixed point rather than
    /// from whenever the map happened to scroll it into view.
    @State private var raised = Date()

    var body: some View {
        VStack(spacing: 5) {
            tally
            face
            plate
        }
        .scaleEffect(celebrating ? 1.18 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(standing == .shut ? [] : .isButton)
    }

    // MARK: - Pieces

    /// Three stars, filled in as far as the player has got. Kept in place even for a
    /// level nobody can play yet, so every signpost on the trail stands at the same height
    /// — and given over to the price of a level that is waiting to be paid for in stars.
    ///
    /// A level that has given up its best pen wears the same rainbow the field washes
    /// with when one closes, so a glance up the trail says which maps have nothing left
    /// in them and which are still worth going back down for.
    @ViewBuilder
    private var tally: some View {
        if case .tolled(let toll) = standing {
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                Text("\(toll)")
            }
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(GamePalette.pen)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .background(Capsule().fill(.black.opacity(0.28)))
            .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        } else {
            starRow()
                .overlay { if showsRainbow { rainbow } }
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                .opacity(standing == .shut ? 0 : 1)
        }
    }

    /// Whether this stop's stars are the rainbow sort: the best pen found, and the level
    /// cleared, which one implies but the other does not.
    private var showsRainbow: Bool {
        hasTheBestPen && standing == .cleared
    }

    /// The row itself. Every signpost draws all three stars — the ones still to be won as
    /// hollow outlines — so the row is the same width whatever a level has given up.
    private func starRow(
        filled: AnyShapeStyle = AnyShapeStyle(GamePalette.pen),
        hollow: AnyShapeStyle = AnyShapeStyle(GamePalette.cream.opacity(0.6))
    ) -> some View {
        HStack(spacing: 2) {
            ForEach(1...3, id: \.self) { star in
                Image(systemName: star <= stars ? "star.fill" : "star")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(star <= stars ? filled : hollow)
            }
        }
    }

    /// The whole spectrum laid across the row and turned slowly, painted through the stars
    /// that have been won rather than into each of them: one rainbow on the signpost, the
    /// same way a pen is washed with one rainbow however many tiles it holds. A player who
    /// has asked for less movement gets it standing still.
    private var rainbow: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            // One turn round the colour wheel every twelve seconds, as on the field.
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSince(raised) / 12

            LinearGradient(
                gradient: GamePalette.rainbow(phase: phase),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask {
                starRow(filled: AnyShapeStyle(Color.white), hollow: AnyShapeStyle(Color.clear))
            }
        }
    }

    private var face: some View {
        ZStack {
            if standing == .open, !reduceMotion {
                beckoning
            }

            Circle()
                .fill(tint)
                .brightness(-0.28)
                .frame(width: 58, height: 58)
                .offset(y: 4)

            Circle()
                .fill(tint)
                .overlay {
                    Circle().fill(
                        LinearGradient(
                            colors: [.white.opacity(0.45), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                }
                .overlay {
                    Circle().strokeBorder(GamePalette.post.opacity(0.55), lineWidth: 3)
                }
                .frame(width: 58, height: 58)

            emblem
        }
        .frame(width: 76, height: 66)
        .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
    }

    /// A ring pushed out from a level that is waiting to be played — the one thing on
    /// the map that moves when nothing else is happening.
    private var beckoning: some View {
        Circle()
            .strokeBorder(GamePalette.cream, lineWidth: 3)
            .frame(width: 58, height: 58)
            .phaseAnimator([0.0, 1.0]) { ring, phase in
                ring
                    .scaleEffect(1 + 0.3 * phase)
                    .opacity(0.8 - 0.8 * phase)
            } animation: { _ in
                .easeOut(duration: 1.5)
            }
    }

    @ViewBuilder
    private var emblem: some View {
        switch standing {
        case .shut, .tolled:
            Image(systemName: "lock.fill")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(GamePalette.cream.opacity(0.85))
        case .open, .cleared:
            Text("\(number)")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post)
        }
    }

    private var plate: some View {
        Text(name)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundStyle(GamePalette.post.opacity(isShut ? 0.55 : 1))
            .lineLimit(1)
            .fixedSize()
            .padding(.vertical, 3)
            .padding(.horizontal, 9)
            .background(
                Capsule().fill(GamePalette.cream.opacity(isShut ? 0.55 : 0.96))
            )
            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
    }

    /// Whether the level is one nobody can play yet, whatever is keeping it shut.
    private var isShut: Bool {
        switch standing {
        case .shut, .tolled: true
        case .open, .cleared: false
        }
    }

    private var tint: Color {
        switch standing {
        case .cleared: GamePalette.pen
        case .open: GamePalette.cream
        case .shut, .tolled: GamePalette.stone
        }
    }

    private var spokenLabel: String {
        let spelled = ["no", "one", "two", "three"]
        switch standing {
        case .shut:
            return "Level \(number), \(name), locked"
        case .tolled(let toll):
            return "Level \(number), \(name), locked until \(toll) stars"
        case .open:
            return "Level \(number), \(name), not yet played"
        case .cleared:
            let count = spelled[min(max(stars, 0), 3)]
            let earned = "Level \(number), \(name), \(count) star\(stars == 1 ? "" : "s")"
            // Worth saying out loud as well as showing: it is the one thing three stars
            // does not already say.
            return hasTheBestPen ? earned + ", the best pen there is" : earned
        }
    }
}

/// The press of a signpost: it sinks a little, the way the buttons in this game do.
struct SignpostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 18) {
        LevelSignpost(number: 1, name: "River Bend", stars: 3, standing: .cleared, hasTheBestPen: true)
        // Three stars and still something left in the map, which is what the rainbow is
        // there to tell apart from the one beside it.
        LevelSignpost(number: 2, name: "Puddle Corner", stars: 3, standing: .cleared)
        LevelSignpost(number: 3, name: "Horseshoe Lake", stars: 0, standing: .open)
        LevelSignpost(number: 4, name: "The Narrows", stars: 0, standing: .shut)
        LevelSignpost(number: 9, name: "Stag Mere", stars: 0, standing: .tolled(stars: 21))
    }
    .padding(40)
    .background(GamePalette.beyond)
}
