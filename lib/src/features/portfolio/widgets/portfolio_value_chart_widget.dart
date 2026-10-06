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
import '../portfolio_value_history.dart';

// Card chrome only — the plot itself is DailySnapshotChart, shared with every
// other chart in the app that holds one recorded value per day. It brings the
// min/max scale labels, the dot on the last point, the hold-to-read tooltip
// and the period tabs, all matching Company Detail's PriceChart.
class PortfolioValueChartWidget extends ConsumerWidget {
  final AppPalette palette;

  const PortfolioValueChartWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final points = ref
        .watch(portfolioValueHistoryProvider)
        .maybeWhen(data: (p) => p, orElse: () => const <PortfolioValuePoint>[]);

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
              l10n.portfolioValueChartTitle,
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
            _collecting(l10n)
          else
            DailySnapshotChart(
              palette: palette,
              points: [
                for (final p in points)
                  DailySnapshotPoint(at: p.at, value: p.value),
              ],
            ),
        ],
      ),
    );
  }

  // One point is a dot, not a line. Says so plainly rather than drawing an
  // empty box — for the first day or two after the update this is what
  // everyone sees, and it should read as "come back tomorrow", not as a
  // broken chart.
  Widget _collecting(AppLocalizations l10n) => SizedBox(
    height: 220,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          l10n.portfolioValueChartCollecting,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      ),
    ),
  );
}
