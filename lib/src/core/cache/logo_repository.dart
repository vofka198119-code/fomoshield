import 'package:flutter/foundation.dart';
import '../models/company.dart';
import '../models/logo_cache_entry.dart';
import '../../shared/services/finnhub_service.dart';
import 'logo_dao.dart';

// ---------------------------------------------------------------------------
// LogoRepository — управление загрузкой и кэшированием логотипов
// ---------------------------------------------------------------------------
// Логика:
//   1. Проверить LogoDao (постоянное хранилище)
//   2. Если есть — вернуть URL
//   3. Если нет — запросить profile Finnhub, извлечь домен,
//      сформировать Clearbit URL, сохранить в LogoDao, вернуть
// ---------------------------------------------------------------------------

class LogoRepository {
  final LogoDao _dao;
  final FinnhubService _api;

  LogoRepository({
    LogoDao? dao,
    FinnhubService? api,
  })  : _dao = dao ?? LogoDao(),
        _api = api ?? FinnhubService();

  /// Возвращает кэшированный URL логотипа для тикера.
  /// Если в кэше нет — возвращает null (не загружает).
  Future<String?> getCachedLogo(String ticker) async {
    final entry = await _dao.getLogo(ticker);
    return entry?.logoUrl;
  }

  /// Загружает логотип, если его нет в кэше.
  /// Возвращает URL логотипа (из кэша или свежезагруженный).
  Future<String?> loadLogo(Company company) async {
    // 1. Проверить кэш
    final cached = await _dao.getLogo(company.ticker);
    if (cached != null) return cached.logoUrl;

    // 2. Если нет в кэше — загрузить profile и сохранить
    try {
      final profile = await _api.companyProfile(company.ticker);
      final weburl = profile['weburl'] as String?;
      final finnhubLogo = profile['logo'] as String?;

      // Домен из weburl
      String? domain;
      if (weburl != null && weburl.isNotEmpty) {
        try {
          final uri = Uri.parse(weburl);
          domain = uri.host;
          if (domain.startsWith('www.')) domain = domain.substring(4);
        } catch (_) {}
      }

      // Приоритет: Finnhub logo > Clearbit по домену
      final logoUrl = finnhubLogo ??
          (domain != null ? 'https://logo.clearbit.com/$domain' : null);

      if (logoUrl == null || logoUrl.isEmpty) {
        debugPrint('⚠️ LogoRepository: no logo URL for ${company.ticker}');
        return null;
      }

      // Сохранить в постоянный кэш
      final entry = LogoCacheEntry(
        ticker: company.ticker.toUpperCase(),
        companyName: company.name,
        domain: domain,
        logoUrl: logoUrl,
        createdAt: DateTime.now(),
      );
      await _dao.saveLogo(entry);

      return logoUrl;
    } catch (e) {
      debugPrint('❌ LogoRepository.loadLogo error for ${company.ticker}: $e');
      return null;
    }
  }

  /// Загружает логотип по тикеру (удобный метод для быстрого вызова).
  Future<String?> loadLogoSymbol(String ticker) async {
    final company = Company(ticker: ticker, name: ticker);
    return loadLogo(company);
  }

  /// Проверяет, есть ли логотип в кэше.
  Future<bool> hasLogo(String ticker) async => _dao.hasLogo(ticker);
}
