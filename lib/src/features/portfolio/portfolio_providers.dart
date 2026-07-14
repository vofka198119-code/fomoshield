import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/utils/constants.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/user_data_service.dart';

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
        final curShares = map[t.symbol]!['shares']!;
        final curCost = map[t.symbol]!['cost']!;
        final avgCost = curShares > 0 ? curCost / curShares : 0;
        map[t.symbol]!['shares'] = curShares - t.shares;
        // Reduce cost by avg cost × shares sold (not sell price)
        map[t.symbol]!['cost'] = curCost - (avgCost * t.shares);
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
  final UserDataService _supabaseService;
  String? _userId;

  PortfolioNotifier(this._supabaseService, {this._userId})
      : super([]) {
    _load();
  }

  /// Set user ID to enable Supabase sync + re-scope local cache.
  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  /// Load portfolios from Supabase data (replaces local).
  void loadFromSupabase(List<Portfolio> portfolios) {
    if (portfolios.isEmpty) return;
    state = portfolios;
    _saveLocal(); // Cache locally
  }

  String get _storageKey =>
      _userId != null ? 'portfolios_$_userId' : 'portfolios';

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
      await _saveLocal();
    }
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> _syncToSupabase() async {
    final uid = _userId;
    if (uid != null) {
      await _supabaseService.savePortfolios(uid, state);
    }
  }

  void addPortfolio(String name, {double? startingBalance}) {
    state = [
      ...state,
      Portfolio(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        startingBalance: startingBalance,
      ),
    ];
    _saveLocal();
    _syncToSupabase();
  }

  void renamePortfolio(String id, String newName) {
    state = state.map((p) {
      if (p.id == id) p.name = newName;
      return p;
    }).toList();
    _saveLocal();
    _syncToSupabase();
  }

  void deletePortfolio(String id) {
    state = state.where((p) => p.id != id).toList();
    _saveLocal();
    _syncToSupabase();
  }

  void resetPortfolio(String id) {
    state = state.map((p) {
      if (p.id == id) {
        p.transactions = [];
        // Keep original startingBalance (tier-based amount)
      }
      return p;
    }).toList();
    _saveLocal();
    _syncToSupabase();
  }

  void addTransaction(String portfolioId, Transaction tx) {
    state = state.map((p) {
      if (p.id == portfolioId) {
        p.transactions = [...p.transactions, tx];
      }
      return p;
    }).toList();
    _saveLocal();
    _syncToSupabase();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final portfoliosProvider =
    StateNotifierProvider<PortfolioNotifier, List<Portfolio>>((ref) {
  final service = ref.read(userDataServiceProvider);
  final user = ref.watch(currentUserProvider);
  return PortfolioNotifier(service, userId: user?.id);
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
