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
import '../../../core/theme/app_theme.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';

class StressTestWidget extends ConsumerWidget {
  const StressTestWidget({super.key});

  void _showAllTestsSheet(BuildContext context, WidgetRef ref) {
    final sessions = ref.read(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
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
                    color: AppTheme.textPrimary,
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
                      return _buildActiveSessionTile(sheetContext, ref, s);
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
      final preview = activeSessions.take(2).map((session) {
        return _buildActiveSessionTile(context, ref, session);
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
                  color: AppTheme.premiumGreen,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle_rounded,
                size: 12,
                color: AppTheme.premiumGreen,
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
                    color: AppTheme.premiumGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
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
                color: AppTheme.textDim,
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
        onTap: () {},
        showFooter: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_rounded,
                  color: AppTheme.textDim,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No active tests',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textDim,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a new test from the bottom panel',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textDim,
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
          : () {},
      showFooter: activeSessions.length > 2,
      children: children,
    );
  }

  Widget _buildActiveSessionTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
  ) {
    final tier = ref.watch(subscriptionTierProvider);
    final tierLabel = tier == SubscriptionTier.free ? 'free' : 'premium';

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
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_circle_rounded,
                color: AppTheme.accentBlue,
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
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: tier == SubscriptionTier.free
                          ? AppTheme.textDim.withValues(alpha: 0.15)
                          : AppTheme.premiumGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tierLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tier == SubscriptionTier.free
                            ? AppTheme.textDim
                            : AppTheme.premiumGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${session.totalValue.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.profitLoss >= 0 ? '+' : ''}\$${session.profitLoss.abs().toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: session.profitLoss >= 0
                        ? AppTheme.shieldGreen
                        : AppTheme.dangerRed,
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
    final fsScore = verdict?.fsScore ?? 0;
    final pnlColor = session.profitLoss >= 0
        ? AppTheme.shieldGreen
        : AppTheme.dangerRed;

    return InkWell(
      key: ValueKey('st_completed_${session.id}'),
      onTap: () => context.go('/stress-test/${session.id}/verdict'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // FS Score circle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.premiumGreen, Color(0xFF006634)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '$fsScore',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    session.duration.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            // P&L
            Text(
              '${session.profitLoss >= 0 ? '+' : ''}${session.profitLossPercent.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pnlColor,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textDim,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
