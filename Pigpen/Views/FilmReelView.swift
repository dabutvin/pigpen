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
                    // Named by the film, so one storybook still handing on to another swaps the
                    // screen rather than leaving the first one's clock running under the second
                    // one's script.
                    WorldFilmView(film: playing, counted: false) { advance() }
                        .id(playing.key)
                }

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

    /// The next film, or the end of the reel. Reached both ways a film can end: watched out, or
    /// skipped — which is what makes Skip the button that moves the reel on.
    private func advance() {
        guard reel.billing(at: index + 1) != nil else {
            dismiss()
            return
        }
        index += 1
        raise()
    }

    /// The curtain up on whichever film the reel is standing on.
    private func raise() {
        playing = now?.raise()
    }
}

#Preview("The whole reel") {
    FilmReelView()
}

#Preview("One world") {
    FilmReelView(reel: FilmReel(billings: FilmReel.billings(of: .mudlarkMeadow)))
}
