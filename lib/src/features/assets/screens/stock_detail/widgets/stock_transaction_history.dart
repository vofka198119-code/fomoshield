import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../stress_test/stress_test_models.dart';
import 'stock_detail_helpers.dart';

// ---------------------------------------------------------------------------
// Stress Test transaction history card — split out of the old monolithic
// stock_detail_screen.dart, restyled to the FomoShieldTheme card standard
// (was ThemeV2.surface + ad-hoc shadow). Content/logic unchanged.
// ---------------------------------------------------------------------------

class StockTransactionHistory extends StatelessWidget {
  final String symbol;
  final StressTestSession session;

  const StockTransactionHistory({
    super.key,
    required this.symbol,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final symbolTrades = session.trades.where((t) => t.symbol == symbol).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final displayTrades = symbolTrades.take(5).toList();
    final hasMore = symbolTrades.length > 5;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRANSACTION HISTORY', style: FomoShieldTheme.cardTitle()),
          const Divider(height: 20, color: Color(0x0F000000)),
          if (displayTrades.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No transactions yet',
                style: ThemeV2.body.copyWith(
                  color: ThemeV2.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            for (final t in displayTrades) _tradeRow(t),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to full trade list (future)
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeV2.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                    child: Text(
                      'See All (${symbolTrades.length})',
                      style: ThemeV2.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _tradeRow(StressTestTrade trade) {
    final day = session.startedAt != null
        ? (trade.date.difference(session.startedAt!).inDays + 1)
        : 0;
    final isBuy = trade.isBuy;
    final totalAmount = trade.shares * trade.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeV2.background,
        borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isBuy
                  ? ThemeV2.success.withValues(alpha: 0.12)
                  : ThemeV2.loss.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isBuy ? 'BUY' : 'SELL',
              style: ThemeV2.small.copyWith(
                fontWeight: FontWeight.w700,
                color: isBuy ? ThemeV2.success : ThemeV2.loss,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? '+' : '-'}${trade.shares.toStringAsFixed(4)} $symbol',
                  style: ThemeV2.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Day $day', style: ThemeV2.small),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmtTradeDate(trade.date), style: ThemeV2.small),
              const SizedBox(height: 2),
              Text(
                fmtFullCurrency(totalAmount),
                style: ThemeV2.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
