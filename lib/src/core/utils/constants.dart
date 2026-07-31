import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'F.O.M.O. Shield';
  static const String tagline = 'Invest with discipline, not emotion.';

  // API
  static const int cacheTTLMinutes = 240; // 4 hours for market data

  /// scanco-backend (Finnhub proxy/cache) base URL — every device talks
  /// to this exclusively, sharing one rate-limited Finnhub connection
  /// instead of each device hitting Finnhub directly with an embedded
  /// key (removed 2026-07-31 — see FinnhubService's doc comment).
  static String get backendBaseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3000';

  /// Shared secret sent as the X-API-Key header on every backend call —
  /// must match the server's API_KEY. Empty until the server enables
  /// enforcement (see scanco-backend's apiKeyAuth middleware).
  static String get backendApiKey => dotenv.env['BACKEND_API_KEY'] ?? '';

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
