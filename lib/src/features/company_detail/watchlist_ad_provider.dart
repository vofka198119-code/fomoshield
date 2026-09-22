import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Ad Counter — first 10 free, then every 8th triggers an ad
// ---------------------------------------------------------------------------
// - FREE tier: counter starts at 0, first 10 views free
// - View #11 triggers the ad, then every 8th after that (19, 27, ...) — 8,
//   not 5, because viewing a company card is a cheap/frequent action like
//   Stress Test navigation, not a deliberate one like a trade — same
//   reasoning, same interval (see fomoshield_admob_plan_2026_09_22
//   memory), aligned 2026-09-22.
// - PREMIUM: never show ads
// - Call `incrementView()` before showing company detail
// - Returns true if an ad should be shown
// ---------------------------------------------------------------------------

const int _freeViews = 10;
const int _adInterval = 8;

class WatchlistAdNotifier extends StateNotifier<int> {
  String? _userId;

  WatchlistAdNotifier({this._userId}) : super(0) {
    _load();
  }

  String get _prefsKey => _userId != null
      ? 'watchlist_view_counter_$_userId'
      : 'watchlist_view_counter';

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
    if (state <= _freeViews) return false;
    return (state - _freeViews - 1) % _adInterval == 0;
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
