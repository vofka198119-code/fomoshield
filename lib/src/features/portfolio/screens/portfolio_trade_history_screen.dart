// ---------------------------------------------------------------------------
// Portfolio — full Trade History screen. Reached via the "More" button on
// the Trade History widget on the main Portfolio screen. Lists every
// transaction for this portfolio; tapping a row opens the trade detail
// screen. Real-market counterpart of stress_test_trade_history_screen.dart.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/stagger_fade_in.dart';
import '../../../shared/widgets/trade_history_tile.dart';
import '../portfolio_providers.dart';

class PortfolioTradeHistoryScreen extends ConsumerWidget {
  final String portfolioId;

  const PortfolioTradeHistoryScreen({super.key, required this.portfolioId});

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
          'TRADE HISTORY',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: portfolio == null
          ? const Center(child: Text('Portfolio not found'))
          : portfolio.transactions.isEmpty
          ? const Center(child: Text('No trades yet'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: FomoShieldTheme.cardDecoration,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (int i = 0; i < portfolio.transactions.length; i++)
                      Builder(
                        builder: (context) {
                          final tx = portfolio!.transactions[
                              portfolio.transactions.length - 1 - i];
                          return StaggerFadeIn(
                            index: i,
                            child: TradeHistoryTile(
                              symbol: tx.symbol,
                              companyName:
                                  ref
                                      .watch(resolvedCompanyNameProvider(tx.symbol))
                                      .valueOrNull ??
                                  tx.symbol,
                              isBuy: tx.type == TransactionType.buy,
                              totalValue: tx.shares * tx.price,
                              showDivider: i != portfolio.transactions.length - 1,
                              onTap: () => context.push(
                                '/portfolio/$portfolioId/trade-detail',
                                extra: tx,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
