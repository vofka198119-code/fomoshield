import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fund.dart';
import '../services/fund_api_service.dart';

final fundApiServiceProvider = Provider<FundApiService>((ref) {
  return FundApiService();
});

final fundSectorsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(fundApiServiceProvider).getSectors();
});

/// The Search screen's Funds tab. autoDispose — same reasoning as
/// Portfolio Holdings/Watchlist (see fomoshield_finnhub_rate_limit_fix
/// memory): no point keeping a fund list warm once nothing's watching it.
final fundsListProvider = FutureProvider.autoDispose<List<Fund>>((ref) {
  return ref.watch(fundApiServiceProvider).listFunds();
});

final fundDetailProvider = FutureProvider.autoDispose
    .family<FundDetail, String>((ref, fundId) {
      return ref.watch(fundApiServiceProvider).getFundDetail(fundId);
    });
