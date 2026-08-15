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
import 'widgets/exchange_badge.dart';
import 'widgets/search_browse_lanes.dart';

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
    final stressTestSource = routeExtra?['source'] as String?;
    final stressTestSessionId = routeExtra?['sessionId'] as String?;

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
                  ? SearchBrowseLanes(
                      onTapSymbol: (symbol) {
                        if (stressTestSource == 'stress-test' &&
                            stressTestSessionId != null) {
                          context.push(
                            '/stress-test/$stressTestSessionId/stock/$symbol',
                          );
                          return;
                        }
                        context.push(
                          '/company/$symbol',
                          extra: portfolioId != null
                              ? {'portfolioId': portfolioId}
                              : null,
                        );
                      },
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
                              ExchangeBadge(symbol: symbol, type: type),
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
                                          .read(
                                            watchlistSymbolsProvider.notifier,
                                          )
                                          .add(symbol);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
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
                                  .run(
                                    () => context.push(
                                      '/company/$symbol',
                                      extra: portfolioId != null
                                          ? {'portfolioId': portfolioId}
                                          : null,
                                    ),
                                  );
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
