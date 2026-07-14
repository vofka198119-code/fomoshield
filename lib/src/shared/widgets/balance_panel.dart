// ---------------------------------------------------------------------------
// Balance Panel Widget
// ---------------------------------------------------------------------------
// Shows total portfolio value, unrealized P&L ($ and %), and available cash.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';

class BalancePanel extends StatelessWidget {
  final StressTestSession session;

  const BalancePanel({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? ThemeV2.textSecondary : Colors.black54;
    final totalValue = session.totalValue;
    final pnl = session.profitLoss;
    final pnlPercent = session.profitLossPercent;
    final isPositive = pnl >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Total Value
          Expanded(
            child: _MetricCard(
              label: 'Balance',
              value: '\$${_fmt(totalValue)}',
              valueColor: textColor,
              subTextColor: subTextColor,
            ),
          ),
          Container(width: 1, height: 48, color: isDark ? Colors.white12 : Colors.black12),
          // P&L
          Expanded(
            child: _MetricCard(
              label: 'P&L',
              value: '${isPositive ? '+' : ''}\$${_fmt(pnl.abs())}',
              valueColor: isPositive ? ThemeV2.success : ThemeV2.loss,
              subText: '${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
              subTextColor: isPositive ? ThemeV2.success : ThemeV2.loss,
            ),
          ),
          Container(width: 1, height: 48, color: isDark ? Colors.white12 : Colors.black12),
          // Cash
          Expanded(
            child: _MetricCard(
              label: 'Cash',
              value: '\$${_fmt(session.cash)}',
              valueColor: textColor,
              subTextColor: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? subText;
  final Color subTextColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.subText,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: interNums(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        if (subText != null)
          Text(
            subText!,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
      ],
    );
  }
}

