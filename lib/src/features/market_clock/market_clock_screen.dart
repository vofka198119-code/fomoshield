import 'dart:async';
import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_engine.dart';

class MarketClockScreen extends StatefulWidget {
  const MarketClockScreen({super.key});

  @override
  State<MarketClockScreen> createState() => _MarketClockScreenState();
}

class _MarketClockScreenState extends State<MarketClockScreen> {
  late Timer _timer;
  late MarketClockState _state;

  @override
  void initState() {
    super.initState();
    _state = resolveMarketClockState(nowInNewYork());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _state = resolveMarketClockState(nowInNewYork()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final window = _state.window;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'MARKET CLOCK',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _MarketClockDial(state: _state),
            const SizedBox(height: 24),
            _TimingBox(window: window, isEarlyClose: _state.isEarlyCloseDay),
          ],
        ),
      ),
    );
  }
}

class _MarketClockDial extends StatelessWidget {
  final MarketClockState state;
  const _MarketClockDial({required this.state});

  static const double _size = 240;
  static const double _ringStroke = 14;

  @override
  Widget build(BuildContext context) {
    final minuteOfDay = state.nowEt.hour * 60 + state.nowEt.minute;
    final ringRadius = (_size - _ringStroke) / 2;
    final angle = angleForMinuteOfDay(minuteOfDay);
    final markerOffset = Offset(ringRadius * cos(angle), ringRadius * sin(angle));

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(_size, _size), painter: _RingPainter()),
          Container(
            width: _size - _ringStroke * 2 - 16,
            height: _size - _ringStroke * 2 - 16,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: ThemeV2.surface),
            child: CustomPaint(painter: _ClockFacePainter(state.nowEt)),
          ),
          Transform.translate(
            offset: markerOffset,
            child: _PhaseMarker(phase: state.phase),
          ),
        ],
      ),
    );
  }
}

class _PhaseMarker extends StatelessWidget {
  final MarketPhase phase;
  const _PhaseMarker({required this.phase});

  static const _icons = {
    MarketPhase.closed: Icons.bedtime_rounded,
    MarketPhase.preMarket: Icons.wb_twilight,
    MarketPhase.marketOpen: Icons.wb_sunny_rounded,
    MarketPhase.afterHours: Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Icon(_icons[phase], size: 16, color: _ringColorForPhase(phase)),
    );
  }
}

Color _ringColorForPhase(MarketPhase phase) {
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
  static const double _strokeWidth = _MarketClockDial._ringStroke;

  static final _segments = <(int, int, Color)>[
    (240, 570, _ringColorForPhase(MarketPhase.preMarket)),
    (570, 960, _ringColorForPhase(MarketPhase.marketOpen)),
    (960, 1200, _ringColorForPhase(MarketPhase.afterHours)),
    (1200, 1440, _ringColorForPhase(MarketPhase.closed)),
    (0, 240, _ringColorForPhase(MarketPhase.closed)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final (start, end, color) in _segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
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

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final tickPaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.4)
      ..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * pi / 180 - pi / 2;
      final isMajor = i % 3 == 0;
      final outerR = radius - 4;
      final innerR = radius - (isMajor ? 12 : 6);
      final outer = Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle));
      final inner = Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle));
      canvas.drawLine(inner, outer, tickPaint);
    }

    final hourAngle = ((time.hour % 12) + time.minute / 60) * 30 * pi / 180 - pi / 2;
    final minuteAngle = (time.minute + time.second / 60) * 6 * pi / 180 - pi / 2;

    final hourHandPaint = Paint()
      ..color = ThemeV2.textPrimary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final minuteHandPaint = Paint()
      ..color = ThemeV2.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.5 * cos(hourAngle), center.dy + radius * 0.5 * sin(hourAngle)),
      hourHandPaint,
    );
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.72 * cos(minuteAngle), center.dy + radius * 0.72 * sin(minuteAngle)),
      minuteHandPaint,
    );
    canvas.drawCircle(center, 4, Paint()..color = ThemeV2.primary);
  }

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) => oldDelegate.time != time;
}

class _TimingBox extends StatelessWidget {
  final MarketWindow window;
  final bool isEarlyClose;
  const _TimingBox({required this.window, required this.isEarlyClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(window.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        window.shortHeadline,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  window.shortDetail,
                  style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  window.timeRangeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ThemeV2.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/market-clock/period/${window.id}'),
            icon: const Icon(Icons.help_outline_rounded, color: ThemeV2.primary),
            tooltip: 'Подробнее',
          ),
        ],
      ),
    );
  }
}
