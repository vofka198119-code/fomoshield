import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../orders/order_provider.dart';
import '../../orders/widgets/order_row_tile.dart';
import '../../orders/widgets/order_list_sheet.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// My Limit Orders — Portfolio screen widget listing this portfolio's own
// active orders across all symbols. Unlike Company Detail's Limit Orders
// widget, this one never hides itself — an empty state still shows a
// small "no active orders" line — capped to 5 inline with a "See all"
// sheet beyond that. Logic/wiring only for now, visual pass deferred.
// ---------------------------------------------------------------------------

const int _inlineLimit = 5;

class MyLimitOrdersWidget extends ConsumerWidget {
  final String portfolioId;
  final AppPalette palette;

  const MyLimitOrdersWidget({
    super.key,
    required this.portfolioId,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref
        .watch(activeOrdersProvider)
        .where((o) => o.portfolioId == portfolioId)
        .toList();
    final shown = orders.take(_inlineLimit).toList();
    final l10n = AppLocalizations.of(context)!;

    return CardFrame(
      showTopBar: false,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.myLimitOrdersTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: themedDivider(palette, indent: 0, endIndent: 0),
          ),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                l10n.myLimitOrdersEmpty,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: palette.textBody,
                ),
              ),
            )
          else ...[
            for (final order in shown) OrderRowTile(order: order),
            if (orders.length > _inlineLimit)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 10),
                child: Center(
                  child: TextButton(
                    onPressed: () => showOrderListSheet(
                      context,
                      title: l10n.myLimitOrdersSheetTitle,
                      orders: orders,
                      subtitleFor: (_) => null,
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
        ],
      ),
    );
  }
}
