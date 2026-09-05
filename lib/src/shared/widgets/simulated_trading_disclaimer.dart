// ---------------------------------------------------------------------------
// Simulated Trading & Non-Brokerage Disclaimer — shared between the
// order entry screens (buy/sell) and Stress Test's own Company Card, so
// the same legal text appears verbatim wherever the user can place a trade.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

// Sits directly on the screen background (no card behind it). Color is
// deliberately the same fixed muted gray as DisclaimerFooter's reference
// treatment (2026-08-25: unify every card-level disclaimer to that one
// look) — same optional [AppPalette.disclaimerColor] override as
// DisclaimerFooter (2026-09-05), null everywhere except Black & White.
class SimulatedTradingDisclaimer extends StatelessWidget {
  final AppPalette? palette;

  const SimulatedTradingDisclaimer({super.key, this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final disclaimerColor =
        palette?.disclaimerColor ?? ThemeV2.textSecondary.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            l10n.orderEntrySimulatedDisclaimerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: disclaimerColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.orderEntrySimulatedDisclaimerBody,
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
