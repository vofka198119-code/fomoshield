import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import 'stock_detail_helpers.dart';

// ---------------------------------------------------------------------------
// Stress Test sparkline chart card — split out of the old monolithic
// stock_detail_screen.dart. The painter/data logic is UNCHANGED (still the
// simulation's own priceHistory, not the real Yahoo-backed PriceChart used
// by Company Detail — different data source entirely); only the outer card
// container was converted to the FomoShieldTheme.cardDecoration standard.
// A closer visual match to Company Detail's PriceChart (scrub interaction,
// dashed avg-cost styling) is a deferred follow-up, not done in this pass.
// ---------------------------------------------------------------------------

enum StressTestSparkPeriod { d1, w1, m1, m3, y1, max }

class StockSparklineChart extends StatelessWidget {
  final bool ready;
  final List<double> prices;
  final double? avgPrice;
  final List<StressTestSparkPeriod> availablePeriods;
  final StressTestSparkPeriod selectedPeriod;
  final ValueChanged<StressTestSparkPeriod> onPeriodChanged;

  const StockSparklineChart({
    super.key,
    required this.ready,
    required this.prices,
    required this.availablePeriods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (!ready || prices.isEmpty) {
      return Container(
        height: 280,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: FomoShieldTheme.cardDecoration,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isUp = prices.last >= prices.first;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final openPrice = prices.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: 200,
            child: ClipRect(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _SparklinePainter(
                  prices: prices,
                  avgPrice: avgPrice,
                  lineColor: lineColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _techLabel('O:', openPrice),
                if (avgPrice != null) ...[
                  const SizedBox(width: 16),
                  _techLabel('AVG', avgPrice!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _periodCapsules(),
        ],
      ),
    );
  }

  Widget _techLabel(String prefix, double price) {
    return Text(
      '$prefix ${fmtFullCurrency(price)}',
      style: ThemeV2.small.copyWith(
        color: ThemeV2.textSecondary.withValues(alpha: 0.7),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _periodCapsules() {
    const labels = {
      StressTestSparkPeriod.d1: '1D',
      StressTestSparkPeriod.w1: '1W',
      StressTestSparkPeriod.m1: '1M',
      StressTestSparkPeriod.m3: '3M',
      StressTestSparkPeriod.y1: '1Y',
      StressTestSparkPeriod.max: 'ALL',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: availablePeriods.map((period) {
        final isActive = selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () {
              if (selectedPeriod != period) onPeriodChanged(period);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? ThemeV2.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
              ),
              child: Text(
                labels[period]!,
                style: ThemeV2.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? ThemeV2.primary : ThemeV2.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> prices;
  final double? avgPrice;
  final Color lineColor;

  _SparklinePainter({
    required this.prices,
    this.avgPrice,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    const topPad = 20.0;
    const bottomPad = 24.0;
    const leftPad = 12.0;
    const rightPad = 12.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final range = maxPrice - minPrice;

    double yPrice(double p) {
      if (range == 0) return size.height / 2;
      return topPad + chartH * (1 - (p - minPrice) / range);
    }

    double xIdx(int i) {
      return leftPad + (i / (prices.length - 1)) * chartW;
    }

    final openPrice = prices.first;
    final openY = yPrice(openPrice);
    final dashPaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, leftPad, openY, size.width - rightPad, openY, dashPaint);

    final labelStyle = TextStyle(
      color: ThemeV2.textSecondary.withValues(alpha: 0.5),
      fontSize: 9,
      fontWeight: FontWeight.w400,
    );

    if (avgPrice != null &&
        avgPrice! >= minPrice * 0.995 &&
        avgPrice! <= maxPrice * 1.005) {
      final avgY = yPrice(avgPrice!);
      final avgPaint = Paint()
        ..color = ThemeV2.textSecondary.withValues(alpha: 0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, leftPad, avgY, size.width - rightPad, avgY, avgPaint);
    }

    final path = Path();
    path.moveTo(xIdx(0), yPrice(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      path.lineTo(xIdx(i), yPrice(prices[i]));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path);
    final lastX = xIdx(prices.length - 1);
    fillPath.lineTo(lastX, size.height);
    fillPath.lineTo(xIdx(0), size.height);
    fillPath.close();

    final gradient = ui.Gradient.linear(
      Offset(0, topPad),
      Offset(0, size.height - bottomPad),
      [lineColor.withValues(alpha: 0.12), lineColor.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final minY = yPrice(minPrice);
    final minLinePaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, leftPad, minY, size.width - rightPad, minY, minLinePaint);

    final minLabel = TextPainter(
      text: TextSpan(
        text: '\$${minPrice.toStringAsFixed(2)}',
        style: labelStyle.copyWith(color: ThemeV2.textSecondary.withValues(alpha: 0.5)),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    minLabel.paint(canvas, Offset(leftPad + 2, minY + 2));

    final maxY = yPrice(maxPrice);
    final maxLinePaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, leftPad, maxY, size.width - rightPad, maxY, maxLinePaint);

    final maxLabelStyle = TextStyle(
      color: ThemeV2.textPrimary.withValues(alpha: 0.65),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    final maxLabel = TextPainter(
      text: TextSpan(text: '\$${maxPrice.toStringAsFixed(2)}', style: maxLabelStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    maxLabel.paint(canvas, Offset(size.width - rightPad - maxLabel.width - 2, maxY + 3));
  }

  void _drawDashedLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Paint paint,
  ) {
    const dashLen = 4.0;
    const gapLen = 4.0;
    final dx = x2 - x1;
    final dy = y2 - y1;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    double drawn = 0;
    bool dash = true;
    double cx = x1, cy = y1;
    while (drawn < dist) {
      final remaining = dist - drawn;
      final segment = dash ? min(dashLen, remaining) : min(gapLen, remaining);
      if (dash) {
        canvas.drawLine(Offset(cx, cy), Offset(cx + ux * segment, cy + uy * segment), paint);
      }
      cx += ux * segment;
      cy += uy * segment;
      drawn += segment;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return old.prices != prices || old.avgPrice != avgPrice || old.lineColor != lineColor;
  }
}
