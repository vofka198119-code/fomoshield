import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Per-Company 30-Day Score Cache
// ---------------------------------------------------------------------------
// Отдельный долгоживущий кэш для результатов ScoringEngine (FS Score,
// 6 маркеров, dividend_trap_penalty). Данные финпоказателей обновляются
// раз в 30 дней для экономии API-трафика Finnhub.
//
// Логика:
//   — При заходе на страницу компании проверяем score cache.
//   — Если score есть и < 30 дней → не дёргаем Finnhub metrics,
//     используем кэшированный score + свежие profile/quote.
//   — Если score устарел (≥ 30 дней) → полный запрос к Finnhub →
//     ScoringEngine.calculate() → сохраняем в score cache.
// ---------------------------------------------------------------------------

class _ScoreCacheEntry {
  final Map<String, dynamic> scoreData;
  final DateTime timestamp;

  _ScoreCacheEntry(this.scoreData, this.timestamp);

  bool get isValid => DateTime.now().difference(timestamp).inDays < 30;
}

class ScoreCacheManager {
  final Map<String, _ScoreCacheEntry> _cache = {};

  /// Returns cached score data if valid (less than 30 days old), or null.
  Map<String, dynamic>? get(String ticker) {
    final key = ticker.toUpperCase();
    final entry = _cache[key];
    if (entry == null || !entry.isValid) {
      _cache.remove(key);
      return null;
    }
    return Map<String, dynamic>.from(entry.scoreData);
  }

  /// Store score data for a ticker with current timestamp.
  void set(String ticker, Map<String, dynamic> scoreData) {
    _cache[ticker.toUpperCase()] = _ScoreCacheEntry(
      Map<String, dynamic>.from(scoreData),
      DateTime.now(),
    );
  }

  /// Invalidate cache for a specific ticker.
  void invalidate(String ticker) {
    _cache.remove(ticker.toUpperCase());
  }

  /// Invalidate all score caches.
  void invalidateAll() {
    _cache.clear();
  }
}

final scoreCacheProvider = Provider<ScoreCacheManager>((ref) {
  final manager = ScoreCacheManager();
  ref.onDispose(() => manager.invalidateAll());
  return manager;
});
