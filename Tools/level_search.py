#!/usr/bin/env python3
"""Finds the best pen a Pigpen map has in it, for a given fence budget.

`PuzzleLevel` carries a `maximumScore` that the game uses to tell a player there is
nothing left to beat. It cannot be derived with a sum — it is a search — so it is
authored, and this is what authors it. Feed it an ASCII map (`.` mud, `~` water, `a`
an apple, `x` a skull, `P` the pig's tile) and a budget and it prints the best pen, an
example of it, and star thresholds in the proportions the shipped levels use.

    Tools/level_search.py --budget 12 <<'MAP'
    .........
    ~~~~~~~..
    ...a..~..
    ..P...~..
    .........
    MAP

A pen is any connected run of mud holding the pig and no tile on the rim of the map —
the pig walks straight off the rim — and it costs one fence piece for every mud tile
around its edge. Water costs nothing, which is the whole game. A tile the pen grows
around rather than over is a mud tile on that edge like any other, so burying a skull
under a piece of fencing is a pen with a hole in it, and the search finds those too.

A pen scores a point per tile of ground, five more for an apple shut in with the pig
and five fewer for a skull, and never less than a point however sour the ground. The
search grows a pen outwards a tile at a time, keeping the cheapest few thousand pens
of each size along with the ones holding the most for what they cost, which finds the
best pen on maps this size while an exhaustive walk of every pen would not finish at all.
"""

import argparse
import sys

NEIGHBOURS = ((-1, 0), (1, 0), (0, -1), (0, 1))
# What shutting a tile into the pen is worth, over and above the ground itself.
WORTH = {"a": 5, "x": -5}


def parse(map_text):
    lines = [line for line in map_text.split("\n") if line.strip()]
    width = len(lines[0])
    if any(len(line) != width for line in lines):
        raise SystemExit("The map is ragged: every row must be the same width")

    mud, treats, start = set(), {}, None
    for row, line in enumerate(lines):
        for column, character in enumerate(line):
            if character == "P":
                if start is not None:
                    raise SystemExit("The map names more than one starting tile")
                start = (row, column)
                mud.add(start)
            elif character in WORTH:
                mud.add((row, column))
                treats[(row, column)] = character
            elif character == ".":
                mud.add((row, column))
            elif character != "~":
                raise SystemExit(f"Unknown terrain {character!r}")
    if start is None:
        raise SystemExit("The map names no starting tile")
    return mud, treats, start, len(lines), width


def score(pen, treats):
    """What a pen that holds is worth: its ground, and what is lying on it."""
    if not pen:
        return 0
    return max(1, len(pen) + sum(WORTH[treats[tile]] for tile in pen if tile in treats))


def fences_around(pen, mud):
    """The mud tiles that have to be fenced to hold a pen — including any tile the pen
    was grown around rather than over, which is how a skull gets buried."""
    edge = set()
    for row, column in pen:
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if neighbour in mud and neighbour not in pen:
                edge.add(neighbour)
    return edge


def search(mud, treats, start, rows, columns, budget, beam):
    """The best pen within budget, as (score, tiles)."""

    def on_rim(tile):
        return tile[0] in (0, rows - 1) or tile[1] in (0, columns - 1)

    pennable = {tile for tile in mud if not on_rim(tile)}
    if start not in pennable:
        raise SystemExit("The pig starts on the rim of the map, where no pen can hold it")

    def cost(pen):
        return len(fences_around(pen, mud))

    alone = frozenset({start})
    best = (score(alone, treats), alone) if cost(alone) <= budget else (0, frozenset())
    live = {alone}

    while live:
        grown = {}
        for pen in live:
            for row, column in pen:
                for down, across in NEIGHBOURS:
                    neighbour = (row + down, column + across)
                    if neighbour not in pennable or neighbour in pen:
                        continue
                    wider = pen | {neighbour}
                    if wider in grown:
                        continue
                    grown[wider] = cost(wider)

        if not grown:
            break

        within = [(score(pen, treats), pen) for pen, spent in grown.items() if spent <= budget]
        if within:
            best = max(best, max(within))

        # Cheap pens are the ones worth widening: a pen over budget is not thrown away,
        # since filling in a notch can hand a piece back, but it queues behind the rest.
        # Kept alongside them are the pens holding the most for what they cost, so a pen
        # that went out of its way for an apple is not dropped for a tidier one.
        cheapest = sorted(grown, key=lambda pen: grown[pen])[:beam]
        thriftiest = sorted(grown, key=lambda pen: grown[pen] - score(pen, treats))[: beam // 2]
        live = set(cheapest) | set(thriftiest)

    return best


def draw(mud, treats, start, rows, columns, pen, plan_only=False):
    edge = fences_around(pen, mud)

    lines = []
    for row in range(rows):
        line = ""
        for column in range(columns):
            tile = (row, column)
            if tile in edge:
                line += "#"
            elif plan_only:
                line += "."
            elif tile == start:
                line += "P"
            elif tile in treats:
                line += treats[tile]
            elif tile in pen:
                line += "o"
            elif tile in mud:
                line += "."
            else:
                line += "~"
        lines.append(line)
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--budget", type=int, required=True, help="Fence pieces the level hands out")
    parser.add_argument("--beam", type=int, default=6000, help="Pens of each size kept while searching")
    parser.add_argument(
        "--plan",
        action="store_true",
        help="Also print the pen as the bare plan PigpenTests pins the level to",
    )
    parser.add_argument("map", nargs="?", type=argparse.FileType(), default=sys.stdin)
    options = parser.parse_args()

    mud, treats, start, rows, columns = parse(options.map.read())
    points, pen = search(mud, treats, start, rows, columns, options.budget, options.beam)
    if not pen:
        raise SystemExit("No pen holds within that budget")

    print(draw(mud, treats, start, rows, columns, pen))
    if options.plan:
        print()
        print(draw(mud, treats, start, rows, columns, pen, plan_only=True))
    print()
    print(f"mud tiles      {len(mud)}")
    print(f"fence budget   {options.budget}")
    print(f"fences spent   {len(fences_around(pen, mud))}")
    print(f"pen area       {len(pen)}")
    print(f"apples penned  {sum(1 for tile in pen if treats.get(tile) == 'a')}")
    print(f"skulls penned  {sum(1 for tile in pen if treats.get(tile) == 'x')}")
    print(f"maximumScore   {points}")
    print(f"threeStarScore {round(points * 0.94)}")
    print(f"twoStarScore   {round(points * 0.57)}")


if __name__ == "__main__":
    main()
