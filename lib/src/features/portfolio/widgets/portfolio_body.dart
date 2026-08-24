part of '../portfolio_screen.dart';

// ---------------------------------------------------------------------------
// Portfolio Body — widget-based (customizable order + visibility)
// ---------------------------------------------------------------------------

class _PortfolioBody extends ConsumerStatefulWidget {
  final String portfolioId;
  const _PortfolioBody({required this.portfolioId});

  @override
  ConsumerState<_PortfolioBody> createState() => _PortfolioBodyState();
}

class _PortfolioBodyState extends ConsumerState<_PortfolioBody> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Not a live broker — quotes this fresh don't need sub-minute
    // polling, and this timer keeps ticking even while this screen sits
    // mounted-but-hidden underneath a pushed company-detail route (a
    // push, not a tab switch, doesn't dispose it). 5 minutes is plenty.
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) {
        ref.invalidate(portfolioPerformanceProvider(widget.portfolioId));
        checkPendingOrders(ref);
        checkWeeklyPayout(ref, AppLocalizations.of(context)!);
      }
    });
    // Also check once right away — deferred to a microtask (not called
    // directly here) because AppLocalizations.of(context) depends on an
    // InheritedWidget, which Flutter forbids reading before initState()
    // itself has returned (see project memory: this exact call crashed
    // Market Clock's home card the same way when it was placed directly
    // in initState instead of deferred).
    Future.microtask(() {
      if (mounted) checkWeeklyPayout(ref, AppLocalizations.of(context)!);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(portfolioWidgetsProvider.notifier);
    final currentConfigs = ref.read(portfolioWidgetsProvider);

    showModalBottomSheet(
      context: context,
      // Without this, the sheet pushes onto the ShellRoute's own nested
      // Navigator (this screen's `context`), which sits inside the app
      // shell's Scaffold body — and that Scaffold uses `extendBody: true`
      // for its bottom nav bar, so the persistent nav bar paints on top
      // of the sheet's lower edge instead of the sheet covering it.
      // Pushing onto the root Navigator instead gives proper full-screen
      // coverage over the bottom nav bar.
      useRootNavigator: true,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _PortfolioWidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final performanceAsync = ref.watch(
      portfolioPerformanceProvider(widget.portfolioId),
    );
    final widgetConfigs = ref.watch(portfolioWidgetsProvider);
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return RefreshIndicator(
      color: palette.accentPrimary,
      backgroundColor: palette.card,
      onRefresh: () async {
        ref.invalidate(portfolioPerformanceProvider(widget.portfolioId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Render visible widgets in order
            ...performanceAsync.when(
              loading: () => [
                _buildWidget('portfolio_balance', palette, isLoading: true),
                _buildWidget('portfolio_cash', palette, isLoading: true),
                _buildWidget('portfolio_holdings', palette, isLoading: true),
              ],
              error: (_, _) => [
                _buildWidget('portfolio_balance', palette, hasError: true),
                _buildWidget('portfolio_cash', palette, hasError: true),
                _buildWidget('portfolio_holdings', palette, hasError: true),
              ],
              data: (perf) => [
                for (int i = 0; i < visibleWidgets.length; i++)
                  StaggerFadeIn(
                    index: i,
                    child: _buildWidget(
                      visibleWidgets[i].id,
                      palette,
                      performance: perf,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Add widgets button
            Center(
              child: TextButton.icon(
                onPressed: _showWidgetsBottomSheet,
                icon: Icon(
                  Icons.add_rounded,
                  color: palette.accentPrimary,
                  size: 20,
                ),
                label: Text(
                  AppLocalizations.of(context)!.homeAddWidgets,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.accentPrimary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: palette.accentPrimary, width: 0.5),
                  ),
                ),
              ),
            ),
            const DisclaimerFooter(),
            SizedBox(height: shellBottomClearance(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildWidget(
    String id,
    AppPalette palette, {
    PortfolioPerformance? performance,
    bool isLoading = false,
    bool hasError = false,
  }) {
    switch (id) {
      case 'portfolio_balance':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioBalanceWidget(
            performance: performance,
            isLoading: isLoading,
            hasError: hasError,
            palette: palette,
          ),
        );
      case 'portfolio_cash':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioCashWidget(
            cash: performance?.cash,
            isLoading: isLoading,
            hasError: hasError,
            palette: palette,
          ),
        );
      case 'target':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TargetWidget(
            portfolioId: widget.portfolioId,
            performance: performance,
            isLoading: isLoading,
            hasError: hasError,
          ),
        );
      case 'portfolio_holdings':
        if (isLoading || hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: PortfolioHoldingsWidget(
              portfolioId: widget.portfolioId,
              holdings: null,
              palette: palette,
            ),
          );
        }
        if (performance == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioHoldingsWidget(
            portfolioId: widget.portfolioId,
            holdings: performance.holdings,
            palette: palette,
          ),
        );
      case 'trade_history':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioTradeHistoryWidget(
            portfolioId: widget.portfolioId,
            palette: palette,
          ),
        );
      case 'my_limit_orders':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: MyLimitOrdersWidget(
            portfolioId: widget.portfolioId,
            palette: palette,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
