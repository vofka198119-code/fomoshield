import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/chart_line_glow_painter.dart';
import '../portfolio_value_history.dart';

// Deliberately the same card chrome, 220px plot and glow line as
// FundNavChart (which in turn mirrors Company Detail's PriceChart) — this is
// the third place in the app showing one daily snapshot per point, and it
// should not look like a fourth thing.
//
// No period tabs: the history only starts accumulating from the 2026-10-03
// update, so for the first weeks there is nothing to slice. Worth revisiting
// once a few months of points exist.
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
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _chartArea(l10n, points)),
          ),
        ],
      ),
    );
  }

  Widget _chartArea(AppLocalizations l10n, List<PortfolioValuePoint> points) {
    // One point is a dot, not a line. Says so plainly rather than drawing an
    // empty box — for the first day or two after the update this is what
    // everyone sees, and it should read as "come back tomorrow", not as a
    // broken chart.
    if (points.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.portfolioValueChartCollecting,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
        ),
      );
    }

    final values = points.map((p) => p.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final pad = range > 0 ? range * 0.08 : (maxY.abs() * 0.08 + 1);
    final chartMinY = minY - pad;
    final chartMaxY = maxY + pad;
    final isUp = values.last >= values.first;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final lineGradient = palette.chartLineGradient;
    final lineGlowColor = lineGradient?.colors.last ?? lineColor;
    final areaGradient = palette.chartAreaGradient;
    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final plotWidth = constraints.maxWidth;
        final pixelPoints = spots.map((s) {
          final xFraction = spots.length > 1 ? s.x / (spots.length - 1) : 0.0;
          final px = xFraction * plotWidth;
          final py = 220 * (1 - (s.y - chartMinY) / (chartMaxY - chartMinY));
          return Offset(px, py);
        }).toList();

        return Stack(
          children: [
            CustomPaint(
              size: Size(plotWidth, 220),
              painter: ChartLineGlowPainter(
                pixelPoints: pixelPoints,
                color: lineGlowColor,
              ),
            ),
            LineChart(
              LineChartData(
                minY: chartMinY,
                maxY: chartMaxY,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient:
                        lineGradient ??
                        LinearGradient(colors: [lineColor, lineColor]),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: areaGradient != null,
                      gradient: areaGradient,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
