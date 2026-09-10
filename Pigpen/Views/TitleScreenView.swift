import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a name that plants itself a letter at
/// a time like a run of fence, and a Play button that is impossible to miss.
///
/// Play walks into Mudlark Meadow until that world is held; only once the meadow boss is beaten
/// does it open the universe map. Under Play is the day's own board on a card of its own — what
/// day it is, what that day asks, and once it has been held, the stars it gave up, the time it
/// took and the run of days it is part of. Under that, the archive of every daily there has
/// been, and the tutorial for anybody who wants the walkthrough before the meadow — which
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
    /// Which day's board is up, if one is. A day rather than a flag, because the two ways
    /// in do not always name the same day: the row under Play opens today's, and a reminder
    /// tapped after midnight is asking about the morning it was posted for.
    @State private var playingDaily: DailyDate?
    @State private var isArchiveOpen = false
    @State private var showsSettings = false
    /// Whether the settings sheet was closed on its way to the walkthrough. The practice pen
    /// is pushed onto this screen rather than raised over the sheet, so the ask waits for the
    /// sheet to be gone before it is acted on — a push made from under a sheet still coming
    /// down does not reliably survive the journey.
    @State private var wantsWalkthrough = false
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
    /// Whether the full game has been bought. Held here so the settings sheet and the
    /// archive this screen opens are both looking at the same switch the map is — handed in
    /// so a preview or a screenshot can stand the game up owned or for sale.
    private let fullGame: FullGame
    /// Whether the game's own offer of a reminder is up. Raised once, after a day has been
    /// held — never on the way in, when the player has nothing yet to be reminded about.
    @State private var isOfferingReminders = false
    /// When the game asks what a player thinks of it. It lives here for the same reason the
    /// reminder does: every road out of a puzzle comes back through this screen, so this is
    /// where a player is standing the moment after they have done something worth asking about
    /// — and the one place the ask can be made over nothing at all.
    private let rating: RatingPrompt
    /// Which square of the calendar the game is standing on. Read once when the screen
    /// arrives rather than on every redraw, so the card cannot change under a finger — and
    /// read again every time the screen comes back, which is what carries a player over
    /// midnight onto tomorrow's puzzle.
    @State private var today: DailyDate
    /// Whether the day was handed in rather than asked of the phone. A screenshot run opens
    /// on a fixed square of the calendar, and must not have the screen quietly put it back
    /// to whatever day the runner is having.
    private let dayWasGiven: Bool
    /// Where a tapped reminder leaves the morning it is asking for. The notification centre
    /// has nowhere to push a board from, so it writes the day down and this screen — the
    /// root of the stack, and so the one screen that is always there to be asked — opens it.
    private let taps: TappedReminder

    /// - Parameters:
    ///   - today: The day the game is being played on, or nothing at all to ask the phone.
    ///     Handed in so the previews and the screenshot runs open on a known square of the
    ///     calendar.
    ///   - showsSettings: Opens with the settings sheet already up, which is how CI
    ///     photographs it without tapping through the title screen.
    ///   - showsReminderPrompt: Opens with the game's offer of a daily reminder already up,
    ///     for the same reason — and handed in rather than waited for, since the offer's own
    ///     rule is that it only appears to somebody who has held a day and never been asked.
    ///   - taps: Where tapped reminders are written down. The shared one the phone writes
    ///     into, save where a preview or a test wants a tap of its own without one having to
    ///     arrive on the machine.
    ///   - rating: When the game may ask what the player thinks of it. Handed in by the
    ///     screenshot runs, which open onto a player with a world held and a fortnight of days
    ///     behind them — exactly the standing the prompt watches for — and must never put
    ///     Apple's own prompt in the photograph.
    init(
        progress: WorldProgress = WorldProgress(),
        daily: DailyProgress = DailyProgress(),
        reminder: DailyReminder = DailyReminder(),
        today: DailyDate? = nil,
        showsSettings: Bool = false,
        showsReminderPrompt: Bool = false,
        taps: TappedReminder = .shared,
        fullGame: FullGame = .shared,
        rating: RatingPrompt = .shared
    ) {
        _progress = State(initialValue: progress)
        _daily = State(initialValue: daily)
        _reminder = State(initialValue: reminder)
        _today = State(initialValue: today ?? .today())
        dayWasGiven = today != nil
        _showsSettings = State(initialValue: showsSettings)
        _isOfferingReminders = State(initialValue: showsReminderPrompt)
        self.taps = taps
        self.fullGame = fullGame
        self.rating = rating
    }

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
        .navigationDestination(item: $playingDaily) { date in
            DailyPuzzleView(date: date, progress: daily)
        }
        .navigationDestination(isPresented: $isArchiveOpen) {
            DailyArchiveView(today: today, progress: daily, fullGame: fullGame)
                .onAppear { Analytics.record(.dailyArchiveOpened) }
        }
        // A page of its own rather than a sheet with the meadow showing over the top of it.
        // Settings is a list long enough to scroll — the version, the purchase, the films,
        // the switches, the reminder, and the button that throws it all away — and a half
        // screen made the player read it through a letterbox.
        .fullScreenCover(isPresented: $showsSettings) {
            SettingsView(
                progress: progress,
                daily: daily,
                reminder: reminder,
                fullGame: fullGame,
                onWalkthrough: { wantsWalkthrough = true }
            )
                .onAppear { Analytics.record(.settingsOpened) }
        }
        .sheet(isPresented: $isOfferingReminders) {
            ReminderPromptView(
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
            // Before the curtain and before the reminders are laid down again: a tap made
            // while the game was shut is already waiting by the time this screen arrives,
            // and answering it here means the offer sheet below sees a board on its way up
            // and keeps.
            answerAnyTappedReminder()
            raiseTheCurtain()
            // One after the other rather than side by side: the reminder's offer is the rarer
            // of the two and gets first refusal on the moment, and the rating prompt below
            // stands down for the visit if it went up.
            Task {
                await keepTheRemindersTrue()
                askForARatingIfItIsDue()
            }
        }
        // And a tap that arrives afterwards — the notification centre hands a cold launch's
        // tap over a moment after the first screen is up, and hands a backgrounded game's
        // over whenever the player gets round to it.
        .onChange(of: taps.waiting) { _, _ in answerAnyTappedReminder() }
        // The walkthrough asked for from the settings drawer, once the drawer is shut.
        .onChange(of: showsSettings) { _, isUp in
            guard !isUp, wantsWalkthrough else { return }
            wantsWalkthrough = false
            isTutorial = true
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
              !showsSettings, playDestination == nil, playingDaily == nil, !isArchiveOpen
        else { return }
        isOfferingReminders = true
    }

    /// Opens the morning a tapped reminder is asking for.
    ///
    /// A reminder that puts the player down here, with the board still a tap away, has spent
    /// its one interruption on nothing — so whatever else is up comes down and the day it
    /// names goes up instead. A player who taps *Pig's waiting* has said where they want
    /// to be, and a world map they left an hour ago is not an answer to it.
    ///
    /// The tap is taken rather than read, so one tap opens one board and coming back here
    /// later does not open it again. A morning the almanac has nothing for, or one still to
    /// come, is let go rather than opened onto an empty field — neither should ever have had
    /// a reminder laid down for it, and a day cannot be played merely because something on
    /// the lock screen said so.
    private func answerAnyTappedReminder() {
        guard let day = taps.take(), DailyAlmanac.isOpen(day, today: today) else { return }
        Analytics.record(.reminderFollowed)
        playDestination = nil
        isTutorial = false
        isArchiveOpen = false
        showsSettings = false
        isOfferingReminders = false
        open(day)
    }

    // MARK: - Being rated

    /// Puts what the player has to show for themselves in front of the rating prompt, which
    /// decides whether any of it is worth asking about — see `RatingPrompt`, which holds the
    /// whole of that decision and every reason for it.
    ///
    /// What this screen owns is the *where*: the title screen, at rest, with the board finished
    /// and the map behind them. Apple's prompt cannot be taken back down and cannot be aimed,
    /// so it must never arrive over something a player is in the middle of — and it must never
    /// arrive over the one sheet that offers the morning reminder, which is a question the game
    /// gets asked once ever and this one is not.
    ///
    /// A visit with anything up is left alone entirely rather than merely kept quiet: the
    /// prompt writes down what it has looked at, so looking now would spend the moment on a
    /// screen that could not have shown anything.
    private func askForARatingIfItIsDue() {
        guard !isOfferingReminders, !progress.isTheTutorialDue, !isTutorial, !showsOpening,
              !showsSettings, playDestination == nil, playingDaily == nil, !isArchiveOpen
        else { return }

        let moment = rating.look(at: .read(from: progress, daily: daily, today: today))
        guard let moment else { return }
        Analytics.record(.ratingAsked(at: moment))
    }

    // MARK: - The bar across the top

    /// How much of whatever Play opens has been taken, and a gear well away from Play. What
    /// is behind the gear — the version, and a button that throws away every star — is
    /// nothing a player needs while they are playing.
    private var topBar: some View {
        HStack(spacing: 10) {
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

    /// Every star in every built world.
    ///
    /// The count used to sit in a capsule at the top of the screen, and it counted whatever
    /// Play opened — the meadow's own stars until the meadow was held, then the universe's.
    /// It is a line on the Play button now, and it counts the whole game from the first
    /// star, so it never has to widen partway through and the button is where a player is
    /// already looking. How many there are altogether is left to the percentage beside it,
    /// which is the same question asked in the units a player actually thinks in.
    private var starsHeld: Int { Universe.all.totalStars(stars: progress.bestStars) }

    // MARK: - The name

    private var wordmark: some View {
        VStack(spacing: 16) {
            PlantedWord(word: "PIGPEN", size: 70, planted: planted)
                // Over the sign rather than under it, so the ropes can run up behind the
                // letters and be hidden by them instead of crossing the white.
                .zIndex(1)

            tagline
                .opacity(arrived ? 1 : 0)
                .scaleEffect(arrived ? 1 : 0.88)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pigpen. Build the perfect pen.")
    }

    /// A board hung under the name on a pair of short ropes, lit from above like the buttons
    /// are, with a nail head holding down each end of it and a rope tied off at each nail.
    ///
    /// It used to sit at a couple of degrees off level, which read as a board knocked
    /// crooked. Hung from the name instead, it wants to be straight: a sign on two ropes
    /// of the same length hangs level, and the ropes are what say it is hanging at all.
    private var tagline: some View {
        Text("Build the perfect pen")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 9)
            .padding(.horizontal, 26)
            .background(plank)
            .overlay(nailHeads)
            // Laid on above the board's top edge, into the gap the name leaves over it, so
            // hanging the sign costs the layout nothing.
            .overlay(alignment: .top) { ropes.offset(y: -Self.ropeLength) }
    }

    /// How far the ropes run up from the board. Longer than the gap the name leaves over it:
    /// the last few points go up behind the lettering, which is what makes the board read as
    /// hung from the name rather than as floating under it with two pegs above it.
    private static let ropeLength: CGFloat = 30

    /// The two ropes, one to each nail head, so a rope and the nail it is tied to stand in
    /// the same place along the board.
    private var ropes: some View {
        HStack(spacing: 0) {
            rope
            Spacer(minLength: 0)
            rope
        }
        .padding(.horizontal, 9)
    }

    private var rope: some View {
        Capsule(style: .continuous)
            .fill(GamePalette.rail)
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.35), lineWidth: 0.75)
            }
            .frame(width: 3.5, height: Self.ropeLength)
    }

    private var plank: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(GamePalette.signboard)
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
        VStack(spacing: 14) {
            Button {
                Haptics.tap(.medium)
                play()
            } label: {
                MenuRow(
                    icon: "play.fill",
                    title: "Play",
                    detail: playDetail,
                    tint: GamePalette.cream,
                    tally: playTally
                ) {
                    chevron
                }
            }
            .buttonStyle(MenuRowButtonStyle())
            .modifier(Breathing(active: !reduceMotion))
            .accessibilityLabel(playSpoken)

            dailyRow

            destinationRow(
                icon: "calendar",
                title: "Daily puzzle archive",
                detail: "See past puzzles",
                hint: "Every daily puzzle there has been, a month at a time"
            ) {
                isArchiveOpen = true
            }

        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// What Play has to say for itself under its own name: the world the button walks into.
    ///
    /// Always a world's own name, wherever the player has got to. Once the meadow is held Play
    /// opens the universe map rather than a trail, and the map settles on the frontier — so
    /// naming that world says where Play is about to put you, which *Worlds to fence* never
    /// did. How many puzzles the world holds used to be said here too, and the line below says
    /// more with the same room.
    private var playDetail: String {
        deepestWorld.theme.name
    }

    /// The furthest world open to the player: the first one not yet held, or the last stop
    /// there is once the whole chain has been. Worked out from the stars this screen already
    /// holds, the same way the tally above is — level ids are unique across worlds, so the
    /// meadow's store is every world's store.
    private var deepestWorld: UniverseWorld {
        let universe = Universe.all
        return universe[universe.frontier(stars: progress.bestStars)]
    }

    /// The line under that one: the stars in hand out of the stars there are, and how much of
    /// the whole game that adds up to. Two different questions — a star is a star, where the
    /// percentage counts the rainbow over each board as well — so both are worth saying.
    private var playTally: String {
        "\(starsHeld) star\(starsHeld == 1 ? "" : "s") earned · \(completion.percent)% complete"
    }

    /// Play read out in full, since the percent it wears sits in the row as a badge VoiceOver
    /// would otherwise read as a bare number.
    private var playSpoken: String {
        var said = "Play. \(playDetail)."
        said += " \(starsHeld) star\(starsHeld == 1 ? "" : "s") earned."
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
            open(today)
        } label: {
            MenuRow(
                icon: dailyIcon(stars: stars),
                title: "Today's puzzle",
                detail: dailyDetail(stars: stars, streak: streak),
                tint: GamePalette.cream,
                dimmed: !hasADailyPuzzle
            ) {
                // Every day with a board on it wears all three stars, the ones it has not
                // given up as outlines. A row that showed nothing until the first star was
                // won said nothing about what was on offer; three empties say there are
                // three to take, and the chevron the row used to keep here said only that
                // the row opens something, which is true of every row on the list.
                if hasADailyPuzzle {
                    StarRow(
                        stars: stars,
                        size: 12,
                        hasTheBestPen: daily.hasTheBestPen(on: today),
                        hollow: GamePalette.post.opacity(0.22)
                    )
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
            return "Today's puzzle. There is none — update Pigpen to get more daily puzzles."
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
    /// What day it is, and the run of days it is part of if there is one to keep.
    ///
    /// The row's own name says what it is now, so this line is free to be the date. Whether
    /// the day has been held is said by the seal on the token and by the stars at the other
    /// end of the row, which leaves the run of days as the one thing here with nowhere else
    /// to be said — and it is the thing a player comes back for.
    private func dailyDetail(stars: Int, streak: Int) -> String {
        guard hasADailyPuzzle else { return "None today — update Pigpen for more" }
        guard streak > 1 else { return today.written }
        return "\(today.written) · \(streak) days"
    }

    /// Opens a day's board, exactly as it was left.
    ///
    /// A day already held used to be a question first — put the submitted wall back, or clear
    /// the field and play it again — asked before the board had been seen. It is not asked
    /// any more. Tapping the day opens the day: the fencing that was standing when it was put
    /// away is laid back down, submitted wall and all, and the board itself carries both
    /// answers once it is up. *Restore* on the tally puts the best pen back the moment the
    /// field is somewhere else, and *Start over* clears it — either of which is a better
    /// place to choose than a dialog in front of a board the player has not looked at yet.
    ///
    /// It takes the day rather than assuming today's, since a tapped reminder can ask for
    /// the morning behind this one: a reminder posted at nine and read after midnight is
    /// about yesterday's board, and yesterday's board is what it should open.
    private func open(_ date: DailyDate) {
        Analytics.record(.dailyOpened(isToday: date == today))
        playingDaily = date
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

    /// How far the ends of the word drop below the middle of it, as a share of the letter
    /// size, and how far the outermost letter leans away from upright. Both are small on
    /// purpose: the name should read as painted along a gentle curve, the way a sign over a
    /// gate is, rather than as a semicircle of letters.
    private static let arcDrop = 0.11
    private static let arcLean = 5.0

    var body: some View {
        ZStack {
            // Two passes along the word, the whole white cut first and every letter after
            // it. One pass could not do it: laid down letter by letter, each keyline went
            // on top of the letter to its left — a keyline reaches further than the gap
            // between two letters — and took a bite of paint out of the P where the I's
            // white crossed it. Nothing white is drawn after any letter now.
            word { keyline(letters[$0]) }
            word { painted(letters[$0]) }
        }
        // Flattened before the shadow is thrown, and that is the whole point of it: a
        // shadow put on a stack is put on every letter in it, so each one cast its own and
        // the ones they threw across their neighbours showed up as seams inside a sticker
        // that is meant to read as one piece. Grouped first, the sky sees a single shape.
        .compositingGroup()
        // A soft grey under the whole name, rather than the name's own colour: the sticker
        // is lifted off the sky by a shadow, and a shadow is not pink. Mid grey rather than
        // black, which under a white keyline read as a smudge.
        .shadow(color: Color(white: 0.4).opacity(0.5), radius: 10, y: 8)
    }

    /// One pass along the word: each letter placed on the curve and carrying whatever it is
    /// this pass draws. Both passes lay their letters on exactly the same spots, because
    /// every placement here is worked out from the letter's index and nothing else.
    private func word<Letter: View>(
        @ViewBuilder _ content: @escaping (Int) -> Letter
    ) -> some View {
        HStack(spacing: letterSpacing) {
            ForEach(letters.indices, id: \.self) { index in
                let landed = landing(of: index)
                let settling = 1 - min(landed, 1)

                content(index)
                    .opacity(min(landed, 1))
                    // Clamped, like the opacity beside it. A letter's landing runs past 1
                    // — that is what staggers the run, each letter having the back half of
                    // it to itself — and scaling by the raw figure left every letter but
                    // the last resting bigger than the one after it: the P a third larger
                    // than the N, and the whole name tapering off to the right.
                    .scaleEffect(CGFloat(0.7 + 0.3 * min(landed, 1)))
                    // The arc rides on top of the drop-in: a letter still on its way in is
                    // leaning the way it always did, and comes to rest along the curve.
                    .rotationEffect(.degrees(lean(of: index) - 9 * settling))
                    .offset(y: drop(of: index) - size * 0.45 * CGFloat(settling))
            }
        }
    }

    /// Where a letter sits along the word, from -1 at the left end to 1 at the right.
    private func across(_ index: Int) -> Double {
        guard letters.count > 1 else { return 0 }
        return Double(index) / Double(letters.count - 1) * 2 - 1
    }

    /// How far down the curve carries a letter. The average drop is taken back off every
    /// letter, so the word keeps the middle of the space it is given however long it is —
    /// an arc that pushed its ends down would otherwise hang the whole name low.
    private func drop(of index: Int) -> CGFloat {
        let curve = across(index) * across(index)
        let average = letters.indices
            .map { across($0) * across($0) }
            .reduce(0, +) / Double(max(letters.count, 1))
        return size * CGFloat(Self.arcDrop * (curve - average))
    }

    /// A letter's lean: none in the middle of the word, most at either end, and away from
    /// the middle in both directions, so each one stands square to the curve it is on.
    private func lean(of index: Int) -> Double {
        Self.arcLean * across(index)
    }

    /// The white a letter is cut out on: the letter laid down all the way round itself, a
    /// full turn of copies, which is the outline of the letter grown outwards by the width
    /// of one. Four hard shadows did this in a quarter of the passes and left corners that
    /// read as melted, because nothing was ever laid on the diagonals.
    private func keyline(_ letter: Character) -> some View {
        ZStack {
            ForEach(0..<keylineTurns, id: \.self) { turn in
                let angle = 2 * Double.pi * Double(turn) / Double(keylineTurns)
                glyph(letter)
                    .foregroundStyle(.white)
                    .offset(x: outline * CGFloat(cos(angle)), y: outline * CGFloat(sin(angle)))
            }
        }
    }

    /// The letter itself: the glaze, flat. It wore a wash of light across the top and an
    /// edge shaded into its foot, the way the painted buttons do, and both are gone — a
    /// sticker is printed in one colour, and the keyline round it is what gives it its
    /// edge rather than a light source.
    private func painted(_ letter: Character) -> some View {
        glyph(letter)
            .foregroundStyle(GamePalette.clay)
    }

    /// How thick the keyline round each letter is.
    private var outline: CGFloat { size * 0.12 }

    /// How many copies of the letter go round to lay that keyline down. Enough that they
    /// land about a point and a half apart whatever the keyline is set to: a fixed count
    /// scallops the curves as soon as the line is thickened, since the copies spread out
    /// round a longer way round.
    private var keylineTurns: Int {
        min(32, max(12, Int((2 * Double.pi * outline / 1.5).rounded(.up))))
    }

    /// The gap between one letter and the next, and it has two jobs at once: the keylines
    /// either side of it have to overlap, so the white reads as one sticker cut out of the
    /// sky, while the letters inside that sticker have to stay clear of each other.
    ///
    /// Both hold across a fair range, because a keyline reaches a good deal further than
    /// this gap: two of them close over anything under about four points, and the letters
    /// keep their own side bearings on top of whatever is set here. This lands the tightest
    /// pair — the I against the G — around six points apart with the white still overlapping
    /// by eight. Tighter and the letters start to touch; wider and the sticker comes apart
    /// into six.
    private var letterSpacing: CGFloat { size * 0.02 }

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
/// its stars — every world, every level, every star and every rainbow, in one number, and the
/// word for what that number counts so it is not left to be guessed at.
///
/// It goes rainbow at a hundred, and only there. Three stars on every level in the game stops at
/// 75, so the badge sitting gold at 99 is the game saying there is a map somewhere still holding
/// its best pen back — which is the whole reason the number is on the button rather than buried
private struct MenuRow<Trailing: View>: View {
    let icon: String
    let title: String
    let detail: String
    /// The paint on the board. Every row on the list is painted the same cream now; Play
    /// used to be gold, and what marks it out instead is the slow breath it takes and the
    /// three lines it carries where the others have two.
    var tint: Color
    /// A row with nothing behind it — a day the almanac skips — is greyed down rather than
    /// dropped, so the list never changes height under a finger.
    var dimmed = false
    /// A third line under the detail, for the row that has a running total to carry. The
    /// star it opens with is painted gold rather than set in the line's own ink.
    var tally: String?
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
                    // Lower than the title's floor, because this is the line that runs long and
                    // the one a badge crowds. A sentence a size or two down still reads; one cut
                    // off mid-word does not, and there is no width at which cutting is the
                    // better of the two.
                    .minimumScaleFactor(0.6)

                if let tally {
                    // Set off from the line above rather than stacked straight onto it: the
                    // two above are a name and what it is, where this one is a running
                    // total, and reads as its own remark with a little air over it.
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(GamePalette.pen)
                            .shadow(color: GamePalette.post.opacity(0.25), radius: 0.5, y: 0.5)

                        Text(tally)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(GamePalette.post.opacity(0.62))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.top, 4)
                }
            }
            // The words take the slack themselves rather than leaving it to a Spacer. A Spacer
            // here is every bit as hungry as the text beside it, so the two split what is going
            // and the line came out clipped to "A universe of wo…" with the gap it wanted still
            // sitting empty to its right. Widening the column instead hands that gap to the
            // words, and only what they cannot use goes to holding the trailing end out.
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
        }
        .foregroundStyle(GamePalette.post)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
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
