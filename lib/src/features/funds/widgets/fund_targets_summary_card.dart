import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_target_weight.dart';

// ---------------------------------------------------------------------------
// Target weights, as they appear on the Balancing screen: what they are, how
// many are set, and the way in.
//
// The editor itself moved to its own screen (2026-10-10). Inline, it sat
// under two other cards, so reaching the steppers meant scrolling past
// everything the plan is compared against — and the same screen then carried
// three different jobs at once. Same shape as the rebalance card beside it:
// say what this is, then one button.
// ---------------------------------------------------------------------------

class FundTargetsSummaryCard extends StatelessWidget {
  final String fundId;
  final List<FundTargetWeight> targets;
  final AppPalette palette;
  final AppLocalizations l10n;

  /// Whether this person may change the plan. Without the right, the card
  /// still says what the plan is — it just offers no way in.
  final bool canEdit;

  const FundTargetsSummaryCard({
    super.key,
    required this.fundId,
    required this.targets,
    required this.palette,
    required this.l10n,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlan = targets.isNotEmpty;
    final total = targets.fold<double>(0, (sum, t) => sum + t.targetPercent);

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfBalancingTargetTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          Text(
            l10n.etfBalancingTargetsIntro,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hasPlan
                      ? l10n.etfBalancingTargetsCount(targets.length)
                      : l10n.etfBalancingTargetsEmpty,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
              ),
              if (hasPlan)
                Text(
                  '${total.toStringAsFixed(2)}%',
                  style: interNums(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
            ],
          ),
          if (canEdit) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: brandCtaButton(
                palette: palette,
                label: hasPlan
                    ? l10n.etfBalancingTargetsEditButton
                    : l10n.etfBalancingTargetsSetButton,
                onTap: () => context.push('/funds/$fundId/targets'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              l10n.etfBalancingReadOnlyNote,
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            ),
          ],
        ],
      ),
    );
  }
}
