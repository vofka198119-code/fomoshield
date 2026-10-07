import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/daily_snapshot_chart.dart';
import '../models/fund.dart';
import '../providers/fund_chart_hover_provider.dart';

// The fund's whole balance over time, for the management panel — the same
// number FundBalanceCard shows live, drawn on the same daily points the
// public card uses for unit price. Card chrome only; the plot is the shared
// DailySnapshotChart, so this looks and behaves exactly like the Portfolio
// value chart it was asked to mirror.
//
// Days with no stored balance are skipped rather than drawn as zero: rows
// written before the server started returning `aum` have none, and a dip to
// zero would read as the fund having briefly gone broke.
class FundBalanceHistoryChart extends ConsumerWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundBalanceHistoryChart({
    super.key,
    required this.fund,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final points = [
      for (final p in fund.navHistory)
        if (p.aum != null) DailySnapshotPoint(at: p.date, value: p.aum!),
    ];

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
              l10n.etfFundBalanceHistoryTitle,
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
          if (points.length < 2)
            SizedBox(
              height: 220,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.portfolioValueChartCollecting,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.textBody,
                    ),
                  ),
                ),
              ),
            )
          else
            DailySnapshotChart(
              palette: palette,
              points: points,
              // Hand the held day to the BALANCE card above, so the big
              // number there follows the finger the same way a fund's price
              // header follows its NAV chart.
              onHoverChanged: (point, previous) {
                ref.read(fundBalanceHoverProvider(fund.id).notifier).state =
                    point == null ? null : (point: point, previous: previous);
              },
            ),
        ],
      ),
    );
  }
}
