import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../features/portfolio/portfolio_providers.dart';
import '../../features/portfolio/portfolio_value_history.dart';
import '../../features/home/home_providers.dart';
import '../../features/home/widget_order_provider.dart';
import '../../features/orders/order_provider.dart';
import '../../features/stress_test/stress_test_engine.dart';
import '../../features/stress_test/stress_test_funding_sync.dart';

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

/// Stand-in payload for the two answers that carry no information
/// ([UserDataSource.missing] and [UserDataSource.error]). Nothing should read
/// it — check [UserDataSnapshot.isAuthoritative] first — but it keeps every
/// key present so a careless caller gets an empty list rather than a crash.
const Map<String, dynamic> _noData = {
  'portfolios': <dynamic>[],
  'watchlist': <dynamic>[],
  'widget_order': <dynamic>[],
  'orders': <dynamic>[],
  'stress_test_sessions': <dynamic>[],
  'stress_test_verdicts': <dynamic>[],
  'stress_test_funding': <String, dynamic>{},
  'portfolio_value_history': <dynamic>[],
};

/// Where a [UserDataService.loadAll] answer came from.
///
/// These three used to be indistinguishable — every one of them returned the
/// same empty lists — and two opposite bugs grew out of that (both found
/// 2026-10-06):
///
///  * To keep a failed read from wiping anything, the restore ignored empty
///    lists. So a deletion made on one install never reached another: an
///    admin "Reset all stress tests" cleared the server, the other install
///    kept showing its stale verdicts, and its next significant action
///    pushed them straight back up, undoing the reset.
///  * The watchlist was deliberately exempted from that guard so deletions
///    WOULD propagate — which meant a failed read at sign-in silently
///    emptied the watchlist instead, locally and then on the server.
///
/// Knowing which case we are in fixes both: only [row] is authoritative, and
/// only then is an empty list a real answer rather than an absence of one.
enum UserDataSource {
  /// The user's row was read successfully. Its contents are the truth,
  /// including the columns that came back empty.
  row,

  /// No row exists for this user yet. Says nothing about what they have
  /// locally — a first sign-in must not erase it.
  missing,

  /// The read failed (offline, timeout, Supabase error). Tells us nothing
  /// at all; every local provider must be left exactly as it is.
  error,
}

class UserDataSnapshot {
  final UserDataSource source;
  final Map<String, dynamic> data;

  const UserDataSnapshot(this.source, this.data);

  /// Whether an empty list in [data] means "the user has none of these"
  /// rather than "we could not find out".
  bool get isAuthoritative => source == UserDataSource.row;
}

class UserDataService {
  final SupabaseClient _client;

  UserDataService(this._client);

  // ── Load all data for a user ──────────────────────────────────────

  Future<UserDataSnapshot> loadAll(String userId) async {
    try {
      final response = await _client
          .from('user_data')
          .select(
            'portfolios, watchlist, widget_order, orders, stress_test_sessions, stress_test_verdicts, stress_test_funding, portfolio_value_history',
          )
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return const UserDataSnapshot(UserDataSource.missing, _noData);
      }

      return UserDataSnapshot(UserDataSource.row, {
        'portfolios': _decodeJsonList(response['portfolios']),
        'watchlist': _decodeJsonList(response['watchlist']),
        'widget_order': _decodeJsonList(response['widget_order']),
        'orders': _decodeJsonList(response['orders']),
        'stress_test_sessions': _decodeJsonList(response['stress_test_sessions']),
        'stress_test_verdicts': _decodeJsonList(response['stress_test_verdicts']),
        'stress_test_funding': _decodeJsonMap(response['stress_test_funding']),
        'portfolio_value_history': _decodeJsonList(
          response['portfolio_value_history'],
        ),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.loadAll($userId) failed: $e');
      return const UserDataSnapshot(UserDataSource.error, _noData);
    }
  }

  // ── Save portfolios ───────────────────────────────────────────────

  Future<void> savePortfolios(String userId, List<Portfolio> portfolios) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'portfolios': portfolios.map((p) => p.toJson()).toList(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      // Best-effort sync — local cache will be used on next load, but log
      // it so a real outage leaves a trace instead of silent cross-device
      // desync with nothing to debug from (same pattern as loadAll above).
      debugPrint('🔄 userDataService.savePortfolios($userId) failed: $e');
    }
  }

  // ── Save watchlist ────────────────────────────────────────────────

  Future<void> saveWatchlist(String userId, List<String> symbols) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'watchlist': symbols,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveWatchlist($userId) failed: $e');
    }
  }

  // ── Save orders ───────────────────────────────────────────────────

  Future<void> saveOrders(String userId, List<Map<String, dynamic>> orders) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'orders': orders,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveOrders($userId) failed: $e');
    }
  }

  // ── Save stress-test sessions ─────────────────────────────────────
  // Pushed only on significant events (trade, start, complete, delete),
  // not on every ~20s simulation tick — see stress_test_engine.dart.

  Future<void> saveStressTestSessions(
      String userId, List<Map<String, dynamic>> sessions) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'stress_test_sessions': sessions,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveStressTestSessions($userId) failed: $e');
    }
  }

  // ── Save stress-test verdict archive ──────────────────────────────
  // The completed-test results (scores/tiers) — same "significant events
  // only" cadence as saveStressTestSessions above. Added 2026-08-06 after
  // confirmed data loss: this was local-only before, so a reinstall wiped
  // every past verdict with nothing to restore from.

  Future<void> saveVerdictArchive(
      String userId, List<Map<String, dynamic>> archive) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'stress_test_verdicts': archive,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveVerdictArchive($userId) failed: $e');
    }
  }

  // ── Save portfolio value history ──────────────────────────────────
  // One point per day (Migration 033). Written from
  // portfolio_value_history.dart, which already skips the write when the
  // day's stored value hasn't actually moved.

  Future<void> savePortfolioValueHistory(
    String userId,
    List<Map<String, dynamic>> points,
  ) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'portfolio_value_history': points,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint(
        '🔄 userDataService.savePortfolioValueHistory($userId) failed: $e',
      );
    }
  }

  // ── Save stress-test funding flags ────────────────────────────────
  // The Custom-duration weekly top-up / dividend-simulation markers. Local
  // only until Migration 032 — see that file for the data loss this fixes.
  // Pushed on every change to the local stores rather than on "significant
  // events" like the sessions above: these writes are tiny (a handful of
  // timestamps) and rare (opt-in at setup, then once per credited period).

  Future<void> saveStressTestFunding(
    String userId,
    Map<String, dynamic> funding,
  ) async {
    try {
      await _client.from('user_data').upsert({
        'id': userId,
        'stress_test_funding': funding,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveStressTestFunding($userId) failed: $e');
    }
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
        'widget_order': data,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('🔄 userDataService.saveWidgetOrder($userId) failed: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  // Same tolerance as _decodeJsonList, for a JSONB object column: Supabase
  // hands these back already decoded, but a String slips through on some
  // driver/column-type combinations — the list helper below was written for
  // exactly that surprise.
  Map<String, dynamic> _decodeJsonMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
      } catch (_) {
        return {};
      }
    }
    return {};
  }

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
  final snapshot = await service.loadAll(user.id);
  final data = snapshot.data;

  // Nothing below may run unless the row was actually read: a failed request
  // and a not-yet-created row both arrive as empty lists, and acting on those
  // would erase whatever the device already holds.
  if (!snapshot.isAuthoritative) return;

  // Load portfolios
  final portfolioList = (data['portfolios'] as List<dynamic>)
      .map((e) => Portfolio.fromJson(e as Map<String, dynamic>))
      .toList();
  if (portfolioList.isNotEmpty) {
    ref.read(portfoliosProvider.notifier).loadFromSupabase(portfolioList);
  }

  // Load watchlist — including an empty list, so a watchlist genuinely
  // cleared on another device actually propagates here (unlike portfolios/
  // widget order below, an empty watchlist is a normal, reachable user
  // state, not just "nothing synced yet"). Safe to apply an empty list only
  // because of the isAuthoritative check above — before that existed, a
  // failed read at sign-in emptied the watchlist for real.
  final watchlist = (data['watchlist'] as List<dynamic>)
      .map((e) => e.toString())
      .toList();
  ref.read(watchlistSymbolsProvider.notifier).loadFromSupabase(watchlist);

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

  // Load orders — empty included: cancelling your last limit order is a
  // normal state, and it has to be able to reach this device.
  final ordersList = data['orders'] as List<dynamic>? ?? [];
  ref.read(ordersProvider.notifier).loadFromSupabase(
        ordersList.cast<Map<String, dynamic>>(),
      );

  // Load stress-test sessions — empty included, same reasoning: finishing or
  // deleting every test leaves none, and that must propagate.
  final stressTestSessions = data['stress_test_sessions'] as List<dynamic>;
  ref.read(stressTestProvider.notifier).loadFromSupabase(stressTestSessions);

  // Restore the Custom-duration funding flags (weekly top-up / dividends)
  // before anything can credit against them — the stress-test screen's own
  // catch-up runs on screen open, which is always later than this.
  final funding = data['stress_test_funding'] as Map<String, dynamic>? ?? {};
  if (funding.isNotEmpty) {
    await applyStressTestFunding(user.id, funding);
  }

  // Restore the portfolio value chart's points before the Portfolio screen
  // can record today's — otherwise a fresh install would start a brand-new
  // history and the old one would be overwritten on the first write.
  final valueHistory = data['portfolio_value_history'] as List<dynamic>? ?? [];
  if (valueHistory.isNotEmpty) {
    await applyPortfolioHistoryFromSupabase(user.id, valueHistory);
  }

  // Load stress-test verdict archive — empty included. An admin reset clears
  // it on the server, and until 2026-10-06 that deletion could never reach a
  // second install: it kept its stale archive and pushed it back up on the
  // next trade or test, quietly undoing the reset.
  final stressTestVerdicts = data['stress_test_verdicts'] as List<dynamic>;
  ref
      .read(stressTestProvider.notifier)
      .loadVerdictArchiveFromSupabase(stressTestVerdicts);
});
