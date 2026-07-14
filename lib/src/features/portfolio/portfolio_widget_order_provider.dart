import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Widget Order Provider (SharedPreferences-backed)
// ---------------------------------------------------------------------------
// Allows reordering, hiding/showing, and adding widgets on the Portfolio
// screen — identical UX to Home widget customization.
// Premium widgets are available here too.
// ---------------------------------------------------------------------------

const List<String> _defaultPortfolioWidgetOrder = [
  'portfolio_summary',
  'portfolio_allocation',
  'portfolio_holdings',
  'portfolio_journal',
  'historical_sim',
  'scenario_compare',
];

String _orderPrefsKey(String? uid) =>
    uid != null ? 'portfolio_widget_order_$uid' : 'portfolio_widget_order';
String _visibilityPrefsKey(String? uid) =>
    uid != null ? 'portfolio_widget_visibility_$uid' : 'portfolio_widget_visibility';

/// Model representing a portfolio widget's configuration.
class PortfolioWidgetConfig {
  final String id;
  final bool visible;

  const PortfolioWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'portfolio_summary':
        return 'Portfolio Summary';
      case 'portfolio_allocation':
        return 'Allocation';
      case 'portfolio_holdings':
        return 'Holdings';
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
      other is PortfolioWidgetConfig &&
          id == other.id &&
          visible == other.visible;

  @override
  int get hashCode => id.hashCode ^ visible.hashCode;
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class PortfolioWidgetsNotifier extends StateNotifier<List<PortfolioWidgetConfig>> {
  String? _userId;

  PortfolioWidgetsNotifier({this._userId}) : super([]) {
    _load();
  }

  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final orderKey = _orderPrefsKey(_userId);
    final visKey = _visibilityPrefsKey(_userId);

    final savedOrder = prefs.getStringList(orderKey);
    var order = savedOrder ?? _defaultPortfolioWidgetOrder;

    // Merge: append any default widgets missing from saved order
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing = _defaultPortfolioWidgetOrder.where((id) => !savedSet.contains(id));
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

    state = order.map((id) {
      final visible = visibilityMap[id] ?? true;
      return PortfolioWidgetConfig(id: id, visible: visible);
    }).toList();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _orderPrefsKey(_userId), state.map((c) => c.id).toList());
    await prefs.setString(
      _visibilityPrefsKey(_userId),
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

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

  Future<void> toggleVisibility(String id) async {
    state = state.map((c) {
      if (c.id == id) return PortfolioWidgetConfig(id: c.id, visible: !c.visible);
      return c;
    }).toList();
    await _saveLocal();
  }

  Future<void> resetToDefaults() async {
    state = _defaultPortfolioWidgetOrder
        .map((id) => PortfolioWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final portfolioWidgetsProvider =
    StateNotifierProvider<PortfolioWidgetsNotifier, List<PortfolioWidgetConfig>>((ref) {
  final user = ref.watch(currentUserProvider);
  return PortfolioWidgetsNotifier(userId: user?.id);
});
