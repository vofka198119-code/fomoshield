import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import 'stock_detail_helpers.dart';

// ---------------------------------------------------------------------------
// Stress Test "Your Position" card — split out of the old monolithic
// stock_detail_screen.dart, restyled to the FomoShieldTheme card standard
// (was ThemeV2.surface + ad-hoc shadow). Content/logic unchanged.
// ---------------------------------------------------------------------------

class StockPositionCard extends StatelessWidget {
  final double shares;
  final double avgPrice;
  final double pnl;

  const StockPositionCard({
    super.key,
    required this.shares,
    required this.avgPrice,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final isProfitPositive = pnl >= 0;
    final costBasis = shares * avgPrice;
    final positionValue = costBasis + pnl;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR POSITION', style: FomoShieldTheme.cardTitle()),
          const Divider(height: 20, color: Color(0x0F000000)),
          Row(
            children: [
              Expanded(
                child: _metric(label: 'VALUE', value: fmtFullCurrency(positionValue)),
              ),
              Expanded(
                child: _metric(
                  label: 'P&L',
                  value: '${isProfitPositive ? '+' : ''}${fmtFullCurrency(pnl.abs())}',
                  valueColor: isProfitPositive ? ThemeV2.success : ThemeV2.loss,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metric(label: 'SHARES', value: shares.toStringAsFixed(2)),
              ),
              Expanded(
                child: _metric(label: 'AVG PRICE', value: fmtFullCurrency(avgPrice)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric({required String label, required String value, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeV2.caption.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ThemeV2.title.copyWith(
            color: valueColor ?? ThemeV2.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
