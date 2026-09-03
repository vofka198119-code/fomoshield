// ---------------------------------------------------------------------------
// Stress Test — Discipline card, standalone marker widget on the Psychology
// Meter detail screen. Single bar for now (profile.discipline). See
// psychology_engine.dart's evaluateBuyTrade for what moves this score.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

// Below this, the bar switches to AllocationBarRow's red warning gradient —
// inverted from the sector-allocation card's own threshold (there, HIGH %
// is the risk; here, a LOW score is).
const double _warningThreshold = 40.0;

class PsychologyDisciplineCard extends StatelessWidget {
  final double discipline; // 0.0-1.0
  final AppPalette palette;

  const PsychologyDisciplineCard({
    super.key,
    required this.discipline,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (discipline * 100).clamp(0.0, 100.0);
    return PsychologyMarkerCard(
      title: l10n.psychologyDisciplineWidgetTitle,
      infoId: 'psychology-discipline',
      child: AllocationBarRow(
        name: l10n.psychologyDisciplineWidgetLabel,
        percent: percent,
        palette: palette,
        warning: percent < _warningThreshold,
        decimals: 0,
        suffix: '',
      ),
    );
  }
}
