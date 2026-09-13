import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const FundAssetAllocationCard({
    super.key,
    required this.holdings,
    required this.palette,
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

    final visibleCount = _expanded
        ? _revealedCount.clamp(0, sorted.length)
        : _collapsedCount.clamp(0, sorted.length);
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
              if (hasData && !_expanded && sorted.length > _collapsedCount)
                InkWell(
                  onTap: () => setState(() => _expanded = true),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_right_rounded,
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
            if (_expanded && remaining > 0)
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
                  style: TextStyle(fontSize: 13, color: palette.textBody),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
