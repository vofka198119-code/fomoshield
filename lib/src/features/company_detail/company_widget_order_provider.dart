import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// Company Detail Widget Order Provider (SharedPreferences-backed)
// ---------------------------------------------------------------------------
// Allows reordering, hiding/showing widgets on the Company Detail screen.
// Widgets: price_header, chart, key_metrics, position, events, news, fs_score
// ---------------------------------------------------------------------------

const List<String> defaultCompanyWidgetOrder = [
  'price_header',
  'chart',
  'key_metrics',
  'fs_score',
  'position',
  'events',
  'news',
];

String _orderPrefsKey(String? uid) =>
    uid != null ? 'company_widget_order_$uid' : 'company_widget_order';
String _visibilityPrefsKey(String? uid) =>
    uid != null ? 'company_widget_visibility_$uid' : 'company_widget_visibility';

/// Model representing a company detail widget's configuration.
class CompanyWidgetConfig {
  final String id;
  final bool visible;

  const CompanyWidgetConfig({required this.id, required this.visible});

  String get displayName {
    switch (id) {
      case 'price_header':
        return 'Price & Header';
      case 'chart':
        return 'Price Chart';
      case 'key_metrics':
        return 'Key Metrics';
      case 'fs_score':
        return 'FS Score';
      case 'position':
        return 'Your Position';
      case 'events':
        return 'Upcoming Events';
      case 'news':
        return 'News';
      default:
        return id;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyWidgetConfig &&
          id == other.id &&
          visible == other.visible;

  @override
  int get hashCode => id.hashCode ^ visible.hashCode;
}

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class CompanyWidgetsNotifier extends StateNotifier<List<CompanyWidgetConfig>> {
  String? _userId;

  CompanyWidgetsNotifier({this._userId}) : super([]) {
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
    var order = savedOrder ?? defaultCompanyWidgetOrder;

    // Merge: append any default widgets missing from saved order
    if (savedOrder != null) {
      final savedSet = Set<String>.from(savedOrder);
      final missing = defaultCompanyWidgetOrder.where((id) => !savedSet.contains(id));
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
      return CompanyWidgetConfig(id: id, visible: visible);
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
      if (c.id == id) return CompanyWidgetConfig(id: c.id, visible: !c.visible);
      return c;
    }).toList();
    await _saveLocal();
  }

  Future<void> resetToDefaults() async {
    state = defaultCompanyWidgetOrder
        .map((id) => CompanyWidgetConfig(id: id, visible: true))
        .toList();
    await _saveLocal();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final companyWidgetsProvider =
    StateNotifierProvider<CompanyWidgetsNotifier, List<CompanyWidgetConfig>>((ref) {
  final user = ref.watch(currentUserProvider);
  return CompanyWidgetsNotifier(userId: user?.id);
});
