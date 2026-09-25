# App Store assets

What the store listing needs, and how this repo makes it.

## Screenshots

App Review wants screenshots at exact pixel sizes, and only two sets matter for
this app:

| Set | Size (px) | Simulator it comes off |
| --- | --- | --- |
| iPhone 6.9″ | 1320 × 2868 | iPhone 16/17 Pro Max |
| iPad 13″ | 2064 × 2752 | iPad Pro 13-inch (M4) |

Apple scales the 6.9″ iPhone set down for every smaller iPhone, so that one set
is the whole iPhone requirement. The iPad set is required only because the app
ships on iPad; make the app iPhone-only and it goes away.

### Making them

Run the **App Store Assets** workflow from the Actions tab (it is hand-cranked —
`workflow_dispatch` — since assets are wanted at a release, not on every commit).
It:

1. builds the app and boots a 6.9″ iPhone and a 13″ iPad simulator, status bar
   set to 9:41, full wifi, a full battery and no cellular (an iPad's date beside
   the clock is the runner's own);
2. shoots the seven screens the live listing has, in its order — Clocktower
   Square part way through, Smoulder Ridge's best pen, the gate left open, Stag
   Mere's two pens, the universe map, the daily archive and the Great Floe's best
   pen — off the same launch arguments the PR screenshots use;
3. frames each one with a line of copy through `Tools/appstore_frames.py`;
4. records the preview video on each (below);
5. uploads a single **appstore-assets** artifact holding, per device, the `raw`
   shots, the `framed` ones and the `preview` video.

Download the artifact, and upload the `framed` PNGs to App Store Connect →
your app → the version → Media Manager, in numbered order. The `raw` ones are
there if you would rather submit bare shots or reframe them by hand.

The live listing is the source of truth for which screens, in what order, with
what captions: when it changes in App Store Connect, copy the change back into
`SCREENS`.

Light or dark is a choice on the run; the default is light.

### Changing the copy or the screens

Both live in one place — the `SCREENS` array in
`.github/workflows/appstore-assets.yml`, each entry a `slug:-launch-argument:caption`.
Add, drop or reword a line there. The launch arguments the app understands are
the `Photograph` cases in `Pigpen/App/PigpenApp.swift`.

To try a caption without a whole CI run, frame any PNG by hand:

```sh
python3 Tools/appstore_frames.py \
    --input shot.png --output framed.png --caption "A cozy pig puzzle"
```

The frame keeps the canvas the size of the shot it is handed, so a shot taken at
a store size comes out at that size.

## The purchase's screenshot

An in-app purchase is reviewed with a screenshot of its own, attached to the product in App
Store Connect — the offer sheet, not the board. It is for the reviewer only and never shown
on the store, so it is taken by hand rather than by the workflow: run the app in any
simulator, press **Archive** on the title screen, tap any day but today, and shoot the sheet
that comes up (⌘S in Simulator, or `xcrun simctl io booted screenshot offer.png`). Anything
at or above 640 × 920 px does; a 6.9″ shot is comfortably past it.

## App previews (the video)

Apple takes a preview only as a **recording of the app** — 15–30 seconds, portrait,
at its own sizes per device — never a rendered video. So the workflow records one:
the app is launched with `-preview`, which plays the live listing's preview on a
fixed clock (`Pigpen/Views/PreviewReel.swift`). Like the one on the listing, it is
20 seconds cut across three boards at a player's pace, and it loops:

| Time | What plays |
| --- | --- |
| 0–2 s | The Great Floe's best pen, let go into: the lap of honour |
| 2–8 s | Windfall Orchard from bare mud, twelve pieces tapped in, the pig let go |
| 8–11 s | Smoulder Ridge with three pieces left, finished and let go |
| 11–20 s | The Great Floe with three left, finished, let go, the verdict card, then *Start over* back to the bare floe the film loops into |

`xcrun simctl io … recordVideo` is started before the launch and stopped a fixed
time after it, and the 20 seconds are cut counting back from the stop, so a slow
recorder cannot clip the opening. ffmpeg brings the cut to what App Store Connect
takes:

| Set | Preview size (px) | File |
| --- | --- | --- |
| iPhone 6.9″ | 886 × 1920 | `iphone_6_9/preview/preview.mp4` |
| iPad 13″ | 1200 × 1600 | `ipad_13/preview/preview.mp4` |

Both are 20 seconds, H.264 High at 30 fps, with a silent stereo AAC track — the
simulator records no sound, and App Store Connect wants an audio track all the
same. The unconverted recording sits beside each as `raw.mov`.

Upload the `.mp4` in App Store Connect beside the screenshots, where it plays
before them. Pick the poster frame there; the listing's is the orchard with eight
of its twelve pieces down, about 4.5 seconds in.

To change what the video shows, change the reel: the boards, the pieces and the
beats are all in `PreviewReel`, and `PuzzleGameTests` checks the pieces it lays
still close each board's best pen. The one thing on the listing's video the reel
does not do is the grey circle a hand recording shows under each tap. Anything the reel cannot do — a real finger dragging a run of
fence, say — is still a recording made by hand, the same way: run the app on a
6.9″ simulator or a device, record with `xcrun simctl io <udid> recordVideo
preview.mov` or QuickTime, and trim to 15–30 seconds.
