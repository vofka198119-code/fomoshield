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
            'Could not restore your account. Please try again.',
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
                'Account Scheduled for Deletion',
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
                    ? 'You have $_dayWord left to restore this account'
                        '${dateLabel != null ? ' — after $dateLabel it will be permanently erased, with no way to recover it' : ''}.'
                    : 'This account is about to be permanently erased, with '
                          'no way to recover it.',
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
                          'Restore Account',
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
                  'Sign Out',
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

  String get _dayWord {
    final n = widget.daysRemaining;
    return n == 1 ? '1 day' : '$n days';
  }
}
