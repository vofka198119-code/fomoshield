// ---------------------------------------------------------------------------
// Portfolio Chart Data Providers
// ---------------------------------------------------------------------------
// Generates historical portfolio value data from transactions + current state.
// Stores snapshots locally so portfolio works even when app is closed.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../stress_test/stress_test_engine.dart'; // reuse ChartDataPoint
import 'portfolio_providers.dart';

/// Key for local storage
const _kSnapshotsKey = 'portfolio_value_snapshots';

/// A value snapshot at a point in time
class PortfolioValueSnapshot {
  final DateTime time;
  final double value;

  const PortfolioValueSnapshot({required this.time, required this.value});

  Map<String, dynamic> toJson() => {
        'time': time.millisecondsSinceEpoch,
        'value': value,
      };

  factory PortfolioValueSnapshot.fromJson(Map<String, dynamic> json) =>
      PortfolioValueSnapshot(
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
        value: (json['value'] as num).toDouble(),
      );
}

/// Provides chart data points for a portfolio's historical value.
/// Builds from: stored snapshots + transaction history + current value.
final portfolioChartDataProvider =
    FutureProvider.family<List<ChartDataPoint>, String>(
        (ref, portfolioId) async {
  final portfolios = ref.watch(portfoliosProvider);
  final portfolio = portfolios.firstWhere(
    (p) => p.id == portfolioId,
    orElse: () => throw Exception('Portfolio not found'),
  );

  // 1. Load stored snapshots
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('${_kSnapshotsKey}_$portfolioId');
  final snapshots = <PortfolioValueSnapshot>[];
  if (stored != null) {
    final list = jsonDecode(stored) as List;
    for (final item in list) {
      snapshots.add(PortfolioValueSnapshot.fromJson(item as Map<String, dynamic>));
    }
  }

  // 2. Build timeline from transactions
  final txPoints = <ChartDataPoint>[];
  if (portfolio.transactions.isNotEmpty) {
    // Sort transactions by date
    final sorted = List.from(portfolio.transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double runningCash = portfolio.startingBalance;
    final runningHoldings = <String, double>{};

    for (final tx in sorted) {
      if (tx.type == TransactionType.buy) {
        runningCash -= tx.shares * tx.price;
        runningHoldings[tx.symbol] =
            (runningHoldings[tx.symbol] ?? 0) + tx.shares;
      } else {
        runningCash += tx.shares * tx.price;
        final cur = (runningHoldings[tx.symbol] ?? 0) - tx.shares;
        if (cur <= 0) {
          runningHoldings.remove(tx.symbol);
        } else {
          runningHoldings[tx.symbol] = cur;
        }
      }

      // Total value = cash + holdings valued at tx price (approximation)
      double holdingsValue = 0;
      for (final h in runningHoldings.entries) {
        final symTx = sorted
            .where((t) => t.symbol == h.key)
            .toList();
        final avgPrice = symTx.isNotEmpty
            ? symTx.fold<double>(0, (sum, t) => sum + t.price) /
                symTx.length
            : tx.price;
        holdingsValue += h.value * avgPrice;
      }

      txPoints.add(ChartDataPoint(tx.date, runningCash + holdingsValue));
    }
  }

  // 3. Add current value as the latest point
  final performance =
      ref.read(portfolioPerformanceProvider(portfolioId)).maybeWhen(
            data: (d) => d,
            orElse: () => null,
          );
  if (performance != null) {
    txPoints.add(ChartDataPoint(DateTime.now(), performance.currentValue));
  }

  // 4. Merge snapshots + transaction points, deduplicate by time
  final allPoints = <ChartDataPoint>[
    ...snapshots
        .map((s) => ChartDataPoint(s.time, s.value)),
    ...txPoints,
  ];

  // Remove duplicates (keep latest value for same second)
  final seen = <int>{};
  final merged = <ChartDataPoint>[];
  for (final p in allPoints) {
    final key = p.time.millisecondsSinceEpoch ~/ 1000;
    if (seen.add(key)) {
      merged.add(p);
    }
  }

  merged.sort((a, b) => a.time.compareTo(b.time));

  // 5. Save current snapshot for next time
  if (performance != null) {
    snapshots.add(PortfolioValueSnapshot(
      time: DateTime.now(),
      value: performance.currentValue,
    ));
    // Keep last 500 snapshots
    if (snapshots.length > 500) {
      snapshots.removeRange(0, snapshots.length - 500);
    }
    await prefs.setString(
      '${_kSnapshotsKey}_$portfolioId',
      jsonEncode(snapshots.map((s) => s.toJson()).toList()),
    );
  }

  if (merged.isEmpty) {
    // Fallback: single point with current value
    return [
      ChartDataPoint(
        DateTime.now().subtract(const Duration(days: 1)),
        performance?.currentValue ?? portfolio.startingBalance,
      ),
      ChartDataPoint(
        DateTime.now(),
        performance?.currentValue ?? portfolio.startingBalance,
      ),
    ];
  }

  return merged;
});
