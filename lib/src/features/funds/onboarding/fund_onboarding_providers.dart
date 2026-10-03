import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fund Onboarding "seen once" tracking — same SharedPreferences-flag +
// Riverpod-provider-gating-navigation shape as
// disclaimer_providers.dart's AcceptedVersionsNotifier, simplified to a
// plain boolean (no remote version to reconcile against — this onboarding
// doesn't change once shipped, unlike the disclaimer/ToS text).
// ---------------------------------------------------------------------------

enum FundOnboardingBranch { head, analyst }

String _prefsKey(FundOnboardingBranch branch) => switch (branch) {
  FundOnboardingBranch.head => 'etf_onboarding_seen_head',
  FundOnboardingBranch.analyst => 'etf_onboarding_seen_analyst',
};

class FundOnboardingSeenNotifier extends StateNotifier<bool> {
  final FundOnboardingBranch branch;

  FundOnboardingSeenNotifier(this.branch) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey(branch)) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey(branch), true);
    state = true;
  }
}

final fundOnboardingSeenProvider =
    StateNotifierProvider.family<
      FundOnboardingSeenNotifier,
      bool,
      FundOnboardingBranch
    >((ref, branch) {
      return FundOnboardingSeenNotifier(branch);
    });
