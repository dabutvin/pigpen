#!/usr/bin/env python3
"""Finds the best pen a Pigpen map has in it, for a given fence budget.

`PuzzleLevel` carries a `maximumScore` that the game uses to tell a player there is
nothing left to beat. It cannot be derived with a sum — it is a search — so it is
authored, and this is what authors it. Feed it an ASCII map (`.` mud, `~` water, `a`
an apple, `x` a skull, `P` the pig's tile, `D` a deer's, `B` a boar's, `W` a wyrm's, `R` a
rat's, `V` a visitor's, `T` a bat's, `U` its pup's, `M` the ringmaster's, `S` the
scorpion's, `C` the crab's and `L` the bull seal's) and a budget and it prints the best pen,
an example of it,
and star thresholds in the proportions the shipped levels use.

    Tools/level_search.py --budget 12 <<'MAP'
    .........
    ~~~~~~~..
    ...a..~..
    ..P...~..
    .........
    MAP

A pen is any run of mud holding every animal on the map and no tile on the rim — an
animal walks straight off the rim — and it costs one fence piece for every mud tile
around its edge. Water costs nothing, which is the whole game. Anything lying on the
ground is staked into it and takes no fence, so a pen whose edge falls on an apple or a
skull is no pen at all: the treat has to be shut in and paid for, or the wall has to go
round it. The two differ only in what shutting it in is worth — five for the apple and
five against for the skull — which is what makes a treat a fork rather than a bonus or a
tax: the pen can never simply ignore one it is standing next to.

A map with more on it than the pig — a deer, a boar, a wyrm, a rat, a visitor, a bat and its
pup, a ringmaster, a scorpion, a crab, a bull seal, or an old croc — is held by ground in
two pieces just as happily as by one,
since what has to hold is each animal rather than the pen: the search grows out from every
animal at once and the ground it ends up with is connected to one or another of them, so a wall
shared between two enclosures is paid for once, like any other. `--rule berth` is the one board
that will not have that discount, and says so. `--rule moat` is the carnival's ring asked
of a pool rather than a man: the pig's ground has to close round the crab's whole pool,
break and all, with the crab never standing in it. `--rule hole` is the thicket's two-pens
rule with the tundra's own clause on it: the seal is never in with the pig, and his ground
has to lie against the water, because he keeps a breathing hole.

`--rule wallow` is the fen's boss: the pig and the old croc held apart, and the croc's pen
owed one whole channel — every wet tile of one body of water lying against his own ground,
because a croc keeps a wallow rather than visits one, and half a wallow is nobody's.

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
# The apple, which is the treat worth having inside.
APPLE = "a"
# The skull, which is the treat worth keeping out.
SKULL = "x"
# Both of them are staked into the mud, and nothing can be built on top of either.
STAKED = (APPLE, SKULL)
# The animals a map can stand on its ground, and the tile each one starts on. `T` and `U` are
# the caverns' bat and its pup, which are two animals to the board and one roost to the rule.
ANIMALS = ("P", "D", "B", "W", "R", "V", "T", "U", "M", "S", "C", "L", "G")
# The roost: the animals the `roost` rule wants in one pen, with the pig kept out of it.
ROOST = ("T", "U")


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

    Nothing lying on the ground takes a fence, apple or skull alike, so a pen with either
    on its edge cannot be closed there. Such a pen is not thrown away while the search runs
    — growing out over the treat turns it back into a pen that holds — but it is never an
    answer. Which is what makes an apple two things at once: five points if the pen swallows
    it, and a hole in the wall if the pen tries to run through it.
    """
    return all(tile not in treats and tile not in staked for tile in edge)


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
    staked = worth[APPLE] | worth[SKULL]

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

    # The whole board rather than the ground on it, and the way off it. A pen shuts an animal
    # in with fencing and water together; whether one animal is standing *inside* another's pen
    # is a question about the board, so it is asked over every tile there is, wet or dry.
    everywhere = (1 << (rows * columns)) - 1
    first_column, last_column, rim = 0, 0, 0
    for row in range(rows):
        for column in range(columns):
            tile = 1 << (row * columns + column)
            if column == 0:
                first_column |= tile
            if column == columns - 1:
                last_column |= tile
            if row in (0, rows - 1) or column in (0, columns - 1):
                rim |= tile

    def spilling(mask):
        """The same tiles and every tile touching them, kept from wrapping round the edge."""
        return (
            ((mask & ~last_column) << 1)
            | ((mask & ~first_column) >> 1)
            | (mask << columns)
            | (mask >> columns)
        ) & everywhere

    # The eight ways out of the ringmaster, as masks, so how far a pen has got round him is a
    # count of the ones it has crossed. Only the board that asks it needs them.
    if rule == "berth" and "S" not in starts:
        raise SystemExit("--rule berth wants a scorpion on the board")

    # The animal the pig has to go round: the carnival's ringmaster, or the cove's crab —
    # the same question aimed at whoever keeps the middle.
    ringed = "C" if rule == "moat" else "M"
    if rule == "moat" and "C" not in starts:
        raise SystemExit("--rule moat wants a crab on the board")
    if rule == "hole" and "L" not in starts:
        raise SystemExit("--rule hole wants a seal on the board")
    if rule == "wallow" and "G" not in starts:
        raise SystemExit("--rule wallow wants a croc on the board")

    # The ground lying against the water, for the board whose seal must keep a breathing hole.
    lapped = 0
    for tile in mud:
        row, column = tile
        for down, across in NEIGHBOURS:
            neighbour = (row + down, column + across)
            if 0 <= neighbour[0] < rows and 0 <= neighbour[1] < columns and neighbour not in mud:
                lapped |= bit(tile)
                break

    # Every body of water on the board, each as its own mask, for the boss who must be
    # penned with the whole of one.
    wet = {
        (row, column)
        for row in range(rows)
        for column in range(columns)
        if (row, column) not in mud
    }
    bodies = []
    while wet:
        seed = wet.pop()
        body, queue = bit(seed), [seed]
        while queue:
            row, column = queue.pop()
            for down, across in NEIGHBOURS:
                step = (row + down, column + across)
                if step in wet:
                    wet.remove(step)
                    body |= bit(step)
                    queue.append(step)
        bodies.append(body)

    rays = []
    if rule in ("ring", "moat"):
        if ringed not in starts:
            raise SystemExit("--rule ring wants a ringmaster on the board")
        for down, across in ((-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1)):
            mask, row, column = 0, *starts[ringed]
            while True:
                row, column = row + down, column + across
                if not (0 <= row < rows and 0 <= column < columns):
                    break
                mask |= 1 << (row * columns + column)
            rays.append(mask)

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

    def run_of(seed, pen):
        """The tiles of `pen` an animal standing on `seed` can walk to, as a mask."""
        seen, queue = bit(seed), [bit(seed)]
        while queue:
            tile = queue.pop()
            spreading = reach[tile] & pen & ~seen
            while spreading:
                step = spreading & -spreading
                spreading ^= step
                seen |= step
                queue.append(step)
        return seen

    def roost_holds(pen):
        """Whether a pen keeps the roost together and the pig out of it.

        Two questions at once, which is what makes it the sixth rule rather than a fourth
        turn of the third: the bat and its pup have to be in one run of ground, and the pig
        has to be in another. The pen that holds everything on the board is refused, and so
        is the pen that hangs the pup on its own.
        """
        mine = run_of(starts["P"], pen)
        if mine & (bit(starts["T"]) | bit(starts["U"])):
            return False
        return bool(run_of(starts["T"], pen) & bit(starts["U"]))

    def encircled(mine):
        """Whether every way off the board from the ringmaster crosses the pig's ground.

        Walked over the whole board rather than over the mud, so the crowd is no help: a
        ringmaster standing on an island in the middle of a pond would otherwise be surrounded
        before a single piece was laid, and the one thing this rule asks is that the pig go
        round him. Water is a wall to an animal and no wall at all to this question.
        """
        reached = bit(starts[ringed])
        while True:
            wider = (reached | spilling(reached)) & ~mine
            if wider & rim:
                return False
            if wider == reached:
                return True
            reached = wider

    def ring_holds(pen):
        """Whether the pen leaves the ringmaster in the middle of the pig's own ground.

        Two things, as with the roost, and again they pull opposite ways: the pig may not be
        standing in with him, and the pig's ground has to close all the way round him. The pen
        that holds the pair together is refused, and so is the tidy pair of pens side by side.
        """
        mine = run_of(starts["P"], pen)
        if mine & bit(starts[ringed]):
            return False
        return encircled(mine)

    def berth_holds(pen):
        """Whether the pen gives the scorpion a wide berth: two pens, and no wall doing for both.

        The one rule in the game that takes the discount away. Everywhere else a mud tile with
        the pig on one side of it and something else on the other is one piece paying for two
        enclosures, which is what makes a boss cheaper than two boards; a sting goes through a
        fence, so here it is no wall at all and the ground between the two pens has to be left
        unclaimed.
        """
        mine = run_of(starts["P"], pen)
        if mine & bit(starts["S"]):
            return False
        theirs = run_of(starts["S"], pen)
        # A mud tile outside the pen and touching both runs is exactly the shared wall the
        # scorpion refuses. Sand between them is another matter: a dune is not a fence.
        return not (spilling(mine) & spilling(theirs) & ground & ~pen)

    def keeps_the_rule(pen):
        """Whether a pen that holds is one this board will actually accept."""
        if rule == "wallow":
            # The thicket's rule first — a croc is not company — and then the fen's own:
            # somewhere on the board there has to be one whole channel every bank of which
            # is the croc's own ground, because a croc keeps a wallow rather than visits
            # one, and half a wallow is nobody's.
            if run_of(starts["P"], pen) & bit(starts["G"]):
                return False
            reach_of_croc = spilling(run_of(starts["G"], pen))
            return any(body & reach_of_croc == body for body in bodies)
        if rule == "hole":
            # The thicket's rule first — a seal is not company — and then the tundra's own:
            # somewhere in the seal's ground there has to be a tile lying against the water,
            # or he has been penned away from his breathing hole.
            if run_of(starts["P"], pen) & bit(starts["L"]):
                return False
            return bool(run_of(starts["L"], pen) & lapped)
        if rule == "berth":
            return berth_holds(pen)
        if rule in ("ring", "moat"):
            return ring_holds(pen)
        if rule == "roost":
            return roost_holds(pen)
        if rule not in ("apart", "together", "even"):
            return True
        # All three rules turn on the same question first — whether the pig can walk to the
        # other one without leaving the pen — and want different answers: `together` refuses
        # ground the two do not share, and `apart` and `even` refuse ground they do.
        mine = run_of(starts["P"], pen)
        shared = bool(mine & bit(others[0]))
        if rule == "together":
            return shared
        if rule == "apart":
            return not shared
        if shared:
            return False
        # `even` then asks the thing no rule has asked before: that the two pens hold the
        # same amount of ground. It is what stops one budget being spent almost entirely on
        # one animal, which every other two-animal rule allows and most boards reward.
        return mine.bit_count() == run_of(others[0], pen).bit_count()

    def divided(grown, cost):
        """Which pens are worth widening on a board that wants two pens of the same size.

        A pen only ever grows, so a pen whose ground the pig can already walk from itself to
        the other animal will never come apart again: for `even` those are not slow
        candidates but impossible ones, and every one of them dropped is room in the beam for
        a pen that could still be an answer. Which matters here and nowhere else — two pens
        need a wall between them that one pen does not, so a beam kept by cost alone fills up
        with single blobs and the rule's own shape is gone long before it is big enough to
        win.

        The cheapest divided pen of a given size is the most lopsided one — a tile of ground
        for the visitor and all the rest for the pig costs less wall than any fair split of
        the same ground — so cost alone would throw the answer away too. A share of the beam
        is therefore set aside for each way the ground comes out divided.
        """
        ordered = sorted(grown, key=lambda pen: cost[pen])
        keeping, shares = set(), {}
        for pen in ordered[: beam * 4]:
            mine = run_of(starts["P"], pen)
            if mine & bit(others[0]):
                continue
            share = shares.setdefault(mine.bit_count(), 0)
            if len(keeping) < beam or share < beam // 8:
                shares[mine.bit_count()] = share + 1
                keeping.add(pen)
        return keeping

    def spaced(grown, cost):
        """Which pens are worth widening on a board that wants clear ground between two pens.

        `divided`'s problem with one clause more. Two pens need a wall between them that one pen
        does not, so a beam kept by cost alone fills up with single blobs; and the cheapest
        divided pen of a given size is the most lopsided one, so cost alone throws away the fair
        split as well. Hence the same shares of the beam, one for each way the ground comes out
        divided.

        What is new is that a pen can be spoilt for good rather than merely be behind. A pen only
        ever grows, so once the pig can walk from her ground into the scorpion's — or once one mud
        tile touches both — no amount of widening puts it right: widening either leaves that tile
        a shared wall or takes it into the pen, which joins the two runs into one. So those are
        dropped outright, and every one dropped is room for a pen that could still be an answer.
        """
        ordered = sorted(grown, key=lambda pen: cost[pen])
        keeping, shares = set(), {}
        for pen in ordered[: beam * 4]:
            mine = run_of(starts["P"], pen)
            if mine & bit(starts["S"]):
                continue
            theirs = run_of(starts["S"], pen)
            if spilling(mine) & spilling(theirs) & ground & ~pen:
                continue
            share = shares.setdefault(mine.bit_count(), 0)
            if len(keeping) < beam or share < beam // 8:
                shares[mine.bit_count()] = share + 1
                keeping.add(pen)
        return keeping

    def hanging(grown, cost):
        """Which pens are worth widening on a board that wants the roost in one pen.

        Two things have to be true of the answer and only one of them can be pruned for. A
        pen the pig can already walk out of into a bat will never come apart again, so those
        are impossible rather than slow and every one dropped is room in the beam for a pen
        that could still win. The other half is the opposite: the bat and its pup start apart,
        and the pen that joins them costs more wall than the pen that leaves them hanging in
        separate corners — so cost alone would throw the answer away every time. A share of
        the beam is therefore held back for pens that have already gathered the roost.
        """
        ordered = sorted(grown, key=lambda pen: cost[pen])
        keeping, gathered = set(), 0
        for pen in ordered[: beam * 4]:
            if run_of(starts["P"], pen) & (bit(starts["T"]) | bit(starts["U"])):
                continue
            joined = bool(run_of(starts["T"], pen) & bit(starts["U"]))
            if len(keeping) < beam:
                keeping.add(pen)
                gathered += 1 if joined else 0
            elif joined and gathered < beam // 2:
                keeping.add(pen)
                gathered += 1
        return keeping

    def breathing(grown, cost):
        """Which pens are worth widening on a board whose seal must reach the water.

        A pen the pig can already walk out of into the seal is impossible rather than slow,
        so those go, as in every two-pen rule. The other half is the seal's hole: the pens
        whose seal-ground already lies against the water cost more wall than the ones that
        pen him tight where he stands, so a beam kept by cost alone starves the only pens
        that can be answers. A share of it is held back for the ones already breathing.
        """
        ordered = sorted(grown, key=lambda pen: cost[pen])
        keeping, lapping = set(), 0
        for pen in ordered[: beam * 4]:
            if run_of(starts["P"], pen) & bit(starts["L"]):
                continue
            if len(keeping) < beam:
                keeping.add(pen)
                lapping += 1 if run_of(starts["L"], pen) & lapped else 0
            elif lapping < beam // 2 and run_of(starts["L"], pen) & lapped:
                keeping.add(pen)
                lapping += 1
        return keeping

    def wading(grown, cost):
        """Which pens are worth widening on a board whose croc must own a whole wallow.

        A pen the pig can already walk out of into the croc is impossible rather than
        slow, so those go, as in every two-pen rule. The rest have `circling`'s problem
        knee-deep: a pen that means to own every bank of a channel only gets there on the
        last tile of the way round it, and costs more than a blob of the same ground every
        step before that — so the pens are sorted into how many wet tiles the croc's
        ground already laps, and each rung keeps its own share of the beam.
        """
        buckets = {}
        for pen in grown:
            his = run_of(starts["G"], pen)
            if his & bit(starts["P"]):
                continue
            reach_of_croc = spilling(his)
            lapping = (reach_of_croc & ~ground & everywhere).bit_count()
            shut = any(body & reach_of_croc == body for body in bodies)
            buckets.setdefault((lapping, shut), []).append(pen)

        keeping = set()
        share = max(beam // 8, 1)
        for penned in buckets.values():
            penned.sort(key=lambda pen: cost[pen])
            keeping.update(penned[:share])
        return keeping

    def circling(grown, cost):
        """Which pens are worth widening on a board that wants one pen inside another.

        A pen the pig can already walk out of into the ringmaster will never come apart again,
        so those go. The rest are a harder problem than any rule before this one: the answer is
        a pen with a hole in it, and a pen with a hole in it costs more wall than the same
        ground in a blob every step of the way there, so a beam kept by cost is a beam of
        blobs. Nor can the pens that already close be held back on their own the way the roost's
        are — a pen only encircles on the very last tile of the loop, and by then the search
        has thrown away everything that was on its way to being one.

        So the pens are sorted into how far round they have got: the eight compass rays out of
        the ringmaster, counted by how many of them the pig's ground has crossed. A blob beside
        him crosses two or three, a horseshoe round him crosses seven, and the pen that wins
        crosses all eight and has shut. Each of those is a bucket with its own share of the
        beam, and the sorting by cost happens inside a bucket rather than across the lot — which
        is the whole trick, since a horseshoe never wins a race against a blob on price.

        The pig's ground is taken as the pen less the ringmaster's own run rather than by
        walking out from the pig. A pen only ever grows from the tiles the animals started on,
        so it is in one piece or two and never three, and his piece is the small one.
        """
        buckets = {}
        for pen in grown:
            theirs = run_of(starts[ringed], pen)
            if theirs & bit(starts["P"]):
                continue
            mine = pen & ~theirs
            crossed = sum(1 for ray in rays if mine & ray)
            shut = crossed == 8 and encircled(mine)
            buckets.setdefault((crossed, shut), []).append(pen)

        keeping = set()
        share = max(beam // 8, 1)
        for penned in buckets.values():
            penned.sort(key=lambda pen: cost[pen])
            keeping.update(penned[:share])
        return keeping

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
        # treat, since growing out over the treat is what makes it buildable. Kept
        # alongside them are the pens holding the most for what they cost, so a pen that
        # went out of its way for an apple is not dropped for a tidier one.
        cheapest = sorted(grown, key=lambda pen: cost[pen])[:beam]
        thriftiest = sorted(grown, key=lambda pen: cost[pen] - held[pen])[: beam // 2]
        keeping = set(cheapest)
        keeping.update(thriftiest)
        if rule == "even":
            keeping = divided(grown, cost)
        if rule == "roost":
            keeping = hanging(grown, cost)
        if rule in ("ring", "moat"):
            keeping = circling(grown, cost)
        if rule == "hole":
            keeping = breathing(grown, cost)
        if rule == "wallow":
            keeping = wading(grown, cost)
        if rule == "berth":
            keeping = spaced(grown, cost)
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


def shut_inside(tile, pen, rows, columns):
    """Whether every way off the board from `tile` crosses `pen`.

    The set-of-tiles twin of the search's own `encircled`, for squaring a carnival board off.
    Walked over the whole board rather than over the mud, so a crowd standing round the
    ringmaster is no help to him: the ring has to be the pig's own ground.
    """
    reached, queue = {tile}, [tile]
    while queue:
        row, column = queue.pop()
        for down, across in NEIGHBOURS:
            step = (row + down, column + across)
            if not (0 <= step[0] < rows and 0 <= step[1] < columns):
                return False
            if step not in reached and step not in pen:
                reached.add(step)
                queue.append(step)
    return True


def wall_between(mine, theirs, mud, pen):
    """Whether one fence piece would do for both pens, for squaring a dune board off.

    The set-of-tiles twin of what `berth_holds` asks in the search: a mud tile lying outside the
    pen altogether with one run of ground on one side of it and the other run on the other.
    """
    return bool((fences_around(mine, mud) & fences_around(theirs, mud)) - set(pen))


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


def nudged_over_treats(pen, mud, treats, rows, columns):
    """A block of ground with the wall bumped out round whatever it cannot be built on.

    Nothing lying on the ground takes a fence, so a rectangle whose edge happens to fall on
    an apple or a skull is not a pen at all. That is not, however, the end of squaring a map
    off: a player who lays out the obvious block and finds a treat in the wall's way does the
    obvious local thing and takes it inside, which costs a piece or two and changes nothing
    else about the shape. Swallowing widens the edge, which can turn up another treat, so it
    is run to a standstill.

    Taking it in rather than stepping round it is the same closure the game itself promises
    with `smallestPen` — and on an apple it is what a player would want anyway.

    What cannot be swallowed is a treat lying on the rim. Nothing on the rim can ever be shut
    in — an animal standing there is already off the map — so a block whose wall wants that
    tile has nowhere to bump out to, and is no block at all. Returns nothing for those.
    """
    pen = set(pen)
    while True:
        staked = {tile for tile in fences_around(pen, mud) if tile in treats}
        if not staked:
            return frozenset(pen)
        if any(on_rim(tile, rows, columns) for tile in staked):
            return None
        pen |= staked


def bodies_of_water(mud, rows, columns):
    """Every body of water on the board, each as its own set of tiles."""
    wet = {
        (row, column)
        for row in range(rows)
        for column in range(columns)
        if (row, column) not in mud
    }
    bodies = []
    while wet:
        seed = wet.pop()
        body, queue = {seed}, [seed]
        while queue:
            row, column = queue.pop()
            for down, across in NEIGHBOURS:
                step = (row + down, column + across)
                if step in wet:
                    wet.remove(step)
                    body.add(step)
                    queue.append(step)
        bodies.append(body)
    return bodies


def owns_a_wallow(his, bodies):
    """Whether one whole body of water lies against this run of ground — every wet tile of
    it beside a tile of his — which is what owning a wallow is."""
    banks = set()
    for row, column in his:
        for down, across in NEIGHBOURS:
            banks.add((row + down, column + across))
    return any(body <= banks for body in bodies)


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

    Since nothing lying on the ground takes a fence, the block is nudged out over any treat
    its wall would have wanted before it is weighed — otherwise a single apple sitting on the
    obvious wall line would say the map has no obvious pen at all, which is not what a player
    holding a fence and looking at an apple does.
    """
    pennable = {tile for tile in mud if not on_rim(tile, rows, columns)}
    others = [tile for animal, tile in starts.items() if animal != "P"]
    staked = set(others) if rule == "exclude" else set()
    ringed = starts.get("C" if rule == "moat" else "M")
    if rule == "exclude":
        # Only the pig is being held, and no block may swallow the one left outside.
        pennable = pennable - set(others)
        each = [blocks_around(pennable, starts["P"], rows, columns)]
    elif rule == "together":
        # One pen holds the pair, so squaring the map off is one rectangle rather than two:
        # the block a player picks is the one with both animals standing in it.
        each = [blocks_around(pennable, starts["P"], rows, columns)]
    elif rule in ("ring", "moat"):
        # One block round the pig and one round whoever keeps the middle, the same as any
        # two-animal board. What squaring off cannot do here is make a ring out of nothing:
        # the only rectangle that comes out with a hole in it is one laid over a crowd or a
        # pool, so the boards that have an obvious answer at all are the ones with something
        # already standing partway round him.
        each = [
            blocks_around(pennable, starts["P"], rows, columns),
            blocks_around(pennable, ringed, rows, columns),
        ]
    elif rule == "roost":
        # Two blocks rather than three: one round the pig, and one that has to have both the
        # bat and its pup standing in it, since the roost is one pen however many bats it is.
        each = [
            blocks_around(pennable, starts["P"], rows, columns),
            {
                block
                for block in blocks_around(pennable, starts["T"], rows, columns)
                if starts["U"] in block
            },
        ]
    else:
        each = [blocks_around(pennable, start, rows, columns) for start in starts.values()]

    best = (0, frozenset())
    for choice in itertools.product(*each):
        # Two animals may not be held by the same ground twice over, and a wall between
        # two blocks is paid for once, so the cost is of the pair together.
        if any(one & other for one, other in itertools.combinations(choice, 2)):
            continue
        # Nudged out over its treats before anything is asked of it, since that is the pen
        # the player would actually be holding, and every rule below turns on its shape.
        pen = nudged_over_treats(frozenset().union(*choice), mud, treats, rows, columns)
        if pen is None:
            continue
        # A board that keeps two apart is not squared off by a pair of blocks that touch,
        # since ground the pig can walk from one into the other is one pen, not two.
        if rule in ("apart", "even", "hole", "wallow") and others:
            if others[0] in run_of_ground(pen, starts["P"]):
                continue
        # And a board that wants the same ground in each is not squared off by a big block
        # and a little one: the blocks a player picks have to come out the same size.
        if rule == "even" and others:
            if len(run_of_ground(pen, starts["P"])) != len(run_of_ground(pen, others[0])):
                continue
        # And a board that wants them in one pen is not squared off by a block that leaves
        # the other one standing outside it.
        if rule == "together" and others:
            if others[0] not in run_of_ground(pen, starts["P"]):
                continue
        # The caverns want both at once: the pig's block clear of the roost, and the roost's
        # block holding the pair of them. Two blocks that meet are one pen, not two.
        if rule == "roost":
            mine = run_of_ground(pen, starts["P"])
            if starts["T"] in mine or starts["U"] in mine:
                continue
            if starts["U"] not in run_of_ground(pen, starts["T"]):
                continue
        # And the carnival wants one block standing inside the other: the pig clear of the
        # ringmaster, and his ground with no way off the board that does not cross hers.
        if rule in ("ring", "moat"):
            mine = run_of_ground(pen, starts["P"])
            if ringed in mine:
                continue
            if not shut_inside(ringed, mine, rows, columns):
                continue
        # And the dunes want the two blocks standing well apart: not merely two blocks rather
        # than one, but two with clear ground between them, since a piece laid where the pig is
        # on one side and the scorpion on the other is no wall to a sting.
        if rule == "berth":
            mine = run_of_ground(pen, starts["P"])
            if starts["S"] in mine:
                continue
            if wall_between(mine, run_of_ground(pen, starts["S"]), mud, pen):
                continue
        # And the fen will not have the croc short-changed: his block only counts if one
        # whole channel lies against his ground, every wet tile of it.
        if rule == "wallow" and others:
            if not owns_a_wallow(
                run_of_ground(pen, others[0]), bodies_of_water(mud, rows, columns)
            ):
                continue
        # And the tundra will not have the seal penned dry: a block pair only counts if some
        # tile of his block lies against the water, where his breathing hole is.
        if rule == "hole" and others:
            his = run_of_ground(pen, others[0])
            if not any(
                (tile[0] + down, tile[1] + across) not in mud
                and 0 <= tile[0] + down < rows
                and 0 <= tile[1] + across < columns
                for tile in his
                for down, across in NEIGHBOURS
            ):
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
        choices=("herd", "apart", "exclude", "together", "even", "roost", "ring", "berth", "moat", "hole", "wallow"),
        default="herd",
        help="What a board with more than the pig on it asks: hold both, hold them apart, "
             "hold the pig and shut the other one out, hold the pair in a single pen, "
             "hold them in two pens with the same ground in each, hold the roost in one "
             "pen with the pig in another, hold the ringmaster in the middle of the "
             "pig's own ring, hold the two in pens that share no wall, close the "
             "pig's ground round the crab's whole pool, hold the pair apart with "
             "the seal's ground lying against the water, or hold the pair apart with "
             "one whole channel's every bank held as the croc's own ground",
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
