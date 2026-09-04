// ---------------------------------------------------------------------------
// My Stress Test Widget — Home Screen
// ---------------------------------------------------------------------------
// Shows active stress test sessions on the home screen, plus completed
// "Мои результаты" (My Results) section with PREMIUM badge for free users.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../monetization/monetization_modal.dart';
import '../../market_clock/market_clock_dial.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../../l10n/gen/app_localizations.dart';

// Market Clock ring's gold accent — used for the play-button badge and
// every "PREMIUM" tag below.
List<Shadow> _goldGlow(Color color) => [
  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
];

class StressTestWidget extends ConsumerWidget {
  const StressTestWidget({super.key});

  void _showAllTestsSheet(BuildContext context, WidgetRef ref) {
    final sessions = ref.read(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();

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
                  AppLocalizations.of(context)!.stressTestActiveTests,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: activeSessions.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) {
                      final s = activeSessions[i];
                      // This sheet is always light/white, unrelated to the
                      // Luxury Gold rollout (modals stay out of scope) — an
                      // explicit Standard palette keeps the tile's look
                      // exactly as before regardless of the active theme.
                      return _buildActiveSessionTile(
                        sheetContext,
                        ref,
                        s,
                        i,
                        AppPalette.standard,
                      );
                    },
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
    final l10n = AppLocalizations.of(context)!;
    final sessions = ref.watch(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();
    final completedSessions = sessions
        .where((s) => s.status == StressTestStatus.completed)
        .toList();
    final tier = ref.watch(subscriptionTierProvider);
    final isFree = tier == SubscriptionTier.free;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    // Collect all children
    final List<Widget> children = [];

    // ── Active sessions ────────────────────────────────────────────
    if (activeSessions.isNotEmpty) {
      final preview = activeSessions.take(2).toList().asMap().entries.map((e) {
        return _buildActiveSessionTile(context, ref, e.value, e.key, palette);
      }).toList();
      children.addAll(preview);
    }

    // ── Completed results ("Мои результаты") ───────────────────────
    if (completedSessions.isNotEmpty) {
      final completedPreview = completedSessions.take(2).map((session) {
        return _buildCompletedResultTile(context, ref, session, palette);
      }).toList();

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                l10n.stressTestMyResults,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: palette.accentPrimary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle_rounded,
                size: 12,
                color: palette.accentPrimary,
              ),
              const Spacer(),
              // PREMIUM badge for free users
              if (isFree)
                themedBorder(
                  palette: palette,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: palette.windowGradient != null
                        ? BoxDecoration(
                            gradient: palette.windowGradient,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : darkCardDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                    child: Text(
                      l10n.profilePremiumBadge,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: palette.marketClockAccent ?? dialBrassLight,
                        letterSpacing: 1.2,
                        shadows: _goldGlow(
                          palette.marketClockAccent ?? dialBrassLight,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
      children.addAll(completedPreview);

      if (completedSessions.length > 2) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              l10n.stressTestMoreCompleted(completedSessions.length - 2),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: palette.textBody,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
    }

    // No content at all — show empty state
    if (children.isEmpty) {
      return WidgetContainer(
        title: l10n.stressTestWidgetTitle,
        showFooter: false,
        palette: palette,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology_rounded,
                  color: palette.textBody,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.stressTestNoActiveTests,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.stressTestStartNewTest,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: palette.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return WidgetContainer(
      title: l10n.stressTestWidgetTitle,
      onTap: activeSessions.length > 2
          ? () => _showAllTestsSheet(context, ref)
          : null,
      showFooter: activeSessions.length > 2,
      palette: palette,
      children: children,
    );
  }

  // Play-button icon color, same slot rules as [_tierBadge]: slot 1 is
  // always free (white), slot 2 is white on free tier / gold once premium,
  // slots 3-5 are premium-only so always gold.
  Color _playIconColor(WidgetRef ref, int index, AppPalette palette) {
    if (index == 0) return Colors.white;
    final tier = ref.watch(subscriptionTierProvider);
    final isPremiumTier = tier.isPremiumOrAdmin;
    final accentColor = palette.marketClockAccent ?? dialBrassLight;
    if (index == 1) return isPremiumTier ? accentColor : Colors.white;
    return accentColor;
  }

  // Tier badge, keyed by slot position (index) among the user's active
  // tests, not the user's own tier alone — slot 1 is always free (no
  // badge), slot 2 is the free tier's ad-unlockable extra test (no ad
  // integration yet, so it's a "Go Premium" nudge for free users, a
  // normal premium badge once actually on premium), slots 3-5 are
  // premium-only so any session there always belongs to a premium/admin
  // user. Uses the session's position within the currently-active list,
  // which is a good-enough proxy but isn't authoritative if an earlier
  // session was deleted — flag if a slot ever looks mislabeled.
  Widget? _tierBadge(
    WidgetRef ref,
    BuildContext context,
    int index,
    AppPalette palette,
  ) {
    if (index == 0) return null;

    final tier = ref.watch(subscriptionTierProvider);
    final isPremiumTier = tier.isPremiumOrAdmin;

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
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: BorderRadius.circular(5),
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(5)),
      child: Text(
        // Uppercased on purpose — lowercase glyphs sit visibly off-center
        // in this pill's tight vertical padding (confirmed on-device
        // 2026-09-04: every OTHER premium badge here is already an
        // all-caps string and centers fine; only this one wasn't).
        AppLocalizations.of(context)!.stressTestPremiumLowercase.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: palette.marketClockAccent ?? dialBrassLight,
          letterSpacing: 0.8,
          shadows: _goldGlow(palette.marketClockAccent ?? dialBrassLight),
        ),
      ),
    );
  }

  Widget _buildActiveSessionTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
    int index,
    AppPalette palette,
  ) {
    final tierBadge = _tierBadge(ref, context, index, palette);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      key: ValueKey('st_${session.id}'),
      onTap: () => context.go('/stress-test/${session.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            themedBorder(
              palette: palette,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: palette.windowGradient != null
                    ? BoxDecoration(
                        gradient: palette.windowGradient,
                        borderRadius: BorderRadius.circular(10),
                      )
                    : darkCardDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                child: Icon(
                  Icons.play_circle_rounded,
                  color: _playIconColor(ref, index, palette),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session.displayLabel(
                            session.duration.localizedLabel(l10n),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.textHeader,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (session.name != null &&
                            session.name!.trim().isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            session.duration.localizedLabel(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: palette.titleGradient != null
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : palette.textBody,
                            ),
                          ),
                        ],
                      ],
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
                themedPriceText(
                  formatUsd(session.totalValue),
                  palette,
                  interNums(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  formatUsdSigned(session.unrealizedPnl),
                  style: interNums(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: session.unrealizedPnl >= 0
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedResultTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
    AppPalette palette,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Retrieve psychological verdict
    PsychologicalVerdict? verdict;
    try {
      verdict = ref
          .read(stressTestProvider.notifier)
          .calculateVerdict(session.id, l10n);
    } catch (_) {}

    final verdictTitle = verdict?.title ?? '—';
    final pnlColor = session.profitLoss >= 0 ? ThemeV2.success : ThemeV2.loss;

    return InkWell(
      key: ValueKey('st_completed_${session.id}'),
      onTap: () => context.go('/stress-test/${session.id}/verdict'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Completed-test icon — same badge style as the active-test
            // play button, stop square instead of a play triangle.
            themedBorder(
              palette: palette,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                decoration: palette.windowGradient != null
                    ? BoxDecoration(
                        gradient: palette.windowGradient,
                        borderRadius: BorderRadius.circular(10),
                      )
                    : darkCardDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                child: Icon(
                  Icons.stop_circle_rounded,
                  color: palette.marketClockAccent ?? dialBrassLight,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.displayLabel(verdictTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    session.duration.localizedLabel(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            // P&L
            Text(
              '${session.profitLoss >= 0 ? '+' : ''}${session.profitLossPercent.toStringAsFixed(1)}%',
              style: interNums(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: pnlColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textBody,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
