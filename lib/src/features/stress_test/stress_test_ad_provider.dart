import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Stress Test Navigation Ad Counter — screen change #5 (inside an active
// session — see stress_test_nav_ad_trigger.dart for exactly which screens
// count) triggers an interstitial, then every 8th after that (13, 21, ...).
// Unlike watchlist_ad_provider.dart's lifetime counter, this resets 5
// hours after the limit is first hit — Stress Test is meant to stay light
// across many short visits in a day, not accumulate forever.
// ---------------------------------------------------------------------------

const int _freeActions = 4;
const int _adInterval = 8;
const Duration _resetAfter = Duration(hours: 5);

class StressTestAdNotifier extends StateNotifier<int> {
  String? _userId;
  late Future<void> _loadFuture;

  StressTestAdNotifier({this._userId}) : super(0) {
    _loadFuture = _load();
  }

  String get _countKey => _userId != null
      ? 'stress_test_ad_count_$_userId'
      : 'stress_test_ad_count';
  String get _resetAtKey => _userId != null
      ? 'stress_test_ad_reset_at_$_userId'
      : 'stress_test_ad_reset_at';

  void setUserId(String? uid) {
    _userId = uid;
    _loadFuture = _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final resetAtMs = prefs.getInt(_resetAtKey);
    if (resetAtMs != null &&
        DateTime.now().millisecondsSinceEpoch >= resetAtMs) {
      state = 0;
      await prefs.remove(_countKey);
      await prefs.remove(_resetAtKey);
      debugPrint('🎬 StressTestAdNotifier: _load reset window expired, state=0');
      return;
    }
    state = prefs.getInt(_countKey) ?? 0;
    debugPrint('🎬 StressTestAdNotifier: _load loaded state=$state (userId=$_userId)');
  }

  bool get shouldShowAd {
    if (state <= _freeActions) return false;
    return (state - _freeActions - 1) % _adInterval == 0;
  }

  /// Increments the navigation counter and returns true if an interstitial
  /// should show for this screen change.
  Future<bool> incrementAndCheck() async {
    // Wait for the persisted value to finish loading before mutating —
    // without this, a fast first call right after app launch can race
    // _load()'s own SharedPreferences read: the increment below happens
    // against the fresh default (0), then _load() resolves moments later
    // and clobbers it with the stale persisted value, silently losing the
    // increment. Confirmed live 2026-09-23 (state jumped 1 -> 21 mid-call).
    await _loadFuture;
    state = state + 1;
    debugPrint(
      '🎬 StressTestAdNotifier: state=$state (userId=$_userId) shouldShowAd=$shouldShowAd',
    );
    final prefs = await SharedPreferences.getInstance();
    // Start the 5h reset window the first time the free actions run out —
    // not re-extended on every later trigger, so an active session still
    // gets a fresh batch 5h after first running dry, not 5h after its
    // LAST action.
    if (state > _freeActions && prefs.getInt(_resetAtKey) == null) {
      await prefs.setInt(
        _resetAtKey,
        DateTime.now().add(_resetAfter).millisecondsSinceEpoch,
      );
    }
    await prefs.setInt(_countKey, state);
    return shouldShowAd;
  }
}

final stressTestAdProvider = StateNotifierProvider<StressTestAdNotifier, int>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  return StressTestAdNotifier(userId: user?.id);
});
