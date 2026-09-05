// ---------------------------------------------------------------------------
// Verdict screen — Trade Breakdown widget
// ---------------------------------------------------------------------------
// Portfolio-wide summary for the completed test: the session's top-line
// numbers — total trades, holdings, final P&L ($), final balance, starting
// cash, duration. Buys/Sells count tiles and the profitable/losing-sells
// bars were cut 2026-08-08 (redundant with the detail screen's own
// Statistics/Financial Summary cards); Final P&L switched from % to $ at
// the same time.
//
// The per-trade list itself lives on the chevron-linked
// VerdictTradeBreakdownDetailScreen, not here.
//
// Dark card family (dialLight/dialDark gradient), matching the detail
// screen's own look — recolored 2026-08-08, was previously this screen's
// one light-themed exception.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../stress_test_models.dart';

class VerdictTradeBreakdownWidget extends StatelessWidget {
  final VerdictArchiveEntry entry;
  final AppPalette palette;

  const VerdictTradeBreakdownWidget({
    super.key,
    required this.entry,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalPnl = entry.finalValue - entry.startingCash;
    final totalCommission = entry.trades.fold<double>(
      0,
      (sum, t) => sum + t.fee,
    );

    // Simulated dividends / weekly DCA top-ups / commission — dividends and
    // top-ups only shown when they actually happened (most sessions have
    // neither), commission shown whenever there were trades to charge it
    // on. Built as a list (rather than inline widgets) so the LAST row can
    // skip its divider regardless of which of these trailing rows ends up
    // being last. See VerdictArchiveEntry.dividendsReceived/dcaTopUpCount/
    // dcaTotalReceived doc comments — added 2026-09-02.
    final rows = <(String, String)>[
      (l10n.verdictTotalTradesLabel, '${entry.totalTrades}'),
      (l10n.verdictHoldingsLabel, '${entry.holdingCount}'),
      (l10n.verdictFinalPnlLabel, formatUsdSigned(totalPnl)),
      (l10n.verdictFinalBalanceLabel, formatUsd(entry.finalValue)),
      (l10n.verdictStartingCashLabel, formatUsd(entry.startingCash)),
      (l10n.verdictTestDurationLabel, entry.durationLabel),
      if (entry.dividendsReceived > 0)
        (l10n.verdictDividendsLabel, formatUsd(entry.dividendsReceived)),
      if (entry.dcaTopUpCount > 0) ...[
        (l10n.verdictTopUpCountLabel, '${entry.dcaTopUpCount}'),
        (l10n.verdictTopUpTotalLabel, formatUsd(entry.dcaTotalReceived)),
      ],
      if (totalCommission > 0)
        (l10n.verdictCommissionLabel, formatUsd(totalCommission)),
    ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                themedGoldGradient(
                  Text(
                    l10n.verdictTradeBreakdownTitle,
                    style: FomoShieldTheme.cardTitle(palette.onWindow ?? Colors.white).copyWith(
                      shadows: palette.titleShadow != null
                          ? [palette.titleShadow!]
                          : null,
                    ),
                  ),
                  palette,
                ),
                GestureDetector(
                  onTap: () => context.push(
                    '/stress-test/${entry.sessionId}/verdict-trade-breakdown',
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < rows.length; i++)
                  _statRow(
                    rows[i].$1,
                    rows[i].$2,
                    isLast: i == rows.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Same shape as the detail screen's own row (_Row in
  /// verdict_trade_breakdown_detail_screen.dart): white label, gold value,
  /// white 12%-alpha underline between rows — kept in sync by eye per
  /// 2026-08-08 visual-parity ask, not shared code (that _Row is private).
  Widget _statRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12)),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: palette.onWindow ?? Colors.white,
            ),
          ),
          themedPriceText(
            value,
            palette,
            interNums(fontSize: 15, fontWeight: FontWeight.w700),
            fallbackColor: dialBrassLight,
          ),
        ],
      ),
    );
  }
}
