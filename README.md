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
- **Apples and skulls** lie on the mud rather than being mud of their own. An apple shut
  into the pen is worth five ordinary tiles, so a pen that goes out of its way for one is
  usually worth the ground it gives up getting there. An apple takes a fence like any other
  tile, which is how one gets wasted. A skull costs five, and it is staked into the ground:
  no piece can be laid on it, so a wall that wants a skull's tile has to be built round it —
  and a wall built round one still has to shut it out, since ground you leave open is ground
  the pig walks onto. Sour ground is planned around, not paved over. Tapping a skull says
  what it costs — `-5 points` — rather than shaking the fence rack like a spent budget.
- **Escape.** Release the pig and it tries every route. If a single gap leads to the edge
  of the map, it walks out and the attempt fails.
- **A pen that holds gets a lap of honour.** With nowhere to go, the pig runs two circuits
  of the ground you shut it into — leaning into the corners, bobbing on every tile it
  covers — and finishes on a hop where it started, under confetti thrown up out of its own
  tile. Only then does the score come up, through the last of the falling paper. A pen too
  narrow for a circle is run out and back instead, one too tight for that is bounced on the
  spot, and the best pen the map has in it gets its confetti in every colour there is. Ask
  for reduced motion and the field keeps still.
- **The boss keeps two.** The last puzzle in the meadow stands a deer on the field as well
  as the pig, and one budget has to hold both of them. One pen round the pair or a pen
  apiece is up to you — a pen holds whatever ground it shuts in, whether that ground is in
  one piece or two — but an animal left loose loses the field however well the other one
  is held.
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

Play leads out to the **universe map** (below), and its first world is **Mudlark Meadow**:
nine puzzles as nine signposts up one winding trail, with the pig standing at the furthest
one it has reached and mist over everything past that. The first six are fencing and water
alone and climb in what they ask of you, the next two scatter apples and skulls as well, and
the last is the boss. Every world in the game is a trail like this one.

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
| 4 | The Big Meadow | 16 | — | 26 | 33 | 21% |
| 5 | Otter Ford | 12 | — | 16 | 24 | 33% |
| 6 | Puddle Corner | 8 | — | 16 | 26 | 38% |
| 7 | Windfall Orchard | 12 | 4 apples | 26 | 37 | 29% |
| 8 | Sour Ground | 14 | 3 apples, 2 skulls | 15 | 29 | 48% |
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

The meadow opens on two maps whose best pen *is* the obvious pen, so the first three stars
are free and the game gets to explain itself. From there the gap widens the whole way to
Puddle Corner — eight pieces, a small board, and nothing to lean on but the shape of the
wall, which is the widest gap on that stretch and why the smallest-looking level closes it
instead of opening it. The last three change what is on the ground rather than what the wall
has to do, so they run apples, then skulls to build around as well, then a second animal and
one budget to split: sorting *those* by the gap would put the ideas in the wrong order. Sour
Ground has the widest gap in the game and still belongs eighth — a skull refuses fencing, so
every squared-off block worth having on that map is one the player cannot build, and the
number says more about the block than about the level. `DifficultyTests` pins the lot, so the
climb cannot quietly flatten out again.

Each of those pens is drawn out in [`solutions.md`](solutions.md), which is spoilers from
the first line.

## The Universe

Hold every pen in Mudlark Meadow and its send-off pulls back to the **universe map**: the
meadow behind you, the next world lit up ahead, and ten more strung out past them through
space, each drawn as a little planet with its boss shown on it. A world opens once the one
before it is held, so the map is a chain — finish a world to reach the next — and the pig
carries the same game into every one of them.

- **Every world is the meadow's game on new ground.** Fence in the pig, the biggest pen the
  pieces will reach round, shut or it is no pen at all. What a theme changes is only the
  dressing: the light the trail is drawn in, what the windfall and the hazard look like on
  the ground, and the shape that waits at the end. The board underneath never knows the
  difference, which is why one solver authors every level in the game.
- **Each world plays its own films.** An opening the first time you walk into it, and a
  send-off once every pen is held — the send-off pointing on past the world, the way the
  meadow's points past the hills to a gate standing open somewhere else.
- **The bosses are silhouettes until you reach them.** A world you have not opened yet shows
  its boss as a dark shape on its planet; reach it and the shape comes up in full colour. The
  whole journey is on the map from the first time you see it, so there is always somewhere to
  be going.

Twelve worlds are drawn: **Mudlark Meadow** and **Thornwood Thicket** to play, then Emberpeak,
Cogsworth City, Starfall Reaches, Gloamdeep Caverns, Lantern Carnival, Sunbaked Dunes,
Tidepool Cove, Frostwhisker Tundra, Mirebog Fen and Cloudspire Heights waiting as silhouettes.
Adding one is a matter of authoring its levels and its theme — the map, the unlocking and the
films are already there.

### Thornwood Thicket

The second world, and the first past the meadow. The pig has taken the tree line, so the
trail runs through deep woods in forest light, the windfall is a **truffle** rather than an
apple and the hazard a **bramble** rather than a skull — each worth exactly what its meadow
twin was, a truffle five tiles to shut in and a bramble five to shut in with and no fencing
at all. The one thing the thicket does that the meadow did not is **scatter** its treats. The
meadow held them all back for its last three fields; the thicket has walked its pig everywhere
at once, so a truffle turns up in the third field and a bramble in the sixth, with plain
fields in between. It reads as woods a pig has been rooting through rather than a lesson laid
out in order.

| # | Level | Pieces | On the ground | Best pen |
|---|---|---|---|---|
| 1 | Bramble Brook | 10 | — | 20 |
| 2 | Foxglove Dell | 6 | — | 20 |
| 3 | Hazel Copse | 12 | 1 truffle | 30 |
| 4 | Gnarl Ford | 12 | — | 24 |
| 5 | Fern Gully | 12 | 2 truffles | 34 |
| 6 | Willow Corner | 8 | — | 26 |
| 7 | Nettle Bank | 13 | 2 truffles, 1 bramble | 26 |
| 8 | Elderwood | 15 | 3 truffles, 1 bramble | 41 |
| 9 | Boar Hollow | 18 | 6 truffles, 2 brambles | 54 |

Its boss, Boar Hollow, is the thicket's deepest and treat-thickest field rather than a second
animal — held by one pig and the biggest budget in the woods, and asking for 21 of the 24
stars below it before it opens, the same toll Stag Mere charges. Every pen is drawn out in
[`solutions.md`](solutions.md).

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

Three films so far, each played once and each with a **Skip** in the corner from a beat in. Skipping counts as having seen one.

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

#### How they are built

Like the pasture behind the title and the lap of honour on a pen that holds, a film is a
clock rather than a queue of steps: [`CutScene`](Pigpen/Models/CutScene.swift) says which
shot is up at a given second and how far through it, and `CutSceneView` paints that. All
three are the same machine — a list of shots, each held for a moment and captioned — so a
fourth is a list and a few pictures rather than another screen.

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

A level is an ASCII map — `.` mud, `~` water, `a` an apple, `x` a skull, `P` the pig, `D` a deer — and four numbers: the fence budget, the scores the second and third stars are worth, and `maximumScore` — the best pen the map and that budget allow. The first three are a judgement call. The last one is not, and getting it wrong either withholds the "best pen there is" verdict forever or hands it out for a pen that could still be bettered. `Tools/level_search.py` works it out:

```bash
Tools/level_search.py --budget 12 --plan <<'MAP'
.........
~~~~~~~..
...a..~..
..P...~..
.........
MAP
```

It prints the best pen it found, marked out on the map, along with `maximumScore` and star thresholds in the proportions the shipped levels use. It knows what the game knows: a skull takes no fencing, so a pen whose wall would have to stand on one is never offered as an answer. Add the level to `PuzzleLevel`, hang it on the trail in `WorldMap.mudlarkMeadow`, and add its plan — the `#` tiles `--plan` prints on their own — to `shipped` in `PuzzleLevelTests`, which replays the pen and fails if the level stops giving up what it claims.

The star thresholds are the judgement call, but not a free one: `DifficultyTests` holds every level to a second star for the pen a player gets by squaring the map off, so `--demand` is worth running on any map with skulls on it — walling round one can cost a plain block far more than it costs a shaped pen, and the second star has to stay under what the block is worth.

Then work out where on the trail it belongs. `--demand` squares the map off as well — the best plain block of ground per animal — and prints that pen, `squaredOff`, and the gap between it and the best pen as a percentage. That gap is what the level asks of a player, and the fencing-and-water stretch is ordered by it. Add the level and its squared-off plan to `baselines` in `DifficultyTests`, which replays that pen too and fails if the trail stops climbing.

A map with a `D` on it as well as a `P` is held by ground in two pieces as happily as by one, and the search knows it: it grows out from both animals at once and prices a wall shared between two enclosures once, like any other. It is a bigger search than a one-animal map, so give it a minute — and check the answer holds with a wider `--beam` before authoring it. A stop on the trail can also be given a `starToll`, which shuts it until the world has that many stars however far the trail has got.

The search carries its pens as bitmasks — one bit per tile of the board — rather than as sets of coordinates, which is the same search written so that it finishes in a second rather than half a minute. Nothing about which pens it keeps changed when it was rewritten, and the nine shipped levels come out at exactly the numbers they always did, which is what `PuzzleLevelTests` and `DifficultyTests` are there to say. That speed is what makes a year of daily puzzles possible at all.

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

The bands are laid end to end and never overlap, which is what makes a week a climb rather than a claim. Skulls are kept off the four tiles around the pig, so the four pieces boxed round it that hold on every other board in this game hold on a daily too.

It writes two files, both generated and both committed:

- `Pigpen/Models/DailyAlmanacData.swift` — the puzzles, one line to a day: the date, the fence budget, the two star thresholds, the best pen the map has in it, and the map itself with its rows run together by `/`.
- `PigpenTests/DailyAlmanacFixtures.swift` — what each day asks, and the wall of the pen its `maximumScore` was measured on.

`DailyAlmanacTests` lays every one of those walls out on its day's board and lets the pig go, so a day that promised a pen its map does not hold fails in CI rather than withholding the "best pen there is" verdict from a player forever. It checks the rest of what the almanac claims too: that the book runs from New Year's Day to New Year's Eve without a gap, that every day falls in its weekday's band, that every week climbs from Monday to Sunday, and that four pieces round the pig hold on every board in it.

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
| `screenshots.yml` | PR to main | Build, wake a simulator, capture the title screen, the tutorial, the universe map, both world trails, five boards (including a thicket board of truffles and brambles), the settings sheet, a daily board and its archive and all fourteen shots of the three cut scenes in light + dark, post/update a PR comment |
| `testflight.yml` | Push to main | Archive, sign, upload to TestFlight |
| `release.yml` | Tag `v*.*.*` | Archive with the tag's version, submit to App Store Connect, cut a GitHub Release |
| `signing-setup.yml` | Manual | Create, list or revoke the signing certificate and profile over the App Store Connect API |

Notes on the details:

- **Signing.** Runners are wiped after every job, so `testflight.yml` and `release.yml` import a distribution certificate and App Store profile into a throwaway keychain (`.github/actions/setup-signing`) and archive with `CODE_SIGN_STYLE=Manual`. They deliberately do *not* pass `-allowProvisioningUpdates`: with an empty keychain that flag makes Xcode ask Apple for a **brand new certificate on every run** and abandon it, so after a handful of builds the account hits its certificate limit and every archive fails with "Your account has reached the maximum number of certificates." Where the certificate comes from is covered under [Signing](#signing) below.
- **Versioning.** `MARKETING_VERSION` lives in `project.yml`; the build number is a `YYYYMMDDHHMM` timestamp injected at archive time, so it always increases. A release tag overrides the marketing version, so `v0.2.0` ships as version `0.2.0`.
- **Screenshots.** The PR screenshot images are committed to an orphan-ish `ci-screenshots` branch under `pr-<number>/` and hot-linked into a single PR comment that gets updated in place on each push. That branch is CI-only — never merge it. Files are named `<order>_<screen>_<light|dark>.png`, and each screen gets its own row in the comment. The app takes `-universe`, `-map`, `-woods-map`, `-puzzle`, `-orchard`, `-sour`, `-boss`, `-truffles`, `-tutorial`, `-daily`, `-archive`, `-title` and `-settings` launch arguments so the universe map, each world's trail, the boards, the practice pen and the settings sheet can be captured without tapping through the title screen; `-universe` opens the cosmic map with the meadow held and the thicket open, `-woods-map` opens the thicket's trail, and the meadow map and plain board open part way through, since an untouched world has nothing on it to look at and an untouched field has no fencing and not a control on it lit. `-truffles` opens Nettle Bank dressed for the woods, where a truffle and a bramble sit on the ground in place of an apple and a skull. The next two are the boards with something lying on the ground: `-orchard` opens Windfall Orchard with its best pen closed, where an apple inside the pen and an apple buried under the fencing can be seen at once, and `-sour` opens Sour Ground with a pen holding one apple and one skull, which cancel each other out. `-boss` opens Stag Mere with the best pen it has in it standing, which is the one board with two animals on it and two enclosures holding them. `-tutorial` opens the practice pen on its first coach card. `-settings` opens the title screen with the sheet already up, over a world part way through and held in memory, so the clear button in the screenshot has something to say and nothing on the device to say it to. `-daily` and `-archive` open the daily board and the calendar behind it on a fixed square of the calendar rather than on whatever day the runner is having, so the archive shows the same month of finished and shut days every time; the clock over that board is handed over already stopped, for the same reason a film is photographed a shot at a time. `-title` is the title screen with a fortnight of dailies behind it, so the card under Play has its stars, its clock and its run of days on it, where the plain title shot has the card as a new player finds it. The fourteen film arguments each stop a cut scene on one of its shots rather than playing it, since a screenshot of something on a clock is a screenshot of whenever the runner got round to it; the films are lit by the shot rather than by the phone, so their two appearances are meant to match. Each screen is shot in both appearances off one launch: the views read the colour scheme out of the environment, so flipping the simulator under a running app re-draws it, and the pair then shows the same board rather than two rolls of the dice.
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
│   ├── StorybookScene.swift     # A themed world's films, as clocks: the lighter hand a new world opens on
│   ├── Stopwatch.swift          # The count-up clock over a timed board: start, stop, resume, reset
│   ├── PuzzleGame.swift         # Observable state for one puzzle in progress
│   ├── WorldMap.swift           # The levels of a world and where their signposts stand
│   ├── WorldProgress.swift      # Best stars and best pens, what that unlocks, which films are owed
│   ├── WorldTheme.swift         # A world's look: its light, its truffle/bramble skin, its boss silhouette
│   ├── GameWorld.swift          # A world bundled: its map, its theme, and the films that wrap it
│   ├── Woodland.swift           # Thornwood Thicket: its nine levels and the trail through them
│   ├── Universe.swift           # Every world there is, and the chain that unlocks them one at a time
│   ├── UniverseProgress.swift   # How far across the universe, read from the one shared star store
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
│   ├── MeadowBackdrop.swift     # The meadow behind a board, and the timber bar over it
│   ├── FenceRack.swift          # The budget as a rack of pieces, spent ones taken off it
│   ├── Celebration.swift        # The lap of honour, as a clock: where an animal is at any moment of it
│   ├── BoardGeometry.swift      # Tiles ↔ points on screen
│   ├── ChunkyButtonStyle.swift  # The wooden buttons: the title screen's, and the board's
│   ├── GamePalette.swift        # Colours, including the pasture's day, dusk, sunrise and forest sets
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
