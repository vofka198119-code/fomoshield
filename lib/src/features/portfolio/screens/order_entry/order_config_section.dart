import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';

// ---------------------------------------------------------------------------
// Order Config Section — limit price input (Limit orders only), the order
// type info box, extended-hours toggle, and expiration selector (Limit
// orders only). Grouped as the secondary order-configuration block.
// ---------------------------------------------------------------------------

class OrderConfigSection extends StatelessWidget {
  final bool isLimit;
  final TextEditingController limitPriceController;
  final String infoText;
  final bool extendedHours;
  final ValueChanged<bool> onExtendedHoursChanged;

  const OrderConfigSection({
    super.key,
    required this.isLimit,
    required this.limitPriceController,
    required this.infoText,
    required this.extendedHours,
    required this.onExtendedHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLimit) _limitPriceInput(),
        _infoBox(),
        _extendedHoursToggle(),
        if (isLimit) _expirationSelector(),
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

  Widget _limitPriceInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: FomoShieldTheme.cardDecoration,
        child: Row(
          children: [
            const Icon(Icons.trending_flat_rounded, color: ThemeV2.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Limit Price',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: TextField(
                controller: limitPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                ),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.primary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
          ],
        ),
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

  Widget _extendedHoursToggle() {
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
                    'Pre-market and post-market volatility',
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: extendedHours,
              onChanged: onExtendedHoursChanged,
              activeTrackColor: ThemeV2.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _expirationSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: FomoShieldTheme.cardDecoration,
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: ThemeV2.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiration',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  Text(
                    'Valid until end of day',
                    style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: ThemeV2.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
