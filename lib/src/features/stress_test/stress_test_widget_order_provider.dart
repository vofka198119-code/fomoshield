// ---------------------------------------------------------------------------
// StressTest Widget Order Provider — drag-to-reorder + hide/show
// ---------------------------------------------------------------------------
// Mirror of HomeWidgetsNotifier for the stress test screen.
// Persists order & visibility in SharedPreferences keyed by sessionId.
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for a reorderable widget on the stress test screen.
class StressTestWidgetConfig {
  final String id;
  final bool visible;

  const StressTestWidgetConfig({
    required this.id,
    required this.visible,
  });

  String get displayName {
    switch (id) {
      case 'psychology_meter':
        return 'Psychology Meter';
      case 'my_assets':
        return 'My Assets';
      case 'market_timeline':
        return 'Market Timeline';
      case 'corporate_events':
        return 'Corporate Events';
      case 'trade_history':
        return 'Trade History';
      case 'timer':
        return 'Timer';
      default:
        return id;
    }
  }

}

/// Default order of reorderable widgets.
const List<String> _defaultOrder = [
  'psychology_meter',
  'my_assets',
  'market_timeline',
  'corporate_events',
  'trade_history',
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

  // ── Load from SharedPreferences ──────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved order
    final savedOrder = prefs.getStringList(_orderKey);
    final orderIds =
        (savedOrder != null && savedOrder.isNotEmpty) ? savedOrder : _defaultOrder;

    // Merge: add any new default widgets that aren't in saved order
    final merged = <String>[...orderIds];
    for (final id in _defaultOrder) {
      if (!merged.contains(id)) merged.add(id);
    }

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

    state = merged.map((id) {
      return StressTestWidgetConfig(
        id: id,
        visible: visibilityMap[id] ?? true,
      );
    }).toList();
  }

  // ── Save to SharedPreferences ────────────────────────────────────

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _orderKey,
      state.map((c) => c.id).toList(),
    );
    await prefs.setString(
      _visibilityKey,
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

  // ── Reorder ──────────────────────────────────────────────────────

  Future<void> reorder(String id, int newIndex) async {
    final currentIndex = state.indexWhere((c) => c.id == id);
    if (currentIndex < 0) return;
    final config = state[currentIndex];
    final newList = [...state]
      ..removeAt(currentIndex)
      ..insert(newIndex.clamp(0, state.length - 1), config);
    state = newList;
    await _saveLocal();
  }

  // ── Toggle visibility ────────────────────────────────────────────

  Future<void> toggleVisibility(String id) async {
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
    state = _defaultOrder
        .map((id) => StressTestWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
  }
}

/// Provider for stress test widget order — keyed by sessionId.
final stressTestWidgetOrderProvider = StateNotifierProvider.family<
    StressTestWidgetsNotifier,
    List<StressTestWidgetConfig>,
    String>(
  (ref, sessionId) => StressTestWidgetsNotifier(sessionId),
);
