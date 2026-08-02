import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/logo_dao.dart';
import '../../core/models/logo_cache_entry.dart';
import '../../core/services/gics_sector_mapper.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/scoring_engine.dart';
import '../search/top_companies_provider.dart';
import 'company_cache_provider.dart';
import 'score_cache_provider.dart';
import 'metrics_cache_provider.dart';

// ---------------------------------------------------------------------------
// Providers — with layered cache: 4h (main) + 30d (score + metrics)
// ---------------------------------------------------------------------------

/// Average P/E per GICS sector, computed from the full ranked S&P 500 list
/// (see `top_companies_provider.dart`) grouped via
/// `resolveGicsSector()` — Finnhub has no sector-average field of its
/// own, so this is the FS Score Valuation marker's real comparison
/// baseline instead of the nonexistent `sectorPeTTM` the engine used to
/// (silently) read as always-zero. Refreshes whenever the backend's
/// quarterly ranking job does.
final sectorAveragePeProvider = FutureProvider<Map<GicsSector, double>>((
  ref,
) async {
  final companies = await ref.watch(topCompaniesProvider.future);
  final sums = <GicsSector, double>{};
  final counts = <GicsSector, int>{};
  for (final c in companies) {
    final pe = c.peTTM;
    if (pe == null || pe <= 0) continue;
    final sector = resolveGicsSector(c.symbol, companyName: c.name);
    if (sector == null) continue;
    sums[sector] = (sums[sector] ?? 0) + pe;
    counts[sector] = (counts[sector] ?? 0) + 1;
  }
  return {for (final sector in sums.keys) sector: sums[sector]! / counts[sector]!};
});

final companyDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
      final cache = ref.read(companyCacheProvider);

      // Check per-ticker cache first (4h TTL)
      final cached = cache.get(symbol);
      if (cached != null) return cached;

      final api = ref.read(finnhubServiceProvider);
      final scoreCache = ref.read(scoreCacheProvider);
      final metricsCache = ref.read(metricsCacheProvider);

      // Check 30-day score cache before full API call (экономия трафика)
      final cachedScore = scoreCache.get(symbol);
      if (cachedScore != null) {
        // Score актуален — берём только profile + quote
        // Метрики пробуем из 30-дневного кэша, если нет — запрос к Finnhub
        final profile = await api.companyProfile(symbol);
        final quote = await api.quote(symbol);

        cacheCompanyLogo(symbol, profile);

        Map<String, dynamic> metrics = {};
        final cachedMetrics = metricsCache.get(symbol);
        if (cachedMetrics != null) {
          metrics = cachedMetrics;
        } else {
          try {
            metrics = await api.metrics(symbol);
            metricsCache.set(symbol, metrics);
          } catch (_) {
            metrics = {};
          }
        }

        final data = {
          'profile': profile,
          'quote': quote,
          'metrics': metrics,
          'score': cachedScore,
        };

        // Store in 4h cache
        cache.set(symbol, Map<String, dynamic>.from(data));
        return data;
      }

      // Score кэш пуст — полный запрос к Finnhub
      final profile = await api.companyProfile(symbol);
      final quote = await api.quote(symbol);
      final metrics = await api.metrics(symbol);

      final sectorAverages = await ref.watch(sectorAveragePeProvider.future);
      final sector = resolveGicsSector(
        symbol,
        companyName: profile['name'] as String?,
      );
      final sectorPe = sector != null ? sectorAverages[sector] : null;

      // 5Y weekly price history for the Historical Trend marker's real
      // CAGR — same shape of candle call PriceChart makes for
      // ChartPeriod.year5. Left null (marker stays neutral) if the
      // fetch fails or the symbol doesn't have 5 years of history yet
      // (e.g. a recent IPO) — never guess.
      double? priceCagr5Y;
      try {
        final fiveYearsAgo = DateTime.now()
                .subtract(const Duration(days: 1825))
                .millisecondsSinceEpoch ~/
            1000;
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final candleData = await api.candles(
          symbol,
          resolution: 'W',
          from: fiveYearsAgo,
          to: nowSec,
        );
        final closes = (candleData['c'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList();
        if (closes != null && closes.length >= 2 && closes.first > 0) {
          final totalReturn = closes.last / closes.first;
          // Percentage-point annualized return (e.g. 12.5 for +12.5%/yr).
          priceCagr5Y = (math.pow(totalReturn, 1 / 5) - 1) * 100;
        }
      } catch (_) {
        // priceCagr5Y stays null.
      }

      final score = ScoringEngine.calculate(
        metrics,
        sectorPe: sectorPe,
        priceCagr5Y: priceCagr5Y,
      );

      // Сохранить логотип в LogoCache (если есть и нет в кэше)
      cacheCompanyLogo(symbol, profile);

      // Сохранить score в 30-дневный кэш — null (fund/ETF, no
      // fundamentals) cached as {} so a re-open this session doesn't
      // redo the same "no fundamentals" check for nothing.
      scoreCache.set(
        symbol,
        score != null ? Map<String, dynamic>.from(score) : {},
      );
      // Сохранить сырые метрики в 30-дневный кэш
      metricsCache.set(symbol, Map<String, dynamic>.from(metrics));

      final data = {
        'profile': profile,
        'quote': quote,
        'metrics': metrics,
        'score': score,
      };

      // Store in per-ticker cache (4h)
      cache.set(symbol, Map<String, dynamic>.from(data));

      return data;
    });

/// Price at the point the user is currently dragging on `PriceChart`, or
/// null when they're not touching it. Lets the Price Header's PRICE cell
/// mirror the touched point while scrubbing, like most trading apps do,
/// without PriceChart and PriceHeader needing to know about each other
/// directly — keyed by symbol so switching companies can't leak a stale
/// value across screens.
final chartHoverPriceProvider = StateProvider.autoDispose.family<
  double?,
  String
>((ref, symbol) => null);

/// Change/%change for whichever period is currently selected on
/// `PriceChart` (plus its label, e.g. "1D"), or null before the chart's
/// first candle load finishes. Lets the Price Header's CHANGE cell track
/// the selected period instead of always showing the fixed daily change
/// — same PriceChart<->PriceHeader decoupling pattern as
/// [chartHoverPriceProvider].
final chartPeriodChangeProvider = StateProvider.autoDispose.family<
  ({double change, double changePercent, String periodLabel})?,
  String
>((ref, symbol) => null);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Сохраняет логотип компании в LogoCache.
Future<void> cacheCompanyLogo(String symbol, Map<String, dynamic> profile) async {
  try {
    final dao = LogoDao();
    final existing = await dao.getLogo(symbol);
    if (existing != null) return; // уже есть в кэше

    final finnhubLogo = profile['logo'] as String?;
    final weburl = profile['weburl'] as String?;
    String? domain;
    if (weburl != null && weburl.isNotEmpty) {
      try {
        final uri = Uri.parse(weburl);
        domain = uri.host;
        if (domain.startsWith('www.')) domain = domain.substring(4);
      } catch (_) {}
    }
    final logoUrl =
        finnhubLogo ??
        (domain != null ? 'https://logo.clearbit.com/$domain' : null);
    if (logoUrl == null) return;

    final entry = LogoCacheEntry(
      ticker: symbol.toUpperCase(),
      companyName: profile['name'] as String? ?? symbol,
      domain: domain,
      logoUrl: logoUrl,
      createdAt: DateTime.now(),
    );
    await dao.saveLogo(entry);
  } catch (_) {
    // Не ломаем UI
  }
}
