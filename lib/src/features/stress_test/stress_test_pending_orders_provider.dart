import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_pending_order.dart';

// ---------------------------------------------------------------------------
// Stress Test Pending Orders — Riverpod state, own SharedPreferences key.
// Listens to stressTestProvider (read-only) and calls the real
// StressTestNotifier.executeTrade to fill orders — never mutates
// StressTestSession fields directly.
// ---------------------------------------------------------------------------

const String _prefsKey = 'stress_test_pending_orders';

class StressTestPendingOrdersNotifier
    extends StateNotifier<List<StressTestPendingOrder>> {
  final Ref _ref;

  StressTestPendingOrdersNotifier(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    state = list
        .map((e) => StressTestPendingOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((o) => o.toJson()).toList()),
    );
  }

  List<StressTestPendingOrder> forSession(String sessionId) => state
      .where((o) =>
          o.sessionId == sessionId && o.status == StressTestOrderStatus.pending)
      .toList();

  StressTestPendingOrder placeLimitOrder({
    required String sessionId,
    required String symbol,
    required bool isBuy,
    required double quantity,
    required double limitPrice,
  }) {
    final order = StressTestPendingOrder(
      id: 'sto_${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sessionId,
      symbol: symbol,
      isBuy: isBuy,
      quantity: quantity,
      limitPrice: limitPrice,
      createdAt: DateTime.now(),
    );
    state = [...state, order];
    _save();
    return order;
  }

  void cancelOrder(String id) {
    final index = state.indexWhere((o) => o.id == id);
    if (index < 0) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(status: StressTestOrderStatus.cancelled)
        else
          state[i],
    ];
    _save();
  }

  /// Checks every session's pending orders against its current simulated
  /// prices and fills whichever have crossed their limit, via the
  /// existing executeTrade (unmodified engine logic). Orders that fail to
  /// fill (e.g. cash spent elsewhere since placing) stay pending and are
  /// retried on the next call.
  void _checkAllSessions(List<StressTestSession> sessions) {
    var changed = false;
    for (final session in sessions) {
      final pending = forSession(session.id);
      if (pending.isEmpty) continue;

      for (final order in pending) {
        final price = session.currentPrices[order.symbol];
        if (price == null) continue;
        final shouldFill =
            order.isBuy ? price <= order.limitPrice : price >= order.limitPrice;
        if (!shouldFill) continue;

        final result = _ref.read(stressTestProvider.notifier).executeTrade(
              session.id,
              order.symbol,
              order.isBuy,
              order.quantity,
              useShares: true,
            );
        if (result.success) {
          final idx = state.indexWhere((o) => o.id == order.id);
          if (idx >= 0) {
            state = [
              for (int i = 0; i < state.length; i++)
                if (i == idx)
                  state[i].copyWith(status: StressTestOrderStatus.filled)
                else
                  state[i],
            ];
            changed = true;
          }
        }
      }
    }
    if (changed) _save();
  }
}

final stressTestPendingOrdersProvider = StateNotifierProvider<
    StressTestPendingOrdersNotifier, List<StressTestPendingOrder>>((ref) {
  final notifier = StressTestPendingOrdersNotifier(ref);
  // Reacts to every stressTestProvider state change (each 20s price tick
  // included) without needing to touch the existing timer that drives it
  // (stress_test_screen.dart) — deferred to a microtask so a fill's own
  // state write never runs synchronously inside this listener callback.
  ref.listen<List<StressTestSession>>(stressTestProvider, (previous, next) {
    scheduleMicrotask(() => notifier._checkAllSessions(next));
  });
  return notifier;
});

/// This session's own pending (not yet filled/cancelled) limit orders.
final stressTestSessionPendingOrdersProvider =
    Provider.family<List<StressTestPendingOrder>, String>((ref, sessionId) {
  final all = ref.watch(stressTestPendingOrdersProvider);
  return all
      .where((o) =>
          o.sessionId == sessionId && o.status == StressTestOrderStatus.pending)
      .toList();
});
