import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/themed_border.dart';
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

/// Palette for the dark "instrument panel" card family. Centralizes what
/// used to be individual dialLight/dialMid/dialDark/dialIvory consts
/// referenced directly by ~34 files, so a future alternate palette (e.g. a
/// premium theme) is a single new [DarkCardPalette] instance + one swap
/// point, not another pass through every dark-card consumer. Only
/// [instrumentPanel] exists today — no switching mechanism yet, this just
/// prepares the seam for one.
class DarkCardPalette {
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color accentGold;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const DarkCardPalette({
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.accentGold,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  // Text stays plain white — user explicitly kept white text on 2026-08-14
  // when rolling the radial gradient out app-wide (only the gradient shape
  // was the ask, not Market Clock's own dialIvory tone). Fields exist so a
  // real future palette can override them; not wired to any widget yet.
  static const instrumentPanel = DarkCardPalette(
    gradientStart: dialLight,
    gradientMid: dialMid,
    gradientEnd: dialDark,
    accentGold: dialBrassLight,
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textTertiary: Colors.white54,
  );
}

/// Shared dark-card shell — the radial "instrument panel" gradient, now the
/// single standard for every dark/premium card, button, pill and badge (was
/// previously Market Clock only; the rest used a flat linear
/// `[dialLight, dialDark]` gradient — see docs/DESIGN_TOKENS.md §3/§11,
/// unified 2026-08-14). [borderRadius] defaults to the unified 22px card
/// radius; pass a smaller one for buttons/pills/badges.
/// The gradient alone, for the rare shape (e.g. a circular avatar-style
/// badge) that can't take a [BoxDecoration.borderRadius] at all.
RadialGradient darkCardGradient({
  DarkCardPalette palette = DarkCardPalette.instrumentPanel,
}) => RadialGradient(
  center: const Alignment(0, -0.3),
  radius: 1.2,
  colors: [palette.gradientStart, palette.gradientMid, palette.gradientEnd],
  stops: const [0.0, 0.6, 1.0],
);

BoxDecoration darkCardDecoration({
  BorderRadius? borderRadius,
  DarkCardPalette palette = DarkCardPalette.instrumentPanel,
}) => BoxDecoration(
  gradient: darkCardGradient(palette: palette),
  borderRadius: borderRadius ?? FomoShieldTheme.cardRadius,
  boxShadow: FomoShieldTheme.shadowSoft,
);

/// Same brand dark-green colors as [darkCardGradient], but a vertical
/// linear gradient (light top -> dark bottom) instead of radial — the BUY
/// / "Place Order" CTA buttons' own look (user's ask, 2026-09-03: keep the
/// color, just stop using the radial instrument-panel shape there). Not a
/// replacement for [darkCardGradient] itself, which stays the standard for
/// every OTHER dark card/button/pill/badge app-wide.
LinearGradient buyButtonGradient({
  DarkCardPalette palette = DarkCardPalette.instrumentPanel,
}) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [palette.gradientStart, palette.gradientMid, palette.gradientEnd],
);

BoxDecoration buyButtonDecoration({
  BorderRadius? borderRadius,
  DarkCardPalette palette = DarkCardPalette.instrumentPanel,
}) => BoxDecoration(
  gradient: buyButtonGradient(palette: palette),
  borderRadius: borderRadius ?? FomoShieldTheme.cardRadius,
  boxShadow: FomoShieldTheme.shadowSoft,
);

/// Card wrapper for anything sitting on the same instrument-panel dial
/// background — keeps the Market Clock screen and Home widget visually
/// unified (gradient IS the card background, not a separate surface color).
/// [palette]?.windowGradient, when set, replaces the default green
/// instrument-panel gradient (same "dark green becomes this theme's own
/// dark treatment" swap every other `darkCardDecoration()` call site
/// makes) — null (the default) keeps the original look untouched.
BoxDecoration marketClockCardDecoration({
  BorderRadius? borderRadius,
  AppPalette? palette,
}) => palette?.windowGradient != null
    ? BoxDecoration(
        gradient: palette!.windowGradient,
        borderRadius: borderRadius ?? FomoShieldTheme.cardRadius,
        boxShadow: FomoShieldTheme.shadowSoft,
      )
    : darkCardDecoration(borderRadius: borderRadius);

class MarketClockDial extends StatelessWidget {
  final MarketClockState state;
  final double size;
  final double ringStroke;
  final bool showDigitalReadout;

  // Null (the default) is a complete no-op — the dial keeps its original
  // green "instrument panel" face everywhere that doesn't pass a themed
  // palette (e.g. the full Market Clock screen's own dial, not yet part
  // of the Luxury Gold rollout). Only the face background is affected —
  // ring/ticks/numerals stay as-is regardless.
  final AppPalette? palette;

  const MarketClockDial({
    super.key,
    required this.state,
    this.size = 240,
    this.ringStroke = 7,
    this.showDigitalReadout = false,
    this.palette,
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
            painter: _RingPainter(
              strokeWidth: ringStroke,
              color: palette?.marketClockAccent ?? dialBrassLight,
              gradient: palette?.marketClockRingGradient,
              glowOpacity: palette?.glowOpacity ?? 0.35,
            ),
          ),
          SizedBox(
            width: faceSize,
            height: faceSize,
            child: CustomPaint(
              painter: _ClockFaceBackgroundPainter(
                faceGradient:
                    palette?.marketClockFaceGradient ?? palette?.windowGradient,
                numeralColor: palette?.marketClockAccent,
              ),
            ),
          ),
          if (showDigitalReadout)
            Transform.translate(
              offset: Offset(0, size * 0.12),
              child: _DigitalReadout(
                nowEt: state.nowEt,
                phase: state.phase,
                size: size,
                palette: palette,
              ),
            ),
          SizedBox(
            width: faceSize,
            height: faceSize,
            child: CustomPaint(
              painter: _ClockHandsPainter(
                state.nowEt,
                handColor: palette?.marketClockAccent != null
                    ? (palette?.onWindow ?? Colors.white)
                    : null,
                pivotColor: palette?.marketClockAccent,
                pivotFillColor:
                    palette?.marketClockAccent != null ? palette!.card : null,
              ),
            ),
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
  final AppPalette? palette;
  const _DigitalReadout({
    required this.nowEt,
    required this.phase,
    required this.size,
    this.palette,
  });

  // preMarket/closed were flat dialBrassLight (gold) / Colors.white,
  // unconditionally — fine while this box was always dark, but now that a
  // themed palette (Black & White) makes it light via `isThemed` below,
  // gold reads as unwanted "sandy" color and white is invisible. Themed
  // callers get marketClockAccent (black for B&W) / onWindow instead; an
  // untheemed palette keeps the original two colors exactly.
  static Color _colorForPhase(MarketPhase phase, AppPalette? palette) {
    switch (phase) {
      case MarketPhase.preMarket:
        return palette?.marketClockAccent ?? dialBrassLight;
      case MarketPhase.marketOpen:
        return ThemeV2.success;
      case MarketPhase.afterHours:
        return const Color(0xFF5DA9E0);
      case MarketPhase.closed:
        return palette?.onWindow ?? Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hh = nowEt.hour.toString().padLeft(2, '0');
    final mm = nowEt.minute.toString().padLeft(2, '0');
    final color = _colorForPhase(phase, palette);
    final fontSize = size * 0.065;
    final radius = BorderRadius.circular(size * 0.025);
    // marketClockAccent != null is Midnight Sea's own signal (see the
    // dial face/ring above) — its window gets the theme's dark card tone
    // + the same gradient border every widget uses (themedBorder no-ops
    // for other themes that don't set borderGradient, but Luxury Gold
    // DOES — gate on marketClockAccent specifically so this box stays
    // exactly as it was for every theme except Midnight Sea).
    final isThemed = palette?.marketClockAccent != null;
    final box = Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.035,
        vertical: size * 0.012,
      ),
      decoration: BoxDecoration(
        color: isThemed
            ? palette!.card.withValues(alpha: 0.55)
            : dialDark.withValues(alpha: 0.55),
        borderRadius: radius,
        border: isThemed
            ? null
            : Border.all(
                color: dialBrassLight.withValues(alpha: 0.4),
                width: size * 0.004,
              ),
      ),
      child: Text(
        '$hh:$mm',
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
          // Glow disabled per palette.glowOpacity (Black & White, 2026-09-
          // 05): a black-tinted blur behind black digits on this theme's
          // now-light readout box read as a dirty smudge, not a glow —
          // same fix as the dial ring's glow.
          shadows: (palette?.glowOpacity ?? 1.0) > 0
              ? [
                  Shadow(
                    color: color.withValues(alpha: 0.8),
                    blurRadius: fontSize * 0.35,
                  ),
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: fontSize * 0.7,
                  ),
                ]
              : null,
        ),
      ),
    );
    return isThemed
        ? themedBorder(palette: palette!, borderRadius: radius, child: box)
        : box;
  }
}

class _RingPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  // Optional vertical gradient for the ring itself — top a couple of
  // shades lighter, bottom the base [color] — same top-lit-metal
  // convention as the widget border gradients (light top → base tone),
  // just applied to the ring's stroke shader instead of a straight edge.
  // Null keeps the flat single-color ring (every theme except Midnight
  // Sea). (An earlier attempt put the highlight on the FACE's radial
  // gradient instead — a bright center stop there read as a glowing disc
  // behind the hands, not a highlight; confirmed on-device 2026-09-02.)
  final Gradient? gradient;

  // Blurred halo behind the ring stroke — flattering as a colored glow on
  // a dark card (Luxury Gold's gold, Midnight Sea's teal), but a BLACK
  // blur on Black & White's now-light card reads as a dirty smudge, not a
  // glow (user: "грязь сверху вылезла", 2026-09-05). 0.0 fully suppresses
  // it; every other theme keeps the original 0.35 via the default.
  final double glowOpacity;

  _RingPainter({
    required this.strokeWidth,
    required this.color,
    this.gradient,
    this.glowOpacity = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    if (glowOpacity > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: glowOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 1.1);
      canvas.drawCircle(center, radius, glowPaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final g = gradient;
    if (g != null) {
      ringPaint.shader = g.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    } else {
      ringPaint.color = color;
    }
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradient != gradient ||
      oldDelegate.glowOpacity != glowOpacity;
}

Offset _polar(Offset center, double radius, double degrees) {
  final rad = (degrees - 90) * pi / 180;
  return Offset(center.dx + radius * cos(rad), center.dy + radius * sin(rad));
}

/// Dial gradient + ticks + numerals only — painted behind the digital
/// readout so [_ClockHandsPainter] can be layered on top of it.
class _ClockFaceBackgroundPainter extends CustomPainter {
  static const _tickMinor = Color(0xFF5C6E64);

  // Null keeps the original green instrument-panel gradient. Non-null
  // (Luxury Gold's windowGradient, or a theme's own marketClockFaceGradient)
  // replaces it entirely — this face is just another "inner window" of the
  // widget by the same rule every other nested panel follows.
  final Gradient? faceGradient;

  // Null keeps the original brass/gold numerals + ticks. Non-null (a
  // theme's marketClockAccent) recolors the hour numerals, hour ticks, and
  // minor ticks (at half alpha) to match — everything on the face that
  // isn't the gradient itself or the hands.
  final Color? numeralColor;

  _ClockFaceBackgroundPainter({this.faceGradient, this.numeralColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final gradient =
        faceGradient ??
        const RadialGradient(
          center: Alignment(0, -0.16),
          radius: 0.9,
          colors: [dialLight, dialMid, dialDark],
          stops: [0.0, 0.7, 1.0],
        );
    final dialPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: r),
      );
    canvas.drawCircle(center, r, dialPaint);

    for (int i = 0; i < 60; i++) {
      final isHour = i % 5 == 0;
      final deg = i * 6.0;
      final p1 = _polar(center, r * (isHour ? 0.86 : 0.90), deg);
      final p2 = _polar(center, r * 0.94, deg);
      final tickPaint = Paint()
        ..color = isHour
            ? (numeralColor ?? dialBrassLight)
            : (numeralColor?.withValues(alpha: 0.5) ?? _tickMinor)
        ..strokeWidth = isHour ? r * 0.03 : r * 0.012
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, tickPaint);
    }

    final numeralStyle = TextStyle(
      color: numeralColor ?? dialIvory,
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
  bool shouldRepaint(covariant _ClockFaceBackgroundPainter oldDelegate) =>
      oldDelegate.faceGradient != faceGradient ||
      oldDelegate.numeralColor != numeralColor;
}

/// Hour/minute hands + center pivot cap only — painted on top of the digital
/// readout so the hands visually pass over it, matching a real watch's
/// date-window layering.
class _ClockHandsPainter extends CustomPainter {
  final DateTime time;

  // Null keeps the original ivory hands / dark-green pivot cap / gold
  // pivot ring (every theme except Midnight Sea).
  final Color? handColor;
  final Color? pivotColor;
  final Color? pivotFillColor;

  _ClockHandsPainter(
    this.time, {
    this.handColor,
    this.pivotColor,
    this.pivotFillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final hands = handColor ?? dialIvory;
    final pivot = pivotColor ?? dialBrassLight;
    final pivotFill = pivotFillColor ?? dialDark;

    final hourDeg = (time.hour % 12) * 30.0 + time.minute * 0.5;
    final hourTip = _polar(center, r * 0.42, hourDeg);
    canvas.drawLine(
      center,
      hourTip,
      Paint()
        ..color = hands
        ..strokeWidth = r * 0.045
        ..strokeCap = StrokeCap.round,
    );

    final minDeg = time.minute * 6.0 + time.second * 0.1;
    final minTip = _polar(center, r * 0.62, minDeg);
    canvas.drawLine(
      center,
      minTip,
      Paint()
        ..color = hands
        ..strokeWidth = r * 0.028
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, r * 0.05, Paint()..color = pivotFill);
    canvas.drawCircle(
      center,
      r * 0.05,
      Paint()
        ..color = pivot
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.014,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockHandsPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.handColor != handColor ||
      oldDelegate.pivotColor != pivotColor ||
      oldDelegate.pivotFillColor != pivotFillColor;
}
