import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/year_pill.dart';

// ---------------------------------------------------------------------------
// FundInvestorFlowChart — monthly bar chart, Investors screen (2026-09-13
// ask, modeled on a generic monthly-bookings dashboard reference). Same
// card shell as FundNavChart (title/divider/220px plot) but a BarChart
// instead of a LineChart -- this app's first bar chart, built on the same
// fl_chart dependency FundNavChart already uses rather than adding a new
// package. One reusable widget, two call sites on the Investors screen:
// inflow (subscribes) in ThemeV2.success, outflow (redeems) in
// ThemeV2.loss -- same directional-color convention FundNavChart itself
// uses (green when NAV is up, red when down), not a themed-per-admin-theme
// color, since inflow/outflow is a real financial direction, not a UI
// action button.
//
// monthlyValues is a HEADCOUNT (distinct investors, bots included) per
// month, NOT a dollar sum -- corrected same day after the first pass
// wrongly showed $ amounts; fundService.js's getFundInvestorFlows counts
// distinct user_id per month now.
// ---------------------------------------------------------------------------
class FundInvestorFlowChart extends StatelessWidget {
  final String title;
  final List<double> monthlyValues;
  final Color barColor;
  final AppPalette palette;
  final int selectedYear;
  final VoidCallback onTapYear;

  const FundInvestorFlowChart({
    super.key,
    required this.title,
    required this.monthlyValues,
    required this.barColor,
    required this.palette,
    required this.selectedYear,
    required this.onTapYear,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final maxValue = monthlyValues.fold<double>(
      0,
      (m, v) => v > m ? v : m,
    );
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;

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
                    title,
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
                  maxY: chartMaxY,
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  // Always-on value label above each non-empty bar, not a
                  // tap tooltip -- showingTooltipIndicators (set per group
                  // below) forces it to render permanently; a transparent,
                  // zero-padding "tooltip" is the fl_chart mechanism for
                  // that, since it has no separate "permanent bar label"
                  // API of its own.
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 6,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            rod.toY.toInt().toString(),
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
                          // Capped to 3 letters (no period) -- Russian's
                          // full DateFormat.MMM abbreviations ("февр.",
                          // "июнь") run into each other across 12 narrow
                          // bars; English's own 3-letter form (Jan, Feb...)
                          // already fits, so this is a no-op there.
                          final rawLabel = DateFormat.MMM(
                            locale,
                          ).format(DateTime(2000, index + 1, 1)).replaceAll('.', '');
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
                            toY: monthlyValues[i],
                            color: barColor,
                            width: 12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                        showingTooltipIndicators: monthlyValues[i] > 0
                            ? [0]
                            : [],
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

