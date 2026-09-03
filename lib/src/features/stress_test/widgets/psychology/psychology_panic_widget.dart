// ---------------------------------------------------------------------------
// Stress Test — Panic card, standalone marker widget on the Psychology
// Meter detail screen. Single bar for now (profile.panicResistance). See
// psychology_engine.dart's evaluateSellTrade for what moves this score.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

const double _warningThreshold = 40.0;

class PsychologyPanicCard extends StatelessWidget {
  final double panicResistance; // 0.0-1.0
  final AppPalette palette;

  const PsychologyPanicCard({
    super.key,
    required this.panicResistance,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (panicResistance * 100).clamp(0.0, 100.0);
    return PsychologyMarkerCard(
      title: l10n.psychologyPanicWidgetTitle,
      infoId: 'psychology-panic',
      child: AllocationBarRow(
        name: l10n.psychologyPanicWidgetLabel,
        percent: percent,
        palette: palette,
        warning: percent < _warningThreshold,
        decimals: 0,
        suffix: '',
      ),
    );
  }
}
