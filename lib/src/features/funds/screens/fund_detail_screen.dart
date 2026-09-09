import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../portfolio/portfolio_providers.dart';
import '../../company_detail/widgets/company_bottom_bar.dart';
import '../../company_detail/widgets/position_section.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_delete_dialog.dart';
import '../widgets/fund_price_header.dart';
import '../widgets/fund_nav_chart.dart';
import '../widgets/fund_key_metrics_card.dart';
import '../widgets/fund_sector_allocation_card.dart';
import '../widgets/fund_holdings_card.dart';
import '../widgets/fund_text_card.dart';
import '../widgets/fund_info_card.dart';

// ---------------------------------------------------------------------------
// Fund Detail — investor-facing view, styled to mirror Company Detail's
// composition/skins (see widgets/ for each card). Live on-demand NAV/holdings
// via fundDetailProvider. Buy/Sell (Phase 2) reuses Company Detail's own
// CompanyBottomBar/PositionSection widgets directly — a fund ticker is just
// a regular Portfolio symbol from the client's point of view (see
// PortfolioOrderEntryScreen's fundId branch for where the money actually
// settles). Hiring (Phase 3) isn't built yet.
// ---------------------------------------------------------------------------

class FundDetailScreen extends ConsumerWidget {
  final String fundId;

  const FundDetailScreen({super.key, required this.fundId});

  // No portfolio picker (unlike Company Detail's own _openOrderEntry) —
  // Portfolio is capped at one slot per user (maxPortfoliosProvider), so
  // that branch of Company Detail's logic is currently unreachable there
  // too; this mirrors only the reachable path.
  void _openOrderEntry(
    BuildContext context,
    WidgetRef ref,
    FundDetail fund,
    String type,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final portfolios = ref.read(portfoliosProvider);
    if (portfolios.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.companyDetailNoPortfolios)));
      return;
    }
    context.push(
      '/portfolio/${portfolios.first.id}/stock/${fund.ticker}/order',
      extra: {
        'type': type,
        'price': fund.navPerUnit,
        'companyName': fund.name,
        'fundId': fund.id,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: fundAsync.maybeWhen(
          data: (fund) => themedHeaderText(
            fund.ticker,
            palette,
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          fundAsync.maybeWhen(
            data: (fund) =>
                fund.headUserId == ref.watch(currentUserProvider)?.id
                ? IconButton(
                    icon: Icon(Icons.delete_outline, color: palette.textBody),
                    onPressed: () =>
                        showFundDeleteFlow(context, ref, fund.id, palette),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: fundAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (fund) => Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: palette.accentPrimary,
                  onRefresh: () async =>
                      ref.invalidate(fundDetailProvider(fundId)),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: [
                      // PriceHeader wraps its own two cards in horizontal:16
                      // padding already (see price_header.dart) — no extra
                      // wrap here, or it'd double up like every other card
                      // below.
                      FundPriceHeader(fund: fund, palette: palette),
                      const SizedBox(height: 16),
                      _padded(FundNavChart(fund: fund, palette: palette)),
                      const SizedBox(height: 16),
                      // PositionSection also wraps itself in horizontal:16
                      // padding already (see position_section.dart) — same
                      // reason as FundPriceHeader above.
                      PositionSection(
                        symbol: fund.ticker,
                        price: fund.navPerUnit,
                        palette: palette,
                      ),
                      const SizedBox(height: 16),
                      _padded(FundKeyMetricsCard(fund: fund, palette: palette)),
                      const SizedBox(height: 16),
                      _padded(
                        FundSectorAllocationCard(fund: fund, palette: palette),
                      ),
                      const SizedBox(height: 16),
                      _padded(FundHoldingsCard(fund: fund, palette: palette)),
                      const SizedBox(height: 16),
                      if (fund.strategy != null &&
                          fund.strategy!.isNotEmpty) ...[
                        _padded(
                          FundTextCard(
                            title: l10n.etfFundDetailStrategyTitle,
                            body: fund.strategy!,
                            palette: palette,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (fund.description != null &&
                          fund.description!.isNotEmpty) ...[
                        _padded(
                          FundTextCard(
                            title: l10n.etfFundDetailDescriptionTitle,
                            body: fund.description!,
                            palette: palette,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _padded(FundInfoCard(fund: fund, palette: palette)),
                    ],
                  ),
                ),
              ),
              CompanyBottomBar(
                price: fund.navPerUnit,
                isUp: true,
                onBuy: () => _openOrderEntry(context, ref, fund, 'buy'),
                onSell: () => _openOrderEntry(context, ref, fund, 'sell'),
                palette: palette,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Company Detail's own convention: the scroll container carries no
  // horizontal padding, each card supplies its own — PriceHeader already
  // does internally, everything else needs this wrapper.
  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
