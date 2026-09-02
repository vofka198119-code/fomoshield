// ---------------------------------------------------------------------------
// Price Chart — real tick-engine-driven portfolio value chart for the stress
// test's own "Price Chart" widget (was "Market Value"/"Portfolio Value").
// ---------------------------------------------------------------------------
// Unlike the real Portfolio's PortfolioValueChartWidget (real Finnhub
// prices, real transaction history — intentionally untouched, out of
// scope), this chart is driven entirely by the simulation engine's own
// per-tick data (StressTestNotifier.computeChartData, built from
// StressTestSession.priceHistory) since the stress test is a fake-money
// sandbox, not the real portfolio.
//
// Visual design is a deliberate copy of company_detail/widgets/price_chart.dart
// (straight thin line, no fill/grid/axis-title chrome, manual min/max price
// labels, custom hold-to-reveal touch tooltip+indicator, gradient period
// tabs) — the two should look like the same chart family. Only the data
// pipeline (time-based spots from the engine, duration-scaled tabs) stays
// specific to Stress Test; don't reintroduce PriceChart's Finnhub fetch or
// re-add MarketValueChart's old curved/filled/grid look without asking.
//
// Timeframe tabs scale with the test's own duration (week1 -> 1D/1W,
// month1 -> +1M, months3 -> +3M); for Infinite/Custom, only tabs whose
// period has actually elapsed so far are shown — no "3M" tab on a test
// that's 4 days old.
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/chart_line_glow_painter.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../stress_test_engine.dart';
import '../stress_test_models.dart';

enum _ValuePeriod { d1, w1, m1, m3, y1 }

String _periodLabel(AppLocalizations l10n, _ValuePeriod period) =>
    switch (period) {
      _ValuePeriod.d1 => l10n.chartPeriod1D,
      _ValuePeriod.w1 => l10n.chartPeriod1W,
      _ValuePeriod.m1 => l10n.chartPeriod1M,
      _ValuePeriod.m3 => l10n.chartPeriod3M,
      _ValuePeriod.y1 => l10n.chartPeriod1Y,
    };

const Map<_ValuePeriod, Duration> _periodCutoffs = {
  _ValuePeriod.d1: Duration(days: 1),
  _ValuePeriod.w1: Duration(days: 7),
  _ValuePeriod.m1: Duration(days: 30),
  _ValuePeriod.m3: Duration(days: 90),
  _ValuePeriod.y1: Duration(days: 365),
};

/// Time-bucket averaging: splits [domainStart, domainEnd] into [maxBuckets]
/// equal time slices and averages every raw point that falls in the same
/// slice into one point. A slice with only one raw point in it (e.g. a
/// widely-spaced old catch-up burst) passes through unchanged — nothing
/// gets smoothed away that wasn't already sparse. This is what actually
/// fixes the "earthquake" look of raw 20s-tick data plotted point-by-point
/// (each rendered point is a local average, not one noisy instant) without
/// switching to curved/Bezier interpolation, which stays off by design
/// (see reference_chart_visual_standard.md — this app's charts are always
/// straight-segment, never curved).
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
      // Keep the bucket's own last real timestamp (not a synthetic
      // midpoint) so elapsed-time math downstream stays honest.
      result.add(ChartDataPoint(bucket.last.time, avgValue));
    }
  }
  // Preserve the true first/last raw point exactly, so domain boundaries
  // (e.g. 1D's "line starts exactly where real data begins") don't shift.
  result[0] = data.first;
  result[result.length - 1] = data.last;
  return result;
}

class MarketValueChart extends ConsumerStatefulWidget {
  final StressTestSession session;

  const MarketValueChart({super.key, required this.session});

  @override
  ConsumerState<MarketValueChart> createState() => _MarketValueChartState();
}

/// Everything _buildChartArea derives from (points, selected period) alone
/// — independent of live touch state (_touchDx/_touchedSpotIndex) and the
/// layout-time plot width. Memoized so a touch-drag's per-frame setState
/// (which only moves the touch indicator) doesn't re-filter/re-downsample/
/// rebuild the whole spots list on every pointer-move event.
class _ChartGeometry {
  final List<ChartDataPoint> filtered;
  final List<FlSpot> spots;
  final Color lineColor;
  final double minValue;
  final double maxValue;
  final double chartMinY;
  final double chartMaxY;
  final double touchLineTopY;
  final bool intraday;

  const _ChartGeometry({
    required this.filtered,
    required this.spots,
    required this.lineColor,
    required this.minValue,
    required this.maxValue,
    required this.chartMinY,
    required this.chartMaxY,
    required this.touchLineTopY,
    required this.intraday,
  });
}

class _MarketValueChartState extends ConsumerState<MarketValueChart> {
  // The touch-indicator line's own top stops at the date tooltip's bottom
  // edge (~24px, matching its padding+text height) instead of piercing
  // straight through the box — same as PriceChart.
  // Bumped from 24 to fit the tooltip's new 2nd line (value, above the
  // date) without the touch line's top overlapping the text.
  static const _dateTooltipHeight = 38.0;
  static const _chartHeight = 220.0;

  _ValuePeriod _selected = _ValuePeriod.d1;
  List<ChartDataPoint>? _cachedPoints;
  _ChartGeometry? _cachedGeometry;
  int? _lastGeometrySignature;
  // Cheap proxy for "has real new tick data landed since the last compute"
  // — sum of held symbols' priceHistory lengths. Used instead of a
  // wall-clock throttle: the screen rebuilds this widget every 20s (engine
  // tick timer) AND every 1s (countdown timer's setState), so a time-based
  // cache either redraws needlessly often or — as it did before this fix —
  // sits stale for minutes after a real tick because the wall-clock window
  // hadn't elapsed yet, only refreshing once the widget was torn down and
  // recreated (leaving the screen and coming back). Comparing this
  // signature is a handful of map lookups, cheap enough to run on every
  // rebuild, so the actual O(holdings × ticks) recompute only fires when
  // there's genuinely new data.
  int? _lastDataSignature;
  // Which period _cachedPoints was last computed for — a period change
  // alone (no new tick data) still needs a re-fetch, since d1 vs.
  // everything-else pulls from two different data sources (see
  // _getPoints).
  _ValuePeriod? _lastGeometryPeriod;

  // Touch state for the custom date tooltip — fixed vertically at the top
  // of the chart, moves only horizontally with the touch. Mirrors
  // PriceChart's exact mechanic: a quick tap/swipe (e.g. scrolling the
  // page) shows nothing; the indicator+tooltip only reveal after a
  // sustained hold.
  double? _touchDx;
  int? _touchedSpotIndex;

  static const _revealDelay = Duration(milliseconds: 1200);
  Timer? _touchHoldTimer;
  bool _touchRevealed = false;
  double? _pendingDx;
  int? _pendingSpotIndex;

  /// Returns the last-computed point series, recomputing from the engine
  /// only when new data has actually landed (see [_lastDataSignature]) —
  /// mutating plain fields (not calling setState) during build is safe
  /// here since it's a pure memoization, not a state change that needs its
  /// own rebuild trigger.
  List<ChartDataPoint> _getPoints() {
    var signature = 0;
    for (final h in widget.session.holdings) {
      signature += widget.session.priceHistory[h.symbol]?.length ?? 0;
      signature += widget.session.dailyPriceHistory[h.symbol]?.length ?? 0;
    }
    // 1D reads raw per-tick data (intraday resolution); every longer
    // period reads the daily-bucket history instead — raw priceHistory
    // only covers ~27h (see _maxPriceHistoryPoints's doc comment in
    // stress_test_engine.dart), so it has nothing distinct to show for a
    // real week/month-old window anyway. Re-fetch (not just re-filter) on
    // period change since the two are different underlying data sources.
    if (_cachedPoints == null ||
        _lastDataSignature != signature ||
        _lastGeometryPeriod != _selected) {
      final notifier = ref.read(stressTestProvider.notifier);
      _cachedPoints = _selected == _ValuePeriod.d1
          ? notifier.computeChartData(widget.session.id)
          : notifier.computeDailyChartData(widget.session.id);
      _lastDataSignature = signature;
      _lastGeometryPeriod = _selected;
    }
    return _cachedPoints!;
  }

  /// Duration-scaled tabs. Fixed-length tests show their whole progressive
  /// set upfront (the test's total length is known). Infinite/Custom show
  /// every period too, not gated by how much real time has actually
  /// elapsed — a period tab reflects however little (or much) data exists
  /// so far (auto-scaled in `_buildChartArea`), same as a fixed-length
  /// test already does; hiding "1W" until a real week has passed made the
  /// chart invisible/inaccessible right when the user most wants to check
  /// in on a brand-new test. Explicit ask — don't reintroduce elapsed
  /// gating here.
  List<_ValuePeriod> _availablePeriods(StressTestSession session) {
    switch (session.duration) {
      case TestDuration.week1:
        return [_ValuePeriod.d1, _ValuePeriod.w1];
      case TestDuration.month1:
        return [_ValuePeriod.d1, _ValuePeriod.w1, _ValuePeriod.m1];
      case TestDuration.months3:
        return [
          _ValuePeriod.d1,
          _ValuePeriod.w1,
          _ValuePeriod.m1,
          _ValuePeriod.m3,
        ];
      case TestDuration.infinite:
      case TestDuration.custom:
        return _ValuePeriod.values;
    }
  }

  @override
  void dispose() {
    _touchHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: FomoShieldTheme.cardPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: themedHeaderText(
              AppLocalizations.of(context)!.stressTestPriceChartTitle,
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

          // Chart area — bled almost to the card's own edges (1px left,
          // 2px right), same as PriceChart.
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _buildChartArea(palette)),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: _buildPeriodSelector(palette),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AppPalette palette) {
    final l10n = AppLocalizations.of(context)!;
    final available = _availablePeriods(widget.session);
    if (!available.contains(_selected)) {
      _selected = available.last;
    }
    return Row(
      children: available.map((period) {
        final isSelected = period == _selected;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              setState(() => _selected = period);
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
                  color: isSelected ? Colors.white : palette.textBody,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartArea(AppPalette palette) {
    final l10n = AppLocalizations.of(context)!;
    final points = _getPoints();
    if (points.length < 2) {
      return Center(
        child: Text(
          l10n.stressTestChartNotEnoughData,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      );
    }

    final available = _availablePeriods(widget.session);
    if (!available.contains(_selected)) {
      _selected = available.last;
    }

    final geometry = _getGeometry(points);
    if (geometry == null) {
      return Center(
        child: Text(
          l10n.stressTestChartNotEnoughDataForPeriod,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      );
    }
    final filtered = geometry.filtered;
    final spots = geometry.spots;
    final lineColor = geometry.lineColor;
    final minValue = geometry.minValue;
    final maxValue = geometry.maxValue;
    final chartMinY = geometry.chartMinY;
    final chartMaxY = geometry.chartMaxY;
    final touchLineTopY = geometry.touchLineTopY;
    final intraday = geometry.intraday;
    const chartHeight = _chartHeight;

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
                        // fl_chart's own tooltip bubble is replaced by a custom
                        // fixed-position one drawn outside the chart below.
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) =>
                              touchedSpots.map((_) => null).toList(),
                        ),
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          // Was hardcoded black — invisible against Luxury
                          // Gold's dark background. palette.textHeader
                          // (cream) reads on both themes' chart canvas.
                          final indicatorColor = palette.textHeader;
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

                          if (_touchRevealed) {
                            setState(() {
                              _touchDx = _pendingDx;
                              _touchedSpotIndex = _pendingSpotIndex;
                            });
                          } else {
                            _touchHoldTimer ??= Timer(_revealDelay, () {
                              _touchHoldTimer = null;
                              if (!mounted) return;
                              _touchRevealed = true;
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
              color: palette.textBody,
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
              color: palette.textBody,
            ),
          ),
        ),
        // Custom date tooltip — fixed at the top of the chart, moves only
        // horizontally with the touch.
        if (_touchDx != null &&
            _touchedSpotIndex != null &&
            _touchedSpotIndex! < filtered.length)
          Positioned(
            top: 0,
            left: _touchDx! - 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // Was a flat ThemeV2.primaryBg (10%-opacity green) with
                // hardcoded black text — on Luxury Gold's dark background
                // that tint reads as barely-there black-on-black. Uses the
                // same instrument-window fill as everywhere else under
                // Luxury; Standard keeps the exact original look.
                color: palette.windowGradient == null
                    ? ThemeV2.primaryBg
                    : null,
                gradient: palette.windowGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // This chart has no separate "current balance" header of
                  // its own to mirror the touched value into (unlike
                  // PriceChart/StockSparklineChart, which sync a price
                  // header above them) — the value has to live in the
                  // tooltip itself, or holding the chart would show a date
                  // but never the balance it corresponds to.
                  Text(
                    formatUsd(filtered[_touchedSpotIndex!].value),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.windowGradient == null
                          ? Colors.black
                          : (palette.onWindow ?? palette.textHeader),
                    ),
                  ),
                  Text(
                    _fmtTouchDate(
                      filtered[_touchedSpotIndex!].time,
                      intraday: intraday,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: palette.windowGradient == null
                          ? Colors.black54
                          : (palette.onWindow ?? palette.textBody),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Memoized wrapper around [_computeGeometry] — recomputes only when the
  /// underlying [points] (by identity — only changes when [_getPoints]
  /// actually recomputes) or [_selected] period change, not on every
  /// touch-drag frame (see [_ChartGeometry]'s doc comment).
  _ChartGeometry? _getGeometry(List<ChartDataPoint> points) {
    final signature = Object.hash(identityHashCode(points), _selected);
    if (_cachedGeometry == null || _lastGeometrySignature != signature) {
      _cachedGeometry = _computeGeometry(points);
      _lastGeometrySignature = signature;
    }
    return _cachedGeometry;
  }

  /// Null when [_selected]'s period has fewer than 2 points after
  /// filtering — caller shows the "not enough data for period" message.
  _ChartGeometry? _computeGeometry(List<ChartDataPoint> points) {
    final now = DateTime.now();
    final DateTime domainStart;
    final DateTime domainEnd;
    List<ChartDataPoint> filtered;
    if (_selected == _ValuePeriod.d1) {
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      filtered = points
          .where(
            (p) => !p.time.isBefore(todayStart) && !p.time.isAfter(todayEnd),
          )
          .toList();
      if (filtered.length < 2) return null;
      // Left edge anchors to wherever today's REAL data actually starts —
      // not literal midnight. A simulated session can't backfill more than
      // ~5 real hours of catch-up (_maxCatchUpTicks), so pinning to
      // midnight would show a permanent empty gap every time the app was
      // closed overnight. The right edge stays fixed at midnight tomorrow
      // so the line still stops at "now" with empty space after it —
      // that's a genuine "hasn't happened yet" gap, not a missing-data one.
      domainStart = filtered.first.time;
      domainEnd = todayEnd;
    } else {
      // Periods longer than a day always stretch to fill the chart's full
      // width using whatever real data falls in the rolling window —
      // explicit ask: unlike 1D, these don't stop short at "now" with
      // empty trailing space.
      final cutoff = now.subtract(_periodCutoffs[_selected]!);
      filtered = points.where((p) => !p.time.isBefore(cutoff)).toList();
      if (filtered.length < 2) return null;
      domainStart = filtered.first.time;
      domainEnd = filtered.last.time;
    }

    // Downsample before rendering — priceHistory can hold up to
    // _maxPriceHistoryPoints (5000) per symbol, and a long-running test's
    // 1Y/ALL view could otherwise hand fl_chart thousands of points for a
    // ~300px-wide plot area, most of which land on the same screen pixel.
    // Always keeps the first/last point so the domain's real boundaries
    // (start-of-data for 1D, filtered.first/last for longer periods) don't
    // shift.
    filtered = _downsampleForRender(filtered, domainStart, domainEnd, 200);

    // 1D uses the fixed calendar-day domain computed above (so it can stop
    // short of the right edge); every other period's domain is just
    // [filtered.first, filtered.last], stretching to fill the full width.
    final minTimeMs = domainStart.millisecondsSinceEpoch.toDouble();
    final maxTimeMs = domainEnd.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTimeMs - minTimeMs;
    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      final t = filtered[i].time.millisecondsSinceEpoch.toDouble();
      final x = timeRange > 0
          ? ((t - minTimeMs) / timeRange).clamp(0.0, 1.0)
          : 0.0;
      spots.add(FlSpot(x, filtered[i].value));
    }

    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;

    final values = filtered.map((p) => p.value);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    // 15% headroom each side — the line occupies ~70% of the chart's
    // height instead of nearly touching top/bottom, matching the
    // reference chart's proportions.
    final headroom = valueRange > 0 ? valueRange * 0.15 : maxValue * 0.15;
    final chartMinY = minValue - headroom;
    final chartMaxY = maxValue + headroom;

    final touchLineTopY =
        chartMaxY -
        (_dateTooltipHeight / _chartHeight) * (chartMaxY - chartMinY);

    final intraday =
        _selected == _ValuePeriod.d1 || _selected == _ValuePeriod.w1;

    return _ChartGeometry(
      filtered: filtered,
      spots: spots,
      lineColor: lineColor,
      minValue: minValue,
      maxValue: maxValue,
      chartMinY: chartMinY,
      chartMaxY: chartMaxY,
      touchLineTopY: touchLineTopY,
      intraday: intraday,
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
