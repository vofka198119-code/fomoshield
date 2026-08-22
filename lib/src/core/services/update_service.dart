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
/// the ScanCo.* binaries there (job `publish-public`).
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

        if (_isNewer(tagName, currentVersion, currentBuild)) {
          final assets = data['assets'] as List<dynamic>? ?? [];
          final platform = Platform.isAndroid
              ? TargetPlatform.android
              : TargetPlatform.iOS;

          String? downloadUrl;
          int? apkSize;

          if (Platform.isAndroid) {
            final apk = assets.cast<Map<String, dynamic>>().firstWhere(
                  (a) => (a['name'] as String).endsWith('.apk'),
                  orElse: () => <String, dynamic>{},
                );
            downloadUrl = apk['browser_download_url'] as String?;
            apkSize = apk['size'] as int?;
          }

          if (Platform.isAndroid && downloadUrl == null) continue;

          return UpdateInfo(
            latestVersion: tagName,
            downloadUrl: downloadUrl,
            releaseNotes: data['body'] as String?,
            apkSize: apkSize,
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

  // ─── Private ─────────────────────────────────────────────────────────────

  /// Build-aware semver comparison.
  ///
  /// Returns true if [latest] is newer than the installed build identified by
  /// [current] (version) and [currentBuild] (build/run number).
  ///
  /// Releases are tagged `v{major.minor.patch}-dev.{run_number}` where the run
  /// number is the CI build number (injected as `APP_BUILD` at build time), so
  /// dev pre-releases are compared by that number — same build = no update.
  ///
  /// Examples (currentBuild = 24):
  ///   isNewer("1.0.0-dev.25", "1.0.0", 24) → true   (25 > 24)
  ///   isNewer("1.0.0-dev.24", "1.0.0", 24) → false  (same build)
  ///   isNewer("1.0.0-dev.10", "1.0.0", 24) → false  (older build)
  ///   isNewer("1.0.1", "1.0.0", 24)        → true   (higher base semver)
  ///   isNewer("1.0.0", "1.0.0", 24)        → false  (stable, same base)
  @visibleForTesting
  bool isNewer(String latest, String current, int currentBuild) =>
      _isNewer(latest, current, currentBuild);

  bool _isNewer(String latest, String current, int currentBuild) {
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

    // Same base version — compare pre-release build numbers.
    final lSuffix = l.contains('-') ? l.split('-').last : '';
    if (lSuffix.isNotEmpty) {
      // Dev/pre-release: newer only if its run number exceeds the installed
      // build number. Same or older run → already up to date.
      final lBuild = int.tryParse(
            RegExp(r'\d+').firstMatch(lSuffix)?.group(0) ?? '',
          ) ??
          0;
      return lBuild > currentBuild;
    }

    // Latest is stable with the same base version → not newer.
    return false;
  }
}
