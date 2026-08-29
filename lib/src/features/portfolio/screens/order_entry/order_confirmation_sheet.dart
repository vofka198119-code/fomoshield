import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/themed_divider.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../l10n/gen/app_localizations.dart';
import 'order_bottom_button.dart' show ReviewOrderButton;

// ---------------------------------------------------------------------------
// Order Confirmation Sheet — the "review your order" step every real broker
// app shows before actually submitting: symbol, side, quantity, price,
// subtotal, commission, and total, with a final Confirm/Cancel pair. Shared
// between real Portfolio and Stress Test order entry (both call sites pass
// their own already-computed fee) — pure presentation, no coupling to
// either trading engine.
// ---------------------------------------------------------------------------

/// Shows the confirmation sheet and returns true if the user tapped
/// Confirm, false/null if they backed out (Cancel, swipe-down, tap-outside).
Future<bool?> showOrderConfirmationSheet({
  required BuildContext context,
  required AppPalette palette,
  required String symbol,
  required String companyName,
  String? logoUrl,
  required bool isBuy,
  required String orderTypeLabel,
  required double shares,
  required double price,
  required double fee,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: palette.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _OrderConfirmationSheet(
      palette: palette,
      symbol: symbol,
      companyName: companyName,
      logoUrl: logoUrl,
      isBuy: isBuy,
      orderTypeLabel: orderTypeLabel,
      shares: shares,
      price: price,
      fee: fee,
    ),
  );
}

class _OrderConfirmationSheet extends StatelessWidget {
  final AppPalette palette;
  final String symbol;
  final String companyName;
  final String? logoUrl;
  final bool isBuy;
  final String orderTypeLabel;
  final double shares;
  final double price;
  final double fee;

  const _OrderConfirmationSheet({
    required this.palette,
    required this.symbol,
    required this.companyName,
    required this.logoUrl,
    required this.isBuy,
    required this.orderTypeLabel,
    required this.shares,
    required this.price,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtotal = shares * price;
    // Buying: fee is extra cost on top. Selling: fee comes out of proceeds.
    final total = isBuy ? subtotal + fee : subtotal - fee;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.orderConfirmTitle,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CompanyLogo(
                      ticker: symbol,
                      logoUrl: logoUrl,
                      radius: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      Text(
                        symbol,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isBuy
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFF3B30))
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isBuy ? l10n.tradeBuy : l10n.tradeSell,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isBuy
                          ? const Color(0xFF00C853)
                          : const Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            themedDivider(palette, indent: 0, endIndent: 0, height: 1),
            const SizedBox(height: 14),
            _row(l10n.tradeOrderTypeLabel, orderTypeLabel),
            _row(
              isBuy ? l10n.tradeSharesBoughtLabel : l10n.tradeSharesSoldLabel,
              shares.toStringAsFixed(4),
            ),
            _row(l10n.tradePricePerShareLabel, formatUsd(price)),
            _row(l10n.orderConfirmSubtotalLabel, formatUsd(subtotal)),
            if (fee > 0) _row(l10n.tradeCommissionLabel, formatUsd(fee)),
            const SizedBox(height: 4),
            themedDivider(palette, indent: 0, endIndent: 0, height: 1),
            const SizedBox(height: 10),
            _row(l10n.orderConfirmTotalLabel, formatUsd(total), emphasize: true),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.orderConfirmCancelButton,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textBody,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ReviewOrderButton(
                      isBuy: isBuy,
                      palette: palette,
                      onSubmit: () => Navigator.pop(context, true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    // Sheet background is palette.card — dark under Luxury Gold, but
    // plain white on Standard (ThemeV2.surface), so plain white text only
    // reads correctly under Luxury; Standard keeps its own textBody gray.
    final labelColor = emphasize
        ? palette.textHeader
        : (palette.titleGradient != null ? Colors.white : palette.textBody);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: emphasize ? 14 : 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: interNums(
              fontSize: emphasize ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: emphasize ? palette.accentPrimary : palette.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
