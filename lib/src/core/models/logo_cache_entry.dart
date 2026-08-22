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

  /// GICS sector name ([GicsSector.name]) and Finnhub's own raw industry
  /// string — both come from the SAME `/profile/:symbol` response this
  /// entry's logo/name already do, so LogoRepository fills them in for
  /// free rather than SectorRepository issuing its own separate profile
  /// fetch for the same ticker (was two independent permanent caches off
  /// one endpoint — merged 2026-08-22). Null means "not resolved yet",
  /// not "no sector" — companies_tag_mapper's own null (ETF/crypto) is
  /// represented by an empty string, mirroring the old SectorCacheEntry
  /// convention, so a genuinely-checked-and-sectorless instrument isn't
  /// retried forever.
  final String? gicsSector;
  final String? finnhubIndustry;

  const LogoCacheEntry({
    required this.ticker,
    required this.companyName,
    this.domain,
    required this.logoUrl,
    required this.createdAt,
    this.gicsSector,
    this.finnhubIndustry,
  });

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'companyName': companyName,
        'domain': domain,
        'logoUrl': logoUrl,
        'createdAt': createdAt.toIso8601String(),
        if (gicsSector != null) 'gicsSector': gicsSector,
        if (finnhubIndustry != null) 'finnhubIndustry': finnhubIndustry,
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
      gicsSector: json['gicsSector'] as String?,
      finnhubIndustry: json['finnhubIndustry'] as String?,
    );
  }
}
