import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';

// ---------------------------------------------------------------------------
// The two ways to act on the drift, and the only place either of them starts.
//
// The card itself does nothing but navigate: each button opens the preview
// screen, which fetches the plan, shows every trade it would make, and asks
// for the decision there. Nothing is proposed from this card — a button that
// filed thirty trades on one tap would be a trap, however it was labelled.
//
// Same shape as the target-weights card beside it: say what this is, then
// one button per route.
// ---------------------------------------------------------------------------

class FundRebalanceCard extends StatelessWidget {
  final String fundId;
  final AppPalette palette;
  final AppLocalizations l10n;

  /// Whether this person may propose trades at all. Mirrored server-side —
  /// this only decides whether the buttons are offered.
  final bool canPropose;

  const FundRebalanceCard({
    super.key,
    required this.fundId,
    required this.palette,
    required this.l10n,
    required this.canPropose,
  });

  @override
  Widget build(BuildContext context) {
    if (!canPropose) return const SizedBox.shrink();

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Автоматическая", his wording — and the line under it is what
          // keeps that word honest: in most finance apps "automatic" means
          // "runs by itself on a schedule", which this does not. It computes
          // automatically; it commits to nothing (2026-10-10).
          themedHeaderText(
            l10n.etfRebalanceCardTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          Text(
            l10n.etfRebalanceCardIntro,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          const SizedBox(height: 16),
          _option(
            context,
            mode: 'cash',
            title: l10n.etfRebalanceModeCash,
            hint: l10n.etfRebalanceModeCashHint,
          ),
          const SizedBox(height: 16),
          _option(
            context,
            mode: 'full',
            title: l10n.etfRebalanceModeFull,
            hint: l10n.etfRebalanceModeFullHint,
          ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required String mode,
    required String title,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: brandCtaButton(
            palette: palette,
            label: title,
            onTap: () => context.push('/funds/$fundId/rebalance?mode=$mode'),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hint,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      ],
    );
  }
}
