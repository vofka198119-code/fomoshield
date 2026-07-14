// ---------------------------------------------------------------------------
// VerdictCard — compact psychological verdict for main screen (Bible Part 10)
// ---------------------------------------------------------------------------
// Shows FS Score, verdict type/description, Absolute Shield badge, and
// a "View Full Analysis" action. Designed for _buildSectionCard() wrapper.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';
import 'card_frame.dart';

/// Compact verdict card for embedding in the main stress test screen.
/// Reads from a [VerdictArchiveEntry] and navigates to the full verdict.
class VerdictCard extends StatelessWidget {
  final VerdictArchiveEntry entry;
  final String sessionId;

  const VerdictCard({
    super.key,
    required this.entry,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final verdict = entry.verdict;
    final color = _verdictColor(verdict.primaryType);
    final icon = _verdictIcon(verdict.primaryType);

    return CardFrame(
      padding: EdgeInsets.zero,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: FS Score + Verdict Type ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              // FS Score circle (compact)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fsColor(verdict.fsScore).withValues(alpha: 0.1),
                  border: Border.all(
                    color: _fsColor(verdict.fsScore).withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${verdict.fsScore}',
                  style: interNums(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _fsColor(verdict.fsScore),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Verdict type + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            verdict.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      verdict.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Absolute Shield Badge ──
        if (verdict.hasAbsoluteShieldBadge)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.shieldYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.shieldYellow.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  color: AppTheme.shieldYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ABSOLUTE SHIELD — Master of Emotions',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.shieldYellow,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

        // ── Stats row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _statChip('Trades', '${entry.totalTrades}'),
              const SizedBox(width: 16),
              _statChip('Holdings', '${entry.holdingCount}'),
              const SizedBox(width: 16),
              _statChip(
                'P&L',
                '${entry.pnlPercent >= 0 ? '+' : ''}${entry.pnlPercent.toStringAsFixed(1)}%',
                valueColor: entry.pnlPercent >= 0
                    ? AppTheme.shieldGreen
                    : AppTheme.dangerRed,
              ),
            ],
          ),
        ),

        // ── Diversification Warning ──
        if (verdict.hasDiversificationWarning)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppTheme.shieldYellow,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Over-concentration risk: >50% in one asset',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.shieldYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── View Full Analysis button ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '/stress-test/$sessionId/verdict',
              ),
              icon: const Icon(Icons.analytics_rounded, size: 16),
              label: Text(
                'View Full Analysis',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: BorderSide(
                  color: AppTheme.accentBlue.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _statChip(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textDim,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _fsColor(int score) {
    if (score >= 70) return AppTheme.shieldGreen;
    if (score >= 40) return AppTheme.shieldYellow;
    return AppTheme.dangerRed;
  }

  Color _verdictColor(VerdictType type) => switch (type) {
    VerdictType.panic => AppTheme.dangerRed,
    VerdictType.fomo => AppTheme.shieldYellow,
    VerdictType.activeTrader => AppTheme.accentBlue,
    VerdictType.buffettShield => AppTheme.shieldGreen,
  };

  IconData _verdictIcon(VerdictType type) => switch (type) {
    VerdictType.panic => Icons.psychology_rounded,
    VerdictType.fomo => Icons.trending_up_rounded,
    VerdictType.activeTrader => Icons.swap_horiz_rounded,
    VerdictType.buffettShield => Icons.shield_rounded,
  };
}
