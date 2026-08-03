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
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import '../stress_test_engine.dart';
import '../stress_test_models.dart';

enum _ValuePeriod { d1, w1, m1, m3, y1 }

const Map<_ValuePeriod, String> _periodLabels = {
  _ValuePeriod.d1: '1D',
  _ValuePeriod.w1: '1W',
  _ValuePeriod.m1: '1M',
  _ValuePeriod.m3: '3M',
  _ValuePeriod.y1: '1Y',
};

const Map<_ValuePeriod, Duration> _periodCutoffs = {
  _ValuePeriod.d1: Duration(days: 1),
  _ValuePeriod.w1: Duration(days: 7),
  _ValuePeriod.m1: Duration(days: 30),
  _ValuePeriod.m3: Duration(days: 90),
  _ValuePeriod.y1: Duration(days: 365),
};

/// Start of the visible window for [period], given the current moment.
/// 1D is a calendar day (resets at local midnight), not a rolling 24h
/// lookback — explicit ask: the daily chart should start drawing a NEW
/// day, not keep showing part of yesterday until a full 24h have passed.
DateTime _periodCutoff(_ValuePeriod period, DateTime now) {
  if (period == _ValuePeriod.d1) {
    return DateTime(now.year, now.month, now.day);
  }
  return now.subtract(_periodCutoffs[period]!);
}

final _priceFmt = NumberFormat('#,##0.00', 'en_US');

class MarketValueChart extends ConsumerStatefulWidget {
  final StressTestSession session;

  const MarketValueChart({super.key, required this.session});

  @override
  ConsumerState<MarketValueChart> createState() => _MarketValueChartState();
}

class _MarketValueChartState extends ConsumerState<MarketValueChart> {
  _ValuePeriod _selected = _ValuePeriod.d1;
  List<ChartDataPoint>? _cachedPoints;
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
    }
    if (_cachedPoints == null || _lastDataSignature != signature) {
      _cachedPoints = ref
          .read(stressTestProvider.notifier)
          .computeChartData(widget.session.id);
      _lastDataSignature = signature;
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
            child: Text('PRICE CHART', style: FomoShieldTheme.cardTitle()),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: Divider(
              height: 1,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
          const SizedBox(height: 12),

          // Chart area — bled almost to the card's own edges (1px left,
          // 2px right), same as PriceChart.
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _buildChartArea()),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: _buildPeriodSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [dialLight, dialDark],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                _periodLabels[period]!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartArea() {
    final points = _getPoints();
    if (points.length < 2) {
      return Center(
        child: Text(
          'Not enough data yet',
          style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
        ),
      );
    }

    final available = _availablePeriods(widget.session);
    if (!available.contains(_selected)) {
      _selected = available.last;
    }

    final cutoff = _periodCutoff(_selected, DateTime.now());
    var filtered = points.where((p) => !p.time.isBefore(cutoff)).toList();
    if (filtered.length < 2) {
      filtered = points.length >= 2 ? [points.first, points.last] : points;
    }
    if (filtered.length < 2) {
      return Center(
        child: Text(
          'Not enough data',
          style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
        ),
      );
    }

    final minTime = filtered.first.time.millisecondsSinceEpoch.toDouble();
    final maxTime = filtered.last.time.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTime - minTime;
    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      final t = filtered[i].time.millisecondsSinceEpoch.toDouble();
      final x = timeRange > 0 ? (t - minTime) / timeRange : 0.0;
      spots.add(FlSpot(x, filtered[i].value));
    }

    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;

    final values = filtered.map((p) => p.value);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    final headroom = valueRange > 0 ? valueRange * 0.08 : maxValue * 0.08;
    final chartMinY = minValue - headroom;
    final chartMaxY = maxValue + headroom;

    // The touch-indicator line's own top stops at the date tooltip's
    // bottom edge (~24px, matching its padding+text height) instead of
    // piercing straight through the box — same as PriceChart.
    const dateTooltipHeight = 24.0;
    const chartHeight = 220.0;
    final touchLineTopY =
        chartMaxY -
        (dateTooltipHeight / chartHeight) * (chartMaxY - chartMinY);

    final intraday =
        _selected == _ValuePeriod.d1 || _selected == _ValuePeriod.w1;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 130 / 3),
          child: LineChart(
            LineChartData(
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
                  return spotIndexes
                      .map(
                        (_) => TouchedSpotIndicatorData(
                          _touchRevealed
                              ? const FlLine(
                                  color: Colors.black,
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
                  barWidth: 1.2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        Positioned(
          top: 0,
          right: 3,
          child: Text(
            '\$${_priceFmt.format(maxValue)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textSecondary,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 3,
          child: Text(
            '\$${_priceFmt.format(minValue)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textSecondary,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ThemeV2.primaryBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _fmtTouchDate(
                  filtered[_touchedSpotIndex!].time,
                  intraday: intraday,
                ),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
