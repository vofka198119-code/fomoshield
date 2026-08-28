import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../company_widget_order_provider.dart';

// ===========================================================================
// Company Detail Widgets Settings BottomSheet
// ===========================================================================

class CompanyWidgetsSettingsSheet extends StatefulWidget {
  final List<CompanyWidgetConfig> initialConfigs;
  final CompanyWidgetsNotifier notifier;
  final AppPalette palette;

  const CompanyWidgetsSettingsSheet({
    super.key,
    required this.initialConfigs,
    required this.notifier,
    required this.palette,
  });

  @override
  State<CompanyWidgetsSettingsSheet> createState() =>
      _CompanyWidgetsSettingsSheetState();
}

class _CompanyWidgetsSettingsSheetState
    extends State<CompanyWidgetsSettingsSheet> {
  late List<CompanyWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  // 'price_header' is pinned first — never draggable, never hidden.
  static const _pinnedFirstId = 'price_header';

  void _onReorder(int oldIndex, int newIndex) {
    if (_configs[oldIndex].id == _pinnedFirstId) return;
    if (newIndex == 0) newIndex = 1;
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    widget.notifier.reorder(_configs[newIndex].id, newIndex);
  }

  void _toggleVisibility(String id) {
    if (id == _pinnedFirstId) return;
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = CompanyWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'price_header':
        return Icons.business_rounded;
      case 'chart':
        return Icons.show_chart_rounded;
      case 'key_metrics':
        return Icons.analytics_rounded;
      case 'financial_score':
        return Icons.shield_rounded;
      case 'position':
        return Icons.account_balance_wallet_rounded;
      case 'limit_orders':
        return Icons.pending_actions_rounded;
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
        // viewInsets covers the keyboard; padding.bottom covers the
        // device's own system nav bar / gesture area.
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
                      _configs = defaultCompanyWidgetOrder
                          .map(
                            (id) => CompanyWidgetConfig(id: id, visible: true),
                          )
                          .toList();
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
                final isPinned = config.id == _pinnedFirstId;
                final rowContent = ListTile(
                  key: ValueKey('${config.id}_tile'),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle — pinned widget can't be dragged.
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
                final card = isLuxury
                    ? Opacity(
                        opacity: config.visible ? 1.0 : 0.55,
                        child: themedBorder(
                          palette: palette,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: palette.windowGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: rowContent,
                          ),
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
