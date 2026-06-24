import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';

import '../../features/disclaimer/disclaimer_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/screens/watchlist_full_screen.dart';
import '../../features/home/screens/events_full_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/news/news_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/company_detail/company_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
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

      GoRoute(
        path: '/disclaimer',
        name: 'disclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),

      // Company detail (full screen, no shell)
      GoRoute(
        path: '/company/:symbol',
        name: 'companyDetail',
        builder: (context, state) {
          final symbol = state.pathParameters['symbol'] ?? '';
          return CompanyDetailScreen(symbol: symbol.toUpperCase());
        },
      ),

      // Watchlist full screen
      GoRoute(
        path: '/watchlist',
        name: 'watchlist',
        builder: (context, state) => const WatchlistFullScreen(),
      ),

      // Search — standalone full screen (outside ShellRoute to avoid
      // navigator key conflicts when called from watchlist, company detail, etc.)
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Events full screen
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsFullScreen(),
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
            path: '/news',
            name: 'news',
            builder: (context, state) => const NewsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _currentIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri == '/home') return 0;
    if (uri == '/search') return 1;
    if (uri == '/portfolio') return 2;
    if (uri == '/news') return 3;
    if (uri == '/profile') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.push('/search');
            case 2:
              context.go('/portfolio');
            case 3:
              context.go('/news');
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
            icon: Icon(Icons.newspaper_rounded),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
