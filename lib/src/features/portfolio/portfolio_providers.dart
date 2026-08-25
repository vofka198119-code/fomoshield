import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/utils/constants.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/user_data_service.dart';
import 'portfolio_limits_provider.dart';

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
  // Links back to the Order that produced this fill (see order_model.dart /
  // order_execution_service.dart) so a trade-detail screen can show how the
  // trade was executed (market/limit/stop) and its limit price. Null for
  // transactions created before this field existed.
  final String? orderId;
  // Realized P&L on sells, avg-cost matched against holdings at the moment
  // of sale (same formula as Portfolio.holdings below). Null for buys and
  // for transactions created before this field existed.
  final double? realizedPnl;

  const Transaction({
    required this.symbol,
    required this.type,
    required this.shares,
    required this.price,
    required this.date,
    this.orderId,
    this.realizedPnl,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'type': type.name,
    'shares': shares,
    'price': price,
    'date': date.toIso8601String(),
    'orderId': orderId,
    'realizedPnl': realizedPnl,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    symbol: json['symbol'] as String,
    type: TransactionType.values.firstWhere(
      (e) => e.name == (json['type'] as String),
    ),
    shares: (json['shares'] as num).toDouble(),
    price: (json['price'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    orderId: json['orderId'] as String?,
    realizedPnl: (json['realizedPnl'] as num?)?.toDouble(),
  );
}

class Portfolio {
  final String id;
  String name;
  double startingBalance;
  List<Transaction> transactions;
  DateTime createdAt;
  double? goalAmount;
  // When the weekly +$180 premium payout stream last credited this
  // portfolio. Null until the user's first premium check-in — see
  // weekly_payout_provider.dart. Not reset on a tier downgrade, so a
  // returning premium user resumes accruing from where they left off
  // rather than losing the whole history.
  DateTime? lastWeeklyPayoutAt;

  Portfolio({
    required this.id,
    required this.name,
    double? startingBalance,
    List<Transaction>? transactions,
    DateTime? createdAt,
    this.goalAmount,
    this.lastWeeklyPayoutAt,
  }) : startingBalance = startingBalance ?? AppConstants.defaultStartingBalance,
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
        map[t.symbol]!['cost'] = map[t.symbol]!['cost']! + (t.shares * t.price);
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
    'goalAmount': goalAmount,
    'lastWeeklyPayoutAt': lastWeeklyPayoutAt?.toIso8601String(),
  };

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
    id: json['id'] as String,
    name: json['name'] as String,
    startingBalance:
        (json['startingBalance'] as num?)?.toDouble() ??
        AppConstants.defaultStartingBalance,
    transactions:
        (json['transactions'] as List<dynamic>?)
            ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    goalAmount: (json['goalAmount'] as num?)?.toDouble(),
    lastWeeklyPayoutAt: json['lastWeeklyPayoutAt'] != null
        ? DateTime.tryParse(json['lastWeeklyPayoutAt'] as String)
        : null,
  );
}

// ---------------------------------------------------------------------------
// Portfolio State Notifier
// ---------------------------------------------------------------------------

class PortfolioNotifier extends StateNotifier<List<Portfolio>> {
  final UserDataService _supabaseService;
  String? _userId;
  // Starting capital for the auto-created default portfolio — resolved from
  // the caller's subscription tier at construction time (see
  // portfoliosProvider below). Not re-applied to an already-existing
  // portfolio if the tier changes later; only affects a portfolio created
  // fresh by this instance's _load().
  final double _startingCapital;
  // Guards against _load()'s async SharedPreferences read finishing AFTER
  // loadFromSupabase() and clobbering the just-synced server data with an
  // empty/stale local cache (or worse, creating a spurious default portfolio).
  bool _loadedFromSupabase = false;

  PortfolioNotifier(
    this._supabaseService, {
    this._userId,
    required this._startingCapital,
  }) : super([]) {
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
    _loadedFromSupabase = true;
    // Same migration as _load() below — a Supabase-synced account from
    // before "one portfolio for everyone" can still hand back several.
    state = portfolios.length > 1 ? [_oldestOf(portfolios)] : portfolios;
    _saveLocal(); // Cache locally
    if (portfolios.length > 1) _syncToSupabase();
  }

  Portfolio _oldestOf(List<Portfolio> portfolios) =>
      ([...portfolios]..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
          .first;

  String get _storageKey =>
      _userId != null ? 'portfolios_$_userId' : 'portfolios';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_loadedFromSupabase) return;
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
          name: 'Portfolio',
          startingBalance: _startingCapital,
        ),
      ];
      await _saveLocal();
    } else if (state.length > 1) {
      // Migration: an install from before "one portfolio for everyone"
      // may still have several saved locally. Keep only the oldest (was
      // always the free-tier "base" portfolio under the old 1/3-slot
      // system) and persist the trim so the extras don't keep reappearing
      // on every load.
      state = [_oldestOf(state)];
      await _saveLocal();
      _syncToSupabase();
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

  /// Sets (or clears, with `null`) the target value goal for a portfolio.
  void setGoal(String id, double? goal) {
    state = state.map((p) {
      if (p.id == id) p.goalAmount = goal;
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

  /// Credits the weekly premium payout — bumps startingBalance directly
  /// (not a Transaction; this is capital added, not a trade) and advances
  /// the portfolio's own payout clock to [creditedThrough]. See
  /// weekly_payout_provider.dart for the caller that computes [amount] and
  /// [creditedThrough] from elapsed weeks.
  void creditWeeklyPayout(
    String portfolioId,
    double amount,
    DateTime creditedThrough,
  ) {
    state = state.map((p) {
      if (p.id == portfolioId) {
        p.startingBalance += amount;
        p.lastWeeklyPayoutAt = creditedThrough;
      }
      return p;
    }).toList();
    _saveLocal();
    _syncToSupabase();
  }

  /// Starts (or restarts) a portfolio's payout clock without crediting
  /// anything — called the first time a portfolio is seen as premium, so
  /// there's no retroactive credit for time before the user ever had
  /// premium (or before this feature existed).
  void startWeeklyPayoutClock(String portfolioId, DateTime at) {
    state = state.map((p) {
      if (p.id == portfolioId) {
        p.lastWeeklyPayoutAt = at;
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
      final tier = ref.watch(subscriptionTierProvider);
      return PortfolioNotifier(
        service,
        userId: user?.id,
        startingCapital: startingCapitalForTier(tier),
      );
    });

final activePortfolioIdProvider = StateProvider<String?>((ref) => null);

/// Live performance data for a portfolio (prices from Finnhub)
class PortfolioPerformance {
  final String portfolioId;
  final String name;
  final double totalInvested;
  final double cash;
  final double currentValue;

  /// Unrealized P&L — sum of P&L across currently held positions only.
  /// Does NOT include gains/losses already locked in from past sales.
  final double pnl;
  final double pnlPercent;
  final double startingBalance;
  final double? goalAmount;
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
    required this.startingBalance,
    this.goalAmount,
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
    FutureProvider.family<PortfolioPerformance, String>((
      ref,
      portfolioId,
    ) async {
      final portfolios = ref.watch(portfoliosProvider);
      final portfolio = portfolios.firstWhere((p) => p.id == portfolioId);

      final api = ref.read(finnhubServiceProvider);
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
          startingBalance: portfolio.startingBalance,
          goalAmount: portfolio.goalAmount,
          holdings: [],
        );
      }

      // Quotes fetched in parallel (used to be a sequential await-in-loop —
      // one round-trip's latency per holding, stacked). A failed quote falls
      // back to null and is priced at avgCost below, same as before.
      final entries = holdings.entries.toList();
      final quotes = await Future.wait(
        entries.map((entry) async {
          try {
            return await api.quote(entry.key);
          } catch (_) {
            return null;
          }
        }),
      );

      final holdingPerformances = <HoldingPerformance>[];
      double totalCurrentValue = portfolio.cash;

      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final symbol = entry.key;
        final shares = entry.value['shares']!;
        final totalCost = entry.value['cost']!;
        final avgCost = totalCost / shares;

        final quote = quotes[i];
        final currentPrice = quote != null
            ? ((quote['c'] as num?)?.toDouble() ?? avgCost)
            : avgCost;
        final currentValue = shares * currentPrice;
        totalCurrentValue += currentValue;

        holdingPerformances.add(
          HoldingPerformance(
            symbol: symbol,
            shares: shares,
            avgCost: avgCost,
            totalCost: totalCost,
            currentPrice: currentPrice,
            currentValue: currentValue,
            pnl: currentValue - totalCost,
            pnlPercent: totalCost > 0
                ? ((currentValue - totalCost) / totalCost) * 100
                : 0.0,
          ),
        );
      }

      final totalInvested = portfolio.totalInvested;
      // Unrealized P&L — sum of P&L on positions currently held, NOT total
      // account return since start. Selling a position at a gain/loss moves
      // its slice into cash (visible in currentValue/Cash already) but
      // shouldn't move this number — it only tracks what's still open. See
      // 2026-08-07: this used to be `totalCurrentValue - startingBalance`
      // (a combined figure that silently absorbed every past sale's P&L,
      // making it look unchanged — or worse, wrong-direction — right after
      // locking in a gain/loss).
      final pnl = holdingPerformances.fold(0.0, (sum, h) => sum + h.pnl);
      final unrealizedCost = holdingPerformances.fold(
        0.0,
        (sum, h) => sum + h.totalCost,
      );
      final pnlPercent = unrealizedCost > 0
          ? (pnl / unrealizedCost) * 100
          : 0.0;

      return PortfolioPerformance(
        portfolioId: portfolio.id,
        name: portfolio.name,
        totalInvested: totalInvested,
        cash: portfolio.cash,
        currentValue: totalCurrentValue,
        pnl: pnl,
        pnlPercent: pnlPercent,
        startingBalance: portfolio.startingBalance,
        goalAmount: portfolio.goalAmount,
        holdings: holdingPerformances,
      );
    });
