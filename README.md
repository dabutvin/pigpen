# Pigpen

An iOS puzzle game about trapping a pig. You get a grid, a pig, and a strict number of
fence pieces. Pen the pig in — and pen in as much mud as you can while you are at it.

## The Game

- **The pig** starts on a fixed tile and walks up, down, left or right, never diagonally.
- **Fences** fill in whole tiles. Tap a tile to wall it off; the pig cannot walk through it.
  Press and drag to lay a whole run at once — starting the drag on a fence tears out
  everything you drag over instead. You have a fixed budget of pieces per puzzle, standing on
  a rack over the board: one picket for every piece the level allows, and an empty socket for
  every one already in the ground. Corners cost nothing, since a pig cannot cut across one.
- **Undo and redo** walk back and forth through the field a press at a time, so a drag laid
  in the wrong place comes out in one go rather than tile by tile. Clearing the field is a
  press like any other and one undo brings the whole thing back. Laying a new piece gives up
  whatever was waiting to be redone.
- **Water** — rivers and lakes — is a permanent boundary the pig cannot cross. You cannot
  build on it and you never need to: it walls the pen for free. Build against it instead of
  spending fences.
- **Apples and skulls** lie on the mud rather than being mud of their own, and neither of
  them takes a fence. Both are staked into the ground: no piece can be laid on either, so a
  wall that wants one of those tiles has to be built round it — and a wall built round one
  still has to shut it out, since ground you leave open is ground the pig walks onto. Ground
  with something on it is planned around, not paved over.
  What separates them is only the sign. An apple shut into the pen is worth five ordinary
  tiles, so a pen that goes out of its way for one is usually worth the ground it gives up
  getting there; a skull costs five, so a pen usually wants it outside. Either way the choice
  cannot be declined: a wall that meets a treat has to swallow it or step in beside it.
  Tapping either says what it is worth — `+5 points`, `-5 points` — rather than shaking the
  fence rack like a spent budget.
- **Escape.** Release the pig and it tries every route. If a single gap leads to the edge
  of the map, it walks out and the attempt fails.
- **A pen that holds gets a lap of honour.** With nowhere to go, the pig runs two circuits
  of the ground you shut it into — leaning into the corners, bobbing on every tile it
  covers — and finishes on a hop where it started, under confetti thrown up out of its own
  tile. Only then does the score come up, through the last of the falling paper. A pen too
  narrow for a circle is run out and back instead, one too tight for that is bounced on the
  spot, and the best pen the map has in it gets its confetti in every colour there is. Ask
  for reduced motion and the field keeps still.
- **The boss changes a rule.** A world's last puzzle stands a second animal on the field as
  well as the pig — a deer in the meadow, a boar in the thicket, a wyrm on the mountain, a rat
  king in the city — and each world asks something different of the pair. The meadow's one
  budget has to hold both of them. One pen round the pair or a pen apiece is up to you — a pen
  holds whatever ground
  it shuts in, whether that ground is in one piece or two — but an animal left loose loses
  the field however well the other one is held.
- **A pen that closes colours itself in.** The moment the last gap is filled, the ground the
  fencing holds washes gold, so you can see the pen you have made before you commit to it.
  Releasing the pig is still yours to do — the wash only says the pig has nowhere to go.
  Take a piece back out and the wash goes with it.
- **The best pen the map has in it goes rainbow.** A pen worth that much drifts through the
  spectrum instead of sitting gold, from the moment you close it. There is nothing above it
  to aim for.
- **Score.** A point for every mud tile inside a pen that holds, five more for every apple
  in it and five fewer for every skull — and never less than a point, however sour the
  ground. Four pieces boxed in around the pig always work and score 1, so the puzzle is not
  whether you can pen it but how much the same budget can be made to hold. A pen that holds
  invites you back out to better it — until it is the best pen the map has in it, which the
  game knows and says so.
- **Your best pen is kept, and you can go back to it.** A pen counts the moment it closes,
  so the running best is yours without letting the pig go. Rearrange the fencing, see the
  tally say the new arrangement holds less ground than the old one, and *Put it back* — the
  trophy beside the tally — stands every piece exactly where it stood on your best, however
  many presses ago that was and even after clearing the field. Undo walks back a press at a
  time; this goes the whole way in one, and is itself one press to undo. It lasts as long as
  you stay on the puzzle. Holding the same ground with a piece to spare replaces the best
  too, since the spare piece is one more to widen with.

The first puzzle, **River Bend**, hands you 12 fence pieces. A free-standing box that size
holds 9 tiles; hugging the river and the pond holds 35, which is every tile the pig can be
shut into — a wider pen would have to hold ground on the rim of the map, and the pig just
walks off it. That 35 is the level's `maximumScore`, and the pen it goes rainbow for.

The next two puzzles put apples and skulls on the ground, so the best pen there is no longer
the widest one. **Windfall Orchard** hands out 12 pieces for a map with four apples on it:
the pen that scores highest holds 27 tiles and narrows as it goes south to bring two of the
apples inside, which is worth more than the ground it gives up doing so. **Sour Ground** adds
two skulls, and neither can be built on: the best pen there bends its wall in beside the
skull by the lake to leave it outside, and pays the five tiles to shut the other one in
rather than give up the ground a detour round it would cost. 24 tiles, two apples and one
skull: 29.

**Stag Mere** is the boss, and it is everything at once: a mere across the middle of the map
with the pig grazing north of it and a stag south, apples on both shores and a skull on
each. The 20 pieces — the biggest budget in the game — go out as two enclosures rather than
one, because the water is a wall both of them can lean on and a single pen round the pair
would spend its whole budget getting there. Every piece given to the pig is a piece the stag
does not get, which is the puzzle. Both skulls stand where a wall would want to go and
neither will take one, so each pen swallows its own and pays for it. The best split holds 33
tiles, three apples and the two skulls: 38.

## The World

Play leads into **Mudlark Meadow** until that world is held, and only then opens the
**universe map** (below). The meadow is nine puzzles as nine signposts up one winding trail,
with the pig standing at the furthest one it has reached and mist over everything past that.
The first six are fencing and water alone and climb in what they ask of you, the next two
scatter apples and skulls as well, and the last is the boss. Every world in the game is a
trail like this one.

- **Beating a level opens the next one.** Any pen at all is enough — one star will do it.
- **The boss is paid for in stars.** Stag Mere wants 21 of the 24 the eight levels below it
  hold, on top of them all being beaten, and its signpost carries the price from the first
  time you see it. Scraping through the meadow is not enough to get in: you have to go back
  down the trail and better the pens you rushed. The star that pays it opens the level
  wherever on the trail it was won, and the pig sets off up the meadow for it there and then.
- **The pig walks there.** Come back from a level you have just beaten and it sets off up
  a length of trail that was not there before, the map scrolling along behind it, and the
  mist pulls back off the signpost it arrives at.
- **Stars stay on the signpost.** Each one shows the best you have ever done there, so a
  level replayed badly costs you nothing and a level replayed well is worth going back for.
- **The best pen there is turns a signpost's stars rainbow.** Three stars is set a little
  under the maximum, so it does not on its own say a map has nothing left in it. Match the
  best pen a level has and its stars drift through the spectrum from then on — the same
  rainbow the field washes with the moment such a pen closes — so one look up the trail
  says which maps are finished with and which are still worth going back down for. Like the
  stars, it stays: a worse pen afterwards does not take it off.
- **You can go back down the trail** to any level already open, and the pig trots down to
  it before the puzzle opens — and stays there when you come back out. Only something newly
  opened moves the pig on its own, so a replay leaves you standing where you chose to be.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | River Bend | 12 | — | 35 | 35 | — |
| 2 | Horseshoe Lake | 6 | — | 24 | 24 | — |
| 3 | The Narrows | 10 | — | 19 | 22 | 13% |
| 4 | The Dew Ponds | 12 | — | 32 | 44 | 27% |
| 5 | Otter Ford | 12 | — | 16 | 24 | 33% |
| 6 | Puddle Corner | 8 | — | 16 | 26 | 38% |
| 7 | Windfall Orchard | 12 | 4 apples | 30 | 37 | 18% |
| 8 | Sour Ground | 14 | 3 apples, 2 skulls | 22 | 29 | 24% |
| 9 | Stag Mere | 20 | a deer, 3 apples, 2 skulls | 34 | 38 | 10% |

"Best pen" is the most that budget can be made to score on that map: the level's
`maximumScore`, the number the third star is set just under, and the pen each level goes
rainbow for. On the first six maps it is a count of mud, since mud is all there is to hold;
after that it is mud and fruit against skulls. Either way it is a search rather than a
sum — `Tools/level_search.py` does the searching, and a test pins every one of them to a pen
that actually holds, so no level can promise a rainbow that is not there. Find one and the
world map remembers it, beside the stars for the level.

"Squared off" is the other end of it: the best pen you get from a plain block of ground per
animal, leaning on whatever water is already there, with no diagonal staircase and no detour
for an apple. It is what a player reaches for before they know any of the game's ideas, and
it is always worth at least two stars — nobody is ever stuck on one for want of a trick.
What a level **asks** is the gap between the two, and that is what the first six are ordered
by rather than by board size or budget.

Since nothing lying on the ground takes a fence, a block whose wall would have to stand on
an apple is nudged out over it before it is weighed — one piece more, one tile and five
points better off. That is the obvious local move, and it is the same widening the game
itself promises when it says every level can be finished by boxing the animals in where they
stand. It also means the treat-carrying levels ask less than they used to: a player who
never learnt to detour for an apple now collects the ones that happen to sit on the wall
they were going to build anyway.

The meadow opens on two maps whose best pen *is* the obvious pen, so the first three stars
are free and the game gets to explain itself. From there the gap widens the whole way to
Puddle Corner — eight pieces, a small board, and nothing to lean on but the shape of the
wall, which is the widest gap on that stretch and why the smallest-looking level closes it
instead of opening it. The last three change what is on the ground rather than what the wall
has to do, so they run apples, then skulls to build around as well, then a second animal and
one budget to split: sorting *those* by the gap would put the ideas in the wrong order. Sour
Ground used to read as the widest gap in the game, which said more about the block than about
the level — every squared-off block worth having on that map was one the player could not
build, so the measure had nothing sensible to compare against. Nudging the block out over
what it cannot be built on gives it something, and Sour Ground now reads as the ordinary
eighth stop it always was. `DifficultyTests` pins the lot, so the climb cannot quietly
flatten out again.

The same number keeps the *worlds* in order. Free three stars are something the first world
gets because it has the game to teach, and nothing after it is owed them: each world declares
a **floor** — the least any of its fields may ask — and a world's floor has to stand above the
floor of the world below it, while its opening field has to ask more than the last world's
opening field did. The meadow floors at nothing and opens on a map with no trick in it; the
thicket floors at 23% and opens at 25%, so the second world starts around where the first
world's middle sat; Emberpeak floors at 28% and opens there too, which is above anything
the thicket asked before its fourth field; Cogsworth City floors and opens at 30%; Starfall
Reaches floors and opens at 32%, on the biggest boards in the game; Gloamdeep Caverns floors and
opens at 34%; Lantern Carnival floors and opens at 37%; and Sunbaked Dunes floors at 38% and opens
at 39%, the highest floor any world has stood on. Bosses are held to each other rather than to the
floor:
a boss is one budget split between two animals, so the gap it leaves against a squared-off
pen understates it, and what is asked there is only that no world's boss splits its budget
for less than the last one did.

Each of those pens is drawn out in [`solutions.md`](solutions.md), which is spoilers from
the first line.

## The Universe

Hold every pen in Mudlark Meadow and its send-off pulls back to the **universe map**: the
world behind you, the next one lit up ahead, and the rest strung out past them through
space, each drawn as a little planet with its boss shown on it. A world opens once the one
before it is held, so the map is a chain — finish a world to reach the next — and the pig
carries the same game into every one of them.

- **Every world is the meadow's game on new ground.** Fence in the pig, the biggest pen the
  pieces will reach round, shut or it is no pen at all. What a theme changes is only the
  dressing: the light the trail is drawn in, the ground it runs over — mown pasture, woodland
  floor, bare scree, paving, star dust, wet flowstone, trodden sawdust or rippled sand — what the
  windfall and the hazard look like on that ground,
  and the shape that waits at the end. The board underneath never knows the difference, which
  is why one solver authors every level in the game.
- **The board is dressed too.** Not just the country around it: the field in the middle of the
  screen is painted in the world it stands in, so the mud, the water and the fencing are that
  world's. Mud is mud to the rules wherever it is — a tile that takes a fence — and water is
  still the wall a pen never pays for, but they are drawn as what a place like that would have.

  | World | Ground | Water | Fencing |
  |---|---|---|---|
  | Mudlark Meadow | mud, stones turned up in it | open water, light breaking on it | pickets and rails |
  | Thornwood Thicket | leaf mould, leaves where they fell | peat pools, rings on the still | woven hurdles |
  | Emberpeak | ash, cinder still going in it | a steaming tarn | stakes burnt black |
  | Cogsworth City | paving in courses of setts | a canal with a slick on it | wrought iron railings |
  | Starfall Reaches | dust, pitted where things landed | a well a star went into, still lit | posts with a light strung between |
  | Gloamdeep Caverns | flowstone in ribs | one river, running | pit props |
  | Lantern Carnival | trodden ground under sawdust | **a crowd**, not water at all | painted poles and bunting |

  The carnival is the one worth saying twice: its water is a crowd of people, and a crowd walls
  a pen exactly as a mere does, because the board cannot tell the difference between a river and
  a queue for the waltzers.
- **Each world plays its own films.** An opening the first time you walk into it, and a
  send-off once every pen is held — the send-off pointing on past the world, the way the
  meadow's points past the hills to a gate standing open somewhere else.
- **The bosses are silhouettes until you reach them.** A world you have not opened yet shows
  its boss as a dark shape on its planet; reach it and the shape comes up in full colour. The
  whole journey is on the map from the first time you see it, so there is always somewhere to
  be going.
- **Play wears how much of it is done.** The button on the title screen carries a percent —
  the whole game in one number, counted across every level of every world that is built. A
  level is worth four marks: one for each star it can give up, and a fourth for the rainbow
  it keeps for the best pen the map has in it. So three stars on every level in the game
  reads 75%, and the last quarter is the rainbows. The number is rounded down and held at 99
  for anything short of the lot, so **100% only ever means every star and every rainbow
  there is** — and the badge goes rainbow itself when it gets there. It is held at 1% the
  other way round, so the first star of a long game shows rather than rounding away to
  nothing. Silhouettes are not counted, since a world with no levels in it would make the
  game unfinishable and would move the number every time another one was drawn; nor are the
  dailies, which come and go with the calendar.

Twelve worlds are drawn: **Mudlark Meadow**, **Thornwood Thicket**, **Emberpeak**, **Cogsworth
City**, **Starfall Reaches**, **Gloamdeep Caverns**, **Lantern Carnival** and **Sunbaked Dunes** to
play, then Tidepool Cove, Frostwhisker Tundra, Mirebog Fen and Cloudspire Heights waiting as
silhouettes.
Adding one is a matter of authoring its levels and its theme — its light, its treat skin and
the skin its board is painted in — since the map, the unlocking and the films are already there.

### Thornwood Thicket

The second world, and the first past the meadow. The pig has taken the tree line, so the
trail runs through deep woods in forest light, the windfall is a **truffle** rather than an
apple and the hazard a **bramble** rather than a skull — each worth exactly what its meadow
twin was, a truffle five tiles to shut in and a bramble five to shut in with and no fencing
at all. The one thing the thicket does that the meadow did not is **scatter** its treats. The
meadow held them all back for its last three fields; the thicket has walked its pig everywhere
at once, so a truffle turns up in the second field and a bramble in the seventh, with plain
fields in between. It reads as woods a pig has been rooting through rather than a lesson laid
out in order.

The other thing it does is **start higher**. The woods are walked by somebody who has already
held every pen in the meadow, so there is nothing here as generous as the two fields the
meadow opens on: not one field in the thicket gives its third star to a squared-off pen, and
the least any of them asks — 23%, at Hazel Copse — is more than the meadow asked anywhere
before Otter Ford, its fifth. Bramble Brook opens the world at 25%, where River Bend opened
the meadow at nothing.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Bramble Brook | 9 | — | 20 | 27 | 25% |
| 2 | Foxglove Dell | 7 | 2 truffles | 20 | 29 | 31% |
| 3 | Hazel Copse | 12 | 1 truffle | 23 | 30 | 23% |
| 4 | Fairy Ring | 13 | 1 truffle | 19 | 36 | 47% |
| 5 | Fern Gully | 12 | 2 truffles | 23 | 34 | 32% |
| 6 | Willow Corner | 8 | — | 16 | 26 | 38% |
| 7 | Nettle Bank | 13 | 2 truffles, 1 bramble | 18 | 26 | 30% |
| 8 | Elderwood | 15 | 3 truffles, 1 bramble | 30 | 41 | 26% |
| 9 | Boar Hollow | 20 | a boar, 3 truffles, 2 brambles | 36 | 43 | 16% |

Its boss, Boar Hollow, is the thicket's answer to Stag Mere: a hollow pool across the middle
of the wood with the pig north of it and a boar south, and one budget for both. It asks for
21 of the 24 stars below it before it opens, the same toll Stag Mere charges, and — like the
mere — it stops for a briefing on the way in rather than springing its second animal on you.
Every pen is drawn out in [`solutions.md`](solutions.md).

### Emberpeak

The third world, and the first that takes something away rather than adding to it. Past the
tree line the pig has climbed a mountain that has never stopped smoking, so the trail runs
over ash and cinder in hazed light, the windfall is a **chestnut** roasting where it fell and
the hazard an **ember** burning in the ground — each worth exactly what its meadow twin was, a
chestnut five tiles to shut in, an ember five to shut in with and no fencing at all.

The mountain's own idea is that there is **no clean ground on it**. The meadow saved its
treats for its last three fields and the thicket scattered them, but both of them handed out
fields with nothing lying about at all; every one of Emberpeak's nine has at least one ember
staked in it, so there is nowhere up here a wall runs straight without something in the way of
it. Sometimes the answer is to swallow the ember and pay the five, sometimes to step the wall
in beside it and give up a tile — which of the two is the whole of what most of these fields
are asking.

The other thing it does is **run dry**. Every field in both worlds below leans on water
somewhere; **Basalt Flats** is the first field in the game with none on it at all — seventeen
pieces, a bare shelf, two embers and nothing to build against but the shape of your own wall.
There are fewer than a hundred tiles of water in the whole world, where the thicket has 140
and the meadow 159.

And it **climbs the whole way**. Where the meadow climbs for six fields and then orders the
last three by what they scatter, the mountain has something on the ground everywhere, so it is
sorted by what it asks from Cinder Slope's 28% up to Crater Pools' 50% — the widest gap any field
left until the reaches — with the broadest board and then the boss after them, since neither is
measured by that yardstick.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Cinder Slope | 9 | 1 ember | 18 | 25 | 28% |
| 2 | Basalt Flats | 17 | 2 embers | 16 | 23 | 30% |
| 3 | Ashfall Terrace | 13 | 1 chestnut, 1 ember | 21 | 31 | 32% |
| 4 | Chestnut Scree | 12 | 2 chestnuts, 1 ember | 21 | 32 | 34% |
| 5 | Sulphur Rill | 13 | 2 embers | 15 | 24 | 37% |
| 6 | Fumarole Field | 14 | 2 chestnuts, 2 embers | 16 | 28 | 42% |
| 7 | Crater Pools | 12 | 1 chestnut, 1 ember | 17 | 34 | 50% |
| 8 | Smoulder Ridge | 16 | 3 chestnuts, 2 embers | 30 | 42 | 28% |
| 9 | Wyrm Caldera | 20 | a wyrm, 3 chestnuts, 2 embers | 27 | 43 | 37% |

Smoulder Ridge held the biggest pen on any world trail until Wide Reaches — 42, off sixteen
pieces, three chestnuts and a shore to follow. Its boss, Wyrm Caldera, is the crater lake itself:
the pig up on the north rim, the wyrm down on the crater floor, and one budget for the pair. It
charges the same 21 of the 24 stars below it that Stag Mere and Boar Hollow charge and stops for
the same briefing on the way in; what it adds is how unevenly it wants the budget split, since
the rim is narrow ground and the crater floor is the widest in the world. Every pen is drawn out
in [`solutions.md`](solutions.md).

### Cogsworth City

The fourth world, and the first one somebody built. Down off the ash the pig has got in under
the gate, so the trail runs over paving in gaslight, the windfall is a **pie** dropped outside
a shop and the hazard a **drain** sunk in the road — each worth exactly what its meadow twin
was, a pie five tiles to shut in, a drain five to shut in with and no fencing at all, since
nothing will drive a post through cast iron.

The city's own idea is that its **water was dug**. A meadow has meres, a thicket pools and a
mountain tarns, and every one of them lies in a body two or three tiles thick; every drop down
here is canal, cut one tile wide and turned at right angles. Nowhere in this world do two
tiles of water lie side by side and one above the other. It reads as a place rather than a
landscape, and it plays differently too: a body of water walls a pen *and* fills the ground
behind it, so a rectangle can be squared off against one, where a line hands over the wall and
nothing else.

The other thing it does is **take the room away**. Every board in the city is smaller than the
tightest shelf on Emberpeak, so the rim is always close and a block squared off against it
wastes more than a block ever wasted in open country. That is what holds the whole world at
30% and above, which is the highest floor any world has stood on, and it lets the city climb
the whole way from Gasworks Cut to Foundry Corner, with the broad board and the boss after
them as usual.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Gasworks Cut | 9 | — | 18 | 26 | 30% |
| 2 | Pieman's Row | 12 | 2 pies | 16 | 24 | 33% |
| 3 | Cobble Yard | 14 | 2 drains | 12 | 18 | 33% |
| 4 | Lock Gate | 13 | 1 drain | 14 | 22 | 36% |
| 5 | Culvert Row | 13 | — | 16 | 27 | 40% |
| 6 | Gutter Lane | 14 | 2 drains | 15 | 26 | 42% |
| 7 | Foundry Corner | 9 | 2 drains | 15 | 27 | 44% |
| 8 | Clocktower Square | 17 | 3 pies, 2 drains | 25 | 40 | 37% |
| 9 | Rat King Wharf | 19 | a rat king, 2 pies, 2 drains | 26 | 43 | 39% |

Two of its fields ask questions nothing has asked since the meadow: Culvert Row puts its two
banks at opposite ends of the street where The Narrows put them a stride apart, and Lock Gate
stakes a drain under the ford Otter Ford handed over for a single piece. Foundry Corner is the
third `corner` field in the game and the first to stake anything on the diagonal itself —
Puddle Corner and Willow Corner were both eight pieces on clean ground, and both asked 38%.

Its boss, Rat King Wharf, adds the city's own rule, and it is the thicket's rule turned round:
**the rat king will not be left on its own**. Both of them held, and in one pen — a yard of its
own is exactly what a rat king is after, so two enclosures, however well they hold, are refused.
Which makes the single pen a player learned not to build in Boar Hollow the only pen that counts
here, and the whole question is what shape it has to be: the pair stand four tiles apart on the
diagonal, so the smallest block that takes them both is a five by five with a drain in a corner
it cannot avoid. It charges the same 21 of the 24 stars below it that every boss charges and
stops for the same briefing on the way in. Every pen is drawn out in
[`solutions.md`](solutions.md).

### Starfall Reaches

The fifth world, and the first one the sky keeps landing on. Up out of the gaslight the pig has
walked out onto open dust under a violet sky, so the windfall is a **stardrop** still cooling
where it fell and the hazard a **meteor** sunk into the ground — each worth exactly what its
meadow twin was, a stardrop five tiles to shut in, a meteor five to shut in with and no fencing
at all, since nothing will drive a post through a stone that came in from that far out.

The reaches' own idea is that the **water is in single drops**. A meadow has meres, a thicket
pools, a mountain tarns, and the city cut its canals in straight runs a tile wide; every drop out
here is one tile alone — a well where a star went in — and no two wells in the world share an
edge. `StarfallTests` pins it, and it is the first world whose water cannot be walked along.

Which sounds like the end of free walls and is not, because of the one arrangement the law still
allows: **wells laid corner to corner**. A chain of them on the diagonal is a wall a pig cannot
cross, and it is a wall no rectangle can ever lean on. So the reaches hand over staircases where
every world below handed over banks, and squaring a board off against a staircase wastes more
than squaring off against anything in the game so far.

The other thing it does is **give the room back**. Every board here is bigger than the widest
board in any world below — eleven by eleven at the smallest, twelve by twelve for Wide Reaches,
which is the biggest board in the game and holds the biggest pen in it at 69. More room and less
of it a block can reach is what holds the whole world at 32% and above, and it climbs the whole
way from Dust Shore to Starwell Ring.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Dust Shore | 12 | — | 21 | 31 | 32% |
| 2 | Fallwater Basin | 13 | — | 24 | 36 | 33% |
| 3 | Broken Chain | 15 | — | 24 | 38 | 36% |
| 4 | Swept Flat | 18 | — | 20 | 32 | 37% |
| 5 | Stardrop Hollow | 13 | 2 stardrops | 23 | 39 | 41% |
| 6 | Meteor Field | 15 | 2 meteors | 17 | 32 | 46% |
| 7 | Starwell Ring | 12 | — | 14 | 32 | 56% |
| 8 | Wide Reaches | 20 | 1 stardrop | 45 | 69 | 34% |
| 9 | Visitor Crater | 20 | a visitor, 3 stardrops, 2 meteors | 27 | 49 | 44% |

Starwell Ring asks 56%, which is the widest gap any field in the game leaves — six wells, twelve
pieces, and nothing on the board to say where the wall goes but the shape the drops are pointing
at. Swept Flat is the second field in the game with no water on it at all, after Basalt Flats,
and eighteen pieces on eleven tiles of bare dust is the largest budget anything has ever been
given with nothing to lean on.

Its boss, Visitor Crater, adds the reaches' rule, and it is the first one to weigh two pens
against each other: **the visitor will not be housed worse than the pig**. Both of them held, in
two pens rather than one, and the same ground in each. Which forbids every other two-animal
board's answer at once — Stag Mere splits its budget wherever it scores best, Boar Hollow wants
two pens and does not mind what is in them, Wyrm Caldera throws its second animal out, Rat King
Wharf demands the single pen this one refuses — and it kills the cheap move all four of them
reward, which is to pour the budget into the animal standing in the better country and box the
other one in four pieces. A line of wells falls down the middle of the crater with two tiles
missing out of it, so plugging that neck is what turns one pen into two; then the halves come out
uneven, and the last thing to work out is which tiles of the wider one to hand back. It charges
the same 21 of the 24 stars below it that every boss charges and stops for the same briefing on
the way in. Every pen is drawn out in [`solutions.md`](solutions.md).

### Gloamdeep Caverns

The sixth world, and the first one under the ground. The pig went down a hole in the dust, so the
trail runs through wet limestone by crystal light, the windfall is a **crystal** growing out of the
flowstone and the hazard a **boulder** come off the roof — each worth exactly what its meadow twin
was, a crystal five tiles to shut in, a boulder five to shut in with and no fencing at all, since
nothing will drive a post through a block of limestone the size of a cow.

The caverns' own idea is that all the water is **one river**. A meadow has meres, a thicket pools, a
mountain tarns, a city canals and drains, and the reaches a scatter of wells no two of which touch;
every board down here has one body of water on it at most, and it comes in off the rim of the cave,
because it is the same river the whole way and a cave has no second river in it. `GloamdeepTests`
pins both halves, and one field has no water at all — The Blind Grike, the cave the river never
found.

Which is not less wall to lean on but more of it in one place, and the shape it leaves is what the
world is built on. A river that runs in off the rim and stops short of the far wall has done nine
tenths of a wall's work and left a **neck** — the strip of dry floor where the two halves of the
cave still run into one another — and a single piece laid in the neck buys the whole length of the
water. And because the only way to make a river long enough to matter on a board this size is to
step it, the banks down here are staircases rather than straight lines, so the pen that follows one
is a wedge or a lozenge and never a box.

The other thing it does is keep **the light**. Emberpeak staked an ember in all nine of its fields;
this is that idea turned the other way up — there is a crystal on every board in the world, because
a crystal is the only light in the Gloamdeep and a field with none would be a field nobody could
see. Emberpeak is the only other world that guarantees anything on every board, and what it
guarantees is a hazard; the caverns are the only world where every board has something worth going
out for.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Sinter Basin | 12 | 2 crystals | 21 | 32 | 34% |
| 2 | Dripstone Shelf | 11 | 2 crystals | 23 | 36 | 36% |
| 3 | Stillwater Neck | 11 | 3 crystals, 1 boulder | 19 | 31 | 38% |
| 4 | The Blind Grike | 19 | 2 crystals, 1 boulder | 25 | 41 | 39% |
| 5 | Glowworm Reach | 11 | 3 crystals | 15 | 26 | 42% |
| 6 | Rimstone Corner | 9 | 2 crystals | 25 | 46 | 45% |
| 7 | Boulder Chamber | 15 | 2 crystals, 3 boulders | 23 | 44 | 47% |
| 8 | Great Gallery | 19 | 3 crystals, 1 boulder | 42 | 63 | 33% |
| 9 | The Roost | 20 | a bat, a pup, 3 crystals, 1 boulder | 23 | 45 | 48% |

Rimstone Corner is the corner question with nothing else in the way of it, and the hardest corner
in the game: the river takes the whole roof of the cave and the whole east wall, and nine pieces
laid corner to corner across the bend hold 46 where the same nine laid as a right angle hold 25.
Foundry Corner asked it with the same nine and one free side rather than two, and could only reach
round 27. The Great Gallery holds the third biggest pen in the game, at 58 tiles — second until the
dunes' Great Erg came in a tile above it.

Its boss, The Roost, adds the caverns' rule, and it is the first board anywhere to stand three
animals on the ground: **the roost hangs together and the pig hangs apart**. A bat, its pup and the
pig, one budget, and two things asked at once that pull opposite ways — the two bats in the same
pen, the pig in another. Which forbids every other multi-animal board's answer at once, and two of
them with the same wall: Stag Mere splits its budget wherever it scores best, Boar Hollow wants two
pens and does not mind what is in them, Wyrm Caldera throws its second animal out, Rat King Wharf
demands the single pen this one refuses, Visitor Crater wants two pens holding the same ground.
Here the pens are two and *which animal is in which* is the whole of it — so the cheap answer every
one of those five leaves open, three little boxes so that nothing can possibly be sharing, is
turned down flat, because a pup boxed on its own is a roost split. The river climbs across the cave
and the bat and its pup hang either side of the tip of it, so joining them means reaching round
that tip — and reaching round the tip is what hands the pig the whole staircase as the wall of its
own pen. It charges the same 21 of the 24 stars below it that every boss charges and stops for the
same briefing on the way in. Every pen is drawn out in [`solutions.md`](solutions.md).

### Lantern Carnival

The seventh world, and the way back up out of the dark. The pig came out of a cave into a field
full of lights, so the trail runs over trodden sawdust under paper lanterns, the windfall is a
**toffee apple** dropped off its stick and the hazard a **guy rope** pegged down to hold a tent
up — each worth exactly what its meadow twin was, a toffee apple five tiles to shut in, a guy rope
five to shut in with and no fencing at all, since a peg is already somebody else's post and there
is no room beside it for one of yours.

What the water is up here is **the crowd**, and the carnival's own idea is that the crowd stands
in **blocks**. A meadow has meres, a thicket pools, a mountain tarns, a city canals, the reaches a
scatter of single drops and the caverns one long river; on every field here each body of crowd is a
filled rectangle of two tiles or more — a stall, a queue, the wall of a tent — with never a bend in
it and never a drop standing on its own. `CarnivalTests` pins that, and pins the boss as the one
deliberate exception: its crowd is a three by three with the ringmaster in the middle of it, so what
closes round him is a ring of eight rather than a block of nine.

Which changes what a wall is *for*. A river hands a pen one long edge to follow; a block hands it a
short one and then stops, and the ground between two blocks is a **gangway** a single piece closes.
So a pen out here is assembled rather than followed — pick which blocks to string together, pay a
piece for each gap between them, and the shape that comes out is whatever those blocks happened to
leave, which is why the carnival's answers are lopsided where the caverns' were wedges.

The other thing it does is keep **the guying**. Emberpeak staked an ember in all nine of its
fields and the caverns hung a crystal in all nine of theirs; there is rope on every board here,
and the *run* is the point — never one peg on its own, always two or more in a straight line. A
single hazard is one tile to build around, which every world since the meadow has had. A run of
them is a length of ground no wall may cross, because a rope takes no fence and a pen may not lean
on one either, so a run of two is a strip of dead ground three tiles wide. The crowd is a wall the
board gives you and a guy rope is a wall the board forbids you, and reading the difference is the
world.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Coconut Shy | 14 | 2 toffee apples, a run of rope | 18 | 29 | 37% |
| 2 | Sideshow Row | 14 | 2 toffee apples, a run of rope | 24 | 39 | 38% |
| 3 | The Turnstile | 14 | 3 toffee apples, a run of rope | 21 | 35 | 40% |
| 4 | Ticket Line | 15 | 2 toffee apples, a run of rope | 20 | 34 | 41% |
| 5 | The Toffee Stand | 17 | 3 toffee apples, a run of rope | 22 | 38 | 42% |
| 6 | The Big Top | 11 | 2 toffee apples, a run of rope | 25 | 51 | 50% |
| 7 | The Rigging | 18 | 3 toffee apples, 3 runs of rope | 21 | 42 | 50% |
| 8 | The Midway | 19 | 3 toffee apples, a run of rope | 30 | 49 | 38% |
| 9 | The Centre Ring | 22 | the ringmaster, a toffee apple, 4 runs of rope | 17 | 40 | 57% |

The Big Top is the corner question with the crowd along the front of the tent and down its far
side, so two of the four walls are handed over: eleven pieces laid corner to corner hold 51 tiles,
the biggest pen in the world for the smallest budget in it, where the same eleven laid as a right
angle hold 25 — because the pair of guy ropes is pegged inside every rectangle worth drawing, and
the tidy pen has to swallow them and pay their ten. The Rigging carries seven pegs in three runs —
more rope than any other field at the fair, and the only line of three in the game — and at 50% it
leaves the widest gap of any ordinary field at the fair.

Its boss, The Centre Ring, adds the carnival's rule, and it is the first rule in the game about
**where one pen stands in relation to another** rather than about which animal is in which:
the ringmaster keeps the middle, and the pig has to close all the way round him. So the answer
five worlds have taught is refused — four pieces round the pig where she stands hold her perfectly
well, and a pen beside his is a pen and not a ring — and so is the wall that comes three quarters
of the way round and closes on itself, because he walks out of the side that was left open. He is
standing in the middle of a three by three of crowd, which is the one thing that makes squaring
the board off possible at all: a rectangle laid over that crowd comes out as a ring with him in the
hole of it, worth 17, where the same twenty-two pieces run out to the corners as an octagon hold 35
tiles and the apple hanging over the ring, which is 40. It charges the same 21 of the 24 stars below
it that every boss charges, and stops for the same briefing on the way in. Every pen is drawn out in
[`solutions.md`](solutions.md).

### Sunbaked Dunes

The eighth world, and the driest. The lights of the fair are behind and there is sand to the
horizon, so the trail runs over rippled sand under a white sky, the windfall is a **melon** lying
where it fell and the hazard a **cactus** rooted in the sand — each worth exactly what its meadow
twin was, a melon five tiles to shut in, a cactus five to shut in with and no fencing at all, since
there is no room beside a cactus for a post of yours.

What the water is out here is **a dune**: sand too steep to climb and too loose to hold a post, so
it stops a pig and a fence exactly as a river does. And the world's own idea is the shape of it —
**every dune is a crescent.** A barchan: a straight back with a horn trailing off each end, one tile
thick, so the sand comes back on itself. A meadow has meres, a thicket pools, a mountain tarns, a
city canals in straight runs, the reaches a scatter of single drops, the caverns one stepped river
and the carnival filled blocks with never a bend in them; here there is nothing but bends.
`DunesTests` pins it, and pins the other half of it too — every crescent on a board opens the same
way, because barchans are made by a wind and a wind blows one way across a field.

Which is new in what it **offers** rather than in what it forbids. Every world below hands a pen one
wall to follow, or two meeting at a corner, and the player draws the rest. A crescent hands over a
finished pen: the shade inside it is dry ground, walled on three sides, and the only thing to pay
for is the mouth — which is shorter than the back it hangs off. It is the cheapest pen in the game.

And that is the trap, which is the whole world. The belly of a dune is rectangle-shaped, so it is
exactly what squaring a board off finds; it is also a fixed size, because the sand is where it is
and no amount of budget makes the shade any wider. So the question every field here asks is *is the
free pen worth having*, and the answer is almost always no. Slipface Hollow says it on the first
board by standing a cactus in each end of the shade: take the gift the sand is holding out and you
have been given six tiles and ten points of debt.

One field has no dune on it anywhere, the way The Blind Grike has no river: The Hardpan, the ground
the sand never reached, where every tile of the pen is bought and the biggest budget in the world is
laid out across bare hardpan to buy it.

| # | Level | Pieces | On the ground | Squared off | Best pen | Asks |
|---|---|---|---|---|---|---|
| 1 | Slipface Hollow | 14 | one barchan, 2 melons, 2 cacti | 20 | 33 | 39% |
| 2 | The Long Slack | 14 | three barchans, 2 melons, a run of cactus | 19 | 33 | 42% |
| 3 | The Blowout | 13 | two barchans back to back, 2 melons | 18 | 32 | 43% |
| 4 | The Hardpan | 21 | no sand at all, 2 melons | 25 | 45 | 44% |
| 5 | Two Horns | 18 | two barchans, 2 melons, a run of cactus | 29 | 50 | 42% |
| 6 | Melon Ground | 17 | one barchan, 3 melons, a run of cactus | 19 | 35 | 45% |
| 7 | Scarp Corner | 11 | one great barchan, 2 melons | 20 | 41 | 51% |
| 8 | The Great Erg | 19 | two barchans, 3 melons, a run of three cacti | 33 | 56 | 41% |
| 9 | Scorpion Flats | 16 | the scorpion, two barchans, 2 melons | 19 | 50 | 62% |

Scarp Corner is the corner question with one great barchan hooked into the north-west, so its back
is the north wall and its western horn stands on the rim: two sides handed over, and the smallest
budget in the world to draw the rest. The right-angled answer hangs a rectangle under the back and
pays for its own east wall for 20, where the same eleven pieces run out as a chevron — from the
western rim, across the whole mouth of the crescent, back up to a point in the south — hold 41
tiles, which is nearly four tiles a piece and the best rate anywhere in the world. At 51% it is the
hardest corner in the game. Melon Ground, at 48%, is the hardest detour in it. And The Great Erg
holds 59 tiles on the broadest board out here, which is the second biggest pen in the game: five
behind Wide Reaches, one ahead of the Great Gallery.

Its boss, Scorpion Flats, adds the dunes' rule, and it is the direct inversion of the game's oldest
boss lesson. Stag Mere taught that two pens can share a wall — one boundary doing two jobs — and the
search has priced a shared wall at half ever since; every boss from Boar Hollow to The Centre Ring
is built on that discount. **A scorpion stings straight through a fence**, so here there is no
discount: the pig may not be standing in with him, and no piece of fence may have her ground on one
side of it and his on the other. The ground between the two pens has to be given up unclaimed, and
one budget has to pay for two whole walls.

He is standing in the shade of a barchan three tiles wide, which is what makes the board answerable
and what makes it hard at the same time. Three of his walls are free and one piece shuts him in —
and that piece is one she may not lean on, so the sand round it is ground she may not have either.
Her wall has to come past the notch and close behind it, giving it a berth, which is a thing no
rectangle can do. Sixteen pieces is the smallest budget any boss in the game hands out, and the
cheapest legal pair it buys is the tidy pair of pens side by side: four pieces box the pig where she
stands on one tile, and the rest wall the open sand east of the notch as the scorpion's own yard,
which is 19. The same sixteen run out from the pig up the west of the flats, along under the great
back in the north and down round the far side of the notch hold 45 tiles and the melon in the
north-east, which is 50 — the biggest pen any boss holds, and at 62% the widest gap any board in the
game leaves. The melon in the lane between the two pens is the board saying what the rule costs: the
pen that wins this field is the only pen in the game that walks past five points it can see and
leaves them lying there. It charges the same 21 of the 24 stars below it that every boss charges, and
stops for the same briefing on the way in. Every pen is drawn out in [`solutions.md`](solutions.md).

## The Daily Puzzle

A puzzle a day, on its own board, with a clock running on it.

- **A week is a climb.** Monday's map is mostly water — free walls everywhere, and the best
  pen is the pen anybody would build — and by Sunday there is barely anything to lean on:
  five tiles of water on a board of a hundred and never more than three of them lying
  together, apples worth going out of the way for and a couple of skulls standing where a
  wall would want to go. What makes that a climb rather than a claim is that it is *measured*: every
  daily map is searched for the best pen its budget holds and squared off as well, and the
  gap between the two — what the level asks, the same number the meadow is ordered by — has
  to fall in the band its weekday was given. The bands are laid end to end, so a Tuesday
  always asks more than a Monday.
- **Not every board is laid out the same way.** Running across the climb is a second thing,
  which is what the water on a board actually looks like. Most days drop it in bodies until
  the board is wet enough, but about a quarter of them arrange it instead: freckled over
  every other square so there is plenty of room and no clean run of it, stepped across a
  corner as a shore that hands you half a staircase, or split into two banks that pinch the
  board down to a neck and leave you to decide which side the pen belongs on. It changes
  nothing about what the day asks — the band is measured on whatever board came out — and
  everything about what you are looking at when you open it.
- **The clock counts up.** It starts when the board opens and stops the moment the pen
  holds, so the lap of honour is not charged to you. *Go bigger* picks the clock back up
  where it stood; *Start over* puts it back to nothing; *Put it back* puts the submitted
  time back with the fencing. The time a day is remembered by is still the quickest shut
  that held. The meadow has no clock on it at all: a level up the trail is worth taking
  apart, and a clock over that would only ask you to hurry.
- **The archive is a calendar.** Every day of the year is a little field with the day's
  number under it: bare mud for a day nobody has finished, washed gold for a day complete,
  drifting through the spectrum for one that gave up the best pen it had in it — which is
  what the real board does when such a pen closes — and grey ground under a padlock for a
  day still to come. The stars a day gave up sit under its square. It opens on the month
  you are in and turns back as far as the first of January.
- **Nothing here unlocks anything.** The meadow is a trail, where one stop opens the next.
  The archive is a calendar: a week missed is a week of squares nobody has washed gold
  rather than a wall, and the only thing shut is tomorrow — until it is today.
- **The whole year ships with the game.** The puzzles are not fetched: tomorrow's board is
  already on the phone the day the game is installed, and what keeps it out of reach is a
  rule rather than a gap. A player who puts the clock forward can walk into next week, and
  is welcome to.
- **Best is kept, like everywhere else.** Stars, the quickest run and the rainbow are each
  kept at their best, so a worse or slower second attempt at an old day costs nothing.
  The wall of fencing that was standing when the best pen was submitted is kept too: tapping
  a day already held offers *Put it back* — the same words the trophy uses mid-session —
  which lays that wall down again, or *Play again* for an empty field with the wall still
  waiting behind the trophy.
- **Hitting back keeps the fencing.** Leave a day without releasing the animals and the
  board is still there when you open it again — pieces, the best pen of the go, and the
  clock where you left it. The clock keeps the time the board has cost rather than the
  hour you started it, so a day left in the morning and picked up at night comes back on
  two minutes rather than on fourteen hours. Clearing the game's data forgets those drafts
  with everything else.

The almanac is generated rather than authored — `Tools/generate_dailies.py` writes it, and
`DailyAlmanacTests` replays the best pen of every single day so that no day can promise a
pen its map does not hold. See [The daily almanac](#the-daily-almanac).

The name on the title screen plants itself a letter at a time, each one dropping in and
settling like a fence post going into the ground, over a pasture — drifting clouds by day,
fireflies at dusk — with a pig trotting up and down a run of fence. The whole backdrop is
drawn in code from one clock and stops dead when the system asks for reduced motion. The
stars taken so far sit in a badge in the top corner, well away from Play.

Under Play is a board with **today's puzzle** on it — what day it is, and once it is
complete, the stars it gave up, the time it took and how many days in a row you are on. Under that, **Archive** opens the calendar of every daily there has been
this year, and **Tutorial** opens a practice pen off the world map and walks through
tapping a post, dragging a run, building against water, shutting the pen until the ground
washes gold, and releasing the pig. A gear in the corner opens settings, which holds the
version number and one red button: clearing all game data throws away every star and every
day completed, and shuts the trail back to its first level, so it asks before it does
anything.

A puzzle is a patch of the same meadow rather than a grid on a slab of colour: mown grass,
wildflowers and a stone or two behind a plot of mud with the water lying in it as one lake,
banked with silt, instead of a run of blue squares. The rack of fence pieces is over the
board with the count of what is left the size of a scoreboard — barn red once the last piece
is in the ground, and shaken by any press the field will not take — and everything else on
the screen is a painted board: the buttons that work the fencing, the tally of your best pen,
and the verdict when the gate is opened. All of it takes the meadow from daylight to dusk with
the system appearance, and none of it is on a clock: the board is the only thing that moves.

### The story

Fourteen lines of type, and they have to add up to something. Mudlark Meadow is nine fields
of open country with a barn at the bottom of it and not a fence anywhere in it, and one
morning somebody leaves the gate open. You do not catch the pig — nobody catches a pig in
the open, which is the whole reason the game is a fence rather than a chase. You fence the
field it has got into, and the next one, and the one after that, up the trail towards the
hills.

The pig is on the loose and was never meant to be. It wants to be free, and open country is
no place for a pig — the danger is not the meadow, it is that nothing out there holds it.
So the job is not the smallest pen that will hold an animal: it is the biggest one you can
get the fencing round. **Room to run** is why. A pig that cannot be let go should at least
have somewhere to stretch its legs, and the score is only how the game keeps count of that
— a point a tile is the tally of a pig's morning, not a reason of its own. It has to be
shut as well, because one gap is one way out and the pig will find it. Big as you can, and
closed — that is the whole of the rule, and the opening says it out loud, reason included,
before a piece is laid.

At the top of the meadow the ground stops belonging to the farm. Stag Mere is the ninth
field and the stag had that shore before the barn did, so the last fence has to hold both
animals — making room for the one that lives there rather than walling it out is what
"both of them held, or neither counts" means, and it is why one budget goes out as two
enclosures.

Then the meadow is fenced from the barn to the mere: the stag stays on its own water, the
pig has the run of all nine fields, and nothing gets out of Mudlark Meadow any more. That
is the rule paid off rather than a view — nine fields, shut, is the biggest pen in the
game, and the pig is loose inside it, which is what it wanted and as much freedom as is
safe to give a pig. The last shot is the second shot of the opening said again from further
away — somewhere else, another gate is standing open — which is the next world, and a
reason to go to it.

### The cut scenes

Nine films so far — the meadow's three, painted shot by shot, and three apiece for the thicket
and the mountain in storybook stills — each played once and each with a **Skip** in the corner
from a beat in.
Skipping counts as having seen one. Every world plays the same three: an opening before its
first field, a briefing before its boss, and a send-off once every pen in it is held.

#### The opening

The very first press of Play — on a world with no stars on it — plays a short film before
the meadow. Six shots and a little over sixteen seconds, between black bars, with a line
of type over each: the meadow at first light with nothing fenced in it, the barn with the
one gate nobody shut, the pig itself head on with the light coming apart behind it and the
line that says what it wants, the pig outrunning the camera under the line that rules out
chasing it and says open country is not safe for it either, the pen a player is being asked
for pushing out from a tight one round the pig to as much meadow as it will take, and the
run of fencing that shuts it. There is a **Skip** in the corner from a beat in, and
skipping counts as having seen it.

The last two shots are the briefing. Outside the practice pen nothing else tells a player
that a pen is worth what it holds and worth nothing at all with a gap in it, so the film
draws it rather than writing it down: the tight pen round the pig fading out as a far
bigger one opens past it is the scoring rule with no numbers in it, and *Fence it in. One
gap, and it is gone.* is the other half of the rule, on the card the film hands the game
over on.

*Room to run* is the two words that keep the first of those from being a scoring rule and
nothing else. A player told only to make the pen big is being handed a number to optimise;
a player told the pen is big so the pig has somewhere to run is being handed the reason the
game exists, and it is the same reason the send-off ends on nine fields with the pig loose
in all of them. It costs the film a third of a second, paid for out of the two lines that
had the most air in them.

It plays once. `WorldProgress` keeps the names of the films already played beside the stars,
so a player who watches one, backs out without penning anything and comes back does not get
it twice — and for the opening the stars are checked as well, so nobody already up the trail
is introduced to the pig they have been chasing for an hour. Clearing all game data hands
every film back with everything else.

#### Stag Mere

Tapping the meadow's last signpost stops for nine seconds first. A player who has fenced
eight fields does not need teaching how to fence a ninth — they need telling the one thing
this map does differently, which is that there are two animals on it and one budget for the
pair. Three shots: the water down the middle, the stag head on under the line that says the
far shore was its before the barn was there, and then both of them with the pen each would
take marked out round it in dashes, so the shape of the answer — two enclosures, not one —
is on screen before a piece is laid. The middle shot is the half of the briefing that makes
the rule worth keeping rather than merely worth reading: the last field of the meadow is
not empty ground. It is lit flat and bright where the films either side of it are lit at
sunrise, because a briefing wants reading rather than admiring.

#### The meadow held

When the last pen in the meadow holds, the world gets seen out. Both animals shut in on
ground washed gold, a shore apiece; the stag left standing on the water it had before the
barn did while the trail runs away out of the picture; the nine fields fenced at last, with
the pig loose in all of them and a stop marked at every puzzle on the trail — and then the
meadow from far enough out to be a world nothing gets out of any more, with the stag stood
on top of it for a mark. A world somebody has finished is a world with something of its own
still living on it, which is why the stag is left there rather than brought along. Out past
it another world comes up out of the dark with a road drawn on towards it, still under cloud
and without a name, because what is on it is nobody's business yet — except that somewhere
on it a gate is standing open, which is where the opening started.

#### Boar Hollow

The thicket's boss gets the same nine seconds, in the storybook hand rather than painted:
the pool that runs across the wood, the boar that had the hollow before you did, and
the rule on a card — *twenty pieces, both of them held, or neither counts*. It is the mere's
briefing done in the woods, because it is the mere's board done in the woods, and a world
should no more spring a second animal on a player than the meadow did. Lit for daylight
where the thicket's send-off is lit after dark, for the reason the mere's is lit flat.

#### Wyrm Caldera

The mountain's boss gets the same nine seconds again, and says the same three things: the
lake in the summit, the wyrm that had the crater long before you did, and the rule on a card
— *twenty pieces, both of them held, or neither counts*. Three worlds in, this is the shape a
boss is announced in, and a player who has seen the mere and the hollow knows what the stop
means before the first still is up.

A briefing plays before a level that changes the rules, and no world so far has more than
one — a boss is the only board that stands a second animal on the ground. Which level stops
for which film is the world's own business: [`GameWorld`](Pigpen/Models/GameWorld.swift)
carries its briefings by level id, so the thicket briefs Boar Hollow and the mountain briefs
Wyrm Caldera in their own storybook stills without the meadow or the map screen knowing which
kind of film came up. A boss you have already held is never briefed — the same reason the opening checks the stars as well
as its own flag, and what keeps a film written after a world has shipped from stopping the
player who finished it first.

#### How they are built

Like the pasture behind the title and the lap of honour on a pen that holds, a film is a
clock rather than a queue of steps: [`CutScene`](Pigpen/Models/CutScene.swift) says which
shot is up at a given second and how far through it, and `CutSceneView` paints that. All
three are the same machine — a list of shots, each held for a moment and captioned — so a
fourth is a list and a few pictures rather than another screen.

A themed world's films are the same clock with a lighter hand:
[`StorybookScene`](Pigpen/Models/StorybookScene.swift) is a themed backdrop, a motif held
over it and a line of type, timed to the frame the way a painted film is, so a new world
can open, brief its boss and close on a film long before it has art of its own. `WorldFilm`
wraps either kind and `WorldFilmView` plays it, which is why the map screen can stop for a
briefing without knowing whether what comes up was painted or strewn.

So any moment of any of them can be stopped and photographed, which is how CI shows all
fourteen shots, and a player who asks for reduced motion gets every shot and every caption
with the camera held still. They are the only screens in the game lit by something other
than the phone: the opening and the send-off are at sunrise, so the world opens and closes
on one light whatever the system appearance says.

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Swift 6.2 |
| UI | SwiftUI |
| Min iOS | 17.0 |
| Project | XcodeGen (no `.xcodeproj` in repo) |
| CI/CD | GitHub Actions |
| Distribution | TestFlight + App Store |

## Development

### Prerequisites

- Xcode 26+ (for local dev) or just use GitHub Actions — no laptop needed, including for [signing setup](#signing-setup-from-the-actions-tab)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

### Build locally

```bash
xcodegen generate
open Pigpen.xcodeproj
```

`Pigpen.xcodeproj` and `Pigpen/Resources/Info.plist` are both generated from `project.yml` and are gitignored — edit `project.yml`, never the generated project.

### App icon

The icon is a pig face drawn in code, so it can be tweaked without a design tool. `Tools/generate_app_icon.py` writes the three PNGs the asset catalog expects — the standard icon, the dark variant, and the grayscale tinted variant:

```bash
pip install cairosvg pillow
python3 Tools/generate_app_icon.py
```

Colors live in the `LIGHT`, `DARK` and `TINTED` palettes at the top of the script; the shapes are one SVG shared by all three. Commit the regenerated PNGs — the build reads them, not the script.

### Adding a level

A level is an ASCII map — `.` mud, `~` water, `a` an apple, `x` a skull, `P` the pig, `D` a deer, `B` a boar, `W` a wyrm, `R` a rat king, `V` a visitor, `T` a bat and `U` its pup — and four numbers: the fence budget, the scores the second and third stars are worth, and `maximumScore` — the best pen the map and that budget allow. The first three are a judgement call. The last one is not, and getting it wrong either withholds the "best pen there is" verdict forever or hands it out for a pen that could still be bettered. `Tools/level_search.py` works it out:

```bash
Tools/level_search.py --budget 12 --plan <<'MAP'
.........
~~~~~~~..
...a..~..
..P...~..
.........
MAP
```

It prints the best pen it found, marked out on the map, along with `maximumScore` and star thresholds in the proportions the shipped levels use. It knows what the game knows: nothing lying on the ground takes fencing, apple or skull, so a pen whose wall would have to stand on one is never offered as an answer. Add the level to `PuzzleLevel` — beside the meadow's in `PuzzleLevel.swift`, or in its own world's file, the way `Woodland.swift` and `Emberpeak.swift` do — hang it on that world's trail, and add its plan — the `#` tiles `--plan` prints on their own — to `shipped` in that world's tests, which replays the pen and fails if the level stops giving up what it claims.

The star thresholds are the judgement call, but not a free one: `DifficultyTests` holds every level to a second star for the pen a player gets by squaring the map off, so `--demand` is worth running on any map with anything lying on it — a treat in the way moves a plain block and a shaped pen by different amounts, and the second star has to stay under what the block is worth.

Then work out where on the trail it belongs. `--demand` squares the map off as well — the best plain block of ground per animal — and prints that pen, `squaredOff`, and the gap between it and the best pen as a percentage. That gap is what the level asks of a player, and the fencing-and-water stretch is ordered by it. Add the level and its squared-off plan to `baselines` in `DifficultyTests`, which replays that pen too and fails if the trail stops climbing.

A whole new world has one more number to author: its **floor**, the least any of its fields may ask, declared in `floors` in `DifficultyTests` beside the world it belongs to — nothing for the meadow, 23% for the thicket, 28% for Emberpeak, 30% for Cogsworth City, 32% for Starfall Reaches, 34% for Gloamdeep Caverns, 37% for Lantern Carnival, 38% for Sunbaked
Dunes. A world may not floor at or under the floor of the world below it, and its opening field may not ask less than the one below it opened with, so a second world cannot quietly restart the first world's tutorial. Bosses sit outside the floor and are compared to each other instead.

A map with a second or third animal on it as well as a `P` is held by ground in two pieces as happily as by one, and the search knows it: it grows out from both animals at once and prices a wall shared between two enclosures once, like any other. It is a bigger search than a one-animal map, so give it a minute — and check the answer holds with a wider `--beam` before authoring it. A stop on the trail can also be given a `starToll`, which shuts it until the world has that many stars however far the trail has got.

The search carries its pens as bitmasks — one bit per tile of the board — rather than as sets of coordinates, which is the same search written so that it finishes in a second rather than half a minute. Nothing about which pens it keeps changed when it was rewritten, and the nine shipped levels come out at exactly the numbers they always did, which is what `PuzzleLevelTests` and `DifficultyTests` are there to say. That speed is what makes a year of daily puzzles possible at all.

### Building a world

A world is not nine maps. It is **nine questions in an order**.

Every field on a trail declares the question it asks — its *type* — and a world is built by
choosing nine of them, ordering them by how much they ask, and making sure each one asks more
than the last time the universe asked it.

#### The questions

| Type | What the field asks | What it hands you free |
|---|---|---|
| `shore` | Which stretch of bank is worth walling? | One long straight wall |
| `basin` | The water has nearly done it — where is the mouth? | Three sides of a pen |
| `span` | Two banks that are each useless alone | Two facing walls, if you can reach both |
| `gap` | Where exactly does one piece go? | A whole bank, for a single piece |
| `corner` | How much does a diagonal buy over a right angle? | Two sides meeting at a corner |
| `constellation` | The free walls are scattered — what shape do they imply? | A wall tile here and there |
| `detour` | Is the windfall worth the ground you give up reaching it? | Nothing |
| `obstruction` | Swallow the hazard and pay, or step the wall in beside it? | Nothing |
| `bare` | Nothing is free. What shape holds the most per piece? | Nothing at all |
| `herd` | One budget, two animals, held together or apart — whichever scores | The water between them |
| `apart` | One budget, two animals that will not share ground | The water between them |
| `exclude` | Hold the pig and leave the other animal outside | Nothing — its tile is a hole |
| `together` | One budget, two animals that will not be parted | Nothing — one pen has to reach both |
| `even` | Two pens, and the same ground in each | The water between them |
| `roost` | Three animals: two that will not be split, and a third they will not share with | The water between them |
| `ring` | Two pens, one inside the other: the pig's ground has to close round him | The water between them |
| `berth` | Two pens with clear ground between them: no piece of wall may serve both | The water between them |

`herd`, `apart`, `exclude`, `together`, `even`, `roost`, `ring` and `berth` are the **boss rules**,
and a field never asks one.

#### The shape of a world

- **Fields 1–7 climb.** Each asks at least as much as the one before it.
- **Field 8 is the broad board** — the widest map in the world and the biggest pen in it. It
  stands outside the climb, because the gap a big board leaves against a squared-off pen says
  more about its size than about its difficulty.
- **Field 9 is the boss**: the field where the world adds a rule its other eight do not use,
  plus a star toll. **No two worlds may add the same rule** — otherwise every world climbs to
  the same finale with a different animal painted on it, which is what the first three did.
- The boss stops for a briefing film. Nothing else does.

A world may repeat a type, and it need not use them all. What it may not do is ship a field
with no type at all.

#### The two ladders

1. **Down a world** — fields are ordered by what they ask: `(maximumScore − squaredOff) / maximumScore`.
2. **Across the universe, one type at a time** — a type's *hardest* field in a world asks at
   least what that type's hardest field asked in the last world that had it.

The second ladder is what stops a fourth world being the meadow in a new coat. It binds from the
second world onward: Mudlark Meadow is the baseline every type is measured from, and it is
allowed to have overshot, because it was authored before any of this existed. Sour Ground used
to overshoot the worst — 48%, more than anything in the two worlds above it — for a reason that
was about blocks rather than about difficulty: every squared-off pen worth having on that map was
one the player could not build, so the measure had nothing to compare against. Now that a block
is nudged out over what it cannot stand on, it asks 24% and sits where it belongs.

#### Making a type harder next time

| Type | Turn it up by |
|---|---|
| `shore` | Shortening the bank, or bending it so a rectangle cannot follow it |
| `basin` | Widening the mouth, so plugging it is no longer most of the answer |
| `span` | Moving the two banks further apart than one wall can reach |
| `gap` | Staking a hazard beside the gap, so the cheap plug costs shape |
| `corner` | A longer budget — a diagonal pays more the further it runs |
| `constellation` | Widening the spacing of the dots: every 2nd tile ≈ 27%, every 3rd ≈ 50% |
| `detour` | Moving the windfall further off the tidy line, or making two of them compete |
| `obstruction` | Moving the hazard from the edge of the ground into the middle of it |
| `bare` | A longer budget — a bigger ring beats a bigger rectangle by more |
| `herd` | Splitting the value unevenly, so the budget split stops being symmetric |
| `apart` | Bringing the two close enough that one pen round the pair nearly wins |
| `exclude` | Standing the one to be left out in the middle of the ground worth having |
| `together` | Standing the two further apart, so the block that holds both costs more |
| `even` | Making the two halves the free wall leaves more lopsided, so more has to be handed back |
| `roost` | Running the free wall *between* the two that must share, so joining them is the expensive part |
| `ring` | Standing him further off centre, so the ring has to be lopsided to close |
| `berth` | Standing the two so close that the cheap wall between them is the one that serves both |

#### Authoring one

`Tools/level_search.py --budget N --plan --demand` prints the best pen, the squared-off block and
the gap between them. A `constellation` is the one type easier to author backwards: choose the pen
you want the player to find, take its wall with `fences_around`, lay water on every second or
third tile of it, and **give the level exactly the rest of that wall as its budget**. The dots
then imply the answer without drawing it, and no rectangle can use them, which is where the gap
comes from.

That budget rule is the whole of it, and getting it wrong is quiet. Hand out fewer pieces than
the wall needs and the best pen is some smaller shape that only touches a few of the dots — the
rest are then decoration, the level still measures hard because the dots are useless to
*everyone*, and what shipped is a scatter rather than a constellation. So every constellation
field is replayed with `Constellation.idleWater`, which fails the build if the pen it is
authored around leaves a single tile of water unused.

Every field is pinned twice — its best pen in its world's tests, its squared-off block in
`DifficultyTests` — and both are replayed through the game's own rules, so a level that stops
giving up what it claims fails the build.

### The daily almanac

The daily puzzles are not authored one at a time — there are seven hundred of them. `Tools/generate_dailies.py` shapes a map from the date and nothing else, weighs it the way `--demand` weighs a level, and keeps it only if what it asks falls in the band its weekday was given:

```bash
Tools/generate_dailies.py --years 2026 2027 --jobs 4
```

| Day | Board | Water | Most of it in one piece | On the ground | Asks |
|---|---|---|---|---|---|
| Monday | 9×8 | 38% | 28 tiles | — | 0–5% |
| Tuesday | 9×9 | 28% | 20 tiles | — | 6–14% |
| Wednesday | 9×9 | 22% | 15 tiles | 2 apples | 15–23% |
| Thursday | 9×9 | 15% | 11 tiles | 2 apples | 24–32% |
| Friday | 10×9 | 12% | 8 tiles | 3 apples, a skull | 33–41% |
| Saturday | 10×10 | 8% | 5 tiles | 3 apples, a skull | 42–52% |
| Sunday | 10×10 | 5% | 3 tiles | 4 apples, 2 skulls | 53–66% |

Water is the knob that does nearly all of the work, and it has two halves. Water is a wall you are given, so a map with a lot of it has an obvious best pen and one with little of it has to be worked out — but only water lying in one long stretch walls anything. A river from one side of the board to the other is a ten-piece wall handed over for nothing, and what is left to work out is a single staircase against it. The same ten tiles in three puddles wall nothing at all: they only eat ground the pen wanted. So a day is given a share of the board to put under water *and* a limit on how much of it may lie in one piece, and both dry up across the week.

Both halves are budgets rather than floors, which is the part that used to go wrong quietly. The generator laid water down until the board was wet enough and then stopped, so a day whose whole share came to less than one river got a river anyway and overshot: Saturday and Sunday, asked for 8% and 5% of the board, both landed at 13% of it under a single run of water crossing the map. Sunday was Saturday with more apples on it, and its hardest-of-the-week band was being met by maps that hand the player most of the wall. Now each body of water is drawn only if it fits what is left of the day's share and what the day allows in one piece, so by Sunday there really is nothing to lean on. `DailyAlmanacTests` measures the stretch on every board that ships and holds it to the table above, so this cannot go quiet again.

The bands are laid end to end and never overlap, which is what makes a week a climb rather than a claim. Treats are kept off the four tiles around the pig — apples as well as skulls, now that neither takes a fence — so the four pieces boxed round it that hold on every other board in this game hold on a daily too.

#### The shape a day's water takes

The table above says how much water a day gets. It says nothing about where it goes, and for seven hundred boards the answer was the same one: bodies of it dropped one after another until the day was wet enough. That is the right default — it is the arrangement a weekday's share of water was tuned against — but it is also the reason a Tuesday in March looks like a Tuesday in September. So roughly two days a week are handed one of the shapes in `SHAPES` instead:

| Shape | What the board looks like | Rungs |
|---|---|---|
| `speckle` | Water freckled a tile at a time over one colour of the board's checkerboard, never beside water already there, so every freckle stands alone. Part of the day's water still goes down as ordinary bodies first; the rest of the board gets the lattice. | all |
| `coast` | A shore cut across one corner on the diagonal, stepping in a tile at a time. A lake against an edge hands over a straight wall, which is the wall a player would have built anyway; a stepped shore hands over half a staircase. | Mon, Wed–Fri |
| `strait` | Two banks of water reaching in from opposite edges and stopping short of each other, so the board is very nearly cut in two and a neck of ground a tile or three wide holds the halves together. | Mon, Tue, Thu, Fri |

A shape only decides where the water goes. The weekday still sets how wet the board is, how much of it may lie in one piece, and what the day has to ask, and a shaped map is thrown back and drawn again until it lands in its band exactly like a plain one. Which days get a shape is drawn from the date alone rather than from the day's generator, which is what made adding this a change to some of the book rather than all of it: a day that comes up plain asks its generator for the same things in the same order and comes out the board it always was.

A shape is only offered a rung it can actually be built on, and the rungs in the table are measured rather than guessed. A coast is one long body, so it wants a pool cap worth spending — and because a stepped shore is a *staircase*, it widens the gap between the best pen and the squared-off one rather than closing it, which is why a Tuesday coast lands around 20% against a band of 6–14 and is not offered. The freckles pull the other way, and that is the counter-intuitive one: a freckle beside the block of ground a player squares off is a free fence piece for the pen that needed one most, while the staircase pen it is being measured against was already spending its budget well. Water broken up small therefore makes a day *easier*, so the dry end of the week keeps more of its water in bodies to pay for its freckles.

Because a shape is a claim about the board a player is handed, and a claim nobody counts is one the generator can quietly stop honouring, the shape each day came out as is written into the fixtures beside what it asks. `DailyAlmanacTests` counts them, holds the plain board to still being what a day usually looks like, and makes every freckled day prove it really is freckled rather than a plain board filed under another name.

It writes two files, both generated and both committed:

- `Pigpen/Models/DailyAlmanacData.swift` — the puzzles, one line to a day: the date, the fence budget, the two star thresholds, the best pen the map has in it, and the map itself with its rows run together by `/`.
- `PigpenTests/DailyAlmanacFixtures.swift` — what each day asks, the shape its water was laid in, and the wall of the pen its `maximumScore` was measured on.

`DailyAlmanacTests` lays every one of those walls out on its day's board and lets the pig go, so a day that promised a pen its map does not hold fails in CI rather than withholding the "best pen there is" verdict from a player forever. It checks the rest of what the almanac claims too: that the book runs from New Year's Day to New Year's Eve without a gap, that every day falls in its weekday's band, that every week climbs from Monday to Sunday, that the book still holds every shape of water the generator knows how to lay, and that four pieces round the pig hold on every board in it.

Everything a day is made of comes out of a generator seeded from that date alone, so days are independent, the work spreads over as many cores as there are, and the same run of the tool produces the same year twice over. Running it takes the better part of an hour across four cores, which is the price of measuring what a puzzle asks rather than declaring it.

To carry the book further, re-run the tool with the years wanted and commit what it writes. Nothing else has to change: the archive works out its own months from what is in the book, and a day past the end of it is told there is no puzzle rather than handed an empty field.

### Build from phone (no laptop)

1. Edit code on GitHub (mobile app or web)
2. Open a PR — CI builds it and posts screenshots as a comment
3. Merge to main — a TestFlight build ships automatically
4. Install from TestFlight on your phone

## How changes ship

```
PR to main ──► ci.yml (build) + screenshots.yml (screenshot comment)
     │
     ▼
merge to main ──► testflight.yml ──► TestFlight (build number = UTC timestamp)
     │
     ▼
tag vX.Y.Z ──► release.yml ──► App Store Connect + GitHub Release
```

| Workflow | Trigger | Action |
|---|---|---|
| `ci.yml` | PR to main, push to main | Build for simulator, no signing, then run the unit tests |
| `screenshots.yml` | PR to main | Build, wake a simulator, capture the title screen, the tutorial, the universe map, all three world trails, six boards (including a thicket board of truffles and brambles and a mountain board of chestnuts and embers), the settings sheet, a daily board and its archive and all fourteen shots of the three cut scenes in light + dark, post/update a PR comment |
| `testflight.yml` | Push to main | Archive, sign, upload to TestFlight |
| `release.yml` | Tag `v*.*.*` | Archive with the tag's version, submit to App Store Connect, cut a GitHub Release |
| `signing-setup.yml` | Manual | Create, list or revoke the signing certificate and profile over the App Store Connect API |

Notes on the details:

- **Signing.** Runners are wiped after every job, so `testflight.yml` and `release.yml` import a distribution certificate and App Store profile into a throwaway keychain (`.github/actions/setup-signing`) and archive with `CODE_SIGN_STYLE=Manual`. They deliberately do *not* pass `-allowProvisioningUpdates`: with an empty keychain that flag makes Xcode ask Apple for a **brand new certificate on every run** and abandon it, so after a handful of builds the account hits its certificate limit and every archive fails with "Your account has reached the maximum number of certificates." Where the certificate comes from is covered under [Signing](#signing) below.
- **Versioning.** `MARKETING_VERSION` lives in `project.yml`; the build number is a `YYYYMMDDHHMM` timestamp injected at archive time, so it always increases. A release tag overrides the marketing version, so `v0.2.0` ships as version `0.2.0`.
- **Screenshots.** The PR screenshot images are committed to an orphan-ish `ci-screenshots` branch under `pr-<number>/` and hot-linked into a single PR comment that gets updated in place on each push. That branch is CI-only — never merge it. Files are named `<order>_<screen>_<light|dark>.png`, and each screen gets its own row in the comment. The app takes `-universe`, `-map`, `-woods-map`, `-peak-map`, `-puzzle`, `-orchard`, `-sour`, `-boss`, `-truffles`, `-embers`, `-tutorial`, `-daily`, `-archive`, `-title` and `-settings` launch arguments so the universe map, each world's trail, the boards, the practice pen and the settings sheet can be captured without tapping through the title screen; `-universe` opens the cosmic map with the meadow held and the thicket open, `-woods-map` opens the thicket's trail and `-peak-map` the mountain's, and the meadow map and plain board open part way through, since an untouched world has nothing on it to look at and an untouched field has no fencing and not a control on it lit. `-truffles` opens Nettle Bank dressed for the woods, where a truffle and a bramble sit on the ground in place of an apple and a skull, and `-embers` opens Smoulder Ridge dressed for the mountain, on ash and cinder with chestnuts and embers on it. The next two are the boards with something lying on the ground: `-orchard` opens Windfall Orchard with its best pen closed, where an apple shut in and an apple left standing outside the wall can be seen at once, and `-sour` opens Sour Ground with a pen holding one apple and one skull, which cancel each other out. `-boss` opens Stag Mere with the best pen it has in it standing, which is the one board with two animals on it and two enclosures holding them. `-tutorial` opens the practice pen on its first coach card. `-settings` opens the title screen with the sheet already up, over a world part way through and held in memory, so the clear button in the screenshot has something to say and nothing on the device to say it to. `-daily` and `-archive` open the daily board and the calendar behind it on a fixed square of the calendar rather than on whatever day the runner is having, so the archive shows the same month of finished and shut days every time; the clock over that board is handed over already stopped, for the same reason a film is photographed a shot at a time. `-title` is the title screen with a fortnight of dailies behind it, so the card under Play has its stars, its clock and its run of days on it, where the plain title shot has the card as a new player finds it. The fourteen film arguments each stop a cut scene on one of its shots rather than playing it, since a screenshot of something on a clock is a screenshot of whenever the runner got round to it; the films are lit by the shot rather than by the phone, so their two appearances are meant to match. Each screen is shot in both appearances off one launch: the views read the colour scheme out of the environment, so flipping the simulator under a running app re-draws it, and the pair then shows the same board rather than two rolls of the dice.
- **The simulator is the slow part.** Not the build. A simulator that has never been booted on a fresh runner spends five or six minutes getting to the point where it can install, run and photograph an app: booting, starting installd, building the runtime's shared cache the first time anything launches, attaching a display the first time anything is photographed. That, not compiling, was where all but a minute of a twelve-minute check went. `.github/actions/simulator` hands the expensive firsts to a stub app — five lines of C linked against UIKit and SwiftUI, never called, only loaded — and to one throwaway screen grab, so the real app arrives to a simulator that has done all of it once already. Installing and launching the app for real then takes seconds instead of four minutes. Only the boot can fail the job; if the rest of the warm-up does not happen the job simply pays for it itself, later, which is where it was paying before.
- **Waking the simulator is not worth overlapping with the build.** It looks like free parallelism and it is not: a runner has three cores, the boot wants all of them, and running the two together made a 30-second build take two to five minutes — more than the overlap ever saved. So the build finishes first and the simulator is woken after it. For the same reason the builds ask for a generic simulator destination rather than naming the device: naming it makes xcodebuild ask CoreSimulator about a device that is still booting, and it will sit there for minutes waiting for an answer.
- **Concurrency.** CI and screenshots cancel superseded runs per branch. Everything that signs shares one `apple-signing` group and never cancels, so two merges in quick succession both ship, one after the other, and no two runs touch the account's certificates at the same time.
- **Doc-only changes.** Pushes and pull requests that only touch `*.md`, `LICENSE` or `.gitignore` skip all three of CI, screenshots and TestFlight.

### Cutting a release

```bash
git tag v0.2.0
git push origin v0.2.0
```

## Required Secrets

Set these in GitHub repo settings → Secrets and variables → Actions.

| Secret | Purpose | How to get it |
|---|---|---|
| `TEAM_ID` | Apple Developer Team ID | developer.apple.com → Membership |
| `APP_STORE_CONNECT_API_KEY_ID` | API key ID, for uploading builds | App Store Connect → Users and Access → Integrations → Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | Same page as above |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | API key (`.p8` file contents), **raw text** | Paste the full text including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` |
| `APPLE_DISTRIBUTION_CERT_P12` | Optional. Distribution certificate **and its private key**, base64 | [One stored certificate](#one-stored-certificate) |
| `APPLE_DISTRIBUTION_CERT_PASSWORD` | Optional. Password protecting that `.p12` | Same |
| `APPLE_PROVISIONING_PROFILE` | Optional. App Store profile for `com.pigpen.app`, base64 | Same |

The App Store Connect app record must exist with bundle ID `com.pigpen.app` (see `project.yml`) before the first TestFlight upload.

## Signing

A distribution certificate is only usable together with the private key it was created from, and Apple caps each account at a couple of certificates — so a build cannot just ask for a fresh one each time, which is what broke this repo's first few TestFlight runs. Apple's instructions have you make the key in Keychain Access on a Mac, but nothing requires that: the key can be generated anywhere, the signing request submitted over the App Store Connect API, and the `.p12` assembled with openssl. `Tools/bootstrap_signing.py` does that, so none of what follows needs a Mac.

### Per-build certificates

This is what happens by default, with no setup beyond the App Store Connect API key. Each release build creates its own certificate and profile, signs, uploads, and a later build retires them, so the account holds one certificate at rest and never approaches the limit.

The sweep runs at the *start* of a build rather than the end of the previous one. That keeps revocation well away from App Store Connect still processing an upload, and it collects anything a cancelled run left behind, so the account cannot silently fill up again. Profiles are named `Pigpen CI <run id>`, which is how the sweep tells CI's certificates apart from a person's: a certificate you made yourself survives as long as some profile references it, and if you have one with no profile at all, add `--keep-serial <serial>` to the cleanup step.

Revoking a distribution certificate does not disturb builds already on TestFlight or the App Store, because Apple re-signs those for distribution. It would break Ad Hoc or direct-install builds, which this repo never produces.

What you give up is independence from Apple's API: every release build now calls it twice, and two builds must never mint at once — hence the shared `apple-signing` concurrency group across `testflight.yml`, `release.yml` and `signing-setup.yml`.

### One stored certificate

If you would rather builds never touch Apple's certificate API, set the three `APPLE_*` secrets and every build reuses that one certificate instead of minting anything. From a phone:

1. Create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new) scoped to this repository with **Secrets: read and write**, and save it as a secret named `SIGNING_BOOTSTRAP_PAT`. The built-in workflow token cannot write secrets, which is the only reason a PAT is needed.
2. Actions → **Signing Setup** → *Run workflow* → task `create`. It registers the App ID if missing, creates the certificate and profile, and sets the three secrets.
3. Delete `SIGNING_BOOTSTRAP_PAT`. The next build signs with the stored certificate.

Renew it before it expires a year later. Note that a GitHub secret can be written but never read back, so a certificate created this way lives only inside Actions; that is recoverable by revoking and re-running `create`, but if you also want the `.p12` in hand, run the script locally instead:

```bash
export APP_STORE_CONNECT_API_KEY_ID=... APP_STORE_CONNECT_ISSUER_ID=...
export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat ~/Downloads/AuthKey_XXXXXX.p8)"

Tools/bootstrap_signing.py list
Tools/bootstrap_signing.py create   # writes the three values to .signing-secrets/
```

### Clearing out certificates

Actions → **Signing Setup** → task `list` shows every certificate and profile on the account with their ids, and task `revoke` takes those ids. That is the way out of "your account has reached the maximum number of certificates": revoke the ones nobody holds a private key for. Certificates whose key is lost — anything an old CI run created and threw away — are only taking up slots.

### Using a certificate from a Mac

If you would rather use Xcode's own certificate flow for the stored-certificate route:

1. Xcode → Settings → Accounts → select the team → *Manage Certificates* → `+` → *Apple Distribution*.
2. Keychain Access → *My Certificates* → right-click the `Apple Distribution: …` row → *Export*, save as `.p12`, set a password. Expanding the row must reveal a private key; if it does not, this Mac does not have the key and the export is useless.
3. developer.apple.com → Profiles → `+` → *App Store Connect* → App ID `com.pigpen.app` → pick that certificate → download the `.mobileprovision`.
4. Check and encode the pair, which also confirms the profile was really issued for that certificate:

```bash
Tools/prepare_signing_secrets.sh ~/Downloads/Certificates.p12 ~/Downloads/Pigpen_AppStore.mobileprovision
```

5. Set the three secrets with the `gh secret set` commands it prints, then delete `.signing-secrets/` and keep the `.p12` and its password somewhere safe.

Local development needs none of this: `project.yml` keeps `CODE_SIGN_STYLE: Automatic`, so Xcode signs with your personal team, and only the release workflows override it with the shared identity.

## Project Structure

```
Pigpen/
├── App/
│   └── PigpenApp.swift          # App entry point
├── Models/
│   ├── GridPoint.swift          # Tile coordinates and the four directions
│   ├── PuzzleLevel.swift        # Terrain, treats, pig start, budget, scoring, and every shipped map
│   ├── PenOutcome.swift         # Releases the pig: escape route, or the pen it is stuck in
│   ├── VictoryLap.swift         # The little circle an animal runs when its pen holds
│   ├── CutScene.swift           # The meadow's films, as clocks: which shot is up when, and for how long
│   ├── StorybookScene.swift     # A themed world's films, as clocks: the lighter hand a new world opens, briefs and closes on
│   ├── Stopwatch.swift          # The count-up clock over a timed board: start, stop, resume, reset
│   ├── PuzzleGame.swift         # Observable state for one puzzle in progress
│   ├── WorldMap.swift           # The levels of a world and where their signposts stand
│   ├── WorldProgress.swift      # Best stars and best pens, what that unlocks, which films are owed
│   ├── WorldTheme.swift         # A world's look: its light, its ground, its treat skin, its board skin, its boss silhouette
│   ├── GameWorld.swift          # A world bundled: its map, its theme, the films that wrap it and the boss it briefs
│   ├── Woodland.swift           # Thornwood Thicket: its nine levels and the trail through them
│   ├── Emberpeak.swift          # Emberpeak: its nine levels and the trail up them
│   ├── Cogsworth.swift          # Cogsworth City: its nine levels and the trail through them
│   ├── Starfall.swift           # Starfall Reaches: its nine levels and the trail out across them
│   ├── Gloamdeep.swift          # Gloamdeep Caverns: its nine levels and the trail down through them
│   ├── Carnival.swift           # Lantern Carnival: its nine levels and the trail round them
│   ├── Dunes.swift              # Sunbaked Dunes: its nine levels and the trail out over them
│   ├── Universe.swift           # Every world there is, and the chain that unlocks them one at a time
│   ├── UniverseProgress.swift   # How far across the universe, read from the one shared star store
│   ├── GameCompletion.swift     # The whole game as one percent: every star and every rainbow in every world
│   ├── DailyDate.swift          # A square of the calendar: its weekday, its month, its name
│   ├── DailyAlmanac.swift       # The book of daily puzzles, and which of them are open yet
│   ├── DailyAlmanacData.swift   # Generated: every daily puzzle, one line to a day
│   └── DailyProgress.swift      # Days done: stars, times, best pens, walls, drafts, streaks
├── Views/
│   ├── TitleScreenView.swift    # Start screen
│   ├── TitleSceneView.swift     # The animated pasture behind the title
│   ├── DailyCard.swift          # Today's puzzle on the title screen: the day, its stars, its clock
│   ├── DailyArchiveView.swift   # The calendar of every daily there has been this year
│   ├── DailySquare.swift        # One day in the archive: a little field, washed once it is done
│   ├── DailyPuzzleView.swift    # One day's board: clock, draft kept on the way out, record on a pen
│   ├── StarRow.swift            # Three stars, and the rainbow a best pen keeps
│   ├── CutSceneView.swift       # Paints any of the meadow's films, shot by shot
│   ├── StorybookSceneView.swift # Plays a storybook film, and either kind of film behind one interface
│   ├── SettingsView.swift       # Behind the gear: the version, and clearing all game data
│   ├── WorldMapView.swift       # A world's map: signposts, the walking pig, the trail, its send-off
│   ├── WorldMapScene.swift      # The meadow the trail runs through
│   ├── UniverseMapView.swift    # The universe map: planets, boss silhouettes, and the unlock chain
│   ├── WorldTrail.swift         # Stops ↔ points on screen, and the curve between them
│   ├── LevelSignpost.swift      # One stop on the map: stars — rainbow for a best pen — number, name
│   ├── PuzzleView.swift         # A puzzle end to end: build, release, verdict
│   ├── FieldView.swift          # Draws the field and turns taps into fenced tiles
│   ├── FieldSkin.swift          # How a world paints its board: its ground, its water and its fencing
│   ├── MeadowBackdrop.swift     # The meadow behind a board, and the timber bar over it
│   ├── FenceRack.swift          # The budget as a rack of pieces, spent ones taken off it
│   ├── Celebration.swift        # The lap of honour, as a clock: where an animal is at any moment of it
│   ├── BoardGeometry.swift      # Tiles ↔ points on screen
│   ├── ChunkyButtonStyle.swift  # The wooden buttons: the title screen's, and the board's
│   ├── GamePalette.swift        # Colours: the pasture's day, dusk and sunrise, and the forest, ember and city sets
│   └── Scatter.swift            # The seeded generator every drawn scene scatters things with
└── Resources/
    ├── Assets.xcassets          # App icon, accent color
    └── Pigpen.entitlements
PigpenTests/                     # Unit tests, including the generated daily almanac fixtures
Tools/
├── generate_app_icon.py         # Redraws the app icon PNGs
├── level_search.py              # Finds the best pen a map and budget allow, and what it asks
├── generate_dailies.py          # Writes a year of daily puzzles, and measures what each asks
├── bootstrap_signing.py         # Creates/lists/revokes the signing certificate over the API
└── prepare_signing_secrets.sh   # Checks and encodes a certificate exported from a Mac
```

The model layer is plain Swift with no UI imports, so all of the game rules — escape
detection, water boundaries, budgets, scoring — are covered by unit tests.

## License

MIT
