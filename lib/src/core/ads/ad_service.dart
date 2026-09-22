import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ---------------------------------------------------------------------------
// AdService — thin wrapper around google_mobile_ads for the app's ad
// formats (Rewarded, Interstitial; App Open lands in a later phase). Every
// call site goes through here rather than touching the SDK directly, so
// swapping test ad unit IDs for real ones later (see
// fomoshield_admob_plan_2026_09_22 memory) only ever touches this file.
// ---------------------------------------------------------------------------

/// Google's own public TEST ad unit IDs — safe to ship while no real AdMob
/// account exists yet, never returns real ads/revenue. Swap for real unit
/// IDs once an AdMob account/app is created; nothing outside this file
/// should reference an ad unit ID directly.
class AdUnitIds {
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
}

class AdService {
  Future<void> init() async {
    final status = await MobileAds.instance.initialize();
    debugPrint(
      '📺 AdMob init: ${status.adapterStatuses.values.map((s) => s.description).join(', ')}',
    );
  }

  /// Loads and shows a rewarded ad. Returns true only if the user actually
  /// earned the reward (watched to completion) — false on any load/show
  /// failure, or if dismissed before earning it.
  Future<bool> showRewarded() async {
    final loaded = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future;
    if (ad == null) return false;

    final shown = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!shown.isCompleted) shown.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!shown.isCompleted) shown.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return shown.future;
  }

  /// Loads and shows an interstitial. Resolves once dismissed (or on any
  /// load/show failure) — no reward payload, callers just wait for it to
  /// be done before continuing.
  Future<void> showInterstitial() async {
    final loaded = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future;
    if (ad == null) return;

    final shown = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!shown.isCompleted) shown.complete();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!shown.isCompleted) shown.complete();
      },
    );
    ad.show();
    return shown.future;
  }
}
