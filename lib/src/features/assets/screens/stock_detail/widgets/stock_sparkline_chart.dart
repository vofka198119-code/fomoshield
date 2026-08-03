import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
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

enum StressTestSparkPeriod { d1, w1, m1, m3, y1, max }

const Map<StressTestSparkPeriod, String> _periodLabels = {
  StressTestSparkPeriod.d1: '1D',
  StressTestSparkPeriod.w1: '1W',
  StressTestSparkPeriod.m1: '1M',
  StressTestSparkPeriod.m3: '3M',
  StressTestSparkPeriod.y1: '1Y',
  StressTestSparkPeriod.max: 'ALL',
};

final _priceFmt = NumberFormat('#,##0.00', 'en_US');

class StockSparklineChart extends StatefulWidget {
  final bool ready;
  final List<ChartDataPoint> points;
  final double? avgPrice;
  final List<StressTestSparkPeriod> availablePeriods;
  final StressTestSparkPeriod selectedPeriod;
  final ValueChanged<StressTestSparkPeriod> onPeriodChanged;

  const StockSparklineChart({
    super.key,
    required this.ready,
    required this.points,
    required this.availablePeriods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.avgPrice,
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

  @override
  void didUpdateWidget(covariant StockSparklineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _touchHoldTimer?.cancel();
      _touchHoldTimer = null;
      _touchRevealed = false;
      _touchDx = null;
      _touchedSpotIndex = null;
    }
  }

  @override
  void dispose() {
    _touchHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.ready || widget.points.length < 2) {
      return Container(
        height: 280,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: FomoShieldTheme.cardDecoration,
        child: const Center(
          child: CircularProgressIndicator(
            color: ThemeV2.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(
        vertical: FomoShieldTheme.cardPadding,
      ),
      decoration: FomoShieldTheme.cardDecoration,
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
    final points = widget.points;

    final minTime = points.first.time.millisecondsSinceEpoch.toDouble();
    final maxTime = points.last.time.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTime - minTime;
    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      final t = points[i].time.millisecondsSinceEpoch.toDouble();
      final x = timeRange > 0 ? (t - minTime) / timeRange : 0.0;
      spots.add(FlSpot(x, points[i].value));
    }

    final isUp = spots.last.y >= spots.first.y;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;

    final values = points.map((p) => p.value);
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final valueRange = maxValue - minValue;
    final headroom = valueRange > 0 ? valueRange * 0.08 : maxValue * 0.08;
    final chartMinY = minValue - headroom;
    final chartMaxY = maxValue + headroom;

    final avgPrice = widget.avgPrice;
    final showAvgLine =
        avgPrice != null && avgPrice >= chartMinY && avgPrice <= chartMaxY;
    final horizontalLines = [
      HorizontalLine(y: chartMinY, color: ThemeV2.surfaceDark, strokeWidth: 1),
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
        chartMaxY -
        (dateTooltipHeight / chartHeight) * (chartMaxY - chartMinY);

    final intraday =
        widget.selectedPeriod == StressTestSparkPeriod.d1 ||
        widget.selectedPeriod == StressTestSparkPeriod.w1;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 130 / 3),
          child: LineChart(
            LineChartData(
              minY: chartMinY,
              maxY: chartMaxY,
              gridData: const FlGridData(show: false),
              extraLinesData: ExtraLinesData(horizontalLines: horizontalLines),
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
        if (showAvgLine)
          Positioned(
            top: (avgLineTop - 14).clamp(0.0, chartHeight - 14),
            right: 3,
            child: Text(
              '\$${_priceFmt.format(avgPrice)}',
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
            _touchedSpotIndex! < points.length)
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
                  points[_touchedSpotIndex!].time,
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
