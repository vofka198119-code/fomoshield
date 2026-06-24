import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Home Widget Order Provider (SharedPreferences-backed)
// ---------------------------------------------------------------------------
// Stores the visible order of widgets on the Home Screen.
// Default order: shield_signal, markets, watchlist, upcoming_events,
//                news, portfolio.
// Any changes are immediately persisted to SharedPreferences.
// ---------------------------------------------------------------------------

const List<String> _defaultOrder = [
  'shield_signal',
  'markets',
  'portfolio',
  'watchlist',
  'news',
  'upcoming_events',
];

const String _prefsKey = 'home_widget_order';
const String _prefsVisibilityKey = 'home_widget_visibility';

/// Model representing a home widget's configuration.
class HomeWidgetConfig {
  final String id;
  final bool visible;

  const HomeWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'shield_signal':
        return 'Shield Signal';
      case 'markets':
        return 'Markets';
      case 'watchlist':
        return 'Watchlist';
      case 'upcoming_events':
        return 'Upcoming Events';
      case 'news':
        return 'News';
      case 'portfolio':
        return 'My Portfolio';
      default:
        return id;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeWidgetConfig &&
          id == other.id &&
          visible == other.visible;

  @override
  int get hashCode => id.hashCode ^ visible.hashCode;
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class HomeWidgetsNotifier extends StateNotifier<List<HomeWidgetConfig>> {
  HomeWidgetsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load order
    final savedOrder = prefs.getStringList(_prefsKey);
    var order = savedOrder ?? _defaultOrder;

    // Merge: append any default widgets missing from saved order
    // This ensures new widgets appear automatically after updates
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing = _defaultOrder.where((id) => !savedSet.contains(id));
      if (missing.isNotEmpty) {
        order = [...savedOrder, ...missing];
      }
    }

    // Load visibility
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

    // Build config list preserving order, default visible = true
    state = order.map((id) {
      final visible = visibilityMap[id] ?? true;
      return HomeWidgetConfig(id: id, visible: visible);
    }).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, state.map((c) => c.id).toList());
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
      if (c.id == id) return HomeWidgetConfig(id: c.id, visible: !c.visible);
      return c;
    }).toList();
    await _save();
  }

  /// Reset to default order and visibility.
  Future<void> resetToDefaults() async {
    state = _defaultOrder
        .map((id) => HomeWidgetConfig(id: id, visible: true))
        .toList();
    await _save();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final homeWidgetsProvider =
    StateNotifierProvider<HomeWidgetsNotifier, List<HomeWidgetConfig>>((ref) {
  return HomeWidgetsNotifier();
});
