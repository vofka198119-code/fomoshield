import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Recently Viewed — last companies opened via the company detail card.
// ---------------------------------------------------------------------------
// Not tied to the tracked-50 list — just a memory of symbol+name, capped at
// 25, FIFO eviction (re-viewing an already-listed symbol moves it to the
// front instead of duplicating it). Persisted so it survives app restarts,
// same pattern as search_counter_provider.dart.
// ---------------------------------------------------------------------------

const _maxRecentlyViewed = 25;
const _prefsKey = 'recently_viewed_companies';

class RecentlyViewedEntry {
  final String symbol;
  final String name;

  const RecentlyViewedEntry({required this.symbol, required this.name});

  Map<String, dynamic> toJson() => {'symbol': symbol, 'name': name};

  factory RecentlyViewedEntry.fromJson(Map<String, dynamic> json) =>
      RecentlyViewedEntry(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
      );
}

class RecentlyViewedNotifier extends StateNotifier<List<RecentlyViewedEntry>> {
  RecentlyViewedNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final decoded = json.decode(raw) as List;
      state = decoded
          .map(
            (e) => RecentlyViewedEntry.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      // Corrupt/old-shape entry — start fresh rather than crash.
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode(state.map((e) => e.toJson()).toList()),
    );
  }

  /// Records a company view, moving it to the front if already present.
  Future<void> recordView(String symbol, String name) async {
    final upper = symbol.toUpperCase();
    final updated = [
      RecentlyViewedEntry(symbol: upper, name: name),
      ...state.where((e) => e.symbol != upper),
    ];
    state = updated.length > _maxRecentlyViewed
        ? updated.sublist(0, _maxRecentlyViewed)
        : updated;
    await _save();
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<RecentlyViewedEntry>>(
      (ref) => RecentlyViewedNotifier(),
    );
