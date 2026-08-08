// ---------------------------------------------------------------------------
// Stress Test Stock Detail Screen — stock detail (Block 2)
// ---------------------------------------------------------------------------
// Restyled 2026-08-02 to match Company Detail's visual system: composes
// modular widgets from stock_detail/widgets/ (was one 1960-line monolith),
// reuses Company Detail's own PriceHeader (with a phase-label override —
// this is a simulated price, not a real NYSE one) and CompanyBottomBar for
// exact visual parity on those two pieces. No FS Score — Stress Test's
// assets aren't real companies. New: a symbol-scoped Limit Orders section,
// lowest widget, wired to Stress Test's own isolated pending-orders
// provider (never the real orders feature).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../company_detail/widgets/price_header.dart';
import '../../company_detail/widgets/company_bottom_bar.dart';
import 'stock_detail/widgets/stock_detail_helpers.dart';
import 'stock_detail/widgets/stock_market_status.dart';
import 'stock_detail/widgets/stock_sparkline_chart.dart';
import 'stock_detail/widgets/stock_position_card.dart';
import 'stock_detail/widgets/stock_why_today_card.dart';
import 'stock_detail/widgets/stock_limit_orders_section.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String symbol;

  const StockDetailScreen({
    super.key,
    required this.sessionId,
    required this.symbol,
  });

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  StressTestSparkPeriod _selectedPeriod = StressTestSparkPeriod.m1;
  List<ChartDataPoint> _points = [];
  bool _chartReady = false;

  @override
  void initState() {
    super.initState();
    _generateSparkData();
    // If this is a new asset (not yet in portfolio), fetch price from Finnhub
    Future.microtask(() => _ensurePriceForNewAsset());
  }

  @override
  void didUpdateWidget(StockDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol ||
        oldWidget.sessionId != widget.sessionId) {
      _generateSparkData();
    }
  }

  static const Map<StressTestSparkPeriod, Duration> _sparkPeriodCutoffs = {
    StressTestSparkPeriod.d1: Duration(days: 1),
    StressTestSparkPeriod.w1: Duration(days: 7),
    StressTestSparkPeriod.m1: Duration(days: 30),
    StressTestSparkPeriod.m3: Duration(days: 90),
    StressTestSparkPeriod.y1: Duration(days: 365),
  };

  void _generateSparkData() {
    final session = _session;
    if (session == null) return;

    final available = _availablePeriods(session);
    if (!available.contains(_selectedPeriod)) {
      _selectedPeriod = available.first;
    }

    final priceHist = session.priceHistory[widget.symbol] ?? [];
    if (priceHist.isEmpty) {
      final price = session.currentPrices[widget.symbol] ??
          session.basePrices[widget.symbol] ??
          100.0;
      final now = DateTime.now();
      setState(() {
        _points = [
          ChartDataPoint(now.subtract(const Duration(minutes: 1)), price),
          ChartDataPoint(now, price),
        ];
        _chartReady = true;
      });
      return;
    }

    // Real per-tick timestamps if this symbol has them (see
    // stress_test_engine.dart's priceHistoryTimestamps) — falls back to
    // the old synthetic "nominally tickIntervalSeconds apart" spacing for
    // points recorded before that field existed, same as
    // StressTestNotifier.computeChartData.
    final tsHist = session.priceHistoryTimestamps[widget.symbol];
    final hasRealTimestamps =
        tsHist != null && tsHist.length == priceHist.length;
    final now = DateTime.now();
    final allPoints = <ChartDataPoint>[];
    for (int i = 0; i < priceHist.length; i++) {
      final time = hasRealTimestamps
          ? DateTime.fromMillisecondsSinceEpoch(tsHist[i])
          : now.subtract(
              Duration(
                seconds: (priceHist.length - 1 - i) * tickIntervalSeconds,
              ),
            );
      allPoints.add(ChartDataPoint(time, priceHist[i]));
    }

    List<ChartDataPoint> filtered;
    final periodDuration = _sparkPeriodCutoffs[_selectedPeriod];
    if (periodDuration == null) {
      // StressTestSparkPeriod.max — no time filter, whole history.
      filtered = allPoints;
    } else if (_selectedPeriod == StressTestSparkPeriod.d1) {
      // 1D is a fixed calendar day (midnight → midnight) — StockSparklineChart
      // further anchors its left edge to wherever today's real data starts
      // (not literal midnight); this just needs to include all of today.
      final todayStart = DateTime(now.year, now.month, now.day);
      filtered = allPoints.where((p) => !p.time.isBefore(todayStart)).toList();
    } else {
      // Periods longer than a day are a plain trailing rolling window —
      // StockSparklineChart stretches whatever falls in it to fill the
      // full chart width (no "stop at now" empty space for these).
      final cutoff = now.subtract(periodDuration);
      filtered = allPoints.where((p) => !p.time.isBefore(cutoff)).toList();
    }

    // Passed through at full resolution — StockSparklineChart does its own
    // time-bucket averaging (not blind stride-sampling) once it knows the
    // exact fixed domain it's rendering into, so raw noisy ticks get
    // properly smoothed instead of arbitrarily thinned out beforehand.
    setState(() {
      _points = filtered;
      _chartReady = true;
    });
  }

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  /// Returns available sparkline periods based on session duration.
  /// Infinite/Custom show every period upfront too, not gated by how much
  /// real time has actually elapsed — a period tab reflects however
  /// little (or much) data exists so far (auto-scaled in
  /// StockSparklineChart), same as a fixed-length test already does;
  /// hiding "1W" until a real week had passed made the chart
  /// inaccessible right when the user most wanted to check a brand-new
  /// test. Explicit ask — don't reintroduce elapsed gating here.
  List<StressTestSparkPeriod> _availablePeriods(StressTestSession session) {
    return switch (session.duration) {
      TestDuration.week1 => [StressTestSparkPeriod.d1, StressTestSparkPeriod.w1],
      TestDuration.month1 => [
          StressTestSparkPeriod.d1,
          StressTestSparkPeriod.w1,
          StressTestSparkPeriod.m1,
        ],
      TestDuration.months3 => [
          StressTestSparkPeriod.d1,
          StressTestSparkPeriod.w1,
          StressTestSparkPeriod.m1,
          StressTestSparkPeriod.m3,
        ],
      TestDuration.infinite || TestDuration.custom => [
          StressTestSparkPeriod.d1,
          StressTestSparkPeriod.w1,
          StressTestSparkPeriod.m1,
          StressTestSparkPeriod.m3,
          StressTestSparkPeriod.y1,
        ],
    };
  }

  StressTestHolding? _findHolding(StressTestSession session) {
    try {
      return session.holdings.firstWhere((h) => h.symbol == widget.symbol);
    } catch (_) {
      return null;
    }
  }

  /// For a new asset not yet in the portfolio, fetch the current price
  /// from Finnhub and store it in the engine via setExternalPrice.
  Future<void> _ensurePriceForNewAsset() async {
    final session =
        ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
    if (session == null) return;

    final isHeld = session.holdings.any((h) => h.symbol == widget.symbol);
    final hasPrice = session.currentPrices.containsKey(widget.symbol) ||
        session.basePrices.containsKey(widget.symbol);

    if (!isHeld && !hasPrice) {
      try {
        final quote = await ref.read(finnhubServiceProvider).quote(widget.symbol);
        if (!mounted) return;
        final price = (quote['c'] as num?)?.toDouble() ?? 0;
        if (price > 0) {
          ref
              .read(stressTestProvider.notifier)
              .setExternalPrice(widget.sessionId, widget.symbol, price);
          _generateSparkData();
        }
      } catch (_) {
        // Silently fail — price remains 0, user sees fallback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    // Regenerate the chart's points whenever the engine ticks — previously
    // only initState/didUpdateWidget/period-tap called _generateSparkData,
    // so the chart sat stale (while the price header above it kept
    // updating live) until the screen was torn down and rebuilt by
    // leaving and re-entering. Safe to call here (not directly in build)
    // since ref.listen's callback fires after the build phase completes.
    ref.listen<int>(stressTestRefreshProvider, (prev, next) {
      _generateSparkData();
    });
    final session = _session;
    if (session == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Session not found')),
      );
    }

    final currentPrice = session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        0;
    final basePrice = session.basePrices[widget.symbol] ?? currentPrice;
    final priceChange = currentPrice - basePrice;
    final priceChangePercent =
        basePrice > 0 ? (priceChange / basePrice) * 100 : 0.0;
    final isPositive = priceChange >= 0;
    final holding = _findHolding(session);
    final logoAsync = ref.watch(cachedLogoProvider(widget.symbol));
    final phaseInfo = stressTestMarketPhaseDisplay(currentStressTestMarketPhase());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PriceHeader(
                        logo: logoAsync.valueOrNull,
                        companyName: resolveStressTestCompanyName(ref, widget.symbol),
                        symbol: widget.symbol,
                        price: currentPrice,
                        change: priceChange,
                        changePercent: priceChangePercent,
                        isUp: isPositive,
                        // Simulated price — never the real NYSE session.
                        phaseLabel: phaseInfo.label,
                        phaseLabelColor: phaseInfo.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => showStressTestMarketHoursSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(phaseInfo.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              phaseInfo.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: phaseInfo.color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: ThemeV2.textSecondary.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StockSparklineChart(
                      ready: _chartReady,
                      points: _points,
                      avgPrice: holding?.averagePrice,
                      availablePeriods: _availablePeriods(session),
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (p) {
                        setState(() => _selectedPeriod = p);
                        _generateSparkData();
                      },
                    ),
                    if (holding != null)
                      StockPositionCard(
                        shares: holding.shares,
                        avgPrice: holding.averagePrice,
                        pnl: session.positionPnL[widget.symbol] ?? 0.0,
                      ),
                    StockWhyTodayCard(
                      sessionId: widget.sessionId,
                      symbol: widget.symbol,
                      priceChange: priceChange,
                      priceChangePercent: priceChangePercent,
                      isPositive: isPositive,
                      marketPct: session.explanationLog[widget.symbol]?.isNotEmpty == true
                          ? session.explanationLog[widget.symbol]!.last.contributions.marketPct
                          : null,
                      sectorPct: session.explanationLog[widget.symbol]?.isNotEmpty == true
                          ? session.explanationLog[widget.symbol]!.last.contributions.sectorPct
                          : null,
                      newsPct: session.explanationLog[widget.symbol]?.isNotEmpty == true
                          ? session.explanationLog[widget.symbol]!.last.contributions.newsPct
                          : null,
                      noisePct: session.explanationLog[widget.symbol]?.isNotEmpty == true
                          ? session.explanationLog[widget.symbol]!.last.contributions.noisePct
                          : null,
                    ),
                    StockLimitOrdersSection(
                      sessionId: widget.sessionId,
                      symbol: widget.symbol,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            CompanyBottomBar(
              price: currentPrice,
              isUp: isPositive,
              onBuy: () => context.push(
                '/stress-test/${widget.sessionId}/stock/${widget.symbol}/order',
                extra: {'type': 'buy', 'price': currentPrice},
              ),
              onSell: () => context.push(
                '/stress-test/${widget.sessionId}/stock/${widget.symbol}/order',
                extra: {'type': 'sell', 'price': currentPrice},
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 22),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 22,
              color: ThemeV2.textPrimary,
            ),
            onPressed: () => context.pop(),
            splashRadius: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.bookmark_border_rounded,
                size: 22,
                color: ThemeV2.textPrimary,
              ),
              splashRadius: 22,
              onPressed: () {
                /* TODO: bookmark */
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 22,
                color: ThemeV2.textPrimary,
              ),
              splashRadius: 22,
              onPressed: () {
                /* TODO: notifications */
              },
            ),
          ),
        ],
      ),
    );
  }
}
