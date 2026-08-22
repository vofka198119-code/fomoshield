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
  'portfolio_balance',
  'portfolio_cash',
  'target',
  'portfolio_holdings',
  'trade_history',
  'my_limit_orders',
];

String _orderPrefsKey(String? uid) =>
    uid != null ? 'portfolio_widget_order_$uid' : 'portfolio_widget_order';
String _visibilityPrefsKey(String? uid) => uid != null
    ? 'portfolio_widget_visibility_$uid'
    : 'portfolio_widget_visibility';

/// Model representing a portfolio widget's configuration.
class PortfolioWidgetConfig {
  final String id;
  final bool visible;

  const PortfolioWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'portfolio_balance':
        return 'Portfolio Balance';
      case 'portfolio_cash':
        return 'Cash Available';
      case 'target':
        return 'Target';
      case 'portfolio_holdings':
        return 'Holdings';
      case 'trade_history':
        return 'Trade History';
      case 'my_limit_orders':
        return 'My Limit Orders';
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

class PortfolioWidgetsNotifier
    extends StateNotifier<List<PortfolioWidgetConfig>> {
  String? _userId;

  PortfolioWidgetsNotifier({this._userId}) : super([]) {
    _load();
  }

  // 'portfolio_balance' is pinned first — always at the top, never hidden,
  // never draggable out of position (mirrors Stress Test's own
  // 'allocation_chart' pin, see stress_test_widget_order_provider.dart).
  // Guarded here too, not just in the settings sheet UI, so it holds
  // regardless of caller.
  static const _pinnedFirstId = 'portfolio_balance';

  /// Forces the pinned id to the front regardless of whatever order it
  /// arrived in (e.g. a saved layout from before it was pinned, which
  /// would otherwise leave it wherever the merge above happens to place it).
  List<String> _normalizePinned(List<String> ids) {
    final rest = [...ids]..remove(_pinnedFirstId);
    return [_pinnedFirstId, ...rest];
  }

  /// The same default list [resetToDefaults] assigns to `state` — exposed
  /// so callers outside this class (which can't read the protected `state`
  /// field) can mirror it without hand-duplicating the widget id list.
  List<PortfolioWidgetConfig> get defaultConfigs => _defaultPortfolioWidgetOrder
      .map((id) => PortfolioWidgetConfig(id: id, visible: true))
      .toList();

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
      final missing = _defaultPortfolioWidgetOrder.where(
        (id) => !savedSet.contains(id),
      );
      if (missing.isNotEmpty) {
        order = [...savedOrder, ...missing];
      }
    }
    order = _normalizePinned(order);

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
      _orderPrefsKey(_userId),
      state.map((c) => c.id).toList(),
    );
    await prefs.setString(
      _visibilityPrefsKey(_userId),
      state.map((c) => '${c.id}:${c.visible}').join(','),
    );
  }

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

  Future<void> toggleVisibility(String id) async {
    if (id == _pinnedFirstId) return;
    state = state.map((c) {
      if (c.id == id)
        return PortfolioWidgetConfig(id: c.id, visible: !c.visible);
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

final portfolioWidgetsProvider =
    StateNotifierProvider<
      PortfolioWidgetsNotifier,
      List<PortfolioWidgetConfig>
    >((ref) {
      final user = ref.watch(currentUserProvider);
      return PortfolioWidgetsNotifier(userId: user?.id);
    });
