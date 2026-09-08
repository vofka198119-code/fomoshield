import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund.dart';

// Light-card skin, matches Company Detail's KeyMetricsSection. Fund-flavored
// metrics: AUM, units outstanding, number of holdings.
class FundKeyMetricsCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundKeyMetricsCard({
    super.key,
    required this.fund,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(String, String)>[
      (l10n.etfFundDetailAumLabel, '\$${fund.aum.toStringAsFixed(0)}'),
      (l10n.etfFundDetailUnitsLabel, fund.unitsOutstanding.toStringAsFixed(0)),
      (l10n.etfFundDetailHoldingsCountLabel, fund.holdings.length.toString()),
    ];

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.companyDetailKeyMetricsTitle,
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
