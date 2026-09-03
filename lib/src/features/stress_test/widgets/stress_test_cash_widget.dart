// ---------------------------------------------------------------------------
// Stress Test — Cash Available card
// Split out of StressTestAllocationChart (Phase 5, step-by-step widget pass)
// so the cash balance reads as its own widget rather than a capsule glued
// to the bottom of the allocation donut.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../stress_test_models.dart';

/// Dark-green gradient card (same brand gradient as TARGET / Shield Signal)
/// showing the session's available cash: left-aligned "CASH AVAILABLE"
/// title + divider, then the amount centered below in brand gold.
class StressTestCashWidget extends StatelessWidget {
  final StressTestSession session;
  final AppPalette palette;

  const StressTestCashWidget({
    super.key,
    required this.session,
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
              child: Text(
                formatUsd(session.cash),
                textAlign: TextAlign.center,
                style: interNums(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
