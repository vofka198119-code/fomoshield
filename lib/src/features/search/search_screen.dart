import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/cache/logo_providers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/widgets/company_logo.dart';
import '../home/home_providers.dart';
import '../monetization/monetization_modal.dart';
import 'search_counter_provider.dart';
import 'search_provider.dart';

// ---------------------------------------------------------------------------
// Search Screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (q) => ref.read(searchProvider.notifier).onSearchInput(q),
          decoration: InputDecoration(
            hintText: 'Search ticker or company...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
            border: InputBorder.none,
            filled: false,
          ),
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
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
                      color: AppTheme.textDim,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? 'No results',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.textDim,
                        fontSize: 14,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'The API key may be exhausted. Try again shortly.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppTheme.textDim,
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
                  leading: Consumer(
                    builder: (context, ref, _) {
                      final logoAsync = ref.watch(cachedLogoProvider(symbol));
                      final logoUrl = logoAsync.valueOrNull;
                      return CompanyLogo(ticker: symbol, logoUrl: logoUrl);
                    },
                  ),
                  title: Row(
                    children: [
                      Text(
                        symbol,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
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
                      color: AppTheme.textDim,
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
                                  ? AppTheme.accentBlue
                                  : AppTheme.textDim,
                            ),
                            onPressed: () {
                              if (inWatchlist) {
                                ref
                                    .read(watchlistSymbolsProvider.notifier)
                                    .remove(symbol);
                              } else {
                                ref
                                    .read(watchlistSymbolsProvider.notifier)
                                    .add(symbol);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    ref.read(searchProvider.notifier).selectCompany(symbol);

                    // ── Check search counter ───────────────────────
                    final tier = ref.read(subscriptionTierProvider);
                    final canSearch = tier == SubscriptionTier.premium ||
                        tier == SubscriptionTier.admin ||
                        ref.read(searchCounterProvider) > 0;

                    if (!canSearch) {
                      showMonetizationModal(context, ref);
                      return;
                    }

                    // Consume one search (no-op for premium)
                    if (tier != SubscriptionTier.premium &&
                        tier != SubscriptionTier.admin) {
                      await ref.read(searchCounterProvider.notifier).consumeSearch();
                    }

                    if (!context.mounted) return;

                    // Check if navigating from stress-test context
                    final extra = GoRouterState.of(context).extra
                        as Map<String, dynamic>?;
                    final source = extra?['source'] as String?;
                    final sessionId = extra?['sessionId'] as String?;

                    // Debounce 1s guard against double-tap
                    if (source == 'stress-test' && sessionId != null) {
                      ref.read(debouncerProvider).run(() =>
                          context.push(
                              '/stress-test/$sessionId/stock/$symbol'));
                    } else {
                      ref.read(debouncerProvider).run(() =>
                          context.push('/company/$symbol'));
                    }
                  },
                );
              },
            ),
    );
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
    final isEtf = type.toUpperCase() == 'ETF';
    final exchange = symbol.contains('.') ? symbol.split('.').last.toUpperCase() : 'US';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(
          exchange,
          exchange == 'US'
              ? AppTheme.accentBlue
              : exchange == 'L'
                  ? const Color(0xFF9B59B6)
                  : AppTheme.textDim,
        ),
        if (isEtf) ...[
          const SizedBox(width: 4),
          _badge('ETF', AppTheme.shieldYellow),
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
