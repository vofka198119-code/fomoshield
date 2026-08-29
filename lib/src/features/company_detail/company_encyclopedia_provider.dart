import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Company Encyclopedia — "Company History" long-form text (business history
// + market/exchange history, RU+EN), authored offline and filled in
// company-by-company (see scanco-backend's scripts/seed-encyclopedia.js).
// A symbol with no content yet is expected, not an error — every field on
// [CompanyEncyclopediaEntry] is nullable and the widget shows its own
// "no data yet" state per row instead.
// ---------------------------------------------------------------------------

class CompanyEncyclopediaEntry {
  final String? businessHistoryRu;
  final String? businessHistoryEn;
  final String? marketHistoryRu;
  final String? marketHistoryEn;
  final String? presentDayRu;
  final String? presentDayEn;

  const CompanyEncyclopediaEntry({
    this.businessHistoryRu,
    this.businessHistoryEn,
    this.marketHistoryRu,
    this.marketHistoryEn,
    this.presentDayRu,
    this.presentDayEn,
  });

  factory CompanyEncyclopediaEntry.fromJson(Map<String, dynamic> json) =>
      CompanyEncyclopediaEntry(
        businessHistoryRu: json['businessHistoryRu'] as String?,
        businessHistoryEn: json['businessHistoryEn'] as String?,
        marketHistoryRu: json['marketHistoryRu'] as String?,
        marketHistoryEn: json['marketHistoryEn'] as String?,
        presentDayRu: json['presentDayRu'] as String?,
        presentDayEn: json['presentDayEn'] as String?,
      );

  /// Picks RU or EN by the app's current locale, falling back to whichever
  /// language IS filled in when the other is still missing — content is
  /// added company-by-company and language-by-language, so a company with
  /// only a Russian draft so far should still show something to an EN user
  /// rather than a premature "no data" while translation is pending.
  String? businessHistory(BuildContext context) => _pick(
    context,
    businessHistoryRu,
    businessHistoryEn,
  );

  String? marketHistory(BuildContext context) => _pick(
    context,
    marketHistoryRu,
    marketHistoryEn,
  );

  String? presentDay(BuildContext context) => _pick(
    context,
    presentDayRu,
    presentDayEn,
  );

  String? _pick(BuildContext context, String? ru, String? en) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final primary = isRu ? ru : en;
    final fallback = isRu ? en : ru;
    return (primary != null && primary.isNotEmpty)
        ? primary
        : (fallback != null && fallback.isNotEmpty ? fallback : null);
  }
}

final companyEncyclopediaProvider = FutureProvider.autoDispose
    .family<CompanyEncyclopediaEntry, String>((ref, symbol) async {
      final json = await ref
          .read(finnhubServiceProvider)
          .encyclopedia(symbol);
      return CompanyEncyclopediaEntry.fromJson(json);
    });

// ---------------------------------------------------------------------------
// Ad-gate unlock state — free tier only. Deliberately NOT persisted:
// autoDispose means it resets to locked the moment nothing on Company
// Detail is watching it anymore (i.e. the user navigated away), matching
// the user's own spec: "вышел, снова хочет открыть — снова баннер"
// (leave and come back → the paywall/ad choice shows again). Scoped per
// symbol, not per article-type — watching one article's ad-gate for a
// company unlocks the other article for that same company too, since
// they're the same company's own encyclopedia entry, not separate content.
// ---------------------------------------------------------------------------

final companyEncyclopediaUnlockedProvider = StateProvider.autoDispose
    .family<bool, String>((ref, symbol) => false);
