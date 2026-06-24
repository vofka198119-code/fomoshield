// ---------------------------------------------------------------------------
// LogoCacheEntry — модель для хранения логотипа компании
// ---------------------------------------------------------------------------
// Хранится в LogoDao (SharedPreferences).
// Не имеет TTL — хранится навсегда.
// Не зависит от StockCache.
// ---------------------------------------------------------------------------

class LogoCacheEntry {
  final String ticker;
  final String companyName;
  final String? domain;
  final String logoUrl;
  final DateTime createdAt;

  const LogoCacheEntry({
    required this.ticker,
    required this.companyName,
    this.domain,
    required this.logoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'companyName': companyName,
        'domain': domain,
        'logoUrl': logoUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LogoCacheEntry.fromJson(Map<String, dynamic> json) {
    return LogoCacheEntry(
      ticker: json['ticker'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      domain: json['domain'] as String?,
      logoUrl: json['logoUrl'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
