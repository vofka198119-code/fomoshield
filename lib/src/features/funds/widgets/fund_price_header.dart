import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../company_detail/widgets/price_header.dart';
import '../models/fund.dart';
import '../providers/fund_chart_hover_provider.dart';

// Thin wrapper around Company Detail's own PriceHeader — reused directly
// (not reimplemented) so this card is pixel-identical to a real company's,
// per "делаем такой же вид как и карточки компании". fsScore stays null
// (renders PriceHeader's own empty-gauge placeholder) until the user
// decides what an FS Score means for a fund.
class FundPriceHeader extends ConsumerWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundPriceHeader({super.key, required this.fund, required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Live navPerUnit against the previous DAY's snapshot — the same
    // "price vs prevClose" shape as a real stock quote.
    //
    // Two earlier attempts got this wrong in opposite directions. The first
    // compared two history entries against each other and never touched the
    // live price, so the badge sat dead all day while the price above it
    // moved (2026-09-16). The fix compared the live price against
    // history.last — correct until the server started upserting TODAY's row
    // every hour (fundNavSnapshotService), which made history.last today's
    // own value, refreshed minutes ago. The badge then read ~0.00% all day
    // again, for a different reason (reported on-device 2026-10-07).
    //
    // So: skip back to the last entry from a different day. Matching on the
    // day itself rather than on the device's clock matters — snapshot_date
    // is a UTC day and the phone can be hours ahead of it, so "is this row
    // today's?" has no stable answer here, while "is it the same day as the
    // newest row?" does.
    final history = fund.navHistory;
    double change = 0;
    double changePercent = 0;
    if (history.isNotEmpty) {
      final newestDay = _dayKey(history.last.date);
      double? previousClose;
      for (var i = history.length - 1; i >= 0; i--) {
        if (_dayKey(history[i].date) != newestDay) {
          previousClose = history[i].navPerUnit;
          break;
        }
      }
      // A fund on its first day has nothing to compare against yet; 0.00%
      // is the honest answer there, not a number invented from its seed NAV.
      if (previousClose != null && previousClose != 0) {
        change = fund.navPerUnit - previousClose;
        changePercent = change / previousClose * 100;
      }
    }

    // While a point on the NAV chart is held, the header shows THAT day
    // instead of the live value — price, change and all. Company Detail
    // moves only its price cell while scrubbing, because its change cell
    // belongs to the selected period; a fund has no period tabs worth
    // speaking of yet, so here the whole badge follows the finger, which is
    // what was actually asked for.
    final hover = ref.watch(fundChartHoverProvider(fund.id));
    double price = fund.navPerUnit;
    if (hover != null) {
      price = hover.point.value;
      final before = hover.previous?.value;
      change = before == null ? 0 : price - before;
      changePercent = (before == null || before == 0)
          ? 0
          : change / before * 100;
    }

    return PriceHeader(
      companyName: fund.name,
      symbol: fund.ticker,
      price: price,
      change: change,
      changePercent: changePercent,
      isUp: change >= 0,
      changeLabel: l10n.companyDetailChangeLabel,
      fsScore: null,
      palette: palette,
      isEtf: true,
    );
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
