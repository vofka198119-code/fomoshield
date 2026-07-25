import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Limits & Capital — based on subscription tier
// ---------------------------------------------------------------------------
// FREE:  1 portfolio max
// PREMIUM: 3 portfolios max (base + 2)
// Starting capital is based on the portfolio's POSITION, not the tier:
//   1st portfolio (free or premium): $15,000
//   2nd/3rd portfolio (premium only): $50,000 each
// ---------------------------------------------------------------------------

const int _freeMaxPortfolios = 1;
const int _premiumMaxPortfolios = 3;
const double firstPortfolioStartingCapital = 15000;
const double additionalPortfolioStartingCapital = 50000;

final maxPortfoliosProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumMaxPortfolios
      : _freeMaxPortfolios;
});

/// Starting capital for a portfolio at [index] (0-based, existing-portfolio
/// count before creation). The first portfolio is always $15k regardless of
/// tier; premium's 2nd/3rd portfolios are $50k each.
double startingCapitalForIndex(int index) =>
    index == 0 ? firstPortfolioStartingCapital : additionalPortfolioStartingCapital;
