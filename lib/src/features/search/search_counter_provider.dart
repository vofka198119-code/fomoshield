import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Search Counter — 15 free searches per user, persisted in SharedPreferences
// ---------------------------------------------------------------------------
// - FREE tier: starts at 15, decrements on each search
// - PREMIUM tier: 999 (effectively unlimited)
// - Call `consumeSearch()` before navigating to company detail
// - Call `addSearches(15)` after watching an ad
// - Call `resetToFree()` from admin panel
// ---------------------------------------------------------------------------

const int _defaultFreeSearches = 15;
const int _premiumSearchLimit = 999;

class SearchCounterNotifier extends StateNotifier<int> {
  String? _userId;

  SearchCounterNotifier({this._userId}) : super(_defaultFreeSearches) {
    _load();
  }

  String get _prefsKey =>
      _userId != null ? 'search_counter_$_userId' : 'search_counter';

  /// Set user ID to re-scope the local cache key.
  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_prefsKey) ?? _defaultFreeSearches;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, state);
  }

  /// Returns true if the user can search (counter > 0).
  bool get canSearch => state > 0;

  /// Decrements the counter by 1. Returns remaining count.
  Future<int> consumeSearch() async {
    if (state > 0) {
      state = state - 1;
      await _save();
    }
    return state;
  }

  /// Adds additional searches (e.g. +15 after watching an ad).
  Future<void> addSearches(int count) async {
    state = state + count;
    await _save();
  }

  /// Resets counter to the default free amount.
  Future<void> resetToFree() async {
    state = _defaultFreeSearches;
    await _save();
  }

  /// Sets counter to unlimited (for premium users).
  Future<void> setUnlimited() async {
    state = _premiumSearchLimit;
    await _save();
  }
}

final searchCounterProvider =
    StateNotifierProvider<SearchCounterNotifier, int>((ref) {
  final user = ref.watch(currentUserProvider);
  return SearchCounterNotifier(userId: user?.id);
});

/// Provides whether the current user can perform a search.
final canSearchProvider = Provider<bool>((ref) {
  final counter = ref.watch(searchCounterProvider);
  final tier = ref.watch(subscriptionTierProvider);
  return tier == SubscriptionTier.premium ||
      tier == SubscriptionTier.admin ||
      counter > 0;
});
