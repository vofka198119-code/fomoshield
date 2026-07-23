import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';

/// Talks to Finnhub — partly directly, partly via `scanco-backend` (the
/// Finnhub proxy/cache server, see d:/Projects/scanco-backend), which
/// exists because every device sharing one embedded Finnhub key blows
/// through the free tier's 60 req/min limit once there's more than a
/// handful of concurrent users.
///
/// Routed through the backend (works for ANY symbol, not just a fixed
/// list — see the backend's `/quote` fallback path): [quote] (and
/// therefore [previousTradingDayQuote], which calls it), [candles],
/// [generalNews].
///
/// Still direct to Finnhub (backend has no matching route yet): [search],
/// [companyProfile], [metrics], [companyNews] (per-symbol — the backend
/// only pre-caches news for its fixed `HOT_TICKERS` list, so an arbitrary
/// watchlist symbol wouldn't get real news back from it yet),
/// [earningsCalendar], [dividendsCalendar], [earningsSurprises].
class FinnhubService {
  final Dio _dio;
  final Dio _backendDio;
  final Map<String, _CacheEntry> _cache = {};

  FinnhubService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.finnhubBase,
          queryParameters: {'token': AppConstants.finnhubKey},
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ),
      _backendDio = Dio(
        BaseOptions(
          baseUrl: '${AppConstants.backendBaseUrl}/api/v1',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Mask the token in logs for security
          final uri = options.uri.toString().replaceAll(
            RegExp(r'token=[^&]+'),
            'token=***MASKED***',
          );
          debugPrint('🌐 ➡️ Finnhub REQ: $uri');
          handler.next(options);
        },
        onError: (error, handler) {
          final uri = error.requestOptions.uri.toString().replaceAll(
            RegExp(r'token=[^&]+'),
            'token=***MASKED***',
          );
          debugPrint(
            '🌐 ❌ Finnhub ERROR | $uri | '
            'Status: ${error.response?.statusCode} | '
            'Body: ${error.response?.data} | '
            '${error.message}',
          );
          handler.next(error);
        },
        onResponse: (response, handler) {
          debugPrint(
            '🌐 ✅ Finnhub OK | ${response.requestOptions.path} | '
            'Status: ${response.statusCode}',
          );
          handler.next(response);
        },
      ),
    );
    _backendDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🖥️ ➡️ Backend REQ: ${options.uri}');
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint(
            '🖥️ ❌ Backend ERROR | ${error.requestOptions.uri} | '
            'Status: ${error.response?.statusCode} | ${error.message}',
          );
          handler.next(error);
        },
        onResponse: (response, handler) {
          debugPrint(
            '🖥️ ✅ Backend OK | ${response.requestOptions.path} | '
            'Status: ${response.statusCode}',
          );
          handler.next(response);
        },
      ),
    );
  }

  /// Get from API (top-level JSON object).
  /// Throws if server returns an error object.
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = '$path?${params?.toString() ?? ''}';
    final cached = _getCached(cacheKey);
    if (cached != null) return cached.data as Map<String, dynamic>;

    final response = await _dio.get(path, queryParameters: params);
    // Safely cast response – Finnhub always returns JSON objects for _get endpoints
    if (response.data is! Map) {
      throw Exception(
        'Finnhub $path: unexpected response type ${response.data.runtimeType}',
      );
    }
    final data = Map<String, dynamic>.from(response.data);
    // Check for Finnhub error response
    if (data.containsKey('error')) {
      throw Exception('Finnhub $path: ${data['error']}');
    }
    _setCache(cacheKey, data);
    return data;
  }

  /// Get from API (top-level JSON array).
  /// If server returns an error object, throws a descriptive exception.
  Future<List<dynamic>> _getRaw(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = 'raw:$path?${params?.toString() ?? ''}';
    final cached = _getCachedRaw(cacheKey);
    if (cached != null) return cached;

    final response = await _dio.get(path, queryParameters: params);
    if (response.data is List) {
      final data = List<dynamic>.from(response.data);
      _setCacheRaw(cacheKey, data);
      return data;
    }
    // Finnhub sometimes returns {"error":"...","message":"..."} on failure
    if (response.data is Map) {
      final errorMap = Map<String, dynamic>.from(response.data);
      final errMsg =
          errorMap['error'] as String? ??
          errorMap['message'] as String? ??
          'Unknown API error';
      throw Exception('Finnhub $path: $errMsg');
    }
    throw Exception(
      'Finnhub $path: unexpected response type ${response.data.runtimeType}',
    );
  }

  /// Get from scanco-backend (top-level JSON object). Same cache/error
  /// handling as [_get] but against `_backendDio`, with a `backend:`-
  /// prefixed cache key so it can never collide with a direct-Finnhub
  /// cache entry for a differently-shaped path. Callers are expected to
  /// catch and fall back to [_get]/[_getRaw] — the backend may not be
  /// deployed yet, or may be temporarily down.
  Future<Map<String, dynamic>> _getFromBackend(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = 'backend:$path?${params?.toString() ?? ''}';
    final cached = _getCached(cacheKey);
    if (cached != null) return cached.data as Map<String, dynamic>;

    final response = await _backendDio.get(path, queryParameters: params);
    if (response.data is! Map) {
      throw Exception(
        'Backend $path: unexpected response type ${response.data.runtimeType}',
      );
    }
    final data = Map<String, dynamic>.from(response.data);
    if (data.containsKey('error')) {
      throw Exception('Backend $path: ${data['error']}');
    }
    _setCache(cacheKey, data);
    return data;
  }

  /// Get from scanco-backend (top-level JSON array). See [_getFromBackend].
  Future<List<dynamic>> _getRawFromBackend(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = 'backend-raw:$path?${params?.toString() ?? ''}';
    final cached = _getCachedRaw(cacheKey);
    if (cached != null) return cached;

    final response = await _backendDio.get(path, queryParameters: params);
    if (response.data is List) {
      final data = List<dynamic>.from(response.data);
      _setCacheRaw(cacheKey, data);
      return data;
    }
    throw Exception(
      'Backend $path: unexpected response type ${response.data.runtimeType}',
    );
  }

  // ---------------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------------

  _CacheEntry? _getCached(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.time).inMinutes >
        AppConstants.cacheTTLMinutes) {
      _cache.remove(key);
      return null;
    }
    return entry;
  }

  List<dynamic>? _getCachedRaw(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.time).inMinutes >
        AppConstants.cacheTTLMinutes) {
      _cache.remove(key);
      return null;
    }
    return entry.data as List<dynamic>?;
  }

  void _setCache(String key, Map<String, dynamic> data) =>
      _cache[key] = _CacheEntry(data, DateTime.now());

  void _setCacheRaw(String key, List<dynamic> data) =>
      _cache[key] = _CacheEntry(data, DateTime.now());

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Allowed exchanges for search results.
  /// Empty = US (no suffix). .L = London Stock Exchange.
  /// We keep ETFs (type='ETF') regardless of exchange.
  static const _allowedExchangeSuffixes = {'', '.US', '.L'};

  /// Exchanges to explicitly exclude (e.g. Warsaw, Mexico, etc.)
  static const _excludedSuffixes = {
    '.WA',  // Warsaw
    '.MX',  // Mexico
    '.BC',  // Colombia
    '.LM',  // Chile
    '.IS',  // Israel
    '.TA',  // Tel Aviv
    '.SS',  // Shanghai
    '.SZ',  // Shenzhen
    '.HK',  // Hong Kong
    '.TW',  // Taiwan
    '.KS',  // Korea
    '.KQ',  // KOSDAQ
    '.T',   // Tokyo
    '.F',   // Frankfurt (we keep .DE for Xetra)
    '.BE',  // Berlin
    '.MU',  // Munich
    '.HA',  // Hanover
    '.SG',  // Singapore
    '.OL',  // Oslo
    '.ST',  // Stockholm
    '.CO',  // Copenhagen
    '.HE',  // Helsinki
    '.VI',  // Vienna
    '.AT',  // Athens
    '.IR',  // Irish
    '.LS',  // Lisbon
    '.PA',  // Euronext Paris
    '.AS',  // Euronext Amsterdam
    '.BR',  // Euronext Brussels
  };

  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.length < AppConstants.minSearchChars) return [];
    // Finnhub /search returns { "count": N, "result": [...] }
    final data = await _get('/search', params: {'q': query});
    final items = data['result'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> results = [];
    final seen = <String>{};

    for (final item in items) {
      final m = Map<String, dynamic>.from(item);
      final symbol = m['symbol'] as String? ?? '';
      final type = (m['type'] as String? ?? '').toUpperCase();

      // Always keep ETFs regardless of exchange
      if (type == 'ETF') {
        final baseSymbol = symbol.split('.')[0];
        if (seen.contains(baseSymbol)) continue;
        seen.add(baseSymbol);
        results.add(m);
        if (results.length >= AppConstants.maxSearchResults) break;
        continue;
      }

      // Extract exchange suffix
      final exchangeSuffix = symbol.contains('.')
          ? '.${symbol.split('.').last}'
          : '';

      // Skip explicitly excluded exchanges
      if (_excludedSuffixes.contains(exchangeSuffix)) continue;

      // Check if exchange is allowed
      if (!_allowedExchangeSuffixes.contains(exchangeSuffix)) continue;

      // Deduplication: prefer US ticker (no dot) or .US
      final baseSymbol = symbol.split('.')[0];
      if (seen.contains(baseSymbol)) continue;

      seen.add(baseSymbol);
      results.add(m);
      if (results.length >= AppConstants.maxSearchResults) break;
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // Company Profile
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> companyProfile(String symbol) async =>
      _get('/stock/profile2', params: {'symbol': symbol});

  // ---------------------------------------------------------------------------
  // Quote
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> quote(String symbol) async {
    try {
      final data = await _getFromBackend('/quote/$symbol');
      // Reshape the backend's {price, change, changePercent, high, low,
      // open, prevClose, timestamp} back into Finnhub's own raw
      // {c,d,dp,h,l,o,pc,t} shape, so every existing caller (portfolio/
      // home/stress-test buy flow/…) keeps working unchanged.
      return {
        'c': data['price'],
        'd': data['change'],
        'dp': data['changePercent'],
        'h': data['high'],
        'l': data['low'],
        'o': data['open'],
        'pc': data['prevClose'],
        't': data['timestamp'],
      };
    } catch (e) {
      // Backend not deployed yet / temporarily down — fall back to
      // Finnhub directly so the app keeps working during the migration.
      debugPrint('⚠️ Backend quote($symbol) failed, falling back direct: $e');
      return _get('/quote', params: {'symbol': symbol});
    }
  }

  // ---------------------------------------------------------------------------
  // Previous Trading Day Quote (yesterday's close via candles)
  // ---------------------------------------------------------------------------

  /// Returns a quote-like map for the current trading data.
  /// Keys: 'c' (close), 'dp' (change%), 'pc' (prev close for reference)
  ///
  /// Uses the FREE `/quote` endpoint (no date parameters needed).
  /// Avoids `/stock/candle` which is a PAID endpoint.
  Future<Map<String, dynamic>> previousTradingDayQuote(String symbol) async {
    try {
      // /quote works on free Finnhub tier — returns real-time price, change, prev close
      final q = await quote(symbol);
      final c = (q['c'] as num?)?.toDouble() ?? 0;
      final dp = (q['dp'] as num?)?.toDouble() ?? 0;
      final pc = (q['pc'] as num?)?.toDouble() ?? 0;
      debugPrint(
        '📊 quote($symbol): c=$c dp=$dp pc=$pc',
      );
      return {'c': c, 'dp': dp, 'pc': pc};
    } catch (e) {
      debugPrint('❌ previousTradingDayQuote error for $symbol: $e');
      return {'c': 0, 'dp': 0, 'pc': 0};
    }
  }

  // ---------------------------------------------------------------------------
  // Financials / Metrics
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> metrics(String symbol) async =>
      _get('/stock/metric', params: {'symbol': symbol, 'metric': 'all'});

  // ---------------------------------------------------------------------------
  // News
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> companyNews(String symbol, {int days = 7}) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    final toStr = _fmtDate(now);
    final fromStr = _fmtDate(from);
    return _getRaw(
      '/company-news',
      params: {'symbol': symbol, 'from': fromStr, 'to': toStr},
    );
  }

  Future<List<dynamic>> generalNews() async {
    try {
      return await _getRawFromBackend('/news');
    } catch (e) {
      debugPrint('⚠️ Backend generalNews() failed, falling back direct: $e');
      return _getRaw('/news', params: {'category': 'general'});
    }
  }

  // ---------------------------------------------------------------------------
  // Market Index
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> indexQuote(String symbol) async =>
      _get('/quote', params: {'symbol': symbol});

  // ---------------------------------------------------------------------------
  // Calendar
  // ---------------------------------------------------------------------------

  /// Returns earnings calendar items.
  /// Finnhub response: { "earningsCalendar": [...] }
  Future<List<dynamic>> earningsCalendar({
    String? symbol,
    int daysAhead = 30,
  }) async {
    final now = DateTime.now();
    final from = _fmtDate(now);
    final to = _fmtDate(now.add(Duration(days: daysAhead)));
    final params = <String, dynamic>{'from': from, 'to': to};
    if (symbol != null) params['symbol'] = symbol;
    final data = await _get('/calendar/earnings', params: params);
    return data['earningsCalendar'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> dividendsCalendar({
    required String symbol,
    int daysAhead = 30,
  }) async {
    final now = DateTime.now();
    final from = _fmtDate(now);
    final to = _fmtDate(now.add(Duration(days: daysAhead)));
    return _getRaw(
      '/stock/dividend',
      params: {'symbol': symbol, 'from': from, 'to': to},
    );
  }

  // ---------------------------------------------------------------------------
  // Earnings / Revenue trends
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> earningsSurprises(String symbol) async =>
      _getRaw('/stock/earnings', params: {'symbol': symbol, 'limit': 5});

  // ---------------------------------------------------------------------------
  // Historical Candles
  // ---------------------------------------------------------------------------

  /// `/stock/candle` is a Finnhub PAID-tier endpoint — confirmed via a
  /// live 403 on the free tier (2026-07-23), both direct and through the
  /// backend. Blocked here with zero network calls (not even to our own
  /// backend) rather than letting every chart open waste a request that
  /// can only ever fail — no retry/fallback path makes sense for a
  /// permanently-403 endpoint. Callers already handle a thrown exception
  /// (see `price_chart.dart`'s `_loadCandles` catch block → "Failed to
  /// load chart"). Flip back on if the Finnhub plan is ever upgraded.
  Future<Map<String, dynamic>> candles(
    String symbol, {
    required String resolution,
    required int from,
    required int to,
  }) async {
    throw Exception(
      'Candle/chart data requires a paid Finnhub plan — not available.',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _fmtDate(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _CacheEntry {
  final dynamic data;
  final DateTime time;
  _CacheEntry(this.data, this.time);
}
