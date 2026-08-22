// ---------------------------------------------------------------------------
// StressTest Widget Order Provider — drag-to-reorder + hide/show
// ---------------------------------------------------------------------------
// Mirror of HomeWidgetsNotifier for the stress test screen.
// Persists order & visibility in SharedPreferences keyed by sessionId.
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/gen/app_localizations.dart';

/// Configuration for a reorderable widget on the stress test screen.
class StressTestWidgetConfig {
  final String id;
  final bool visible;

  const StressTestWidgetConfig({required this.id, required this.visible});

  String displayName(AppLocalizations l10n) {
    switch (id) {
      case 'allocation_chart':
        return l10n.stressTestWidgetPortfolioBalance;
      case 'cash':
        return l10n.stressTestWidgetCashAvailable;
      case 'psychology_meter':
        return l10n.stressTestWidgetPsychologyMeter;
      case 'my_assets':
        return l10n.stressTestWidgetHoldings;
      case 'price_chart':
        return l10n.stressTestWidgetPriceChart;
      case 'epoch_history':
        return l10n.stressTestWidgetEpochs;
      case 'trade_history':
        return l10n.stressTestWidgetTradeHistory;
      case 'limit_orders':
        return l10n.stressTestWidgetLimitOrders;
      case 'timer':
        return l10n.stressTestWidgetTimer;
      default:
        return id;
    }
  }
}

/// Default order of reorderable widgets. 'allocation_chart' is pinned first
/// and 'timer' is pinned last (see [StressTestWidgetsNotifier._pinnedFirstId]
/// / [_pinnedLastId]) — never hidden, never draggable out of position.
const List<String> stressTestDefaultWidgetOrder = [
  'allocation_chart',
  'cash',
  'price_chart',
  'my_assets',
  'psychology_meter',
  'trade_history',
  'limit_orders',
  'epoch_history',
  'timer',
];

/// Notifier that manages widget order & visibility, persisted in SharedPreferences.
class StressTestWidgetsNotifier
    extends StateNotifier<List<StressTestWidgetConfig>> {
  final String _sessionId;

  StressTestWidgetsNotifier(this._sessionId) : super([]) {
    _load();
  }

  String get _orderKey => 'stress_widget_order_$_sessionId';
  String get _visibilityKey => 'stress_widget_visibility_$_sessionId';

  // 'allocation_chart' is pinned first, 'timer' is pinned last — always at
  // those positions, never hidden. Guarded here too (not just in the
  // settings sheet UI) so it holds regardless of caller.
  static const _pinnedFirstId = 'allocation_chart';
  static const _pinnedLastId = 'timer';

  /// Forces the pinned ids to their fixed positions regardless of whatever
  /// order they arrived in (e.g. a saved layout from before these ids
  /// existed/were pinned, which would otherwise land them wherever the
  /// merge below happens to append them).
  List<String> _normalizePinned(List<String> ids) {
    final rest = [...ids]
      ..remove(_pinnedFirstId)
      ..remove(_pinnedLastId);
    return [_pinnedFirstId, ...rest, _pinnedLastId];
  }

  // ── Load from SharedPreferences ──────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved order
    final savedOrder = prefs.getStringList(_orderKey);
    final orderIds = (savedOrder != null && savedOrder.isNotEmpty)
        ? savedOrder
        : stressTestDefaultWidgetOrder;

    // Merge: drop stale ids no longer in the default set (e.g. the removed
    // 'corporate_events'), then add any new default widgets missing from
    // the saved order.
    final merged = <String>[
      ...orderIds.where(stressTestDefaultWidgetOrder.contains),
    ];
    for (final id in stressTestDefaultWidgetOrder) {
      if (!merged.contains(id)) merged.add(id);
    }
    final normalized = _normalizePinned(merged);

    // Load visibility
    final visibilityStr = prefs.getString(_visibilityKey) ?? '';
    final visibilityMap = <String, bool>{};
    if (visibilityStr.isNotEmpty) {
      for (final pair in visibilityStr.split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          visibilityMap[parts[0]] = parts[1] == 'true';
        }
      }
    }

    state = normalized.map((id) {
      return StressTestWidgetConfig(id: id, visible: visibilityMap[id] ?? true);
    }).toList();
  }

  // ── Save to SharedPreferences ────────────────────────────────────

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, state.map((c) => c.id).toList());
    await prefs.setString(
      _visibilityKey,
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

  // ── Reorder ──────────────────────────────────────────────────────

  Future<void> reorder(String id, int newIndex) async {
    if (id == _pinnedFirstId || id == _pinnedLastId) return;
    final currentIndex = state.indexWhere((c) => c.id == id);
    if (currentIndex < 0) return;
    final config = state[currentIndex];
    final clampedIndex = newIndex.clamp(1, state.length - 2);
    final newList = [...state]
      ..removeAt(currentIndex)
      ..insert(clampedIndex, config);
    state = newList;
    await _saveLocal();
  }

  // ── Toggle visibility ────────────────────────────────────────────

  Future<void> toggleVisibility(String id) async {
    if (id == _pinnedFirstId || id == _pinnedLastId) return;
    state = state.map((c) {
      if (c.id == id) {
        return StressTestWidgetConfig(id: c.id, visible: !c.visible);
      }
      return c;
    }).toList();
    await _saveLocal();
  }

  // ── Reset to defaults ────────────────────────────────────────────

  Future<void> resetToDefaults() async {
    state = stressTestDefaultWidgetOrder
        .map((id) => StressTestWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
  }
}

/// Provider for stress test widget order — keyed by sessionId.
final stressTestWidgetOrderProvider =
    StateNotifierProvider.family<
      StressTestWidgetsNotifier,
      List<StressTestWidgetConfig>,
      String
    >((ref, sessionId) => StressTestWidgetsNotifier(sessionId));
