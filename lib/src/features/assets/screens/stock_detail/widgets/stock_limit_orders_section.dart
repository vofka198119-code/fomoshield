import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../stress_test/stress_test_pending_order.dart';
import '../../../../stress_test/stress_test_pending_orders_provider.dart';
import 'stress_test_order_row_tile.dart';

// ---------------------------------------------------------------------------
// Stress Test Limit Orders — this symbol's active pending limit orders in
// this session, mirroring Company Detail's limit_orders_section.dart
// (same card standard, same 5-item cap + "See all" sheet). Reads from
// Stress Test's own isolated pending-orders provider, not the real orders
// feature.
// ---------------------------------------------------------------------------

const int _inlineLimit = 5;

class StockLimitOrdersSection extends ConsumerWidget {
  final String sessionId;
  final String symbol;

  const StockLimitOrdersSection({
    super.key,
    required this.sessionId,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref
        .watch(stressTestSessionPendingOrdersProvider(sessionId))
        .where((o) => o.symbol == symbol)
        .toList();

    if (orders.isEmpty) return const SizedBox.shrink();

    final shown = orders.take(_inlineLimit).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIMIT ORDERS', style: FomoShieldTheme.cardTitle()),
          const Divider(height: 20, color: Color(0x0F000000)),
          for (final order in shown) StressTestOrderRowTile(order: order),
          if (orders.length > _inlineLimit)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllSheet(context, orders),
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
      ),
    );
  }

  void _showAllSheet(BuildContext context, List<StressTestPendingOrder> orders) {
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
                '$symbol Limit Orders',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: orders.length,
                  itemBuilder: (_, i) => StressTestOrderRowTile(order: orders[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
