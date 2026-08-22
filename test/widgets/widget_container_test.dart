import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:scanco/src/core/theme/app_theme.dart';
import 'package:scanco/src/core/supabase/supabase_providers.dart';
import 'package:scanco/src/l10n/gen/app_localizations.dart';
import 'package:scanco/src/shared/services/user_data_service.dart';
import 'package:scanco/src/shared/widgets/widget_container.dart';
import 'package:scanco/src/features/home/widgets/watchlist_widget.dart';

// =============================================================================
// Test Helpers
// =============================================================================

/// Wraps a widget in [MaterialApp] with the app's dark theme + [Scaffold]
/// (Scaffold provides the Material ancestor required by InkWell inside
/// WidgetContainer). Delegates/supportedLocales mirror main.dart's
/// MaterialApp.router — without them AppLocalizations.of(context) returns
/// null and any widget calling the `!` on it (e.g. WatchlistWidget) throws.
Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

/// Pre-populates SharedPreferences so WatchlistNotifier._load()
/// finds symbols on init instead of an empty list.
Future<void> _seedWatchlistSymbols(List<String> symbols) async {
  SharedPreferences.setMockInitialValues({
    'watchlist_symbols': symbols,
  });
  await SharedPreferences.getInstance();
}

/// Stands in for a real SupabaseClient in tests — constructing the real
/// class starts background auth-refresh timers that outlive the widget
/// tree and fail the test ("A Timer is still pending..."), and the real
/// singleton (Supabase.instance) isn't initialized in a widget test at
/// all. Never actually called: WatchlistNotifier only touches its
/// UserDataService on add()/remove(), neither of which this test
/// exercises — every member here only needs to type-check, not run.
class _FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  // ---------------------------------------------------------------------------
  // 1. WidgetContainer — Dividers indent/endIndent
  // ---------------------------------------------------------------------------
  group('WidgetContainer — Dividers', () {
    testWidgets(
      'renders Divider with indent:16 and endIndent:16 when children > 1',
      (WidgetTester tester) async {
        await tester.pumpWidget(_wrapWithTheme(
          WidgetContainer(
            title: 'TEST',
            onTap: () {},
            children: [
              const Text('Item A'),
              const SizedBox.shrink(),
            ],
          ),
        ));

        // WidgetContainer always renders a title/content separator, plus
        // one between-item Divider per gap — 2 children means 1 gap, so
        // 2 Dividers total (title separator + the one between the items).
        expect(find.byType(Divider), findsNWidgets(2));

        final dividers = tester.widgetList<Divider>(find.byType(Divider));
        for (final divider in dividers) {
          expect(divider.indent, equals(16.0));
          expect(divider.endIndent, equals(16.0));
        }
      },
    );
  });

  // ---------------------------------------------------------------------------
  // 2. WidgetContainer — Footer show/hide logic
  // ---------------------------------------------------------------------------
  group('WidgetContainer — Footer (More button)', () {
    testWidgets('hides "More" button when showFooter=false (≤2 items)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        WidgetContainer(
          title: 'TEST',
          onTap: () {},
          showFooter: false,
          children: [
            const Text('Item 1'),
            const Text('Item 2'),
          ],
        ),
      ));

      expect(find.text('More'), findsNothing);
    });

    testWidgets('shows "More" button when showFooter=true (>2 items)',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        WidgetContainer(
          title: 'TEST',
          onTap: () {},
          showFooter: true,
          children: [
            const Text('Item 1'),
            const Text('Item 2'),
            const Text('Item 3'),
          ],
        ),
      ));

      expect(find.text('More'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. WidgetContainer — Empty State
  // ---------------------------------------------------------------------------
  group('WidgetContainer — Empty State', () {
    testWidgets('shows emptyText when children list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        WidgetContainer(
          title: 'TEST',
          onTap: () {},
          emptyText: 'Здесь пока ничего нет',
          children: const [],
        ),
      ));

      expect(find.text('Здесь пока ничего нет'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. WatchlistWidget — Compact mode (only 2 of 5 companies)
  // ---------------------------------------------------------------------------
  group('WatchlistWidget — Compact mode', () {
    testWidgets('renders only 2 company tiles out of 5 via .take(2)',
        (WidgetTester tester) async {
      // Seed watchlist symbols BEFORE pumping the widget
      await _seedWatchlistSymbols(['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA']);

      // currentUserProvider is overridden (logged-out/null) so
      // watchlistSymbolsProvider never watches real auth state, and
      // userDataServiceProvider is overridden with _FakeSupabaseClient so
      // merely constructing it doesn't require Supabase.initialize() to
      // have run and doesn't start any real background timers — this
      // test never actually calls through it, since watchlist symbols
      // come from the seeded SharedPreferences data above, not a
      // Supabase load. No quote-related override needed anymore — the
      // widget reads symbols straight from watchlistSymbolsProvider (no
      // live fetch), so logo/name/sector all resolve from local
      // cache-or-fallback only.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(null),
            userDataServiceProvider.overrideWithValue(
              UserDataService(_FakeSupabaseClient()),
            ),
          ],
          child: _wrapWithTheme(const WatchlistWidget()),
        ),
      );

      // Pump a couple frames to let WatchlistNotifier._load() and the
      // per-tile cachedLogoEntryProvider reads settle.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Each _WatchlistTile renders exactly one CircleAvatar (via
      // CompanyLogo's letter-fallback, since no logo is cached in tests).
      // With 5 companies and .take(2), only 2 should be present.
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });

}
