// ---------------------------------------------------------------------------
// Stress Test — Psychology Meter detail screen. Reached via the chevron
// next to the Psychology Meter widget's title on the main Stress Test
// screen (see PsychologyMeter in shared/widgets/psychology_meter.dart).
// Hosts the trade/portfolio analytics section that used to render directly
// below the ring on the main widget.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/psychology_meter.dart';
import 'stress_test_engine.dart';
import 'widgets/psychology/psychology_discipline_widget.dart';
import 'widgets/psychology/psychology_diversification_widget.dart';
import 'widgets/psychology/psychology_panic_widget.dart';
import 'widgets/psychology/psychology_patience_widget.dart';
import 'widgets/psychology/psychology_strategy_widget.dart';
import 'widgets/verdict/stress_test_verdict_disclaimer.dart';

class StressTestPsychologyMeterScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestPsychologyMeterScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));
    final data = session == null
        ? null
        : PsychologyMeterData.fromSession(session);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.stressTestPsychologyMeterTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: session == null || data == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _FsScoreGaugeCard(
                      score: data.strategicScore,
                      label: l10n.psychologyMeterScreenStrategyScore,
                    ),
                    const SizedBox(height: 16),
                    PsychologyStrategyCard(session: session),
                    const SizedBox(height: 16),
                    PsychologyDiversificationCard(session: session),
                    const SizedBox(height: 24),
                    _FsScoreGaugeCard(
                      score: data.psychologicalScore,
                      label: l10n.psychologyMeterScreenPsychologyScore,
                    ),
                    const SizedBox(height: 16),
                    PsychologyDisciplineCard(
                      discipline: session.psychologyProfile.discipline,
                    ),
                    const SizedBox(height: 16),
                    PsychologyPanicCard(
                      panicResistance:
                          session.psychologyProfile.panicResistance,
                    ),
                    const SizedBox(height: 16),
                    PsychologyPatienceCard(
                      patience: session.psychologyProfile.patience,
                    ),
                    const SizedBox(height: 16),
                    _PsychologyMeterDetailCard(data: data),
                    const StressTestVerdictDisclaimer(),
                  ],
                ),
              ),
      ),
    );
  }
}

/// FS Score speedometer gauge card — used for both halves of the
/// 2026-08-16 split (Strategy Score, Psychology Score), same light card
/// shell as the other detail-screen cards. Also shown compact on the main
/// Stress Test screen's PsychologyMeter card (that one stays single-gauge,
/// see PsychologyMeter/FsScoreRing in psychology_meter.dart).
class _FsScoreGaugeCard extends StatelessWidget {
  final double score;
  final String label;

  const _FsScoreGaugeCard({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: FomoShieldTheme.cardTitle()),
                GestureDetector(
                  onTap: () => context.push('/metric-info/investor-score'),
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
                      color: ThemeV2.textSecondary,
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
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: FsScoreRing(score: score),
          ),
        ],
      ),
    );
  }
}

class _PsychologyMeterDetailCard extends StatelessWidget {
  final PsychologyMeterData data;

  const _PsychologyMeterDetailCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Text(
              l10n.psychologyMeterScreenSessionStats,
              style: FomoShieldTheme.cardTitle(),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: PsychologyAnalyticsSection(data: data),
          ),
        ],
      ),
    );
  }
}
