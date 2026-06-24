import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';

class FinnhubService {
  final Dio _dio;
  final Map<String, _CacheEntry> _cache = {};

  FinnhubService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.finnhubBase,
          queryParameters: {'token': AppConstants.finnhubKey},
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
      // Deduplication: prefer US ticker (no dot)
      final baseSymbol = symbol.split('.')[0];
      if (seen.contains(baseSymbol)) continue;
      if (symbol.contains('.') && symbol.endsWith('.US') == false) {
        // Foreign listing, skip if we have US version
        continue;
      }
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

  Future<Map<String, dynamic>> quote(String symbol) async =>
      _get('/quote', params: {'symbol': symbol});

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

  Future<List<dynamic>> generalNews() async =>
      _getRaw('/news', params: {'category': 'general'});

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

  Future<Map<String, dynamic>> candles(
    String symbol, {
    required String resolution,
    required int from,
    required int to,
  }) async => _get(
    '/stock/candle',
    params: {
      'symbol': symbol,
      'resolution': resolution,
      'from': from.toString(),
      'to': to.toString(),
    },
  );

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
