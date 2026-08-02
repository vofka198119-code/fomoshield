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
// always confirms first (see order_cancel_dialog.dart).
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? 'Buy' : 'Sell'} ${formatOrderQuantity(order.quantity)} '
                  '${order.assetSymbol} ${order.type.label}'
                  '${price != null ? ' @ \$${price.toStringAsFixed(2)}' : ''}',
                  style: interNums(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
                  ),
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
