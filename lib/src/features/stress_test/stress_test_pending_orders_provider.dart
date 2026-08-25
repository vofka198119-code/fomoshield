import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/utils/currency_format.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_naming.dart';
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
      .where(
        (o) =>
            o.sessionId == sessionId &&
            o.status == StressTestOrderStatus.pending,
      )
      .toList();

  /// Cash already committed to this session's pending BUY limit orders —
  /// mirrors real Portfolio's OrderNotifier.reservedCashForPortfolio.
  /// Session.cash isn't touched until a limit order actually fills, but it
  /// shouldn't be offered as "available" a second time to a later order
  /// placed while the first is still pending.
  double reservedCashForSession(String sessionId) {
    double reserved = 0;
    for (final o in forSession(sessionId)) {
      if (!o.isBuy) continue;
      reserved += o.limitPrice * o.quantity;
    }
    return reserved;
  }

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

  /// No-ops if the order already filled/cancelled since the caller last
  /// saw it (e.g. an engine tick filled it while a "See all orders" sheet
  /// was open) — otherwise this would silently overwrite a filled order's
  /// status back to cancelled, corrupting its audit trail.
  void cancelOrder(String id) {
    final index = state.indexWhere((o) => o.id == id);
    if (index < 0) return;
    if (state[index].status != StressTestOrderStatus.pending) return;
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
        final shouldFill = order.isBuy
            ? price <= order.limitPrice
            : price >= order.limitPrice;
        if (!shouldFill) continue;

        final result = _ref
            .read(stressTestProvider.notifier)
            .executeTrade(
              session.id,
              order.symbol,
              order.isBuy,
              order.quantity,
              useShares: true,
              tier: _ref.read(subscriptionTierProvider),
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
          final label = session.duration.displayName;
          pushAppNotification(
            _ref.read(notificationsProvider.notifier),
            AppNotification(
              id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
              type: AppNotificationType.limitOrderFilled,
              portfolioKind: NotificationPortfolioKind.stressTest,
              portfolioId: session.id,
              portfolioLabel: 'Market Simulation — $label',
              symbol: order.symbol,
              companyName: stressTestCompanyName(order.symbol),
              title: 'Limit ${order.isBuy ? 'Buy' : 'Sell'} Order Filled',
              detail:
                  '${order.quantity.toStringAsFixed(4)} shares of '
                  '${stressTestCompanyName(order.symbol)} at '
                  '${formatUsd(order.limitPrice)}',
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }
    if (changed) _save();
  }
}

final stressTestPendingOrdersProvider =
    StateNotifierProvider<
      StressTestPendingOrdersNotifier,
      List<StressTestPendingOrder>
    >((ref) {
      final notifier = StressTestPendingOrdersNotifier(ref);
      // Lets the price engine (noise_engine.dart) keep ticking a symbol
      // in the background while a BUY limit order on it is still pending
      // — even before it's in session.holdings — via a callback rather
      // than an import, so stress_test_engine.dart stays unaware of this
      // pending-order system (see stress_test_pending_order.dart's
      // isolation comment).
      ref.read(stressTestProvider.notifier).watchedSymbolsProvider =
          (sessionId) => notifier
              .forSession(sessionId)
              .where((o) => o.isBuy)
              .map((o) => o.symbol)
              .toSet();
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
          .where(
            (o) =>
                o.sessionId == sessionId &&
                o.status == StressTestOrderStatus.pending,
          )
          .toList();
    });
