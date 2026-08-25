import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../orders/order_provider.dart';
import '../../orders/widgets/order_row_tile.dart';
import '../../orders/widgets/order_list_sheet.dart';
import '../../portfolio/portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Limit Orders Section — Company Detail's lowest widget. Lists this
// symbol's active (pending) orders across all portfolios, capped to 5 with
// a "See all" sheet beyond that. Logic/wiring only for now, per user's ask
// 2026-08-02 — visual pass deferred, currently a plain light card.
// ---------------------------------------------------------------------------

const int _inlineLimit = 5;

class LimitOrdersSection extends ConsumerWidget {
  final String symbol;
  final AppPalette palette;

  const LimitOrdersSection({
    super.key,
    required this.symbol,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref
        .watch(activeOrdersProvider)
        .where((o) => o.assetSymbol == symbol)
        .toList();

    if (orders.isEmpty) return const SizedBox.shrink();

    final portfolios = ref.watch(portfoliosProvider);
    String portfolioNameFor(String portfolioId) => portfolios
        .firstWhere(
          (p) => p.id == portfolioId,
          orElse: () => Portfolio(id: '', name: ''),
        )
        .name;

    final shown = orders.take(_inlineLimit).toList();

    return CardFrame(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.companyDetailLimitOrdersTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette, indent: 0, endIndent: 0)
              : const Divider(height: 20, color: Color(0x0F000000)),
          for (final order in shown)
            OrderRowTile(
              order: order,
              subtitle: portfolioNameFor(order.portfolioId),
            ),
          if (orders.length > _inlineLimit)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Center(
                child: TextButton(
                  onPressed: () => showOrderListSheet(
                    context,
                    title: l10n.companyDetailSymbolLimitOrdersTitle(symbol),
                    orders: orders,
                    subtitleFor: (o) => portfolioNameFor(o.portfolioId),
                  ),
                  child: Text(
                    l10n.myLimitOrdersSeeAll(orders.length),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.accentPrimary,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}
