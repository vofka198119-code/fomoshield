import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;

// Stub for Phase 2 (Buy/Sell fund units). Same "MY INVESTMENTS" title/skin
// as Company Detail's PositionSection, but every value is a dash until
// fund_investor_positions exists.
class FundInvestmentsStubCard extends StatelessWidget {
  final AppPalette palette;

  const FundInvestmentsStubCard({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onWindow = palette.onWindow ?? Colors.white;

    return CardFrame(
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: FomoShieldTheme.cardRadius,
              boxShadow: FomoShieldTheme.shadowSoft,
            )
          : darkCardDecoration(),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedGoldGradient(
            Text(
              l10n.companyDetailPositionTitle,
              style: FomoShieldTheme.cardTitle(onWindow),
            ),
            palette,
          ),
          const SizedBox(height: 10),
          palette.dividerGradient != null
              ? themedDivider(palette, indent: 0, endIndent: 0)
              : Divider(height: 1, color: onWindow.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.etfFundDetailInvestmentsStubNote,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onWindow.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
