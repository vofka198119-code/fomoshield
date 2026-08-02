import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
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
        _disclaimer(),
      ],
    );
  }

  Widget _disclaimer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            'Simulated Trading & Non-Brokerage Disclaimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This application is not a registered broker-dealer, investment '
            'advisor, or financial institution, and does not provide order '
            'execution services for real financial markets.\n\n'
            'All buy and sell operations are performed exclusively on a '
            'simulated account using virtual currency (Paper Trading). '
            'Transactions executed within this app are intended solely for '
            'educational purposes, do not result in the purchase or '
            'ownership of actual securities, create no shareholder rights, '
            'and carry no real-world financial or legal force.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: ThemeV2.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
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
