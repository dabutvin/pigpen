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
        /// Shut behind a toll of stars: how many the world already holds, and how many it
        /// wants. Both are shown where the stars earned would go — as `have/need` — since a
        /// running count against the price is the one thing worth knowing about a level
        /// nobody can open yet, and says plainly that stars are what unlock it.
        case tolled(have: Int, need: Int)
    }

    /// What this signpost is standing at: a numbered stop on the trail, or a door beside it.
    ///
    /// A door has no number, because it is not one of the world's nine — it carries a small
    /// painting in place of one and says what it is rather than where it comes. It has no stars
    /// either: it is somewhere to go rather than something to beat, and three hollow stars over a
    /// door would be three promises nothing behind it can keep.
    enum Sign: Equatable {
        case stop(Int)
        case door(DoorMark)
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let sign: Sign
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
        if case .tolled(let have, let need) = standing {
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                Text("\(have)/\(need)")
                    .monospacedDigit()
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
                // Kept in place but unpainted over a door and over a stop nobody can play yet,
                // so that every sign in the meadow stands at the same height whatever it is.
                .opacity(standing == .shut || !hasStars ? 0 : 1)
        }
    }

    /// Whether there are stars to show at all. A door is not a puzzle and has none.
    private var hasStars: Bool {
        if case .door = sign { false } else { true }
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
            // Never over a door: the ring means *play me*, and a door that has nothing to play
            // would pulse for the rest of the game without ever being satisfied.
            if standing == .open, hasStars, !reduceMotion {
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
            switch sign {
            case .stop(let number):
                Text("\(number)")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(GamePalette.post)
            case .door(.barn):
                // Painted, not set as a glyph: the sign carries the barn standing at the foot of
                // the trail, drawn small. See `Barn`.
                BarnMark(walls: 30)
            }
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

    /// How the sign names itself out loud. A stop is called by its number and its name; a door
    /// has only its name, which is already the whole of what is behind it.
    private var called: String {
        switch sign {
        case .stop(let number): "Level \(number), \(name)"
        case .door: name
        }
    }

    private var spokenLabel: String {
        let spelled = ["no", "one", "two", "three"]
        // A door is open or it is not. Nothing has been played there and nothing ever will be,
        // so the words a stop uses — *not yet played*, a count of stars — would all be wrong.
        guard hasStars else {
            return standing == .shut ? "\(called), locked" : "\(called), open"
        }
        switch standing {
        case .shut:
            return "\(called), locked"
        case .tolled(let have, let need):
            return "\(called), locked until \(need) stars, \(have) so far"
        case .open:
            return "\(called), not yet played"
        case .cleared:
            let count = spelled[min(max(stars, 0), 3)]
            let earned = "\(called), \(count) star\(stars == 1 ? "" : "s")"
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
        LevelSignpost(sign: .stop(1), name: "River Bend", stars: 3, standing: .cleared, hasTheBestPen: true)
        // Three stars and still something left in the map, which is what the rainbow is
        // there to tell apart from the one beside it.
        LevelSignpost(sign: .stop(2), name: "Puddle Corner", stars: 3, standing: .cleared)
        LevelSignpost(sign: .stop(3), name: "Horseshoe Lake", stars: 0, standing: .open)
        LevelSignpost(sign: .stop(4), name: "The Narrows", stars: 0, standing: .shut)
        LevelSignpost(sign: .stop(9), name: "Stag Mere", stars: 0, standing: .tolled(have: 13, need: 21))
        // The dressing barn beside the orchard, which carries a painting of itself where a stop
        // carries its number, and no stars at all.
        LevelSignpost(sign: .door(.barn), name: "Dressing Barn", stars: 0, standing: .open)
    }
    .padding(40)
    .background(GamePalette.beyond)
}
