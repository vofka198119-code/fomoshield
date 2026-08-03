// ---------------------------------------------------------------------------
// Portfolio Balance Widget Order Provider — drag-to-reorder + hide/show for
// the Portfolio Balance detail screen's 4 widgets (Portfolio Health, Asset
// Allocation %, Diversification Indicator, Diversification Progress).
// Mirror of StressTestWidgetsNotifier (stress_test_widget_order_provider.dart)
// scoped to this screen instead of the main Stress Test screen.
// Persists order & visibility in SharedPreferences keyed by sessionId.
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for a reorderable widget on the Portfolio Balance screen.
class PortfolioBalanceWidgetConfig {
  final String id;
  final bool visible;

  const PortfolioBalanceWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'portfolio_health':
        return 'Portfolio Health';
      case 'asset_allocation':
        return 'Asset Allocation %';
      case 'diversification_indicator':
        return 'Diversification Indicator';
      case 'diversification_progress':
        return 'Diversification Progress';
      default:
        return id;
    }
  }
}

/// Default order of reorderable widgets. 'portfolio_health' is pinned first
/// (see [PortfolioBalanceWidgetsNotifier._pinnedFirstId]) — never hidden,
/// never draggable out of position, matching the dashboard-style summary's
/// fixed placement above the raw breakdown widgets.
const List<String> portfolioBalanceDefaultWidgetOrder = [
  'portfolio_health',
  'asset_allocation',
  'diversification_indicator',
  'diversification_progress',
];

/// Notifier that manages widget order & visibility, persisted in SharedPreferences.
class PortfolioBalanceWidgetsNotifier
    extends StateNotifier<List<PortfolioBalanceWidgetConfig>> {
  final String _sessionId;

  PortfolioBalanceWidgetsNotifier(this._sessionId) : super([]) {
    _load();
  }

  String get _orderKey => 'portfolio_balance_widget_order_$_sessionId';
  String get _visibilityKey =>
      'portfolio_balance_widget_visibility_$_sessionId';

  // 'portfolio_health' is pinned first — always at that position, never
  // hidden. Guarded here too (not just in the settings sheet UI) so it
  // holds regardless of caller.
  static const _pinnedFirstId = 'portfolio_health';

  /// Forces the pinned id to its fixed position regardless of whatever
  /// order it arrived in.
  List<String> _normalizePinned(List<String> ids) {
    final rest = [...ids]..remove(_pinnedFirstId);
    return [_pinnedFirstId, ...rest];
  }

  // ── Load from SharedPreferences ──────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedOrder = prefs.getStringList(_orderKey);
    final orderIds = (savedOrder != null && savedOrder.isNotEmpty)
        ? savedOrder
        : portfolioBalanceDefaultWidgetOrder;

    // Merge: drop stale ids no longer in the default set, then add any new
    // default widgets missing from the saved order.
    final merged = <String>[
      ...orderIds.where(portfolioBalanceDefaultWidgetOrder.contains),
    ];
    for (final id in portfolioBalanceDefaultWidgetOrder) {
      if (!merged.contains(id)) merged.add(id);
    }
    final normalized = _normalizePinned(merged);

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
      return PortfolioBalanceWidgetConfig(
        id: id,
        visible: visibilityMap[id] ?? true,
      );
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
    if (id == _pinnedFirstId) return;
    final currentIndex = state.indexWhere((c) => c.id == id);
    if (currentIndex < 0) return;
    final config = state[currentIndex];
    final clampedIndex = newIndex.clamp(1, state.length - 1);
    final newList = [...state]
      ..removeAt(currentIndex)
      ..insert(clampedIndex, config);
    state = newList;
    await _saveLocal();
  }

  // ── Toggle visibility ────────────────────────────────────────────

  Future<void> toggleVisibility(String id) async {
    if (id == _pinnedFirstId) return;
    state = state.map((c) {
      if (c.id == id) {
        return PortfolioBalanceWidgetConfig(id: c.id, visible: !c.visible);
      }
      return c;
    }).toList();
    await _saveLocal();
  }

  // ── Reset to defaults ────────────────────────────────────────────

  Future<void> resetToDefaults() async {
    state = portfolioBalanceDefaultWidgetOrder
        .map((id) => PortfolioBalanceWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
  }
}

/// Provider for Portfolio Balance widget order — keyed by sessionId.
final portfolioBalanceWidgetOrderProvider =
    StateNotifierProvider.family<
      PortfolioBalanceWidgetsNotifier,
      List<PortfolioBalanceWidgetConfig>,
      String
    >((ref, sessionId) => PortfolioBalanceWidgetsNotifier(sessionId));
