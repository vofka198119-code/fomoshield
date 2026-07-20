// ---------------------------------------------------------------------------
// SectorCacheEntry — модель для хранения сектора компании
// ---------------------------------------------------------------------------
// Хранится в SectorDao (SharedPreferences). Зеркало LogoCacheEntry/LogoDao —
// та же структура, тот же источник (Finnhub companyProfile), другое поле.
// Не имеет TTL — хранится навсегда.
// ---------------------------------------------------------------------------

class SectorCacheEntry {
  final String ticker;

  /// [GicsSector.name] — null-эквивалент хранится как пустая строка
  /// (инструменты без единого реального сектора: широкие ETF, крипта).
  final String gicsSector;

  /// Сырое значение `finnhubIndustry` из ответа Finnhub — для отладки и
  /// для повторного маппинга без нового запроса, если таблица
  /// `_finnhubIndustryToGics` расширится.
  final String finnhubIndustry;
  final DateTime createdAt;

  const SectorCacheEntry({
    required this.ticker,
    required this.gicsSector,
    required this.finnhubIndustry,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'gicsSector': gicsSector,
        'finnhubIndustry': finnhubIndustry,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SectorCacheEntry.fromJson(Map<String, dynamic> json) {
    return SectorCacheEntry(
      ticker: json['ticker'] as String? ?? '',
      gicsSector: json['gicsSector'] as String? ?? '',
      finnhubIndustry: json['finnhubIndustry'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
