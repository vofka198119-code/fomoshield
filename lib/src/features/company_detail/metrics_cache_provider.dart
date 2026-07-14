import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Per-Company 30-Day Metrics Cache (финпоказатели: P/E, дивиденды, маржа…)
// ---------------------------------------------------------------------------
// Отдельный долгоживущий кэш для сырых финансовых метрик Finnhub.
// Данные меняются редко (раз в квартал), поэтому TTL = 30 дней.
//
// Логика:
//   — При заходе на страницу компании проверяем metrics cache.
//   — Если метрики есть и < 30 дней → используем их для Key Metrics.
//   — Если устарели → запрос к Finnhub → сохраняем.
// ---------------------------------------------------------------------------

class _MetricsCacheEntry {
  final Map<String, dynamic> metricsData;
  final DateTime timestamp;

  _MetricsCacheEntry(this.metricsData, this.timestamp);

  bool get isValid => DateTime.now().difference(timestamp).inDays < 30;
}

class MetricsCacheManager {
  final Map<String, _MetricsCacheEntry> _cache = {};

  /// Returns cached metrics if valid (< 30 days), or null.
  Map<String, dynamic>? get(String ticker) {
    final key = ticker.toUpperCase();
    final entry = _cache[key];
    if (entry == null || !entry.isValid) {
      _cache.remove(key);
      return null;
    }
    return Map<String, dynamic>.from(entry.metricsData);
  }

  /// Store metrics data for a ticker with current timestamp.
  void set(String ticker, Map<String, dynamic> metricsData) {
    _cache[ticker.toUpperCase()] = _MetricsCacheEntry(
      Map<String, dynamic>.from(metricsData),
      DateTime.now(),
    );
  }

  /// Invalidate cache for a specific ticker.
  void invalidate(String ticker) {
    _cache.remove(ticker.toUpperCase());
  }

  /// Invalidate all metrics caches.
  void invalidateAll() {
    _cache.clear();
  }
}

final metricsCacheProvider = Provider<MetricsCacheManager>((ref) {
  final manager = MetricsCacheManager();
  ref.onDispose(() => manager.invalidateAll());
  return manager;
});
