// ---------------------------------------------------------------------------
// Shared row: color bar + window border + name + "?" + score, no progress
// bar. Used both inside multi-row combo cards (VerdictDiversificationCard,
// VerdictStrategyCard) and, via VerdictSingleMarkerCard, as a standalone
// one-row card for markers that don't share a combo (Discipline/Panic/
// Patience). One shape everywhere on Session Complete — see 2026-08-06/07
// visual-parity asks.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;

class VerdictMarkerRow extends StatelessWidget {
  final String sessionId;
  final String markerId;
  final String label;
  final double score; // 0.0-1.0

  const VerdictMarkerRow({
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
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Single tap target for "see detailed result" — replaces both the
          // raw score number and the row's own separate "?" icon (2026-08-16,
          // both did the same thing, kept only this one; the card HEADER's
          // own "?" — general explanatory article, not this row's detail
          // screen — is untouched).
          GestureDetector(
            onTap: () => context.push(
              '/stress-test/$sessionId/verdict/marker/$markerId',
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusWord,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One-row version of the DIVERSIFICATION/STRATEGY combo-card shape, for
/// markers that stand alone (Discipline/Panic/Patience) rather than
/// sharing a card with siblings.
class VerdictSingleMarkerCard extends StatelessWidget {
  final String sessionId;
  final String markerId;
  final String title; // card header, e.g. 'DISCIPLINE'
  final String label; // row label, e.g. 'Discipline'
  final double score; // 0.0-1.0

  const VerdictSingleMarkerCard({
    super.key,
    required this.sessionId,
    required this.markerId,
    required this.title,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(title, style: FomoShieldTheme.cardTitle(Colors.white)),
                GestureDetector(
                  onTap: () =>
                      context.push('/metric-info/psychology-$markerId'),
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
            child: VerdictMarkerRow(
              sessionId: sessionId,
              markerId: markerId,
              label: label,
              score: score,
            ),
          ),
        ],
      ),
    );
  }
}
