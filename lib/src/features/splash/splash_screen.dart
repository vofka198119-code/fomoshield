import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_client.dart';
import '../disclaimer/disclaimer_providers.dart';
import '../auth/auth_providers.dart';

// Brand shield-logo palette — matches the reference splash mock, kept local
// to this file the way every other brand-gradient consumer in the app does
// (see docs/DESIGN_TOKENS.md §6, "no shared brandGradient constant").
const _shieldDark = Color(0xFF16281F); // wordmark + shield outline
const _goldDeep = Color(0xFFC9A227); // bar chart, deep gold
const _goldLight = Color(0xFFE8C468); // trend line, light gold (dialBrassLight)

/// Minimum time the splash stays up so the app behind it has a real chance
/// to finish warming up — see feedback: splash must gate on actual
/// readiness, not just a flat timer that hands off to a laggy Home.
const _minSplashDuration = Duration(milliseconds: 7000);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;
  late final AnimationController _pulseController;

  late final Future<String> _routeFuture;
  String? _resolvedRoute;
  bool _routeReady = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: _minSplashDuration,
    )..addListener(_maybeNavigate);
    _progressController.forward();

    _routeFuture = _resolveTargetRoute();
    _routeFuture.then((route) {
      _resolvedRoute = route;
      _routeReady = true;
      if (mounted) setState(() {});
      _maybeNavigate();
    });
  }

  /// Same auth/disclaimer resolution the old flat-timer splash did, just
  /// returning a destination instead of navigating on the spot — lets it
  /// run concurrently with the minimum-display timer below.
  Future<String> _resolveTargetRoute() async {
    try {
      final isLoggedIn = await ref.read(isLoggedInProvider.future);
      if (!isLoggedIn) {
        await clearAllSessionData();
        return '/auth';
      }

      final savedCreds = await ref.read(savedCredentialsProvider.future);
      if (savedCreds == null) {
        await clearAllSessionData();
        return '/auth';
      }

      try {
        await SupabaseConfig.client.auth.signInWithPassword(
          email: savedCreds.email,
          password: savedCreds.password,
        );
      } catch (_) {
        await clearAllSessionData();
        return '/auth';
      }

      final disclaimerAccepted =
          await ref.read(isDisclaimerAcceptedProvider.future);
      return disclaimerAccepted ? '/home' : '/disclaimer';
    } catch (_) {
      return '/auth';
    }
  }

  void _maybeNavigate() {
    if (_navigated) return;
    if (!_progressController.isCompleted || !_routeReady) return;
    _navigated = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) context.go(_resolvedRoute!);
    });
  }

  /// Visual progress: rides the 7s timer, but never shows 100% until the
  /// real init work is actually done — avoids a "full bar, still frozen"
  /// moment if auth/network happens to run long.
  double get _displayProgress {
    final t = _progressController.value;
    if (_routeReady) return t;
    return math.min(t, 0.99);
  }

  Animation<double> _stagger(double start, double end) => CurvedAnimation(
    parent: _entranceController,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shieldAnim = _stagger(0.0, 0.55);
    final wordmarkAnim = _stagger(0.20, 0.70);
    final taglineAnim = _stagger(0.35, 0.85);
    final ringAnim = _stagger(0.55, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: shieldAnim,
              child: ScaleTransition(
                scale: Tween(
                  begin: 0.85,
                  end: 1.0,
                ).animate(CurvedAnimation(parent: shieldAnim, curve: Curves.easeOutBack)),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => CustomPaint(
                    size: const Size(150, 158),
                    painter: _ShieldLogoPainter(dotPulse: _pulseController.value),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            FadeTransition(
              opacity: wordmarkAnim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(wordmarkAnim),
                child: Column(
                  children: [
                    Text(
                      'FOMO',
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: _shieldDark,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _rule(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'S H I E L D',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                              color: _goldDeep,
                            ),
                          ),
                        ),
                        _rule(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            FadeTransition(
              opacity: taglineAnim,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: ThemeV2.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Invest with clarity.\nStay protected from '),
                    TextSpan(
                      text: 'FOMO',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _shieldDark,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 44),

            FadeTransition(
              opacity: ringAnim,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => _LoadingRing(progress: _displayProgress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rule() => Container(
    width: 28,
    height: 1,
    color: _goldDeep.withValues(alpha: 0.5),
  );
}

class _LoadingRing extends StatelessWidget {
  final double progress;
  const _LoadingRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: CustomPaint(
            painter: _RingPainter(progress: progress),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _shieldDark,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Loading...',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ThemeV2.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 5;

    final track = Paint()
      ..color = _goldLight.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = ThemeV2.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Hand-built shield + bar-chart + trend-line mark — there is no source
/// vector asset for the reference design, so this is a from-scratch
/// approximation tuned by eye against the reference screenshot.
class _ShieldLogoPainter extends CustomPainter {
  final double dotPulse; // 0..1, drives the trend-dot's gentle pulse
  _ShieldLogoPainter({required this.dotPulse});

  Path _shieldPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.015)
      ..cubicTo(w * 0.30, h * 0.00, w * 0.06, h * 0.09, w * 0.06, h * 0.27)
      ..lineTo(w * 0.06, h * 0.53)
      ..cubicTo(w * 0.06, h * 0.77, w * 0.21, h * 0.90, w * 0.50, h * 0.995)
      ..cubicTo(w * 0.79, h * 0.90, w * 0.94, h * 0.77, w * 0.94, h * 0.53)
      ..lineTo(w * 0.94, h * 0.27)
      ..cubicTo(w * 0.94, h * 0.09, w * 0.70, h * 0.00, w * 0.50, h * 0.015)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shield = _shieldPath(size);

    // Fill — a touch whiter than the page so the mark reads as a distinct
    // surface against the app's cream background gradient.
    canvas.drawPath(shield, Paint()..color = const Color(0xFFFFFEFA));

    // Bars + trend line, clipped to the shield interior.
    canvas.save();
    canvas.clipPath(shield);
    _paintBars(canvas, size);
    _paintTrendLine(canvas, size);
    canvas.restore();

    // Thin inner gold border, then the primary outer stroke.
    canvas.drawPath(
      shield,
      Paint()
        ..color = _goldLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = _shieldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );
  }

  void _paintBars(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Heights as a fraction of the shield's body, ascending then a small
    // dip on the last (gold) bar — matches the reference skyline.
    const heights = [0.16, 0.24, 0.34, 0.46, 0.58, 0.44];
    final colors = [
      ThemeV2.primary.withValues(alpha: 0.85),
      ThemeV2.primary.withValues(alpha: 0.90),
      ThemeV2.primary,
      _goldDeep.withValues(alpha: 0.85),
      _goldDeep,
      _goldDeep.withValues(alpha: 0.75),
    ];

    const barCount = 6;
    const gap = 0.018;
    final totalGap = gap * (barCount - 1);
    final barW = (0.76 - totalGap) / barCount * w;
    var x = w * 0.12;
    const baseline = 0.80;

    for (var i = 0; i < barCount; i++) {
      final barH = heights[i] * h;
      final rect = Rect.fromLTWH(x, h * baseline - barH, barW, barH);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = colors[i],
      );
      x += barW + gap * w;
    }
  }

  void _paintTrendLine(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.14, h * 0.72)
      ..lineTo(w * 0.34, h * 0.60)
      ..lineTo(w * 0.46, h * 0.68)
      ..lineTo(w * 0.62, h * 0.42)
      ..lineTo(w * 0.72, h * 0.50)
      ..lineTo(w * 0.88, h * 0.24);

    canvas.drawPath(
      path,
      Paint()
        ..color = _goldLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotRadius = 4.0 + dotPulse * 1.6;
    canvas.drawCircle(
      Offset(w * 0.88, h * 0.24),
      dotRadius,
      Paint()..color = _goldLight,
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldLogoPainter oldDelegate) =>
      oldDelegate.dotPulse != dotPulse;
}
