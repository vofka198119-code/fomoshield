import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/notifications/notification_providers.dart';
import 'home_providers.dart';
import 'widget_order_provider.dart';
import 'widgets/shield_signal_widget.dart';
import 'widgets/watchlist_widget.dart';
import 'widgets/market_clock_widget.dart';
import 'widgets/portfolio_widget.dart';
import 'widgets/stress_test_widget.dart';
import '../../shared/widgets/disclaimer_footer.dart';
import '../../shared/widgets/stagger_fade_in.dart';

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onRefresh() {
    ref.invalidate(marketIndicesProvider);
    ref.read(marketCacheProvider).invalidate();
  }

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(homeWidgetsProvider.notifier);
    final currentConfigs = ref.read(homeWidgetsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _WidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgetConfigs = ref.watch(homeWidgetsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'F.O.M.O. SHIELD',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: ThemeV2.loss,
              textColor: Colors.white,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: ThemeV2.primary,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: ThemeV2.primary,
        backgroundColor: ThemeV2.surface,
        onRefresh: () async {
          _onRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < visibleWidgets.length; i++) ...[
                if (i > 0) const SizedBox(height: 24),
                KeyedSubtree(
                  key: ValueKey(visibleWidgets[i].id),
                  child: StaggerFadeIn(
                    index: i,
                    child: _buildWidget(visibleWidgets[i].id),
                  ),
                ),
              ],
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
              const DisclaimerFooter(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidget(String id) {
    switch (id) {
      case 'shield_signal':
        return const ShieldSignalWidget();
      case 'watchlist':
        return const WatchlistWidget();
      case 'news':
        return const MarketClockWidget();
      case 'portfolio':
        return const PortfolioWidget();
      case 'stress_test':
        return const StressTestWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets Settings BottomSheet
// ---------------------------------------------------------------------------

class _WidgetsSettingsSheet extends StatefulWidget {
  final List<HomeWidgetConfig> initialConfigs;
  final HomeWidgetsNotifier notifier;

  const _WidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<_WidgetsSettingsSheet> createState() => _WidgetsSettingsSheetState();
}

class _WidgetsSettingsSheetState extends State<_WidgetsSettingsSheet> {
  late List<HomeWidgetConfig> _configs;

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
    // Persist immediately
    widget.notifier.reorder(_configs[newIndex].id, newIndex);
  }

  void _toggleVisibility(String id) {
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = HomeWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'shield_signal':
        return Icons.shield_rounded;
      case 'watchlist':
        return Icons.bookmark_rounded;
      case 'news':
        return Icons.access_time_filled_rounded;
      case 'portfolio':
        return Icons.account_balance_rounded;
      case 'stress_test':
        return Icons.psychology_rounded;
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
                  'Widget Settings',
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
                        const HomeWidgetConfig(id: 'news', visible: true),
                        const HomeWidgetConfig(id: 'portfolio', visible: true),
                        const HomeWidgetConfig(
                          id: 'shield_signal',
                          visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'stress_test',
                          visible: true,
                        ),
                        const HomeWidgetConfig(id: 'watchlist', visible: true),
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
                        // Drag handle
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
                              ? ThemeV2.primary
                              : ThemeV2.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Text(
                      config.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.visible
                            ? ThemeV2.textPrimary
                            : ThemeV2.textSecondary,
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
