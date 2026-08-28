import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/layout/bottom_clearance.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_button.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/notifications/notification_providers.dart';
import '../../l10n/gen/app_localizations.dart';
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
    final palette = resolveAppPalette(ref.read(themeVariantProvider));

    showModalBottomSheet(
      context: context,
      // See portfolio_body.dart's identical fix: without this, the sheet
      // pushes onto the ShellRoute's nested Navigator, and the shell's
      // extendBody Scaffold paints its persistent bottom nav bar on top
      // of the sheet's lower edge instead of the sheet covering it.
      useRootNavigator: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return _WidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
          palette: palette,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgetConfigs = ref.watch(homeWidgetsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    // Resolved once per build from whichever theme is active — see
    // app_palette.dart. The app-wide background gradient itself is now
    // painted once in main.dart (not here) so every screen picks it up
    // uniformly; this local palette only drives this screen's own
    // AppBar/button/widget-card styling.
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        // Bottom-nav tab root (ShellRoute) — normally not poppable, so
        // Flutter's own automaticallyImplyLeading already shows nothing.
        // Only supply a themed one for the rare case this screen IS
        // pushed with a back stack, instead of unconditionally adding a
        // back button that wasn't there before.
        leading: Navigator.canPop(context)
            ? themedBackButton(context, palette)
            : null,
        title: themedHeaderText(
          'F.O.M.O. SHIELD',
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
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
              child: themedHeaderIcon(
                Icons.notifications_none_rounded,
                palette,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: palette.accentPrimary,
        backgroundColor: palette.card,
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
                child: themedAddWidgetsButton(
                  context,
                  palette,
                  label: AppLocalizations.of(context)!.homeAddWidgets,
                  onTap: _showWidgetsBottomSheet,
                ),
              ),
              const DisclaimerFooter(),
              SizedBox(height: shellBottomClearance(context)),
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
  final AppPalette palette;

  const _WidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
    required this.palette,
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
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final isLuxury = palette.windowGradient != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
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
              color: isLuxury ? Colors.white.withValues(alpha: 0.24) : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  l10n.homeWidgetSettingsTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: palette.textHeader,
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
                    l10n.homeReset,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.accentPrimary,
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
                final rowContent = ListTile(
                  key: ValueKey('${config.id}_tile'),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: palette.textBody,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _widgetIcon(config.id),
                        color: config.visible
                            ? palette.accentPrimary
                            : palette.textBody,
                        size: 22,
                      ),
                    ],
                  ),
                  title: Text(
                    config.displayName(l10n),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: config.visible
                          ? palette.textHeader
                          : palette.textBody,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _toggleVisibility(config.id),
                    child: Icon(
                      config.visible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: config.visible
                          ? palette.accentPrimary
                          : palette.textBody,
                      size: 22,
                    ),
                  ),
                );
                final card = isLuxury
                    ? Opacity(
                        opacity: config.visible ? 1.0 : 0.55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: palette.windowGradient,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: palette.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: rowContent,
                        ),
                      )
                    : Container(
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
                        child: rowContent,
                      );
                return Container(
                  key: ValueKey(config.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: card,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
