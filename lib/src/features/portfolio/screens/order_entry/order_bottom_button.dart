import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import 'order_amount_section.dart' show OrderInputMode;

// ---------------------------------------------------------------------------
// Order Bottom Button — "Review Order", restyled to match Company Card's
// BUY/SELL bar (company_bottom_bar.dart): olive fill + black text for buy,
// dark-green brand gradient + white text for sell, radius 18.
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
    final canExecute = onSubmit != null;

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
                    inputMode == OrderInputMode.cost ? 'Cost:' : 'Qty:',
                    style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary),
                  ),
                  Text(
                    inputMode == OrderInputMode.cost
                        ? '\$${displayAmount.toStringAsFixed(2)}'
                        : '${displayAmount.toStringAsFixed(4)} sh.',
                    style: interNums(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          _button(canExecute),
        ],
      ),
    );
  }

  Widget _button(bool canExecute) {
    if (!canExecute) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: ThemeV2.textSecondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          'Review Order',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (isBuy) {
      return Material(
        color: Color.alphaBlend(ThemeV2.primaryBg, Colors.white),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            child: Text(
              'Review Order',
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [dialLight, dialDark],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: onSubmit,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.center,
            child: Text(
              'Review Order',
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
