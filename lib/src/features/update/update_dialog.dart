import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/update_info.dart';
import '../../core/services/desktop_updater.dart';
import '../../core/services/update_service.dart';
import '../../l10n/gen/app_localizations.dart';

/// Internal states for the update dialog lifecycle.
enum _DialogState { checking, upToDate, info, downloading, restarting }

/// Numeric App Store ID — set once the app is published to the App Store.
const String _appStoreId = ''; // TODO(publish): fill in after App Store submission

/// A 3-state auto-update dialog.
///
/// Opens in [CHECKING] with a spinner, calls the GitHub Releases API,
/// then transitions to [UP_TO_DATE] (auto-dismiss) or [INFO] (new version).
/// Android & iOS can only ship updates through their own app stores, so the
/// [INFO] "Update" button opens the Play Store / App Store (desktop falls
/// back to the GitHub release page). No in-app download or install.
///
/// Follows FOMO Shield Design Bible:
/// - Editorial Heritage palette (#F6F1E7, #1B365D, #4A5D23, #3F7CFF)
/// - Card radius 24px, no countdown timers, no pressure language
/// - Dismissible at CHECKING and INFO states
class UpdateDialog extends ConsumerStatefulWidget {
  /// When true (the auto-check on app open), the dialog closes silently if
  /// the user is already on the latest version — no "You're on the latest"
  /// notification. The manual Profile ⟳ button keeps that feedback.
  const UpdateDialog({super.key, this.silentWhenUpToDate = false});

  final bool silentWhenUpToDate;

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  _DialogState _state = _DialogState.checking;
  UpdateInfo? _updateInfo;
  double _progress = 0;
  CancelToken? _cancelToken;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _performCheck();
  }

  // ── API call ────────────────────────────────────────────────────────────

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
        // Up to date: auto-check closes silently, manual check shows feedback.
        if (widget.silentWhenUpToDate) {
          Navigator.of(context).pop();
          return;
        }
        setState(() => _state = _DialogState.upToDate);
        _autoDismiss();
      }
    } catch (_) {
      if (!mounted) return;
      if (widget.silentWhenUpToDate) {
        Navigator.of(context).pop();
        return;
      }
      setState(() => _state = _DialogState.upToDate);
      _autoDismiss();
    }
  }

  void _autoDismiss() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────

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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (_state) {
        _DialogState.checking => _buildChecking(),
        _DialogState.upToDate => _buildUpToDate(),
        _DialogState.info => _buildInfo(),
        _DialogState.downloading => _buildDownloading(),
        _DialogState.restarting => _buildRestarting(),
      },
    );
  }

  // ── CHECKING ────────────────────────────────────────────────────────────

  Widget _buildChecking() {
    return Column(
      key: const ValueKey('checking'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Color(0xFF1B365D)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _l10n.updateChecking,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
      ],
    );
  }

  // ── UP TO DATE ──────────────────────────────────────────────────────────

  Widget _buildUpToDate() {
    return Column(
      key: const ValueKey('upToDate'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4A5D23), size: 48),
        const SizedBox(height: 12),
        Text(
          _l10n.updateUpToDate,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
      ],
    );
  }

  // ── DOWNLOADING ─────────────────────────────────────────────────────────

  Widget _buildDownloading() {
    return Column(
      key: const ValueKey('downloading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _l10n.updateDownloading(_updateInfo!.latestVersion),
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
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
        Text(
          '${(_progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF6B6B6B),
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _cancelDownload,
          child: Text(
            _l10n.updateCancel,
            style: TextStyle(
              color: const Color(0xFF6B6B6B),
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  // ── RESTARTING ──────────────────────────────────────────────────────────

  Widget _buildRestarting() {
    return Column(
      key: const ValueKey('restarting'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Color(0xFF1B365D)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _l10n.updateRestarting,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
      ],
    );
  }

  // ── INFO ────────────────────────────────────────────────────────────────

  Widget _buildInfo() {
    final info = _updateInfo!;
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    // Desktop: "Update directly" = the in-app self-update (download+install+
    // relaunch); the raw package download stays as the manual secondary.
    // Mobile: primary goes to the app store; secondary downloads the binary.
    final primaryLabel =
        isDesktop ? _l10n.updateDirectly : _l10n.updateFromStore;
    final VoidCallback primaryAction =
        isDesktop ? _startDesktopUpdate : _openStore;
    final secondaryLabel =
        isDesktop ? _l10n.updateDownloadPackage : _l10n.updateDirectly;
    final VoidCallback secondaryAction = _openBrowserDownload;

    return Column(
      key: const ValueKey('info'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _l10n.updateNewVersionAvailable,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _l10n.updateYouHavePrevious(info.latestVersion),
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF4A5D23),
            fontFamily: _fontFamily,
          ),
        ),
        if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Text(
                info.releaseNotes!,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF6B6B6B),
                  fontFamily: _fontFamily,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: primaryAction,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B365D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              primaryLabel,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: secondaryAction,
            child: Text(
              secondaryLabel,
              style: TextStyle(
                color: const Color(0xFF1B365D),
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _l10n.updateMaybeLater,
              style: TextStyle(
                color: const Color(0xFF6B6B6B),
                fontFamily: _fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  /// Desktop self-update: download the platform package, then apply & relaunch
  /// via [DesktopUpdater] and exit so the new version takes over.
  Future<void> _startDesktopUpdate() async {
    final info = _updateInfo;
    final url = info?.downloadUrl;
    if (url == null) return;

    setState(() {
      _state = _DialogState.downloading;
      _progress = 0;
    });
    _cancelToken = CancelToken();
    try {
      final service = ref.read(updateServiceProvider);
      final file = await service.downloadPackage(
        url,
        (p) {
          if (mounted) setState(() => _progress = p);
        },
        cancelToken: _cancelToken,
      );
      if (!mounted) return;

      setState(() => _state = _DialogState.restarting);
      await DesktopUpdater.applyAndRelaunch(file);

      // Give the detached helper a moment to start, then exit so it can
      // replace the running files and launch the new version.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      exit(0);
    } on DioException catch (_) {
      if (mounted) setState(() => _state = _DialogState.info);
    } catch (e) {
      debugPrint('[UpdateDialog] Desktop update failed: $e');
      if (mounted) setState(() => _state = _DialogState.info);
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
    if (mounted) setState(() => _state = _DialogState.info);
  }

  /// "Update directly": open the platform package (APK/IPA/desktop archive)
  /// in the external browser, where the download is handled natively — robust,
  /// no in-app download/install. Falls back to the release page when the
  /// release has no binary URL for this platform.
  void _openBrowserDownload() {
    final info = _updateInfo;
    final url = info?.downloadUrl;
    if (url == null) {
      _openReleasePage();
      return;
    }
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (mounted) Navigator.of(context).pop();
  }

  /// Android + iOS can only ship updates through their own app stores — the
  /// "Update" button forwards there instead of self-installing.
  void _openStore() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _launchAndClose(
        'https://play.google.com/store/apps/details?id=com.scanco.scanco',
      );
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS && _appStoreId.isNotEmpty) {
      _launchAndClose('https://apps.apple.com/app/id$_appStoreId');
      return;
    }
    // Desktop, or iOS not yet published — the GitHub release page is the
    // current dev distribution path.
    _openReleasePage();
  }

  void _launchAndClose(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (mounted) Navigator.of(context).pop();
  }

  void _openReleasePage() {
    launchUrl(
      Uri.parse(
        'https://github.com/vofka198119-code/fomoshield-releases/releases/latest',
      ),
      mode: LaunchMode.externalApplication,
    );
    if (mounted) Navigator.of(context).pop();
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Matches the Editorial Heritage typography used across the app.
const String _fontFamily = 'Inter';
