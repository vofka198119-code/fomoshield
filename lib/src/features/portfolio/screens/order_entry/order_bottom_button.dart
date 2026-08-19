import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../../../../l10n/gen/app_localizations.dart';
import 'order_amount_section.dart' show OrderInputMode;

// ---------------------------------------------------------------------------
// Order Bottom Button — "Place Order": dark-green brand gradient + white
// text for buy, olive fill + black text for sell, radius 18.
// ---------------------------------------------------------------------------

class OrderBottomButton extends StatelessWidget {
  final bool isBuy;
  final OrderInputMode inputMode;
  final double displayAmount;
  final VoidCallback? onSubmit;

  const OrderBottomButton({
    super.key,
    required this.isBuy,
    required this.inputMode,
    required this.displayAmount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: ThemeV2.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayAmount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    inputMode == OrderInputMode.cost
                        ? l10n.orderEntryCostLabel
                        : l10n.orderEntryQtyLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                  Text(
                    inputMode == OrderInputMode.cost
                        ? formatUsd(displayAmount)
                        : l10n.orderEntrySharesAbbrev(
                            displayAmount.toStringAsFixed(4),
                          ),
                    style: interNums(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ReviewOrderButton(isBuy: isBuy, onSubmit: onSubmit),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Review Order Button — the actual olive/dark-green CTA, pulled out on its
// own so AmountKeypad can also show it (compact) above the numeric grid.
// ---------------------------------------------------------------------------

class ReviewOrderButton extends StatelessWidget {
  final bool isBuy;
  final VoidCallback? onSubmit;
  final double height;

  const ReviewOrderButton({
    super.key,
    required this.isBuy,
    required this.onSubmit,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canExecute = onSubmit != null;

    if (!canExecute) {
      return Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: ThemeV2.textSecondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.orderEntryPlaceOrder,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (!isBuy) {
      return Material(
        color: Color.alphaBlend(ThemeV2.primaryBg, Colors.white),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            child: Text(
              l10n.orderEntryPlaceOrder,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: darkCardDecoration(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            child: Text(
              l10n.orderEntryPlaceOrder,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
