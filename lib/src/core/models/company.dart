// ---------------------------------------------------------------------------
// Company — центральная модель приложения
// ---------------------------------------------------------------------------
// Используется всеми экранами для получения информации о компании.
// Содержит данные о тикере, названии, бирже, домене и URL логотипа.
// Логотип загружается один раз и сохраняется в LogoCache навсегда.
// ---------------------------------------------------------------------------

class Company {
  final String ticker;
  final String name;
  final String? exchange;
  final String? domain;
  final String? logoUrl;

  const Company({
    required this.ticker,
    required this.name,
    this.exchange,
    this.domain,
    this.logoUrl,
  });

  /// Создаёт Company из карты данных Finnhub profile2.
  factory Company.fromProfile({
    required String ticker,
    required Map<String, dynamic> profile,
    String? cachedLogoUrl,
  }) {
    final name = profile['name'] as String? ?? ticker;
    final weburl = profile['weburl'] as String?;
    final domain = _extractDomain(weburl);
    final logoUrl = cachedLogoUrl ??
        profile['logo'] as String? ??
        (domain != null ? 'https://logo.clearbit.com/$domain' : null);

    return Company(
      ticker: ticker.toUpperCase(),
      name: name,
      exchange: profile['exchange'] as String?,
      domain: domain,
      logoUrl: logoUrl,
    );
  }

  /// Создаёт Company из результата поиска Finnhub.
  factory Company.fromSearch(Map<String, dynamic> item) {
    final symbol = (item['symbol'] as String? ?? '').toUpperCase();
    final name = item['description'] as String? ?? symbol;
    return Company(
      ticker: symbol,
      name: name,
      exchange: item['type'] as String?,
    );
  }

  /// Создаёт Company из карты данных watchlist.
  factory Company.fromWatchlistMap(Map<String, dynamic> data) {
    return Company(
      ticker: (data['symbol'] as String? ?? '').toUpperCase(),
      name: data['name'] as String? ?? '',
      domain: data['domain'] as String?,
      logoUrl: data['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'name': name,
        'exchange': exchange,
        'domain': domain,
        'logoUrl': logoUrl,
      };

  /// Извлекает домен из URL компании.
  static String? _extractDomain(String? weburl) {
    if (weburl == null || weburl.isEmpty) return null;
    try {
      final uri = Uri.parse(weburl);
      final host = uri.host;
      if (host.startsWith('www.')) return host.substring(4);
      return host;
    } catch (_) {
      return null;
    }
  }
}
