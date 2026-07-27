import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final bool showDigitalReadout;

  const MarketClockDial({
    super.key,
    required this.state,
    this.size = 240,
    this.ringStroke = 7,
    this.showDigitalReadout = false,
  });

  @override
  Widget build(BuildContext context) {
    final faceSize = size - ringStroke * 2 - size * 0.067;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(strokeWidth: ringStroke, color: dialBrassLight),
          ),
          SizedBox(
            width: faceSize,
            height: faceSize,
            child: CustomPaint(painter: _ClockFaceBackgroundPainter()),
          ),
          if (showDigitalReadout)
            Transform.translate(
              offset: Offset(0, size * 0.12),
              child: _DigitalReadout(nowEt: state.nowEt, phase: state.phase, size: size),
            ),
          SizedBox(
            width: faceSize,
            height: faceSize,
            child: CustomPaint(painter: _ClockHandsPainter(state.nowEt)),
          ),
        ],
      ),
    );
  }
}

/// Electronic-display style 24h readout shown inside the dial, tinted by the
/// current trading phase (calendar closures already fold into `phase` via
/// `resolveMarketClockState` — a weekend/holiday resolves to `closed` same
/// as an ordinary overnight close, so no separate calendar check is needed).
class _DigitalReadout extends StatelessWidget {
  final DateTime nowEt;
  final MarketPhase phase;
  final double size;
  const _DigitalReadout({required this.nowEt, required this.phase, required this.size});

  static Color _colorForPhase(MarketPhase phase) {
    switch (phase) {
      case MarketPhase.preMarket:
        return dialBrassLight;
      case MarketPhase.marketOpen:
        return ThemeV2.success;
      case MarketPhase.afterHours:
        return const Color(0xFF5DA9E0);
      case MarketPhase.closed:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hh = nowEt.hour.toString().padLeft(2, '0');
    final mm = nowEt.minute.toString().padLeft(2, '0');
    final color = _colorForPhase(phase);
    final fontSize = size * 0.065;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.035, vertical: size * 0.012),
      decoration: BoxDecoration(
        color: dialDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(size * 0.025),
        border: Border.all(color: dialBrassLight.withValues(alpha: 0.4), width: size * 0.004),
      ),
      child: Text(
        '$hh:$mm',
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.8), blurRadius: fontSize * 0.35),
            Shadow(color: color.withValues(alpha: 0.5), blurRadius: fontSize * 0.7),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  _RingPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.1);
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

Offset _polar(Offset center, double radius, double degrees) {
  final rad = (degrees - 90) * pi / 180;
  return Offset(center.dx + radius * cos(rad), center.dy + radius * sin(rad));
}

/// Dial gradient + ticks + numerals only — painted behind the digital
/// readout so [_ClockHandsPainter] can be layered on top of it.
class _ClockFaceBackgroundPainter extends CustomPainter {
  static const _tickMinor = Color(0xFF5C6E64);

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
  }

  @override
  bool shouldRepaint(covariant _ClockFaceBackgroundPainter oldDelegate) => false;
}

/// Hour/minute hands + center pivot cap only — painted on top of the digital
/// readout so the hands visually pass over it, matching a real watch's
/// date-window layering.
class _ClockHandsPainter extends CustomPainter {
  final DateTime time;
  _ClockHandsPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

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
  bool shouldRepaint(covariant _ClockHandsPainter oldDelegate) => oldDelegate.time != time;
}
