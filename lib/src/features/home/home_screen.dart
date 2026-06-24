import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'home_providers.dart';
import 'widget_order_provider.dart';
import 'widgets/shield_signal_widget.dart';
import 'widgets/markets_widget.dart';
import 'widgets/watchlist_widget.dart';
import 'widgets/upcoming_events_widget.dart';
import 'widgets/news_widget.dart';
import 'widgets/portfolio_widget.dart';

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
    ref.invalidate(shieldSignalProvider);
    ref.invalidate(marketIndicesProvider);
    ref.invalidate(watchlistQuotesProvider);
    ref.invalidate(calendarEventsProvider);
    ref.read(marketCacheProvider).invalidate();
    ref.read(eventsCacheProvider).invalidate();
  }

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(homeWidgetsProvider.notifier);
    final currentConfigs = ref.read(homeWidgetsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
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

    final visibleWidgets =
        widgetConfigs.where((w) => w.visible).toList();

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF00BCD4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'F.O.M.O. SHIELD',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textDim),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accentBlue,
        backgroundColor: AppTheme.card,
        onRefresh: () async {
          _onRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < visibleWidgets.length; i++) ...[
                if (i > 0) const SizedBox(height: 24),
                KeyedSubtree(
                  key: ValueKey(visibleWidgets[i].id),
                  child: _buildWidget(visibleWidgets[i].id),
                ),
              ],
              const SizedBox(height: 24),
              // Add widgets button
              Center(
                child: TextButton.icon(
                  onPressed: _showWidgetsBottomSheet,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppTheme.accentBlue,
                    size: 20,
                  ),
                  label: Text(
                    'Add widgets',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentBlue,
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
                        color: AppTheme.accentBlue,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
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
      case 'markets':
        return const MarketsWidget();
      case 'watchlist':
        return const WatchlistWidget();
      case 'upcoming_events':
        return const UpcomingEventsWidget();
      case 'news':
        return const NewsWidget();
      case 'portfolio':
        return const PortfolioWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets Settings BottomSheet (Revolut-style)
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
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    // Persist immediately
    widget.notifier.reorder(
      _configs[newIndex].id,
      newIndex,
    );
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
      case 'markets':
        return Icons.show_chart_rounded;
      case 'watchlist':
        return Icons.bookmark_rounded;
      case 'upcoming_events':
        return Icons.event_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      case 'portfolio':
        return Icons.account_balance_rounded;
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
              color: Colors.white24,
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
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.notifier.resetToDefaults();
                    setState(() {
                      _configs = [
                        const HomeWidgetConfig(
                          id: 'shield_signal', visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'markets', visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'portfolio', visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'watchlist', visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'news', visible: true,
                        ),
                        const HomeWidgetConfig(
                          id: 'upcoming_events', visible: true,
                        ),
                      ];
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.accentBlue,
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
              onReorder: _onReorder,
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
                        ? AppTheme.cardDark
                        : AppTheme.cardDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.visible
                          ? Colors.white10
                          : Colors.white.withValues(alpha: 0.03),
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
                            color: AppTheme.textDim,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _widgetIcon(config.id),
                          color: config.visible
                              ? AppTheme.accentBlue
                              : AppTheme.textDim,
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
                            ? Colors.white
                            : AppTheme.textDim,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: config.visible
                          ? () => _toggleVisibility(config.id)
                          : () => _toggleVisibility(config.id),
                      child: Icon(
                        config.visible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: config.visible
                            ? AppTheme.accentBlue
                            : AppTheme.textDim,
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
