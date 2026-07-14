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
import '../../core/theme/app_theme.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../shared/widgets/guardian/guardian_data.dart';
import '../../shared/guardian/guardian_engine.dart';
import '../../shared/guardian/guardian_providers.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';

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
              color: AppTheme.accentBlue,
            ),
          ),
        ),
        body: const Center(
          child: Text('Verdict not available — complete the test first.'),
        ),
      );
    }

    final verdict = entry.verdict;

    // Determine guardian state from verdict type
    final guardianState = _verdictToGuardianState(verdict.primaryType);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Session Complete',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentBlue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.go('/stress-test-hub'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Guardian Verdict ────────────────────────────────
            _GuardianVerdictSection(
              state: guardianState,
              fsScore: verdict.fsScore,
              verdictType: verdict.primaryType,
            ),
            const SizedBox(height: 24),

            // ── Guardian Shield Icon + FS Score ─────────────────
            _buildFsScoreGauge(verdict.fsScore),
            const SizedBox(height: 24),

            // ── Absolute Shield Badge ───────────────────────────
            if (verdict.hasAbsoluteShieldBadge) ...[
              _buildAbsoluteShieldBadge(),
              const SizedBox(height: 20),
            ],

            // ── Verdict Card ────────────────────────────────────
            _buildVerdictCard(verdict),
            const SizedBox(height: 16),

            // ── What Mattered Most? ─────────────────────────────
            _buildMainLesson(verdict),
            const SizedBox(height: 16),

            // ── Diversification Warning ─────────────────────────
            if (verdict.hasDiversificationWarning) ...[
              _buildWarningCard(),
              const SizedBox(height: 16),
            ],

            // ── Session Stats ───────────────────────────────────
            _buildStatsCard(entry),
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
                    color: AppTheme.textDim,
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
        ? AppTheme.shieldGreen
        : score >= 40
        ? AppTheme.shieldYellow
        : AppTheme.dangerRed;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.card,
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
                color: AppTheme.textDim,
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
            AppTheme.shieldYellow.withValues(alpha: 0.15),
            AppTheme.shieldYellow.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.shieldYellow.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: AppTheme.shieldYellow, size: 48),
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
                    color: AppTheme.shieldYellow,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Master of Emotions — rarest achievement',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.shieldYellow.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictCard(PsychologicalVerdict verdict) {
    Color verdictColor;
    IconData verdictIcon;

    switch (verdict.primaryType) {
      case VerdictType.panic:
        verdictColor = AppTheme.dangerRed;
        verdictIcon = Icons.psychology_rounded;
      case VerdictType.fomo:
        verdictColor = AppTheme.shieldYellow;
        verdictIcon = Icons.trending_up_rounded;
      case VerdictType.activeTrader:
        verdictColor = AppTheme.accentBlue;
        verdictIcon = Icons.swap_horiz_rounded;
      case VerdictType.buffettShield:
        verdictColor = AppTheme.shieldGreen;
        verdictIcon = Icons.shield_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: verdictColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(verdictIcon, color: verdictColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  verdict.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verdict.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.7,
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
        color: AppTheme.shieldYellow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.shieldYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.shieldYellow,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Warning: Over-concentration detected. Putting more than 50% '
              'of capital into one asset exposes you to unmitigated systemic risk.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.shieldYellow,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(VerdictArchiveEntry entry) {
    final pnlPercent = entry.pnlPercent;
    final pnlColor = pnlPercent >= 0
        ? AppTheme.shieldGreen
        : AppTheme.dangerRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION STATS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDim,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _statRow('Total Trades', '${entry.totalTrades}'),
          _statRow('Holdings', '${entry.holdingCount}'),
          _statRow(
            'Final P&L',
            '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
            valueColor: pnlColor,
          ),
          _statRow('Final Balance', '\$${entry.finalValue.toStringAsFixed(0)}'),
          _statRow(
            'Starting Cash',
            '\$${entry.startingCash.toStringAsFixed(0)}',
          ),
          _statRow('Test Duration', entry.durationLabel),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim),
          ),
          Text(
            value,
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Map verdict type to guardian state for display.
  static GuardianState _verdictToGuardianState(VerdictType type) =>
      switch (type) {
        VerdictType.panic => GuardianState.crash,
        VerdictType.fomo => GuardianState.bear,
        VerdictType.activeTrader => GuardianState.volatility,
        VerdictType.buffettShield => GuardianState.recovery,
      };

  /// "What mattered most?" — key lesson based on verdict type.
  Widget _buildMainLesson(PsychologicalVerdict verdict) {
    final (icon, lesson) = switch (verdict.primaryType) {
      VerdictType.panic => (
        Icons.self_improvement_rounded,
        'Fear was the dominant force. Practice staying calm during '
            'drawdowns — the market rewards those who wait.',
      ),
      VerdictType.fomo => (
        Icons.trending_flat_rounded,
        'Chasing momentum led to buying at peaks. Focus on entry '
            'discipline and dollar-cost averaging.',
      ),
      VerdictType.activeTrader => (
        Icons.swap_horiz_rounded,
        'You traded actively. Review if each trade had a clear '
            'thesis — quality matters more than quantity.',
      ),
      VerdictType.buffettShield => (
        Icons.shield_rounded,
        'Discipline was your greatest asset. You followed the '
            'strategy and controlled emotions. This is the path.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 18, color: AppTheme.accentBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHAT MATTERED MOST',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: AppTheme.textDim,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: AppTheme.textSecondary,
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

// ═══════════════════════════════════════════════════════════════════════════
//  GuardianVerdictSection — Guardian message on the verdict screen
// ═══════════════════════════════════════════════════════════════════════════

/// Displays Guardian's final verdict message + shield icon.
/// Uses [GuardianIntelligenceEngine] to generate context-aware message.
class _GuardianVerdictSection extends ConsumerWidget {
  final GuardianState state;
  final int fsScore;
  final VerdictType verdictType;

  const _GuardianVerdictSection({
    required this.state,
    required this.fsScore,
    required this.verdictType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineAsync = ref.watch(guardianEngineProvider);

    return engineAsync.when(
      data: (engine) {
        // Get guardian message for this completed test
        final message = engine.selectMessage(
          state: state,
          action: UserAction.completedTest,
          temperature: _stateToTemperature(state),
        );

        // Record the completed test and action
        engine.recordTestCompleted();
        engine.recordAction(UserAction.completedTest);

        return _buildCard(state, message);
      },
      loading: () => _buildCard(state, 'Analyzing your performance...'),
      error: (_, __) => _buildCard(
        state,
        'Every simulation teaches something. Reflect on your decisions.',
      ),
    );
  }

  Widget _buildCard(GuardianState gs, String message) {
    final config = GuardianStateConfig.of(gs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.shieldColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.shieldColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shield icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: config.shieldColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 24,
              color: config.shieldColor,
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
                    color: config.shieldColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: FomoShieldTheme.text,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Approximate temperature from state for message selection.
  double _stateToTemperature(GuardianState gs) => switch (gs) {
    GuardianState.bull => 50,
    GuardianState.sideways => 0,
    GuardianState.bear => -25,
    GuardianState.volatility => -40,
    GuardianState.blackSwan => -70,
    GuardianState.crash => -80,
    GuardianState.recovery => 15,
    GuardianState.hype => 70,
    GuardianState.speculation => -10,
  };
}
