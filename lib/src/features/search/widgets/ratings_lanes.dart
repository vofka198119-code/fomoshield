import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../popularity_provider.dart';
import '../top_companies_provider.dart';
import 'browse_lane.dart';
import 'company_mini_card.dart';

// ---------------------------------------------------------------------------
// Ratings — the Search screen's third lane
// ---------------------------------------------------------------------------
// Rankings of the S&P 500 roster the backend already serves and already keeps
// warm (/top-companies: symbol, name, market cap, P/E, refreshed quarterly).
// Nothing here costs an extra API call and nothing here collects anything
// about anyone — a deliberate choice, since the obvious reading of "popular"
// would mean either counting what our own users hold (new aggregation, and a
// new thing to disclose) or a daily market-activity feed (a backend change
// during the Play test). Both are better done afterwards, on purpose, than
// smuggled in behind a lane title.
//
// So these are rankings by a stated metric, titled as such. "Biggest" is the
// honest name for a market-cap ranking; calling it "most popular" would be a
// small lie that the data can't back up.
// ---------------------------------------------------------------------------

const int _previewCount = 4;

// How deep a ranking goes once opened in full. The popularity lanes never
// reach it — the counter only serves ten — but a market-cap or P/E ranking
// could run the whole 500-name roster, which stops being a "rating" long
// before the end of it.
const int _fullListCount = 30;

class RatingsLanes extends ConsumerWidget {
  final AppPalette palette;
  final void Function(String symbol) onTapSymbol;

  const RatingsLanes({
    super.key,
    required this.palette,
    required this.onTapSymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companiesAsync = ref.watch(topCompaniesProvider);
    final iconMap = ref.watch(iconsBatchWarmProvider).valueOrNull ?? const {};
    // Empty until the counter is deployed, and empty again on any error —
    // see popularity_provider.dart. Both lanes simply don't render then.
    final popularity = ref
        .watch(popularityProvider)
        .maybeWhen(data: (p) => p, orElse: () => PopularityRanking.empty);

    return companiesAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: palette.accentPrimary),
      ),
      error: (_, _) => _message(l10n.searchRatingsUnavailable),
      data: (companies) {
        if (companies.isEmpty) return _message(l10n.searchRatingsUnavailable);

        // Already ranked by market cap on the server — no need to re-sort.
        final biggest = companies.take(_fullListCount).toList();

        // A P/E only means anything when it exists and is positive: a
        // loss-making company reports a negative one, and sorting those in
        // would put the deepest losses at the "cheapest" end of the list,
        // which is precisely backwards.
        final rated =
            companies.where((c) => (c.peTTM ?? 0) > 0).toList()
              ..sort((a, b) => a.peTTM!.compareTo(b.peTTM!));
        final lowestPe = rated.take(_fullListCount).toList();
        final highestPe = rated.reversed.take(_fullListCount).toList();

        // Name lookup for the popularity lanes, which come back as bare
        // symbols — the counter stores nothing but a ticker and a number.
        final nameOf = {for (final c in companies) c.symbol: c.name};

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (popularity.today.isNotEmpty) ...[
              _lane(
                context,
                l10n.searchRatingsPopularToday,
                _entries(popularity.today, nameOf),
                iconMap,
              ),
              const SizedBox(height: 16),
            ],
            if (popularity.allTime.isNotEmpty) ...[
              _lane(
                context,
                l10n.searchRatingsPopular,
                _entries(popularity.allTime, nameOf),
                iconMap,
              ),
              const SizedBox(height: 16),
            ],
            _lane(context, l10n.searchRatingsBiggest, biggest, iconMap),
            const SizedBox(height: 16),
            if (lowestPe.isNotEmpty) ...[
              _lane(context, l10n.searchRatingsLowestPe, lowestPe, iconMap),
              const SizedBox(height: 16),
            ],
            if (highestPe.isNotEmpty)
              _lane(context, l10n.searchRatingsHighestPe, highestPe, iconMap),
          ],
        );
      },
    );
  }

  // The counter knows only tickers; the roster supplies the names. A symbol
  // the roster doesn't carry (an index, a delisted ticker) falls back to its
  // own symbol rather than being dropped — it was genuinely looked at.
  List<TopCompanyEntry> _entries(
    List<PopularCompany> ranked,
    Map<String, String> nameOf,
  ) {
    return [
      for (final p in ranked)
        TopCompanyEntry(
          symbol: p.symbol,
          name: nameOf[p.symbol] ?? p.symbol,
          marketCap: 0,
        ),
    ];
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
      ),
    ),
  );

  // [entries] is the whole ranking; the lane shows the first few and hands
  // the rest to the full-list screen behind the chevron and the "Show more"
  // pill. A ranking that already fits in the preview gets neither — there is
  // nothing more to show.
  Widget _lane(
    BuildContext context,
    String title,
    List<TopCompanyEntry> entries,
    Map<String, String> iconMap,
  ) {
    final preview = entries.take(_previewCount).toList();
    return BrowseLane(
      title: title,
      palette: palette,
      onSeeAll: entries.length > _previewCount
          ? () => context.push(
              '/search/company-list',
              extra: {
                'title': title,
                'companies': entries,
                'onTapSymbol': onTapSymbol,
                'suppressSector': false,
              },
            )
          : null,
      items: [
        for (int i = 0; i < preview.length; i++)
          CompanyMiniCard(
            symbol: preview[i].symbol,
            name: preview[i].name,
            logoUrl: iconMap[preview[i].symbol],
            onTap: () => onTapSymbol(preview[i].symbol),
            showDivider: i < preview.length - 1,
            palette: palette,
          ),
      ],
    );
  }
}
