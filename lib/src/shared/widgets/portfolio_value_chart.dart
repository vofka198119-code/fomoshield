// ---------------------------------------------------------------------------
// Portfolio Value Chart Widget — fl_chart (Portfolio section)
// ---------------------------------------------------------------------------
// Professional chart showing portfolio value over time.
// Same Trading 212-style design as Stress Test chart.
// Takes List<ChartDataPoint> from portfolioChartDataProvider.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../features/stress_test/stress_test_engine.dart';
import '../../features/portfolio/portfolio_chart_providers.dart';

// ---------------------------------------------------------------------------
// Time range options
// ---------------------------------------------------------------------------

enum PortfolioChartRange { w1, m1, m3, m6, all }

extension on PortfolioChartRange {
  String get label {
    switch (this) {
      case PortfolioChartRange.w1:
        return '1W';
      case PortfolioChartRange.m1:
        return '1M';
      case PortfolioChartRange.m3:
        return '3M';
      case PortfolioChartRange.m6:
        return '6M';
      case PortfolioChartRange.all:
        return 'ALL';
    }
  }
}

// ---------------------------------------------------------------------------
// Portfolio Value Chart Widget
// ---------------------------------------------------------------------------

class PortfolioValueChartWidget extends ConsumerWidget {
  final String portfolioId;
  final double height;

  const PortfolioValueChartWidget({
    super.key,
    required this.portfolioId,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(portfolioChartDataProvider(portfolioId));

    return dataAsync.when(
      loading: () => _buildSkeleton(),
      error: (err, _) => _buildFallback(),
      data: (points) => _PortfolioValueChart(
        portfolioId: portfolioId,
        allPoints: points,
        height: height,
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E5DF)),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accentBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E5DF)),
      ),
      child: Center(
        child: Text(
          'Not enough data for chart',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal stateful chart
// ---------------------------------------------------------------------------

class _PortfolioValueChart extends ConsumerStatefulWidget {
  final String portfolioId;
  final List<ChartDataPoint> allPoints;
  final double height;

  const _PortfolioValueChart({
    required this.portfolioId,
    required this.allPoints,
    required this.height,
  });

  @override
  ConsumerState<_PortfolioValueChart> createState() =>
      _PortfolioValueChartState();
}

class _PortfolioValueChartState extends ConsumerState<_PortfolioValueChart> {
  PortfolioChartRange _selectedRange = PortfolioChartRange.all;
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _applyRange();
  }

  @override
  void didUpdateWidget(_PortfolioValueChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allPoints != widget.allPoints) {
      _applyRange();
    }
  }

  void _applyRange() {
    if (widget.allPoints.isEmpty) {
      _spots = [];
      return;
    }

    final now = DateTime.now();
    DateTime cutoff;

    switch (_selectedRange) {
      case PortfolioChartRange.w1:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case PortfolioChartRange.m1:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case PortfolioChartRange.m3:
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case PortfolioChartRange.m6:
        cutoff = now.subtract(const Duration(days: 180));
        break;
      case PortfolioChartRange.all:
        cutoff = widget.allPoints.first.time;
        break;
    }

    final filtered = widget.allPoints
        .where((p) =>
            p.time.isAfter(cutoff) || p.time == widget.allPoints.first.time)
        .toList();

    if (filtered.length < 2) {
      if (widget.allPoints.length >= 2) {
        _spots = [
          FlSpot(0, widget.allPoints.first.value),
          FlSpot(1, widget.allPoints.last.value),
        ];
      } else {
        _spots = [FlSpot(0, widget.allPoints.last.value)];
      }
      return;
    }

    final minTime = filtered.first.time.millisecondsSinceEpoch.toDouble();
    final maxTime = filtered.last.time.millisecondsSinceEpoch.toDouble();
    final timeRange = maxTime - minTime;

    _spots = filtered.map((p) {
      final x = timeRange > 0
          ? (p.time.millisecondsSinceEpoch - minTime) / timeRange
          : 0.0;
      return FlSpot(x, p.value);
    }).toList();
  }

  bool get _isUp => _spots.length >= 2 && _spots.last.y >= _spots.first.y;

  Color get _lineColor =>
      _isUp ? AppTheme.shieldGreen : AppTheme.dangerRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E5DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + change % ──────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                Text(
                  'PORTFOLIO VALUE',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentBlue,
                    letterSpacing: 1.2,
                  ),
                ),
                if (_spots.length >= 2) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _lineColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_isUp ? '+' : ''}${_changePercent().toStringAsFixed(2)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _lineColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ── Chart ──────────────────────────────────────────
          SizedBox(
            height: widget.height - 100,
            child: _spots.isEmpty
                ? Center(
                    child: Text(
                      'Not enough data',
                      style: GoogleFonts.inter(color: AppTheme.textDim),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcYInterval(),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.cardDark,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${_fmtAxis(value)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppTheme.textDim,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: _spots.length > 8
                                ? (_spots.length / 5).ceilToDouble()
                                : 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= _spots.length) {
                                return const SizedBox();
                              }
                              // Map fl-spot index back to original data point
                              if (widget.allPoints.isEmpty) {
                                return const SizedBox();
                              }
                              final ratio = _spots.length > 1
                                  ? idx / (_spots.length - 1)
                                  : 0.0;
                              final dataIdx = (ratio *
                                      (widget.allPoints.length - 1))
                                  .round()
                                  .clamp(0, widget.allPoints.length - 1);
                              final point = widget.allPoints[dataIdx];
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _fmtTime(point.time),
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: AppTheme.textDim,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: _calcMinY(),
                      maxY: _calcMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _spots,
                          isCurved: true,
                          preventCurveOverShooting: true,
                          color: _lineColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _lineColor.withValues(alpha: 0.20),
                                _lineColor.withValues(alpha: 0.06),
                                _lineColor.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.card,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final changeSinceStart = _spots.isNotEmpty && _spots.first.y != 0
                                      ? ((spot.y - _spots.first.y) /
                                              _spots.first.y) *
                                          100
                                      : 0.0;
                              return LineTooltipItem(
                                '\$${_fmtValue(spot.y)}',
                                TextStyle(
                                  color: _lineColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  fontFamily:
                                      GoogleFonts.playfairDisplay().fontFamily,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        '\n${changeSinceStart >= 0 ? '+' : ''}${changeSinceStart.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: changeSinceStart >= 0
                                          ? AppTheme.shieldGreen
                                          : AppTheme.dangerRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.inter().fontFamily,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                    duration: const Duration(milliseconds: 300),
                  ),
          ),

          const SizedBox(height: 6),

          // ── Range Selector ──────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: PortfolioChartRange.values.map((range) {
                final selected = range == _selectedRange;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedRange = range;
                      _applyRange();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        range.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? AppTheme.textPrimary
                              : AppTheme.textDim,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────

  double _changePercent() {
    if (_spots.length < 2) return 0;
    final first = _spots.first.y;
    if (first == 0) return 0;
    return ((_spots.last.y - first) / first) * 100;
  }

  double _calcMinY() {
    if (_spots.isEmpty) return 0;
    double min = _spots.first.y;
    for (final s in _spots) {
      if (s.y < min) min = s.y;
    }
    return min * 0.95;
  }

  double _calcMaxY() {
    if (_spots.isEmpty) return 1000;
    double max = _spots.first.y;
    for (final s in _spots) {
      if (s.y > max) max = s.y;
    }
    return max * 1.05;
  }

  double _calcYInterval() {
    final range = _calcMaxY() - _calcMinY();
    if (range <= 0) return 100;
    final raw = range / 4;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final normalized = raw / magnitude;
    double nice;
    if (normalized <= 1.5) {
      nice = 1;
    } else if (normalized <= 3.5) {
      nice = 2;
    } else if (normalized <= 7.5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }

  String _fmtValue(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }

  String _fmtAxis(double v) {
    return NumberFormat('#,##0', 'en_US').format(v);
  }

  String _fmtTime(DateTime t) {
    switch (_selectedRange) {
      case PortfolioChartRange.w1:
      case PortfolioChartRange.m1:
        return '${t.month}/${t.day}';
      case PortfolioChartRange.m3:
      case PortfolioChartRange.m6:
      case PortfolioChartRange.all:
        return '${t.month}/${t.year % 100}';
    }
  }
}
