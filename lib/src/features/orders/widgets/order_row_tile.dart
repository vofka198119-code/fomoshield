import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../order_model.dart';
import '../order_provider.dart';
import '../order_cancel_dialog.dart';

// ---------------------------------------------------------------------------
// Order Row Tile — one active order, shared by the Company Detail and
// Portfolio "Limit Orders" widgets and the "see all" sheet. Cancel (X)
// always confirms first (see order_cancel_dialog.dart). Three stacked
// lines (side+quantity / company name / limit price) inside the app's
// themed window box (Standard keeps the original olive brand tint —
// ThemeV2.primaryBg + ThemeV2.divider border; other themes get
// [AppPalette.windowGradient] + a themedBorder ring, same as every other
// inner window in the app — was hardcoded light regardless of theme,
// which read as a stray light box on a dark Luxury Gold/Midnight Sea
// screen, fixed 2026-09-04) — one order per box rather than a single
// cramped line.
// ---------------------------------------------------------------------------

class OrderRowTile extends ConsumerWidget {
  final Order order;
  final String? subtitle;
  final AppPalette palette;

  const OrderRowTile({
    super.key,
    required this.order,
    this.subtitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isBuy = order.side == OrderSide.buy;
    final accentColor = isBuy ? ThemeV2.success : ThemeV2.loss;
    final price = order.limitPrice ?? order.stopPrice;
    final companyName = order.companyName ?? order.assetSymbol;

    // The margin lives on this outer Padding, not on themedBorder's own
    // `margin` param — themedBorder is a no-op for any theme without a
    // borderGradient (Standard is the only one left without one as of
    // 2026-09-06 — every admin preview theme now sets one), and a no-op
    // drops whatever margin it was asked to draw along with it (see
    // more_less_pill.dart's own fix, same bug, 2026-09-04).
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
                      isBuy
                          ? l10n.stressTestOrderRowBuyLine(
                              formatOrderQuantity(order.quantity),
                            )
                          : l10n.stressTestOrderRowSellLine(
                              formatOrderQuantity(order.quantity),
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
                    if (price != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.orderRowTilePriceLabel(
                          order.type.label,
                          formatUsd(price),
                        ),
                        style: interNums(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.accentPrimary,
                        ),
                      ),
                    ],
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                    ],
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
                        .read(ordersProvider.notifier)
                        .cancelOrder(order.orderId);
                  }
                },
              ),
            ],
          ),
        ),
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
