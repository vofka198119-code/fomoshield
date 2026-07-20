import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sector_cache_entry.dart';

// ---------------------------------------------------------------------------
// SectorDao — отдельное хранилище секторов компаний
// ---------------------------------------------------------------------------
// Хранит SectorCacheEntry в SharedPreferences как JSON-карту. Зеркало
// LogoDao — та же структура хранения, другой ключ.
// Не имеет TTL — данные хранятся навсегда.
// ---------------------------------------------------------------------------

class SectorDao {
  static const String _storageKey = 'sector_cache';

  /// Возвращает сектор для тикера, или null если не найден.
  Future<SectorCacheEntry?> getSector(String ticker) async {
    final key = ticker.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(_storageKey);
    if (jsonMap == null) return null;

    try {
      final map = Map<String, dynamic>.from(json.decode(jsonMap) as Map);
      final entryJson = map[key];
      if (entryJson == null) return null;
      return SectorCacheEntry.fromJson(
        Map<String, dynamic>.from(entryJson as Map),
      );
    } catch (e) {
      debugPrint('❌ SectorDao.getSector error for $ticker: $e');
      return null;
    }
  }

  /// Возвращает ВСЕ закэшированные сектора — используется для прогрева
  /// синхронного in-memory кэша движка при старте приложения.
  Future<Map<String, SectorCacheEntry>> getAllSectors() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(_storageKey);
    if (jsonMap == null) return {};

    try {
      final map = Map<String, dynamic>.from(json.decode(jsonMap) as Map);
      return map.map(
        (key, value) => MapEntry(
          key,
          SectorCacheEntry.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    } catch (e) {
      debugPrint('❌ SectorDao.getAllSectors error: $e');
      return {};
    }
  }

  /// Сохраняет сектор в постоянное хранилище.
  Future<void> saveSector(SectorCacheEntry entry) async {
    final key = entry.ticker.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(_storageKey);
    final map = <String, dynamic>{};

    if (jsonMap != null) {
      try {
        map.addAll(Map<String, dynamic>.from(json.decode(jsonMap) as Map));
      } catch (_) {}
    }

    map[key] = entry.toJson();
    await prefs.setString(_storageKey, json.encode(map));
  }
}
