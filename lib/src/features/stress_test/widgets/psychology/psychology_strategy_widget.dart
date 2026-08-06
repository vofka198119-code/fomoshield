// ---------------------------------------------------------------------------
// Stress Test — Strategy card, standalone marker widget on the Psychology
// Meter detail screen. Shows the 3 signals blended into
// profile.strategyAdherence that AREN'T already broken out elsewhere:
// Concentration, ETF Exposure, Cash Buffer. Diversification and Sector
// Balance (the other 2 of the 5) live in their own PsychologyDiversificationCard
// instead — showing them here too was a confirmed duplicate (2026-08-06),
// removed rather than kept for a "full picture in one place" view.
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
          _bar('Concentration', scores.concentration),
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
