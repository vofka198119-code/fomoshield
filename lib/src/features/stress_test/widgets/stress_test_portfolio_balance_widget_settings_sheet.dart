// ---------------------------------------------------------------------------
// Portfolio Balance Widget Settings Sheet — reorder + show/hide bottom sheet
// for the Portfolio Balance detail screen's 4 widgets. Mirror of
// stress_test_screen.dart's _StressTestWidgetSettingsSheet, scoped to
// PortfolioBalanceWidgetsNotifier instead of the main screen's provider.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../stress_test_portfolio_balance_widget_order_provider.dart';

class StressTestPortfolioBalanceWidgetSettingsSheet extends StatefulWidget {
  final List<PortfolioBalanceWidgetConfig> initialConfigs;
  final PortfolioBalanceWidgetsNotifier notifier;
  final AppPalette palette;

  const StressTestPortfolioBalanceWidgetSettingsSheet({
    super.key,
    required this.initialConfigs,
    required this.notifier,
    required this.palette,
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
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final isLuxury = palette.windowGradient != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
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
                  color: isLuxury
                      ? Colors.white.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.15),
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
                      color: palette.textHeader,
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
                      l10n.homeReset,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isLuxury
                  ? palette.border.withValues(alpha: 0.3)
                  : const Color(0xFFE8E5DF),
            ),
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
                  final tile = ListTile(
                    key: isLuxury ? null : ValueKey(config.id),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isPinned
                            ? Icon(
                                Icons.push_pin_rounded,
                                color: palette.textBody,
                                size: 20,
                              )
                            : ReorderableDragStartListener(
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
                          color: palette.textBody,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Text(
                      config.displayName(l10n),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                    ),
                    trailing: isPinned
                        ? Icon(
                            Icons.visibility_rounded,
                            color: palette.textBody.withValues(alpha: 0.4),
                            size: 22,
                          )
                        : GestureDetector(
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
                  if (!isLuxury) return tile;
                  return Opacity(
                    key: ValueKey(config.id),
                    opacity: config.visible ? 1.0 : 0.55,
                    child: themedBorder(
                      palette: palette,
                      borderRadius: BorderRadius.circular(14),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: palette.windowGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: tile,
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
