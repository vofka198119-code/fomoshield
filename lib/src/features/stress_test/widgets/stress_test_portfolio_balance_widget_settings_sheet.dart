// ---------------------------------------------------------------------------
// Portfolio Balance Widget Settings Sheet — reorder + show/hide bottom sheet
// for the Portfolio Balance detail screen's 4 widgets. Mirror of
// stress_test_screen.dart's _StressTestWidgetSettingsSheet, scoped to
// PortfolioBalanceWidgetsNotifier instead of the main screen's provider.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../stress_test_portfolio_balance_widget_order_provider.dart';

class StressTestPortfolioBalanceWidgetSettingsSheet extends StatefulWidget {
  final List<PortfolioBalanceWidgetConfig> initialConfigs;
  final PortfolioBalanceWidgetsNotifier notifier;

  const StressTestPortfolioBalanceWidgetSettingsSheet({
    super.key,
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<StressTestPortfolioBalanceWidgetSettingsSheet> createState() =>
      _StressTestPortfolioBalanceWidgetSettingsSheetState();
}

class _StressTestPortfolioBalanceWidgetSettingsSheetState
    extends State<StressTestPortfolioBalanceWidgetSettingsSheet> {
  late List<PortfolioBalanceWidgetConfig> _configs;

  // 'portfolio_health' is pinned first — never draggable, never hidden
  // (mirrors the main Stress Test screen's pinned-first pattern).
  static const _pinnedFirstId = 'portfolio_health';

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    final id = _configs[oldIndex].id;
    if (id == _pinnedFirstId) return;
    final clampedIndex = newIndex.clamp(1, _configs.length - 1);
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(clampedIndex, item);
    });
    widget.notifier.reorder(id, clampedIndex);
  }

  void _toggleVisibility(String id) {
    if (id == _pinnedFirstId) return;
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = PortfolioBalanceWidgetConfig(
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
        height: MediaQuery.of(context).size.height * 0.55,
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
                        _configs = portfolioBalanceDefaultWidgetOrder
                            .map(
                              (id) => PortfolioBalanceWidgetConfig(
                                id: id,
                                visible: true,
                              ),
                            )
                            .toList();
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
                  final isPinned = config.id == _pinnedFirstId;
                  return ListTile(
                    key: ValueKey(config.id),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      config.displayName,
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
      case 'portfolio_health':
        return Icons.health_and_safety_rounded;
      case 'asset_allocation':
        return Icons.pie_chart_rounded;
      case 'diversification_indicator':
        return Icons.category_rounded;
      case 'diversification_progress':
        return Icons.bar_chart_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}
