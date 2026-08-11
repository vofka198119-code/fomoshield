import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';

import '../models/update_info.dart';

// ─── Provider ───────────────────────────────────────────────────────────────

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

// ─── Service ────────────────────────────────────────────────────────────────

/// Checks GitHub Releases for newer app versions and downloads APKs (Android).
///
/// Uses a fine-grained PAT injected at build time via --dart-define:
///   flutter build apk --dart-define=GITHUB_TOKEN=github_pat_...
class UpdateService {
  static const _baseUrl = 'https://api.github.com';
  static const _repo = 'vofka198119-code/fomoshield';

  /// GitHub fine-grained PAT — injected at build time, never in source code.
  /// Scope: Contents: Read on vofka198119-code/fomoshield only.
  static const _token = String.fromEnvironment('GITHUB_TOKEN');

  late final Dio _dio;

  UpdateService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ));

    // Debug logging (minimal — does NOT log the Authorization header).
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

        if (_isNewer(tagName, currentVersion)) {
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

  /// Semver comparison handling both stable tags ("1.0.1") and dev
  /// pre-releases ("1.0.0-dev.123" from CI builds on main).
  ///
  /// Returns true if [latest] > [current].
  ///
  /// Examples:
  ///   isNewer("1.0.0-dev.5", "1.0.0")     → true  (dev build is newer)
  ///   isNewer("1.0.0-dev.12", "1.0.0-dev.5") → true
  ///   isNewer("1.0.1", "1.0.0-dev.99")    → true  (higher base semver)
  ///   isNewer("1.0.0", "1.0.0")           → false
  @visibleForTesting
  bool isNewer(String latest, String current) => _isNewer(latest, current);

  bool _isNewer(String latest, String current) {
    // Normalize: strip leading 'v' and split base from pre-release suffix.
    final lBase = latest.split('-').first;
    final cBase = current.split('-').first;

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

    // Same base version — compare pre-release suffixes.
    final lSuffix = latest.contains('-') ? latest.split('-').last : '';
    final cSuffix = current.contains('-') ? current.split('-').last : '';

    // No suffix on either side → equal.
    if (lSuffix.isEmpty && cSuffix.isEmpty) return false;

    // Latest has a suffix, current does not → latest is a pre-release
    // (dev build). Consider it newer so dev builds are picked up.
    if (lSuffix.isNotEmpty && cSuffix.isEmpty) return true;

    // Current has a suffix but latest doesn't → latest is stable,
    // current is a dev build. Stable is newer.
    if (lSuffix.isEmpty && cSuffix.isNotEmpty) return false;

    // Both have suffixes — compare numerically.
    // Extract numeric part from patterns like "dev.123".
    final lBuild = int.tryParse(
      RegExp(r'\d+').firstMatch(lSuffix)?.group(0) ?? '',
    );
    final cBuild = int.tryParse(
      RegExp(r'\d+').firstMatch(cSuffix)?.group(0) ?? '',
    );

    if (lBuild != null && cBuild != null) return lBuild > cBuild;

    // Fallback: string comparison of suffixes.
    return lSuffix.compareTo(cSuffix) > 0;
  }
}
