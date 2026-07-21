// ---------------------------------------------------------------------------
// Stress Test Stock Detail Screen — stock detail (Block 2)
// ---------------------------------------------------------------------------
// Trading 212 style:
//   - Header: logo, name, ticker/exchange
//   - Price (large) + change badge
//   - Sparkline (CustomPainter, real price history) + period toggles (1D, 1W, 1M, 3M, 1Y, MAX)
//   - AVG PRICE dashed line on sparkline (if held)
//   - Open-price dashed reference line
//   - "Your Position" card (if held)
//   - Transaction History
//   - Bottom Buy / Sell buttons
// ---------------------------------------------------------------------------

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';

/// Sparkline periods
enum _SparkPeriod { d1, w1, m1, m3, y1, max }

/// Market session phases for UI display.
enum _MarketPhase { preMarket, regular, postMarket, closed }

_MarketPhase _currentMarketPhase() {
  final now = DateTime.now();
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    return _MarketPhase.closed;
  }
  final hour = now.hour;
  if (hour < 9 || hour >= 19) return _MarketPhase.closed;
  if (hour < 11) return _MarketPhase.preMarket;
  if (hour < 17) return _MarketPhase.regular;
  return _MarketPhase.postMarket;
}

({String label, String emoji, Color color}) _marketPhaseDisplay(
  _MarketPhase phase,
) {
  return switch (phase) {
    _MarketPhase.preMarket => (
      label: 'Pre-market',
      emoji: '🌅',
      color: const Color(0xFFE67E22),
    ),
    _MarketPhase.regular => (
      label: 'Open',
      emoji: '🟢',
      color: ThemeV2.success,
    ),
    _MarketPhase.postMarket => (
      label: 'After-hours',
      emoji: '🌆',
      color: const Color(0xFF8E44AD),
    ),
    _MarketPhase.closed => (
      label: 'Market closed',
      emoji: '🌙',
      color: ThemeV2.textSecondary,
    ),
  };
}

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
  _SparkPeriod _selectedPeriod = _SparkPeriod.m1;
  List<double> _rawPrices = [];
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

  void _generateSparkData() {
    final session = _session;
    if (session == null) return;

    // Sync period to available options for current duration
    final available = _availablePeriods(session);
    if (!available.contains(_selectedPeriod)) {
      _selectedPeriod = available.first;
    }

    final history = session.priceHistory[widget.symbol] ?? [];
    if (history.isEmpty) {
      // Fallback: flat line at current price
      final price =
          session.currentPrices[widget.symbol] ??
          session.basePrices[widget.symbol] ??
          100.0;
      setState(() {
        _rawPrices = [price, price];
        _chartReady = true;
      });
      return;
    }

    // Determine target point count for the selected period.
    // We downsample evenly if history has more points than needed.
    final targetCount = switch (_selectedPeriod) {
      _SparkPeriod.d1 => 24,
      _SparkPeriod.w1 => 30,
      _SparkPeriod.m1 => 60,
      _SparkPeriod.m3 => 90,
      _SparkPeriod.y1 => 120,
      _SparkPeriod.max => 200,
    };

    final sampled = _sampleData(history, targetCount);

    setState(() {
      _rawPrices = sampled;
      _chartReady = true;
    });
  }

  /// Evenly downsample [data] to at most [targetCount] points,
  /// always keeping the very last point as-is.
  List<double> _sampleData(List<double> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    final result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final idx = (i * step).floor();
      result.add(data[idx.clamp(0, data.length - 1)]);
    }
    result.last = data.last;
    return result;
  }

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  /// Returns available sparkline periods based on session duration.
  /// Fixed-length tests (week1/month1/months3) show their whole
  /// progressive set upfront — the test's total length is known. For
  /// Infinite/Custom, only periods that have actually elapsed so far are
  /// shown (no "3M" tab on a test that's 4 days old).
  List<_SparkPeriod> _availablePeriods(StressTestSession session) {
    return switch (session.duration) {
      TestDuration.week1 => [_SparkPeriod.d1, _SparkPeriod.w1],
      TestDuration.month1 => [
        _SparkPeriod.d1,
        _SparkPeriod.w1,
        _SparkPeriod.m1,
      ],
      TestDuration.months3 => [
        _SparkPeriod.d1,
        _SparkPeriod.w1,
        _SparkPeriod.m1,
        _SparkPeriod.m3,
      ],
      TestDuration.infinite ||
      TestDuration.custom => _elapsedGatedPeriods(session),
    };
  }

  static const Map<_SparkPeriod, Duration> _periodElapsedCutoffs = {
    _SparkPeriod.w1: Duration(days: 7),
    _SparkPeriod.m1: Duration(days: 30),
    _SparkPeriod.m3: Duration(days: 90),
    _SparkPeriod.y1: Duration(days: 365),
  };

  List<_SparkPeriod> _elapsedGatedPeriods(StressTestSession session) {
    final start = session.startedAt ?? session.createdAt;
    final elapsed = DateTime.now().difference(start);
    final periods = [_SparkPeriod.d1];
    for (final p in [
      _SparkPeriod.w1,
      _SparkPeriod.m1,
      _SparkPeriod.m3,
      _SparkPeriod.y1,
    ]) {
      if (elapsed >= _periodElapsedCutoffs[p]!) periods.add(p);
    }
    return periods;
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
    final session = ref
        .read(stressTestProvider.notifier)
        .getSession(widget.sessionId);
    if (session == null) return;

    final isHeld = session.holdings.any((h) => h.symbol == widget.symbol);
    final hasPrice =
        session.currentPrices.containsKey(widget.symbol) ||
        session.basePrices.containsKey(widget.symbol);

    if (!isHeld && !hasPrice) {
      try {
        final quote = await FinnhubService().quote(widget.symbol);
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
    final session = _session;
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: Text('Session not found')),
      );
    }

    final currentPrice =
        session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        0;
    final basePrice = session.basePrices[widget.symbol] ?? currentPrice;
    final priceChange = currentPrice - basePrice;
    final priceChangePercent = basePrice > 0
        ? (priceChange / basePrice) * 100
        : 0.0;
    final isPositive = priceChange >= 0;
    final holding = _findHolding(session);
    final logoAsync = ref.watch(cachedLogoProvider(widget.symbol));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Scrollable Content ──────────── Step 102 order ─
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Company Header (Steps 107–112)
                    _buildCompanyHeader(session, logoAsync),

                    // 2. Live Price Card (Steps 113–123)
                    _buildPriceCard(
                      session: session,
                      currentPrice: currentPrice,
                      priceChange: priceChange,
                      priceChangePercent: priceChangePercent,
                      isPositive: isPositive,
                    ),

                    // 3. Chart Card (Steps 124–140)
                    _buildChartCard(holding: holding),

                    // 4. Position Card (Steps 141–150)
                    if (holding != null) _buildPositionCard(holding, session),

                    // 5. Why Today Card (Steps 151–175)
                    _buildWhyTodayCard(
                      session: session,
                      priceChange: priceChange,
                      priceChangePercent: priceChangePercent,
                      isPositive: isPositive,
                    ),

                    // 6. Transaction History (Steps 176–182)
                    _buildTransactionHistory(session),

                    // Bottom safe gap for fixed buttons
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 7. Action Buttons (Steps 183–195) — fixed bottom
            _buildActionButtons(session),
          ],
        ),
      ),
    );
  }

  // ─── AppBar (Steps 103–106) ─────────────────────────────────────
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

  // ─── Company Header (Steps 107–112) ──────────────────────────────
  Widget _buildCompanyHeader(
    StressTestSession session,
    AsyncValue<String?> logoAsync,
  ) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: logoAsync.when(
              data: (url) =>
                  CompanyLogo(ticker: widget.symbol, logoUrl: url, radius: 32),
              error: (_, _) => CompanyLogo(ticker: widget.symbol, radius: 32),
              loading: () => CompanyLogo(ticker: widget.symbol, radius: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_companyName(widget.symbol), style: ThemeV2.title),
                const SizedBox(height: 4),
                Text('${widget.symbol} · NYSE', style: ThemeV2.caption),
              ],
            ),
          ),
          // Sector Badge (Step 112)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeV2.primaryBg,
              borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            ),
            child: Text(
              _sectorName(widget.symbol),
              style: ThemeV2.small.copyWith(
                color: ThemeV2.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Live Price Card (Steps 113–123) ─────────────────────────────
  Widget _buildPriceCard({
    required StressTestSession session,
    required double currentPrice,
    required double priceChange,
    required double priceChangePercent,
    required bool isPositive,
  }) {
    final phase = _currentMarketPhase();
    final phaseInfo = _marketPhaseDisplay(phase);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: ThemeV2.borderRadiusLarge,
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Price row (Steps 113–116) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtFull(currentPrice), style: ThemeV2.displayXL),
              const SizedBox(width: 10),
              // Change capsule (Step 115)
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isPositive ? ThemeV2.successBg : ThemeV2.lossBg,
                  borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${isPositive ? '+' : ''}${_fmtFull(priceChange)} '
                  '(${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%)',
                  style: ThemeV2.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPositive ? ThemeV2.success : ThemeV2.loss,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Market status + Why today (Steps 117–123) ──
          Row(
            children: [
              // Market status
              GestureDetector(
                onTap: () => _showMarketHoursSheet(),
                child: Row(
                  children: [
                    Text(phaseInfo.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      phaseInfo.label,
                      style: ThemeV2.caption.copyWith(
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
              const Spacer(),
              // "Why today?" button (Steps 118–120) — Filled Tonal
              FilledButton.tonal(
                onPressed: () => context.push(
                  '/stress-test/${widget.sessionId}/stock/${widget.symbol}/why',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeV2.primaryBg,
                  foregroundColor: ThemeV2.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
                  ),
                  textStyle: ThemeV2.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 14),
                    SizedBox(width: 6),
                    Text('Why today?'),
                  ],
                ),
              ),
            ],
          ),
          // Last Updated (Step 123)
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_fmtTime(DateTime.now())}',
            style: ThemeV2.small.copyWith(
              color: ThemeV2.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chart Card (Steps 124–140) ──────────────────────────────────
  Widget _buildChartCard({StressTestHolding? holding}) {
    if (!_chartReady || _rawPrices.isEmpty) {
      return Container(
        height: 280,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: ThemeV2.borderRadiusLarge,
          boxShadow: ThemeV2.cardShadow,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isUp = _rawPrices.last >= _rawPrices.first;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final openPrice = _rawPrices.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: ThemeV2.borderRadiusLarge,
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Sparkline (Steps 127–131) ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: 200,
            child: ClipRect(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _SparklinePainter(
                  prices: _rawPrices,
                  avgPrice: holding?.averagePrice,
                  lineColor: lineColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // O: and AVG labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _techLabelV2('O:', openPrice),
                if (holding != null) ...[
                  const SizedBox(width: 16),
                  _techLabelV2('AVG', holding.averagePrice),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Period Capsule Toggles (Steps 136–140) ──
          _buildPeriodCapsules(),
        ],
      ),
    );
  }

  Widget _techLabelV2(String prefix, double price) {
    return Text(
      '$prefix ${_fmtFull(price)}',
      style: ThemeV2.small.copyWith(
        color: ThemeV2.textSecondary.withValues(alpha: 0.7),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  // ─── Period Capsule Toggles (Steps 136–140) ─────────────────────
  Widget _buildPeriodCapsules() {
    final session = _session;
    if (session == null) return const SizedBox.shrink();

    final periods = _availablePeriods(session);
    const labels = {
      _SparkPeriod.d1: '1D',
      _SparkPeriod.w1: '1W',
      _SparkPeriod.m1: '1M',
      _SparkPeriod.m3: '3M',
      _SparkPeriod.y1: '1Y',
      _SparkPeriod.max: 'ALL',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: periods.map((period) {
        final isActive = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () {
              if (_selectedPeriod != period) {
                setState(() => _selectedPeriod = period);
                _generateSparkData();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? ThemeV2.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
              ),
              child: Text(
                labels[period]!,
                style: ThemeV2.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? ThemeV2.primary : ThemeV2.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Position Card (Steps 141–150) ───────────────────────────────
  Widget _buildPositionCard(
    StressTestHolding holding,
    StressTestSession session,
  ) {
    final pnl = session.positionPnL[widget.symbol] ?? 0.0;
    final isProfitPositive = pnl >= 0;
    final costBasis = holding.shares * holding.avgCost;
    final positionValue = costBasis + pnl;

    return Container(
      height: 150,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: ThemeV2.borderRadiusLarge,
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Column(
        children: [
          // Row 1: VALUE | P&L
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _positionMetric(
                    label: 'VALUE',
                    value: _fmtFull(positionValue),
                  ),
                ),
                Expanded(
                  child: _positionMetric(
                    label: 'P&L',
                    value:
                        '${isProfitPositive ? '+' : ''}${_fmtFull(pnl.abs())}',
                    valueColor: isProfitPositive
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ThemeV2.divider),
          // Row 2: SHARES | AVG PRICE
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _positionMetric(
                    label: 'SHARES',
                    value: holding.shares.toStringAsFixed(2),
                  ),
                ),
                Expanded(
                  child: _positionMetric(
                    label: 'AVG PRICE',
                    value: _fmtFull(holding.averagePrice),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionMetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeV2.caption.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: ThemeV2.title.copyWith(
            color: valueColor ?? ThemeV2.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  // ─── Why Today Card (Steps 151–175) ──────────────────────────────
  Widget _buildWhyTodayCard({
    required StressTestSession session,
    required double priceChange,
    required double priceChangePercent,
    required bool isPositive,
  }) {
    final tickLog = session.explanationLog[widget.symbol];
    final latest = tickLog?.isNotEmpty == true ? tickLog!.last : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'WHY TODAY',
            style: ThemeV2.section.copyWith(
              color: ThemeV2.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          // Price change summary
          Text(
            '${isPositive ? '+' : ''}${_fmtFull(priceChange)} '
            '(${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%)',
            style: ThemeV2.displayL.copyWith(
              color: isPositive ? ThemeV2.success : ThemeV2.loss,
            ),
          ),
          const SizedBox(height: 20),
          // Factor bars
          if (latest != null) ...[
            _factorBar(
              'Market',
              latest.contributions.marketPct / 100,
              FomoShieldTheme.factorMarket,
            ),
            const SizedBox(height: 10),
            _factorBar(
              'Sector',
              latest.contributions.sectorPct / 100,
              FomoShieldTheme.factorSector,
            ),
            const SizedBox(height: 10),
            _factorBar(
              'Company',
              latest.contributions.companyPct / 100,
              FomoShieldTheme.factorCompany,
            ),
            const SizedBox(height: 10),
            _factorBar(
              'News',
              latest.contributions.newsPct / 100,
              FomoShieldTheme.factorNews,
            ),
            const SizedBox(height: 10),
            _factorBar(
              'Noise',
              latest.contributions.noisePct / 100,
              FomoShieldTheme.factorNoise,
            ),
          ] else ...[
            _factorBar('Market', 0.40, FomoShieldTheme.factorMarket),
            const SizedBox(height: 10),
            _factorBar('Sector', 0.25, FomoShieldTheme.factorSector),
            const SizedBox(height: 10),
            _factorBar('Company', 0.15, FomoShieldTheme.factorCompany),
            const SizedBox(height: 10),
            _factorBar('News', 0.12, FomoShieldTheme.factorNews),
            const SizedBox(height: 10),
            _factorBar('Noise', 0.08, FomoShieldTheme.factorNoise),
          ],
          const SizedBox(height: 16),
          // Explanation text
          Text(
            _defaultExplanation(isPositive),
            style: ThemeV2.body.copyWith(
              height: 1.5,
              color: ThemeV2.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Guardian row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            ),
            child: Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guardian insight available — tap "Why today?" for full analysis',
                    style: ThemeV2.small.copyWith(color: ThemeV2.textSecondary),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: ThemeV2.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _factorBar(String label, double fraction, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: ThemeV2.small.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeV2.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ThemeV2.radiusSmall / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                  borderRadius: BorderRadius.circular(6),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${(fraction * 100).round()}%',
            style: ThemeV2.small.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeV2.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  String _defaultExplanation(bool isPositive) {
    return isPositive
        ? 'Market sentiment is positive today. Broad market strength and '
              'sector tailwinds are driving this asset higher. Company-specific '
              'news adds extra momentum.'
        : 'Market pressure is weighing on this asset. A combination of '
              'sector rotation and company-specific headwinds explains today\'s '
              'decline. Noise accounts for some volatility.';
  }

  Widget _buildTransactionHistory(StressTestSession session) {
    final symbolTrades =
        session.trades.where((t) => t.symbol == widget.symbol).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final displayTrades = symbolTrades.take(5).toList();
    final hasMore = symbolTrades.length > 5;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: ThemeV2.borderRadiusLarge,
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSACTION HISTORY',
            style: ThemeV2.small.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeV2.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          if (displayTrades.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No transactions yet',
                style: ThemeV2.body.copyWith(
                  color: ThemeV2.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            ...displayTrades.map((t) => _buildTradeCard(t, session)),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to full trade list (future)
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeV2.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      'See All (${symbolTrades.length})',
                      style: ThemeV2.small.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeCard(StressTestTrade trade, StressTestSession session) {
    final day = session.startedAt != null
        ? (trade.date.difference(session.startedAt!).inDays + 1)
        : 0;
    final isBuy = trade.isBuy;
    final totalAmount = trade.shares * trade.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeV2.background,
        borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
      ),
      child: Row(
        children: [
          // Left: BUY/SELL badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isBuy
                  ? ThemeV2.success.withValues(alpha: 0.12)
                  : ThemeV2.loss.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isBuy ? 'BUY' : 'SELL',
              style: ThemeV2.small.copyWith(
                fontWeight: FontWeight.w700,
                color: isBuy ? ThemeV2.success : ThemeV2.loss,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Middle: shares
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? '+' : '-'}${trade.shares.toStringAsFixed(4)} ${widget.symbol}',
                  style: ThemeV2.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Day $day', style: ThemeV2.small),
              ],
            ),
          ),
          // Right: date + amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtDate(trade.date), style: ThemeV2.small),
              const SizedBox(height: 2),
              Text(
                _fmtFull(totalAmount),
                style: ThemeV2.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons (Steps 183–195) ──────────────────────────────
  Widget _buildActionButtons(StressTestSession session) {
    final currentPrice =
        session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        0;
    final hasShares = _findHolding(session) != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Buy button (Steps 185–190)
            Expanded(
              child: _ActionButton(
                label: 'Buy',
                color: ThemeV2.primary,
                onPressed: () {
                  context.push(
                    '/stress-test/${widget.sessionId}/stock/${widget.symbol}/order',
                    extra: {'type': 'buy', 'price': currentPrice},
                  );
                },
              ),
            ),
            if (hasShares) ...[
              const SizedBox(width: 12),
              // Sell button
              Expanded(
                child: _ActionButton(
                  label: 'Sell',
                  color: ThemeV2.loss,
                  onPressed: () {
                    context.push(
                      '/stress-test/${widget.sessionId}/stock/${widget.symbol}/order',
                      extra: {'type': 'sell', 'price': currentPrice},
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Show market hours bottom sheet (Revolut-style).
  void _showMarketHoursSheet() {
    final currentPhase = _currentMarketPhase();

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                MediaQuery.of(ctx).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ThemeV2.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Market Hours', style: ThemeV2.section),
                  const SizedBox(height: 6),
                  Text(
                    'Trading schedule for simulated market engine',
                    style: ThemeV2.caption,
                  ),
                  const SizedBox(height: 20),
                  // Session rows
                  _marketHourRow(
                    emoji: '🌅',
                    label: 'Pre-market',
                    time: '09:00 – 10:59',
                    desc: 'Low volatility, sleepy price action',
                    isActive: currentPhase == _MarketPhase.preMarket,
                  ),
                  const SizedBox(height: 12),
                  _marketHourRow(
                    emoji: '🟢',
                    label: 'Main session',
                    time: '11:00 – 16:59',
                    desc: 'Full activity, maximum volatility',
                    isActive: currentPhase == _MarketPhase.regular,
                  ),
                  const SizedBox(height: 12),
                  _marketHourRow(
                    emoji: '🌆',
                    label: 'After-hours',
                    time: '17:00 – 18:59',
                    desc: 'Fading activity, noise dies down',
                    isActive: currentPhase == _MarketPhase.postMarket,
                  ),
                  const SizedBox(height: 12),
                  _marketHourRow(
                    emoji: '🌙',
                    label: 'Market closed',
                    time: '19:00 – 08:59',
                    desc: 'No trading, weekend included',
                    isActive: currentPhase == _MarketPhase.closed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Single row in market hours sheet.
  Widget _marketHourRow({
    required String emoji,
    required String label,
    required String time,
    required String desc,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? ThemeV2.primaryBg : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
        border: isActive
            ? Border.all(
                color: ThemeV2.primary.withValues(alpha: 0.25),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: ThemeV2.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive ? ThemeV2.primary : ThemeV2.textPrimary,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeV2.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NOW',
                          style: ThemeV2.small.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ThemeV2.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: ThemeV2.caption.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 1),
                Text(desc, style: ThemeV2.small),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }

  String _companyName(String symbol) {
    const names = <String, String>{
      'AAPL': 'Apple',
      'MSFT': 'Microsoft',
      'GOOGL': 'Alphabet',
      'GOOG': 'Alphabet',
      'AMZN': 'Amazon',
      'META': 'Meta',
      'NVDA': 'NVIDIA',
      'TSLA': 'Tesla',
      'AMD': 'AMD',
      'INTC': 'Intel',
      'CRM': 'Salesforce',
      'ADBE': 'Adobe',
      'NFLX': 'Netflix',
      'CSCO': 'Cisco',
      'ORCL': 'Oracle',
      'IBM': 'IBM',
      'QCOM': 'Qualcomm',
      'TXN': 'Texas Instruments',
      'AVGO': 'Broadcom',
      'MU': 'Micron',
      'JPM': 'JPMorgan Chase',
      'BAC': 'Bank of America',
      'C': 'Citigroup',
      'GS': 'Goldman Sachs',
      'MS': 'Morgan Stanley',
      'WFC': 'Wells Fargo',
      'AXP': 'American Express',
      'V': 'Visa',
      'MA': 'Mastercard',
      'BLK': 'BlackRock',
      'SCHW': 'Charles Schwab',
      'PYPL': 'PayPal',
      'JNJ': 'Johnson & Johnson',
      'PFE': 'Pfizer',
      'UNH': 'UnitedHealth',
      'ABBV': 'AbbVie',
      'MRK': 'Merck',
      'ABT': 'Abbott',
      'LLY': 'Eli Lilly',
      'MDT': 'Medtronic',
      'BMY': 'Bristol-Myers',
      'AMGN': 'Amgen',
      'KO': 'Coca-Cola',
      'PEP': 'PepsiCo',
      'PG': 'Procter & Gamble',
      'WMT': 'Walmart',
      'COST': 'Costco',
      'MO': 'Altria',
      'CL': 'Colgate',
      'KMB': 'Kimberly-Clark',
      'SYY': 'Sysco',
      'GIS': 'General Mills',
      'NOVA': 'NovaGenix',
      'ZEN': 'Zenith AI',
      'AURA': 'Aura Energy',
      'VERT': 'VertiCarbon',
      'CORE': 'CoreVault',
      'MORF': 'Morphic Labs',
      'DRIF': 'Drift Auto',
      'PULS': 'Pulse Health',
      'CASP': 'Caspian Data',
      'NEXO': 'NexoGene',
    };
    return names[symbol] ?? symbol;
  }

  /// Full currency format — NEVER compact (4.67K, 1.5M). Always $X,XXX.XX
  String _fmtFull(double v) {
    return NumberFormat.currency(locale: 'en_US', symbol: r'$').format(v);
  }

  /// Date formatter: "Jan 15"
  String _fmtDate(DateTime d) {
    return DateFormat('MMM d').format(d);
  }

  /// Time formatter: "14:30"
  String _fmtTime(DateTime d) {
    return DateFormat('HH:mm').format(d);
  }

  /// Sector name from symbol (Step 112)
  String _sectorName(String symbol) {
    const tech = {
      'AAPL',
      'MSFT',
      'GOOGL',
      'GOOG',
      'AMZN',
      'META',
      'NVDA',
      'AMD',
      'INTC',
      'CRM',
      'ADBE',
      'NFLX',
      'CSCO',
      'ORCL',
      'IBM',
      'QCOM',
      'TXN',
      'AVGO',
      'MU',
    };
    const finance = {
      'JPM',
      'BAC',
      'C',
      'GS',
      'MS',
      'WFC',
      'AXP',
      'V',
      'MA',
      'BLK',
      'SCHW',
      'PYPL',
    };
    const healthcare = {
      'JNJ',
      'PFE',
      'UNH',
      'ABBV',
      'MRK',
      'ABT',
      'LLY',
      'MDT',
      'BMY',
      'AMGN',
    };
    const consumer = {
      'KO',
      'PEP',
      'PG',
      'WMT',
      'COST',
      'MO',
      'CL',
      'KMB',
      'SYY',
      'GIS',
    };
    if (tech.contains(symbol)) return 'Technology';
    if (finance.contains(symbol)) return 'Finance';
    if (healthcare.contains(symbol)) return 'Healthcare';
    if (consumer.contains(symbol)) return 'Consumer';
    if (['TSLA', 'DRIF'].contains(symbol)) return 'Automotive';
    if (['NOVA', 'ZEN', 'MORF', 'PULS', 'NEXO'].contains(symbol))
      return 'Biotech';
    if (['AURA', 'VERT'].contains(symbol)) return 'Energy';
    if (['CORE', 'CASP'].contains(symbol)) return 'Tech';
    return 'Other';
  }
}

// ── Action Button (Steps 183–195) ────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: ThemeV2.body.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Painter for sparkline ────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> prices;
  final double? avgPrice;
  final Color lineColor;

  _SparklinePainter({
    required this.prices,
    this.avgPrice,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    const topPad = 20.0;
    const bottomPad = 24.0;
    const leftPad = 12.0;
    const rightPad = 12.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final range = maxPrice - minPrice;

    // Map price to Y (min → bottom+pad, max → top+pad)
    double yPrice(double p) {
      if (range == 0) return size.height / 2;
      return topPad + chartH * (1 - (p - minPrice) / range);
    }

    // Map index to X
    double xIdx(int i) {
      return leftPad + (i / (prices.length - 1)) * chartW;
    }

    // ── Dashed open‑price line (from first point → right edge) ──
    final openPrice = prices.first;
    final openY = yPrice(openPrice);
    final dashPaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      leftPad,
      openY,
      size.width - rightPad,
      openY,
      dashPaint,
    );

    final labelStyle = TextStyle(
      color: ThemeV2.textSecondary.withValues(alpha: 0.5),
      fontSize: 9,
      fontWeight: FontWeight.w400,
    );

    // ── AVG PRICE dashed line (label moved below chart) ──
    if (avgPrice != null &&
        avgPrice! >= minPrice * 0.995 &&
        avgPrice! <= maxPrice * 1.005) {
      final avgY = yPrice(avgPrice!);
      final avgPaint = Paint()
        ..color = ThemeV2.textSecondary.withValues(alpha: 0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      _drawDashedLine(
        canvas,
        leftPad,
        avgY,
        size.width - rightPad,
        avgY,
        avgPaint,
      );
    }

    // ── Price line (straight segments, NO Bezier) ──
    final path = Path();
    path.moveTo(xIdx(0), yPrice(prices[0]));
    for (int i = 1; i < prices.length; i++) {
      path.lineTo(xIdx(i), yPrice(prices[i]));
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // ── Gradient fill below the line ──
    final fillPath = Path.from(path);
    final lastX = xIdx(prices.length - 1);
    fillPath.lineTo(lastX, size.height);
    fillPath.lineTo(xIdx(0), size.height);
    fillPath.close();

    final gradient = ui.Gradient.linear(
      Offset(0, topPad),
      Offset(0, size.height - bottomPad),
      [lineColor.withValues(alpha: 0.12), lineColor.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // ── MIN price dashed line + label ──
    final minY = yPrice(minPrice);
    final minLinePaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      leftPad,
      minY,
      size.width - rightPad,
      minY,
      minLinePaint,
    );

    final minLabel = TextPainter(
      text: TextSpan(
        text: '\$${minPrice.toStringAsFixed(2)}',
        style: labelStyle.copyWith(
          color: ThemeV2.textSecondary.withValues(alpha: 0.5),
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    minLabel.paint(canvas, Offset(leftPad + 2, minY + 2));

    // ── MAX price label (top right) ──
    final maxY = yPrice(maxPrice);
    final maxLinePaint = Paint()
      ..color = ThemeV2.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      leftPad,
      maxY,
      size.width - rightPad,
      maxY,
      maxLinePaint,
    );

    // ── MAX label: below dashed line, larger font (Revolut style) ──
    final maxLabelStyle = TextStyle(
      color: ThemeV2.textPrimary.withValues(alpha: 0.65),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    final maxLabel = TextPainter(
      text: TextSpan(
        text: '\$${maxPrice.toStringAsFixed(2)}',
        style: maxLabelStyle,
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    maxLabel.paint(
      canvas,
      Offset(size.width - rightPad - maxLabel.width - 2, maxY + 3),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    double x1,
    double y1,
    double x2,
    double y2,
    Paint paint,
  ) {
    const dashLen = 4.0;
    const gapLen = 4.0;
    final dx = x2 - x1;
    final dy = y2 - y1;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    double drawn = 0;
    bool dash = true;
    double cx = x1, cy = y1;
    while (drawn < dist) {
      final remaining = dist - drawn;
      final segment = dash ? min(dashLen, remaining) : min(gapLen, remaining);
      if (dash) {
        canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + ux * segment, cy + uy * segment),
          paint,
        );
      }
      cx += ux * segment;
      cy += uy * segment;
      drawn += segment;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return old.prices != prices ||
        old.avgPrice != avgPrice ||
        old.lineColor != lineColor;
  }
}
