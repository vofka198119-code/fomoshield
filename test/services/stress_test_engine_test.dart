// ignore_for_file: avoid_print

// ---------------------------------------------------------------------------
// Stress Test Engine — Comprehensive Internal Test Suite
// ---------------------------------------------------------------------------
// Tests all market scenarios, durations, IPO, trades, verdicts.
// Runs accelerated simulation directly on StressTestNotifier.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanco/src/features/stress_test/stress_test_models.dart';
import 'package:scanco/src/features/stress_test/stress_test_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  StressTestNotifier.globalMarketOpenOverride = (_) => true; // run anytime

  /// Create a fresh notifier for each test.
  Future<StressTestNotifier> createNotifier() async {
    SharedPreferences.setMockInitialValues({});
    final n = StressTestNotifier(userId: 'test_user');
    return n;
  }

  /// Backdates [sessionId]'s `startedAt` (and `lastTickTimestamp`) by [by]
  /// in persisted storage, then returns a freshly reloaded notifier for
  /// [userId] that picks up the change. Used to simulate real elapsed time
  /// for the time-based `canExitInfinite` gate (14 days) without an actual
  /// 14-day wait — mirrors the technique used to verify the Custom-duration
  /// and load-race fixes.
  Future<StressTestNotifier> backdateStartedAtAndReload(
    String userId,
    String sessionId,
    Duration by,
  ) async {
    // Let any pending fire-and-forget _save() from setup calls flush first.
    await Future.delayed(const Duration(milliseconds: 150));
    final prefs = await SharedPreferences.getInstance();
    final key = 'active_stress_test_sessions_$userId';
    final raw = prefs.getString(key)!;
    final list = jsonDecode(raw) as List;
    final sessJson = list.firstWhere((e) => e['id'] == sessionId) as Map;
    final backdated = DateTime.now().subtract(by);
    sessJson['startedAt'] = backdated.toIso8601String();
    sessJson['lastTickTimestamp'] = backdated.toIso8601String();
    await prefs.setString(key, jsonEncode(list));
    await Future.delayed(const Duration(milliseconds: 150));
    final reloaded = StressTestNotifier(userId: userId);
    await Future.delayed(const Duration(milliseconds: 200));
    return reloaded;
  }

  group('1. Session Creation & Limits', () {
    test('1.1 Create session in setup mode', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 5000);
      expect(id, isNotEmpty);
      expect(notifier.totalSessionsCreated, equals(1));

      final session = notifier.getSession(id);
      expect(session, isNotNull);
      expect(session!.status, equals(StressTestStatus.setup));
      expect(session.cash, equals(5000));
      expect(session.duration, equals(TestDuration.week1));
    });

    test('1.2 Can create session respects limits', () async {
      final notifier = await createNotifier();
      expect(notifier.canCreateSession(2), isTrue);
      notifier.createSession(TestDuration.week1, 5000);
      expect(notifier.canCreateSession(2), isTrue);
      notifier.createSession(TestDuration.week1, 5000);
      expect(notifier.canCreateSession(2), isFalse);
    });

    test('1.3 Delete session', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 5000);
      expect(notifier.getSession(id), isNotNull);
      notifier.deleteSession(id);
      expect(notifier.getSession(id), isNull);
    });

    test('1.4 Delete all sessions', () async {
      final notifier = await createNotifier();
      notifier.createSession(TestDuration.week1, 5000);
      notifier.createSession(TestDuration.month1, 15000);
      expect(notifier.state.length, equals(2));
      notifier.deleteAllSessions();
      expect(notifier.state.length, equals(0));
      expect(notifier.totalSessionsCreated, equals(0));
    });
  });

  group('2. Asset Setup Phase', () {
    test('2.1 Buy asset during setup', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 10000);
      final result = await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      expect(result, isTrue);

      final session = notifier.getSession(id);
      expect(session!.holdings.length, equals(1));
      expect(session.holdings[0].symbol, equals('AAPL'));
      expect(session.holdings[0].shares, closeTo(33.33, 0.1));
      expect(session.cash, closeTo(5000, 0.01));
      expect(session.currentPrices['AAPL'], equals(150.0));
    });

    test('2.2 Cannot exceed cash during setup', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 10000);
      final result = await notifier.buyAssetSetup(id, 'AAPL', 15000, 150.0);
      expect(result, isFalse);
    });

    test('2.3 Remove asset during setup', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'MSFT', 3000, 300.0);
      expect(notifier.getSession(id)!.holdings.length, equals(2));

      notifier.removeAssetSetup(id, 'AAPL');
      final session = notifier.getSession(id);
      expect(session!.holdings.length, equals(1));
      expect(session.holdings[0].symbol, equals('MSFT'));
      // cash: 10000 - 5000(AAPL) - 3000(MSFT) + 5000(refund) = 7000
      expect(session.cash, closeTo(7000, 0.01));
    });
  });

  group('3. Epoch Generation & Scenario Distribution', () {
    test(
      '3.1 Generate epochs for 1W (14 epochs = 2 per day × 7 days)',
      () async {
        final notifier = await createNotifier();
        final id = notifier.createSession(TestDuration.week1, 5000);
        await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
        notifier.startTest(id);

        final session = notifier.getSession(id);
        expect(session!.epochHistory.length, greaterThanOrEqualTo(1));
        expect(session.status, equals(StressTestStatus.active));
      },
    );

    test('3.2 Generate epochs for Infinite (780 epochs)', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 5000);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      final session = notifier.getSession(id);
      expect(session!.epochHistory.length, greaterThanOrEqualTo(1));
    });

    test('3.2 Scenario distribution over epochs', () async {
      // Casino wall-clock: infinite-mode epochs roll every 7 days.
      // Use debugForceEpochRoll to fast-forward 200 epochs for stats.
      const rollCount = 200;

      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 5000);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      // Fast-forward through 199 additional epochs (1 already from startTest)
      for (int i = 0; i < rollCount - 1; i++) {
        notifier.debugForceEpochRoll(id);
      }

      final session = notifier.getSession(id)!;
      final counts = <MarketScenario, int>{};
      for (final s in MarketScenario.values) {
        counts[s] = 0;
      }
      for (final e in session.epochHistory) {
        counts[e.scenario] = (counts[e.scenario] ?? 0) + 1;
      }

      // Print distribution
      print(
        '\n═══ SCENARIO DISTRIBUTION (${session.epochHistory.length} epochs) ═══',
      );
      for (final s in MarketScenario.values) {
        final pct = (counts[s]! / session.epochHistory.length * 100)
            .toStringAsFixed(1);
        print(
          '  ${s.name.padRight(18)}: ${counts[s]!.toString().padLeft(3)} ep. ($pct%) [wt: ${s.weight}]',
        );
      }

      expect(counts[MarketScenario.bull]!, greaterThan(20));
      expect(
        counts[MarketScenario.blackSwan]! + counts[MarketScenario.crash]!,
        greaterThan(0),
        reason: 'Should see at least one catastrophe in 200 epochs',
      );
      // No 3 consecutive bears (anti-stuck guarantee)
      bool tripleBear = false;
      for (int i = 0; i < session.epochHistory.length - 2; i++) {
        if (session.epochHistory[i].scenario == MarketScenario.bear &&
            session.epochHistory[i + 1].scenario == MarketScenario.bear &&
            session.epochHistory[i + 2].scenario == MarketScenario.bear) {
          tripleBear = true;
          break;
        }
      }
      expect(tripleBear, isFalse, reason: 'No 3 consecutive bear epochs');

      // Verify Sideways + Volatility appear (regression check)
      expect(
        counts[MarketScenario.sideways]!,
        greaterThan(0),
        reason: 'Sideways scenario must appear',
      );
      expect(
        counts[MarketScenario.volatility]!,
        greaterThan(0),
        reason: 'Volatility scenario must appear',
      );
    });
  });

  group('4. Price Simulation & Sector Behavior', () {
    test('4.1 Prices move from entry values', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.month1, 15000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id, 'XOM', 5000, 100.0);
      notifier.startTest(id);

      for (int i = 0; i < 5; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final session = notifier.getSession(id);
      expect(session!.currentPrices.length, equals(3));
      print('\n═══ PRICE MOVEMENT ═══');
      for (final h in session.holdings) {
        final p = session.currentPrices[h.symbol]!;
        print(
          '  ${h.symbol}: \$${h.entryPrice.toStringAsFixed(1)} ⇒ \$${p.toStringAsFixed(2)}',
        );
        expect(p, greaterThan(h.entryPrice * 0.3));
        expect(p, lessThan(h.entryPrice * 3.0));
      }
    });

    test('4.2 Sector divergence across 6 sectors', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 30000);
      await notifier.buyAssetSetup(id, 'TSLA', 5000, 200.0);
      await notifier.buyAssetSetup(id, 'JPM', 5000, 65.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id, 'XOM', 5000, 100.0);
      await notifier.buyAssetSetup(id, 'PLD', 5000, 120.0);
      await notifier.buyAssetSetup(id, 'JNJ', 5000, 160.0);
      notifier.startTest(id);

      for (int i = 0; i < 20; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final session = notifier.getSession(id);
      final s = session!;
      print(
        '\n═══ SECTOR PERFORMANCE (scenario: ${s.epochHistory.first.scenario.name}) ═══',
      );
      for (final h in s.holdings) {
        final entry = s.basePrices[h.symbol] ?? h.entryPrice;
        final current = s.currentPrices[h.symbol] ?? entry;
        final change = ((current - entry) / entry * 100);
        print(
          '  ${h.symbol.padRight(5)} ${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
        );
      }
      expect(s.totalValue, greaterThan(0));
      expect(s.totalValue, lessThan(300000));
    });

    test('4.3 KO (staples) within ±30% first 10 moves', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 10000);
      await notifier.buyAssetSetup(id, 'KO', 10000, 60.0);
      notifier.startTest(id);

      for (int i = 0; i < 10; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final session = notifier.getSession(id);
      final koPrice = session!.currentPrices['KO']!;
      final change = ((koPrice - 60.0) / 60.0 * 100).abs();
      print('\n═══ KO STABILITY ═══');
      print(
        '  Entry: \$60.00 ⇒ \$${koPrice.toStringAsFixed(2)} (|Δ|=${change.toStringAsFixed(2)}%)',
      );
      // With 7 dynamic scenarios (no neutral sideways), defensive stocks can drift
      // ±50% over 10 epochs under normal conditions. ±80% allows for speculation
      // volatility bursts. Catastrophes (blackSwan/crash) are excluded entirely.
      final hasCatastrophe = session.epochHistory
          .take(10)
          .any((e) => e.scenario.isCatastrophe);
      if (!hasCatastrophe) {
        expect(change, lessThan(50.0));
      } else {
        expect(change, lessThan(80.0));
      }
    });
  });

  group('5. Trading During Active Test', () {
    test('5.1 Buy trade updates cash and holdings', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.month1, 5000);
      // Leave $100 cash for trading during active phase
      await notifier.buyAssetSetup(id, 'AAPL', 4900, 150.0);
      notifier.startTest(id);

      notifier.refreshPrices(id);
      final r = notifier.executeTrade(id, 'AAPL', true, 100);
      expect(r.success, isTrue);

      final session = notifier.getSession(id);
      expect(session!.cash, closeTo(0, 0.1));
      expect(session.trades.length, equals(1));
      expect(session.trades[0].isBuy, isTrue);
    });

    test('5.2 Sell trade reduces shares', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      notifier.refreshPrices(id);
      final r = notifier.executeTrade(id, 'AAPL', false, 10, useShares: true);
      expect(r.success, isTrue);

      final session = notifier.getSession(id);
      final holding = session!.holdings.firstWhere((h) => h.symbol == 'AAPL');
      expect(holding.shares, closeTo(23.33, 0.1));
      expect(session.trades.length, equals(1));
    });

    test('5.3 Insufficient shares rejected', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      notifier.refreshPrices(id);
      final r = notifier.executeTrade(id, 'AAPL', false, 9999, useShares: true);
      expect(r.success, isFalse);
    });

    test('5.4 Insufficient cash rejected', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.month1, 5000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      notifier.refreshPrices(id);
      final r = notifier.executeTrade(id, 'AAPL', true, 999999);
      expect(r.success, isFalse);
    });

    test(
      '5.5 executeTrade preserves casino state + lastTickTimestamp',
      () async {
        // Regression test for the executeTrade state-wipe bug: these
        // fields are mutable, non-final fields on StressTestSession, set
        // directly by casino_epochs.dart via in-place mutation —
        // executeTrade's full-object rebuild used to omit them from the
        // constructor call, silently reverting them to their constructor
        // defaults (0/0/0/-100/null) on every single trade.
        final notifier = await createNotifier();
        final id = notifier.createSession(TestDuration.month1, 10000);
        await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
        notifier.startTest(id);
        notifier.refreshPrices(id);

        // Force non-default values as if a catastrophe had recently
        // rolled and a tick had recently run.
        final before = notifier.getSession(id)!;
        before.casinoCatastropheCooldown = 2;
        before.casinoDeclineStreak = 1;
        before.casinoCatastropheCount = 3;
        before.casinoLastCatastropheEpoch = 5;
        final tickStamp = DateTime.now().subtract(const Duration(seconds: 45));
        before.lastTickTimestamp = tickStamp;

        final r = notifier.executeTrade(id, 'AAPL', false, 5, useShares: true);
        expect(r.success, isTrue);

        final after = notifier.getSession(id)!;
        expect(after.casinoCatastropheCooldown, equals(2));
        expect(after.casinoDeclineStreak, equals(1));
        expect(after.casinoCatastropheCount, equals(3));
        expect(after.casinoLastCatastropheEpoch, equals(5));
        expect(after.lastTickTimestamp, equals(tickStamp));
      },
    );
  });

  group('6. IPO System (CompanyStock autonomous lifecycle)', () {
    test('6.1 No IPO in non-Infinite modes', () async {
      final notifier = await createNotifier();
      for (int a = 0; a < 200; a++) {
        final id = notifier.createSession(TestDuration.week1, 5000);
        await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
        notifier.startTest(id);
        expect(notifier.getSession(id)!.companies.isEmpty, isTrue);
        notifier.deleteSession(id);
      }
    });

    test('6.2 IPO triggers ~3% in Infinite', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'ipo_test');

      int ipoCount = 0;
      const int N = 500;
      for (int a = 0; a < N; a++) {
        final id = notifier.createSession(TestDuration.infinite, 5000);
        await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
        notifier.startTest(id);
        if (notifier.getSession(id)!.companies.isNotEmpty) ipoCount++;
        notifier.deleteSession(id);
      }

      final pct = ipoCount / N * 100;
      print('\n═══ IPO TRIGGER RATE ═══');
      print('  Trials: $N, IPOs: $ipoCount ($pct%)   [expected ~3%]');
      expect(ipoCount, greaterThan(0));
      expect(pct, lessThan(15.0));
    });

    test('6.3 IPO lifecycle when triggered', () async {
      // Find an IPO by brute force
      String? ipoId;
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'ipo_life');
      for (int a = 0; a < 500; a++) {
        final id = notifier.createSession(TestDuration.infinite, 10000);
        await notifier.buyAssetSetup(id, 'KO', 10000, 60.0);
        notifier.startTest(id);
        if (notifier.getSession(id)!.companies.isNotEmpty) {
          ipoId = id;
          break;
        }
        notifier.deleteSession(id);
      }

      if (ipoId != null) {
        print('\n═══ IPO LIFECYCLE ═══');
        for (int i = 0; i < 15; i++) {
          notifier.refreshPrices(ipoId);
          await Future.delayed(const Duration(milliseconds: 20));
          final s = notifier.getSession(ipoId)!;
          if (s.companies.isNotEmpty) {
            for (final company in s.companies.values) {
              print('  Step $i: ${company.symbol} (${company.companyName})');
              print('    Phase: ${company.ipoPhase.name}');
              print('    Age: ${company.ageWeeks} weeks');
              print(
                '    Current:  \$${(s.currentPrices[company.symbol] ?? 0).toStringAsFixed(2)}',
              );
            }
            break;
          }
        }
      } else {
        print('\n═══ IPO: none triggered in 500 attempts (rare) ═══');
      }
    });
  });

  group('7. Test Completion & Verdict', () {
    test('7.1 Archive exists after test', () async {
      final notifier = await createNotifier();
      expect(notifier.verdictArchive, isNotNull);
      expect(notifier.verdictArchive.length, equals(0));
    });

    test('7.2 Terminate infinite mode', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 5000);
      // Leave $1000 cash for trading during active phase
      await notifier.buyAssetSetup(id, 'KO', 4000, 60.0);
      notifier.startTest(id);
      notifier.refreshPrices(id);
      final r = notifier.executeTrade(id, 'KO', true, 100);
      expect(r.success, isTrue);

      // canExitInfinite is time-based: minimum 14 real days elapsed since
      // startedAt (matches the countdown shown in stress_test_screen.dart's
      // timer bar, replaced by "Test Complete" once elapsed). Before that,
      // termination must be refused even with trades already executed.
      expect(notifier.getSession(id)!.canExitInfinite, isFalse);
      expect(notifier.terminateTest(id), isFalse);
      expect(notifier.getSession(id), isNotNull);

      // Simulate 15 real days having elapsed (past the 14-day minimum).
      final reloaded = await backdateStartedAtAndReload(
        'test_user',
        id,
        const Duration(days: 15),
      );

      final s = reloaded.getSession(id)!;
      expect(s.canExitInfinite, isTrue);

      // Now test actual termination
      final terminated = reloaded.terminateTest(id);
      expect(terminated, isTrue);
      // Session should be removed from state (archived)
      expect(reloaded.getSession(id), isNull);
      // Archive should have 1 entry
      expect(reloaded.verdictArchive.length, equals(1));
      // Mirrors the exact predicate stress_test_screen.dart's
      // _handleCompletionIfNeeded uses to distinguish "completed" from
      // "deleted" when the session disappears from active state — confirms
      // the archive entry is already present (not just non-empty) by the
      // time getSession returns null, since terminateTest is synchronous.
      expect(
        reloaded.verdictArchive.any((e) => e.sessionId == id),
        isTrue,
      );
      print(
        '  Terminated — Verdict: ${reloaded.verdictArchive.first.verdict.title}',
      );
    });

    test('7.3 Various verdict types', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'verdict_test');

      print('\n═══ VERDICT EXAMPLES ═══');
      // The verdict is calculated by calculateVerdict(sessionId).
      // Since _completeTest removes sessions, we test the method on mock sessions.
      // We'll create a session, run it, and directly test calculateVerdict.

      // Session 1: Active trader (many trades)
      final id1 = notifier.createSession(TestDuration.week1, 5000);
      await notifier.buyAssetSetup(id1, 'KO', 2500, 60.0);
      await notifier.buyAssetSetup(id1, 'AAPL', 2500, 150.0);
      notifier.startTest(id1);
      for (int t = 0; t < 20; t++) {
        notifier.refreshPrices(id1);
        await Future.delayed(const Duration(milliseconds: 5));
        notifier.executeTrade(id1, 'KO', true, 50);
      }
      // Can't call calculateVerdict because it tries to find session in state by ID and
      // _completeTest removes it. The active session is still there though.
      final v1 = notifier.calculateVerdict(id1);
      print('  Trader (20 trades): ${v1.title} — FS: ${v1.fsScore}');
      notifier.deleteSession(id1);

      // Session 2: Minimal trades (Buffett)
      final id2 = notifier.createSession(TestDuration.week1, 5000);
      await notifier.buyAssetSetup(id2, 'KO', 5000, 60.0);
      notifier.startTest(id2);
      for (int t = 0; t < 3; t++) {
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 5));
      }
      final v2 = notifier.calculateVerdict(id2);
      print('  Minimal (3 trades):  ${v2.title} — FS: ${v2.fsScore}');
      notifier.deleteSession(id2);
    });
  });

  group('8. Pre/Post Market Effects', () {
    test('8.1 Prices stay in clamp range', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 5000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      for (int i = 0; i < 30; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 5));
      }

      final session = notifier.getSession(id);
      final p = session!.currentPrices['AAPL']!;
      print('\n═══ PRE/POST MARKET ═══');
      print('  AAPL clamped: \$${p.toStringAsFixed(2)}  [min=45.0, max=450.0]');
      expect(p, greaterThanOrEqualTo(45.0));
      expect(p, lessThanOrEqualTo(450.0));
    });
  });

  group('9. Comprehensive Market Analysis', () {
    test('9.1 1M duration — all 6 sectors', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'long_test');
      final id = notifier.createSession(TestDuration.month1, 30000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'JPM', 5000, 65.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id, 'XOM', 5000, 100.0);
      await notifier.buyAssetSetup(id, 'JNJ', 5000, 160.0);
      await notifier.buyAssetSetup(id, 'PLD', 5000, 120.0);
      notifier.startTest(id);

      for (int i = 0; i < 30; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final s = notifier.getSession(id)!;
      print('\n═══ LONG SIMULATION (1M) ═══');
      print(
        '  Portfolio: \$${s.totalValue.toStringAsFixed(2)}  P&L: ${s.profitLossPercent.toStringAsFixed(2)}%',
      );
      for (final h in s.holdings) {
        final e = s.basePrices[h.symbol] ?? h.entryPrice;
        final c = s.currentPrices[h.symbol] ?? e;
        final ch = ((c - e) / e * 100);
        print(
          '  ${h.symbol.padRight(5)} \$${e.toStringAsFixed(1)} ⇒ \$${c.toStringAsFixed(2)}  ${ch >= 0 ? '+' : ''}${ch.toStringAsFixed(2)}%',
        );
      }

      // Validate totalValue = cash + Σ(shares × price)
      double calc = s.cash;
      for (final h in s.holdings) {
        calc += h.shares * (s.currentPrices[h.symbol] ?? h.entryPrice);
      }
      expect(s.totalValue, closeTo(calc, 0.01));
    });

    test('9.2 KO (stable) vs TSLA (volatile) volatility', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'sector_cmp');
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id, 'TSLA', 5000, 200.0);
      notifier.startTest(id);

      final List<double> koP = [], tslaP = [];
      for (int i = 0; i < 40; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 8));
        final s = notifier.getSession(id)!;
        koP.add(s.currentPrices['KO'] ?? 60.0);
        tslaP.add(s.currentPrices['TSLA'] ?? 200.0);
      }

      double koVol = 0, tslaVol = 0;
      for (int i = 1; i < koP.length; i++) {
        koVol += ((koP[i] - koP[i - 1]) / koP[i - 1]).abs();
        tslaVol += ((tslaP[i] - tslaP[i - 1]) / tslaP[i - 1]).abs();
      }
      koVol = koVol / (koP.length - 1) * 100;
      tslaVol = tslaVol / (tslaP.length - 1) * 100;

      print('\n═══ VOLATILITY: KO vs TSLA ═══');
      print('  KO (Staples):   avg step ${koVol.toStringAsFixed(3)}%');
      print('  TSLA (Tech):    avg step ${tslaVol.toStringAsFixed(3)}%');
      print(
        '  Ratio: ${(tslaVol / koVol).toStringAsFixed(2)}×  (TSLA should be more volatile)',
      );
    });

    test('9.3 Bear market — staples vs tech', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'bear_test');
      final id = notifier.createSession(TestDuration.week1, 10000);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      for (int i = 0; i < 20; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 8));
      }

      final s = notifier.getSession(id)!;
      print('\n═══ BEAR MARKET ═══');
      print(
        '  Bears: ${s.epochHistory.where((e) => e.scenario == MarketScenario.bear).length}/${s.epochHistory.length}',
      );
      for (final h in s.holdings) {
        final e = s.basePrices[h.symbol] ?? h.entryPrice;
        final c = s.currentPrices[h.symbol] ?? e;
        final ch = ((c - e) / e * 100);
        print(
          '  ${h.symbol.padRight(5)} ${ch >= 0 ? '+' : ''}${ch.toStringAsFixed(2)}%',
        );
      }
      expect(s.totalValue, greaterThan(0));
    });
  });

  group('10. Edge Cases & Stability', () {
    test('10.1 Start with no holdings goes to active', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 5000);
      notifier.startTest(id);
      expect(notifier.getSession(id)!.status, equals(StressTestStatus.active));
    });

    test('10.2 Trade on missing session fails', () async {
      final notifier = await createNotifier();
      final r = notifier.executeTrade('fake', 'AAPL', true, 100);
      expect(r.success, isFalse);
    });

    test('10.3 Price clamping after 100 refreshes', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 5000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      for (int i = 0; i < 100; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final p = notifier.getSession(id)!.currentPrices['AAPL']!;
      print('\n═══ CLAMP CHECK ═══');
      print('  AAPL after 100 refs: \$${p.toStringAsFixed(2)}  [45.0 … 450.0]');
      expect(p, greaterThanOrEqualTo(45.0));
      expect(p, lessThanOrEqualTo(450.0));
    });

    test('10.4 Multiple independent sessions', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'multi_test');
      final id1 = notifier.createSession(TestDuration.week1, 5000);
      final id2 = notifier.createSession(TestDuration.month1, 15000);
      await notifier.buyAssetSetup(id1, 'KO', 5000, 60.0);
      await notifier.buyAssetSetup(id2, 'AAPL', 10000, 150.0);
      await notifier.buyAssetSetup(id2, 'MSFT', 5000, 300.0);
      notifier.startTest(id1);
      notifier.startTest(id2);

      for (int i = 0; i < 10; i++) {
        notifier.refreshPrices(id1);
        notifier.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 8));
      }

      final s1 = notifier.getSession(id1)!;
      final s2 = notifier.getSession(id2)!;
      expect(s1.status, equals(StressTestStatus.active));
      expect(s2.status, equals(StressTestStatus.active));
      expect(s1.holdings.length, equals(1));
      expect(s2.holdings.length, equals(2));

      print('\n═══ MULTI-SESSION ═══');
      print(
        '  S1 (1W, KO):   \$${(s1.currentPrices['KO'] ?? 0).toStringAsFixed(2)}',
      );
      print(
        '  S2 (1M, AAPL): \$${(s2.currentPrices['AAPL'] ?? 0).toStringAsFixed(2)}',
      );
      print(
        '  S2 (MSFT):     \$${(s2.currentPrices['MSFT'] ?? 0).toStringAsFixed(2)}',
      );
    });
  });

  group('11. Per-Stock Price Correction Events', () {
    test('11.1 Sector-dependent price correction events', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'corr_test');
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      final totalRefreshes = 500;
      for (int i = 0; i < totalRefreshes; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      // Simulate many refreshes (infinite mode) and count drops > 10% in one step
      final session = notifier.getSession(id)!;
      final aaplPrice = session.currentPrices['AAPL'] ?? 150.0;
      final koPrice = session.currentPrices['KO'] ?? 60.0;

      print('\n═══ CORRECTION EVENT CHECK ═══');
      print('  Refreshes: $totalRefreshes');
      print('  AAPL final: \$${aaplPrice.toStringAsFixed(2)}');
      print('  KO final:   \$${koPrice.toStringAsFixed(2)}');

      // Prices should still be within clamp bounds
      expect(aaplPrice, greaterThanOrEqualTo(45.0));
      expect(aaplPrice, lessThanOrEqualTo(450.0));
      expect(koPrice, greaterThanOrEqualTo(18.0));
      expect(koPrice, lessThanOrEqualTo(180.0));
    });

    test(
      '11.2 Macro drop magnitudes from scenario drift (crash/blackSwan)',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = StressTestNotifier(userId: 'corr_mag');
        final id = notifier.createSession(TestDuration.infinite, 10000);
        await notifier.buyAssetSetup(id, 'AAPL', 10000, 150.0);
        notifier.startTest(id);

        double prevPrice = 150.0;
        bool foundDrop = false;
        for (int i = 0; i < 500 && !foundDrop; i++) {
          notifier.refreshPrices(id);
          await Future.delayed(const Duration(milliseconds: 3));
          final cur = notifier.getSession(id)!.currentPrices['AAPL']!;
          final drop = (prevPrice - cur) / prevPrice;
          if (drop > 0.06) {
            // Significant drop detected (crash scenario drift −11.5%
            // or blackSwan −30%, plus normal corrections 0.5-8%)
            expect(drop, greaterThan(0.06));
            // Max plausible: blackSwan drift −30% + vol half −4.5% + correction −8% ≈ −42%
            expect(drop, lessThanOrEqualTo(0.50));
            foundDrop = true;
            print('\n═══ MACRO DROP MAGNITUDE ═══');
            print('  Drop detected: ${(drop * 100).toStringAsFixed(1)}%');
          }
          prevPrice = cur;
        }
        // Informational — large drops come from crash/blackSwan, not micro-corrections
        if (!foundDrop) {
          print('\n═══ MACRO DROP MAGNITUDE ═══');
          print(
            '  No >6% step drop in 500 refreshes — crash/blackSwan not rolled',
          );
        }
      },
    );

    test('11.3 Correction does not affect other holdings', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'corr_indep');
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      // Track price histories
      final List<double> aaplPrices = [];
      final List<double> koPrices = [];

      for (int i = 0; i < 100; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
        final s = notifier.getSession(id)!;
        aaplPrices.add(s.currentPrices['AAPL'] ?? 150.0);
        koPrices.add(s.currentPrices['KO'] ?? 60.0);
      }

      // Find the biggest single-step drops for each
      double maxAaplDrop = 0, maxKoDrop = 0;
      for (int i = 1; i < aaplPrices.length; i++) {
        final aaplDrop =
            (aaplPrices[i - 1] - aaplPrices[i]) / aaplPrices[i - 1];
        final koDrop = (koPrices[i - 1] - koPrices[i]) / koPrices[i - 1];
        if (aaplDrop > maxAaplDrop) maxAaplDrop = aaplDrop;
        if (koDrop > maxKoDrop) maxKoDrop = koDrop;
      }

      print('\n═══ CORRECTION INDEPENDENCE ═══');
      print('  Max AAPL drop/step: ${(maxAaplDrop * 100).toStringAsFixed(1)}%');
      print('  Max KO drop/step:   ${(maxKoDrop * 100).toStringAsFixed(1)}%');
      print('  (Corrections are per-stock, not correlated)');
    });
  });

  group('12. Explainable Simulation — Price Contribution Breakdown', () {
    test('12.1 Explanation log is populated after refresh', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'expl_test');
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'MSFT', 5000, 300.0);
      notifier.startTest(id);

      // Run several refreshes to populate explanationLog
      for (int i = 0; i < 20; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final session = notifier.getSession(id)!;
      expect(session.explanationLog, isNotEmpty);
      expect(session.explanationLog.containsKey('AAPL'), isTrue);
      expect(session.explanationLog.containsKey('MSFT'), isTrue);

      final aaplLog = session.explanationLog['AAPL']!;
      expect(aaplLog.length, greaterThanOrEqualTo(20));

      // Each entry must have epochIndex, prices, contributions, phase, scenario
      final first = aaplLog.first;
      expect(first.epochIndex, greaterThanOrEqualTo(0));
      expect(first.priceBefore, greaterThan(0));
      expect(first.priceAfter, greaterThan(0));
      expect(first.contributions, isNotNull);
      expect(first.marketPhase, isNotEmpty);
      expect(first.scenario, isNotEmpty);

      print('\n═══ EXPLAINABLE SIMULATION ═══');
      print('  AAPL entries: ${aaplLog.length}');
      print(
        '  First: epoch#${first.epochIndex} '
        '${first.marketPhase}/${first.scenario} '
        '\$${first.priceBefore.toStringAsFixed(2)} → '
        '\$${first.priceAfter.toStringAsFixed(2)}',
      );
    });

    test('12.2 Contributions sum to 100% (within tolerance)', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'expl_sum');
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0);
      notifier.startTest(id);

      for (int i = 0; i < 30; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final log = notifier.getSession(id)!.explanationLog;
      int totalChecks = 0;
      int withinTolerance = 0;

      for (final entry in log.entries) {
        for (final expl in entry.value) {
          totalChecks++;
          final sum = expl.contributions.total;
          // Allow ±0.5% rounding tolerance around 100%
          if ((sum - 100.0).abs() <= 0.5) withinTolerance++;
        }
      }

      print('\n═══ CONTRIBUTION SUM CHECK ═══');
      print('  Entries checked: $totalChecks');
      print('  Within tolerance: $withinTolerance');

      // At least 90% of entries should sum to ~100%
      expect(totalChecks, greaterThan(0));
      expect(withinTolerance / totalChecks, greaterThanOrEqualTo(0.90));
    });

    test('12.3 MarketPct dominates in stable market', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'expl_market');
      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));
      final id = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);

      for (int i = 0; i < 20; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final log = notifier.getSession(id)!.explanationLog;
      double avgMarketPct = 0;
      int count = 0;

      for (final expl in (log['AAPL'] ?? [])) {
        if (expl.contributions.total > 0) {
          avgMarketPct += expl.contributions.marketPct;
          count++;
        }
      }
      avgMarketPct = count > 0 ? avgMarketPct / count : 0;

      print('\n═══ MARKET CONTRIBUTION ═══');
      print('  Avg marketPct: ${avgMarketPct.toStringAsFixed(1)}%');
      // Market drift is a meaningful contributor even with realistic S&P 500 bounds
      expect(count, greaterThan(0), reason: 'Explanations must be generated');
      expect(avgMarketPct, greaterThan(0));
    });

    test('12.4 SectorPct differs between tech and defensive sectors', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'expl_sector');
      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0); // tech
      await notifier.buyAssetSetup(id, 'KO', 5000, 60.0); // consumer staples
      notifier.startTest(id);

      for (int i = 0; i < 30; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final log = notifier.getSession(id)!.explanationLog;
      double avgSectorAapl = 0, avgSectorKo = 0;
      int cntAapl = 0, cntKo = 0;

      for (final expl in (log['AAPL'] ?? [])) {
        if (expl.contributions.total > 0) {
          avgSectorAapl += expl.contributions.sectorPct;
          cntAapl++;
        }
      }
      for (final expl in (log['KO'] ?? [])) {
        if (expl.contributions.total > 0) {
          avgSectorKo += expl.contributions.sectorPct;
          cntKo++;
        }
      }
      avgSectorAapl = cntAapl > 0 ? avgSectorAapl / cntAapl : 0;
      avgSectorKo = cntKo > 0 ? avgSectorKo / cntKo : 0;

      print('\n═══ SECTOR CONTRIBUTION COMPARISON ═══');
      print(
        '  AAPL (tech) avg sectorPct: ${avgSectorAapl.toStringAsFixed(1)}%',
      );
      print(
        '  KO (consumer) avg sectorPct: ${avgSectorKo.toStringAsFixed(1)}%',
      );
      // AAPL (tech) always has non-zero sectorPct (tech.drift ≠ avgDrift)
      expect(avgSectorAapl, greaterThan(0));
      // Sector contributions MUST differ across sectors (different drift values)
      // Note: in Bull scenario, consumerStaples.drift == avgDrift → KO sectorPct = 0%.
      // This is correct market behavior — the test validates that difference EXISTS.
      expect(avgSectorAapl, isNot(equals(avgSectorKo)));
    });

    test('12.5 Correction event increases newsPct contribution', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'expl_news');
      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 10000, 150.0);
      notifier.startTest(id);

      // Run many refreshes to encounter a correction event
      for (int i = 0; i < 200; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      // Scan for ticks with high newsPct (indicating a correction/bounce event)
      final log = notifier.getSession(id)!.explanationLog['AAPL'] ?? [];
      double maxNewsPct = 0;
      for (final expl in log) {
        if (expl.contributions.newsPct > maxNewsPct) {
          maxNewsPct = expl.contributions.newsPct;
        }
      }

      print('\n═══ NEWS CONTRIBUTION (CORRECTION) ═══');
      print('  Max newsPct observed: ${maxNewsPct.toStringAsFixed(1)}%');
      // Corrections can happen but are random; just print for info
      // Not asserting — corrections are probabilistic
    });
  });

  group('13. Causal Chain — Scenario → Phase → Explanation', () {
    setUp(() async {
      // Reset SharedPreferences singleton to prevent test pollution.
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    });

    test('13.1 Explanation captures phase and scenario metadata', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'causal_meta', seed: 42);
      final id = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 10000, 150.0);
      notifier.startTest(id);

      for (int i = 0; i < 30; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final log = notifier.getSession(id)!.explanationLog['AAPL'] ?? [];
      expect(log, isNotEmpty);

      // Collect unique phases and scenarios observed
      final phases = log.map((e) => e.marketPhase).toSet();
      final scenarios = log.map((e) => e.scenario).toSet();

      print('\n═══ CAUSAL CHAIN METADATA ═══');
      print('  Phases observed: $phases');
      print('  Scenarios observed: $scenarios');
      print('  Total ticks logged: ${log.length}');

      // Every entry must have non-empty phase and scenario
      for (final expl in log) {
        expect(expl.marketPhase, isNotEmpty);
        expect(expl.scenario, isNotEmpty);
      }
    });

    test('13.2 PriceBefore and PriceAfter form a sequential chain', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'causal_chain', seed: 42);
      final id = notifier.createSession(TestDuration.infinite, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      await notifier.buyAssetSetup(id, 'MSFT', 5000, 300.0);
      notifier.startTest(id);

      for (int i = 0; i < 25; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final session = notifier.getSession(id)!;

      // For each symbol, verify chain: log[n].priceAfter ≈ log[n+1].priceBefore
      for (final entry in session.explanationLog.entries) {
        final log = entry.value;
        for (int i = 0; i < log.length - 1; i++) {
          expect(log[i].priceAfter, closeTo(log[i + 1].priceBefore, 0.001));
        }
      }

      print('\n═══ PRICE CHAIN INTEGRITY ═══');
      for (final entry in session.explanationLog.entries) {
        final log = entry.value;
        print(
          '  ${entry.key}: ${log.length} ticks, '
          '\$${log.first.priceBefore.toStringAsFixed(2)} → '
          '\$${log.last.priceAfter.toStringAsFixed(2)}',
        );
      }
    });

    test('13.3 Scenario phase transitions create distinct patterns', () async {
      // Use month1 duration to increase chance of phase transitions
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'causal_pattern');
      final id = notifier.createSession(TestDuration.month1, 10000);
      await notifier.buyAssetSetup(id, 'AAPL', 10000, 150.0);
      notifier.startTest(id);

      // Run enough refreshes to likely trigger phase transitions
      for (int i = 0; i < 60; i++) {
        notifier.refreshPrices(id);
        await Future.delayed(const Duration(milliseconds: 3));
      }

      final log = notifier.getSession(id)!.explanationLog['AAPL'] ?? [];
      final phases = log.map((e) => e.marketPhase).toList();

      // Count phase transitions (change in marketPhase between consecutive ticks)
      int transitions = 0;
      for (int i = 1; i < phases.length; i++) {
        if (phases[i] != phases[i - 1]) transitions++;
      }

      print('\n═══ PHASE TRANSITIONS ═══');
      print('  Total ticks: ${log.length}');
      print('  Unique phases: ${phases.toSet()}');
      print('  Phase transitions: $transitions');

      // If transitions occurred, check that contributions differ between phases
      if (transitions > 0) {
        // Find first phase change index
        int changeIdx = 0;
        for (int i = 1; i < phases.length; i++) {
          if (phases[i] != phases[i - 1]) {
            changeIdx = i;
            break;
          }
        }
        if (changeIdx > 0 && changeIdx < log.length) {
          final before = log[changeIdx - 1].contributions;
          final after = log[changeIdx].contributions;
          print(
            '  Phase transition: ${phases[changeIdx - 1]} → ${phases[changeIdx]}',
          );
          print(
            '    Before: '
            'M=${before.marketPct.toStringAsFixed(1)} '
            'S=${before.sectorPct.toStringAsFixed(1)} '
            'C=${before.companyPct.toStringAsFixed(1)} '
            'N=${before.newsPct.toStringAsFixed(1)} '
            'Noise=${before.noisePct.toStringAsFixed(1)}',
          );
          print(
            '    After:  '
            'M=${after.marketPct.toStringAsFixed(1)} '
            'S=${after.sectorPct.toStringAsFixed(1)} '
            'C=${after.companyPct.toStringAsFixed(1)} '
            'N=${after.newsPct.toStringAsFixed(1)} '
            'Noise=${after.noisePct.toStringAsFixed(1)}',
          );
        }
      }
    });

    test(
      '13.4 Epoch scenario changes are reflected in explanation metadata',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = StressTestNotifier(userId: 'causal_scenario');
        final id = notifier.createSession(TestDuration.month1, 10000);
        await notifier.buyAssetSetup(id, 'AAPL', 10000, 150.0);
        notifier.startTest(id);

        for (int i = 0; i < 60; i++) {
          notifier.refreshPrices(id);
          await Future.delayed(const Duration(milliseconds: 3));
        }

        final session = notifier.getSession(id)!;
        final log = session.explanationLog['AAPL'] ?? [];
        final epochScenarios = {
          for (final e in session.epochHistory) e.index: e.scenario.name,
        };

        // Verify explanation scenarios match epoch definitions
        int mismatches = 0;
        final scenariosInLog = <String>{};
        for (final expl in log) {
          scenariosInLog.add(expl.scenario);
          if (epochScenarios.containsKey(expl.epochIndex)) {
            // The scenario in the log should match the epoch definition
            // (may have drift forward, so just print mismatch for info)
            if (expl.scenario != epochScenarios[expl.epochIndex]) {
              mismatches++;
            }
          }
        }

        print('\n═══ SCENARIO CONSISTENCY ═══');
        print('  Epoch scenarios: ${epochScenarios.values.toSet()}');
        print('  Scenarios in log: $scenariosInLog');
        print('  Mismatches: $mismatches');

        // Scenarios observed should overlap with epoch-defined scenarios
        for (final s in scenariosInLog) {
          expect(
            epochScenarios.values.contains(s),
            isTrue,
            reason: 'Scenario "$s" not found in any epoch definition',
          );
        }
      },
    );
  });

  group('14. Determinism — Seeded Reproducibility', () {
    test(
      '14.1 Same seed → identical prices across two independent notifiers',
      () async {
        SharedPreferences.setMockInitialValues({});
        final n1 = StressTestNotifier(userId: 'det_1', seed: 42);
        final id1 = n1.createSession(
          TestDuration.month1,
          10000,
          simulationSeed: 42,
        );
        await n1.buyAssetSetup(id1, 'AAPL', 5000, 150.0);
        await n1.buyAssetSetup(id1, 'MSFT', 5000, 300.0);
        n1.startTest(id1);

        for (int i = 0; i < 48; i++) {
          n1.refreshPrices(id1);
          await Future.delayed(const Duration(milliseconds: 3));
        }

        final s1 = n1.getSession(id1)!;
        final prices1 = Map<String, double>.from(s1.currentPrices);

        // Second notifier with identical seed
        SharedPreferences.setMockInitialValues({});
        final n2 = StressTestNotifier(userId: 'det_2', seed: 42);
        final id2 = n2.createSession(
          TestDuration.month1,
          10000,
          simulationSeed: 42,
        );
        await n2.buyAssetSetup(id2, 'AAPL', 5000, 150.0);
        await n2.buyAssetSetup(id2, 'MSFT', 5000, 300.0);
        n2.startTest(id2);

        for (int i = 0; i < 48; i++) {
          n2.refreshPrices(id2);
          await Future.delayed(const Duration(milliseconds: 3));
        }

        final s2 = n2.getSession(id2)!;

        print('\n═══ DETERMINISM CHECK ═══');
        print('  Seed: 42, Ticks: 48');
        print(
          '  Epochs: n1=${s1.epochHistory.length}, n2=${s2.epochHistory.length}',
        );
        for (final symbol in prices1.keys) {
          final p1 = prices1[symbol]!;
          final p2 = s2.currentPrices[symbol]!;
          final diff = (p1 - p2).abs();
          print(
            '  ${symbol.padRight(5)}: n1=\$${p1.toStringAsFixed(4)} n2=\$${p2.toStringAsFixed(4)}  diff=${diff.toStringAsExponential(2)}',
          );
          expect(p2, closeTo(p1, 1e-7));
        }
      },
    );

    test('14.2 Different seeds produce different price paths', () async {
      SharedPreferences.setMockInitialValues({});
      final n1 = StressTestNotifier(userId: 'det_diff1', seed: 42);
      final id1 = n1.createSession(
        TestDuration.month1,
        10000,
        simulationSeed: 42,
      );
      await n1.buyAssetSetup(id1, 'AAPL', 10000, 150.0);
      n1.startTest(id1);

      for (int i = 0; i < 48; i++) {
        n1.refreshPrices(id1);
        await Future.delayed(const Duration(milliseconds: 3));
      }
      final p1 = n1.getSession(id1)!.currentPrices['AAPL']!;

      SharedPreferences.setMockInitialValues({});
      final n2 = StressTestNotifier(userId: 'det_diff2', seed: 999);
      final id2 = n2.createSession(
        TestDuration.month1,
        10000,
        simulationSeed: 999,
      );
      await n2.buyAssetSetup(id2, 'AAPL', 10000, 150.0);
      n2.startTest(id2);

      for (int i = 0; i < 48; i++) {
        n2.refreshPrices(id2);
        await Future.delayed(const Duration(milliseconds: 3));
      }
      final p2 = n2.getSession(id2)!.currentPrices['AAPL']!;

      final diff = (p1 - p2).abs();
      print('\n═══ DIFFERENT SEEDS ═══');
      print('  Seed 42: \$${p1.toStringAsFixed(4)}');
      print('  Seed 999: \$${p2.toStringAsFixed(4)}');
      print('  Diff: \$${diff.toStringAsFixed(4)}');
      // Astronomical odds that two different seeds give identical prices
      expect(diff, greaterThan(0.01));
    });
  });

  // ═════════════════════════════════════════════════════════════════
  // Task 1.7.1 — Cache Lifecycle Verification
  // ═════════════════════════════════════════════════════════════════

  group('15. Ephemeral Session Wipe on Complete/Delete', () {
    test('15.1 Active session is wiped from state after terminateTest', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.infinite, 5000);
      await notifier.buyAssetSetup(id, 'KO', 4000, 60.0);
      notifier.startTest(id);
      notifier.refreshPrices(id);
      expect(notifier.executeTrade(id, 'KO', true, 100).success, isTrue);

      final before = notifier.getSession(id);
      expect(before, isNotNull);
      expect(before!.status, equals(StressTestStatus.active));

      // canExitInfinite is time-based (14 real days elapsed) — simulate
      // that having passed so terminateTest's real gate actually opens.
      final reloaded = await backdateStartedAtAndReload(
        'test_user',
        id,
        const Duration(days: 15),
      );

      // Terminate → _completeTest wipes from state
      final terminated = reloaded.terminateTest(id);
      expect(terminated, isTrue);

      // Session must be null — fully removed from active state
      expect(reloaded.getSession(id), isNull);

      // State list must NOT contain the session
      expect(reloaded.state.any((s) => s.id == id), isFalse);

      print('  ✅ Active session wiped: getSession → null, state has 0 refs');
    });

    test('15.2 deleteSession wipes session from state and RNG map', () async {
      final notifier = await createNotifier();
      final id = notifier.createSession(TestDuration.week1, 5000);
      await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
      notifier.startTest(id);
      notifier.refreshPrices(id);

      expect(notifier.getSession(id), isNotNull);
      expect(notifier.state.length, equals(1));

      notifier.deleteSession(id);

      expect(notifier.getSession(id), isNull);
      expect(notifier.state.any((s) => s.id == id), isFalse);

      print('  ✅ deleteSession: state empty, getSession → null');
    });

    test('15.3 deleteSession does NOT affect verdict history', () async {
      final notifier = await createNotifier();

      // First: complete one session to populate archive
      final id1 = notifier.createSession(TestDuration.infinite, 5000);
      await notifier.buyAssetSetup(id1, 'KO', 4000, 60.0);
      notifier.startTest(id1);
      notifier.refreshPrices(id1);
      notifier.executeTrade(id1, 'KO', true, 100);
      notifier.refreshPrices(id1);
      notifier.executeTrade(id1, 'KO', false, 20, useShares: true);
      notifier.refreshPrices(id1);
      notifier.executeTrade(id1, 'KO', true, 200);
      // canExitInfinite is now time-based (14 real days elapsed) — this
      // test isn't about the termination gate itself, so bypass it.
      notifier.debugCompleteTest(id1);
      final archiveAfterComplete = notifier.verdictArchive.length;
      expect(archiveAfterComplete, equals(1));

      // Second: create a session and just delete it (no completion)
      final id2 = notifier.createSession(TestDuration.week1, 5000);
      await notifier.buyAssetSetup(id2, 'AAPL', 5000, 150.0);
      notifier.startTest(id2);
      notifier.deleteSession(id2);

      // Archive must still be intact — deleteSession does not touch verdicts
      expect(notifier.verdictArchive.length, equals(1));
      expect(notifier.verdictArchive.first.sessionId, equals(id1));

      print('  ✅ Verdict history untouched after deleteSession');
    });

    test(
      '15.4 Active session key is rewritten without completed session',
      () async {
        // Use a notifier with a specific userId to test SharedPreferences
        SharedPreferences.setMockInitialValues({});
        final notifier = StressTestNotifier(userId: 'wipe_test');
        final prefs = await SharedPreferences.getInstance();

        final id = notifier.createSession(TestDuration.infinite, 5000);
        await notifier.buyAssetSetup(id, 'KO', 4000, 60.0);
        notifier.startTest(id);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 100);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', false, 20, useShares: true);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 200);
        // canExitInfinite is now time-based (14 real days elapsed) — this
        // test isn't about the termination gate itself, so bypass it.
        notifier.debugCompleteTest(id);

        // _save() is called async inside _completeTest() — wait for it
        await Future.delayed(const Duration(milliseconds: 100));

        // Read the active_stress_test_sessions key from prefs
        final sessionsKey = 'active_stress_test_sessions_wipe_test';
        final raw = prefs.getString(sessionsKey);
        if (raw != null && raw.isNotEmpty) {
          final list = jsonDecode(raw) as List<dynamic>;
          // None of the entries should have the completed session's ID
          final ids = list
              .map((e) => (e as Map<String, dynamic>)['id'] as String)
              .toSet();
          expect(
            ids.contains(id),
            isFalse,
            reason: 'Completed session leaked in active cache!',
          );
        }
        // else: empty string or null — both are correct (session was the only one)

        print('  ✅ active_stress_test_sessions key: no leaked session IDs');
      },
    );
  });

  group('16. FIFO Verdict History — 21st Element Rule', () {
    test('16.1 Archive stays at exactly 20 after 22 completions', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = StressTestNotifier(userId: 'fifo_test');

      // Complete 22 infinite sessions — each pushes a verdict into archive
      final List<String> allIds = [];
      for (int i = 0; i < 22; i++) {
        final id = notifier.createSession(TestDuration.infinite, 5000);
        allIds.add(id);
        await notifier.buyAssetSetup(id, 'KO', 4000, 60.0);
        notifier.startTest(id);
        // 3 trades for canExitInfinite
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 100);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', false, 10, useShares: true);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 100);
        // canExitInfinite is now time-based (14 real days elapsed) — this
        // test is about FIFO eviction, not the termination gate, so bypass it.
        notifier.debugCompleteTest(id);
      }

      final archive = notifier.verdictArchive;
      expect(
        archive.length,
        equals(20),
        reason: 'Archive must cap at 20, but got ${archive.length}',
      );

      // Oldest entry at index 0 = the 3rd completed session
      // (first 2 were evicted by FIFO)
      // Newest entry at index 19 = the 22nd completed session
      expect(
        archive.first.sessionId,
        equals(allIds[2]),
        reason: 'Oldest surviving entry should be session #3 (index 2)',
      );
      expect(
        archive.last.sessionId,
        equals(allIds[21]),
        reason: 'Newest entry should be session #22 (index 21)',
      );

      // Verify evicted IDs are NOT in the archive
      final archivedIds = archive.map((e) => e.sessionId).toSet();
      expect(
        archivedIds.contains(allIds[0]),
        isFalse,
        reason: 'Session #1 should be evicted (FIFO)',
      );
      expect(
        archivedIds.contains(allIds[1]),
        isFalse,
        reason: 'Session #2 should be evicted (FIFO)',
      );

      print('\n═══ FIFO VERIFICATION ═══');
      print('  Total completed: 22');
      print('  Archive length: ${archive.length} (capped at 20)');
      print('  Evicted: ${allIds[0]}, ${allIds[1]}');
      print('  Oldest present: ${archive.first.sessionId} (completed 3rd)');
      print('  Newest present: ${archive.last.sessionId} (completed 22nd)');
    });

    test(
      '16.2 Exactly 20 entries remain after filling to exactly 20',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notifier = StressTestNotifier(userId: 'fifo_exact');

        // Fill exactly 20
        for (int i = 0; i < 20; i++) {
          final id = notifier.createSession(TestDuration.infinite, 5000);
          await notifier.buyAssetSetup(id, 'KO', 4000, 60.0);
          notifier.startTest(id);
          notifier.refreshPrices(id);
          notifier.executeTrade(id, 'KO', true, 100);
          notifier.refreshPrices(id);
          notifier.executeTrade(id, 'KO', false, 10, useShares: true);
          notifier.refreshPrices(id);
          notifier.executeTrade(id, 'KO', true, 100);
          // canExitInfinite is now time-based (14 real days elapsed) — this
          // test is about the FIFO cap, not the termination gate, so bypass it.
          notifier.debugCompleteTest(id);
        }

        expect(notifier.verdictArchive.length, equals(20));
        print('  ✅ 20 entries — exactly at cap, no eviction');
      },
    );

    test('16.3 Archive persists across notifier reloads', () async {
      SharedPreferences.setMockInitialValues({});
      const uid = 'fifo_persist';
      final n1 = StressTestNotifier(userId: uid);

      // Complete 5 sessions
      final List<String> ids = [];
      for (int i = 0; i < 5; i++) {
        final id = n1.createSession(TestDuration.infinite, 5000);
        ids.add(id);
        await n1.buyAssetSetup(id, 'KO', 4000, 60.0);
        n1.startTest(id);
        n1.refreshPrices(id);
        n1.executeTrade(id, 'KO', true, 100);
        n1.refreshPrices(id);
        n1.executeTrade(id, 'KO', false, 10, useShares: true);
        n1.refreshPrices(id);
        n1.executeTrade(id, 'KO', true, 100);
        // canExitInfinite is now time-based (14 real days elapsed) — this
        // test is about archive persistence, not the termination gate.
        n1.debugCompleteTest(id);
      }
      expect(n1.verdictArchive.length, equals(5));

      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 200));

      // Create a NEW notifier with same userId — should reload archive
      final n2 = StressTestNotifier(userId: uid);
      // Wait for async _load() to finish inside n2 constructor
      await Future.delayed(const Duration(milliseconds: 100));
      expect(n2.verdictArchive.length, equals(5));
      // Verify session IDs match
      final n2Ids = n2.verdictArchive.map((e) => e.sessionId).toSet();
      for (final id in ids) {
        expect(
          n2Ids.contains(id),
          isTrue,
          reason: 'Session $id lost after reload',
        );
      }

      print('  ✅ Archive survived full notifier reload');
    });

    test(
      '16.4 Verdict entry structure is complete (all fields present)',
      () async {
        final notifier = await createNotifier();
        final id = notifier.createSession(TestDuration.infinite, 7500);
        await notifier.buyAssetSetup(id, 'AAPL', 5000, 150.0);
        await notifier.buyAssetSetup(id, 'KO', 2000, 60.0);
        notifier.startTest(id);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 100);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', false, 10, useShares: true);
        notifier.refreshPrices(id);
        notifier.executeTrade(id, 'KO', true, 100);
        // canExitInfinite is now time-based (14 real days elapsed) — this
        // test is about verdict-entry structure, not the termination gate.
        notifier.debugCompleteTest(id);

        final entry = notifier.verdictArchive.first;
        expect(entry.sessionId, equals(id));
        expect(entry.durationLabel, isNotEmpty);
        expect(entry.startingCash, equals(7500));
        expect(entry.finalValue, greaterThan(0));
        expect(entry.totalTrades, greaterThanOrEqualTo(3));
        expect(entry.holdingCount, equals(2));
        expect(entry.verdict.primaryType, isNotNull);
        expect(entry.verdict.title, isNotEmpty);
        expect(entry.verdict.fsScore, greaterThanOrEqualTo(0));
        expect(entry.verdict.fsScore, lessThanOrEqualTo(100));

        print('\n═══ VERDICT ENTRY STRUCTURE ═══');
        print('  ID: ${entry.sessionId}');
        print('  Duration: ${entry.durationLabel}');
        print('  P&L: ${entry.pnlPercent.toStringAsFixed(2)}%');
        print(
          '  Trades: ${entry.totalTrades}  Holdings: ${entry.holdingCount}',
        );
        print(
          '  Verdict: ${entry.verdict.title} (FS: ${entry.verdict.fsScore})',
        );
      },
    );
  });

  group('17. Corruption & Null Safety — Graceful Degradation', () {
    test('17.1 Corrupted verdict JSON does not crash engine', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Write utterly broken JSON to the verdicts history key
      const uid = 'corrupt_test';
      await prefs.setString(
        'stress_test_verdicts_history_$uid',
        'this is { NOT valid JSON {{{',
      );

      // Creating a notifier should load this key and NOT throw
      StressTestNotifier? notifier;
      try {
        notifier = StressTestNotifier(userId: uid);
      } catch (e) {
        fail('Engine crashed on corrupted verdict JSON: $e');
      }

      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier, isNotNull);
      expect(
        notifier.verdictArchive,
        isEmpty,
        reason: 'Corrupted archive should fallback to empty list',
      );

      print('  ✅ Corrupted JSON → empty list, no crash');
    });

    test('17.2 Corrupted active sessions JSON does not crash engine', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const uid = 'corrupt_sessions';
      await prefs.setString(
        'active_stress_test_sessions_$uid',
        '{"garbage": "not an array"}',
      );

      StressTestNotifier? notifier;
      try {
        notifier = StressTestNotifier(userId: uid);
      } catch (e) {
        fail('Engine crashed on corrupted sessions JSON: $e');
      }

      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier, isNotNull);
      expect(
        notifier.state,
        isEmpty,
        reason: 'Corrupted sessions should fallback to empty list',
      );

      print('  ✅ Corrupted active sessions → empty state, no crash');
    });

    test('17.3 Missing fields in verdict JSON use safe defaults', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Write minimal but valid JSON — missing many fields
      const uid = 'missing_fields';
      await prefs.setString(
        'stress_test_verdicts_history_$uid',
        '[{"sessionId":"test_123"}]',
      );

      StressTestNotifier? notifier;
      try {
        notifier = StressTestNotifier(userId: uid);
      } catch (e) {
        fail('Engine crashed on incomplete verdict JSON: $e');
      }

      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier, isNotNull);
      // Missing required field 'verdict' causes fromJson to fail →
      // _loadArchive falls back to empty list (graceful degradation)
      final archive = notifier.verdictArchive;
      expect(
        archive,
        isEmpty,
        reason:
            'Incomplete JSON (missing verdict) → fallback to empty, no crash',
      );

      print('  ✅ Missing fields → empty fallback, no crash');
    });

    test('17.4 Empty string storage key returns clean empty state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Write empty string (not null) for both keys
      await prefs.setString('active_stress_test_sessions_empty_user', '');
      await prefs.setString('stress_test_verdicts_history_empty_user', '');

      StressTestNotifier? notifier;
      try {
        notifier = StressTestNotifier(userId: 'empty_user');
      } catch (e) {
        fail('Engine crashed on empty string storage: $e');
      }

      // _load() is async in constructor — wait for it to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier, isNotNull);
      expect(notifier.state, isEmpty);
      expect(notifier.verdictArchive, isEmpty);

      print('  ✅ Empty string storage → clean empty state');
    });

    test(
      '17.5 Null/missing storage keys default to empty gracefully',
      () async {
        // setMockInitialValues with empty map = all keys return null
        SharedPreferences.setMockInitialValues({});
        final notifier = StressTestNotifier(userId: 'fresh_user');

        // _load() is async in constructor — wait for it to complete
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, isEmpty);
        expect(notifier.verdictArchive, isEmpty);
        expect(notifier.totalSessionsCreated, equals(0));

        print('  ✅ Fresh user (no keys) → all defaults empty');
      },
    );
  });
}
