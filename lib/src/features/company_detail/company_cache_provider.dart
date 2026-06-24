import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Per-Company 4-Hour Cache (separate from market-level cache)
// ---------------------------------------------------------------------------

class _CompanyCacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CompanyCacheEntry(this.data, this.timestamp);

  bool get isValid => DateTime.now().difference(timestamp).inHours < 4;
}

class CompanyCacheManager {
  final Map<String, _CompanyCacheEntry> _cache = {};

  /// Returns cached data if valid (less than 4 hours old), or null.
  Map<String, dynamic>? get(String ticker) {
    final key = ticker.toUpperCase();
    final entry = _cache[key];
    if (entry == null || !entry.isValid) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  /// Store data for a ticker with the current timestamp.
  void set(String ticker, Map<String, dynamic> data) {
    _cache[ticker.toUpperCase()] = _CompanyCacheEntry(data, DateTime.now());
  }

  /// Invalidate cache for a specific ticker.
  void invalidate(String ticker) {
    _cache.remove(ticker.toUpperCase());
  }

  /// Invalidate all company caches.
  void invalidateAll() {
    _cache.clear();
  }
}

final companyCacheProvider = Provider<CompanyCacheManager>((ref) {
  final manager = CompanyCacheManager();
  ref.onDispose(() => manager.invalidateAll());
  return manager;
});
