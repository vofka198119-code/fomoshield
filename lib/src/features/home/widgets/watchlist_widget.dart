import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../home_providers.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Watchlist Widget — Compact
// ---------------------------------------------------------------------------

class WatchlistWidget extends ConsumerWidget {
  const WatchlistWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistSymbols = ref.watch(watchlistSymbolsProvider);

    if (watchlistSymbols.isEmpty) {
      return _emptyContainer(context);
    }

    // Show only first 2 — no live fetch involved, so no loading/error state
    // to branch on (see cachedLogoEntryProvider doc comment).
    final preview = watchlistSymbols.take(2).toList();

    return WidgetContainer(
      title: AppLocalizations.of(context)!.watchlistTitle,
      onTap: () => context.push('/watchlist'),
      showFooter: watchlistSymbols.length > 2,
      children: preview.map((s) => _WatchlistTile(symbol: s)).toList(),
    );
  }

  Widget _emptyContainer(BuildContext context) {
    return WidgetContainer(
      title: AppLocalizations.of(context)!.watchlistTitle,
      onTap: () => context.push('/watchlist'),
      showFooter: false,
      emptyText: AppLocalizations.of(context)!.watchlistEmpty,
    );
  }
}

// ---------------------------------------------------------------------------
// Watchlist Tile — Compact version (no accordion), no live price (see
// cachedLogoEntryProvider doc comment: no Finnhub call ever from this tile).
// ---------------------------------------------------------------------------

class _WatchlistTile extends ConsumerWidget {
  final String symbol;
  const _WatchlistTile({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoEntry = ref.watch(cachedLogoEntryProvider(symbol)).valueOrNull;
    final name = logoEntry?.companyName.isNotEmpty == true
        ? logoEntry!.companyName
        : symbol;
    final sector = resolveGicsSector(
      symbol,
      companyName: logoEntry?.companyName,
    );

    return InkWell(
      onTap: () => context.push('/company/$symbol'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Company Logo (cached) — thin brand-green ring around it
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ThemeV2.primary, width: 1.5),
              ),
              child: CompanyLogo(
                ticker: symbol,
                logoUrl: logoEntry?.logoUrl,
                domain: logoEntry?.domain,
              ),
            ),
            const SizedBox(width: 12),
            // Name + Sector
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
                    sector?.label ?? symbol,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: ThemeV2.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
