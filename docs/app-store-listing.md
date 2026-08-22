# The App Store listing

Every word the store asks for, written down here so filling in App Store Connect is
transcription rather than composition. Each field fits its limit as written — the limits are
noted so an edit here knows what it is editing against. Screenshots come from the **App Store
Assets** workflow ([app-store-assets.md](app-store-assets.md)); the URLs and the checklist
that goes with all of this are in the README under *Before a submission*.

## App Information

| Field | Value | Limit |
| --- | --- | --- |
| Name | `Pigpen` | 30 |
| Subtitle | `A cozy puzzle about a pig` | 30 |
| Primary category | Games → Puzzle | |
| Secondary category | Games → Board | |
| Privacy Policy URL | `https://pigpen.app/privacy.html` | |
| Content rights | Does not contain third-party content | |

Short names get taken: if `Pigpen` alone is refused, `Pigpen — Pen the Pig` (21) says the
same thing and keeps the word a player would search for at the front.

## The version page

**Promotional text** — the one field that can change without a new build, so it carries the
seasonal line if there ever is one. 170 characters; this is 150:

> A cozy puzzle about a pig and some fences. Twelve worlds, a boss at the end of
> each, and a new board every morning. No ads, no account — just the pig.

**Description** — 4,000 characters allowed, and deliberately nowhere near it: only the first
few lines show before the fold, so the hook does the selling and everything after it earns
its line or goes. What earns one: how it plays, how much game there is, and what is free and
what the one purchase opens — said plainly, since a paywall a player did not see coming is
what one-star reviews are made of. The cut scenes, the privacy talk and the rest of the
game's furniture live better in the screenshots, the promotional text's six words and the
policy page than in prose here:

> You get a grid, a pig, and a strict number of fence pieces. Pen the pig in — and pen in as
> much mud as you can while you are at it.
>
> The pig walks up, down, left and right, never diagonally. Tap a tile to wall it off; press
> and drag to lay a whole run. When you let the pig go it tries every route it has, and one
> gap that reaches the edge of the map is an escape.
>
> Holding the pig is only half of it. A pen is scored on the ground it shuts in: water walls
> a pen for free, an apple inside is worth five tiles, a skull costs five. Your best pen is
> kept the moment it closes, and finding the best pen a map has in it turns the ground
> rainbow.
>
> Twelve worlds, nine puzzles each — 108 in all, every one solvable with the pieces it gives
> you — and a boss at the end of every world that stands a second animal on the field and
> changes a rule. Past those, a new puzzle every morning: the same board for everybody, with
> an archive that keeps every day you have held.
>
> Free to start: the download holds the whole first world and today's daily puzzle. One
> purchase opens every world and every day, for good — a single one-time payment, no
> subscription.

**Keywords** — 100 characters, commas and all; this is 86. The name and subtitle are already
searched, so `pigpen`, `cozy` and `puzzle` are not spent again here:

```
pig,puzzle,logic,cozy,daily,brain,fence,farm,grid,relax,casual,pen,animal,board,teaser
```

**What's New** — for 1.0, one line is the honest one:

> The first release: twelve worlds, a daily puzzle, and a pig.

**Support URL** `https://pigpen.app/support.html` · **Marketing URL** `https://pigpen.app`

## App Review Information

Contact: a real first and last name, `support@pigpen.app`, and a phone number that answers.
Sign-in required: **off** — there is no account in the game. Notes, as pasted:

> Pigpen needs no account and no sign-in — there is nothing to log into, so there are no demo
> credentials to give. Every world is in the build.
>
> The free part is the first world (Mudlark Meadow, nine puzzles and its boss) and today's
> daily puzzle. One non-consumable purchase, The Full Game (com.pigpen.app.fullgame), opens
> every other world and every past day in the archive.
>
> The quickest way to the purchase sheet on a fresh install: press Archive on the title
> screen, then tap any day but today. (It is also raised by tapping a locked world on the
> universe map, but the universe map only opens once the meadow's boss is beaten.)
>
> The game plays offline. Analytics are anonymous (TelemetryDeck), can be turned off under
> Settings → Privacy, and the app never tracks — which is why it asks for no tracking
> permission.

## The purchase

Created under the app's **In-App Purchases**, and — the part that is easy to miss on a first
submission — **attached to the version and submitted with the first build**. A purchase not
submitted alongside it leaves the map selling a thing the store has never heard of.

| Field | Value | Limit |
| --- | --- | --- |
| Type | Non-Consumable | |
| Reference name | `Full Game` | 64 |
| Product ID | `com.pigpen.app.fullgame` | |
| Price | $3.99 (USD tier; let the store set the others) | |
| Family Sharing | Off | |
| Display name | `The Full Game` | 30 |
| Description | `Every world and every day, yours for good.` | 45 |

The product ID and display name are the ones `Pigpen.storekit` and `AppStoreStorefront`
already agree on — App Store Connect has to say exactly the same or the sheet in the app
finds nothing to sell. The `.storekit` file's longer description is for the simulator only;
the store's 45-character limit is why the line above is shorter. The purchase's review
screenshot is the offer sheet itself — how to shoot it is in
[app-store-assets.md](app-store-assets.md).

## App Privacy

The questionnaire, agreeing with `PrivacyInfo.xcprivacy` and the policy — two data types,
nothing else, and no to tracking:

| Question | Answer |
| --- | --- |
| Do you collect data? | Yes |
| **Product Interaction** | Collected · purposes **Analytics** and **App Functionality** · **not** linked to the user · **not** used for tracking |
| **User ID** | Collected · purpose **Analytics** · **not** linked to the user · **not** used for tracking |

The user ID is the random number the counting mints on the phone; it names an install, never
a person. Purchases go through Apple and are not collected by the app, so they are not
declared.

## Age rating

Every questionnaire answer is **None** or **No** — no violence, no fear, no gambling, no
contests, no user content, no chat, no unrestricted web access, no ads. That comes out as
**4+**, and the one thing for sale changes none of it: the store badges "In-App Purchases"
on its own.

## Pricing and Availability

The app itself is **free**; the money is the purchase above. Availability: all territories —
nothing in the game is regional, and the daily is the same board everywhere by design.
