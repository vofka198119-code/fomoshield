import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/chart_line_glow_painter.dart';
import '../models/fund.dart';

// Same card chrome/proportions as Company Detail's PriceChart (light-card
// skin, 220px plot, glow line) — no period tabs, since fund NAV is one
// daily snapshot per point rather than multi-resolution candles.
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
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _chartArea(context, l10n)),
          ),
        ],
      ),
    );
  }

  Widget _chartArea(BuildContext context, AppLocalizations l10n) {
    final values = fund.navHistory.map((p) => p.navPerUnit).toList();
    if (values.length < 2) {
      return Center(
        child: Text(
          l10n.companyDetailChartNotEnoughData,
          style: TextStyle(fontSize: 13, color: palette.textBody),
        ),
      );
    }

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final pad = range > 0 ? range * 0.08 : maxY * 0.08;
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
