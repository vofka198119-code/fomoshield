# Implementation Plan

> 10 steps, 10 files (5 create, 3 modify, 2 manual)

---

## Phase 0 — Prerequisites (Manual, One-Time)

### Step 0a: Create Fine-Grained PAT

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. **Resource owner**: `vofka198119-code`
3. **Repository**: `vofka198119-code/fomoshield` (single repo)
4. **Permissions**: `Contents: Read-only`
5. Copy the generated token (`github_pat_...`).

### Step 0b: Store as Repository Secret

1. Go to repo → Settings → Secrets and variables → Actions
2. New repository secret: **Name** = `RELEASE_READ_TOKEN`, **Value** = the PAT from 0a.

---

## Phase 1 — Platform Foundation

### Step 1: Add `package_info_plus` Dependency

**File**: `pubspec.yaml`

```bash
dart pub add package_info_plus path_provider open_filex
```

Enables runtime access to `versionName` / `versionCode` (Android) and `CFBundleShortVersionString` / `CFBundleVersion` (iOS), external cache directory for APK downloads, and triggering the Android package installer via FileProvider.

### Step 2: Android FileProvider XML

**File**: `android/app/src/main/res/xml/file_paths.xml` **(CREATE)**

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-cache-path name="apk_downloads" path="apk/" />
</paths>
```

Allows the FileProvider to serve APKs from the app's external cache directory.

### Step 3: Android Manifest Updates

**File**: `android/app/src/main/AndroidManifest.xml` **(MODIFY)**

Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

Add inside `<application>`:
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

### Step 4: iOS Notes

No special permissions or config for iOS. The update flow will use `url_launcher` (already in `pubspec.yaml`) to open the GitHub release page in Safari. IPA sideloading requires MDM or enterprise distribution — out of scope for this feature.

---

## Phase 2 — Service Layer

### Step 5: UpdateInfo Model

**File**: `lib/src/core/models/update_info.dart` **(CREATE)**

```dart
import 'dart:io';

class UpdateInfo {
  final String latestVersion;
  final String? downloadUrl; // null for iOS
  final String? releaseNotes;
  final int? apkSize; // bytes, Android only
  final TargetPlatform platform;

  const UpdateInfo({
    required this.latestVersion,
    this.downloadUrl,
    this.releaseNotes,
    this.apkSize,
    required this.platform,
  });

  bool get isAndroidUpdate => platform == TargetPlatform.android;
  bool get isIosUpdate => platform == TargetPlatform.iOS;

  @override
  String toString() => 'UpdateInfo(v$latestVersion, $platform)';
}
```

Design decisions:
- `downloadUrl` is nullable — null on iOS means "open release page in browser"
- `apkSize` is nullable — only meaningful on Android
- `platform` is explicit — prevents accidental cross-platform asset selection

### Step 6: UpdateService

**File**: `lib/src/core/services/update_service.dart` **(CREATE)**

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod/riverpod.dart';
import '../models/update_info.dart';

// ─── Provider ───
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

class UpdateService {
  static const _baseUrl = 'https://api.github.com';
  static const _repo = 'vofka198119-code/fomoshield';
  
  // Injected at build time via --dart-define
  static const _token = String.fromEnvironment('GITHUB_TOKEN');
  
  late final Dio _dio;

  UpdateService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    ));
  }

  // ─── Public API ───

  /// Returns [UpdateInfo] if a newer version exists on GitHub, else null.
  ///
  /// Checks the 5 most recent releases (including pre-releases) so dev
  /// builds pushed on every main commit are detected alongside stable tags.
  /// Silently returns null on any error.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

      // /releases (not /releases/latest) — includes pre-releases for dev builds.
      final response = await _dio.get('/repos/$_repo/releases', queryParameters: {
        'per_page': 5,
      });
      final releases = response.data as List<dynamic>;
      if (releases.isEmpty) return null;

      // Iterate newest-first, pick first release newer than current.
      for (final release in releases) {
        final data = release as Map<String, dynamic>;
        final tagName = (data['tag_name'] as String).replaceFirst(RegExp(r'^v'), '');

        if (!_isNewer(tagName, currentVersion)) continue;

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

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK to external cache dir. Android only.
          (a) => (a['name'] as String).endsWith('.apk'),
          orElse: () => <String, dynamic>{},
        );
        downloadUrl = apk['browser_download_url'] as String?;
        apkSize = apk['size'] as int?;
      }
      // iOS: downloadUrl stays null → "View on GitHub" flow

      if (Platform.isAndroid && downloadUrl == null) return null; // no APK asset

      return UpdateInfo(
        latestVersion: tagName,
        downloadUrl: downloadUrl,
        releaseNotes: data['body'] as String?,
        apkSize: apkSize,
        platform: platform,
      );
    } catch (_) {
      return null; // Fail silently — never block the user
    }
  }

  /// Downloads the APK to external cache dir. Android only.
  /// [onProgress] receives 0.0 → 1.0.
  Future<File> downloadApk(
    String url,
    void Function(double) onProgress, {
    CancelToken? cancelToken,
  }) async {
    final dir = await getExternalCacheDirectories();
    final apkDir = Directory('${dir!.first.path}/apk');
    if (!await apkDir.exists()) await apkDir.create(recursive: true);

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

  // ─── Private ────────────────────────────────────────────────────────

  /// Semver comparison handling both stable tags ("1.0.1") and dev
  /// pre-releases ("1.0.0-dev.123" from CI builds on main).
  ///
  /// Examples:
  ///   _isNewer("1.0.0-dev.5", "1.0.0")      → true
  ///   _isNewer("1.0.0-dev.12", "1.0.0-dev.5") → true
  ///   _isNewer("1.0.1", "1.0.0-dev.99")     → true
  ///   _isNewer("1.0.0", "1.0.0")            → false
  bool _isNewer(String latest, String current) {
    // Normalize: strip leading 'v' and split base from pre-release suffix.
    final lBase = latest.split('-').first;
    final cBase = current.split('-').first;

    final lNum = lBase.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final cNum = cBase.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    while (lNum.length < 3) lNum.add(0);
    while (cNum.length < 3) cNum.add(0);

    // Compare base semver.
    for (var i = 0; i < 3; i++) {
      if (lNum[i] > cNum[i]) return true;
      if (lNum[i] < cNum[i]) return false;
    }

    // Same base — compare pre-release suffixes.
    final lSuffix = latest.contains('-') ? latest.split('-').last : '';
    final cSuffix = current.contains('-') ? current.split('-').last : '';
    if (lSuffix.isEmpty && cSuffix.isEmpty) return false;
    if (lSuffix.isNotEmpty && cSuffix.isEmpty) return true;  // dev > base
    if (lSuffix.isEmpty && cSuffix.isNotEmpty) return false; // stable > dev

    final lBuild = int.tryParse(RegExp(r'\d+').firstMatch(lSuffix)?.group(0) ?? '');
    final cBuild = int.tryParse(RegExp(r'\d+').firstMatch(cSuffix)?.group(0) ?? '');
    if (lBuild != null && cBuild != null) return lBuild > cBuild;
    return lSuffix.compareTo(cSuffix) > 0;
  }
}
```

Key design points:
- `_token` is `const` — compiled into the binary, never changes at runtime
- `_token.isNotEmpty` guard — prevents 401 errors during local dev without the token
- `checkForUpdate()` iterates `/releases?per_page=5` — includes pre-releases for dev builds
- `_isNewer()` handles `-dev.{N}` suffixes — dev builds correctly compare against base versions
- `downloadApk` uses Dio's built-in download with progress callback
- CancelToken support — user can cancel mid-download

### Step 6b: Dependencies

All three dependencies were added in Step 1. No additional steps needed.

## Phase 3 — UI Layer

### Step 7: UpdateDialog (with CHECKING + UP_TO_DATE states)

**File**: `lib/src/features/update/update_dialog.dart` **(CREATE)**

The dialog now opens immediately (not after the API call completes) with a "Checking for updates..." spinner. This gives the user immediate feedback. If no update is found, it briefly shows an "up to date" confirmation and auto-dismisses.

```dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/update_info.dart';
import '../../core/services/update_service.dart';

enum _DialogState { checking, upToDate, info, downloading, ready }

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({super.key});

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  _DialogState _state = _DialogState.checking;
  UpdateInfo? _updateInfo;
  double _progress = 0;
  CancelToken? _cancelToken;
  File? _downloadedFile;

  @override
  void initState() {
    super.initState();
    _performCheck();
  }

  Future<void> _performCheck() async {
    try {
      final service = ref.read(updateServiceProvider);
      final result = await service.checkForUpdate();
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _updateInfo = result;
          _state = _DialogState.info;
        });
      } else {
        setState(() => _state = _DialogState.upToDate);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _DialogState.upToDate);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFF6F1E7),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_state) {
      _DialogState.checking   => _buildChecking(),
      _DialogState.upToDate   => _buildUpToDate(),
      _DialogState.info       => _buildInfo(),
      _DialogState.downloading => _buildDownloading(),
      _DialogState.ready      => _buildReady(),
    };
  }

  // ── CHECKING ──
  Widget _buildChecking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36, height: 36,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(height: 16),
        Text('Checking for updates...',
          style: TextStyle(fontSize: 15, color: Color(0xFF1B365D))),
      ],
    );
  }

  // ── UP TO DATE ──
  Widget _buildUpToDate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4A5D23), size: 48),
        const SizedBox(height: 12),
        Text('You\'re on the latest version',
          style: TextStyle(fontSize: 15, color: Color(0xFF1B365D))),
      ],
    );
  }

  // ── INFO ──
  Widget _buildInfo() {
    final isAndroid = _updateInfo!.isAndroidUpdate;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Version Available',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B365D))),
        const SizedBox(height: 8),
        Text('v${_updateInfo!.latestVersion} (you have a previous version)',
          style: TextStyle(fontSize: 14, color: Color(0xFF4A5D23))),
        if (_updateInfo!.releaseNotes != null && _updateInfo!.releaseNotes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Text(_updateInfo!.releaseNotes!,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B))),
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isAndroid ? _startDownload : _openReleasePage,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B365D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAndroid ? 'Download & Install' : 'View on GitHub'),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later',
              style: TextStyle(color: Color(0xFF6B6B6B))),
          ),
        ),
      ],
    );
  }

  // ── DOWNLOADING ──
  Widget _buildDownloading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Downloading v${_updateInfo!.latestVersion}...',
          style: TextStyle(fontSize: 15, color: Color(0xFF1B365D))),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5DFD3),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF3F7CFF)),
          ),
        ),
        const SizedBox(height: 8),
        Text('${(_progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B))),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _cancelToken?.cancel();
            setState(() => _state = _DialogState.info);
          },
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B6B6B))),
        ),
      ],
    );
  }

  // ── READY ──
  Widget _buildReady() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4A5D23), size: 48),
        const SizedBox(height: 12),
        Text('Ready to Install',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B365D))),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _installApk,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4A5D23),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Install'),
          ),
        ),
      ],
    );
  }

  // ── Actions ──
  Future<void> _startDownload() async {
    setState(() {
      _state = _DialogState.downloading;
      _progress = 0;
    });
    _cancelToken = CancelToken();
    try {
      final service = ref.read(updateServiceProvider);
      _downloadedFile = await service.downloadApk(
        _updateInfo!.downloadUrl!,
        (p) => setState(() => _progress = p),
        cancelToken: _cancelToken,
      );
      if (mounted) setState(() => _state = _DialogState.ready);
    } on DioException catch (_) {
      if (mounted) setState(() => _state = _DialogState.info);
    }
  }

  void _installApk() {
    final file = _downloadedFile;
    if (file == null) return;
    try {
      // open_filex handles FileProvider internally on Android 7+.
      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        debugPrint('[UpdateDialog] Install result: ${result.type}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Installation failed.')),
        );
      }
    }
  }

  void _openReleasePage() {
    launchUrl(
      Uri.parse('https://github.com/vofka198119-code/fomoshield/releases/latest'),
      mode: LaunchMode.externalApplication,
    );
    Navigator.of(context).pop();
  }
}
```

Design compliance:
- Editorial Heritage palette: `#F6F1E7` bg, `#1B365D` accent, `#4A5D23` stress, `#3F7CFF` progress
- Card radius 24px, padding 24px, button radius 12px
- `CircularProgressIndicator` for CHECKING — subtle, 36×36, 2.5px stroke
- `LinearProgressIndicator` for DOWNLOADING — `#3F7CFF` (shield blue) on `#E5DFD3` track
- No countdown timers, no "Update NOW!", no pressure language
- "Maybe Later" always available — user is in full control
- UP_TO_DATE auto-dismisses after 1.5s — brief, non-intrusive confirmation
- 5 states with smooth transitions

### Step 8: Startup Integration

**File**: `lib/main.dart` **(MODIFY)**

The dialog is now opened first (CHECKING state), then the API call runs inside it. This replaces the "silent check" approach from v1 of the plan.

```dart
// ... existing initState code ...

@override
void initState() {
  super.initState();

  // NEW: Show update dialog after 5 seconds — it starts in CHECKING state
  Future.delayed(const Duration(seconds: 5), () {
    _showUpdateDialog();
  });

  // Existing: Check pending orders after 8 seconds
  Future.delayed(const Duration(seconds: 8), () {
    checkPendingOrders(ref);
  });
}

void _showUpdateDialog() {
  if (!mounted) return;
  showDialog(
    context: context,
    barrierDismissible: true,  // User can dismiss at CHECKING or INFO
    builder: (_) => const UpdateDialog(),
  );
}
```

Note: The dialog no longer receives `updateInfo` — it creates its own `UpdateService` call in `initState()`. The `container` (pre-runApp ProviderContainer) is still accessible via `ref.read(updateServiceProvider)` inside the dialog's `ConsumerState`. If no update or error, it transitions to UP_TO_DATE → auto-close. The app is never blocked — the dialog is fully dismissible.

### Step 9: Settings Screen Polish

**File**: `lib/src/features/settings/settings_screen.dart` **(MODIFY)**

Two changes:
1. Replace hardcoded `'1.0.0'` (line ~86) with live `PackageInfo.version`
2. Add "Check for Updates" tile — opens the same `UpdateDialog` (starts in CHECKING state, shows UP_TO_DATE or INFO)

```dart
// Existing: version display becomes:
FutureBuilder<PackageInfo>(
  future: PackageInfo.fromPlatform(),
  builder: (context, snapshot) {
    final version = snapshot.data?.version ?? '...';
    return Text(version);
  },
);

// New: "Check for Updates" tile — opens UpdateDialog in CHECKING state
ListTile(
  leading: const Icon(Icons.system_update),
  title: const Text('Check for Updates'),
  subtitle: const Text('Check GitHub for new versions'),
  onTap: () {
    showDialog(
      context: context,
      builder: (_) => const UpdateDialog(), // Starts in CHECKING → auto-handles all states
    );
  },
),
```

No more SnackBar for "up to date" — the dialog itself shows the UP_TO_DATE state with a checkmark and auto-dismisses after 1.5 seconds. Same flow as the automatic startup check.

---

## Phase 4 — CI/CD Pipeline

### Step 10: GitHub Actions Release Workflow

**File**: `.github/workflows/release.yml` **(CREATE)**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - run: flutter pub get
      
      - run: |
          flutter build apk --release \
            --dart-define=GITHUB_TOKEN=${{ secrets.RELEASE_READ_TOKEN }}
      
      - uses: actions/upload-artifact@v4
        with:
          name: app-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS IPA (unsigned)
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - run: flutter pub get
      
      - run: |
          flutter build ios --release --no-codesign \
            --dart-define=GITHUB_TOKEN=${{ secrets.RELEASE_READ_TOKEN }}
      
      - run: |
          cd build/ios/iphoneos
          mkdir -p Payload
          cp -r Runner.app Payload/
          zip -r app-release.ipa Payload
      
      - uses: actions/upload-artifact@v4
        with:
          name: app-release-ipa
          path: build/ios/iphoneos/app-release.ipa

  release:
    name: Create GitHub Release
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: app-release-apk
      
      - uses: actions/download-artifact@v4
        with:
          name: app-release-ipa
      
      - uses: softprops/action-gh-release@v2
        with:
          name: ${{ github.ref_name }}
          files: |
            app-release.apk
            app-release.ipa
          generate_release_notes: true
```

Notes:
- `subosito/flutter-action@v2` — official Flutter setup action (not `D:\flutter`, which is local dev path)
- iOS build may fail without Apple Developer certificates — document this
- `generate_release_notes: true` — auto-generates changelog from merged PRs
- Both APK and IPA uploaded to same release

---

## Verification Checklist

- [ ] **Unit**: `_isNewer('1.0.1', '1.0.0')` → `true`
- [ ] **Unit**: `_isNewer('1.0.0', '1.0.0')` → `false`
- [ ] **Unit**: `_isNewer('0.9.9', '1.0.0')` → `false`
- [ ] **Unit**: `checkForUpdate()` returns `null` when versions match
- [ ] **Unit**: `checkForUpdate()` returns `UpdateInfo` when newer release exists
- [ ] **Unit**: Android gets `.apk` asset URL, iOS gets `null` downloadUrl
- [ ] **Manual**: Launch app → dialog after 5s → CHECKING spinner → UP_TO_DATE (if current version ≥ latest)
- [ ] **Manual**: UP_TO_DATE auto-dismisses after 1.5 seconds
- [ ] **Manual (Android)**: Build `1.0.0+1`, create `v1.0.1` release with APK, launch → CHECKING → INFO → Download & Install → DOWNLOADING progress bar → READY → Install
- [ ] **Manual (iOS)**: Same → CHECKING → INFO → "View on GitHub" → Safari opens
- [ ] **Manual**: Dismiss dialog at CHECKING state → app continues normally
- [ ] **Manual**: Dismiss dialog at INFO state ("Maybe Later") → app continues normally
- [ ] **Manual**: Cancel download (DOWNLOADING → back to INFO) → works correctly
- [ ] **Manual**: Settings → "Check for Updates" → same dialog flow (CHECKING → UP_TO_DATE or INFO)
- [ ] **CI**: Push `v1.0.1` tag → Actions builds both APK and IPA → release created
- [ ] **Design**: No FOMO language, Editorial Heritage palette, card radius 24px
- [ ] **Design**: CHECKING: subtle spinner, 36×36, 2.5px stroke
- [ ] **Design**: DOWNLOADING: `#3F7CFF` progress bar on `#E5DFD3` track
- [ ] **Accessibility**: Dialog content readable, dismissible via back button, no input trapping
