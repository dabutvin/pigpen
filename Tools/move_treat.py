#!/usr/bin/env python3
"""Moves a treat on an authored level's map, in the Swift source it is written in.

Editing an ASCII map by hand is how a river loses a tile without anybody noticing. This lifts
a treat off one tile and puts it down on another, leaves every other character exactly where
it was, and refuses anything that would not be a legal board: a treat onto water, onto an
animal, onto another treat, onto the rim, or against the pig — where no treat may stand, since
none of them takes a fence and the four pieces boxed round the pig are what make every level
finishable.

    Tools/move_treat.py the-roost 4,8 2,7

It prints the map before and after, and says what moved.
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from level_search import NEIGHBOURS, parse  # noqa: E402
from levels_index import SOURCES, levels  # noqa: E402


def tile(written):
    row, column = written.split(",")
    return int(row), int(column)


def moved(rows, at, to):
    """The map with the treat at `at` picked up and put down on `to`."""
    mark = rows[at[0]][at[1]]
    if mark not in ("a", "x"):
        raise SystemExit(f"No treat at {at} — that tile is {mark!r}")
    if rows[to[0]][to[1]] != ".":
        raise SystemExit(f"{to} is not open mud — it is {rows[to[0]][to[1]]!r}")
    grid = [list(line) for line in rows]
    grid[at[0]][at[1]] = "."
    grid[to[0]][to[1]] = mark
    return ["".join(line) for line in grid], mark


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("level", help="The level's id, as its world file writes it")
    parser.add_argument("moves", nargs="+", help="Pairs of row,column — from, then to")
    options = parser.parse_args()

    if len(options.moves) % 2:
        raise SystemExit("Moves come in pairs: a tile to lift from and a tile to put down on")

    found = {level["id"]: level for level in levels()}
    if options.level not in found:
        raise SystemExit(f"No level called {options.level}")
    level = found[options.level]
    rows = level["map"].split("\n")
    before = list(rows)

    said = []
    for index in range(0, len(options.moves), 2):
        at, to = tile(options.moves[index]), tile(options.moves[index + 1])
        rows, mark = moved(rows, at, to)
        said.append(f"{mark!r} {at[0]},{at[1]} -> {to[0]},{to[1]}")

    # A treat put down on the rim is one nothing can ever shut in, so it may be authored
    # there deliberately but never moved there by this.
    height, width = len(rows), len(rows[0])
    for index in range(0, len(options.moves), 2):
        to = tile(options.moves[index + 1])
        if to[0] in (0, height - 1) or to[1] in (0, width - 1):
            raise SystemExit(f"A treat would be put down on the rim at {to[0]},{to[1]}")

    # And the promise every level makes has to survive the move: an animal boxed in where it
    # stands, widened over any treat the box would have to be built on, still inside budget.
    # A treat may stand against the pig — several authored boards do — so long as the four
    # pieces round her, plus whatever they have to swallow, still fit.
    mud, treats, starts, _, _ = parse("\n".join(rows))
    pen = set(starts.values())
    while True:
        wall = {
            (row + down, column + across)
            for row, column in pen
            for down, across in NEIGHBOURS
        } & mud - pen
        staked = {spot for spot in wall if spot in treats}
        if not staked:
            break
        pen |= staked
    if len(wall) > level["fenceBudget"]:
        raise SystemExit(
            f"The box round the animals would cost {len(wall)} pieces of {level['fenceBudget']}"
        )

    # Everything else about the board has to come through untouched.
    for old, new in zip(before, rows):
        if sorted(old.replace("a", ".").replace("x", ".")) != sorted(
            new.replace("a", ".").replace("x", ".")
        ):
            raise SystemExit("The move changed something other than a treat")

    source = next(path for path in SOURCES if path.name == level["source"])
    text = source.read_text()
    indent = " " * 12
    was = "\n".join(indent + line for line in before)
    now = "\n".join(indent + line for line in rows)
    if text.count(was) != 1:
        raise SystemExit(f"{level['id']}'s map is not written down exactly once")
    source.write_text(text.replace(was, now))

    for old, new in zip(before, rows):
        print(f"  {old}    {new}" if old != new else f"  {old}    {new}")
    print(f"{level['id']}: " + ", ".join(said))


if __name__ == "__main__":
    main()
