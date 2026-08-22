// ---------------------------------------------------------------------------
// Stress Test Hub Screen
// ---------------------------------------------------------------------------
// Full-screen hub opened from bottom navigation. Shows active stress test
// sessions, completed verdict archive, and a "New Stress Test" button
// to create a new session and navigate to setup.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/layout/bottom_clearance.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import '../../shared/utils/currency_format.dart';
import '../../shared/widgets/widget_container.dart';
import '../market_clock/market_clock_dial.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';

// Market Clock ring's gold accent — used for the play-button badge and the
// "premium" tag below.
List<Shadow> _goldGlow(Color color) => [
  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
];

class StressTestHubScreen extends ConsumerWidget {
  const StressTestHubScreen({super.key});

  // Only the most recent 5 completed tests show inline; "More" opens a
  // sheet with the full archive instead of the card growing without limit.
  static const int _archivePreviewLimit = 5;

  void _showAllArchiveSheet(
    BuildContext context,
    List<VerdictArchiveEntry> archive,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(
                    sheetContext,
                  )!.stressTestCompletedTestsSheetTitle,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.6,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: archive.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) =>
                        _buildArchiveTile(sheetContext, archive[i]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();
    final archive = ref.watch(verdictArchiveProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.stressTestHubTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── New Stress Test Button ──────────────────────────────
            _buildNewTestCard(context, ref),
            const SizedBox(height: 12),

            // ── Active Sessions ─────────────────────────────────────
            if (activeSessions.isNotEmpty) ...[
              WidgetContainer(
                title: l10n.stressTestActiveTestsTitle,
                showFooter: false,
                children: activeSessions
                    .asMap()
                    .entries
                    .map(
                      (e) =>
                          _buildActiveSessionTile(context, ref, e.value, e.key),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Verdict Archive (WidgetContainer — always visible) ─
            WidgetContainer(
              title: l10n.stressTestCompletedTestsTitle,
              onTap: archive.length > _archivePreviewLimit
                  ? () => _showAllArchiveSheet(context, archive)
                  : null,
              showFooter: archive.length > _archivePreviewLimit,
              children: archive.isNotEmpty
                  ? archive
                        .take(_archivePreviewLimit)
                        .map((entry) => _buildArchiveTile(context, entry))
                        .toList()
                  : [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Center(
                          child: Text(
                            l10n.stressTestNoCompletedTestsYet,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ThemeV2.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 24),

            // Empty state
            if (sessions.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      color: ThemeV2.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.stressTestNoTestsYet,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.stressTestNoTestsHint,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: shellBottomClearance(context)),
          ],
        ),
      ),
    );
  }

  // ── New Test Card ────────────────────────────────────────────────

  Widget _buildNewTestCard(BuildContext context, WidgetRef ref) {
    final sessions = ref.read(stressTestProvider);
    final activeCount = sessions
        .where((s) => s.status == StressTestStatus.active)
        .length;
    final maxSessions = ref.read(maxStressTestSessionsProvider);
    final tier = ref.read(subscriptionTierProvider);
    final isFree = tier == SubscriptionTier.free;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => _startNewTest(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: darkCardDecoration(borderRadius: BorderRadius.circular(16))
            .copyWith(
              boxShadow: [
                BoxShadow(
                  color: dialDark.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stressTestNewTest,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isFree
                        ? l10n.stressTestActiveCountFree(
                            activeCount,
                            maxSessions,
                          )
                        : l10n.stressTestEmotionalResilience,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Premium badge for free users
            if (isFree)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeV2.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.profilePremiumBadge,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _startNewTest(BuildContext context, WidgetRef ref) {
    final activeCount = ref
        .read(stressTestProvider)
        .where((s) => s.status == StressTestStatus.active)
        .length;
    final maxSessions = ref.read(maxStressTestSessionsProvider);
    final tier = ref.read(subscriptionTierProvider);
    final notifier = ref.read(stressTestProvider.notifier);

    // Only the concurrent-slot limit gates creation (free: 2 at once,
    // premium: 5 at once) — no lifetime cap. Completing or deleting a
    // test frees its slot for a new one.
    if (activeCount >= maxSessions) {
      final l10n = AppLocalizations.of(context)!;
      if (tier == SubscriptionTier.free) {
        showPremiumPromoOverlay(
          context: context,
          title: l10n.stressTestLimitReachedTitle,
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.stressTestMaxSessionsReached)),
        );
      }
      return;
    }

    final cash = ref.read(stressTestStartingCashProvider);
    final id = notifier.createSession(TestDuration.week1, cash);
    if (context.mounted) {
      context.push('/stress-test/$id/setup');
    }
  }

  // ── Active Session Tile (Home style) ────────────────────────────

  // Same slot-position badge rules as the Home "MY STRESS TEST" widget's
  // _buildActiveSessionTile — see the comment there for the full
  // rationale (slot 1 = free, no badge; slot 2 = free tier's
  // ad-unlockable extra, shown as a "Go Premium" nudge until ad
  // integration exists; slots 3-5 = premium-only, always a premium
  // badge).
  Widget? _tierBadge(WidgetRef ref, BuildContext context, int index) {
    if (index == 0) return null;

    final tier = ref.watch(subscriptionTierProvider);
    final isPremiumTier =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;

    if (index == 1 && !isPremiumTier) {
      return InkWell(
        onTap: () => showMonetizationModal(context, ref),
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: ThemeV2.primary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            AppLocalizations.of(context)!.stressTestGoPremium,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(5)),
      child: Text(
        AppLocalizations.of(context)!.stressTestPremiumLowercase,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: dialBrassLight,
          letterSpacing: 0.8,
          shadows: _goldGlow(dialBrassLight),
        ),
      ),
    );
  }

  // Play-button icon color, same slot rules as [_tierBadge]: slot 1 is
  // always free (white), slot 2 is white on free tier / gold once premium,
  // slots 3-5 are premium-only so always gold.
  Color _playIconColor(WidgetRef ref, int index) {
    if (index == 0) return Colors.white;
    final tier = ref.watch(subscriptionTierProvider);
    final isPremiumTier =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;
    if (index == 1) return isPremiumTier ? dialBrassLight : Colors.white;
    return dialBrassLight;
  }

  Widget _buildActiveSessionTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
    int index,
  ) {
    final tierBadge = _tierBadge(ref, context, index);
    // Unrealized, not total-since-start — totalValue right above it
    // already reflects the whole account (cash + positions, including
    // any realized gains already banked), so this dollar figure shows
    // paper P&L on currently held positions specifically, matching the
    // same fix on the main Portfolio Balance card. Confirmed 2026-08-07.
    final plDollar = session.unrealizedPnl;
    final plColor = plDollar >= 0 ? ThemeV2.success : ThemeV2.loss;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: ValueKey('st_${session.id}'),
      onTap: () => context.go('/stress-test/${session.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: darkCardDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.play_circle_rounded,
                color: _playIconColor(ref, index),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.stressTestActiveLabel(
                        session.duration.localizedLabel(l10n),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tierBadge != null) ...[
                    const SizedBox(width: 6),
                    tierBadge,
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatUsd(session.totalValue),
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatUsdSigned(plDollar),
                  style: interNums(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: plColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Archive Tile (Verdict Archive — WidgetContainer style) ──────

  Widget _buildArchiveTile(BuildContext context, VerdictArchiveEntry entry) {
    final pnlColor = entry.pnlPercent >= 0 ? ThemeV2.success : ThemeV2.loss;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: ValueKey('archive_${entry.sessionId}'),
      onTap: () => context.push('/stress-test/${entry.sessionId}/verdict'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pnlColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                entry.pnlPercent >= 0
                    ? Icons.check_circle_rounded
                    : Icons.assessment_rounded,
                color: pnlColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.durationLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.stressTestArchiveSummary(
                      formatUsd(entry.finalValue),
                      entry.holdingCount,
                      entry.totalTrades,
                    ),
                    style: interNums(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.pnlPercent >= 0 ? '+' : ''}${entry.pnlPercent.toStringAsFixed(1)}%',
              style: interNums(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pnlColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
