import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';

// ---------------------------------------------------------------------------
// Numeric Keypad — custom digit input replacing the system Android
// keyboard anywhere the app needs a dollar/share/price amount. Plain 1-9 /
// 0 / . / backspace grid, no extras (no emoji row, no currency toggle).
// Dismissed by a downward swipe (drag handle above the grid), not a tap
// target. Extracted from Portfolio order entry's AmountKeypad (which now
// wraps this) so Set Goal's target-amount field (2026-08-09) could reuse
// the exact same input instead of a real TextField summoning the system
// keyboard. [header], if given, sits above the grid while typing — e.g. a
// submit button so the user doesn't have to dismiss the keypad first.
// ---------------------------------------------------------------------------

class NumericKeypad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onDone;
  final Widget? header;
  // Null (the default) is a complete no-op — every existing call site is
  // unaffected unless it opts in by passing a palette.
  final AppPalette? palette;

  const NumericKeypad({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onDone,
    this.header,
    this.palette,
  });

  void _tapDigit(String digit) {
    final current = controller.text;
    controller.text = current == '0' ? digit : current + digit;
    onChanged();
  }

  void _tapDot() {
    if (controller.text.contains('.')) return;
    controller.text = controller.text.isEmpty ? '0.' : '${controller.text}.';
    onChanged();
  }

  void _tapBackspace() {
    final current = controller.text;
    if (current.isEmpty) return;
    controller.text = current.substring(0, current.length - 1);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 200) onDone();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          gradient: palette?.windowGradient,
          // Matches backgroundGradient's bottom stop so the sheet blends
          // into the grey strip above the system nav bar instead of
          // showing a stark white-to-grey seam.
          color: palette?.windowGradient == null
              ? const Color(0xFFDCDBD7)
              : null,
          border: Border(top: BorderSide(color: palette?.border ?? ThemeV2.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: palette?.border ?? ThemeV2.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (header != null) ...[header!, const SizedBox(height: 10)],
            _row(['1', '2', '3']),
            _row(['4', '5', '6']),
            _row(['7', '8', '9']),
            _row(['.', '0', '⌫']),
          ],
        ),
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Row(children: keys.map((k) => Expanded(child: _key(k))).toList());
  }

  Widget _key(String label) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (label == '⌫') {
              _tapBackspace();
            } else if (label == '.') {
              _tapDot();
            } else {
              _tapDigit(label);
            }
          },
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // A dark "window" tile (not buttonGradient's bright gold —
              // cream digit glyphs need a dark backdrop to stay legible,
              // and bright-gold-on-bright-gold would be poor contrast).
              gradient: palette?.windowGradient,
              color: palette?.windowGradient == null
                  ? Color.alphaBlend(ThemeV2.primaryBg, Colors.white)
                  : null,
              borderRadius: BorderRadius.circular(14),
            ),
            child: label == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    color: palette?.textHeader ?? ThemeV2.textPrimary,
                    size: 20,
                  )
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: palette?.textHeader ?? ThemeV2.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
