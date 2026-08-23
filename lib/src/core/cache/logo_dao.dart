import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/logo_cache_entry.dart';

// ---------------------------------------------------------------------------
// LogoDao — отдельное хранилище логотипов компаний
// ---------------------------------------------------------------------------
// Хранит LogoCacheEntry в SharedPreferences — один ключ на тикер, плюс
// небольшой индекс тикеров (для getAllEntries). Раньше всё хранилось одним
// общим JSON-блобом под ключом _legacyStorageKey: каждое чтение/запись
// декодировало/перекодировало ВЕСЬ кэш ради одного тикера, и saveLogo делал
// неатомарный read-modify-write — параллельные сохранения для разных
// тикеров (например, 8 одновременных подгрузок логотипов в списке) могли
// затереть записи друг друга. Один ключ на тикер убирает обе проблемы:
// чтение/запись касается только своего тикера, конкурентные записи для
// разных тикеров больше не пересекаются.
// Не имеет TTL — данные хранятся навсегда.
// Не зависит от StockCache и других DAO.
// ---------------------------------------------------------------------------

class LogoDao {
  static const String _legacyStorageKey = 'logo_cache';
  static const String _indexKey = 'logo_cache_v2_index';
  static String _entryKey(String ticker) => 'logo_cache_v2:$ticker';

  bool _migrated = false;

  /// One-time move of any pre-existing single-blob cache into the new
  /// per-ticker keys, so upgrading users don't silently lose their whole
  /// logo cache and mass-refetch from Finnhub — see project memory on the
  /// app's prior Finnhub rate-limit incidents.
  Future<void> _migrateLegacyIfNeeded(SharedPreferences prefs) async {
    if (_migrated) return;
    _migrated = true;
    final legacyJson = prefs.getString(_legacyStorageKey);
    if (legacyJson == null) return;
    try {
      final map = Map<String, dynamic>.from(json.decode(legacyJson) as Map);
      final tickers = <String>{...(prefs.getStringList(_indexKey) ?? [])};
      for (final entry in map.entries) {
        await prefs.setString(_entryKey(entry.key), json.encode(entry.value));
        tickers.add(entry.key);
      }
      await prefs.setStringList(_indexKey, tickers.toList());
    } catch (e) {
      debugPrint('❌ LogoDao migration error: $e');
    } finally {
      await prefs.remove(_legacyStorageKey);
    }
  }

  /// Возвращает логотип для тикера, или null если не найден.
  Future<LogoCacheEntry?> getLogo(String ticker) async {
    final key = ticker.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);
    final raw = prefs.getString(_entryKey(key));
    if (raw == null) return null;

    try {
      return LogoCacheEntry.fromJson(
        Map<String, dynamic>.from(json.decode(raw) as Map),
      );
    } catch (e) {
      debugPrint('❌ LogoDao.getLogo error for $ticker: $e');
      return null;
    }
  }

  /// Сохраняет логотип в постоянное хранилище.
  Future<void> saveLogo(LogoCacheEntry entry) async {
    final key = entry.ticker.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);
    await prefs.setString(_entryKey(key), json.encode(entry.toJson()));

    final index = prefs.getStringList(_indexKey) ?? [];
    if (!index.contains(key)) {
      await prefs.setStringList(_indexKey, [...index, key]);
    }
  }

  /// Проверяет, существует ли логотип для тикера.
  Future<bool> hasLogo(String ticker) async {
    final entry = await getLogo(ticker);
    return entry != null;
  }

  /// Возвращает ВСЕ закэшированные записи — используется для прогрева
  /// синхронного in-memory кэша сектора движка при старте приложения
  /// (см. SectorRepository.hydrateLiveCache).
  Future<Map<String, LogoCacheEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIfNeeded(prefs);
    final index = prefs.getStringList(_indexKey) ?? [];
    final result = <String, LogoCacheEntry>{};
    for (final ticker in index) {
      final raw = prefs.getString(_entryKey(ticker));
      if (raw == null) continue;
      try {
        result[ticker] = LogoCacheEntry.fromJson(
          Map<String, dynamic>.from(json.decode(raw) as Map),
        );
      } catch (e) {
        debugPrint('❌ LogoDao.getAllEntries error for $ticker: $e');
      }
    }
    return result;
  }
}
