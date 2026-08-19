import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a name that plants itself a letter at
/// a time like a run of fence, and a Play button that is impossible to miss.
///
/// Play walks into Mudlark Meadow until that world is held; only once the meadow boss is beaten
/// does it open the universe map. Under Play is the day's own board on a card of its own — what
/// day it is, what that day asks, and once it has been held, the stars it gave up, the time it
/// took and the run of days it is part of. Under that, the archive of every daily there has been
/// this year, and the tutorial for anybody who wants the walkthrough before the meadow — which
/// on a first run opens itself, so that a player meeting the game has been shown how to lay a
/// fence before they are asked to.
@MainActor
struct TitleScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// How much of the name has been driven into the ground, 0 to 1.
    @State private var planted: Double = 0
    /// The board under the name, the tally and the buttons all arrive a beat behind the
    /// lettering.
    @State private var arrived = false
    /// Where Play has sent the player: the meadow trail until that world is held, and the
    /// universe map only once the meadow boss is beaten.
    @State private var playDestination: PlayDestination?
    /// Whether the practice pen is up. Pushed by the row on the list, and by the screen
    /// itself the first time the game is opened.
    @State private var isTutorial = false
    @State private var isDailyOpen = false
    @State private var restoreSubmittedDaily = false
    @State private var isOfferingSubmittedDaily = false
    @State private var isArchiveOpen = false
    @State private var showsSettings = false
    /// The meadow's opening film, over the title screen. It plays here rather than pushing
    /// the map behind it, so that the stack stays a title screen with a map on top of it —
    /// the same hand-off the game used before the universe map existed.
    @State private var showsOpening = false
    /// Whether the film that has just come down was the real thing rather than a player
    /// changing their mind, and so whether the meadow is what happens next.
    @State private var openingLedToTheMap = false
    /// The same progress the map is handed, so the stars on the tally above are the ones
    /// just won — and go the moment they are cleared from the settings sheet.
    @State private var progress: WorldProgress
    /// The same book of days the archive and today's board are handed, so the card below
    /// shows the stars that were just won without having to be told about them.
    @State private var daily: DailyProgress
    /// The daily reminder. It lives here because this is the screen every road out of a
    /// puzzle comes back to, and so the one place that reliably gets to lay the fortnight
    /// of reminders down again against a book of days that has just changed.
    @State private var reminder: DailyReminder
    /// Whether the game's own offer of a reminder is up. Raised once, after a day has been
    /// held — never on the way in, when the player has nothing yet to be reminded about.
    @State private var isOfferingReminders = false
    /// Which square of the calendar the game is standing on. Read once when the screen
    /// arrives rather than on every redraw, so the card cannot change under a finger — and
    /// read again every time the screen comes back, which is what carries a player over
    /// midnight onto tomorrow's puzzle.
    @State private var today: DailyDate
    /// Whether the day was handed in rather than asked of the phone. A screenshot run opens
    /// on a fixed square of the calendar, and must not have the screen quietly put it back
    /// to whatever day the runner is having.
    private let dayWasGiven: Bool

    /// - Parameters:
    ///   - today: The day the game is being played on, or nothing at all to ask the phone.
    ///     Handed in so the previews and the screenshot runs open on a known square of the
    ///     calendar.
    ///   - showsSettings: Opens with the settings sheet already up, which is how CI
    ///     photographs it without tapping through the title screen.
    ///   - showsReminderPrompt: Opens with the game's offer of a daily reminder already up,
    ///     for the same reason — and handed in rather than waited for, since the offer's own
    ///     rule is that it only appears to somebody who has held a day and never been asked.
    init(
        progress: WorldProgress = WorldProgress(),
        daily: DailyProgress = DailyProgress(),
        reminder: DailyReminder = DailyReminder(),
        today: DailyDate? = nil,
        showsSettings: Bool = false,
        showsReminderPrompt: Bool = false
    ) {
        _progress = State(initialValue: progress)
        _daily = State(initialValue: daily)
        _reminder = State(initialValue: reminder)
        _today = State(initialValue: today ?? .today())
        dayWasGiven = today != nil
        _showsSettings = State(initialValue: showsSettings)
        _isOfferingReminders = State(initialValue: showsReminderPrompt)
    }

    private var world: WorldMap { progress.world }
    private var hasADailyPuzzle: Bool { DailyAlmanac.holdsAPuzzle(on: today) }

    var body: some View {
        ZStack {
            TitleSceneView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                wordmark

                Spacer(minLength: 12)

                playBlock
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 18)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $playDestination) { destination in
            switch destination {
            case .meadow:
                // Finishing the meadow's send-off reveals the universe: swap the trail for
                // the cosmic map in place, so the boss's farewell leads straight into it.
                WorldMapView(progress: progress) {
                    playDestination = .universe
                }
            case .universe:
                UniverseMapView()
            }
        }
        .navigationDestination(isPresented: $isTutorial) {
            TutorialView()
        }
        .navigationDestination(isPresented: $isDailyOpen) {
            DailyPuzzleView(
                date: today,
                progress: daily,
                restoreSubmitted: restoreSubmittedDaily
            )
        }
        .confirmationDialog(
            today.fullTitle,
            isPresented: $isOfferingSubmittedDaily,
            titleVisibility: .visible
        ) {
            Button("Put it back") {
                restoreSubmittedDaily = true
                isDailyOpen = true
            }
            Button("Play again") {
                // Clear the field means clear the field: the board filed away when the day
                // was left is the submitted wall itself, so it has to go or *Play again*
                // opens on the very wall *Put it back* offers. The wall stays on the books
                // — the trophy still has it once the new field is somewhere else.
                daily.clearDraft(on: today)
                restoreSubmittedDaily = false
                isDailyOpen = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Put the fencing back the way you submitted it, or clear the field and try again.")
        }
        .navigationDestination(isPresented: $isArchiveOpen) {
            DailyArchiveView(today: today, progress: daily)
                .onAppear { Analytics.record(.dailyArchiveOpened) }
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView(progress: progress, daily: daily, reminder: reminder)
                .onAppear { Analytics.record(.settingsOpened) }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isOfferingReminders) {
            ReminderPromptView(
                streak: daily.streak(upTo: today),
                time: reminder.time,
                onAccept: {
                    // The offer is marked as made whichever way it goes, so the sheet is
                    // never put up twice — the phone's own prompt follows from here, and
                    // that one a phone only ever shows once anyway.
                    reminder.markOffered()
                    Task {
                        // Counted on what `turnOn` gives back rather than on the tap, so the
                        // phone's answer is counted beside the player's. A yes the phone then
                        // refuses is the one outcome this whole sheet exists to avoid, and
                        // the only way to find out it is happening is to count it.
                        let allowed = await reminder.turnOn(today: today, progress: daily)
                        Analytics.record(.reminderAnswered(taken: true, allowed: allowed))
                    }
                },
                onDecline: {
                    reminder.markOffered()
                    Analytics.record(.reminderAnswered(taken: false))
                }
            )
            .onAppear { Analytics.record(.reminderOffered) }
            // Half the screen: an offer, made while the title screen is still visible
            // behind it, rather than a wall the player has to get past to carry on.
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // The meadow is pushed as the film comes down rather than from inside it, so the
        // two never fight over the screen.
        .fullScreenCover(isPresented: $showsOpening, onDismiss: { openTheMeadow() }) {
            CutSceneView(.opening()) { endTheOpening() }
        }
        .onAppear {
            // The map keeps its own copy of the stars while it is up; read them back so a
            // player coming off the trail sees the ones they have just taken.
            progress.reload()
            daily.reload()
            // A game left open overnight comes back to a new day's puzzle rather than to
            // yesterday's, already held.
            if !dayWasGiven { today = .today() }
            raiseTheCurtain()
            Task { await keepTheRemindersTrue() }
        }
        // The push waits for the screen to be up rather than going out from inside
        // `onAppear`, which is a stack being asked to walk on before it has finished
        // standing its own root up.
        .task { openTheTutorialOnAFirstRun() }
    }

    /// The walkthrough shows itself on a first run rather than waiting to be found. A player
    /// opening the game for the first time is handed the practice pen straight away: how a
    /// pen is laid, why water is worth building against and what closing one is worth are
    /// not things the title screen can say, and a row fourth down a list is a poor place to
    /// keep them.
    ///
    /// It is written down as seen the moment it goes up rather than when it finishes, the
    /// same way a film is. A player who backs out of it lands here, and this runs again as
    /// they land — so anything less would put them straight back into the walkthrough they
    /// just left, over and over, with no way through to the game.
    private func openTheTutorialOnAFirstRun() {
        guard progress.isTheTutorialDue else { return }
        progress.markTutorialSeen()
        isTutorial = true
    }

    // MARK: - The daily reminder

    /// Every road out of a puzzle comes back through here, so this is where the fortnight
    /// of reminders is laid down again: what is worth reminding about has just changed, and a
    /// day held at ten past eight must not be reminded about at nine.
    ///
    /// The phone is asked where it stands first, because permission is granted and taken
    /// away in the system settings — somewhere neither this screen nor the game behind it
    /// can see into.
    private func keepTheRemindersTrue() async {
        await reminder.readTheStanding()
        await reminder.replan(today: today, progress: daily)
        offerTheReminderIfItIsDue()
    }

    /// Whether to put the game's own offer up, and the whole of when it is allowed to
    /// appear: the player has held a daily puzzle, so there is a run of days to lose, and
    /// neither the game nor the phone has asked them about it before.
    ///
    /// Never on the way in. A phone shows its permission sheet once and never again, and
    /// spending that on somebody who has not yet found out what a daily puzzle is spends it
    /// for nothing.
    private func offerTheReminderIfItIsDue() {
        guard reminder.isDueAnOffer, daily.completedCount > 0 else { return }
        // Nothing else may be going up or already up. The walkthrough is the one worth
        // naming: a player who has only ever played dailies is owed both at once, and an
        // offer sheet arriving over a practice pen pushing itself onto the stack would be
        // two screens fighting over the same moment. The offer keeps — it is made the
        // next time they come back here, which is on the way out of the walkthrough.
        guard !progress.isTheTutorialDue, !isTutorial,
              !showsSettings, playDestination == nil, !isDailyOpen, !isArchiveOpen
        else { return }
        isOfferingReminders = true
    }

    // MARK: - The bar across the top

    /// How much of whatever Play opens has been taken, and a gear well away from Play. What
    /// is behind the gear — the version, and a button that throws away every star — is
    /// nothing a player needs while they are playing.
    private var topBar: some View {
        HStack(spacing: 10) {
            starTally

            Spacer(minLength: 0)

            Button {
                Haptics.tap(.light)
                showsSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(GamePalette.post)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(GamePalette.cream.opacity(0.94)))
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            }
            .accessibilityLabel("Settings")
        }
        .opacity(arrived ? 1 : 0)
        .padding(.bottom, 26)
    }

    /// The running total, up here where it is a badge rather than small print under the
    /// buttons. How much mud three stars takes on any given puzzle is left for the player
    /// to find out by taking it.
    private var starTally: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(GamePalette.pen)
                .shadow(color: GamePalette.post.opacity(0.25), radius: 0.5, y: 0.5)

            Text("\(tally)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(GamePalette.post)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(Capsule().fill(GamePalette.cream.opacity(0.94)))
        .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(starsSpoken)
    }

    /// What the badge counts, which is whatever Play opens. While the meadow is still being
    /// held it is the meadow's own stars, the same number the trail wears in its corner. Once the
    /// meadow is held Play opens the universe instead, and a badge still stuck on the meadow
    /// would sit at 27 for the whole rest of the game — going nowhere on the very screen a player
    /// crosses to go and take more. So it widens to every star in every built world, and carries
    /// on meaning something all the way out.
    private var tally: Int {
        guard progress.isTheWorldHeld else { return progress.totalStars }
        return Universe.all.totalStars(stars: progress.bestStars)
    }

    /// The tally read out, with the ground it covers said aloud — the badge shows the widening
    /// by its number alone, which is nothing VoiceOver can point at.
    private var starsSpoken: String {
        let counted = tally
        let ground = progress.isTheWorldHeld ? "across every world" : "in \(world.name)"
        return "\(counted) star\(counted == 1 ? "" : "s") \(ground)"
    }

    // MARK: - The name

    private var wordmark: some View {
        VStack(spacing: 16) {
            PlantedWord(word: "PIGPEN", size: 54, planted: planted)

            tagline
                .opacity(arrived ? 1 : 0)
                .scaleEffect(arrived ? 1 : 0.88)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pigpen. Fence in the pig.")
    }

    /// A board nailed up under the name, lit from above like the buttons are, with a nail
    /// head holding down each end of it.
    private var tagline: some View {
        Text("Fence in the pig")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 9)
            .padding(.horizontal, 26)
            .background(plank)
            .overlay(nailHeads)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 4)
            .rotationEffect(.degrees(-2))
    }

    private var plank: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(GamePalette.picket)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.42), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.28), lineWidth: 1.5)
            }
    }

    private var nailHeads: some View {
        HStack(spacing: 0) {
            nailHead
            Spacer(minLength: 0)
            nailHead
        }
        .padding(.horizontal, 9)
    }

    private var nailHead: some View {
        Circle()
            .fill(GamePalette.post.opacity(0.45))
            .frame(width: 6, height: 6)
    }

    // MARK: - The list of ways to play

    /// Every way off the title screen, painted on the one run of boards so they read as a
    /// list rather than as four buttons the game happened to leave lying about: Play at the
    /// head of it in gold, today's board under it, and the archive and the tutorial below
    /// that. Each is the same plank with the same press in it; only the paint and what stands
    /// on the right-hand end tell one from the next.
    private var playBlock: some View {
        VStack(spacing: 9) {
            Button {
                Haptics.tap(.medium)
                play()
            } label: {
                MenuRow(
                    icon: "play.fill",
                    title: "Play",
                    detail: playDetail,
                    tint: GamePalette.pen
                ) {
                    HStack(spacing: 8) {
                        if completion.percent > 0 {
                            CompletionBadge(completion: completion)
                        }
                        chevron
                    }
                }
            }
            .buttonStyle(MenuRowButtonStyle())
            .modifier(Breathing(active: !reduceMotion))
            .accessibilityLabel(playSpoken)

            dailyRow

            destinationRow(
                icon: "calendar",
                title: "Archive",
                detail: "Every daily puzzle of the year",
                hint: "Every daily puzzle of the year, a month at a time"
            ) {
                isArchiveOpen = true
            }

            destinationRow(
                icon: "hand.tap.fill",
                title: "Tutorial",
                detail: "Walk through how to fence in the pig",
                hint: "Walk through how to fence in the pig"
            ) {
                isTutorial = true
            }
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// What Play has to say for itself under its own name: the world it walks into while the
    /// meadow is still being held, and the whole universe once it is.
    private var playDetail: String {
        progress.isTheWorldHeld
            ? "A universe of worlds to fence"
            : "\(world.name) · \(world.count) puzzles"
    }

    /// Play read out in full, since the percent it wears sits in the row as a badge VoiceOver
    /// would otherwise read as a bare number.
    private var playSpoken: String {
        var said = "Play. \(playDetail)."
        guard completion.percent > 0 else { return said }
        said += " \(completion.percent) per cent of the game held."
        if completion.isEverything {
            said += " Every star and every rainbow there is."
        }
        return said
    }

    /// How far through the whole game the player is.
    ///
    /// Worked out from the stars and the rainbows this screen already holds rather than from a
    /// second reading of the store: level ids are unique across worlds, so the store a world is
    /// handed holds every world's stars — `WorldProgress` only narrows them to its own trail when
    /// it counts them. That keeps the previews and the screenshot runs honest too, since the
    /// number then comes from whatever progress the screen was handed rather than from the device.
    private var completion: GameCompletion {
        Universe.all.completion(stars: progress.bestStars, bestPens: progress.bestPens)
    }

    /// The chevron on the right of a row that only opens something. The daily wears its stars
    /// there instead, which is the one row on the list with anything else to say for itself.
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 15, weight: .black))
            .foregroundStyle(GamePalette.post.opacity(0.4))
    }

    /// Today's board, made to sit in the list as one more row: the day itself along the top,
    /// how the day has gone underneath, and — once it has been held — the stars it gave up
    /// where the other rows keep their chevron. A day the almanac has nothing for is greyed
    /// down rather than left off, so the list never changes height under a finger.
    private var dailyRow: some View {
        let stars = daily.stars(on: today)
        let streak = daily.streak(upTo: today)
        return Button {
            Haptics.tap(.medium)
            openToday()
        } label: {
            MenuRow(
                icon: dailyIcon(stars: stars),
                title: hasADailyPuzzle ? today.title : "No puzzle today",
                detail: dailyDetail(stars: stars, streak: streak),
                tint: GamePalette.cream,
                dimmed: !hasADailyPuzzle
            ) {
                if stars > 0 {
                    StarRow(stars: stars, size: 12, hasTheBestPen: daily.hasTheBestPen(on: today))
                } else if hasADailyPuzzle {
                    chevron
                }
            }
        }
        .buttonStyle(MenuRowButtonStyle())
        .disabled(!hasADailyPuzzle)
        .accessibilityLabel(dailySpoken(stars: stars, streak: streak))
    }

    /// The seal for a day that has been held, the sun for one still waiting — the same two
    /// marks the card carried before the board became a row.
    private func dailyIcon(stars: Int) -> String {
        stars > 0 ? "checkmark.seal.fill" : "sun.max.fill"
    }

    /// The daily read out in full, since its stars sit in the row as a picture VoiceOver
    /// steps past. Everything the old card said aloud is said here instead.
    private func dailySpoken(stars: Int, streak: Int) -> String {
        guard hasADailyPuzzle else {
            return "Today's puzzle. There is none — the almanac stops before today."
        }
        let spelled = ["no", "one", "two", "three"]
        var said = "Today's puzzle. \(today.fullTitle)."
        if stars > 0 {
            said += " Penned, \(spelled[min(max(stars, 0), 3)]) star\(stars == 1 ? "" : "s")."
            if daily.hasTheBestPen(on: today) { said += " The best pen there is." }
            if let best = daily.bestTime(on: today) {
                said += " Best time \(Stopwatch.spoken(TimeInterval(best)))."
            }
        } else {
            said += " Not penned yet."
        }
        if streak > 1 { said += " \(streak) days in a row." }
        return said
    }

    /// What the day has to say for itself under its own name: nothing if the book is empty,
    /// the run of days once it is going, the best time once it has been held, or simply that
    /// it is today's and waiting.
    private func dailyDetail(stars: Int, streak: Int) -> String {
        guard hasADailyPuzzle else { return "The almanac stops before today" }
        if stars > 0 {
            if streak > 1 { return "Penned · \(streak) days in a row" }
            if let best = daily.bestTime(on: today) {
                return "Penned · best \(Stopwatch.face(TimeInterval(best)))"
            }
            return "Penned — play it again"
        }
        return streak > 1 ? "Today's puzzle · \(streak) days in a row" : "Today's puzzle"
    }

    /// Opens today's board, or — once a wall has been submitted — offers to put that wall
    /// back before the field comes up empty.
    private func openToday() {
        Analytics.record(.dailyOpened(isToday: true))
        if daily.submittedFences(on: today) != nil {
            isOfferingSubmittedDaily = true
        } else {
            restoreSubmittedDaily = false
            isDailyOpen = true
        }
    }

    /// A row that simply pushes another screen: the archive and the tutorial, cut from the
    /// same board as Play so the list stays one thing.
    private func destinationRow(
        icon: String,
        title: String,
        detail: String,
        hint: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.tap(.light)
            action()
        } label: {
            MenuRow(icon: icon, title: title, detail: detail, tint: GamePalette.cream) {
                chevron
            }
        }
        .buttonStyle(MenuRowButtonStyle())
        .accessibilityHint(hint)
    }

    // MARK: - Play

    /// Where Play goes. The universe map stays hidden until every pen in the meadow is held;
    /// until then Play walks straight into Mudlark Meadow (through its opening film the first
    /// time). Once the meadow boss is beaten, Play opens the universe map instead — and each
    /// world past the meadow plays its own opening the first time it is entered.
    private func play() {
        if progress.isTheWorldHeld {
            playDestination = .universe
        } else if progress.isTheOpeningDue {
            showsOpening = true
        } else {
            playDestination = .meadow
        }
    }

    /// The film is over, watched or skipped. It has had its one showing either way, and the
    /// meadow is what it was always leading to.
    private func endTheOpening() {
        progress.markPlayed(.opening)
        openingLedToTheMap = true
        showsOpening = false
    }

    /// Called as the film comes down. A player who somehow leaves it by another road than
    /// the one above is simply put back on the title screen.
    private func openTheMeadow() {
        guard openingLedToTheMap else { return }
        openingLedToTheMap = false
        playDestination = .meadow
    }

    // MARK: - Timing

    private func raiseTheCurtain() {
        guard !reduceMotion else {
            planted = 1
            arrived = true
            return
        }
        withAnimation(.spring(duration: 0.9, bounce: 0.4)) { planted = 1 }
        withAnimation(.spring(duration: 0.6, bounce: 0.3).delay(0.45)) { arrived = true }
    }
}

/// The name, set a letter at a time like a run of fence posts: each letter drops in, turns
/// straight and settles, and the one to its right follows it into the ground.
private struct PlantedWord: View {
    let word: String
    let size: CGFloat
    /// How much of the word is in the ground, 0 to 1. Values a little over 1 let the last
    /// letters overshoot, which is what gives the wordmark its pop.
    let planted: Double

    private var letters: [Character] { Array(word) }

    var body: some View {
        HStack(spacing: size * 0.06) {
            ForEach(letters.indices, id: \.self) { index in
                let landed = landing(of: index)
                let settling = 1 - min(landed, 1)

                lettering(letters[index])
                    .opacity(min(landed, 1))
                    .scaleEffect(CGFloat(0.7 + 0.3 * landed))
                    .rotationEffect(.degrees(-9 * settling))
                    .offset(y: -size * 0.45 * CGFloat(settling))
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 10, y: 8)
    }

    private func lettering(_ letter: Character) -> some View {
        ZStack {
            // A dark copy behind the letter gives it its cut-out edge.
            glyph(letter)
                .foregroundStyle(GamePalette.post)
                .offset(y: 4)

            glyph(letter)
                .foregroundStyle(
                    LinearGradient(
                        colors: [GamePalette.cream, GamePalette.pen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private func glyph(_ letter: Character) -> Text {
        Text(String(letter))
            .font(.system(size: size, weight: .black, design: .rounded))
    }

    /// Each letter waits its turn, then has the back half of the run to itself.
    private func landing(of index: Int) -> Double {
        guard letters.count > 1 else { return max(0, planted) }
        let turn = 0.5 * Double(index) / Double(letters.count - 1)
        return max(0, (planted - turn) / 0.5)
    }
}

/// A slow pulse to hold the eye on the button. It has to be a phase animator rather than a
/// repeating animation on a flag: the flag flips as the button is arriving, and a repeating
/// animation would take the arrival with it and swing the button about the screen for good.
private struct Breathing: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content.phaseAnimator([1.0, 1.04]) { button, scale in
                button.scaleEffect(CGFloat(scale))
            } animation: { _ in
                .easeInOut(duration: 1.5)
            }
        } else {
            content
        }
    }
}

/// Where Play on the title screen leads. The meadow comes first; the universe only after it.
private enum PlayDestination: Hashable {
    case meadow
    case universe
}

/// How much of the whole game is in, worn on the right-hand end of Play the way the daily wears
/// its stars — every world, every level, every star and every rainbow, in one number.
///
/// It goes rainbow at a hundred, and only there. Three stars on every level in the game stops at
/// 75, so the badge sitting gold at 99 is the game saying there is a map somewhere still holding
/// its best pen back — which is the whole reason the number is on the button rather than buried
/// in the settings sheet.
private struct CompletionBadge: View {
    let completion: GameCompletion

    var body: some View {
        Text("\(completion.percent)%")
            .font(.system(size: 13, weight: .black, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 4)
            .padding(.horizontal, 9)
            .background {
                Capsule()
                    .fill(.white.opacity(0.45))
                    .overlay {
                        if completion.isEverything {
                            RainbowWash()
                                .mask { Capsule() }
                                .opacity(0.8)
                        }
                    }
            }
            .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1))
            .accessibilityHidden(true)
    }
}

/// One board on the title screen's list of ways to play: a round token on the left with the
/// row's mark in it, the row's name and a line under it, and whatever the row keeps on its
/// right-hand end — a chevron for the ones that only open a screen, the day's stars for the
/// daily.
///
/// Every row is the same plank, lit from the top the way the fence rack and the signposts
/// are, so Play, today's board, the archive and the tutorial read as one list rather than as
/// four unlike buttons. The paint is the only thing that sets the head of the list apart:
/// Play stands in gold, the rest on cream.
private struct MenuRow<Trailing: View>: View {
    let icon: String
    let title: String
    let detail: String
    /// The paint on the board. Gold marks the row the screen most wants pressed.
    var tint: Color
    /// A row with nothing behind it — a day the almanac skips — is greyed down rather than
    /// dropped, so the list never changes height under a finger.
    var dimmed = false
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 13) {
            token

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(detail)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(GamePalette.post.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            trailing()
        }
        .foregroundStyle(GamePalette.post)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 11)
        .padding(.horizontal, 14)
        .background(plank)
        .opacity(dimmed ? 0.55 : 1)
        .accessibilityElement(children: .combine)
    }

    /// The round token that opens the row, a smaller cousin of the faces on the world map's
    /// signposts.
    private var token: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .black))
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(.white.opacity(0.4))
                    .overlay(Circle().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1))
            }
    }

    private var plank: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(tint)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1.5)
            }
            .shadow(color: .black.opacity(0.28), radius: 5, y: 3)
    }
}

/// The press of a row: it sinks a little, the way every board in this game does.
private struct MenuRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        // The walkthrough already spent, so the preview is the title screen rather than the
        // practice pen it opens itself into on a first run.
        TitleScreenView(progress: .beforeTheFirstStar())
    }
}

#Preview("A first run") {
    NavigationStack {
        TitleScreenView(progress: WorldProgress(store: RememberedProgress()))
    }
}

#Preview("Settings up") {
    NavigationStack {
        TitleScreenView(progress: .partWayThrough(), showsSettings: true)
    }
}

#Preview("The meadow behind us") {
    NavigationStack {
        TitleScreenView(progress: .theMeadowHeld())
    }
}

#Preview("Nothing left to take") {
    NavigationStack {
        TitleScreenView(progress: .everythingHeld())
    }
}

#Preview("A week of dailies in") {
    NavigationStack {
        TitleScreenView(
            progress: .partWayThrough(),
            daily: .partWayThroughTheMonth(today: DailyDate(year: 2026, month: 4, day: 22)),
            reminder: .reminding(),
            today: DailyDate(year: 2026, month: 4, day: 22)
        )
    }
}

#Preview("The reminder offered") {
    NavigationStack {
        TitleScreenView(
            progress: .partWayThrough(),
            daily: .partWayThroughTheMonth(
                today: DailyDate(year: 2026, month: 4, day: 22),
                includingToday: true
            ),
            reminder: .neverAsked(),
            today: DailyDate(year: 2026, month: 4, day: 22),
            showsReminderPrompt: true
        )
    }
}
