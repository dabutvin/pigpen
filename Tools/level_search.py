#!/usr/bin/env python3
"""Finds the best pen a Pigpen map has in it, for a given fence budget.

`PuzzleLevel` carries a `maximumScore` that the game uses to tell a player there is
nothing left to beat. It cannot be derived with a sum — it is a search — so it is
authored, and this is what authors it. Feed it an ASCII map (`.` mud, `~` water, `a`
an apple, `x` a skull, `P` the pig's tile, `D` a deer's) and a budget and it prints the
best pen, an example of it, and star thresholds in the proportions the shipped levels use.

    Tools/level_search.py --budget 12 <<'MAP'
    .........
    ~~~~~~~..
    ...a..~..
    ..P...~..
    .........
    MAP

A pen is any run of mud holding every animal on the map and no tile on the rim — an
animal walks straight off the rim — and it costs one fence piece for every mud tile
around its edge. Water costs nothing, which is the whole game. A tile the pen grows
around rather than over is a mud tile on that edge like any other, so burying a skull
under a piece of fencing is a pen with a hole in it, and the search finds those too.

A map with a deer on it as well as the pig is held by ground in two pieces just as
happily as by one, since what has to hold is each animal rather than the pen: the search
grows out from both animals at once and the ground it ends up with is connected to one
or the other, so a wall shared between two enclosures is paid for once, like any other.

A pen scores a point per tile of ground, five more for an apple shut in with an animal
and five fewer for a skull, and never less than a point however sour the ground. The
search grows a pen outwards a tile at a time, keeping the cheapest few thousand pens
of each size along with the ones holding the most for what they cost, which finds the
best pen on maps this size while an exhaustive walk of every pen would not finish at all.

It also squares the map off — the best pen a player gets from a plain block of ground per
animal, no diagonal staircase and no detour for an apple — and prints the two side by
side. The gap between them is what the level is actually asking of the player, and it is
the number to sort a world by: see `--demand`.
"""

import argparse
import itertools
import sys

NEIGHBOURS = ((-1, 0), (1, 0), (0, -1), (0, 1))
# What shutting a tile into the pen is worth, over and above the ground itself.
WORTH = {"a": 5, "x": -5}
# The animals a map can stand on its ground, and the tile each one starts on.
ANIMALS = ("P", "D")


def parse(map_text):
    lines = [line for line in map_text.split("\n") if line.strip()]
    width = len(lines[0])
    if any(len(line) != width for line in lines):
        raise SystemExit("The map is ragged: every row must be the same width")

    mud, treats, starts = set(), {}, {}
    for row, line in enumerate(lines):
        for column, character in enumerate(line):
            if character in ANIMALS:
                if character in starts:
                    raise SystemExit(f"The map stands more than one {character!r} on it")
                starts[character] = (row, column)
                mud.add((row, column))
            elif character in WORTH:
                mud.add((row, column))
                treats[(row, column)] = character
            elif character == ".":
                mud.add((row, column))
            elif character != "~":
                raise SystemExit(f"Unknown terrain {character!r}")
    if "P" not in starts:
        raise SystemExit("The map names no starting tile")
    return mud, treats, starts, len(lines), width


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


def on_rim(tile, rows, columns):
    """Whether a tile is on the edge of the world, where no pen can hold an animal."""
    return tile[0] in (0, rows - 1) or tile[1] in (0, columns - 1)


def search(mud, treats, starts, rows, columns, budget, beam):
    """The best pen within budget, as (score, tiles)."""

    pennable = {tile for tile in mud if not on_rim(tile, rows, columns)}
    for animal, start in starts.items():
        if start not in pennable:
            raise SystemExit(f"{animal!r} starts on the rim of the map, where no pen can hold it")

    def cost(pen):
        return len(fences_around(pen, mud))

    alone = frozenset(starts.values())
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


def run_of_ground(tiles, start):
    """The tiles of `tiles` an animal standing on `start` can walk to."""
    if start not in tiles:
        return set()
    reached, queue = {start}, [start]
    while queue:
        row, column = queue.pop()
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if neighbour in tiles and neighbour not in reached:
                reached.add(neighbour)
                queue.append(neighbour)
    return reached


def blocks_around(pennable, start, rows, columns):
    """Every block of ground that holds `start`.

    A block is a rectangle of the map with the water and the rim taken out of it, so a
    block laid over a lake is the shore it leaves behind — which is what a player does
    without being taught anything: pick two corners and build round what is left. Ground
    the rectangle cuts off from the animal goes with it, since a pen is one run of ground.
    """
    found = set()
    for top in range(1, start[0] + 1):
        for bottom in range(start[0], rows - 1):
            for left in range(1, start[1] + 1):
                for right in range(start[1], columns - 1):
                    inside = {
                        (row, column)
                        for row in range(top, bottom + 1)
                        for column in range(left, right + 1)
                        if (row, column) in pennable
                    }
                    found.add(frozenset(run_of_ground(inside, start)))
    return found - {frozenset()}


def squared_off(mud, treats, starts, rows, columns, budget):
    """The best pen a player gets by squaring the map off, as (score, tiles).

    One block of ground per animal, leaning on whatever water happens to be there, and
    the budget split between them however suits. It is the answer somebody reaches for
    before they know any of the game's ideas — that a staircase wall holds nearly twice
    what a right-angled one does, that a piece laid just short of a gap is worth more
    than one laid in it, that an apple is worth going out of the way for.

    So the gap between this and `search` is what the level is really asking. A level the
    two agree on is one whose best pen is the obvious pen, which is what an early stop on
    a world wants; a wide gap is a level that only gives itself up to a player who has
    learnt something, and those belong further along.
    """
    pennable = {tile for tile in mud if not on_rim(tile, rows, columns)}
    each = [blocks_around(pennable, start, rows, columns) for start in starts.values()]

    best = (0, frozenset())
    for choice in itertools.product(*each):
        # Two animals may not be held by the same ground twice over, and a wall between
        # two blocks is paid for once, so the cost is of the pair together.
        if any(one & other for one, other in itertools.combinations(choice, 2)):
            continue
        pen = frozenset().union(*choice)
        if len(fences_around(pen, mud)) <= budget:
            best = max(best, (score(pen, treats), pen))
    return best


def draw(mud, treats, starts, rows, columns, pen, plan_only=False):
    edge = fences_around(pen, mud)
    standing = {tile: animal for animal, tile in starts.items()}

    lines = []
    for row in range(rows):
        line = ""
        for column in range(columns):
            tile = (row, column)
            if tile in edge:
                line += "#"
            elif plan_only:
                line += "."
            elif tile in standing:
                line += standing[tile]
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
    parser.add_argument(
        "--demand",
        action="store_true",
        help="Also square the map off, and print how much better the best pen is than that",
    )
    parser.add_argument("map", nargs="?", type=argparse.FileType(), default=sys.stdin)
    options = parser.parse_args()

    mud, treats, starts, rows, columns = parse(options.map.read())
    points, pen = search(mud, treats, starts, rows, columns, options.budget, options.beam)
    if not pen:
        raise SystemExit("No pen holds within that budget")

    print(draw(mud, treats, starts, rows, columns, pen))
    if options.plan:
        print()
        print(draw(mud, treats, starts, rows, columns, pen, plan_only=True))

    if options.demand:
        plain, block = squared_off(mud, treats, starts, rows, columns, options.budget)
        print()
        print(draw(mud, treats, starts, rows, columns, block))
        if options.plan:
            print()
            print(draw(mud, treats, starts, rows, columns, block, plan_only=True))

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
    if options.demand:
        print(f"squaredOff     {plain}")
        print(f"demand         {(points - plain) * 100 // points}")


if __name__ == "__main__":
    main()
