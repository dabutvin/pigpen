import SwiftUI

/// One day in the archive: a little field with the day's number under it, and the stars it
/// gave up under that.
///
/// The square says what happened to the day in the game's own terms rather than with a
/// tick. A day nobody has finished is bare mud; a day completed is washed gold, which is
/// what the real board does the moment a pen closes; a day that gave up the best pen it had
/// in it drifts through the spectrum, which is what the real board does for one of those.
/// A day still to come is grey ground under a padlock — the almanac has it, but not yet.
struct DailySquare: View {
    /// What the archive has to say about a day.
    enum Standing: Equatable {
        /// Complete, and worth the stars shown under it.
        case complete(stars: Int, hasTheBestPen: Bool)
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
        if case .complete(let stars, _) = standing { stars } else { 0 }
    }

    private var hasTheBestPen: Bool {
        if case .complete(_, let best) = standing { best } else { false }
    }

    var body: some View {
        VStack(spacing: 3) {
            square
            Text("\(date.day)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                // Dark lettering, the same ink as the weekday letters heading the calendar
                // and the month's name on the pill above them. These were cream with a
                // shadow under them, written as though painted onto the grass, and against
                // a meadow this pale a pale number had nothing to stand on.
                .foregroundStyle(GamePalette.post.opacity(standing == .missing ? 0.3 : 1))
                .monospacedDigit()
            // The row is kept whether or not there are stars in it, so every square in the
            // month stands the same height and the grid does not go ragged.
            //
            // Gold on grass is two colours of the same weight — the stars were there to be
            // counted and came out as a smudge — so the row is laid on a little dark plaque,
            // the same ink the square above it stands on, and the gold has something to
            // strike against.
            StarRow(stars: stars, size: 7, hasTheBestPen: hasTheBestPen)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Capsule().fill(GamePalette.post.opacity(0.72)))
                .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                .opacity(stars > 0 ? 1 : 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(isPlayable ? .isButton : [])
    }

    private var isPlayable: Bool {
        switch standing {
        case .complete, .open: true
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
        case .complete:
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
            return "\(date.fullTitle), not yet complete"
        case .complete(let stars, let best):
            let count = spelled[min(max(stars, 0), 3)]
            let said = "\(date.fullTitle), complete, \(count) star\(stars == 1 ? "" : "s")"
            return best ? said + ", the best pen there is" : said
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 6), standing: .complete(stars: 3, hasTheBestPen: true))
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 7), standing: .complete(stars: 2, hasTheBestPen: false))
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 8), standing: .open, isToday: true)
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 9), standing: .locked)
        DailySquare(date: DailyDate(year: 2026, month: 4, day: 10), standing: .missing)
    }
    .padding(30)
    // The grass of the archive rather than a dark board, since the day's number and the
    // stars under it are read against the meadow.
    .background(GamePalette.Pasture.day.ground)
}
