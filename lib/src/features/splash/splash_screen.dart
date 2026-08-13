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
const _shieldDark = Color(0xFF1C3325); // wordmark + shield outline
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shieldAnim = _stagger(0.0, 0.55);
    final wordmarkAnim = _stagger(0.20, 0.70);
    final ringAnim = _stagger(0.55, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Extra headroom above the shield — pushes the whole block down
            // so it doesn't sit crammed into the upper half of the screen.
            const SizedBox(height: 205),

            FadeTransition(
              opacity: shieldAnim,
              child: ScaleTransition(
                scale: Tween(
                  begin: 0.85,
                  end: 1.0,
                ).animate(CurvedAnimation(parent: shieldAnim, curve: Curves.easeOutBack)),
                child: Transform.translate(
                  // The shield art sits ~1.6% right-of-center within its
                  // own PNG canvas (measured, not touching the source
                  // file) — nudge the rendered widget left to compensate.
                  offset: const Offset(-4, 0),
                  child: Image.asset(
                    'assets/images/fomoshield_logo.png',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 45),

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
                        fontSize: 46,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 5,
                        color: _shieldDark,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(2, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _rule(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'S H I E L D',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3.5,
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

            const SizedBox(height: 18),

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
          width: 59,
          height: 59,
          child: CustomPaint(
            painter: _RingPainter(progress: progress),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
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
    final radius = size.width / 2 - 4;

    final track = Paint()
      ..color = _goldLight.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = ThemeV2.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
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
