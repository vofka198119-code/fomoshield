import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../portfolio/portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Widget — Live portfolio summary for Home screen
// ---------------------------------------------------------------------------

class PortfolioWidget extends ConsumerWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);
    final activeId = ref.watch(activePortfolioIdProvider);
    final effectiveId =
        activeId ?? (portfolios.isNotEmpty ? portfolios.first.id : null);

    if (effectiveId == null) {
      return WidgetContainer(
        title: 'MY PORTFOLIO',
        onTap: () => context.go('/portfolio'),
        showFooter: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text('No portfolio',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.textDim)),
          ),
        ],
      );
    }

    final performanceAsync =
        ref.watch(portfolioPerformanceProvider(effectiveId));
    final activePortfolio =
        portfolios.firstWhere((p) => p.id == effectiveId);

    return performanceAsync.when(
      loading: () => WidgetContainer(
        title: 'MY PORTFOLIO',
        onTap: () => context.go('/portfolio'),
        showFooter: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accentBlue),
                ),
                const SizedBox(width: 12),
                Text(activePortfolio.name,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textDim)),
              ],
            ),
          ),
        ],
      ),
      error: (_, _) => WidgetContainer(
        title: 'MY PORTFOLIO',
        onTap: () => context.go('/portfolio'),
        showFooter: false,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text('\$– – –',
                style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5)),
          ),
        ],
      ),
      data: (perf) => WidgetContainer(
        title: activePortfolio.name.toUpperCase(),
        onTap: () => context.go('/portfolio'),
        showFooter: false,
        children: [
          _balanceSection(perf),
          if (perf.holdings.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            _holdingsPreview(perf),
          ],
          const SizedBox(height: 12),
          _simulationBadge(),
        ],
      ),
    );
  }

  Widget _balanceSection(dynamic perf) {
    final isUp = perf.pnl >= 0;
    final c = isUp ? AppTheme.shieldGreen : AppTheme.dangerRed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textDim,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('\$${perf.currentValue.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${isUp ? '+' : ''}\$${perf.pnl.toStringAsFixed(2)} (${isUp ? '+' : ''}${perf.pnlPercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c)),
              const SizedBox(width: 8),
              Text('\u00b7 \$${perf.totalInvested.toStringAsFixed(0)} invested',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textDim)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _holdingsPreview(dynamic perf) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Holdings (${perf.holdings.length})',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textDim)),
              Text('\$${perf.currentValue.toStringAsFixed(2)} in stocks',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textDim)),
            ],
          ),
          const SizedBox(height: 8),
          ...perf.holdings.take(3).map<Widget>((h) {
            final hIsUp = h.pnl >= 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(h.symbol,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text('\$${h.currentValue.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '${hIsUp ? '+' : ''}\$${h.pnl.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: hIsUp
                              ? AppTheme.shieldGreen
                              : AppTheme.dangerRed),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (perf.holdings.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('+${perf.holdings.length - 3} more',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _simulationBadge() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.shieldYellow,
              ),
            ),
            const SizedBox(width: 8),
            Text('Simulation mode',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.shieldYellow,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('Tap to open',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.textDim)),
          ],
        ),
      ),
    );
  }
}
