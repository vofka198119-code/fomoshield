import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../supabase/supabase_client.dart';

import '../../features/auth/account_restore_screen.dart';
import '../../shared/services/finnhub_service.dart' show AccountDeletionStatus;
import '../../features/disclaimer/disclaimer_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/screens/watchlist_full_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/portfolio/screens/portfolio_order_entry_screen.dart';
import '../../features/portfolio/screens/set_goal_screen.dart';
import '../../features/market_clock/market_clock_screen.dart';
import '../../features/market_clock/market_period_detail_screen.dart';
import '../../features/market_clock/market_clock_risk_detail_screen.dart';
import '../../features/market_clock/market_phases_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/company_detail/company_detail_screen.dart';
import '../../features/company_detail/widgets/metric_info_screen.dart';
import '../../features/company_detail/widgets/metric_info_data.dart';
import '../../features/stress_test/stress_test_setup_screen.dart';
import '../../features/stress_test/stress_test_screen.dart';
import '../../features/stress_test/verdict_screen.dart';
import '../../features/stress_test/verdict_marker_detail_screen.dart';
import '../../features/stress_test/stress_test_hub_screen.dart';
import '../../features/stress_test/stress_test_portfolio_balance_screen.dart';
import '../../features/stress_test/stress_test_psychology_meter_screen.dart';
import '../../features/stress_test/stress_test_trade_history_screen.dart';
import '../../features/stress_test/stress_test_trade_detail_screen.dart';
import '../../features/stress_test/verdict_trade_breakdown_detail_screen.dart';
import '../../features/stress_test/stress_test_models.dart'
    show StressTestTrade;
import '../../features/portfolio/screens/portfolio_trade_history_screen.dart';
import '../../features/portfolio/screens/portfolio_trade_detail_screen.dart';
import '../../features/portfolio/portfolio_providers.dart' show Transaction;
import '../../features/assets/screens/assets_screen.dart';
import '../../features/assets/screens/stock_detail_screen.dart';
import '../../features/assets/screens/why_today_screen.dart';
import '../../features/assets/screens/order_entry_screen.dart';
import '../theme/theme_v2.dart';
import 'navigation_history_provider.dart';

/// Bridges a Stream (Supabase's auth-state stream) into a [Listenable] so
/// GoRouter re-evaluates its `redirect` callback whenever auth state
/// changes — not just at initial navigation. Standard go_router pattern.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Routes that manage their own auth/session logic — never redirected away
// from by the session guard below (Splash resolves the real destination
// itself; Auth/forgot-password/disclaimer are the destinations).
const _authExemptPaths = {'/', '/auth', '/forgot-password', '/disclaimer'};

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(
      SupabaseConfig.client.auth.onAuthStateChange,
    ),
    // Session guard only — if a live Supabase session gets revoked/expires
    // while the app is already open (not just at cold start, which Splash
    // already handles), send the user back to /auth instead of leaving
    // them stranded on a screen that assumes they're signed in.
    redirect: (context, state) {
      if (_authExemptPaths.contains(state.matchedLocation)) return null;
      final hasSession = SupabaseConfig.client.auth.currentSession != null;
      return hasSession ? null : '/auth';
    },
    routes: [
      // Auth flow (full screen, no shell)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Forgot password (full screen, no shell)
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/disclaimer',
        name: 'disclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),

      // Account Restore — full-block gate for a pending-deletion account,
      // see resolvePostAuthRoute() in auth_providers.dart.
      GoRoute(
        path: '/account-restore',
        name: 'accountRestore',
        builder: (context, state) {
          final status = state.extra as AccountDeletionStatus?;
          return AccountRestoreScreen(
            daysRemaining: status?.daysRemaining ?? 0,
            deleteAt: status?.deleteAt,
          );
        },
      ),

      // Company detail (full screen, no shell)
      GoRoute(
        path: '/company/:symbol',
        name: 'companyDetail',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return CompanyDetailScreen(
            symbol: symbol.toUpperCase(),
            contextPortfolioId: extra?['portfolioId'] as String?,
          );
        },
      ),

      // Metric info — title + explanation sections, reached from the "?"
      // next to a KEY METRICS row. No transition: both this screen and its
      // callers use a transparent Scaffold over the app-wide gradient
      // (see main.dart), so an animated push/pop briefly shows both
      // routes' text overlapping — a plain cut avoids that ghosting.
      GoRoute(
        path: '/metric-info/:id',
        name: 'metricInfo',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final content = metricInfoRegistry[id];
          return NoTransitionPage(
            child: content == null
                ? const SizedBox()
                : MetricInfoScreen(content: content),
          );
        },
      ),

      // Watchlist full screen
      GoRoute(
        path: '/watchlist',
        name: 'watchlist',
        builder: (context, state) => const WatchlistFullScreen(),
      ),

      // Notifications — bell icon on Home
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Search — standalone full screen (outside ShellRoute to avoid
      // navigator key conflicts when called from watchlist, company detail, etc.)
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Market Clock — standalone (outside shell)
      GoRoute(
        path: '/market-clock',
        name: 'marketClock',
        builder: (context, state) => const MarketClockScreen(),
      ),
      GoRoute(
        path: '/market-clock/period/:id',
        name: 'marketClockPeriod',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MarketPeriodDetailScreen(windowId: id);
        },
      ),
      GoRoute(
        path: '/market-clock/phases',
        name: 'marketClockPhases',
        builder: (context, state) => const MarketPhasesScreen(),
      ),
      GoRoute(
        path: '/market-clock/risk-status/:id',
        name: 'marketClockRiskStatus',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RiskStatusDetailScreen(windowId: id);
        },
      ),

      // ── Stress Test (full screen, no bottom nav) ──────────────────
      GoRoute(
        path: '/stress-test/:id',
        name: 'stressTest',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/setup',
        name: 'stressTestSetup',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestSetupScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/verdict',
        name: 'stressTestVerdict',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return VerdictScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/verdict/marker/:markerId',
        name: 'stressTestVerdictMarker',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final markerId = state.pathParameters['markerId'] ?? '';
          return VerdictMarkerDetailScreen(sessionId: id, markerId: markerId);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/portfolio-balance',
        name: 'stressTestPortfolioBalance',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestPortfolioBalanceScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/psychology-meter',
        name: 'stressTestPsychologyMeter',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestPsychologyMeterScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/trade-history',
        name: 'stressTestTradeHistory',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestTradeHistoryScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/trade-detail',
        name: 'stressTestTradeDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StressTestTradeDetailScreen(
            sessionId: id,
            trade: state.extra as StressTestTrade?,
          );
        },
      ),
      GoRoute(
        path: '/stress-test/:id/verdict-trade-breakdown',
        name: 'verdictTradeBreakdown',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return VerdictTradeBreakdownDetailScreen(sessionId: id);
        },
      ),

      // ── Assets (broker-style screens, inside stress test) ──
      GoRoute(
        path: '/stress-test/:id/assets',
        name: 'stressTestAssets',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AssetsScreen(sessionId: id);
        },
      ),
      GoRoute(
        path: '/stress-test/:id/stock/:symbol',
        name: 'stressTestStockDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final symbol = state.pathParameters['symbol'] ?? '';
          return StockDetailScreen(sessionId: id, symbol: symbol.toUpperCase());
        },
      ),
      GoRoute(
        path: '/stress-test/:id/stock/:symbol/why',
        name: 'stressTestWhyToday',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final symbol = state.pathParameters['symbol'] ?? '';
          return WhyTodayScreen(sessionId: id, symbol: symbol.toUpperCase());
        },
      ),
      GoRoute(
        path: '/stress-test/:id/stock/:symbol/order',
        name: 'stressTestOrderEntry',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final symbol = state.pathParameters['symbol'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OrderEntryScreen(
            sessionId: id,
            symbol: symbol.toUpperCase(),
            orderType: (extra['type'] as String?) ?? 'buy',
            price: (extra['price'] as num?)?.toDouble() ?? 0,
            companyName: extra['companyName'] as String?,
            logo: extra['logo'] as String?,
          );
        },
      ),

      GoRoute(
        path: '/portfolio/:id/stock/:symbol/order',
        name: 'portfolioOrderEntry',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final symbol = state.pathParameters['symbol'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PortfolioOrderEntryScreen(
            portfolioId: id,
            symbol: symbol.toUpperCase(),
            orderType: (extra['type'] as String?) ?? 'buy',
            initialPrice: (extra['price'] as num?)?.toDouble(),
            companyName: extra['companyName'] as String?,
            logo: extra['logo'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/portfolio/:id/goal',
        name: 'portfolioSetGoal',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SetGoalScreen(portfolioId: id);
        },
      ),
      GoRoute(
        path: '/portfolio/:id/trade-history',
        name: 'portfolioTradeHistory',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PortfolioTradeHistoryScreen(portfolioId: id);
        },
      ),
      GoRoute(
        path: '/portfolio/:id/trade-detail',
        name: 'portfolioTradeDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PortfolioTradeDetailScreen(
            portfolioId: id,
            transaction: state.extra as Transaction?,
          );
        },
      ),

      // Main app (with bottom navigation shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/portfolio',
            name: 'portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/stress-test-hub',
            name: 'stressTestHub',
            builder: (context, state) => const StressTestHubScreen(),
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _currentIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri == '/home') return 0;
    if (uri == '/portfolio') return 2;
    if (uri == '/stress-test-hub') return 3;
    if (uri == '/profile') return 4;
    return 0;
  }

  void _onStressTestTap(BuildContext context, WidgetRef ref) {
    context.push('/stress-test-hub');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeV2.surface.withValues(alpha: 0.75),
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex(context),
                  onTap: (index) {
                    ref.read(previousTabRouteProvider.notifier).state =
                        GoRouterState.of(context).uri.toString();
                    switch (index) {
                      case 0:
                        context.go('/home');
                      case 1:
                        context.push('/search');
                      case 2:
                        context.go('/portfolio');
                      case 3:
                        _onStressTestTap(context, ref);
                      case 4:
                        context.go('/profile');
                    }
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shield_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search_rounded),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_rounded),
                      label: 'Portfolio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.psychology_rounded),
                      label: 'Stress Test',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
