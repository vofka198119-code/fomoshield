import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Admin Badge — small red pill marking the hardcoded admin account.
// Extracted from employee_identity_card.dart (2026-09-14, FundTeamCard
// needed the same badge for a fund's head row) so both call sites share
// one definition instead of two copies drifting apart.
// ---------------------------------------------------------------------------
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ThemeV2.loss.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ThemeV2.loss, width: 1),
      ),
      child: Text(
        l10n.etfAdminBadge,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: ThemeV2.loss,
        ),
      ),
    );
  }
}
