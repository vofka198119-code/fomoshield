import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../shared/widgets/trade_history_tile.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio — Trade History widget. Real-market counterpart of the Stress
// Test Trade History card, same TradeHistoryTile row, same 5-visible + More
// behavior. Sourced from Portfolio.transactions (real Finnhub-priced fills),
// not the Stress Test engine — the two never share data.
// ---------------------------------------------------------------------------

class PortfolioTradeHistoryWidget extends ConsumerWidget {
  final String portfolioId;

  const PortfolioTradeHistoryWidget({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);
    Portfolio? portfolio;
    for (final p in portfolios) {
      if (p.id == portfolioId) {
        portfolio = p;
        break;
      }
    }
    if (portfolio == null) return const SizedBox.shrink();

    final allTx = portfolio.transactions.reversed.toList();
    if (allTx.isEmpty) return const SizedBox.shrink();
    final displayTx = allTx.take(5).toList();
    final hasMore = allTx.length > 5;

    final l10n = AppLocalizations.of(context)!;
    return WidgetContainer(
      title: l10n.tradeHistoryTitle,
      showFooter: hasMore,
      footerText: l10n.commonMoreCount(allTx.length - 5),
      onTap: hasMore
          ? () => context.push('/portfolio/$portfolioId/trade-history')
          : null,
      children: displayTx
          .map(
            (tx) => TradeHistoryTile(
              symbol: tx.symbol,
              companyName:
                  ref
                      .watch(resolvedCompanyNameProvider(tx.symbol))
                      .valueOrNull ??
                  tx.symbol,
              isBuy: tx.type == TransactionType.buy,
              totalValue: tx.shares * tx.price,
              showDivider: false,
              onTap: () => context.push(
                '/portfolio/$portfolioId/trade-detail',
                extra: tx,
              ),
            ),
          )
          .toList(),
    );
  }
}
