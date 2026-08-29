import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/numeric_keypad.dart';
import 'order_amount_section.dart' show OrderInputMode;
import 'order_bottom_button.dart' show ReviewOrderButton;

// ---------------------------------------------------------------------------
// Amount Keypad — thin order-entry wrapper around the shared NumericKeypad
// grid (user's explicit ask, 2026-08-01; extracted to a shared widget
// 2026-08-09 so Set Goal's target-amount field could reuse the same input).
// The Review Order button rides above the grid while typing so users can
// submit without dismissing the keypad first; swiping down hands back to
// OrderBottomButton at the screen's bottom.
// ---------------------------------------------------------------------------

class AmountKeypad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onDone;
  final bool isBuy;
  final OrderInputMode inputMode;
  final double displayAmount;
  final VoidCallback? onSubmit;
  final AppPalette palette;

  const AmountKeypad({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onDone,
    required this.isBuy,
    required this.inputMode,
    required this.displayAmount,
    required this.onSubmit,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return NumericKeypad(
      controller: controller,
      onChanged: onChanged,
      onDone: onDone,
      header: ReviewOrderButton(
        isBuy: isBuy,
        onSubmit: onSubmit,
        palette: palette,
        height: 44,
      ),
      palette: palette,
    );
  }
}
