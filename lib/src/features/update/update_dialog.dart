import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/update_info.dart';
import '../../core/services/update_service.dart';
import '../../l10n/gen/app_localizations.dart';

/// Internal states for the update dialog lifecycle.
enum _DialogState { checking, upToDate, info }

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

  // ── INFO ────────────────────────────────────────────────────────────────

  Widget _buildInfo() {
    final info = _updateInfo!;

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
            onPressed: _openStore,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B365D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _l10n.updateFromStore,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _openReleasePage,
            child: Text(
              _l10n.updateViewOnGithub,
              style: TextStyle(
                color: const Color(0xFF6B6B6B),
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

  /// Android + iOS can only ship updates through their own app stores — the
  /// "Update" button forwards there instead of self-installing. Desktop builds
  /// (no store) fall back to the public GitHub release page.
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
