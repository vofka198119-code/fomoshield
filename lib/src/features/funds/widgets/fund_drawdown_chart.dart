import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/year_pill.dart';

// ---------------------------------------------------------------------------
// FundDrawdownChart — Charts screen's monthly drawdown bar chart
// (2026-09-13, redesigned same day per explicit "как в притоке/оттоке
// инвесторов" ask): bars growing DOWN from the 0% ceiling, replacing an
// earlier area/line-chart version. Same conventions as
// FundInvestorFlowChart: no left axis, a permanent value label at each
// non-zero bar (via showingTooltipIndicators, not a tap tooltip), 3-letter
// bottom month labels, year-picker header. Data is
// FundBalanceHistory.drawdownPercent -- a pure client-side derivative of
// navPerUnit, no separate backend endpoint.
//
// Bars sidestep the previous version's edge-clipping bug for free: a rod
// ending exactly at 0% has no dot marker to bleed past the plot's own
// top edge the way the old line chart's point did.
// ---------------------------------------------------------------------------
class FundDrawdownChart extends StatelessWidget {
  final List<double?> monthlyDrawdownPercent;
  final AppPalette palette;
  final int selectedYear;
  final VoidCallback onTapYear;

  const FundDrawdownChart({
    super.key,
    required this.monthlyDrawdownPercent,
    required this.palette,
    required this.selectedYear,
    required this.onTapYear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final values = [for (final v in monthlyDrawdownPercent) v ?? 0.0];
    final minValue = values.reduce((a, b) => a < b ? a : b);
    // Ceiling is always exactly 0% (a drawdown chart never goes above the
    // running peak); the floor gets a little headroom below the deepest
    // drawdown so its bar/label isn't flush against the plot edge.
    final chartMinY = minValue == 0 ? -1.0 : minValue * 1.2;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: themedHeaderText(
                    l10n.etfDrawdownChartTitle,
                    palette,
                    FomoShieldTheme.cardTitle(),
                  ),
                ),
                const SizedBox(width: 8),
                YearPill(
                  year: selectedYear,
                  onTap: onTapYear,
                  palette: palette,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: themedDivider(palette, indent: 0, endIndent: 0),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: 0,
                  minY: chartMinY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  // Always-on value label below each non-zero bar (bars
                  // grow down, so the label sits below the rod's far end),
                  // not a tap tooltip -- same recipe as
                  // FundInvestorFlowChart's own bar labels.
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 6,
                      direction: TooltipDirection.bottom,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            '${rod.toY.toStringAsFixed(1)}%',
                            TextStyle(
                              color: palette.textHeader,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index > 11) {
                            return const SizedBox.shrink();
                          }
                          final rawLabel = DateFormat.MMM(locale)
                              .format(DateTime(2000, index + 1, 1))
                              .replaceAll('.', '');
                          final label = rawLabel.length > 3
                              ? rawLabel.substring(0, 3)
                              : rawLabel;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                color: palette.textBody,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (int i = 0; i < 12; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            fromY: 0,
                            toY: values[i],
                            color: ThemeV2.loss,
                            width: 12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                        showingTooltipIndicators: values[i] < 0 ? [0] : [],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
