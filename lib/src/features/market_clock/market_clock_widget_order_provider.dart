import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Market Clock Widget Order Provider (SharedPreferences-backed)
// ---------------------------------------------------------------------------
// Mirrors home/widget_order_provider.dart's pattern, scoped to the Market
// Clock screen instead of the Home screen. Default order: ny_time,
// market_phase, timing_indicator.
// ---------------------------------------------------------------------------

const List<String> marketClockDefaultOrder = [
  'ny_time',
  'market_phase',
  'timing_indicator',
];

const _prefsOrderKey = 'market_clock_widget_order';
const _prefsVisibilityKey = 'market_clock_widget_visibility';

/// Model representing a Market Clock screen widget's configuration.
class MarketClockWidgetConfig {
  final String id;
  final bool visible;

  const MarketClockWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'ny_time':
        return 'New York Time';
      case 'market_phase':
        return 'Market Phase';
      case 'timing_indicator':
        return 'FOMO Shield Status';
      default:
        return id;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketClockWidgetConfig &&
          id == other.id &&
          visible == other.visible;

  @override
  int get hashCode => id.hashCode ^ visible.hashCode;
}

class MarketClockWidgetsNotifier
    extends StateNotifier<List<MarketClockWidgetConfig>> {
  MarketClockWidgetsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList(_prefsOrderKey);
    var order = savedOrder ?? marketClockDefaultOrder;

    // Merge: append any default widgets missing from saved order, and drop
    // any saved ids that have since been retired.
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing =
          marketClockDefaultOrder.where((id) => !savedSet.contains(id));
      order = [
        ...savedOrder.where((id) => marketClockDefaultOrder.contains(id)),
        ...missing,
      ];
    }

    final savedVisibility = prefs.getString(_prefsVisibilityKey);
    Map<String, bool> visibilityMap = {};
    if (savedVisibility != null) {
      try {
        final parts = savedVisibility.split(',');
        for (final part in parts) {
          final kv = part.split(':');
          if (kv.length == 2) {
            visibilityMap[kv[0]] = kv[1] == 'true';
          }
        }
      } catch (_) {}
    }

    state = order.map((id) {
      final visible = visibilityMap[id] ?? true;
      return MarketClockWidgetConfig(id: id, visible: visible);
    }).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsOrderKey, state.map((c) => c.id).toList());
    await prefs.setString(
      _prefsVisibilityKey,
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

  /// Reorder by moving [id] from its current position to [newIndex].
  Future<void> reorder(String id, int newIndex) async {
    final currentIndex = state.indexWhere((c) => c.id == id);
    if (currentIndex < 0) return;

    final config = state[currentIndex];
    final newList = [...state]
      ..removeAt(currentIndex)
      ..insert(newIndex.clamp(0, state.length - 1), config);

    state = newList;
    await _save();
  }

  /// Toggle visibility of a widget.
  Future<void> toggleVisibility(String id) async {
    state = state.map((c) {
      if (c.id == id) {
        return MarketClockWidgetConfig(id: c.id, visible: !c.visible);
      }
      return c;
    }).toList();
    await _save();
  }

  /// Reset to default order and visibility.
  Future<void> resetToDefaults() async {
    state = marketClockDefaultOrder
        .map((id) => MarketClockWidgetConfig(id: id, visible: true))
        .toList();
    await _save();
  }
}

final marketClockWidgetsProvider = StateNotifierProvider<
    MarketClockWidgetsNotifier, List<MarketClockWidgetConfig>>(
  (ref) => MarketClockWidgetsNotifier(),
);
