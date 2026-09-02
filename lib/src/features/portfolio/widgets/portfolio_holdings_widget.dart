// ---------------------------------------------------------------------------
// Portfolio Holdings — pixel-for-pixel copy of Stress Test's own "HOLDINGS"
// card (stress_test_screen.dart's _buildMyAssets): same card, same 72px
// logo rows with a donut-color ring, same name/symbol/shares + value/P&L
// layout, same "More (N)/Less" toggle at a 10-row preview. No chevron — the
// old WidgetContainer-based header (chevron tied to a tap-to-expand toggle
// that didn't actually navigate anywhere) is gone along with it; expand/
// collapse now lives entirely in the "More/Less" button, same as the
// reference. Row tap still pushes to Company Detail (a real destination,
// unlike a decorative chevron).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../shared/widgets/donut_ring_painter.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../portfolio_providers.dart';

class PortfolioHoldingsWidget extends StatefulWidget {
  final String portfolioId;
  final List<HoldingPerformance>? holdings;
  final AppPalette palette;

  const PortfolioHoldingsWidget({
    super.key,
    required this.portfolioId,
    this.holdings,
    required this.palette,
  });

  @override
  State<PortfolioHoldingsWidget> createState() =>
      _PortfolioHoldingsWidgetState();
}

class _PortfolioHoldingsWidgetState extends State<PortfolioHoldingsWidget> {
  static const int _previewLimit = 10;
  bool _showAll = false;

  // Memoized sort — re-sorting the full holdings list is O(n log n) and
  // this widget rebuilds on every price tick as well as the "More/Less"
  // toggle; re-sort only when the underlying data actually changed.
  // Mutating plain fields (not calling setState) during build is safe
  // here since it's a pure memoization, not a state change that needs its
  // own rebuild trigger — same pattern as MarketValueChart._getPoints.
  List<HoldingPerformance>? _cachedSorted;
  int? _lastHoldingsSignature;

  List<HoldingPerformance> _sortedHoldings(List<HoldingPerformance> holdings) {
    final signature = Object.hashAll(
      holdings.map((h) => Object.hash(h.symbol, h.currentValue)),
    );
    if (_cachedSorted == null || _lastHoldingsSignature != signature) {
      // Sort descending by currentValue — same order the Portfolio
      // Balance donut's legend uses, so donutAllocationColor(i) lines up
      // with the same color for the same holding across both widgets.
      _cachedSorted = List<HoldingPerformance>.from(holdings)
        ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
      _lastHoldingsSignature = signature;
    }
    return _cachedSorted!;
  }

  Widget _addButton(BuildContext context, AppPalette palette) {
    return GestureDetector(
      onTap: () =>
          context.push('/search', extra: {'portfolioId': widget.portfolioId}),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: palette.accentPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add_rounded, size: 18, color: palette.accentPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final holdings = widget.holdings;
    final palette = widget.palette;

    if (holdings == null) {
      return CardFrame(
        padding: EdgeInsets.zero,
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.accentPrimary,
              ),
            ),
          ),
        ),
      );
    }

    final sorted = _sortedHoldings(holdings);
    final display = _showAll ? sorted : sorted.take(_previewLimit).toList();

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  themedHeaderText(
                    l10n.holdingsTitle,
                    palette,
                    FomoShieldTheme.cardTitle(),
                  ),
                  const Spacer(),
                  _addButton(context, palette),
                ],
              ),
            ),
          ),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      l10n.holdingsEmpty,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.holdingsEmptyHint,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: palette.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            themedDivider(palette),
            for (int i = 0; i < display.length; i++)
              _HoldingRow(
                holding: display[i],
                portfolioId: widget.portfolioId,
                colorIndex: i,
                showDivider: i < display.length - 1,
                palette: palette,
              ),
            if (sorted.length > _previewLimit)
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: palette.accentPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _showAll
                          ? l10n.commonLess
                          : l10n.commonMoreCount(sorted.length - _previewLimit),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _HoldingRow extends ConsumerWidget {
  final HoldingPerformance holding;
  final String portfolioId;
  final int colorIndex;
  final bool showDivider;
  final AppPalette palette;

  const _HoldingRow({
    required this.holding,
    required this.portfolioId,
    required this.colorIndex,
    required this.showDivider,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPositive = holding.pnl >= 0;
    final logoAsync = ref.watch(cachedLogoProvider(holding.symbol));
    final logoUrl = logoAsync.valueOrNull;
    final companyName =
        ref.watch(resolvedCompanyNameProvider(holding.symbol)).valueOrNull ??
        holding.symbol;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => context.push(
            '/company/${holding.symbol}',
            extra: {'portfolioId': portfolioId},
          ),
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: donutAllocationColor(
                        colorIndex,
                      ).withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: ClipOval(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CompanyLogo(
                        ticker: holding.symbol,
                        logoUrl: logoUrl,
                        radius: 18,
                        resolveIfMissing: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        holding.symbol,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.sharesCount(holding.shares.toStringAsFixed(2)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: themedPriceText(
                        formatUsd(holding.currentValue),
                        palette,
                        interNums(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${formatUsdSigned(holding.pnl)} '
                        '(${isPositive ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%)',
                        style: interNums(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? ThemeV2.success : ThemeV2.loss,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
