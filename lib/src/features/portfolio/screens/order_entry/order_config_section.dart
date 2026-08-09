import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../../shared/widgets/simulated_trading_disclaimer.dart';
import 'limit_price_input.dart';

// ---------------------------------------------------------------------------
// Order Config Section — limit price input (Limit orders only), the order
// type info box, and extended-hours toggle. Grouped as the secondary
// order-configuration block.
// ---------------------------------------------------------------------------

class OrderConfigSection extends StatelessWidget {
  final bool isLimit;
  final TextEditingController limitPriceController;
  final double currentPrice;
  final bool isBuy;
  final VoidCallback onTapLimitPriceField;
  final String infoText;
  // Null on both hides the toggle entirely — for markets with no concept
  // of trading hours (Stress Test's simulated market is always open).
  final bool? extendedHours;
  final ValueChanged<bool>? onExtendedHoursChanged;

  const OrderConfigSection({
    super.key,
    required this.isLimit,
    required this.limitPriceController,
    required this.currentPrice,
    required this.isBuy,
    required this.onTapLimitPriceField,
    required this.infoText,
    this.extendedHours,
    this.onExtendedHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLimit)
          LimitPriceInput(
            controller: limitPriceController,
            currentPrice: currentPrice,
            isBuy: isBuy,
            onTapField: onTapLimitPriceField,
          ),
        _infoBox(),
        if (extendedHours != null && onExtendedHoursChanged != null)
          _extendedHoursToggle(extendedHours!, onExtendedHoursChanged!),
        const SimulatedTradingDisclaimer(),
      ],
    );
  }

  Widget _infoBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: FomoShieldTheme.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: ThemeV2.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              infoText,
              style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _extendedHoursToggle(bool extendedHours, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: FomoShieldTheme.cardDecoration,
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: ThemeV2.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extended Hours',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  Text(
                    'Off: trade only while the real market is open',
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: extendedHours,
              onChanged: onChanged,
              activeTrackColor: ThemeV2.primary,
            ),
          ],
        ),
      ),
    );
  }

}
