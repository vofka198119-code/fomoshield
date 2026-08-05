import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Draws a fill that hugs the line at every x-position, fading to transparent
// a fixed number of pixels below it — NOT fl_chart's built-in
// LineChartBarData.belowBarData, which positions its gradient relative to
// the whole chart box's Y-range (chartMinY..chartMaxY), not the line's own
// local height. That made the fill only visible near the chart's absolute
// peak and invisible everywhere the line dips below it (confirmed on-device
// 2026-08-05). This paints each line segment as its own small quad with a
// gradient shader scoped to that segment's own bounding box, so the fade
// genuinely follows the line everywhere, not just near the top of the chart.
// ---------------------------------------------------------------------------

class ChartLineGlowPainter extends CustomPainter {
  /// Points already in PIXEL space (not data space) — x in [0, width],
  /// y in [0, height], y-down (standard canvas coordinates).
  final List<Offset> pixelPoints;
  final Color color;
  final double fadeHeight;
  final double topAlpha;

  const ChartLineGlowPainter({
    required this.pixelPoints,
    required this.color,
    required this.fadeHeight,
    this.topAlpha = 0.22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pixelPoints.length < 2) return;

    for (int i = 0; i < pixelPoints.length - 1; i++) {
      final p1 = pixelPoints[i];
      final p2 = pixelPoints[i + 1];

      final segTop = p1.dy < p2.dy ? p1.dy : p2.dy;
      final rect = Rect.fromLTRB(p1.dx, segTop, p2.dx, segTop + fadeHeight);
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
        ..lineTo(p2.dx, p2.dy + fadeHeight)
        ..lineTo(p1.dx, p1.dy + fadeHeight)
        ..close();

      canvas.drawPath(path, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(covariant ChartLineGlowPainter oldDelegate) {
    return oldDelegate.pixelPoints != pixelPoints ||
        oldDelegate.color != color ||
        oldDelegate.fadeHeight != fadeHeight ||
        oldDelegate.topAlpha != topAlpha;
  }
}
