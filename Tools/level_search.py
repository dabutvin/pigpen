#!/usr/bin/env python3
"""Finds the best pen a Pigpen map has in it, for a given fence budget.

`PuzzleLevel` carries a `maximumScore` that the game uses to tell a player there is
nothing left to beat. It cannot be derived with a sum — it is a search — so it is
authored, and this is what authors it. Feed it an ASCII map (`.` mud, `~` water, `a`
an apple, `x` a skull, `P` the pig's tile, `D` a deer's, `B` a boar's, `W` a wyrm's) and a budget and
it prints the best pen, an example of it, and star thresholds in the proportions the
shipped levels use.

    Tools/level_search.py --budget 12 <<'MAP'
    .........
    ~~~~~~~..
    ...a..~..
    ..P...~..
    .........
    MAP

A pen is any run of mud holding every animal on the map and no tile on the rim — an
animal walks straight off the rim — and it costs one fence piece for every mud tile
around its edge. Water costs nothing, which is the whole game. A skull is staked into
the ground and takes no fence, so a pen whose edge falls on one is no pen at all: the
skull has to be shut in and paid for, or the wall has to go round it.

A map with a second animal on it as well as the pig — a deer, a boar or a wyrm — is held by
ground in two pieces just as happily as by one, since what has to hold is each animal
rather than the pen: the search grows out from both animals at once and the ground it
ends up with is connected to one or the other, so a wall shared between two enclosures
is paid for once, like any other.

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
# A skull is staked into the mud, and nothing can be built on top of it.
SKULL = "x"
# The animals a map can stand on its ground, and the tile each one starts on.
ANIMALS = ("P", "D", "B", "W")


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
    was grown around rather than over, which is a hole to be plugged like any other."""
    edge = set()
    for row, column in pen:
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if neighbour in mud and neighbour not in pen:
                edge.add(neighbour)
    return edge


def can_be_walled(edge, treats, staked=()):
    """Whether the wall a pen needs is one that could actually be built.

    A skull takes no fence, so a pen with one on its edge cannot be closed there. Such a
    pen is not thrown away while the search runs — growing out over the skull turns it
    back into a pen that holds — but it is never an answer.
    """
    return all(treats.get(tile) != SKULL and tile not in staked for tile in edge)


def on_rim(tile, rows, columns):
    """Whether a tile is on the edge of the world, where no pen can hold an animal."""
    return tile[0] in (0, rows - 1) or tile[1] in (0, columns - 1)


def search(mud, treats, starts, rows, columns, budget, beam, rule="herd"):
    """The best pen within budget, as (score, tiles).

    The pens are carried as bitmasks — one bit per tile of the board — rather than as sets
    of coordinates, which is the same search written so that it finishes in a second rather
    than half a minute. Growing a pen by every tile it could take is then one machine word
    of arithmetic per pen instead of a walk over its tiles and their neighbours, and the
    walls are counted with a popcount. Nothing about which pens are kept changes, and the
    shipped levels come out at exactly the numbers they came out at before, which is what
    `PuzzleLevelTests` is there to say.
    """

    def bit(tile):
        return 1 << (tile[0] * columns + tile[1])

    ground = 0
    for tile in mud:
        ground |= bit(tile)

    pennable = 0
    for tile in mud:
        if not on_rim(tile, rows, columns):
            pennable |= bit(tile)

    worth = {}
    for treat, points in WORTH.items():
        mask = 0
        for tile, lying in treats.items():
            if lying == treat:
                mask |= bit(tile)
        worth[treat] = mask
    staked = worth[SKULL]

    # Every tile a pen touching this one has along its edge, so widening a pen is a single
    # union rather than a walk over the tiles it has just gained.
    reach = {}
    for tile in mud:
        row, column = tile
        mask = 0
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if 0 <= neighbour[0] < rows and 0 <= neighbour[1] < columns:
                mask |= bit(neighbour)
        reach[bit(tile)] = mask

    for animal, start in starts.items():
        if not bit(start) & pennable:
            raise SystemExit(f"{animal!r} starts on the rim of the map, where no pen can hold it")

    def points(pen):
        if not pen:
            return 0
        return max(
            1,
            pen.bit_count()
            + 5 * (pen & worth["a"]).bit_count()
            - 5 * (pen & worth[SKULL]).bit_count(),
        )

    def holds(edge):
        """Whether a wall of these tiles is within budget and can be built at all."""
        return edge.bit_count() <= budget and not edge & staked

    # Which animals the pen has to grow from, and which tile it may never cover.
    others = [tile for animal, tile in starts.items() if animal != "P"]
    if rule == "exclude":
        if len(others) != 1:
            raise SystemExit("--rule exclude wants exactly one animal besides the pig")
        seeds = [starts["P"]]
        # The one left outside is a hole in the ground the wall can neither cover nor stand
        # on: no piece may be laid on an animal, so its tile is staked exactly like a skull.
        pennable &= ~bit(others[0])
        staked |= bit(others[0])
    else:
        seeds = list(starts.values())

    def keeps_the_rule(pen):
        """Whether a pen that holds is one this board will actually accept."""
        if rule != "apart":
            return True
        # The two will not share ground, so the pig's run of it must not reach the other.
        seen, queue = bit(starts["P"]), [bit(starts["P"])]
        while queue:
            tile = queue.pop()
            spreading = reach[tile] & pen & ~seen
            while spreading:
                step = spreading & -spreading
                spreading ^= step
                seen |= step
                queue.append(step)
        return not seen & bit(others[0])

    alone, touching = 0, 0
    for start in seeds:
        alone |= bit(start)
        touching |= reach[bit(start)]

    best = (points(alone), alone) if (
        holds(touching & ground & ~alone) and keeps_the_rule(alone)
    ) else (0, 0)
    live = {alone: touching}

    while live:
        grown = {}
        for pen, halo in live.items():
            taking = halo & pennable & ~pen
            while taking:
                tile = taking & -taking
                taking ^= tile
                wider = pen | tile
                if wider not in grown:
                    grown[wider] = halo | reach[tile]

        if not grown:
            break

        cost, held = {}, {}
        for pen, halo in grown.items():
            edge = halo & ground & ~pen
            cost[pen] = edge.bit_count()
            held[pen] = points(pen)
            if holds(edge) and held[pen] > best[0] and keeps_the_rule(pen):
                best = (held[pen], pen)

        # Cheap pens are the ones worth widening: a pen over budget is not thrown away,
        # since filling in a notch can hand a piece back, and nor is one walled over a
        # skull, since growing out over the skull is what makes it buildable. Kept
        # alongside them are the pens holding the most for what they cost, so a pen that
        # went out of its way for an apple is not dropped for a tidier one.
        cheapest = sorted(grown, key=lambda pen: cost[pen])[:beam]
        thriftiest = sorted(grown, key=lambda pen: cost[pen] - held[pen])[: beam // 2]
        keeping = set(cheapest)
        keeping.update(thriftiest)
        live = {pen: grown[pen] for pen in keeping}

    return best[0], spread(best[1], columns)


def spread(pen, columns):
    """A pen carried as a bitmask, back as the set of tiles the rest of the tool speaks in."""
    tiles = set()
    index = 0
    while pen:
        if pen & 1:
            tiles.add((index // columns, index % columns))
        pen >>= 1
        index += 1
    return frozenset(tiles)


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


def squared_off(mud, treats, starts, rows, columns, budget, rule="herd"):
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
    others = [tile for animal, tile in starts.items() if animal != "P"]
    staked = set(others) if rule == "exclude" else set()
    if rule == "exclude":
        # Only the pig is being held, and no block may swallow the one left outside.
        pennable = pennable - set(others)
        each = [blocks_around(pennable, starts["P"], rows, columns)]
    else:
        each = [blocks_around(pennable, start, rows, columns) for start in starts.values()]

    best = (0, frozenset())
    for choice in itertools.product(*each):
        # Two animals may not be held by the same ground twice over, and a wall between
        # two blocks is paid for once, so the cost is of the pair together.
        if any(one & other for one, other in itertools.combinations(choice, 2)):
            continue
        pen = frozenset().union(*choice)
        # A board that keeps two apart is not squared off by a pair of blocks that touch,
        # since ground the pig can walk from one into the other is one pen, not two.
        if rule == "apart" and others:
            if others[0] in run_of_ground(pen, starts["P"]):
                continue
        edge = fences_around(pen, mud)
        if len(edge) <= budget and can_be_walled(edge, treats, staked):
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
        "--rule",
        choices=("herd", "apart", "exclude"),
        default="herd",
        help="What a board with a second animal on it asks: hold both, hold them apart, or "
             "hold the pig and shut the other one out",
    )
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
    points, pen = search(mud, treats, starts, rows, columns, options.budget, options.beam, options.rule)
    if not pen:
        raise SystemExit("No pen holds within that budget")

    print(draw(mud, treats, starts, rows, columns, pen))
    if options.plan:
        print()
        print(draw(mud, treats, starts, rows, columns, pen, plan_only=True))

    if options.demand:
        plain, block = squared_off(mud, treats, starts, rows, columns, options.budget, options.rule)
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
