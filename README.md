# Pigpen

An iOS game built around the [pigpen cipher](https://en.wikipedia.org/wiki/Pigpen_cipher) — the tic-tac-toe-and-X alphabet you scribbled in notebooks as a kid.

Right now the app is a single static title screen. Game mechanics come next.

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
| `ci.yml` | PR to main, push to main | Build for simulator, no signing |
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
│   └── PigpenGlyph.swift        # Cipher letter → drawable geometry
├── Views/
│   ├── TitleScreenView.swift    # The static start screen
│   └── PigpenGlyphView.swift    # Renders glyphs and words
└── Resources/
    ├── Assets.xcassets          # App icon, accent color
    └── Pigpen.entitlements
PigpenTests/                     # Unit tests
```

## License

MIT
