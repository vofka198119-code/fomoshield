import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/supabase/supabase_client.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_providers.dart';
import '../home/home_providers.dart'
    show watchlistSymbolsProvider, marketIndicesProvider;
import '../home/widget_order_provider.dart' show homeWidgetsProvider;
import '../portfolio/portfolio_providers.dart' show portfoliosProvider;
import '../update/update_dialog.dart';

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

  late final Future<({String route, Object? extra})> _routeFuture;
  ({String route, Object? extra})? _resolved;
  bool _routeReady = false;
  bool _navigated = false;
  bool _updateGateShown = false;
  bool _updateGateOpen = false;

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
    _routeFuture.then((resolved) {
      _resolved = resolved;
      _routeReady = true;
      if (mounted) setState(() {});
      _maybeNavigate();
    });

    // Fire-and-forget — doesn't gate route resolution, just needs to be
    // done before the user could possibly reach the "Continue with
    // Google" button (at least _minSplashDuration away). Moved here from
    // main()'s blocking pre-runApp sequence 2026-08-14 — it was adding
    // real time to the black screen before Flutter's first frame, for a
    // capability nothing needs until the user taps that specific button.
    GoogleSignIn.instance.initialize(
      clientId: SupabaseConfig.googleIosClientId,
      serverClientId: SupabaseConfig.googleWebClientId,
    );

    // Auto-update: run the check while the splash is still loading and PAUSE
    // the hand-off until the user deals with the prompt — the update dialog
    // appears BEFORE the main UI, using the loading time instead of nagging
    // the user after they've already reached the home screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 300), _showUpdateGate);
    });
  }

  /// Auth/disclaimer resolution — returns a destination instead of
  /// navigating on the spot, so it can run concurrently with the minimum-
  /// display timer below.
  ///
  /// Supabase's SDK already restored any live session during
  /// `Supabase.initialize()` in main(), before this ever runs — for every
  /// sign-in method (email/password AND Google) alike. So the only
  /// question here is whether to honor that restored session (Remember Me
  /// was checked) or sign back out (it wasn't). No stored password, no
  /// re-login network call.
  Future<({String route, Object? extra})> _resolveTargetRoute() async {
    try {
      final rememberMe = await ref.read(isLoggedInProvider.future);
      if (!rememberMe) {
        await clearAllSessionData();
        return (route: '/auth', extra: null);
      }

      final hasSession = await ref.read(hasSupabaseSessionProvider.future);
      if (!hasSession) {
        return (route: '/auth', extra: null);
      }

      final resolved = await resolvePostAuthRoute(ref);
      if (resolved.route == '/home') _prefetchHomeData();
      return resolved;
    } catch (_) {
      return (route: '/auth', extra: null);
    }
  }

  /// Touches Home's main data providers as early as possible once we know
  /// we're heading there, so their fetches spend the REST of the splash's
  /// display time in flight instead of only starting once Home's own
  /// widgets first build — Home showed empty for a couple seconds after
  /// hand-off before this (fixed 2026-08-14). Fire-and-forget: Riverpod
  /// providers start computing as soon as they're read, and stay cached
  /// app-wide, so Home's own `ref.watch(...)` calls a few seconds later
  /// pick up the same in-flight (or by then finished) result instead of
  /// starting fresh. Doesn't cover every nested per-item fetch (e.g. a
  /// specific portfolio's live performance) — just the top-level providers
  /// each Home widget watches first.
  void _prefetchHomeData() {
    // homeWidgetsProvider decides WHICH widgets to show at all — it starts
    // at an empty list and loads the real order/visibility from
    // SharedPreferences asynchronously (see HomeWidgetsNotifier._load() in
    // widget_order_provider.dart). Until that resolves, Home's body is
    // completely blank (not loading placeholders — an empty widget list),
    // which is the actual cause of the multi-second blank Home the user
    // saw, separate from the per-widget data latency below.
    ref.read(homeWidgetsProvider);
    ref.read(portfoliosProvider);
    ref.read(watchlistSymbolsProvider);
    ref.read(marketIndicesProvider);
  }

  /// Shows the modal auto-update dialog over the splash. The hand-off waits
  /// for it to be dismissed (see [_maybeNavigate]), so an available update is
  /// surfaced before the main UI — not after the user is already there.
  void _showUpdateGate() {
    if (_updateGateShown || !mounted) return;
    _updateGateShown = true;
    _updateGateOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UpdateDialog(silentWhenUpToDate: true),
    ).then((_) {
      _updateGateOpen = false;
      if (mounted) _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (_navigated) return;
    if (!_progressController.isCompleted || !_routeReady) return;
    if (_updateGateOpen) return; // wait for the update dialog to be dismissed
    _navigated = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) context.go(_resolved!.route, extra: _resolved!.extra);
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

            // No entrance animation here (2026-08-14) — the native
            // pre-Flutter launch screen (android/.../launch_background.xml)
            // already shows this same shield mark before this widget ever
            // builds. Fading/scaling it in again on Flutter's first frame
            // made it look like the shield flickered or reloaded; showing
            // it already-in-place instead reads as one continuous image
            // straight through from tapping the app icon.
            Transform.translate(
              // The shield art sits ~1.6% right-of-center within its own
              // PNG canvas (measured, not touching the source file) —
              // nudge the rendered widget left to compensate.
              offset: const Offset(-4, 0),
              child: Image.asset(
                'assets/images/fomoshield_logo.png',
                width: 250,
                height: 250,
              ),
            ),

            const SizedBox(height: 45),

            // Also no entrance animation (2026-08-14) — same reasoning as
            // the shield above: the native launch screen shows this same
            // wordmark already in place, so it needs to stay static on
            // Flutter's first frame too, not fade/slide in a second time.
            Column(
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

            const SizedBox(height: 18),

            FadeTransition(
              opacity: ringAnim,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) =>
                    _LoadingRing(progress: _displayProgress),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rule() =>
      Container(width: 28, height: 1, color: _goldDeep.withValues(alpha: 0.5));
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
          AppLocalizations.of(context)!.commonLoading,
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
