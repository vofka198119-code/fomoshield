// ---------------------------------------------------------------------------
// Verdict — Trade Breakdown detail screen. Reached via the chevron next to
// the Trade Breakdown card's title on the Session Complete screen. Full,
// detailed portfolio-wide summary for the completed test. Dark branded card
// family (dialLight/dialDark gradient, gold numbers) — same look as the
// Psychology Meter's per-marker widgets, NOT the light Session Complete
// card style.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/utils/currency_format.dart';
import '../../shared/widgets/company_logo.dart';
import '../../shared/widgets/card_frame.dart';
import '../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../../shared/widgets/stagger_fade_in.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_naming.dart';
import '../../l10n/gen/app_localizations.dart';

class VerdictTradeBreakdownDetailScreen extends ConsumerWidget {
  final String sessionId;

  const VerdictTradeBreakdownDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final archive = ref.watch(verdictArchiveProvider);
    final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
      (e) => e?.sessionId == sessionId,
      orElse: () => null,
    );
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.verdictTradeBreakdownTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: entry == null
            ? Center(
                child: Text(
                  l10n.verdictSessionNotFound,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    KeyedSubtree(
                      key: const ValueKey('duration'),
                      child: StaggerFadeIn(
                        index: 0,
                        child: _DarkCard(
                          palette: palette,
                          child: _Row(
                            label: l10n.verdictTestDurationLabel,
                            value: _durationDays(l10n, entry.durationLabel),
                            isLast: true,
                            palette: palette,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('statistics'),
                      child: StaggerFadeIn(
                        index: 1,
                        child: _DarkCard(
                          title: l10n.verdictStatisticsTitle,
                          palette: palette,
                          child: Column(
                            children: [
                              _Row(
                                label: l10n.verdictTotalTradesLabel,
                                value: '${entry.totalTrades}',
                                palette: palette,
                              ),
                              _Row(
                                label: l10n.verdictBoughtLabel,
                                value:
                                    '${entry.trades.where((t) => t.isBuy).length}',
                                palette: palette,
                              ),
                              _Row(
                                label: l10n.verdictSoldLabel,
                                value:
                                    '${entry.trades.where((t) => !t.isBuy).length}',
                                isLast: true,
                                palette: palette,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('totalAssets'),
                      child: StaggerFadeIn(
                        index: 2,
                        child: _DarkCard(
                          title: l10n.verdictTotalAssetsTitle,
                          palette: palette,
                          child: Column(
                            children: [
                              _Row(
                                label: l10n.verdictAssetsHeldTotalLabel,
                                value: '${_totalAssetsEverHeld(entry)}',
                                palette: palette,
                              ),
                              _Row(
                                label: l10n.verdictAssetsAtEndLabel,
                                value: '${entry.holdingCount}',
                                isLast: true,
                                palette: palette,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('financialSummary'),
                      child: StaggerFadeIn(
                        index: 3,
                        child: _financialSummaryCard(l10n, entry, palette),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('scenarios'),
                      child: StaggerFadeIn(
                        index: 4,
                        child: _scenariosCard(l10n, entry, palette),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('companies'),
                      child: StaggerFadeIn(
                        index: 5,
                        child: _CompaniesCard(entry: entry, palette: palette),
                      ),
                    ),
                    const SizedBox(height: 16),
                    KeyedSubtree(
                      key: const ValueKey('tradeHistory'),
                      child: StaggerFadeIn(
                        index: 6,
                        child: _TradeHistoryCard(
                          entry: entry,
                          palette: palette,
                        ),
                      ),
                    ),
                    KeyedSubtree(
                      key: const ValueKey('breakdownDisclaimer'),
                      child: StaggerFadeIn(
                        index: 7,
                        child: _TradeBreakdownDisclaimer(palette: palette),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Fixed-duration presets map to real day counts; Infinite/Custom have no
  /// stored day count on VerdictArchiveEntry (only the display label), so
  /// they fall back to showing the label itself.
  String _durationDays(AppLocalizations l10n, String durationLabel) {
    switch (durationLabel) {
      case '1 Week':
        return l10n.verdictDurationDays(7);
      case '1 Month':
        return l10n.verdictDurationDays(30);
      case '3 Months':
        return l10n.verdictDurationDays(90);
      default:
        return durationLabel;
    }
  }

  /// Distinct symbols ever bought during the test — compared against
  /// [VerdictArchiveEntry.holdingCount] (still-held at completion) to show
  /// portfolio turnover.
  int _totalAssetsEverHeld(VerdictArchiveEntry entry) =>
      entry.trades.where((t) => t.isBuy).map((t) => t.symbol).toSet().length;

  /// Plain-English labels — never the raw enum/jargon names (per explicit
  /// ask: no bare "Bull"/"Bear").
  String _scenarioLabel(AppLocalizations l10n, MarketScenario s) => switch (s) {
    MarketScenario.bull => l10n.verdictScenarioBull,
    MarketScenario.bear => l10n.verdictScenarioBear,
    MarketScenario.sideways => l10n.verdictScenarioSideways,
    MarketScenario.volatility => l10n.verdictScenarioVolatility,
    MarketScenario.recovery => l10n.verdictScenarioRecovery,
    MarketScenario.hype => l10n.verdictScenarioHype,
    MarketScenario.speculation => l10n.verdictScenarioSpeculation,
    MarketScenario.blackSwan => l10n.verdictScenarioBlackSwan,
    MarketScenario.crash => l10n.verdictScenarioCrash,
  };

  Widget _scenariosCard(
    AppLocalizations l10n,
    VerdictArchiveEntry entry,
    AppPalette palette,
  ) {
    final scenarios = MarketScenario.values;
    return _DarkCard(
      title: l10n.verdictScenariosTitle,
      palette: palette,
      child: Column(
        children: [
          for (int i = 0; i < scenarios.length; i++)
            _Row(
              label: _scenarioLabel(l10n, scenarios[i]),
              value: '${entry.scenarioCounts[scenarios[i].name] ?? 0}',
              isLast: i == scenarios.length - 1,
              palette: palette,
            ),
        ],
      ),
    );
  }

  Widget _financialSummaryCard(
    AppLocalizations l10n,
    VerdictArchiveEntry entry,
    AppPalette palette,
  ) {
    final sells = entry.trades.where((t) => !t.isBuy).toList();
    final profitSells = sells.where((t) => (t.realizedPnl ?? 0) > 0).toList();
    final lossSells = sells.where((t) => (t.realizedPnl ?? 0) < 0).toList();
    final totalProfit = profitSells.fold<double>(
      0,
      (sum, t) => sum + (t.realizedPnl ?? 0),
    );
    final totalLoss = lossSells.fold<double>(
      0,
      (sum, t) => sum + (t.realizedPnl ?? 0),
    );
    // Excludes dcaTotalReceived from the baseline — DCA top-ups are
    // deposits, not investment return (see StressTestSession.profitLoss).
    final totalPnl =
        entry.finalValue - (entry.startingCash + entry.dcaTotalReceived);

    return _DarkCard(
      title: l10n.verdictFinancialSummaryTitle,
      palette: palette,
      child: Column(
        children: [
          _Row(
            label: l10n.verdictStartingAmountLabel,
            value: formatUsd(entry.startingCash),
            palette: palette,
          ),
          _Row(
            label: l10n.verdictTotalPnlLabel,
            value: formatUsdSigned(totalPnl),
            palette: palette,
          ),
          _Row(
            label: l10n.verdictProfitableSellsLabel(profitSells.length),
            value: formatUsdSigned(totalProfit),
            palette: palette,
          ),
          _Row(
            label: l10n.verdictLosingSellsLabel(lossSells.length),
            value: formatUsdSigned(totalLoss),
            palette: palette,
          ),
          _Row(
            label: l10n.verdictFinalBalanceLabel,
            value: formatUsd(entry.finalValue),
            isLast: true,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

/// Every symbol ever bought during the test, with its combined realized
/// P&L (summed from sell trades) plus, for shares still held at
/// completion, [VerdictArchiveEntry.unrealizedPnlBySymbol]'s mark-to-market
/// figure — so a never-sold holding shows its real gain/loss "as if sold at
/// test end" instead of a misleading $0. Capped at 5 rows with a
/// More(N)/Less toggle, same shape as [market_timeline.dart]'s expand button.
class _CompaniesCard extends StatefulWidget {
  final VerdictArchiveEntry entry;
  final AppPalette palette;

  const _CompaniesCard({required this.entry, required this.palette});

  @override
  State<_CompaniesCard> createState() => _CompaniesCardState();
}

class _CompaniesCardState extends State<_CompaniesCard> {
  static const _collapsedCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entry = widget.entry;
    final symbols = entry.trades
        .where((t) => t.isBuy)
        .map((t) => t.symbol)
        .toSet()
        .toList();
    final pnlBySymbol = <String, double>{};
    for (final t in entry.trades.where((t) => !t.isBuy)) {
      pnlBySymbol[t.symbol] =
          (pnlBySymbol[t.symbol] ?? 0) + (t.realizedPnl ?? 0);
    }
    for (final e in entry.unrealizedPnlBySymbol.entries) {
      pnlBySymbol[e.key] = (pnlBySymbol[e.key] ?? 0) + e.value;
    }
    // Max profit first, down to max loss.
    symbols.sort(
      (a, b) => (pnlBySymbol[b] ?? 0).compareTo(pnlBySymbol[a] ?? 0),
    );
    final visible = _showAll ? symbols : symbols.take(_collapsedCount).toList();

    return _DarkCard(
      title: l10n.verdictCompaniesTitle,
      palette: widget.palette,
      child: Column(
        children: [
          if (symbols.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.verdictNoCompaniesTraded,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: (widget.palette.onWindow ?? Colors.white).withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (int i = 0; i < visible.length; i++)
              _CompanyRow(
                symbol: visible[i],
                pnl: pnlBySymbol[visible[i]] ?? 0,
                isLast: i == visible.length - 1,
                palette: widget.palette,
              ),
          if (symbols.length > _collapsedCount)
            _MoreLessButton(
              expanded: _showAll,
              hiddenCount: symbols.length - _collapsedCount,
              onTap: () => setState(() => _showAll = !_showAll),
              palette: widget.palette,
            ),
        ],
      ),
    );
  }
}

/// Full per-trade log for the completed test, newest first — moved here
/// 2026-08-08 from its own light-theme widget on the Session Complete
/// screen, restyled dark-green to match this screen's card family. Capped
/// at 5 rows with a More(N)/Less toggle (added since this screen is
/// already the "full detail" destination — there's nowhere further to push).
class _TradeHistoryCard extends StatefulWidget {
  final VerdictArchiveEntry entry;
  final AppPalette palette;

  const _TradeHistoryCard({required this.entry, required this.palette});

  @override
  State<_TradeHistoryCard> createState() => _TradeHistoryCardState();
}

class _TradeHistoryCardState extends State<_TradeHistoryCard> {
  static const _collapsedCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = widget.entry.trades.reversed.toList();
    final visible = _showAll ? sorted : sorted.take(_collapsedCount).toList();

    return _DarkCard(
      title: l10n.tradeHistoryTitle,
      palette: widget.palette,
      child: Column(
        children: [
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.verdictNoTradesYet,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: (widget.palette.onWindow ?? Colors.white).withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (int i = 0; i < visible.length; i++)
              _TradeRow(
                trade: visible[i],
                isLast: i == visible.length - 1,
                palette: widget.palette,
              ),
          if (sorted.length > _collapsedCount)
            _MoreLessButton(
              expanded: _showAll,
              hiddenCount: sorted.length - _collapsedCount,
              onTap: () => setState(() => _showAll = !_showAll),
              palette: widget.palette,
            ),
        ],
      ),
    );
  }
}

/// Shared More(N)/Less pill for this screen's dark card family — same
/// interaction as [market_timeline.dart]/[stress_test_allocation_chart.dart]'s
/// expand toggle, restyled with the white-on-gradient palette used here.
class _MoreLessButton extends StatelessWidget {
  final bool expanded;
  final int hiddenCount;
  final VoidCallback onTap;
  final AppPalette palette;

  const _MoreLessButton({
    required this.expanded,
    required this.hiddenCount,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              expanded ? l10n.commonLess : l10n.commonMoreCount(hiddenCount),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dialBrassLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final AppPalette palette;

  const _DarkCard({this.title, required this.child, required this.palette});

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: BorderRadius.circular(20),
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            themedGoldGradient(
              Text(title!, style: FomoShieldTheme.cardTitle(palette.onWindow ?? Colors.white)),
              palette,
            ),
            const SizedBox(height: 12),
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : Divider(
                    height: 1,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12),
                  ),
            const SizedBox(height: 4),
          ],
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final AppPalette palette;

  const _Row({
    required this.label,
    required this.value,
    this.isLast = false,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12)),
              ),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: palette.onWindow ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          themedPriceText(
            value,
            palette,
            interNums(fontSize: 15, fontWeight: FontWeight.w700),
            fallbackColor: dialBrassLight,
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends ConsumerWidget {
  final String symbol;
  final double pnl;
  final bool isLast;
  final AppPalette palette;

  const _CompanyRow({
    required this.symbol,
    required this.pnl,
    this.isLast = false,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoAsync = ref.watch(cachedLogoProvider(symbol));
    final companyName = resolveStressTestCompanyName(ref, symbol);
    final isPositive = pnl >= 0;
    final pnlColor = isPositive ? ThemeV2.success : ThemeV2.loss;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12)),
              ),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: dialBrassLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: dialBrassLight.withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
            child: logoAsync.when(
              data: (url) =>
                  CompanyLogo(ticker: symbol, logoUrl: url, radius: 16),
              error: (_, _) => CompanyLogo(ticker: symbol, radius: 16),
              loading: () => CompanyLogo(ticker: symbol, radius: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.onWindow ?? Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  symbol,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatUsdSigned(pnl),
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: pnlColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeRow extends ConsumerWidget {
  final StressTestTrade trade;
  final bool isLast;
  final AppPalette palette;

  const _TradeRow({
    required this.trade,
    this.isLast = false,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logoAsync = ref.watch(cachedLogoProvider(trade.symbol));
    final companyName = resolveStressTestCompanyName(ref, trade.symbol);
    final accent = trade.isBuy ? ThemeV2.success : ThemeV2.loss;
    final totalValue = trade.shares * trade.price;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12)),
              ),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: dialBrassLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: dialBrassLight.withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
            child: logoAsync.when(
              data: (url) =>
                  CompanyLogo(ticker: trade.symbol, logoUrl: url, radius: 16),
              error: (_, _) => CompanyLogo(ticker: trade.symbol, radius: 16),
              loading: () => CompanyLogo(ticker: trade.symbol, radius: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.onWindow ?? Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trade.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              themedPriceText(
                formatUsd(totalValue),
                palette,
                interNums(fontSize: 14, fontWeight: FontWeight.w700),
                fallbackColor: dialBrassLight,
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.isBuy ? l10n.tradeBuy : l10n.tradeSell,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TradeBreakdownDisclaimer extends StatelessWidget {
  final AppPalette palette;

  const _TradeBreakdownDisclaimer({required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Sits directly on the screen background (no card behind it). Color is
    // the same fixed muted gray as DisclaimerFooter's reference treatment
    // (2026-08-25: unify every card-level disclaimer to that one look),
    // overridden per [AppPalette.disclaimerColor] (only Black & White sets
    // it, 2026-09-05) — readable regardless of backdrop in both themes
    // without needing the "always-dark panel" gating this file's other
    // elements require.
    final disclaimerColor =
        palette.disclaimerColor ?? ThemeV2.textSecondary.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            l10n.verdictTradeBreakdownDisclaimerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: disclaimerColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.verdictTradeBreakdownDisclaimerBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: disclaimerColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
