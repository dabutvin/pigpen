#!/usr/bin/env python3
"""Writes the almanac of daily puzzles the game ships with.

One puzzle per day, shaped from the date and nothing else, so the same run of this script
produces the same year twice over and the app can be shipped knowing what next October is
going to ask of anybody who is still playing it.

A week is a climb. Monday's map is mostly water — free walls everywhere, and the best pen
is the pen anybody would build — and by Sunday there is almost nothing to lean on and a
couple of skulls standing where a wall would want to go. What makes that a climb rather
than a claim is that it is measured: for every candidate map this searches out the best pen
the budget has in it and also squares the map off, the way `level_search.py --demand` does
for the meadow's levels, and keeps the map only if the gap between the two falls in the band
its weekday asks for. The bands do not overlap, so a Tuesday always asks more than a Monday.

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

# What each day of the week is made of. `water` is the share of the board under water,
# which is the knob that does nearly all of the work: water is a wall you are given, so a
# map with a lot of it has an obvious best pen and one with little of it has to be worked
# out. `band` is the gap this day's map has to leave between the pen it has in it and the
# pen a player gets by squaring the map off — what the level asks — as a percentage. The
# bands are laid end to end, so the week can only climb.
PROFILES = {
    1: dict(name="Monday", rows=9, cols=8, water=0.38, rivers=0.15, hug=True,
            apples=0, skulls=0, budget=(10, 14), band=(0, 5), least=16),
    2: dict(name="Tuesday", rows=9, cols=9, water=0.28, rivers=0.25, hug=True,
            apples=0, skulls=0, budget=(9, 13), band=(6, 14), least=16),
    3: dict(name="Wednesday", rows=9, cols=9, water=0.22, rivers=0.35, hug=True,
            apples=2, skulls=0, budget=(9, 13), band=(15, 23), least=16),
    4: dict(name="Thursday", rows=9, cols=9, water=0.15, rivers=0.45, hug=False,
            apples=2, skulls=0, budget=(9, 13), band=(24, 32), least=18),
    5: dict(name="Friday", rows=10, cols=9, water=0.12, rivers=0.5, hug=False,
            apples=3, skulls=1, budget=(9, 12), band=(33, 41), least=18),
    6: dict(name="Saturday", rows=10, cols=10, water=0.08, rivers=0.55, hug=False,
            apples=3, skulls=1, budget=(8, 12), band=(42, 52), least=18),
    7: dict(name="Sunday", rows=10, cols=10, water=0.05, rivers=0.6, hug=False,
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


# --- Shaping a map ---------------------------------------------------------------------


def lake(rng, grid, rows, columns, hug):
    """A pool of water. On the gentler days it is pushed up against an edge of the map,
    where it walls a pen for free rather than merely getting in the way."""
    height = rng.randint(2, max(2, rows // 2))
    width = rng.randint(2, max(2, columns // 2))
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


def river(rng, grid, rows, columns):
    """A run of water across the map, wandering a tile at a time."""
    if rng.random() < 0.5:
        row, column = rng.randrange(1, rows - 1), 0
        while column < columns:
            grid[row][column] = "~"
            if rng.random() < 0.3:
                row = max(0, min(rows - 1, row + rng.choice((-1, 1))))
                grid[row][column] = "~"
            column += 1
    else:
        row, column = 0, rng.randrange(1, columns - 1)
        while row < rows:
            grid[row][column] = "~"
            if rng.random() < 0.3:
                column = max(0, min(columns - 1, column + rng.choice((-1, 1))))
                grid[row][column] = "~"
            row += 1


def wetness(grid):
    return sum(row.count("~") for row in grid) / (len(grid) * len(grid[0]))


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


def shape(rng, profile):
    """A map, or nothing at all if the water swallowed everything worth penning."""
    rows, columns = profile["rows"], profile["cols"]
    grid = [["." for _ in range(columns)] for _ in range(rows)]

    guard = 0
    while wetness(grid) < profile["water"] and guard < 40:
        guard += 1
        if rng.random() < profile["rivers"]:
            river(rng, grid, rows, columns)
        else:
            lake(rng, grid, rows, columns, profile["hug"])

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
    home = run_of_ground(grid, pig)
    spare = [
        tile
        for tile in home
        if tile != pig and 1 <= tile[0] < rows - 1 and 1 <= tile[1] < columns - 1
    ]
    rng.shuffle(spare)
    for _ in range(profile["apples"]):
        if spare:
            row, column = spare.pop()
            grid[row][column] = "a"

    # A skull takes no fencing, so one laid against the pig would take away the four pieces
    # boxed round it that hold on every other board in this game. Skulls keep their
    # distance, and the promise that no puzzle is unpennable holds for the dailies too.
    beside = {(pig[0] + down, pig[1] + across) for down, across in NEIGHBOURS}
    spare = [tile for tile in spare if tile not in beside]
    for _ in range(profile["skulls"]):
        if spare:
            row, column = spare.pop()
            grid[row][column] = "x"

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
    profile = PROFILES[rung(day)]
    rng = seeded(day)
    low, high = profile["band"]

    for _ in range(ATTEMPTS):
        drawn = shape(rng, profile)
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
        )

    raise SystemExit(
        f"{day} ({profile['name']}) would not give up a map asking {low}–{high}% "
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
    return f"{entry['day']} {entry['demand']} {'/'.join(entry['plan'])}"


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
        "/// and the wall of that best pen, as a grid of `#` with its rows run together by `/`.\n"
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
            asked = [
                entry["demand"]
                for entry, day in zip(entries, wanted)
                if rung(day) == step
            ]
            best = [
                entry["best"] for entry, day in zip(entries, wanted) if rung(day) == step
            ]
            print(
                f"{PROFILES[step]['name']:9} band={PROFILES[step]['band']} "
                f"asks={sorted(asked)} best={sorted(best)}"
            )
        return

    write_almanac(options.almanac, years, entries)
    write_fixtures(options.fixtures, years, entries)
    print(f"{len(entries)} days written to {options.almanac} and {options.fixtures}")


if __name__ == "__main__":
    main()
