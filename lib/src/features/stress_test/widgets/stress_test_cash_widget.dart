// ---------------------------------------------------------------------------
// Stress Test — Cash Available card
// Split out of StressTestAllocationChart (Phase 5, step-by-step widget pass)
// so the cash balance reads as its own widget rather than a capsule glued
// to the bottom of the allocation donut.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialLight, dialDark, dialBrassLight;
import '../stress_test_models.dart';

/// Dark-green gradient card (same brand gradient as TARGET / Shield Signal)
/// showing the session's available cash: left-aligned "CASH AVAILABLE"
/// title + divider, then the amount centered below in brand gold.
class StressTestCashWidget extends StatelessWidget {
  final StressTestSession session;

  const StressTestCashWidget({super.key, required this.session});

  /// Full number format with commas and fixed 2 decimals — e.g. $15,000.00
  String _fmtFull(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intStr = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
      buf.write(intStr[i]);
    }
    buf.write('.');
    buf.write(parts[1]);
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dialLight, dialDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Text(
                'CASH AVAILABLE',
                style: FomoShieldTheme.cardTitle(Colors.white),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '\$${_fmtFull(session.cash)}',
                textAlign: TextAlign.center,
                style:
                    interNums(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: dialBrassLight,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: dialBrassLight.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
