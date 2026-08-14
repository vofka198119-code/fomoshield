import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../stress_test_pending_orders_provider.dart';
import '../../assets/screens/stock_detail/widgets/stress_test_order_row_tile.dart';

// ---------------------------------------------------------------------------
// Stress Test My Limit Orders — session-wide widget listing this session's
// active limit orders across ALL symbols, mirroring Portfolio's
// my_limit_orders_widget.dart. Unlike Stock Detail's own per-symbol
// StockLimitOrdersSection (which hides itself when empty), this one never
// hides — an empty state still shows a "no active orders" line — capped to
// 5 inline with a live "See all" sheet beyond that.
// ---------------------------------------------------------------------------

const int _inlineLimit = 5;

class StressTestMyLimitOrdersWidget extends ConsumerWidget {
  final String sessionId;

  const StressTestMyLimitOrdersWidget({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(stressTestSessionPendingOrdersProvider(sessionId));
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
            for (final order in shown) StressTestOrderRowTile(order: order),
            if (orders.length > _inlineLimit)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 10),
                child: Center(
                  child: TextButton(
                    onPressed: () => _showAllSheet(context),
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

  void _showAllSheet(BuildContext context) {
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
                'My Limit Orders',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    // Watched live so a fill/cancel while the sheet is open
                    // updates the list instead of showing a stale snapshot
                    // (same fix as Stock Detail's own sheet).
                    final liveOrders = ref.watch(
                      stressTestSessionPendingOrdersProvider(sessionId),
                    );
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: liveOrders.length,
                      itemBuilder: (_, i) =>
                          StressTestOrderRowTile(order: liveOrders[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
