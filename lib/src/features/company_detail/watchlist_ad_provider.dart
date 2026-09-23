import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Ad Counter — first 5 free, then every 5th triggers TWO
// back-to-back ads (see CompanyDetailScreen._showWatchAdOverlay)
// ---------------------------------------------------------------------------
// - FREE tier: counter starts at 0, first 5 views free
// - View #6 triggers the ad gate, then every 5th after that (11, 16, ...)
//   — changed 2026-09-23 from the original 10-free/every-8th/single-ad
//   design (see fomoshield_admob_plan_2026_09_22 memory) to a tighter
//   5-free/every-5th/two-ads cadence, matching Company Encyclopedia's
//   two-ad unlock pattern.
// - Counts regardless of entry point (Search, Watchlist, Portfolio,
//   Recently Viewed, ...) and regardless of which symbol — reopening the
//   same company after closing it is a new increment, same as a
//   different one.
// - PREMIUM: never show ads
// - Call `incrementAndCheck()` before showing company detail
// - Returns true if the ad gate should be shown
// ---------------------------------------------------------------------------

const int _freeViews = 5;
const int _adInterval = 5;

class WatchlistAdNotifier extends StateNotifier<int> {
  String? _userId;
  late Future<void> _loadFuture;

  WatchlistAdNotifier({this._userId}) : super(0) {
    _loadFuture = _load();
  }

  String get _prefsKey => _userId != null
      ? 'watchlist_view_counter_$_userId'
      : 'watchlist_view_counter';

  /// Set user ID to re-scope the local cache key.
  void setUserId(String? uid) {
    _userId = uid;
    _loadFuture = _load();
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
    if (state <= _freeViews) return false;
    return (state - _freeViews - 1) % _adInterval == 0;
  }

  /// Increments the view counter and returns true if an ad should show.
  Future<bool> incrementAndCheck() async {
    // Wait for the persisted value to finish loading before mutating —
    // without this, a fast first call right after app launch can race
    // _load()'s own SharedPreferences read and silently lose the
    // increment (see stress_test_ad_provider.dart's identical fix,
    // confirmed live 2026-09-23).
    await _loadFuture;
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

final watchlistAdProvider = StateNotifierProvider<WatchlistAdNotifier, int>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  return WatchlistAdNotifier(userId: user?.id);
});

/// Whether an ad should be shown (respects premium tier).
final shouldShowAdProvider = Provider<bool>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  if (tier.isPremiumOrAdmin) return false;
  return ref.watch(watchlistAdProvider.notifier).shouldShowAd;
});
