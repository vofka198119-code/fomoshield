# macOS Dev Environment Setup — F.O.M.O. Shield

One-time setup for a fresh Mac to build/run this project (Android + iOS)
and use Claude Code the same way it's used on the Windows machine. Written
2026-08-19 during the Windows → Mac migration — verify tool versions are
still current if this is read much later.

## 1. Core tools to install

- **Xcode** (App Store) — required for any iOS build/simulator.
- **Xcode Command Line Tools**: `xcode-select --install`
- **Homebrew**: https://brew.sh
- **Flutter SDK** — the Windows machine runs `3.44.1 • stable` channel,
  not pinned via fvm/`.tool-versions` in this repo (nothing to match
  exactly, just use current stable). Install via the official installer
  (https://docs.flutter.dev/get-started/install/macos) or
  `brew install --cask flutter`.
- **CocoaPods**: `brew install cocoapods` (or `sudo gem install cocoapods`
  if Homebrew's Ruby conflicts).
- **Java 17**: `brew install openjdk@17` — Android Gradle build needs this
  exact major version (`sourceCompatibility`/`targetCompatibility` are
  pinned to `JavaVersion.VERSION_17` in `android/app/build.gradle.kts`).
- **Android SDK** — via Android Studio (https://developer.android.com/studio)
  or `brew install --cask android-studio`, then run
  `flutter doctor --android-licenses` to accept licenses.
- **VS Code** + extensions: **Claude Code**, **Flutter**, **Dart**.

Run `flutter doctor -v` after installing everything and resolve anything
it flags before proceeding.

## 2. Clone the repo

```bash
git clone https://github.com/vofka198119-code/fomoshield.git
cd fomoshield
```

## 3. Wire up the tracked git hooks (one-time)

```bash
git config core.hooksPath .githooks
```

This points git at `.githooks/pre-commit` (tracked in the repo, added
2026-08-19), which auto-bumps `pubspec.yaml`'s build number (`1.0.0+N`)
on every commit. Without this step, commits from the Mac won't bump the
build number — App Store/Play Store both require it to strictly increase.

## 4. Secrets — NOT in git, copy manually from the Windows machine

`.env` (repo root) is gitignored and must be copied over by hand (AirDrop,
USB, password manager — not committed, not sent through Claude). It needs
exactly these 3 keys (values live on the Windows machine's `.env`):

```
FINNHUB_API_KEY=
BACKEND_BASE_URL=
BACKEND_API_KEY=
```

## 5. Firebase config

- **Android**: `android/app/google-services.json` is already committed —
  nothing to do.
- **iOS**: `ios/Runner/GoogleService-Info.plist` does **not exist yet** in
  this repo — an iOS app was likely never registered in the Firebase
  project. Before the first iOS build that touches Firebase (Crashlytics
  is wired up per `pubspec.yaml`), register an iOS app in the Firebase
  console for bundle ID `com.scanco.scanco`, download
  `GoogleService-Info.plist`, and add it to `ios/Runner/` in Xcode (not
  just the filesystem — it needs to be added to the Xcode project so it's
  bundled). **Flag this to the user before attempting it** — it's a
  Firebase-console action, not something to do unprompted.

## 6. Apple signing (first iOS build only)

- Needs an Apple Developer account added in Xcode → Settings → Accounts.
- Bundle ID: `com.scanco.scanco`, minimum iOS version: 13.0 (from
  `IPHONEOS_DEPLOYMENT_TARGET` in `Runner.xcodeproj`).
- Opening `ios/Runner.xcworkspace` in Xcode for the first time will
  surface signing errors — Xcode's "Signing & Capabilities" tab has an
  "Automatically manage signing" option that resolves most of this once
  a team is selected.

## 7. Get dependencies + generate code

```bash
flutter pub get
flutter gen-l10n          # regenerates lib/src/l10n/gen/ from the .arb files
cd ios && pod install && cd ..   # first iOS build only
```

## 8. Verify the setup

```bash
flutter doctor
flutter analyze
flutter devices           # should list any connected phone/simulator
```

## Known gaps as of 2026-08-19 (not yet resolved on Windows either)

- No iOS `GoogleService-Info.plist` (see §5) — iOS Firebase features will
  not build until this is added.
- iOS side of the nav/status-bar transparency fix was never attempted —
  see the project memory
  `project_fomo_shield_navbar_transparency_fix_2026_08_18` (Windows-side
  memory store, not in this repo) for the Android investigation to use as
  a reference point.
- iOS side of Google Sign-In was deferred pending a Mac — see
  `project_fomo_shield_google_signin_and_buy_sell_swap_2026_08_10`.
