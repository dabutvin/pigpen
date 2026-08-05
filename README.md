# Pigpen

An iOS puzzle game about trapping a pig. You get a grid, a pig, and a strict number of
fence pieces. Pen the pig in — and pen in as much mud as you can while you are at it.

## The Game

- **The pig** starts on a fixed tile and walks up, down, left or right, never diagonally.
- **Fences** fill in whole tiles. Tap a tile to wall it off; the pig cannot walk through it.
  Press and drag to lay a whole run at once — starting the drag on a fence tears out
  everything you drag over instead. You have a fixed budget of pieces per puzzle. Corners
  cost nothing, since a pig cannot cut across one.
- **Undo and redo** walk back and forth through the field a press at a time, so a drag laid
  in the wrong place comes out in one go rather than tile by tile. Clearing the field is a
  press like any other and one undo brings the whole thing back. Laying a new piece gives up
  whatever was waiting to be redone.
- **Water** — rivers and lakes — is a permanent boundary the pig cannot cross. You cannot
  build on it and you never need to: it walls the pen for free. Build against it instead of
  spending fences.
- **Escape.** Release the pig and it tries every route. If a single gap leads to the edge
  of the map, it walks out and the attempt fails.
- **A pen that closes colours itself in.** The moment the last gap is filled, the ground the
  fencing holds washes gold, so you can see the pen you have made before you commit to it.
  Releasing the pig is still yours to do — the wash only says the pig has nowhere to go.
  Take a piece back out and the wash goes with it.
- **The biggest pen the map has in it goes rainbow.** A pen that big drifts through the
  spectrum instead of sitting gold, from the moment you close it. There is nothing above it
  to aim for.
- **Score.** The mud tiles inside a pen that holds. Four pieces boxed in around the pig
  always work and score 1, so the puzzle is not whether you can pen it but how much ground
  you can take with the same budget. A pen that holds invites you back out to widen it —
  until it is the biggest pen the map has in it, which the game knows and says so.
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
walks off it. That 35 is the level's `maximumArea`, and the pen it goes rainbow for. Special
tiles (cupcakes, frying pans) come next.

## The World

Play opens **Mudlark Meadow**: six puzzles as six signposts up one winding trail, with the
pig standing at the furthest one it has reached and mist over everything past that.

- **Beating a level opens the next one.** Any pen at all is enough — one star will do it.
- **The pig walks there.** Come back from a level you have just beaten and it sets off up
  a length of trail that was not there before, the map scrolling along behind it, and the
  mist pulls back off the signpost it arrives at.
- **Stars stay on the signpost.** Each one shows the best you have ever done there, so a
  level replayed badly costs you nothing and a level replayed well is worth going back for.
- **You can go back down the trail** to any level already open, and the pig trots down to
  it before the puzzle opens.

| # | Level | Pieces | Biggest pen |
|---|---|---|---|
| 1 | River Bend | 12 | 35 |
| 2 | Puddle Corner | 8 | 26 |
| 3 | Horseshoe Lake | 6 | 24 |
| 4 | The Narrows | 10 | 22 |
| 5 | Otter Ford | 12 | 24 |
| 6 | The Big Meadow | 16 | 33 |

"Biggest pen" is the most mud that budget can shut a pig into on that map: the level's
`maximumArea`, the number the third star is set just under, and the pen each level goes
rainbow for. It is a search rather than a sum — `Tools/level_search.py` does the searching,
and a test pins every one of them to a pen that actually holds, so no level can promise a
rainbow that is not there.

The wordmark on the title screen is written in the
[pigpen cipher](https://en.wikipedia.org/wiki/Pigpen_cipher), whose glyphs happen to look
a lot like fence posts. It plants itself one glyph at a time over a pasture — drifting
clouds by day, fireflies at dusk — with a pig trotting up and down a run of fence. The
whole backdrop is drawn in code from one clock and stops dead when the system asks for
reduced motion.

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

A level is an ASCII map and four numbers: the fence budget, the areas the second and third stars are worth, and `maximumArea` — the biggest pen the map and that budget allow. The first three are a judgement call. The last one is not, and getting it wrong either withholds the "biggest pen there is" verdict forever or hands it out for a pen that could still be widened. `Tools/level_search.py` works it out:

```bash
Tools/level_search.py --budget 12 <<'MAP'
.........
~~~~~~~..
..P...~..
.........
MAP
```

It prints the best pen it found, marked out on the map, along with `maximumArea` and star thresholds in the proportions the shipped levels use. Add the level to `PuzzleLevel`, hang it on the trail in `WorldMap.mudlarkMeadow`, and add its plan — the printed `#` tiles — to `shipped` in `PuzzleLevelTests`, which replays the pen and fails if the level stops giving up what it claims.

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
| `screenshots.yml` | PR to main | Build, boot a simulator, capture the title screen and the board in light + dark, post/update a PR comment |
| `testflight.yml` | Push to main | Archive, sign, upload to TestFlight |
| `release.yml` | Tag `v*.*.*` | Archive with the tag's version, submit to App Store Connect, cut a GitHub Release |
| `signing-setup.yml` | Manual | Create, list or revoke the signing certificate and profile over the App Store Connect API |

Notes on the details:

- **Signing.** Runners are wiped after every job, so `testflight.yml` and `release.yml` import a distribution certificate and App Store profile into a throwaway keychain (`.github/actions/setup-signing`) and archive with `CODE_SIGN_STYLE=Manual`. They deliberately do *not* pass `-allowProvisioningUpdates`: with an empty keychain that flag makes Xcode ask Apple for a **brand new certificate on every run** and abandon it, so after a handful of builds the account hits its certificate limit and every archive fails with "Your account has reached the maximum number of certificates." Where the certificate comes from is covered under [Signing](#signing) below.
- **Versioning.** `MARKETING_VERSION` lives in `project.yml`; the build number is a `YYYYMMDDHHMM` timestamp injected at archive time, so it always increases. A release tag overrides the marketing version, so `v0.2.0` ships as version `0.2.0`.
- **Screenshots.** The PR screenshot images are committed to an orphan-ish `ci-screenshots` branch under `pr-<number>/` and hot-linked into a single PR comment that gets updated in place on each push. That branch is CI-only — never merge it. Files are named `<order>_<screen>_<light|dark>.png`, and each screen gets its own row in the comment. The app takes `-map` and `-puzzle` launch arguments so the world map and the board can be captured without tapping through the title screen; both open part way through, since an untouched world has nothing on it to look at and an untouched field has no fencing and not a control on it lit.
- **Concurrency.** CI and screenshots cancel superseded runs per branch. Everything that signs shares one `apple-signing` group and never cancels, so two merges in quick succession both ship, one after the other, and no two runs touch the account's certificates at the same time.
- **Doc-only changes.** Pushes that only touch `*.md` or `.gitignore` skip the TestFlight workflow.

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
│   ├── PuzzleLevel.swift        # Terrain, pig start, budget, and every shipped map
│   ├── PenOutcome.swift         # Releases the pig: escape route, or the pen it is stuck in
│   ├── PuzzleGame.swift         # Observable state for one puzzle in progress
│   ├── WorldMap.swift           # The levels of a world and where their signposts stand
│   ├── WorldProgress.swift      # Best stars per level, what that unlocks, and where it is kept
│   └── PigpenGlyph.swift        # Cipher letter → drawable geometry, for the wordmark
├── Views/
│   ├── TitleScreenView.swift    # Start screen
│   ├── TitleSceneView.swift     # The animated pasture behind the title
│   ├── WorldMapView.swift       # The world map: signposts, the walking pig, the trail
│   ├── WorldMapScene.swift      # The meadow the trail runs through
│   ├── WorldTrail.swift         # Stops ↔ points on screen, and the curve between them
│   ├── LevelSignpost.swift      # One stop on the map: stars, number, name
│   ├── PuzzleView.swift         # A puzzle end to end: build, release, verdict
│   ├── FieldView.swift          # Draws the field and turns taps into fenced tiles
│   ├── BoardGeometry.swift      # Tiles ↔ points on screen
│   ├── ChunkyButtonStyle.swift  # The wooden button the title screen is built on
│   ├── GamePalette.swift        # Colours, including the pasture's day and dusk sets
│   ├── Scatter.swift            # The seeded generator every drawn scene scatters things with
│   └── PigpenGlyphView.swift    # Renders glyphs and words
└── Resources/
    ├── Assets.xcassets          # App icon, accent color
    └── Pigpen.entitlements
PigpenTests/                     # Unit tests
Tools/
├── generate_app_icon.py         # Redraws the app icon PNGs
├── level_search.py              # Finds the biggest pen a map and budget allow
├── bootstrap_signing.py         # Creates/lists/revokes the signing certificate over the API
└── prepare_signing_secrets.sh   # Checks and encodes a certificate exported from a Mac
```

The model layer is plain Swift with no UI imports, so all of the game rules — escape
detection, water boundaries, budgets, scoring — are covered by unit tests.

## License

MIT
