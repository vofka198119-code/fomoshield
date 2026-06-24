import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/logo_cache_entry.dart';

// ---------------------------------------------------------------------------
// LogoDao — отдельное хранилище логотипов компаний
// ---------------------------------------------------------------------------
// Хранит LogoCacheEntry в SharedPreferences как JSON-карту.
// Не имеет TTL — данные хранятся навсегда.
// Не зависит от StockCache и других DAO.
// ---------------------------------------------------------------------------

class LogoDao {
  static const String _storageKey = 'logo_cache';

  /// Возвращает логотип для тикера, или null если не найден.
  Future<LogoCacheEntry?> getLogo(String ticker) async {
    final key = ticker.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(_storageKey);
    if (jsonMap == null) return null;

    try {
      final map = Map<String, dynamic>.from(json.decode(jsonMap) as Map);
      final entryJson = map[key];
      if (entryJson == null) return null;
      return LogoCacheEntry.fromJson(
        Map<String, dynamic>.from(entryJson as Map),
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

  /// Проверяет, существует ли логотип для тикера.
  Future<bool> hasLogo(String ticker) async {
    final entry = await getLogo(ticker);
    return entry != null;
  }
}
