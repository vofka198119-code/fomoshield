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
// Cached Logo Provider — загружает логотип при первом обращении
// ---------------------------------------------------------------------------
// Возвращает Future с URL логотипа или null.
// При первом вызове проверяет кэш, если нет — загружает через Finnhub.

final cachedLogoProvider = FutureProvider.family<String?, String>((ref, ticker) async {
  final repo = ref.read(logoRepositoryProvider);
  // Сначала проверить кэш
  final cached = await repo.getCachedLogo(ticker);
  if (cached != null) return cached;

  // Если нет в кэше — попробовать загрузить
  return repo.loadLogoSymbol(ticker);
});

// ---------------------------------------------------------------------------
// Quick Logo Check — только проверка кэша, без загрузки
// ---------------------------------------------------------------------------
// Используется в Search, где не нужно вызывать API для каждого результата.

final quickLogoProvider = FutureProvider.family<String?, String>((ref, ticker) async {
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
    FutureProvider.family<LogoCacheEntry?, String>((ref, ticker) async {
  final dao = ref.read(logoDaoProvider);
  return dao.getLogo(ticker);
});

final logoDaoProvider = Provider<LogoDao>((ref) => LogoDao());
