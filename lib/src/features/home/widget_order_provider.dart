import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/user_data_service.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Home Widget Order Provider (SharedPreferences-backed)
// ---------------------------------------------------------------------------
// Stores the visible order of widgets on the Home Screen.
// Default order: shield_signal, markets, watchlist, upcoming_events,
//                news, portfolio.
// Any changes are immediately persisted to SharedPreferences.
// ---------------------------------------------------------------------------

const List<String> _defaultOrder = [
  // Bible Part 2 — Main Screen Sections (in order)
  'portfolio',
  'holdings',
  'analysis',
  'verdict',
  // Legacy / utility widgets
  'shield_signal',
  'markets',
  'stress_test',
  'watchlist',
  'news',
  'upcoming_events',
  // Premium widgets (hidden by default for FREE, shown with 🔒)
  'portfolio_journal',
  'historical_sim',
  'scenario_compare',
];

String _prefsKey(String? uid) =>
    uid != null ? 'home_widget_order_$uid' : 'home_widget_order';
String _prefsVisibilityKey(String? uid) =>
    uid != null ? 'home_widget_visibility_$uid' : 'home_widget_visibility';

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
      case 'stress_test':
        return 'Stress Test';
      case 'portfolio':
        return 'My Portfolio';
      case 'holdings':
        return 'Holdings';
      case 'analysis':
        return 'Analysis';
      case 'verdict':
        return 'Latest Verdict';
      case 'portfolio_journal':
        return 'Portfolio Journal';
      case 'historical_sim':
        return 'Historical Simulator';
      case 'scenario_compare':
        return 'Scenario Comparison';
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
  final UserDataService _supabaseService;
  String? _userId;

  HomeWidgetsNotifier(this._supabaseService, {this._userId})
      : super([]) {
    _load();
  }

  /// Set user ID to enable Supabase sync + re-scope local cache.
  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  /// Load widget order from Supabase data (replaces local).
  void loadFromSupabase(List<HomeWidgetConfig> configs) {
    if (configs.isEmpty) return;
    state = configs;
    _saveLocal();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final orderKey = _prefsKey(_userId);
    final visKey = _prefsVisibilityKey(_userId);

    // Load order
    final savedOrder = prefs.getStringList(orderKey);
    var order = savedOrder ?? _defaultOrder;

    // Merge: append any default widgets missing from saved order
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing = _defaultOrder.where((id) => !savedSet.contains(id));
      if (missing.isNotEmpty) {
        order = [...savedOrder, ...missing];
      }
    }

    // Load visibility
    final savedVisibility = prefs.getString(visKey);
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

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey(_userId), state.map((c) => c.id).toList());
    await prefs.setString(
      _prefsVisibilityKey(_userId),
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

  Future<void> _syncToSupabase() async {
    final uid = _userId;
    if (uid != null) {
      await _supabaseService.saveWidgetOrder(uid, state);
    }
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
    await _saveLocal();
    _syncToSupabase();
  }

  /// Toggle visibility of a widget.
  Future<void> toggleVisibility(String id) async {
    state = state.map((c) {
      if (c.id == id) return HomeWidgetConfig(id: c.id, visible: !c.visible);
      return c;
    }).toList();
    await _saveLocal();
    _syncToSupabase();
  }

  /// Reset to default order and visibility.
  Future<void> resetToDefaults() async {
    state = _defaultOrder
        .map((id) => HomeWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
    _syncToSupabase();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final homeWidgetsProvider =
    StateNotifierProvider<HomeWidgetsNotifier, List<HomeWidgetConfig>>((ref) {
  final service = ref.read(userDataServiceProvider);
  final user = ref.watch(currentUserProvider);
  return HomeWidgetsNotifier(service, userId: user?.id);
});
