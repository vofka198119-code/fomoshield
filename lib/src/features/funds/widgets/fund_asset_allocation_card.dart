import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/more_less_pill.dart';
import '../models/fund.dart';
import 'fund_allocation_bar_row.dart';

// ---------------------------------------------------------------------------
// FundAssetAllocationCard — Charts screen widget (2026-09-13 ask: reuse
// Stress Test's own "распределение активов" bars instead of a donut). A
// snapshot of the fund's CURRENT holdings (no year-picker -- there's no
// history to page through, [Fund.holdings] is always "as of now").
//
// Two-level reveal, same recipe as Search's BrowseLane -> company list
// (2026-09-13 follow-up ask, "чтобы не было лагов"): collapsed shows only
// the top 3 rows plus a chevron; tapping it switches to a paginated view
// (company_list_screen.dart's own "+6" pattern, via MoreLessPill) instead
// of building every holding's row up front. Each row watches
// resolvedCompanyNameProvider, so capping how many rows ever get built
// also caps how many of those lookups fire at once -- the same reasoning
// company_list_screen.dart's own header comment gives for not building
// unrevealed rows.
// ---------------------------------------------------------------------------
class FundAssetAllocationCard extends ConsumerStatefulWidget {
  final List<FundHolding> holdings;
  final AppPalette palette;

  /// On a screen that exists only to show this, there is nothing to reveal
  /// and nothing to hide: every holding is drawn and the chevron goes away.
  /// Opening a whole screen to find three rows of forty-four and a small
  /// arrow was, in his words, глупо (2026-10-10).
  final bool alwaysExpanded;

  const FundAssetAllocationCard({
    super.key,
    required this.holdings,
    required this.palette,
    this.alwaysExpanded = false,
  });

  @override
  ConsumerState<FundAssetAllocationCard> createState() =>
      _FundAssetAllocationCardState();
}

class _FundAssetAllocationCardState
    extends ConsumerState<FundAssetAllocationCard> {
  static const int _collapsedCount = 3;
  static const int _pageSize = 6;

  bool _expanded = false;
  int _revealedCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final sorted = [...widget.holdings]
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalValue = sorted.fold<double>(0, (s, h) => s + h.value);
    final hasData = sorted.isNotEmpty && totalValue > 0;

    final visibleCount = widget.alwaysExpanded
        ? sorted.length
        : (_expanded
              ? _revealedCount.clamp(0, sorted.length)
              : _collapsedCount.clamp(0, sorted.length));
    final display = sorted.take(visibleCount).toList();
    final remaining = sorted.length - display.length;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              themedHeaderText(
                l10n.etfAssetAllocationChartTitle,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
              // A toggle, not a one-way door. It used to be drawn only while
              // collapsed, so once the list was open there was no way to shut
              // it again — on this screen and on the Charts screen alike
              // (found on the phone, 2026-10-10).
              if (hasData &&
                  !widget.alwaysExpanded &&
                  sorted.length > _collapsedCount)
                InkWell(
                  onTap: () => setState(() {
                    _expanded = !_expanded;
                    // A reopened list starts from the first page again
                    // rather than remembering how far it was paged.
                    if (!_expanded) _revealedCount = _pageSize;
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.chevron_right_rounded,
                      color: palette.textBody,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          if (hasData) ...[
            for (final holding in display)
              FundAllocationBarRow(
                name:
                    ref
                        .watch(resolvedCompanyNameProvider(holding.symbol))
                        .valueOrNull ??
                    holding.symbol,
                percent: holding.value / totalValue * 100,
                palette: palette,
              ),
            if (!widget.alwaysExpanded && _expanded && remaining > 0)
              MoreLessPill(
                label: l10n.commonMoreCount(
                  remaining < _pageSize ? remaining : _pageSize,
                ),
                onTap: () => setState(() => _revealedCount += _pageSize),
                palette: palette,
                margin: EdgeInsets.zero,
              ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  l10n.etfAssetAllocationEmptyText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
