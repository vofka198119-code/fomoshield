// ---------------------------------------------------------------------------
// Stress Test Main Screen — Portfolio-style Redesign
// ---------------------------------------------------------------------------
// Uses card layout matching main portfolio design:
//   Card 1 – Dynamic allocation donut chart (fl_chart)
//   Card 2 – Balance summary (Total Value, P&L, Cash)
//   Card 3 – Holdings (4 visible + MORE) with logos and BUY/SELL
//   Card 4 – Corporate events (ex-div dates, dividends, popup)
//   Card 5 – Trade history (last 10, reversed)
//   Timer card at bottom
//   Analytics card → navigates to full analytics screen
//   Disclaimer footer
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/widgets/company_logo.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../shared/widgets/corporate_events.dart';
import '../../shared/widgets/disclaimer_footer.dart';

import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import '../../shared/widgets/psychology_meter.dart';
import '../../shared/widgets/market_timeline.dart';
import '../../shared/widgets/verdict_card.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';
import 'stress_test_widget_order_provider.dart';

class StressTestScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const StressTestScreen({super.key, required this.sessionId});

  @override
  ConsumerState<StressTestScreen> createState() => _StressTestScreenState();
}

class _StressTestScreenState extends ConsumerState<StressTestScreen> {
  Timer? _timer;
  Timer? _countdownTimer;
  Timer? _timelineTimer;
  int _tick = 0;
  bool _showAllAssets = false;
  bool _showAllTrades = false;

  @override
  void initState() {
    super.initState();
    // ── Sandbox Isolation (Step 1): Session ID is already passed via
    // GoRouter path parameter → widget.sessionId. Screen uses
    // ref.watch(stressTestSessionProvider(widget.sessionId)) which is
    // 100% isolated and deterministic — no global state, no race.
    // refreshPrices() → _catchUp() → _simulateCurrentPrices() writes to the
    // StressTestNotifier's state synchronously. Calling it directly here
    // hits Riverpod's "Tried to modify a provider while the widget tree
    // was building" error on every (re)open of this screen, since initState
    // runs mid-build. Deferred via addPostFrameCallback so it runs only
    // after the current frame has fully built — matches the pattern already
    // used below for the ad-counter check and the periodic refresh timer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(stressTestProvider.notifier).refreshPrices(widget.sessionId);
      }
    });
    // Check open counter for ad (every 6th opening for free users past 1st test)
    Future.microtask(() {
      if (!mounted) return;
      final tier = ref.read(subscriptionTierProvider);
      if (tier == SubscriptionTier.free) {
        final showAd = ref
            .read(stressTestProvider.notifier)
            .checkAndIncrementOpenCounter();
        if (showAd) {
          showPremiumPromoOverlay(
            context: context,
            title: 'Stress test access',
            durationSeconds: 5,
            onComplete: () {
              if (context.mounted) showMonetizationModal(context, ref);
            },
          );
        }
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        ref.read(stressTestProvider.notifier).refreshPrices(widget.sessionId);
        ref.read(stressTestRefreshProvider.notifier).state++;
      }
    });
    // 1-second tick for real-time countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _tick++);
      }
    });
    // ── Sandbox Isolation (Step 2): Per-session timeline tick ──
    // Each session gets its own tick counter, ensuring epoch progress
    // updates independently — no cross-session timeline leakage.
    _timelineTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.read(timelineTickProvider(widget.sessionId).notifier).state++;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _timelineTimer?.cancel();
    super.dispose();
  }

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  void _onAssetRowTap(String symbol) {
    final session = _session;
    if (session == null) return;
    final holding = session.holdings.firstWhere(
      (h) => h.symbol == symbol,
      orElse: () => const StressTestHolding(
        symbol: '',
        shares: 0,
        avgCost: 0,
        entryPrice: 0,
        cachedLogoUrl: null,
      ),
    );
    if (holding.symbol.isEmpty) return;
    final currentPrice = session.currentPrices[symbol] ?? holding.entryPrice;
    context.push(
      '/stress-test/${widget.sessionId}/stock/$symbol',
      extra: {
        'source': 'stress-test',
        'averagePrice': holding.averagePrice,
        'quantity': holding.shares,
        'currentPrice': currentPrice,
        'cachedLogoUrl': holding.cachedLogoUrl,
      },
    );
  }

  void _openAddAssetSheet() {
    context.push(
      '/search',
      extra: {'source': 'stress-test', 'sessionId': widget.sessionId},
    );
  }

  void _showVerdict() {
    _showDisclaimerModal().then((accepted) {
      if (accepted == true && mounted) {
        context.push('/stress-test/${widget.sessionId}/verdict');
      }
    });
  }

  Future<bool?> _showDisclaimerModal() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => const _DisclaimerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    // ── Sandbox Isolation (Step 2): Watch per-session timeline tick ──
    ref.watch(timelineTickProvider(widget.sessionId));
    final session = ref.watch(stressTestSessionProvider(widget.sessionId));
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 64,
          centerTitle: true,
          title: Text(
            'STRESS TEST PORTFOLIO',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeV2.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: const Center(child: Text('Session not found')),
      );
    }

    final isCompleted = session.status == StressTestStatus.completed;
    final isActive = session.status == StressTestStatus.active;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 64,
        centerTitle: true,
        title: Text(
          'STRESS TEST PORTFOLIO',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.go('/stress-test-hub'),
        ),
        actions: [],
      ),
      body: isCompleted
          ? _buildCompletedView(session)
          : isActive
          ? (session.holdings.isEmpty && session.trades.isEmpty
                ? _buildActiveEmptyView()
                : _buildActiveView(session))
          : _buildSetupView(session),
    );
  }

  // ── Setup View ───────────────────────────────────────────────────

  Widget _buildSetupView(StressTestSession session) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            color: ThemeV2.textSecondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Test not started yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back to setup and start the test',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.push('/stress-test/${widget.sessionId}/setup'),
            child: const Text('Go to Setup'),
          ),
        ],
      ),
    );
  }

  // ── Startup Empty View — shown when no trades have been made yet ──

  Widget _buildActiveEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openAddAssetSheet,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeV2.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: ThemeV2.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Building Your Portfolio',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the + button to search stocks\nand add your first position.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ThemeV2.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Active View — Portfolio-style Redesign ─────────────────────

  Duration? _getTestDuration(StressTestSession session) {
    if (session.duration == TestDuration.infinite) {
      return infiniteMinDuration;
    }
    if (session.duration == TestDuration.custom) {
      if (session.customDurationDays != null &&
          session.customDurationDays! > 0) {
        return Duration(days: session.customDurationDays!);
      }
      return null;
    }
    return session.duration.totalDuration;
  }

  bool _isExpired(StressTestSession session) {
    final total = _getTestDuration(session);
    if (total == null || session.startedAt == null) return false;
    return DateTime.now().difference(session.startedAt!) >= total;
  }

  Widget _buildActiveView(StressTestSession session) {
    final isExpired = _isExpired(session);
    final widgetConfigs = ref.watch(
      stressTestWidgetOrderProvider(widget.sessionId),
    );
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return RefreshIndicator(
      color: ThemeV2.primary,
      backgroundColor: ThemeV2.surface,
      onRefresh: () async {
        ref.read(stressTestProvider.notifier).refreshPrices(widget.sessionId);
        ref.read(stressTestRefreshProvider.notifier).state++;
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Market Status Card ────────────────────────
            // Always at top, not reorderable.
            _buildMarketStatusCard(session),
            const SizedBox(height: 12),

            // ── IPO Alert ──────────────────────────────────────
            // Always at top when present, not reorderable.
            if (session.companies.values.any(
              (c) => c.ipoPhase != CompanyIpoPhase.none,
            )) ...[
              for (final company in session.companies.values.where(
                (c) => c.ipoPhase != CompanyIpoPhase.none,
              ))
                _buildIpoAlert(company),
              const SizedBox(height: 12),
            ],

            // ── Verdict / Exit button ──────────────────────────
            // Always at top when applicable, not reorderable.
            if (isExpired)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showVerdict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'GET PSYCHOLOGIST VERDICT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            if (isExpired) const SizedBox(height: 12),

            // ── Allocation chart (always above dynamic widgets) ──
            _buildAllocationChart(session),
            const SizedBox(height: 14),

            // ── Dynamic widgets (reorderable via gear icon) ──
            for (final cfg in visibleWidgets) ...[
              if (cfg.id != 'allocation_chart')
                _buildWidgetById(cfg.id, session),
              if (cfg.id != 'allocation_chart') const SizedBox(height: 12),
            ],

            const SizedBox(height: 4),

            // ── Add widgets button ───────────────────────────
            Center(
              child: TextButton.icon(
                onPressed: _showWidgetSettingsSheet,
                icon: const Icon(
                  Icons.add_rounded,
                  color: ThemeV2.primary,
                  size: 20,
                ),
                label: Text(
                  'Add widgets',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: ThemeV2.primary, width: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Disclaimer (always at bottom) ────────────────
            const DisclaimerFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Dispatch method — builds a widget by its config id.
  /// Returns [SizedBox.shrink] if the widget's conditions aren't met.
  Widget _buildWidgetById(String id, StressTestSession session) {
    switch (id) {
      case 'psychology_meter':
        return PsychologyMeter(data: PsychologyMeterData.fromSession(session));
      case 'allocation_chart':
        return const SizedBox.shrink();
      case 'my_assets':
        return _buildMyAssetsSection();
      case 'market_timeline':
        if (session.epochHistory.isEmpty) return const SizedBox.shrink();
        // ── Step 1: Reactive timeline snapshot (deterministic epoch math) ──
        final timelineSnapshot = ref.watch(
          timelineSnapshotProvider(widget.sessionId),
        );
        final epochIndex =
            timelineSnapshot?.activeEpochIndex ??
            MarketTimeline.findCurrentEpoch(session.epochHistory);
        final epochProgress = timelineSnapshot?.progressFraction;
        return _buildSectionCard(
          title: '',
          noInnerPadding: true,
          child: MarketTimeline(
            epochs: session.epochHistory,
            currentEpochIndex: epochIndex,
            activeEpochProgress: epochProgress,
          ),
        );
      case 'corporate_events':
        if (session.holdings.isEmpty) return const SizedBox.shrink();
        return _buildSectionCard(
          title: '',
          noInnerPadding: true,
          child: CorporateEventsWidget(holdings: session.holdings),
        );
      case 'trade_history':
        if (session.trades.isEmpty) return const SizedBox.shrink();
        final allTrades = session.trades.reversed.toList();
        final displayTrades = _showAllTrades
            ? allTrades
            : allTrades.take(10).toList();
        return _buildSectionCard(
          title: 'TRADE HISTORY',
          child: Column(
            children: [
              ...displayTrades.map((t) => _buildTradeTile(t)),
              if (allTrades.length > 10) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showAllTrades = !_showAllTrades),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ThemeV2.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _showAllTrades
                            ? 'Less'
                            : 'More (${allTrades.length - 10})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      case 'timer':
        return _buildTimerBar(session);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Opens the widget settings bottom sheet (reorder + show/hide).
  void _showWidgetSettingsSheet() {
    final notifier = ref.read(
      stressTestWidgetOrderProvider(widget.sessionId).notifier,
    );
    final currentConfigs = ref.read(
      stressTestWidgetOrderProvider(widget.sessionId),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => _StressTestWidgetSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
      ),
    );
  }

  /// Portfolio-style card wrapper matching main portfolio design.
  /// Adds subtle left accent border with stressAccent for visual distinction.
  /// [noInnerPadding] — set true for children that have their own internal
  /// container/padding (e.g. StressHoldingsWidget, CorporateEventsWidget).
  Widget _buildSectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
    bool noInnerPadding = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(ThemeV2.radiusLarge),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: FomoShieldTheme.cardTitle(),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          if (!noInnerPadding)
            Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: ThemeV2.divider,
            ),
          if (noInnerPadding)
            child
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
        ],
      ),
    );
  }

  /// Full number format with commas and fixed 2 decimals — e.g. $15,000.00
  String _fmtFull(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intStr = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
      buf.write(intStr[i]);
    }
    buf.write('.');
    buf.write(parts[1]);
    return buf.toString();
  }

  // ── Donut Chart with centered portfolio metrics ──────────────────────

  /// Generates a deterministic distinct color for any index using
  /// golden-angle hue distribution — unlimited unique colors.
  static Color _allocationColor(int index) {
    const double goldenAngle = 137.508; // degrees
    final hue = (index * goldenAngle) % 360.0;
    // Slightly vary saturation & lightness to keep colours vibrant
    final saturation = 55.0 + (index % 3) * 10.0;
    final lightness = 40.0 + (index % 2) * 8.0;
    return HSLColor.fromAHSL(
      1.0,
      hue,
      saturation / 100,
      lightness / 100,
    ).toColor();
  }

  /// Market Status Card — Steps 50–54.
  /// Replaces the old HeroBlock + Guardian. Height 92 px.
  /// Shows market icon, phase name, description, and temperature badge.
  Widget _buildMarketStatusCard(StressTestSession session) {
    final phase = session.devMarketPhase;
    final temp = session.devMarketTemperature;
    final isBull = temp >= 0;
    final phaseLabel = phase.isNotEmpty
        ? '${phase[0].toUpperCase()}${phase.substring(1)}'
        : 'Unknown';

    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(ThemeV2.radiusLarge),
        boxShadow: ThemeV2.cardShadow,
      ),
      child: Row(
        children: [
          // Market icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isBull ? ThemeV2.success : ThemeV2.loss).withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            ),
            alignment: Alignment.center,
            child: Icon(
              isBull ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: isBull ? ThemeV2.success : ThemeV2.loss,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Phase name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phaseLabel,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBull ? 'Optimism is high' : 'Caution is warranted',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Temperature badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeV2.primaryBg,
              borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Temperature',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ThemeV2.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isBull ? '+' : ''}$temp',
                  style: interNums(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Thin elegant donut chart with portfolio metrics centered inside the ring.
  /// Steps 56–62: 240×240, ring thickness 18, animation 400ms, cash capsule below.
  Widget _buildAllocationChart(StressTestSession session) {
    final holdings = session.holdings;
    final isEmpty = holdings.isEmpty;

    // Calculate total invested value per holding (shares * current price)
    final invested = <({String symbol, double value})>[];
    double totalInvested = 0;
    for (final h in holdings) {
      final price = session.currentPrices[h.symbol] ?? h.entryPrice;
      final val = h.shares * price;
      invested.add((symbol: h.symbol, value: val));
      totalInvested += val;
    }
    invested.sort((a, b) => b.value.compareTo(a.value));

    final hasData = !isEmpty && totalInvested > 0;

    // ── Portfolio metrics for the center ──────────────────────────
    final portfolioTotal = session.totalValue;
    final pnl = session.profitLoss;
    final pnlPercent = session.profitLossPercent;
    final isPositive = pnl >= 0;
    final isZero = pnl == 0;
    final pnlColor = isZero
        ? ThemeV2.textSecondary
        : isPositive
        ? ThemeV2.success
        : ThemeV2.loss;
    final pnlText = isZero
        ? '\$0.00'
        : '${isPositive ? '+' : ''}\$${_fmtFull(pnl.abs())} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: hasData
                    ? PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 102,
                          sections: List.generate(invested.length, (i) {
                            final item = invested[i];
                            final share = item.value / totalInvested;
                            return PieChartSectionData(
                              value: share * 100,
                              title: '',
                              radius: 12,
                              color: _allocationColor(i),
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 400),
                      )
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 102,
                          sections: [
                            PieChartSectionData(
                              value: 100,
                              title: '',
                              radius: 12,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
              ),
              // ── Center content: Portfolio Value + P&L ─────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Portfolio Value',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${_fmtFull(portfolioTotal)}',
                    style: interNums(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pnlText,
                    style: interNums(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: pnlColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Cash Capsule (Steps 61–62) ──────────────────────
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: ThemeV2.primaryBg,
            borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
          ),
          child: Text(
            'Cash: \$${_fmtFull(session.cash)} available',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeV2.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Reactive wrapper for _buildMyAssets — watches the provider
  /// and rebuilds when holdings change.
  Widget _buildMyAssetsSection() {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(stressTestRefreshProvider);
        final session = ref
            .read(stressTestProvider.notifier)
            .getSession(widget.sessionId);
        if (session == null) return const SizedBox.shrink();
        return _buildMyAssets(session);
      },
    );
  }

  // ── My Assets — full holdings list with color dots ─────────────────
  // Always wrapped in _buildSectionCard with a (+) add button in header.

  Widget _buildMyAssets(StressTestSession session) {
    final holdings = session.holdings;

    // Sort same as allocation chart — by value descending
    final sorted = List<StressTestHolding>.from(holdings)
      ..sort((a, b) {
        final priceA = session.currentPrices[a.symbol] ?? a.entryPrice;
        final priceB = session.currentPrices[b.symbol] ?? b.entryPrice;
        return (b.shares * priceB).compareTo(a.shares * priceA);
      });

    final addButton = GestureDetector(
      onTap: _openAddAssetSheet,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: ThemeV2.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add_rounded, size: 18, color: ThemeV2.primary),
      ),
    );

    // Show first 10 by default, expand with "More" button
    final displayList = _showAllAssets
        ? sorted
        : sorted.take(10).toList();

    return _buildSectionCard(
      title: 'MY ASSETS',
      trailing: addButton,
      noInnerPadding: holdings.isEmpty,
      child: holdings.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      session.trades.isEmpty
                          ? 'No assets yet'
                          : 'No active positions',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.trades.isEmpty
                          ? 'Tap + to search and add your first asset'
                          : 'Tap (+) to buy assets',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                ...displayList.asMap().entries.map((entry) {
                final i = entry.key;
                final h = entry.value;
                final currentPrice =
                    session.currentPrices[h.symbol] ?? h.entryPrice;
                final positionValue = h.shares * currentPrice;
                final costBasis = h.shares * h.avgCost;
                final pnl = positionValue - costBasis;
                final pnlPercent = costBasis > 0
                    ? (pnl / costBasis) * 100
                    : 0.0;
                final isPositive = pnl >= 0;

                return Consumer(
                  builder: (context, ref, _) {
                    final logoAsync = ref.watch(cachedLogoProvider(h.symbol));

                    return GestureDetector(
                      onTap: () => _onAssetRowTap(h.symbol),
                      onTapDown: (_) {},
                      onTapCancel: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        decoration: i < sorted.length - 1
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: ThemeV2.divider,
                                    width: 0.5,
                                  ),
                                ),
                              )
                            : null,
                        child: Row(
                          children: [
                            // Logo 40×40 с цветным кольцом от аллокации
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _allocationColor(
                                    i,
                                  ).withValues(alpha: 0.7),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(1.5),
                              child: ClipOval(
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: logoAsync.when(
                                    data: (url) => CompanyLogo(
                                      ticker: h.symbol,
                                      logoUrl: url,
                                      radius: 18,
                                    ),
                                    error: (_, _) => CompanyLogo(
                                      ticker: h.symbol,
                                      radius: 18,
                                    ),
                                    loading: () => CompanyLogo(
                                      ticker: h.symbol,
                                      radius: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Symbol + shares (как в Portfolio Holdings)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _companyName(h.symbol),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeV2.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${h.shares.toStringAsFixed(2)} shares',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: ThemeV2.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Position value + P&L (как в Portfolio Holdings)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '\$${_fmtPosition(positionValue)}',
                                    style: interNums(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeV2.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${isPositive ? '+' : ''}\$${pnl.toStringAsFixed(2)} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
                                    style: interNums(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isPositive
                                          ? ThemeV2.success
                                          : ThemeV2.loss,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // ── Lightbulb button — компактный ──
                            if (session.explanationLog.containsKey(h.symbol))
                              GestureDetector(
                                onTap: () => context.push(
                                  '/stress-test/${widget.sessionId}/stock/${h.symbol}/why',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: ThemeV2.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        ThemeV2.radiusSmall,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.help_outline_rounded,
                                      size: 16,
                                      color: ThemeV2.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              if (sorted.length > 10)
                GestureDetector(
                  onTap: () => setState(() => _showAllAssets = !_showAllAssets),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ThemeV2.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _showAllAssets
                            ? 'Less'
                            : 'More (${sorted.length - 10})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
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

  String _fmtPosition(double v) {
    return _fmtFull(v);
  }

  // ── Timer Bar — real-time countdown (ticks every second) ──────

  Widget _buildTimerBar(StressTestSession session) {
    if (session.startedAt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final total = _getTestDuration(session);
    final isCountdown = total != null;
    final remaining = total != null
        ? total - now.difference(session.startedAt!)
        : null;
    final isExpiredTimer = remaining != null && remaining.isNegative;

    String label;
    String timeText;
    Color timerColor;

    if (isExpiredTimer) {
      label = 'Test Complete';
      timeText = '0д 00ч 00м 00с';
      timerColor = ThemeV2.loss;
    } else if (isCountdown && remaining != null) {
      label = 'Time Remaining';
      timerColor = ThemeV2.textPrimary;
      final d = remaining.inDays;
      final h = remaining.inHours % 24;
      final m = remaining.inMinutes % 60;
      final s = remaining.inSeconds % 60;
      timeText =
          '$dд ${h.toString().padLeft(2, '0')}ч ${m.toString().padLeft(2, '0')}м ${s.toString().padLeft(2, '0')}с';
      if (remaining.inDays < 1) timerColor = ThemeV2.warning;
      if (remaining.inHours < 1) timerColor = ThemeV2.loss;
    } else {
      // Infinite with no expiry — show elapsed
      label = 'Elapsed Time';
      timerColor = ThemeV2.textPrimary;
      final elapsed = now.difference(session.startedAt!);
      final d = elapsed.inDays;
      final h = elapsed.inHours % 24;
      final m = elapsed.inMinutes % 60;
      final s = elapsed.inSeconds % 60;
      timeText =
          '$dд ${h.toString().padLeft(2, '0')}ч ${m.toString().padLeft(2, '0')}м ${s.toString().padLeft(2, '0')}с';
    }

    // Infinite ("until bored") past its 14-day minimum: the countdown is
    // done, and unlike Fixed/Custom (which auto-complete on their own),
    // Infinite only ever ends when the user says so — show the actual
    // tappable action here instead of leaving the label as a dead end.
    final showFinishButton =
        session.duration == TestDuration.infinite && session.canExitInfinite;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpiredTimer
              ? ThemeV2.loss.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  isExpiredTimer
                      ? Icons.check_circle_rounded
                      : isCountdown
                      ? Icons.timer_rounded
                      : Icons.timer_off_rounded,
                  color: timerColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isExpiredTimer
                            ? ThemeV2.loss
                            : ThemeV2.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      timeText,
                      style: interNums(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Epoch progress indicator
              if (!isExpiredTimer &&
                  session.epochHistory.isNotEmpty &&
                  session.startedAt != null)
                Text(
                  'Epoch #${session.epochHistory.length}',
                  style: interNums(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (showFinishButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmFinishInfiniteTest(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B365D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'FINISH TEST',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Finish Test (Infinite mode manual completion) ──────────────────

  void _confirmFinishInfiniteTest(StressTestSession session) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Finish Test?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          "End this test now and get your verdict? This can't be undone.",
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: ThemeV2.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final ended = ref
                  .read(stressTestProvider.notifier)
                  .terminateTest(session.id);
              if (ended && mounted) {
                _showVerdict();
              }
            },
            child: Text(
              'Finish Test',
              style: GoogleFonts.inter(
                color: ThemeV2.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── IPO Alert ──────────────────────────────────────────────────

  Widget _buildIpoAlert(CompanyStock company) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeV2.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeV2.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rocket_launch_rounded,
            color: ThemeV2.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BREAKING: ${company.companyName} IPO',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.warning,
                  ),
                ),
                Text(
                  '${company.symbol} just went public — extreme volatility expected!',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.warning.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Trade Tile ─────────────────────────────────────────────────

  Widget _buildTradeTile(StressTestTrade trade) {
    final totalValue = trade.shares * trade.price;

    return Container(
      key: ValueKey('${trade.date.millisecondsSinceEpoch}_${trade.symbol}'),
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // ── Logo ──
          Consumer(
            builder: (context, ref, _) {
              final logoAsync = ref.watch(cachedLogoProvider(trade.symbol));
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: trade.isBuy
                        ? ThemeV2.success.withValues(alpha: 0.3)
                        : ThemeV2.loss.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: logoAsync.when(
                      data: (url) => CompanyLogo(
                        ticker: trade.symbol,
                        logoUrl: url,
                        radius: 17,
                      ),
                      error: (_, _) =>
                          CompanyLogo(ticker: trade.symbol, radius: 17),
                      loading: () =>
                          CompanyLogo(ticker: trade.symbol, radius: 17),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // ── Company name + shares ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _companyName(trade.symbol),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trade.shares.toStringAsFixed(4)} ${trade.symbol}',
                  style: interNums(fontSize: 11, color: ThemeV2.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Total sum + BUY/SELL chip ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${_fmtPosition(totalValue)}',
                style: interNums(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trade.isBuy
                      ? ThemeV2.success.withValues(alpha: 0.12)
                      : ThemeV2.loss.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.isBuy ? 'BUY' : 'SELL',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: trade.isBuy ? ThemeV2.success : ThemeV2.loss,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Completed View ─────────────────────────────────────────────

  Widget _buildCompletedView(StressTestSession session) {
    // Try to find the verdict archive entry for this session
    final archive = ref.watch(verdictArchiveProvider);
    final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
      (e) => e?.sessionId == widget.sessionId,
      orElse: () => null,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Market Status Card ────────────────────────
          _buildMarketStatusCard(session),
          const SizedBox(height: 12),

          // ── Psychology Meter ────────────────────────────
          PsychologyMeter(data: PsychologyMeterData.fromSession(session)),
          const SizedBox(height: 16),

          // ── Allocation Chart ────────────────────────────
          _buildAllocationChart(session),
          const SizedBox(height: 16),

          // ── Cash Row ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeV2.surface,
                    borderRadius: BorderRadius.circular(ThemeV2.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINAL BALANCE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${session.totalValue.toStringAsFixed(2)}',
                        style: interNums(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ThemeV2.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.profitLoss >= 0 ? '+' : ''}${session.profitLossPercent.toStringAsFixed(1)}%',
                        style: interNums(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: session.profitLoss >= 0
                              ? ThemeV2.success
                              : ThemeV2.loss,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Verdict Card ────────────────────────────────
          if (entry != null)
            _buildSectionCard(
              title: 'PSYCHOLOGIST VERDICT',
              noInnerPadding: true,
              child: VerdictCard(entry: entry, sessionId: widget.sessionId),
            )
          else ...[
            // Fallback: session completed but verdict not in archive yet
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showVerdict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeV2.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'VIEW PSYCHOLOGIST VERDICT',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const DisclaimerFooter(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// StressTest Widget Settings Sheet — reorder + show/hide
// ---------------------------------------------------------------------------

class _StressTestWidgetSettingsSheet extends StatefulWidget {
  final List<StressTestWidgetConfig> initialConfigs;
  final StressTestWidgetsNotifier notifier;

  const _StressTestWidgetSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<_StressTestWidgetSettingsSheet> createState() =>
      _StressTestWidgetSettingsSheetState();
}

class _StressTestWidgetSettingsSheetState
    extends State<_StressTestWidgetSettingsSheet> {
  late List<StressTestWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    widget.notifier.reorder(_configs[newIndex].id, newIndex);
  }

  void _toggleVisibility(String id) {
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = StressTestWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            // ── Handle bar ──
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Widget Settings',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.notifier.resetToDefaults();
                      setState(() {
                        _configs = [
                          const StressTestWidgetConfig(
                            id: 'psychology_meter',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'allocation_chart',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'my_assets',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'market_timeline',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'corporate_events',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'trade_history',
                            visible: true,
                          ),
                          const StressTestWidgetConfig(
                            id: 'timer',
                            visible: true,
                          ),
                        ];
                      });
                    },
                    child: Text(
                      'Reset',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E5DF)),
            const SizedBox(height: 8),
            // ── Reorderable list ──
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: _configs.length,
                onReorderItem: _onReorderItem,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Material(
                      color: Colors.transparent,
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: child!,
                    ),
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final config = _configs[index];
                  return ListTile(
                    key: ValueKey(config.id),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            color: ThemeV2.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _widgetIcon(config.id),
                          color: ThemeV2.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Text(
                      config.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleVisibility(config.id),
                      child: Icon(
                        config.visible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: config.visible
                            ? ThemeV2.primary
                            : ThemeV2.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'psychology_meter':
        return Icons.psychology_rounded;
      case 'allocation_chart':
        return Icons.pie_chart_rounded;
      case 'my_assets':
        return Icons.account_balance_rounded;
      case 'market_timeline':
        return Icons.timeline_rounded;
      case 'corporate_events':
        return Icons.event_rounded;
      case 'trade_history':
        return Icons.swap_horiz_rounded;
      case 'timer':
        return Icons.timer_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}

// ---------------------------------------------------------------------------
// Disclaimer Modal
// ---------------------------------------------------------------------------

class _DisclaimerModal extends ConsumerWidget {
  const _DisclaimerModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool accepted = false;

    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.all(24),
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
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'INVESTMENT DISCLAIMER\n& LIMITATION OF LIABILITY',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemeV2.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This verdict is generated automatically by a mathematical model based '
              'solely on your simulated historical behavior within this closed testing '
              'environment. It is provided for educational and illustrative purposes '
              'only and does NOT constitute personalized investment, legal, or financial '
              'advice. Past performance within this simulator does not guarantee, predict, '
              'or reflect real-world market outcomes. Final financial decisions, asset '
              'purchases, or trading activities in real life carry substantial risk and '
              'are made solely at your own discretion and responsibility. The creators of '
              'F.O.M.O. Shield accept no liability for financial losses incurred in '
              'real-world trading.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => accepted = !accepted),
              child: Row(
                children: [
                  Icon(
                    accepted
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: accepted ? ThemeV2.primary : ThemeV2.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'I Understand & Accept',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accepted
                            ? ThemeV2.primary
                            : ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: accepted
                    ? () => Navigator.of(context).pop(true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accepted
                      ? ThemeV2.primary
                      : ThemeV2.textSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'I Understand & Accept',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
