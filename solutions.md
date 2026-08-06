# Solutions

**Spoilers.** This is the best pen for every puzzle in Mudlark Meadow — the pen each
level goes rainbow for, worth exactly the `maximumScore` it claims. Reading it gives away
the whole game.

These are not the *only* pens worth three stars; the third star is set a little under the
maximum, so most levels have several arrangements that earn it. Each one below is the pen
the level was authored around, found by `Tools/level_search.py` and pinned in
`PigpenTests/PuzzleLevelTests.swift`, which replays it and fails if the level stops giving
up what it promises.

## How to read a diagram

```
#  a fence piece            o  ground inside the pen
P  the pig                  .  mud outside the pen
D  the deer                 ~  water
a  an apple                 x  a skull
```

A treat inside the pen shows as its own letter on `o` ground. A treat with a `#` on it has
been fenced over: an apple wasted, or a skull buried.

A pen scores a point per tile of ground it holds, five more for every apple inside it and
five fewer for every skull.

| # | Level | Pieces | Ground held | In the pen | Score |
|---|---|---|---|---|---|
| 1 | River Bend | 12 | 35 | — | 35 |
| 2 | Puddle Corner | 8 | 26 | — | 26 |
| 3 | Horseshoe Lake | 6 | 24 | — | 24 |
| 4 | The Narrows | 10 | 22 | — | 22 |
| 5 | Otter Ford | 12 | 24 | — | 24 |
| 6 | The Big Meadow | 16 | 33 | — | 33 |
| 7 | Windfall Orchard | 12 | 27 | 2 apples | 37 |
| 8 | Sour Ground | 14 | 22 | 2 apples, 2 skulls buried | 32 |
| 9 | Stag Mere | 20 | 31 | 3 apples, 2 skulls buried | 46 |

Every one of these spends its whole budget.

## What the solutions have in common

Four ideas cover all nine maps, and every level is one of them dressed differently.

- **Water is a wall you already own.** Build against it, never near it. Half of what looks
  like a hard budget is a map where the shore does most of the walling for free.
- **Fence on the diagonal.** A piece laid on a diagonal blocks two ways past it, so a
  staircase wall encloses roughly twice the ground a right-angled one does for the same
  count. Puddle Corner is the clearest case: eight pieces in a staircase hold 26 tiles,
  where the best rectangle those eight can make holds 16. Out in open country this comes
  out as an octagon — a box with its corners cut off.
- **The pen can never hold a tile on the rim of the map,** because walling that tile would
  need a piece off the edge. So the fencing itself ends up standing on the rim, and a pen
  that reaches its limit is one whose wall runs along the edge of the world.
- **Fence just short of a gap, not in it.** Plugging a one-tile gap from the near side
  costs the same one piece and hands you the gap tile as ground. Otter Ford turns on this.

The boss adds a fifth: **two pens can share a wall.** Water between two animals is one
boundary doing two jobs, so holding them apart costs less than dragging a single pen round
both — and then the only question left is how to split the budget between the two.

## 1. River Bend — 12 pieces, 35

```
.........
.........
~~~~~~~..
#ooooo~..
#ooooo~..
#ooooo~..
#oPooo~..
#ooooo~..
#ooooo~~.
#ooooo~~.
.#####...
```

The river walls the north and the pond walls the east, so only two sides are yours to
build. Seven pieces straight down the west edge and five along the south close it, and the
pen takes every tile the water leaves reachable — 35 of the map's 83. The same twelve
pieces spent on a free-standing box out in the meadow hold 9.

## 2. Puddle Corner — 8 pieces, 26

```
~~~~~~~~
~oooooo#
~oooooo#
~ooPoo#.
~oooo#..
~ooo#...
~oo#....
.##.....
```

Two whole sides are water, so the eight pieces only have to cut the corner off — and cut
it diagonally. The staircase runs from the top right down to the bottom left, holding 26
tiles. Squared off into the largest rectangle eight pieces can wall, the same corner holds
16.

## 3. Horseshoe Lake — 6 pieces, 24

```
..........
..~~~~~~..
.~~~~~~~~.
.~~oooo~~.
.~~oooo~~.
.~~oooo~~.
.~~oPoo~~.
.~~oooo~~.
..#oooo#..
...####...
```

The lake bends right round the pig and leaves a mouth four tiles wide at the bottom.
Plugging that mouth straight across takes four pieces and holds 20 tiles — a complete
solution with two pieces left over. Dropping the plug one row lower instead, down onto the
rim, and paying two more pieces to close the ends where the lake's arms stop short, buys
the extra row: 24 tiles for all six.

## 4. The Narrows — 10 pieces, 22

```
..........
..~~~.#...
.~~~~~o#..
#o~~~ooo#.
#oooooooo#
#oooPooo#.
#o~~~~o#..
.~~~~~~...
..~~~~....
..........
```

Neither lake is any use alone: the pig walks round either one. A pen thrown across the neck
leans on both at once, taking the south shore of the top lake and the north shore of the
bottom one as free walls. Four pieces down the west rim close that side; the other six run
a diagonal down the east, wide enough to take in the ground past the arms of both lakes.
22 tiles.

## 5. Otter Ford — 12 pieces, 24

```
..........
..........
.....#....
~~~~~o~~~~
#oooooooo#
.#ooPoooo#
..#ooooo#.
...#ooo#..
....###...
```

One dry tile breaks the river, and it is the only way north. Fence the tile *above* it
rather than the ford itself: one piece either way, but this way the ford stays inside the
pen and the entire far bank of the river becomes a free wall. The remaining eleven pieces
have only three sides left to close, which they do as an octagon pressed up against the
south side of the river. 24 tiles.

## 6. The Big Meadow — 16 pieces, 33

```
..........
.~~~~~....
.~~~~~~...
..~~~~~~..
.#o~~~~~..
#ooo~~~o#.
#oPoooooo#
#oooooooo#
.#ooooooo#
..#ooooo#.
...#####..
```

The widest board in the meadow, with a lake down one side and no corner to hide in.
Sixteen pieces make an octagon, and the only trick is cutting the top of it to the shape of
the shore rather than walling straight underneath the lake: the pen tucks up the west side
of the water and round the foot of it, taking ground that a tidy octagon would leave out.
33 tiles.

## 7. Windfall Orchard — 12 pieces, 37

```
..........
.~~~~~~~~.
.~~~~~~~~.
#oooooooo#
#ooPoooo#.
#oooooo#..
.#aooa#...
..#oo#....
..a##a....
..........
```

The river bars the whole north, so the ground under it is cheap to wall, and the four
apples lie in two rows further south where walling is dear. An apple is worth five tiles,
which is more than the ground a pen gives up narrowing itself to reach one — so the widest
pen is no longer the best one.

The fencing runs a diagonal down each side, tapering as it goes south, and closes just past
the near pair of apples. Two apples inside and 27 tiles of ground make 37. The far pair are
left out, and the two pieces that close the bottom happen to land on top of them, which
costs nothing: an apple outside the pen is worth nothing whether it is buried or not.

## 8. Sour Ground — 14 pieces, 32

```
....###...
...#aoo#..
..#ooooo#.
...#ooaoo#
..#ooooo#.
...~Poo#..
..~~~o#...
.~~~~#....
....a.....
..........
```

Three apples worth five apiece, two skulls costing five apiece, and a small lake at the
pig's shoulder. Shutting a skull in with the pig throws away five tiles of ground; walling
around one leaves a hole in the pen. Laying a piece straight over it does both jobs at
once, since a skull is mud like any other and takes a fence.

So the pen is shaped to make its own wall pass over both skulls. The wall would have needed
a piece somewhere near each of them anyway; putting it exactly there buries them for free.
The pen then reaches north for one apple and east for another, leaves the third out in the
south, and holds 22 tiles with two apples and no skulls: 32.

## 9. Stag Mere — 20 pieces, 46

```
...###....
..#ooa#...
.#Poooo#..
#oo#ooo#..
.~~~~~~...
.~~~~~~...
#oooooo#..
.#aooooD#.
..#oooo#..
...#ao#...
....##....
```

The boss, and the only map with two animals on it: the pig north of the mere, the stag
south, and one budget for both. Both have to be held, but *how* they are held is open —
a pen holds whatever ground it shuts in, in one piece or two.

One pen round the pair of them has to go the whole way round the mere, and there is no
budget in the game long enough to do that and hold anything worth having. Two pens, one on
each shore, use the same water as a wall twice over and pay for it once — which is the
answer, and then the puzzle is only where to split twenty pieces.

Ten pieces go to each, and each side is the octagon the earlier levels teach, tucked up
against the water and cut to reach the apple on its own shore. The skull below the pig sits
where that pen's wall wants to be anyway, so a piece lands on it and buries it; the skull by
the stag goes the same way. The pig holds 13 tiles and an apple, the stag 18 tiles and two:
31 tiles, three apples, 46.

Boxing the pig into its own tile for four pieces and pouring the other sixteen into the
stag's shore is the tempting shortcut. It is worth 40 — the north shore gives up far more
than four pieces' worth of ground when it is abandoned, which is what makes the split the
puzzle.

## Working one out yourself

```bash
Tools/level_search.py --budget 12 --plan <<'MAP'
.........
~~~~~~~..
...a..~..
..P...~..
.........
MAP
```

It prints the best pen it found drawn on the map, the plan on its own, and the score and
star thresholds that go with it. That is where every number above came from.
