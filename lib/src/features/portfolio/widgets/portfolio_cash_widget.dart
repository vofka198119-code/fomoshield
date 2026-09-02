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
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../../../l10n/gen/app_localizations.dart';

class PortfolioCashWidget extends StatelessWidget {
  final double? cash;
  final bool isLoading;
  final bool hasError;
  final AppPalette palette;

  const PortfolioCashWidget({
    super.key,
    this.cash,
    this.isLoading = false,
    this.hasError = false,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: FomoShieldTheme.shadowSoft,
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      palette: palette,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              // Always-dark panel in both themes.
              child: themedGoldGradient(
                Text(
                  AppLocalizations.of(context)!.portfolioCashLabel,
                  style: FomoShieldTheme.cardTitle(Colors.white).copyWith(
                    shadows: palette.titleShadow != null
                        ? [palette.titleShadow!]
                        : null,
                  ),
                ),
                palette,
              ),
            ),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
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
                      formatUsd(cash!),
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
