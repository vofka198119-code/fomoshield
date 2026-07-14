import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Ad Counter — first 10 free, then every 5th triggers an ad
// ---------------------------------------------------------------------------
// - FREE tier: counter starts at 0, first 10 views free
// - After 10: every 5th company detail view shows ad
// - PREMIUM: never show ads
// - Call `incrementView()` before showing company detail
// - Returns true if an ad should be shown
// ---------------------------------------------------------------------------

const int _freeViews = 10;
const int _adInterval = 5;

class WatchlistAdNotifier extends StateNotifier<int> {
  String? _userId;

  WatchlistAdNotifier({this._userId}) : super(0) {
    _load();
  }

  String get _prefsKey =>
      _userId != null ? 'watchlist_view_counter_$_userId' : 'watchlist_view_counter';

  /// Set user ID to re-scope the local cache key.
  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_prefsKey) ?? 0;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, state);
  }

  /// Returns true if the user should see an ad before the detail view.
  bool get shouldShowAd {
    if (state < _freeViews) return false;
    final adjusted = state - _freeViews;
    return adjusted > 0 && adjusted % _adInterval == 0;
  }

  /// Increments the view counter and returns true if an ad should show.
  Future<bool> incrementAndCheck() async {
    state = state + 1;
    await _save();
    return shouldShowAd;
  }

  /// Resets the counter (admin function).
  Future<void> reset() async {
    state = 0;
    await _save();
  }
}

final watchlistAdProvider =
    StateNotifierProvider<WatchlistAdNotifier, int>((ref) {
  final user = ref.watch(currentUserProvider);
  return WatchlistAdNotifier(userId: user?.id);
});

/// Whether an ad should be shown (respects premium tier).
final shouldShowAdProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin) return false;
  return ref.watch(watchlistAdProvider.notifier).shouldShowAd;
});
