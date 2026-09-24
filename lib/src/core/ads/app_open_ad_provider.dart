import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// App Open Ad cooldown — 4h between shows (Google's own recommended
// cadence for this format), device-level rather than per-account. Unlike
// every other ad gate in the app, this isn't a free-tier allowance — it's
// purely "don't annoy whoever is holding the phone by replaying this on
// every quick app switch" — so it's intentionally NOT scoped by userId.
// ---------------------------------------------------------------------------

const Duration _cooldown = Duration(hours: 4);
const _lastShownKey = 'app_open_ad_last_shown_at';

class AppOpenAdCooldown {
  Future<bool> get isReady async {
    final prefs = await SharedPreferences.getInstance();
    final lastShownMs = prefs.getInt(_lastShownKey);
    if (lastShownMs == null) return true;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastShownMs),
    );
    return elapsed >= _cooldown;
  }

  Future<void> recordShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastShownKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final appOpenAdCooldownProvider = Provider<AppOpenAdCooldown>(
  (ref) => AppOpenAdCooldown(),
);
