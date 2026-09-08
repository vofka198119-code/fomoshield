import 'package:flutter/material.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../company_detail/widgets/price_header.dart';
import '../models/fund.dart';

// Thin wrapper around Company Detail's own PriceHeader — reused directly
// (not reimplemented) so this card is pixel-identical to a real company's,
// per "делаем такой же вид как и карточки компании". fsScore stays null
// (renders PriceHeader's own empty-gauge placeholder) until the user
// decides what an FS Score means for a fund.
class FundPriceHeader extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundPriceHeader({super.key, required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final history = fund.navHistory;
    double change = 0;
    double changePercent = 0;
    if (history.length >= 2) {
      final prev = history[history.length - 2].navPerUnit;
      final last = history.last.navPerUnit;
      change = last - prev;
      changePercent = prev == 0 ? 0 : change / prev * 100;
    }

    return PriceHeader(
      companyName: fund.name,
      symbol: fund.ticker,
      price: fund.navPerUnit,
      change: change,
      changePercent: changePercent,
      isUp: change >= 0,
      changeLabel: l10n.companyDetailChangeLabel,
      fsScore: null,
      palette: palette,
      isEtf: true,
    );
  }
}
