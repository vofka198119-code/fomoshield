// ---------------------------------------------------------------------------
// Session Complete screen — condensed per-marker verdict card. One of these
// per Psychology Meter marker (Discipline, Panic, Patience, Strategy,
// Diversification): name + final score + a "More" button that pushes to
// VerdictMarkerDetailScreen for the full praise/mistake breakdown.
//
// Same light ThemeV2.surface card style as VerdictTradeBreakdownWidget —
// this screen's own look, not the dark Psychology Meter widget family.
// Content on the detail screen is a placeholder for now — wired up here,
// filled in per marker in a follow-up pass.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/typography_helpers.dart';

class VerdictMarkerCard extends StatelessWidget {
  final String sessionId;
  final String markerId; // 'discipline' | 'panic' | 'patience' | ...
  final String label;
  final double score; // 0.0-1.0

  const VerdictMarkerCard({
    super.key,
    required this.sessionId,
    required this.markerId,
    required this.label,
    required this.score,
  });

  Color get _color {
    if (score >= 0.7) return ThemeV2.success;
    if (score >= 0.4) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  String get _statusWord {
    if (score >= 0.7) return 'Good';
    if (score >= 0.4) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).clamp(0.0, 100.0);
    final color = _color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${percent.round()}',
                style: interNums(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ThemeV2.surfaceDark.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (percent / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusWord,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              TextButton(
                onPressed: () => context.push(
                  '/stress-test/$sessionId/verdict/marker/$markerId',
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'More',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
