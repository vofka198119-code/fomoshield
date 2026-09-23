import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Order Placement Ad Gate counter — shared shape between Stress Test and
// Portfolio order entry, but each context gets its OWN counter/prefs key
// (a Stress Test session burning through orders shouldn't eat into real
// Portfolio's allowance or vice versa — see fomoshield_admob_plan_2026_09_22
// memory, agreed 2026-09-23).
// ---------------------------------------------------------------------------
// - FREE tier: first 3 order placements (per context) are free
// - Order #4 and EVERY one after it is gated — unlike the view/nav
//   counters elsewhere in the app, there is no periodic free window here;
//   placing a trade is a deliberate action, so once the free allowance is
//   spent every further order needs an ad or Premium until the reset.
// - Resets 5h after the limit is first hit (same window shape as
//   stress_test_ad_provider.dart).
// - PREMIUM: never gated — checked by the caller before incrementing.
// ---------------------------------------------------------------------------

const int _freeOrders = 3;
const Duration _resetAfter = Duration(hours: 5);

class OrderAdNotifier extends StateNotifier<int> {
  final String contextKey;
  String? _userId;

  OrderAdNotifier({required this.contextKey, this._userId}) : super(0) {
    _load();
  }

  String get _countKey => _userId != null
      ? 'order_ad_count_${contextKey}_$_userId'
      : 'order_ad_count_$contextKey';
  String get _resetAtKey => _userId != null
      ? 'order_ad_reset_at_${contextKey}_$_userId'
      : 'order_ad_reset_at_$contextKey';

  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final resetAtMs = prefs.getInt(_resetAtKey);
    if (resetAtMs != null &&
        DateTime.now().millisecondsSinceEpoch >= resetAtMs) {
      state = 0;
      await prefs.remove(_countKey);
      await prefs.remove(_resetAtKey);
      return;
    }
    state = prefs.getInt(_countKey) ?? 0;
  }

  bool get shouldShowAd => state > _freeOrders;

  /// Increments the order counter and returns true if this order should be
  /// gated behind an ad/Premium.
  Future<bool> incrementAndCheck() async {
    state = state + 1;
    final prefs = await SharedPreferences.getInstance();
    if (state > _freeOrders && prefs.getInt(_resetAtKey) == null) {
      await prefs.setInt(
        _resetAtKey,
        DateTime.now().add(_resetAfter).millisecondsSinceEpoch,
      );
    }
    await prefs.setInt(_countKey, state);
    return shouldShowAd;
  }
}

final orderAdProvider =
    StateNotifierProvider.family<OrderAdNotifier, int, String>((
      ref,
      contextKey,
    ) {
      final user = ref.watch(currentUserProvider);
      return OrderAdNotifier(contextKey: contextKey, userId: user?.id);
    });
