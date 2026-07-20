import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gics_sector_mapper.dart';
import 'sector_dao.dart';
import 'sector_repository.dart';

// ---------------------------------------------------------------------------
// SectorRepository Provider
// ---------------------------------------------------------------------------

final sectorRepositoryProvider = Provider<SectorRepository>((ref) {
  return SectorRepository(dao: SectorDao());
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
