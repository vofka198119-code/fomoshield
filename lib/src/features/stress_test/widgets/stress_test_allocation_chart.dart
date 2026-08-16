// ---------------------------------------------------------------------------
// Stress Test — Allocation Donut Chart card
// Extracted from stress_test_screen.dart (Phase 5, step-by-step widget pass).
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/donut_ring_painter.dart';
import '../stress_test_models.dart';
import '../stress_test_naming.dart';

/// Card wrapper: donut chart + centered portfolio metrics + cash capsule,
/// styled to the standard light card (see reference_widget_card_standard).
class StressTestAllocationChart extends ConsumerStatefulWidget {
  final StressTestSession session;

  const StressTestAllocationChart({super.key, required this.session});

  @override
  ConsumerState<StressTestAllocationChart> createState() =>
      _StressTestAllocationChartState();
}

class _StressTestAllocationChartState
    extends ConsumerState<StressTestAllocationChart> {
  static const int _legendPreviewLimit = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final holdings = session.holdings;
    final isEmpty = holdings.isEmpty;

    final invested = <({String symbol, double value})>[];
    double totalInvested = 0;
    for (final h in holdings) {
      final price = session.currentPrices[h.symbol] ?? h.entryPrice;
      final val = h.shares * price;
      invested.add((symbol: h.symbol, value: val));
      totalInvested += val;
    }
    invested.sort((a, b) => b.value.compareTo(a.value));

    final hasData = !isEmpty && totalInvested > 0;

    final portfolioTotal = session.totalValue;
    // Balance itself already reflects the whole account (cash + positions,
    // including any realized gains already banked into cash) — this
    // subtitle shows Unrealized P&L specifically (paper P&L on currently
    // held positions only), so it stops double-counting realized gains
    // that are already visible in Balance. Realized P&L lives in its own
    // row on the Psychology Meter's Session Stats card. Confirmed
    // 2026-08-07 after a live on-device walkthrough.
    final pnl = session.unrealizedPnl;
    final pnlPercent = session.unrealizedPnlPercent;
    final isPositive = pnl >= 0;
    final isZero = pnl == 0;
    final pnlColor = isZero
        ? ThemeV2.textSecondary
        : isPositive
        ? ThemeV2.success
        : ThemeV2.loss;
    final pnlText = isZero
        ? formatUsd(0)
        : '${formatUsdSigned(pnl)} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)';

    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                context.push('/stress-test/${session.id}/portfolio-balance'),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                child: Row(
                  children: [
                    Text(
                      'PORTFOLIO BALANCE',
                      style: FomoShieldTheme.cardTitle(),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: ThemeV2.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 16),
          Padding(
            // Wider than the title's 22px inset on purpose — shrinks the
            // ring itself so it doesn't dominate the card now that a legend
            // sits below it (see DonutRingPainter, which derives its
            // radius from the box size it's given).
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final ringSize = constraints.maxWidth;
                return SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(ringSize, ringSize),
                        painter: DonutRingPainter(
                          shares: hasData
                              ? invested
                                    .map((item) => item.value / totalInvested)
                                    .toList()
                              : [1.0],
                          colors: hasData
                              ? List.generate(
                                  invested.length,
                                  (i) => donutAllocationColor(i),
                                )
                              : [Colors.black.withValues(alpha: 0.06)],
                          gapDegrees: hasData ? 5 : 0,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'BALANCE',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeV2.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatUsd(portfolioTotal),
                            style: interNums(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pnlText,
                            style: interNums(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: pnlColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (hasData) ...[
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    for (
                      var i = 0;
                      i <
                          (_showAll
                              ? invested.length
                              : math.min(_legendPreviewLimit, invested.length));
                      i++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: donutAllocationColor(i),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                resolveStressTestCompanyName(
                                  ref,
                                  invested[i].symbol,
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeV2.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(invested[i].value / totalInvested * 100).toStringAsFixed(1)}%',
                              style: interNums(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (invested.length > _legendPreviewLimit)
                      GestureDetector(
                        onTap: () => setState(() => _showAll = !_showAll),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: ThemeV2.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _showAll
                                  ? 'Less'
                                  : 'More (${invested.length - _legendPreviewLimit})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
