// ---------------------------------------------------------------------------
// Stress Test — Strategy card, standalone marker widget on the Psychology
// Meter detail screen. 5 independent bars — the same 5 signals blended
// into profile.strategyAdherence, shown here broken out instead of merged.
// Recomputed live from the CURRENT portfolio via computeStrategySubScores
// (psychology_engine.dart) — always agrees with the engine's own math.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../psychology_engine.dart';
import '../../stress_test_models.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

const double _warningThreshold = 40.0;

class PsychologyStrategyCard extends StatelessWidget {
  final StressTestSession session;

  const PsychologyStrategyCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final scores = computeStrategySubScores(
      holdings: session.holdings,
      cash: session.cash,
    );

    return PsychologyMarkerCard(
      title: 'STRATEGY',
      infoId: 'psychology-strategy',
      child: Column(
        children: [
          _bar('Diversification', scores.diversification),
          _bar('Concentration', scores.concentration),
          _bar('Sector Balance', scores.sector),
          _bar('ETF Exposure', scores.etf),
          _bar('Cash Buffer', scores.cashBuffer),
        ],
      ),
    );
  }

  Widget _bar(String name, double value) {
    final percent = (value * 100).clamp(0.0, 100.0);
    return AllocationBarRow(
      name: name,
      percent: percent,
      warning: percent < _warningThreshold,
      decimals: 0,
      suffix: '',
    );
  }
}
