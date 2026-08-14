// ---------------------------------------------------------------------------
// Portfolio Balance — donut allocation ring + centered balance/unrealized
// P&L + per-holding legend. Pixel-for-pixel copy of Stress Test's own
// "Portfolio Balance" card (StressTestAllocationChart in
// stress_test/widgets/stress_test_allocation_chart.dart) — same card
// decoration, donut painter, fonts, colors, legend shape. Two deliberate
// differences from that reference: (1) no chevron / tap-through to a detail
// screen — real Portfolio doesn't have (or need) that drill-down; (2) driven
// by real Finnhub-backed PortfolioPerformance instead of the stress-test
// engine's simulated session. Replaces the old separate
// PortfolioSummaryWidget + PortfolioAllocationWidget (2026-08-09).
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/cache/logo_providers.dart'
    show resolvedCompanyNameProvider;
import '../../../shared/widgets/donut_ring_painter.dart';
import '../portfolio_providers.dart';

class PortfolioBalanceWidget extends ConsumerStatefulWidget {
  final PortfolioPerformance? performance;
  final bool isLoading;
  final bool hasError;

  const PortfolioBalanceWidget({
    super.key,
    this.performance,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  ConsumerState<PortfolioBalanceWidget> createState() =>
      _PortfolioBalanceWidgetState();
}

class _PortfolioBalanceWidgetState
    extends ConsumerState<PortfolioBalanceWidget> {
  static const int _legendPreviewLimit = 5;
  bool _showAll = false;

  /// Full number format with commas and fixed 2 decimals — e.g. $15,000.00
  String _fmtFull(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intStr = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
      buf.write(intStr[i]);
    }
    buf.write('.');
    buf.write(parts[1]);
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || widget.hasError || widget.performance == null) {
      return Container(
        width: double.infinity,
        height: 260,
        decoration: FomoShieldTheme.cardDecoration,
        alignment: Alignment.center,
        child: widget.hasError
            ? Text(
                'Failed to load',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                ),
              )
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeV2.primary,
                ),
              ),
      );
    }

    final perf = widget.performance!;
    final holdings = List<HoldingPerformance>.from(perf.holdings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final totalInvested = holdings.fold<double>(
      0,
      (s, h) => s + h.currentValue,
    );
    final hasData = holdings.isNotEmpty && totalInvested > 0;

    final portfolioTotal = perf.currentValue;
    // Unrealized P&L only — perf.pnl already excludes realized gains from
    // past sales (see portfolio_providers.dart), same semantics as Stress
    // Test's session.unrealizedPnl here.
    final pnl = perf.pnl;
    final pnlPercent = perf.pnlPercent;
    final isPositive = pnl >= 0;
    final isZero = pnl == 0;
    final pnlColor = isZero
        ? ThemeV2.textSecondary
        : isPositive
        ? ThemeV2.success
        : ThemeV2.loss;
    final pnlText = isZero
        ? '\$0.00'
        : '${isPositive ? '+' : '-'}\$${_fmtFull(pnl.abs())} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)';

    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Text(
                'PORTFOLIO BALANCE',
                style: FomoShieldTheme.cardTitle(),
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
                              ? holdings
                                    .map((h) => h.currentValue / totalInvested)
                                    .toList()
                              : [1.0],
                          colors: hasData
                              ? List.generate(
                                  holdings.length,
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
                            '\$${_fmtFull(portfolioTotal)}',
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
                              ? holdings.length
                              : math.min(_legendPreviewLimit, holdings.length));
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
                                ref
                                        .watch(
                                          resolvedCompanyNameProvider(
                                            holdings[i].symbol,
                                          ),
                                        )
                                        .valueOrNull ??
                                    holdings[i].symbol,
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
                              '${(holdings[i].currentValue / totalInvested * 100).toStringAsFixed(1)}%',
                              style: interNums(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (holdings.length > _legendPreviewLimit)
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
                                  : 'More (${holdings.length - _legendPreviewLimit})',
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
