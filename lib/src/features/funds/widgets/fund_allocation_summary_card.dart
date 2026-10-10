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
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund.dart';

// ---------------------------------------------------------------------------
// What the fund holds, in one line and a button — the Balancing screen's own
// entry to the full breakdown.
//
// Same shape as the target-weights card below it: say what this is, give the
// one number worth seeing without opening anything, then one button. The full
// list lives on its own screen now, so opening it no longer buries the plan
// and the rebalance under forty bars (2026-10-10).
// ---------------------------------------------------------------------------

class FundAllocationSummaryCard extends StatelessWidget {
  final String fundId;
  final List<FundHolding> holdings;
  final AppPalette palette;
  final AppLocalizations l10n;

  const FundAllocationSummaryCard({
    super.key,
    required this.fundId,
    required this.holdings,
    required this.palette,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final invested = holdings.fold<double>(0, (sum, h) => sum + h.value);

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfAssetAllocationChartTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          Text(
            l10n.etfAllocationIntro,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  holdings.isEmpty
                      ? l10n.etfAssetAllocationEmptyText
                      : l10n.etfAllocationCount(holdings.length),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
              ),
              if (holdings.isNotEmpty)
                Text(
                  formatUsd(invested),
                  style: interNums(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
            ],
          ),
          if (holdings.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: brandCtaButton(
                palette: palette,
                label: l10n.etfAllocationOpenButton,
                onTap: () => context.push('/funds/$fundId/allocation'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
