// ignore_for_file: avoid_print

// ---------------------------------------------------------------------------
// Stress Test — Session Isolation Tests (Step 4)
// ---------------------------------------------------------------------------
// Verifies that 2-3 parallel sessions of different durations maintain
// fully independent state: epoch histories, prices, casino state,
// devMarketPhase, and Guardian-computed values.
//
// Key invariants:
//   - Each session has its own epochHistory (no cross-contamination)
//   - Prices from one session don't leak into another
//   - devMarketPhase / devFearIndex are per-session
//   - Casino state (declineStreak, cooldown, weights) is isolated
//   - Switching between sessions preserves correct per-session values
// ---------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanco/src/features/stress_test/stress_test_models.dart';
import 'package:scanco/src/features/stress_test/stress_test_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  StressTestNotifier.globalMarketOpenOverride = (_) => true;

  /// Create a fresh notifier for each test.
  Future<StressTestNotifier> createNotifier() async {
    SharedPreferences.setMockInitialValues({});
    final n = StressTestNotifier(userId: 'test_isolation_user');
    return n;
  }

  group('Isolation: Multi-Session Independence', () {
    test('ISO-01: Two sessions have independent epoch histories', () async {
      final notifier = await createNotifier();

      // Create 2 sessions of different durations
      final id1 = notifier.createSession(TestDuration.week1, 10000);
      final id2 = notifier.createSession(TestDuration.month1, 15000);

      await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(id2, 'KO', 15000, 60.0);

      notifier.startTest(id1);
      notifier.startTest(id2);

      // Advance both
      for (int i = 0; i < 5; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final s1 = notifier.getSession(id1)!;
      final s2 = notifier.getSession(id2)!;

      // Each has its own epochHistory
      expect(s1.epochHistory.isNotEmpty, isTrue);
      expect(s2.epochHistory.isNotEmpty, isTrue);

      // Histories are NOT identical references
      expect(identical(s1.epochHistory, s2.epochHistory), isFalse);

      // Each session has exactly 1 active epoch
      final active1 = s1.epochHistory.where((e) => e.isActive).length;
      final active2 = s2.epochHistory.where((e) => e.isActive).length;
      expect(
        active1,
        equals(1),
        reason: 'Session 1 should have 1 active epoch',
      );
      expect(
        active2,
        equals(1),
        reason: 'Session 2 should have 1 active epoch',
      );

      // Different sessions may have different scenarios (probabilistic)
      // But epochs should be independently generated
      print(
        '\n[ISO-01] Session 1: ${s1.epochHistory.length} epochs, '
        'active: ${s1.epochHistory.last.scenario.name}',
      );
      print(
        '[ISO-01] Session 2: ${s2.epochHistory.length} epochs, '
        'active: ${s2.epochHistory.last.scenario.name}',
      );
    });

    test('ISO-02: Prices are isolated between sessions', () async {
      final notifier = await createNotifier();

      // Session 1: AAPL only
      final id1 = notifier.createSession(TestDuration.week1, 10000);
      await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      notifier.startTest(id1);

      // Session 2: KO only
      final id2 = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id2, 'KO', 10000, 60.0);
      notifier.startTest(id2);

      for (int i = 0; i < 5; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final s1 = notifier.getSession(id1)!;
      final s2 = notifier.getSession(id2)!;

      // Session 1 should NOT have KO price
      expect(
        s1.currentPrices.containsKey('KO'),
        isFalse,
        reason: 'Session 1 should not know about KO',
      );
      // Session 2 should NOT have AAPL price
      expect(
        s2.currentPrices.containsKey('AAPL'),
        isFalse,
        reason: 'Session 2 should not know about AAPL',
      );

      // Each session only knows its own assets
      expect(s1.currentPrices.containsKey('AAPL'), isTrue);
      expect(s2.currentPrices.containsKey('KO'), isTrue);

      print(
        '\n[ISO-02] S1 AAPL: \$${s1.currentPrices['AAPL']!.toStringAsFixed(2)}',
      );
      print(
        '[ISO-02] S2 KO:   \$${s2.currentPrices['KO']!.toStringAsFixed(2)}',
      );
    });

    test('ISO-03: devMarketPhase is independent per session', () async {
      final notifier = await createNotifier();

      final id1 = notifier.createSession(TestDuration.week1, 10000);
      final id2 = notifier.createSession(TestDuration.month1, 10000);

      await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(id2, 'KO', 10000, 60.0);

      notifier.startTest(id1);
      notifier.startTest(id2);

      for (int i = 0; i < 3; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final s1 = notifier.getSession(id1)!;
      final s2 = notifier.getSession(id2)!;

      // Each session has a market phase — they exist independently
      expect(s1.devMarketPhase, isNotEmpty);
      expect(s2.devMarketPhase, isNotEmpty);

      // Phases come from each session's own epochHistory
      final active1 = s1.epochHistory.where((e) => e.isActive).firstOrNull;
      final active2 = s2.epochHistory.where((e) => e.isActive).firstOrNull;

      expect(active1, isNotNull);
      expect(active2, isNotNull);
      expect(s1.devMarketPhase, equals(active1!.scenario.name));
      expect(s2.devMarketPhase, equals(active2!.scenario.name));

      print('\n[ISO-03] S1 phase: ${s1.devMarketPhase}');
      print('[ISO-03] S2 phase: ${s2.devMarketPhase}');

      // Fear index is also independent
      expect(s1.devFearIndex, isNotNull);
      expect(s2.devFearIndex, isNotNull);
    });

    test('ISO-04: Three sessions of different durations coexist', () async {
      final notifier = await createNotifier();

      final idWeek = notifier.createSession(TestDuration.week1, 10000);
      final idMonth = notifier.createSession(TestDuration.month1, 15000);
      final id3Mo = notifier.createSession(TestDuration.months3, 20000);

      await notifier.buyAssetSetup(idWeek, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(idMonth, 'KO', 15000, 60.0);
      await notifier.buyAssetSetup(id3Mo, 'XOM', 20000, 100.0);

      notifier.startTest(idWeek);
      notifier.startTest(idMonth);
      notifier.startTest(id3Mo);

      // Advance all three in round-robin
      for (int r = 0; r < 5; r++) {
        notifier.refreshPrices(idWeek);
        notifier.refreshPrices(idMonth);
        notifier.refreshPrices(id3Mo);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final sWeek = notifier.getSession(idWeek)!;
      final sMonth = notifier.getSession(idMonth)!;
      final s3Mo = notifier.getSession(id3Mo)!;

      // All are active
      expect(sWeek.status, equals(StressTestStatus.active));
      expect(sMonth.status, equals(StressTestStatus.active));
      expect(s3Mo.status, equals(StressTestStatus.active));

      // Each has correct duration
      expect(sWeek.duration, equals(TestDuration.week1));
      expect(sMonth.duration, equals(TestDuration.month1));
      expect(s3Mo.duration, equals(TestDuration.months3));

      // Each has its own epochHistory
      expect(sWeek.epochHistory, isNotEmpty);
      expect(sMonth.epochHistory, isNotEmpty);
      expect(s3Mo.epochHistory, isNotEmpty);

      // Histories are independent collections
      expect(identical(sWeek.epochHistory, sMonth.epochHistory), isFalse);
      expect(identical(sMonth.epochHistory, s3Mo.epochHistory), isFalse);

      // Each has exactly 1 active epoch
      for (final (label, s) in [
        ('Week', sWeek),
        ('Month', sMonth),
        ('3Mo', s3Mo),
      ]) {
        final activeCount = s.epochHistory.where((e) => e.isActive).length;
        expect(
          activeCount,
          equals(1),
          reason: '$label session should have exactly 1 active epoch',
        );
      }

      print(
        '\n[ISO-04] Week:  ${sWeek.epochHistory.length} epochs, '
        'phase=${sWeek.devMarketPhase}',
      );
      print(
        '[ISO-04] Month: ${sMonth.epochHistory.length} epochs, '
        'phase=${sMonth.devMarketPhase}',
      );
      print(
        '[ISO-04] 3Mo:   ${s3Mo.epochHistory.length} epochs, '
        'phase=${s3Mo.devMarketPhase}',
      );
    });

    test('ISO-05: Deleting one session does not affect the other', () async {
      final notifier = await createNotifier();

      final id1 = notifier.createSession(TestDuration.week1, 10000);
      final id2 = notifier.createSession(TestDuration.month1, 15000);

      await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(id2, 'KO', 15000, 60.0);

      notifier.startTest(id1);
      notifier.startTest(id2);

      for (int i = 0; i < 3; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      // Capture session 2 state before deletion
      final s2Before = notifier.getSession(id2)!;
      final s2EpochCount = s2Before.epochHistory.length;
      final s2Phase = s2Before.devMarketPhase;
      final s2Price = s2Before.currentPrices['KO'];

      // Delete session 1
      notifier.deleteSession(id1);
      expect(notifier.getSession(id1), isNull);

      // Session 2 still exists and is unchanged
      final s2After = notifier.getSession(id2);
      expect(s2After, isNotNull);
      expect(s2After!.epochHistory.length, equals(s2EpochCount));
      expect(s2After.devMarketPhase, equals(s2Phase));
      expect(s2After.currentPrices['KO'], equals(s2Price));

      print(
        '\n[ISO-05] Deleted S1. S2 unchanged: '
        '$s2EpochCount epochs, phase=$s2Phase',
      );
    });

    test(
      'ISO-06: Switching between sessions preserves correct state',
      () async {
        final notifier = await createNotifier();

        // Create and start session 1
        final id1 = notifier.createSession(TestDuration.week1, 10000);
        await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
        notifier.startTest(id1);
        for (int i = 0; i < 3; i++) {
          notifier.refreshPrices(id1);
          await Future.delayed(const Duration(milliseconds: 5));
        }

        // Capture S1 state
        final s1snap = notifier.getSession(id1)!;
        final s1Epochs = s1snap.epochHistory.length;
        final s1Phase = s1snap.devMarketPhase;
        final s1Price = s1snap.currentPrices['AAPL']!;

        // Create and start session 2 while S1 exists
        final id2 = notifier.createSession(TestDuration.month1, 15000);
        await notifier.buyAssetSetup(id2, 'KO', 15000, 60.0);
        notifier.startTest(id2);
        for (int i = 0; i < 3; i++) {
          notifier.refreshPrices(id2);
          await Future.delayed(const Duration(milliseconds: 5));
        }

        // S1 should be unchanged by S2's existence
        final s1after = notifier.getSession(id1)!;
        expect(s1after.epochHistory.length, equals(s1Epochs));
        expect(s1after.devMarketPhase, equals(s1Phase));
        expect(s1after.currentPrices['AAPL']!, equals(s1Price));
        // S1 should not have KO
        expect(s1after.currentPrices.containsKey('KO'), isFalse);

        // S2 should exist with its own state
        final s2 = notifier.getSession(id2)!;
        expect(s2.epochHistory.isNotEmpty, isTrue);
        expect(s2.currentPrices.containsKey('KO'), isTrue);
        expect(s2.currentPrices.containsKey('AAPL'), isFalse);

        print(
          '\n[ISO-06] S1 (week):  $s1Epochs epochs, '
          'AAPL=\$${s1Price.toStringAsFixed(2)}, phase=$s1Phase',
        );
        print(
          '[ISO-06] S2 (month): ${s2.epochHistory.length} epochs, '
          'KO=\$${s2.currentPrices['KO']!.toStringAsFixed(2)}, '
          'phase=${s2.devMarketPhase}',
        );
      },
    );

    test('ISO-07: Casino state is isolated per session', () async {
      final notifier = await createNotifier();

      final id1 = notifier.createSession(TestDuration.infinite, 10000);
      final id2 = notifier.createSession(TestDuration.infinite, 10000);

      await notifier.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(id2, 'KO', 10000, 60.0);

      notifier.startTest(id1);
      notifier.startTest(id2);

      // Advance both through many refreshes to accumulate casino state
      for (int i = 0; i < 10; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final s1 = notifier.getSession(id1)!;
      final s2 = notifier.getSession(id2)!;

      // Each session has its own casino state fields
      // (They exist independently; values may differ based on RNG)
      print('\n[ISO-07] Casino state comparison:');
      print(
        '  S1: declineStreak=${s1.casinoDeclineStreak}, '
        'cooldown=${s1.casinoCatastropheCooldown}, '
        'catCount=${s1.casinoCatastropheCount}',
      );
      print(
        '  S2: declineStreak=${s2.casinoDeclineStreak}, '
        'cooldown=${s2.casinoCatastropheCooldown}, '
        'catCount=${s2.casinoCatastropheCount}',
      );

      // Each has its own currentWeights with correct independent values.
      // (identical() can be unreliable due to Dart VM optimizations;
      //  functional isolation — independent content — is what matters.)
      for (final s in [s1, s2]) {
        expect(s.currentWeights, isNotEmpty);
        // All non-catastrophe scenarios should have entries
        for (final scenario in MarketScenario.values) {
          if (!scenario.isCatastrophe) {
            expect(
              s.currentWeights.containsKey(scenario.name),
              isTrue,
              reason: 'Missing weight for ${scenario.name}',
            );
          }
        }
      }

      // Verify no cross-contamination: mutate S1 weights and check S2 unchanged
      final s2BullBefore = s2.currentWeights['bull']!;
      s1.currentWeights['bull'] = 999.0;
      final s2BullAfter = s2.currentWeights['bull']!;
      expect(
        s2BullAfter,
        equals(s2BullBefore),
        reason: 'Modifying S1 currentWeights must not affect S2',
      );
      // Restore S1
      s1.currentWeights['bull'] = MarketScenario.bull.weight;
    });
  });
}
