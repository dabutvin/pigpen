#!/usr/bin/env python3
"""Reads the board's recording and says where its moments really are.

The reel plays on a fixed clock and writes down the second of the film it asked for each
noise at. The simulator's recorder does not keep up with that clock on a busy runner: it
says it has started a little before its first frame is taken, and under the load of the
rainbow wash and the confetti it falls further behind, so a piece is seen a tenth of a
second or half a second after it was knocked in, three quick knocks can land in one
frame, and the card with three stars on it comes up most of a second late. None of that
is visible in the app; all of it is in the recording, which is what the spot is cut from.

So the cut follows the picture. This looks at the recording around each moment the reel
wrote down and finds the frame where it is actually seen — a piece going in is a burst
of changed pixels on a board that is otherwise still, and the card coming up is the
biggest change of all — and prints, for Tools/cut_spot.sh:

    ORIGIN <seconds>     where in the recording the reading started, which is where
                         the cut has to start reading too: the recorder stamps its
                         frames in clumps, and where a steady rate is taken from
                         changes where everything after it lands
    SKIP <seconds>       how far into the steady stream from there the film starts,
                         so that the first piece is seen at the second the reel
                         knocked it in
    BOARD <seconds>      how long the board runs: the reel's length, or longer if the
                         card came up late and wants its time on screen
    SOUND <file> <sec>   every noise the board makes, at the second of the film its
                         picture is seen — a knock on the frame its piece appears, the
                         lap's hop and fanfare shifted by however late the card was

Usage: sync_board.py RAW.MOV APP.LOG INTO
"""

from __future__ import annotations

import subprocess
import sys

WIDTH, HEIGHT = 132, 286
FPS = 30
# A frame counts as changed when this many of its pixels moved by more than a shade.
# A piece going in on a 6.9-inch phone moves about PIECE of them at this size; a still
# board, encoded, moves a dozen at most; the card coming up moves thousands. A frame
# that moved two or three pieces' worth is two or three knocks the recorder caught at once.
KNOCK = 80
PIECE = 200
CARD = 1500
# How long the card with three stars on it is held before the cut.
CARD_HOLD = 0.75


def changes(path: str, origin: float, seconds: float) -> list[tuple[float, int]]:
    """(seconds since ORIGIN in the steady stream, pixels changed since the frame before)."""
    # Trimmed on the recording's own timestamps from ORIGIN and only then brought to a
    # steady rate. The recorder stamps its frames in clumps, so where the steady rate is
    # taken from changes where everything after it lands, by whole fractions of a second:
    # the cut has to read the recording from the very same place, and does.
    out = subprocess.run(
        ["ffmpeg", "-hide_banner", "-loglevel", "error", "-nostats", "-i", path,
         "-vf", f"trim=start={origin:.3f}:end={origin + seconds:.3f},setpts=PTS-STARTPTS,fps={FPS},"
                f"scale={WIDTH}:{HEIGHT},format=gray",
         "-f", "rawvideo", "-"],
        check=True, capture_output=True).stdout
    n = WIDTH * HEIGHT
    frames = [out[i * n:(i + 1) * n] for i in range(len(out) // n)]
    rows = []
    for i in range(1, len(frames)):
        moved = sum(1 for a, b in zip(frames[i], frames[i - 1]) if abs(a - b) > 24)
        rows.append((i / FPS, moved))
    return rows


def main() -> None:
    raw, log, into = sys.argv[1], sys.argv[2], float(sys.argv[3])
    length = None
    sounds: list[tuple[str, float]] = []
    for line in open(log):
        parts = line.split()
        if len(parts) >= 3 and parts[0] == "SPOT_REEL_START":
            length = float(parts[2])
        elif len(parts) == 3 and parts[0] == "SPOT_REEL_SOUND" and float(parts[2]) >= 0:
            sounds.append((parts[1], float(parts[2])))
    if length is None:
        sys.exit("the reel never said how long its film is")

    knocks = [t for name, t in sounds if name == "fence-in"]
    after = [(name, t) for name, t in sounds if name != "fence-in"]
    card = next((t for name, t in sounds if name.startswith("held-")), None)

    # One reading of the recording, from a little before where the clocks put the first
    # knock to well after the card. Everything below is in seconds since that origin.
    first = knocks[0] if knocks else 0.0
    origin = max(0.0, round(into + first - 0.6, 3))
    rows = changes(raw, origin, (card if card is not None else length) - first + 3.0)
    # Where the clocks say the film starts, in that stream.
    skip = into - origin

    def seen(after_t: float, threshold: int) -> float | None:
        """The first frame at or after a moment that changed enough."""
        return next((t for t, moved in rows if t >= after_t - 1 / FPS and moved >= threshold), None)

    # Knocks: the film's start is moved so the first piece is seen at the second it was
    # knocked in, and then each changed frame from there is as many knocks as pieces'
    # worth of pixels it moved — so three knocks the recorder caught in one frame are
    # all played on it — until every knock has a frame. Knocks the recording never
    # shows go on the last frame that showed one.
    placed: list[tuple[str, float]] = []
    if knocks:
        start_seen = seen(skip + first, KNOCK)
        if start_seen is not None:
            print(f"the first piece is seen {start_seen - (skip + first):+.3f}s from where the clocks put it", file=sys.stderr)
            skip = start_seen - first
        left = len(knocks)
        last_frame = skip + first
        for t, moved in rows:
            if left == 0:
                break
            if t < skip + first - 1 / FPS or moved < KNOCK:
                continue
            count = min(left, max(1, round(moved / PIECE)))
            placed.extend(("fence-in", round(t - skip, 3)) for _ in range(count))
            left -= count
            last_frame = t
        placed.extend(("fence-in", round(last_frame - skip, 3)) for _ in range(left))

    # The card: the biggest change after the lap. The recording's clock wobbles either
    # way against the reel's by a quarter second or so — it is not simply behind — so
    # the fanfare goes where the card is seen, the lap's hop keeps its distance ahead of
    # it, and the board runs until the card has had its time, however late that is.
    late = 0.0
    if card is not None:
        frame = seen(skip + card - 0.4, CARD)
        if frame is not None:
            late = frame - skip - card
            print(f"the card is seen {late:+.3f}s from where the reel put it", file=sys.stderr)
    for name, t in after:
        placed.append((name, round(t + late, 3)))
    board = max(length, (card + late + CARD_HOLD) if card is not None else length)

    print(f"ORIGIN {origin:.3f}")
    print(f"SKIP {max(0.0, skip):.3f}")
    print(f"BOARD {board:.3f}")
    for name, t in placed:
        print(f"SOUND {name} {t:.3f}")


if __name__ == "__main__":
    main()
