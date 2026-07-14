import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scanco/src/core/theme/app_theme.dart';
import 'package:scanco/src/shared/widgets/widget_container.dart';
import 'package:scanco/src/features/home/widgets/watchlist_widget.dart';
import 'package:scanco/src/features/home/widgets/upcoming_events_widget.dart';
import 'package:scanco/src/features/home/home_providers.dart';

// =============================================================================
// Mock Providers (FutureProvider overrides only — StateNotifierProvider is
// handled via SharedPreferences.setMockInitialValues)
// =============================================================================

/// 5 companies with price/change data — overrides watchlistQuotesProvider.
Future<List<Map<String, dynamic>>> _mockWatchlistQuotes() async {
  return [
    {
      'symbol': 'AAPL',
      'name': 'Apple Inc.',
      'price': 198.50,
      'change': 1.20,
    },
    {
      'symbol': 'GOOGL',
      'name': 'Alphabet Inc.',
      'price': 175.30,
      'change': -0.50,
    },
    {
      'symbol': 'MSFT',
      'name': 'Microsoft Corp.',
      'price': 425.10,
      'change': 0.80,
    },
    {
      'symbol': 'AMZN',
      'name': 'Amazon.com Inc.',
      'price': 185.20,
      'change': 2.10,
    },
    {
      'symbol': 'TSLA',
      'name': 'Tesla Inc.',
      'price': 248.90,
      'change': -1.50,
    },
  ];
}

/// 5 calendar events — overrides calendarEventsProvider.
Future<List<CalendarEvent>> _mockCalendarEvents() async {
  final now = DateTime.now();
  return [
    CalendarEvent(
      symbol: 'AAPL',
      type: 'earnings',
      date: now,
      title: 'Q1 Earnings',
      epsEstimate: '2.10',
    ),
    CalendarEvent(
      symbol: 'GOOGL',
      type: 'earnings',
      date: now,
      title: 'Q1 Earnings',
      epsEstimate: '1.85',
    ),
    CalendarEvent(
      symbol: 'MSFT',
      type: 'dividend',
      date: now,
      title: 'Dividend',
      amount: 0.75,
    ),
    CalendarEvent(
      symbol: 'AMZN',
      type: 'earnings',
      date: now,
      title: 'Q1 Earnings',
      epsEstimate: '1.20',
    ),
    CalendarEvent(
      symbol: 'TSLA',
      type: 'dividend',
      date: now,
      title: 'Dividend',
      amount: 0.50,
    ),
  ];
}

// =============================================================================
// Test Helpers
// =============================================================================

/// Wraps a widget in [MaterialApp] with the app's dark theme + [Scaffold]
/// (Scaffold provides the Material ancestor required by InkWell inside
/// WidgetContainer).
Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
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

        // With 2 children → exactly 1 Divider is rendered between them
        expect(find.byType(Divider), findsOneWidget);

        final divider = tester.widget<Divider>(find.byType(Divider));
        expect(divider.indent, equals(16.0));
        expect(divider.endIndent, equals(16.0));
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchlistQuotesProvider
                .overrideWith((ref) => _mockWatchlistQuotes()),
          ],
          child: _wrapWithTheme(const WatchlistWidget()),
        ),
      );

      // Pump multiple frames to let WatchlistNotifier._load() complete
      // and FutureProvider resolve, WITHOUT hanging on CircularProgressIndicator
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Each _WatchlistTile renders exactly one CircleAvatar.
      // With 5 companies and .take(2), only 2 should be present.
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. UpcomingEventsWidget — Compact mode (only 2 of 5 events)
  // ---------------------------------------------------------------------------
  group('UpcomingEventsWidget — Compact mode', () {
    testWidgets('renders only 2 event tiles out of 5 via .take(2)',
        (WidgetTester tester) async {
      // Seed watchlist symbols so real provider returns non-empty list
      await _seedWatchlistSymbols(['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA']);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarEventsProvider
                .overrideWith((ref) => _mockCalendarEvents()),
          ],
          child: _wrapWithTheme(const UpcomingEventsWidget()),
        ),
      );

      // Pump frames to let FutureProvider resolve
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // First 2 event symbols should be on screen
      expect(find.text('AAPL'), findsOneWidget);
      expect(find.text('GOOGL'), findsOneWidget);

      // Remaining 3 must NOT be rendered
      expect(find.text('MSFT'), findsNothing);
      expect(find.text('AMZN'), findsNothing);
      expect(find.text('TSLA'), findsNothing);
    });
  });
}
