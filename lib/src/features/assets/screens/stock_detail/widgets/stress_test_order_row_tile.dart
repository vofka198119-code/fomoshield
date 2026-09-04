import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/typography_helpers.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/themed_border.dart';
import '../../../../../shared/utils/currency_format.dart';
import '../../../../orders/order_cancel_dialog.dart';
import '../../../../stress_test/stress_test_pending_order.dart';
import '../../../../stress_test/stress_test_pending_orders_provider.dart';
import '../../../../stress_test/stress_test_naming.dart';
import '../../../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Stress Test Order Row Tile — same themed-window visual as the real orders
// feature's order_row_tile.dart, but built for StressTestPendingOrder (a
// different model on purpose — see stress_test_pending_order.dart). Cancel
// reuses the same generic confirm dialog (order_cancel_dialog.dart takes no
// order-specific params).
// ---------------------------------------------------------------------------

class StressTestOrderRowTile extends ConsumerWidget {
  final StressTestPendingOrder order;
  final AppPalette palette;

  const StressTestOrderRowTile({
    super.key,
    required this.order,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor = order.isBuy ? ThemeV2.success : ThemeV2.loss;
    final companyName = resolveStressTestCompanyName(ref, order.symbol);

    // The margin lives on this outer Padding, not on themedBorder's own
    // `margin` param — see order_row_tile.dart's own fix, same bug,
    // 2026-09-04.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: themedBorder(
        palette: palette,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: palette.windowGradient,
            color: palette.windowGradient == null ? ThemeV2.primaryBg : null,
            borderRadius: BorderRadius.circular(16),
            border: palette.windowGradient == null
                ? Border.all(color: ThemeV2.divider)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5, right: 10),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.isBuy
                          ? l10n.stressTestOrderRowBuyLine(
                              _formatQuantity(order.quantity),
                            )
                          : l10n.stressTestOrderRowSellLine(
                              _formatQuantity(order.quantity),
                            ),
                      style: interNums(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textHeader,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      companyName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: palette.textHeader,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.stressTestOrderRowLimitPriceLine(
                        formatUsd(order.limitPrice),
                      ),
                      style: interNums(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: palette.textBody,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final confirmed = await confirmCancelOrder(context);
                  if (confirmed) {
                    ref
                        .read(stressTestPendingOrdersProvider.notifier)
                        .cancelOrder(order.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double quantity) {
    var s = quantity.toStringAsFixed(4);
    while (s.contains('.') && s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s;
  }
}
