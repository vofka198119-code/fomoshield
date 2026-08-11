# Auto-Update — Overview

> **Feature branch**: `feature/auto-update`
> **Status**: ✅ Implemented
> **Last updated**: 2026-08-11

## What

Self-hosted auto-update that checks GitHub Releases for newer versions, downloads the APK (Android) or redirects to the release page (iOS), and triggers the OS installer. No Play Store, no backend changes.

## Why

FOMO Shield is distributed as manual `.apk` installs — no Google Play Store access. Users need a way to discover and install new versions without manually checking the repo.

## How (TL;DR)

```
App startup (5s delay) → UpdateDialog opens (CHECKING spinner)
  ├─ GitHub API call (inside dialog)
  ├─ Up to date → UP_TO_DATE (✓ checkmark) → auto-dismiss 1.5s
  └─ Newer found → INFO state → user taps action
       ├─ Android: Download APK → Progress → FileProvider → Installer
       └─ iOS: "View on GitHub" → Safari opens release page
```

CI/CD: Push to `main` → auto-tag `v1.0.0-dev.{run_number}` → GitHub Actions builds APK + IPA → release created. No manual steps.

## Files

| File | Purpose |
|------|---------|
| `README.md` | This overview |
| `architecture.md` | Architecture decisions, auth flow, data flow |
| `implementation-plan.md` | Step-by-step implementation (10 steps) |
| `security.md` | PAT token scope and risk analysis |
| `ci-cd.md` | GitHub Actions release workflow |
| `platform-notes.md` | Android vs iOS differences |

## Key Decisions

- **Fine-grained PAT** with `Contents: Read` on this repo only — injected at build time via `--dart-define`
- **No backend changes** — pure GitHub API
- **5-second startup delay** — non-intrusive, per Product Constitution
- **Dismissible dialog** — no forced updates, no pressure
- **5-state dialog**: CHECKING → UP_TO_DATE (auto-dismiss) or CHECKING → INFO → DOWNLOADING → READY
- **Android**: in-app APK download with progress bar + install
- **iOS**: redirect to GitHub release page (no IPA sideload without MDM)

## Prerequisites

1. Create fine-grained GitHub PAT (Contents: Read, this repo only)
2. Store as repo secret `RELEASE_READ_TOKEN`
3. Dependencies added: `package_info_plus`, `path_provider`, `open_filex`
