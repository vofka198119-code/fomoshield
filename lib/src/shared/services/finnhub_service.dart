import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';
import '../../core/supabase/supabase_client.dart';

/// Talks to `scanco-backend` (the Finnhub proxy/cache server, see
/// d:/Projects/scanco-backend) exclusively — never Finnhub directly.
/// Every device sharing one embedded Finnhub key would blow through the
/// free tier's 60 req/min limit with more than a handful of concurrent
/// users; a device falling back to that shared key on a backend hiccup
/// used to turn one rate-limit blip into every device hammering Finnhub
/// at once, which is worse, not better (direct-Finnhub fallback removed
/// 2026-07-31).
///
/// Blocked entirely, zero network calls (Finnhub paid-tier-only, confirmed
/// via live 403): [dividendsCalendar].
class FinnhubService {
  final Dio _backendDio;
  final Map<String, _CacheEntry> _cache = {};

  FinnhubService()
    : _backendDio = Dio(
        BaseOptions(
          baseUrl: '${AppConstants.backendBaseUrl}/api/v1',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: AppConstants.backendApiKey.isEmpty
              ? null
              : {'X-API-Key': AppConstants.backendApiKey},
        ),
      ) {
    _backendDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Read the CURRENT session token fresh on every request (not
          // cached at Dio-construction time) — supabase_flutter auto-
          // refreshes it in the background, so a stale copy would start
          // failing the backend's JWT verification after expiry.
          final accessToken =
              SupabaseConfig.client.auth.currentSession?.accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
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

  /// Get from scanco-backend (top-level JSON object), `backend:`-prefixed
  /// cache key.
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
    // Backend-only — no direct-Finnhub fallback. A device falling back to
    // the shared embedded key on a backend hiccup is exactly what turns
    // one rate-limit blip into every device hammering Finnhub at once.
    final data = await _getFromBackend('/search', params: {'q': query});
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

  /// Ranked search over our own backend-cached list of ~11k real US
  /// tickers (see scanco-backend's localSymbolsService.js) instead of
  /// Finnhub's own /search, which caps at 11 results and often omits the
  /// obviously-right match for short/partial queries (confirmed live
  /// 2026-07-29 — e.g. "Realty Income" never appeared for "re"/"real").
  /// Falls back to the direct-Finnhub [search] above only if the backend
  /// call itself fails (down/unreachable), same resilience pattern as
  /// every other backend-routed call in this class.
  Future<List<Map<String, dynamic>>> searchLocal(String query) async {
    if (query.length < AppConstants.minSearchChars) return [];
    try {
      final data = await _getFromBackend('/search-local', params: {'q': query});
      final items = data['results'] as List<dynamic>? ?? [];
      return [
        for (final item in items)
          {
            'symbol': (item as Map)['symbol'],
            'description': item['name'],
            'type': item['type'],
          },
      ];
    } catch (e) {
      debugPrint(
        '⚠️ Backend searchLocal($query) failed, falling back to direct Finnhub search: $e',
      );
      return search(query);
    }
  }

  // ---------------------------------------------------------------------------
  // Company Profile
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> companyProfile(String symbol) async =>
      _getFromBackend('/profile/$symbol');

  // ---------------------------------------------------------------------------
  // Quote
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> quote(String symbol) async {
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
      _getFromBackend('/metrics/$symbol');

  // ---------------------------------------------------------------------------
  // News
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> companyNews(String symbol, {int days = 7}) async =>
      _getRawFromBackend('/news', params: {'symbol': symbol});


  // ---------------------------------------------------------------------------
  // Top Companies (backend-computed, no direct-Finnhub equivalent)
  // ---------------------------------------------------------------------------

  /// Top ~47 S&P 500 companies by market cap, refreshed quarterly on the
  /// backend (Wikipedia constituent scrape + Finnhub market-cap ranking —
  /// Finnhub's own index-constituents endpoint is paid-tier only, see
  /// scanco-backend/src/services/sp500Service.js). No direct-Finnhub
  /// fallback exists for this one — it's purely our own backend's data.
  /// Shape: `{updatedAt, companies: [{symbol, name, marketCap}]}`.
  Future<Map<String, dynamic>> topCompanies() async =>
      _getFromBackend('/top-companies');

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

    final data = await _getFromBackend('/earnings/calendar', params: params);
    return data['earningsCalendar'] as List<dynamic>? ?? [];
  }

  /// `/stock/dividend` is a Finnhub PAID-tier endpoint — confirmed via a
  /// live 403 on every company-detail-page open (2026-07-24), same
  /// pattern as [candles]. Blocked here with zero network calls for the
  /// same reason: a permanently-403 call still costs a slot against the
  /// shared rate-limit budget. Caller (`home_providers.dart`) already
  /// wraps this in a try/catch. Flip back on if the Finnhub plan is ever
  /// upgraded.
  Future<List<dynamic>> dividendsCalendar({
    required String symbol,
    int daysAhead = 30,
  }) async {
    throw Exception(
      'Dividend data requires a paid Finnhub plan — not available.',
    );
  }

  // ---------------------------------------------------------------------------
  // Earnings / Revenue trends
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> earningsSurprises(String symbol) async =>
      _getRawFromBackend('/earnings/surprises/$symbol');

  // ---------------------------------------------------------------------------
  // Historical Candles
  // ---------------------------------------------------------------------------

  /// Backed by the scanco-backend `/candles` route, which fetches from
  /// Yahoo Finance (Finnhub's own `/stock/candle` is paid-tier only — see
  /// yahooClient.js on the backend). No direct-Finnhub fallback: Finnhub
  /// would just 403 here.
  Future<Map<String, dynamic>> candles(
    String symbol, {
    required String resolution,
    required int from,
    required int to,
  }) => _getFromBackend(
    '/candles/$symbol',
    params: {'resolution': resolution, 'from': from, 'to': to},
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
