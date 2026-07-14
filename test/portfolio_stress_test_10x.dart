// ---------------------------------------------------------------------------
// Portfolio Stress Test — 10 companies × 1 Month × Full Engine
// ---------------------------------------------------------------------------
// Покупает 10 компаний из разных секторов, запускает месячный стресс-тест,
// совершает сделки во время симуляции, выводит развёрнутый результат.
// ---------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../lib/src/features/stress_test/stress_test_models.dart';
import '../lib/src/features/stress_test/stress_test_engine.dart';

void main() {
  test('10-company portfolio → 1M stress test → full results', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = StressTestNotifier(userId: 'portfolio_test');

    // ── 1. Создать сессию с балансом $100,000 ─────────────────
    const double startingCash = 100000;
    final sessionId = notifier.createSession(
      TestDuration.month1,
      startingCash,
    );
    expect(sessionId, isNotEmpty);

    // ── 2. Купить 10 компаний из разных секторов ───────────────
    // По $8,000 на компанию — $80,000 invested, $20,000 остается на трейды
    const double perAsset = 8000;

    const portfolio = <String, double>{
      'AAPL': 150.0, // Technology
      'JPM':  65.0,  // Finance
      'JNJ':  160.0, // Healthcare
      'KO':   60.0,  // Consumer Staples
      'XOM':  100.0, // Energy
      'PLD':  120.0, // Real Estate
      'GILD': 75.0,  // Biotech
      'CAT':  250.0, // Cyclical
      'META': 300.0, // Technology (social media)
      'V':    200.0, // Finance (payments)
    };

    final fmt = NumberFormat.currency(locale: 'en_US', symbol: r'$');

    print('\n══════════════════════════════════════════════════════════');
    print('  10-COMPANY STRESS PORTFOLIO — SETUP');
    print('══════════════════════════════════════════════════════════');
    print('  Balance: ${fmt.format(startingCash)}');
    print('  Per asset: ${fmt.format(perAsset)}');
    print('  Duration: 1 Month');
    print('──────────────────────────────────────────────────────────────');

    for (final entry in portfolio.entries) {
      final success = await notifier.buyAssetSetup(
        sessionId, entry.key, perAsset, entry.value,
      );
      expect(success, isTrue, reason: 'Failed to buy ${entry.key}');
    }

    var session = notifier.getSession(sessionId)!;
    expect(session.holdings.length, equals(10));
    expect(session.cash, closeTo(20000, 100)); // ~$20k remainder

    print('  Holdings: ${session.holdings.length} assets');
    print('  Remaining cash: ${fmt.format(session.cash)}');
    print('══════════════════════════════════════════════════════════');

    // ── 3. Запустить тест — сгенерировать эпохи ────────────────
    notifier.startTest(sessionId);
    session = notifier.getSession(sessionId)!;
    expect(session.status, equals(StressTestStatus.active));
    expect(session.epochHistory.length, greaterThan(0));

    print('\n  Test started — ${session.epochHistory.length} epochs generated');
    print('  First epoch: ${session.epochHistory.first.scenario.name}');
    print('──────────────────────────────────────────────────────────────');

    // ── 4. Симуляция: 40 тиков ценообразования ─────────────────
    // Каждый тик ≈ 24 часа (epochDuration для 1M). 40 тиков = 40 дней
    // Внутри simulateCurrentPrices могут происходить weekly phase-переходы.
    print('\n══════════════════════════════════════════════════════════');
    print('  SIMULATION — 40 PRICE TICKS + TRADES');
    print('══════════════════════════════════════════════════════════');

    // Торгуем во время симуляции: несколько сделок для реалистичности
    const tradePlan = <(String, bool, double)>[
      // (symbol, isBuy, amount/shares)
      ('AAPL', true,  5000),   // докупили AAPL
      ('KO',   true,  3000),   // докупили защитных
      ('AAPL', false, 5),      // продали часть AAPL
      ('META', true,  4000),   // докупили META
      ('JPM',  false, 10),     // продали часть банков
      ('XOM',  true,  2000),   // докупили энергетику
      ('PLD',  false, 5),      // продали часть недвиж.
      ('CAT',  true,  3000),   // докупили циклич.
      ('V',    false, 3),      // продали часть V
      ('KO',   false, 8),      // продали часть staples
    ];

    double prevValue = startingCash;
    int tradeIdx = 0;

    for (int tick = 1; tick <= 40; tick++) {
      notifier.refreshPrices(sessionId);
      await Future.delayed(const Duration(milliseconds: 10));

      // Каждые 4 тика — сделка
      if (tick % 4 == 0 && tradeIdx < tradePlan.length) {
        final (sym, isBuy, amount) = tradePlan[tradeIdx];
        notifier.executeTrade(
          sessionId, sym, isBuy, amount,
          useShares: !isBuy,
        );
        tradeIdx++;
      }

      session = notifier.getSession(sessionId)!;

      // Каждые 10 тиков — печать прогресса
      if (tick % 10 == 0) {
        final phase = session.devMarketPhase.padRight(12);
        final temp = session.devMarketTemperature.toStringAsFixed(1).padLeft(5);
        final fear = session.devFearIndex.toString().padLeft(3);
        final val = session.totalValue;
        final pnl = session.profitLossPercent;
        final ledSign = pnl >= 0 ? '+' : '';
        final arrow = val >= prevValue ? '▲' : '▼';
        print('  Tick $tick | Phase: $phase | Temp: $temp | Fear: $fear | '
            'Value: ${fmt.format(val)} ($arrow ${ledSign}${pnl.toStringAsFixed(2)}%)');
        prevValue = val;
      }
    }

    // ── 5. Финальный срез до завершения ────────────────────────
    session = notifier.getSession(sessionId)!;
    final finalValue = session.totalValue;
    final pnlPct = session.profitLossPercent;
    final totalTrades = session.trades.length;

    print('\n══════════════════════════════════════════════════════════');
    print('  SIMULATION COMPLETE — 40 TICKS, $totalTrades TRADES');
    print('══════════════════════════════════════════════════════════');
    print('  Final portfolio: ${fmt.format(finalValue)}');
    print('  P&L: ${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%');
    print('  Market phase: ${session.devMarketPhase}');
    print('  Market temp: ${session.devMarketTemperature.toStringAsFixed(1)}');
    print('  Fear index: ${session.devFearIndex}/100');
    print('  Recovery progress: ${session.devRecoveryProgress.toStringAsFixed(1)}%');
    print('  Volatility: ${session.devVolatilityLabel} (×${session.devVolatilityMultiplier.toStringAsFixed(2)})');
    print('──────────────────────────────────────────────────────────────');

    // Поажная разбивка
    print('\n  ── HOLDINGS BREAKDOWN ──');
    for (final h in session.holdings) {
      final entryPrice = session.basePrices[h.symbol] ?? h.entryPrice;
      final currentPrice = session.currentPrices[h.symbol] ?? entryPrice;
      final positionValue = h.shares * currentPrice;
      final change = ((currentPrice - entryPrice) / entryPrice * 100);
      final sign = change >= 0 ? '+' : '';
      final weight = finalValue > 0 ? (positionValue / finalValue * 100) : 0;
      print('  ${h.symbol.padRight(6)} '
          '\$${entryPrice.toStringAsFixed(1)} → '
          '\$${currentPrice.toStringAsFixed(2)} '
          '(${sign}${change.toStringAsFixed(2)}%)  '
          '[${weight.toStringAsFixed(1)}%]  '
          '${h.shares.toStringAsFixed(4)} sh.)');
    }

    print('  ────────────────────────────────────');
    print('  Cash: ${fmt.format(session.cash)}');
    print('  Total: ${fmt.format(finalValue)}');
    print('──────────────────────────────────────────────────────────────');

    // ── 6. Психологический вердикт ─────────────────────────────
    print('\n══════════════════════════════════════════════════════════');
    print('  PSYCHOLOGICAL VERDICT');
    print('══════════════════════════════════════════════════════════');
    final verdict = notifier.calculateVerdict(sessionId);
    print('  Title: ${verdict.title}');
    print('  Type: ${verdict.primaryType.name}');
    print('  FS Score: ${verdict.fsScore}/100');
    print('  Description: ${verdict.description.replaceAll('\n', '\n    ')}');
    if (verdict.hasDiversificationWarning) print('  ⚠️  Diversification warning');
    if (verdict.hasAbsoluteShieldBadge) print('  🛡️  ABSOLUTE SHIELD BADGE');
    print('══════════════════════════════════════════════════════════');

    // ── 7. Удаляем сессию ──────────────────────────────────────
    notifier.deleteSession(sessionId);
    expect(notifier.getSession(sessionId), isNull);

    // ── Проверки (assertions) ──────────────────────────────────
    expect(finalValue, greaterThan(0));
    expect(finalValue, lessThan(500000)); // Разумный потолок для $100k + трейды
    expect(totalTrades, greaterThanOrEqualTo(5)); // минимум половина сделок прошла
    expect(session.holdings.length, greaterThanOrEqualTo(8)); // не всё продали
    expect(session.explanationLog, isNotNull);
    expect(verdict.fsScore, greaterThanOrEqualTo(0));
    expect(verdict.fsScore, lessThanOrEqualTo(100));
  });
}
