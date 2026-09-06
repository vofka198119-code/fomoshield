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
// One-shot bulk icon warm — see FinnhubService.iconsBatch's doc comment for
// the "old tickers load instantly, new ones trickle in one by one" symptom
// this fixes. SearchBrowseLanes watches this alongside topCompaniesProvider
// so every row in every lane/sector reads its icon from the local cache on
// first build, instead of each CompanyLogo firing its own /icons request
// through FinnhubService's shared concurrency limiter.
// ---------------------------------------------------------------------------
final iconsBatchWarmProvider = FutureProvider.autoDispose<void>((ref) async {
  final companies = await ref.watch(topCompaniesProvider.future);
  if (companies.isEmpty) return;

  final dao = ref.read(logoDaoProvider);
  final missing = <String>[];
  for (final c in companies) {
    if (c.symbol.isEmpty) continue;
    if (await dao.getLogo(c.symbol) == null) missing.add(c.symbol);
  }
  if (missing.isEmpty) return;

  try {
    final service = ref.read(finnhubServiceProvider);
    final icons = await service.iconsBatch(missing);
    await ref.read(logoRepositoryProvider).cacheIconsBatch(icons);
  } catch (e) {
    debugPrint('🖼️ ❌ iconsBatchWarmProvider failed: $e');
  }
});
