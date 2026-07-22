import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Limits & Capital — based on subscription tier
// ---------------------------------------------------------------------------
// FREE:  1 portfolio max, $5,000 capital
// PREMIUM: 3 portfolios max (base + 2), $15,000 capital
// ---------------------------------------------------------------------------

const int _freeMaxPortfolios = 1;
const int _premiumMaxPortfolios = 3;
const double _freeStartingCapital = 5000;
const double _premiumStartingCapital = 15000;

final maxPortfoliosProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumMaxPortfolios
      : _freeMaxPortfolios;
});

final startingCapitalProvider = Provider<double>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumStartingCapital
      : _freeStartingCapital;
});
