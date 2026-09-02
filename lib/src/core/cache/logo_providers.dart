import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/logo_cache_entry.dart';
import '../../shared/services/finnhub_service.dart';
import 'logo_dao.dart';
import 'logo_repository.dart';

// ---------------------------------------------------------------------------
// LogoRepository Provider
// ---------------------------------------------------------------------------

final logoRepositoryProvider = Provider<LogoRepository>((ref) {
  return LogoRepository(dao: LogoDao(), api: ref.read(finnhubServiceProvider));
});

// ---------------------------------------------------------------------------
// Cached Logo Provider — резолвит логотип, никогда не вызывая Finnhub
// напрямую с клиента
// ---------------------------------------------------------------------------
// 1. Локальный кэш (LogoDao) — если тикер уже реально резолвился раньше
//    (обычно через Company Detail, см. cacheFromProfile), берём оттуда.
// 2. Промах — идём в НАШ бэкенд (/api/v1/icons/:symbol), а не в Finnhub
//    напрямую. Тот эндпоинт сам никогда синхронно не бьёт по Finnhub —
//    отдаёт бесплатный ticker-CDN фоллбэк сразу же, а настоящее лого
//    подтягивает отдельная фоновая джоба на сервере (throttled, вне
//    пользовательского запроса). Раньше здесь стоял
//    repo.loadLogoSymbol(ticker) — прямой Finnhub-вызов с клиента на
//    каждый непопавший в кэш тикер, тот самый источник rate-limit'ов при
//    браузинге Search-лент (см. fomoshield_finnhub_rate_limit_fix_2026_08_22
//    memory, round 6, 2026-08-27).
final cachedLogoProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, ticker) async {
  final repo = ref.read(logoRepositoryProvider);
  final cached = await repo.getCachedLogo(ticker);
  if (cached != null) return cached;

  final service = ref.read(finnhubServiceProvider);
  // One retry after a beat: a cold-start burst on Home (quotes, indices,
  // Shield Signal, portfolio, this fetch, all at once right after a fresh
  // install) can make the first /icons hit lose the race and throw. Since
  // this is a FutureProvider.family, a single swallowed failure used to
  // cache `null` for the provider's whole lifetime — and the Home
  // Watchlist widget never unmounts (lives in the bottom tab bar), so the
  // icon stayed dead for the rest of the session. Confirmed report:
  // "died after reinstall, never came back" 2026-09-02.
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final data = await service.icon(ticker);
      return data['iconUrl'] as String?;
    } catch (e) {
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        debugPrint('🖼️ ❌ cachedLogoProvider($ticker) failed twice: $e');
      }
    }
  }
  return null;
});

// ---------------------------------------------------------------------------
// Quick Logo Check — только проверка кэша, без загрузки
// ---------------------------------------------------------------------------
// Используется в Search, где не нужно вызывать API для каждого результата.

final quickLogoProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, ticker) async {
  final repo = ref.read(logoRepositoryProvider);
  return repo.getCachedLogo(ticker);
});

// ---------------------------------------------------------------------------
// Cached Logo Entry Provider — full entry (name + logo), cache-only
// ---------------------------------------------------------------------------
// Purely local (SharedPreferences) read, no network call ever — a symbol
// only reaches this provider (Watchlist rows) after having already been
// viewed on Company Detail or a Search result row, both of which populate
// LogoDao first. Returns null only right after a fresh reinstall/Supabase
// sync, before the symbol has been opened once on this device.

final cachedLogoEntryProvider =
    FutureProvider.autoDispose.family<LogoCacheEntry?, String>((
  ref,
  ticker,
) async {
  final dao = ref.read(logoDaoProvider);
  return dao.getLogo(ticker);
});

final logoDaoProvider = Provider<LogoDao>((ref) => LogoDao());

// ---------------------------------------------------------------------------
// Resolved Company Name Provider — real name for tickers outside any
// hand-maintained curated list (e.g. Stress Test's stressTestCompanyName()).
// ---------------------------------------------------------------------------
// Reuses the same LogoDao cache as the logo providers above: if a trustworthy
// name is already cached, returns it instantly; otherwise triggers the same
// Finnhub profile fetch loadLogo() uses (now fixed to persist profile['name']
// instead of the ticker) and returns the freshly-cached name. Reactive, so
// UI watching this provider updates once the fetch lands instead of staying
// stuck on a fallback — unlike a plain synchronous helper would.

final resolvedCompanyNameProvider =
    FutureProvider.autoDispose.family<String, String>((ref, ticker) async {
  final dao = ref.read(logoDaoProvider);
  final cached = await dao.getLogo(ticker);
  if (cached != null &&
      cached.companyName.isNotEmpty &&
      cached.companyName.toUpperCase() != ticker.toUpperCase()) {
    return cached.companyName;
  }

  await ref.read(logoRepositoryProvider).loadLogoSymbol(ticker);
  final refreshed = await dao.getLogo(ticker);
  final name = refreshed?.companyName;
  return (name != null && name.isNotEmpty) ? name : ticker;
});
