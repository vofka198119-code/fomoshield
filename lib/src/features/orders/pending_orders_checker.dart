import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/finnhub_service.dart';
import 'order_model.dart';
import 'order_provider.dart';

// ---------------------------------------------------------------------------
// Pending Orders Checker — fills any active limit/stop/stop-limit orders
// that have crossed their trigger price since they were last checked.
//
// Cheap by design: only fetches quotes for symbols that actually have a
// pending order (typically none or a handful), reusing
// FinnhubService.quote()'s existing backend-proxy + cache — no direct
// Finnhub calls, and no polling of its own beyond wherever this is
// explicitly called from (app startup + Portfolio screen's 5-min timer).
// ---------------------------------------------------------------------------

Future<void> checkPendingOrders(WidgetRef ref) async {
  final activeOrders = ref.read(activeOrdersProvider);
  if (activeOrders.isEmpty) return;

  final symbols = activeOrders.map((o) => o.assetSymbol).toSet();
  final api = ref.read(finnhubServiceProvider);
  final prices = <String, double>{};

  for (final symbol in symbols) {
    try {
      final quote = await api.quote(symbol);
      final price = (quote['c'] as num?)?.toDouble();
      if (price != null && price > 0) prices[symbol] = price;
    } catch (_) {
      // Skip this symbol this round — will retry on the next check.
    }
  }

  if (prices.isEmpty) return;

  ref
      .read(ordersProvider.notifier)
      .processPendingOrders(
        currentPrices: prices,
        session: currentMarketSession(),
      );
}
