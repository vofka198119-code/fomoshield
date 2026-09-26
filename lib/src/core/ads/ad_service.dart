import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ---------------------------------------------------------------------------
// AdService — thin wrapper around google_mobile_ads for the app's ad
// formats (Rewarded, Interstitial, App Open). Every call site goes
// through here rather than touching the SDK directly.
// ---------------------------------------------------------------------------

/// Real production ad unit IDs — AdMob account/app created 2026-09-24 (see
/// fomoshield_admob_plan_2026_09_22 memory). Were Google's public TEST ad
/// unit IDs before this; nothing outside this file should reference an ad
/// unit ID directly.
class AdUnitIds {
  static const rewarded = 'ca-app-pub-4765078548912596/5334279157';
  static const interstitial = 'ca-app-pub-4765078548912596/6180456963';
  static const appOpen = 'ca-app-pub-4765078548912596/8615048616';
}

/// Outcome of a rewarded ad attempt — three states, not a bool, because
/// "the user walked away" and "our ad inventory didn't fill" must lead to
/// different behavior at the call site.
///
/// [failed] is OUR side breaking: no fill, a load error, or a show error.
/// [dismissed] is the user choosing to abandon the ad, which legitimately
/// earns no reward.
///
/// Every call site must handle [failed] deliberately, and NEVER let it pass
/// silently — a no-fill with no feedback is indistinguishable from a broken
/// app. How to handle it depends on what blocking costs (decided 2026-09-26):
/// - order_ad_gate.dart FAILS OPEN — the gate is 100% after the free
///   allowance, so blocking would kill this app's core action for hours.
/// - The view gates (company_detail_screen.dart, company_encyclopedia_widget
///   .dart) stay CLOSED and explain why — they cost the user little (the
///   Company Detail gate only fires every 5th view; the Encyclopedia unlock
///   is permanent), so failing open there would hand unlimited free access
///   to anyone running an ad blocker.
enum RewardedAdOutcome { earned, dismissed, failed }

class AdService {
  Future<void> init() async {
    final status = await MobileAds.instance.initialize();
    debugPrint(
      '📺 AdMob init: ${status.adapterStatuses.values.map((s) => s.description).join(', ')}',
    );
  }

  /// Loads and shows a rewarded ad. See [RewardedAdOutcome] — callers must
  /// distinguish a user dismissal from a load/show failure, and fail open
  /// on the latter.
  Future<RewardedAdOutcome> showRewarded() async {
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
    if (ad == null) return RewardedAdOutcome.failed;

    final shown = Completer<RewardedAdOutcome>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!shown.isCompleted) {
          shown.complete(
            earned ? RewardedAdOutcome.earned : RewardedAdOutcome.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!shown.isCompleted) shown.complete(RewardedAdOutcome.failed);
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

  /// Loads and shows an App Open ad. Callers own the cold-start/resume
  /// trigger and the cooldown (see app_open_ad_provider.dart) — this just
  /// plays one ad on request.
  ///
  /// Returns true only if an ad actually played. The caller MUST NOT burn
  /// its cooldown on false: a no-fill would otherwise cost the next full
  /// cooldown window for an ad the user never saw.
  Future<bool> showAppOpen() async {
    final loaded = Completer<AppOpenAd?>();
    AppOpenAd.load(
      adUnitId: AdUnitIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future;
    if (ad == null) return false;

    final shown = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!shown.isCompleted) shown.complete(true);
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!shown.isCompleted) shown.complete(false);
      },
    );
    ad.show();
    return shown.future;
  }
}
