#!/usr/bin/env python3
"""Frames a raw app screenshot into a captioned App Store marketing image.

The store lets you upload a bare screenshot, but a bare screenshot sells nothing:
the shots that convert carry a line of copy above them and stand the phone on a
background rather than filling the frame edge to edge. This does that, once per
shot — a cozy pasture gradient, the caption in the game's own brown, and the
screenshot floated in the lower two-thirds with rounded corners and a soft
shadow, the way a phone sits on a table.

It keeps the canvas the exact size of the shot it is handed, so a screenshot
captured on the simulator App Review actually asks for — iPhone 6.9 inch at
1320x2868, iPad 13 inch at 2064x2752 — comes out framed at the very size the
store wants back. The output is flattened to RGB, since App Store screenshots
carry no alpha.

    python3 Tools/appstore_frames.py \\
        --input raw/iphone_title.png \\
        --output framed/iphone_1_title.png \\
        --caption "A cozy pig puzzle"

The workflow in .github/workflows/appstore-assets.yml drives it over every shot;
run it by hand to re-frame one, or to try a caption on for size.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

# The game's own colours, out of GamePalette, so the frame and the screen inside
# it are painted from one tin. RGB, since that is what Pillow wants.
CREAM = (252, 242, 222)
POST = (69, 43, 26)
# The ground the phone stands on, in three stops rather than two: warm cream light
# at the head of the tile, a pale field through the middle, and a muted sage at the
# foot. The green it used to end on was a lit meadow green, and against the game's
# own creams it read as poster paint — a colour from a different tin than anything
# in the screenshot standing on it. This one is the same pasture with the light off
# it, which is what lets the shot be the brightest thing in its own frame.
SKY = (250, 246, 236)
FIELD = (229, 234, 213)
MEADOW = (179, 199, 163)
# The pool of light the phone stands in, and the warm dark that closes the corners.
GLOW = (255, 253, 246)
SHADE = (86, 66, 43)

# Where to look for a bold, rounded face. SF Pro Rounded first, since that is the
# font the game itself sets its wordmark in, then whatever the machine has, then
# Pillow's own last-resort bitmap so the tool never dies for want of a typeface.
FONT_CANDIDATES = [
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/SFCompactRounded.ttf",
    "/Library/Fonts/Arial Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def load_font(size: int) -> ImageFont.FreeTypeFont:
    """A bold rounded face at the asked size, from the first candidate that loads.

    Apple's system fonts ship as variable faces whose default cut is a regular
    weight, so where the file offers a heavier named instance we take it — a
    caption wants to be heavy — and shrug off any file that does not.
    """
    for path in FONT_CANDIDATES:
        if not Path(path).exists():
            continue
        try:
            font = ImageFont.truetype(path, size)
        except OSError:
            continue
        for weight in ("Black", "Heavy", "Bold"):
            try:
                font.set_variation_by_name(weight)
                break
            except (OSError, ValueError, AttributeError):
                continue
        return font
    return ImageFont.load_default(size)


def gradient(width: int, height: int, stops: list) -> Image.Image:
    """A vertical wash through a run of colours, the pasture behind the phone.

    Eased rather than ruled straight: a linear ramp between two colours has a visible
    kink where it starts and where it stops, and the eye finds both. Each step is
    softened at either end, and the whole thing is drawn one pixel wide and stretched,
    which is the same picture for a fraction of the work.
    """
    strip = Image.new("RGB", (1, height))
    px = strip.load()
    spans = len(stops) - 1
    for y in range(height):
        t = y / max(height - 1, 1)
        span = min(int(t * spans), spans - 1)
        u = t * spans - span
        u = u * u * (3 - 2 * u)
        lo, hi = stops[span], stops[span + 1]
        px[0, y] = tuple(round(lo[i] + (hi[i] - lo[i]) * u) for i in range(3))
    return strip.resize((width, height), Image.BILINEAR)


def halo(size: tuple, colour: tuple, strength: float) -> Image.Image:
    """A soft pool of light, brightest at its middle and gone by its edge."""
    mask = ImageOps.invert(Image.radial_gradient("L")).resize(size, Image.BILINEAR)
    mask = mask.point(lambda v: round((v / 255) ** 1.7 * 255 * strength))
    layer = Image.new("RGBA", size, colour + (255,))
    layer.putalpha(mask)
    return layer


def vignetted(canvas: Image.Image, strength: float) -> Image.Image:
    """The corners closed a little, so the tile reads as lit rather than as flat fill."""
    mask = Image.radial_gradient("L").resize(canvas.size, Image.BILINEAR)
    mask = mask.point(lambda v: round((v / 255) ** 2.4 * 255 * strength))
    layer = Image.new("RGBA", canvas.size, SHADE + (255,))
    layer.putalpha(mask)
    canvas.alpha_composite(layer)
    return canvas


def grained(canvas: Image.Image) -> Image.Image:
    """A pinch of noise over the wash.

    A gradient this wide, held in eight bits and saved as a PNG, bands: the eye picks
    out the step where one value gives way to the next and reads it as a stripe across
    the sky. A couple of levels of noise scattered over it puts the step somewhere
    different in every column, and the banding goes.
    """
    noise = Image.effect_noise(canvas.size, 2.2).convert("RGB")
    return ImageChops.add(canvas, noise, scale=1.0, offset=-128)


def rounded(image: Image.Image, radius: int) -> Image.Image:
    """The screenshot with its corners taken off, so it reads as a phone."""
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), image.size], radius=radius, fill=255)
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def wrapped(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, limit: int) -> list:
    """The caption broken into lines that each fit inside the limit."""
    words = text.split()
    lines: list[str] = []
    line = ""
    for word in words:
        trial = f"{line} {word}".strip()
        if draw.textlength(trial, font=font) <= limit or not line:
            line = trial
        else:
            lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def frame(input_path: Path, caption: str, output_path: Path) -> tuple:
    """Composes one framed shot and writes it, returning the canvas size."""
    shot = Image.open(input_path).convert("RGB")
    width, height = shot.size

    canvas = gradient(width, height, [SKY, FIELD, MEADOW]).convert("RGBA")

    # The phone sits in the lower four-fifths, leaving a band at the top for the
    # caption; it is scaled to fit that box with room to breathe on either side.
    box_w, box_h = width * 0.82, height * 0.78
    scale = min(box_w / width, box_h / height)
    shot_w, shot_h = round(width * scale), round(height * scale)
    shot = shot.resize((shot_w, shot_h), Image.LANCZOS)

    shot_x = (width - shot_w) // 2
    shot_y = round(height * 0.185)
    # A phone's corners are far rounder than a tablet's, and a phone's radius laid
    # over an iPad shot bites the clock out of the top-left corner — the status bar
    # sits nearer the edge there, with no notch to hold it in. Tall shots are
    # phones; squarer ones are tablets, and get the gentler curve the device has.
    radius = round(shot_w * (0.085 if height / width >= 1.9 else 0.035))

    # A pool of light behind the phone, wider than the phone and centred on it, so the
    # tile has somewhere the light is coming from and the shot sits in the bright of it.
    glow_w, glow_h = round(width * 1.5), round(height * 0.95)
    canvas.alpha_composite(
        halo((glow_w, glow_h), GLOW, 0.68),
        ((width - glow_w) // 2, shot_y + shot_h // 2 - glow_h // 2),
    )

    # Two shadows rather than one. A single blurred plate is either tight and hard or
    # wide and vague; a phone on a table casts both at once — a dark seam where it
    # meets the ground, and a soft breadth well beyond it — and having the two lets
    # the shot look set down rather than pasted on.
    def plate(drop: float, blur: float, alpha: int) -> Image.Image:
        layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        top = shot_y + round(height * drop)
        ImageDraw.Draw(layer).rounded_rectangle(
            [(shot_x, top), (shot_x + shot_w, top + shot_h)],
            radius=radius,
            fill=SHADE + (alpha,),
        )
        return layer.filter(ImageFilter.GaussianBlur(round(width * blur)))

    canvas.alpha_composite(plate(0.020, 0.055, 78))
    canvas.alpha_composite(plate(0.005, 0.010, 92))
    canvas.alpha_composite(rounded(shot, radius), (shot_x, shot_y))

    # A hairline round the phone. Three of the five screens are cream to their own
    # edges, and on a cream ground the shot dissolved into the tile it stands on;
    # a thread of the game's brown, barely there, gives the glass an edge to end at.
    ImageDraw.Draw(canvas).rounded_rectangle(
        [(shot_x, shot_y), (shot_x + shot_w - 1, shot_y + shot_h - 1)],
        radius=radius,
        outline=POST + (46,),
        width=max(2, round(width * 0.0018)),
    )

    draw = ImageDraw.Draw(canvas)

    # The caption, set as large as two lines will allow, centred in the band above
    # the phone. It shrinks until it fits rather than spilling over the shot.
    limit = round(width * 0.86)
    size = round(height * 0.036)
    while size > round(height * 0.02):
        font = load_font(size)
        lines = wrapped(draw, caption, font, limit)
        line_h = (font.getbbox("Ag")[3] - font.getbbox("Ag")[1]) + round(size * 0.28)
        if len(lines) <= 2 and all(draw.textlength(ln, font=font) <= limit for ln in lines):
            break
        size -= 4
    else:
        font = load_font(size)
        lines = wrapped(draw, caption, font, limit)
        line_h = (font.getbbox("Ag")[3] - font.getbbox("Ag")[1]) + round(size * 0.28)

    block_h = line_h * len(lines)
    y = max(round(height * 0.055), (shot_y - block_h) // 2)
    for line in lines:
        w = draw.textlength(line, font=font)
        draw.text((round((width - w) / 2), y), line, font=font, fill=POST)
        y += line_h

    canvas = vignetted(canvas, 0.16)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    grained(canvas.convert("RGB")).save(output_path, "PNG")
    return canvas.size


def main() -> None:
    parser = argparse.ArgumentParser(description="Frame a screenshot into an App Store image.")
    parser.add_argument("--input", required=True, type=Path, help="Raw screenshot PNG.")
    parser.add_argument("--output", required=True, type=Path, help="Where the framed image is written.")
    parser.add_argument("--caption", required=True, help="The line of copy above the phone.")
    args = parser.parse_args()

    size = frame(args.input, args.caption, args.output)
    print(f"Wrote {args.output} ({size[0]}x{size[1]}) — {args.caption!r}")


if __name__ == "__main__":
    main()
