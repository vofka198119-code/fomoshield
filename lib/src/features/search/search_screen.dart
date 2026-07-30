import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/cache/logo_providers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/widgets/company_logo.dart';
import '../home/home_providers.dart';
import '../home/watchlist_limits_provider.dart';
import '../monetization/monetization_modal.dart';
import 'search_counter_provider.dart';
import 'search_provider.dart';
import 'widgets/browse_lane.dart';
import 'widgets/company_mini_card.dart';
import 'recently_viewed_provider.dart';
import 'top_companies_provider.dart';
import '../../core/services/gics_sector_mapper.dart';

// ---------------------------------------------------------------------------
// Search Screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(searchProvider.notifier).onSearchInput('');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    // Set when opened via a specific portfolio's "+" (e.g. Holdings widget)
    // — buying a result then skips company_detail_screen's portfolio picker
    // and trades straight into this portfolio (see contextPortfolioId).
    final routeExtra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final portfolioId = routeExtra?['portfolioId'] as String?;

    // First back press while a query is active just clears search (back to
    // the browse lanes); only a second press with no query actually leaves
    // the screen — matches the standard "search then back" pattern.
    return PopScope(
      canPop: state.query.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _clear();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'SEARCH',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (q) =>
                  ref.read(searchProvider.notifier).onSearchInput(q),
              decoration: InputDecoration(
                hintText: 'Search ticker or company...',
                hintStyle: GoogleFonts.inter(
                  color: ThemeV2.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                filled: false,
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: ThemeV2.textSecondary,
                          size: 20,
                        ),
                        onPressed: _clear,
                      ),
              ),
              style: GoogleFonts.inter(
                color: ThemeV2.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: ThemeV2.primary),
                  )
                : state.query.isEmpty
                ? _BrowseLanes(
                    onTapSymbol: (symbol) => context.push(
                      '/company/$symbol',
                      extra: portfolioId != null
                          ? {'portfolioId': portfolioId}
                          : null,
                    ),
                  )
                : state.results.isEmpty && state.query.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.errorMessage != null
                                ? Icons.cloud_off_rounded
                                : Icons.search_off_rounded,
                            color: ThemeV2.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'No results',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: ThemeV2.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'The API key may be exhausted. Try again shortly.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: ThemeV2.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.results.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final item = state.results[i];
                      final symbol = item['symbol'] as String? ?? '';
                      final name = item['description'] as String? ?? '';
                      final type = item['type'] as String? ?? '';

                      return ListTile(
                        key: ValueKey(symbol),
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ThemeV2.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Consumer(
                            builder: (context, ref, _) {
                              final logoAsync = ref.watch(
                                cachedLogoProvider(symbol),
                              );
                              final logoUrl = logoAsync.valueOrNull;
                              return CompanyLogo(
                                ticker: symbol,
                                logoUrl: logoUrl,
                                radius: 22,
                              );
                            },
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              symbol,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _ExchangeBadge(symbol: symbol, type: type),
                          ],
                        ),
                        subtitle: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ThemeV2.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer(
                              builder: (context, ref, _) {
                                final inWatchlist = ref
                                    .watch(watchlistSymbolsProvider)
                                    .contains(symbol);
                                return IconButton(
                                  icon: Icon(
                                    inWatchlist
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 20,
                                    color: inWatchlist
                                        ? ThemeV2.primary
                                        : ThemeV2.textSecondary,
                                  ),
                                  onPressed: () {
                                    if (inWatchlist) {
                                      ref
                                          .read(
                                            watchlistSymbolsProvider.notifier,
                                          )
                                          .remove(symbol);
                                      return;
                                    }
                                    final maxW = ref.read(
                                      maxWatchlistProvider,
                                    );
                                    final current = ref.read(
                                      watchlistSymbolsProvider,
                                    );
                                    if (current.length >= maxW) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            maxW == 30
                                                ? 'FREE limit: 30 companies. Upgrade to Premium (50).'
                                                : 'Max $maxW companies reached.',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                            ),
                                          ),
                                          backgroundColor: ThemeV2.primary,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }
                                    ref
                                        .read(watchlistSymbolsProvider.notifier)
                                        .add(symbol);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          ref
                              .read(searchProvider.notifier)
                              .selectCompany(symbol);

                          // ── Check search counter ───────────────────────
                          final tier = ref.read(subscriptionTierProvider);
                          final canSearch =
                              tier == SubscriptionTier.premium ||
                              tier == SubscriptionTier.admin ||
                              ref.read(searchCounterProvider) > 0;

                          if (!canSearch) {
                            showMonetizationModal(context, ref);
                            return;
                          }

                          // Consume one search (no-op for premium)
                          if (tier != SubscriptionTier.premium &&
                              tier != SubscriptionTier.admin) {
                            await ref
                                .read(searchCounterProvider.notifier)
                                .consumeSearch();
                          }

                          if (!context.mounted) return;

                          // Check if navigating from stress-test context
                          final extra =
                              GoRouterState.of(context).extra
                                  as Map<String, dynamic>?;
                          final source = extra?['source'] as String?;
                          final sessionId = extra?['sessionId'] as String?;

                          // Debounce 1s guard against double-tap
                          if (source == 'stress-test' && sessionId != null) {
                            ref
                                .read(debouncerProvider)
                                .run(
                                  () => context.push(
                                    '/stress-test/$sessionId/stock/$symbol',
                                  ),
                                );
                          } else {
                            ref
                                .read(debouncerProvider)
                                .run(() => context.push(
                                      '/company/$symbol',
                                      extra: portfolioId != null
                                          ? {'portfolioId': portfolioId}
                                          : null,
                                    ));
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Browse Lanes — shown on the empty-query state. "TOP S&P 500" + per-sector
// lanes are real, backend-ranked data (topCompaniesProvider — quarterly
// Wikipedia+Finnhub job, see scanco-backend's sp500Service.js), grouped
// client-side by real GICS sector via resolveGicsSector(). Each card fetches
// its own live price (see CompanyMiniCard). Recently Viewed is separately
// real — see recently_viewed_provider and company_detail_screen.dart's
// ref.listen that records each view.
// ---------------------------------------------------------------------------

class _BrowseLanes extends ConsumerWidget {
  final void Function(String symbol) onTapSymbol;

  const _BrowseLanes({required this.onTapSymbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final topCompanies = ref.watch(topCompaniesProvider);

    return topCompanies.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: ThemeV2.primary),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Couldn't load top companies. Pull to retry shortly.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: ThemeV2.textSecondary, fontSize: 13),
          ),
        ),
      ),
      data: (companies) {
        if (companies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Top companies list is still being built on the server.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: ThemeV2.textSecondary, fontSize: 13),
              ),
            ),
          );
        }

        final bySector = <GicsSector, List<TopCompanyEntry>>{};
        for (final c in companies) {
          final sector = resolveGicsSector(c.symbol);
          if (sector == null) continue;
          bySector.putIfAbsent(sector, () => []).add(c);
        }

        // One BrowseLane per list item so ListView.separated only builds
        // (and only fires each card's live quote/logo fetch) for lanes
        // actually scrolled into view — building all ~10 lanes eagerly in
        // one Column was firing ~50+ simultaneous network calls on open.
        final lanes = <BrowseLane>[
          BrowseLane(title: 'TOP S&P 500', items: _cards(companies)),
          for (final sector in GicsSector.values)
            if (bySector[sector] != null)
              BrowseLane(
                title: sector.label.toUpperCase(),
                items: _cards(bySector[sector]!),
              ),
          if (recentlyViewed.isNotEmpty)
            BrowseLane(
              title: 'RECENTLY VIEWED',
              items: [
                for (final e in recentlyViewed)
                  CompanyMiniCard(
                    symbol: e.symbol,
                    name: e.name,
                    showPrice: false,
                    onTap: () => onTapSymbol(e.symbol),
                  ),
              ],
            ),
        ];

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: lanes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, i) => lanes[i],
        );
      },
    );
  }

  List<CompanyMiniCard> _cards(List<TopCompanyEntry> data) {
    return [
      for (final c in data)
        CompanyMiniCard(
          symbol: c.symbol,
          name: c.name,
          onTap: () => onTapSymbol(c.symbol),
        ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Exchange & Type Badge
// ---------------------------------------------------------------------------

class _ExchangeBadge extends StatelessWidget {
  final String symbol;
  final String type;

  const _ExchangeBadge({required this.symbol, required this.type});

  @override
  Widget build(BuildContext context) {
    // Finnhub/our local index label ETFs "ETP" (Exchange Traded Product),
    // not "ETF" — checking only 'ETF' silently hid the badge for almost
    // every real fund (confirmed live 2026-07-29: SPY/QQQ/VOO all "ETP").
    final isEtf = type.toUpperCase() == 'ETF' || type.toUpperCase() == 'ETP';
    final exchange = symbol.contains('.')
        ? symbol.split('.').last.toUpperCase()
        : 'US';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(
          exchange,
          exchange == 'US'
              ? ThemeV2.primary
              : exchange == 'L'
              ? const Color(0xFF9B59B6)
              : ThemeV2.textSecondary,
        ),
        if (isEtf) ...[
          const SizedBox(width: 4),
          _badge('ETF', ThemeV2.warning),
        ],
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
