// ---------------------------------------------------------------------------
// Portfolio — single trade detail screen. Reached by tapping a row on the
// Trade History screen. Shows how the trade was executed (resolved from the
// originating Order via Transaction.orderId — falls back to "Market" for
// transactions recorded before that link existed), size, price, and
// realized P&L. Real-market counterpart of stress_test_trade_detail_screen.dart.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../orders/order_model.dart';
import '../../orders/order_provider.dart';
import '../portfolio_providers.dart';

class PortfolioTradeDetailScreen extends ConsumerWidget {
  final String portfolioId;
  final Transaction? transaction;

  const PortfolioTradeDetailScreen({
    super.key,
    required this.portfolioId,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = transaction;
    final orders = ref.watch(ordersProvider);
    final order = tx?.orderId == null
        ? null
        : orders.where((o) => o.orderId == tx!.orderId).firstOrNull;

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
      body: tx == null
          ? const Center(child: Text('Trade not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _TradeDetailCard(tx: tx, order: order),
            ),
    );
  }
}

class _TradeDetailCard extends ConsumerWidget {
  final Transaction tx;
  final Order? order;

  const _TradeDetailCard({required this.tx, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBuy = tx.type == TransactionType.buy;
    final accent = isBuy ? ThemeV2.success : ThemeV2.loss;
    final companyName =
        ref.watch(resolvedCompanyNameProvider(tx.symbol)).valueOrNull ??
        tx.symbol;

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
                  final logoAsync = ref.watch(cachedLogoProvider(tx.symbol));
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
                            ticker: tx.symbol,
                            logoUrl: url,
                            radius: 23,
                          ),
                          error: (_, _) =>
                              CompanyLogo(ticker: tx.symbol, radius: 23),
                          loading: () =>
                              CompanyLogo(ticker: tx.symbol, radius: 23),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    Text(
                      tx.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBuy ? 'BUY' : 'SELL',
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
          _DetailRow(label: 'Order Type', value: order?.type.label ?? 'Market'),
          if (order?.limitPrice != null)
            _DetailRow(
              label: 'Limit Price',
              value: '\$${order!.limitPrice!.toStringAsFixed(2)}',
            ),
          if (order?.stopPrice != null)
            _DetailRow(
              label: 'Stop Price',
              value: '\$${order!.stopPrice!.toStringAsFixed(2)}',
            ),
          _DetailRow(
            label: isBuy ? 'Shares Bought' : 'Shares Sold',
            value: tx.shares.toStringAsFixed(4),
          ),
          _DetailRow(
            label: 'Price per Share',
            value: '\$${tx.price.toStringAsFixed(2)}',
          ),
          _DetailRow(
            label: 'Total Value',
            value: '\$${(tx.shares * tx.price).toStringAsFixed(2)}',
          ),
          _DetailRow(label: 'Date', value: _formatDate(tx.date)),
          if (tx.realizedPnl != null)
            _DetailRow(
              label: 'Realized P&L',
              value:
                  '${tx.realizedPnl! >= 0 ? '+' : '-'}\$${tx.realizedPnl!.abs().toStringAsFixed(2)}',
              valueColor: tx.realizedPnl! >= 0 ? ThemeV2.success : ThemeV2.loss,
              isLast: true,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
