// ---------------------------------------------------------------------------
// Verdict screen — Trade Breakdown widget
// ---------------------------------------------------------------------------
// Portfolio-wide summary for the completed test: how many buys/sells, how
// many sells locked in a profit vs a loss, the $ total either way, and
// (merged in 2026-08-08, was its own "Session Stats" card) the session's
// top-line numbers — total trades, holdings, final P&L, final balance,
// starting cash, duration. Always renders the full structure (tiles + bars)
// even at zero — same "always visible, never a substitute empty state" rule
// as the Portfolio Balance detail screen's widgets.
//
// The per-trade list itself lives on the chevron-linked
// VerdictTradeBreakdownDetailScreen (dark card family), not here — this
// card is purely the light-theme aggregate summary.
//
// Light card, matches verdict_screen.dart's own FomoShieldTheme.cardDecoration
// style (NOT the dark-green Stress Test widget family — this screen uses its
// own lighter look throughout).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../stress_test_models.dart';

final _priceFmt = NumberFormat('#,##0.00', 'en_US');

class VerdictTradeBreakdownWidget extends StatelessWidget {
  final VerdictArchiveEntry entry;

  const VerdictTradeBreakdownWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final trades = entry.trades;
    final buys = trades.where((t) => t.isBuy).length;
    final sells = trades.where((t) => !t.isBuy).toList();
    final profitSells = sells.where((t) => (t.realizedPnl ?? 0) > 0).toList();
    final lossSells = sells.where((t) => (t.realizedPnl ?? 0) < 0).toList();
    final totalProfit = profitSells.fold<double>(
      0,
      (sum, t) => sum + (t.realizedPnl ?? 0),
    );
    final totalLoss = lossSells.fold<double>(
      0,
      (sum, t) => sum + (t.realizedPnl ?? 0),
    );

    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
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
                Text('TRADE BREAKDOWN', style: FomoShieldTheme.cardTitle()),
                GestureDetector(
                  onTap: () => context.push(
                    '/stress-test/${entry.sessionId}/verdict-trade-breakdown',
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
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
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _countTile('Buys', buys, ThemeV2.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _countTile(
                        'Sells',
                        sells.length,
                        ThemeV2.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _pnlBar(
                  label: 'Profitable sells',
                  count: profitSells.length,
                  totalSells: sells.length,
                  amount: totalProfit,
                  color: ThemeV2.success,
                ),
                const SizedBox(height: 10),
                _pnlBar(
                  label: 'Losing sells',
                  count: lossSells.length,
                  totalSells: sells.length,
                  amount: totalLoss,
                  color: ThemeV2.loss,
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                const SizedBox(height: 14),
                _statRow('Total Trades', '${entry.totalTrades}'),
                _statRow('Holdings', '${entry.holdingCount}'),
                _statRow(
                  'Final P&L',
                  '${entry.pnlPercent >= 0 ? '+' : ''}'
                      '${entry.pnlPercent.toStringAsFixed(1)}%',
                  valueColor: entry.pnlPercent >= 0
                      ? ThemeV2.success
                      : ThemeV2.loss,
                ),
                _statRow(
                  'Final Balance',
                  '\$${entry.finalValue.toStringAsFixed(0)}',
                ),
                _statRow(
                  'Starting Cash',
                  '\$${entry.startingCash.toStringAsFixed(0)}',
                ),
                _statRow('Test Duration', entry.durationLabel, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
          ),
          Text(
            value,
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? ThemeV2.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countTile(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ThemeV2.surfaceDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: interNums(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: ThemeV2.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pnlBar({
    required String label,
    required int count,
    required int totalSells,
    required double amount,
    required Color color,
  }) {
    final fraction = totalSells > 0 ? count / totalSells : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label ($count)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
            Text(
              '${amount >= 0 ? '+' : ''}\$${_priceFmt.format(amount)}',
              style: interNums(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ThemeV2.surfaceDark.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
