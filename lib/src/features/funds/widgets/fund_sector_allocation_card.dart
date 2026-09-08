import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../../stress_test/widgets/allocation_bar_row.dart';
import '../models/fund.dart';

// Bars, not a pie/donut — same AllocationBarRow used by Stress Test's
// sector allocation card, computed from actual holdings (not fund.sectors'
// flat declared tags).
class FundSectorAllocationCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundSectorAllocationCard({
    super.key,
    required this.fund,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totals = <String, double>{};
    double total = 0;
    for (final h in fund.holdings) {
      final sector =
          resolveGicsSector(h.symbol)?.localizedLabel(l10n) ?? l10n.commonOther;
      totals[sector] = (totals[sector] ?? 0) + h.value;
      total += h.value;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
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
              l10n.etfFundDetailSectorsTitle,
              style: FomoShieldTheme.cardTitle(onWindow),
            ),
            palette,
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          if (total <= 0)
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  l10n.etfFundDetailHoldingsEmpty,
                  style: GoogleFonts.inter(fontSize: 13, color: onWindow),
                ),
              ),
            )
          else
            for (final e in sorted)
              AllocationBarRow(
                name: e.key,
                percent: e.value / total * 100,
                palette: palette,
                dangerZoneGradient: true,
              ),
        ],
      ),
    );
  }
}
