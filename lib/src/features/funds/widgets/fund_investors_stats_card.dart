import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_investor.dart';

// ---------------------------------------------------------------------------
// FundInvestorsStatsCard — Investors screen's first widget (2026-09-13 ask).
// Same title/divider/row shell as FundKeyMetricsCard/FundBalanceCard.
// Bankruptcy Payout is a PREVIEW of the solvent-case payout formula
// (invested * 1.05 per investor, summed — see
// [[fomoshield_etf_bankruptcy_flow_spec]]), not a promise the fund can
// always honor -- the real liquidation flow (not yet built) still has to
// fall back to a pro-rata split if the fund's actual balance falls short.
// ---------------------------------------------------------------------------
class FundInvestorsStatsCard extends StatelessWidget {
  final List<FundInvestor> investors;
  final AppPalette palette;

  const FundInvestorsStatsCard({
    super.key,
    required this.investors,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalInvested = investors.fold<double>(0, (s, i) => s + i.invested);
    final items = <(String, String)>[
      (l10n.etfInvestorsStatsTotalLabel, formatUsd(totalInvested)),
      (l10n.etfInvestorsStatsCountLabel, investors.length.toString()),
      (
        l10n.etfInvestorsStatsBankruptcyPayoutLabel,
        formatUsd(totalInvested * 1.05),
      ),
    ];

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfInvestorsStatsTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  items[i].$1,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
                themedPriceText(
                  items[i].$2,
                  palette,
                  interNums(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
