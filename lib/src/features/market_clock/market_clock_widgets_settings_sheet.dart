import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';
import 'market_clock_widget_order_provider.dart';

// ---------------------------------------------------------------------------
// Widgets Settings BottomSheet — mirrors home_screen.dart's
// _WidgetsSettingsSheet (same reorder + visibility-toggle UI), scoped to
// this screen's own provider. No premium-lock concept yet since none of
// this screen's widgets are premium-gated.
// ---------------------------------------------------------------------------

class MarketClockWidgetsSettingsSheet extends StatefulWidget {
  final List<MarketClockWidgetConfig> initialConfigs;
  final MarketClockWidgetsNotifier notifier;

  const MarketClockWidgetsSettingsSheet({
    super.key,
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<MarketClockWidgetsSettingsSheet> createState() =>
      _MarketClockWidgetsSettingsSheetState();
}

class _MarketClockWidgetsSettingsSheetState
    extends State<MarketClockWidgetsSettingsSheet> {
  late List<MarketClockWidgetConfig> _configs;

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
        _configs[index] = MarketClockWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'ny_time':
        return Icons.access_time_filled_rounded;
      case 'market_phase':
        return Icons.schedule_rounded;
      case 'timing_indicator':
        return Icons.shield_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.marketClockWidgetSettingsTitle,
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
                      _configs = marketClockDefaultOrder
                          .map(
                            (id) =>
                                MarketClockWidgetConfig(id: id, visible: true),
                          )
                          .toList();
                    });
                  },
                  child: Text(
                    l10n.marketClockWidgetSettingsReset,
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
                      config.displayName(l10n),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.visible
                            ? ThemeV2.textPrimary
                            : ThemeV2.textSecondary,
                      ),
                    ),
                    trailing: Switch(
                      value: config.visible,
                      activeThumbColor: ThemeV2.primary,
                      onChanged: (_) => _toggleVisibility(config.id),
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
