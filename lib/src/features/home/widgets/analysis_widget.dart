// ---------------------------------------------------------------------------
// Analysis Widget — Explainable Analysis card (Bible Part 2, section 9)
// ---------------------------------------------------------------------------
// Показывает ExplainableCard с разбивкой изменения цены по 5 факторам.
// Использует последнюю сессию stress test — берёт реальные TickExplanation
// из explanationLog движка, а не случайные данные.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../stress_test/stress_test_models.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../shared/widgets/explainable_card.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';

class AnalysisWidget extends ConsumerWidget {
  const AnalysisWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(stressTestProvider);
    final activeSession = sessions.where(
      (s) => s.status == StressTestStatus.active,
    ).firstOrNull;

    if (activeSession != null) {
      final data = _buildExplainableData(activeSession);

      return WidgetContainer(
        title: 'ANALYSIS',
        onTap: () => context.go('/stress-test/${activeSession.id}'),
        showFooter: true,
        footerText: 'Full analysis',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: ExplainableCard(data: data),
          ),
        ],
      );
    }

    // No active session
    return WidgetContainer(
      title: 'ANALYSIS',
      onTap: () => context.go('/stress-test-hub'),
      showFooter: true,
      footerText: 'Start stress test',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Icon(Icons.analytics_rounded,
                  size: 32, color: ThemeV2.textSecondary.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'Run a stress test to see\nwhat drives your returns',
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

  /// Берёт реальные TickExplanation из explanationLog движка.
  /// Если данных нет — возвращает ExplainableData с нулевыми изменениями.
  ExplainableData _buildExplainableData(StressTestSession session) {
    // Берём первый активный тикер в портфеле
    final topSymbol = session.holdings.isNotEmpty
        ? session.holdings.first.symbol
        : 'PORTFOLIO';

    // Пробуем взять последнее TickExplanation из движка
    final explanations = session.explanationLog[topSymbol] ?? [];
    if (explanations.isNotEmpty) {
      final latest = explanations.last;
      return ExplainableData.fromExplanation(latest);
    }

    // Если explanationLog пуст — возвращаем данные с 0 изменений
    return ExplainableData(
      symbol: topSymbol,
      changePercent: 0.0,
      contributions: const PriceContribution(
        marketPct: 40,
        sectorPct: 25,
        companyPct: 15,
        newsPct: 0,
        noisePct: 20,
      ),
      marketPhase: session.devMarketPhase,
      scenario: session.epochHistory.isNotEmpty
          ? session.epochHistory.last.scenario.name
          : 'unknown',
    );
  }
}


