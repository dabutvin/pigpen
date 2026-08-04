#!/usr/bin/env python3
"""Draw the Pigpen app icon (a pig face) and write the asset catalog PNGs.

Usage:
    pip install cairosvg pillow
    python3 Tools/generate_app_icon.py

Writes AppIcon.png, AppIcon-Dark.png and AppIcon-Tinted.png into
Pigpen/Resources/Assets.xcassets/AppIcon.appiconset/.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path

import cairosvg
from PIL import Image

SIZE = 1024
# The face is drawn at a comfortable size and then grown to fill the tile, well
# inside the corners iOS rounds off.
ARTWORK_SCALE = 1.12
DEFAULT_OUTPUT = (
    Path(__file__).resolve().parents[1]
    / "Pigpen/Resources/Assets.xcassets/AppIcon.appiconset"
)


@dataclass(frozen=True)
class Palette:
    filename: str
    # None leaves the background transparent, which is what iOS wants for the
    # dark and tinted variants — the system draws its own backdrop behind them.
    background: tuple[str, str] | None
    head_top: str
    head_bottom: str
    ear: str
    ear_inner: str
    snout_top: str
    snout_bottom: str
    nostril: str
    eye: str
    blush: str
    blush_opacity: str


LIGHT = Palette(
    filename="AppIcon.png",
    background=("#1e243a", "#101422"),
    head_top="#fdbcd3",
    head_bottom="#ef8db0",
    ear="#f6a5c2",
    ear_inner="#dd7c9e",
    snout_top="#ef93b2",
    snout_bottom="#d9769a",
    nostril="#ab4f73",
    eye="#232841",
    blush="#ee6b95",
    blush_opacity="0.32",
)

DARK = Palette(
    filename="AppIcon-Dark.png",
    background=None,
    head_top="#f0a9c3",
    head_bottom="#d97ea2",
    ear="#e492b1",
    ear_inner="#c26e8f",
    snout_top="#e28fae",
    snout_bottom="#cd7291",
    nostril="#8e3d5d",
    eye="#1a1f33",
    blush="#dd5f88",
    blush_opacity="0.30",
)

# The tinted variant is recreated by iOS from luminance, so it is drawn in
# grayscale: light where the tint should read bright, dark where it should read
# deep.
TINTED = Palette(
    filename="AppIcon-Tinted.png",
    background=None,
    head_top="#f2f2f2",
    head_bottom="#c8c8c8",
    ear="#dcdcdc",
    ear_inner="#a8a8a8",
    snout_top="#d2d2d2",
    snout_bottom="#b0b0b0",
    nostril="#5a5a5a",
    eye="#3c3c3c",
    blush="#8c8c8c",
    blush_opacity="0.26",
)

PALETTES = (LIGHT, DARK, TINTED)


def svg(palette: Palette) -> str:
    if palette.background is None:
        background_gradient = ""
        background_rect = ""
    else:
        top, bottom = palette.background
        background_gradient = f"""
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{top}"/>
      <stop offset="1" stop-color="{bottom}"/>
    </linearGradient>"""
        background_rect = f'\n  <rect width="{SIZE}" height="{SIZE}" fill="url(#bg)"/>'

    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}">
  <defs>{background_gradient}
    <linearGradient id="head" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{palette.head_top}"/>
      <stop offset="1" stop-color="{palette.head_bottom}"/>
    </linearGradient>
    <linearGradient id="snout" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{palette.snout_top}"/>
      <stop offset="1" stop-color="{palette.snout_bottom}"/>
    </linearGradient>
  </defs>{background_rect}

  <g transform="translate(512 531) scale({ARTWORK_SCALE}) translate(-512 -531)">
    <!-- Ears. Squat triangles with round joins, drawn before the head so they
         tuck in behind it. -->
    <g stroke-linejoin="round">
      <polygon points="296,462 332,256 486,364" fill="{palette.ear}" stroke="{palette.ear}" stroke-width="62"/>
      <polygon points="728,462 692,256 538,364" fill="{palette.ear}" stroke="{palette.ear}" stroke-width="62"/>
      <polygon points="332,414 352,318 430,374" fill="{palette.ear_inner}" stroke="{palette.ear_inner}" stroke-width="42"/>
      <polygon points="692,414 672,318 594,374" fill="{palette.ear_inner}" stroke="{palette.ear_inner}" stroke-width="42"/>
    </g>

    <ellipse cx="512" cy="566" rx="302" ry="272" fill="url(#head)"/>

    <ellipse cx="290" cy="642" rx="52" ry="34" fill="{palette.blush}" opacity="{palette.blush_opacity}"/>
    <ellipse cx="734" cy="642" rx="52" ry="34" fill="{palette.blush}" opacity="{palette.blush_opacity}"/>

    <g fill="{palette.eye}">
      <circle cx="392" cy="506" r="44"/>
      <circle cx="632" cy="506" r="44"/>
    </g>
    <g fill="#ffffff" opacity="0.9">
      <circle cx="377" cy="491" r="14"/>
      <circle cx="617" cy="491" r="14"/>
    </g>

    <ellipse cx="512" cy="672" rx="150" ry="112" fill="url(#snout)"/>
    <g fill="{palette.nostril}">
      <ellipse cx="468" cy="674" rx="24" ry="32"/>
      <ellipse cx="556" cy="674" rx="24" ry="32"/>
    </g>
  </g>
</svg>
"""


def render(palette: Palette, output_dir: Path) -> Path:
    destination = output_dir / palette.filename
    png = cairosvg.svg2png(
        bytestring=svg(palette).encode(),
        output_width=SIZE,
        output_height=SIZE,
    )
    if palette.background is None:
        destination.write_bytes(png)
    else:
        # App Store validation rejects an alpha channel on the primary icon.
        Image.open(BytesIO(png)).convert("RGB").save(destination)
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="directory to write the PNGs into",
    )
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    for palette in PALETTES:
        print(f"wrote {render(palette, args.out)}")


if __name__ == "__main__":
    main()
