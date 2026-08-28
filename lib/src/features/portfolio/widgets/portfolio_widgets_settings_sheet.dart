part of '../portfolio_screen.dart';

// ---------------------------------------------------------------------------
// Widget Settings BottomSheet (matching HomeScreen exactly)
// ---------------------------------------------------------------------------

class _PortfolioWidgetsSettingsSheet extends StatefulWidget {
  final List<PortfolioWidgetConfig> initialConfigs;
  final PortfolioWidgetsNotifier notifier;
  final AppPalette palette;

  const _PortfolioWidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
    required this.palette,
  });

  @override
  State<_PortfolioWidgetsSettingsSheet> createState() =>
      _PortfolioWidgetsSettingsSheetState();
}

class _PortfolioWidgetsSettingsSheetState
    extends State<_PortfolioWidgetsSettingsSheet> {
  late List<PortfolioWidgetConfig> _configs;

  // 'portfolio_balance' is pinned first — never draggable, never hidden
  // (mirrors Stress Test's own pinned-first widget in its equivalent
  // settings sheet).
  static const _pinnedFirstId = 'portfolio_balance';

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorder(int oldIndex, int newIndex) {
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
      case 'portfolio_balance':
        return Icons.pie_chart_rounded;
      case 'portfolio_cash':
        return Icons.payments_rounded;
      case 'target':
        return Icons.track_changes_rounded;
      case 'portfolio_holdings':
        return Icons.view_list_rounded;
      case 'trade_history':
        return Icons.receipt_long_rounded;
      case 'my_limit_orders':
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
        // device's own system nav bar / gesture area — now that this
        // sheet pushes onto the root Navigator (see the useRootNavigator
        // fix at its call site), it's no longer sitting above the app's
        // own bottom nav bar, so it needs to clear the OS one itself.
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
                  l10n.portfolioWidgetsSettingsSheetTitle,
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
                    // Mirror the same default list the notifier just reset
                    // its (protected, unreadable-from-here) state to —
                    // this used to be hand-duplicated and had drifted out
                    // of sync, silently dropping 2 of the 9 widgets.
                    setState(() {
                      _configs = widget.notifier.defaultConfigs;
                    });
                  },
                  child: Text(
                    l10n.marketClockWidgetSettingsReset,
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
                      // Pinned widgets can't be dragged.
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
