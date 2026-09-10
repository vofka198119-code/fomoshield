import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/cache/logo_providers.dart' show resolvedCompanyNameProvider;
import '../models/fund.dart';
import '../services/fund_api_service.dart';

/// Fund tickers are always "FS" + 1-5 uppercase letters (fundService.js's
/// TICKER_PREFIX, enforced server-side) — used as a cheap pre-filter
/// wherever a Portfolio holding's symbol might be a fund's units rather
/// than a real stock, before paying for a funds-list round trip to confirm
/// against the actual ticker (a real stock ticker can coincidentally match
/// this shape, e.g. FSLR — First Solar — so the pattern alone is never
/// sufficient on its own).
final RegExp fundTickerPattern = RegExp(r'^FS[A-Z]{1,5}$');

final fundApiServiceProvider = Provider<FundApiService>((ref) {
  return FundApiService();
});

final fundSectorsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(fundApiServiceProvider).getSectors();
});

/// The Search screen's Funds tab, and Home's own-fund lookup
/// (FundEntryWidget). Deliberately NOT autoDispose — unlike Watchlist/
/// Portfolio Holdings (fomoshield_finnhub_rate_limit_fix memory), this hits
/// our own backend, not Finnhub, so there's no rate-limit cost to keeping
/// it warm. Home's own-fund shortcut relies on that: it remounts on every
/// return to Home (no persistent shell around the bottom-nav screens), and
/// autoDispose meant that remount always restarted from `loading` (no
/// value) for a frame, flashing the pre-fund label before flipping to the
/// real one — confirmed live 2026-09-10. Mutation sites already
/// ref.invalidate this after creating/deleting a fund.
final fundsListProvider = FutureProvider<List<Fund>>((ref) {
  return ref.watch(fundApiServiceProvider).listFunds();
});

final fundDetailProvider = FutureProvider.autoDispose
    .family<FundDetail, String>((ref, fundId) {
      return ref.watch(fundApiServiceProvider).getFundDetail(fundId);
    });

/// Display name for a Portfolio holding/transaction's symbol — resolves a
/// fund's real name first when the symbol is actually a fund's ticker,
/// before ever falling through to [resolvedCompanyNameProvider]. That
/// provider has no concept of funds and, left to its own devices, tries
/// (and fails) to fetch a Finnhub company profile for one, silently
/// falling back to the raw ticker — which is why the trade history
/// widget/screen and trade detail card kept showing "FSFOF" as the title
/// instead of the fund's name even after PortfolioHoldingsWidget was fixed
/// to show it correctly. Every UI surface displaying a symbol's name for a
/// real-Portfolio holding or transaction should watch this one instead of
/// resolvedCompanyNameProvider directly.
final resolvedAssetNameProvider = FutureProvider.autoDispose
    .family<String, String>((ref, symbol) async {
      if (fundTickerPattern.hasMatch(symbol)) {
        final funds = await ref.watch(fundsListProvider.future);
        final match = funds.where((f) => f.ticker == symbol).firstOrNull;
        if (match != null) return match.name;
      }
      return ref.watch(resolvedCompanyNameProvider(symbol).future);
    });
