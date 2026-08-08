// ---------------------------------------------------------------------------
// Verdict screen — Trade History widget
// ---------------------------------------------------------------------------
// Just the per-trade list for the completed test (last 5, newest first,
// "More" pushes to the full VerdictTradeHistoryScreen) — split out of
// VerdictTradeBreakdownWidget, which now only holds the aggregate
// buys/sells/profit-loss summary. Same TradeHistoryTile 5+More shape used
// everywhere else (Stress Test's own Trade History card, Portfolio's).
//
// Light card, matches verdict_screen.dart's own FomoShieldTheme.cardDecoration
// style (NOT the dark-green Stress Test widget family — this screen uses its
// own lighter look throughout).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/widgets/trade_history_tile.dart';
import '../../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import '../stress_test_models.dart';

class VerdictTradeHistoryWidget extends ConsumerWidget {
  final String sessionId;
  final List<StressTestTrade> trades;

  static const _collapsedCount = 5;

  const VerdictTradeHistoryWidget({
    super.key,
    required this.sessionId,
    required this.trades,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = trades.reversed.toList(); // newest first
    final visible = sorted.take(_collapsedCount).toList();

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
            child: Text('TRADE HISTORY', style: FomoShieldTheme.cardTitle()),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Text(
                'No individual trades to list.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ThemeV2.textSecondary,
                ),
              ),
            )
          else
            ...visible.asMap().entries.map(
              (e) => TradeHistoryTile(
                symbol: e.value.symbol,
                companyName: resolveStressTestCompanyName(ref, e.value.symbol),
                isBuy: e.value.isBuy,
                totalValue: e.value.shares * e.value.price,
                showDivider: e.key != visible.length - 1,
                onTap: () => context.push(
                  '/stress-test/$sessionId/trade-detail',
                  extra: e.value,
                ),
              ),
            ),
          if (sorted.length > _collapsedCount)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: GestureDetector(
                onTap: () => context.push(
                  '/stress-test/$sessionId/verdict-trade-history',
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeV2.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'More (${sorted.length - _collapsedCount})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.primary,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
