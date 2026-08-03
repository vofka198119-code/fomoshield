// ---------------------------------------------------------------------------
// Stress Test — Sector Allocation card, lives on the Portfolio Balance
// detail screen below the per-asset breakdown. Same gold-bar visual, but
// grouped by sector instead of by holding, and flags concentration risk:
// any sector at 75%+ of the portfolio switches to a red warning gradient
// instead of gold.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import '../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import '../stress_test_models.dart';
import 'allocation_bar_row.dart';

const double _sectorWarningThreshold = 75.0;

// Every sector stressTestSectorName() can return — kept in sync with that
// helper so a sector with zero holdings still shows up (as an empty bar)
// instead of only appearing once the user actually buys into it.
const _allSectors = [
  'Technology',
  'Finance',
  'Healthcare',
  'Consumer',
  'Automotive',
  'Biotech',
  'Energy',
  'Tech',
  'Other',
];

class StressTestSectorAllocationCard extends StatelessWidget {
  final StressTestSession session;

  const StressTestSectorAllocationCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final holdings = session.holdings;
    final sectorTotals = <String, double>{for (final s in _allSectors) s: 0};
    double totalInvested = 0;
    for (final h in holdings) {
      final price = session.currentPrices[h.symbol] ?? h.entryPrice;
      final val = h.shares * price;
      final sector = stressTestSectorName(h.symbol);
      sectorTotals[sector] = (sectorTotals[sector] ?? 0) + val;
      totalInvested += val;
    }
    final sectors = sectorTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final hasData = totalInvested > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dialLight, dialDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Text(
                'DIVERSIFICATION INDICATOR',
                style: FomoShieldTheme.cardTitle(Colors.white),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          if (hasData)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                children: [
                  for (final entry in sectors)
                    AllocationBarRow(
                      name: entry.key,
                      percent: entry.value / totalInvested * 100,
                      warning:
                          entry.value / totalInvested * 100 >=
                          _sectorWarningThreshold,
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 60),
        ],
      ),
    );
  }
}
