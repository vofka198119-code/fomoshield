import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Shared color/fill math for the red->yellow->green 20-segment gauge used by
// the TARGET widget's two layouts — horizontal on the Portfolio screen
// (_SegmentedBar in target_widget.dart), vertical on Home
// (_VerticalProgressBar in portfolio_widget.dart). Layout (Row vs Column,
// marker positioning) stays separate per widget on purpose; only the math
// that has to agree between them lives here, so tuning thresholds/colors
// later is one edit instead of two hand-kept-in-sync copies.
// ---------------------------------------------------------------------------

class SegmentGaugeMath {
  static const int segmentCount = 20;
  static const double rangeWidth = 200 / segmentCount; // 10%
  static const Color red = Color(0xFFFF3B30);
  static const Color yellow = Color(0xFFFFD600);
  static const Color green = Color(0xFF00C853);
  static const Color unfilled = Color(0x33FFFFFF); // white @ 20%

  static double rangeStart(int index) => -100 + index * rangeWidth;

  /// Color at the segment's midpoint, red (-100%) -> yellow (0%) -> green (+100%).
  static Color colorForIndex(int index) {
    final t = (index + 0.5) / segmentCount;
    if (t <= 0.5) return Color.lerp(red, yellow, t / 0.5)!;
    return Color.lerp(yellow, green, (t - 0.5) / 0.5)!;
  }

  /// How much of this segment's range is filled, 0..1.
  static double fillFraction(double currentPercent, int index) {
    final start = rangeStart(index);
    if (currentPercent <= start) return 0.0;
    if (currentPercent >= start + rangeWidth) return 1.0;
    return (currentPercent - start) / rangeWidth;
  }
}
