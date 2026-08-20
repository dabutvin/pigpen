import SwiftUI

/// The projection room: every film in the game played one after another, with the world and the
/// running order in one corner and the same **Skip** the films have always had in the other.
///
/// The one thing that changes about Skip in here is what it means. Where the game plays a film,
/// Skip is a way out of it and back to whatever was waiting; on the reel there is nothing waiting
/// but the next film, so Skip is what moves the reel on — the whole story leafed through at
/// whatever pace the player wants, a press at a time. The way out of the reel itself is the cross
/// in the other corner, so leaving and moving on cannot be confused for one another.
///
/// The whole glass works the reel as well: a tap anywhere moves it on, a swipe back takes it to
/// the film before, and a swipe on is the same as a tap. Where the game plays a film that would
/// be wrong — an opening worth watching should not be lost to a thumb resting on the screen, which
/// is why those have a button and nothing else — but a player who has come in here to leaf through
/// three dozen films is doing it deliberately, and asking them to find a button in the corner
/// thirty-six times is asking too much. The films themselves are untouched: the glass belongs to
/// the reel.
///
/// Neither the reel nor anything on it touches what the game remembers. A film watched in here is
/// not a film the world has played, so a player who leafs ahead is still shown the opening when
/// they reach the world it belongs to — and nothing on the reel goes on the charts, since a
/// player rattling down three dozen films is not answering the question the counting asks.
@MainActor
struct FilmReelView: View {
    @Environment(\.dismiss) private var dismiss

    let reel: FilmReel

    /// Which film of the reel is up.
    @State private var index = 0
    /// The film itself, raised — and so its clock started — as it goes up rather than when the
    /// reel was put together. Held in state so a redraw does not start it again.
    @State private var playing: WorldFilm?
    /// How many times the curtain has gone up, which is what the film on screen is named by.
    ///
    /// Counted rather than named after the film because the same film can come up twice running —
    /// a swipe back off the first one rewinds it — and a screen that kept the old name would leave
    /// the first showing's clock running under the second one rather than starting it again.
    @State private var take = 0

    init(reel: FilmReel = .everything) {
        self.reel = reel
    }

    var body: some View {
        GeometryReader { proxy in
            let bar = proxy.size.height * FilmBars.fraction

            ZStack {
                // Under everything, so the beat between one film and the next is black rather
                // than whatever was behind the screen.
                Color.black

                if let playing {
                    // Named by the take rather than the film, so every raising of the curtain is
                    // a fresh clock — one storybook still handing on to another, and a film
                    // rewound onto itself, alike.
                    WorldFilmView(film: playing, counted: false) { advance() }
                        .id(take)
                }

                // Over the film and under the reel's own controls: the cross and the billing keep
                // their presses, and the film's Skip gives its up to the glass, which does the
                // very same thing to the very same film.
                glass

                billing(under: bar, across: proxy.size.width)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            // An empty reel is nothing to sit through. It cannot happen on the shipped map, and
            // a screen that hangs on black if it ever did would be worse than a screen that
            // simply closes.
            guard playing == nil else { return }
            guard reel.billing(at: index) != nil else {
                dismiss()
                return
            }
            raise()
        }
    }

    /// The film on screen, for the billing over it.
    private var now: FilmReel.Billing? { reel.billing(at: index) }

    /// The reel worked by hand: tap on, swipe back, swipe on.
    ///
    /// A sheet of nothing over the picture, which is the whole trick — the film underneath is
    /// painted by the same views that play it in the game, and neither of them has ever had to
    /// know it is being leafed through.
    ///
    /// One recogniser rather than a tap and a swipe arguing over the same finger, the way the
    /// board reads a press: what the touch did is worked out when it is lifted. A press that
    /// stayed put is a tap; one that travelled sideways is a swipe; anything in between is a
    /// wobble rather than a decision, and is left alone — as is a finger dragged down the shot,
    /// since a picture should not be taken away by a hand that was not asking for that.
    ///
    /// Hidden from a screen read aloud: there is nothing here to describe, and the billing
    /// carries the same two moves as actions for anybody who cannot make the gestures.
    private var glass: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { touch in
                        let across = touch.translation.width
                        let down = touch.translation.height

                        if max(abs(across), abs(down)) < Self.stillEnoughForATap {
                            moveOn()
                            return
                        }

                        guard abs(across) > abs(down), abs(across) > Self.farEnoughForASwipe else {
                            return
                        }
                        if across > 0 { moveBack() } else { moveOn() }
                    }
            )
            .accessibilityHidden(true)
    }

    /// How far a finger may wander and still have been a tap, and how far it has to travel
    /// before it was a swipe. Nothing between the two counts: a touch that went further than a
    /// press but not as far as a swipe is a player who has not decided anything.
    private static let stillEnoughForATap: CGFloat = 12
    private static let farEnoughForASwipe: CGFloat = 60

    // MARK: - Over the picture

    /// Which film this is and where it comes in the reel, opposite the Skip and clear of the top
    /// bar the same way. It is what turns three dozen films end to end into something a player
    /// can find their place in — and the cross beside it is the way out of the whole reel, which
    /// Skip deliberately is not.
    @ViewBuilder
    private func billing(under bar: CGFloat, across width: CGFloat) -> some View {
        if let now {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Button {
                        Haptics.tap(.light)
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(GamePalette.post)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(GamePalette.cream.opacity(0.94)))
                    }
                    .accessibilityLabel("Close")

                    VStack(alignment: .leading, spacing: 1) {
                        Text(now.title)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(GamePalette.post)

                        Text("\(index + 1) of \(reel.count)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(GamePalette.post.opacity(0.6))
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    // Half the glass at the most, so the longest world name in the game cannot
                    // grow across the screen and shoulder the Skip out of its corner.
                    .frame(maxWidth: width * 0.5, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule().fill(GamePalette.cream.opacity(0.94))
                    )
                    .overlay(
                        Capsule().strokeBorder(GamePalette.post.opacity(0.18), lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(now.title), film \(index + 1) of \(reel.count)")
                    // What the tap and the swipe do, for a player who cannot make either. The
                    // Skip in the other corner is the same move as the first of them; this is
                    // the only way back there is.
                    .accessibilityAction(named: "Next cut scene") { advance() }
                    .accessibilityAction(named: "Previous cut scene") { back() }

                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            // Below the top bar, so it sits on the picture rather than in the letterbox — the
            // same place the Skip sits on the other side.
            .padding(.top, bar + 16)
        }
    }

    // MARK: - The running order

    /// The next film, or the end of the reel. Reached every way a film can end: watched out,
    /// skipped, tapped past or swiped on.
    private func advance() {
        guard let next = reel.onward(from: index) else {
            dismiss()
            return
        }
        index = next
        raise()
    }

    /// The film before this one, or this one over again at the head of the reel. Always raises
    /// something, so a swipe back is always answered.
    private func back() {
        index = reel.backward(from: index)
        raise()
    }

    /// The reel moved on by a hand rather than by a film running out, which is why it buzzes: a
    /// move the player made should be felt, where one the reel made itself should not.
    private func moveOn() {
        Haptics.tap(.light)
        advance()
    }

    /// The same, backwards.
    private func moveBack() {
        Haptics.tap(.light)
        back()
    }

    /// The curtain up on whichever film the reel is standing on, on a take of its own.
    private func raise() {
        take += 1
        playing = now?.raise()
    }
}

#Preview("The whole reel") {
    FilmReelView()
}

#Preview("One world") {
    FilmReelView(reel: FilmReel(billings: FilmReel.billings(of: .mudlarkMeadow)))
}
