import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../shared/widgets/more_less_pill.dart';
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
// Revealed 6-at-a-time (2026-09-04) instead of one flat list — a row's
// CompanyLogo fires its own fetch the moment it's built, and even with
// ListView's own scroll virtualization every row still eventually gets
// built (and fetches) just by scrolling down a long sector; a hard reveal
// count means a row past it never builds — and never fetches — until the
// user actually asks for more via the MoreLessPill.
//
// Rows read name from the entry the caller already has
// (top_companies_provider.dart's backend-ranked list). Logo: CompanyLogo
// resolves it on its own (via cachedLogoProvider -> our backend's /icons
// endpoint, never Finnhub directly). Sector: quickGicsSectorProvider,
// cache-only — see company_mini_card.dart's doc comment for why sector
// stays cache-only even though logo no longer needs to. Price still only
// shows once the user taps through to Company Detail — that's the one
// per-row cost this screen must never pay.
// ---------------------------------------------------------------------------

const int _revealBatchSize = 6;

class CompanyListScreen extends ConsumerStatefulWidget {
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
  ConsumerState<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends ConsumerState<CompanyListScreen> {
  int _revealedCount = _revealBatchSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final revealed = _revealedCount.clamp(0, widget.companies.length);
    final hasMore = revealed < widget.companies.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          widget.title,
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
                    '${widget.companies.length}',
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
                // +1 for the trailing MoreLessPill — never built (and
                // never fetches anything) until the user actually reveals
                // it, same as every row past `revealed`.
                itemCount: revealed + (hasMore ? 1 : 0),
                separatorBuilder: (_, i) => i >= revealed - 1
                    ? const SizedBox.shrink()
                    : palette.dividerGradient != null
                    ? themedDivider(palette, indent: 68, endIndent: 0)
                    : const Divider(
                        height: 1,
                        indent: 68,
                        color: Color(0x0F000000),
                      ),
                itemBuilder: (context, i) {
                  if (i >= revealed) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MoreLessPill(
                        label: l10n.commonMoreCount(
                          widget.companies.length - revealed,
                        ),
                        onTap: () =>
                            setState(() => _revealedCount += _revealBatchSize),
                        palette: palette,
                        margin: EdgeInsets.zero,
                      ),
                    );
                  }
                  return _CompanyRow(
                    entry: widget.companies[i],
                    onTapSymbol: widget.onTapSymbol,
                    suppressSector: widget.suppressSector,
                    palette: palette,
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
        child: CompanyLogo(ticker: entry.symbol, radius: 18),
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
        style: GoogleFonts.inter(
          fontSize: 11,
          // Same fix as watchlist_widget.dart's tile — see its comment.
          color: palette.titleGradient != null
              ? Colors.white.withValues(alpha: 0.85)
              : palette.textBody,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: palette.textBody,
        size: 20,
      ),
    );
  }
}
