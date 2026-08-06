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
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';

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
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Text('DIVERSIFICATION', style: FomoShieldTheme.cardTitle()),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
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
                    child: _MarkerRow(sessionId: sessionId, row: rows[i]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerRow extends StatelessWidget {
  final String sessionId;
  final _DiversificationRow row;

  const _MarkerRow({required this.sessionId, required this.row});

  Color get _color {
    if (row.score >= 0.7) return ThemeV2.success;
    if (row.score >= 0.4) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  String get _statusWord {
    if (row.score >= 0.7) return 'Good';
    if (row.score >= 0.4) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final percent = (row.score * 100).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    row.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FomoShieldTheme.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => context.push(
                    '/stress-test/$sessionId/verdict/marker/${row.markerId}',
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 13,
                      color: FomoShieldTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percent.round()}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _statusWord,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
