// ---------------------------------------------------------------------------
// Stress Test Holdings Widget
// ---------------------------------------------------------------------------
// Shows holdings with company logos, current price, P&L per position.
// Shows first 4 by default + "MORE" button to expand.
// Includes BUY/SELL inline buttons per position.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/cache/logo_providers.dart';
import '../../features/stress_test/stress_test_models.dart';
import 'company_logo.dart';

class StressHoldingsWidget extends ConsumerStatefulWidget {
  final StressTestSession session;
  final void Function(String symbol, bool isBuy) onBuySell;

  const StressHoldingsWidget({
    super.key,
    required this.session,
    required this.onBuySell,
  });

  @override
  ConsumerState<StressHoldingsWidget> createState() => _StressHoldingsWidgetState();
}

class _StressHoldingsWidgetState extends ConsumerState<StressHoldingsWidget> {
  bool _showAll = false;
  static const int _initialCount = 4;

  @override
  Widget build(BuildContext context) {
    final holdings = widget.session.holdings;
    if (holdings.isEmpty) return const SizedBox.shrink();

    final bgColor = AppTheme.card;
    final textColor = AppTheme.textPrimary;
    final subTextColor = AppTheme.textDim;

    final displayList = _showAll ? holdings : holdings.take(_initialCount).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HOLDINGS',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentBlue,
                  letterSpacing: 1.2,
                ),
              ),
              if (holdings.length > _initialCount)
                TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _showAll ? 'Less' : 'More (${holdings.length - _initialCount})',
                    style: interNums(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.shieldGreen,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8E5DF)),
          const SizedBox(height: 12),
          // Holdings list
          ...displayList.map((h) => _HoldingRow(
            holding: h,
            session: widget.session,
            onBuySell: widget.onBuySell,
            textColor: textColor,
            subTextColor: subTextColor,
          )),
        ],
      ),
    );
  }
}

class _HoldingRow extends ConsumerWidget {
  final StressTestHolding holding;
  final StressTestSession session;
  final void Function(String symbol, bool isBuy) onBuySell;
  final Color textColor;
  final Color subTextColor;

  const _HoldingRow({
    required this.holding,
    required this.session,
    required this.onBuySell,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPrice = session.currentPrices[holding.symbol] ?? holding.entryPrice;
    final positionValue = holding.shares * currentPrice;
    final costBasis = holding.shares * holding.avgCost;
    final pnl = positionValue - costBasis;
    final pnlPercent = costBasis > 0 ? (pnl / costBasis) * 100 : 0.0;
    final isPositive = pnl >= 0;

    final logoAsync = ref.watch(cachedLogoProvider(holding.symbol));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          // Logo
          SizedBox(
            width: 36,
            height: 36,
            child: logoAsync.when(
              data: (url) => CompanyLogo(
                ticker: holding.symbol,
                logoUrl: url,
                radius: 16,
              ),
              error: (_, _) => CompanyLogo(ticker: holding.symbol, radius: 16),
              loading: () => CompanyLogo(ticker: holding.symbol, radius: 16),
            ),
          ),
          const SizedBox(width: 10),
          // Symbol + shares
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  '${holding.shares.toStringAsFixed(2)} shares @ \$${currentPrice.toStringAsFixed(2)}',
                  style: interNums(
                    fontSize: 11,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          // P&L
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${positionValue.toStringAsFixed(0)}',
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
                  style: interNums(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppTheme.shieldGreen : AppTheme.dangerRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // BUY / SELL buttons
          _TradeButton(label: 'B', color: const Color(0xFF1B5E20), onTap: () => onBuySell(holding.symbol, true)),
          const SizedBox(width: 6),
          _TradeButton(label: 'S', color: const Color(0xFF7B1D1D), onTap: () => onBuySell(holding.symbol, false)),
        ],
      ),
    );
  }
}

class _TradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TradeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
