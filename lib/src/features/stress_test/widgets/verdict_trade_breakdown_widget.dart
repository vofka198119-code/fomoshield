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
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../stress_test_models.dart';

class VerdictTradeBreakdownWidget extends StatelessWidget {
  final VerdictArchiveEntry entry;

  const VerdictTradeBreakdownWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalPnl = entry.finalValue - entry.startingCash;

    return Container(
      width: double.infinity,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.verdictTradeBreakdownTitle,
                  style: FomoShieldTheme.cardTitle(Colors.white),
                ),
                GestureDetector(
                  onTap: () => context.push(
                    '/stress-test/${entry.sessionId}/verdict-trade-breakdown',
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow(l10n.verdictTotalTradesLabel, '${entry.totalTrades}'),
                _statRow(l10n.verdictHoldingsLabel, '${entry.holdingCount}'),
                _statRow(l10n.verdictFinalPnlLabel, formatUsdSigned(totalPnl)),
                _statRow(l10n.verdictFinalBalanceLabel, formatUsd(entry.finalValue)),
                _statRow(l10n.verdictStartingCashLabel, formatUsd(entry.startingCash)),
                _statRow(
                  l10n.verdictTestDurationLabel,
                  entry.durationLabel,
                  isLast: true,
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
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: interNums(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: dialBrassLight,
            ),
          ),
        ],
      ),
    );
  }
}
