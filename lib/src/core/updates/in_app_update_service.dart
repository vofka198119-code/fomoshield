import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Google Play In-App Updates — flexible flow only (a small "update ready"
// snackbar the user can dismiss and keep using the app, never a blocking
// full-screen immediate update). Only ever takes effect on a device that
// installed the app FROM Play (checkForUpdate silently no-ops/throws
// otherwise — sideloaded/dev-flavor builds, emulators without Play
// Services, etc.), and only starts mattering from the release that first
// ships this file onward — it can't retroactively notify anyone still on
// an older build that predates it.
// ---------------------------------------------------------------------------

/// Checks Play Store for a newer version and, if one exists and a flexible
/// update is allowed, downloads it in the background and shows a snackbar
/// once it's ready to install. Safe to call repeatedly (cold start, each
/// resume) — a no-op if already on the latest version, and every failure
/// (no Play Services, not a Play-installed build, offline, ...) is
/// swallowed since this is a nice-to-have, not a critical path.
Future<void> checkForAppUpdate(GlobalKey<ScaffoldMessengerState> messengerKey) async {
  try {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability != UpdateAvailability.updateAvailable) return;
    if (!info.flexibleUpdateAllowed) return;

    final result = await InAppUpdate.startFlexibleUpdate();
    if (result != AppUpdateResult.success) return;

    await for (final status in InAppUpdate.installUpdateListener) {
      if (status == InstallStatus.downloaded) {
        _showRestartPrompt(messengerKey);
        break;
      }
      if (status == InstallStatus.failed || status == InstallStatus.canceled) {
        break;
      }
    }
  } catch (e) {
    debugPrint('🔄 in-app update check failed (non-fatal): $e');
  }
}

void _showRestartPrompt(GlobalKey<ScaffoldMessengerState> messengerKey) {
  final messenger = messengerKey.currentState;
  if (messenger == null) return;
  final context = messengerKey.currentContext;
  final l10n = context != null ? AppLocalizations.of(context) : null;
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n?.appUpdateReadyMessage ?? 'Update downloaded'),
      duration: const Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: l10n?.appUpdateRestartButton ?? 'Restart',
        onPressed: () => InAppUpdate.completeFlexibleUpdate(),
      ),
    ),
  );
}
