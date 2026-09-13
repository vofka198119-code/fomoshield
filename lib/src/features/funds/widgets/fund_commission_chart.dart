import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/year_pill.dart';
import 'fund_monthly_line_chart.dart' show compactUsdAxisLabel;

// ---------------------------------------------------------------------------
// FundCommissionChart — Charts screen's Broker Commission bar chart
// (2026-09-13 ask, next after Balance/NAV/Drawdown/Asset Allocation). Same
// bar-chart shell as FundInvestorFlowChart (permanent value label via
// showingTooltipIndicators, no left axis, 3-letter month labels, year
// picker) but dollar amounts instead of a headcount, so the bar label uses
// FundMonthlyLineChart's compact "$150"/"$1.2K" rounding rather than a
// plain int. A themed accent fill, not ThemeV2.success/loss -- commission
// paid isn't a directional "up=good, down=bad" signal the way inflow/
// outflow or NAV trend are, just a cost metric, so it takes the theme's own
// accent like every other neutral fund card.
// ---------------------------------------------------------------------------
class FundCommissionChart extends StatelessWidget {
  final List<double> monthlyCommission;
  final AppPalette palette;
  final int selectedYear;
  final VoidCallback onTapYear;

  const FundCommissionChart({
    super.key,
    required this.monthlyCommission,
    required this.palette,
    required this.selectedYear,
    required this.onTapYear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final maxValue = monthlyCommission.fold<double>(
      0,
      (m, v) => v > m ? v : m,
    );
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;
    final barColor = palette.accentPrimary;

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
                    l10n.etfCommissionChartTitle,
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
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 6,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            compactUsdAxisLabel(rod.toY),
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
                            toY: monthlyCommission[i],
                            color: barColor,
                            width: 12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                        showingTooltipIndicators: monthlyCommission[i] > 0
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
