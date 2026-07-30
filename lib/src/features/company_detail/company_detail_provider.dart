import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/logo_dao.dart';
import '../../core/models/logo_cache_entry.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/scoring_engine.dart';
import 'company_cache_provider.dart';
import 'score_cache_provider.dart';
import 'metrics_cache_provider.dart';

// ---------------------------------------------------------------------------
// Providers — with layered cache: 4h (main) + 30d (score + metrics)
// ---------------------------------------------------------------------------

final companyDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
      final cache = ref.read(companyCacheProvider);

      // Check per-ticker cache first (4h TTL)
      final cached = cache.get(symbol);
      if (cached != null) return cached;

      final api = FinnhubService();
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
      final score = ScoringEngine.calculate(metrics);

      // Сохранить логотип в LogoCache (если есть и нет в кэше)
      cacheCompanyLogo(symbol, profile);

      // Сохранить score в 30-дневный кэш
      scoreCache.set(symbol, Map<String, dynamic>.from(score));
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
