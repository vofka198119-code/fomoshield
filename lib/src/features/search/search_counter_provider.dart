import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Search Counter — legacy per-user search allowance, persisted in
// SharedPreferences. The counter no longer gates anything (retired
// 2026-09-23 — every entry point into Company Detail already goes through
// its own universal ad-or-Premium view-gate, so a second gate on top of
// it, specific to Search, was pure duplicated friction — see
// fomoshield_admob_plan_2026_09_22 memory). Kept only for the admin
// panel's reset/unlimited toggles (profile_screen.dart,
// monetization_modal.dart) and to invalidate on logout — nothing reads
// `state` to make a decision anymore.
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

final searchCounterProvider = StateNotifierProvider<SearchCounterNotifier, int>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return SearchCounterNotifier(userId: user?.id);
  },
);
