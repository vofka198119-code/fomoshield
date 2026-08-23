import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';
import '../../core/supabase/supabase_client.dart';

/// True if a search result's `type` field (Finnhub's own `/search`, or the
/// backend's local index) identifies an ETF. Both sources label real ETFs
/// "ETP" (Exchange Traded Product), not "ETF" — checking only "ETF" was a
/// confirmed real bug twice (search UI badge 2026-07-29, Stress Test's
/// ETF-exposure buy-time detection 2026-08-06: SPY/QQQ/VOO and others all
/// come back "ETP"). Single source of truth — every "is this an ETF" check
/// anywhere in the app should call this, not compare `type` directly.
bool isEtfSecurityType(String? type) {
  final t = (type ?? '').toUpperCase();
  return t == 'ETF' || t == 'ETP';
}

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

  // ---------------------------------------------------------------------------
  // Concurrency limiting + in-flight de-dup
  // ---------------------------------------------------------------------------
  // A screen that renders N rows at once (S&P 500 list, Portfolio/Stress
  // Test holdings) used to fire N independent backend calls the instant it
  // mounted — easily blowing past the backend's own 120-req/60s client
  // rate limit in under a second and leaving every row stuck on its letter-
  // avatar fallback. [_limiter] caps how many of THIS client's requests are
  // actually in flight to the backend at once; the rest queue instead of
  // firing immediately. [_inFlight] additionally collapses concurrent
  // requests for the exact same cache key (e.g. Logo and Sector both
  // fetching AAPL's profile in the same frame) into a single network call
  // that both callers await.
  //
  // maxConcurrent was 4 — safe against the 120-req/60s budget (even 3-4
  // screens bursting at once on cold app open stays well under it), but
  // visibly wrong on its own: a single list's ~10-15 visible rows only
  // ever had 4 in flight together, so icons/sectors populated in
  // conspicuous waves ("slideshow" — confirmed 2026-08-22 on-device,
  // present even after capping the S&P 500 list to 30, because visible
  // row count — not list length — is what drove it; ListView.builder was
  // already lazy). Raised to 8: still a shared, app-wide gate (this
  // instance is a singleton — see finnhubServiceProvider below — so it
  // still caps a multi-screen pile-up the same as before), just wide
  // enough that one screen's own rows resolve in ~2 waves instead of ~4.
  final _limiter = _ConcurrencyLimiter(maxConcurrent: 8);
  // Concurrency alone caps how many requests are in flight AT ONCE, not
  // how many go out over TIME — browsing 3 different cold Search lanes
  // back to back (each its own burst of ~10-15 never-cached tickers)
  // still summed past Finnhub's real upstream 60-req/min budget within a
  // couple of minutes, confirmed live 2026-08-22 (backend log: "[upstream
  // error] Failed to fetch ... 429 ... x-ratelimit-limit: 60" — that's
  // Finnhub's own limit, shared across every device and the server's own
  // warm-up cron, not this app's 120/60s client-facing one). [_rateLimiter]
  // caps this client's own sustained rate.
  //
  // 30/60s (tried 2026-08-22) was a serious over-correction: it averages
  // one request every 2s, so a single cold sector lane with 40-50 never-
  // cached tickers took 1.5-2 minutes to populate — read as "just hangs".
  // The real bottleneck that day turned out to be the BACKEND's own
  // profileCache (60-day TTL, but in-memory node-cache — wiped on every
  // pm2 restart/deploy, and the server had restarted 47x in ~5h during
  // that session's own debugging), not this client bursting — so a tight
  // client limit was punishing the wrong layer. 55/60s stays just under
  // Finnhub's real 60/min ceiling (still leaves a sliver of headroom for
  // the server's own warm-up cron + any other device) while letting one
  // normal lane-sized burst clear almost immediately.
  final _rateLimiter = _RateLimiter(maxPerWindow: 55, window: const Duration(seconds: 60));
  final Map<String, Future<Map<String, dynamic>>> _inFlight = {};
  final Map<String, Future<List<dynamic>>> _inFlightRaw = {};

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

    // Someone else already asked for this exact key this instant (e.g. Logo
    // and Sector both cache-missing the same ticker's profile in the same
    // frame) — await their in-flight request instead of firing a duplicate.
    final pending = _inFlight[cacheKey];
    if (pending != null) return pending;

    final future = _fetchFromBackend(path, params, cacheKey);
    _inFlight[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  Future<Map<String, dynamic>> _fetchFromBackend(
    String path,
    Map<String, dynamic>? params,
    String cacheKey,
  ) async {
    try {
      final response = await _rateLimiter.run(
        () => _limiter.run(() => _backendDio.get(path, queryParameters: params)),
      );
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
    } catch (e) {
      // A stale (past-TTL) entry beats no data at all — e.g. a portfolio
      // holding's price falling back to null/avgCost on a transient quote
      // failure used to render as a false $0.00 unrealized P&L. Only kicks
      // in when this same key was successfully fetched at some earlier
      // point in this FinnhubService instance's lifetime.
      final stale = _cache[cacheKey];
      if (stale != null) {
        debugPrint('🖥️ ⚠️ Backend $path failed, serving stale cache: $e');
        return stale.data as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  /// Get from scanco-backend (top-level JSON array). See [_getFromBackend].
  Future<List<dynamic>> _getRawFromBackend(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final cacheKey = 'backend-raw:$path?${params?.toString() ?? ''}';
    final cached = _getCachedRaw(cacheKey);
    if (cached != null) return cached;

    final pending = _inFlightRaw[cacheKey];
    if (pending != null) return pending;

    final future = _fetchRawFromBackend(path, params, cacheKey);
    _inFlightRaw[cacheKey] = future;
    try {
      return await future;
    } finally {
      _inFlightRaw.remove(cacheKey);
    }
  }

  Future<List<dynamic>> _fetchRawFromBackend(
    String path,
    Map<String, dynamic>? params,
    String cacheKey,
  ) async {
    final response = await _rateLimiter.run(
      () => _limiter.run(() => _backendDio.get(path, queryParameters: params)),
    );
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
    '.WA', // Warsaw
    '.MX', // Mexico
    '.BC', // Colombia
    '.LM', // Chile
    '.IS', // Israel
    '.TA', // Tel Aviv
    '.SS', // Shanghai
    '.SZ', // Shenzhen
    '.HK', // Hong Kong
    '.TW', // Taiwan
    '.KS', // Korea
    '.KQ', // KOSDAQ
    '.T', // Tokyo
    '.F', // Frankfurt (we keep .DE for Xetra)
    '.BE', // Berlin
    '.MU', // Munich
    '.HA', // Hanover
    '.SG', // Singapore
    '.OL', // Oslo
    '.ST', // Stockholm
    '.CO', // Copenhagen
    '.HE', // Helsinki
    '.VI', // Vienna
    '.AT', // Athens
    '.IR', // Irish
    '.LS', // Lisbon
    '.PA', // Euronext Paris
    '.AS', // Euronext Amsterdam
    '.BR', // Euronext Brussels
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

      // Always keep ETFs regardless of exchange
      if (isEtfSecurityType(m['type'] as String?)) {
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
    // /quote works on free Finnhub tier — returns real-time price, change, prev close.
    // Deliberately doesn't catch: callers (e.g. marketIndicesProvider's
    // Future.wait over SPY/QQQ/DIA) need a failure on ANY one symbol to
    // fail the whole batch, not silently succeed with a zeroed entry that
    // then gets cached for hours indistinguishable from a real flat market.
    final q = await quote(symbol);
    final c = (q['c'] as num?)?.toDouble() ?? 0;
    final dp = (q['dp'] as num?)?.toDouble() ?? 0;
    final pc = (q['pc'] as num?)?.toDouble() ?? 0;
    debugPrint('📊 quote($symbol): c=$c dp=$dp pc=$pc');
    return {'c': c, 'dp': dp, 'pc': pc};
  }

  // ---------------------------------------------------------------------------
  // Financials / Metrics
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> metrics(String symbol) async =>
      _getFromBackend('/metrics/$symbol');

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

  /// Current Disclaimer/Privacy Policy/Terms version numbers, uncached —
  /// this is a compliance check, a stale answer defeats its purpose.
  Future<Map<String, dynamic>> documentVersions() async {
    final response = await _backendDio.get('/config/versions');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Permanently deletes the signed-in user's account and all their data,
  /// immediately, with no recovery. Kept for potential admin/manual use —
  /// the app's own Delete Account button calls [scheduleAccountDeletion]
  /// instead, which gives a 14-day recovery window.
  Future<void> deleteAccount() async {
    await _backendDio.delete('/account');
  }

  /// Marks the signed-in account for deletion — the account keeps working
  /// normally (still signs in, all data intact) unless/until it's hard-
  /// deleted by the server's daily sweep after the recovery window closes.
  /// See [restoreAccount] and [accountDeletionStatus].
  Future<void> scheduleAccountDeletion() async {
    await _backendDio.post('/account/schedule-deletion');
  }

  /// Cancels a pending deletion for the signed-in account.
  Future<void> restoreAccount() async {
    await _backendDio.post('/account/restore');
  }

  /// Whether the signed-in account is currently pending deletion, and how
  /// many days are left to restore it. Checked right after sign-in/session
  /// resume to decide whether to show the full-block Restore Account
  /// screen instead of the app.
  Future<AccountDeletionStatus> accountDeletionStatus() async {
    final response = await _backendDio.get('/account/status');
    final data = Map<String, dynamic>.from(response.data as Map);
    return AccountDeletionStatus(
      pendingDeletion: data['pendingDeletion'] as bool? ?? false,
      daysRemaining: (data['daysRemaining'] as num?)?.toInt() ?? 0,
      deleteAt: data['deleteAt'] != null
          ? DateTime.tryParse(data['deleteAt'] as String)
          : null,
    );
  }
}

class AccountDeletionStatus {
  final bool pendingDeletion;
  final int daysRemaining;
  final DateTime? deleteAt;

  const AccountDeletionStatus({
    required this.pendingDeletion,
    required this.daysRemaining,
    this.deleteAt,
  });
}

// ---------------------------------------------------------------------------
// Shared instance — the in-memory per-instance cache above only helps if
// callers actually share one instance; most call sites used to construct
// `FinnhubService()` fresh per call, which meant `_cache` almost never
// survived long enough to be hit. Read this instead of constructing
// directly wherever `ref` is available.
// ---------------------------------------------------------------------------

final finnhubServiceProvider = Provider<FinnhubService>(
  (ref) => FinnhubService(),
);

class _CacheEntry {
  final dynamic data;
  final DateTime time;
  _CacheEntry(this.data, this.time);
}

/// Simple FIFO concurrency gate — at most [maxConcurrent] calls to [run]
/// are ever mid-flight at once; anything past that queues until a slot
/// frees up. Mirrors, on the client side, what the backend's own
/// per-client rate limit already enforces server-side — without this, a
/// screen rendering N rows at once fired all N requests in the same
/// frame instead of trickling them out.
class _ConcurrencyLimiter {
  final int maxConcurrent;
  int _active = 0;
  final List<Completer<void>> _queue = [];

  _ConcurrencyLimiter({required this.maxConcurrent});

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= maxConcurrent) {
      final waiter = Completer<void>();
      _queue.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      }
    }
  }
}

/// Sliding-window rate gate — at most [maxPerWindow] calls to [run] START
/// within any rolling [window]; anything past that waits until the oldest
/// call in the window ages out. Unlike [_ConcurrencyLimiter] (which only
/// bounds how many are mid-flight AT ONCE), this bounds sustained
/// throughput OVER TIME — needed because Finnhub's own upstream limit (60
/// req/min, shared across every device using the app AND the server's own
/// warm-up cron) is a rate, not a concurrency cap: three quick, mostly
/// non-overlapping bursts from opening 3 different cold Search lanes back
/// to back can still sum past it even with a tight concurrency gate.
/// Confirmed live 2026-08-22 via the backend's own error log.
class _RateLimiter {
  final int maxPerWindow;
  final Duration window;
  final List<DateTime> _timestamps = [];
  // Serializes the "wait for a slot, then reserve it" decision itself —
  // without this, N concurrent callers could all observe room for one
  // more slot and all proceed together, defeating the limit.
  Future<void> _chain = Future.value();

  _RateLimiter({required this.maxPerWindow, required this.window});

  Future<T> run<T>(Future<T> Function() task) {
    final reserved = _chain.then((_) => _waitForSlot());
    _chain = reserved;
    return reserved.then((_) => task());
  }

  Future<void> _waitForSlot() async {
    while (true) {
      final now = DateTime.now();
      _timestamps.removeWhere((t) => now.difference(t) >= window);
      if (_timestamps.length < maxPerWindow) {
        _timestamps.add(now);
        return;
      }
      final waitFor = window - now.difference(_timestamps.first);
      await Future.delayed(
        waitFor > Duration.zero ? waitFor : const Duration(milliseconds: 50),
      );
    }
  }
}
