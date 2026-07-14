// ---------------------------------------------------------------------------
// Portfolio Ad Provider
// ---------------------------------------------------------------------------
// Manages ad frequency for the free tier:
//   - Banner ads on 2nd & 3rd portfolios (impression-based, no click needed)
//   - Interstitial-style ad every 5 portfolio switches
//   - Interstitial-style ad every 3 buy/sell transactions
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

class PortfolioAdState {
  final int switchCount;
  final int transactionCount;

  const PortfolioAdState({
    this.switchCount = 0,
    this.transactionCount = 0,
  });
}

class PortfolioAdNotifier extends StateNotifier<PortfolioAdState> {
  String? _userId;

  PortfolioAdNotifier({this._userId}) : super(const PortfolioAdState()) {
    _load();
  }

  String get _prefsKey =>
      _userId != null ? 'portfolio_ad_$_userId' : 'portfolio_ad';

  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final parts = raw.split(',');
      state = PortfolioAdState(
        switchCount: int.tryParse(parts[0]) ?? 0,
        transactionCount: int.tryParse(parts[1]) ?? 0,
      );
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, '${state.switchCount},${state.transactionCount}');
  }

  /// Returns true when an interstitial ad should show (every 5 switches).
  Future<bool> incrementSwitch() async {
    state = PortfolioAdState(
      switchCount: state.switchCount + 1,
      transactionCount: state.transactionCount,
    );
    await _save();
    return state.switchCount > 0 && state.switchCount % 5 == 0;
  }

  /// Returns true when an interstitial ad should show (every 3 transactions).
  Future<bool> incrementTransaction() async {
    state = PortfolioAdState(
      switchCount: state.switchCount,
      transactionCount: state.transactionCount + 1,
    );
    await _save();
    return state.transactionCount > 0 && state.transactionCount % 3 == 0;
  }

  Future<void> reset() async {
    state = const PortfolioAdState();
    await _save();
  }
}

final portfolioAdProvider =
    StateNotifierProvider<PortfolioAdNotifier, PortfolioAdState>((ref) {
  final user = ref.watch(currentUserProvider);
  return PortfolioAdNotifier(userId: user?.id);
});

/// Whether the portfolio at [index] (0-based) should show a banner ad.
/// Free tier: 1st is ad-free, 2nd & 3rd show banner.
/// Premium/Admin: no banner ads at all.
final isPortfolioBannerAdSupportedProvider =
    Provider.family<bool, int>((ref, index) {
  final tier = ref.watch(subscriptionTierProvider);
  if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin) {
    return false;
  }
  // Free tier: index 0 = free, index >= 1 = ad-supported
  return index >= 1;
});
