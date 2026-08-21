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
   set to the usual 9:41;
2. shoots five screens on each — the title, a board mid-solve, the universe map,
   the archive and a boss board — off the same launch arguments the PR
   screenshots use;
3. frames each one with a line of copy through `Tools/appstore_frames.py`;
4. uploads a single **appstore-assets** artifact holding, per device, the `raw`
   shots and the `framed` ones.

Download the artifact, and upload the `framed` PNGs to App Store Connect →
your app → the version → Media Manager, in numbered order. The `raw` ones are
there if you would rather submit bare shots or reframe them by hand.

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

## App previews (the video)

Apple does not take a rendered video the way it takes a rendered screenshot: a
preview has to be **screen-recorded from the app**, 15–30 seconds, portrait, at
the same device sizes as the screenshots. There is nothing to automate here that
Apple will accept, so it is recorded by hand:

1. Run the app on a **6.9″ iPhone simulator** (or a real device), and record with
   `xcrun simctl io <udid> recordVideo preview.mov` — or QuickTime → New Screen
   Recording against a plugged-in device.
2. Play a short, legible run: open a board, lay a few fences, close the pen, let
   the pig settle. Keep it slow enough to read.
3. Trim to 15–30 seconds and upload the `.mov` in App Store Connect beside the
   screenshots. Up to three per size; the first frame is the poster, so end (or
   start) on the title.

A preview is optional. The framed screenshots above carry the listing on their
own until there is one.
