import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import 'portfolio_providers.dart';
import 'portfolio_limits_provider.dart';
import 'portfolio_ad_provider.dart';
import 'portfolio_widget_order_provider.dart';
import 'widgets/portfolio_summary_widget.dart';
import 'widgets/portfolio_allocation_widget.dart';
import 'widgets/portfolio_holdings_widget.dart';
import '../home/widgets/portfolio_journal_widget.dart';
import '../home/widgets/historical_sim_widget.dart';
import '../home/widgets/scenario_compare_widget.dart';
import '../../shared/widgets/disclaimer_footer.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);
    final activeId = ref.watch(activePortfolioIdProvider);
    final effectiveId =
        activeId ?? (portfolios.isNotEmpty ? portfolios.first.id : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'PORTFOLIO',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ThemeV2.textSecondary),
            color: ThemeV2.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              final pid = effectiveId;
              if (pid == null) return;
              if (value == 'reset') {
                _showResetPortfolioDialog(context, pid);
              } else if (value == 'delete') {
                _showDeletePortfolioDialog(context, pid, portfolios);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(
                    Icons.refresh_rounded,
                    color: ThemeV2.warning,
                    size: 20,
                  ),
                  title: const Text(
                    'Reset Portfolio',
                    style: TextStyle(color: ThemeV2.warning),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_rounded,
                    color: ThemeV2.loss,
                    size: 20,
                  ),
                  title: const Text(
                    'Delete Portfolio',
                    style: TextStyle(color: ThemeV2.loss),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: ThemeV2.primary),
            onPressed: () => _showCreatePortfolioDialog(context),
          ),
        ],
      ),
      body: portfolios.isEmpty
          ? _emptyState(context)
          : effectiveId == null
          ? _emptyState(context)
          : _PortfolioBody(portfolioId: effectiveId),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: ThemeV2.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolios yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first virtual portfolio\nwith \$10,000 starting balance',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePortfolioDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: Text('Create Portfolio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeV2.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePortfolioDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'New Portfolio',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Tech Growth',
            hintStyle: GoogleFonts.inter(color: ThemeV2.textSecondary, fontSize: 14),
            filled: true,
            fillColor: ThemeV2.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.inter(color: ThemeV2.textPrimary, fontSize: 14),
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
              if (controller.text.trim().isNotEmpty) {
                final maxP = ref.read(maxPortfoliosProvider);
                final currentCount = ref.read(portfoliosProvider).length;
                if (currentCount >= maxP) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        maxP == 3
                            ? 'FREE limit: 3 portfolios. Upgrade to Premium (6).'
                            : 'Max $maxP portfolios reached.',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      backgroundColor: ThemeV2.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                ref
                    .read(portfoliosProvider.notifier)
                    .addPortfolio(
                      controller.text.trim(),
                      startingBalance: ref.read(startingCapitalProvider),
                    );
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Create',
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

  void _showResetPortfolioDialog(BuildContext context, String portfolioId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'Reset Portfolio?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          'All holdings and history will be cleared.\nBalance will be restored to its original amount.',
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
              ref.read(portfoliosProvider.notifier).resetPortfolio(portfolioId);
              Navigator.pop(ctx);
            },
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                color: ThemeV2.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePortfolioDialog(
    BuildContext context,
    String portfolioId,
    List<Portfolio> ps,
  ) {
    if (ps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete the last portfolio. Create a new one first.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: ThemeV2.loss,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'Delete Portfolio?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          'All holdings and history will be lost.',
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
              ref
                  .read(portfoliosProvider.notifier)
                  .deletePortfolio(portfolioId);
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: ThemeV2.loss,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(portfolioPerformanceProvider(widget.portfolioId));
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
        final tier = ref.read(subscriptionTierProvider);
        return _PortfolioWidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
          isPremium:
              tier == SubscriptionTier.premium ||
              tier == SubscriptionTier.admin,
          onPremiumLockTap: () => showPremiumPromoOverlay(
            context: context,
            title: 'Premium widget',
            durationSeconds: 5,
            onComplete: () {
              if (context.mounted) showMonetizationModal(context, ref);
            },
          ),
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
                _buildWidget('portfolio_summary', isLoading: true),
                _buildWidget('portfolio_allocation', isLoading: true),
                _buildWidget('portfolio_holdings', isLoading: true),
              ],
              error: (_, _) => [
                _buildWidget('portfolio_summary', hasError: true),
                _buildWidget('portfolio_allocation', hasError: true),
                _buildWidget('portfolio_holdings', hasError: true),
              ],
              data: (perf) => visibleWidgets
                  .map((w) => _buildWidget(w.id, performance: perf))
                  .toList(),
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
                    side: const BorderSide(
                      color: ThemeV2.primary,
                      width: 0.5,
                    ),
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
            const SizedBox(height: 100),
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
      case 'portfolio_summary':
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioSummaryWidget(
            performance: performance,
            isLoading: isLoading,
            hasError: hasError,
          ),
        );
      case 'portfolio_allocation':
        if (isLoading ||
            hasError ||
            performance == null ||
            performance.holdings.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioAllocationWidget(holdings: performance.holdings),
        );
      case 'portfolio_holdings':
        if (isLoading || hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: PortfolioHoldingsWidget(holdings: null),
          );
        }
        if (performance == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: PortfolioHoldingsWidget(
            holdings: performance.holdings,
            emptyPortfolioName: performance.name,
          ),
        );
      case 'portfolio_journal':
        return const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: PortfolioJournalWidget(),
        );
      case 'historical_sim':
        return const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: HistoricalSimWidget(),
        );
      case 'scenario_compare':
        return const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: ScenarioCompareWidget(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Portfolio Selector
// ---------------------------------------------------------------------------

class _PortfolioSelector extends ConsumerWidget {
  final List<Portfolio> portfolios;
  final String activeId;
  const _PortfolioSelector({required this.portfolios, required this.activeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: portfolios.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = portfolios[i];
          final isActive = p.id == activeId;
          return GestureDetector(
            key: ValueKey(p.id),
            onTap: () async {
              if (p.id == activeId) return;
              ref.read(activePortfolioIdProvider.notifier).state = p.id;
              // Check ad counter on switch
              final tier = ref.read(subscriptionTierProvider);
              if (tier == SubscriptionTier.free) {
                final showAd = await ref
                    .read(portfolioAdProvider.notifier)
                    .incrementSwitch();
                if (showAd && context.mounted) {
                  showPremiumPromoOverlay(
                    context: context,
                    title: 'Portfolio switched',
                    durationSeconds: 5,
                    onComplete: () {
                      if (context.mounted) showMonetizationModal(context, ref);
                    },
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? ThemeV2.primary : ThemeV2.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (isActive)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                  Text(
                    p.name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? ThemeV2.primary : ThemeV2.textSecondary,
                    ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => _deleteConfirm(context, ref, p.id),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteConfirm(BuildContext context, WidgetRef ref, String id) {
    if (portfolios.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete the last portfolio',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: ThemeV2.loss,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'Delete portfolio?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          'All holdings and history will be lost.',
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
              ref.read(portfoliosProvider.notifier).deletePortfolio(id);
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: ThemeV2.loss,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget Settings BottomSheet (Revolut-style, matching HomeScreen exactly)
// ---------------------------------------------------------------------------

class _PortfolioWidgetsSettingsSheet extends StatefulWidget {
  final List<PortfolioWidgetConfig> initialConfigs;
  final PortfolioWidgetsNotifier notifier;
  final bool isPremium;
  final VoidCallback onPremiumLockTap;

  const _PortfolioWidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
    required this.isPremium,
    required this.onPremiumLockTap,
  });

  @override
  State<_PortfolioWidgetsSettingsSheet> createState() =>
      _PortfolioWidgetsSettingsSheetState();
}

class _PortfolioWidgetsSettingsSheetState
    extends State<_PortfolioWidgetsSettingsSheet> {
  late List<PortfolioWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorder(int oldIndex, int newIndex) {
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
        _configs[index] = PortfolioWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'portfolio_summary':
        return Icons.account_balance_rounded;
      case 'portfolio_allocation':
        return Icons.pie_chart_rounded;
      case 'portfolio_holdings':
        return Icons.view_list_rounded;
      case 'portfolio_journal':
        return Icons.auto_stories_rounded;
      case 'historical_sim':
        return Icons.query_stats_rounded;
      case 'scenario_compare':
        return Icons.compare_arrows_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Portfolio Widgets',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.notifier.resetToDefaults();
                    setState(() {
                      _configs = [
                        const PortfolioWidgetConfig(
                          id: 'portfolio_summary',
                          visible: true,
                        ),
                        const PortfolioWidgetConfig(
                          id: 'portfolio_allocation',
                          visible: true,
                        ),
                        const PortfolioWidgetConfig(
                          id: 'portfolio_holdings',
                          visible: true,
                        ),
                        const PortfolioWidgetConfig(
                          id: 'portfolio_journal',
                          visible: true,
                        ),
                        const PortfolioWidgetConfig(
                          id: 'historical_sim',
                          visible: true,
                        ),
                        const PortfolioWidgetConfig(
                          id: 'scenario_compare',
                          visible: true,
                        ),
                      ];
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Reorderable list
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: _configs.length,
              onReorderItem: _onReorder,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: child!,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final config = _configs[index];
                final isPremiumWidget =
                    config.id == 'portfolio_journal' ||
                    config.id == 'historical_sim' ||
                    config.id == 'scenario_compare';
                return Container(
                  key: ValueKey(config.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: config.visible
                        ? ThemeV2.surfaceDark
                        : ThemeV2.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.visible
                          ? Colors.black12
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  child: ListTile(
                    key: ValueKey('${config.id}_tile'),
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
                          color: config.visible
                              ? (isPremiumWidget
                                    ? ThemeV2.primary
                                    : ThemeV2.primary)
                              : ThemeV2.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            config.displayName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: config.visible
                                  ? Colors.white
                                  : ThemeV2.textSecondary,
                            ),
                          ),
                        ),
                        if (isPremiumWidget) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: widget.isPremium
                                ? ThemeV2.warning
                                : ThemeV2.textSecondary,
                          ),
                        ],
                      ],
                    ),
                    trailing: GestureDetector(
                      onTap: isPremiumWidget && !widget.isPremium
                          ? widget.onPremiumLockTap
                          : () => _toggleVisibility(config.id),
                      child: Icon(
                        isPremiumWidget && !widget.isPremium
                            ? Icons.lock_rounded
                            : (config.visible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded),
                        color: isPremiumWidget && !widget.isPremium
                            ? ThemeV2.warning
                            : (config.visible
                                  ? ThemeV2.primary
                                  : ThemeV2.textSecondary),
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

