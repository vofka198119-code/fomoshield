import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import '../../portfolio/portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Period Selection
// ---------------------------------------------------------------------------

enum ChartPeriod { month1, month6, year1, year5, all }

extension ChartPeriodExt on ChartPeriod {
  String get label {
    switch (this) {
      case ChartPeriod.month1:
        return '1M';
      case ChartPeriod.month6:
        return '6M';
      case ChartPeriod.year1:
        return '1Y';
      case ChartPeriod.year5:
        return '5Y';
      case ChartPeriod.all:
        return 'All';
    }
  }

  (int fromTs, String resolution) toApiParams() {
    final now = DateTime.now();
    switch (this) {
      case ChartPeriod.month1:
        return (
          now.subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
          'D',
        );
      case ChartPeriod.month6:
        return (
          now.subtract(const Duration(days: 182)).millisecondsSinceEpoch ~/
              1000,
          'D',
        );
      case ChartPeriod.year1:
        return (
          now.subtract(const Duration(days: 365)).millisecondsSinceEpoch ~/
              1000,
          'D',
        );
      case ChartPeriod.year5:
        return (
          now.subtract(const Duration(days: 1825)).millisecondsSinceEpoch ~/
              1000,
          'W',
        );
      case ChartPeriod.all:
        return (0, 'M'); // all time = monthly
    }
  }
}

// ---------------------------------------------------------------------------
// Price Chart Widget
// ---------------------------------------------------------------------------

class PriceChart extends ConsumerStatefulWidget {
  final String symbol;

  const PriceChart({super.key, required this.symbol});

  @override
  ConsumerState<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends ConsumerState<PriceChart> {
  final FinnhubService _api = FinnhubService();
  ChartPeriod _selectedPeriod = ChartPeriod.year1;
  Map<String, dynamic>? _candleData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandles();
  }

  Future<void> _loadCandles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final (fromTs, resolution) = _selectedPeriod.toApiParams();
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final data = await _api.candles(
        widget.symbol,
        resolution: resolution,
        from: fromTs,
        to: nowSec,
      );

      if (!mounted) return;

      final status = data['s'] as String? ?? '';
      if (status == 'no_data') {
        setState(() {
          _error = 'No price data available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _candleData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load chart';
          _isLoading = false;
        });
      }
    }
  }

  /// Weighted-average cost basis for this symbol across every portfolio
  /// that holds it, or null if the user doesn't hold it anywhere — same
  /// computation as `PositionSection`'s "Avg Cost" tile.
  double? _avgCost() {
    final portfolios = ref.watch(portfoliosProvider);
    double totalShares = 0;
    double totalCost = 0;
    for (final p in portfolios) {
      final perf = ref.watch(portfolioPerformanceProvider(p.id));
      final holding = perf.asData?.value.holdings.firstWhere(
        (h) => h.symbol == widget.symbol,
        orElse: () => HoldingPerformance(
          symbol: widget.symbol,
          shares: 0,
          avgCost: 0,
          totalCost: 0,
          currentPrice: 0,
          currentValue: 0,
          pnl: 0,
          pnlPercent: 0,
        ),
      );
      if (holding != null && holding.shares > 0) {
        totalShares += holding.shares;
        totalCost += holding.shares * holding.avgCost;
      }
    }
    if (totalShares <= 0) return null;
    return totalCost / totalShares;
  }

  @override
  Widget build(BuildContext context) {
    final avgCost = _avgCost();

    return Container(
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

          // Chart area — bled almost to the card's own edges (1px left,
          // 2px right) rather than sitting at the full card padding.
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 2),
            child: SizedBox(height: 220, child: _buildChartArea(avgCost)),
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
    return Row(
      children: ChartPeriod.values.map((period) {
        final isSelected = period == _selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              setState(() => _selectedPeriod = period);
              _loadCandles();
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
                period.label,
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

  Widget _buildChartArea(double? avgCost) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ThemeV2.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.show_chart_rounded,
              size: 40,
              color: ThemeV2.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final closes = _parseCloses(_candleData);
    final timestamps = _parseTimestamps(_candleData);

    if (closes.length < 2) {
      return Center(
        child: Text(
          'Not enough data',
          style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
        ),
      );
    }

    final minPrice = closes.reduce((a, b) => a < b ? a : b);
    final maxPrice = closes.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;
    final padding = priceRange > 0 ? priceRange * 0.08 : maxPrice * 0.08;
    final chartMinY = (minPrice - padding);
    final chartMaxY = (maxPrice + padding);

    // Determine color: green if last close >= first close
    final isUp = closes.last >= closes.first;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;

    final spots = <FlSpot>[];
    for (int i = 0; i < closes.length; i++) {
      spots.add(FlSpot(i.toDouble(), closes[i]));
    }

    final showAvgLine =
        avgCost != null && avgCost >= chartMinY && avgCost <= chartMaxY;
    final horizontalLines = [
      HorizontalLine(y: chartMinY, color: ThemeV2.surfaceDark, strokeWidth: 1),
      if (showAvgLine)
        HorizontalLine(
          y: avgCost,
          color: ThemeV2.textSecondary,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
    ];
    // Vertical position (within the 220px chart box) of the avg-cost line,
    // for the plain text label drawn outside fl_chart's own inset canvas.
    final avgLineTop = showAvgLine
        ? ((chartMaxY - avgCost) / (chartMaxY - chartMinY)) * 220
        : 0.0;

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
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.spotIndex;
                      final date = idx < timestamps.length
                          ? DateTime.fromMillisecondsSinceEpoch(
                              timestamps[idx] * 1000,
                            )
                          : null;
                      return LineTooltipItem(
                        '\$${spot.y.toStringAsFixed(2)}',
                        TextStyle(
                          color: lineColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        children: date != null
                            ? [
                                TextSpan(
                                  text:
                                      '\n${date.day}.${date.month}.${date.year}',
                                  style: TextStyle(
                                    color: ThemeV2.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ]
                            : [],
                      );
                    }).toList();
                  },
                ),
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
            '\$${maxPrice.toStringAsFixed(2)}',
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
            '\$${minPrice.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textSecondary,
            ),
          ),
        ),
        if (showAvgLine)
          Positioned(
            top: (avgLineTop - 14).clamp(0.0, 220.0 - 14),
            right: 3,
            child: Text(
              '\$${avgCost.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  List<double> _parseCloses(Map<String, dynamic>? data) {
    if (data == null) return [];
    final c = data['c'];
    if (c is List) return c.map((e) => (e as num).toDouble()).toList();
    return [];
  }

  List<int> _parseTimestamps(Map<String, dynamic>? data) {
    if (data == null) return [];
    final t = data['t'];
    if (t is List) return t.map((e) => (e as num).toInt()).toList();
    return [];
  }
}
