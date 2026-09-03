import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/themed_border.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardGradient;
import '../../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Limit Price Input — no card box, everything center-stacked: a big green
// "LIMIT PRICE" title (widget-title style, bumped up a size), a one-line
// buy/sell hint, then the price itself with a +/-1¢ stepper. Tapping the
// price opens the shared amount keypad (via onTapField) for direct entry.
// ---------------------------------------------------------------------------

const double _step = 0.01;
const Duration _holdDelay = Duration(milliseconds: 400);
const Duration _repeatInterval = Duration(milliseconds: 70);

class LimitPriceInput extends StatefulWidget {
  final TextEditingController controller;
  final double currentPrice;
  final bool isBuy;
  final VoidCallback onTapField;
  final AppPalette palette;

  const LimitPriceInput({
    super.key,
    required this.controller,
    required this.currentPrice,
    required this.isBuy,
    required this.onTapField,
    required this.palette,
  });

  @override
  State<LimitPriceInput> createState() => _LimitPriceInputState();
}

class _LimitPriceInputState extends State<LimitPriceInput> {
  Timer? _holdDelayTimer;
  Timer? _repeatTimer;

  double get _value =>
      double.tryParse(widget.controller.text) ?? widget.currentPrice;

  void _adjust(double delta) {
    final next = ((_value + delta) * 100).round() / 100;
    if (next < _step) return;
    setState(() => widget.controller.text = next.toStringAsFixed(2));
  }

  void _startHold(double delta) {
    _adjust(delta);
    _holdDelayTimer = Timer(_holdDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) => _adjust(delta));
    });
  }

  void _stopHold() {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
  }

  @override
  void dispose() {
    _holdDelayTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          Text(
            l10n.orderEntryLimitPriceTitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: widget.palette.accentPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isBuy
                ? l10n.orderEntryLimitPriceHintBuy
                : l10n.orderEntryLimitPriceHintSell,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: widget.palette.textHeader,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTapField,
                  child: Text(
                    formatUsd(_value),
                    style: interNums(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: widget.palette.textHeader,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepperButton(Icons.keyboard_arrow_up_rounded, _step),
                    const SizedBox(height: 8),
                    _stepperButton(Icons.keyboard_arrow_down_rounded, -_step),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Same recipe as OrderAmountSection's Cost/Shares toggle circle
  // (order_amount_section.dart's _modeToggle) — windowGradient fill (or
  // the generic dark-green shell when a theme doesn't define one) with a
  // white icon, instead of a flat accent-tinted fill.
  Widget _stepperButton(IconData icon, double delta) {
    return GestureDetector(
      onTapDown: (_) => _startHold(delta),
      onTapUp: (_) => _stopHold(),
      onTapCancel: _stopHold,
      child: themedBorder(
        palette: widget.palette,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.palette.windowGradient ?? darkCardGradient(),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
