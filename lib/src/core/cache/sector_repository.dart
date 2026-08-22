import 'package:flutter/foundation.dart';
import '../services/gics_sector_mapper.dart';
import 'logo_dao.dart';
import 'logo_repository.dart';

// ---------------------------------------------------------------------------
// SectorRepository — теперь тонкая обёртка над LogoDao/LogoRepository
// ---------------------------------------------------------------------------
// Раньше держал собственный SectorDao и свой собственный запрос к
// /profile/:symbol — тот же самый эндпоинт, что LogoRepository уже
// вызывает ради логотипа. Объединено 2026-08-22: логотип, имя и сектор
// теперь одна постоянная запись (LogoCacheEntry) и один фетч на тикер —
// см. logo_repository.dart's doc comment для деталей.
//
// Публичный API (getCachedSector/loadSector/hydrateLiveCache) намеренно
// не изменился, чтобы ни один вызывающий код (sector_providers.dart и
// далее) не пришлось трогать.
// ---------------------------------------------------------------------------

class SectorRepository {
  final LogoDao _logoDao;
  final LogoRepository _logoRepo;

  SectorRepository({LogoDao? dao, LogoRepository? logoRepo})
    : _logoDao = dao ?? LogoDao(),
      _logoRepo = logoRepo ?? LogoRepository();

  /// Возвращает кэшированный сектор для тикера без загрузки.
  Future<GicsSector?> getCachedSector(String ticker) async {
    final entry = await _logoDao.getLogo(ticker);
    if (entry?.gicsSector == null) return null;
    return _parseGicsSector(entry!.gicsSector!);
  }

  /// Загружает сектор, если его нет в кэше. Возвращает GicsSector (из
  /// кэша или свежезагруженный), или null если Finnhub не дал классифи-
  /// цируемой индустрии.
  Future<GicsSector?> loadSector(String ticker) async {
    final key = ticker.trim().toUpperCase();

    final cached = await _logoDao.getLogo(key);
    if (cached != null && cached.gicsSector != null) {
      final sector = _parseGicsSector(cached.gicsSector!);
      setLiveGicsSector(key, sector);
      return sector;
    }

    // Не резолвился ещё (или профиль вообще ни разу не загружался) —
    // LogoRepository.loadLogoSymbol сам заполнит ОБЕ половины записи из
    // одного и того же ответа /profile/:symbol.
    try {
      await _logoRepo.loadLogoSymbol(key);
    } catch (e) {
      debugPrint('❌ SectorRepository.loadSector error for $key: $e');
      return null;
    }

    final refreshed = await _logoDao.getLogo(key);
    if (refreshed?.gicsSector == null) return null;
    final sector = _parseGicsSector(refreshed!.gicsSector!);
    setLiveGicsSector(key, sector);
    return sector;
  }

  /// Прогревает in-memory кэш движка (gics_sector_mapper.dart's
  /// _liveCache) из постоянного хранилища — вызывать один раз при
  /// старте приложения, чтобы тикеры из прошлых сессий были доступны
  /// синхронно сразу, а не только после повторной покупки.
  Future<void> hydrateLiveCache() async {
    final all = await _logoDao.getAllEntries();
    final parsed = <String, GicsSector?>{};
    for (final entry in all.values) {
      if (entry.gicsSector == null || entry.gicsSector!.isEmpty) continue;
      parsed[entry.ticker] = _parseGicsSector(entry.gicsSector!);
    }
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
