import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// FundCashWidget — "Доступно" as its own widget (2026-09-13 ask: split out
// of FundBalanceCard, one number per card like Portfolio does it). Verbatim
// visual copy of PortfolioCashWidget/StressTestCashWidget: same
// dark-gradient card, same title/divider, same centered gold amount —
// the app's one established recipe for "one big number, its own card".
// ---------------------------------------------------------------------------
class FundCashWidget extends StatelessWidget {
  final double cash;
  final AppPalette palette;

  const FundCashWidget({super.key, required this.cash, required this.palette});

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
                  AppLocalizations.of(context)!.etfFundBalanceAvailableLabel,
                  style: FomoShieldTheme.cardTitle(
                    palette.onWindow ?? Colors.white,
                  ).copyWith(
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
                  color: (palette.onWindow ?? Colors.white).withValues(
                    alpha: 0.12,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                formatUsd(cash),
                textAlign: TextAlign.center,
                style: interNums(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: palette.onWindow ?? Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
