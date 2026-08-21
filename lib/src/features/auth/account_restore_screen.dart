// ---------------------------------------------------------------------------
// Account Restore Screen — full-block gate shown instead of the app when
// the signed-in account is pending deletion (2026-08-16). Reached via
// resolvePostAuthRoute() in auth_providers.dart, from SplashScreen's
// cold-start resume and both AuthScreen sign-in paths. There is no way
// into the app from here except Restore — that's the point (user's
// explicit choice: full block, not a dismissible banner).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/services/finnhub_service.dart';
import '../disclaimer/disclaimer_providers.dart';
import 'auth_providers.dart';

class AccountRestoreScreen extends ConsumerStatefulWidget {
  final int daysRemaining;
  final DateTime? deleteAt;

  const AccountRestoreScreen({
    super.key,
    required this.daysRemaining,
    this.deleteAt,
  });

  @override
  ConsumerState<AccountRestoreScreen> createState() =>
      _AccountRestoreScreenState();
}

class _AccountRestoreScreenState extends ConsumerState<AccountRestoreScreen> {
  bool _busy = false;

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      await FinnhubService().restoreAccount();
      if (!mounted) return;
      final disclaimerAccepted = await ref.read(
        isDisclaimerAcceptedProvider.future,
      );
      if (!mounted) return;
      context.go(disclaimerAccepted ? '/home' : '/disclaimer');
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.accountRestoreScreenRestoreFailed,
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: ThemeV2.loss,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await clearAllSessionData();
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deleteAt = widget.deleteAt;
    final dateLabel = deleteAt != null
        ? DateFormat('MMMM d, yyyy').format(deleteAt.toLocal())
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.restore_from_trash_rounded,
                size: 64,
                color: ThemeV2.warning,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.accountRestoreScreenTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.daysRemaining > 0
                    ? '${l10n.accountRestoreScreenDaysLeft(widget.daysRemaining)}'
                          '${dateLabel != null ? l10n.accountRestoreScreenDeletionWarningSuffix(dateLabel) : ''}.'
                    : l10n.accountRestoreScreenAboutToErase,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: ThemeV2.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _restore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          l10n.accountRestoreScreenRestoreButton,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy ? null : _signOut,
                child: Text(
                  l10n.profileSignOut,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ThemeV2.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
