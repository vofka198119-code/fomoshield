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
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/company_logo.dart';
import '../../shared/utils/currency_format.dart';

import '../../shared/widgets/disclaimer_footer.dart';
import '../../shared/widgets/donut_ring_painter.dart';
import '../../shared/widgets/trade_history_tile.dart';

import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import '../../shared/widgets/psychology_meter.dart';
import '../../shared/widgets/market_timeline.dart';
import 'stress_test_models.dart';
import 'stress_test_engine.dart';
import 'stress_test_dca_provider.dart';
import 'widgets/market_value_chart.dart';
import 'stress_test_widget_order_provider.dart';
import 'widgets/stress_test_allocation_chart.dart';
import 'widgets/stress_test_cash_widget.dart';
import 'widgets/stress_test_my_limit_orders_widget.dart';
import 'stress_test_naming.dart';

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
  Timer? _whyDiagnosticsTimer;
  int _tick = 0;
  bool _showAllAssets = false;
  // Guards the auto-navigate-to-verdict side effect (see
  // _handleCompletionIfNeeded) against firing twice for the same session
  // completion — both the ref.listen transition and the Finish Test
  // button's own post-terminateTest call route through it.
  bool _handledCompletion = false;

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
    // Check open counter for ad (every 6th opening for free users past 1st
    // test) — a frozen (#2/#3) slot uses its own separate counter instead,
    // at the same cadence, so viewing a frozen test doesn't also burn
    // through the general "opened any test" counter.
    Future.microtask(() {
      if (!mounted) return;
      final tier = ref.read(subscriptionTierProvider);
      if (tier != SubscriptionTier.free) return;
      final notifier = ref.read(stressTestProvider.notifier);
      final isFrozen = isStressTestSlotFrozen(
        ref.read(stressTestProvider),
        widget.sessionId,
        tier,
      );
      final showAd = isFrozen
          ? notifier.checkAndIncrementFrozenViewCounter()
          : notifier.checkAndIncrementOpenCounter();
      if (showAd) {
        showPremiumPromoOverlay(
          context: context,
          title: AppLocalizations.of(context)!.stressTestAccessTitle,
          durationSeconds: 5,
          onComplete: () {
            if (context.mounted) showMonetizationModal(context, ref);
          },
        );
      }
    });
    // DCA weekly catch-up — independent of the free-tier-only ad check
    // above (checkStressTestDcaPayout itself gates on premium/admin, so a
    // free-tier viewer here is simply a no-op, matching the freeze logic).
    Future.microtask(() {
      if (!mounted) return;
      final session = ref
          .read(stressTestProvider.notifier)
          .getSession(widget.sessionId);
      if (session != null) {
        checkStressTestDcaPayout(ref, session, AppLocalizations.of(context)!);
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
    // Why Diagnostics — persists the admin-only whole-period accumulator
    // (stress_test_why_diagnostics.dart) to this device's local cache.
    // Admin-gated here, not in the engine itself — regular users never
    // write anything.
    _whyDiagnosticsTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && ref.read(isAdminProvider)) {
        ref.read(stressTestProvider.notifier).saveWhyDiagnostics();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _timelineTimer?.cancel();
    _whyDiagnosticsTimer?.cancel();
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

  /// Full-width tap-through bar styled like a search field — duplicates
  /// the Holdings widget's "+" mechanic (same _openAddAssetSheet target),
  /// just more discoverable for first-time users than the small icon.
  Widget _buildQuickAddSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _openAddAssetSheet,
      child: Container(
        width: double.infinity,
        decoration: FomoShieldTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: ThemeV2.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              l10n.stressTestSearchStocksHint,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: ThemeV2.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerdict() {
    _showDisclaimerModal().then((accepted) {
      if (accepted == true && mounted) {
        context.push('/stress-test/${widget.sessionId}/verdict');
      }
    });
  }

  // Called whenever this session might have just completed (either the
  // ref.listen transition below, or right after a manual terminateTest()
  // call from the Finish Test button). Guarded by _handledCompletion so
  // whichever call happens first "wins" and the other becomes a no-op —
  // avoids depending on the exact sync/async ordering between a provider
  // notification and the caller that triggered it.
  void _handleCompletionIfNeeded() {
    if (_handledCompletion || !mounted) return;
    final archive = ref.read(verdictArchiveProvider);
    final hasVerdict = archive.any((e) => e.sessionId == widget.sessionId);
    if (hasVerdict) {
      _handledCompletion = true;
      _showVerdict();
    }
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
    // Auto-navigate to the verdict screen instead of a dead-end "Session
    // not found" when this session disappears from active state because
    // it completed (Fixed/Custom auto-completion, cold-start catch-up, or
    // Infinite's Finish Test button). A genuine deletion leaves no archive
    // entry, so _handleCompletionIfNeeded() is a no-op and the existing
    // "Session not found" fallback below still applies.
    ref.listen<StressTestSession?>(
      stressTestSessionProvider(widget.sessionId),
      (previous, next) {
        if (previous != null && next == null) {
          _handleCompletionIfNeeded();
        }
      },
    );
    final session = ref.watch(stressTestSessionProvider(widget.sessionId));
    final l10n = AppLocalizations.of(context)!;
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          toolbarHeight: 64,
          centerTitle: true,
          title: Text(
            l10n.stressTestPortfolioTitle,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeV2.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        body: Center(child: Text(l10n.stressTestSessionNotFound)),
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
          l10n.stressTestPortfolioTitle,
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
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: isCompleted
            ? _buildCompletedView(session)
            : isActive
            ? (session.holdings.isEmpty && session.trades.isEmpty
                  ? _buildActiveEmptyView()
                  : _buildActiveView(session))
            : _buildSetupView(session),
      ),
    );
  }

  // ── Setup View ───────────────────────────────────────────────────

  Widget _buildSetupView(StressTestSession session) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.stressTestNotStartedYet,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.stressTestGoBackToSetup,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.push('/stress-test/${widget.sessionId}/setup'),
            child: Text(l10n.stressTestGoToSetup),
          ),
        ],
      ),
    );
  }

  // ── Startup Empty View — shown when no trades have been made yet ──

  Widget _buildActiveEmptyView() {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.stressTestStartBuildingPortfolio,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.stressTestTapToAddFirstPosition,
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
    final l10n = AppLocalizations.of(context)!;
    final isExpired = _isExpired(session);
    final widgetConfigs = ref.watch(
      stressTestWidgetOrderProvider(widget.sessionId),
    );
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return Column(
      children: [
        // ── Quick-add search bar — pinned under the AppBar (not part of
        // the scrollable body) so it stays reachable while swiping through
        // widgets below. Duplicates the Holdings widget's "+" mechanic
        // (_openAddAssetSheet) as a full-width, always visible tap target
        // so first-time users don't have to spot the small "+" inside the
        // Holdings card header. ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _buildQuickAddSearchBar(),
        ),
        Expanded(
          child: RefreshIndicator(
            color: ThemeV2.primary,
            backgroundColor: ThemeV2.surface,
            onRefresh: () async {
              ref
                  .read(stressTestProvider.notifier)
                  .refreshPrices(widget.sessionId);
              ref.read(stressTestRefreshProvider.notifier).state++;
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          l10n.stressTestGetVerdict,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  if (isExpired) const SizedBox(height: 12),

                  // ── Widgets (reorderable via gear icon; Portfolio Balance
                  // pinned first, Timer pinned last — see
                  // stress_test_widget_order_provider.dart) ──
                  for (final cfg in visibleWidgets) ...[
                    _buildWidgetById(cfg.id, session),
                    const SizedBox(height: 12),
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
                        l10n.homeAddWidgets,
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
                          side: const BorderSide(
                            color: ThemeV2.primary,
                            width: 0.5,
                          ),
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
          ),
        ),
      ],
    );
  }

  /// Dispatch method — builds a widget by its config id.
  /// Returns [SizedBox.shrink] if the widget's conditions aren't met.
  Widget _buildWidgetById(String id, StressTestSession session) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'allocation_chart':
        return StressTestAllocationChart(session: session);
      case 'cash':
        return StressTestCashWidget(session: session);
      case 'psychology_meter':
        return PsychologyMeter(
          data: PsychologyMeterData.fromSession(session),
          sessionId: session.id,
        );
      case 'my_assets':
        return _buildMyAssetsSection();
      case 'price_chart':
        return _buildSectionCard(
          title: '',
          noInnerPadding: true,
          child: MarketValueChart(session: session),
        );
      case 'epoch_history':
        // Admin-only — regular users never see the underlying scenario/
        // epoch narrative, only the price chart above.
        if (!ref.watch(isAdminProvider)) return const SizedBox.shrink();
        if (session.epochHistory.isEmpty) return const SizedBox.shrink();
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
            initialLimit: 3,
          ),
        );
      case 'trade_history':
        if (session.trades.isEmpty) return const SizedBox.shrink();
        final allTrades = session.trades.reversed.toList();
        final displayTrades = allTrades.take(5).toList();
        return _buildSectionCard(
          title: l10n.tradeHistoryTitle,
          noInnerPadding: true,
          child: Column(
            children: [
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.black.withValues(alpha: 0.06),
              ),
              ...displayTrades.asMap().entries.map(
                (entry) => TradeHistoryTile(
                  symbol: entry.value.symbol,
                  companyName: _companyName(entry.value.symbol),
                  isBuy: entry.value.isBuy,
                  totalValue: entry.value.shares * entry.value.price,
                  showDivider: entry.key != displayTrades.length - 1,
                  onTap: () => context.push(
                    '/stress-test/${widget.sessionId}/trade-detail',
                    extra: entry.value,
                  ),
                ),
              ),
              if (allTrades.length > 5) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => context.push(
                    '/stress-test/${widget.sessionId}/trade-history',
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ThemeV2.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        l10n.commonMoreCount(allTrades.length - 5),
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
      case 'limit_orders':
        return StressTestMyLimitOrdersWidget(sessionId: session.id);
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
    // 'epoch_history' is an admin-only debugging widget (see
    // _buildWidgetById) — non-admins shouldn't even see it listed here as
    // a togglable/draggable item, not just have it render blank on-screen.
    final isAdmin = ref.read(isAdminProvider);
    final currentConfigs = ref
        .read(stressTestWidgetOrderProvider(widget.sessionId))
        .where((c) => isAdmin || c.id != 'epoch_history')
        .toList();

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
        isAdmin: isAdmin,
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
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: FomoShieldTheme.cardTitle()),
                  ?trailing,
                ],
              ),
            ),
          if (!noInnerPadding)
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          if (noInnerPadding)
            child
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: child,
            ),
        ],
      ),
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
    final l10n = AppLocalizations.of(context)!;
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
    final displayList = _showAllAssets ? sorted : sorted.take(10).toList();

    return _buildSectionCard(
      title: l10n.holdingsTitle,
      trailing: addButton,
      noInnerPadding: true,
      child: holdings.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      session.trades.isEmpty
                          ? l10n.stressTestNoAssetsYet
                          : l10n.stressTestNoActivePositions,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.trades.isEmpty
                          ? l10n.stressTestTapToAddFirstAsset
                          : l10n.stressTestTapToBuyAssets,
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
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
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
                          constraints: const BoxConstraints(minHeight: 72),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: i < sorted.length - 1
                              ? BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
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
                                    color: donutAllocationColor(
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeV2.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      h.symbol,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: ThemeV2.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.sharesCount(
                                        h.shares.toStringAsFixed(2),
                                      ),
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
                                      formatUsd(positionValue),
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
                                      '${formatUsdSigned(pnl)} (${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
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
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                if (sorted.length > 10)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showAllAssets = !_showAllAssets),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: ThemeV2.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _showAllAssets
                              ? l10n.commonLess
                              : l10n.commonMoreCount(sorted.length - 10),
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

  String _companyName(String symbol) =>
      resolveStressTestCompanyName(ref, symbol);

  // ── Timer Bar — real-time countdown (ticks every second) ──────

  Widget _buildTimerBar(StressTestSession session) {
    if (session.startedAt == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

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
      label = l10n.stressTestTestComplete;
      timeText = l10n.stressTestCountdown('0', '00', '00', '00');
      timerColor = ThemeV2.loss;
    } else if (isCountdown && remaining != null) {
      label = l10n.stressTestTimeRemaining;
      timerColor = ThemeV2.textPrimary;
      final d = remaining.inDays;
      final h = remaining.inHours % 24;
      final m = remaining.inMinutes % 60;
      final s = remaining.inSeconds % 60;
      timeText = l10n.stressTestCountdown(
        '$d',
        h.toString().padLeft(2, '0'),
        m.toString().padLeft(2, '0'),
        s.toString().padLeft(2, '0'),
      );
      if (remaining.inDays < 1) timerColor = ThemeV2.warning;
      if (remaining.inHours < 1) timerColor = ThemeV2.loss;
    } else {
      // Infinite with no expiry — show elapsed
      label = l10n.stressTestElapsedTime;
      timerColor = ThemeV2.textPrimary;
      final elapsed = now.difference(session.startedAt!);
      final d = elapsed.inDays;
      final h = elapsed.inHours % 24;
      final m = elapsed.inMinutes % 60;
      final s = elapsed.inSeconds % 60;
      timeText = l10n.stressTestCountdown(
        '$d',
        h.toString().padLeft(2, '0'),
        m.toString().padLeft(2, '0'),
        s.toString().padLeft(2, '0'),
      );
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
        color: FomoShieldTheme.card,
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
                  l10n.stressTestEpochNumber(session.epochHistory.length),
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
                  l10n.stressTestFinishTestButton,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${l10n.stressTestFinishTest}?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          l10n.stressTestFinishTestConfirm,
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.profileCancel,
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
                _handleCompletionIfNeeded();
              }
            },
            child: Text(
              l10n.stressTestFinishTest,
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

  // ── Completed View ─────────────────────────────────────────────

  Widget _buildCompletedView(StressTestSession session) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Psychology Meter ────────────────────────────
          PsychologyMeter(
            data: PsychologyMeterData.fromSession(session),
            sessionId: session.id,
          ),
          const SizedBox(height: 16),

          // ── Allocation Chart ────────────────────────────
          StressTestAllocationChart(session: session),
          const SizedBox(height: 16),

          // ── Cash Row ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeV2.primaryBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ThemeV2.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.stressTestFinalBalance,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatUsd(session.totalValue),
                        style: interNums(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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

          // ── Verdict entry point — the old inline VerdictCard summary
          // (shared/widgets/verdict_card.dart) was cut 2026-08-08: it
          // duplicated an older, unstyled version of the Session Complete
          // screen and the user had never actually seen it. This button
          // always links to the real Session Complete screen instead.
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
                l10n.stressTestViewVerdict,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

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
  final bool isAdmin;

  const _StressTestWidgetSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
    required this.isAdmin,
  });

  @override
  State<_StressTestWidgetSettingsSheet> createState() =>
      _StressTestWidgetSettingsSheetState();
}

class _StressTestWidgetSettingsSheetState
    extends State<_StressTestWidgetSettingsSheet> {
  late List<StressTestWidgetConfig> _configs;

  // 'allocation_chart' is pinned first, 'timer' is pinned last — never
  // draggable, never hidden (mirrors company_detail's pinned-first pattern).
  static const _pinnedFirstId = 'allocation_chart';
  static const _pinnedLastId = 'timer';

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    final id = _configs[oldIndex].id;
    if (id == _pinnedFirstId || id == _pinnedLastId) return;
    final clampedIndex = newIndex.clamp(1, _configs.length - 2);
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(clampedIndex, item);
    });
    widget.notifier.reorder(id, clampedIndex);
  }

  void _toggleVisibility(String id) {
    if (id == _pinnedFirstId || id == _pinnedLastId) return;
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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
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
                    l10n.homeWidgetSettingsTitle,
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
                        _configs = stressTestDefaultWidgetOrder
                            .where(
                              (id) => widget.isAdmin || id != 'epoch_history',
                            )
                            .map(
                              (id) =>
                                  StressTestWidgetConfig(id: id, visible: true),
                            )
                            .toList();
                      });
                    },
                    child: Text(
                      l10n.homeReset,
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
                  final isPinned =
                      config.id == _pinnedFirstId || config.id == _pinnedLastId;
                  return ListTile(
                    key: ValueKey(config.id),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pinned widgets can't be dragged.
                        isPinned
                            ? const Icon(
                                Icons.push_pin_rounded,
                                color: ThemeV2.textSecondary,
                                size: 20,
                              )
                            : ReorderableDragStartListener(
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
                      config.displayName(l10n),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    trailing: isPinned
                        ? Icon(
                            Icons.visibility_rounded,
                            color: ThemeV2.textSecondary.withValues(alpha: 0.4),
                            size: 22,
                          )
                        : GestureDetector(
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
      case 'cash':
        return Icons.account_balance_wallet_rounded;
      case 'my_assets':
        return Icons.account_balance_rounded;
      case 'price_chart':
        return Icons.show_chart_rounded;
      case 'epoch_history':
        return Icons.history_rounded;
      case 'trade_history':
        return Icons.swap_horiz_rounded;
      case 'limit_orders':
        return Icons.receipt_long_rounded;
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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.stressTestInvestmentDisclaimerTitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemeV2.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.stressTestInvestmentDisclaimerBody,
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
                      l10n.stressTestIUnderstandAccept,
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
