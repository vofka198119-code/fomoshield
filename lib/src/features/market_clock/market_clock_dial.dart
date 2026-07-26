import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Market Clock Dial — instrument-panel style analog clock ringed by the
// 4 trading-phase colors. Reused at full size on the Market Clock screen and
// at mini size in the Home widget, so all sizing is relative to [size].
// ---------------------------------------------------------------------------

const dialDark = Color(0xFF0A1B15);
const dialMid = Color(0xFF0F281F);
const dialLight = Color(0xFF173A2E);
const dialBrassLight = Color(0xFFE8C468);
const dialIvory = Color(0xFFF3E7C9);

/// Card wrapper for anything sitting on the same instrument-panel dial
/// background — keeps the Market Clock screen and Home widget visually
/// unified (gradient IS the card background, not a separate surface color).
BoxDecoration marketClockCardDecoration({BorderRadius? borderRadius}) =>
    BoxDecoration(
      gradient: const RadialGradient(
        center: Alignment(0, -0.3),
        radius: 1.2,
        colors: [dialLight, dialMid, dialDark],
        stops: [0.0, 0.6, 1.0],
      ),
      borderRadius: borderRadius ?? FomoShieldTheme.cardRadius,
      boxShadow: FomoShieldTheme.shadowSoft,
    );

class MarketClockDial extends StatelessWidget {
  final MarketClockState state;
  final double size;
  final double ringStroke;

  const MarketClockDial({
    super.key,
    required this.state,
    this.size = 240,
    this.ringStroke = 14,
  });

  @override
  Widget build(BuildContext context) {
    final minuteOfDay = state.nowEt.hour * 60 + state.nowEt.minute;
    final ringRadius = (size - ringStroke) / 2;
    final angle = angleForMinuteOfDay(minuteOfDay);
    final markerOffset = Offset(ringRadius * cos(angle), ringRadius * sin(angle));
    final markerSize = size * 0.117;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _RingPainter(strokeWidth: ringStroke)),
          SizedBox(
            width: size - ringStroke * 2 - size * 0.067,
            height: size - ringStroke * 2 - size * 0.067,
            child: CustomPaint(painter: _ClockFacePainter(state.nowEt)),
          ),
          Transform.translate(
            offset: markerOffset,
            child: _PhaseMarker(phase: state.phase, size: markerSize),
          ),
        ],
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  final MarketPhase phase;
  final double size;
  const _PhaseMarker({required this.phase, required this.size});

  static const _icons = {
    MarketPhase.closed: Icons.bedtime_rounded,
    MarketPhase.preMarket: Icons.wb_twilight,
    MarketPhase.marketOpen: Icons.wb_sunny_rounded,
    MarketPhase.afterHours: Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Icon(_icons[phase], size: size * 0.58, color: ringColorForPhase(phase)),
    );
  }
}

Color ringColorForPhase(MarketPhase phase) {
  switch (phase) {
    case MarketPhase.preMarket:
      return const Color(0xFFE3B341);
    case MarketPhase.marketOpen:
      return ThemeV2.success;
    case MarketPhase.afterHours:
      return const Color(0xFF3E7CB8);
    case MarketPhase.closed:
      return ThemeV2.textSecondary;
  }
}

class _RingPainter extends CustomPainter {
  final double strokeWidth;
  _RingPainter({required this.strokeWidth});

  static final _segments = <(int, int, Color)>[
    (240, 570, Color(0xFFE3B341)),
    (570, 960, ThemeV2.success),
    (960, 1200, Color(0xFF3E7CB8)),
    (1200, 1440, ThemeV2.textSecondary),
    (0, 240, ThemeV2.textSecondary),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final (start, end, color) in _segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      final startAngle = angleForMinuteOfDay(start);
      final sweepAngle = angleForMinuteOfDay(end) - startAngle;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}

class _ClockFacePainter extends CustomPainter {
  final DateTime time;
  _ClockFacePainter(this.time);

  static const _tickMinor = Color(0xFF5C6E64);

  Offset _polar(Offset center, double radius, double degrees) {
    final rad = (degrees - 90) * pi / 180;
    return Offset(center.dx + radius * cos(rad), center.dy + radius * sin(rad));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final dialPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.16),
        radius: 0.9,
        colors: [dialLight, dialMid, dialDark],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, dialPaint);

    for (int i = 0; i < 60; i++) {
      final isHour = i % 5 == 0;
      final deg = i * 6.0;
      final p1 = _polar(center, r * (isHour ? 0.86 : 0.90), deg);
      final p2 = _polar(center, r * 0.94, deg);
      final tickPaint = Paint()
        ..color = isHour ? dialBrassLight : _tickMinor
        ..strokeWidth = isHour ? r * 0.03 : r * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, tickPaint);
    }

    final numeralStyle = TextStyle(
      color: dialIvory,
      fontSize: r * 0.16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Georgia',
      letterSpacing: 0.5,
    );
    for (int i = 1; i <= 12; i++) {
      final deg = i * 30.0;
      final pos = _polar(center, r * 0.68, deg);
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: numeralStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    final hourDeg = (time.hour % 12) * 30.0 + time.minute * 0.5;
    final hourTip = _polar(center, r * 0.42, hourDeg);
    canvas.drawLine(
      center,
      hourTip,
      Paint()
        ..color = dialIvory
        ..strokeWidth = r * 0.045
        ..strokeCap = StrokeCap.round,
    );

    final minDeg = time.minute * 6.0 + time.second * 0.1;
    final minTip = _polar(center, r * 0.62, minDeg);
    canvas.drawLine(
      center,
      minTip,
      Paint()
        ..color = dialIvory
        ..strokeWidth = r * 0.028
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, r * 0.05, Paint()..color = dialDark);
    canvas.drawCircle(
      center,
      r * 0.05,
      Paint()
        ..color = dialBrassLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.014,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) => oldDelegate.time != time;
}
