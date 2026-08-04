# Pigpen

An iOS puzzle game about trapping a pig. You get a grid, a pig, and a strict number of
fence pieces. Pen the pig in — and pen in as much mud as you can while you are at it.

## The Game

- **The pig** starts on a fixed tile and walks up, down, left or right, never diagonally.
- **Fences** go on the lines between tiles. You have a fixed budget of pieces per puzzle.
- **Water** — rivers and lakes — is a permanent boundary that neither the pig nor a fence
  can cross, and it costs nothing. Build against it instead of spending fences.
- **Escape.** Release the pig and it tries every route. If a single gap leads to the edge
  of the map, it walks out and the attempt fails.
- **Score.** The mud tiles inside a pen that holds. A four-piece box around the pig always
  works and scores 1, so the puzzle is not whether you can pen it but how much ground you
  can take with the same budget.

The one puzzle so far, **River Bend**, hands you 16 fence pieces. A free-standing box that
size holds 16 tiles; hugging the river and the pond holds 49, which is the most those 16
pieces can ever enclose. Special tiles (cupcakes, frying pans) and more puzzles come next.

The wordmark on the title screen is written in the
[pigpen cipher](https://en.wikipedia.org/wiki/Pigpen_cipher), whose glyphs happen to look
a lot like fence posts.

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

- Xcode 26+ (for local dev) or just use GitHub Actions (no laptop needed, once the [one-time signing setup](#one-time-signing-setup) is done)
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

Notes on the details:

- **Signing.** Runners are wiped after every job, so `testflight.yml` and `release.yml` import one long-lived distribution certificate and one App Store provisioning profile from secrets into a throwaway keychain (`.github/actions/setup-signing`) and archive with `CODE_SIGN_STYLE=Manual`. They deliberately do *not* pass `-allowProvisioningUpdates`: with an empty keychain that flag makes Xcode ask Apple for a **brand new certificate on every run**, and after a handful of builds the account hits its certificate limit and every archive fails with "Your account has reached the maximum number of certificates."
- **Versioning.** `MARKETING_VERSION` lives in `project.yml`; the build number is a `YYYYMMDDHHMM` timestamp injected at archive time, so it always increases. A release tag overrides the marketing version, so `v0.2.0` ships as version `0.2.0`.
- **Screenshots.** The PR screenshot images are committed to an orphan-ish `ci-screenshots` branch under `pr-<number>/` and hot-linked into a single PR comment that gets updated in place on each push. That branch is CI-only — never merge it. Files are named `<order>_<screen>_<light|dark>.png`, and each screen gets its own row in the comment. The app takes a `-puzzle` launch argument so the board can be captured without tapping through the title screen.
- **Concurrency.** CI and screenshots cancel superseded runs per branch. TestFlight uploads never cancel each other, so two merges in quick succession both ship.
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
| `APPLE_DISTRIBUTION_CERT_P12` | Apple Distribution certificate **and its private key**, base64 | One-time setup below |
| `APPLE_DISTRIBUTION_CERT_PASSWORD` | Password the `.p12` was exported with | You choose it during the export |
| `APPLE_PROVISIONING_PROFILE` | App Store provisioning profile for `com.pigpen.app`, base64 | One-time setup below |

The App Store Connect app record must exist with bundle ID `com.pigpen.app` (see `project.yml`) before the first TestFlight upload.

### One-time signing setup

A distribution certificate's private key only exists on the machine that created it, and Apple caps each account at a couple of them. So the certificate has to be created once, by hand, and then handed to CI — which is what the three `APPLE_*` secrets are for.

1. **Certificate.** In Xcode → Settings → Accounts, select the team, click *Manage Certificates*, then `+` → *Apple Distribution*. (Or make a CSR in Keychain Access and upload it at developer.apple.com → Certificates.) If your team already has one and its key is on another Mac, export it from there instead of making a new one — Apple will refuse once you are at the limit.
2. **Export it.** Keychain Access → *My Certificates* → right-click the `Apple Distribution: …` row → *Export*, save as `.p12`, and set a password. Expanding the row must show a private key; if it does not, this Mac does not have the key and the export is useless.
3. **Profile.** developer.apple.com → Profiles → `+` → *App Store Connect* → App ID `com.pigpen.app` → pick the certificate from step 1 → download the `.mobileprovision`.
4. **Check and encode them**, which also verifies the profile was actually issued for that certificate:

```bash
Tools/prepare_signing_secrets.sh ~/Downloads/Certificates.p12 ~/Downloads/Pigpen_AppStore.mobileprovision
```

5. Set the three secrets with the `gh secret set` commands it prints, delete the generated `.signing-secrets/` directory, and keep the `.p12` and its password somewhere safe — it is the only copy of the private key.

Both files expire (the certificate after a year, the profile after a year), so this repeats at renewal time. Nothing in the build creates or renews them on its own, which is the point: a build that cannot sign fails loudly instead of quietly burning through the account's certificate allowance.

Already over the limit? Go to developer.apple.com → Certificates and revoke the stray ones — keep only the certificate whose `.p12` you hold — then re-run the workflow.

Local builds are unaffected: `project.yml` keeps `CODE_SIGN_STYLE: Automatic`, so Xcode signs with your personal team, and only the release workflows override it with the shared identity.

## Project Structure

```
Pigpen/
├── App/
│   └── PigpenApp.swift          # App entry point
├── Models/
│   ├── GridPoint.swift          # Tile coordinates and the four directions
│   ├── Fence.swift              # A fence piece: one line between two tiles
│   ├── PuzzleLevel.swift        # Terrain, pig start, budget, and the shipped map
│   ├── PenOutcome.swift         # Releases the pig: escape route, or the pen it is stuck in
│   ├── PuzzleGame.swift         # Observable state for one puzzle in progress
│   └── PigpenGlyph.swift        # Cipher letter → drawable geometry, for the wordmark
├── Views/
│   ├── TitleScreenView.swift    # Start screen
│   ├── PuzzleView.swift         # A puzzle end to end: build, release, verdict
│   ├── FieldView.swift          # Draws the field and turns taps into fence lines
│   ├── BoardGeometry.swift      # Tiles and fence lines ↔ points on screen
│   ├── GamePalette.swift        # Colours
│   └── PigpenGlyphView.swift    # Renders glyphs and words
└── Resources/
    ├── Assets.xcassets          # App icon, accent color
    └── Pigpen.entitlements
PigpenTests/                     # Unit tests
Tools/
├── generate_app_icon.py         # Redraws the app icon PNGs
└── prepare_signing_secrets.sh   # Checks and encodes the signing secrets, once
```

The model layer is plain Swift with no UI imports, so all of the game rules — escape
detection, water boundaries, budgets, scoring — are covered by unit tests.

## License

MIT
