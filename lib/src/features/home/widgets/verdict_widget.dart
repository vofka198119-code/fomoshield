// ---------------------------------------------------------------------------
// Verdict Widget — Latest Verdict card (Bible Part 2, section 10)
// ---------------------------------------------------------------------------
// Показывает последний вердикт из архива завершённых stress test.
// Использует VerdictCard если есть завершённая сессия.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../../shared/widgets/verdict_card.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';

class VerdictWidget extends ConsumerWidget {
  const VerdictWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archive = ref.watch(verdictArchiveProvider);

    if (archive.isNotEmpty) {
      final latestEntry = archive.first;
      return WidgetContainer(
        title: 'LATEST VERDICT',
        onTap: () => context.go('/stress-test/${latestEntry.sessionId}/verdict'),
        showFooter: true,
        footerText: 'View full analysis',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: VerdictCard(
              entry: latestEntry,
              sessionId: latestEntry.sessionId,
            ),
          ),
        ],
      );
    }

    // No verdicts yet
    return WidgetContainer(
      title: 'LATEST VERDICT',
      onTap: () => context.go('/stress-test-hub'),
      showFooter: true,
      footerText: 'Start stress test',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Icon(Icons.assignment_rounded,
                  size: 32, color: ThemeV2.textSecondary.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'Complete a stress test\nto receive your verdict',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

