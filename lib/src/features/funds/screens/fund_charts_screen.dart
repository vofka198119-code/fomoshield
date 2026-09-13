import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/year_picker_sheet.dart';
import '../providers/fund_charts_widget_order_provider.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_asset_allocation_card.dart';
import '../widgets/fund_commission_chart.dart';
import '../widgets/fund_drawdown_chart.dart';
import '../widgets/fund_monthly_line_chart.dart';

// ---------------------------------------------------------------------------
// Fund Charts — a dedicated hub for every financial chart about the fund
// (2026-09-13 ask: "все фин графики по фонду" in one customizable place),
// reached from FundManagementScreen's own circle-shortcut row. Same
// reorder/hide-show "Add Widgets" convention as Portfolio/Home/Market
// Clock/Stress Test/Company Detail (fund_charts_widget_order_provider.dart
// is the per-screen catalog, same shape as portfolio_widget_order_provider.dart).
//
// Balance History moved here from Fund Management's main list (was
// previously right under the "Available" cash widget) -- the year-picker
// state that used to live on FundManagementScreen moved with it. The two
// Investor inflow/outflow charts deliberately stayed on the Investors
// screen instead of moving here too (2026-09-13 decision): they're tied
// to that screen's own stats/list, not generic fund performance.
// ---------------------------------------------------------------------------
class FundChartsScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundChartsScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundChartsScreen> createState() => _FundChartsScreenState();
}

class _FundChartsScreenState extends ConsumerState<FundChartsScreen> {
  late int _selectedYear = DateTime.now().year;

  Future<void> _pickYear(AppPalette palette, int firstYear) async {
    final picked = await showYearPickerSheet(
      context: context,
      palette: palette,
      selectedYear: _selectedYear,
      firstYear: firstYear,
    );
    if (picked != null && picked != _selectedYear) {
      setState(() => _selectedYear = picked);
    }
  }

  void _showWidgetsBottomSheet(AppPalette palette) {
    final notifier = ref.read(fundChartsWidgetsProvider(widget.fundId).notifier);
    final currentConfigs = ref.read(fundChartsWidgetsProvider(widget.fundId));

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => _FundChartsWidgetsSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
        palette: palette,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final configs = ref.watch(fundChartsWidgetsProvider(widget.fundId));
    final visible = configs.where((c) => c.visible).toList();
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));
    final firstYear = fundAsync.valueOrNull?.createdAt.year ?? _selectedYear;
    // Both queries have to be ready before ANY widget renders -- the fund
    // (asset_allocation's source) tends to resolve first since it's often
    // already cached from the screen this was opened from, while
    // balance/nav/drawdown wait on their own slower year-scoped query.
    // Rendering asset_allocation the moment it's ready and letting the
    // other three pop in later, above it, made it visibly jump from the
    // top of the list down to its real position once they loaded
    // (confirmed on-device). Gating everything on the slower of the two
    // means every visible card appears together, already in final order.
    final history = ref.watch(
      fundBalanceHistoryProvider((widget.fundId, _selectedYear)),
    );
    final commissionHistory = ref.watch(
      fundCommissionHistoryProvider((widget.fundId, _selectedYear)),
    );
    final holdings = fundAsync.valueOrNull?.holdings;
    final ready =
        history.valueOrNull != null &&
        commissionHistory.valueOrNull != null &&
        holdings != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfChartsScreenTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            if (!ready)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              for (final config in visible) ...[
                switch (config.id) {
                  'balance_history' => FundMonthlyLineChart(
                    title: l10n.etfBalanceHistoryChartTitle,
                    monthlyValues: history.requireValue.balance,
                    palette: palette,
                    selectedYear: _selectedYear,
                    onTapYear: () => _pickYear(palette, firstYear),
                  ),
                  'nav_history' => FundMonthlyLineChart(
                    title: l10n.etfNavHistoryChartTitle,
                    monthlyValues: history.requireValue.navPerUnit,
                    palette: palette,
                    selectedYear: _selectedYear,
                    onTapYear: () => _pickYear(palette, firstYear),
                    axisLabelFormatter: (v) => '\$${v.toStringAsFixed(2)}',
                  ),
                  'drawdown' => FundDrawdownChart(
                    monthlyDrawdownPercent:
                        history.requireValue.drawdownPercent,
                    palette: palette,
                    selectedYear: _selectedYear,
                    onTapYear: () => _pickYear(palette, firstYear),
                  ),
                  'asset_allocation' => FundAssetAllocationCard(
                    holdings: holdings,
                    palette: palette,
                  ),
                  'commission' => FundCommissionChart(
                    monthlyCommission: commissionHistory.requireValue.commission,
                    palette: palette,
                    selectedYear: _selectedYear,
                    onTapYear: () => _pickYear(palette, firstYear),
                  ),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(height: 12),
              ],
            Center(
              child: themedAddWidgetsButton(
                context,
                palette,
                label: l10n.homeAddWidgets,
                onTap: () => _showWidgetsBottomSheet(palette),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings sheet — reorder + show/hide, same recipe as
// portfolio_widgets_settings_sheet.dart. No pinned-first widget yet (only
// one chart exists so far); add one the same way Portfolio pins
// 'portfolio_balance' if a future chart should always lead.
// ---------------------------------------------------------------------------
class _FundChartsWidgetsSettingsSheet extends StatefulWidget {
  final List<FundChartsWidgetConfig> initialConfigs;
  final FundChartsWidgetsNotifier notifier;
  final AppPalette palette;

  const _FundChartsWidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
    required this.palette,
  });

  @override
  State<_FundChartsWidgetsSettingsSheet> createState() =>
      _FundChartsWidgetsSettingsSheetState();
}

class _FundChartsWidgetsSettingsSheetState
    extends State<_FundChartsWidgetsSettingsSheet> {
  late List<FundChartsWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final id = _configs[oldIndex].id;
    final clampedIndex = newIndex.clamp(0, _configs.length - 1);
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(clampedIndex, item);
    });
    widget.notifier.reorder(id, clampedIndex);
  }

  void _toggleVisibility(String id) {
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = FundChartsWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'balance_history':
        return Icons.show_chart_rounded;
      case 'nav_history':
        return Icons.trending_up_rounded;
      case 'drawdown':
        return Icons.trending_down_rounded;
      case 'asset_allocation':
        return Icons.pie_chart_rounded;
      case 'commission':
        return Icons.receipt_long_rounded;
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
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isLuxury
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  l10n.etfChartsWidgetsSettingsSheetTitle,
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
