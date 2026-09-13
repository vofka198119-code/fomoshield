import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/year_pill.dart';

// ---------------------------------------------------------------------------
// FundMonthlyLineChart — reusable monthly $ line chart for the Charts
// screen (2026-09-13, generalized the same day from the original
// Balance-History-only widget so NAV-per-unit could reuse it verbatim
// instead of a copy-pasted near-duplicate). Modeled on a generic
// "User Growth" line-chart dashboard reference: the broken/curved line
// itself, a real left $ axis, bottom month labels in the same style as
// FundInvestorFlowChart's bars, and the same year-picker header. Unlike
// FundNavChart (the public fund detail screen's own line chart, which
// deliberately hides every axis for a minimal sparkline look with a
// custom glow overlay), this one shows real axes on purpose, so it
// doesn't reuse that widget's glow-painter approach -- a plain fl_chart
// LineChart is enough here.
//
// The left $ axis is a SEPARATE, non-scrolling column next to the
// horizontally-scrollable plot (fl_chart's own leftTitles is disabled
// inside the scrollable LineChart) -- putting the axis inside the same
// scroll view it first shipped with meant swiping right to see later
// months scrolled the $ scale off-screen along with the data, leaving no
// reference at all (caught in review before it reached the device).
//
// [axisLabelFormatter] is the one thing that actually differs between
// call sites: Balance History's AUM values want compact "$150K" rounding
// ([compactUsdAxisLabel], the default), NAV-per-unit's small per-share
// values ($9.50-ish) want plain 2-decimal formatting instead.
//
// The plot itself is sized wider than the card and wrapped in a
// horizontal scroll view so 12 months of labels always have breathing
// room regardless of screen width, per the explicit "swipe if it doesn't
// fit" ask, rather than shrinking fonts further.
// ---------------------------------------------------------------------------

/// Default [FundMonthlyLineChart.axisLabelFormatter] — compact "$1.2M"/
/// "$150K"/"$500" rounding, for chart series in the thousands-to-millions
/// range (AUM). NOT suitable for small per-unit values (NAV) -- those
/// pass their own plain-decimal formatter instead.
String compactUsdAxisLabel(double value) {
  final sign = value < 0 ? '-' : '';
  final absValue = value.abs();
  if (absValue >= 1000000) {
    return '$sign\$${(absValue / 1000000).toStringAsFixed(1)}M';
  }
  if (absValue >= 1000) {
    return '$sign\$${(absValue / 1000).toStringAsFixed(0)}K';
  }
  return '$sign\$${absValue.toStringAsFixed(0)}';
}

const double _plotHeight = 220;
const double _plotWidthPerMonth = 60;
const double _leftAxisWidth = 50;

class FundMonthlyLineChart extends StatelessWidget {
  final String title;
  final List<double?> monthlyValues;
  final AppPalette palette;
  final int selectedYear;
  final VoidCallback onTapYear;
  final String Function(double value) axisLabelFormatter;

  const FundMonthlyLineChart({
    super.key,
    required this.title,
    required this.monthlyValues,
    required this.palette,
    required this.selectedYear,
    required this.onTapYear,
    this.axisLabelFormatter = compactUsdAxisLabel,
  });

  /// Rounds a raw step (e.g. 13,842) to a "nice" 1/2/5 × 10^n value (e.g.
  /// 10,000) — fl_chart's own default interval picker doesn't do this, and
  /// left uninterval'd it also renders an extra label pinned exactly at
  /// the raw min/max on top of the regular ticks, duplicating whatever
  /// tick already sits nearby (confirmed on-device: "$173K" over "$170K").
  double _niceInterval(double rawStep) {
    if (rawStep <= 0) return 1;
    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor())
        .toDouble();
    final residual = rawStep / magnitude;
    final niceResidual = residual > 5
        ? 10
        : residual > 2
        ? 5
        : residual > 1
        ? 2
        : 1;
    return niceResidual * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final points = <int, double>{
      for (int i = 0; i < monthlyValues.length; i++)
        if (monthlyValues[i] != null) i: monthlyValues[i]!,
    };

    Widget plotArea;
    if (points.isEmpty) {
      plotArea = SizedBox(
        height: _plotHeight,
        child: Center(
          child: Text(
            l10n.companyDetailChartNotEnoughData,
            style: TextStyle(fontSize: 13, color: palette.textBody),
          ),
        ),
      );
    } else {
      final values = points.values.toList();
      final minY = values.reduce((a, b) => a < b ? a : b);
      final maxY = values.reduce((a, b) => a > b ? a : b);
      final range = maxY - minY;
      final pad = range > 0
          ? range * 0.15
          : (maxY.abs() > 0 ? maxY.abs() * 0.15 : 1);
      final rawMinY = minY - pad;
      final rawMaxY = maxY + pad;
      // Snap the axis bounds AND the tick interval to the same "nice" step
      // so every rendered label lands on a clean multiple with no stray
      // edge label duplicating the nearest regular tick.
      final interval = _niceInterval((rawMaxY - rawMinY) / 5);
      final chartMinY = (rawMinY / interval).floor() * interval;
      final chartMaxY = (rawMaxY / interval).ceil() * interval;

      plotArea = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeftAxis(
            chartMinY: chartMinY,
            chartMaxY: chartMaxY,
            interval: interval,
            formatter: axisLabelFormatter,
            palette: palette,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                // minX/maxX below span 12 units (-0.5..11.5, the extra
                // half-month margin on each side included) -- same
                // per-month density as before the margin was added.
                width: _plotWidthPerMonth * 12,
                height: _plotHeight,
                child: _chart(points, locale, chartMinY, chartMaxY, interval),
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
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: plotArea,
          ),
        ],
      ),
    );
  }

  Widget _chart(
    Map<int, double> points,
    String locale,
    double chartMinY,
    double chartMaxY,
    double interval,
  ) {
    final sortedKeys = points.keys.toList()..sort();
    final isUp = points[sortedKeys.last]! >= points[sortedKeys.first]!;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final lineGradient = palette.chartLineGradient;
    final areaGradient = palette.chartAreaGradient;
    final spots = [
      for (final key in sortedKeys) FlSpot(key.toDouble(), points[key]!),
    ];

    return LineChart(
      LineChartData(
        // Half a month of margin on each side -- January/December sat
        // exactly on the plot's edge otherwise, clipping their bottom
        // labels in half (confirmed on-device: "де" instead of "дек").
        minX: -0.5,
        maxX: 11.5,
        minY: chartMinY,
        maxY: chartMaxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => palette.card,
            getTooltipItems: (touchedSpots) => touchedSpots
                .map(
                  (spot) => LineTooltipItem(
                    formatUsd(spot.y),
                    TextStyle(
                      color: palette.textHeader,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          // The $ axis is now the separate, non-scrolling _LeftAxis column
          // next to this chart -- see this file's own header comment.
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
              interval: 1,
              // Safe to disable here now that minX/maxX (-0.5/11.5) no
              // longer sit exactly on a real tick (0/11) -- forced
              // min/max labels used to coincide with the real edge ticks
              // and were harmless, but once minX/maxX became pure margin
              // the forced pair duplicated "дек" (confirmed on-device).
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index > 11) {
                  return const SizedBox.shrink();
                }
                // Same 3-letter cap as FundInvestorFlowChart's bottom
                // axis, for the same reason (Russian's full month
                // abbreviations overrun each other across 12 labels).
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
                    style: TextStyle(fontSize: 10, color: palette.textBody),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient:
                lineGradient ?? LinearGradient(colors: [lineColor, lineColor]),
            barWidth: 2.5,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: areaGradient != null,
              gradient: areaGradient,
            ),
          ),
        ],
      ),
    );
  }
}

/// The chart's own $ scale, pinned outside the horizontal scroll view so
/// it stays visible while swiping through months. Manually positions each
/// tick label at the same pixel row fl_chart's own (now-disabled) left
/// axis would have used, via the identical linear-interpolation formula
/// LineChart uses internally (portion of the Y range -> fraction of
/// _plotHeight from the bottom).
class _LeftAxis extends StatelessWidget {
  final double chartMinY;
  final double chartMaxY;
  final double interval;
  final String Function(double value) formatter;
  final AppPalette palette;

  const _LeftAxis({
    required this.chartMinY,
    required this.chartMaxY,
    required this.interval,
    required this.formatter,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final range = chartMaxY - chartMinY;
    final tickCount = range > 0 ? (range / interval).round() : 0;
    final ticks = [
      for (int i = 0; i <= tickCount; i++) chartMinY + i * interval,
    ];

    return SizedBox(
      width: _leftAxisWidth,
      height: _plotHeight,
      child: Stack(
        children: [
          for (final tick in ticks)
            Positioned(
              // Same "portion of the range, measured from the top" fl_chart
              // itself uses for a vertical axis; -7 centers the ~14px-tall
              // label line on that pixel row instead of hanging below it.
              // Clamped to stay fully inside the box -- the topmost/
              // bottommost ticks sit exactly at the plot's edges (0 and
              // _plotHeight), so centering them uncapped pushed the label
              // partly above/below the SizedBox and into whatever sits
              // next to it (confirmed on-device: a clipped "$180K" bleeding
              // into the divider above).
              top: (range > 0
                      ? _plotHeight * (1 - (tick - chartMinY) / range) - 7
                      : _plotHeight / 2 - 7)
                  .clamp(0.0, _plotHeight - 14),
              right: 4,
              child: Text(
                formatter(tick),
                style: TextStyle(fontSize: 10, color: palette.textBody),
              ),
            ),
        ],
      ),
    );
  }
}
