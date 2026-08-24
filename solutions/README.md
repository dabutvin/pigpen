# Solutions

**Spoilers.** This is the best pen every puzzle in the game has in it — the pen each
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

One file to a world, in the order the universe map unlocks them. Each holds that world's
table of best pens and all nine of its maps drawn out, boss last.

## The worlds

| # | World | Treat | Hazard | Boss |
|---|---|---|---|---|
| 1 | [Mudlark Meadow](01-mudlark-meadow.md) | apple `a` | skull `x` | Stag Mere |
| 2 | [Thornwood Thicket](02-thornwood-thicket.md) | mushroom `a` | wilted flower `x` | Boar Hollow |
| 3 | [Emberpeak](03-emberpeak.md) | coin `a` | flame `x` | Wyrm Caldera |
| 4 | [Cogsworth City](04-cogsworth-city.md) | pizza `a` | trash can `x` | Rat King Wharf |
| 5 | [Starfall Reaches](05-starfall-reaches.md) | star `a` | meteor `x` | Visitor Crater |
| 6 | [Gloamdeep Caverns](06-gloamdeep-caverns.md) | diamond `a` | boulder `x` | The Roost |
| 7 | [Lantern Carnival](07-lantern-carnival.md) | popcorn `a` | megaphone `x` | The Center Ring |
| 8 | [Sunbaked Dunes](08-sunbaked-dunes.md) | melon `a` | snake `x` | Scorpion Flats |
| 9 | [Tidepool Cove](09-tidepool-cove.md) | seashell `a` | jellyfish `x` | The Crab Pool |
| 10 | [Frostwhisker Tundra](10-frostwhisker-tundra.md) | ski `a` | ice slick `x` | The Haulout |
| 11 | [Mirebog Fen](11-mirebog-fen.md) | lotus flower `a` | mosquito `x` | The Wallow |
| 12 | [Cloudspire Heights](12-cloudspire-heights.md) | rainbow `a` | storm `x` | The Eyrie |

Every world is the meadow's game on new ground, so a treat is worth five tiles to shut in
and a hazard five fewer wherever you meet it, whatever it is called locally. The six ideas
all of these answers are built out of are set out in
[Mudlark Meadow](01-mudlark-meadow.md#what-the-solutions-have-in-common), the world that
teaches them.

## How to read a diagram

```
#  a fence piece            o  ground inside the pen
P  the pig                  .  mud outside the pen
D  the deer                 B  the boar
W  the wyrm                 R  the rat king
V  the visitor              T  a bat
U  its pup                  M  the ringmaster
S  the scorpion             C  the crab
L  the bull seal            G  the old croc
E  the eagle
a  an apple                 x  a skull
~  water
```

A treat inside the pen shows as its own letter on `o` ground. Neither kind ever has a `#` on
it: nothing can be built on an apple or a skull, so a wall that wants one of those tiles is
built round it instead.

A pen scores a point per tile of ground it holds, five more for every apple inside it and
five fewer for every skull.

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
star thresholds that go with it. That is where every number in these files came from. `--demand`
adds the squared-off pen underneath — the best plain block the same budget buys — and the
gap between the two, which is what decides where on the trail a level belongs.
