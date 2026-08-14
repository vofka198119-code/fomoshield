// ---------------------------------------------------------------------------
// Portfolio Cash Available — verbatim visual copy of Stress Test's
// StressTestCashWidget (stress_test/widgets/stress_test_cash_widget.dart):
// same dark-gradient card, same title/divider, same centered gold amount
// with glow. Driven by real PortfolioPerformance.cash instead of a
// simulated session's cash.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;

class PortfolioCashWidget extends StatelessWidget {
  final double? cash;
  final bool isLoading;
  final bool hasError;

  const PortfolioCashWidget({
    super.key,
    this.cash,
    this.isLoading = false,
    this.hasError = false,
  });

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
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
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
              child: hasError
                  ? Text(
                      '—',
                      textAlign: TextAlign.center,
                      style: interNums(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: dialBrassLight.withValues(alpha: 0.6),
                      ),
                    )
                  : isLoading || cash == null
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: dialBrassLight,
                        ),
                      ),
                    )
                  : Text(
                      '\$${_fmtFull(cash!)}',
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
