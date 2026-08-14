// ---------------------------------------------------------------------------
// Session Complete screen — combined "DIVERSIFICATION" card, replacing 3
// separate VerdictMarkerCard instances (Sector Diversification, Safety
// Marker, Sector Balance) with one card, 3 rows. Matches the Psychology
// Meter's own PsychologyDiversificationCard naming/grouping.
//
// Visual: light-theme adaptation of company_detail/financial_score_widget's
// _MarkerCard (color indicator bar + window border + name + "?" + score) —
// same shape, but on FomoShieldTheme's light card standard (title+divider)
// instead of the FS Score widget's dark dialLight/dialDark card, and no
// progress bars — those read as noise on a final summary, per explicit ask
// 2026-08-06. The "?" replaces VerdictMarkerCard's old "More" text button
// but pushes the exact same route.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import 'verdict_marker_row.dart';

class _DiversificationRow {
  final String markerId;
  final String label;
  final double score; // 0.0-1.0
  const _DiversificationRow({
    required this.markerId,
    required this.label,
    required this.score,
  });
}

class VerdictDiversificationCard extends StatelessWidget {
  final String sessionId;
  final double sectorDiversificationScore;
  final double safetyMarkerScore;
  final double sectorBalanceScore;

  const VerdictDiversificationCard({
    super.key,
    required this.sessionId,
    required this.sectorDiversificationScore,
    required this.safetyMarkerScore,
    required this.sectorBalanceScore,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _DiversificationRow(
        markerId: 'sector-diversification',
        label: 'Sector Diversification',
        score: sectorDiversificationScore,
      ),
      _DiversificationRow(
        markerId: 'safety-marker',
        label: 'Safety Marker',
        score: safetyMarkerScore,
      ),
      _DiversificationRow(
        markerId: 'sector-balance',
        label: 'Sector Balance',
        score: sectorBalanceScore,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DIVERSIFICATION',
                  style: FomoShieldTheme.cardTitle(Colors.white),
                ),
                GestureDetector(
                  onTap: () =>
                      context.push('/metric-info/psychology-diversification'),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == rows.length - 1 ? 0 : 10,
                    ),
                    child: VerdictMarkerRow(
                      sessionId: sessionId,
                      markerId: rows[i].markerId,
                      label: rows[i].label,
                      score: rows[i].score,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
