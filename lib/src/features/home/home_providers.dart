import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/user_data_service.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

class MarketIndex {
  final String name;
  final String symbol;
  final double price;
  final double change; // percent
  final double changeAbs; // absolute $ move vs previous close

  const MarketIndex({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    this.changeAbs = 0,
  });

  factory MarketIndex.fromQuote(
    String name,
    String symbol,
    Map<String, dynamic> quote,
  ) {
    final price = (quote['c'] as num?)?.toDouble() ?? 0;
    final prevClose = (quote['pc'] as num?)?.toDouble() ?? 0;
    return MarketIndex(
      name: name,
      symbol: symbol,
      price: price,
      change: ((quote['dp'] as num?)?.toDouble() ?? 0),
      changeAbs: price - prevClose,
    );
  }
}

// ---------------------------------------------------------------------------
// Cache Layer (4-hour TTL)
// ---------------------------------------------------------------------------

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final int ttlHours;
  _CacheEntry(this.data, this.timestamp, {this.ttlHours = 4});

  bool get isValid => DateTime.now().difference(timestamp).inHours < ttlHours;
}

class MarketCache {
  _CacheEntry<List<MarketIndex>>? _indices;

  List<MarketIndex>? get cachedIndices =>
      (_indices != null && _indices!.isValid) ? _indices!.data : null;

  void setIndices(List<MarketIndex> data) =>
      _indices = _CacheEntry(data, DateTime.now(), ttlHours: 12);

  void invalidate() {
    _indices = null;
  }
}

final marketCacheProvider = Provider<MarketCache>((ref) => MarketCache());

// ---------------------------------------------------------------------------
// Debounce Utility (1 second)
// ---------------------------------------------------------------------------

class Debouncer {
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), action);
  }

  void dispose() => _timer?.cancel();
}

final debouncerProvider = Provider<Debouncer>((ref) {
  final d = Debouncer();
  ref.onDispose(() => d.dispose());
  return d;
});

// ---------------------------------------------------------------------------
// Watchlist Provider (SharedPreferences + Supabase)
// ---------------------------------------------------------------------------

final watchlistSymbolsProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
      final service = ref.read(userDataServiceProvider);
      final user = ref.watch(currentUserProvider);
      return WatchlistNotifier(service, userId: user?.id);
    });

class WatchlistNotifier extends StateNotifier<List<String>> {
  final UserDataService _supabaseService;
  String? _userId;
  // Guards against _load()'s async SharedPreferences read finishing AFTER
  // loadFromSupabase() and clobbering the just-synced server data with an
  // empty/stale local cache.
  bool _loadedFromSupabase = false;

  WatchlistNotifier(this._supabaseService, {this._userId})
      : super([]) {
    _load();
  }

  String get _key =>
      _userId != null ? 'watchlist_symbols_$_userId' : 'watchlist_symbols';

  /// Set user ID to enable Supabase sync + re-scope local cache.
  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  /// Load watchlist from Supabase data (replaces local).
  void loadFromSupabase(List<String> symbols) {
    if (symbols.isEmpty) return;
    _loadedFromSupabase = true;
    state = symbols;
    _saveLocal();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (_loadedFromSupabase) return;
    final list = prefs.getStringList(_key) ?? [];
    state = list;
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  Future<void> _syncToSupabase() async {
    final uid = _userId;
    if (uid != null) {
      await _supabaseService.saveWatchlist(uid, state);
    }
  }

  Future<void> add(String symbol) async {
    if (state.contains(symbol.toUpperCase())) return;
    final newState = [...state, symbol.toUpperCase()];
    state = newState;
    await _saveLocal();
    _syncToSupabase();
  }

  Future<void> remove(String symbol) async {
    final newState = state.where((s) => s != symbol.toUpperCase()).toList();
    state = newState;
    await _saveLocal();
    _syncToSupabase();
  }

  bool contains(String symbol) => state.contains(symbol.toUpperCase());
}

// ---------------------------------------------------------------------------
// Market Indices Provider (uses yesterday's data + 12h cache)
// ---------------------------------------------------------------------------

final marketIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  final cache = ref.read(marketCacheProvider);

  // Check cache first
  final cached = cache.cachedIndices;
  if (cached != null) return cached;

  try {
    final api = FinnhubService();
    final results = await Future.wait([
      api.previousTradingDayQuote('SPY'),
      api.previousTradingDayQuote('QQQ'),
      api.previousTradingDayQuote('DIA'),
    ]);
    final indices = [
      MarketIndex.fromQuote('S&P 500', 'SPY', results[0]),
      MarketIndex.fromQuote('NASDAQ', 'QQQ', results[1]),
      MarketIndex.fromQuote('DOW JONES', 'DIA', results[2]),
    ];
    cache.setIndices(indices);
    return indices;
  } catch (e) {
    debugPrint('❌ marketIndicesProvider error: $e');
    return [
      const MarketIndex(name: 'S&P 500', symbol: 'SPY', price: 0, change: 0),
      const MarketIndex(name: 'NASDAQ', symbol: 'QQQ', price: 0, change: 0),
      const MarketIndex(name: 'DOW JONES', symbol: 'DIA', price: 0, change: 0),
    ];
  }
});

