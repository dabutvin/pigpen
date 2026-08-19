# Mudlark Meadow

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | River Bend | 12 | 35 | — | 35 | 35 |
| 2 | Horseshoe Lake | 6 | 24 | — | 24 | 24 |
| 3 | The Narrows | 10 | 22 | — | 22 | 19 |
| 4 | The Dew Ponds | 12 | 44 | — | 44 | 32 |
| 5 | Otter Ford | 12 | 24 | — | 24 | 16 |
| 6 | Puddle Corner | 8 | 26 | — | 26 | 16 |
| 7 | Windfall Orchard | 12 | 27 | 2 apples | 37 | 30 |
| 8 | Sour Ground | 14 | 24 | 2 apples, 1 skull | 29 | 22 |
| 9 | Stag Mere | 20 | 33 | 3 apples, 2 skulls | 38 | 34 |

Every one of these spends its whole budget.

The last column is what the same budget gets you from a plain block of ground — no
staircase, no detour for an apple — and the gap between it and the score is what the level
is really asking. It is nothing on the first two, which is why they are the first two, and
it widens the whole way to Puddle Corner. `Tools/level_search.py --demand` prints both.

Sour Ground used to read far harder than it is, for a reason of its own: a plain block on
that map wants a wall over one skull or the other, and no piece will lie on a skull, so every
block worth having was one you could not build at all. A block is nudged out over what it
cannot stand on now — the obvious local move, and the one the game itself makes when it
promises every level can be finished — so the column says something about the level again.
The last three stops are still ordered by what they scatter rather than by it.

## What the solutions have in common

Six ideas cover all nine maps, and every level is one of them dressed differently. Five of
them turn up again and again:

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
- **A skull is a tile you cannot build on.** So a skull on the line your wall wants is a
  choice: shut it in and pay five, or move the wall in beside it and give up its tile along
  with the skull. Out at the edge of a pen the second is nearly free; in the middle of one
  it is no choice at all, since a wall built round a tile in the middle of your ground is a
  wall across your pen.

The boss adds a sixth: **two pens can share a wall.** Water between two animals is one
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

## 2. Horseshoe Lake — 6 pieces, 24

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

## 3. The Narrows — 10 pieces, 22

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

## 4. The Dew Ponds — 12 pieces, 44

```
...#~.....
..#oo~....
.#oooo~...
#oooooo~..
#ooooooo~.
#oooPoooo~
#ooooooo~.
#oooooo~..
.#oooo~...
..##~#....
```

A line of ponds down the east of the field, one tile apart, and nothing else on the map. Each
pond is a tile of wall you do not pay for — and they are laid along the side of a pen nobody
has drawn.

A rectangle cannot use a single one of them: a right-angled wall runs past a diagonal line of
ponds and touches it once. So the block pays for its own east wall and holds 32. The twelve
pieces spent along the *west* instead, letting the ponds do the east, close a diamond of 44 —
the biggest pen in the meadow.

The ponds here sit a tile apart, so the shape is nearly drawn for you. That is the gentle
version; the woods space them two apart and the mountain three.

## 5. Otter Ford — 12 pieces, 24

```
...~#....
...~o#...
...~oo#..
...~ooo#.
...~oPoo#
..#ooooo#
...~oooo#
...~ooo#.
...~oo#..
...~##...
```

One dry tile breaks the river, and it is the only way west. Fence the tile *west of* it
rather than the ford itself: one piece either way, but this way the ford stays inside the
pen and the entire far bank of the river becomes a free wall. The remaining eleven pieces
have only three sides left to close, which they do as an octagon pressed up against the
east side of the river. 24 tiles.

## 6. Puddle Corner — 8 pieces, 26

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
left out in the open: the two pieces that close the bottom go between them rather than over
them, because no piece will lie on an apple. An apple outside the pen is worth nothing, but
it is still a tile the wall has to work around.

## 8. Sour Ground — 14 pieces, 29

```
...###....
..#oao#...
.#ooooo#..
#ooxooao#.
#oooooo#..
.#o~Po#...
..~~~#x...
.~~~~.....
....a.....
..........
```

Three apples worth five apiece, two skulls costing five apiece, and a small lake at the
pig's shoulder. Nothing can be built on a skull, so there are only two things to do with
one: shut it in and pay the five, or shut it out with a wall built on the tiles around it.
This map is worth doing one of each.

The skull by the lake is easy. The pen's south-east wall has to come past there anyway, so
it comes past one tile early — the piece goes on the tile between the pen and the skull, and
the skull is left outside for nothing.

The skull north-west of the pig is not. It sits in the middle of the ground the pen wants,
and a wall built round a tile in the middle of a pen is not a wall round the tile: it is a
wall across the pen, and everything beyond it is lost with it. Four pieces to keep out five
points, and a bite out of the pen besides. So it goes inside and is paid for, which buys the
room to run the pen north for one apple and east for another. 24 tiles, two apples and one
skull: 29.

## 9. Stag Mere — 20 pieces, 38

```
...###....
..#ooa#...
.#Poooo#..
#ooxooo#..
.~~~~~~...
.~~~~~~#..
#oooooox#.
.#aooooD#.
..#oooo#..
...#ao#...
....##....
```

The boss, and the first map with two animals on it: the pig north of the mere, the stag
south, and one budget for both. Both have to be held, but *how* they are held is open —
a pen holds whatever ground it shuts in, in one piece or two.

One pen round the pair of them has to go the whole way round the mere, and there is no
budget in the game long enough to do that and hold anything worth having. Two pens, one on
each shore, use the same water as a wall twice over and pay for it once — which is the
answer, and then the puzzle is only where to split twenty pieces.

Nine pieces go to the pig and eleven to the stag, and each side is the octagon the earlier
levels teach, tucked up against the water and cut to reach the apple on its own shore. There
is a skull on each shore, both of them in the middle of the ground its pen wants, and
neither will take a piece of fencing. Walling round either one would cut its pen in half for
the sake of five points, so each pen takes its skull in and pays. The pig holds 14 tiles, an
apple and a skull; the stag 19 tiles, two apples and a skull: 33 tiles, three apples, two
skulls, 38.

Boxing the pig into its own tile for four pieces and pouring the other sixteen into the
stag's shore is the tempting shortcut. The north shore gives up far more than four pieces'
worth of ground when it is abandoned, which is what makes the split the puzzle.

---

[Index](README.md) · [Thornwood Thicket →](02-thornwood-thicket.md)
