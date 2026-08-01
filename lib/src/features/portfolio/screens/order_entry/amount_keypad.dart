import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// Amount Keypad — custom numeric input replacing the system Android
// keyboard for the amount field. Plain 1-9 / 0 / . / backspace grid, no
// extras (no emoji row, no currency toggle here — that lives in the
// dark-green circle next to the amount) — user's explicit ask, 2026-08-01.
// ---------------------------------------------------------------------------

class AmountKeypad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onDone;

  const AmountKeypad({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onDone,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: const BoxDecoration(
        color: ThemeV2.surface,
        border: Border(top: BorderSide(color: ThemeV2.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDone,
              child: Text(
                'Done',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          ),
          _row(['1', '2', '3']),
          _row(['4', '5', '6']),
          _row(['7', '8', '9']),
          _row(['.', '0', '⌫']),
        ],
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
              color: ThemeV2.surfaceDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: label == '⌫'
                ? const Icon(Icons.backspace_outlined, color: ThemeV2.textPrimary, size: 20)
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
