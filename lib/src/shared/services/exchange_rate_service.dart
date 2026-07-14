import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Exchange Rate Service — Frankfurter API (free, no key)
// ---------------------------------------------------------------------------
// Uses https://api.frankfurter.dev — supports 30+ currencies.
// Rates are cached in-memory for 1 hour to avoid redundant requests.
// ---------------------------------------------------------------------------

class _RateCacheEntry {
  final Map<String, double> rates;
  final DateTime timestamp;

  _RateCacheEntry(this.rates, this.timestamp);

  bool get isValid =>
      DateTime.now().difference(timestamp).inMinutes < 60;
}

class ExchangeRateService {
  final Dio _dio;
  final Map<String, _RateCacheEntry> _cache = {};

  static const _baseUrl = 'https://api.frankfurter.dev';

  ExchangeRateService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ));

  /// Returns the exchange rate from [fromCurrency] to [toCurrency].
  /// E.g. getRate('GBP', 'USD') -> 1.27 (how many USD for 1 GBP)
  Future<double> getRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;

    final normalizedFrom = fromCurrency.toUpperCase();
    final normalizedTo = toCurrency.toUpperCase();

    // Check cache
    final cached = _cache[normalizedFrom];
    if (cached != null && cached.isValid && cached.rates.containsKey(normalizedTo)) {
      return cached.rates[normalizedTo]!;
    }

    try {
      final response = await _dio.get(
        '/latest',
        queryParameters: {'from': normalizedFrom, 'to': normalizedTo},
      );

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>? ?? {};
        final rate = (rates[normalizedTo] as num?)?.toDouble();

        if (rate != null && rate > 0) {
          // Cache the result
          _cache[normalizedFrom] = _RateCacheEntry(
            {normalizedTo: rate},
            DateTime.now(),
          );
          return rate;
        }
      }

      // Fallback: if Frankfurter fails, try inverse rate
      if (normalizedFrom != 'USD') {
        final inverseRate = await _getInverseRate(normalizedFrom, normalizedTo);
        if (inverseRate != null) return inverseRate;
      }

      debugPrint('⚠️ FX rate fallback for $normalizedFrom→$normalizedTo: using 1.0');
      return 1.0;
    } catch (e) {
      debugPrint('❌ FX rate error $normalizedFrom→$normalizedTo: $e');

      // Try inverse as fallback
      if (normalizedFrom != 'USD') {
        final inverseRate = await _getInverseRate(normalizedFrom, normalizedTo);
        if (inverseRate != null) return inverseRate;
      }

      return 1.0;
    }
  }

  /// Tries to get rate via USD as intermediate: from → USD → to
  Future<double?> _getInverseRate(String from, String to) async {
    try {
      // Get USD→from and USD→to, then calculate from→to
      final response = await _dio.get(
        '/latest',
        queryParameters: {'from': 'USD', 'to': '$from,$to'},
      );
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>? ?? {};
        final usdToFrom = (rates[from] as num?)?.toDouble();
        final usdToTarget = (rates[to] as num?)?.toDouble();

        if (usdToFrom != null && usdToTarget != null && usdToFrom > 0) {
          final rate = usdToTarget / usdToFrom;
          _cache[from] = _RateCacheEntry({to: rate}, DateTime.now());
          return rate;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Converts [amount] in [fromCurrency] to [toCurrency].
  Future<double> convert(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    final rate = await getRate(fromCurrency, toCurrency);
    return amount * rate;
  }

  /// Clears all cached rates.
  void clearCache() {
    _cache.clear();
  }
}
