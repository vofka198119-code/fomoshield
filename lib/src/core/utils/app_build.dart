/// Build number override injected by CI via `--dart-define=APP_BUILD=...`
/// (the GitHub Actions run number), so that installed builds and release tags
/// (`v1.0.0-dev.{run_number}`) share one comparable build number.
///
/// Empty string when built locally without the dart-define — callers then
/// fall back to the build number baked into pubspec (`version: 1.0.0+24`).
const String kAppBuildOverride = String.fromEnvironment('APP_BUILD');

/// Pre-release label injected by CI via `--dart-define=APP_LABEL=...`
/// (derived from the source branch: `main`, `dev`, or a sanitized branch name).
/// Lets the updater honor branch precedence: stable > main > dev > other > 0.
///
/// Empty string when built locally without the dart-define — the updater then
/// falls back to comparing by build number only.
const String kAppLabelOverride = String.fromEnvironment('APP_LABEL');
