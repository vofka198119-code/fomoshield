import 'package:flutter/foundation.dart';

/// Represents an available app update from GitHub Releases.
class UpdateInfo {
  /// The latest version string from the GitHub release tag (e.g. "1.0.1").
  final String latestVersion;

  /// Direct download URL for the APK. Null for iOS (redirects to release page).
  final String? downloadUrl;

  /// Release notes / changelog from the GitHub release body.
  final String? releaseNotes;

  /// Size of the APK asset in bytes. Null for iOS.
  final int? apkSize;

  /// The platform this update is targeting.
  final TargetPlatform platform;

  const UpdateInfo({
    required this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
    this.apkSize,
    required this.platform,
  });

  /// Whether this is an Android update (with in-app download).
  bool get isAndroidUpdate => platform == TargetPlatform.android;

  /// Whether this is an iOS update (redirect to release page).
  bool get isIosUpdate => platform == TargetPlatform.iOS;

  /// Human-readable file size.
  String get formattedSize {
    if (apkSize == null) return '';
    if (apkSize! < 1024) return '${apkSize!} B';
    if (apkSize! < 1024 * 1024) return '${(apkSize! / 1024).toStringAsFixed(1)} KB';
    return '${(apkSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() => 'UpdateInfo(v$latestVersion, $platform, $formattedSize)';
}
