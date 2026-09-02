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
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
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
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.stressTestPsychologyMeterTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
                      palette: palette,
                    ),
                    const SizedBox(height: 16),
                    PsychologyStrategyCard(session: session),
                    const SizedBox(height: 16),
                    PsychologyDiversificationCard(session: session),
                    const SizedBox(height: 24),
                    _FsScoreGaugeCard(
                      score: data.psychologicalScore,
                      label: l10n.psychologyMeterScreenPsychologyScore,
                      palette: palette,
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
                    _PsychologyMeterDetailCard(data: data, palette: palette),
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
  final AppPalette palette;

  const _FsScoreGaugeCard({
    required this.score,
    required this.label,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                themedHeaderText(label, palette, FomoShieldTheme.cardTitle()),
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
                      color: palette.textBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
          themedDivider(palette),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: FsScoreRing(score: score, palette: palette),
          ),
        ],
      ),
    );
  }
}

class _PsychologyMeterDetailCard extends StatelessWidget {
  final PsychologyMeterData data;
  final AppPalette palette;

  const _PsychologyMeterDetailCard({required this.data, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: themedHeaderText(
              l10n.psychologyMeterScreenSessionStats,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          themedDivider(palette),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: PsychologyAnalyticsSection(data: data, palette: palette),
          ),
        ],
      ),
    );
  }
}
