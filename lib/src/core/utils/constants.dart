import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'F.O.M.O. Shield';
  static const String tagline = 'Invest with discipline, not emotion.';

  // API
  static String get finnhubKey =>
      dotenv.env['FINNHUB_API_KEY'] ?? 'd8l3qgpr01qut1f8r240d8l3qgpr01qut1f8r24g';
  static const String finnhubBase = 'https://finnhub.io/api/v1';
  static const int finnhubRateLimit = 60; // req/min
  static const int cacheTTLMinutes = 240; // 4 hours for market data

  /// scanco-backend (Finnhub proxy/cache) base URL — shares one
  /// rate-limited Finnhub connection across all users instead of every
  /// device hitting Finnhub directly with the same embedded key. Only
  /// quote/news(general)/candles are proxied so far — see
  /// FinnhubService's doc comment for which calls still go direct.
  static String get backendBaseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3000';

  // Wikipedia
  static const String wikiBaseEN = 'https://en.wikipedia.org/api/rest_v1/page/summary';
  static const String wikiBaseRU = 'https://ru.wikipedia.org/api/rest_v1/page/summary';

  // Company search
  static const int minSearchChars = 2;
  static const int maxSearchResults = 20;

  // Portfolio
  static const double defaultStartingBalance = 10000.0;
  static const int maxParallelStressTests = 5;

  // NYSE hours
  static const int nyseOpenHour = 9;
  static const int nyseOpenMin = 30;
  static const int nyseCloseHour = 16;
  static const int nyseCloseMin = 0;

  // Dividends
  static const double dividendTrapThreshold = 10.0; // yield %
  static const int dividendTrapPenalty = 20;
}
