import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/update_info.dart';
import '../../core/services/update_service.dart';

/// Internal states for the update dialog lifecycle.
enum _DialogState { checking, upToDate, info, downloading, ready }

/// A 5-state auto-update dialog.
///
/// Opens in [CHECKING] with a spinner, calls the GitHub Releases API,
/// then transitions to [UP_TO_DATE] (auto-dismiss) or [INFO] (new version).
/// On Android, continues through [DOWNLOADING] → [READY] → system installer.
/// On iOS, redirects to the GitHub release page in Safari.
///
/// Follows FOMO Shield Design Bible:
/// - Editorial Heritage palette (#F6F1E7, #1B365D, #4A5D23, #3F7CFF)
/// - Card radius 24px, no countdown timers, no pressure language
/// - Dismissible at CHECKING and INFO states
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
        setState(() => _state = _DialogState.upToDate);
        _autoDismiss();
      }
    } catch (_) {
      if (!mounted) return;
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
        _DialogState.ready => _buildReady(),
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
          'Checking for updates...',
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
          "You're on the latest version",
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
    final isAndroid = info.isAndroidUpdate;

    return Column(
      key: const ValueKey('info'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Version Available',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'v${info.latestVersion} (you have a previous version)',
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
            onPressed: isAndroid ? _startDownload : _openReleasePage,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B365D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isAndroid ? 'Download & Install' : 'View on GitHub',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
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

  // ── DOWNLOADING ─────────────────────────────────────────────────────────

  Widget _buildDownloading() {
    return Column(
      key: const ValueKey('downloading'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Downloading v${_updateInfo!.latestVersion}...',
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
            'Cancel',
            style: TextStyle(
              color: const Color(0xFF6B6B6B),
              fontFamily: _fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  // ── READY ───────────────────────────────────────────────────────────────

  Widget _buildReady() {
    return Column(
      key: const ValueKey('ready'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4A5D23), size: 48),
        const SizedBox(height: 12),
        Text(
          'Ready to Install',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B365D),
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _installApk,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4A5D23),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Install', style: TextStyle(fontFamily: 'Inter')),
          ),
        ),
      ],
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

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
        (p) {
          if (mounted) setState(() => _progress = p);
        },
        cancelToken: _cancelToken,
      );
      if (mounted) setState(() => _state = _DialogState.ready);
    } on DioException catch (_) {
      if (mounted) setState(() => _state = _DialogState.info);
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
    if (mounted) setState(() => _state = _DialogState.info);
  }

  Future<void> _installApk() async {
    final file = _downloadedFile;
    if (file == null) return;

    try {
      // open_filex uses FileProvider internally on Android 7+,
      // generating the required content:// URI automatically.
      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        debugPrint('[UpdateDialog] Install result: ${result.type} — ${result.message}');
      }
    } catch (e) {
      debugPrint('[UpdateDialog] Install failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Installation failed. Please try again.')),
        );
      }
    }
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
