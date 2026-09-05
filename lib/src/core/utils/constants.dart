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
  ///
  /// Compile-time constant (`--dart-define-from-file=.env`), not a bundled
  /// runtime asset (2026-09-05) — the previous flutter_dotenv setup shipped
  /// the whole .env file as plaintext inside the APK's asset bundle, so
  /// anyone could unzip a release build and read it directly. This isn't a
  /// real secret either way (any static value the client presents to its
  /// own backend is inherently extractable from the binary), but it raises
  /// the bar from "open a text file" to "decompile the app".
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Shared secret sent as the X-API-Key header on every backend call —
  /// must match the server's API_KEY. Empty until the server enables
  /// enforcement (see scanco-backend's apiKeyAuth middleware).
  static const String backendApiKey = String.fromEnvironment('BACKEND_API_KEY');

  // Wikipedia
  static const String wikiBaseEN = 'https://en.wikipedia.org/api/rest_v1/page/summary';
  static const String wikiBaseRU = 'https://ru.wikipedia.org/api/rest_v1/page/summary';

  // Company search
  static const int minSearchChars = 2;
  static const int maxSearchResults = 20;

  // Portfolio
  // Fallback only — used when a Portfolio's own startingBalance is missing
  // from stored/synced data (corrupted or pre-migration record). The real
  // per-tier values live in portfolio_limits_provider.dart.
  static const double defaultStartingBalance = 10000.0;

  // NYSE hours
  static const int nyseOpenHour = 9;
  static const int nyseOpenMin = 30;
  static const int nyseCloseHour = 16;
  static const int nyseCloseMin = 0;

  // Dividends
  static const double dividendTrapThreshold = 10.0; // yield %
  static const int dividendTrapPenalty = 20;

  // FS Score — a clean balance sheet (low debt, strong current ratio)
  // can mask a company burning cash far faster than it earns revenue;
  // Financial Health measures balance-sheet strength independent of the
  // P&L, so catastrophic losses don't otherwise drag the weighted
  // average down as much as they should. Net margin below -100% means
  // losses exceed total revenue.
  static const double catastrophicLossThreshold = -100.0; // net margin %
  static const int catastrophicLossPenalty = 25;
}
