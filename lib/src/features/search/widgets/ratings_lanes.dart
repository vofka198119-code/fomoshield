import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
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

const int _previewCount = 6;

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

    return companiesAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: palette.accentPrimary),
      ),
      error: (_, _) => _message(l10n.searchRatingsUnavailable),
      data: (companies) {
        if (companies.isEmpty) return _message(l10n.searchRatingsUnavailable);

        // Already ranked by market cap on the server — no need to re-sort.
        final biggest = companies.take(_previewCount).toList();

        // A P/E only means anything when it exists and is positive: a
        // loss-making company reports a negative one, and sorting those in
        // would put the deepest losses at the "cheapest" end of the list,
        // which is precisely backwards.
        final rated =
            companies.where((c) => (c.peTTM ?? 0) > 0).toList()
              ..sort((a, b) => a.peTTM!.compareTo(b.peTTM!));
        final lowestPe = rated.take(_previewCount).toList();
        final highestPe = rated.reversed.take(_previewCount).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _lane(l10n.searchRatingsBiggest, biggest, iconMap),
            const SizedBox(height: 16),
            if (lowestPe.isNotEmpty) ...[
              _lane(l10n.searchRatingsLowestPe, lowestPe, iconMap),
              const SizedBox(height: 16),
            ],
            if (highestPe.isNotEmpty)
              _lane(l10n.searchRatingsHighestPe, highestPe, iconMap),
          ],
        );
      },
    );
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

  Widget _lane(
    String title,
    List<TopCompanyEntry> entries,
    Map<String, String> iconMap,
  ) {
    return BrowseLane(
      title: title,
      palette: palette,
      items: [
        for (int i = 0; i < entries.length; i++)
          CompanyMiniCard(
            symbol: entries[i].symbol,
            name: entries[i].name,
            logoUrl: iconMap[entries[i].symbol],
            onTap: () => onTapSymbol(entries[i].symbol),
            showDivider: i < entries.length - 1,
            palette: palette,
          ),
      ],
    );
  }
}
