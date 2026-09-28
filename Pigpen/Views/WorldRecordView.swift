import SwiftUI

/// What the landmark at the foot of a trail has to say when you tap it: your record on this
/// world, and — where enough people have been up here to make it mean anything — what
/// everybody else made of the same stops.
///
/// Laid out like the game's other sheets, a name on the page and cards under it, because it
/// is the same kind of aside. What it is careful about is the second card. The game knows
/// what the field has done from a table baked in when the build was cut, and that table is
/// thin at the top of the game and will stay thin for years: the meadow has been played by
/// everybody and the tundra by almost nobody. So the field is a card that comes and goes
/// rather than a column that is sometimes blank — and when it goes it goes quietly, leaving
/// the record above it, rather than standing there to say it has nothing to say.
///
/// Nothing here is a leaderboard and nothing here is a percentile. A percentile off fifty-odd
/// players is a decimal point pretending to be a fact, and a game about taking a map apart
/// slowly is not improved by being told you are the four hundredth best at it. What it says
/// instead is the two things a share of players can honestly carry: how many of them get
/// three stars out of a stop, and how many ever find the best pen it has.
@MainActor
struct WorldRecordView: View {
    @Environment(\.dismiss) private var dismiss

    let record: WorldRecord
    /// What the thing you tapped is called, so the page can say where you are standing.
    let landmark: String

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
                    VStack(spacing: 14) {
                        mine
                        theirs
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .staysInDaylight()
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
    }

    /// How far up the sheet comes, which depends on how much there is to read.
    ///
    /// A world with a field behind it has two cards and nine stops in the second of them, and
    /// at the middle height the line the whole panel is building to — the one about what you
    /// hold that most players do not — sits below the fold with nothing to say it is there. So
    /// it opens tall.
    ///
    /// A world without one is a heading and three figures. The middle height was built for two
    /// cards and leaves most of itself empty under one, which reads as a page still loading
    /// rather than a page that has said its piece — so the short version asks for about what it
    /// occupies instead. `.large` stays on both, since a sheet a player cannot drag feels stuck.
    private var detents: Set<PresentationDetent> {
        record.hasField ? [.large] : [.height(Self.shortSheet), .large]
    }

    /// What the short version comes to: the header, one card, and the padding around them.
    ///
    /// Taken off the screenshot rather than guessed at — the header and card run to about 190
    /// points, and the sheet adds the home indicator's strip under that. Slack enough that a
    /// step or two of larger text still fits before it starts scrolling instead of growing,
    /// and no slacker, since every point past the card is empty cream.
    private static let shortSheet: CGFloat = 210

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.world)
                    .font(.title3.weight(.heavy))
                Text("What \(landmark) has been keeping count of")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.7)
            }
            .foregroundStyle(GamePalette.post)
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                Haptics.tap(.light)
                Sounds.play(.press)
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    /// The player's own three figures, which are right for anybody who has ever played: they
    /// are read off the same stars and best pens the signposts up the trail are drawing.
    private var mine: some View {
        card {
            VStack(spacing: 14) {
                Text("Your record")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(GamePalette.post.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 0) {
                    tally("\(record.solved)/\(record.count)", String(localized: "solved"))
                    divider
                    tally("\(record.stars)/\(record.starTotal)", String(localized: "stars"))
                    divider
                    tally(
                        "\(record.bestPens)",
                        // The figure is already above it, so the caption is the noun alone —
                        // but which noun is a question of how many, and a catalog plural is
                        // not allowed to answer it: a plural variation has to print the
                        // number it counts, or `xcstringstool` refuses the build. So the
                        // choice is made here, between two strings. Every language the game
                        // speaks splits one from the rest; one that split them three ways
                        // would want a third string and a third branch.
                        record.bestPens == 1
                            ? String(localized: "record.bestPen", defaultValue: "best pen")
                            : String(localized: "record.bestPens", defaultValue: "best pens")
                    )
                }
            }
        }
    }

    /// Everybody else, where there is an everybody else to speak of.
    @ViewBuilder
    private var theirs: some View {
        if record.hasField {
            card {
                VStack(alignment: .leading, spacing: 12) {
                    // A label and not a headcount. How many players stand behind these shares
                    // is what the quorum is for, and it is answered by the card being here at
                    // all: on a world too thin to speak for, there is no card.
                    Text("Everybody else")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(GamePalette.post.opacity(0.55))

                    ForEach(record.measured) { measured in
                        line(measured.row, measured.benchmark)
                    }

                    if let standing {
                        Text(standing)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(GamePalette.post)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        // No else. A world the counting cannot speak for shows the record above and stops,
        // rather than opening a card to announce that it has nothing to say — which is a
        // sentence nobody needs and, on eleven of the twelve worlds, the only sentence there
        // would be. The absence says it.
    }

    /// One stop: its number and name, the stars you have off it, and underneath, the one
    /// thing the field has to say about it.
    private func line(_ row: WorldRecord.Row, _ benchmark: LevelBenchmark) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(verbatim: "\(row.stop)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post.opacity(0.5))
                .monospacedDigit()
                .frame(width: 14, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.name)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(GamePalette.post)
                Text(field(row, benchmark))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(GamePalette.post.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            StarRow(
                stars: row.stars,
                size: 12,
                hasTheBestPen: row.hasTheBestPen,
                hollow: GamePalette.post.opacity(0.2)
            )
            .padding(.top, 2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken(row, benchmark))
    }

    private func tally(_ figure: String, _ caption: String) -> some View {
        VStack(spacing: 2) {
            Text(figure)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(GamePalette.post)
                .monospacedDigit()
            Text(caption)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(GamePalette.post.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "record.tally.spoken",
                                   defaultValue: "\(figure) \(caption)"))
    }

    private var divider: some View {
        Rectangle()
            .fill(GamePalette.post.opacity(0.12))
            .frame(width: 1, height: 30)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
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

    // MARK: - Words

    /// What the field has to say about one stop. A player holding the best pen is told how
    /// rare that is, since it is the rarer of the two things and the one they have; anybody
    /// else is told what the third star is worth, which is the thing still in front of them.
    private func field(_ row: WorldRecord.Row, _ benchmark: LevelBenchmark) -> String {
        row.hasTheBestPen
            ? String(localized: "\(percent(benchmark.bestPenShare)) of players have found this pen")
            : String(localized: "\(percent(benchmark.threeStarShare)) of players get three stars here")
    }

    /// The same row for VoiceOver, which wants the stars said rather than drawn.
    private func spoken(_ row: WorldRecord.Row, _ benchmark: LevelBenchmark) -> String {
        let stars = row.isSolved
            ? String(localized: "\(row.stars) stars")
            : String(localized: "not held yet")
        let you = row.hasTheBestPen
            ? String(localized: "You: \(stars), best pen found")
            : String(localized: "You: \(stars)")
        let stop = String(localized: "Stop \(row.stop), \(row.name).")
        return "\(stop) \(you). \(field(row, benchmark))."
    }

    /// The line that closes the card: what the player has that most players do not. Said only
    /// when there is something to say — a card that ends on "you are ahead on none of them"
    /// is a card that would have read better without a last line.
    private var standing: String? {
        if record.rarePens > 0 {
            return String(localized: """
                You hold \(record.rarePens) best pens here that most players never find.
                """)
        }
        if record.aheadOfMost > 0 {
            return String(localized: """
                You have three-starred \(record.aheadOfMost) stops that most players do not.
                """)
        }
        return nil
    }

    /// A share as a whole percent. Never rounded up to 100 or down to 0 off a share that is
    /// neither: "100% of players" beside a stop somebody has plainly not all managed reads as
    /// a bug, and so does 0% beside one the player is being told about because people do it.
    private func percent(_ share: Double) -> String {
        let whole = Int((share * 100).rounded())
        if whole >= 100, share < 1 { return "99%" }
        if whole <= 0, share > 0 { return "1%" }
        return "\(whole)%"
    }
}

#Preview("The meadow, well played") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            WorldRecordView(
                record: WorldRecord(
                    world: .mudlarkMeadow,
                    stars: [
                        "river-bend": 3, "puddle-corner": 3, "dew-ponds": 3,
                        "horseshoe-lake": 2, "the-narrows": 3, "otter-ford": 1,
                        "sour-ground": 3, "windfall-orchard": 3
                    ],
                    bestPens: ["river-bend", "sour-ground", "windfall-orchard"]
                ),
                landmark: "the barn"
            )
        }
}

#Preview("A mountain nobody has climbed") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            WorldRecordView(
                record: WorldRecord(
                    world: .emberpeak,
                    stars: [
                        "cinder-slope": 3, "basalt-flats": 3, "ashfall-terrace": 2,
                        "chestnut-scree": 3, "sulphur-rill": 1
                    ],
                    bestPens: ["cinder-slope", "chestnut-scree"]
                ),
                landmark: "the cairn"
            )
        }
}
