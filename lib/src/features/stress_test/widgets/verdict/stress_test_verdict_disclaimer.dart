// ---------------------------------------------------------------------------
// Stress Test — Verdict/Psychology Meter disclaimer. Mandatory: every
// screen that shows verdict scores, tier copy, or psychology-marker
// analysis ends with this — Session Complete (verdict_screen.dart), the
// generic per-marker "More" screen (verdict_marker_detail_screen.dart),
// and the Psychology Meter detail screen
// (stress_test_psychology_meter_screen.dart). One per screen, at the
// bottom — not per small condensed widget/card.
//
// Same centered title+body shape as stress_test_portfolio_balance_screen's
// _educationalDisclaimer() ("Company Card style"), but this is a distinct,
// stress-test-verdict-specific text — don't merge the two. Color is the
// same fixed muted gray as DisclaimerFooter's reference treatment
// (2026-08-25: unify every card-level disclaimer to that one look) — NOT
// palette-based.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../l10n/gen/app_localizations.dart';

class StressTestVerdictDisclaimer extends StatelessWidget {
  const StressTestVerdictDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disclaimerColor = ThemeV2.textSecondary.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            l10n.verdictDisclaimerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: disclaimerColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.verdictDisclaimerBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: disclaimerColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
