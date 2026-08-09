// ---------------------------------------------------------------------------
// Stress Test — Allocation Donut Chart card
// Extracted from stress_test_screen.dart (Phase 5, step-by-step widget pass).
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../stress_test_models.dart';
import '../stress_test_naming.dart';

/// Card wrapper: donut chart + centered portfolio metrics + cash capsule,
/// styled to the standard light card (see reference_widget_card_standard).
class StressTestAllocationChart extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<StressTestAllocationChart> createState() =>
      _StressTestAllocationChartState();
}

class _StressTestAllocationChartState
    extends ConsumerState<StressTestAllocationChart> {
  static const int _legendPreviewLimit = 5;
  bool _showAll = false;

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
    final session = widget.session;
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
    // Balance itself already reflects the whole account (cash + positions,
    // including any realized gains already banked into cash) — this
    // subtitle shows Unrealized P&L specifically (paper P&L on currently
    // held positions only), so it stops double-counting realized gains
    // that are already visible in Balance. Realized P&L lives in its own
    // row on the Psychology Meter's Session Stats card. Confirmed
    // 2026-08-07 after a live on-device walkthrough.
    final pnl = session.unrealizedPnl;
    final pnlPercent = session.unrealizedPnlPercent;
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
          InkWell(
            onTap: () => context.push('/stress-test/${session.id}/portfolio-balance'),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                child: Row(
                  children: [
                    Text(
                      'PORTFOLIO BALANCE',
                      style: FomoShieldTheme.cardTitle(),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: ThemeV2.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 16),
          Padding(
            // Wider than the title's 22px inset on purpose — shrinks the
            // ring itself so it doesn't dominate the card now that a legend
            // sits below it (see _DonutRingPainter, which derives its
            // radius from the box size it's given).
            padding: const EdgeInsets.symmetric(horizontal: 40),
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
                                  (i) => StressTestAllocationChart.allocationColor(i),
                                )
                              : [Colors.black.withValues(alpha: 0.06)],
                          gapDegrees: hasData ? 5 : 0,
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
          if (hasData) ...[
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    for (
                      var i = 0;
                      i <
                          (_showAll
                              ? invested.length
                              : math.min(_legendPreviewLimit, invested.length));
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: StressTestAllocationChart.allocationColor(i),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                resolveStressTestCompanyName(
                                  ref,
                                  invested[i].symbol,
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeV2.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(invested[i].value / totalInvested * 100).toStringAsFixed(1)}%',
                              style: interNums(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (invested.length > _legendPreviewLimit)
                      GestureDetector(
                        onTap: () => setState(() => _showAll = !_showAll),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: ThemeV2.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _showAll
                                  ? 'Less'
                                  : 'More (${invested.length - _legendPreviewLimit})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Paints the allocation donut as separate stroked arcs (not fl_chart's
/// PieChart) so each slice can get a round stroke cap — reads as a pill
/// shape instead of a hard-edged wedge — plus its own soft color glow
/// underneath. Stroke is kept thin (see [_strokeWidth]) so the cap's bulge
/// stays small enough not to fuse into neighboring slices once holdings
/// count grows past ~10 and individual gaps get thin. [shares] must sum
/// to ~1.0.
class _DonutRingPainter extends CustomPainter {
  final List<double> shares;
  final List<Color> colors;
  final double gapDegrees;

  const _DonutRingPainter({
    required this.shares,
    required this.colors,
    this.gapDegrees = 6,
  });

  static const double _strokeWidth = 7;
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

    final n = shares.length;
    final rawSweeps = List<double>.generate(n, (i) => shares[i] * 2 * math.pi);
    final rawStarts = <double>[];
    double startAngle = -math.pi / 2;
    for (var i = 0; i < n; i++) {
      rawStarts.add(startAngle);
      startAngle += rawSweeps[i];
    }

    // Each boundary's gap is carved out of whichever of its two neighbors
    // is BIGGER, never the smaller one. Sizing the gap off the smaller
    // slice (the old approach) meant the smallest slice in the whole ring
    // — which, since holdings are sorted by value, sits right where the
    // ring wraps back to the largest slice — always got the thinnest gap
    // of anywhere on the ring. Taking it from the bigger neighbor instead
    // means that seam gets a full-size gap donated from the large slice,
    // which has plenty of room to spare, while tiny slices are never
    // shrunk further.
    final trimStart = List<double>.filled(n, 0.0);
    final trimEnd = List<double>.filled(n, 0.0);
    if (n > 1) {
      for (var i = 0; i < n; i++) {
        final next = (i + 1) % n;
        final donorIsCurrent = rawSweeps[i] >= rawSweeps[next];
        final donorSweep = donorIsCurrent ? rawSweeps[i] : rawSweeps[next];
        final gap = math.min(gapRad, donorSweep * 0.8);
        if (donorIsCurrent) {
          trimEnd[i] += gap;
        } else {
          trimStart[next] += gap;
        }
      }
    }

    final starts = <double>[];
    final sweeps = <double>[];
    for (var i = 0; i < n; i++) {
      starts.add(rawStarts[i] + trimStart[i]);
      sweeps.add(rawSweeps[i] - trimStart[i] - trimEnd[i]);
    }

    // One shared blur pass for every slice's glow, instead of a separate
    // MaskFilter.blur per slice — with 10+ holdings that was 10+ blur
    // layers in a single frame, which was corrupting/truncating the rest
    // of the page's raster on some Android GPUs (MediaTek in particular).
    canvas.saveLayer(
      rect.inflate(_strokeWidth + _glowBlurSigma * 3),
      Paint()
        ..imageFilter = ImageFilter.blur(
          sigmaX: _glowBlurSigma,
          sigmaY: _glowBlurSigma,
        ),
    );
    canvas.save();
    canvas.translate(0, _glowOffset);
    for (var i = 0; i < shares.length; i++) {
      final glowPaint = Paint()
        ..color = colors[i].withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, starts[i], sweeps[i], false, glowPaint);
    }
    canvas.restore();
    canvas.restore();

    for (var i = 0; i < shares.length; i++) {
      final slicePaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, starts[i], sweeps[i], false, slicePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) => true;
}
