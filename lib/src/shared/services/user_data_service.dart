import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../features/portfolio/portfolio_providers.dart';
import '../../features/home/home_providers.dart';
import '../../features/home/widget_order_provider.dart';
import '../../features/orders/order_provider.dart';

// ---------------------------------------------------------------------------
// UserDataService — syncs user data between Supabase and local providers
// ---------------------------------------------------------------------------
// Every user gets a single row in public.user_data with JSONB columns:
//   - portfolios:   JSON array of Portfolio.toJson()
//   - watchlist:    JSON array of ticker strings
//   - widget_order: JSON array of {id, visible}
//   - orders:       JSON array of Order.toJson()
//
// On login:  loadFromSupabase(userId) → populate all providers
// On change: save*() → write to Supabase + fallback to local cache
// On logout: clear all providers
// ---------------------------------------------------------------------------

class UserDataService {
  final SupabaseClient _client;

  UserDataService(this._client);

  // ── Load all data for a user ──────────────────────────────────────

  Future<Map<String, dynamic>> loadAll(String userId) async {
    try {
      final response = await _client
          .from('user_data')
          .select('portfolios, watchlist, widget_order, orders')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return {'portfolios': [], 'watchlist': [], 'widget_order': [], 'orders': []};

      return {
        'portfolios': _decodeJsonList(response['portfolios']),
        'watchlist': _decodeJsonList(response['watchlist']),
        'widget_order': _decodeJsonList(response['widget_order']),
        'orders': _decodeJsonList(response['orders']),
      };
    } catch (e) {
      return {'portfolios': [], 'watchlist': [], 'widget_order': []};
    }
  }

  // ── Save portfolios ───────────────────────────────────────────────

  Future<void> savePortfolios(String userId, List<Portfolio> portfolios) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'portfolios': jsonEncode(portfolios.map((p) => p.toJson()).toList()),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Silent fail — local cache will be used on next load
    }
  }

  // ── Save watchlist ────────────────────────────────────────────────

  Future<void> saveWatchlist(String userId, List<String> symbols) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'watchlist': jsonEncode(symbols),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  // ── Save orders ───────────────────────────────────────────────────

  Future<void> saveOrders(String userId, List<Map<String, dynamic>> orders) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'orders': jsonEncode(orders),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  // ── Save widget order ─────────────────────────────────────────────

  Future<void> saveWidgetOrder(
      String userId, List<HomeWidgetConfig> configs) async {
    try {
      final data = configs
          .map((c) => {'id': c.id, 'visible': c.visible})
          .toList();
      await _client.from('user_data').upsert({
        'id': userId,
        'widget_order': jsonEncode(data),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────

  List<dynamic> _decodeJsonList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded is List ? decoded : [];
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final userDataServiceProvider = Provider<UserDataService>((ref) {
  return UserDataService(SupabaseConfig.client);
});

/// A provider that, when watched, ensures user data is loaded after login.
/// Call this from auth flow to trigger data sync.
final userDataSyncProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final service = ref.read(userDataServiceProvider);
  final data = await service.loadAll(user.id);

  // Load portfolios
  final portfolioList = (data['portfolios'] as List<dynamic>)
      .map((e) => Portfolio.fromJson(e as Map<String, dynamic>))
      .toList();
  if (portfolioList.isNotEmpty) {
    ref.read(portfoliosProvider.notifier).loadFromSupabase(portfolioList);
  }

  // Load watchlist
  final watchlist = (data['watchlist'] as List<dynamic>)
      .map((e) => e.toString())
      .toList();
  if (watchlist.isNotEmpty) {
    ref.read(watchlistSymbolsProvider.notifier).loadFromSupabase(watchlist);
  }

  // Load widget order
  final widgetOrder = (data['widget_order'] as List<dynamic>)
      .map((e) => HomeWidgetConfig(
            id: e['id'] as String,
            visible: e['visible'] as bool,
          ))
      .toList();
  if (widgetOrder.isNotEmpty) {
    ref.read(homeWidgetsProvider.notifier).loadFromSupabase(widgetOrder);
  }

  // Load orders
  final ordersList = data['orders'] as List<dynamic>? ?? [];
  if (ordersList.isNotEmpty) {
    ref.read(ordersProvider.notifier).loadFromSupabase(
          ordersList.cast<Map<String, dynamic>>(),
        );
  }
});
