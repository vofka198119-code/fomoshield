import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/utils/constants.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum TransactionType { buy, sell }

class Transaction {
  final String symbol;
  final TransactionType type;
  final double shares;
  final double price;
  final DateTime date;

  const Transaction({
    required this.symbol,
    required this.type,
    required this.shares,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'type': type.name,
        'shares': shares,
        'price': price,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        symbol: json['symbol'] as String,
        type: TransactionType.values.firstWhere(
            (e) => e.name == (json['type'] as String)),
        shares: (json['shares'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}

class Portfolio {
  final String id;
  String name;
  double startingBalance;
  List<Transaction> transactions;
  DateTime createdAt;

  Portfolio({
    required this.id,
    required this.name,
    double? startingBalance,
    List<Transaction>? transactions,
    DateTime? createdAt,
  })  : startingBalance = startingBalance ?? AppConstants.defaultStartingBalance,
        transactions = transactions ?? [],
        createdAt = createdAt ?? DateTime.now();

  // ---- Computed ----

  double get totalInvested {
    double total = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.buy) {
        total += t.shares * t.price;
      } else {
        total -= t.shares * t.price;
      }
    }
    return total;
  }

  double get cash {
    double c = startingBalance;
    for (final t in transactions) {
      if (t.type == TransactionType.buy) {
        c -= t.shares * t.price;
      } else {
        c += t.shares * t.price;
      }
    }
    return c;
  }

  Map<String, Map<String, double>> get holdings {
    final map = <String, Map<String, double>>{};
    for (final t in transactions) {
      if (t.type == TransactionType.buy) {
        map.putIfAbsent(t.symbol, () => {'shares': 0, 'cost': 0});
        map[t.symbol]!['shares'] = map[t.symbol]!['shares']! + t.shares;
        map[t.symbol]!['cost'] =
            map[t.symbol]!['cost']! + (t.shares * t.price);
      } else {
        map.putIfAbsent(t.symbol, () => {'shares': 0, 'cost': 0});
        map[t.symbol]!['shares'] = map[t.symbol]!['shares']! - t.shares;
        map[t.symbol]!['cost'] =
            map[t.symbol]!['cost']! - (t.shares * t.price);
      }
    }
    // Remove zero-share holdings
    map.removeWhere((_, v) => (v['shares'] ?? 0) <= 0);
    return map;
  }

  List<String> get symbols => holdings.keys.toList();

  // ---- Serialization ----

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startingBalance': startingBalance,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
        id: json['id'] as String,
        name: json['name'] as String,
        startingBalance: (json['startingBalance'] as num?)?.toDouble() ??
            AppConstants.defaultStartingBalance,
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((e) =>
                    Transaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

// ---------------------------------------------------------------------------
// Portfolio State Notifier
// ---------------------------------------------------------------------------

class PortfolioNotifier extends StateNotifier<List<Portfolio>> {
  PortfolioNotifier() : super([]) {
    _load();
  }

  static const _storageKey = 'portfolios';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => Portfolio.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
    if (state.isEmpty) {
      state = [
        Portfolio(
          id: 'default_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Main Portfolio',
        ),
      ];
      await _save();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  void addPortfolio(String name) {
    state = [
      ...state,
      Portfolio(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
      ),
    ];
    _save();
  }

  void renamePortfolio(String id, String newName) {
    state = state.map((p) {
      if (p.id == id) p.name = newName;
      return p;
    }).toList();
    _save();
  }

  void deletePortfolio(String id) {
    state = state.where((p) => p.id != id).toList();
    _save();
  }

  void addTransaction(String portfolioId, Transaction tx) {
    state = state.map((p) {
      if (p.id == portfolioId) {
        p.transactions = [...p.transactions, tx];
      }
      return p;
    }).toList();
    _save();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final portfoliosProvider =
    StateNotifierProvider<PortfolioNotifier, List<Portfolio>>((ref) {
  return PortfolioNotifier();
});

final activePortfolioIdProvider = StateProvider<String?>((ref) => null);

/// Live performance data for a portfolio (prices from Finnhub)
class PortfolioPerformance {
  final String portfolioId;
  final String name;
  final double totalInvested;
  final double cash;
  final double currentValue;
  final double pnl;
  final double pnlPercent;
  final List<HoldingPerformance> holdings;
  final bool isLoading;
  final String? error;

  PortfolioPerformance({
    required this.portfolioId,
    required this.name,
    required this.totalInvested,
    required this.cash,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
    required this.holdings,
    this.isLoading = false,
    this.error,
  });
}

class HoldingPerformance {
  final String symbol;
  final double shares;
  final double avgCost;
  final double totalCost;
  final double currentPrice;
  final double currentValue;
  final double pnl;
  final double pnlPercent;

  HoldingPerformance({
    required this.symbol,
    required this.shares,
    required this.avgCost,
    required this.totalCost,
    required this.currentPrice,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
  });
}

final portfolioPerformanceProvider =
    FutureProvider.family<PortfolioPerformance, String>((ref, portfolioId) async {
  final portfolios = ref.watch(portfoliosProvider);
  final portfolio = portfolios.firstWhere((p) => p.id == portfolioId);

  final api = FinnhubService();
  final holdings = portfolio.holdings;

  if (holdings.isEmpty) {
    return PortfolioPerformance(
      portfolioId: portfolio.id,
      name: portfolio.name,
      totalInvested: 0,
      cash: portfolio.cash,
      currentValue: portfolio.cash,
      pnl: 0,
      pnlPercent: 0,
      holdings: [],
    );
  }

  final holdingPerformances = <HoldingPerformance>[];
  double totalCurrentValue = portfolio.cash;

  for (final entry in holdings.entries) {
    final symbol = entry.key;
    final shares = entry.value['shares']!;
    final totalCost = entry.value['cost']!;
    final avgCost = totalCost / shares;

    try {
      final quote = await api.quote(symbol);
      final currentPrice = (quote['c'] as num?)?.toDouble() ?? avgCost;
      final currentValue = shares * currentPrice;
      totalCurrentValue += currentValue;

      holdingPerformances.add(HoldingPerformance(
        symbol: symbol,
        shares: shares,
        avgCost: avgCost,
        totalCost: totalCost,
        currentPrice: currentPrice,
        currentValue: currentValue,
        pnl: currentValue - totalCost,
        pnlPercent: ((currentValue - totalCost) / totalCost) * 100,
      ));
    } catch (_) {
      // If quote fails, use avgCost as current price
      totalCurrentValue += totalCost;
      holdingPerformances.add(HoldingPerformance(
        symbol: symbol,
        shares: shares,
        avgCost: avgCost,
        totalCost: totalCost,
        currentPrice: avgCost,
        currentValue: totalCost,
        pnl: 0,
        pnlPercent: 0,
      ));
    }
  }

  final totalInvested = portfolio.totalInvested;
  final pnl = totalCurrentValue - portfolio.startingBalance;
  final pnlPercent =
      portfolio.startingBalance > 0 ? (pnl / portfolio.startingBalance) * 100 : 0.0;

  return PortfolioPerformance(
    portfolioId: portfolio.id,
    name: portfolio.name,
    totalInvested: totalInvested,
    cash: portfolio.cash,
    currentValue: totalCurrentValue,
    pnl: pnl,
    pnlPercent: pnlPercent,
    holdings: holdingPerformances,
  );
});
