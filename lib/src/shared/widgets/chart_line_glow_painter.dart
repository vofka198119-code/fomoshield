import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Draws a fill that hugs the line at every x-position, fading to fully
// transparent by the bottom of the plot — NOT fl_chart's built-in
// LineChartBarData.belowBarData, which positions its gradient relative to
// the whole chart box's Y-range (chartMinY..chartMaxY), not the line's own
// local height. That made the fill only visible near the chart's absolute
// peak and invisible everywhere the line dips below it (confirmed on-device
// 2026-08-05). This paints each line segment as its own quad, spanning from
// the line down to the plot's bottom edge, with a gradient shader scoped to
// that segment's own bounding box — so the fade genuinely follows the line
// everywhere, and always resolves to transparent right at the axis rather
// than stopping short and leaving a dead gap above it (confirmed on-device
// 2026-08-09: a fixed fade height left a visible flat gap under tall
// segments since the fill simply stopped, unfilled, partway down).
// ---------------------------------------------------------------------------

class ChartLineGlowPainter extends CustomPainter {
  /// Points already in PIXEL space (not data space) — x in [0, width],
  /// y in [0, height], y-down (standard canvas coordinates).
  final List<Offset> pixelPoints;
  final Color color;
  final double topAlpha;

  const ChartLineGlowPainter({
    required this.pixelPoints,
    required this.color,
    this.topAlpha = 0.22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pixelPoints.length < 2) return;

    for (int i = 0; i < pixelPoints.length - 1; i++) {
      final p1 = pixelPoints[i];
      final p2 = pixelPoints[i + 1];

      final segTop = p1.dy < p2.dy ? p1.dy : p2.dy;
      final fadeBottom = size.height;
      final rect = Rect.fromLTRB(p1.dx, segTop, p2.dx, fadeBottom);
      if (rect.width <= 0) continue;

      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: topAlpha),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p2.dx, fadeBottom)
        ..lineTo(p1.dx, fadeBottom)
        ..close();

      canvas.drawPath(path, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(covariant ChartLineGlowPainter oldDelegate) {
    return oldDelegate.pixelPoints != pixelPoints ||
        oldDelegate.color != color ||
        oldDelegate.topAlpha != topAlpha;
  }
}
