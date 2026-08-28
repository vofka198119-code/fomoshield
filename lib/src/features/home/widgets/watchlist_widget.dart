import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
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
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    if (watchlistSymbols.isEmpty) {
      return _emptyContainer(context, palette);
    }

    // Show only first 2 — small enough to live-fetch (see _WatchlistTile).
    final preview = watchlistSymbols.take(2).toList();

    return WidgetContainer(
      title: AppLocalizations.of(context)!.watchlistTitle,
      onTap: () => context.push('/watchlist'),
      showFooter: watchlistSymbols.length > 2,
      palette: palette,
      children: preview
          .map((s) => _WatchlistTile(symbol: s, palette: palette))
          .toList(),
    );
  }

  Widget _emptyContainer(BuildContext context, AppPalette palette) {
    return WidgetContainer(
      title: AppLocalizations.of(context)!.watchlistTitle,
      onTap: () => context.push('/watchlist'),
      showFooter: false,
      emptyText: AppLocalizations.of(context)!.watchlistEmpty,
      palette: palette,
    );
  }
}

// ---------------------------------------------------------------------------
// Watchlist Tile — Compact version (no accordion), no live price. Only ever
// renders the first 2 symbols (see WatchlistWidget.build's .take(2)) — a
// small, bounded, always-visible set, same reasoning that already applies
// to Portfolio Holdings (see feedback_finnhub_cost_at_scale memory): live
// icon/name lookups here don't scale with the catalog, just this one
// user's own list, and /api/v1/icons is cheap and fast (server-side
// cached, never blocks on a live Finnhub call).
// ---------------------------------------------------------------------------

class _WatchlistTile extends ConsumerWidget {
  final String symbol;
  final AppPalette palette;
  const _WatchlistTile({required this.symbol, required this.palette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(cachedLogoProvider(symbol)).valueOrNull;
    final resolvedName = ref.watch(resolvedCompanyNameProvider(symbol));
    final name = resolvedName.valueOrNull ?? symbol;
    final sector = resolveGicsSector(symbol, companyName: name);

    return InkWell(
      onTap: () => context.push('/company/$symbol'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Company Logo (cached) — thin accent ring around it
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.accentPrimary, width: 1.5),
              ),
              child: CompanyLogo(ticker: symbol, logoUrl: logoUrl),
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
                      color: palette.textHeader,
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
                      // Under Luxury, palette.textBody (Muted Silver) read
                      // as flat gray — same fix as Market Clock's shortDetail,
                      // brighten to white instead. Standard is untouched.
                      color: palette.titleGradient != null
                          ? Colors.white.withValues(alpha: 0.85)
                          : palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textBody,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
