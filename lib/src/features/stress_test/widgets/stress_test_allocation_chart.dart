// ---------------------------------------------------------------------------
// Stress Test — Allocation Donut Chart card
// Extracted from stress_test_screen.dart (Phase 5, step-by-step widget pass).
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../stress_test_models.dart';

/// Card wrapper: donut chart + centered portfolio metrics + cash capsule,
/// styled to the standard light card (see reference_widget_card_standard).
class StressTestAllocationChart extends StatelessWidget {
  final StressTestSession session;

  const StressTestAllocationChart({super.key, required this.session});

  /// Generates a deterministic distinct color for any index using
  /// golden-angle hue distribution — unlimited unique colors. Public because
  /// the My Assets list (stress_test_screen.dart) rings each logo in the
  /// same color as its donut slice, so both must share one source.
  static Color allocationColor(int index) {
    const double goldenAngle = 137.508; // degrees
    final hue = (index * goldenAngle) % 360.0;
    // Punchier than before — vivid saturation, brighter lightness so slices
    // pop against the dark-green card background.
    final saturation = 78.0 + (index % 3) * 7.0;
    final lightness = 55.0 + (index % 2) * 8.0;
    return HSLColor.fromAHSL(
      1.0,
      hue,
      saturation / 100,
      lightness / 100,
    ).toColor();
  }

  /// Full number format with commas and fixed 2 decimals — e.g. $15,000.00
  String _fmtFull(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intStr = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
      buf.write(intStr[i]);
    }
    buf.write('.');
    buf.write(parts[1]);
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final holdings = session.holdings;
    final isEmpty = holdings.isEmpty;

    final invested = <({String symbol, double value})>[];
    double totalInvested = 0;
    for (final h in holdings) {
      final price = session.currentPrices[h.symbol] ?? h.entryPrice;
      final val = h.shares * price;
      invested.add((symbol: h.symbol, value: val));
      totalInvested += val;
    }
    invested.sort((a, b) => b.value.compareTo(a.value));

    final hasData = !isEmpty && totalInvested > 0;

    final portfolioTotal = session.totalValue;
    final pnl = session.profitLoss;
    final pnlPercent = session.profitLossPercent;
    final isPositive = pnl >= 0;
    final isZero = pnl == 0;
    final pnlColor = isZero
        ? ThemeV2.textSecondary
        : isPositive
        ? ThemeV2.success
        : ThemeV2.loss;
    final pnlText = isZero
        ? '\$0.00'
        : '${isPositive ? '+' : '-'}\$${_fmtFull(pnl.abs())} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)';

    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Text(
                'PORTFOLIO BALANCE',
                style: FomoShieldTheme.cardTitle(),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 32),
          Padding(
            // Same 22px inset as the title above — the ring fills the full
            // width between these margins (see _DonutRingPainter, which
            // derives its radius from the box size it's given).
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final ringSize = constraints.maxWidth;
                return SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: _DonutRingPainter(
                          shares: hasData
                              ? invested
                                    .map((item) => item.value / totalInvested)
                                    .toList()
                              : [1.0],
                          colors: hasData
                              ? List.generate(
                                  invested.length,
                                  (i) => allocationColor(i),
                                )
                              : [Colors.black.withValues(alpha: 0.06)],
                          gapDegrees: hasData ? 6 : 0,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'BALANCE',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeV2.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${_fmtFull(portfolioTotal)}',
                            style: interNums(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pnlText,
                            style: interNums(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: pnlColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Bottom inset matches the top gap (divider → ring) for symmetry
          // now that the cash capsule (moved to StressTestCashWidget) no
          // longer fills this space.
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Paints the allocation donut as separate stroked arcs (not fl_chart's
/// PieChart) so each slice can get a round stroke cap — reads as a pill
/// shape instead of a hard-edged wedge — plus its own soft color glow
/// underneath. [shares] must sum to ~1.0.
class _DonutRingPainter extends CustomPainter {
  final List<double> shares;
  final List<Color> colors;
  final double gapDegrees;

  const _DonutRingPainter({
    required this.shares,
    required this.colors,
    this.gapDegrees = 6,
  });

  static const double _strokeWidth = 10;
  static const double _glowOffset = 5;
  static const double _glowBlurSigma = 6;
  // Room left inside the box edge for the glow's blur/offset bleed so it
  // doesn't get hard-clipped by the parent Stack.
  static const double _edgeMargin = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.shortestSide / 2 - _strokeWidth / 2 - _edgeMargin;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    final gapRad = gapDegrees * math.pi / 180;

    double startAngle = -math.pi / 2;
    for (var i = 0; i < shares.length; i++) {
      final sweep = shares[i] * 2 * math.pi;
      final drawSweep = shares.length > 1
          ? (sweep - gapRad).clamp(0.05, sweep)
          : sweep;
      final color = colors[i];

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlurSigma);
      canvas.save();
      canvas.translate(0, _glowOffset);
      canvas.drawArc(rect, startAngle, drawSweep, false, glowPaint);
      canvas.restore();

      final slicePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, drawSweep, false, slicePaint);

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) => true;
}
