import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Limits — based on subscription tier
// ---------------------------------------------------------------------------
// FREE:    30 companies max
// PREMIUM: 50 companies max
// ---------------------------------------------------------------------------

const int _freeMaxWatchlist = 30;
const int _premiumMaxWatchlist = 50;

final maxWatchlistProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumMaxWatchlist
      : _freeMaxWatchlist;
});
