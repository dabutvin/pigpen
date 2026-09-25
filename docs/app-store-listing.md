# The App Store listing

Every word the store asks for, written down here so filling in App Store Connect is
transcription rather than composition. The live listing is the source of truth: when it is
changed in App Store Connect, the change is copied back here, not the other way round. Each field fits its limit as written — the limits are
noted so an edit here knows what it is editing against. Screenshots come from the **App Store
Assets** workflow ([app-store-assets.md](app-store-assets.md)); the URLs and the checklist
that goes with all of this are in the README under *Before a submission*.

## App Information

| Field | Value | Limit |
| --- | --- | --- |
| Name | `Pigpen - Build the perfect pen` | 30 |
| Subtitle | `A cozy fence puzzle adventure` | 30 |
| Primary category | Games → Puzzle | |
| Secondary category | Games → Board | |
| Privacy Policy URL | `https://pigpen.app/privacy.html` | |
| Content rights | Does not contain third-party content | |

The name is at the limit to the character: `Pigpen` alone keeps the word a player searches
for at the front, and the rest says what the game is before the subtitle gets a word in.

## The version page

**Promotional text** — the one field that can change without a new build, so it carries the
seasonal line if there ever is one. 170 characters; this is 150. The store's web page does not
show it, so it is the one field here not checked against the live listing:

> A cozy puzzle about a pig and some fences. Twelve worlds, a boss at the end of
> each, and a new board every morning. No ads, no account — just the pig.

**Description** — 4,000 characters allowed, and nowhere near it: only the first few lines
show before the fold, so the hook does the selling. As it stands on the listing:

> Pig needs a bigger pen. You need a good puzzle.
>
> Pigpen is a daily puzzle game about building the biggest pen you can with a limited number
> of fence pieces.
>
> Each puzzle gives you a new board, a set number of fences, and one simple goal: use every
> piece and enclose as much space as possible. Tap to place fences, plan your route, and
> watch out for obstacles, bonuses, and other surprises along the way.
>
> The rules are simple. Finding the best solution is not.
>
> Play a new puzzle every day, build your streak, and see if you can earn all three stars.
> Then keep exploring new worlds, each with its own layouts, challenges, and twists.
>
> • A fresh puzzle every day
> • Quick, satisfying puzzles that are easy to learn
> • Streaks to keep you coming back
> • Three-star challenges for better solutions
> • New worlds with unique boards and mechanics
> • A small pig with very big pen ambitions
>
> How big can you build?

(Line breaks inside a paragraph above are only this file's wrapping — each paragraph is one
line in App Store Connect.)

**Keywords** — 100 characters, commas and all; this is 86. The name and subtitle are already
searched, so `pigpen`, `cozy` and `puzzle` are not spent again here. Like the promotional
text, the store never shows these, so they are as written here rather than as checked:

```
pig,puzzle,logic,cozy,daily,brain,fence,farm,grid,relax,casual,pen,animal,board,teaser
```

**What's New** — one entry per shipped version, newest first, each written to be read by a
player deciding whether to update. As the listing's version history has them:

For 1.4:

> Improved Pigpen notifications!
>
> Make it easier to get to the next free level unlock and other fixes and improvements
> throughout.

For 1.3:

> You can now share your daily puzzle wins with your friends!
>
> Also added a few more outfits for Pig to wear, some stats hidden in the map, and a round of
> improvements and fixes throughout.

For 1.2:

> Pigpen has sound now! If you'd rather play in quiet, the sound and haptics switches are
> right at the top of Settings.
>
> There's also a new dressing barn in the meadow with 10 accessories for Pig to wear!
>
> Elsewhere, a round of improvements and minor fixes.

For 1.1:

> All new story cut scenes and improvements to the user interface.

For 1.0.0:

> The first release: twelve worlds, a daily puzzle, and a pig.

**Support URL** `https://pigpen.app/support.html` · **Marketing URL** `https://pigpen.app`

## App Review Information

Contact: a real first and last name, `support@pigpen.app`, and a phone number that answers.
Sign-in required: **off** — there is no account in the game. Notes, as pasted:

> Pigpen needs no account and no sign-in — there is nothing to log into, so there are no demo
> credentials to give. Every world is in the build.
>
> The free part is the first world (Mudlark Meadow, nine puzzles and its boss), today's
> daily puzzle, and one new level a day in every world after the first — a level opened
> starts a 24-hour clock on the next. One non-consumable purchase, The Full Game
> (com.pigpen.app.fullgame), removes the wait — every level in every world at once — and
> opens every past day in the archive.
>
> The quickest way to the purchase sheet on a fresh install: press Archive on the title
> screen, then tap any day but today. (It is also raised by tapping a level still on its
> 24-hour clock up a world's trail, and by tapping a world on the universe map the trail
> has not yet reached — but the universe map only opens once the meadow's boss is beaten.)
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
| Family Sharing | On (the listing carries the *Supports Family Sharing* badge) | |
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
