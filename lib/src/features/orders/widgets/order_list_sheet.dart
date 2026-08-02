import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../order_model.dart';
import 'order_row_tile.dart';

// ---------------------------------------------------------------------------
// "See all" order list — swipe-up sheet listing every active order for a
// widget's scope (all of a symbol's orders, or all of a portfolio's),
// opened once a Limit Orders widget has more than it shows inline.
// ---------------------------------------------------------------------------

void showOrderListSheet(
  BuildContext context, {
  required String title,
  required List<Order> orders,
  required String? Function(Order) subtitleFor,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: ThemeV2.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ThemeV2.primary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: orders.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                itemBuilder: (_, i) => OrderRowTile(
                  order: orders[i],
                  subtitle: subtitleFor(orders[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
