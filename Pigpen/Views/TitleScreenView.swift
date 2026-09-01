import SwiftUI
import UIKit

/// The start screen: a pasture with a pig loose in it, a name that plants itself a letter at
/// a time like a run of fence, and a Play button that is impossible to miss.
///
/// Play walks into Mudlark Meadow until that world is held; only once the meadow boss is beaten
/// does it open the universe map. Under Play is the day's own board on a card of its own — what
/// day it is, what that day asks, and once it has been held, the stars it gave up, the time it
/// took and the run of days it is part of. Under that, the archive of every daily there has
/// been. The walkthrough is kept behind the gear for anybody who wants it back — and on a
/// first run it opens itself, so that a player meeting the game has been shown how to lay a
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
    /// The day whose submitted wall is being offered back, while that offer is up.
    @State private var offeringDaily: DailyDate?
    @State private var restoreSubmittedDaily = false
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
        .navigationDestination(item: $playingDaily) { date in
            DailyPuzzleView(
                date: date,
                progress: daily,
                restoreSubmitted: restoreSubmittedDaily
            )
        }
        .confirmationDialog(
            offeringDaily?.fullTitle ?? "",
            isPresented: Binding(
                get: { offeringDaily != nil },
                set: { if !$0 { offeringDaily = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Put it back") {
                guard let offeringDaily else { return }
                restoreSubmittedDaily = true
                playingDaily = offeringDaily
                self.offeringDaily = nil
            }
            Button("Play again") {
                guard let offeringDaily else { return }
                // Clear the field means clear the field: the board filed away when the day
                // was left is the submitted wall itself, so it has to go or *Play again*
                // opens on the very wall *Put it back* offers. The wall stays on the books
                // — the trophy still has it once the new field is somewhere else.
                daily.clearDraft(on: offeringDaily)
                restoreSubmittedDaily = false
                playingDaily = offeringDaily
                self.offeringDaily = nil
            }
            Button("Cancel", role: .cancel) { offeringDaily = nil }
        } message: {
            Text("Put the fencing back the way you submitted it, or clear the field and try again.")
        }
        .navigationDestination(isPresented: $isArchiveOpen) {
            DailyArchiveView(today: today, progress: daily, fullGame: fullGame)
                .onAppear { Analytics.record(.dailyArchiveOpened) }
        }
        .sheet(isPresented: $showsSettings) {
            SettingsView(
                progress: progress,
                daily: daily,
                reminder: reminder,
                fullGame: fullGame,
                onOpenTutorial: {
                    showsSettings = false
                    isTutorial = true
                }
            )
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
        VStack(spacing: 4) {
            PlantedWord(word: "PIGPEN", size: 62, planted: planted)

            tagline
                .opacity(arrived ? 1 : 0)
                .scaleEffect(arrived ? 1 : 0.88)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pigpen. Build the perfect pen.")
    }

    /// A board hung under the name on two short ropes, lit from above like the buttons are,
    /// with a peg at each end where the rope ties on.
    private var tagline: some View {
        Text("Build the perfect pen")
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 10)
            .padding(.horizontal, 28)
            .background(plank)
            .overlay(nailHeads)
            .overlay(alignment: .top) { ropes }
            .shadow(color: .black.opacity(0.3), radius: 5, y: 4)
    }

    private var plank: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(GamePalette.rail)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.28), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(GamePalette.post.opacity(0.35), lineWidth: 1.5)
            }
    }

    private var nailHeads: some View {
        HStack(spacing: 0) {
            nailHead
            Spacer(minLength: 0)
            nailHead
        }
        .padding(.horizontal, 12)
    }

    private var nailHead: some View {
        Circle()
            .fill(GamePalette.post.opacity(0.6))
            .frame(width: 6, height: 6)
    }

    /// Two short strings coming off the top of the plank, so the sign reads as hanging rather
    /// than as floating in the air on its own.
    private var ropes: some View {
        HStack(spacing: 0) {
            rope
            Spacer(minLength: 0)
            rope
        }
        .padding(.horizontal, 15)
        .frame(height: 18)
        .offset(y: -14)
    }

    private var rope: some View {
        Capsule()
            .fill(GamePalette.post.opacity(0.55))
            .frame(width: 2.5, height: 18)
    }

    // MARK: - The list of ways to play

    /// Every way off the title screen, painted on the one run of boards so they read as a
    /// list rather than as three buttons the game happened to leave lying about: Play at the
    /// head of it in cream, today's board under it in barn red, and the archive below that
    /// back on cream. Each is the same plank with the same press in it; only the paint and
    /// what stands on the right-hand end tell one from the next.
    private var playBlock: some View {
        VStack(spacing: 12) {
            Button {
                Haptics.tap(.medium)
                play()
            } label: {
                MenuRow(
                    icon: "play.fill",
                    title: "Play",
                    detail: "See where Pig goes next",
                    tint: GamePalette.cream,
                    trailing: { chevron },
                    footer: { playStats }
                )
            }
            .buttonStyle(MenuRowButtonStyle())
            .modifier(Breathing(active: !reduceMotion))
            .accessibilityLabel(playSpoken)

            dailyRow

            destinationRow(
                icon: "archivebox.fill",
                title: "Archive",
                detail: "See past puzzles",
                hint: "Every daily puzzle there has been, a month at a time"
            ) {
                isArchiveOpen = true
            }
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived ? 0 : 26)
    }

    /// The stars-and-completion line that sits inside the Play card, underneath its own
    /// title. It only appears once the player has something to show for themselves — a first
    /// run has nothing to say here and the card is left cleaner for it.
    @ViewBuilder
    private var playStats: some View {
        if tally > 0 || completion.percent > 0 {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(GamePalette.pen)
                    .shadow(color: GamePalette.post.opacity(0.25), radius: 0.5, y: 0.5)

                Text("\(tally) / \(starDenominator) stars")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(GamePalette.post.opacity(0.72))
                    .contentTransition(.numericText())

                if completion.percent > 0 {
                    Text("·")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(GamePalette.post.opacity(0.4))
                        .padding(.horizontal, 2)

                    completionText
                }
            }
            .padding(.leading, 53)
            .padding(.top, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)
        }
    }

    /// The percent-complete line inside Play's stats row: plain text on cream when the game
    /// is still going, and a rainbow wash the moment there is nothing left to take — the same
    /// mark the finished badge used to wear, kept for the one player who has finished
    /// everything.
    @ViewBuilder
    private var completionText: some View {
        let text = Text("\(completion.percent)% complete")
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText())
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)

        if completion.isEverything {
            text
                .foregroundStyle(GamePalette.post)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background {
                    Capsule()
                        .fill(.white.opacity(0.5))
                        .overlay {
                            RainbowWash()
                                .mask { Capsule() }
                                .opacity(0.8)
                        }
                }
                .overlay(Capsule().strokeBorder(GamePalette.post.opacity(0.2), lineWidth: 1))
        } else {
            text.foregroundStyle(GamePalette.post.opacity(0.72))
        }
    }

    /// How many stars there are to take in the ground the Play button opens: this world's
    /// count while the meadow is still being held, and every world's once Play widens to the
    /// universe map. Matches whatever `tally` is counting up towards.
    private var starDenominator: Int {
        progress.isTheWorldHeld ? Universe.all.starTotal : world.starTotal
    }

    /// Where Play walks into, said in a whole sentence for VoiceOver: this world by name while
    /// the meadow is still being held, and the universe map once it is. The row itself carries
    /// only "See where Pig goes next" now, which is fine on screen and no help spoken.
    private var playWhereItGoes: String {
        progress.isTheWorldHeld
            ? "The universe map — every world there is."
            : "\(world.name), \(world.count) puzzles."
    }

    /// Play read out in full: the row's own title, where it is going, and — from the stats line
    /// beneath — how many stars have been taken and how much of the game that is, since those
    /// sit inside the card as small print VoiceOver would otherwise read as bare numbers.
    private var playSpoken: String {
        var said = "Play. \(playWhereItGoes)"
        if tally > 0 {
            said += " \(tally) of \(starDenominator) stars taken."
        }
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

    /// Today's board, made to sit in the list as one more row on its own paint: the day named
    /// along the top, the date underneath, and on the right-hand end a badge that reads NEW!
    /// while the board is still to be pressed, and the stars it gave up once it has been.
    /// A day the almanac has nothing for is greyed down rather than left off, so the list
    /// never changes height under a finger.
    private var dailyRow: some View {
        let stars = daily.stars(on: today)
        let streak = daily.streak(upTo: today)
        return Button {
            Haptics.tap(.medium)
            open(today)
        } label: {
            MenuRow(
                icon: dailyIcon(stars: stars),
                title: hasADailyPuzzle ? "Today's puzzle" : "No puzzle today",
                detail: dailyDetail(stars: stars, streak: streak),
                tint: GamePalette.barn,
                titleColor: GamePalette.cream,
                detailColor: GamePalette.cream.opacity(0.85),
                iconColor: GamePalette.barn,
                dimmed: !hasADailyPuzzle,
                trailing: {
                    if stars > 0 {
                        StarRow(stars: stars, size: 12, hasTheBestPen: daily.hasTheBestPen(on: today))
                    } else if hasADailyPuzzle {
                        newBadge
                    } else {
                        chevron
                    }
                },
                footer: { EmptyView() }
            )
        }
        .buttonStyle(MenuRowButtonStyle())
        .disabled(!hasADailyPuzzle)
        .accessibilityLabel(dailySpoken(stars: stars, streak: streak))
    }

    /// The gold pill that marks today's board as unpressed. Pen-yellow on the barn-red row so
    /// it reads as the row's one call to attention, the way Play does at the top of the list.
    private var newBadge: some View {
        Text("NEW!")
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(GamePalette.post)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Capsule().fill(GamePalette.pen))
            .overlay(Capsule().strokeBorder(.white.opacity(0.55), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
    }

    /// The seal for a day that has been held, and a calendar leaf for one still waiting.
    private func dailyIcon(stars: Int) -> String {
        stars > 0 ? "checkmark.seal.fill" : "calendar"
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

    /// What sits under *Today's puzzle*: the date itself on a fresh day, and once it has been
    /// held whichever of the run of days or the best time is worth saying — the row's title is
    /// the standing headline now and the date has moved down here.
    private func dailyDetail(stars: Int, streak: Int) -> String {
        guard hasADailyPuzzle else { return "Update Pigpen to get more daily puzzles" }
        if stars > 0 {
            if streak > 1 { return "Penned · \(streak) days in a row" }
            if let best = daily.bestTime(on: today) {
                return "Penned · best \(Stopwatch.face(TimeInterval(best)))"
            }
            return "Penned — play it again"
        }
        return today.title
    }

    /// Opens a day's board, or — once a wall has been submitted — offers to put that wall
    /// back before the field comes up empty.
    ///
    /// It takes the day rather than assuming today's, since a tapped reminder can ask for
    /// the morning behind this one: a reminder posted at nine and read after midnight is
    /// about yesterday's board, and yesterday's board is what it should open.
    private func open(_ date: DailyDate) {
        Analytics.record(.dailyOpened(isToday: date == today))
        if daily.submittedFences(on: date) != nil {
            offeringDaily = date
        } else {
            restoreSubmittedDaily = false
            playingDaily = date
        }
    }

    /// A row that simply pushes another screen — the archive — cut from the same board as
    /// Play so the list stays one thing.
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
            MenuRow(
                icon: icon,
                title: title,
                detail: detail,
                tint: GamePalette.cream,
                trailing: { chevron },
                footer: { EmptyView() }
            )
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
        let stroke = size * 0.055
        return ZStack {
            // The cream outline: the same letter set eight times around the fill so the
            // stroke is even on every side. Text does not stroke on its own; this stack of
            // offsets is what makes the outline read as one.
            ForEach(0..<Self.strokeOffsets.count, id: \.self) { index in
                let offset = Self.strokeOffsets[index]
                glyph(letter)
                    .foregroundStyle(GamePalette.cream)
                    .offset(x: offset.x * stroke, y: offset.y * stroke)
            }

            // A small dark shadow underneath so the letter still reads as sitting on the
            // sky rather than floating over it.
            glyph(letter)
                .foregroundStyle(GamePalette.post.opacity(0.35))
                .offset(y: stroke * 0.6)

            glyph(letter)
                .foregroundStyle(GamePalette.barn)
        }
    }

    /// Eight directions around the compass, so the cream outline lies at the same thickness
    /// whichever way the glyph runs.
    private static let strokeOffsets: [CGPoint] = [
        CGPoint(x: 1, y: 0), CGPoint(x: -1, y: 0),
        CGPoint(x: 0, y: 1), CGPoint(x: 0, y: -1),
        CGPoint(x: 0.7, y: 0.7), CGPoint(x: -0.7, y: 0.7),
        CGPoint(x: 0.7, y: -0.7), CGPoint(x: -0.7, y: -0.7)
    ]

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

/// One board on the title screen's list of ways to play: a round token on the left with the
/// row's mark in it, the row's name and a line under it, and whatever the row keeps on its
/// right-hand end — a chevron for the ones that only open a screen, the day's stars for the
/// daily.
///
/// Every row is the same plank, lit from the top the way the fence rack and the signposts
/// are, so Play, today's board and the archive read as one list rather than as three unlike
/// buttons. The paint is the only thing that sets the head of the list apart: today's board
/// stands in barn red, the rest on cream.
private struct MenuRow<Trailing: View, Footer: View>: View {
    let icon: String
    let title: String
    let detail: String
    /// The paint on the board. Barn red marks today's board so it stands out among the cream
    /// rows either side of it.
    var tint: Color
    /// The colour the title reads in — cream on a barn-red row, post-brown on a cream one.
    var titleColor: Color = GamePalette.post
    /// The colour the line under it reads in. Left as nothing so the row picks the natural
    /// dim of its own title colour, and any caller who needs to override it can.
    var detailColor: Color? = nil
    /// The paint on the round token, so the mark reads as the tint of the plank rather than
    /// the pen-gold every other icon carries. Only barn-red rows override this so the seal
    /// on the token reads as belonging to the row's own paint.
    var iconColor: Color = GamePalette.post
    /// A row with nothing behind it — a day the almanac skips — is greyed down rather than
    /// dropped, so the list never changes height under a finger.
    var dimmed = false
    @ViewBuilder var trailing: () -> Trailing
    /// A second line inside the plank, sitting under the title/detail block. Play uses it for
    /// its stars and its per-cent-complete; everything else leaves it empty.
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 13) {
                token

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(titleColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(detail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(detailColor ?? titleColor.opacity(0.62))
                        .lineLimit(1)
                        // Lower than the title's floor, because this is the line that runs long
                        // and the one a badge crowds. A sentence a size or two down still reads;
                        // one cut off mid-word does not, and there is no width at which cutting
                        // is the better of the two.
                        .minimumScaleFactor(0.6)
                }
                // The words take the slack themselves rather than leaving it to a Spacer. A
                // Spacer here is every bit as hungry as the text beside it, so the two split
                // what is going and the line came out clipped to "A universe of wo…" with the
                // gap it wanted still sitting empty to its right. Widening the column instead
                // hands that gap to the words, and only what they cannot use goes to holding
                // the trailing end out.
                .frame(maxWidth: .infinity, alignment: .leading)

                trailing()
            }

            footer()
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
            .foregroundStyle(iconColor)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(GamePalette.cream)
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
