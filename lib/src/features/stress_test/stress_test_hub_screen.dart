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
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import '../../shared/widgets/widget_container.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';

class StressTestHubScreen extends ConsumerWidget {
  const StressTestHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(stressTestProvider);
    final activeSessions = sessions
        .where((s) => s.status == StressTestStatus.active)
        .toList();
    final archive = ref.watch(verdictArchiveProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'STRESS TEST',
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
                title: 'ACTIVE TESTS',
                onTap: () {},
                showFooter: false,
                children: activeSessions
                    .map((s) => _buildActiveSessionTile(context, ref, s))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Verdict Archive (WidgetContainer — always visible) ─
            WidgetContainer(
              title: 'COMPLETED TESTS',
              onTap: () {},
              showFooter: archive.length > 2,
              children: archive.isNotEmpty
                  ? archive
                        .take(20)
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
                            'No completed tests yet',
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
                      'No stress tests yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the button above to start your first test',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── New Test Card ────────────────────────────────────────────────

  Widget _buildNewTestCard(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(stressTestProvider.notifier);
    final maxTotal = ref.read(maxStressTestTotalProvider);
    final totalUsed = notifier.totalSessionsCreated;
    final remaining = (maxTotal - totalUsed).clamp(0, maxTotal);
    final tier = ref.read(subscriptionTierProvider);
    final isFree = tier == SubscriptionTier.free;

    return InkWell(
      onTap: () => _startNewTest(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ThemeV2.primary, Color(0xFF0055CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeV2.primary.withValues(alpha: 0.3),
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
                    'New Stress Test',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isFree
                        ? '$remaining/$maxTotal remaining · Premium = 5'
                        : 'Test your emotional resilience',
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
                  'PREMIUM',
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
    final maxTotal = ref.read(maxStressTestTotalProvider);
    final tier = ref.read(subscriptionTierProvider);
    final notifier = ref.read(stressTestProvider.notifier);

    // Check total sessions created limit (2 for free, 5 for premium)
    if (notifier.totalSessionsCreated >= maxTotal) {
      if (tier == SubscriptionTier.free) {
        showPremiumPromoOverlay(
          context: context,
          title: 'Stress test limit reached',
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum test sessions reached')),
        );
      }
      return;
    }

    // Check active sessions limit
    if (activeCount >= maxSessions) {
      if (tier == SubscriptionTier.free) {
        showPremiumPromoOverlay(
          context: context,
          title: 'Stress test limit reached',
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum active test sessions reached')),
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

  Widget _buildActiveSessionTile(
    BuildContext context,
    WidgetRef ref,
    StressTestSession session,
  ) {
    final tier = ref.watch(subscriptionTierProvider);
    final tierLabel = tier == SubscriptionTier.free ? 'free' : 'premium';
    final plDollar = session.profitLoss;
    final plSign = plDollar >= 0 ? '+' : '';
    final plColor = plDollar >= 0 ? ThemeV2.success : ThemeV2.loss;

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
                color: ThemeV2.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_circle_rounded,
                color: ThemeV2.primary,
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
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: tier == SubscriptionTier.free
                          ? ThemeV2.textSecondary.withValues(alpha: 0.15)
                          : ThemeV2.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tierLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tier == SubscriptionTier.free
                            ? ThemeV2.textSecondary
                            : ThemeV2.primary,
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
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$plSign\$${plDollar.abs().toStringAsFixed(0)}',
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
                    'Final: \$${entry.finalValue.toStringAsFixed(0)} · ${entry.holdingCount} holdings · ${entry.totalTrades} trades',
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
                fontWeight: FontWeight.w700,
                color: pnlColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
