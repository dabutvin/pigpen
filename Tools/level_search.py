#!/usr/bin/env python3
"""Finds the biggest pen a Pigpen map has in it, for a given fence budget.

`PuzzleLevel` carries a `maximumArea` that the game uses to tell a player there is
nothing left to beat. It cannot be derived with a sum — it is a search — so it is
authored, and this is what authors it. Feed it an ASCII map (`.` mud, `~` water, `P`
the pig's tile) and a budget and it prints the largest pen, an example of it, and
star thresholds in the proportions the shipped levels use.

    Tools/level_search.py --budget 12 <<'MAP'
    .........
    ~~~~~~~..
    ......~..
    ..P...~..
    .........
    MAP

A pen is any connected run of mud holding the pig and no tile on the rim of the map —
the pig walks straight off the rim — and it costs one fence piece for every mud tile
around its edge. Water costs nothing, which is the whole game. The search grows a pen
outwards a tile at a time, keeping the cheapest few thousand pens of each size, which
finds the best pen on maps this size while an exhaustive walk of every pen would not
finish at all.
"""

import argparse
import sys

NEIGHBOURS = ((-1, 0), (1, 0), (0, -1), (0, 1))


def parse(map_text):
    lines = [line for line in map_text.split("\n") if line.strip()]
    width = len(lines[0])
    if any(len(line) != width for line in lines):
        raise SystemExit("The map is ragged: every row must be the same width")

    mud, start = set(), None
    for row, line in enumerate(lines):
        for column, character in enumerate(line):
            if character == "P":
                if start is not None:
                    raise SystemExit("The map names more than one starting tile")
                start = (row, column)
                mud.add(start)
            elif character == ".":
                mud.add((row, column))
            elif character != "~":
                raise SystemExit(f"Unknown terrain {character!r}")
    if start is None:
        raise SystemExit("The map names no starting tile")
    return mud, start, len(lines), width


def search(mud, start, rows, columns, budget, beam):
    """The biggest pen within budget, as (area, tiles)."""

    def on_rim(tile):
        return tile[0] in (0, rows - 1) or tile[1] in (0, columns - 1)

    pennable = {tile for tile in mud if not on_rim(tile)}
    if start not in pennable:
        raise SystemExit("The pig starts on the rim of the map, where no pen can hold it")

    def cost(pen):
        edge = set()
        for row, column in pen:
            for down, across in NEIGHBOURS:
                neighbour = (row + down, column + across)
                if neighbour in mud and neighbour not in pen:
                    edge.add(neighbour)
        return len(edge)

    best = (1, frozenset({start})) if cost({start}) <= budget else (0, frozenset())
    live = {frozenset({start})}

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

        within = [(len(pen), pen) for pen, spent in grown.items() if spent <= budget]
        if within:
            best = max(best, max(within))

        # Cheap pens are the ones worth widening: a pen over budget is not thrown away,
        # since filling in a notch can hand a piece back, but it queues behind the rest.
        live = {pen for pen, _ in sorted(grown.items(), key=lambda item: item[1])[:beam]}

    return best


def draw(mud, start, rows, columns, pen):
    edge = set()
    for row, column in pen:
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if neighbour in mud and neighbour not in pen:
                edge.add(neighbour)

    lines = []
    for row in range(rows):
        line = ""
        for column in range(columns):
            tile = (row, column)
            if tile == start:
                line += "P"
            elif tile in edge:
                line += "#"
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
    parser.add_argument("map", nargs="?", type=argparse.FileType(), default=sys.stdin)
    options = parser.parse_args()

    mud, start, rows, columns = parse(options.map.read())
    area, pen = search(mud, start, rows, columns, options.budget, options.beam)
    if not pen:
        raise SystemExit("No pen holds within that budget")

    print(draw(mud, start, rows, columns, pen))
    print()
    print(f"mud tiles      {len(mud)}")
    print(f"fence budget   {options.budget}")
    print(f"maximumArea    {area}")
    print(f"threeStarArea  {round(area * 0.94)}")
    print(f"twoStarArea    {round(area * 0.57)}")


if __name__ == "__main__":
    main()
