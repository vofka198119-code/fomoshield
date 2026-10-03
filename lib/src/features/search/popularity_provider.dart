import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Company popularity — how many times people opened each company's page
// ---------------------------------------------------------------------------
// Counted entirely server-side off requests that already happen (see the
// backend's popularityService.js). Nothing per-user exists behind it: two
// numbers per symbol, all-time and today.
//
// Returns an empty list rather than throwing when the endpoint isn't there —
// the counter is deployed separately from the app, so a build can reach a
// server that predates it, and an empty Ratings lane is the right answer then,
// not an error banner.
// ---------------------------------------------------------------------------

class PopularCompany {
  final String symbol;
  final int count;

  const PopularCompany({required this.symbol, required this.count});
}

class PopularityRanking {
  final List<PopularCompany> allTime;
  final List<PopularCompany> today;

  const PopularityRanking({required this.allTime, required this.today});

  static const empty = PopularityRanking(allTime: [], today: []);
}

List<PopularCompany> _parse(dynamic raw) {
  if (raw is! List) return const [];
  final out = <PopularCompany>[];
  for (final e in raw) {
    if (e is Map) {
      final symbol = e['symbol'] as String?;
      final count = (e['count'] as num?)?.toInt();
      if (symbol != null && symbol.isNotEmpty && count != null) {
        out.add(PopularCompany(symbol: symbol, count: count));
      }
    }
  }
  return out;
}

final popularityProvider = FutureProvider<PopularityRanking>((ref) async {
  try {
    final data = await ref
        .read(finnhubServiceProvider)
        .popularCompanies(limit: 10);
    return PopularityRanking(
      allTime: _parse(data['allTime']),
      today: _parse(data['today']),
    );
  } catch (_) {
    return PopularityRanking.empty;
  }
});
