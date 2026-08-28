// ---------------------------------------------------------------------------
// Verdict Screen — Final Psychological Assessment
// ---------------------------------------------------------------------------
// Displays the calculated psychological verdict: FS Score plus the
// Strategy/Diversification/marker breakdown cards. The Absolute Shield
// badge and over-concentration warning card (conditional, rarely shown)
// were cut 2026-08-08, along with the in-progress Stress Test screen's
// old duplicate VerdictCard widget (shared/widgets/verdict_card.dart,
// deleted the same day — this screen is now the only verdict UI).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_border.dart';
import '../../l10n/gen/app_localizations.dart';
import '../market_clock/market_clock_dial.dart'
    show darkCardDecoration, dialDark;
import '../../shared/widgets/stagger_fade_in.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';
import 'stress_test_verdict_access_provider.dart';
import '../monetization/monetization_modal.dart';
import 'psychology_engine.dart' show computeStrategicScore;
import 'widgets/verdict_trade_breakdown_widget.dart';
import 'widgets/verdict/verdict_marker_row.dart';
import 'widgets/verdict/verdict_diversification_card.dart';
import 'widgets/verdict/verdict_strategy_card.dart';
import 'widgets/verdict/stress_test_verdict_disclaimer.dart';

class VerdictScreen extends ConsumerWidget {
  final String sessionId;

  const VerdictScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
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
          title: themedHeaderText(
            l10n.verdictTitle,
            palette,
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Text(
            l10n.verdictNotAvailable,
            style: GoogleFonts.inter(color: palette.textBody),
          ),
        ),
      );
    }

    final access = ref.watch(verdictAccessProvider(sessionId));
    if (access.isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: palette.accentPrimary),
        ),
      );
    }
    final locked = access.valueOrNull == false;
    if (locked) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: themedHeaderText(
            l10n.verdictTitle,
            palette,
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 48, color: palette.textBody),
                const SizedBox(height: 16),
                Text(
                  l10n.verdictAccessLockedTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.verdictAccessLockedDetail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => showMonetizationModal(context, ref),
                  child: Text(l10n.verdictAccessLockedTitle),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: themedHeaderText(
          l10n.verdictSessionCompleteTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        leading: themedBackButton(
          context,
          palette,
          size: 22,
          onPressed: () => context.go('/stress-test-hub'),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Guardian Verdict ────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('guardian'),
                child: StaggerFadeIn(
                  index: 0,
                  child: _GuardianVerdictSection(palette: palette),
                ),
              ),
              const SizedBox(height: 24),

              // ── Strategy Score ───────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('strategyScore'),
                child: StaggerFadeIn(
                  index: 1,
                  child: _buildFsScoreGauge(
                    (computeStrategicScore(
                              diversification: entry.strategyDiversification,
                              sector: entry.strategySector,
                              concentration: entry.strategyConcentration,
                              etf: entry.strategyEtf,
                              cashBuffer: entry.strategyCashBuffer,
                              safetyMarker: entry.safetyMarker,
                            ) *
                            100)
                        .round(),
                    l10n.verdictScreenStrategyScoreLabel,
                    palette,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Strategy ─────────────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('strategy'),
                child: StaggerFadeIn(
                  index: 2,
                  child: VerdictStrategyCard(
                    sessionId: sessionId,
                    concentrationScore: entry.strategyConcentration,
                    etfExposureScore: entry.strategyEtf,
                    cashBufferScore: entry.strategyCashBuffer,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Diversification ──────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('diversification'),
                child: StaggerFadeIn(
                  index: 3,
                  child: VerdictDiversificationCard(
                    sessionId: sessionId,
                    sectorDiversificationScore: entry.strategyDiversification,
                    safetyMarkerScore: entry.safetyMarker,
                    sectorBalanceScore: entry.strategySector,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Psychology Score ─────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('psychologyScore'),
                child: StaggerFadeIn(
                  index: 4,
                  child: _buildFsScoreGauge(
                    ((entry.discipline * 0.37 +
                                    entry.panicResistance * 0.32 +
                                    entry.patience * 0.31)
                                .clamp(0.0, 1.0) *
                            100)
                        .round(),
                    l10n.verdictScreenPsychologyScoreLabel,
                    palette,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Per-marker verdict cards ─────────────────────────
              KeyedSubtree(
                key: const ValueKey('discipline'),
                child: StaggerFadeIn(
                  index: 5,
                  child: VerdictSingleMarkerCard(
                    sessionId: sessionId,
                    markerId: 'discipline',
                    title: l10n.verdictScreenDisciplineTitle,
                    label: l10n.verdictScreenDisciplineLabel,
                    score: entry.discipline,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: const ValueKey('panic'),
                child: StaggerFadeIn(
                  index: 6,
                  child: VerdictSingleMarkerCard(
                    sessionId: sessionId,
                    markerId: 'panic',
                    title: l10n.verdictScreenPanicTitle,
                    label: l10n.verdictScreenPanicLabel,
                    score: entry.panicResistance,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: const ValueKey('patience'),
                child: StaggerFadeIn(
                  index: 7,
                  child: VerdictSingleMarkerCard(
                    sessionId: sessionId,
                    markerId: 'patience',
                    title: l10n.verdictScreenPatienceTitle,
                    label: l10n.verdictScreenPatienceLabel,
                    score: entry.patience,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Trade Breakdown (incl. session stats; full detail
              // screen — reached via its own chevron — now also hosts
              // Trade History) ──────────────────────────────────────
              KeyedSubtree(
                key: const ValueKey('tradeBreakdown'),
                child: StaggerFadeIn(
                  index: 8,
                  child: VerdictTradeBreakdownWidget(
                    entry: entry,
                    palette: palette,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              KeyedSubtree(
                key: const ValueKey('disclaimer'),
                child: StaggerFadeIn(
                  index: 9,
                  child: const StressTestVerdictDisclaimer(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Continue Learning ───────────────────────────────
              KeyedSubtree(
                key: const ValueKey('continueLearning'),
                child: StaggerFadeIn(
                  index: 10,
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/stress-test-hub'),
                        borderRadius: BorderRadius.circular(14),
                        child: Ink(
                          decoration:
                              darkCardDecoration(
                                borderRadius: BorderRadius.circular(14),
                              ).copyWith(
                                boxShadow: [
                                  BoxShadow(
                                    color: dialDark.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.verdictContinueLearning,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: const ValueKey('backToHome'),
                child: StaggerFadeIn(
                  index: 11,
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: Text(
                        l10n.verdictBackToHome,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: palette.textBody,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFsScoreGauge(int score, String label, AppPalette palette) {
    final color = score >= 70
        ? ThemeV2.success
        : score >= 40
        ? ThemeV2.warning
        : ThemeV2.loss;
    // This gauge is normal-case (light-under-Standard, dark-under-Luxury)
    // — swap the flat circle fill only when Luxury is active, keeping
    // Standard pixel-for-pixel (palette.card isn't guaranteed to equal
    // FomoShieldTheme.card's exact value).
    final circleColor = palette.titleGradient != null
        ? palette.card
        : FomoShieldTheme.card;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
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
            // Deliberate 2-line stack (word / "SCORE") instead of relying
            // on auto-wrap — "PSYCHOLOGY SCORE" doesn't fit this circle's
            // width on one line at this letter-spacing, and letting it wrap
            // wherever it wants broke mid-word ("PSYCHOLOGICAL" over
            // "SCORE") — this always breaks cleanly at the space instead.
            Text(
              label.replaceFirst(' ', '\n'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                height: 1.4,
                color: palette.textBody,
              ),
            ),
          ],
        ),
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
  final AppPalette palette;
  const _GuardianVerdictSection({required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasThemedBorder = palette.borderGradient != null;
    final radius = BorderRadius.circular(20);
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasThemedBorder ? null : ThemeV2.primary.withValues(alpha: 0.06),
        gradient: hasThemedBorder ? palette.windowGradient : null,
        borderRadius: radius,
        border: hasThemedBorder
            ? null
            : Border.all(color: ThemeV2.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shield icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: palette.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 24,
              color: palette.accentPrimary,
            ),
          ),
          const SizedBox(width: 16),
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verdictGuardianVerdictLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: palette.accentPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.verdictGuardianHeadline,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.verdictGuardianShortText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: palette.textBody,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push('/metric-info/guardian-verdict'),
                  child: Text(
                    l10n.verdictViewYourAnalysis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return hasThemedBorder
        ? themedBorder(palette: palette, borderRadius: radius, child: content)
        : content;
  }
}
