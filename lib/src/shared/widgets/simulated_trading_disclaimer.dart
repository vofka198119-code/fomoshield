// ---------------------------------------------------------------------------
// Simulated Trading & Non-Brokerage Disclaimer — shared between the
// order entry screens (buy/sell) and Stress Test's own Company Card, so
// the same legal text appears verbatim wherever the user can place a trade.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../l10n/gen/app_localizations.dart';

// Sits directly on the screen background (no card behind it) — resolves
// its own palette rather than being threaded a param, since it's reused
// across several unrelated screens (order entry, Stress Test's Company
// Card).
class SimulatedTradingDisclaimer extends ConsumerWidget {
  const SimulatedTradingDisclaimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
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
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.orderEntrySimulatedDisclaimerBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: palette.textHeader,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
