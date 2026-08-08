// ---------------------------------------------------------------------------
// Verdict Screen — Final Psychological Assessment
// ---------------------------------------------------------------------------
// Displays the calculated psychological verdict with FS Score, behavioral
// diagnosis, diversification warning, and the "Absolute Shield" badge.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';
import 'widgets/verdict_trade_breakdown_widget.dart';
import 'widgets/verdict_trade_history_widget.dart';
import 'widgets/verdict/verdict_marker_row.dart';
import 'widgets/verdict/verdict_diversification_card.dart';
import 'widgets/verdict/verdict_strategy_card.dart';
import 'widgets/verdict/stress_test_verdict_disclaimer.dart';

class VerdictScreen extends ConsumerWidget {
  final String sessionId;

  const VerdictScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archive = ref.watch(verdictArchiveProvider);
    final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
      (e) => e?.sessionId == sessionId,
      orElse: () => null,
    );

    if (entry == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Verdict',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
            ),
          ),
        ),
        body: const Center(
          child: Text('Verdict not available — complete the test first.'),
        ),
      );
    }

    final verdict = entry.verdict;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'SESSION COMPLETE',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.go('/stress-test-hub'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Guardian Verdict ────────────────────────────────
            const _GuardianVerdictSection(),
            const SizedBox(height: 24),

            // ── Guardian Shield Icon + FS Score ─────────────────
            _buildFsScoreGauge(verdict.fsScore),
            const SizedBox(height: 24),

            // ── Absolute Shield Badge ───────────────────────────
            if (verdict.hasAbsoluteShieldBadge) ...[
              _buildAbsoluteShieldBadge(),
              const SizedBox(height: 20),
            ],

            // ── Diversification Warning ─────────────────────────
            if (verdict.hasDiversificationWarning) ...[
              _buildWarningCard(),
              const SizedBox(height: 16),
            ],

            // ── Strategy ─────────────────────────────────────────
            VerdictStrategyCard(
              sessionId: sessionId,
              concentrationScore: entry.strategyConcentration,
              etfExposureScore: entry.strategyEtf,
              cashBufferScore: entry.strategyCashBuffer,
            ),
            const SizedBox(height: 12),

            // ── Diversification ──────────────────────────────────
            VerdictDiversificationCard(
              sessionId: sessionId,
              sectorDiversificationScore: entry.strategyDiversification,
              safetyMarkerScore: entry.safetyMarker,
              sectorBalanceScore: entry.strategySector,
            ),
            const SizedBox(height: 12),

            // ── Per-marker verdict cards ─────────────────────────
            VerdictSingleMarkerCard(
              sessionId: sessionId,
              markerId: 'discipline',
              title: 'DISCIPLINE',
              label: 'Discipline',
              score: entry.discipline,
            ),
            const SizedBox(height: 12),
            VerdictSingleMarkerCard(
              sessionId: sessionId,
              markerId: 'panic',
              title: 'PANIC',
              label: 'Panic',
              score: entry.panicResistance,
            ),
            const SizedBox(height: 12),
            VerdictSingleMarkerCard(
              sessionId: sessionId,
              markerId: 'patience',
              title: 'PATIENCE',
              label: 'Patience',
              score: entry.patience,
            ),
            const SizedBox(height: 16),

            // ── Trade Breakdown (incl. session stats) ────────────
            VerdictTradeBreakdownWidget(entry: entry),
            const SizedBox(height: 16),

            // ── Trade History ────────────────────────────────────
            VerdictTradeHistoryWidget(
              sessionId: sessionId,
              trades: entry.trades,
            ),
            const SizedBox(height: 16),

            const StressTestVerdictDisclaimer(),
            const SizedBox(height: 24),

            // ── Continue Learning ───────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go('/stress-test-hub');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: FomoShieldTheme.primary,
                  side: BorderSide(color: FomoShieldTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue Learning',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.go('/home');
                },
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ThemeV2.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFsScoreGauge(int score) {
    final color = score >= 70
        ? ThemeV2.success
        : score >= 40
        ? ThemeV2.warning
        : ThemeV2.loss;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FomoShieldTheme.card,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: interNums(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            Text(
              'FS SCORE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: ThemeV2.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsoluteShieldBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeV2.warning.withValues(alpha: 0.15),
            ThemeV2.warning.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeV2.warning.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: ThemeV2.warning, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABSOLUTE SHIELD',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ThemeV2.warning,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Master of Emotions — rarest achievement',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ThemeV2.warning.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeV2.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeV2.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: ThemeV2.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Warning: Over-concentration detected. Putting more than 50% '
              'of capital into one asset exposes you to unmitigated systemic risk.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.warning,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════
//  GuardianVerdictSection — Guardian message on the verdict screen
// ═══════════════════════════════════════════════════════════════════════════

/// Displays Guardian's final verdict message + shield icon.
/// Uses [GuardianIntelligenceEngine] to generate context-aware message.
// Static, informational — same text for every completed stress test
// regardless of outcome (no more per-verdict Guardian Engine message).
// Short intro here; "View your analysis" pushes /metric-info/guardian-verdict
// for the expanded copy, same shape as every other "?" info screen.
class _GuardianVerdictSection extends StatelessWidget {
  const _GuardianVerdictSection();

  static const _headline = 'YOU MADE IT THROUGH';
  static const _shortText =
      'Your stress test is complete. You experienced different market '
      'conditions and saw how your portfolio and decisions responded. Now '
      'it\'s time to see what your results reveal about your investment '
      'behavior.';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeV2.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeV2.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shield icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeV2.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 24,
              color: ThemeV2.primary,
            ),
          ),
          const SizedBox(width: 16),
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUARDIAN\'S VERDICT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: ThemeV2.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _headline,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _shortText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: FomoShieldTheme.text,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push('/metric-info/guardian-verdict'),
                  child: Text(
                    'View your analysis →',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.primary,
                    ),
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

