import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/themed_header.dart';
import '../../../../../core/theme/themed_divider.dart';
import '../../../../../shared/widgets/card_frame.dart';
import '../../../../../shared/utils/currency_format.dart';
import '../../../../../shared/widgets/chart_line_glow_painter.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../../../market_clock/market_clock_dial.dart'
    show darkCardDecoration;
import '../../../../stress_test/stress_test_engine.dart' show ChartDataPoint;

// ---------------------------------------------------------------------------
// Stress Test sparkline chart card — per-symbol price chart for the "company
// card" within an active stress test. Visual design is a deliberate copy of
// company_detail/widgets/price_chart.dart and stress_test/widgets/
// market_value_chart.dart (straight thin line, no fill/grid/axis-title
// chrome, manual min/max/avg-cost price labels, custom hold-to-reveal touch
// tooltip+indicator, gradient period tabs) — all three should read as the
// same chart family. Data comes from the simulation's own
// session.priceHistory[symbol] + session.priceHistoryTimestamps[symbol]
// (real per-tick timestamps), not Finnhub — see stock_detail_screen.dart's
// _generateSparkData for how points are built and period-filtered.
// ---------------------------------------------------------------------------

enum StressTestSparkPeriod { d1, w1, m1, m3, y1 }

String _periodLabel(AppLocalizations l10n, StressTestSparkPeriod period) =>
    switch (period) {
      StressTestSparkPeriod.d1 => l10n.chartPeriod1D,
      StressTestSparkPeriod.w1 => l10n.chartPeriod1W,
      StressTestSparkPeriod.m1 => l10n.chartPeriod1M,
      StressTestSparkPeriod.m3 => l10n.chartPeriod3M,
      StressTestSparkPeriod.y1 => l10n.chartPeriod1Y,
    };

/// Time-bucket averaging: splits [domainStart, domainEnd] into [maxBuckets]
/// equal time slices and averages every raw point that falls in the same
/// slice into one point. A slice with only one raw point in it (e.g. a
/// widely-spaced old catch-up burst) passes through unchanged. This is what
/// actually fixes the "earthquake" look of raw 20s-tick data plotted
/// point-by-point (each rendered point is a local average, not one noisy
/// instant) without switching to curved/Bezier interpolation, which stays
/// off by design (see reference_chart_visual_standard.md).
List<ChartDataPoint> _downsampleForRender(
  List<ChartDataPoint> data,
  DateTime domainStart,
  DateTime domainEnd,
  int maxBuckets,
) {
  if (data.length <= 2) return data;
  final startMs = domainStart.millisecondsSinceEpoch;
  final endMs = domainEnd.millisecondsSinceEpoch;
  final rangeMs = endMs - startMs;
  if (rangeMs <= 0) return data;
  final bucketMs = rangeMs / maxBuckets;

  final buckets = <int, List<ChartDataPoint>>{};
  for (final p in data) {
    final idx = ((p.time.millisecondsSinceEpoch - startMs) / bucketMs)
        .floor()
        .clamp(0, maxBuckets - 1);
    (buckets[idx] ??= []).add(p);
  }

  final sortedKeys = buckets.keys.toList()..sort();
  final result = <ChartDataPoint>[];
  for (final k in sortedKeys) {
    final bucket = buckets[k]!;
    if (bucket.length == 1) {
      result.add(bucket.first);
    } else {
      final avgValue =
          bucket.map((p) => p.value).reduce((a, b) => a + b) / bucket.length;
      result.add(ChartDataPoint(bucket.last.time, avgValue));
    }
  }
  result[0] = data.first;
  result[result.length - 1] = data.last;
  return result;
}

class StockSparklineChart extends StatefulWidget {
  final bool ready;
  final List<ChartDataPoint> points;
  final double? avgPrice;
  final List<StressTestSparkPeriod> availablePeriods;
  final StressTestSparkPeriod selectedPeriod;
  final ValueChanged<StressTestSparkPeriod> onPeriodChanged;

  final AppPalette palette;

  /// Fires with the price at the touched point while the user is holding
  /// the chart, and with null the instant they let go — lets the parent
  /// screen's price header mirror the touched value while scrubbing, the
  /// same "trading app" behavior Company Detail's PriceChart already has
  /// via chartHoverPriceProvider. Optional — null means the parent hasn't
  /// wired a price header up to this chart.
  final ValueChanged<double?>? onTouchedPriceChanged;

  const StockSparklineChart({
    super.key,
    required this.ready,
    required this.points,
    required this.availablePeriods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.palette,
    this.avgPrice,
    this.onTouchedPriceChanged,
  });

  @override
  State<StockSparklineChart> createState() => _StockSparklineChartState();
}

class _StockSparklineChartState extends State<StockSparklineChart> {
  // Touch state for the custom date tooltip — same hold-to-reveal mechanic
  // as PriceChart/MarketValueChart: a quick tap/swipe (e.g. scrolling the
  // page) shows nothing, the indicator+tooltip only reveal after a
  // sustained hold.
  double? _touchDx;
  int? _touchedSpotIndex;

  static const _revealDelay = Duration(milliseconds: 1200);
  Timer? _touchHoldTimer;
  bool _touchRevealed = false;
  double? _pendingDx;
  int? _pendingSpotIndex;
  double? _pendingY;

  @override
  void didUpdateWidget(covariant StockSparklineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compares content, not list identity — _generateSparkData rebuilds a
    // fresh List instance on every ~20s engine tick even when the visible
    // period's data hasn't actually changed, which used to reset (and
    // effectively kill) the hold-to-reveal tooltip mid-hold.
    if (_pointsChanged(oldWidget.points, widget.points)) {
      _touchHoldTimer?.cancel();
      _touchHoldTimer = null;
      _touchRevealed = false;
      _touchDx = null;
      _touchedSpotIndex = null;
      widget.onTouchedPriceChanged?.call(null);
    }
  }

  bool _pointsChanged(List<ChartDataPoint> a, List<ChartDataPoint> b) {
    if (a.length != b.length) return true;
    if (a.isEmpty) return false;
    return a.first.time != b.first.time ||
        a.first.value != b.first.value ||
        a.last.time != b.last.time ||
        a.last.value != b.last.value;
  }

  @override
  void dispose() {
    _touchHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    // Only genuinely "still loading" gates the whole card (title/divider/
    // period tabs included) behind a spinner. Once ready, points.length < 2
    // is a real state of its own — e.g. a period whose daily-bucket
    // history hasn't accumulated 2 days yet — and needs the period tabs
    // to STAY visible so the user can switch to one that has data,
    // instead of being stuck looking at a spinner forever (that used to
    // be indistinguishable from "not loaded yet" here).
    if (!widget.ready) {
      return Container(
        height: 280,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: FomoShieldTheme.cardDecoration,
        child: Center(
          child: CircularProgressIndicator(
            color: palette.accentPrimary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return CardFrame(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
              l10n.stockSparklineChartTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _buildChartArea()),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: _periodSelector(),
          ),
        ],
      ),
    );
  }

  Widget _periodSelector() {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    return Row(
      children: widget.availablePeriods.map((period) {
        final isSelected = period == widget.selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              widget.onPeriodChanged(period);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: !isSelected
                  ? null
                  : palette.windowGradient != null
                  ? BoxDecoration(
                      gradient: palette.windowGradient,
                      borderRadius: BorderRadius.circular(6),
                    )
                  : darkCardDecoration(borderRadius: BorderRadius.circular(6)),
              child: Text(
                _periodLabel(l10n, period),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (palette.onWindow ?? Colors.white)
                      : palette.textBody,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartArea() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    DateTime domainStart;
    DateTime domainEnd;
    List<ChartDataPoint> points;
    if (widget.selectedPeriod == StressTestSparkPeriod.d1) {
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      points = widget.points
          .where(
            (p) => !p.time.isBefore(todayStart) && !p.time.isAfter(todayEnd),
          )
          .toList();
      if (points.length < 2) {
        return Center(
          child: Text(
            l10n.stressTestChartNotEnoughDataForPeriod,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: widget.palette.textBody,
            ),
          ),
        );
      }
      // Left edge anchors to wherever today's REAL data actually starts —
      // not literal midnight. A simulated holding can't backfill more than
      // ~5 real hours of catch-up, so pinning to midnight would show a
      // permanent empty gap every time the app was closed overnight. The
      // right edge stays fixed at midnight tomorrow so the line still
      // stops at "now" with empty space after it — a genuine "hasn't
      // happened yet" gap, not a missing-data one.
      domainStart = points.first.time;
      domainEnd = todayEnd;
    } else {
      // Every period longer than a day (including ALL) always stretches to
      // fill the chart's full width using whatever real data falls in the
      // window — explicit ask: unlike 1D, no "stop at now" empty space.
      points = widget.points;
      if (points.length < 2) {
        return Center(
          child: Text(
            l10n.stressTestChartNotEnoughDataForPeriod,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: widget.palette.textBody,
            ),
          ),
        );
      }
      domainStart = points.first.time;
      domainEnd = points.last.time;
    }

    points = _downsampleForRender(points, domainStart, domainEnd, 200);

    // 1D uses the fixed calendar-day domain computed above (so it can stop
    // short of the right edge); every other period's domain is just
    // [points.first, points.last], stretching to fill the full width.
    final minTimeMs = domainStart.millisecondsSinceEpoch.toDouble();
    final maxTimeMs = domainEnd.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTimeMs - minTimeMs;
    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      final t = points[i].time.millisecondsSinceEpoch.toDouble();
      final x = timeRange > 0
          ? ((t - minTimeMs) / timeRange).clamp(0.0, 1.0)
          : 0.0;
      spots.add(FlSpot(x, points[i].value));
    }

    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;

    final values = points.map((p) => p.value);
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final valueRange = maxValue - minValue;
    // 15% headroom each side — the line occupies ~70% of the chart's
    // height instead of nearly touching top/bottom, matching the
    // reference chart's proportions.
    final headroom = valueRange > 0 ? valueRange * 0.15 : maxValue * 0.15;
    final chartMinY = minValue - headroom;
    final chartMaxY = maxValue + headroom;

    final avgPrice = widget.avgPrice;
    final showAvgLine =
        avgPrice != null && avgPrice >= chartMinY && avgPrice <= chartMaxY;
    final horizontalLines = [
      if (showAvgLine)
        HorizontalLine(
          y: avgPrice,
          color: ThemeV2.textSecondary,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
    ];
    const chartHeight = 220.0;
    final avgLineTop = showAvgLine
        ? ((chartMaxY - avgPrice) / (chartMaxY - chartMinY)) * chartHeight
        : 0.0;

    // The touch-indicator line's own top stops at the date tooltip's bottom
    // edge instead of piercing straight through the box — same as
    // PriceChart/MarketValueChart.
    const dateTooltipHeight = 24.0;
    final touchLineTopY =
        chartMaxY - (dateTooltipHeight / chartHeight) * (chartMaxY - chartMinY);

    final intraday =
        widget.selectedPeriod == StressTestSparkPeriod.d1 ||
        widget.selectedPeriod == StressTestSparkPeriod.w1;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 130 / 3),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final plotWidth = constraints.maxWidth;
              final pixelPoints = spots.map((s) {
                final px = s.x * plotWidth;
                final py =
                    chartHeight *
                    (1 - (s.y - chartMinY) / (chartMaxY - chartMinY));
                return Offset(px, py);
              }).toList();
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(plotWidth, chartHeight),
                    painter: ChartLineGlowPainter(
                      pixelPoints: pixelPoints,
                      color: lineColor,
                    ),
                  ),
                  LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 1,
                      minY: chartMinY,
                      maxY: chartMaxY,
                      gridData: const FlGridData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: horizontalLines,
                      ),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) =>
                              touchedSpots.map((_) => null).toList(),
                        ),
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          // Was hardcoded black — invisible against Luxury
                          // Gold's dark background. palette.textHeader
                          // (cream) reads on both themes' chart canvas.
                          final indicatorColor = widget.palette.textHeader;
                          return spotIndexes
                              .map(
                                (_) => TouchedSpotIndicatorData(
                                  _touchRevealed
                                      ? FlLine(
                                          color: indicatorColor,
                                          strokeWidth: 1.3,
                                        )
                                      : const FlLine(
                                          color: Colors.transparent,
                                          strokeWidth: 0,
                                        ),
                                  const FlDotData(show: false),
                                ),
                              )
                              .toList();
                        },
                        getTouchLineEnd: (barData, spotIndex) => touchLineTopY,
                        touchCallback: (event, response) {
                          final touched = response?.lineBarSpots;
                          final isDown =
                              event.isInterestedForInteractions &&
                              touched != null &&
                              touched.isNotEmpty;

                          if (!isDown) {
                            _touchHoldTimer?.cancel();
                            _touchHoldTimer = null;
                            _touchRevealed = false;
                            widget.onTouchedPriceChanged?.call(null);
                            if (_touchDx != null || _touchedSpotIndex != null) {
                              setState(() {
                                _touchDx = null;
                                _touchedSpotIndex = null;
                              });
                            }
                            return;
                          }

                          _pendingDx = event.localPosition?.dx;
                          _pendingSpotIndex = touched.first.spotIndex;
                          _pendingY = touched.first.y;

                          if (_touchRevealed) {
                            widget.onTouchedPriceChanged?.call(_pendingY);
                            setState(() {
                              _touchDx = _pendingDx;
                              _touchedSpotIndex = _pendingSpotIndex;
                            });
                          } else {
                            _touchHoldTimer ??= Timer(_revealDelay, () {
                              _touchHoldTimer = null;
                              if (!mounted) return;
                              _touchRevealed = true;
                              widget.onTouchedPriceChanged?.call(_pendingY);
                              setState(() {
                                _touchDx = _pendingDx;
                                _touchedSpotIndex = _pendingSpotIndex;
                              });
                            });
                          }
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          color: lineColor,
                          barWidth: 1.7,
                          isStrokeCapRound: true,
                          // A small dot on the very last point only — anchors the
                          // eye to where the line currently ends, especially when
                          // there's empty space after it (1D stops at "now").
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) =>
                                spot == barData.spots.last,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 3,
                                  color: lineColor,
                                  strokeWidth: 0,
                                ),
                          ),
                        ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                ],
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 3,
          child: Text(
            formatUsd(maxValue),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.palette.textBody,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 3,
          child: Text(
            formatUsd(minValue),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.palette.textBody,
            ),
          ),
        ),
        if (showAvgLine)
          Positioned(
            top: (avgLineTop - 14).clamp(0.0, chartHeight - 14),
            right: 3,
            child: Text(
              formatUsd(avgPrice),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.palette.textBody,
              ),
            ),
          ),
        // Custom date tooltip — fixed at the top of the chart, moves only
        // horizontally with the touch.
        if (_touchDx != null &&
            _touchedSpotIndex != null &&
            _touchedSpotIndex! < points.length)
          Positioned(
            top: 0,
            left: _touchDx! - 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                // Was a flat ThemeV2.primaryBg (10%-opacity green) with
                // hardcoded black text — on Luxury Gold's dark background
                // that tint reads as barely-there black-on-black. Uses the
                // same instrument-window fill as everywhere else under
                // Luxury; Standard keeps the exact original look.
                color: widget.palette.windowGradient == null
                    ? ThemeV2.primaryBg
                    : null,
                gradient: widget.palette.windowGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _fmtTouchDate(
                  points[_touchedSpotIndex!].time,
                  intraday: intraday,
                ),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.palette.windowGradient == null
                      ? Colors.black
                      : (widget.palette.onWindow ?? widget.palette.textHeader),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fmtTouchDate(DateTime date, {bool intraday = false}) {
    if (intraday) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return '${date.day}.${date.month} $hh:$mm';
    }
    return '${date.day}.${date.month}.${date.year}';
  }
}
