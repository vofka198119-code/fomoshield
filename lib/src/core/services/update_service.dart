import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

import '../models/update_info.dart';
import '../utils/app_build.dart';

// ─── Provider ───────────────────────────────────────────────────────────────

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

// ─── Service ────────────────────────────────────────────────────────────────

/// Checks the PUBLIC releases repo for newer app versions and downloads APKs
/// (Android). The repo is public, so NO authentication/token is needed — the
/// updater works for anyone, and the private source repo is never exposed.
///
/// The public repo is a CI mirror: `.github/workflows/release.yml` publishes
/// the ScanCo.* binaries there (job `publish`).
class UpdateService {
  static const _baseUrl = 'https://api.github.com';

  /// Public binaries-only repo. Change here if the repo is named differently.
  static const _repo = 'vofka198119-code/fomoshield-releases';

  late final Dio _dio;

  UpdateService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ));

    // Debug logging (minimal).
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint('[UpdateService] $obj'),
    ));
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Returns [UpdateInfo] if a newer version exists on GitHub, else null.
  ///
  /// Checks the 5 most recent releases (including pre-releases) so dev
  /// builds pushed on every main commit are detected alongside stable tags.
  ///
  /// Fails silently on any error — never blocks the user.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"
      // Build-aware: prefer the CI run number injected via APP_BUILD, else the
      // pubspec build number. Lets us skip releases we're already on.
      final currentBuild = int.tryParse(
            kAppBuildOverride.isNotEmpty
                ? kAppBuildOverride
                : packageInfo.buildNumber,
          ) ??
          0;
      // Branch label of the installed build (APP_LABEL), used to honor
      // precedence: stable > main > dev > other. Empty on old/local builds.
      final installedLabel = kAppLabelOverride;

      // Use /releases (not /releases/latest) to include pre-releases.
      final response = await _dio.get('/repos/$_repo/releases', queryParameters: {
        'per_page': 5,
      });
      final releases = response.data as List<dynamic>;
      if (releases.isEmpty) return null;

      // Find the newest release whose tag represents a newer version.
      for (final release in releases) {
        final data = release as Map<String, dynamic>;
        final tagName =
            (data['tag_name'] as String).replaceFirst(RegExp(r'^v'), '');

        if (_isNewer(tagName, currentVersion, currentBuild, installedLabel)) {
          final assets = data['assets'] as List<dynamic>? ?? [];
          final platform = _currentPlatform();

          // Which asset this platform downloads — null for store-only (iOS).
          final assetSuffix = _assetSuffix(platform);
          String? downloadUrl;
          int? packageSize;

          if (assetSuffix != null) {
            final asset = assets.cast<Map<String, dynamic>>().firstWhere(
                  (a) => (a['name'] as String)
                      .toLowerCase()
                      .endsWith(assetSuffix),
                  orElse: () => <String, dynamic>{},
                );
            downloadUrl = asset['browser_download_url'] as String?;
            packageSize = asset['size'] as int?;
            // Release has no binary for our platform — skip it.
            if (downloadUrl == null) continue;
          }

          return UpdateInfo(
            latestVersion: tagName,
            downloadUrl: downloadUrl,
            releaseNotes: data['body'] as String?,
            apkSize: packageSize,
            platform: platform,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('[UpdateService] checkForUpdate failed: $e');
      return null;
    }
  }

  /// The platform we're running on, including desktop.
  TargetPlatform _currentPlatform() {
    if (Platform.isAndroid) return TargetPlatform.android;
    if (Platform.isIOS) return TargetPlatform.iOS;
    if (Platform.isWindows) return TargetPlatform.windows;
    if (Platform.isLinux) return TargetPlatform.linux;
    if (Platform.isMacOS) return TargetPlatform.macOS;
    return TargetPlatform.fuchsia;
  }

  /// The release-asset suffix this platform downloads, or null for store-only
  /// platforms (iOS). The public repo names assets `ScanCo.{ext}`:
  /// `.apk` (Android), `.zip` (Windows), `.tar.gz` (Linux), `.dmg` (macOS).
  /// The release-asset suffix this platform downloads (null for unknown
  /// platforms). The public repo names assets `ScanCo.{ext}`:
  /// `.apk` (Android), `.ipa` (iOS), `.zip` (Windows), `.tar.gz` (Linux),
  /// `.dmg` (macOS).
  @visibleForTesting
  String? assetSuffix(TargetPlatform platform) => _assetSuffix(platform);

  String? _assetSuffix(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
        return '.apk';
      case TargetPlatform.windows:
        return '.zip';
      case TargetPlatform.linux:
        return '.tar.gz';
      case TargetPlatform.macOS:
        return '.dmg';
      case TargetPlatform.iOS:
        return '.ipa';
      default:
        return null; // unknown platform — no asset
    }
  }

  /// Downloads the APK to external cache dir. Android only.
  ///
  /// [onProgress] receives values 0.0 → 1.0.
  /// [cancelToken] allows the user to cancel mid-download.
  Future<File> downloadApk(
    String url,
    void Function(double) onProgress, {
    CancelToken? cancelToken,
  }) async {
    final dirs = await getExternalCacheDirectories();
    final apkDir = Directory('${dirs!.first.path}/apk');
    if (!await apkDir.exists()) {
      await apkDir.create(recursive: true);
    }

    final filePath = '${apkDir.path}/update.apk';

    await _dio.download(
      url,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    return File(filePath);
  }

  /// Downloads a release package (zip / tar.gz / dmg / apk) to a temp dir.
  /// Works on every platform — Android uses external cache, desktop uses the
  /// system temp dir (getExternalCacheDirectories throws on desktop).
  ///
  /// [onProgress] receives values 0.0 → 1.0.
  /// [cancelToken] allows the user to cancel mid-download.
  Future<File> downloadPackage(
    String url,
    void Function(double) onProgress, {
    CancelToken? cancelToken,
  }) async {
    final Directory dir;
    if (Platform.isAndroid) {
      final cache = await getExternalCacheDirectories();
      dir = Directory('${cache!.first.path}/apk');
    } else {
      dir = await getTemporaryDirectory();
    }
    if (!await dir.exists()) await dir.create(recursive: true);

    final filename = url.split('/').last;
    final filePath = '${dir.path}/$filename';

    await _dio.download(
      url,
      filePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    return File(filePath);
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  /// Build-aware semver comparison with branch-label precedence.
  ///
  /// Returns true if [latest] is newer than the installed build identified by
  /// [current] (version) and [currentBuild] (build/run number). [installedLabel]
  /// is the branch label the installed build was built from (`APP_LABEL`); when
  /// provided, branch precedence is honored for same-base pre-releases:
  ///   stable > main > dev > other branch > numeric (0)
  /// so a `main` build supersedes a `dev` build even if its run number is lower,
  /// and a `dev` build never supersedes a `main` build. Older builds without a
  /// label (or [installedLabel] == '') keep the build-number-only comparison.
  ///
  /// Releases are tagged `v{major.minor.patch}-{label}.{run_number}` where the
  /// run number is the CI build number (injected as `APP_BUILD` at build time),
  /// so pre-releases are compared by that number — same build = no update.
  ///
  /// Examples (currentBuild = 24, installedLabel = "dev"):
  ///   isNewer("1.0.0-dev.25", "1.0.0", 24, "dev") → true   (25 > 24)
  ///   isNewer("1.0.0-dev.24", "1.0.0", 24, "dev") → false  (same build)
  ///   isNewer("1.0.0-main.30", "1.0.0", 24, "dev") → true   (main > dev)
  ///   isNewer("1.0.0-dev.40", "1.0.0", 24, "main") → false  (dev < main)
  ///   isNewer("1.0.1", "1.0.0", 24, "dev")        → true   (higher base)
  ///   isNewer("1.0.0", "1.0.0", 24, "dev")        → false  (stable, same base)
  @visibleForTesting
  bool isNewer(String latest, String current, int currentBuild,
          [String installedLabel = '']) =>
      _isNewer(latest, current, currentBuild, installedLabel);

  bool _isNewer(String latest, String current, int currentBuild,
      [String installedLabel = '']) {
    // Normalize: strip leading 'v' and split base from pre-release suffix.
    final l = latest.startsWith('v') ? latest.substring(1) : latest;
    final c = current.startsWith('v') ? current.substring(1) : current;

    final lBase = l.split('-').first;
    final cBase = c.split('-').first;

    final lNum = lBase.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final cNum = cBase.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    // Pad to 3 parts (major.minor.patch).
    while (lNum.length < 3) lNum.add(0);
    while (cNum.length < 3) cNum.add(0);

    // Compare base semver.
    for (var i = 0; i < 3; i++) {
      if (lNum[i] > cNum[i]) return true;
      if (lNum[i] < cNum[i]) return false;
    }

    // Same base version — inspect the pre-release suffix, e.g. "dev.35".
    final lSuffix = l.contains('-') ? l.split('-').last : '';
    if (lSuffix.isEmpty) {
      // Latest is stable with the same base version → not newer.
      return false;
    }

    // Split "<label>.<run>": label may be "main", "dev", "feature-x", etc.
    final m = RegExp(r'^(.*)\.(\d+)$').firstMatch(lSuffix);
    final lBuild = int.tryParse(m?.group(2) ?? '') ?? 0;
    final lLabel = (m?.group(1) ?? lSuffix).toLowerCase();

    // Branch precedence — only when the installed app knows its own label.
    // Older builds (no APP_LABEL) keep the build-number-only comparison.
    if (installedLabel.isNotEmpty) {
      final lRank = _labelRank(lLabel);
      final iRank = _labelRank(installedLabel);
      if (lRank > iRank) return true;
      if (lRank < iRank) return false;
    }

    // Same branch/rank → newer only if its run number exceeds the installed
    // build number. Same or older run → already up to date.
    return lBuild > currentBuild;
  }

  /// Pre-release label precedence. Higher = more important.
  ///
  ///   stable (4) > main/master (3) > dev/develop (2) > other-alnum (1) > numeric (0)
  int _labelRank(String label) {
    final l = label.toLowerCase();
    if (l.isEmpty || l == 'stable') return 4;
    if (l == 'main' || l == 'master') return 3;
    if (l == 'dev' || l == 'develop') return 2;
    if (RegExp(r'^\d+$').hasMatch(l)) return 0;
    return 1;
  }
}
