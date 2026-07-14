import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Summary Widget — performance card
// ---------------------------------------------------------------------------

class PortfolioSummaryWidget extends StatelessWidget {
  final PortfolioPerformance? performance;
  final bool isLoading;
  final bool hasError;

  const PortfolioSummaryWidget({
    super.key,
    this.performance,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || hasError || performance == null) {
      return WidgetContainer(
        title: 'PORTFOLIO SUMMARY',
        onTap: () {},
        showFooter: false,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final perf = performance!;
    final isUp = perf.pnl >= 0;
    final c = isUp ? ThemeV2.success : ThemeV2.loss;

    return WidgetContainer(
      title: 'PORTFOLIO SUMMARY',
      onTap: () {},
      showFooter: false,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Labels row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Value',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                  Text(
                    'P&L',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // ── Values row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${perf.currentValue.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ThemeV2.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isUp ? '+' : ''}\$${perf.pnl.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: c,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${isUp ? '+' : ''}${perf.pnlPercent.toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: c.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Divider ──
              Container(height: 1, color: ThemeV2.divider),
              const SizedBox(height: 12),
              // ── Bottom stats row ──
              Row(
                children: [
                  _stat(
                    'Invested',
                    '\$${perf.totalInvested.toStringAsFixed(2)}',
                  ),
                  _stat('Cash', '\$${perf.cash.toStringAsFixed(2)}'),
                  _stat('Holdings', '${perf.holdings.length}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ThemeV2.textPrimary,
          ),
        ),
      ],
    ),
  );
}

