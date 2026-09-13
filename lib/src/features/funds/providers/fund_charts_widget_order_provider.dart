import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fund Charts Widget Order Provider (SharedPreferences-backed) — same
// reorder/hide/show convention as Portfolio's own
// portfolio_widget_order_provider.dart (Home/Market Clock/Stress Test/
// Company Detail all have their own equivalent instance too), scoped per
// (fund, user) instead of just per user since this catalog belongs to one
// specific fund's Charts screen, not a personal account-wide screen.
//
// Catalog starts with just the chart that already existed elsewhere
// (fund balance history, moved here 2026-09-13 per the "все финансовые
// графики фонда собираем в одном месте" ask); new chart types (NAV/unit,
// drawdown, asset allocation, etc.) get appended to
// _defaultFundChartsOrder as they're built, same as every other screen's
// catalog grew over time.
// ---------------------------------------------------------------------------

const List<String> _defaultFundChartsOrder = [
  'balance_history',
  'nav_history',
  'drawdown',
  'asset_allocation',
  'commission',
];

String _orderPrefsKey(String fundId, String? uid) =>
    'fund_charts_widget_order_${fundId}_${uid ?? 'anon'}';
String _visibilityPrefsKey(String fundId, String? uid) =>
    'fund_charts_widget_visibility_${fundId}_${uid ?? 'anon'}';

class FundChartsWidgetConfig {
  final String id;
  final bool visible;

  const FundChartsWidgetConfig({required this.id, required this.visible});

  String displayName(AppLocalizations l10n) {
    switch (id) {
      case 'balance_history':
        return l10n.etfBalanceHistoryChartTitle;
      case 'nav_history':
        return l10n.etfNavHistoryChartTitle;
      case 'drawdown':
        return l10n.etfDrawdownChartTitle;
      case 'asset_allocation':
        return l10n.etfAssetAllocationChartTitle;
      case 'commission':
        return l10n.etfCommissionChartTitle;
      default:
        return id;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundChartsWidgetConfig &&
          id == other.id &&
          visible == other.visible;

  @override
  int get hashCode => id.hashCode ^ visible.hashCode;
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class FundChartsWidgetsNotifier
    extends StateNotifier<List<FundChartsWidgetConfig>> {
  final String fundId;
  final String? userId;

  FundChartsWidgetsNotifier({required this.fundId, this.userId}) : super([]) {
    _load();
  }

  /// The same default list [resetToDefaults] assigns to `state` — exposed
  /// so the settings sheet (which can't read the protected `state` field)
  /// can mirror it without hand-duplicating the widget id list.
  List<FundChartsWidgetConfig> get defaultConfigs => _defaultFundChartsOrder
      .map((id) => FundChartsWidgetConfig(id: id, visible: true))
      .toList();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final orderKey = _orderPrefsKey(fundId, userId);
    final visKey = _visibilityPrefsKey(fundId, userId);

    final savedOrder = prefs.getStringList(orderKey);
    var order = savedOrder ?? _defaultFundChartsOrder;

    // Merge: append any default widgets missing from a saved order (i.e.
    // a new chart type shipped after this user last customized the order).
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing = _defaultFundChartsOrder.where(
        (id) => !savedSet.contains(id),
      );
      if (missing.isNotEmpty) {
        order = [...savedOrder, ...missing];
      }
    }

    final savedVisibility = prefs.getString(visKey);
    final visibilityMap = <String, bool>{};
    if (savedVisibility != null) {
      try {
        for (final part in savedVisibility.split(',')) {
          final kv = part.split(':');
          if (kv.length == 2) visibilityMap[kv[0]] = kv[1] == 'true';
        }
      } catch (_) {}
    }

    state = order
        .map(
          (id) => FundChartsWidgetConfig(
            id: id,
            visible: visibilityMap[id] ?? true,
          ),
        )
        .toList();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _orderPrefsKey(fundId, userId),
      state.map((c) => c.id).toList(),
    );
    await prefs.setString(
      _visibilityPrefsKey(fundId, userId),
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

  Future<void> reorder(String id, int newIndex) async {
    final currentIndex = state.indexWhere((c) => c.id == id);
    if (currentIndex < 0) return;

    final config = state[currentIndex];
    final clampedIndex = newIndex.clamp(0, state.length - 1);
    final newList = [...state]
      ..removeAt(currentIndex)
      ..insert(clampedIndex, config);

    state = newList;
    await _saveLocal();
  }

  Future<void> toggleVisibility(String id) async {
    state = state.map((c) {
      if (c.id == id) {
        return FundChartsWidgetConfig(id: c.id, visible: !c.visible);
      }
      return c;
    }).toList();
    await _saveLocal();
  }

  Future<void> resetToDefaults() async {
    state = defaultConfigs;
    await _saveLocal();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final fundChartsWidgetsProvider =
    StateNotifierProvider.family<
      FundChartsWidgetsNotifier,
      List<FundChartsWidgetConfig>,
      String
    >((ref, fundId) {
      final user = ref.watch(currentUserProvider);
      return FundChartsWidgetsNotifier(fundId: fundId, userId: user?.id);
    });
