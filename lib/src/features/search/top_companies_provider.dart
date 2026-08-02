import 'package:flutter_riverpod/flutter_riverpod.dart';
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
