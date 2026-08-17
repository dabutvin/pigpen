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
V  the visitor              T  a bat
U  its pup                  M  the ringmaster
S  the scorpion             a  an apple
x  a skull                  ~  water
```

A treat inside the pen shows as its own letter on `o` ground. Neither kind ever has a `#` on
it: nothing can be built on an apple or a skull, so a wall that wants one of those tiles is
built round it instead.

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
#ooPooa#..
#ooooo#...
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

## 9. Boar Hollow — 20 pieces, 43

```
..#.......
.#a#...x..
#ooP#.....
#oooo#....
#ooo~~~...
.#o~~~~...
..#o~~o#..
.#aooooB#.
..#ooooa#.
..x#ooo#..
....###...
```

The boss, and the field where the woods stop copying the meadow. The pool has been pulled back
into the middle of the wood and touches neither animal, so Stag Mere's answer — two pens sharing
a stretch of water — is not on offer here.

For a while it looks as though one big pen round the pair is right, and with twenty pieces it
very nearly is. It is not, because the boar will not have it: this is the first field in the
game that refuses a pen for a reason other than something walking out of it. Hold them both,
but never in the same ground.

So the twenty go out as two enclosures leaning on the pool from opposite sides, sharing not one
tile: 28 tiles and three truffles, 43, against a squared-off 36 — a pair of blocks nudged out
over the truffles their walls wanted picks up all three of those as well.

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
| 6 | Fumarole Field | 14 | 18 | 2 chestnuts | 28 | 16 |
| 7 | Crater Pools | 12 | 29 | 1 chestnut | 34 | 17 |
| 8 | Smoulder Ridge | 16 | 32 | 3 chestnuts, 1 ember | 42 | 30 |
| 9 | Wyrm Caldera | 20 | 38 | 3 chestnuts, 2 embers | 43 | 27 |

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
#oooxooo#.
.#ooooo#..
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
#ooPoooa#.
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

## 6. Fumarole Field — 14 pieces, 28

```
..........
.....##...
..~~~oo#..
...x#ooo#.
...#Poooo#
....#ooao#
..x..#ooo#
......#a#.
.......#..
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

The widest board on the mountain, and the biggest pen on any world trail until the reaches. Cut
to the shape of the tarn, the pen gathers all three chestnuts on the way round: 32 tiles, three
chestnuts, one ember, 42.

Both embers are treated exactly as the ground around them asks. The upper one sits in the
middle of the pen and is bought for five; the lower one is out on the southern edge, where
stepping the wall in beside it costs a single tile — so it is left outside, and the notch it
makes is the difference between a good pen here and the best one.

## 9. Wyrm Caldera — 20 pieces, 43

```
..##......
.#Po#.....
#oooa#....
#oxooo#...
#oooooo~..
#oooooo~..
#oooxo#...
#oaoo#W...
.#oooo#...
..#oa#.x..
...##.....
```

The boss, and the only field in the game that does not ask you to hold everything on it.

The wyrm is not livestock. The board does not want it fenced — it wants it left where it is, on
the outside of whatever you build — so its tile is a hole you can neither cover nor stand a post
on, like an ember that walks. Only the pig's ground counts.

Which turns the boss inside out. The mere and the hollow are a budget split two ways; here all
twenty pieces go to the pig, and the question is how much of the mountain you can take before
the wall has to bend round the thing sitting in the middle of it. Thirty-eight tiles and three
chestnuts, less the two embers it swallows on the way, come to 43 — where squaring off well
clear of the wyrm is worth 27.

It asks for 21 of the 24 stars below it before it opens.

---

# Cogsworth City

The fourth world, solved the same way and drawn the same way. A pie takes the meadow's apple
and a drain its skull, so an `a` below is a pie worth five tiles to shut in, and an `x` a
drain worth five fewer that no piece will build on — nothing drives a post through cast iron
— and an `R` is the rat king, which is held like the deer and the boar before it and, unlike
either, will not be penned on its own.

What the city does differently is that somebody built it. Every drop of water down here is
canal, cut one tile wide and turned at right angles: nowhere in this world do two tiles of
water lie side by side and one above the other, where every world below has meres, pools and
tarns lying in bodies. A canal hands over a wall and no ground with it, which is less of a
gift than it sounds.

The other thing is the room, or the want of it. Every board in the city is smaller than the
tightest shelf on Emberpeak, so the rim is always close and a block squared off against it
wastes more than a block ever wasted in open country. That is why the gentlest field here
asks 16% where the mountain's gentlest asks 14, and why the trail climbs the whole way from
Gasworks Cut to Foundry Corner.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Gasworks Cut | 9 | 26 | — | 26 | 18 |
| 2 | Pieman's Row | 12 | 19 | 1 pie | 24 | 16 |
| 3 | Cobble Yard | 14 | 18 | — | 18 | 12 |
| 4 | Lock Gate | 13 | 27 | 1 drain | 22 | 14 |
| 5 | Culvert Row | 13 | 27 | — | 27 | 16 |
| 6 | Gutter Lane | 14 | 26 | — | 26 | 15 |
| 7 | Foundry Corner | 9 | 32 | 1 drain | 27 | 15 |
| 8 | Clocktower Square | 17 | 35 | 2 pies, 1 drain | 40 | 25 |
| 9 | Rat King Wharf | 19 | 33 | 2 pies | 43 | 26 |

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

## 2. Pieman's Row — 12 pieces, 24

```
~#.......
~o#......
~oP#...a.
~ooo#....
~oooo#...
~ooooo#..
.#oooa#..
..####...
```

Two pies on the row and one canal down the west. A block against the canal holds sixteen tiles
and neither pie — both lie below where a rectangle stops, and no piece will lie on one to sweep
it up on the way past — which is 16 and two stars.

The pen that wins goes out for the near pie and puts nineteen tiles round it, by running the
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

## 9. Rat King Wharf — 19 pieces, 43

```
.#####...
#aoooo~..
#oPooo~..
#ooooo~#.
#ooooooo#
.~~~oooo#
..x#ooRo#
...x#ooa#
.....###.
```

The boss, and the city's own rule: **the rat king will not be left on its own**. Both of them
held, in one pen — never two. Boar Hollow refuses the single pen; this refuses the pair of
them, and a player who learned the woods' answer has to unlearn it here.

So the question is what shape one pen has to be. The pig and the rat king stand four tiles
apart on the diagonal, which makes the smallest block that takes them both a five by five —
and a drain sits in one of the corners such a block cannot avoid, so squaring off is worth 26.

The pen that wins runs out along the diagonal instead of round it: it leans on the culvert in
the north-east and the cut in the south-west, takes the pie at each end of the run, and leaves
both drains outside — the one by the culvert steps in beside it, the one down in the yard is
never reached. 33 tiles and two pies, 43, for every one of the nineteen pieces.

It asks for 21 of the 24 stars below it before it opens.

---

# Starfall Reaches

The fifth world, solved the same way and drawn the same way. A stardrop takes the meadow's
apple and a meteor its skull, so an `a` below is a stardrop worth five tiles to shut in, and an
`x` a meteor worth five fewer that no piece will build on — nothing drives a post through a
stone that came in from that far out — and a `V` is the visitor, which is held like the deer,
the boar and the rat king before it and, unlike any of them, will not be housed worse than the
pig.

What the reaches do differently is that the **water is in single drops**. Every world below has
water lying in something — meres, pools, tarns, or canals cut in straight runs — and out here
every drop is one tile on its own: a well where a star went in, and no two wells sharing an
edge. A `~` below is always alone.

Which sounds like the end of free walls and is not, because of the one arrangement that law
still allows. Wells laid corner to corner are a wall: every way out of the ground behind them
runs into a well, or into the single piece that bridges two of them. So the reaches hand over
**staircases** where the meadow handed over banks, and a staircase is a wall no rectangle can
ever lean on — which is why the world floors at 32% on the biggest boards in the game. There is
more room out here than anywhere else and less of it a plain block can reach.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Dust Shore | 12 | 31 | — | 31 | 21 |
| 2 | Fallwater Basin | 13 | 36 | — | 36 | 24 |
| 3 | Broken Chain | 15 | 38 | — | 38 | 24 |
| 4 | Swept Flat | 18 | 32 | — | 32 | 20 |
| 5 | Stardrop Hollow | 13 | 34 | 1 stardrop | 39 | 23 |
| 6 | Meteor Field | 15 | 42 | 2 meteors | 32 | 17 |
| 7 | Starwell Ring | 12 | 32 | — | 32 | 14 |
| 8 | Wide Reaches | 20 | 64 | 1 stardrop | 69 | 45 |
| 9 | Visitor Crater | 20 | 44 | 2 stardrops, 1 meteor | 49 | 27 |

## 1. Dust Shore — 12 pieces, 31

```
...####....
..#oooo#...
.~oooooo#..
..~ooPooo#.
...~oooooo#
....~ooooo#
.....~ooo#.
......~o#..
.......~...
...........
...........
```

Seven wells fall from the north-west corner down across the middle of the reaches, corner to
corner, and that is the entire south-west side of the pen — every tile behind it has a well
beside it or a well above it, and nothing needs bridging because the pig cannot cross a corner.
So the question is only how far along the chain to keep going, since the north and the east are
yours to pay for however long the pen runs.

Twelve pieces squared off in the open beside the chain hold 21. The same twelve, run along it
as a staircase, hold 31 — every tile between the chain and the rim they can afford to close.

## 2. Fallwater Basin — 13 pieces, 36

```
.~#~#~#~#..
~oooooooo~.
#ooooooo#..
~ooPooo~...
#ooooo#....
~oooo~.....
#oooo#.....
~oo~#......
.##........
...........
...........
```

A whole shower landed here: four wells along the top, four down the west, and four more falling
away south-west through the middle. Twelve drops, every one of them on every other tile, which
is a basin dotted rather than drawn.

The wall that wins is therefore half water. Four pieces go in the gaps along the north and three
in the gaps down the west, which buys two long walls at half price, and the remaining six follow
the inner line of drops down the east and round the bottom. Squared off between the north bank
and the west, thirteen pieces hold 24; laid in the gaps they hold 36.

## 3. Broken Chain — 15 pieces, 38

```
...#####...
..#ooooo#..
.#ooooooo~.
#ooooooo~..
#oooooo~...
#ooPoo#....
#oooo~.....
#ooo~......
.#o~.......
..~........
...........
```

One chain again, longer, with a well missing out of the middle of it. Eight tiles of diagonal
bank and seven wells on them: everything the chain seals is free and the hole is the only way
out, so the whole bank costs exactly one piece.

That is Otter Ford's lesson and Lock Gate's, taught on the only bank in the game that runs on
the diagonal. The piece goes in three tiles east of the pig, in its own row, and the fourteen
still in hand close the north and the west of a pen worth 38, against 24 for a block. Finding
the hole is most of it;
what is left is that closing a staircase wants those fourteen in a different order than closing
a box does.

## 4. Swept Flat — 18 pieces, 32

```
....#......
...#o#x....
..#ooo#....
.#ooooo#...
#ooooooo#..
#oooooPo#x.
.#ooooo#...
..#ooo#....
..x#o#.....
....#......
...........
```

A stretch of the reaches the water never found: not one well on it, eleven tiles of dust in
every direction, three meteors sunk in the dust and eighteen pieces. Every tile of this pen is
bought — a meteor takes no fencing and shuts nothing in, so not one of the three hands over any
wall.

It is Basalt Flats and Cobble Yard with more room and more pieces than either had, and the
answer is the one it always was, worth more here than it has ever been worth: the best block
eighteen pieces can square off holds 20, and the same eighteen run round as a diamond hold 32. A
piece on the diagonal shuts two ways past it where a piece on the square shuts one.

What the stones are for is where to put that diamond. Centred on the pig it is refused twice:
the meteor to the north lies on the line the wall wants, and no piece will go on a stone; the
one to the east lies inside, five against. Carried two columns west and a row north it holds the
same 32 tiles with all three outside it — and the stone in the south-west is there so that a row
south is not an answer either.

## 5. Stardrop Hollow — 13 pieces, 39

```
..~##~#....
.#ooooa#a..
~ooooooo~..
#oooPoooo#.
#ooooooo#..
.~ooooo~...
..#o~o#....
...#.#.....
...........
...........
...........
```

Two stardrops cooling on the north rim with a single tile of dust between them, and seven wells
scattered round the hollow to lean on. Thirteen pieces squared off under the wells hold 13 tiles
and, since no piece goes on a stardrop, both drops with them: 23.

The pen that wins bends out over the near drop and pays for it by cutting back on the diagonal
underneath: 34 tiles and one stardrop, 39. The far one stays where it fell, one tile further
out, and that is the whole of what a stardrop is for — the line between a windfall worth
reaching and a windfall worth leaving runs between two neighbours here.

## 6. Meteor Field — 15 pieces, 32

```
...##~.....
..#ooo#....
.~ooooo#...
#oooxoo~...
#ooooooo#..
.~ooPooo#..
#oooxoo~...
.#ooooo#...
..~ooo#....
...#o~.....
....#......
```

Two meteors staked three tiles apart with the pig standing between them, dead in the middle of
the only ground worth having. Neither will take a piece of fencing, so the pen swallows both and
pays their ten, or it steps round them and gives up the ground behind them as well.

Sour Ground made that choice once and Sulphur Rill and Gutter Lane made it twice on tight
boards. This makes it twice in the open, where stepping round looks affordable and is not: a
block that keeps clear of both stones is worth 17, and the ring that takes them in holds 42
tiles less their ten, which is 32.

## 7. Starwell Ring — 12 pieces, 32

```
....##.....
...~oo~....
..#oooo#...
.#oooooo#..
~ooooPooo~.
.#oooooo#..
..#oooo#...
...~oo~....
....##.....
...........
...........
```

Six wells and nothing else: two on the north, two on the south, one out west and one out east,
none of them touching anything. They are six corners of a shape nobody has drawn, and the budget
is exactly the rest of that shape's wall — twelve pieces, and not one to spare.

So this is The Dew Ponds and Fairy Ring and Crater Pools again, and the hardest field in the
world: twelve pieces squared off between two of the drops hold 14, and the same twelve laid
where the drops are pointing hold 32. Nothing on the board says where the wall goes. The water
only rules out every shape but one — and every one of the six is on the answer, which is what
`Constellation.idleWater` checks in the tests.

## 8. Wide Reaches — 20 pieces, 69

```
....####....
...~oooo~...
..~oooooo#..
.#oooooooo#.
#oooooooooo#
#oooooPoooo#
#ooooooooo~.
.~oooooooo#.
..#aooooo#..
...#oo~o#...
....##.#....
............
```

The widest board in the game and the biggest pen anywhere in it. Twelve by twelve, six wells
thrown across it, one stardrop down in the south-west, twenty pieces.

The wells are a constellation the way the ring's are, but the wall they imply out here is a
diamond ten tiles across, and the diamond is the point: twenty pieces laid as a staircase all
the way round shut 64 tiles and take the stardrop in on the way, which is 69, where the best
block those same twenty can square off holds 40 tiles and the same stardrop, or 45. Nothing
else in the game holds sixty tiles.

The well showing inside the diagram, down at the bottom, is standing in the pen's own wall
rather than being wasted: it seals that corner, so the fencing stops one piece short there.

## 9. Visitor Crater — 20 pieces, 49

```
...##~......
..#ooo#.a...
.#oaoo#x~#..
#oooooo~oo#.
#oooPo~ooo~.
.#ooo#oVo~..
..#o#xoooo#.
...~ooooo#..
....#ooo#...
.....#a~....
......#.....
```

The boss, and the reaches' own rule: **the visitor will not be housed worse than the pig**. Both
of them held, in two pens rather than one, and the same ground in each — a pen apiece that comes
out even, or the field is not won.

Which is every other two-animal board's answer forbidden at once. Stag Mere lets the budget fall
wherever it scores best, Boar Hollow wants two pens and does not care what is in them, Wyrm
Caldera throws the second animal out, and Rat King Wharf demands the single pen this one
refuses. The cheap move all four of those reward — pour the budget into the animal standing in
the better country and box the other one in four pieces — is exactly what this board sends back.

A line of wells falls down the middle of the crater from the north-east rim to the south-west,
which is dividing wall the sky laid and nobody pays for, except that two tiles of it are
missing: a neck of plain dust where the halves still run into one another. Two pieces in the
neck is what turns one pen into two.

What is left after that is the rule, because the halves are not the same size. Plug the neck,
fence the rim, and you have a pen holding every tile in the crater and a board that will not
have it — so the last thing to work out is which tiles of the wider half to hand back. The
answer holds 22 tiles on each side of the line, with a stardrop in each half and a meteor the
visitor's half swallows: 27 for the pig, 22 for the visitor, 49 between them, off a best pair of
blocks worth 27.

The third stardrop lies out past the east rim where no wall on this board can reach it, and the
second meteor stands up on the north rim exactly where a tidy wall would want to go.

It asks for 21 of the 24 stars below it before it opens.

---

# Gloamdeep Caverns

The sixth world, solved the same way and drawn the same way. A crystal takes the meadow's apple
and a boulder its skull, so an `a` below is a crystal worth five tiles to shut in, and an `x` a
boulder worth five fewer that no piece will build on — nothing drives a post through a block of
limestone that size. A `T` is a bat and a `U` its pup: two animals to the board, one roost to the
rule, and the last field will not have them in separate pens.

What the caverns do differently is that all the water is **one river**. Every world above has
water lying in more than one place somewhere — ten ponds, seven pools, six tarns, canals and
drains, twelve wells — and down here there is one body of it at most on any board, and it comes in
off the rim of the cave. A `~` below is always part of the same river, and one field has none of it
at all.

Which is not less wall to lean on but more of it in one place, and the shape it leaves is the whole
world. A river that runs in off the rim and stops short of the far wall has done nine tenths of a
wall's work and left a **neck** — the strip of dry floor where the two halves of the cave still run
into one another — and one piece laid in the neck buys the entire length of the water. And since
the only way to make a river long enough to matter on a board this size is to step it, the banks
down here are **staircases**: the pen that follows one is a wedge or a lozenge, and a rectangle can
only ever get one corner against it. That is what holds the world at 34% and above.

There is a crystal on every board, because a crystal is the only light in the Gloamdeep.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Sinter Basin | 12 | 22 | 2 crystals | 32 | 21 |
| 2 | Dripstone Shelf | 11 | 26 | 2 crystals | 36 | 23 |
| 3 | Stillwater Neck | 11 | 26 | 2 crystals, 1 boulder | 31 | 19 |
| 4 | The Blind Grike | 19 | 36 | 2 crystals, 1 boulder | 41 | 25 |
| 5 | Glowworm Reach | 11 | 21 | 1 crystal | 26 | 15 |
| 6 | Rimstone Corner | 9 | 36 | 2 crystals | 46 | 25 |
| 7 | Boulder Chamber | 15 | 44 | 2 crystals, 2 boulders | 44 | 23 |
| 8 | Great Gallery | 19 | 58 | 2 crystals, 1 boulder | 63 | 42 |
| 9 | The Roost | 20 | 35 | 3 crystals, 1 boulder | 45 | 23 |

## 1. Sinter Basin — 12 pieces, 32

```
.~.........
.~~....~~..
..~~..~~...
...~~~~....
..#ooao#...
.#oooooo#..
#oooooP#...
.#oooo#....
..#ao#.....
...##......
...........
```

The river comes in off the roof at the north-west, steps down to the floor and climbs back out to
the east: a shallow V of free wall with the whole floor of the chamber under it. The belly of that
V is walled for nothing, which is most of a pen already, and it is why this is the gentlest field
in the caverns.

What it leaves is the mouth, and the mouth here is the entire southern side. Twelve pieces hung
straight down off the belly as a rectangle hold 16 tiles and one crystal, which is 21 and what the
board hands over. The same twelve hung under the belly as a lozenge — stepping out west and east,
then closing again on the diagonal — hold 22 tiles and both crystals, which is 32.

## 2. Dripstone Shelf — 11 pieces, 36

```
..~##.....
..~oo#....
..~ooa#...
..~~ooo#..
...~oooo#.
...~ooPoo#
...~~oooa#
....~ooo#.
....~oo#..
....~~#...
..........
```

One river running the length of the shelf, in off the roof at the north and stepping south-east the
whole way down. The bank is a single staircase, so the ground beside it is a wedge and not a
rectangle, and eleven pieces squared off against it can only get one of their four sides on it:
22.

The answer mirrors the river back at itself. The west wall of the pen is the water, free for its
whole length; the east wall is a staircase of its own, out to the widest part of the shelf and back
in again. Twenty-six tiles and both crystals, which is 36. A diagonal wall closes two tiles a piece
where a straight one closes one, and following a bank that is already diagonal is how the caverns
say so.

## 3. Stillwater Neck — 11 pieces, 31

```
.....##....
....#oa#...
...#oooo#..
..#oooooo#.
~~oooooooo#
.~~~~Poxao#
....~~~~o#.
..a....~~..
...........
...........
...........
```

The river runs in off the west wall, steps away south-east across the middle of the cave, and stops
two columns short of the east. What it leaves is the neck the whole world is named for: a corridor
of dry floor round the tip of the water, and the only way from one half of the cave to the other.

Shut the corridor and the entire river is wall — eight tiles of bank for one piece. Eleven pieces
squared off north of the water hold 14 tiles, both crystals and the boulder, or 19, because a wall
that stops short of the east rim has to pay for its own eastern side; the same eleven run right out
along the bank and closed with a single piece at the corridor hold 26 tiles and the same three
things lying on the floor.

The corridor is not clear ground, which is the rest of the field. A boulder stands in it just
behind the tip of the water, so the pen that comes round the river swallows it and pays its five —
26 and two crystals less one boulder, or 31. The eight tiles of free bank that piece bought are
worth that twice over, which is a sum rather than a sight. One of those crystals lies out past the
tip as well, so the corridor is the only way to it: the piece that shuts the cave is the piece that
fetches it. The third lies away south-west, where nothing on this board reaches it.

## 4. The Blind Grike — 19 pieces, 41

```
.....#.....
....#a#....
...#ooo#...
..#ooooo#..
.#ooxoooo#.
.#oooPoooo#
..#oooooo#.
...#oooo#..
....#ao#...
.....##....
...........
```

The one cave the river never found. No water anywhere, eleven tiles of dry floor in every
direction, and nineteen pieces — every tile of this pen is bought.

Which makes it Basalt Flats and Cobble Yard and Swept Flat again, and the answer is the answer it
always was. The best block nineteen pieces can square off holds 25. The same nineteen run round as
a diamond hold 36 tiles, both crystals and the boulder they cannot avoid swallowing on the way,
which is 41. A diagonal wall shuts two tiles per piece where a straight one shuts one, and in a
cave with no river in it there is nothing else to know.

## 5. Glowworm Reach — 11 pieces, 26

```
..~........
..~~.......
.#o~~.a....
#ooo~~.....
#oooo~~....
#oooPo~~...
#oooo#.....
#aoo#......
.#o#.....a.
..#........
...........
```

Three crystals, and not one of them on the line the tidy pen wants. The river steps in off the roof
at the north-west and away south-east, and the best block eleven pieces can hang under it holds 15
tiles and no crystal at all — there is no rectangle on this board that reaches any of the three, and
no piece will lie on one to sweep it up in passing either.

So the whole field is which one to go out for, on the tightest budget in the caverns. The crystal
above the river's arm is on the far side of the water: a pen that wants it has to come round the tip
of the river and climb back up, and no wall of eleven does. The one out east is four tiles of wall
from the nearest ground worth holding, and four tiles of wall cost more than five points pay. The one
against the west wall is a row below where the pen would otherwise stop, and the tongue that fetches
it pinches down to a single tile: 21 tiles and that crystal, which is 26.

## 6. Rimstone Corner — 9 pieces, 46

```
............
~~~~~~~~~~~.
.#aooooooo~.
..#ooooooo~.
...#oooPoo~.
....#oaooo~.
.....#oooo~.
......#ooo~.
.......#oo~.
........#o~.
.........#~.
```

The river takes the length of the roof of the cave and the length of the east wall — in along the
north, round the corner, and down the far side — so two sides of the pen are handed over and there
are nine pieces to draw the other two. It runs a tile inside the rim, so the strip beyond it is a
far bank: no pen can reach it, the way no pen reaches the far shore of the Dew Ponds.

Nine laid as a right angle in the corner hold 25. The same nine laid corner to corner, one long
diagonal from the west wall down to the south-east that cuts the entire bend off in a single line,
hold 36 tiles and both crystals: 46. That is the smallest budget in the caverns paying out the
second biggest score in them, which is the corner question with nothing whatever in the way of it —
Foundry Corner asked it on a canal bend with the same nine pieces and could only reach round 27, and
every one of these nine has to be on the diagonal or the pen falls apart.

## 7. Boulder Chamber — 15 pieces, 44

```
.~####.....
.~oooo#....
.~ooooo#...
.~~ooooo#..
..~oooooa#.
..~ooxoooo#
..~~ooPooa#
...~xoooo#.
...~oooo#..
...~~oo#x..
.....##....
```

Three boulders down off the roof into the middle of the only ground worth having, and the hardest
field in the caverns. A fence will not go through any of them: the pen swallows one and pays its
five, or it steps the wall in beside it and gives up the ground behind it as well.

Fifteen pieces squared off in the long chamber beside the river hold 32 tiles, a crystal and two
boulders, which comes back to 27. The same fifteen run round
as a diamond hold 44 tiles, both crystals and two of the three boulders, which comes back to 44 —
the two in the middle are inside the pen because there is no way round them worth taking, and the
third is left out in the east with the wall stepped in beside it, because it is the one boulder on
the board that costs less to abandon than to shut in.

## 8. Great Gallery — 19 pieces, 63

```
...#~.......
..#o~~......
.#ooo~~.....
#aoooo~~....
#oooooo~~a..
#ooooooo~~..
#ooPooooo~~.
#ooooooxooo#
.#oooooooo#.
..#oooooo#..
...#oaoo#...
....####....
```

The widest floor in the caverns with a river stepping down the length of it: twelve tiles by twelve,
three crystals, one boulder and nineteen pieces. It holds the third biggest pen in the game, at 58
tiles, behind Wide Reaches and the dunes' Great Erg.

Nineteen pieces squared off down the west of the gallery hold 42 tiles, with two crystals and a
boulder in them, which is 47. The same nineteen laid along the river and closed round the south
as a staircase hold 58 tiles, two crystals and that same boulder: 63. The third crystal lies out east
past the tip of the water, where nothing these nineteen pieces can draw will reach it.

It stands outside the climb the way every world's eighth field does. A broad board leaves a wide gap
against a squared-off pen because it is broad, which says more about its size than its difficulty —
this asks 34%, the least anything in the world asks, while holding more ground than all but one pen
anywhere.

## 9. The Roost — 20 pieces, 45

```
......###..
.....#Toa#.
...~~~~aoo#
..~~o#Uooo#
.~~ooo#ooo#
~~ooooo#o#.
.#ooooPo#..
..#oaox#...
...#oo#....
....##.....
```

The boss, and the sixth rule the game has: **the roost hangs together and the pig hangs apart**.
Three animals on one board for the first time anywhere — a bat, its pup, and the pig — and two
things asked at once that pull opposite ways. The two bats in the same pen, because a roost is not
split; the pig in another, because a pig underfoot is not what a roost wants over it. One budget for
both pens, and either half of the rule broken is the field lost.

Which is every other multi-animal board's answer forbidden at once, and two of them forbidden by the
same wall. Stag Mere lets the budget fall wherever it scores best; Boar Hollow insists on two pens
and does not care which animals are in them; Rat King Wharf demands one pen round the pair; Wyrm
Caldera throws the second animal out; Visitor Crater wants two pens holding the same ground. Here
the pens are two and *which animal is in which* is the whole of it — so the cheap answer, three
little boxes so that nothing can possibly be sharing, is turned down flat, because a pup boxed on
its own is a roost split.

The river comes in off the west wall low down and climbs north-east across the cave, and the bat and
its pup hang either side of the tip of it: the water runs between them. Joining them means reaching
round that tip — and reaching round the tip is what hands the pig the whole staircase as the wall of
its own pen. So the one wall the budget cannot afford to leave out does both jobs, and finding it is
finding the field.

The best pair of blocks holds 22 between them. The answer hangs the roost in a pocket of 14 tiles off
the east end of the river with two crystals in it, and gives the pig 21 tiles of the wide floor
south-west of the water with the third crystal and a boulder it cannot get out of swallowing: 45.

It asks for 21 of the 24 stars below it before it opens.

---

# Lantern Carnival

The seventh world, solved the same way and drawn the same way. A toffee apple takes the meadow's
apple and a guy rope its skull, so an `a` below is a toffee apple worth five tiles to shut in, and
an `x` a guy rope worth five fewer that no piece will build on — a peg is already somebody else's
post and there is no room beside it for one of yours. An `M` is the ringmaster, and the last field
will not have the pig in with him or beside him either.

What the carnival does differently is that the water is **the crowd**, and the crowd stands in
**blocks**. A meadow has meres, a thicket pools, a mountain tarns, a city canals, the reaches a
scatter of single drops and the caverns one long river; on all eight fields here every `~` below is
part of a filled rectangle of two tiles or more — a stall, a queue, the wall of a tent — with never
a bend in it and never a drop standing on its own. The boss breaks that on purpose, and the last
diagram in this file is why.

Which is not one long edge to follow but several short ones with **gangways** between them, and a
gangway is one piece to close. So a pen out here is assembled rather than followed: pick which
blocks to string together, pay a piece for each gap, and take whatever shape those blocks leave.
It is why the pens below are lopsided where the caverns' were wedges and the reaches' were diamonds.

The other half of the world is **the run**. There is guy rope on every board, and never one peg on
its own — always two or more in a straight line. One hazard is a tile to build around, which every
world since the meadow has had. A run of them is a length of ground no wall may cross, and since a
pen may not lean on a rope either, a run of two is a strip of dead ground three tiles wide. The
crowd is a wall the board gives you and a guy rope is a wall the board forbids you, and that is
what holds the world at 37% and above, the highest floor in the game.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Coconut Shy | 14 | 24 | 1 toffee apple | 29 | 18 |
| 2 | Sideshow Row | 14 | 39 | 2 toffee apples, 2 guy ropes | 39 | 24 |
| 3 | The Turnstile | 14 | 30 | 1 toffee apple | 35 | 21 |
| 4 | Ticket Line | 15 | 34 | 2 toffee apples, 2 guy ropes | 34 | 20 |
| 5 | The Toffee Stand | 17 | 33 | 1 toffee apple | 38 | 22 |
| 6 | The Big Top | 11 | 51 | 2 toffee apples, 2 guy ropes | 51 | 25 |
| 7 | The Rigging | 18 | 37 | 1 toffee apple | 42 | 21 |
| 8 | The Midway | 19 | 49 | 2 toffee apples, 2 guy ropes | 49 | 30 |
| 9 | The Centre Ring | 22 | 35 | 1 toffee apple | 40 | 17 |

## 1. Coconut Shy — 14 pieces, 29

```
...........
.~~.....~~.
.....#.....
...~~o~~...
..#ooooo#..
..#ooPooo#.
...#oooooo#
....##oooo#
..a.xx#oa#.
.......##..
...........
```

Four stalls set out in a shallow vee across the top of the ground, with the gangways between them
wide open and the whole southern side of the fair missing. The basin question asked on the only
kind of bank the carnival has: not one shore but four short ones, so following it means paying a
piece at each gap and deciding which gaps are worth the piece.

Fourteen pieces hung under the vee as a rectangle hold 18 tiles and neither apple. The answer
spends one piece in the gangway at the bottom of the vee — which buys the tile in the gap as
ground, and both blocks either side of it as wall — and then runs south-east under the eastern arm
and tapers back in: 24 tiles and the eastern apple, which is 29. The western apple lies out past the
arm of the vee, with the run of rope pegged along the only line a southern wall could take to reach
it.

## 2. Sideshow Row — 14 pieces, 39

```
..~~.......
..~~.......
.#oo~~.....
#ooo~~.....
#ooooo~~...
#ooPoo~~...
#ooooooo~~.
#ooooooo~~.
#aoxxoo#...
.#oooa#....
..####.....
```

A row of sideshows stepping away south-east, each one its own block of crowd, with a gangway on
the diagonal between every pair. Fourteen pieces squared off beside the row can only get one of
their four sides against it and hold 24.

The answer mirrors the row back at itself: a staircase of its own down the west, cutting each
gangway on the diagonal so that no gap ever costs more than the piece that crosses it. Thirty-nine
tiles, both apples and both guy ropes shut in with them, which comes back to 39. The pair of ropes
sits square in the middle of the ground the row encloses, so the pen swallows them and pays their
ten — which the tiles round them more than cover.

## 3. The Turnstile — 14 pieces, 35

```
............
.....a......
............
~~~~~.~~~~~~
.....#ooooo#
..xx#oooooo#
...#oPooooo#
...#oooooo#.
....#oooo#..
.....#oa#...
..a...##....
............
```

The queue for the gate runs the whole width of the fair, and there is one turnstile in it: two
blocks of crowd, rim to rim, with a single tile of ground between them. One piece in that tile and
all eleven tiles of queue are wall — Otter Ford's lesson, and Lock Gate's, and Stillwater Neck's.

Everybody finds that piece. The block this field is measured against spends it too and hangs a
plain rectangle underneath for 21. What the block cannot then do is spread west, because the run of
rope is pegged just south-west of the gate and no wall may lie along it. The same fourteen opened
out east as a lozenge instead hold 30 tiles and the apple in the middle of them: 35. The apple
north of the queue is on the far side of the crowd, where every far bank in the game keeps its
treats.

## 4. Ticket Line — 15 pieces, 34

```
...........
....#......
..~~o#.....
..~~oo#....
.#ooxxo#...
#ooooPoo#..
#oooaoooo#.
.#oaooo~~..
..#oooo~~..
...#oo#....
....##.....
```

Two queues standing well apart, one north-west and one south-east, and a run of rope pegged between
them exactly where a wall from one to the other would want to lie. The span question: neither queue
is any use on its own, and no rectangle on this board reaches both, so squaring off leans on one of
them for 20.

Fifteen pieces run on the diagonal from the corner of the near queue to the corner of the far one
hold 34 tiles with both apples and both ropes inside them, which comes back to 34.

The ropes were never a choice. The pig stands directly under the pair of them and no piece will
stand on a rope, so nothing can be walled between her and them: this is the one board at the fair
whose hazards are in every pen it has, however the budget falls. What the diagonal buys is the
second queue — a rectangle can lean on one of them and only a slanted wall leans on both — and the
two apples it collects on the way are what pay the ropes back.

## 5. The Toffee Stand — 17 pieces, 38

```
......##...
.a...#oo#..
....#oooo#.
.~~~oooooo#
.~~~oooooo#
...#Pooooo#
....#ooooo#
...xx#ooo#.
......#a#..
.....a.#...
...........
```

Three toffee apples dropped where the tidy pen does not go, and one block of crowd off to the west
doing a third of a wall's work. The best block seventeen pieces square off against that crowd holds
21 and reaches one apple, so the field is which of the other two to go out for.

The one hanging in the south is three tiles of wall below where the pen would otherwise stop, and
the run of rope is pegged directly between it and the pig, so the wall that fetches it has to go
round the pair as well — more wall than five points pay for. The one up in the north is reached by
running the pen up the eastern side of the crowd and closing over the top of it: 28 tiles and two
apples, which is 38.

## 6. The Big Top — 11 pieces, 51

```
............
~~~~~~~~~~..
#ooooooooo~.
#ooooooooo~.
.#oooaoooo~.
..#oPooooo~.
...#oooxxo~.
....#ooooo~.
.....#oaoo~.
......#ooo~.
.......###~.
```

The crowd runs along the front of the big top, turns at the corner and goes down the far side, so
two of the four walls are handed over before a piece is laid. The corner question the way Rimstone
Corner asked it, and the hardest corner in the game — with eleven pieces, the smallest budget at
the fair, to draw the other two sides.

What makes it hard is where the guy ropes are pegged. A right-angled block in this corner is a
rectangle hung under the crowd, and the pair of ropes lies inside every rectangle worth drawing, so
the tidy pen has to swallow them and pay their ten: 25, where the same block on clear ground would
be 35. The eleven laid corner to corner instead — one long diagonal from the west side down to the
south-east, cutting the whole bend off in a single line — hold 51 tiles, both apples and the same
pair of ropes, which comes back to 51. The biggest pen in the world for the smallest budget in it,
which is what two free sides are worth.

## 7. The Rigging — 18 pieces, 42

```
............
.~~~...x.x..
.~~~...x.x..
.~~~.x.x.a..
#ooo#x##....
#oooP#oo#...
#oooooooo#..
.#ooooooo#a.
..~~~ooooo#.
..~~~ooooa#.
.....#ooo#..
......###...
```

The guying behind the tents, and the hardest field in the world: seven pegs in three runs, laid out
across the only ground worth having. Every board above this one puts its hazards down one at a time
and never two of them touching — two on Sour Ground, two on Gutter Lane, three on Boulder Chamber.
This is the most rope on any field in the game and the only line of three in it, and a line of two
is three tiles of dead ground rather than one, because a wall that does not shut a rope in has to
stand a clear tile off it.

Every rectangle worth having runs into one, so squaring off means retreating down the west and
swallowing the pair of ropes nearest the pig on the way: 31 tiles less their ten, which is 21, and
the whole budget spent on it.

The answer keeps clear of every peg on the board instead. It takes the wide ground south and east
and comes round the apple lying down there rather than over it: 37 tiles and that apple, which is
42. No piece will lie on an apple any more than on a rope, so the wall cannot run through it and
cannot pretend it is not there — it comes inside and pays for itself, or the pen stops short. The
run of three and the pair beside it are left standing out in the north: five pegs, twenty-five
points to shut in, and the ground behind them is not worth that. At 50% it leaves the widest gap
of any ordinary field at the fair.

## 8. The Midway — 19 pieces, 49

```
....#.......
..~~o#......
..~~oo#.a...
.#ooooo#....
#ooooxxo#...
#ooPooooo#..
#ooooooooo#.
#oooooo~~~..
.#aoooo~~~..
..#oooo#....
...#oa#.....
....##......
```

The longest walk at the carnival: twelve tiles by twelve, a stall at the top of it, the crowd round
the waltzer at the bottom, three apples down the length and the biggest budget any field here gets.

Nineteen pieces squared off down the middle of the walk hold 30 tiles with two apples in them and
the pair of ropes lying across them, which comes to 30. The same nineteen run out to both blocks of
crowd and closed round the south hold 49 tiles, two apples and that same run of rope: 49. The third
apple hangs up in the north-east past the stall, where nothing these nineteen pieces draw will
reach it.

It stands outside the climb the way every world's eighth field does. A broad board leaves a wide gap
against a squared-off pen because it is broad, which says more about its size than its difficulty —
this asks 40, less than three of the fields below it, while holding the second biggest pen at the
fair.

## 9. The Centre Ring — 22 pieces, 40

```
.....#.....
....#a#....
.xx#ooo#xx.
..#ooooo#..
.#oo~~~oo#.
#ooo~M~ooo#
#ooo~~~ooo#
.##Poooo##.
.xx#ooo#xx.
....#o#....
.....#.....
```

The boss, and the seventh rule the game has: **the ringmaster keeps the middle and the pig has to
close all the way round him.** Every rule before this one is about which animal ends up in which
pen. This one is about where one pen stands in relation to the other, which nothing in the game has
asked before — the pig may not be in with him, and her ground has to leave him no way off the board
that does not cross it.

So the answer five worlds have taught is refused. Two tidy pens side by side wins Boar Hollow and is
what two animals on a board have meant since the thicket; here a pen beside his is a pen and not a
ring. Four pieces round the pig where she stands hold her perfectly well and leave eighteen of the
budget unspent, and the board sends it back. So does the wall that comes three quarters of the way
round and closes on itself: every piece of it holds, and he walks out of the side that was left
open.

He stands in the middle of a three by three of crowd, which is the one thing here that makes
squaring the board off possible at all. A rectangle laid over that crowd comes out with a hole in
it and the ringmaster in the hole: twenty-two pieces boxed round it that way hold 16 tiles of
walkway, and the single tile he is standing on makes 17. A fair answer, and one nobody has to be
taught.

The same twenty-two run out as an octagon — out from the pig's corner, round the crowd on all four
diagonals and back to where they started — hold 35 tiles and the toffee apple hanging over the
ring, which is 40. The four runs of rope pegged at the corners are what stop it being a bigger
octagon: the wall has to come inside them on every diagonal, and a ring that must be inside four
corners at once has very little slack in it. Take the ropes off the board and the same budget
reaches 46.

It asks for 21 of the 24 stars below it before it opens.

---

# Sunbaked Dunes

The eighth world, solved the same way and drawn the same way. A melon takes the meadow's apple and a
cactus its skull, so an `a` below is a melon worth five tiles to shut in, and an `x` a cactus worth
five fewer that no piece will build on — there is no room beside a cactus for a post of yours. An `S`
is the scorpion, and the last field will not have the pig in with him *or* sharing a wall with him.

What the dunes do differently is that every `~` below is **a crescent**. A barchan: a straight back
with a horn trailing off each end, one tile thick, so the sand comes back on itself. A meadow has
meres, a thicket pools, a mountain tarns, a city canals in straight runs, the reaches a scatter of
single drops, the caverns one stepped river and the carnival filled blocks with never a bend in
them; on all eight fields with sand on them here there is nothing but bends, and every crescent on a
given board opens the same way, because a wind blows one way across a field.

Which is new in what it **offers**. Every world below hands a pen one wall to follow, or two meeting
at a corner. A crescent hands over a finished pen: the shade inside it is dry ground with sand on
three sides of it, and the only thing to pay for is the mouth. It is the cheapest pen in the game.

And that is the trap, which is the whole world. The belly of a dune is rectangle-shaped, so it is
exactly what squaring a board off finds — and it is a fixed size, because the sand is where it is
and no amount of budget widens the shade. So every pen below turns the free one down, and the first
board says why by standing a cactus in each end of the shade. One field has no sand on it at all:
The Hardpan, where every tile is bought.

| # | Level | Pieces | Ground held | In the pen | Score | Squared off |
|---|---|---|---|---|---|---|
| 1 | Slipface Hollow | 14 | 43 | 2 cacti | 33 | 20 |
| 2 | The Long Slack | 14 | 28 | 1 melon | 33 | 19 |
| 3 | The Blowout | 13 | 32 | nothing | 32 | 18 |
| 4 | The Hardpan | 21 | 45 | nothing | 45 | 25 |
| 5 | Two Horns | 18 | 50 | 2 melons, 2 cacti | 50 | 29 |
| 6 | Melon Ground | 17 | 35 | 2 melons, 2 cacti | 35 | 19 |
| 7 | Scarp Corner | 11 | 41 | nothing | 41 | 20 |
| 8 | The Great Erg | 19 | 56 | 3 melons, 3 cacti | 56 | 33 |
| 9 | Scorpion Flats | 16 | 45 | 1 melon | 50 | 19 |

## 1. Slipface Hollow — 14 pieces, 33

```
....a......
.~~~~~~~~..
.~xoooox~..
#oooooooo#.
#oooPooooo#
.#oooooooo#
..#oooooo#.
...#oooo#..
....#oo#...
.....##a...
...........
```

One wide, shallow barchan across the north of the hollow, with the pig out on the open sand below
its mouth. The basin question, asked on the only kind of bank this world has — and asked as a
refusal, which is how the dunes introduce themselves.

The shade under the back is a finished pen: six tiles with sand on three sides of them and a
six-tile mouth to plug. It is also where both cacti are, so six pieces buy six tiles and minus ten
points, and the pig is not in it in any case. A player who takes the gift the sand is holding out
has been handed nothing at all.

So the answer is the shade *and* everything under it. The best rectangle fourteen pieces can square
off is the belly plus three rows below it — thirty tiles with the pair of cacti in them, which is 20.
The same fourteen hung as a lozenge from the two horns and tapered to a point in the south hold 43
tiles and the same pair, which is 33.

Both melons lie where fourteen pieces do not go: one on the far side of the back, which is a far
bank like any other, and one a tile past the tip of the lozenge. Not everything in a desert is worth
walking to.

## 2. The Long Slack — 14 pieces, 33

```
~.~........
~~~........
...#.......
..#o~.~....
.#oo~~~....
#oooooo#...
x#Pooooo~.~
x.#ooooo~~~
...#ooooo#.
....#ooa#..
....a###...
```

Three barchans marching away south-east down the slack with their backs turned, and a gangway on the
diagonal between every pair of them. The shore question asked on a bank that is not one bank but
three, set on the slant — Sideshow Row's lesson with horns on it.

Fourteen pieces squared off beside the rank can get one side against one dune and hold 19. The same
fourteen laid as a staircase that mirrors the rank back at itself, cutting each gangway on the
diagonal, shut 28 tiles and the melon in the south with them, which is 33 — because a diagonal wall
closes two tiles a piece where a straight one closes one, and a rank of dunes set out on the slant is
how the sand says so.

The pair of cacti is pegged against the western rim right where the pig stands, and the answer walls
in beside them rather than swallowing them: the wall comes down between her and the pair, and their
ten points stay outside. The second melon is a row further south again, outside everything.

## 3. The Blowout — 13 pieces, 32

```
............
.....a......
.....#......
~...~o~....~
~~~~~o~~~~~~
#oooooooooo#
.#oooooooo#.
..#oooooo#..
...#oPoo#...
....#oo#....
.....##..a..
............
```

One ridge of sand the whole width of the board — two barchans back to back, horns standing up out of
it — with a single dry tile blown through the middle of the back where the wind got round. So this is
Otter Ford's lesson and Lock Gate's and The Turnstile's: put one piece in the blowout and the whole
ridge is wall.

Everybody finds that piece, and the block this field is measured against spends it too. It hangs a
four by four under the gap, which with the two tiles of the blowout itself comes to 18. What the
rectangle cannot then do is use the rest of the ridge, because a rectangle only has one north side.
The same thirteen pieces run out under the whole length of the sand and closed as a lozenge hold 32
tiles.

The melon north of the ridge is on the far side of the sand, and like every far bank in the game
nothing reaches it. The one in the south-east is three tiles outside the lozenge, in the corner the
taper leaves behind — the cheaper lesson of the two, since a melon is five points and the wall that
fetches it is four pieces of shape.

## 4. The Hardpan — 21 pieces, 45

```
.....##....
....#oo#...
...#oooo#..
..#oooooo#.
.#oooooooo#
#ooooPoooo#
.#ooooooo#.
..#ooooo#..
...#ooo#...
....#o#....
.a...#...a.
```

The ground the sand never reached: bare hardpan eleven tiles in every direction, no dune anywhere on
it, and the biggest budget of any field in the world laid out across it. It is The Blind Grike again,
and Basalt Flats and Cobble Yard and Swept Flat before it, and the answer is the answer it always
was — the best block twenty-one pieces can square off is a five by five holding 25, and the same
twenty-one run round as a diamond hold 45.

A diagonal wall shuts two tiles per piece where a straight one shuts one, and on ground with nothing
on it there is nothing else to know. Which is why the hardpan is the one field here a player has met
before, and why it stands in the middle of the trail rather than at the start of it: a world whose
whole idea is a free wall needs one board that withholds it, and it turns out to ask more than the
ridge with a hole blown through it does.

A melon lies at each end of the southern edge, and twenty-one pieces will not reach either. On ground
with no free wall on it five points is four pieces of fence, and four pieces of diamond are eight
tiles.

## 5. Two Horns — 18 pieces, 50

```
....###....
.~~~ooo#...
.~o~oooo#..
#oooooooo#.
#oooxxoooo#
#ooooPoooo#
.#ooaooooo#
..#oooo~~~.
...#ooo~.~.
....#a#....
.....#.....
```

Two barchans set on the diagonal from one another — one in the north-west, one in the south-east,
both with their mouths open to the south — and the pig on the open sand between them. The span
question: neither dune is any use on its own, and no rectangle on this board reaches round both.

Squaring off gets one corner against each of them across the middle of the board and holds 29.
Eighteen pieces run out as a great lozenge from the one to the other hold 50 tiles, both melons and
both cacti — the melons pay the cacti back exactly, so the pen is worth its ground and no more. It
takes the northern dune's shade into the pen and leaves the southern one's outside, which is the
board's own answer to the question it asks.

The run of cactus is pegged directly north of the pig, and it is the one thing that stops the lozenge
being tidier than it is: no piece will stand on a cactus and no pen may lean on one, so the wall that
comes down between the two horns has to come round the pair.

## 6. Melon Ground — 17 pieces, 35

```
......##...
.....#oo#..
....#ooao#.
.~~~oooooa#
...~oooooo#
.~~~ooooo#.
.#ooPooo#..
..#xxoo#...
...#oo#....
....##a....
...........
```

One barchan with its back to the east and its mouth open west, three melons scattered wide over the
open sand, and a pair of cacti pegged down the middle of the field. The detour question, and the
hardest one in the game.

Seventeen pieces will square off a block under the crescent's southern horn, which does the
north-west corner for nothing: 24 tiles holding the melon in the south and both cacti, which is 19.
That is the tidy answer, and the melon it is holding is the one melon of the three that is easy to
hold.

So the field is whether to give that one up and go out for the other two, and it is: the same
seventeen run out as a lozenge reach the melon in the north and the melon in the east, 35 tiles with
those two in them and the same pair of cacti, which is 35. What is more, the wall the lozenge comes
back on has to come round the melon it left behind rather than over it — no piece will lie on a
melon — so this pen gives up a melon and a tile of ground for its own shape, which is the plainest
way a board has ever said that a tile of pen is worth having.

The pair of cacti lies in the middle of the ground either answer has to cross, so there is no drawing
either pen without swallowing them and paying their ten. The tiles the detour fetches cover it twice
over.

## 7. Scarp Corner — 11 pieces, 41

```
............
~~~~~~~~~~..
~oooooooo~..
~oooooooo~..
#ooooooooo#.
.#oPooooo#..
..#ooooo#...
...#ooo#....
....#o#.....
..a..#...a..
............
............
```

The scarp: one great barchan hooked into the north-west so its back runs nearly the whole width of
the north and its western horn stands on the rim of the board. Two sides of a pen handed over, and
eleven pieces — the smallest budget in the world — to draw the rest. The corner question with two
free sides, the way Rimstone Corner and The Big Top asked it, and the hardest corner in the game.

The right-angled answer hangs a rectangle under the back and pays for its own east wall: 20 tiles,
stopping three columns short of the eastern horn because eleven pieces will not reach it and turn the
corner as well. The eleven run instead as one long chevron — out from the western rim, down across
the whole mouth of the crescent and back up to a point in the south — and hold 41 tiles. That is
nearly four tiles a piece, the best rate anywhere in the world, and it is what two free sides and a
diagonal are worth together.

The two melons lie in the south, well outside the chevron on either side of its tip. Eleven pieces
will not stretch to either, and on a board where two of the walls came free five points is still four
pieces of fence.

## 8. The Great Erg — 19 pieces, 56

```
.....###....
..~~~ooo#...
..~oooooa#..
..~~~ooooo#.
.#oPooooooo#
#oooooooooo#
#oooxxxooo#.
.#ooooo~~~..
..#oooo~....
...#ooo~~~..
....#aa#....
.....##.....
```

The sand sea: twelve tiles by twelve, two barchans with their backs to the west standing at opposite
ends of it, a run of three cacti across the waist and three melons down the length.

Nineteen pieces squared off down the middle of the sea from the northern dune's back hold 38 tiles,
two of the melons and all three cacti, which comes to 33. The same nineteen run out to both dunes
and closed round the south hold 56 tiles, the third melon as well and the same three cacti, which is
56 — the biggest pen in the world, and the third biggest in the game, behind Wide Reaches and
the Great Gallery, which the sand very nearly took second place from.

It stands outside the climb the way every world's eighth field does. A broad board leaves a wide gap
against a squared-off pen because it is broad, which says more about its size than its difficulty —
this asks 41, less than four of the seven fields above it.

## 9. Scorpion Flats — 16 pieces, 50

```
...........
.~~~~~~~~~.
.~ooooooo~.
#ooooooooa#
#ooooooooo#
#oooooooo#.
#ooo~~~o#..
#ooo~S~#...
#ooo##.....
.#P#.a.....
..#........
```

The boss, and the eighth rule the game has: **a scorpion stings through a fence, so the two pens may
not share one.** It is the direct inversion of the game's oldest boss lesson. Stag Mere taught that
two pens can share a wall — one boundary doing two jobs — and the search has priced a shared wall at
half ever since; every boss from Boar Hollow to The Centre Ring is built on that discount. This one
takes it away. The pig may not be standing in with him, and no piece of fence may have her ground on
one side of it and his on the other, so the ground between the two pens has to be given up unclaimed
and one budget has to pay for two whole walls.

He is standing in the shade of a barchan three tiles wide, which is what makes the board answerable
and what makes it hard at the same time. Three of his walls are free and one piece shuts him in —
the cheapest pen in the game — and that one piece is a piece she may not use, so the sand round it is
ground she may not have either. Her wall has to come past the notch and close behind it, giving it a
berth, which is a thing no rectangle can do.

So the answer five worlds have taught is turned down twice over. One pen round the pair of them wins
Stag Mere and Rat King Wharf, and nine pieces do it here — up the lane and over the both of them,
with seven of the budget unspent — and the board sends it back. And so does the pen above with a
single piece moved a single tile: run the wall straight up to his own south wall instead of stopping
short and closing behind it, and every piece still holds, nothing is loose, the pig has one tile
*more* than she has here and it would score 51. One piece of fence then has her ground on one side of
it and his on the other, which is a wall the sting goes straight through, so it is not a wall between
them at all.

Sixteen pieces is the smallest budget any boss in the game hands out. The cheapest legal pair it
buys is the tidy pair of pens side by side: four pieces box the pig where she stands on her one tile,
and the rest wall the open sand east of the notch as the scorpion's own yard with the melon inside
it — 14 tiles and that melon, which is 19. A fair answer, and one nobody has to be taught. The same
sixteen laid as above — out from the pig up the west of the flats, along under the great back in the
north and down round the far side of the notch — hold 45 tiles and the melon in the north-east, which
is 50: the biggest pen any boss holds, and at 62% the widest gap any board in the game leaves.

The melon left lying in the lane is the board saying what the rule costs. It sits in the clear ground
between the two pens, so this is the only pen in the game that walks past five points it can see and
leaves them where they are.

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
