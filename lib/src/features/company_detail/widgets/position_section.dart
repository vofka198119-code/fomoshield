import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../portfolio/portfolio_providers.dart';

// ===========================================================================
// Position Section
// ===========================================================================

class PositionSection extends ConsumerWidget {
  final String symbol;
  final double price;

  const PositionSection({super.key, required this.symbol, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);

    // Find all holdings for this symbol across portfolios
    List<
      ({String portfolioName, double shares, double avgCost, double totalValue})
    >
    positions = [];
    for (final p in portfolios) {
      final perf = ref.watch(portfolioPerformanceProvider(p.id));
      final holding = perf.asData?.value.holdings.firstWhere(
        (h) => h.symbol == symbol,
        orElse: () => HoldingPerformance(
          symbol: symbol,
          shares: 0,
          avgCost: 0,
          totalCost: 0,
          currentPrice: 0,
          currentValue: 0,
          pnl: 0,
          pnlPercent: 0,
        ),
      );
      if (holding != null && holding.shares > 0) {
        positions.add((
          portfolioName: p.name,
          shares: holding.shares,
          avgCost: holding.avgCost,
          totalValue: holding.shares * price,
        ));
      }
    }

    if (positions.isEmpty) return const SizedBox.shrink();

    final totalShares = positions.fold<double>(0, (s, p) => s + p.shares);
    final totalValue = positions.fold<double>(0, (s, p) => s + p.totalValue);
    // Weighted average cost
    final totalCost = positions.fold<double>(
      0,
      (s, p) => s + p.shares * p.avgCost,
    );
    final avgCost = totalShares > 0 ? totalCost / totalShares : 0.0;
    final pnl = totalValue - totalCost;
    final pnlPercent = totalCost > 0 ? (pnl / totalCost) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: FomoShieldTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR POSITION',
              style: FomoShieldTheme.cardTitle(),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            Row(
              children: [
                _positionTile('Shares', totalShares.toStringAsFixed(4)),
                _positionTile('Avg Cost', '\$${avgCost.toStringAsFixed(2)}'),
                _positionTile(
                  'Market Value',
                  '\$${totalValue.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${isUp(pnl) ? '+' : ''}${pnl.toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(2)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: pnl >= 0 ? ThemeV2.success : ThemeV2.loss,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  pnl >= 0 ? 'all time' : 'all time',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionTile(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ThemeV2.textPrimary,
          ),
        ),
      ],
    ),
  );

  bool isUp(double v) => v >= 0;
}
