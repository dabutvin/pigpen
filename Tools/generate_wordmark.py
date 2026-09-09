#!/usr/bin/env python3
"""Draw the PIGPEN wordmark the title screen wears, and write it as a PNG for the website.

The name on the home screen is not an image in the app — `PlantedWord` in
`Pigpen/Views/TitleScreenView.swift` builds it out of live text: SF Pro Rounded at black
weight, every letter set along a gentle arc and leaning off the middle of the word, laid
down twice so that one white keyline is cut round the whole name rather than round each
letter. The website cannot draw it that way, because SF Pro Rounded is on Apple's
machines and not on everybody's, so the same drawing is done here in a browser on a Mac
— where the font is — and photographed.

Every number below is `PlantedWord`'s own, written as a share of the letter size the way
it writes them, so changing the wordmark in the app is a matter of copying the figures
across. The word is drawn at rest: `planted` is 1 on the title screen once the letters
have come down, and at 1 nothing is scaled, faded or still falling.

Usage:
    python3 Tools/generate_wordmark.py

Writes site/img/wordmark.png, transparent, ready to hang on any background.
"""

from __future__ import annotations

import argparse
import math
import subprocess
import tempfile
from pathlib import Path

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "site/img/wordmark.png"

WORD = "PIGPEN"
# The letter size the page is drawn at. The app sets 70pt; this is the same drawing blown
# up, so that the PNG still has pixels to spare on a wide screen at twice the density.
SIZE = 260

# PlantedWord's proportions, each one a share of the letter size.
OUTLINE = 0.12
LETTER_SPACING = 0.02
ARC_DROP = 0.11
ARC_LEAN = 5.0
# How many white copies go round to lay the keyline down: PlantedWord's own rule, enough
# that they land about a point and a half apart, and without the ceiling of 32 it puts on
# top. That ceiling is there to keep a phone from drawing hundreds of live text views; this
# runs once on a Mac, and at the size below 32 copies leave the cut visibly scalloped.

# GamePalette.clay, the one colour a sticker is printed in.
CLAY = "#d18669"
# `.shadow(color: Color(white: 0.4).opacity(0.5), radius: 10, y: 8)` at 70pt. SwiftUI's
# radius is twice the blur's standard deviation, which is what CSS calls its blur, so the
# figure carries across unchanged — and all three grow with the letters.
SHADOW = (0.4 * 100, 10 / 70, 8 / 70)


KEYLINE_TURNS = math.ceil(2 * math.pi * SIZE * OUTLINE / 1.5)


def across(index: int, count: int) -> float:
    """Where a letter sits along the word, from -1 at the left end to 1 at the right."""
    if count < 2:
        return 0.0
    return index / (count - 1) * 2 - 1


def drop(index: int, count: int) -> float:
    """How far down the arc carries a letter, in points, its average taken back off."""
    average = sum(across(i, count) ** 2 for i in range(count)) / count
    return SIZE * ARC_DROP * (across(index, count) ** 2 - average)


def lean(index: int, count: int) -> float:
    """A letter's lean in degrees: none in the middle, most at either end."""
    return ARC_LEAN * across(index, count)


def page(word: str) -> str:
    """The word as one line of HTML, drawn twice: the whole white cut, then every letter.

    Two passes rather than one for the reason the app gives — a keyline laid down letter
    by letter reaches past the gap to its neighbour and takes a bite out of it. The white
    is made the app's way as well, a full turn of white copies of the letter rather than
    a stroke round it: a stroke joins its corners with a mitre and leaves spikes off the
    points of the N and the E, where a ring of copies leaves the rounded cut a sticker has.
    """
    letters = []
    for index, letter in enumerate(word):
        style = (
            f"transform: rotate({lean(index, len(word)):.3f}deg) "
            f"translateY({drop(index, len(word)):.3f}px)"
        )
        letters.append(f'<span style="{style}">{letter}</span>')
    run = "".join(letters)
    keyline = ", ".join(
        f"{SIZE * OUTLINE * math.cos(2 * math.pi * turn / KEYLINE_TURNS):.2f}px "
        f"{SIZE * OUTLINE * math.sin(2 * math.pi * turn / KEYLINE_TURNS):.2f}px #fff"
        for turn in range(KEYLINE_TURNS)
    )

    grey, blur, down = SHADOW
    return f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
  html, body {{ margin: 0; background: transparent; }}
  .mark {{
    position: relative;
    display: inline-block;
    padding: {SIZE * 0.5:.0f}px;
    filter: drop-shadow(0 {SIZE * down:.2f}px {SIZE * blur:.2f}px
                        rgba({grey:.0f}%, {grey:.0f}%, {grey:.0f}%, 0.5));
  }}
  .pass {{
    display: flex;
    letter-spacing: 0;
    font: 900 {SIZE}px ui-rounded, "SF Pro Rounded", -apple-system, sans-serif;
    line-height: 1;
    white-space: pre;
  }}
  .pass span {{ margin-right: {SIZE * LETTER_SPACING:.2f}px; }}
  .pass span:last-child {{ margin-right: 0; }}
  .keyline {{
    position: absolute;
    inset: {SIZE * 0.5:.0f}px;
    color: #fff;
    text-shadow: {keyline};
  }}
  .painted {{ color: {CLAY}; }}
</style></head><body>
<div class="mark"><div class="pass keyline">{run}</div><div class="pass painted">{run}</div></div>
</body></html>
"""


def shoot(html: Path, out: Path) -> None:
    """Photograph the page on a transparent ground and trim it to what was drawn."""
    subprocess.run(
        [
            CHROME,
            "--headless=new",
            "--disable-gpu",
            "--hide-scrollbars",
            "--force-device-scale-factor=1",
            "--default-background-color=00000000",
            f"--screenshot={out}",
            f"--window-size={SIZE * len(WORD)},{SIZE * 3}",
            str(html),
        ],
        check=True,
        capture_output=True,
    )
    subprocess.run(
        ["magick", str(out), "-trim", "+repage", str(out)], check=True
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as scratch:
        html = Path(scratch) / "wordmark.html"
        html.write_text(page(WORD))
        shoot(html, args.output)
    print(f"wrote {args.output}")


if __name__ == "__main__":
    main()
