import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Stress Test Navigation Ad Counter — screen change #11 (inside an active
// session — see stress_test_nav_ad_trigger.dart for exactly which screens
// count) triggers an interstitial, then every 8th after that (19, 27, ...).
// Unlike watchlist_ad_provider.dart's lifetime counter, this resets 5
// hours after the limit is first hit — Stress Test is meant to stay light
// across many short visits in a day, not accumulate forever.
// ---------------------------------------------------------------------------

const int _freeActions = 10;
const int _adInterval = 8;
const Duration _resetAfter = Duration(hours: 5);

class StressTestAdNotifier extends StateNotifier<int> {
  String? _userId;

  StressTestAdNotifier({this._userId}) : super(0) {
    _load();
  }

  String get _countKey => _userId != null
      ? 'stress_test_ad_count_$_userId'
      : 'stress_test_ad_count';
  String get _resetAtKey => _userId != null
      ? 'stress_test_ad_reset_at_$_userId'
      : 'stress_test_ad_reset_at';

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

  bool get shouldShowAd {
    if (state <= _freeActions) return false;
    return (state - _freeActions - 1) % _adInterval == 0;
  }

  /// Increments the navigation counter and returns true if an interstitial
  /// should show for this screen change.
  Future<bool> incrementAndCheck() async {
    state = state + 1;
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
