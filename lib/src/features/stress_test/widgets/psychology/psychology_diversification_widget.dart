// ---------------------------------------------------------------------------
// Stress Test — Diversification card, standalone marker widget on the
// Psychology Meter detail screen. 3 bars, named to match their Session
// Complete verdict-card counterparts exactly (widgets/verdict/): Sector
// Balance (scores.sector, % of capital in the largest GICS sector) +
// Sector Diversification (scores.diversification, the holdings-COUNT
// curve — same signal sector_diversification_tiers.dart's tiers are keyed
// on, despite the "sector" name) + Safety Marker — cost-basis-weighted
// average of each holding's FS Score at the moment of its FIRST purchase
// (see safetyMarkerFor/entryFsScore), flagging portfolios built on "junk"
// (penny-stock trap, dividend trap) rather than real fundamentals.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../psychology_engine.dart';
import '../../stress_test_models.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

const double _warningThreshold = 40.0;

class PsychologyDiversificationCard extends StatelessWidget {
  final StressTestSession session;
  final AppPalette palette;

  const PsychologyDiversificationCard({
    super.key,
    required this.session,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scores = computeStrategySubScores(
      holdings: session.holdings,
      cash: session.cash,
    );
    final safety = safetyMarkerFor(session.holdings);

    return PsychologyMarkerCard(
      title: l10n.psychologyDiversificationWidgetTitle,
      infoId: 'psychology-diversification',
      child: Column(
        children: [
          _bar(
            l10n.psychologyDiversificationWidgetSectorBalance,
            scores.sector * 100,
          ),
          _bar(
            l10n.psychologyDiversificationWidgetSectorDiversification,
            scores.diversification * 100,
          ),
          _bar(
            l10n.psychologyDiversificationWidgetSafetyMarker,
            safety.score * 100,
          ),
        ],
      ),
    );
  }

  Widget _bar(String name, double percent) {
    final clamped = percent.clamp(0.0, 100.0);
    return AllocationBarRow(
      name: name,
      percent: clamped,
      palette: palette,
      warning: clamped < _warningThreshold,
      decimals: 0,
      suffix: '',
    );
  }
}
