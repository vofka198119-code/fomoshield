import 'package:flutter/foundation.dart';
import '../models/sector_cache_entry.dart';
import '../services/gics_sector_mapper.dart';
import '../../shared/services/finnhub_service.dart';
import 'sector_dao.dart';

// ---------------------------------------------------------------------------
// SectorRepository — управление загрузкой и кэшированием секторов компаний
// ---------------------------------------------------------------------------
// Логика (зеркало LogoRepository):
//   1. Проверить SectorDao (постоянное хранилище)
//   2. Если есть — вернуть сектор
//   3. Если нет — запросить profile Finnhub, извлечь finnhubIndustry,
//      смэппить в GicsSector, сохранить в SectorDao, вернуть
// Каждый успешный резолв также пишется в резолвер движка (write-through в
// gics_sector_mapper.dart's _liveCache) — так синхронный tick loop видит
// результат сразу, без await.
// ---------------------------------------------------------------------------

class SectorRepository {
  final SectorDao _dao;
  final FinnhubService _api;

  SectorRepository({
    SectorDao? dao,
    FinnhubService? api,
  })  : _dao = dao ?? SectorDao(),
        _api = api ?? FinnhubService();

  /// Возвращает кэшированный сектор для тикера без загрузки.
  Future<GicsSector?> getCachedSector(String ticker) async {
    final entry = await _dao.getSector(ticker);
    if (entry == null) return null;
    return _parseGicsSector(entry.gicsSector);
  }

  /// Загружает сектор, если его нет в кэше. Возвращает GicsSector (из
  /// кэша или свежезагруженный), или null если Finnhub не дал классифи-
  /// цируемой индустрии — в этом случае вызывающий код падает обратно на
  /// статическую эвристику resolveGicsSector, ничего не кэшируется.
  Future<GicsSector?> loadSector(String ticker) async {
    final key = ticker.trim().toUpperCase();

    // 1. Проверить кэш
    final cached = await _dao.getSector(key);
    if (cached != null) {
      final sector = _parseGicsSector(cached.gicsSector);
      setLiveGicsSector(key, sector);
      return sector;
    }

    // 2. Если нет в кэше — загрузить profile и смэппить
    try {
      final profile = await _api.companyProfile(key);
      final industry = profile['finnhubIndustry'] as String?;
      if (industry == null || industry.isEmpty) {
        debugPrint('⚠️ SectorRepository: no finnhubIndustry for $key');
        return null;
      }

      final sector = finnhubIndustryToGics[industry];
      if (sector == null) {
        debugPrint(
          '⚠️ SectorRepository: unmapped finnhubIndustry "$industry" for $key',
        );
        return null;
      }

      final entry = SectorCacheEntry(
        ticker: key,
        gicsSector: sector.name,
        finnhubIndustry: industry,
        createdAt: DateTime.now(),
      );
      await _dao.saveSector(entry);
      setLiveGicsSector(key, sector);

      return sector;
    } catch (e) {
      debugPrint('❌ SectorRepository.loadSector error for $key: $e');
      return null;
    }
  }

  /// Прогревает in-memory кэш движка (gics_sector_mapper.dart's
  /// _liveCache) из постоянного хранилища — вызывать один раз при
  /// старте приложения, чтобы тикеры из прошлых сессий были доступны
  /// синхронно сразу, а не только после повторной покупки.
  Future<void> hydrateLiveCache() async {
    final all = await _dao.getAllSectors();
    final parsed = all.map(
      (ticker, entry) => MapEntry(ticker, _parseGicsSector(entry.gicsSector)),
    );
    hydrateLiveGicsSectorCache(parsed);
  }

  GicsSector? _parseGicsSector(String name) {
    if (name.isEmpty) return null;
    for (final s in GicsSector.values) {
      if (s.name == name) return s;
    }
    return null;
  }
}
