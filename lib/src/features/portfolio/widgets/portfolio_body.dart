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
      }
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
    final portfolios = ref.watch(portfoliosProvider);
    final performanceAsync = ref.watch(
      portfolioPerformanceProvider(widget.portfolioId),
    );
    final widgetConfigs = ref.watch(portfolioWidgetsProvider);
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();
    final activeIndex = portfolios.indexWhere(
      (p) => p.id == widget.portfolioId,
    );
    final showBannerAd = ref.watch(
      isPortfolioBannerAdSupportedProvider(activeIndex),
    );

    return RefreshIndicator(
      color: ThemeV2.primary,
      backgroundColor: ThemeV2.surface,
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
            _PortfolioSelector(
              portfolios: portfolios,
              activeId: widget.portfolioId,
            ),
            const SizedBox(height: 16),
            // Render visible widgets in order
            ...performanceAsync.when(
              loading: () => [
                _buildWidget('portfolio_balance', isLoading: true),
                _buildWidget('portfolio_cash', isLoading: true),
                _buildWidget('portfolio_holdings', isLoading: true),
              ],
              error: (_, _) => [
                _buildWidget('portfolio_balance', hasError: true),
                _buildWidget('portfolio_cash', hasError: true),
                _buildWidget('portfolio_holdings', hasError: true),
              ],
              data: (perf) => [
                for (int i = 0; i < visibleWidgets.length; i++)
                  StaggerFadeIn(
                    index: i,
                    child: _buildWidget(
                      visibleWidgets[i].id,
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
                icon: const Icon(
                  Icons.add_rounded,
                  color: ThemeV2.primary,
                  size: 20,
                ),
                label: Text(
                  AppLocalizations.of(context)!.homeAddWidgets,
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
            // Banner ad for 2nd/3rd portfolio (free tier)
            if (showBannerAd) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: ThemeV2.surfaceDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.ad_units_rounded,
                      size: 14,
                      color: ThemeV2.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sponsored Content',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ThemeV2.textSecondary.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const DisclaimerFooter(),
            SizedBox(height: shellBottomClearance(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildWidget(
    String id, {
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
          ),
        );
      case 'portfolio_cash':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioCashWidget(
            cash: performance?.cash,
            isLoading: isLoading,
            hasError: hasError,
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
            ),
          );
        }
        if (performance == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioHoldingsWidget(
            portfolioId: widget.portfolioId,
            holdings: performance.holdings,
          ),
        );
      case 'trade_history':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioTradeHistoryWidget(portfolioId: widget.portfolioId),
        );
      case 'my_limit_orders':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: MyLimitOrdersWidget(portfolioId: widget.portfolioId),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
