import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/finnhub_service.dart';

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
        return (now.subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000, 'D');
      case ChartPeriod.month6:
        return (now.subtract(const Duration(days: 182)).millisecondsSinceEpoch ~/ 1000, 'D');
      case ChartPeriod.year1:
        return (now.subtract(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000, 'D');
      case ChartPeriod.year5:
        return (now.subtract(const Duration(days: 1825)).millisecondsSinceEpoch ~/ 1000, 'W');
      case ChartPeriod.all:
        return (0, 'M'); // all time = monthly
    }
  }
}

// ---------------------------------------------------------------------------
// Price Chart Widget
// ---------------------------------------------------------------------------

class PriceChart extends StatefulWidget {
  final String symbol;

  const PriceChart({super.key, required this.symbol});

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period selector
        Row(
          children: ChartPeriod.values.map((p) {
            final isSelected = p == _selectedPeriod;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  if (p != _selectedPeriod) {
                    setState(() => _selectedPeriod = p);
                    _loadCandles();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentBlue.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentBlue.withValues(alpha: 0.5)
                          : AppTheme.cardDark,
                    ),
                  ),
                  child: Text(
                    p.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.accentBlue : AppTheme.textDim,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Chart area
        SizedBox(
          height: 220,
          child: _buildChartArea(),
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentBlue, strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart_rounded, size: 40, color: AppTheme.textDim),
            const SizedBox(height: 8),
            Text(_error!,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim)),
          ],
        ),
      );
    }

    final closes = _parseCloses(_candleData);
    final timestamps = _parseTimestamps(_candleData);

    if (closes.length < 2) {
      return Center(
        child: Text('Not enough data',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim)),
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
    final lineColor = isUp ? AppTheme.shieldGreen : AppTheme.dangerRed;

    final spots = <FlSpot>[];
    for (int i = 0; i < closes.length; i++) {
      spots.add(FlSpot(i.toDouble(), closes[i]));
    }

    return LineChart(
      LineChartData(
        minY: chartMinY,
        maxY: chartMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (chartMaxY - chartMinY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.cardDark,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDim),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: _xLabelInterval(closes.length),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= timestamps.length) return const SizedBox();
                final date = DateTime.fromMillisecondsSinceEpoch(
                    timestamps[idx] * 1000);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${date.month}/${date.year % 100}',
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDim),
                  ),
                );
              },
            ),
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
                        timestamps[idx] * 1000)
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
                            text: '\n${date.day}.${date.month}.${date.year}',
                            style: TextStyle(
                              color: AppTheme.textDim,
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
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.20),
              cutOffY: chartMinY,
              applyCutOffY: true,
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
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

  double _xLabelInterval(int count) {
    if (count <= 30) return 7;
    if (count <= 60) return 15;
    if (count <= 250) return 60;
    if (count <= 500) return 120;
    return 250;
  }
}
