// ---------------------------------------------------------------------------
// Portfolio Analytics Card — inline analytics for main screen (Bible Part 4)
// ---------------------------------------------------------------------------
// Shows compact FS Score gauge + 4 key portfolio metrics in a 2×2 grid,
// plus a "View Full Analytics" action. Designed for _buildSectionCard().
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';

/// Compact portfolio analytics card for embedding in the main screen.
class PortfolioAnalytics extends StatelessWidget {
  final StressTestSession session;
  final String sessionId;

  const PortfolioAnalytics({
    super.key,
    required this.session,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = session.totalValue;
    final pnl = session.profitLoss;
    final pnlPercent = session.profitLossPercent;
    final isPositive = pnl >= 0;
    final cash = session.cash;
    final holdingCount = session.holdings.length;

    // Compute a simple FS Score from psychology profile
    final fsScore = (session.psychologyProfile.compositeScore * 100)
        .round()
        .clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              _buildMiniFsScore(fsScore),
              const SizedBox(width: 16),
              // ── Metrics Grid (2×2) ──
              Expanded(
                child: Column(
                  children: [
                    _metricRow(
                      Icons.account_balance_wallet_rounded,
                      'Total Value',
                      '\$${_fmt(totalValue)}',
                      AppTheme.accentBlue,
                    ),
                    const SizedBox(height: 10),
                    _metricRow(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      'P&L',
                      '${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
                      isPositive
                          ? AppTheme.shieldGreen
                          : AppTheme.dangerRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _metricRow(
                      Icons.percent_rounded,
                      'Holdings',
                      '$holdingCount',
                      AppTheme.shieldYellow,
                    ),
                    const SizedBox(height: 10),
                    _metricRow(
                      Icons.monetization_on_rounded,
                      'Cash',
                      '\$${_fmt(cash)}',
                      AppTheme.textDim,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── View Full Analytics button ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                '/stress-test/$sessionId/analytics',
              ),
              icon: const Icon(Icons.analytics_rounded, size: 16),
              label: Text(
                'View Full Analytics',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: BorderSide(
                  color: AppTheme.accentBlue.withValues(alpha: 0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mini FS Score ring (56px).
  Widget _buildMiniFsScore(int score) {
    final color = score >= 70
        ? AppTheme.shieldGreen
        : score >= 40
            ? AppTheme.shieldYellow
            : AppTheme.dangerRed;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 2.5,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: interNums(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          Text(
            'FS',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDim,
              letterSpacing: 0.8,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDim,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }
}
