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
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/stagger_fade_in.dart';
import '../../../shared/widgets/trade_history_tile.dart';
import '../portfolio_providers.dart';

class PortfolioTradeHistoryScreen extends ConsumerWidget {
  final String portfolioId;

  const PortfolioTradeHistoryScreen({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final portfolios = ref.watch(portfoliosProvider);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
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
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.tradeHistoryTitle,
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
        child: portfolio == null
            ? Center(
                child: Text(
                  l10n.portfolioTradeHistoryScreenPortfolioNotFound,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : portfolio.transactions.isEmpty
            ? Center(
                child: Text(
                  l10n.portfolioTradeHistoryScreenNoTradesYet,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: CardFrame(
                  showTopBar: false,
                  padding: EdgeInsets.zero,
                  decoration: FomoShieldTheme.cardDecoration,
                  palette: palette,
                  child: Column(
                    children: [
                      for (int i = 0; i < portfolio.transactions.length; i++)
                        Builder(
                          builder: (context) {
                            final tx =
                                portfolio!.transactions[portfolio
                                        .transactions
                                        .length -
                                    1 -
                                    i];
                            return StaggerFadeIn(
                              index: i,
                              child: TradeHistoryTile(
                                symbol: tx.symbol,
                                companyName:
                                    ref
                                        .watch(
                                          resolvedCompanyNameProvider(
                                            tx.symbol,
                                          ),
                                        )
                                        .valueOrNull ??
                                    tx.symbol,
                                isBuy: tx.type == TransactionType.buy,
                                totalValue: tx.shares * tx.price,
                                showDivider:
                                    i != portfolio.transactions.length - 1,
                                palette: palette,
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
      ),
    );
  }
}
