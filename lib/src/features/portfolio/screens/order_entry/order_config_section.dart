import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/card_frame.dart';
import '../../../../shared/widgets/simulated_trading_disclaimer.dart';
import '../../../../l10n/gen/app_localizations.dart';
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
  final AppPalette palette;

  const OrderConfigSection({
    super.key,
    required this.isLimit,
    required this.limitPriceController,
    required this.currentPrice,
    required this.isBuy,
    required this.onTapLimitPriceField,
    required this.infoText,
    required this.palette,
    this.extendedHours,
    this.onExtendedHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (isLimit)
          LimitPriceInput(
            controller: limitPriceController,
            currentPrice: currentPrice,
            isBuy: isBuy,
            onTapField: onTapLimitPriceField,
            palette: palette,
          ),
        _infoBox(),
        if (extendedHours != null && onExtendedHoursChanged != null)
          _extendedHoursToggle(l10n, extendedHours!, onExtendedHoursChanged!),
        const SimulatedTradingDisclaimer(),
      ],
    );
  }

  Widget _infoBox() {
    return CardFrame(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: palette.titleGradient != null
                ? Colors.white
                : palette.textBody,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              infoText,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: palette.titleGradient != null
                    ? Colors.white
                    : palette.textBody,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _extendedHoursToggle(
    AppLocalizations l10n,
    bool extendedHours,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: CardFrame(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: palette.textBody,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.orderEntryExtendedHoursTitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textHeader,
                    ),
                  ),
                  Text(
                    l10n.orderEntryExtendedHoursSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: extendedHours,
              onChanged: onChanged,
              activeTrackColor: palette.accentPrimary,
              // Off-state + outline only recolored under Luxury Gold
              // (gated on windowGradient, same as every other themed
              // toggle) — Standard keeps the plain Material defaults it
              // always had.
              inactiveThumbColor: palette.windowGradient != null
                  ? palette.textBody
                  : null,
              inactiveTrackColor: palette.windowGradient != null
                  ? palette.card
                  : null,
              trackOutlineColor: palette.windowGradient != null
                  ? WidgetStateProperty.all(palette.border)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
