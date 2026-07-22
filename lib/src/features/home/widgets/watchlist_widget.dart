import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Widget — Compact (Revolut style)
// ---------------------------------------------------------------------------

class WatchlistWidget extends ConsumerWidget {
  const WatchlistWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistSymbols = ref.watch(watchlistSymbolsProvider);
    final watchlistQuotesAsync = ref.watch(watchlistQuotesProvider);

    if (watchlistSymbols.isEmpty) {
      return _emptyContainer(context);
    }

    return watchlistQuotesAsync.when(
      loading: () => _loadingContainer(context),
      error: (err, _) {
        debugPrint('❌ WatchlistWidget error: $err');
        return _emptyContainer(context);
      },
      data: (companies) {
        if (companies.isEmpty) return _emptyContainer(context);

        // Show only first 2
        final preview = companies.take(2).toList();

        return WidgetContainer(
          title: 'WATCHLIST',
          onTap: () => context.push('/watchlist'),
          showFooter: companies.length > 2,
          children: preview.map((c) => _WatchlistTile(data: c)).toList(),
        );
      },
    );
  }

  Widget _emptyContainer(BuildContext context) {
    return WidgetContainer(
      title: 'WATCHLIST',
      onTap: () => context.push('/watchlist'),
      showFooter: false,
      emptyText: 'Nothing here yet',
    );
  }

  Widget _loadingContainer(BuildContext context) {
    return WidgetContainer(
      title: 'WATCHLIST',
      onTap: () => context.push('/watchlist'),
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ThemeV2.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Watchlist Tile — Compact version (no accordion)
// ---------------------------------------------------------------------------

class _WatchlistTile extends ConsumerWidget {
  final Map<String, dynamic> data;
  const _WatchlistTile({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final change = (data['change'] as num?)?.toDouble() ?? 0;
    final symbol = data['symbol'] as String? ?? '';
    final name = data['name'] as String? ?? '';
    final weburl = data['weburl'] as String?;
    final domain = CompanyLogo.extractDomain(weburl);
    final logoUrl = data['logoUrl'] as String?;
    final sectorAsync = ref.watch(cachedGicsSectorProvider(symbol));

    return InkWell(
      onTap: () => context.push('/company/$symbol'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Company Logo (cached)
            CompanyLogo(ticker: symbol, logoUrl: logoUrl, domain: domain),
            const SizedBox(width: 12),
            // Name + Symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sectorAsync.when(
                      data: (s) => s?.label ?? symbol,
                      loading: () => symbol,
                      error: (_, _) => symbol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Price + Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: interNums(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: interNums(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: change >= 0
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

