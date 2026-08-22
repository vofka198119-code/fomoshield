import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gics_sector_mapper.dart';
import 'logo_dao.dart';
import 'logo_providers.dart';
import 'sector_repository.dart';

// ---------------------------------------------------------------------------
// SectorRepository Provider
// ---------------------------------------------------------------------------
// Shares the same LogoRepository instance logo_providers.dart already
// wires up (which in turn shares finnhubServiceProvider) — sector
// resolution now reads/writes through the same LogoDao entry logo
// resolution does, see sector_repository.dart's doc comment.

final sectorRepositoryProvider = Provider<SectorRepository>((ref) {
  return SectorRepository(
    dao: LogoDao(),
    logoRepo: ref.read(logoRepositoryProvider),
  );
});

// ---------------------------------------------------------------------------
// Cached GICS Sector Provider — загружает сектор при первом обращении
// ---------------------------------------------------------------------------
// Возвращает Future с GicsSector или null. При первом вызове проверяет
// кэш, если нет — загружает через Finnhub companyProfile.

final cachedGicsSectorProvider =
    FutureProvider.family<GicsSector?, String>((ref, ticker) async {
  final repo = ref.read(sectorRepositoryProvider);
  final cached = await repo.getCachedSector(ticker);
  if (cached != null) return cached;
  return repo.loadSector(ticker);
});

// ---------------------------------------------------------------------------
// Quick GICS Sector Check — только проверка кэша, без загрузки
// ---------------------------------------------------------------------------
// Cache-only мирроring quickLogoProvider — для мест, где ряд рендерится
// сразу списком (Search lanes/company list) и не должен сам по себе
// стрелять в Finnhub на каждый непопавший в кэш тикер. Сектор либо уже
// живёт в LogoDao (кто-то раньше открыл Company Detail/купил в Stress
// Test), либо остаётся null — вызывающий код сам решает, чем это
// подменить (обычно resolveGicsSector's static table).

final quickGicsSectorProvider =
    FutureProvider.family<GicsSector?, String>((ref, ticker) async {
  final repo = ref.read(sectorRepositoryProvider);
  return repo.getCachedSector(ticker);
});
