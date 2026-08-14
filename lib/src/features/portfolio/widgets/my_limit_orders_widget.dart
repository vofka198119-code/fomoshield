import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../orders/order_provider.dart';
import '../../orders/widgets/order_row_tile.dart';
import '../../orders/widgets/order_list_sheet.dart';

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

  const MyLimitOrdersWidget({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref
        .watch(activeOrdersProvider)
        .where((o) => o.portfolioId == portfolioId)
        .toList();
    final shown = orders.take(_inlineLimit).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MY LIMIT ORDERS', style: FomoShieldTheme.cardTitle()),
          const Divider(height: 20, color: Color(0x0F000000)),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                'You currently have no active orders',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ThemeV2.textSecondary,
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
                      title: 'My Limit Orders',
                      orders: orders,
                      subtitleFor: (_) => null,
                    ),
                    child: Text(
                      'See all ${orders.length} orders',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.primary,
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
