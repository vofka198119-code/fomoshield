# Architecture

## High-Level Flow

```mermaid
sequenceDiagram
    participant App as FOMO Shield App
    participant GH as GitHub API
    participant FS as File System
    participant OS as Android Installer

    Note over App: 5s after startup
    App->>GH: GET /repos/vofka198119-code/fomoshield/releases?per_page=5
    Note over App,GH: Authorization: Bearer &lt;PAT&gt;
    GH-->>App: [{ tag_name, assets[], body }, ...]
    Note over App: Iterates releases, picks newest that &gt; current
    
    alt Up to date
        App->>App: No action
    else New version (Android)
        App->>App: Show UpdateDialog
        App->>GH: GET {asset.browser_download_url}
        GH-->>App: APK binary stream
        App->>FS: Write to cache/apk/update.apk
        App->>OS: Intent.ACTION_VIEW (FileProvider URI)
        OS-->>App: Installer opens
    else New version (iOS)
        App->>App: Show UpdateDialog ("View on GitHub")
        App->>App: url_launcher → Safari → release page
    end
```

## Auth Strategy

```
┌─────────────────────────────────────────────┐
│ GitHub Repo Secrets & Variables              │
│ RELEASE_READ_TOKEN = ghp_xxxxxxxxxxxx        │
└─────────────────┬───────────────────────────┘
                  │ ${{ secrets.RELEASE_READ_TOKEN }}
                  ▼
┌─────────────────────────────────────────────┐
│ GitHub Actions (.github/workflows/release.yml)│
│ flutter build apk --release                  │
│   --dart-define=GITHUB_TOKEN=${TOKEN}        │
└─────────────────┬───────────────────────────┘
                  │ compiled into app binary
                  ▼
┌─────────────────────────────────────────────┐
│ FOMO Shield App                              │
│ const token = String.fromEnvironment(        │
│   'GITHUB_TOKEN'                             │
│ );                                           │
│ dio.options.headers['Authorization'] =       │
│   'Bearer $token';                           │
└─────────────────────────────────────────────┘
```

**Token scope**: Fine-grained PAT → `vofka198119-code/fomoshield` only → `Contents: Read-only`

**Why this is acceptable**: Even if extracted from the APK, the token can only:
- Read repository contents (already public via APK)
- List releases (already available to app users)
- Cannot push, delete, or access any other repo

## Component Architecture

```
lib/src/
├── core/
│   ├── models/
│   │   └── update_info.dart          ← Data class
│   └── services/
│       └── update_service.dart       ← GitHub API (lists releases, compares semver) + APK download
└── features/
    └── update/
        └── update_dialog.dart        ← UI (5 states: checking→upToDate|info→downloading→ready)

Android:
├── app/src/main/
│   ├── AndroidManifest.xml           ← +REQUEST_INSTALL_PACKAGES + FileProvider
│   └── res/xml/
│       └── file_paths.xml            ← external-cache-path for APKs

Packages (new):
├── package_info_plus                 ← Runtime version reading
├── path_provider                     ← External cache directory for APK
└── open_filex                        ← Triggers Android installer via FileProvider
```

## Version Comparison Logic

```
Semver comparison: major.minor.patch
  - Strip leading 'v' from GitHub tag_name
  - Split both versions on '.'
  - Compare major → minor → patch
  - Return true if GitHub > local

Local version source: package_info_plus → PackageInfo.version
  - Android: versionName from build.gradle (from pubspec.yaml)
  - iOS: CFBundleShortVersionString (from pubspec.yaml)
```

## UpdateDialog State Machine

```
                        ┌──────────────────────────────────────────────────┐
                        │                                                  │
                        ▼                                                  │
┌──────────┐  API call  ┌────────────┐  no update   ┌────────────┐       │
│ CHECKING │ ────────► │  UP_TO_DATE │────────────► │ auto-dismiss│       │
│ spinner  │           │  ✓ latest   │              └────────────┘       │
│ "Checking│           └────────────┘                                     │
│  for     │                                                              │
│  updates"│  update found                                                │
└────┬─────┘────────────┐                                                 │
     │                  ▼                                                 │
     │            ┌──────────┐    "Download"    ┌──────────────┐          │
     │            │  INFO    │ ───────────────► │ DOWNLOADING  │          │
     │            │ v1.0.1   │                  │ progress bar │          │
     │            │ available│ ◄──────────────── │    XX%       │          │
     │            └──────────┘  cancel/dismiss   └──────┬───────┘          │
     │                                                  │                  │
     │                                    download complete                │
     │                                                  │                  │
     │                                                  ▼                  │
     │                                           ┌─────────┐              │
     │                                           │  READY  │              │
     │                                           │ Install │              │
     │                                           │ button  │              │
     │                                           └────┬────┘              │
     │                                                │                   │
     └──── dismiss (back / outside tap) ◄─────────────┘                   │
                                                                          │
     ─────── "Maybe Later" (dismiss from INFO) ─────► app continues       │
```

- **CHECKING**: Dialog opens with a spinning `CircularProgressIndicator` and "Checking for updates..." text. The GitHub API call is in-flight. Replaces the silent background check — user sees immediate feedback.
- **UP_TO_DATE**: Green checkmark + "You're on the latest version" → auto-dismisses after 1.5 seconds. Brief confirmation, no action needed.
- **INFO**: Shows version comparison + release notes + platform-appropriate CTA ("Download & Install" or "View on GitHub").
- **DOWNLOADING**: Dio `onReceiveProgress` drives determinate progress bar. Cancel button calls `CancelToken.cancel()`.
- **READY**: Android: triggers `Intent.ACTION_VIEW` with FileProvider content URI. iOS: never reaches this state (redirects from INFO).

## Startup Integration Point

```
main()
  → dotenv.load()
  → Supabase.initialize()
  → GoogleSignIn.initialize()
  → sectorRepositoryProvider.hydrateLiveCache()
  → runApp(ScanCoApp)
      └─ initState():
           ├─ Future.delayed(5s) → show UpdateDialog (CHECKING state)  ← NEW
           └─ Future.delayed(8s) → checkPendingOrders()                 ← existing
```

The dialog opens immediately in the CHECKING state (spinning indicator) — the GitHub API call happens inside the dialog. This replaces the previous "silent check" approach. The 5-second delay still applies to avoid interrupting the splash/home transition. The app is fully usable — the dialog is dismissible at any CHECKING/INFO state.

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No internet | CHECKING → UP_TO_DATE transition (silently treat as "up to date") |
| GitHub API down (5xx) | CHECKING → UP_TO_DATE transition |
| PAT invalid/expired (401) | CHECKING → UP_TO_DATE transition, log warning |
| Rate limited (403/429) | CHECKING → UP_TO_DATE transition, log warning |
| Download interrupted | CancelToken → reset to INFO state |
| Insufficient storage | FileSystemException → show error in dialog |
| APK parse error (Android) | Catch, show "Installation failed" message |
