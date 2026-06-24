import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logo_dao.dart';
import 'logo_repository.dart';

// ---------------------------------------------------------------------------
// LogoRepository Provider
// ---------------------------------------------------------------------------

final logoRepositoryProvider = Provider<LogoRepository>((ref) {
  return LogoRepository(dao: LogoDao());
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
