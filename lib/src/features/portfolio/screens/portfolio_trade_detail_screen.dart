// ---------------------------------------------------------------------------
// Portfolio — single trade detail screen. Reached by tapping a row on the
// Trade History screen. Shows how the trade was executed (resolved from the
// originating Order via Transaction.orderId — falls back to "Market" for
// transactions recorded before that link existed), size, price, and
// realized P&L. Real-market counterpart of stress_test_trade_detail_screen.dart.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../orders/order_model.dart';
import '../../orders/order_provider.dart';
import '../portfolio_providers.dart';
import '../../../l10n/gen/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final tx = transaction;
    final orders = ref.watch(ordersProvider);
    final order = tx?.orderId == null
        ? null
        : orders.where((o) => o.orderId == tx!.orderId).firstOrNull;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.tradeDetailTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: tx == null
            ? Center(
                child: Text(
                  l10n.tradeNotFound,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _TradeDetailCard(tx: tx, order: order, palette: palette),
              ),
      ),
    );
  }
}

class _TradeDetailCard extends ConsumerWidget {
  final Transaction tx;
  final Order? order;
  final AppPalette palette;

  const _TradeDetailCard({
    required this.tx,
    required this.order,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isBuy = tx.type == TransactionType.buy;
    final accent = isBuy ? ThemeV2.success : ThemeV2.loss;
    final companyName =
        ref.watch(resolvedCompanyNameProvider(tx.symbol)).valueOrNull ??
        tx.symbol;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      padding: const EdgeInsets.all(22),
      palette: palette,
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
                        color: palette.textHeader,
                      ),
                    ),
                    Text(
                      tx.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: palette.textBody,
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
                  isBuy ? l10n.tradeBuy : l10n.tradeSell,
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
          themedDivider(palette, indent: 0, endIndent: 0, height: 1),
          const SizedBox(height: 16),
          _DetailRow(
            label: l10n.tradeOrderTypeLabel,
            value: order?.type.label ?? l10n.tradeMarketType,
            palette: palette,
          ),
          if (order?.limitPrice != null)
            _DetailRow(
              label: l10n.tradeLimitPriceLabel,
              value: formatUsd(order!.limitPrice!),
              palette: palette,
            ),
          if (order?.stopPrice != null)
            _DetailRow(
              label: l10n.tradeStopPriceLabel,
              value: formatUsd(order!.stopPrice!),
              palette: palette,
            ),
          _DetailRow(
            label: isBuy ? l10n.tradeSharesBoughtLabel : l10n.tradeSharesSoldLabel,
            value: tx.shares.toStringAsFixed(4),
            palette: palette,
          ),
          _DetailRow(
            label: l10n.tradePricePerShareLabel,
            value: formatUsd(tx.price),
            palette: palette,
          ),
          _DetailRow(
            label: l10n.tradeTotalValueLabel,
            value: formatUsd(tx.shares * tx.price),
            palette: palette,
          ),
          if (tx.fee > 0)
            _DetailRow(
              label: l10n.tradeCommissionLabel,
              value: formatUsd(tx.fee),
              palette: palette,
            ),
          _DetailRow(
            label: l10n.tradeDateLabel,
            value: _formatDate(context, tx.date),
            palette: palette,
          ),
          if (tx.realizedPnl != null)
            _DetailRow(
              label: l10n.tradeRealizedPnlLabel,
              value: formatUsdSigned(tx.realizedPnl!),
              valueColor: tx.realizedPnl! >= 0 ? ThemeV2.success : ThemeV2.loss,
              isLast: true,
              palette: palette,
            ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).add_Hm().format(d);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;
  final AppPalette palette;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.palette,
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
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          valueColor != null
              ? Text(
                  value,
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                )
              : themedPriceText(
                  value,
                  palette,
                  interNums(fontSize: 14, fontWeight: FontWeight.w600),
                ),
        ],
      ),
    );
  }
}
