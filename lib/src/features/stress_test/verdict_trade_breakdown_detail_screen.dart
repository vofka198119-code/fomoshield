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
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/widgets/company_logo.dart';
import '../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../../shared/widgets/stagger_fade_in.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_naming.dart';

class VerdictTradeBreakdownDetailScreen extends ConsumerWidget {
  final String sessionId;

  const VerdictTradeBreakdownDetailScreen({super.key, required this.sessionId});

  static final _priceFmt = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archive = ref.watch(verdictArchiveProvider);
    final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
      (e) => e?.sessionId == sessionId,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'TRADE BREAKDOWN',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: entry == null
          ? const Center(child: Text('Session not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  KeyedSubtree(
                    key: const ValueKey('duration'),
                    child: StaggerFadeIn(
                      index: 0,
                      child: _DarkCard(
                        child: _Row(
                          label: 'Test Duration',
                          value: _durationDays(entry.durationLabel),
                          isLast: true,
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
                        title: 'STATISTICS',
                        child: Column(
                          children: [
                            _Row(
                              label: 'Total Trades',
                              value: '${entry.totalTrades}',
                            ),
                            _Row(
                              label: 'Bought',
                              value:
                                  '${entry.trades.where((t) => t.isBuy).length}',
                            ),
                            _Row(
                              label: 'Sold',
                              value:
                                  '${entry.trades.where((t) => !t.isBuy).length}',
                              isLast: true,
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
                        title: 'TOTAL ASSETS',
                        child: Column(
                          children: [
                            _Row(
                              label: 'Assets Held (Total)',
                              value: '${_totalAssetsEverHeld(entry)}',
                            ),
                            _Row(
                              label: 'Assets at Test End',
                              value: '${entry.holdingCount}',
                              isLast: true,
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
                      child: _financialSummaryCard(entry),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: const ValueKey('scenarios'),
                    child: StaggerFadeIn(
                      index: 4,
                      child: _scenariosCard(entry),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: const ValueKey('companies'),
                    child: StaggerFadeIn(
                      index: 5,
                      child: _CompaniesCard(entry: entry),
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: const ValueKey('tradeHistory'),
                    child: StaggerFadeIn(
                      index: 6,
                      child: _TradeHistoryCard(entry: entry),
                    ),
                  ),
                  KeyedSubtree(
                    key: const ValueKey('breakdownDisclaimer'),
                    child: StaggerFadeIn(
                      index: 7,
                      child: const _TradeBreakdownDisclaimer(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Fixed-duration presets map to real day counts; Infinite/Custom have no
  /// stored day count on VerdictArchiveEntry (only the display label), so
  /// they fall back to showing the label itself.
  String _durationDays(String durationLabel) {
    switch (durationLabel) {
      case '1 Week':
        return '7 days';
      case '1 Month':
        return '30 days';
      case '3 Months':
        return '90 days';
      default:
        return durationLabel;
    }
  }

  /// Distinct symbols ever bought during the test — compared against
  /// [VerdictArchiveEntry.holdingCount] (still-held at completion) to show
  /// portfolio turnover.
  int _totalAssetsEverHeld(VerdictArchiveEntry entry) =>
      entry.trades.where((t) => t.isBuy).map((t) => t.symbol).toSet().length;

  String _fmtMoney(double v) =>
      '${v >= 0 ? '+' : '-'}\$${_priceFmt.format(v.abs())}';

  /// Plain-English labels — never the raw enum/jargon names (per explicit
  /// ask: no bare "Bull"/"Bear").
  String _scenarioLabel(MarketScenario s) => switch (s) {
    MarketScenario.bull => 'Bull Trend',
    MarketScenario.bear => 'Bear Trend',
    MarketScenario.sideways => 'Sideways Market',
    MarketScenario.volatility => 'Volatility',
    MarketScenario.recovery => 'Recovery',
    MarketScenario.hype => 'Market Hype',
    MarketScenario.speculation => 'Speculation',
    MarketScenario.blackSwan => 'Black Swan',
    MarketScenario.crash => 'Crash',
  };

  Widget _scenariosCard(VerdictArchiveEntry entry) {
    final scenarios = MarketScenario.values;
    return _DarkCard(
      title: 'SCENARIOS EXPERIENCED',
      child: Column(
        children: [
          for (int i = 0; i < scenarios.length; i++)
            _Row(
              label: _scenarioLabel(scenarios[i]),
              value: '${entry.scenarioCounts[scenarios[i].name] ?? 0}',
              isLast: i == scenarios.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _financialSummaryCard(VerdictArchiveEntry entry) {
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
    final totalPnl = entry.finalValue - entry.startingCash;

    return _DarkCard(
      title: 'FINANCIAL SUMMARY',
      child: Column(
        children: [
          _Row(
            label: 'Starting Amount',
            value: '\$${_priceFmt.format(entry.startingCash)}',
          ),
          _Row(
            label: 'Total P&L (Realized + Unrealized)',
            value: _fmtMoney(totalPnl),
          ),
          _Row(
            label: 'Profitable Sells (${profitSells.length})',
            value: _fmtMoney(totalProfit),
          ),
          _Row(
            label: 'Losing Sells (${lossSells.length})',
            value: _fmtMoney(totalLoss),
          ),
          _Row(
            label: 'Final Balance',
            value: '\$${_priceFmt.format(entry.finalValue)}',
            isLast: true,
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

  const _CompaniesCard({required this.entry});

  @override
  State<_CompaniesCard> createState() => _CompaniesCardState();
}

class _CompaniesCardState extends State<_CompaniesCard> {
  static const _collapsedCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
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
      title: 'COMPANIES',
      child: Column(
        children: [
          if (symbols.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No companies traded.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (int i = 0; i < visible.length; i++)
              _CompanyRow(
                symbol: visible[i],
                pnl: pnlBySymbol[visible[i]] ?? 0,
                isLast: i == visible.length - 1,
              ),
          if (symbols.length > _collapsedCount)
            _MoreLessButton(
              expanded: _showAll,
              hiddenCount: symbols.length - _collapsedCount,
              onTap: () => setState(() => _showAll = !_showAll),
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

  const _TradeHistoryCard({required this.entry});

  @override
  State<_TradeHistoryCard> createState() => _TradeHistoryCardState();
}

class _TradeHistoryCardState extends State<_TradeHistoryCard> {
  static const _collapsedCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final sorted = widget.entry.trades.reversed.toList();
    final visible = _showAll ? sorted : sorted.take(_collapsedCount).toList();

    return _DarkCard(
      title: 'TRADE HISTORY',
      child: Column(
        children: [
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No trades yet.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (int i = 0; i < visible.length; i++)
              _TradeRow(trade: visible[i], isLast: i == visible.length - 1),
          if (sorted.length > _collapsedCount)
            _MoreLessButton(
              expanded: _showAll,
              hiddenCount: sorted.length - _collapsedCount,
              onTap: () => setState(() => _showAll = !_showAll),
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

  const _MoreLessButton({
    required this.expanded,
    required this.hiddenCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              expanded ? 'Less' : 'More ($hiddenCount)',
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

  const _DarkCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: FomoShieldTheme.cardTitle(Colors.white)),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
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

  const _Row({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: interNums(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: dialBrassLight,
            ),
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

  const _CompanyRow({
    required this.symbol,
    required this.pnl,
    this.isLast = false,
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
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  symbol,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${isPositive ? '+' : '-'}\$${VerdictTradeBreakdownDetailScreen._priceFmt.format(pnl.abs())}',
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

  const _TradeRow({required this.trade, this.isLast = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trade.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${VerdictTradeBreakdownDetailScreen._priceFmt.format(totalValue)}',
                style: interNums(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: dialBrassLight,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.isBuy ? 'BUY' : 'SELL',
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
  const _TradeBreakdownDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            'Disclaimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The results of this stress test are solely the results of a '
            'computer-generated simulation and are provided for '
            'educational and training purposes only. They are based on '
            'model-defined scenarios and historical market events and do '
            'not represent, predict, or guarantee the performance of any '
            'portfolio under real-world market conditions.\n\n'
            'Actual market behavior, individual companies, and financial '
            'assets may differ substantially from the results of the '
            'simulation. Past market events and performance do not '
            'guarantee similar outcomes in the future.\n\n'
            'Any scores, ratings, verdicts, or other indicators presented '
            'in the test do not constitute investment, financial, or '
            'other professional advice, nor do they constitute a '
            'recommendation, offer, or solicitation to buy or sell any '
            'financial asset or serve as a basis for making investment '
            'decisions.\n\n'
            'Any decision made using or taking into account information '
            'provided by the application is made solely at the user\'s '
            'own discretion and risk. We do not guarantee profits and are '
            'not responsible for any financial losses, damages, or lost '
            'profits resulting from the use of the simulation or its '
            'results.\n\n'
            'The purpose of the stress test is to help users learn about '
            'market scenarios, investment principles, and their own '
            'behavior in a simulated environment — not to predict the '
            'future.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
