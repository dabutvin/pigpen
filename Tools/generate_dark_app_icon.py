#!/usr/bin/env python3
"""Draw the dark app icon from the painted one: the field at night, the pig still lit.

The dark tile used to be the whole painting turned down, pig and all, which left a
grey pig on a grey field — the tile read as the icon with the lights off rather than
as its own thing. This takes the painted `AppIcon.png`, cuts the pig out of it by
colour, and treats the two halves differently: the field behind goes to night, deep
and blue, and the pig keeps the light it was painted with, with a little of that
light spilling onto the field around it.

Usage:
    pip install pillow
    python3 Tools/generate_dark_app_icon.py

Reads AppIcon.png and writes AppIcon-Dark.png, both in
Pigpen/Resources/Assets.xcassets/AppIcon.appiconset/.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ICON_DIR = (
    Path(__file__).resolve().parents[1]
    / "Pigpen/Resources/Assets.xcassets/AppIcon.appiconset"
)
SOURCE = "AppIcon.png"
DESTINATION = "AppIcon-Dark.png"

# Cutting the pig out. The pig is the one pink thing in the tile, so red-minus-green
# finds it — but the fence rail is warm too, and it touches the pig's cheek, so a
# single threshold hands back the fence along with the animal. Two rules keep them
# apart: anything properly pink is the pig, and anything faintly pink is the pig only
# if it is also bright, which the painted-in-shadow fence never is.
PINK = 55  # red-minus-green that is pig whatever its brightness (ears, snout, edges)
FAINT_PINK = 26  # the palest the forehead's highlight gets
LIT = 200  # ...and it is only pig if the red channel is at least this bright
SEED = (512, 600)  # a point inside the pig, for the flood fill that picks its shape

# Night. The field is dimmed hard and then carried towards a deep blue, so it reads
# as dusk rather than as an underexposed meadow.
NIGHT_LEVEL = 0.30
NIGHT_COLOR = (22, 31, 60)
NIGHT_TINT = 0.42

# The light on the pig. It keeps nearly all of what it was painted with; the sliver
# taken off stops it glaring against the night behind it.
PIG_LEVEL = 0.97

# The spill. The pig's shape, blurred wide, lifts the field nearest it a little, so
# the animal sits in the field instead of on top of it.
SPILL_RADIUS = 90
SPILL_STRENGTH = 0.34
SPILL_COLOR = (92, 74, 104)

EDGE_SOFTNESS = 3  # blur on the cut edge, in pixels


def pig_mask(source: Image.Image) -> Image.Image:
    """Return a soft mask, white over the pig and black over the field behind it."""
    red, green, _ = source.split()
    warmth = ImageChops.subtract(red, green)

    pink = warmth.point(lambda v: 255 if v >= PINK else 0)
    faint = ImageChops.darker(
        warmth.point(lambda v: 255 if v >= FAINT_PINK else 0),
        red.point(lambda v: 255 if v >= LIT else 0),
    )
    mask = ImageChops.lighter(pink, faint)

    # Close the speckle the painting's texture leaves along the edges.
    mask = mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))

    # Keep only the patch the seed sits in: the flowers and the sun are warm in
    # places too, and they are nothing to do with the pig.
    ImageDraw.floodfill(mask, SEED, 128, thresh=10)
    mask = mask.point(lambda v: 255 if v == 128 else 0)

    # The eyes and the nostrils are not pink, so they come back as holes. Anything
    # enclosed by the pig is the pig: flood the outside in, and keep what it missed.
    outside = mask.point(lambda v: 0 if v else 255)
    for corner in ((0, 0), (mask.width - 1, 0), (0, mask.height - 1),
                   (mask.width - 1, mask.height - 1)):
        ImageDraw.floodfill(outside, corner, 128, thresh=10)
    mask = ImageChops.lighter(mask, outside.point(lambda v: 255 if v == 255 else 0))

    # Sit the edge a whisker outside the silhouette and soften it, so the cut reads
    # as the light falling off rather than as a line.
    mask = mask.filter(ImageFilter.MaxFilter(5))
    return mask.filter(ImageFilter.GaussianBlur(EDGE_SOFTNESS))


def dim(image: Image.Image, level: float) -> Image.Image:
    return image.point(lambda v: round(v * level))


def tint(image: Image.Image, color: tuple[int, int, int], amount: float) -> Image.Image:
    return Image.blend(image, Image.new("RGB", image.size, color), amount)


def darken(source: Image.Image) -> Image.Image:
    mask = pig_mask(source)

    night = tint(dim(source, NIGHT_LEVEL), NIGHT_COLOR, NIGHT_TINT)
    spill = mask.filter(ImageFilter.GaussianBlur(SPILL_RADIUS)).point(
        lambda v: round(v * SPILL_STRENGTH)
    )
    night = Image.composite(Image.new("RGB", source.size, SPILL_COLOR), night, spill)

    pig = dim(source, PIG_LEVEL)
    return Image.composite(pig, night, mask)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dir",
        type=Path,
        default=ICON_DIR,
        help="directory holding the icon tiles",
    )
    args = parser.parse_args()

    source = Image.open(args.dir / SOURCE).convert("RGB")
    destination = args.dir / DESTINATION
    # No alpha channel: the tile carries its own night sky rather than leaning on
    # whatever iOS would draw behind a transparent one.
    darken(source).save(destination)
    print(f"wrote {destination}")


if __name__ == "__main__":
    main()
