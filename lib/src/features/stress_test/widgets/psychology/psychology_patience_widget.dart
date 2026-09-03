// ---------------------------------------------------------------------------
// Stress Test — Patience card, standalone marker widget on the Psychology
// Meter detail screen. Single bar for now (profile.patience) — profit-take
// bonus + held-through-catastrophe bonus. See psychology_engine.dart and
// noise_engine.dart's recordHeldThroughCatastrophe.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../allocation_bar_row.dart';
import 'psychology_marker_card.dart';

const double _warningThreshold = 40.0;

class PsychologyPatienceCard extends StatelessWidget {
  final double patience; // 0.0-1.0
  final AppPalette palette;

  const PsychologyPatienceCard({
    super.key,
    required this.patience,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (patience * 100).clamp(0.0, 100.0);
    return PsychologyMarkerCard(
      title: l10n.psychologyPatienceWidgetTitle,
      infoId: 'psychology-patience',
      child: AllocationBarRow(
        name: l10n.psychologyPatienceWidgetLabel,
        percent: percent,
        palette: palette,
        warning: percent < _warningThreshold,
        decimals: 0,
        suffix: '',
      ),
    );
  }
}
