// ---------------------------------------------------------------------------
// Session Complete screen — combined "STRATEGY" card, mirrors
// VerdictDiversificationCard's shape exactly (color bar + window border +
// name + "?" + score, no progress bars) but for the Strategy pillar's other
// 3 sub-signals: Concentration, ETF Exposure, Cash Buffer. Replaces the old
// separate generic "Strategy" composite VerdictMarkerCard and the standalone
// Concentration VerdictMarkerCard.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import 'verdict_marker_row.dart';

class _StrategyRow {
  final String markerId;
  final String label;
  final double score; // 0.0-1.0
  const _StrategyRow({
    required this.markerId,
    required this.label,
    required this.score,
  });
}

class VerdictStrategyCard extends StatelessWidget {
  final String sessionId;
  final double concentrationScore;
  final double etfExposureScore;
  final double cashBufferScore;

  const VerdictStrategyCard({
    super.key,
    required this.sessionId,
    required this.concentrationScore,
    required this.etfExposureScore,
    required this.cashBufferScore,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _StrategyRow(
        markerId: 'concentration',
        label: 'Concentration',
        score: concentrationScore,
      ),
      _StrategyRow(
        markerId: 'etf-exposure',
        label: 'ETF Exposure',
        score: etfExposureScore,
      ),
      _StrategyRow(
        markerId: 'cash-buffer',
        label: 'Cash Buffer',
        score: cashBufferScore,
      ),
    ];

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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('STRATEGY', style: FomoShieldTheme.cardTitle(Colors.white)),
                GestureDetector(
                  onTap: () => context.push('/metric-info/psychology-strategy'),
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
