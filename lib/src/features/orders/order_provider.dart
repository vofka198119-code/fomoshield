// ---------------------------------------------------------------------------
// Order Provider — Riverpod state management for orders
// ---------------------------------------------------------------------------
// - Full CRUD for orders
// - Persistence via SharedPreferences + Supabase sync
// - Auto-execution engine for pending orders when prices update
// - Integration with portfolio: filled orders → transactions
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/user_data_service.dart';
import '../portfolio/portfolio_providers.dart';
import 'order_model.dart';
import 'order_execution_service.dart';

/// Generate a unique order ID (no uuid package dependency)
String _generateOrderId() =>
    'ord_${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';

String _randomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final sb = StringBuffer();
  for (int i = 0; i < length; i++) {
    sb.write(chars[(DateTime.now().microsecondsSinceEpoch + i * 7) % chars.length]);
  }
  return sb.toString();
}

// ---------------------------------------------------------------------------
// Preferences keys
// ---------------------------------------------------------------------------

String _ordersPrefsKey(String? uid) =>
    uid != null ? 'orders_$uid' : 'orders';

// ---------------------------------------------------------------------------
// Order Notifier
// ---------------------------------------------------------------------------

class OrderNotifier extends StateNotifier<List<Order>> {
  final UserDataService _service;
  final String? _userId;
  // Guards against _loadLocal()'s async SharedPreferences read finishing
  // AFTER loadFromSupabase() and clobbering the just-synced server data.
  bool _loadedFromSupabase = false;

  OrderNotifier(this._service, {required this._userId})
      : super([]) {
    _loadLocal();
  }

  // -----------------------------------------------------------------------
  // Persistence
  // -----------------------------------------------------------------------

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (_loadedFromSupabase) return;
    final key = _ordersPrefsKey(_userId);
    final raw = prefs.getString(key);
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    state = list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _ordersPrefsKey(_userId);
    final raw = jsonEncode(state.map((o) => o.toJson()).toList());
    await prefs.setString(key, raw);
  }

  Future<void> _syncToSupabase() async {
    if (_userId == null) return;
    try {
      await _service.saveOrders(
        _userId,
        state.map((o) => o.toJson()).toList(),
      );
    } catch (_) {
      // Non-critical, local state persists
    }
  }

  // -----------------------------------------------------------------------
  // Place order
  // -----------------------------------------------------------------------

  /// Place a new order. For MARKET orders, executes immediately.
  /// Returns the placed (and possibly executed) order.
  Order placeOrder({
    required String portfolioId,
    required String assetSymbol,
    String? companyName,
    required OrderSide side,
    required OrderType type,
    required double quantity,
    required double createdPrice,
    double? limitPrice,
    double? stopPrice,
    MarketSession session = MarketSession.regular,
  }) {
    final order = Order(
      orderId: _generateOrderId(),
      userId: _userId,
      portfolioId: portfolioId,
      assetSymbol: assetSymbol,
      companyName: companyName,
      side: side,
      type: type,
      quantity: quantity,
      createdPrice: createdPrice,
      limitPrice: limitPrice,
      stopPrice: stopPrice,
      session: session,
    );

    // Market orders always execute immediately, regardless of real-world
    // market hours — this is a paper-trading simulator, not a live broker.
    if (type == OrderType.market) {
      final engine = OrderExecutionService();
      final result = engine.evaluateOrder(
        order: order,
        currentPrice: createdPrice,
        session: session,
      );

      _upsertOrder(result.updatedOrder);

      if (result.transaction != null) {
        _applyTransaction(portfolioId, result.transaction!);
      }

      return result.updatedOrder;
    }

    // Limit / Stop / Stop-Limit: add as PENDING
    state = [...state, order];
    _saveLocal();
    _syncToSupabase();
    return order;
  }

  // -----------------------------------------------------------------------
  // Reserved cash (pending BUY orders) — used by order entry to cap how
  // much of the portfolio's cash is still free to commit to a new order.
  // -----------------------------------------------------------------------

  /// Cash already committed to this portfolio's active BUY orders — real
  /// cash isn't deducted until a buy actually fills, but it shouldn't be
  /// offered as "available" for a second order while the first is pending.
  double reservedCashForPortfolio(String portfolioId) {
    double reserved = 0;
    for (final o in state) {
      if (!o.status.isActive || o.portfolioId != portfolioId || o.side != OrderSide.buy) {
        continue;
      }
      final price = o.limitPrice ?? o.stopPrice ?? o.createdPrice;
      reserved += price * o.remainingQuantity;
    }
    return reserved;
  }

  // -----------------------------------------------------------------------
  // Reconcile pending SELL orders against actual held shares — a SELL
  // order (market fill, or another pending order filling) can leave less
  // stock behind than an earlier still-pending SELL order for the same
  // symbol needs. Cancels whichever orders (oldest-first) no longer have
  // enough shares behind them, mirroring a real broker's post-fill check.
  // -----------------------------------------------------------------------

  void reconcileSellOrders({
    required String portfolioId,
    required String symbol,
    required double heldShares,
  }) {
    final candidates = state
        .where((o) =>
            o.status.isActive &&
            o.portfolioId == portfolioId &&
            o.assetSymbol == symbol &&
            o.side == OrderSide.sell)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    double remaining = heldShares;
    final toCancelIds = <String>{};
    for (final order in candidates) {
      if (order.remainingQuantity <= remaining + 0.0001) {
        remaining -= order.remainingQuantity;
      } else {
        toCancelIds.add(order.orderId);
      }
    }
    if (toCancelIds.isEmpty) return;

    state = [
      for (final o in state)
        if (toCancelIds.contains(o.orderId))
          o.copyWith(status: OrderStatus.cancelled)
        else
          o,
    ];
    _saveLocal();
    _syncToSupabase();
  }

  // -----------------------------------------------------------------------
  // Cancel order
  // -----------------------------------------------------------------------

  bool cancelOrder(String orderId) {
    final index = state.indexWhere((o) => o.orderId == orderId);
    if (index < 0) return false;

    final order = state[index];
    if (!order.canCancel) return false;

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(status: OrderStatus.cancelled)
        else
          state[i],
    ];
    _saveLocal();
    _syncToSupabase();
    return true;
  }

  // -----------------------------------------------------------------------
  // Execute pending orders (called when price updates arrive)
  // -----------------------------------------------------------------------

  /// Process all active (PENDING or PARTIALLY_FILLED) orders, each against
  /// its own symbol's current price. [currentPrices] must be keyed by
  /// symbol — a single shared price would apply e.g. one held symbol's
  /// price to every other pending order regardless of what it's actually
  /// for (a real bug this method had before it was ever wired up to a
  /// caller). Orders for symbols missing from [currentPrices] are skipped
  /// (left pending) rather than guessed at.
  /// Returns the list of transactions created.
  List<Transaction> processPendingOrders({
    required Map<String, double> currentPrices,
    required MarketSession session,
  }) {
    final activeOrders = state.where((o) => o.status.isActive).toList();
    if (activeOrders.isEmpty) return [];

    final engine = OrderExecutionService();
    final transactions = <Transaction>[];

    final bySymbol = <String, List<Order>>{};
    for (final order in activeOrders) {
      bySymbol.putIfAbsent(order.assetSymbol, () => []).add(order);
    }

    for (final entry in bySymbol.entries) {
      final price = currentPrices[entry.key];
      if (price == null) continue;

      final result = engine.processPendingOrders(
        pendingOrders: entry.value,
        currentPrice: price,
        session: session,
      );

      for (final execResult in result.results) {
        _upsertOrder(execResult.updatedOrder);
      }

      for (final tx in result.transactions) {
        final portfolioId = _findPortfolioForOrder(tx.symbol);
        if (portfolioId != null) {
          _applyTransaction(portfolioId, tx);
          transactions.add(tx);
        }
      }
    }

    if (transactions.isNotEmpty) {
      _saveLocal();
      _syncToSupabase();
    }
    return transactions;
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  void _upsertOrder(Order updated) {
    final index = state.indexWhere((o) => o.orderId == updated.orderId);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) updated else state[i],
      ];
    } else {
      state = [...state, updated];
    }
  }

  void _applyTransaction(String portfolioId, Transaction tx) {
    // We need access to portfoliosProvider, but since this is a
    // StateNotifier, we use a callback pattern
    _onTransaction?.call(portfolioId, tx);
  }

  /// Callback set externally to connect to portfoliosProvider
  void Function(String portfolioId, Transaction tx)? _onTransaction;

  set onTransaction(void Function(String portfolioId, Transaction tx)? cb) {
    _onTransaction = cb;
  }

  String? _findPortfolioForOrder(String symbol) {
    // Find the first portfolio containing an active order for this symbol
    final matching = state.where((o) =>
        o.assetSymbol == symbol &&
        (o.status == OrderStatus.filled ||
         o.status == OrderStatus.partiallyFilled));
    if (matching.isNotEmpty) return matching.first.portfolioId;
    // Fallback: find by first active order with this symbol
    final active = state.where((o) => o.assetSymbol == symbol && o.status.isActive);
    if (active.isNotEmpty) return active.first.portfolioId;
    return null;
  }

  /// Load orders from Supabase (on login)
  void loadFromSupabase(List<Map<String, dynamic>> jsonList) {
    _loadedFromSupabase = true;
    state = jsonList.map((e) => Order.fromJson(e)).toList();
    _saveLocal();
  }

  /// Clear state on logout
  void clear() {
    state = [];
    // Also clear from prefs
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_ordersPrefsKey(_userId));
    });
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final ordersProvider =
    StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  final service = ref.read(userDataServiceProvider);
  final user = ref.watch(currentUserProvider);
  final notifier = OrderNotifier(service, userId: user?.id);

  // Connect to portfolio: when orders fill, add transactions
  notifier.onTransaction = (portfolioId, tx) {
    // Stamp realized P&L on sells, same avg-cost formula Portfolio.holdings
    // already uses — computed against the portfolio's state *before* this
    // fill is appended, since that's the cost basis the shares were
    // actually sold against.
    var enrichedTx = tx;
    if (tx.type == TransactionType.sell) {
      final preSalePortfolios = ref.read(portfoliosProvider);
      Portfolio? preSalePortfolio;
      for (final p in preSalePortfolios) {
        if (p.id == portfolioId) {
          preSalePortfolio = p;
          break;
        }
      }
      final held = preSalePortfolio?.holdings[tx.symbol];
      if (held != null && (held['shares'] ?? 0) > 0) {
        final avgCost = held['cost']! / held['shares']!;
        enrichedTx = Transaction(
          symbol: tx.symbol,
          type: tx.type,
          shares: tx.shares,
          price: tx.price,
          date: tx.date,
          orderId: tx.orderId,
          realizedPnl: (tx.price - avgCost) * tx.shares,
        );
      }
    }

    ref.read(portfoliosProvider.notifier).addTransaction(portfolioId, enrichedTx);

    // A sell just reduced (or could reduce) held shares — any other
    // pending sell order for the same symbol may no longer have enough
    // shares behind it.
    if (tx.type == TransactionType.sell) {
      final portfolios = ref.read(portfoliosProvider);
      Portfolio? portfolio;
      for (final p in portfolios) {
        if (p.id == portfolioId) {
          portfolio = p;
          break;
        }
      }
      if (portfolio != null) {
        double heldShares = 0;
        for (final t in portfolio.transactions) {
          if (t.symbol != tx.symbol) continue;
          heldShares += t.type == TransactionType.buy ? t.shares : -t.shares;
        }
        notifier.reconcileSellOrders(
          portfolioId: portfolioId,
          symbol: tx.symbol,
          heldShares: heldShares,
        );
      }
    }
  };

  return notifier;
});

/// Provider that returns only active (pending/partial) orders
final activeOrdersProvider = Provider<List<Order>>((ref) {
  final allOrders = ref.watch(ordersProvider);
  return allOrders.where((o) => o.status.isActive).toList();
});

/// Provider that returns filled orders (latest first)
final filledOrdersProvider = Provider<List<Order>>((ref) {
  final allOrders = ref.watch(ordersProvider);
  final filled = allOrders.where((o) => o.status == OrderStatus.filled).toList();
  filled.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return filled;
});
