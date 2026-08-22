import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../../core/theme/typography_helpers.dart';
import '../../../../../shared/utils/currency_format.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../../../market_clock/market_clock_dial.dart'
    show darkCardDecoration;

// ---------------------------------------------------------------------------
// Stress Test "Your Position" card — visual match for real Portfolio's
// company_detail/widgets/position_section.dart ("MY INVESTMENTS": dark
// dialLight/dialDark gradient card, same row/label style). No swipeable
// pages here on purpose — a stress test is one sandbox, not multiple
// portfolios holding the same symbol, so there's only ever one position to
// show.
// ---------------------------------------------------------------------------

class StockPositionCard extends StatelessWidget {
  final double shares;
  final double avgPrice;
  final double pnl;

  const StockPositionCard({
    super.key,
    required this.shares,
    required this.avgPrice,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUp = pnl >= 0;
    final pnlColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final costBasis = shares * avgPrice;
    final positionValue = costBasis + pnl;
    final pnlPercent = costBasis > 0 ? (pnl / costBasis) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
      decoration: darkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stockPositionCardTitle,
            style: FomoShieldTheme.cardTitle(Colors.white),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          _row(l10n.stockPositionCardAssetValueLabel, formatUsd(positionValue)),
          const SizedBox(height: 8),
          _row(l10n.stockPositionCardSharesLabel, shares.toStringAsFixed(4)),
          const SizedBox(height: 8),
          _pnlRow(
            l10n: l10n,
            pnl: pnl,
            pnlPercent: pnlPercent,
            isUp: isUp,
            pnlColor: pnlColor,
          ),
          const SizedBox(height: 8),
          _row(l10n.stockPositionCardAvgCostLabel, formatUsd(avgPrice)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      Text(
        value,
        style: interNums(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  );

  Widget _pnlRow({
    required AppLocalizations l10n,
    required double pnl,
    required double pnlPercent,
    required bool isUp,
    required Color pnlColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        l10n.stockPositionCardUnrealizedPnlLabel,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: pnlColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${formatUsdSigned(pnl)} (${pnlPercent.toStringAsFixed(2)}%)',
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: pnlColor,
            ),
          ),
        ],
      ),
    ],
  );
}
