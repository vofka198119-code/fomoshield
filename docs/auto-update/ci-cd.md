# CI/CD — GitHub Actions Release Pipeline

## Workflow: `.github/workflows/release.yml`

**Triggers**:
- **Push to `main`** → auto dev release: `v{version}-dev.{run_number}` (pre-release)
- **Push tag `v*`** → stable release: `v1.0.1` (full release)

No manual tagging needed day-to-day. Developer just `git push`. Tester reopens the app.

**Jobs** (version → parallel builds → release):

```
┌─────────────────────────┐
│        version          │
│     ubuntu-latest       │
│                         │
│  reads pubspec.yaml     │
│  sets tag + prerelease  │
└───────────┬─────────────┘
            │
    ┌───────┴───────┐
    ▼               ▼
┌────────────┐  ┌────────────┐
│    APK     │  │    IPA     │
│ ubuntu     │  │  macos     │
│            │  │            │
│ pub get    │  │ pub get    │
│ build apk  │  │ build ios  │
│ upload     │  │ zip → .ipa │
└─────┬──────┘  │ upload     │
      │         └─────┬──────┘
      │   ┌───────────┘
      ▼   ▼
┌──────────────────────────┐
│        release           │
│     ubuntu-latest        │
│                          │
│  download both artifacts │
│  auto-create tag         │
│  create GitHub Release   │
│  attach APK + IPA        │
│  auto-generate notes     │
└──────────────────────────┘
```

## Job Details

### `version`

| Step | Tool | Notes |
|------|------|-------|
| Checkout | `actions/checkout@v4` | |
| Set version | bash inline | Reads `pubspec.yaml`, extracts `SEMVER`. On tag push → uses tag name. On main push → generates `v{SEMVER}-dev.{run_number}`. Sets `tag` and `prerelease` outputs. |

```
Main push:  pubspec.yaml "1.0.0+1" → tag=v1.0.0-dev.47   prerelease=true
Tag push:   git tag v1.0.1         → tag=v1.0.1           prerelease=false
```

### `build-android` (APK)

| Step | Tool | Notes |
|------|------|-------|
| Checkout | `actions/checkout@v4` | |
| Setup Flutter | `subosito/flutter-action@v2` | Stable channel, Flutter 3.x |
| Dependencies | `flutter pub get` | |
| Build | `flutter build apk --release --dart-define=GITHUB_TOKEN=${{ secrets.RELEASE_READ_TOKEN }}` | Token injected here |
| Upload | `actions/upload-artifact@v4` → `apk` | Path: `build/app/outputs/flutter-apk/app-release.apk` |

### `build-ios` (IPA)

| Step | Tool | Notes |
|------|------|-------|
| Checkout | `actions/checkout@v4` | |
| Setup Flutter | `subosito/flutter-action@v2` | Requires `macos-latest` runner |
| Dependencies | `flutter pub get` | |
| Build | `flutter build ios --release --no-codesign --dart-define=GITHUB_TOKEN=${{ secrets.RELEASE_READ_TOKEN }}` | `--no-codesign` since no Apple certs in CI |
| Package | `mkdir Payload && cp -r Runner.app Payload/ && zip -r app-release.ipa Payload` | Manual IPA packaging |
| Upload | `actions/upload-artifact@v4` → `ipa` | |

> ⚠️ **iOS PSA**: This produces an **unsigned** IPA. It can't be installed without MDM/enterprise distribution or manual re-signing. The IPA is attached to the release primarily for archival and for users who have their own signing setup.

### `release`

| Step | Tool | Notes |
|------|------|-------|
| Download APK | `actions/download-artifact@v4` | Fetches `apk` |
| Download IPA | `actions/download-artifact@v4` | Fetches `ipa` |
| Create Release | `softprops/action-gh-release@v2` | `tag_name`, `name`, `prerelease`, `files`, `generate_release_notes: true` |

The `softprops/action-gh-release` action **auto-creates a lightweight git tag** if the tag doesn't already exist. No infinite loop — GitHub Actions ignores recursive triggers from `GITHUB_TOKEN`.

## Release Naming Convention

```
Main push (auto dev):
  Tag:    v1.0.0-dev.47
  Release: v1.0.0-dev.47   (pre-release ✅)
  Assets:
    ├── app-release.apk
    └── app-release.ipa

Tag push (stable):
  Tag:    v1.0.1
  Release: v1.0.1          (full release)
  Assets:
    ├── app-release.apk
    └── app-release.ipa
```

The `UpdateService` checks `/releases?per_page=5` (including pre-releases), strips the `v` prefix, and compares semver with pre-release suffix handling.

## How to Release

### Daily development (auto)

```bash
# Just push — that's it.
git add .
git commit -m "fix: improve error handling"
git push origin main

# GitHub Actions automatically:
#   → Reads pubspec.yaml version
#   → Tags as v1.0.0-dev.48
#   → Builds APK + IPA
#   → Creates pre-release with both assets
#   → Tester reopens app → auto-update kicks in
```

### Stable release (manual, when shipping)

```bash
# 1. Bump version in pubspec.yaml
#    version: 1.0.0+1  →  version: 1.0.1+2

# 2. Commit & push
git add pubspec.yaml
git commit -m "Release v1.0.1"
git push origin main

# 3. Tag & push (triggers stable release)
git tag v1.0.1
git push origin v1.0.1

# GitHub Actions automatically:
#   → Builds APK + IPA
#   → Creates full release (not pre-release)
#   → All users get the stable update
```

## Permissions

```yaml
permissions:
  contents: write  # Required for softprops/action-gh-release to create releases + auto-tag
```

This is repo-level (not org-level) — only affects the `fomoshield` repo.

## Dependencies

| Action | Version | Purpose |
|--------|---------|---------|
| `actions/checkout` | v4 | Clone repo |
| `subosito/flutter-action` | v2 | Install Flutter SDK |
| `actions/upload-artifact` | v4 | Pass APK/IPA between jobs |
| `actions/download-artifact` | v4 | Retrieve artifacts in release job |
| `softprops/action-gh-release` | v2 | Create GitHub Release + attach files + auto-tag |

All are well-maintained, widely-used actions with 10k+ stars.

## Estimated Run Time

| Job | Estimated Duration |
|-----|-------------------|
| `version` | ~15 seconds |
| `build-android` (APK) | ~5 minutes |
| `build-ios` (IPA) | ~10 minutes (macOS runners are slower to provision) |
| `release` | ~30 seconds |
| **Total** | **~12 minutes** |

## Cost

- **Public repo**: Free (GitHub Actions included minutes for public repos)
- **Private repo**: Consumes Actions minutes from the free tier (2,000 min/month for private repos)

Each release: ~12 macOS minutes + ~5 Linux minutes ≈ 17 real minutes. macOS minutes count 10×: ~105 billable minutes. Private repo free tier allows ~19 releases/month on macOS runners. Consider reducing iOS build frequency by splitting the workflow or using conditional builds.
