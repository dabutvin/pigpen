import SwiftUI

/// One day in the archive: a little field with the day's number under it, and the stars it
/// gave up under that.
///
/// The square says what happened to the day in the game's own terms rather than with a
/// tick. A day nobody has held is bare mud; a day that was held is washed gold, which is
/// what the real board does the moment a pen closes; a day that gave up the best pen it had
/// in it drifts through the spectrum, which is what the real board does for one of those.
/// A day still to come is grey ground under a padlock — the almanac has it, but not yet.
struct DailySquare: View {
    /// What the archive has to say about a day.
    enum Standing: Equatable {
        /// Held, and worth the stars shown under it.
        case held(stars: Int, hasTheBestPen: Bool)
        /// Open, and waiting to be played.
        case open
        /// Still to come. The puzzle shipped with the game, but the day has not arrived.
        case locked
        /// No puzzle at all — a day before the almanac starts or after it runs out.
        case missing
    }

    let date: DailyDate
    let standing: Standing
    /// True for today, which gets a ring round it so a month of squares has one to go to.
    var isToday = false

    private var stars: Int {
        if case .held(let stars, _) = standing { stars } else { 0 }
    }

    private var hasTheBestPen: Bool {
        if case .held(_, let best) = standing { best } else { false }
    }

    var body: some View {
        VStack(spacing: 3) {
            square
            Text("\(date.day)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(GamePalette.cream.opacity(standing == .missing ? 0.25 : 0.9))
                .monospacedDigit()
                // Written straight onto the grass, so it is painted rather than printed.
                .shadow(color: .black.opacity(0.45), radius: 2, y: 1)
            // The row is kept whether or not there are stars in it, so every square in the
            // month stands the same height and the grid does not go ragged.
            StarRow(stars: stars, size: 7, hasTheBestPen: hasTheBestPen)
                .opacity(stars > 0 ? 1 : 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(isPlayable ? .isButton : [])
    }

    private var isPlayable: Bool {
        switch standing {
        case .held, .open: true
        case .locked, .missing: false
        }
    }

    // MARK: - The little field

    @ViewBuilder
    private var square: some View {
        if standing == .missing {
            Color.clear.frame(width: 40, height: 40)
        } else {
            ZStack {
                field(lit: colours.lit, shade: colours.shade)

                if hasTheBestPen {
                    RainbowWash()
                        .mask { field(lit: .white, shade: .white) }
                        .opacity(0.9)
                }

                if standing == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(GamePalette.cream.opacity(0.9))
                        .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                }
            }
            .frame(width: 40, height: 40)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(GamePalette.post.opacity(standing == .locked ? 0.35 : 0.55))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        isToday ? GamePalette.cream : GamePalette.post.opacity(0.35),
                        lineWidth: isToday ? 2.5 : 1
                    )
            }
            .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        }
    }

    /// Nine tiles of ground, laid out like the smallest board the game could have. Two
    /// tones rather than one, so it reads as ploughed ground rather than as a swatch.
    private func field(lit: Color, shade: Color) -> some View {
        VStack(spacing: 1.5) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 1.5) {
                    ForEach(0..<3, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                            .fill((row + column).isMultiple(of: 2) ? lit : shade)
                    }
                }
            }
        }
        .padding(5)
    }

    private var colours: (lit: Color, shade: Color) {
        switch standing {
        case .held:
            (lit: GamePalette.pen, shade: GamePalette.pen.opacity(0.72))
        case .open:
            (lit: GamePalette.mudLit, shade: GamePalette.mud)
        case .locked, .missing:
            (lit: GamePalette.stone.opacity(0.5), shade: GamePalette.stone.opacity(0.35))
        }
    }

    // MARK: - Out loud

    private var spokenLabel: String {
        let spelled = ["no", "one", "two", "three"]
        switch standing {
        case .missing:
            return "\(date.fullTitle), no puzzle"
        case .locked:
            return "\(date.fullTitle), not open yet"
        case .open:
            return "\(date.fullTitle), not yet held"
        case .held(let stars, let best):
            let count = spelled[min(max(stars, 0), 3)]
            let said = "\(date.fullTitle), held, \(count) star\(stars == 1 ? "" : "s")"
            return best ? said + ", the best pen there is" : said
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 6), standing: .held(stars: 3, hasTheBestPen: true))
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 7), standing: .held(stars: 2, hasTheBestPen: false))
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 8), standing: .open, isToday: true)
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 9), standing: .locked)
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 10), standing: .missing)
    }
    .padding(30)
    .background(GamePalette.post)
}
