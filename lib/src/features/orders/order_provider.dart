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

  OrderNotifier(this._service, {required String? userId})
      : _userId = userId,
        super([]) {
    _loadLocal();
  }

  // -----------------------------------------------------------------------
  // Persistence
  // -----------------------------------------------------------------------

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
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
      side: side,
      type: type,
      quantity: quantity,
      createdPrice: createdPrice,
      limitPrice: limitPrice,
      stopPrice: stopPrice,
      session: session,
    );

    // For market orders:
    //   - If market is open (regular/pre/after-hours): execute immediately
    //   - If market is closed (weekend/night): add as PENDING, will execute
    //     when the market opens via processPendingOrders()
    if (type == OrderType.market) {
      if (session == MarketSession.closed) {
        state = [...state, order];
        _saveLocal();
        _syncToSupabase();
        return order;
      }

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

  /// Process all active (PENDING or PARTIALLY_FILLED) orders.
  /// Returns the list of transactions created.
  List<Transaction> processPendingOrders({
    required double currentPrice,
    required MarketSession session,
  }) {
    final activeOrders = state.where((o) => o.status.isActive).toList();
    if (activeOrders.isEmpty) return [];

    final engine = OrderExecutionService();
    final result = engine.processPendingOrders(
      pendingOrders: activeOrders,
      currentPrice: currentPrice,
      session: session,
    );

    // Apply all order updates
    for (final execResult in result.results) {
      _upsertOrder(execResult.updatedOrder);
    }

    // Apply all transactions to their respective portfolios
    final transactions = <Transaction>[];
    for (final tx in result.transactions) {
      final portfolioId = _findPortfolioForOrder(tx.symbol);
      if (portfolioId != null) {
        _applyTransaction(portfolioId, tx);
        transactions.add(tx);
      }
    }

    _saveLocal();
    _syncToSupabase();
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
    ref.read(portfoliosProvider.notifier).addTransaction(portfolioId, tx);
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
