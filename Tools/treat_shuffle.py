#!/usr/bin/env python3
"""Finds where a treat should stand on a map, for a level whose demand has drifted.

What a level asks is the gap between the best pen its budget holds and the pen a player gets
by squaring the map off. Nothing lying on the ground takes a fence, so a treat sitting on the
line the obvious block wants is a treat that block collects for nothing — which costs the
level most of what it was asking. A treat standing clear of that line has to be gone out for,
which is the question the level was built around in the first place.

So this moves one treat at a time and re-measures. Feed it a level's id and it prints, for
every tile that treat could stand on instead, what the map would then be worth and what it
would ask:

    Tools/treat_shuffle.py the-turnstile --treat 6,4 --least 37

It changes nothing on disk. The map edit is made by hand from what it prints, because where a
treat *reads* well on a board is not something a search can weigh.
"""

import argparse
import sys
from multiprocessing import Pool
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from level_search import (  # noqa: E402
    NEIGHBOURS,
    fences_around,
    on_rim,
    parse,
    search,
    squared_off,
)
from levels_index import levels  # noqa: E402

SCREENING_BEAM = 1500
SETTLED_BEAM = 6000


def redrawn(rows, at, to, mark):
    """The map with the treat at `at` lifted and put down on `to`."""
    grid = [list(line) for line in rows]
    grid[at[0]][at[1]] = "."
    grid[to[0]][to[1]] = mark
    return "\n".join("".join(line) for line in grid)


def blocked(job):
    """Only the obvious pen, which is the cheap half and the half a treat actually moves.

    Squaring a map off is an enumeration of rectangles rather than a beam search, so it costs
    a fraction of what weighing the best pen costs — and it is the number a treat standing in
    the wall's way changes. So every standing is screened on this, and the search proper is
    run on the handful that survive.
    """
    drawn, budget, rule = job
    mud, treats, starts, rows, columns = parse(drawn)
    plain, block = squared_off(mud, treats, starts, rows, columns, budget, rule)
    return plain if block else None


def weigh(job):
    drawn, budget, rule, beam = job
    mud, treats, starts, rows, columns = parse(drawn)
    best, pen = search(mud, treats, starts, rows, columns, budget, beam, rule)
    if not pen:
        return None
    plain, block = squared_off(mud, treats, starts, rows, columns, budget, rule)
    if not block:
        return None
    return dict(
        best=best,
        plain=plain,
        demand=(best - plain) * 100 // best,
        area=len(pen),
        spent=len(fences_around(pen, mud)),
    )


def standings(rows, at, pig, treats):
    """Every tile the treat could be moved to.

    Never the rim, where nothing can be shut in; never a tile already spoken for; and never
    against the pig, since no treat takes a fence and one laid beside her would take away the
    four pieces boxed round her that hold on every board in this game.
    """
    height, width = len(rows), len(rows[0])
    beside = {(pig[0] + down, pig[1] + across) for down, across in NEIGHBOURS}
    return [
        (row, column)
        for row in range(height)
        for column in range(width)
        if rows[row][column] == "."
        and (row, column) != at
        and (row, column) not in beside
        and (row, column) not in treats
        and not on_rim((row, column), height, width)
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("level", help="The level's id, as PuzzleLevel writes it")
    parser.add_argument("--treat", required=True, help="The treat to move, as row,column")
    parser.add_argument("--least", type=int, default=0, help="Only print standings asking this much")
    parser.add_argument("--jobs", type=int, default=4)
    options = parser.parse_args()

    found = {level["id"]: level for level in levels()}
    if options.level not in found:
        raise SystemExit(f"No level called {options.level}")
    level = found[options.level]
    rows = level["map"].split("\n")
    at = tuple(int(part) for part in options.treat.split(","))
    mark = rows[at[0]][at[1]]
    if mark not in ("a", "x"):
        raise SystemExit(f"No treat at {at} — that tile is {mark!r}")

    mud, treats, starts, height, width = parse(level["map"])
    where = standings(rows, at, starts["P"], treats)
    budget, rule = level["fenceBudget"], level["rule"]

    standing = weigh((level["map"], budget, rule, SETTLED_BEAM))
    print(
        f"{level['id']}: as it stands, best {standing['best']}, squared off {standing['plain']}, "
        f"asks {standing['demand']}%"
    )
    print(f"trying {len(where)} standings for the {mark!r} at {at}\n")

    # Screen on the obvious pen alone. A standing can only ask what `least` asks if squaring
    # the map off is worth little enough, and the best pen can never beat the one the map
    # already gives up — so anything whose block is too rich is out without a search at all.
    ceiling = standing["best"]
    with Pool(options.jobs) as pool:
        blocks = pool.map(
            blocked, [(redrawn(rows, at, to, mark), budget, rule) for to in where]
        )

    # Measured against the best pen as the map stands, with room either side: moving a treat
    # can lift the best pen as well as the block, and a standing that is close on this screen
    # is cheap enough to weigh properly.
    close = [
        to
        for to, plain in zip(where, blocks)
        if plain is not None and (ceiling - plain) * 100 // ceiling >= options.least - 8
    ]
    print(f"{len(close)} of them worth searching properly\n")
    with Pool(options.jobs) as pool:
        settled = pool.map(
            weigh,
            [(redrawn(rows, at, to, mark), budget, rule, SETTLED_BEAM) for to in close],
        )

    keeping = [
        (got["demand"], to, got)
        for to, got in zip(close, settled)
        if got and got["demand"] >= options.least
    ]
    for demand, to, got in sorted(keeping, reverse=True):
        print(
            f"  {mark} at {to[0]},{to[1]}   best {got['best']:3}  squared off {got['plain']:3}  "
            f"asks {demand:3}%   (pen {got['area']} tiles, {got['spent']} pieces)"
        )
    if not keeping:
        print("  nothing reaches that — try moving a different treat, or asking for less")


if __name__ == "__main__":
    main()
