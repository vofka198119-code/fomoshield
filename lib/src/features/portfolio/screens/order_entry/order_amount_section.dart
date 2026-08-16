import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../market_clock/market_clock_dial.dart'
    show dialDark, dialBrassLight, darkCardDecoration, darkCardGradient;

// ---------------------------------------------------------------------------
// Order Amount Section — the amount input (plain, no card, green text,
// same size class as the price in OrderHeader) with a small dark-green
// gradient circle to its right for toggling Cost/Shares — replaces the
// old popup-sheet mode selector entirely (user's ask, 2026-08-01) — and
// the 0-100% slider below.
// ---------------------------------------------------------------------------

enum OrderInputMode { cost, shares }

class OrderAmountSection extends StatelessWidget {
  final TextEditingController controller;
  final OrderInputMode inputMode;
  final ValueChanged<OrderInputMode> onInputModeChanged;
  final bool isBuy;
  final double currentPrice;
  final double availableCash;
  final double heldShares;
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onAmountChanged;
  final VoidCallback onTapAmount;

  const OrderAmountSection({
    super.key,
    required this.controller,
    required this.inputMode,
    required this.onInputModeChanged,
    required this.isBuy,
    required this.currentPrice,
    required this.availableCash,
    required this.heldShares,
    required this.sliderValue,
    required this.onSliderChanged,
    required this.onAmountChanged,
    required this.onTapAmount,
  });

  // Slider/percentage ceiling for the current mode:
  //   cost + buy    -> cash on hand
  //   cost + sell   -> value of the held position
  //   shares + buy  -> shares affordable with the cash on hand
  //   shares + sell -> shares held
  double get _maxAmount {
    if (inputMode == OrderInputMode.cost) {
      return isBuy ? availableCash : currentPrice * heldShares;
    }
    if (isBuy) {
      return currentPrice > 0 ? availableCash / currentPrice : 0;
    }
    return heldShares;
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = double.tryParse(controller.text) ?? 0;

    return Column(children: [_amountInput(displayAmount), _slider()]);
  }

  Widget _amountInput(double displayAmount) {
    final hasValue = controller.text.isNotEmpty;
    final numberText = hasValue ? controller.text : '0';
    final numberColor = hasValue
        ? ThemeV2.textPrimary
        : ThemeV2.textPrimary.withValues(alpha: 0.3);
    // Only the newest digit animates in — the rest of the number stays
    // put. Animating the whole string on every keystroke made the entire
    // number flash/strobe instead of reading as a single digit popping in.
    final settledDigits = numberText.substring(0, numberText.length - 1);
    final newestDigit = numberText.substring(numberText.length - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Balances the toggle circle on the right so the number
              // stays visually centered in the row.
              const SizedBox(width: 44),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapAmount,
                    // "$" sits directly in front of the number as one
                    // glued unit — not a decoration prefix pinned to the
                    // field's far edge, which is what made it look
                    // disconnected from the digits before.
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (inputMode == OrderInputMode.cost)
                          Text(
                            '\$ ',
                            style: interNums(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: numberColor,
                            ),
                          ),
                        Text(
                          settledDigits,
                          style: interNums(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                            color: numberColor,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.4,
                              end: 1,
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: Text(
                            newestDigit,
                            key: ValueKey(numberText),
                            style: interNums(
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                              color: numberColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _modeToggle(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            inputMode == OrderInputMode.cost ? 'USD' : 'Shares',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ThemeV2.textSecondary,
            ),
          ),
          if (displayAmount > 0 && inputMode == OrderInputMode.cost)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '≈ ${currentPrice > 0 ? (displayAmount / currentPrice).toStringAsFixed(4) : '0'} shares',
                textAlign: TextAlign.center,
                style: interNums(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          if (displayAmount > 0 && inputMode == OrderInputMode.shares)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '≈ ${formatUsd(displayAmount * currentPrice)}',
                textAlign: TextAlign.center,
                style: interNums(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dark-green gradient circle — taps to swap between Cost/Shares input,
  // replacing the old bottom-sheet picker entirely.
  Widget _modeToggle() {
    return GestureDetector(
      onTap: () => onInputModeChanged(
        inputMode == OrderInputMode.cost
            ? OrderInputMode.shares
            : OrderInputMode.cost,
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: darkCardGradient(),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.swap_vert_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _slider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: darkCardDecoration(),
        child: Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                activeTrackColor: dialBrassLight,
                inactiveTrackColor: dialBrassLight.withValues(alpha: 0.25),
                thumbColor: dialBrassLight,
                overlayColor: dialBrassLight.withValues(alpha: 0.2),
                valueIndicatorColor: dialBrassLight,
                valueIndicatorTextStyle: GoogleFonts.inter(
                  color: dialDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Slider(
                value: sliderValue,
                onChanged: (v) {
                  final maxVal = _maxAmount;
                  final newVal = maxVal * v;
                  controller.text = newVal > 0
                      ? newVal.toStringAsFixed(newVal < 1 ? 4 : 2)
                      : '';
                  onSliderChanged(v);
                },
                divisions: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _pctLabel('0%'),
                  _pctLabel('25%'),
                  _pctLabel('50%'),
                  _pctLabel('75%'),
                  _pctLabel('100%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pctLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: dialBrassLight,
      ),
    );
  }
}
