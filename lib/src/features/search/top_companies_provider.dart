import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Top Companies — the full S&P 500, real backend-ranked by market cap
// (see FinnhubService.topCompanies / scanco-backend's sp500Service.js).
// Sector grouping happens client-side via gics_sector_mapper.dart's
// resolveGicsSector(), not here.
// ---------------------------------------------------------------------------

class TopCompanyEntry {
  final String symbol;
  final String name;
  final double marketCap;
  final double? peTTM;

  const TopCompanyEntry({
    required this.symbol,
    required this.name,
    required this.marketCap,
    this.peTTM,
  });
}

final topCompaniesProvider = FutureProvider<List<TopCompanyEntry>>((ref) async {
  final data = await ref.read(finnhubServiceProvider).topCompanies();
  final companies = data['companies'] as List<dynamic>? ?? [];
  return [
    for (final c in companies)
      TopCompanyEntry(
        symbol: (c as Map)['symbol'] as String? ?? '',
        name: c['name'] as String? ?? '',
        marketCap: (c['marketCap'] as num?)?.toDouble() ?? 0,
        peTTM: (c['peTTM'] as num?)?.toDouble(),
      ),
  ];
});

// ---------------------------------------------------------------------------
// One-shot bulk icon warm — returns symbol -> logoUrl for the whole
// top-companies roster. See FinnhubService.iconsBatch's doc comment for the
// "old tickers load instantly, new ones trickle in one by one" symptom this
// targets.
//
// Callers MUST pass this map's value straight into CompanyLogo's own
// `logoUrl` param (as search_browse_lanes.dart / company_list_screen.dart
// do) rather than just letting rows self-resolve via cachedLogoProvider —
// an early version of this provider only wrote into LogoDao and trusted
// each row's own cachedLogoProvider to pick that up, but that provider
// fires its OWN independent /icons request the instant a row builds and
// almost always wins the race against this one (which first has to await a
// LogoDao read per symbol before even issuing its network call), then
// caches whatever it got (often still the fallback) for the rest of this
// screen instance's lifetime — so the batch write here was arriving too
// late to matter. Confirmed live 2026-09-06: rows kept showing the fallback
// image no matter how many times this provider ran, until Company Detail's
// own always-live Finnhub fetch was opened for that one symbol. Passing the
// resolved URL down explicitly bypasses cachedLogoProvider for these rows
// entirely, so there's no race to lose.
// ---------------------------------------------------------------------------
final iconsBatchWarmProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final companies = await ref.watch(topCompaniesProvider.future);
  if (companies.isEmpty) return {};

  final dao = ref.read(logoDaoProvider);
  final result = <String, String>{};
  final missing = <String>[];
  for (final c in companies) {
    if (c.symbol.isEmpty) continue;
    final cached = await dao.getLogo(c.symbol);
    if (cached != null && cached.logoUrl.isNotEmpty) {
      result[c.symbol] = cached.logoUrl;
    }
    // Retry anything not CONFIRMED real, not just entries with no cache
    // entry at all — covers both 'fallback' (see iconService.hasRealIcon's
    // own doc comment for why that isn't "done") and legacy entries with
    // no `source` field. That second case was meant for genuinely old
    // pre-existing installs (see LogoCacheEntry.source's own doc comment),
    // but this session's own earlier iterations of THIS provider wrote
    // exactly such source-less entries today, before the field existed —
    // "leave legacy alone" was silently protecting today's own leftover
    // fallback writes from ever being retried. Re-checking a genuinely
    // fine legacy entry costs nothing (one more symbol in the same shared
    // batch call, server-side is a cache-only lookup), so there's no real
    // downside to including it.
    if (cached == null || cached.source != 'finnhub') missing.add(c.symbol);
  }
  if (missing.isEmpty) return result;

  try {
    final service = ref.read(finnhubServiceProvider);
    final icons = await service.iconsBatch(missing);
    await ref.read(logoRepositoryProvider).cacheIconsBatch(icons);
    for (final entry in icons.entries) {
      result[entry.key] = entry.value.key;
    }
  } catch (e) {
    debugPrint('🖼️ ❌ iconsBatchWarmProvider failed: $e');
  }
  return result;
});
