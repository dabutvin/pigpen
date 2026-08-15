#!/usr/bin/env python3
"""Writes the almanac of daily puzzles the game ships with.

One puzzle per day, shaped from the date and nothing else, so the same run of this script
produces the same year twice over and the app can be shipped knowing what next October is
going to ask of anybody who is still playing it.

A week is a climb. Monday's map is mostly water — free walls everywhere, and the best pen
is the pen anybody would build — and by Sunday there is almost nothing to lean on: five
tiles of water on a board of a hundred, never more than three of them lying together, and a
couple of skulls standing where a wall would want to go. What makes that a climb rather
than a claim is that it is measured: for every candidate map this searches out the best pen
the budget has in it and also squares the map off, the way `level_search.py --demand` does
for the meadow's levels, and keeps the map only if the gap between the two falls in the band
its weekday asks for. The bands do not overlap, so a Tuesday always asks more than a Monday.

Across that climb runs a second thing, which is what the water on a board looks like. Most
days lay it the plain way — bodies of it dropped until the day is wet enough — but roughly
two days a week are handed one of the shapes in `SHAPES` instead: water freckled over the
board a tile at a time, a shore stepping across a corner on the diagonal, or two banks
pinching the board down to a neck. The shape does not change what a day asks; its weekday
still sets the wetness, the pool cap and the band, and the map is thrown back and reshaped
until it lands in that band like any other. It only changes what the board looks like to
build on, which after seven hundred boards of one arrangement is worth something on its own.

    Tools/generate_dailies.py --years 2026 2027

It writes two files, both generated and both committed:

  * `Pigpen/Models/DailyAlmanacData.swift` — the puzzles, as one line per day.
  * `PigpenTests/DailyAlmanacFixtures.swift` — the pen each day's `maximumScore` was
    measured on, and what the day asks. `DailyAlmanacTests` replays every one of them, so a
    day can never promise a pen the map does not actually hold.

Everything about a day comes out of `random.Random` seeded from the date, so days are
independent and the work can be spread over as many cores as there are.
"""

import argparse
import hashlib
import random
import sys
from datetime import date, timedelta
from multiprocessing import Pool
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from level_search import (  # noqa: E402
    can_be_walled,
    fences_around,
    parse,
    score,
    search,
    squared_off,
)

NEIGHBOURS = ((-1, 0), (1, 0), (0, -1), (0, 1))

# What each day of the week is made of. `water` is the share of the board under water and
# `pool` is the most of it that may lie in one piece, and between them they are the knob
# that does nearly all of the work: water is a wall you are given, so a map with a lot of it
# has an obvious best pen and one with little of it has to be worked out.
#
# Both halves of that knob matter, and the second one is the one it is easy to leave out.
# Water only walls a pen if there is enough of it *in one stretch* to be leant on: a river
# from one side of a board to the other hands over a wall ten pieces long for nothing, and
# what is left to work out is a single staircase. Ten tiles of water in three puddles hands
# over no wall at all — it only eats ground the pen would have wanted. So `water` says how
# wet a day is and `pool` says whether that water is a gift or a nuisance, and both dry up
# across the week.
#
# `band` is the gap this day's map has to leave between the pen it has in it and the pen a
# player gets by squaring the map off — what the level asks — as a percentage. The bands are
# laid end to end, so the week can only climb.
PROFILES = {
    1: dict(name="Monday", rows=9, cols=8, water=0.38, pool=28, rivers=0.15, hug=True,
            apples=0, skulls=0, budget=(10, 14), band=(0, 5), least=16),
    2: dict(name="Tuesday", rows=9, cols=9, water=0.28, pool=20, rivers=0.25, hug=True,
            apples=0, skulls=0, budget=(9, 13), band=(6, 14), least=16),
    3: dict(name="Wednesday", rows=9, cols=9, water=0.22, pool=15, rivers=0.35, hug=True,
            apples=2, skulls=0, budget=(9, 13), band=(15, 23), least=16),
    4: dict(name="Thursday", rows=9, cols=9, water=0.15, pool=11, rivers=0.45, hug=False,
            apples=2, skulls=0, budget=(9, 13), band=(24, 32), least=18),
    5: dict(name="Friday", rows=10, cols=9, water=0.12, pool=8, rivers=0.5, hug=False,
            apples=3, skulls=1, budget=(9, 12), band=(33, 41), least=18),
    6: dict(name="Saturday", rows=10, cols=10, water=0.08, pool=5, rivers=0.55, hug=False,
            apples=3, skulls=1, budget=(8, 12), band=(42, 52), least=18),
    7: dict(name="Sunday", rows=10, cols=10, water=0.05, pool=3, rivers=0.6, hug=False,
            apples=4, skulls=2, budget=(8, 12), band=(53, 66), least=18),
}

# How wide a net the search casts. The screening pass is deliberately cheap, since most
# candidates are thrown away; whatever survives it is searched again properly, and the wider
# search is the one whose answer is shipped as `maximumScore`.
SCREENING_BEAM = 1000
SETTLED_BEAM = 5000
# How many maps a day is allowed to shape before its band is given up on.
ATTEMPTS = 400


def rung(day):
    """Where a date stands in the week's climb: 1 for Monday, 7 for Sunday."""
    return day.isoweekday()


def seeded(day):
    """A generator of a day's own, so days can be worked out in any order or all at once."""
    digest = hashlib.sha256(f"pigpen-daily-{day.isoformat()}".encode()).digest()
    return random.Random(int.from_bytes(digest[:8], "big"))


def shape_of(day):
    """The shape this day's water takes: `plain`, or one of the shapes in `SHAPES`.

    Drawn from the date on its own rather than from the day's generator, which is what
    makes this a change to *some* of the book rather than all of it: a day that comes up
    plain asks its generator for exactly what it always asked, in exactly the same order,
    and comes out the board it always was.
    """
    offered = [name for name, water in SHAPES.items() if rung(day) in water["rungs"]]
    if not offered:
        return "plain"
    digest = hashlib.sha256(f"pigpen-shape-{day.isoformat()}".encode()).digest()
    roll = int.from_bytes(digest[:4], "big") / 2**32
    if roll >= VARIED:
        return "plain"
    return offered[min(int(roll / VARIED * len(offered)), len(offered) - 1)]


# --- Shaping a map ---------------------------------------------------------------------


def lake(rng, grid, rows, columns, hug, most):
    """A pool of water of no more than `most` tiles. On the gentler days it is pushed up
    against an edge of the map, where it walls a pen for free rather than merely getting in
    the way; on the dry ones there is not enough of it left to wall anything."""
    least = 2 if most >= 4 else 1
    height = rng.randint(least, max(least, min(rows // 2, most // least)))
    width = rng.randint(least, max(least, min(columns // 2, most // height)))
    if hug and rng.random() < 0.8:
        side = rng.choice("NSEW")
        top = 0 if side == "N" else rows - height if side == "S" else rng.randrange(rows - height + 1)
        left = 0 if side == "W" else columns - width if side == "E" else rng.randrange(columns - width + 1)
    else:
        top = rng.randrange(rows - height + 1)
        left = rng.randrange(columns - width + 1)
    for row in range(top, top + height):
        for column in range(left, left + width):
            grid[row][column] = "~"


def river(rng, grid, rows, columns, most):
    """A run of water across the map, wandering a tile at a time, until it reaches the far
    side or has laid `most` tiles of water it did not already have, whichever comes first —
    so on a wet day a river runs from one side of the board to the other and on a dry one it
    is a brook that peters out well short of anywhere useful."""
    spent = 0

    def lay(row, column):
        nonlocal spent
        if grid[row][column] != "~":
            grid[row][column] = "~"
            spent += 1

    if rng.random() < 0.5:
        row, column = rng.randrange(1, rows - 1), 0
        while column < columns and spent < most:
            lay(row, column)
            if rng.random() < 0.3:
                row = max(0, min(rows - 1, row + rng.choice((-1, 1))))
                lay(row, column)
            column += 1
    else:
        row, column = 0, rng.randrange(1, columns - 1)
        while row < rows and spent < most:
            lay(row, column)
            if rng.random() < 0.3:
                column = max(0, min(columns - 1, column + rng.choice((-1, 1))))
                lay(row, column)
            row += 1


def under_water(grid):
    return sum(row.count("~") for row in grid)


def wetness(grid):
    return under_water(grid) / (len(grid) * len(grid[0]))


def biggest_pool(grid):
    """The most water lying in one piece — the longest wall the map hands over for free."""
    rows, columns = len(grid), len(grid[0])
    seen, biggest = set(), 0
    for row in range(rows):
        for column in range(columns):
            if grid[row][column] != "~" or (row, column) in seen:
                continue
            seen.add((row, column))
            queue, held = [(row, column)], 0
            while queue:
                tile = queue.pop()
                held += 1
                for down, across in NEIGHBOURS:
                    step = (tile[0] + down, tile[1] + across)
                    if (
                        0 <= step[0] < rows
                        and 0 <= step[1] < columns
                        and grid[step[0]][step[1]] == "~"
                        and step not in seen
                    ):
                        seen.add(step)
                        queue.append(step)
            biggest = max(biggest, held)
    return biggest


def run_of_ground(grid, start):
    """The tiles an animal standing on `start` can walk to."""
    rows, columns = len(grid), len(grid[0])
    reached, queue = {start}, [start]
    while queue:
        row, column = queue.pop()
        for down, across in NEIGHBOURS:
            step = (row + down, column + across)
            if (
                0 <= step[0] < rows
                and 0 <= step[1] < columns
                and grid[step[0]][step[1]] != "~"
                and step not in reached
            ):
                reached.add(step)
                queue.append(step)
    return reached


def flood(rng, grid, rows, columns, profile, share):
    """Lakes and rivers, until `share` of the board is under water.

    Water is a budget rather than a floor. Laying it down until the board was wet enough
    and then stopping meant a day whose share was smaller than one river got one river
    anyway and overshot — which is how Saturday and Sunday, asked for 8% and 5%, both
    ended up at 13% of the board under a single stretch of water running its whole width.
    Each body is drawn into a copy first and kept only if it fits both what is left of the
    day's water and what the day allows to lie in one piece.

    Whatever water the grid arrives with counts against the share, so a shape that has
    already laid its own signature body is topped up to the day's wetness rather than
    drowned past it.
    """
    allowed = round(rows * columns * share)
    wet, guard = under_water(grid), 0
    while wet < allowed and guard < 60:
        guard += 1
        drawn = [row[:] for row in grid]
        most = min(profile["pool"], allowed - wet)
        if rng.random() < profile["rivers"]:
            river(rng, drawn, rows, columns, most)
        else:
            lake(rng, drawn, rows, columns, profile["hug"], most)
        # A body laid entirely over water already there has added nothing to keep, and a new
        # one running into an old one can make a pool bigger than either of them.
        laid = under_water(drawn)
        if wet < laid <= allowed and biggest_pool(drawn) <= profile["pool"]:
            grid, wet = drawn, laid
    return grid


# --- The shapes a day's water can take ---------------------------------------------------
#
# What a board is made of is water, and until now every board was made of it the same way:
# bodies of it dropped one after another until the day was wet enough. That is the right
# default — it is the shape that lets a weekday's share of water mean what the table above
# says it means — but seven hundred boards of it in a row is seven hundred boards of one
# idea. So a day can instead be handed one of the shapes below, which lay the day's water
# in a particular arrangement first and then let `flood` top the board up to the wetness
# its weekday asks for. The weekday still sets how wet the day is, how much may lie in one
# piece, and what the board has to ask of a player; the shape only decides where it goes.
#
# `lonely` is how many tiles of water a shape promises to leave standing entirely on their
# own. `DailyAlmanacTests` counts them on the boards that shipped, so a shape cannot come
# out looking like every other day and still be filed under its own name.


def plainly(rng, grid, rows, columns, profile):
    """Bodies of water dropped until the day is wet enough. What most days are."""
    return flood(rng, grid, rows, columns, profile, profile["water"])


def speckled(rng, grid, rows, columns, profile):
    """Water freckled over the board a tile at a time, on every other square.

    Specks are laid only on one colour of the board's checkerboard and never beside water
    already there, so every one of them stands alone: a speck is a hole rather than a wall,
    worth nothing to lean on and costing nothing to fence round, and a board full of them
    is one where the ground a pen wants is everywhere and nowhere. It is the change of pace
    the plain shape cannot give — there is still plenty of room, but no run of it is clean.

    `body` says how much of the day's water still goes down as ordinary lakes and rivers
    before any of this, so a Monday keeps the long free wall a Monday owes and only gets
    freckled around it. The freckles are laid over the top of that rather than out of the
    same share, so a speckled board runs a little wetter than its weekday's figure — what
    is held to that figure is the water that could be leant on, which the freckles are not.
    """
    grid = flood(rng, grid, rows, columns, profile, profile["water"] * profile["body"])

    parity = rng.randrange(2)
    lattice = [
        (row, column)
        for row in range(rows)
        for column in range(columns)
        if (row + column) % 2 == parity and grid[row][column] == "."
    ]
    rng.shuffle(lattice)
    for row, column in lattice[: round(len(lattice) * profile["speck"])]:
        if all(
            not (0 <= row + down < rows and 0 <= column + across < columns)
            or grid[row + down][column + across] != "~"
            for down, across in NEIGHBOURS
        ):
            grid[row][column] = "~"
    return grid


def coasted(rng, grid, rows, columns, profile):
    """A shore cut across one corner of the board on the diagonal.

    A lake hugging an edge hands over a straight wall, and a straight wall is the one a
    player would have built anyway. A shore that steps in a tile at a time hands over a
    staircase instead — the shape this whole game is about — and leaves the player to work
    out only the other half of it. Wet days can afford a long one; by Thursday the day's
    share of water runs out well before the corner does.
    """
    most = min(profile["pool"], round(rows * columns * profile["water"]))
    south = rng.random() < 0.5
    east = rng.random() < 0.5
    reach = rng.randint(2, max(2, columns - 3))
    spent = 0
    for row in range(rows) if south else reversed(range(rows)):
        if reach <= 0 or spent >= most:
            break
        for step in range(reach):
            column = columns - 1 - step if east else step
            if grid[row][column] != "~" and spent < most:
                grid[row][column] = "~"
                spent += 1
        reach -= rng.randint(1, 2)
    return flood(rng, grid, rows, columns, profile, profile["water"])


def straited(rng, grid, rows, columns, profile):
    """Two banks of water reaching in from opposite edges and stopping short of each other.

    The board comes out very nearly cut in two, with a neck of ground a tile or three wide
    holding the halves together. Both banks are wall handed over for free, so this is a
    generous shape — but it is generous in a way that asks a question the plain shape never
    does, which is whether the pen belongs on one side of the neck, the other, or across it.
    """
    most = min(profile["pool"], max(2, round(rows * columns * profile["water"] / 2)))
    neck = rng.randint(1, 3)
    if rng.random() < 0.5:
        column = rng.randrange(2, max(3, columns - 2))
        near = rng.randint(1, max(1, min(most, rows - neck - 1)))
        far = rng.randint(0, max(0, min(most, rows - neck - near)))
        for row in range(near):
            grid[row][column] = "~"
        for row in range(rows - far, rows):
            grid[row][column] = "~"
    else:
        row = rng.randrange(2, max(3, rows - 2))
        near = rng.randint(1, max(1, min(most, columns - neck - 1)))
        far = rng.randint(0, max(0, min(most, columns - neck - near)))
        for column in range(near):
            grid[row][column] = "~"
        for column in range(columns - far, columns):
            grid[row][column] = "~"
    return flood(rng, grid, rows, columns, profile, profile["water"])


# The shapes other than the plain one, what each wants from the day it lands on, and which
# rungs of the week can carry it.
SHAPES = {
    "speckle": dict(
        lay=speckled,
        rungs=(1, 2, 3, 4, 5, 6, 7),
        lonely=4,
        # How much of the day's water still goes down as ordinary bodies, and how much of
        # the board's lattice is freckled on top of it. The wet end of the week keeps nearly
        # all of its water in one piece — a Monday that handed over nothing to lean on would
        # not be a Monday — and by Friday the bodies are mostly gone and the board is
        # freckles.
        #
        # The freckles pull a day *towards* the easy end rather than away from it, which is
        # the opposite of what a tile of water usually does and worth knowing before these
        # are touched. A freckle beside the block of ground a player squares off is a free
        # fence piece for the pen that needed one most, while the staircase pen it is being
        # measured against was already spending its budget well. So water broken up small
        # closes the gap between the two, and the dry end of the week has to be given back
        # some of what the freckles cost it — which is why Saturday keeps nearly all of its
        # bodies too. These are the pairs that landed in band oftenest when swept.
        knobs={
            1: dict(body=0.95, speck=0.17),
            2: dict(body=0.75, speck=0.17),
            3: dict(body=0.75, speck=0.17),
            4: dict(body=0.55, speck=0.17),
            5: dict(body=0.35, speck=0.17),
            6: dict(body=0.95, speck=0.13),
            7: dict(body=0.35, speck=0.17),
        },
    ),
    # A coast is one long body of water, so it wants a day with a pool cap big enough to
    # spend on it, and a strait wants enough for two banks with a gap left between them.
    # Neither is offered a rung whose band it could only reach by accident, and the rungs
    # here were measured rather than guessed: by Saturday there is not enough water left on
    # the board to step a shore down more than a tile or two, a Tuesday coast lands around
    # 20% against a band of 6–14, and a Wednesday strait lands around 30% against 15–23.
    "coast": dict(lay=coasted, rungs=(1, 3, 4, 5), lonely=0, knobs={}),
    "strait": dict(lay=straited, rungs=(1, 2, 4, 5), lonely=0, knobs={}),
}

# How much of the book is given a shape other than the plain one. Roughly two days a week,
# so a shape is a change of pace rather than the new normal.
VARIED = 0.30


def profile_for(step, water):
    """A weekday's profile with the knobs its water's shape wants folded in."""
    if water == "plain":
        return PROFILES[step]
    return {**PROFILES[step], **SHAPES[water]["knobs"].get(step, {})}


def lonely_water(grid):
    """Tiles of water with no water beside them — the freckles, as a board shows them."""
    rows, columns = len(grid), len(grid[0])
    return sum(
        1
        for row in range(rows)
        for column in range(columns)
        if grid[row][column] == "~"
        and all(
            not (0 <= row + down < rows and 0 <= column + across < columns)
            or grid[row + down][column + across] != "~"
            for down, across in NEIGHBOURS
        )
    )


def shape(rng, profile, water="plain"):
    """A map, or nothing at all if the water swallowed everything worth penning.

    `profile` is the day's weekday profile with the shape's knobs already folded into it,
    which is what `profile_for` does.
    """
    rows, columns = profile["rows"], profile["cols"]
    grid = [["." for _ in range(columns)] for _ in range(rows)]

    if water == "plain":
        grid = plainly(rng, grid, rows, columns, profile)
    else:
        laying = SHAPES[water]
        grid = laying["lay"](rng, grid, rows, columns, profile)
        # A shape that did not come out looking like itself is not worth shipping under its
        # own name, and the tests will say so, so it is thrown back here instead.
        if lonely_water(grid) < laying["lonely"]:
            return None

    room = int(rows * columns * 0.30)
    inland = [
        (row, column)
        for row in range(1, rows - 1)
        for column in range(1, columns - 1)
        if grid[row][column] == "."
    ]
    rng.shuffle(inland)
    pig = next((tile for tile in inland if len(run_of_ground(grid, tile)) >= room), None)
    if pig is None:
        return None

    # Treats go on ground the pig can actually reach, and never on the rim, where nothing
    # can ever be shut in with it.
    #
    # Nor do any of them go against the pig. No treat takes fencing, so one laid beside it
    # would take away the four pieces boxed round it that hold on every other board in this
    # game — and that box is the promise that no puzzle is unpennable, which the dailies keep
    # as much as the authored fields do. It used to be a rule for skulls alone, because an
    # apple could be paved over and so was never in the way; now that neither can be, the
    # apples keep their distance too.
    home = run_of_ground(grid, pig)
    beside = {(pig[0] + down, pig[1] + across) for down, across in NEIGHBOURS}
    spare = [
        tile
        for tile in home
        if tile != pig
        and tile not in beside
        and 1 <= tile[0] < rows - 1
        and 1 <= tile[1] < columns - 1
    ]
    rng.shuffle(spare)
    for treat in ("a", "x"):
        for _ in range(profile["apples" if treat == "a" else "skulls"]):
            if spare:
                row, column = spare.pop()
                grid[row][column] = treat

    grid[pig[0]][pig[1]] = "P"
    return "\n".join("".join(row) for row in grid)


# --- Weighing one up -------------------------------------------------------------------


def weigh(drawn, budget, beam):
    """What a map and a budget are worth: the best pen, the obvious pen, and the gap."""
    mud, treats, starts, rows, columns = parse(drawn)
    best, pen = search(mud, treats, starts, rows, columns, budget, beam)
    if not pen:
        return None
    plain, block = squared_off(mud, treats, starts, rows, columns, budget)
    if plain < 3:
        return None
    return dict(
        map=drawn,
        budget=budget,
        best=best,
        pen=pen,
        plain=plain,
        block=block,
        demand=(best - plain) * 100 // best,
        mud=mud,
        treats=treats,
        rows=rows,
        columns=columns,
    )


def stars(weighed):
    """The two thresholds, in the proportions the meadow's levels use — except that the
    second star never asks for more than squaring the map off is worth, so no day withholds
    it from the pen a player builds before they know any of the game's ideas."""
    two = min(round(weighed["best"] * 0.57), weighed["plain"])
    three = round(weighed["best"] * 0.94)
    return max(1, two), three


def plan_of(weighed, pen):
    """The wall a pen needs, as the bare grid of `#` the tests replay."""
    edge = fences_around(pen, weighed["mud"])
    return [
        "".join("#" if (row, column) in edge else "." for column in range(weighed["columns"]))
        for row in range(weighed["rows"])
    ]


def puzzle(day):
    """The one puzzle a day gets, shaped and measured until it asks what its weekday asks."""
    water = shape_of(day)
    profile = profile_for(rung(day), water)
    rng = seeded(day)
    low, high = profile["band"]

    for _ in range(ATTEMPTS):
        drawn = shape(rng, profile, water)
        if drawn is None:
            continue
        budget = rng.randint(*profile["budget"])

        screened = weigh(drawn, budget, SCREENING_BEAM)
        if screened is None or screened["best"] < profile["least"]:
            continue
        # Screening is a cheap look, so give anything close to the band the proper search
        # rather than only what already lands in it.
        if not low - 6 <= screened["demand"] <= high + 6:
            continue

        settled = weigh(drawn, budget, SETTLED_BEAM)
        if settled is None or settled["best"] < profile["least"]:
            continue
        if not low <= settled["demand"] <= high:
            continue

        two, three = stars(settled)
        if three <= two:
            continue

        edge = fences_around(settled["pen"], settled["mud"])
        assert len(edge) <= budget and can_be_walled(edge, settled["treats"]), day
        assert score(settled["pen"], settled["treats"]) == settled["best"], day

        return dict(
            day=day.isoformat(),
            budget=budget,
            two=two,
            three=three,
            best=settled["best"],
            map=settled["map"].split("\n"),
            plan=plan_of(settled, settled["pen"]),
            demand=settled["demand"],
            shape=water,
        )

    raise SystemExit(
        f"{day} ({profile['name']}, {water}) would not give up a map asking {low}–{high}% "
        f"in {ATTEMPTS} tries — loosen its band or its water"
    )


# --- Writing it down -------------------------------------------------------------------


def days_of(year):
    day = date(year, 1, 1)
    while day.year == year:
        yield day
        day += timedelta(days=1)


def almanac_line(entry):
    return (
        f"{entry['day']} {entry['budget']} {entry['two']} {entry['three']} "
        f"{entry['best']} {'/'.join(entry['map'])}"
    )


def fixture_line(entry):
    return f"{entry['day']} {entry['demand']} {entry['shape']} {'/'.join(entry['plan'])}"


BANNER = """\
// Generated by Tools/generate_dailies.py — do not edit by hand.
//
// Re-run the tool to change what is in here:
//
//     Tools/generate_dailies.py --years {years}
//
"""


def swift_literal(name, lines, indent="    "):
    body = "\n".join(f"{indent}{indent}{line}" for line in lines)
    return f'{indent}static let {name} = """\n{body}\n{indent}{indent}"""\n'


def write_almanac(path, years, entries):
    parts = [BANNER.format(years=" ".join(str(year) for year in years))]
    parts.append(
        "/// The daily puzzles, one line to a day: the date, the fence budget, the scores the\n"
        "/// second and third stars are worth, the best pen the map has in it, and the map with\n"
        "/// its rows run together by `/`.\n"
        "extension DailyAlmanac {\n"
    )
    parts.append(
        "    static let almanac: [String] = ["
        + ", ".join(f"puzzlesOf{year}" for year in years)
        + "]\n"
    )
    for year in years:
        parts.append("\n")
        parts.append(
            swift_literal(
                f"puzzlesOf{year}",
                [almanac_line(entry) for entry in entries if entry["day"].startswith(str(year))],
            )
        )
    parts.append("}\n")
    path.write_text("".join(parts))


def write_fixtures(path, years, entries):
    parts = [BANNER.format(years=" ".join(str(year) for year in years))]
    parts.append(
        "/// The workings behind the almanac, for the tests to check it against.\n"
        "///\n"
        "/// One line to a day: the date, what the day asks — the gap between the best pen the\n"
        "/// map has in it and the pen a player gets by squaring the map off, as a percentage —\n"
        "/// the shape its water was laid in, and the wall of that best pen, as a grid of `#`\n"
        "/// with its rows run together by `/`.\n"
        "///\n"
        "/// `DailyAlmanacTests` lays every one of those walls out on its day's board and lets\n"
        "/// the pig go, so no day can promise a pen its map does not hold.\n"
        "enum DailyAlmanacFixtures {\n"
    )
    parts.append(
        "    static let workings: [String] = ["
        + ", ".join(f"workingsOf{year}" for year in years)
        + "]\n"
    )
    for year in years:
        parts.append("\n")
        parts.append(
            swift_literal(
                f"workingsOf{year}",
                [fixture_line(entry) for entry in entries if entry["day"].startswith(str(year))],
            )
        )
    parts.append("}\n")
    path.write_text("".join(parts))


def main():
    here = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--years", type=int, nargs="+", default=[date.today().year])
    parser.add_argument("--jobs", type=int, default=0, help="Cores to spread the search over")
    parser.add_argument("--almanac", type=Path, default=here / "Pigpen/Models/DailyAlmanacData.swift")
    parser.add_argument(
        "--fixtures", type=Path, default=here / "PigpenTests/DailyAlmanacFixtures.swift"
    )
    parser.add_argument(
        "--sample",
        type=int,
        default=0,
        help="Weigh this many days per weekday and report, rather than writing anything",
    )
    options = parser.parse_args()

    years = sorted(set(options.years))
    wanted = [day for year in years for day in days_of(year)]
    if options.sample:
        wanted = [day for day in wanted if (day - date(years[0], 1, 1)).days // 7 < options.sample]

    if options.jobs and options.jobs > 1:
        with Pool(options.jobs) as pool:
            entries = pool.map(puzzle, wanted, chunksize=4)
    else:
        entries = [puzzle(day) for day in wanted]

    if options.sample:
        for step in range(1, 8):
            for water in ["plain", *SHAPES]:
                asked = sorted(
                    entry["demand"]
                    for entry, day in zip(entries, wanted)
                    if rung(day) == step and entry["shape"] == water
                )
                if not asked:
                    continue
                print(
                    f"{PROFILES[step]['name']:9} {water:8} band={PROFILES[step]['band']} "
                    f"asks={asked}"
                )
        return

    write_almanac(options.almanac, years, entries)
    write_fixtures(options.fixtures, years, entries)
    print(f"{len(entries)} days written to {options.almanac} and {options.fixtures}")


if __name__ == "__main__":
    main()
