// ---------------------------------------------------------------------------
// Verdict screen — Trade Breakdown widget
// ---------------------------------------------------------------------------
// Full per-trade record for the completed test: how many buys/sells,
// how many sells locked in a profit vs a loss, the $ total either way,
// and a scrollable list of every individual trade. Always renders the
// full structure (tiles + bars) even at zero — same "always visible,
// never a substitute empty state" rule as the Portfolio Balance detail
// screen's widgets. Requires VerdictArchiveEntry.trades (added
// 2026-08-05 — verdicts archived before that have an empty list, which
// just renders as all-zero here rather than a fallback message).
//
// Light card, matches verdict_screen.dart's own ThemeV2.surface style
// (NOT the dark-green Stress Test widget family — this screen uses its
// own lighter look throughout).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../stress_test_models.dart';

final _priceFmt = NumberFormat('#,##0.00', 'en_US');

class VerdictTradeBreakdownWidget extends StatefulWidget {
  final List<StressTestTrade> trades;

  const VerdictTradeBreakdownWidget({super.key, required this.trades});

  @override
  State<VerdictTradeBreakdownWidget> createState() =>
      _VerdictTradeBreakdownWidgetState();
}

class _VerdictTradeBreakdownWidgetState
    extends State<VerdictTradeBreakdownWidget> {
  bool _showAll = false;
  static const _collapsedCount = 5;

  @override
  Widget build(BuildContext context) {
    final trades = widget.trades;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRADE BREAKDOWN',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._content(trades),
        ],
      ),
    );
  }

  List<Widget> _content(List<StressTestTrade> trades) {
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

    final sorted = trades.reversed.toList(); // newest first
    final visible = _showAll
        ? sorted
        : sorted.take(_collapsedCount).toList();

    return [
      Row(
        children: [
          Expanded(child: _countTile('Buys', buys, ThemeV2.textPrimary)),
          const SizedBox(width: 12),
          Expanded(
            child: _countTile('Sells', sells.length, ThemeV2.textPrimary),
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
      const SizedBox(height: 12),
      if (sorted.isEmpty)
        Text(
          'No individual trades to list.',
          style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary),
        )
      else
        ...visible.map(_tradeRow),
      if (sorted.length > _collapsedCount)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _showAll ? 'Show less' : 'More (${sorted.length - _collapsedCount})',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ThemeV2.primary,
              ),
            ),
          ),
        ),
    ];
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

  Widget _tradeRow(StressTestTrade t) {
    final isSell = !t.isBuy;
    final pnl = t.realizedPnl;
    final pnlColor = pnl == null
        ? ThemeV2.textSecondary
        : pnl >= 0
        ? ThemeV2.success
        : ThemeV2.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (t.isBuy ? ThemeV2.success : ThemeV2.loss).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              t.isBuy ? 'BUY' : 'SELL',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: t.isBuy ? ThemeV2.success : ThemeV2.loss,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                Text(
                  '${_fmtDate(t.date)} · \$${_priceFmt.format(t.price)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSell && pnl != null)
            Text(
              '${pnl >= 0 ? '+' : ''}\$${_priceFmt.format(pnl)}',
              style: interNums(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pnlColor,
              ),
            ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
