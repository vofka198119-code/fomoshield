// ---------------------------------------------------------------------------
// Stress Test — Diversification card, standalone marker widget on the
// Psychology Meter detail screen. 3 bars: Sector Balance + Count Balance
// (same 2 signals reused from computeStrategySubScores, shown here as
// their own detail view) + Safety Marker — cost-basis-weighted average of
// each holding's FS Score at the moment of its FIRST purchase (see
// safetyMarkerFor/entryFsScore), flagging portfolios built on "junk"
// (penny-stock trap, dividend trap) rather than real fundamentals.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../psychology_engine.dart';
import '../../stress_test_models.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

const double _warningThreshold = 40.0;

class PsychologyDiversificationCard extends StatelessWidget {
  final StressTestSession session;

  const PsychologyDiversificationCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final scores = computeStrategySubScores(
      holdings: session.holdings,
      cash: session.cash,
    );
    final safety = safetyMarkerFor(session.holdings);

    return PsychologyMarkerCard(
      title: 'DIVERSIFICATION',
      infoId: 'psychology-diversification',
      child: Column(
        children: [
          _bar('Sector Balance', scores.sector * 100),
          _bar('Count Balance', scores.diversification * 100),
          _bar('Safety Marker', safety.score * 100),
        ],
      ),
    );
  }

  Widget _bar(String name, double percent) {
    final clamped = percent.clamp(0.0, 100.0);
    return AllocationBarRow(
      name: name,
      percent: clamped,
      warning: clamped < _warningThreshold,
      decimals: 0,
      suffix: '',
    );
  }
}
