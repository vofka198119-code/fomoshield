// ---------------------------------------------------------------------------
// Market Value Chart — real tick-engine-driven portfolio value chart for
// the stress test's "Market Timeline" card.
// ---------------------------------------------------------------------------
// Unlike the real Portfolio's PortfolioValueChartWidget (real Finnhub
// prices, real transaction history — intentionally untouched, out of
// scope), this chart is driven entirely by the simulation engine's own
// per-tick data (StressTestNotifier.computeChartData, built from
// StressTestSession.priceHistory) since the stress test is a fake-money
// sandbox, not the real portfolio.
//
// Timeframe tabs scale with the test's own duration (week1 -> 1D/1W,
// month1 -> +1M, months3 -> +3M); for Infinite/Custom, only tabs whose
// period has actually elapsed so far are shown — no "3M" tab on a test
// that's 4 days old.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
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

class MarketValueChart extends ConsumerStatefulWidget {
  final StressTestSession session;

  const MarketValueChart({super.key, required this.session});

  @override
  ConsumerState<MarketValueChart> createState() => _MarketValueChartState();
}

/// How often the chart's data is recomputed/redrawn — deliberately far
/// coarser than the engine's own 20s tick cadence (the algorithm/engine
/// itself is untouched; this only throttles what gets displayed). A
/// portfolio-value overview chart doesn't need to visibly refresh every
/// tick — user's explicit ask after seeing it redraw too often on device.
const Duration _chartRefreshInterval = Duration(minutes: 10);

class _MarketValueChartState extends ConsumerState<MarketValueChart> {
  _ValuePeriod _selected = _ValuePeriod.d1;
  List<ChartDataPoint>? _cachedPoints;
  DateTime? _lastComputedAt;

  /// Returns the last-computed point series, recomputing from the engine
  /// only once [_chartRefreshInterval] has actually elapsed — mutating
  /// plain fields (not calling setState) during build is safe here since
  /// it's a pure memoization, not a state change that needs its own
  /// rebuild trigger.
  List<ChartDataPoint> _getPoints() {
    final now = DateTime.now();
    if (_cachedPoints == null ||
        _lastComputedAt == null ||
        now.difference(_lastComputedAt!) >= _chartRefreshInterval) {
      _cachedPoints = ref
          .read(stressTestProvider.notifier)
          .computeChartData(widget.session.id);
      _lastComputedAt = now;
    }
    return _cachedPoints!;
  }

  /// Duration-scaled tabs. Fixed-length tests show their whole progressive
  /// set upfront (the test's total length is known); Infinite/Custom only
  /// show periods that have actually elapsed so far.
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
        final start = session.startedAt ?? session.createdAt;
        final elapsed = DateTime.now().difference(start);
        return _ValuePeriod.values
            .where((p) => elapsed >= _periodCutoffs[p]!)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = _getPoints();

    if (points.length < 2) {
      return Container(
        height: 220,
        margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        alignment: Alignment.center,
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

    final cutoff = DateTime.now().subtract(_periodCutoffs[_selected]!);
    var filtered = points.where((p) => !p.time.isBefore(cutoff)).toList();
    if (filtered.length < 2) {
      filtered = points.length >= 2
          ? [points.first, points.last]
          : points;
    }

    final minTime = filtered.first.time.millisecondsSinceEpoch.toDouble();
    final maxTime = filtered.last.time.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTime - minTime;
    final spots = filtered.map((p) {
      final x = timeRange > 0
          ? (p.time.millisecondsSinceEpoch - minTime) / timeRange
          : 0.0;
      return FlSpot(x, p.value);
    }).toList();

    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final changePercent = spots.first.y != 0
        ? ((spots.last.y - spots.first.y) / spots.first.y) * 100
        : 0.0;

    // Plain min/max headroom — no PEAK/AVG reference lines. User's explicit
    // call: this chart should show only the portfolio value itself, no
    // side annotations.
    final values = filtered.map((p) => p.value);
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.97;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.03;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            children: [
              Text('PORTFOLIO VALUE', style: FomoShieldTheme.cardTitle()),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: lineColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Taller than the reused single-symbol sparkline (200px) — the
        // user explicitly asked for more height, it read as too flat.
        SizedBox(
          height: 240,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: ThemeV2.surfaceDark, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${NumberFormat('#,##0', 'en_US').format(value)}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: lineColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.20),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => ThemeV2.surface,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                      return LineTooltipItem(
                        '\$${NumberFormat('#,##0.00', 'en_US').format(s.y)}',
                        TextStyle(
                          color: lineColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: available.map((period) {
              final isActive = _selected == period;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () {
                    if (_selected != period) {
                      setState(() => _selected = period);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? ThemeV2.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
                    ),
                    child: Text(
                      _periodLabels[period]!,
                      style: ThemeV2.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? ThemeV2.primary
                            : ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
