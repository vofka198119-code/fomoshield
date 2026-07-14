// ---------------------------------------------------------------------------
// Portfolio Math Test — верификация расчётов средней цены, P&L, частичных
// продаж и докупок. Тестирует Portfolio model напрямую (без Finnhub).
// ---------------------------------------------------------------------------
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/features/portfolio/portfolio_providers.dart';

void main() {
  // ── HELPER: создать портфель с балансом и списком транзакций ──
  Portfolio makePortfolio({
    double balance = 10000,
    List<Transaction>? txs,
  }) {
    return Portfolio(
      id: 'test',
      name: 'Test',
      startingBalance: balance,
      transactions: txs ?? [],
    );
  }

  // ── HELPER: купить ──
  Transaction buy(String symbol, double shares, double price) {
    return Transaction(
      symbol: symbol, type: TransactionType.buy,
      shares: shares, price: price, date: DateTime.now(),
    );
  }

  // ── HELPER: продать ──
  Transaction sell(String symbol, double shares, double price) {
    return Transaction(
      symbol: symbol, type: TransactionType.sell,
      shares: shares, price: price, date: DateTime.now(),
    );
  }

  group('1. Средняя цена (avg cost) — покупка', () {
    test('1.1 Простая покупка: 10 AAPL @ 100', () {
      final p = makePortfolio(txs: [buy('AAPL', 10, 100)]);
      final h = p.holdings;
      expect(h['AAPL'], isNotNull);
      expect(h['AAPL']!['shares'], closeTo(10, 0.001));
      expect(h['AAPL']!['cost'], closeTo(1000, 0.001));
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(100, 0.001)); // avg cost
    });

    test('1.2 Докупка: 10 AAPL @ 100 + 5 AAPL @ 150', () {
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),  // cost=1000, shares=10, avg=100
        buy('AAPL', 5, 150),   // cost=750, shares=5, avg=150
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(15, 0.001));
      expect(h['AAPL']!['cost'], closeTo(1750, 0.001));  // 1000 + 750
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(116.667, 0.01)); // weighted avg
    });

    test('1.3 Три покупки по разным ценам (DCA)', () {
      final p = makePortfolio(txs: [
        buy('MSFT', 5, 300),   // cost=1500
        buy('MSFT', 3, 350),   // cost=1050
        buy('MSFT', 2, 280),   // cost=560
      ]);
      final h = p.holdings;
      expect(h['MSFT']!['shares'], closeTo(10, 0.001));
      expect(h['MSFT']!['cost'], closeTo(3110, 0.01));  // 1500+1050+560
      expect(h['MSFT']!['cost']! / h['MSFT']!['shares']!, closeTo(311, 0.01)); // avg = 311
    });
  });

  group('2. Средняя цена (avg cost) — продажа части', () {
    test('2.1 Продажа части не меняет среднюю цену', () {
      // Покупаем 10 @ $100, продаём 4 @ $120
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),   // cost=1000, shares=10, avg=100
        sell('AAPL', 4, 120),   // sell 4, avgCost=100, cost reduces by 4*100=400
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(6, 0.001));       // 10-4=6
      expect(h['AAPL']!['cost'], closeTo(600, 0.001));       // 1000-(4*100)=600
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(100, 0.001)); // avg=100 — НЕ МЕНЯЕТСЯ
    });

    test('2.2 Продажа половины — avg cost не меняется', () {
      final p = makePortfolio(txs: [
        buy('TSLA', 20, 250),  // cost=5000, shares=20
        sell('TSLA', 10, 300), // sell 10 @ avg=250, cost -= 2500
      ]);
      final h = p.holdings;
      expect(h['TSLA']!['shares'], closeTo(10, 0.001));
      expect(h['TSLA']!['cost'], closeTo(2500, 0.001)); // 5000-(10*250)=2500
      expect(h['TSLA']!['cost']! / h['TSLA']!['shares']!, closeTo(250, 0.001)); // avg=250
    });

    test('2.3 Множественные частичные продажи', () {
      final p = makePortfolio(txs: [
        buy('AAPL', 100, 100),  // cost=10000, shares=100, avg=100
        sell('AAPL', 30, 110),  // sell 30 @ avg=100, cost=10000-3000=7000, shares=70
        sell('AAPL', 20, 130),  // sell 20 @ avg=100, cost=7000-2000=5000, shares=50
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(50, 0.001));
      expect(h['AAPL']!['cost'], closeTo(5000, 0.001));
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(100, 0.001)); // avg=100
    });
  });

  group('3. Средняя цена — докупка после продажи', () {
    test('3.1 Купил → продал часть → докупил дороже', () {
      // Сценарий: купил 10 @ $100, продал 4 @ $120, докупил 6 @ $140
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),   // cost=1000, shares=10
        sell('AAPL', 4, 120),   // sell 4 @ avg=100, cost=1000-400=600, shares=6
        buy('AAPL', 6, 140),    // cost=600+840=1440, shares=12
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(12, 0.001));
      expect(h['AAPL']!['cost'], closeTo(1440, 0.001));  // 600 + 6*140
      // avg = 1440/12 = $120 (взвешенная между $100 остатка и $140 докупки)
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(120, 0.01));
    });

    test('3.2 Полная продажа → повторная покупка — новая средняя', () {
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),  // cost=1000
        sell('AAPL', 10, 120), // sell all @ avg=100, cost=1000-1000=0, shares=0
        buy('AAPL', 5, 200),   // cost=0+1000=1000, shares=5
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(5, 0.001));
      expect(h['AAPL']!['cost'], closeTo(1000, 0.001));
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(200, 0.001)); // avg=200 (новая цена)
    });
  });

  group('4. P&L (нереализованная прибыль)', () {
    test('4.1 P&L при росте цены', () {
      // Купили 10 @ $100, текущая цена $150
      final p = makePortfolio(txs: [buy('AAPL', 10, 100)]);
      final h = p.holdings;
      final totalCost = h['AAPL']!['cost']!;      // 1000
      final shares = h['AAPL']!['shares']!;        // 10
      final avgCost = totalCost / shares;           // 100
      final currentPrice = 150.0;
      final currentValue = shares * currentPrice;   // 1500
      final pnl = currentValue - totalCost;          // 500
      final pnlPercent = ((currentValue - totalCost) / totalCost) * 100;  // 50%

      expect(pnl, closeTo(500, 0.01));
      expect(pnlPercent, closeTo(50, 0.01));
      expect(currentValue, closeTo(1500, 0.01));
      expect(avgCost, closeTo(100, 0.01));
    });

    test('4.2 P&L при падении цены (убыток)', () {
      final p = makePortfolio(txs: [buy('AAPL', 10, 100)]);
      final h = p.holdings;
      final totalCost = h['AAPL']!['cost']!;
      final shares = h['AAPL']!['shares']!;

      final currentPrice = 80.0;  // цена упала
      final currentValue = shares * currentPrice;
      final pnl = currentValue - totalCost;
      final pnlPercent = ((currentValue - totalCost) / totalCost) * 100;

      expect(currentValue, closeTo(800, 0.01));
      expect(pnl, closeTo(-200, 0.01));       // убыток $200
      expect(pnlPercent, closeTo(-20, 0.01));  // -20%
    });

    test('4.3 P&L правильный после докупки и роста', () {
      // Купил 5 @ $100, докупил 5 @ $120, текущая цена $140
      final p = makePortfolio(txs: [
        buy('AAPL', 5, 100),   // cost=500
        buy('AAPL', 5, 120),   // cost=600
      ]);
      final h = p.holdings;
      final totalCost = h['AAPL']!['cost']!;     // 1100
      final shares = h['AAPL']!['shares']!;       // 10
      final avgCost = totalCost / shares;          // 110

      final currentPrice = 140.0;
      final currentValue = shares * currentPrice;  // 1400
      final pnl = currentValue - totalCost;         // 300
      final pnlPercent = (pnl / totalCost) * 100;   // 27.27%

      expect(avgCost, closeTo(110, 0.01));
      expect(currentValue, closeTo(1400, 0.01));
      expect(pnl, closeTo(300, 0.01));
      expect(pnlPercent, closeTo(27.27, 0.1));
    });

    test('4.4 P&L правильный после продажи части', () {
      // Купил 10 @ $100, продал 4 @ $120, текущая цена $140
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),   // cost=1000
        sell('AAPL', 4, 120),   // sell 4 @ avg=100, cost=600, shares=6
      ]);
      final h = p.holdings;
      final totalCost = h['AAPL']!['cost']!;     // 600
      final shares = h['AAPL']!['shares']!;       // 6

      final currentPrice = 140.0;
      final currentValue = shares * currentPrice;  // 840
      final pnl = currentValue - totalCost;         // 240
      final pnlPercent = (pnl / totalCost) * 100;   // 40%

      expect(totalCost, closeTo(600, 0.01));
      expect(shares, closeTo(6, 0.001));
      expect(currentValue, closeTo(840, 0.01));
      expect(pnl, closeTo(240, 0.01));
      expect(pnlPercent, closeTo(40, 0.01));
    });
  });

  group('5. Portfolio-level cash и totalInvested', () {
    test('5.1 Cash уменьшается после покупки', () {
      final p = makePortfolio(balance: 10000, txs: [
        buy('AAPL', 10, 100),  // -1000
      ]);
      expect(p.cash, closeTo(9000, 0.01));
      expect(p.totalInvested, closeTo(1000, 0.01));
    });

    test('5.2 Cash увеличивается после продажи', () {
      final p = makePortfolio(balance: 10000, txs: [
        buy('AAPL', 10, 100),  // -1000
        sell('AAPL', 4, 120),  // +480 (sell price)
      ]);
      expect(p.cash, closeTo(9480, 0.01));  // 10000 - 1000 + 480
      expect(p.totalInvested, closeTo(520, 0.01));  // 1000 - 4*120 = 520
    });

    test('5.3 totalInvested может быть отрицательным (продали больше чем купили)', () {
      final p = makePortfolio(balance: 10000, txs: [
        buy('AAPL', 10, 100),  // +1000
        sell('AAPL', 10, 150), // -1500 (totalInvested уменьшается)
      ]);
      // totalInvested = 1000 - 1500 = -500
      expect(p.totalInvested, closeTo(-500, 0.01));
      // Но holdings пустые (shares=0 удалены)
      expect(p.holdings.length, equals(0));
    });

    test('5.4 Комплексный сценарий: несколько активов', () {
      final p = makePortfolio(balance: 50000, txs: [
        buy('AAPL', 20, 150),    // -3000
        buy('MSFT', 10, 350),    // -3500
        buy('GOOGL', 5, 140),    // -700
        sell('AAPL', 5, 170),    // +850
        buy('NVDA', 8, 800),     // -6400
        sell('MSFT', 3, 380),    // +1140
      ]);

      // cash: 50000 -3000 -3500 -700 +850 -6400 +1140 = 38390
      expect(p.cash, closeTo(38390, 0.01));

      // totalInvested: 3000+3500+700+6400 - (850+1140) = 13600 - 1990 = 11610
      expect(p.totalInvested, closeTo(11610, 0.01));

      // AAPL: купил 20, продал 5 = 15 shares
      final aapl = p.holdings['AAPL']!;
      expect(aapl['shares'], closeTo(15, 0.001));
      expect(aapl['cost'], closeTo(2250, 0.01));  // 3000-(5*150)=2250

      // MSFT: купил 10, продал 3 = 7 shares
      final msft = p.holdings['MSFT']!;
      expect(msft['shares'], closeTo(7, 0.001));
      expect(msft['cost'], closeTo(2450, 0.01));  // 3500-(3*350)=2450

      // GOOGL: 5 shares
      final goog = p.holdings['GOOGL']!;
      expect(goog['shares'], closeTo(5, 0.001));
      expect(goog['cost'], closeTo(700, 0.01));

      // NVDA: 8 shares
      final nvda = p.holdings['NVDA']!;
      expect(nvda['shares'], closeTo(8, 0.001));
      expect(nvda['cost'], closeTo(6400, 0.01));

      // Всего холдингов: 4 (AAPL, MSFT, GOOGL, NVDA)
      expect(p.holdings.length, equals(4));
    });
  });

  group('6. Краевые случаи', () {
    test('6.1 Продажа всех акций удаляет из holdings', () {
      final p = makePortfolio(txs: [
        buy('AAPL', 10, 100),
        sell('AAPL', 10, 150),
      ]);
      expect(p.holdings.containsKey('AAPL'), isFalse);
      expect(p.holdings.length, equals(0));
    });

    test('6.2 Продажа без покупок — не падает', () {
      final p = makePortfolio(txs: [
        sell('AAPL', 5, 100),
      ]);
      // shares=0-5=-5, cost=0-(0*5)=0, но holdings удаляет где shares<=0
      expect(p.holdings.length, equals(0));
      expect(p.cash, closeTo(10000 + 500, 0.01));  // начальный +500
    });

    test('6.3 Пустой портфель', () {
      final p = makePortfolio();
      expect(p.holdings.length, equals(0));
      expect(p.cash, closeTo(10000, 0.01));
      expect(p.totalInvested, closeTo(0, 0.01));
      expect(p.symbols.length, equals(0));
    });

    test('6.4 Дробные акции', () {
      final p = makePortfolio(txs: [
        buy('AAPL', 0.5, 200),    // cost=100
        buy('AAPL', 0.25, 210),   // cost=52.5
        sell('AAPL', 0.1, 220),   // sell @ avg=203.33..., cost=152.5-(0.1*203.33...)=132.17
      ]);
      final h = p.holdings;
      expect(h['AAPL']!['shares'], closeTo(0.65, 0.001));  // 0.5+0.25-0.1
      expect(h['AAPL']!['cost']! / h['AAPL']!['shares']!, closeTo(203.33, 0.01));
    });
  });
}
