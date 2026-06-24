import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scanco/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ScanCoApp()),
    );

    // Advance past the SplashScreen's 2.5s Future.delayed timer
    // so the test framework doesn't complain about a pending timer.
    await tester.pump(const Duration(milliseconds: 2600));
    // Process microtasks and any navigation triggered by the timer
    await tester.pump();

    // The app should always have a MaterialApp regardless of route
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
