import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// App Open Ad cooldown — 4h between shows (Google's own recommended
// cadence for this format), device-level rather than per-account. Unlike
// every other ad gate in the app, this isn't a free-tier allowance — it's
// purely "don't annoy whoever is holding the phone by replaying this on
// every quick app switch" — so it's intentionally NOT scoped by userId.
//
// Stores the NEXT allowed attempt rather than the last show, so a failed
// attempt can take a much shorter backoff than a successful one. Before
// 2026-09-26 the full 4h window was burned before the ad was even
// requested, so an AdMob no-fill silently cost four hours of this format's
// impressions for an ad the user never saw.
// ---------------------------------------------------------------------------

const Duration _cooldown = Duration(hours: 4);

/// Backoff after an ad failed to load or show. Short, because nothing was
/// shown and the user isn't owed a rest — but not zero, or a persistent
/// no-fill would fire a fresh request on literally every app resume.
const Duration _retryAfterFailure = Duration(minutes: 15);

const _nextAttemptKey = 'app_open_ad_next_attempt_at';
const _legacyLastShownKey = 'app_open_ad_last_shown_at';

class AppOpenAdCooldown {
  Future<bool> get isReady async {
    final prefs = await SharedPreferences.getInstance();
    final nextMs = prefs.getInt(_nextAttemptKey) ?? _legacyNextMs(prefs);
    if (nextMs == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= nextMs;
  }

  /// An ad actually played — hold off for the full cadence.
  Future<void> recordShown() => _setNextAttempt(_cooldown);

  /// The ad failed to load or show — retry sooner, since the user saw
  /// nothing. Never skip this: without it a no-fill would re-request on
  /// every single resume.
  Future<void> recordFailedAttempt() => _setNextAttempt(_retryAfterFailure);

  Future<void> _setNextAttempt(Duration wait) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _nextAttemptKey,
      DateTime.now().add(wait).millisecondsSinceEpoch,
    );
  }

  /// Installs from before the key change stored a last-shown stamp instead.
  /// Read it as its own 4h window so upgrading doesn't hand out a bonus ad.
  int? _legacyNextMs(SharedPreferences prefs) {
    final lastShownMs = prefs.getInt(_legacyLastShownKey);
    if (lastShownMs == null) return null;
    return lastShownMs + _cooldown.inMilliseconds;
  }
}

final appOpenAdCooldownProvider = Provider<AppOpenAdCooldown>(
  (ref) => AppOpenAdCooldown(),
);
