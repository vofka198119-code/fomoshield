import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Limits & Capital — based on subscription tier
// ---------------------------------------------------------------------------
// One portfolio for every tier — the old free/premium slot-count split (1
// vs 3) is gone; only the starting capital of that single portfolio still
// differs by tier.
// FREE:    1 portfolio, $7,000 starting capital
// PREMIUM: 1 portfolio, $10,000 starting capital
// ---------------------------------------------------------------------------

const double _freeStartingCapital = 7000;
const double _premiumStartingCapital = 10000;

/// Public aliases so UI copy (the premium upsell banner) can quote the
/// real numbers instead of hand-typed literals — same reasoning as
/// premiumMaxHoldingsPerPortfolio below.
const double freeStartingCapital = _freeStartingCapital;
const double premiumStartingCapital = _premiumStartingCapital;

// Real Portfolio buys go through the app's own backend, which proxies/caches
// Finnhub — a single free-tier user buying dozens of $10 positions would
// still be dozens of distinct symbols worth of live-quote traffic on every
// refresh. Capping distinct holdings per portfolio keeps that bounded.
const int _freeMaxHoldingsPerPortfolio = 20;
const int _premiumMaxHoldingsPerPortfolio = 30;

/// Public alias so UI copy (the holdings-limit monetization sheet) can
/// quote the real premium number instead of a hand-typed literal — same
/// reasoning as premiumMaxStressTestSessions in stress_test_engine.dart.
const int premiumMaxHoldingsPerPortfolio = _premiumMaxHoldingsPerPortfolio;

final maxHoldingsPerPortfolioProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier.isPremiumOrAdmin)
      ? _premiumMaxHoldingsPerPortfolio
      : _freeMaxHoldingsPerPortfolio;
});

/// Starting capital for the one portfolio a user of [tier] gets.
double startingCapitalForTier(SubscriptionTier tier) =>
    (tier.isPremiumOrAdmin) ? _premiumStartingCapital : _freeStartingCapital;
