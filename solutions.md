# Solutions

**Spoilers.** This is the best pen every puzzle in Mudlark Meadow has in it — the pen each
level goes rainbow for, worth exactly the `maximumScore` it claims. Reading it gives away
the whole game.

These are not the *only* pens worth three stars; the third star is set a little under the
maximum, so most levels have several arrangements that earn it. Each one below is the pen
the level was authored around, found by `Tools/level_search.py` and pinned in
`PigpenTests/PuzzleLevelTests.swift`, which replays it and fails if the level stops giving
up what it promises. `PigpenTests/DifficultyTests.swift` pins the other end of each level —
the best pen you get without any of this — and fails if the trail stops getting harder.

The daily puzzles are not in here. Their best pens are pinned the same way — every one of
them, in `PigpenTests/DailyAlmanacFixtures.swift` — but there are seven hundred of them and
nobody wants tomorrow's answer printed a year early. A daily still tells you when you have
found the best pen it has in it, which is the only place the answer belongs.

## How to read a diagram

```
#  a fence piece            o  ground inside the pen
P  the pig                  .  mud outside the pen
D  the deer                 B  the boar
W  the wyrm                 R  the rat king
a  an apple                 ~  water
x  a skull
```

A treat inside the pen shows as its own letter on `o` ground. An apple with a `#` on it has
been fenced over and wasted. A skull never has one on it: nothing can be built on a skull,
so a wall that wants its tile is built round it instead.

A pen scores a point per tile of ground it holds, five more for every apple inside it and
five fewer for every skull.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | River Bend | 12 | 35 | — | 35 | 35 |
| 2 | Horseshoe Lake | 6 | 24 | — | 24 | 24 |
| 3 | The Narrows | 10 | 22 | — | 22 | 19 |
| 4 | The Dew Ponds | 12 | 44 | — | 44 | 32 |
| 5 | Otter Ford | 12 | 24 | — | 24 | 16 |
| 6 | Puddle Corner | 8 | 26 | — | 26 | 16 |
| 7 | Windfall Orchard | 12 | 27 | 2 apples | 37 | 26 |
| 8 | Sour Ground | 14 | 24 | 2 apples, 1 skull | 29 | 15 |
| 9 | Stag Mere | 20 | 33 | 3 apples, 2 skulls | 38 | 34 |

Every one of these spends its whole budget.

The last column is what the same budget gets you from a plain block of ground — no
staircase, no detour for an apple — and the gap between it and the score is what the level
is really asking. It is nothing on the first two, which is why they are the first two, and
it widens the whole way to Puddle Corner. `Tools/level_search.py --demand` prints both.

Sour Ground's block is worth less than the gap suggests, and for a reason of its own: a
plain block on that map wants a wall over one skull or the other, and a skull takes no
fencing, so every block worth having is one you cannot build. That is a fact about blocks
rather than about the level, which is why the last three stops are ordered by what they
scatter rather than by this column.

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
left out, and the two pieces that close the bottom happen to land on top of them, which
costs nothing: an apple outside the pen is worth nothing whether it is buried or not.

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

# Thornwood Thicket

The second world, solved the same way and drawn the same way. A truffle takes the meadow's
apple and a bramble its skull, so an `a` below is a truffle worth five tiles to shut in, and
an `x` a bramble worth five fewer that no piece will build on — exactly as before. The thicket
scatters them rather than saving them for the end, and it starts higher up than the meadow
did: there is no field here whose third star the obvious block will win.

## 1. Bramble Brook — 9 pieces, 27

```
..........
..........
~~~~~~~~..
#oooooo~..
#ooPooo~..
#oooooo~..
.#ooooo~..
..#oooo~..
...####...
```

The brook walls the north and the east, and the two sides left over are yours. Squared off
against them the nine pieces hold a block of 20, which is the answer the meadow trained you
to give and is worth two stars here.

The third comes from spending the same nine on a staircase instead. Each step down the
south-west trades a tile of wall for a tile of ground the block was paying to keep out, and
the diagonal ends up holding 27 — every tile the brook can be made to keep.

## 2. Foxglove Dell — 7 pieces, 29

```
..........
..~~~~~~..
.~~~~~~~~.
.~~oooo~~.
.~~oooo~~.
.~~oPoo~~.
.~~oooo~~.
.a.#ooooa#
....#ooo#.
.....###..
```

Water on every side but the mouth at the bottom, and a truffle lying out beyond each corner
of it. Four pieces plug the mouth and hold the pool's 16 tiles; squaring off below it with
all seven holds 21 and still reaches neither truffle.

Seven pieces lean the wall out to the east instead: 24 tiles and the truffle on that side,
which is 29. The truffle to the west is the trap — the pen cannot have both, and a wall that
goes after the second gives up more ground on the way down than five points can pay for.

## 3. Hazel Copse — 12 pieces, 30

```
..........
..........
~~~~~~~~..
#ooooooo#.
#ooaPoooo#
.#oooooo#.
..#oooo#..
...####...
```

A brook bars the north, so the ground under it is cheap to wall, and the pen closes round the
truffle it was going to hold anyway — the first windfall that costs nothing to take.

## 4. Fairy Ring — 13 pieces, 36

```
..........
...##.....
..~oo~#a..
.#ooooo~..
#ooooooo#.
~oooPoooo#
#ooooooo~.
.#ooooo#..
..~oo~#...
...##.....
```

Seven pools set round a clearing, no two of them touching, and a truffle out past the
north-east. This is the meadow's dew ponds with the spacing opened out — two tiles between
pools instead of one — so what they trace is a good deal less obvious.

Squaring off is worth 19 and reaches nothing, because not one pool falls where a rectangle
wants its wall. The thirteen pieces are exactly the rest of the ring the pools are sitting on:
lay them in the gaps and it closes on 36 tiles.

The truffle is the decoy. Breaking the ring to reach it gives up more ground than five points
ever pays for, which is the same lesson Foxglove Dell taught two fields earlier, asked the
other way round.

## 5. Fern Gully — 12 pieces, 34

```
..........
.~~~~~~~~.
.~~~~~~~~.
#ooooooo#.
#ooPooo#..
#oaooo#...
#oooo#....
.#ao#.....
..##......
..........
```

The pen bends south into a long tongue to gather both truffles, which are worth more than the
ground it gives up narrowing to reach them.

## 6. Willow Corner — 8 pieces, 26

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

Eight pieces cut the far corner off on the diagonal — the woods' staircase, which holds far
more than any right-angled box the same eight could wall.

## 7. Nettle Bank — 13 pieces, 26

```
....#.....
...#a#....
..#ooo#...
.#oxooo#..
.#ooPooo#.
..~~~oooo#
.~~~~~oa#.
..~~~.##..
..........
..........
```

Both truffles shut in, and the bramble taken in and paid for rather than walled around —
going round it would cost more ground than the five it does.

## 8. Elderwood — 15 pieces, 41

```
..........
.~~~~~....
.~~~~~~...
..~~~~~~..
.#o~~~~~#.
#ooo~~~oa#
.#Poooooo#
..#oaoooo#
..x#oooo#.
...#aoo#..
....###...
```

Cut to the shape of the mere, the pen gathers its three truffles on the way round and leaves
the bramble on the outside.

## 9. Boar Hollow — 20 pieces, 34

```
...###....
..#ooa#...
.#Poooo#..
..#xooo#..
...~~~~...
..~~~~~~..
...~~~~o#.
..#ooooxo#
.#aooooB#.
..#oaoo#..
...####...
```

The boss, and the thicket's answer to Stag Mere: the pig north of the hollow, the boar
south, and one budget for both. Both have to be held, but *how* they are held is open —
a pen holds whatever ground it shuts in, in one piece or two.

One pen round the pair of them has to go the whole way round the pool, and there is no
budget in the woods long enough to do that and hold anything worth having. Two pens, one
on each shore, use the same water as a wall twice over and pay for it once — which is the
answer, and then the puzzle is only where to split twenty pieces.

Nine pieces go to the pig and eleven to the boar, and each side is the octagon the earlier
levels teach, tucked up against the water and cut to reach the truffle on its own shore.
There is a bramble on each shore, both of them in the middle of the ground its pen wants,
and neither will take a piece of fencing. Walling round either one would cut its pen in
half for the sake of five points, so each pen takes its bramble in and pays. The pig holds
12 tiles, a truffle and a bramble; the boar 17 tiles, two truffles and a bramble: 29 tiles,
three truffles, two brambles, 34.

Boxing the pig into its own tile for four pieces and pouring the other sixteen into the
boar's shore is the tempting shortcut. The north shore gives up far more than four pieces'
worth of ground when it is abandoned, which is what makes the split the puzzle.

It asks for 21 of the 24 stars below it before it opens.

---

# Emberpeak

The third world, solved the same way and drawn the same way. A chestnut takes the meadow's
apple and an ember its skull, so an `a` below is a chestnut worth five tiles to shut in, and
an `x` an ember worth five fewer that no piece will build on — exactly as before, and a `W`
is the wyrm, held like the deer and the boar before it.

What the mountain does differently is refuse to hand out clean ground: every field up here
has at least one ember staked in it, so there is nowhere a wall runs straight without
something in the way. It is also the dry world — Basalt Flats has no water on it at all,
which no field in either world below can say — and it climbs the whole way from Cinder Slope
to Crater Pools rather than for six stops and then sorting by what it scatters.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Cinder Slope | 9 | 25 | — | 25 | 18 |
| 2 | Basalt Flats | 17 | 23 | — | 23 | 16 |
| 3 | Ashfall Terrace | 13 | 31 | 1 chestnut, 1 ember | 31 | 21 |
| 4 | Chestnut Scree | 12 | 27 | 2 chestnuts, 1 ember | 32 | 21 |
| 5 | Sulphur Rill | 13 | 24 | — | 24 | 15 |
| 6 | Fumarole Field | 14 | 17 | 2 chestnuts | 27 | 17 |
| 7 | Crater Pools | 12 | 29 | 1 chestnut | 34 | 17 |
| 8 | Smoulder Ridge | 16 | 32 | 3 chestnuts, 1 ember | 42 | 29 |
| 9 | Wyrm Caldera | 20 | 29 | 3 chestnuts, 1 ember | 39 | 32 |

## 1. Cinder Slope — 9 pieces, 25

```
..........
..........
..~~~~~~~~
..~oooooo#
..~oPoooo#
..~oooooo#
..~oooo##.
..~ooo#x..
...###....
```

The melt channel walls the west and the top, and the two sides left over are yours. Nine
pieces squared off under it hold a block of 18, which is worth two stars.

The third comes from stepping the wall down the south-east instead — and from what the wall
does when it reaches the ember. It cannot be laid on one, so it steps in beside it and
leaves it out in the corner, which costs a tile of ground and saves the five points the
ember would have charged to be shut in. 25 tiles, and every one of them the channel can be
made to keep.

## 2. Basalt Flats — 17 pieces, 23

```
..........
..........
..#.......
.#o#x.....
#ooo#.....
#oooP#....
#ooooo#...
#oooo#x...
#oooo#....
.#oo#.....
..##......
```

No water anywhere. Every pen in the two worlds below leant on a lake or a brook somewhere;
this one leans on nothing, and the whole of it is paid for out of the seventeen pieces.

Which makes it the plainest statement of what a shaped wall is worth. The best block those
seventeen can square off holds 16 tiles. The same seventeen run out as a ring — an octagon
pulled in beside each of the two embers — hold 23. Neither ember is inside: on a board with
nothing free on it, five points is a lot to pay for a tile.

## 3. Ashfall Terrace — 13 pieces, 31

```
..........
.~~~~~~~..
#ooooooo#.
#oPooooao#
#ooooooo#.
.#ooxoo#..
..#ooo#...
...#o#....
....#.....
```

The tarn along the top is the only free wall on the terrace, and the chestnut is out east
where no tidy pen would ever go. The pen that wins is neither tidy nor cheap: it runs out
far enough east to take the chestnut in, then tapers away south in a long wedge.

The ember it swallows on the way is the point of the field. Walling round it would cut the
pen in two — it is in the middle of the ground, not out at the edge of it — so the pen takes
it in and pays the five. 31 tiles and a chestnut, less the ember, is 31, against a block
worth 21.

## 4. Chestnut Scree — 12 pieces, 32

```
..........
~~~~~~~~~~
#oooooooo#
#ooPooao#.
#oooooo#..
.#ooxo#...
..#ao#....
...##.....
..........
```

Fern Gully's lesson on ground with something staked in it. The tarn bars the whole top, so
the ground under it is cheap to wall, and the chestnuts are strung out south where the
walling is dear.

A block under the tarn holds one chestnut and 16 tiles of ground for 21. The tongue that
reaches down for the second gives up the corners to do it and swallows the ember on the way
— 27 tiles, two chestnuts, one ember, 32. Five points for a chestnut is worth four tiles of
detour, and it is worth the ember as well.

## 5. Sulphur Rill — 13 pieces, 24

```
.....####~
....#oooo~
...#Poooo~
..#oooooo~
..x#ooooo~
....#o#oo~
.....#x#o~
........#~
.........~
```

The rill down the east edge is the free wall, and the two embers are the field. There is no
block worth having here: every rectangle big enough to be worth the budget wants a wall over
one ember or the other, and an ember takes no fencing at all. Squaring off clear of both is
worth 15.

The pen that wins keeps out of the way of both instead. Its west wall runs down the diagonal
tight past the upper ember, and it pinches right in round the lower one — that notch two
rows from the bottom is a wall built round a tile rather than over it — so it holds 24
without paying either of them a thing.

## 6. Fumarole Field — 14 pieces, 27

```
..........
.....#....
..~~~o#...
...x#oo#..
...#Pooo#.
..#ooooa#.
..x#ooo#..
...#ao#...
....##....
..........
```

Two vents either side of the pig, a chestnut beyond each of them, and a tarn at the head of
the field. The embers stand where a pen would want its west wall twice over, so the ground
this field gives up is a lozenge threaded between them rather than anything square.

It is the smallest pen on the mountain and one of the best paid: 17 tiles, but both
chestnuts are inside it, which is 27 against a block worth 17. The vents themselves cost
nothing — the wall is laid one tile clear of each.

## 7. Crater Pools — 12 pieces, 34

```
..........
....~.....
...#o#.x..
..~ooo#...
.#ooooo~..
#oooPooo#.
.~ooooo#..
#ooooo~...
.#aoo#....
..##~.....
```

Tarns caught in the rock three tiles apart — the widest spacing in the game — with an ember
staked beyond them and a chestnut lying inside. At this spacing the pools give away almost
nothing: five hints of a ring, and two thirds of it left to work out.

Which is why this is the field that asks the most of any in the game. A block is worth 17. The
ring the pools imply holds 29 tiles and the chestnut, which is 34, and it leaves the ember on
the outside — out at the edge of the pen, where stepping the wall in beside it costs one tile
rather than five points.

## 8. Smoulder Ridge — 16 pieces, 42

```
..........
.~~~~.....
.~~~~~....
..~~~~#...
.#ooooo#..
#oPooooa#.
#oooxoooo#
.#aoooooo#
..#o#ooa#.
...#x#o#..
......#...
```

The widest board on the mountain, and the biggest pen on any world trail. Cut to the shape of the
tarn, the pen gathers all three chestnuts on the way round: 32 tiles, three chestnuts, one
ember, 42.

Both embers are treated exactly as the ground around them asks. The upper one sits in the
middle of the pen and is bought for five; the lower one is out on the southern edge, where
stepping the wall in beside it costs a single tile — so it is left outside, and the notch it
makes is the difference between a good pen here and the best one.

## 9. Wyrm Caldera — 20 pieces, 39

```
...#......
..#a#.....
.#Poo#....
#ooo#x....
.~~~~~~~..
.~~~~~~~~.
#o~~~~~~o#
#oooxoooo#
#aooooWo#.
.#ooooa#..
..#####...
```

The boss. The pig is up on the north rim, the wyrm is down on the crater floor, the lake is
between them, and one budget has to hold the pair. As at the mere and the hollow, two pens
sharing the water beat one pen dragged the whole way round it.

What the caldera adds is how unevenly the budget wants splitting. The rim is narrow ground:
seven pieces buy the pig 7 tiles and the chestnut lying on them, and an eighth would buy
almost nothing, because there is nothing up there to buy. The other thirteen go to the
crater floor, which is the widest ground in the world — 22 tiles, two chestnuts and the
ember in the middle of it, bought for five rather than walled round. 29 tiles, three
chestnuts, one ember, 39.

The ember above the pig is left outside for the same reason the one below is taken in: it
is at the edge of that pen rather than in the middle of it, so the wall steps in beside it
and gives up one tile instead of five points.

It asks for 21 of the 24 stars below it before it opens.

---

# Cogsworth City

The fourth world, solved the same way and drawn the same way. A pie takes the meadow's apple
and a drain its skull, so an `a` below is a pie worth five tiles to shut in, and an `x` a
drain worth five fewer that no piece will build on — nothing drives a post through cast iron
— and an `R` is the rat king, held like the deer, the boar and the wyrm before it.

What the city does differently is that somebody built it. Every drop of water down here is
canal, cut one tile wide and turned at right angles: nowhere in this world do two tiles of
water lie side by side and one above the other, where every world below has meres, pools and
tarns lying in bodies. A canal hands over a wall and no ground with it, which is less of a
gift than it sounds.

The other thing is the room, or the want of it. Every board in the city is smaller than the
tightest shelf on Emberpeak, so the rim is always close and a block squared off against it
wastes more than a block ever wasted in open country. That is why the gentlest field here
asks 30% where the mountain's gentlest asks 28, and why the trail climbs the whole way from
Gasworks Cut to Foundry Corner.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Gasworks Cut | 9 | 26 | — | 26 | 18 |
| 2 | Pieman's Row | 11 | 20 | 1 pie | 25 | 17 |
| 3 | Cobble Yard | 14 | 18 | — | 18 | 12 |
| 4 | Lock Gate | 13 | 27 | 1 drain | 22 | 14 |
| 5 | Culvert Row | 13 | 27 | — | 27 | 16 |
| 6 | Gutter Lane | 14 | 26 | — | 26 | 15 |
| 7 | Foundry Corner | 9 | 32 | 1 drain | 27 | 15 |
| 8 | Clocktower Square | 17 | 35 | 2 pies, 1 drain | 40 | 25 |
| 9 | Rat King Wharf | 20 | 34 | 3 pies, 2 drains | 39 | 31 |

## 1. Gasworks Cut — 9 pieces, 26

```
.........
~~~~~~~~~
#ooooooo~
#oPooooo~
.#oooooo~
..#oooo#.
...#oo#..
....##...
```

The cut runs the width of the world along the top and turns down the far end of it, which is
two walls handed over. Nine pieces squared off under them hold a block of 18, and that is
worth two stars.

The third comes from giving up the square corner: the wall goes down the west for two tiles
and then steps away south-east, and the ground it picks up on the diagonal is worth more than
the ground it gives up at the bottom. 26 tiles, and every one the yard has in it.

## 2. Pieman's Row — 11 pieces, 25

```
~##......
~oo#.....
~oPo#..a.
~oooo#...
~oooao#..
~oooo#...
.#oo#....
..##.....
```

Two pies on the row and one canal down the west. A block against the canal takes the near pie
and twelve tiles with it, which is 17 and two stars.

The pen that wins takes the same pie and puts twenty tiles round it instead, by running the
wall out on the diagonal and back. The far pie stays where it fell: the ground a wall gives up
bending out to it costs more than the five it pays, which is the whole of what a pie is for.

## 3. Cobble Yard — 14 pieces, 18

```
.....#...
....#o#..
..x#ooo#.
..#ooooo#
.#ooPoo#.
..#ooo#..
...#o#x..
....#....
```

Paving and two drains, and nothing else. Every tile of this pen is bought out of the fourteen
pieces, the way Basalt Flats is bought out of seventeen — on tighter ground, so the ring is
smaller and the drains are harder to keep off its wall.

The best block here holds 12. The same fourteen pieces run out as a ring hold 18, and the
ring has to be placed so that neither drain falls on it: a drain takes no fencing, so a ring
that wants one of those tiles is a ring you cannot build.

## 4. Lock Gate — 13 pieces, 22

```
....#....
~~~~o~~~~
#ooooooo#
#ooxoooo#
#oooPoo#.
.#oooo#..
..#oo#...
...##....
```

The canal crosses the whole world with the lock standing open in the middle of it. One piece
in the gate shuts the only way north and buys the entire canal as a free wall — Otter Ford's
lesson, on a third of the board.

The other twelve close three sides, and the drain under the gate is in the middle of whatever
they close, so it is taken in and paid for rather than walled round. 27 tiles less the drain,
which is 22, against a block worth 14.

## 5. Culvert Row — 13 pieces, 27

```
....#...
~~~~o#..
#ooooo#.
#oooooo#
#ooPooo#
.#ooooo#
..#oooo#
...#~~~~
........
```

Two culverts, one at each end of the street, six rows of paving apart. No wall you can draw
reaches both, so a block leans on one of them and is worth 16.

The pen that wins leans on both: it comes off the top culvert, runs the length of the street
on the diagonal and comes down on the bottom one, so both of them are wall and neither is
paid for. 27 tiles for thirteen pieces.

## 6. Gutter Lane — 14 pieces, 26

```
..######~
.#oooooo~
.#oPoooo~
..#ooooo~
..x#oooo~
....#ooo~
....x#oo~
......##.
```

The canal walls the whole east side and two drains are sunk out where a wall wants to stand.
Neither is worth five points: the wall comes off the canal, runs down the diagonal tight past
the upper drain and pinches in round the lower one, and both stay outside for a tile apiece.

Sour Ground made that choice once and Sulphur Rill made it twice. This makes it twice with
nowhere to put the mistake — a block that keeps clear of both drains is worth 15.

## 7. Foundry Corner — 9 pieces, 27

```
~~~~~~~~~
~ooooooo#
~ooooooo#
~ooPooo#.
~oooxo#..
~oooo#...
~ooo#.x..
.###.....
```

Two canals meeting at a corner, which Puddle Corner and Willow Corner both asked before — and
both of those were eight pieces on clean ground. This is nine pieces with two drains staked on
the diagonal itself, so the staircase cannot simply be drawn.

It has to be drawn round one and over the other. The upper drain is in the middle of the pen,
where walling round it would cost more ground than the five points it charges, so it is taken
in; the lower one is out past the wall entirely. 32 tiles less one drain, which is 27, against
a right-angled block worth 15. No corner in the game gives a diagonal that much to buy.

## 8. Clocktower Square — 17 pieces, 40

```
~~~~~#...
#ooo~o#..
#oooooo#.
#oPooooa#
#ooooooo#
#oooxoo#.
.#aooo#..
..#o##.a.
...#x....
```

The widest board in the city and the biggest pen in it. The canal comes in under the tower and
the wall is cut to its shape, gathering the pie on the east and the pie down in the south-west
on the way round: 35 tiles, two pies, one drain, 40.

The third pie, out at the bottom right, is left where it fell — the pen would have to bend a
long way for it and give up more than five tiles doing it. The drain by the pig's shoulder is
in the middle of the ground and is bought; the one on the south rim is outside the wall
altogether. A block leaning on the canal holds 25.

## 9. Rat King Wharf — 20 pieces, 39

```
..####...
.#Poao#..
#oooooo#.
#ooxoooo#
~~~~~~~~~
#ooooooo#
.#aoooRo#
..#oaox#.
...####..
```

The boss. The canal is cut straight across the wharf, the pig is on the near quay and the rat
king on the far one, and one budget has to hold the pair. As at the mere, the hollow and the
caldera, two pens sharing the water beat one pen dragged the whole way round it.

What the wharf adds is that both quays are worth having, which the caldera's rim was not. Ten
pieces buy the pig 17 tiles and the pie on them and ten buy the far quay 17 tiles, two pies
and the rat king — the only boss in the game whose budget splits down the middle, where the
mere's went nine and eleven and the caldera's seven and thirteen.

Both drains are in the middle of the ground they stand on rather than out at its edge, so both
are bought for five rather than walled round: 34 tiles, three pies, two drains, 39 — every
treat on the board taken in, the way the mere's pens take in every treat on theirs.

It asks for 21 of the 24 stars below it before it opens.

---

## Working one out yourself

```bash
Tools/level_search.py --budget 12 --plan --demand <<'MAP'
.........
~~~~~~~..
...a..~..
..P...~..
.........
MAP
```

It prints the best pen it found drawn on the map, the plan on its own, and the score and
star thresholds that go with it. That is where every number above came from. `--demand`
adds the squared-off pen underneath — the best plain block the same budget buys — and the
gap between the two, which is what decides where on the trail a level belongs.
