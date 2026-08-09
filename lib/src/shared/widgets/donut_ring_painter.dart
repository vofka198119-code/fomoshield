import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Shared allocation-donut painter — used by Stress Test's Portfolio Balance
// card (stress_test/widgets/stress_test_allocation_chart.dart) and real
// Portfolio's own Portfolio Balance card (portfolio/widgets/
// portfolio_balance_widget.dart), so the two stay visually identical and
// any future fix only has to happen in one place.
// ---------------------------------------------------------------------------

/// Deterministic distinct color for any index using golden-angle hue
/// distribution — unlimited unique colors, punchy enough to pop against a
/// dark card background.
Color donutAllocationColor(int index) {
  const double goldenAngle = 137.508; // degrees
  final hue = (index * goldenAngle) % 360.0;
  final saturation = 78.0 + (index % 3) * 7.0;
  final lightness = 55.0 + (index % 2) * 8.0;
  return HSLColor.fromAHSL(1.0, hue, saturation / 100, lightness / 100).toColor();
}

/// Paints the allocation donut as separate stroked arcs (not fl_chart's
/// PieChart) so each slice can get a round stroke cap — reads as a pill
/// shape instead of a hard-edged wedge — plus its own soft color glow
/// underneath. Stroke is kept thin (see [_strokeWidth]) so the cap's bulge
/// stays small enough not to fuse into neighboring slices once holdings
/// count grows past ~10 and individual gaps get thin. [shares] must sum to
/// ~1.0.
class DonutRingPainter extends CustomPainter {
  final List<double> shares;
  final List<Color> colors;
  final double gapDegrees;

  const DonutRingPainter({
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

    // Round stroke caps bulge outward by strokeWidth/2 in PIXELS — a fixed
    // amount independent of how big the ring is drawn. gapDegrees, on the
    // other hand, is a fixed ANGLE. On a small ring (fewer pixels per
    // degree — e.g. a narrower card than this was tuned against) that same
    // angular gap stops covering enough real pixels to clear the bulge, so
    // slices still visually fuse even with the two-sided trim below.
    // Widen the working gap, per-render, to whatever angle THIS ring's
    // actual radius needs to guarantee real pixel clearance (confirmed
    // on-device 2026-08-09: the fixed-degree gap alone wasn't enough on
    // the Portfolio card's ring size).
    final minGapForCaps = ringRadius > 0 ? (_strokeWidth / ringRadius) * 1.4 : 0.0;
    final gapRad = math.max(gapDegrees * math.pi / 180, minGapForCaps);

    final n = shares.length;
    final rawSweeps = List<double>.generate(n, (i) => shares[i] * 2 * math.pi);

    // A holding worth a trivial fraction of the portfolio (e.g. a $1 test
    // buy against a $15k+ balance) gets a near-zero raw sweep — no gap fix
    // helps there, since there's no meaningful arc left to separate; the
    // round stroke cap just paints a dot, indistinguishable from any other
    // near-zero neighbor at the same spot. Bump every slice up to a
    // radius-aware minimum visible width, taking the angle it gained back
    // out of the bigger slices (proportionally to their own size) so the
    // ring still sums to a full circle. Skipped if there isn't remotely
    // enough room for everyone to get the minimum (very high slice counts).
    final minSweep = ringRadius > 0 ? (_strokeWidth * 2.2) / ringRadius : 0.0;
    if (n > 1 && minSweep > 0 && minSweep * n < 2 * math.pi) {
      final isSmall = List<bool>.filled(n, false);
      double deficit = 0;
      for (var i = 0; i < n; i++) {
        if (rawSweeps[i] < minSweep) {
          deficit += minSweep - rawSweeps[i];
          rawSweeps[i] = minSweep;
          isSmall[i] = true;
        }
      }
      if (deficit > 1e-9) {
        var bigTotal = 0.0;
        for (var i = 0; i < n; i++) {
          if (!isSmall[i]) bigTotal += rawSweeps[i];
        }
        if (bigTotal > 1e-9) {
          for (var i = 0; i < n; i++) {
            if (!isSmall[i]) {
              rawSweeps[i] -= deficit * (rawSweeps[i] / bigTotal);
            }
          }
        }
      }
    }

    final rawStarts = <double>[];
    double startAngle = -math.pi / 2;
    for (var i = 0; i < n; i++) {
      rawStarts.add(startAngle);
      startAngle += rawSweeps[i];
    }

    // Every boundary gets trimmed on BOTH sides, not just donated entirely
    // from the bigger neighbor — a donor-only trim left the smaller slice
    // with a full, untrimmed, round-capped edge that ate back into
    // whatever gap the bigger neighbor donated. What actually determines
    // whether two round caps visually touch is the TOTAL angle removed
    // between the two slices' raw endpoints (giveI + giveNext) — not how
    // that total is split between the two sides — so the only real
    // requirement is: always realize the full gapRad if at all possible.
    // Each side first takes its own half, capped at 90% of its own sweep
    // (never fully erasing a sliver-thin slice); if one side is too thin
    // to cover its half, the shortfall is pulled from whatever spare
    // capacity BOTH sides have left (not just whichever is bigger) —
    // covers the case of two adjacent slices that are both thin, which a
    // single-donor rule could still under-trim.
    final trimStart = List<double>.filled(n, 0.0);
    final trimEnd = List<double>.filled(n, 0.0);
    if (n > 1) {
      for (var i = 0; i < n; i++) {
        final next = (i + 1) % n;
        final sweepI = rawSweeps[i];
        final sweepNext = rawSweeps[next];
        final wantEach = gapRad / 2;
        final capI = sweepI * 0.9;
        final capNext = sweepNext * 0.9;
        var giveI = math.min(wantEach, capI);
        var giveNext = math.min(wantEach, capNext);
        final shortfall = gapRad - giveI - giveNext;
        if (shortfall > 1e-9) {
          final spareI = capI - giveI;
          final spareNext = capNext - giveNext;
          final totalSpare = spareI + spareNext;
          if (totalSpare > 1e-9) {
            final takeI = math.min(spareI, shortfall * (spareI / totalSpare));
            final takeNext = math.min(spareNext, shortfall - takeI);
            giveI += takeI;
            giveNext += takeNext;
          }
        }
        trimEnd[i] += giveI;
        trimStart[next] += giveNext;
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
  bool shouldRepaint(covariant DonutRingPainter oldDelegate) => true;
}
