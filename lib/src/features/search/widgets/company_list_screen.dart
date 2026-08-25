import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/company_logo.dart';
import '../top_companies_provider.dart';

// ---------------------------------------------------------------------------
// CompanyListScreen — full list behind a lane's "see all"
// ---------------------------------------------------------------------------
// A real pushed route (GoRoute '/search/company-list'), not a modal bottom
// sheet — the sheet version kept the whole Search screen (with its own
// ~10 animated lanes, each independently fetching logos) alive and
// composited underneath it, which read as visible jank/staggering on open
// ("slideshow" — confirmed on-device 2026-08-22, not fixed by widening the
// network concurrency limiter alone). A pushed route replaces the screen
// instead, same pattern as WatchlistFullScreen's own "see all".
//
// Same no-Finnhub-per-row rule as everywhere else on this screen: rows read
// name from the entry the caller already has (top_companies_provider.dart's
// backend-ranked list) and logo/sector from the permanent local cache only
// (quickLogoProvider/quickGicsSectorProvider — cache-only, never fetching;
// switched from the live-fetching cachedLogoProvider/cachedGicsSectorProvider
// 2026-08-22, a confirmed bug that contradicted this very comment) — price
// only shows once the user taps through to Company Detail.
// ---------------------------------------------------------------------------

class CompanyListScreen extends ConsumerWidget {
  final String title;
  final List<TopCompanyEntry> companies;
  final void Function(String symbol) onTapSymbol;
  // True only for the "Other"/"Прочие" lane — its rows must NOT resolve or
  // display a sector (live or static). Any sector label shown there would
  // contradict the very reason the company landed in this lane in the
  // first place (search_browse_lanes.dart's `unclassified` bucket is
  // decided once, up front, by a static-only check; the live sector
  // provider used elsewhere in this row can resolve moments later and
  // disagree — confirmed on-device as a visible "mixed sectors under
  // Other" look). Skipping the live lookup here also saves a network call
  // for a value this lane deliberately never shows.
  final bool suppressSector;

  const CompanyListScreen({
    super.key,
    required this.title,
    required this.companies,
    required this.onTapSymbol,
    this.suppressSector = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: themedHeaderText(
          title,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${companies.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : const Divider(height: 1, color: Color(0x0F000000)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: companies.length,
                separatorBuilder: (_, _) => palette.dividerGradient != null
                    ? themedDivider(palette, indent: 68, endIndent: 0)
                    : const Divider(
                        height: 1,
                        indent: 68,
                        color: Color(0x0F000000),
                      ),
                itemBuilder: (context, i) => _CompanyRow(
                  entry: companies[i],
                  onTapSymbol: onTapSymbol,
                  suppressSector: suppressSector,
                  palette: palette,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyRow extends ConsumerWidget {
  final TopCompanyEntry entry;
  final void Function(String symbol) onTapSymbol;
  final bool suppressSector;
  final AppPalette palette;

  const _CompanyRow({
    required this.entry,
    required this.onTapSymbol,
    required this.suppressSector,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(quickLogoProvider(entry.symbol)).valueOrNull;

    final String subtitle;
    if (suppressSector) {
      subtitle = entry.symbol;
    } else {
      final cachedSector = ref
          .watch(quickGicsSectorProvider(entry.symbol))
          .valueOrNull;
      final sector =
          cachedSector ??
          resolveGicsSector(entry.symbol, companyName: entry.name);
      subtitle = sector?.label ?? entry.symbol;
    }

    return ListTile(
      onTap: () => onTapSymbol(entry.symbol),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: palette.accentPrimary, width: 1.5),
        ),
        child: CompanyLogo(ticker: entry.symbol, logoUrl: logoUrl, radius: 18),
      ),
      title: Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: palette.textHeader,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: palette.textBody,
        size: 20,
      ),
    );
  }
}
