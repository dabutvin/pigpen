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
| CI/CD | GitHub Actions + Apple cloud signing |
| Distribution | TestFlight + App Store |

## Development

### Prerequisites

- Xcode 26+ (for local dev) or just use GitHub Actions (no laptop needed)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

### Build locally

```bash
xcodegen generate
open Pigpen.xcodeproj
```

`Pigpen.xcodeproj` and `Pigpen/Resources/Info.plist` are both generated from `project.yml` and are gitignored — edit `project.yml`, never the generated project.

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
| `screenshots.yml` | PR to main | Build, boot a simulator, capture light + dark screenshots, post/update a PR comment |
| `testflight.yml` | Push to main | Archive, cloud-sign, upload to TestFlight |
| `release.yml` | Tag `v*.*.*` | Archive with the tag's version, submit to App Store Connect, cut a GitHub Release |

Notes on the details:

- **Versioning.** `MARKETING_VERSION` lives in `project.yml`; the build number is a `YYYYMMDDHHMM` timestamp injected at archive time, so it always increases. A release tag overrides the marketing version, so `v0.2.0` ships as version `0.2.0`.
- **Screenshots.** The PR screenshot images are committed to an orphan-ish `ci-screenshots` branch under `pr-<number>/` and hot-linked into a single PR comment that gets updated in place on each push. That branch is CI-only — never merge it.
- **Concurrency.** CI and screenshots cancel superseded runs per branch. TestFlight uploads never cancel each other, so two merges in quick succession both ship.
- **Doc-only changes.** Pushes that only touch `*.md` or `.gitignore` skip the TestFlight workflow.

### Cutting a release

```bash
git tag v0.2.0
git push origin v0.2.0
```

## Required Secrets

Uses **Apple cloud-managed signing** — no certificates or provisioning profiles to manage. Just an API key.

Set these in GitHub repo settings → Secrets and variables → Actions:

| Secret | Purpose | How to get it |
|---|---|---|
| `TEAM_ID` | Apple Developer Team ID | developer.apple.com → Membership |
| `APP_STORE_CONNECT_API_KEY_ID` | API key ID | App Store Connect → Users and Access → Integrations → Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | Same page as above |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | API key (`.p8` file contents), **raw text** | Paste the full text including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` |

That's it — 4 secrets, all plain text. Apple handles certificates and provisioning profiles in the cloud.

The App Store Connect app record must exist with bundle ID `com.pigpen.app` (see `project.yml`) before the first TestFlight upload.

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
│   ├── GamePalette.swift        # Colours
│   └── PigpenGlyphView.swift    # Renders glyphs and words
└── Resources/
    ├── Assets.xcassets          # App icon, accent color
    └── Pigpen.entitlements
PigpenTests/                     # Unit tests
```

The model layer is plain Swift with no UI imports, so all of the game rules — escape
detection, water boundaries, budgets, scoring — are covered by unit tests.

## License

MIT
