import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Limits & Capital — based on subscription tier
// ---------------------------------------------------------------------------
// FREE:  1 portfolio max, $15,000 capital
// PREMIUM: 3 portfolios max (base + 2), $50,000 capital
// ---------------------------------------------------------------------------

const int _freeMaxPortfolios = 1;
const int _premiumMaxPortfolios = 3;
const double _freeStartingCapital = 15000;
const double _premiumStartingCapital = 50000;

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
