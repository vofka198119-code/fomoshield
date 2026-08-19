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
import '../../l10n/gen/app_localizations.dart';

String _searchErrorText(AppLocalizations l10n, SearchErrorType type) {
  switch (type) {
    case SearchErrorType.connectionTimeout:
      return l10n.searchErrorConnectionTimeout;
    case SearchErrorType.serverNotResponding:
      return l10n.searchErrorServerNotResponding;
    case SearchErrorType.noInternet:
      return l10n.searchErrorNoInternet;
    case SearchErrorType.rateLimited:
      return l10n.searchErrorRateLimited;
    case SearchErrorType.generic:
      return l10n.searchErrorGeneric;
  }
}

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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.searchTitle,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeV2.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: SafeArea(
          bottom: true,
          top: false,
          left: false,
          right: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (q) =>
                      ref.read(searchProvider.notifier).onSearchInput(q),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
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
                        child: CircularProgressIndicator(
                          color: ThemeV2.primary,
                        ),
                      )
                    : state.query.isEmpty
                    ? SearchBrowseLanes(
                        onTapSymbol: (symbol) {
                          // Same check+consume+navigate-inside-debounce
                          // sequence as the typed-result ListTile below —
                          // browsing a lane counts as a search too, so it
                          // shares the same counter and double-tap guard.
                          ref.read(debouncerProvider).run(() async {
                            final tier = ref.read(subscriptionTierProvider);
                            final canSearch =
                                tier == SubscriptionTier.premium ||
                                tier == SubscriptionTier.admin ||
                                ref.read(searchCounterProvider) > 0;

                            if (!canSearch) {
                              if (context.mounted) {
                                showMonetizationModal(context, ref);
                              }
                              return;
                            }

                            if (tier != SubscriptionTier.premium &&
                                tier != SubscriptionTier.admin) {
                              await ref
                                  .read(searchCounterProvider.notifier)
                                  .consumeSearch();
                            }

                            if (!context.mounted) return;

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
                          });
                        },
                      )
                    : state.query.length < 2
                    ? const SizedBox.shrink()
                    : state.results.isEmpty && state.query.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.errorType != null
                                    ? Icons.cloud_off_rounded
                                    : Icons.search_off_rounded,
                                color: ThemeV2.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.errorType != null
                                    ? _searchErrorText(l10n, state.errorType!)
                                    : l10n.searchNoResults,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: ThemeV2.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              if (state.errorType != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  l10n.searchApiExhausted,
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
                                                watchlistSymbolsProvider
                                                    .notifier,
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
                                                    ? l10n.watchlistLimitFree
                                                    : l10n.watchlistLimitMax(
                                                        maxW,
                                                      ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              backgroundColor: ThemeV2.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
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
                            onTap: () {
                              // Whole check+consume+navigate sequence runs
                              // inside the debounce so a fast double-tap only
                              // executes it once — previously the counter
                              // check/consume ran synchronously on every tap
                              // while only navigation was debounced, so a
                              // double-tap could burn 2 searches for 1 visit.
                              ref.read(debouncerProvider).run(() async {
                                final tier = ref.read(subscriptionTierProvider);
                                final canSearch =
                                    tier == SubscriptionTier.premium ||
                                    tier == SubscriptionTier.admin ||
                                    ref.read(searchCounterProvider) > 0;

                                if (!canSearch) {
                                  if (context.mounted) {
                                    showMonetizationModal(context, ref);
                                  }
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
                                final sessionId =
                                    extra?['sessionId'] as String?;

                                if (source == 'stress-test' &&
                                    sessionId != null) {
                                  context.push(
                                    '/stress-test/$sessionId/stock/$symbol',
                                  );
                                } else {
                                  context.push(
                                    '/company/$symbol',
                                    extra: portfolioId != null
                                        ? {'portfolioId': portfolioId}
                                        : null,
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
