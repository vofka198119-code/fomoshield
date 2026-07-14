// ---------------------------------------------------------------------------
// KO Stress Test Simulation — Buy KO at $80.48, hold 1 month accelerated
// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/src/features/stress_test/stress_test_models.dart';
import '../../lib/src/features/stress_test/stress_test_engine.dart';

void main() {
  test('KO 1-month stress test — buy & hold', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final notifier = StressTestNotifier(userId: 'ko_test');

    // --- Setup ---
    const double koEntryPrice = 80.48;
    const double investment = 10000.0;
    final id = notifier.createSession(TestDuration.month1, investment);
    print('  Cash before buy: \$${notifier.getSession(id)!.cash.toStringAsFixed(2)}');
    final bought = await notifier.buyAssetSetup(id, 'KO', investment, koEntryPrice);
    print('  Buy result: $bought');
    final s = notifier.getSession(id)!;
    print('  Holdings: ${s.holdings.length}, Cash after: \$${s.cash.toStringAsFixed(2)}');
    expect(s.holdings.length, equals(1));
    expect(s.cash, closeTo(0, 0.01));

    // --- Start test ---
    notifier.startTest(id);
    expect(notifier.getSession(id)!.status, equals(StressTestStatus.active));
    final totalEpochs = notifier.getSession(id)!.epochHistory.length;
    print('\n========== KO STRESS TEST — 1 MONTH ==========');
    print('  Entry:  KO \$${koEntryPrice.toStringAsFixed(2)}');
    print('  Invest: \$${investment.toStringAsFixed(2)}');
    print('  Total epochs: $totalEpochs');

    // --- Accelerated simulation ---
    final List<double> priceHistory = [];
    final List<String> scenarioHistory = [];

    for (int i = 0; i < totalEpochs; i++) {
      notifier.refreshPrices(id);
      // Tiny delay for time progression
      await Future.delayed(const Duration(milliseconds: 5));
      final s = notifier.getSession(id)!;
      priceHistory.add(s.currentPrices['KO'] ?? koEntryPrice);
      if (i < s.epochHistory.length) {
        scenarioHistory.add(s.epochHistory[i].scenario.name);
      }
    }

    // --- Results ---
    final session = notifier.getSession(id)!;
    final finalPrice = session.currentPrices['KO'] ?? koEntryPrice;
    final shares = session.holdings.first.shares;
    final finalValue = shares * finalPrice;
    final pnl = finalValue - investment;
    final pnlPercent = ((finalValue / investment) - 1) * 100;

    print('\n---------- RESULTS ----------');
    print('  Final price:  \$${finalPrice.toStringAsFixed(2)}');
    print('  Shares held:  ${shares.toStringAsFixed(4)}');
    print('  Final value:  \$${finalValue.toStringAsFixed(2)}');
    print('  P&L:          \$${pnl.toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(2)}%)');

    // Scenario breakdown
    print('\n---------- SCENARIO LOG (${scenarioHistory.length} epochs) ----------');
    final scenarioCounts = <String, int>{};
    for (final sc in scenarioHistory) {
      scenarioCounts[sc] = (scenarioCounts[sc] ?? 0) + 1;
    }
    scenarioCounts.forEach((sc, count) {
      final pct = (count / scenarioHistory.length * 100).toStringAsFixed(1);
      print('  $sc: $count ep. ($pct%)');
    });

    // Price behavior analysis
    print('\n---------- PRICE BEHAVIOR ----------');
    double maxPrice = koEntryPrice, minPrice = koEntryPrice;
    int corrections = 0;
    for (int i = 1; i < priceHistory.length; i++) {
      if (priceHistory[i] > maxPrice) maxPrice = priceHistory[i];
      if (priceHistory[i] < minPrice) minPrice = priceHistory[i];
      final drop = (priceHistory[i-1] - priceHistory[i]) / priceHistory[i-1];
      if (drop > 0.10) corrections++;
    }
    print('  High:        \$${maxPrice.toStringAsFixed(2)}');
    print('  Low:         \$${minPrice.toStringAsFixed(2)}');
    print('  Volatility:  \$${(maxPrice - minPrice).toStringAsFixed(2)} ' +
          '(${((maxPrice - minPrice) / koEntryPrice * 100).toStringAsFixed(1)}%)');
    print('  Corrections (>10% drop/step): $corrections');

    // --- Complete test & verdict ---
    // Force completion by setting startedAt to 31 days ago
    final sessionToComplete = notifier.getSession(id)!;
    sessionToComplete.startedAt =
        DateTime.now().subtract(const Duration(days: 31));
    notifier.refreshPrices(id); // triggers _completeTest via _catchUp

    final verdict = notifier.verdictArchive.isNotEmpty
        ? notifier.verdictArchive.first.verdict
        : null;

    print('\n---------- VERDICT ----------');
    if (verdict != null) {
      print('  ${verdict.title}');
      print('  FS Score: ${verdict.fsScore}/100');
      print('  ${verdict.description}');
      if (verdict.hasDiversificationWarning) {
        print('  ⚠ CONCENTRATION WARNING');
      }
      if (verdict.hasAbsoluteShieldBadge) {
        print('  🛡 ABSOLUTE SHIELD BADGE EARNED');
      }
    } else {
      print('  Verdict not available.');
    }

    print('\n========== END ==========\n');
  });
}
