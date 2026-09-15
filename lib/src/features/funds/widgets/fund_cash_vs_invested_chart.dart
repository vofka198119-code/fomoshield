import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/chart_left_axis.dart';
import '../../../shared/widgets/year_pill.dart';
import 'fund_monthly_line_chart.dart' show compactUsdAxisLabel;

// Its own (narrower) per-month slot width -- FundMonthlyLineChart's 60px
// was sized for a continuous line + dot markers; a two-rod bar group only
// needs ~21px of content, so keeping that width left visibly wide gaps
// between months (2026-09-13 ask, confirmed on-device).
const double _plotWidthPerMonth = 40;

// ---------------------------------------------------------------------------
// FundCashVsInvestedChart — Charts screen widget (2026-09-13, last of the
// planned trio needing Migration 025's fund_nav_snapshots.cash column).
// Grouped bar chart (two rods per month, side by side) rather than
// FundMonthlyLineChart's single line -- user explicitly asked for bars
// over the initial dual-line version ("точки неумесны... два бара рядом").
// Fixed colors (ThemeV2.primary for invested, ThemeV2.warning for cash)
// rather than palette.accentPrimary/accentSecondary: the Standard theme
// sets both of those to the SAME color (see app_palette.dart), which would
// make the two series indistinguishable -- same reasoning
// FundInvestorFlowChart's fixed ThemeV2.success/loss bars already follow.
// Still keeps the left $ axis (ChartLeftAxis) that FundInvestorFlowChart/
// FundCommissionChart skip -- those stay small single-digit-to-low-hundreds
// values readable from permanent bar-top labels alone, but cash/invested
// run into the tens-of-thousands, where an axis reads better than a label
// on every one of 24 bars.
// ---------------------------------------------------------------------------
class FundCashVsInvestedChart extends StatelessWidget {
  final List<double?> monthlyCash;
  final List<double?> monthlyInvested;
  final AppPalette palette;
  final int selectedYear;
  final VoidCallback onTapYear;

  const FundCashVsInvestedChart({
    super.key,
    required this.monthlyCash,
    required this.monthlyInvested,
    required this.palette,
    required this.selectedYear,
    required this.onTapYear,
  });

  static const _cashColor = ThemeV2.warning;
  static const _investedColor = ThemeV2.primary;

  static Widget _legendDot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final allValues = [
      ...monthlyCash.whereType<double>(),
      ...monthlyInvested.whereType<double>(),
    ];

    Widget plotArea;
    if (allValues.isEmpty) {
      plotArea = SizedBox(
        height: chartPlotHeight,
        child: Center(
          child: Text(
            l10n.companyDetailChartNotEnoughData,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
        ),
      );
    } else {
      // Bars represent an absolute $ amount, not a delta -- unlike the
      // line-chart widgets, the floor is always 0, never padded below the
      // lowest data point.
      final maxY = allValues.reduce((a, b) => a > b ? a : b);
      final rawMaxY = maxY > 0 ? maxY * 1.15 : 1.0;
      final interval = niceAxisInterval(rawMaxY / 5);
      const chartMinY = 0.0;
      final chartMaxY = (rawMaxY / interval).ceil() * interval;

      plotArea = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartLeftAxis(
            chartMinY: chartMinY,
            chartMaxY: chartMaxY,
            interval: interval,
            formatter: compactUsdAxisLabel,
            palette: palette,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _plotWidthPerMonth * 12,
                height: chartPlotHeight,
                child: _chart(locale, chartMaxY),
              ),
            ),
          ),
        ],
      );
    }

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
                    l10n.etfCashVsInvestedChartTitle,
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
            child: Row(
              children: [
                _legendDot(_cashColor),
                const SizedBox(width: 6),
                Text(
                  l10n.etfCashVsInvestedCashLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textBody,
                  ),
                ),
                const SizedBox(width: 16),
                _legendDot(_investedColor),
                const SizedBox(width: 6),
                Text(
                  l10n.etfCashVsInvestedInvestedLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textBody,
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: plotArea,
          ),
        ],
      ),
    );
  }

  Widget _chart(String locale, double chartMaxY) {
    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => palette.card,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  formatUsd(rod.toY),
                  GoogleFonts.inter(
                    color: palette.textHeader,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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
                    style: GoogleFonts.inter(fontSize: 10, color: palette.textBody),
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
              barsSpace: 3,
              barRods: [
                BarChartRodData(
                  toY: monthlyCash[i] ?? 0,
                  color: _cashColor,
                  width: 9,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
                BarChartRodData(
                  toY: monthlyInvested[i] ?? 0,
                  color: _investedColor,
                  width: 9,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
