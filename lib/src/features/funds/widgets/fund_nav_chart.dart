import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/daily_snapshot_chart.dart';
import '../models/fund.dart';

// Card chrome only — the plot itself is DailySnapshotChart, the same one the
// Portfolio value chart uses. Fund NAV is one recorded value per day, exactly
// the shape that widget exists for; before this it was a hand-thinned copy of
// Company Detail's PriceChart that had lost the scale labels, the end dot and
// the touch tooltip.
class FundNavChart extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundNavChart({super.key, required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CardFrame(
      padding: const EdgeInsets.symmetric(
        vertical: FomoShieldTheme.cardPadding,
      ),
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: themedHeaderText(
              l10n.etfFundDetailNavHistoryTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: themedDivider(palette, indent: 0, endIndent: 0),
          ),
          const SizedBox(height: 12),
          if (fund.navHistory.length < 2)
            SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  l10n.companyDetailChartNotEnoughData,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                ),
              ),
            )
          else
            DailySnapshotChart(
              palette: palette,
              points: [
                for (final p in fund.navHistory)
                  DailySnapshotPoint(at: p.date, value: p.navPerUnit),
              ],
            ),
        ],
      ),
    );
  }
}
