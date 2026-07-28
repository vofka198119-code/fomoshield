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
import '../../../core/supabase/supabase_providers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../monetization/monetization_modal.dart';
import '../../market_clock/market_clock_dial.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';

// Brand dark-green gradient (same as TARGET/Shield Signal) and the Market
// Clock ring's gold accent — used for the play-button badge and every
// "PREMIUM" tag below.
const List<Color> _brandGradient = [dialLight, dialDark];
List<Shadow> _goldGlow(Color color) =>
    [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6)];

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
                  'Active Tests',
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
                      return _buildActiveSessionTile(sheetContext, ref, s, i);
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
    final sessions = ref.watch(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();
    final completedSessions = sessions
        .where((s) => s.status == StressTestStatus.completed)
        .toList();
    final tier = ref.watch(subscriptionTierProvider);
    final isFree = tier == SubscriptionTier.free;

    // Collect all children
    final List<Widget> children = [];

    // ── Active sessions ────────────────────────────────────────────
    if (activeSessions.isNotEmpty) {
      final preview = activeSessions.take(2).toList().asMap().entries.map((
        e,
      ) {
        return _buildActiveSessionTile(context, ref, e.value, e.key);
      }).toList();
      children.addAll(preview);
    }

    // ── Completed results ("Мои результаты") ───────────────────────
    if (completedSessions.isNotEmpty) {
      final completedPreview = completedSessions.take(2).map((session) {
        return _buildCompletedResultTile(context, ref, session);
      }).toList();

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                'МОИ РЕЗУЛЬТАТЫ',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle_rounded,
                size: 12,
                color: ThemeV2.primary,
              ),
              const Spacer(),
              // PREMIUM badge for free users
              if (isFree)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _brandGradient,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: dialBrassLight,
                      letterSpacing: 1.2,
                      shadows: _goldGlow(dialBrassLight),
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
              '+${completedSessions.length - 2} more completed',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: ThemeV2.textSecondary,
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
        title: 'MY STRESS TEST',
        showFooter: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: ThemeV2.textSecondary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No active tests',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a new test from the bottom panel',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return WidgetContainer(
      title: 'MY STRESS TEST',
      onTap: activeSessions.length > 2
          ? () => _showAllTestsSheet(context, ref)
          : null,
      showFooter: activeSessions.length > 2,
      children: children,
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

  // Tier badge, keyed by slot position (index) among the user's active
  // tests, not the user's own tier alone — slot 1 is always free (no
  // badge), slot 2 is the free tier's ad-unlockable extra test (no ad
  // integration yet, so it's a "Go Premium" nudge for free users, a
  // normal premium badge once actually on premium), slots 3-5 are
  // premium-only so any session there always belongs to a premium/admin
  // user. Uses the session's position within the currently-active list,
  // which is a good-enough proxy but isn't authoritative if an earlier
  // session was deleted — flag if a slot ever looks mislabeled.
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
            'GO PREMIUM',
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _brandGradient,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'premium',
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

  Widget _buildActiveSessionTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
    int index,
  ) {
    final tierBadge = _tierBadge(ref, context, index);

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
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _brandGradient,
                ),
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
                      'Active — ${session.duration.displayName}',
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
                  '\$${session.totalValue.toStringAsFixed(0)}',
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.profitLoss >= 0 ? '+' : '-'}\$${session.profitLoss.abs().toStringAsFixed(0)}',
                  style: interNums(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: session.profitLoss >= 0
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
  ) {
    // Retrieve psychological verdict
    PsychologicalVerdict? verdict;
    try {
      verdict = ref
          .read(stressTestProvider.notifier)
          .calculateVerdict(session.id);
    } catch (_) {}

    final verdictTitle = verdict?.title ?? '—';
    final pnlColor = session.profitLoss >= 0
        ? ThemeV2.success
        : ThemeV2.loss;

    return InkWell(
      key: ValueKey('st_completed_${session.id}'),
      onTap: () => context.go('/stress-test/${session.id}/verdict'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Completed-test icon — same badge style as the active-test
            // play button, stop square instead of a play triangle.
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _brandGradient,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.stop_circle_rounded,
                color: dialBrassLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verdictTitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    session.duration.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: ThemeV2.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

