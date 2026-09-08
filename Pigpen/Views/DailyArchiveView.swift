import SwiftUI
import UIKit

/// Every daily puzzle there has been, a month at a time.
///
/// The meadow is a trail: one stop opens the next, and where you are is where you have got
/// to. The archive is a calendar instead — nothing here unlocks anything, and a week missed
/// is simply a week of squares nobody has washed gold. The only thing shut is tomorrow,
/// and only until it is today.
@MainActor
struct DailyArchiveView: View {
    @Environment(\.dismiss) private var dismiss

    /// The day the archive is being read on. Handed in rather than asked for, so previews
    /// and the screenshots CI takes open on a month with a known shape to it.
    let today: DailyDate

    /// Whether the full game has been bought. The calendar opens for nothing — every day
    /// is drawn, every month turns — but only today's board plays for free; tapping any
    /// other day raises the offer instead of the board.
    var fullGame: FullGame = .shared

    @State private var progress: DailyProgress
    @State private var month: DailyMonth
    /// The day whose board is on screen. Emptying it pops back to the calendar.
    @State private var playing: DailyDate?
    /// Whether the offer of the full game is up, raised by tapping a day the free game does
    /// not open — any day but today.
    @State private var isOffering = false

    init(
        today: DailyDate = .today(),
        progress: DailyProgress = DailyProgress(),
        fullGame: FullGame = .shared
    ) {
        self.today = today
        self.fullGame = fullGame
        _progress = State(initialValue: progress)
        // The last page the archive offers rather than today's month outright: for anybody
        // playing inside the years the book covers those are the same thing, and for
        // anybody past the end of it this is the difference between opening on the last
        // month of puzzles and opening on a page of empty squares with both arrows greyed.
        _month = State(
            initialValue: DailyAlmanac.months(upTo: today).last ?? DailyMonth(of: today)
        )
    }

    private var months: [DailyMonth] { DailyAlmanac.months(upTo: today) }
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    }

    var body: some View {
        ZStack {
            // The far country carried down the screen, so the month bar stands against open
            // sky and the pines keep to the grass below it rather than crowding the name of
            // the month and the weekday letters under it.
            MeadowBackdrop(horizonDrop: 0.58)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                monthBar

                // One page per month the archive offers. A swipe left turns to the month
                // after, a swipe right to the one before — the same doors the chevrons open,
                // only drawn with a finger. The dots stay hidden: the month bar already
                // says which page you are on.
                TabView(selection: $month) {
                    ForEach(months) { page in
                        ScrollView {
                            VStack(spacing: 10) {
                                weekdayHeadings
                                grid(for: page)
                                footnote
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 26)
                            .frame(maxWidth: .infinity)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .tag(page)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { banner }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $playing) { date in
            DailyPuzzleView(date: date, progress: progress)
        }
        .sheet(isPresented: $isOffering) {
            FullGameOffer(fullGame: fullGame, source: .archive)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear { progress.reload() }
        .onChange(of: month) { _, _ in
            Haptics.tap(.light)
        }
    }

    // MARK: - The bar across the top

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
                Text("The Daily Archive")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                Text("Pick a day and pen it in")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.75)
            }
            .foregroundStyle(GamePalette.cream)

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(GamePalette.pen)
                Text("\(progress.streak(upTo: today))")
                    .foregroundStyle(GamePalette.cream)
                    .monospacedDigit()
            }
            .font(.system(size: 14, weight: .heavy, design: .rounded))
            .padding(.vertical, 6)
            .padding(.horizontal, 11)
            .background(Capsule().fill(.black.opacity(0.22)))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(progress.streak(upTo: today)) days in a row")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            // The same dusty salmon glaze the map and the boards wear across the top, so
            // every screen with a bar over it is a room of the one building.
            LinearGradient(
                colors: [GamePalette.clay, GamePalette.clayShade],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(alignment: .bottom) {
                Rectangle().fill(.black.opacity(0.25)).frame(height: 2)
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    /// Which month is on the page, and the way to the ones either side of it. The archive
    /// runs from the first month the book has up to the month you are standing in, across
    /// however many years that is — there is nothing worth turning to past that, since
    /// every day on the page would be shut.
    /// The page itself also turns under a swipe; these arrows are the same turn, written
    /// down for anybody who would rather tap.
    private var monthBar: some View {
        HStack(spacing: 10) {
            turn(to: month.previous, systemImage: "chevron.left", label: "The month before")

            VStack(spacing: 1) {
                Text(month.name)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .contentTransition(.identity)
                Text("\(progress.completedCount(in: month)) of \(playableCount) complete")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .opacity(0.75)
            }
            .foregroundStyle(GamePalette.post)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Capsule().fill(GamePalette.cream.opacity(0.95)))
            .accessibilityElement(children: .combine)
            .accessibilityHint("Swipe left or right on the calendar to change month")

            turn(to: month.next, systemImage: "chevron.right", label: "The month after")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func turn(to other: DailyMonth, systemImage: String, label: String) -> some View {
        let open = months.contains(other)
        return Button {
            // The haptic fires from onChange once the page settles on its new month,
            // whether the turn came from this button or from a swipe across the calendar.
            withAnimation { month = other }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(GamePalette.post)
                .frame(width: 36, height: 36)
                .background(Circle().fill(GamePalette.cream.opacity(open ? 0.95 : 0.4)))
                .opacity(open ? 1 : 0.5)
        }
        .disabled(!open)
        .accessibilityLabel(label)
    }

    /// How many days of this month can be played at all: every day up to today that the
    /// almanac has a puzzle for. It is what the month's tally is counted out of, so a
    /// month still going does not read as though the player were already behind.
    private var playableCount: Int {
        month.days.filter { DailyAlmanac.isOpen($0, today: today) }.count
    }

    // MARK: - The calendar

    private var weekdayHeadings: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Weekday.allCases, id: \.rawValue) { day in
                Text(day.initial)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    // Dark lettering, the same as the month's name on the pill above them:
                    // these used to be cream cut out of a dark horizon, and the sky behind
                    // them now is pale enough that a pale letter had nothing to stand on.
                    .foregroundStyle(GamePalette.post)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(day.name)
            }
        }
        .padding(.top, 2)
    }

    private func grid(for page: DailyMonth) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<page.openingBlanks, id: \.self) { _ in
                Color.clear
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }

            ForEach(page.days) { date in
                Button {
                    open(date)
                } label: {
                    DailySquare(
                        date: date,
                        standing: standing(on: date),
                        isToday: date == today
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SignpostButtonStyle())
                .disabled(!DailyAlmanac.isOpen(date, today: today))
            }
        }
    }

    /// What the archive says about a day. A day the almanac has nothing for is drawn as a
    /// gap rather than as a locked square: there is no puzzle to be waiting for.
    private func standing(on date: DailyDate) -> DailySquare.Standing {
        guard DailyAlmanac.holdsAPuzzle(on: date) else { return .missing }
        guard date <= today else { return .locked }
        guard progress.isComplete(date) else { return .open }
        return .complete(
            stars: progress.stars(on: date),
            hasTheBestPen: progress.hasTheBestPen(on: date)
        )
    }

    /// What the calendar is for, said once at the bottom rather than on every square.
    private var footnote: some View {
        Text("Every daily puzzle so far is here. Each new day unlocks when it arrives.")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(GamePalette.cream.opacity(0.75))
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
            .padding(.top, 6)
            .padding(.horizontal, 12)
    }

    private func open(_ date: DailyDate) {
        guard DailyAlmanac.isOpen(date, today: today) else { return }
        // Today's board is the free one; any other day out of the archive is the full game.
        // The calendar was walkable the whole way here — this is the one tap that meets the
        // wall, on the very day the player reached for.
        if date != today, !fullGame.isUnlocked {
            Haptics.tap(.medium)
            Analytics.record(.offerShown(from: FullGameOfferSource.archive.rawValue))
            isOffering = true
            return
        }
        Haptics.tap(.medium)
        // A day out of the archive rather than this morning's, which is the difference
        // between somebody catching up and somebody browsing.
        Analytics.record(.dailyOpened(isToday: date == today))
        // Opened as it was left, submitted wall and all, the same as today's is off the
        // title screen. A day already held used to be asked about first — put the wall
        // back, or clear the field — in front of a board the player had not looked at yet;
        // the board carries both answers itself, in *Restore* and *Start over*.
        playing = date
    }
}

#Preview {
    NavigationStack {
        DailyArchiveView(
            today: DailyDate(year: 2026, month: 4, day: 22),
            progress: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
            fullGame: .unlocked()
        )
    }
}

#Preview("Behind the wall") {
    NavigationStack {
        DailyArchiveView(
            today: DailyDate(year: 2026, month: 4, day: 22),
            progress: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
            fullGame: .locked()
        )
    }
}
