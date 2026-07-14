import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/user_data_service.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../core/cache/logo_dao.dart';
import '../../core/models/logo_cache_entry.dart';
import '../../core/services/company_tag_mapper.dart';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

class ShieldSignal {
  final String level; // 'fear' | 'neutral' | 'greed'
  final String label;
  final double spyChange;
  final double spyPrice;

  const ShieldSignal({
    required this.level,
    required this.label,
    required this.spyChange,
    required this.spyPrice,
  });

  factory ShieldSignal.fromQuote(Map<String, dynamic> quote) {
    final change = ((quote['dp'] as num?)?.toDouble() ?? 0);
    final price = ((quote['c'] as num?)?.toDouble() ?? 0);

    String level;
    String label;
    if (change > 0.5) {
      level = 'greed';
      label = 'Greed — market is overheating';
    } else if (change < -0.5) {
      level = 'fear';
      label = 'Fear — market is pessimistic';
    } else {
      level = 'neutral';
      label = 'Neutral — market is calm';
    }

    return ShieldSignal(
      level: level,
      label: label,
      spyChange: change,
      spyPrice: price,
    );
  }

  factory ShieldSignal.initial() {
    return const ShieldSignal(
      level: 'neutral',
      label: 'Loading...',
      spyChange: 0.0,
      spyPrice: 0.0,
    );
  }
}

class MarketIndex {
  final String name;
  final String symbol;
  final double price;
  final double change;

  const MarketIndex({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
  });

  factory MarketIndex.fromQuote(
    String name,
    String symbol,
    Map<String, dynamic> quote,
  ) {
    return MarketIndex(
      name: name,
      symbol: symbol,
      price: ((quote['c'] as num?)?.toDouble() ?? 0),
      change: ((quote['dp'] as num?)?.toDouble() ?? 0),
    );
  }
}

class CalendarEvent {
  final String symbol;
  final String type; // 'earnings' | 'dividend'
  final DateTime date;
  final String title;
  final String? epsEstimate; // for earnings
  final double? amount; // for dividends
  final String? quarter;
  final int? year;
  final String? hour; // 'bmo' | 'amc' | 'dmh' — before open / after close / during market

  const CalendarEvent({
    required this.symbol,
    required this.type,
    required this.date,
    required this.title,
    this.epsEstimate,
    this.amount,
    this.quarter,
    this.year,
    this.hour,
  });
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
  _CacheEntry<ShieldSignal>? _signal;

  List<MarketIndex>? get cachedIndices =>
      (_indices != null && _indices!.isValid) ? _indices!.data : null;

  ShieldSignal? get cachedSignal =>
      (_signal != null && _signal!.isValid) ? _signal!.data : null;

  void setIndices(List<MarketIndex> data) =>
      _indices = _CacheEntry(data, DateTime.now());

  void setSignal(ShieldSignal data) =>
      _signal = _CacheEntry(data, DateTime.now());

  void invalidate() {
    _indices = null;
    _signal = null;
  }
}

class EventsCache {
  _CacheEntry<List<CalendarEvent>>? _events;

  List<CalendarEvent>? get cachedEvents =>
      (_events != null && _events!.isValid) ? _events!.data : null;

  void setEvents(List<CalendarEvent> data) =>
      _events = _CacheEntry(data, DateTime.now(), ttlHours: 12);

  void invalidate() => _events = null;
}

final eventsCacheProvider = Provider<EventsCache>((ref) => EventsCache());

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
    state = symbols;
    _saveLocal();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
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
// Shield Signal Provider (uses yesterday's data + 4h cache)
// ---------------------------------------------------------------------------

final shieldSignalProvider = FutureProvider<ShieldSignal>((ref) async {
  final cache = ref.read(marketCacheProvider);

  // Check cache first
  final cached = cache.cachedSignal;
  if (cached != null) return cached;

  try {
    final api = FinnhubService();
    final quote = await api.previousTradingDayQuote('SPY');
    final signal = ShieldSignal.fromQuote(quote);
    cache.setSignal(signal);
    return signal;
  } catch (e) {
    debugPrint('❌ shieldSignalProvider error: $e');
    return ShieldSignal.initial();
  }
});

// ---------------------------------------------------------------------------
// Market Indices Provider (uses yesterday's data + 4h cache)
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

// ---------------------------------------------------------------------------
// Watchlist Quote Cache (4-hour TTL per symbol)
// ---------------------------------------------------------------------------

class _WatchlistQuoteEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _WatchlistQuoteEntry(this.data, this.timestamp);

  bool get isValid => DateTime.now().difference(timestamp).inHours < 4;
}

class WatchlistQuoteCache {
  final Map<String, _WatchlistQuoteEntry> _cache = {};

  Map<String, dynamic>? get(String symbol) {
    final key = symbol.toUpperCase();
    final entry = _cache[key];
    if (entry == null || !entry.isValid) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  void set(String symbol, Map<String, dynamic> data) {
    _cache[symbol.toUpperCase()] = _WatchlistQuoteEntry(data, DateTime.now());
  }

  void invalidate(String symbol) {
    _cache.remove(symbol.toUpperCase());
  }
}

final watchlistQuoteCacheProvider = Provider<WatchlistQuoteCache>((ref) {
  return WatchlistQuoteCache();
});

// ---------------------------------------------------------------------------
// Watchlist Quotes Provider (4h cache + 1s delay between requests)
// ---------------------------------------------------------------------------

final watchlistQuotesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final symbols = ref.watch(watchlistSymbolsProvider);
  if (symbols.isEmpty) return [];

  final quoteCache = ref.read(watchlistQuoteCacheProvider);
  final api = FinnhubService();
  final List<Map<String, dynamic>> quotes = [];

  for (final s in symbols) {
    // Check 4h cache first
    final cached = quoteCache.get(s);
    if (cached != null) {
      quotes.add(cached);
      continue;
    }

    try {
      final profile = await api.companyProfile(s);
      final quote = await api.previousTradingDayQuote(s);

      // Получить логотип из LogoCache (если есть)
      final logoDao = LogoDao();
      final cachedLogo = await logoDao.getLogo(s);
      String? logoUrl = cachedLogo?.logoUrl;

      // Если нет в кэше — попробовать загрузить логотип (fire-and-forget)
      if (logoUrl == null) {
        final weburl = profile['weburl'] as String?;
        String? domain;
        if (weburl != null && weburl.isNotEmpty) {
          try {
            final uri = Uri.parse(weburl);
            domain = uri.host;
            if (domain.startsWith('www.')) domain = domain.substring(4);
          } catch (_) {}
        }
        final finnhubLogo = profile['logo'] as String?;
        logoUrl = finnhubLogo ??
            (domain != null ? 'https://logo.clearbit.com/$domain' : null);

        // Сохранить в кэш асинхронно
        if (logoUrl != null) {
          final entry = LogoCacheEntry(
            ticker: s.toUpperCase(),
            companyName: profile['name'] as String? ?? s,
            domain: domain,
            logoUrl: logoUrl,
            createdAt: DateTime.now(),
          );
          logoDao.saveLogo(entry); // fire-and-forget
        }
      }

      final name = profile['name'] as String? ?? s;
      final tag = CompanyTagMapper.tag(s, companyName: name)?.tag;

      final data = {
        'symbol': s,
        'name': name,
        'tag': tag,
        'description': profile['description'] as String? ?? '',
        'weburl': profile['weburl'] as String?,
        'domain': _extractDomain(profile['weburl'] as String?),
        'logoUrl': logoUrl,
        'price': ((quote['c'] as num?)?.toDouble() ?? 0),
        'change': ((quote['dp'] as num?)?.toDouble() ?? 0),
      };
      quoteCache.set(s, Map<String, dynamic>.from(data));
      quotes.add(data);
    } catch (_) {
      quotes.add({
        'symbol': s,
        'name': s,
        'tag': CompanyTagMapper.tag(s, companyName: s)?.tag,
        'description': '',
        'weburl': null,
        'domain': null,
        'logoUrl': null,
        'price': 0.0,
        'change': 0.0,
      });
    }

    // 1-second delay between requests to prevent API rate-limiting
    if (symbols.length > 1) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  return quotes;
});

// ---------------------------------------------------------------------------
// Calendar Events Provider (Watchlist-aware, 12h cache)
// ---------------------------------------------------------------------------

String _quarterLabel(int month) {
  if (month <= 3) return 'Q1';
  if (month <= 6) return 'Q2';
  if (month <= 9) return 'Q3';
  return 'Q4';
}

final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final symbols = ref.watch(watchlistSymbolsProvider);
  if (symbols.isEmpty) return [];

  // Check 12h cache
  final cache = ref.read(eventsCacheProvider);
  final cached = cache.cachedEvents;
  if (cached != null) return cached;

  final api = FinnhubService();
  final now = DateTime.now();
  final List<CalendarEvent> events = [];

  for (final symbol in symbols) {
    // --- Earnings ---
    try {
      final earnings = await api.earningsCalendar(
        symbol: symbol,
        daysAhead: 90,
      );
      for (final item in earnings) {
        final data = Map<String, dynamic>.from(item);
        final dateStr = data['date'] as String?;
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null ||
            date.isBefore(now.subtract(const Duration(days: 1)))) {
          continue;
        }

        final quarterRaw = data['quarter'] as int?;
        final yearRaw = data['year'] as int?;
        final quarter = quarterRaw != null
            ? 'Q$quarterRaw'
            : _quarterLabel(date.month);
        final year = yearRaw ?? date.year;
        final hour = data['hour'] as String?;

        events.add(
          CalendarEvent(
            symbol: symbol,
            type: 'earnings',
            date: date,
            title: '$quarter $year Earnings Release',
            epsEstimate: (data['epsEstimate'] as num?)?.toStringAsFixed(2),
            quarter: quarter,
            year: year,
            hour: hour,
          ),
        );
      }
    } catch (_) {
      // Ignore individual symbol errors
    }

    // --- Dividends ---
    try {
      final dividends = await api.dividendsCalendar(
        symbol: symbol,
        daysAhead: 90,
      );
      for (final item in dividends) {
        final data = Map<String, dynamic>.from(item);
        // Try exDate first, fall back to date
        final dateStr = data['exDate'] as String? ?? data['date'] as String?;
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null ||
            date.isBefore(now.subtract(const Duration(days: 1)))) {
          continue;
        }

        events.add(
          CalendarEvent(
            symbol: symbol,
            type: 'dividend',
            date: date,
            title: 'Dividend Ex-Date',
            amount:
                (data['amount'] as num?)?.toDouble() ??
                (data['dividend'] as num?)?.toDouble(),
          ),
        );
      }
    } catch (_) {
      // Ignore individual symbol errors
    }

    // 1-second delay between symbols to prevent API rate-limiting
    if (symbols.length > 1) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Sort by date ascending and cache
  events.sort((a, b) => a.date.compareTo(b.date));
  cache.setEvents(events);
  return events;
});

// ---------------------------------------------------------------------------
// News Provider (Fetches general market news)
// ---------------------------------------------------------------------------

final newsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final api = FinnhubService();
    final raw = await api.generalNews();
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .take(5)
        .toList();
  } catch (e) {
    debugPrint('❌ newsProvider error: $e');
    return [];
  }
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Извлекает домен из URL компании.
/// e.g. "https://www.apple.com" → "apple.com"
String? _extractDomain(String? weburl) {
  if (weburl == null || weburl.isEmpty) return null;
  try {
    final uri = Uri.parse(weburl);
    final host = uri.host;
    if (host.startsWith('www.')) return host.substring(4);
    return host;
  } catch (_) {
    return null;
  }
}
