import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../order_model.dart';
import '../order_provider.dart';
import '../order_cancel_dialog.dart';

// ---------------------------------------------------------------------------
// Order Row Tile — one active order, shared by the Company Detail and
// Portfolio "Limit Orders" widgets and the "see all" sheet. Cancel (X)
// always confirms first (see order_cancel_dialog.dart). Three stacked
// lines (side+quantity / company name / limit price) inside the app's
// olive brand tint box (same recipe as Home's Portfolio Balance/Cash
// cells: ThemeV2.primaryBg + ThemeV2.divider border) — one order per box
// rather than a single cramped line.
// ---------------------------------------------------------------------------

class OrderRowTile extends ConsumerWidget {
  final Order order;
  final String? subtitle;

  const OrderRowTile({super.key, required this.order, this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuy = order.side == OrderSide.buy;
    final accentColor = isBuy ? ThemeV2.success : ThemeV2.loss;
    final price = order.limitPrice ?? order.stopPrice;
    final companyName = order.companyName ?? order.assetSymbol;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeV2.primaryBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? 'Buy' : 'Sell'} ${formatOrderQuantity(order.quantity)} shares',
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  companyName,
                  style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textPrimary),
                ),
                if (price != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${order.type.label} Price \$${price.toStringAsFixed(2)}',
                    style: interNums(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.primary,
                    ),
                  ),
                ],
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: ThemeV2.textSecondary),
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              final confirmed = await confirmCancelOrder(context);
              if (confirmed) {
                ref.read(ordersProvider.notifier).cancelOrder(order.orderId);
              }
            },
          ),
        ],
      ),
    );
  }
}

String formatOrderQuantity(double quantity) {
  var s = quantity.toStringAsFixed(4);
  while (s.contains('.') && s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}
