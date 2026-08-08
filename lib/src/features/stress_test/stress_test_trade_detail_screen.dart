// ---------------------------------------------------------------------------
// Stress Test — single trade detail screen. Reached by tapping a row on the
// Trade History screen. Shows how the trade was executed, size, price, and
// realized P&L. The Stress Test engine never queues limit/stop orders — every
// StressTestTrade fills instantly at the simulated market price — so
// execution type is always "Market" here (see trades_engine.dart).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/widgets/company_logo.dart';
import '../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import 'stress_test_models.dart';

class StressTestTradeDetailScreen extends StatelessWidget {
  final String sessionId;
  final StressTestTrade? trade;

  const StressTestTradeDetailScreen({
    super.key,
    required this.sessionId,
    required this.trade,
  });

  @override
  Widget build(BuildContext context) {
    final t = trade;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'TRADE DETAIL',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: t == null
          ? const Center(child: Text('Trade not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _TradeDetailCard(trade: t),
            ),
    );
  }
}

class _TradeDetailCard extends ConsumerWidget {
  final StressTestTrade trade;

  const _TradeDetailCard({required this.trade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = trade.isBuy ? ThemeV2.success : ThemeV2.loss;
    final companyName = resolveStressTestCompanyName(ref, trade.symbol);

    return Container(
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final logoAsync = ref.watch(cachedLogoProvider(trade.symbol));
                  return Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: logoAsync.when(
                          data: (url) => CompanyLogo(
                            ticker: trade.symbol,
                            logoUrl: url,
                            radius: 23,
                          ),
                          error: (_, _) =>
                              CompanyLogo(ticker: trade.symbol, radius: 23),
                          loading: () =>
                              CompanyLogo(ticker: trade.symbol, radius: 23),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    Text(
                      trade.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trade.isBuy ? 'BUY' : 'SELL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 16),
          _DetailRow(label: 'Order Type', value: 'Market'),
          _DetailRow(
            label: trade.isBuy ? 'Shares Bought' : 'Shares Sold',
            value: trade.shares.toStringAsFixed(4),
          ),
          _DetailRow(
            label: 'Price per Share',
            value: '\$${trade.price.toStringAsFixed(2)}',
          ),
          _DetailRow(
            label: 'Total Value',
            value: '\$${(trade.shares * trade.price).toStringAsFixed(2)}',
          ),
          _DetailRow(
            label: 'Date',
            value: _formatDate(trade.date),
          ),
          if (trade.realizedPnl != null)
            _DetailRow(
              label: 'Realized P&L',
              value:
                  '${trade.realizedPnl! >= 0 ? '+' : '-'}\$${trade.realizedPnl!.abs().toStringAsFixed(2)}',
              valueColor: trade.realizedPnl! >= 0
                  ? ThemeV2.success
                  : ThemeV2.loss,
              isLast: true,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeV2.textSecondary,
            ),
          ),
          Text(
            value,
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? ThemeV2.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
